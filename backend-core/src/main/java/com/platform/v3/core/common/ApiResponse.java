package com.platform.v3.core.common;

import java.util.List;

public record ApiResponse<T>(
        boolean success,
        T data,
        String message,
        ErrorDetail error,
        List<FieldError> errors
) {
    public static <T> ApiResponse<T> ok(T data) {
        return new ApiResponse<>(true, data, null, null, null);
    }

    public static <T> ApiResponse<T> ok(T data, String message) {
        return new ApiResponse<>(true, data, message, null, null);
    }

    public static <T> ApiResponse<T> fail(String code, String message) {
        return new ApiResponse<>(false, null, message, new ErrorDetail(code, null), null);
    }

    public static <T> ApiResponse<T> fail(String code, String message, String field) {
        return new ApiResponse<>(false, null, message, new ErrorDetail(code, field), null);
    }

    public static <T> ApiResponse<T> validationFail(List<FieldError> errors) {
        return new ApiResponse<>(false, null, "validation failed", new ErrorDetail("VALIDATION", null), errors);
    }

    public record ErrorDetail(String code, String field) {}
    public record FieldError(String field, String message, Object rejectedValue) {}
}
