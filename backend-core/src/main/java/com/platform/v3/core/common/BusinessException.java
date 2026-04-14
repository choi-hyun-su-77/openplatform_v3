package com.platform.v3.core.common;

import org.springframework.http.HttpStatus;

public class BusinessException extends RuntimeException {
    private final HttpStatus status;
    private final String errorCode;
    private final String field;

    public BusinessException(HttpStatus status, String errorCode, String message, String field) {
        super(message);
        this.status = status;
        this.errorCode = errorCode;
        this.field = field;
    }

    public HttpStatus getStatus() { return status; }
    public String getErrorCode() { return errorCode; }
    public String getField() { return field; }

    public static BusinessException notFound(String message) {
        return new BusinessException(HttpStatus.NOT_FOUND, "NOT_FOUND", message, null);
    }

    public static BusinessException duplicate(String message, String field) {
        return new BusinessException(HttpStatus.CONFLICT, "DUPLICATE", message, field);
    }

    public static BusinessException forbidden(String message) {
        return new BusinessException(HttpStatus.FORBIDDEN, "FORBIDDEN", message, null);
    }

    public static BusinessException badRequest(String message, String field) {
        return new BusinessException(HttpStatus.BAD_REQUEST, "BAD_REQUEST", message, field);
    }
}
