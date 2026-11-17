package com.example.rbac.security;

import com.example.rbac.entity.SysDept;
import com.example.rbac.entity.SysRole;
import com.example.rbac.entity.SysUser;
import com.example.rbac.mapper.SysDeptMapper;
import com.example.rbac.mapper.SysMenuMapper;
import com.example.rbac.mapper.SysRoleMapper;
import com.example.rbac.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 每次请求按 userId 装配登录态：保证停用/改权限后立即生效，不依赖 token 内的旧快照。
 */
@Service
@RequiredArgsConstructor
public class LoginUserLoader {

    private final SysUserMapper userMapper;
    private final SysMenuMapper menuMapper;
    private final SysRoleMapper roleMapper;
    private final SysDeptMapper deptMapper;

    public LoginUser load(Long userId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            return null;
        }
        LoginUser lu = new LoginUser();
        lu.setUserId(user.getId());
        lu.setUsername(user.getUsername());
        lu.setNickname(user.getNickname());
        lu.setDeptId(user.getDeptId());
        lu.setStatus(user.getStatus());
        if (user.getDeptId() != null) {
            SysDept dept = deptMapper.selectById(user.getDeptId());
            lu.setDeptName(dept == null ? null : dept.getDeptName());
        }

        boolean admin = "1".equals(user.getIsAdmin());
        lu.setAdmin(admin);

        Set<String> perms = new HashSet<>();
        if (admin) {
            perms.add("*:*:*");
        } else {
            perms.addAll(menuMapper.selectPermsByUserId(userId));
        }
        lu.setPerms(perms);

        List<SysRole> roles = roleMapper.selectRolesByUserId(userId);
        lu.setRoleList(roles);
        Set<String> keys = new HashSet<>();
        for (SysRole r : roles) {
            keys.add(r.getRoleKey());
        }
        lu.setRoles(keys);
        return lu;
    }
}
