package com.example.rbac.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysRole;
import com.example.rbac.entity.SysRoleDept;
import com.example.rbac.entity.SysRoleMenu;
import com.example.rbac.entity.SysUserRole;
import com.example.rbac.mapper.SysRoleDeptMapper;
import com.example.rbac.mapper.SysRoleMapper;
import com.example.rbac.mapper.SysRoleMenuMapper;
import com.example.rbac.mapper.SysUserRoleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SysRoleService {

    private final SysRoleMapper roleMapper;
    private final SysRoleMenuMapper roleMenuMapper;
    private final SysRoleDeptMapper roleDeptMapper;
    private final SysUserRoleMapper userRoleMapper;

    public Page<SysRole> page(long pageNum, long pageSize, String roleName, String status) {
        QueryWrapper<SysRole> wrapper = new QueryWrapper<>();
        if (roleName != null && !roleName.isBlank()) {
            wrapper.and(w -> w.like("role_name", roleName.trim()).or().like("role_key", roleName.trim()));
        }
        if (status != null && !status.isBlank()) {
            wrapper.eq("status", status);
        }
        wrapper.orderByAsc("order_num").orderByAsc("id");
        return roleMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    public List<SysRole> listAll() {
        return roleMapper.selectList(new QueryWrapper<SysRole>()
                .eq("status", "0").orderByAsc("order_num"));
    }

    public SysRole getById(Long id) {
        SysRole role = roleMapper.selectById(id);
        if (role == null) {
            throw new BizException("角色不存在");
        }
        role.setMenuIds(roleMapper.selectMenuIdsByRoleId(id));
        return role;
    }

    @Transactional(rollbackFor = Exception.class)
    public void add(SysRole role) {
        validate(role, null);
        role.setStatus(role.getStatus() == null ? "0" : role.getStatus());
        role.setDataScope(role.getDataScope() == null ? "1" : role.getDataScope());
        role.setOrderNum(role.getOrderNum() == null ? 0 : role.getOrderNum());
        role.setDelFlag("0");
        roleMapper.insert(role);
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(SysRole role) {
        if (role.getId() == null) {
            throw new BizException("缺少角色ID");
        }
        if (role.getId() == 1L) {
            throw new BizException("内置超级管理员角色不允许修改");
        }
        validate(role, role.getId());
        role.setDelFlag(null);
        roleMapper.updateById(role);
    }

    private void validate(SysRole role, Long selfId) {
        if (role.getRoleName() == null || role.getRoleName().isBlank()) {
            throw new BizException("角色名称不能为空");
        }
        if (role.getRoleKey() == null || role.getRoleKey().isBlank()) {
            throw new BizException("权限字符不能为空");
        }
        QueryWrapper<SysRole> wrapper = new QueryWrapper<SysRole>().eq("role_key", role.getRoleKey().trim());
        if (selfId != null) {
            wrapper.ne("id", selfId);
        }
        if (roleMapper.selectCount(wrapper) > 0) {
            throw new BizException("权限字符已存在");
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        if (id == 1L) {
            throw new BizException("内置超级管理员角色不允许删除");
        }
        long used = userRoleMapper.selectCount(new QueryWrapper<SysUserRole>().eq("role_id", id));
        if (used > 0) {
            throw new BizException("角色已分配给用户，不允许删除");
        }
        roleMapper.deleteById(id);
        roleMenuMapper.delete(new QueryWrapper<SysRoleMenu>().eq("role_id", id));
        roleDeptMapper.delete(new QueryWrapper<SysRoleDept>().eq("role_id", id));
    }

    @Transactional(rollbackFor = Exception.class)
    public void saveMenus(Long roleId, List<Long> menuIds) {
        if (roleId == 1L) {
            throw new BizException("内置超级管理员角色拥有全部权限，无需配置");
        }
        roleMenuMapper.delete(new QueryWrapper<SysRoleMenu>().eq("role_id", roleId));
        if (menuIds == null) {
            return;
        }
        for (Long menuId : menuIds) {
            SysRoleMenu rm = new SysRoleMenu();
            rm.setRoleId(roleId);
            rm.setMenuId(menuId);
            roleMenuMapper.insert(rm);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void saveDepts(Long roleId, List<Long> deptIds) {
        roleDeptMapper.delete(new QueryWrapper<SysRoleDept>().eq("role_id", roleId));
        if (deptIds == null) {
            return;
        }
        for (Long deptId : deptIds) {
            SysRoleDept rd = new SysRoleDept();
            rd.setRoleId(roleId);
            rd.setDeptId(deptId);
            roleDeptMapper.insert(rd);
        }
    }

    public List<Long> deptIdsOf(Long roleId) {
        return new ArrayList<>(roleMapper.selectDeptIdsByRoleId(roleId));
    }
}
