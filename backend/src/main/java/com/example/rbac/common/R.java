package com.example.rbac.common;

import lombok.Data;

import java.io.Serializable;

@Data
public class R<T> implements Serializable {

    public static final int SUCCESS = 200;
    public static final int FAIL = 500;
    public static final int UNAUTHORIZED = 401;
    public static final int FORBIDDEN = 403;

    private int code;
    private String msg;
    private T data;

    public static <T> R<T> ok() {
        return build(SUCCESS, "操作成功", null);
    }

    public static <T> R<T> ok(T data) {
        return build(SUCCESS, "操作成功", data);
    }

    public static <T> R<T> ok(String msg, T data) {
        return build(SUCCESS, msg, data);
    }

    public static <T> R<T> fail(String msg) {
        return build(FAIL, msg, null);
    }

    public static <T> R<T> fail(int code, String msg) {
        return build(code, msg, null);
    }

    private static <T> R<T> build(int code, String msg, T data) {
        R<T> r = new R<>();
        r.setCode(code);
        r.setMsg(msg);
        r.setData(data);
        return r;
    }
}
