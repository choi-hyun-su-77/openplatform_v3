package com.platform.v3.core.config;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * MinIO 클라이언트 설정 — backend-core 가 자료실(자체 객체 삭제·presigned 발급)
 * 등에서 직접 MinIO 와 통신하기 위한 빈 등록.
 *
 * BFF (`MinioStorageAdapter`) 와 동일한 endpoint/credential 을 공유하며,
 * application.yml 의 `minio.*` 프로퍼티로 설정한다.
 */
@Configuration
public class MinioConfig {

    @Bean
    public MinioClient minioClient(
            @Value("${minio.endpoint}") String endpoint,
            @Value("${minio.access-key}") String accessKey,
            @Value("${minio.secret-key}") String secretKey) {
        return MinioClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .build();
    }
}
