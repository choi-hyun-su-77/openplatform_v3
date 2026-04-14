package com.platform.v3.bff.port;

import java.io.InputStream;
import java.util.Map;

public interface StoragePort {
    Map<String, Object> uploadFile(String objectName, InputStream content, long size, String contentType);
    String presignedGetUrl(String objectName, int expireSeconds);
    String presignedPutUrl(String objectName, int expireSeconds);
    void deleteFile(String objectName);
}
