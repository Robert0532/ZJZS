package com.example.rbac.service;

import cn.hutool.crypto.digest.BCrypt;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysDept;
import com.example.rbac.entity.SysUser;
import com.example.rbac.entity.SysUserRole;
import com.example.rbac.mapper.SysDeptMapper;
import com.example.rbac.mapper.SysUserMapper;
import com.example.rbac.mapper.SysUserRoleMapper;
import com.example.rbac.security.DataScopeHelper;
import com.example.rbac.security.LoginUserHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SysUserService {

    public static final String DEFAULT_PASSWORD = "123456";

    private final SysUserMapper userMapper;
    private final SysUserRoleMapper userRoleMapper;
    private final SysDeptMapper deptMapper;
    private final DataScopeHelper dataScopeHelper;

    public Page<SysUser> page(long pageNum, long pageSize, String username, String status, Long deptId) {
        QueryWrapper<SysUser> wrapper = new QueryWrapper<>();
        dataScopeHelper.apply(wrapper, "dept_id", "id");
        if (username != null && !username.isBlank()) {
            wrapper.and(w -> w.like("username", username.trim()).or().like("nickname", username.trim()));
        }
        if (status != null && !status.isBlank()) {
            wrapper.eq("status", status);
        }
        if (deptId != null) {
            List<Long> deptIds = deptId == 0L ? new ArrayList<>() : deptMapper.selectSelfAndChildIds(deptId);
            if (deptIds.isEmpty()) {
                wrapper.eq("dept_id", deptId);
            } else {
                wrapper.in("dept_id", deptIds);
            }
        }
        wrapper.orderByDesc("id");

        Page<SysUser> page = userMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
        fillDeptName(page.getRecords());
        return page;
    }

    private void fillDeptName(List<SysUser> users) {
        if (users.isEmpty()) {
            return;
        }
        List<SysDept> depts = deptMapper.selectList(null);
        Map<Long, String> nameMap = new HashMap<>();
        for (SysDept dept : depts) {
            nameMap.put(dept.getId(), dept.getDeptName());
        }
        for (SysUser user : users) {
            user.setDeptName(nameMap.get(user.getDeptId()));
        }
    }

    /** 带数据权限校验的读取：越权访问他人/他部门用户会直接报错 */
    public SysUser getById(Long id) {
        QueryWrapper<SysUser> wrapper = new QueryWrapper<>();
        dataScopeHelper.apply(wrapper, "dept_id", "id");
        wrapper.eq("id", id);
        SysUser user = userMapper.selectOne(wrapper);
        if (user == null) {
            throw new BizException(com.example.rbac.common.R.FORBIDDEN, "用户不存在或无权操作");
        }
        if (user.getDeptId() != null) {
            SysDept dept = deptMapper.selectById(user.getDeptId());
            user.setDeptName(dept == null ? null : dept.getDeptName());
        }
        return user;
    }

    @Transactional(rollbackFor = Exception.class)
    public void add(SysUser user, List<Long> roleIds) {
        if (user.getUsername() == null || user.getUsername().isBlank()) {
            throw new BizException("用户名不能为空");
        }
        if (user.getNickname() == null || user.getNickname().isBlank()) {
            throw new BizException("用户昵称不能为空");
        }
        checkUsernameUnique(user.getUsername().trim(), null);
        if (user.getDeptId() == null) {
            throw new BizException("请选择所属部门");
        }
        String raw = (user.getPassword() == null || user.getPassword().isBlank())
                ? DEFAULT_PASSWORD : user.getPassword();
        user.setPassword(BCrypt.hashpw(raw));
        user.setStatus(user.getStatus() == null ? "0" : user.getStatus());
        user.setIsAdmin("0");
        user.setDelFlag("0");
        user.setUsername(user.getUsername().trim());
        userMapper.insert(user);
        saveUserRoles(user.getId(), roleIds);
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(SysUser user, List<Long> roleIds) {
        if (user.getId() == null) {
            throw new BizException("缺少用户ID");
        }
        SysUser exist = getById(user.getId());
        if (user.getUsername() != null && !user.getUsername().isBlank()) {
            checkUsernameUnique(user.getUsername().trim(), user.getId());
        }
        // 密码不允许从这个接口改，统一走重置密码
        user.setPassword(null);
        user.setIsAdmin(null);
        user.setUsername(user.getUsername() == null ? null : user.getUsername().trim());
        user.setDelFlag(null);
        if ("1".equals(exist.getIsAdmin())) {
            user.setDeptId(null);
            user.setStatus(null);
            user.setUsername(null);
        }
        userMapper.updateById(user);
        if (roleIds != null) {
            saveUserRoles(user.getId(), roleIds);
        }
    }

    private void checkUsernameUnique(String username, Long selfId) {
        QueryWrapper<SysUser> wrapper = new QueryWrapper<SysUser>().eq("username", username);
        if (selfId != null) {
            wrapper.ne("id", selfId);
        }
        if (userMapper.selectCount(wrapper) > 0) {
            throw new BizException("用户名已存在");
        }
    }

    private void saveUserRoles(Long userId, List<Long> roleIds) {
        userRoleMapper.delete(new QueryWrapper<SysUserRole>().eq("user_id", userId));
        if (roleIds == null || roleIds.isEmpty()) {
            return;
        }
        for (Long roleId : roleIds) {
            SysUserRole ur = new SysUserRole();
            ur.setUserId(userId);
            ur.setRoleId(roleId);
            userRoleMapper.insert(ur);
        }
    }

    /** 防止用户改自己的权限后把自己锁在门外 */
    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        Long currentId = LoginUserHolder.get().getUserId();
        if (id.equals(currentId)) {
            throw new BizException("不能删除当前登录用户");
        }
        SysUser user = getById(id);
        if ("1".equals(user.getIsAdmin())) {
            throw new BizException("超级管理员不允许删除");
        }
        userMapper.deleteById(id);
        userRoleMapper.delete(new QueryWrapper<SysUserRole>().eq("user_id", id));
    }

    public void resetPassword(Long id, String rawPassword) {
        if (rawPassword == null || rawPassword.length() < 6) {
            throw new BizException("密码长度不能少于6位");
        }
        getById(id);
        SysUser user = new SysUser();
        user.setId(id);
        user.setPassword(BCrypt.hashpw(rawPassword));
        userMapper.updateById(user);
    }

    public void changeStatus(Long id, String status) {
        SysUser exist = getById(id);
        if ("1".equals(exist.getIsAdmin()) && "1".equals(status)) {
            throw new BizException("超级管理员不允许停用");
        }
        SysUser user = new SysUser();
        user.setId(id);
        user.setStatus(status);
        userMapper.updateById(user);
    }

    public List<Long> roleIdsOf(Long userId) {
        List<SysUserRole> list = userRoleMapper.selectList(
                new QueryWrapper<SysUserRole>().eq("user_id", userId));
        List<Long> ids = new ArrayList<>();
        for (SysUserRole ur : list) {
            ids.add(ur.getRoleId());
        }
        return ids;
    }
}
