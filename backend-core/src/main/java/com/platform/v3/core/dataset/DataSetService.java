package com.platform.v3.core.dataset;

import com.platform.v3.core.common.BusinessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;

@Service
public class DataSetService {

    private final ServiceRegistry serviceRegistry;

    public DataSetService(ServiceRegistry serviceRegistry) {
        this.serviceRegistry = serviceRegistry;
    }

    public Map<String, Object> search(String serviceName, Map<String, Object> datasets, String currentUser) {
        validate(serviceName);
        return serviceRegistry.execute(serviceName, datasets, currentUser);
    }

    @Transactional
    public Map<String, Object> save(String serviceName, Map<String, Object> datasets, String currentUser) {
        validate(serviceName);
        return serviceRegistry.execute(serviceName, datasets, currentUser);
    }

    @Transactional
    public Map<String, Object> searchAfterSave(
            String saveServiceName,
            String searchServiceName,
            Map<String, Object> datasets,
            String currentUser
    ) {
        validate(saveServiceName);
        validate(searchServiceName);
        serviceRegistry.execute(saveServiceName, datasets, currentUser);
        return serviceRegistry.execute(searchServiceName, datasets, currentUser);
    }

    private void validate(String serviceName) {
        if (serviceName == null || serviceName.isBlank()) {
            throw BusinessException.badRequest("serviceName is required", "serviceName");
        }
        if (!serviceRegistry.hasService(serviceName)) {
            throw BusinessException.notFound("Service not found: " + serviceName);
        }
    }
}
