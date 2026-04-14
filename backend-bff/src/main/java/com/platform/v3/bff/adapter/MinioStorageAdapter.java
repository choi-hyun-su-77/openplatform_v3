package com.platform.v3.bff.adapter;

import com.platform.v3.bff.port.StoragePort;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.http.Method;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.InputStream;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@Component
public class MinioStorageAdapter implements StoragePort {

    private final MinioClient client;
    private final String bucket;

    public MinioStorageAdapter(
            @Value("${bff.minio.endpoint}") String endpoint,
            @Value("${bff.minio.access-key}") String accessKey,
            @Value("${bff.minio.secret-key}") String secretKey,
            @Value("${bff.minio.bucket}") String bucket) {
        this.client = MinioClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .build();
        this.bucket = bucket;
    }

    @Override
    public Map<String, Object> uploadFile(String objectName, InputStream content, long size, String contentType) {
        try {
            client.putObject(PutObjectArgs.builder()
                    .bucket(bucket)
                    .object(objectName)
                    .stream(content, size, -1)
                    .contentType(contentType != null ? contentType : "application/octet-stream")
                    .build());
            return Map.of("bucket", bucket, "object", objectName, "size", size);
        } catch (Exception e) {
            throw new RuntimeException("MinIO upload failed: " + e.getMessage(), e);
        }
    }

    @Override
    public String presignedGetUrl(String objectName, int expireSeconds) {
        try {
            return client.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .method(Method.GET)
                    .bucket(bucket)
                    .object(objectName)
                    .expiry(expireSeconds, TimeUnit.SECONDS)
                    .build());
        } catch (Exception e) {
            throw new RuntimeException("MinIO presigned GET failed: " + e.getMessage(), e);
        }
    }

    @Override
    public String presignedPutUrl(String objectName, int expireSeconds) {
        try {
            return client.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .method(Method.PUT)
                    .bucket(bucket)
                    .object(objectName)
                    .expiry(expireSeconds, TimeUnit.SECONDS)
                    .build());
        } catch (Exception e) {
            throw new RuntimeException("MinIO presigned PUT failed: " + e.getMessage(), e);
        }
    }

    @Override
    public void deleteFile(String objectName) {
        try {
            client.removeObject(RemoveObjectArgs.builder().bucket(bucket).object(objectName).build());
        } catch (Exception e) {
            throw new RuntimeException("MinIO delete failed: " + e.getMessage(), e);
        }
    }
}
