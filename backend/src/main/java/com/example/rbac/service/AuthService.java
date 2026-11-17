package com.example.rbac.service;

import cn.hutool.crypto.digest.BCrypt;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysMenu;
import com.example.rbac.entity.SysUser;
import com.example.rbac.mapper.SysMenuMapper;
import com.example.rbac.mapper.SysUserMapper;
import com.example.rbac.security.JwtService;
import com.example.rbac.security.LoginUser;
import com.example.rbac.security.LoginUserLoader;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final SysUserMapper userMapper;
    private final SysMenuMapper menuMapper;
    private final JwtService jwtService;
    private final LoginUserLoader loginUserLoader;
    private final SysMenuService menuService;

    public Map<String, Object> login(String username, String password) {
        if (username == null || username.isBlank() || password == null || password.isBlank()) {
            throw new BizException("用户名和密码不能为空");
        }
        SysUser user = userMapper.selectOne(
                new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<SysUser>()
                        .eq("username", username.trim()));
        if (user == null) {
            throw new BizException("用户名或密码错误");
        }
        if (!"0".equals(user.getStatus())) {
            throw new BizException("账号已停用");
        }
        if (!BCrypt.checkpw(password, user.getPassword())) {
            throw new BizException("用户名或密码错误");
        }
        String token = jwtService.createToken(user.getId());
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("token", token);
        data.put("expireHours", jwtService.getExpireHours());
        return data;
    }

    public Map<String, Object> info(Long userId) {
        LoginUser loginUser = loginUserLoader.load(userId);
        if (loginUser == null) {
            throw new BizException("用户不存在");
        }
        List<SysMenu> menus;
        if (loginUser.isAdmin()) {
            menus = menuMapper.selectList(
                    new com.baomidou.mybatisplus.core.conditions.query.QueryWrapper<SysMenu>()
                            .in("menu_type", List.of("M", "C"))
                            .eq("status", "0")
                            .eq("visible", "0")
                            .orderByAsc("parent_id", "order_num"));
        } else {
            menus = menuMapper.selectMenusByUserId(userId);
        }

        Map<String, Object> user = new LinkedHashMap<>();
        user.put("userId", loginUser.getUserId());
        user.put("username", loginUser.getUsername());
        user.put("nickname", loginUser.getNickname());
        user.put("deptId", loginUser.getDeptId());
        user.put("deptName", loginUser.getDeptName());
        user.put("admin", loginUser.isAdmin());

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("user", user);
        data.put("roles", new ArrayList<>(loginUser.getRoles()));
        data.put("perms", new ArrayList<>(loginUser.getPerms()));
        data.put("menus", menuService.buildTree(menus));
        return data;
    }
}
