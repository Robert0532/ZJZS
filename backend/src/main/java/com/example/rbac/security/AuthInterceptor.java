package com.example.rbac.security;

import com.example.rbac.common.R;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

import java.nio.charset.StandardCharsets;

@Component
@RequiredArgsConstructor
public class AuthInterceptor implements HandlerInterceptor {

    private final JwtService jwtService;
    private final LoginUserLoader loginUserLoader;
    private final ObjectMapper objectMapper;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws Exception {
        if (HttpMethod.OPTIONS.matches(request.getMethod())) {
            return true;
        }

        String header = request.getHeader("Authorization");
        String token = header != null && header.startsWith("Bearer ") ? header.substring(7).trim() : null;
        Long userId = jwtService.parseUserId(token);
        if (userId == null) {
            write(response, R.UNAUTHORIZED, "登录已失效，请重新登录");
            return false;
        }

        LoginUser loginUser = loginUserLoader.load(userId);
        if (loginUser == null) {
            write(response, R.UNAUTHORIZED, "用户不存在");
            return false;
        }
        if (!"0".equals(loginUser.getStatus())) {
            write(response, R.UNAUTHORIZED, "账号已停用");
            return false;
        }

        LoginUserHolder.set(loginUser);

        if (handler instanceof HandlerMethod handlerMethod) {
            RequiresPerm perm = handlerMethod.getMethodAnnotation(RequiresPerm.class);
            if (perm == null) {
                perm = handlerMethod.getBeanType().getAnnotation(RequiresPerm.class);
            }
            if (perm != null && !loginUser.hasPerm(perm.value())) {
                write(response, R.FORBIDDEN, "没有操作权限：" + perm.value());
                return false;
            }
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler,
                                Exception ex) {
        LoginUserHolder.clear();
    }

    private void write(HttpServletResponse response, int code, String msg) throws Exception {
        response.setStatus(code);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding(StandardCharsets.UTF_8.name());
        response.getWriter().write(objectMapper.writeValueAsString(R.fail(code, msg)));
    }
}
