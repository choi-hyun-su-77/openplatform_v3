package com.platform.v3.core.dataset;

import com.platform.v3.core.common.BusinessException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.aop.support.AopUtils;
import org.springframework.beans.factory.SmartInitializingSingleton;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * ApplicationContext 기동 완료 후 모든 Bean 을 스캔하여
 * {@link DataSetServiceMapping} 어노테이션이 붙은 메서드를 레지스트리에 등록.
 */
@Component
public class ServiceRegistry implements SmartInitializingSingleton {

    private static final Logger log = LoggerFactory.getLogger(ServiceRegistry.class);

    private final ApplicationContext applicationContext;
    private final Map<String, ServiceMethodHolder> registry = new ConcurrentHashMap<>();

    public ServiceRegistry(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
    }

    @Override
    public void afterSingletonsInstantiated() {
        for (String beanName : applicationContext.getBeanDefinitionNames()) {
            Object bean;
            try {
                bean = applicationContext.getBean(beanName);
            } catch (Exception e) {
                continue;
            }
            Class<?> beanClass = AopUtils.getTargetClass(bean);
            for (Method method : beanClass.getDeclaredMethods()) {
                DataSetServiceMapping mapping = method.getAnnotation(DataSetServiceMapping.class);
                if (mapping == null) continue;
                String key = mapping.value();
                if (registry.containsKey(key)) {
                    throw new IllegalStateException("Duplicate DataSetServiceMapping: " + key);
                }
                method.setAccessible(true);
                registry.put(key, new ServiceMethodHolder(bean, method));
                log.info("DataSet service registered: {} -> {}#{}", key, beanClass.getSimpleName(), method.getName());
            }
        }
        log.info("ServiceRegistry initialized with {} services", registry.size());
    }

    public boolean hasService(String serviceName) {
        return registry.containsKey(serviceName);
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> execute(String serviceName, Map<String, Object> datasets, String currentUser) {
        ServiceMethodHolder holder = registry.get(serviceName);
        if (holder == null) {
            throw BusinessException.notFound("Service not found: " + serviceName);
        }
        try {
            Object result = holder.method().invoke(holder.bean(), datasets, currentUser);
            if (result == null) return Map.of();
            if (result instanceof Map<?, ?> map) return (Map<String, Object>) map;
            throw new IllegalStateException("DataSet service must return Map<String,Object>: " + serviceName);
        } catch (InvocationTargetException e) {
            Throwable cause = e.getCause();
            if (cause instanceof RuntimeException re) throw re;
            throw new RuntimeException(cause);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        }
    }

    public record ServiceMethodHolder(Object bean, Method method) {}
}
