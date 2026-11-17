package com.example.rbac.security;

/**
 * 当前请求的登录用户上下文。
 * 注意：拦截器 afterCompletion 中必须 clear，否则线程复用会串号。
 */
public final class LoginUserHolder {

    private static final ThreadLocal<LoginUser> HOLDER = new ThreadLocal<>();

    private LoginUserHolder() {
    }

    public static void set(LoginUser user) {
        HOLDER.set(user);
    }

    public static LoginUser get() {
        return HOLDER.get();
    }

    public static LoginUser require() {
        LoginUser user = HOLDER.get();
        if (user == null) {
            throw new IllegalStateException("未获取到登录用户上下文");
        }
        return user;
    }

    public static void clear() {
        HOLDER.remove();
    }
}
