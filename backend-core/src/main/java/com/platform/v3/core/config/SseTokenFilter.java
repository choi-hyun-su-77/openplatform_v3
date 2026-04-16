package com.platform.v3.core.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;

/**
 * SSE 엔드포인트용 쿼리 토큰 → Authorization 헤더 변환 필터.
 * 브라우저 EventSource 는 커스텀 헤더를 지원하지 않으므로
 * ?token=xxx 쿼리 파라미터를 Authorization: Bearer xxx 로 변환.
 */
public class SseTokenFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String token = request.getParameter("token");
        if (token != null && !token.isBlank() && request.getHeader("Authorization") == null) {
            filterChain.doFilter(new BearerHeaderWrapper(request, token), response);
        } else {
            filterChain.doFilter(request, response);
        }
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        return !request.getServletPath().startsWith("/api/notification/subscribe");
    }

    private static class BearerHeaderWrapper extends HttpServletRequestWrapper {
        private final String token;

        BearerHeaderWrapper(HttpServletRequest request, String token) {
            super(request);
            this.token = token;
        }

        @Override
        public String getHeader(String name) {
            if ("Authorization".equalsIgnoreCase(name)) {
                return "Bearer " + token;
            }
            return super.getHeader(name);
        }

        @Override
        public Enumeration<String> getHeaders(String name) {
            if ("Authorization".equalsIgnoreCase(name)) {
                return Collections.enumeration(List.of("Bearer " + token));
            }
            return super.getHeaders(name);
        }

        @Override
        public Enumeration<String> getHeaderNames() {
            List<String> names = Collections.list(super.getHeaderNames());
            if (!names.contains("Authorization")) {
                names.add("Authorization");
            }
            return Collections.enumeration(names);
        }
    }
}
