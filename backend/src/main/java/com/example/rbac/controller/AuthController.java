package com.example.rbac.controller;

import com.example.rbac.common.R;
import com.example.rbac.security.LoginUserHolder;
import com.example.rbac.service.AuthService;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Data
    public static class LoginBody {
        @NotBlank(message = "用户名不能为空")
        private String username;
        @NotBlank(message = "密码不能为空")
        private String password;
    }

    @PostMapping("/login")
    public R<Map<String, Object>> login(@RequestBody LoginBody body) {
        return R.ok(authService.login(body.getUsername(), body.getPassword()));
    }

    @GetMapping("/info")
    public R<Map<String, Object>> info() {
        return R.ok(authService.info(LoginUserHolder.require().getUserId()));
    }

    @PostMapping("/logout")
    public R<Void> logout() {
        return R.ok();
    }
}
