package com.example.rbac.common;

public class BizException extends RuntimeException {

    private final int code;

    public BizException(String message) {
        super(message);
        this.code = R.FAIL;
    }

    public BizException(int code, String message) {
        super(message);
        this.code = code;
    }

    public int getCode() {
        return code;
    }
}
