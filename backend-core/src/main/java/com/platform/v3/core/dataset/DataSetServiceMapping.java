package com.platform.v3.core.dataset;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * DataSet 단일 진입점에서 serviceName 으로 호출될 메서드에 부착.
 * 예: {@code @DataSetServiceMapping("org/searchDeptTree")}
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface DataSetServiceMapping {
    String value();
}
