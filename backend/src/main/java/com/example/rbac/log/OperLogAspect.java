package com.example.rbac.log;

import com.example.rbac.entity.SysOperLog;
import com.example.rbac.mapper.SysOperLogMapper;
import com.example.rbac.security.LoginUser;
import com.example.rbac.security.LoginUserHolder;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 操作日志切面。日志写入失败不得影响主流程。
 */
@Slf4j
@Aspect
@Component
@RequiredArgsConstructor
public class OperLogAspect {

    private final SysOperLogMapper operLogMapper;
    private final ObjectMapper objectMapper;

    @Around("@annotation(operLog)")
    public Object around(ProceedingJoinPoint point, OperLog operLog) throws Throwable {
        long start = System.currentTimeMillis();
        String errorMsg = null;
        String status = "0";
        Object result = null;
        try {
            result = point.proceed();
            return result;
        } catch (Throwable e) {
            status = "1";
            errorMsg = e.getMessage();
            throw e;
        } finally {
            try {
                save(point, operLog, result, status, errorMsg, System.currentTimeMillis() - start);
            } catch (Exception e) {
                log.warn("写操作日志失败: {}", e.getMessage());
            }
        }
    }

    private void save(ProceedingJoinPoint point, OperLog operLog, Object result,
                      String status, String errorMsg, long cost) {
        SysOperLog entity = new SysOperLog();
        entity.setTitle(operLog.title());
        entity.setBusinessType(operLog.businessType());
        MethodSignature signature = (MethodSignature) point.getSignature();
        entity.setMethod(signature.getDeclaringTypeName() + "." + signature.getName());
        entity.setOperParam(truncate(toJson(safeArgs(point.getArgs())), 2000));
        entity.setJsonResult(truncate(toJson(result), 2000));
        entity.setStatus(status);
        entity.setErrorMsg(truncate(errorMsg, 500));
        entity.setCostTime(cost);
        entity.setOperTime(LocalDateTime.now());

        LoginUser user = LoginUserHolder.get();
        if (user != null) {
            entity.setOperName(user.getUsername());
            entity.setDeptName(user.getDeptName());
        }

        ServletRequestAttributes attrs =
                (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs != null) {
            HttpServletRequest request = attrs.getRequest();
            entity.setRequestMethod(request.getMethod());
            entity.setOperUrl(truncate(request.getRequestURI(), 255));
            entity.setOperIp(clientIp(request));
        }
        operLogMapper.insert(entity);
    }

    private Object[] safeArgs(Object[] args) {
        if (args == null) {
            return new Object[0];
        }
        List<Object> list = new ArrayList<>();
        Arrays.stream(args).forEach(a -> {
            if (a == null) {
                return;
            }
            String name = a.getClass().getName();
            if (a instanceof MultipartFile || name.startsWith("jakarta.servlet")
                    || name.startsWith("org.springframework.web")) {
                return;
            }
            list.add(a);
        });
        return list.toArray();
    }

    private String toJson(Object value) {
        if (value == null) {
            return null;
        }
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception e) {
            return String.valueOf(value);
        }
    }

    private String truncate(String value, int max) {
        if (value == null) {
            return null;
        }
        return value.length() <= max ? value : value.substring(0, max);
    }

    private String clientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isBlank() && !"unknown".equalsIgnoreCase(ip)) {
            return ip.split(",")[0].trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isBlank() && !"unknown".equalsIgnoreCase(ip)) {
            return ip;
        }
        return request.getRemoteAddr();
    }
}
