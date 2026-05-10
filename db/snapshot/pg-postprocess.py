"""
PostgreSQL data.sql post-processor: convert pg_dump --on-conflict-do-nothing
output into true MERGE/UPSERT statements.

Input pattern (from pg_dump --column-inserts --on-conflict-do-nothing):
    INSERT INTO public.fw_user (id, name, email)
    VALUES (1, 'foo', 'foo@x.com') ON CONFLICT DO NOTHING;

Output pattern (per-table — ON CONFLICT (pk) DO UPDATE SET non_pk_cols = EXCLUDED.non_pk_cols):
    INSERT INTO public.fw_user (id, name, email)
    VALUES (1, 'foo', 'foo@x.com')
    ON CONFLICT ("id") DO UPDATE SET "name" = EXCLUDED."name", "email" = EXCLUDED."email";

For all-PK tables (e.g., association tables): keep DO NOTHING (no non-PK to update).
For tables without PK: keep DO NOTHING (can't define a conflict target).

Usage (run inside python:3.12-slim container with psycopg installed):
    DB_HOST=... DB_PORT=5432 DB_NAME=... DB_USER=... DB_PASSWORD=... DB_SCHEMA=public \\
        python pg-postprocess.py < input.sql > output.sql
"""
from __future__ import annotations

import os
import re
import sys

import psycopg


def build_pk_map(schema: str) -> dict[str, list[str]]:
    """Query information_schema for table → ordered PK columns."""
    conn = psycopg.connect(
        host=os.environ["DB_HOST"],
        port=int(os.environ.get("DB_PORT", "5432")),
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
    )
    pk_map: dict[str, list[str]] = {}
    with conn, conn.cursor() as cur:
        cur.execute(
            """
            SELECT kcu.table_name, kcu.column_name
            FROM information_schema.table_constraints tc
            JOIN information_schema.key_column_usage kcu
              ON kcu.constraint_name = tc.constraint_name
             AND kcu.table_schema    = tc.table_schema
             AND kcu.table_name      = tc.table_name
            WHERE tc.constraint_type = 'PRIMARY KEY'
              AND tc.table_schema    = %s
            ORDER BY kcu.table_name, kcu.ordinal_position
            """,
            (schema,),
        )
        for table, col in cur.fetchall():
            pk_map.setdefault(table, []).append(col)
    return pk_map


# Captures: (1) the body up to and including the closing ')' of VALUES,
#           (2) the table name (last identifier after schema dot, optional quotes),
#           (3) the column list inside the first parens.
INSERT_RE = re.compile(
    r"^(INSERT INTO\s+(?:\"?[\w]+\"?\.)?\"?(\w+)\"?\s*\(([^)]+)\)\s+VALUES\s+.+?\))"
    r"\s+ON CONFLICT DO NOTHING;\s*$",
    re.DOTALL,
)


def transform(stmt: str, pk_map: dict[str, list[str]]) -> str:
    m = INSERT_RE.match(stmt)
    if not m:
        return stmt  # not an INSERT (sequences, comments, etc.) — pass through
    body, table, cols_str = m.group(1), m.group(2), m.group(3)
    cols = [c.strip().strip('"') for c in cols_str.split(",")]
    pks = pk_map.get(table, [])
    if not pks:
        # No PK — keep DO NOTHING (can't define conflict target without PK)
        return stmt
    non_pk = [c for c in cols if c not in pks]
    if not non_pk:
        # All-PK table (association table) — DO NOTHING is correct
        return stmt
    set_clause = ", ".join(f'"{c}" = EXCLUDED."{c}"' for c in non_pk)
    pk_str = ", ".join(f'"{c}"' for c in pks)
    return f"{body} ON CONFLICT ({pk_str}) DO UPDATE SET {set_clause};\n"


def main() -> int:
    schema = os.environ.get("DB_SCHEMA", "public")
    pk_map = build_pk_map(schema)
    print(f"[pg-postprocess] PK map for schema '{schema}': {len(pk_map)} tables", file=sys.stderr)

    # Process input statement-by-statement (statements end with ';\n')
    buffer: list[str] = []
    transformed = 0
    do_nothing_kept = 0
    for line in sys.stdin:
        buffer.append(line)
        s = "".join(buffer)
        if not s.rstrip().endswith(";"):
            continue
        out = transform(s, pk_map)
        if out is not s and "DO UPDATE SET" in out:
            transformed += 1
        elif "ON CONFLICT DO NOTHING" in out and out.startswith("INSERT INTO"):
            do_nothing_kept += 1
        sys.stdout.write(out)
        buffer = []
    if buffer:
        sys.stdout.write("".join(buffer))

    print(
        f"[pg-postprocess] transformed {transformed} INSERTs to UPSERT, "
        f"kept {do_nothing_kept} DO NOTHING (all-PK or no-PK tables)",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
