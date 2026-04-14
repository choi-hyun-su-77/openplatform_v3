package com.platform.v3.core.config;

import org.apache.ibatis.executor.resultset.ResultSetHandler;
import org.apache.ibatis.plugin.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.sql.Statement;
import java.util.*;

/**
 * MyBatis 전역 설정:
 * 1) Map 반환 쿼리의 snake_case 컬럼명을 camelCase 로 자동 변환 (Interceptor)
 */
@Configuration
public class MyBatisConfig {

    @Bean
    public CamelCaseMapInterceptor camelCaseMapInterceptor() {
        return new CamelCaseMapInterceptor();
    }

    @Intercepts({
            @Signature(type = ResultSetHandler.class, method = "handleResultSets", args = {Statement.class})
    })
    public static class CamelCaseMapInterceptor implements Interceptor {

        @Override
        public Object intercept(Invocation invocation) throws Throwable {
            Object result = invocation.proceed();
            if (result instanceof List<?> list) {
                for (Object item : list) {
                    convertInPlace(item);
                }
            }
            return result;
        }

        @SuppressWarnings("unchecked")
        private static void convertInPlace(Object item) {
            if (item instanceof Map<?, ?> raw) {
                Map<String, Object> map = (Map<String, Object>) raw;
                List<String> keys = new ArrayList<>(map.keySet());
                for (String key : keys) {
                    if (key == null) continue;
                    String camel = toCamel(key);
                    if (!camel.equals(key)) {
                        Object v = map.remove(key);
                        map.put(camel, v);
                    }
                }
                for (Object v : map.values()) {
                    convertInPlace(v);
                }
            } else if (item instanceof List<?> sub) {
                for (Object s : sub) convertInPlace(s);
            }
        }

        private static String toCamel(String s) {
            if (s == null || s.indexOf('_') < 0) return s;
            StringBuilder sb = new StringBuilder(s.length());
            boolean upper = false;
            for (int i = 0; i < s.length(); i++) {
                char c = s.charAt(i);
                if (c == '_') { upper = true; continue; }
                sb.append(upper ? Character.toUpperCase(c) : c);
                upper = false;
            }
            return sb.toString();
        }
    }
}
