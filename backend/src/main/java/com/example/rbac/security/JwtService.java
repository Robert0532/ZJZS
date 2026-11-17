package com.example.rbac.security;

import cn.hutool.jwt.JWT;
import cn.hutool.jwt.JWTUtil;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtService {

    @Value("${app.jwt.secret}")
    private String secret;

    @Value("${app.jwt.expire-hours}")
    private long expireHours;

    private byte[] key() {
        return secret.getBytes(StandardCharsets.UTF_8);
    }

    public String createToken(Long userId) {
        long now = System.currentTimeMillis();
        return JWT.create()
                .setPayload("uid", String.valueOf(userId))
                .setIssuedAt(new Date(now))
                .setExpiresAt(new Date(now + expireHours * 3600_000L))
                .setKey(key())
                .sign();
    }

    /**
     * @return 解析成功返回 userId，失败返回 null
     */
    public Long parseUserId(String token) {
        try {
            if (token == null || token.isEmpty()) {
                return null;
            }
            if (!JWTUtil.verify(token, key())) {
                return null;
            }
            JWT jwt = JWTUtil.parseToken(token);
            Object uid = jwt.getPayload("uid");
            return uid == null ? null : Long.valueOf(uid.toString());
        } catch (Exception e) {
            return null;
        }
    }

    public long getExpireHours() {
        return expireHours;
    }
}
