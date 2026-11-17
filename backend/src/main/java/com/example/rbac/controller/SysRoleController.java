package com.example.rbac.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.common.R;
import com.example.rbac.entity.SysRole;
import com.example.rbac.log.OperLog;
import com.example.rbac.security.RequiresPerm;
import com.example.rbac.service.SysRoleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/system/role")
@RequiredArgsConstructor
public class SysRoleController {

    private final SysRoleService roleService;

    @GetMapping("/page")
    @RequiresPerm("system:role:list")
    public R<Page<SysRole>> page(@RequestParam(defaultValue = "1") long pageNum,
                                 @RequestParam(defaultValue = "10") long pageSize,
                                 @RequestParam(required = false) String roleName,
                                 @RequestParam(required = false) String status) {
        return R.ok(roleService.page(pageNum, pageSize, roleName, status));
    }

    @GetMapping("/all")
    public R<List<SysRole>> all() {
        return R.ok(roleService.listAll());
    }

    @GetMapping("/{id}")
    @RequiresPerm("system:role:query")
    public R<SysRole> detail(@PathVariable Long id) {
        return R.ok(roleService.getById(id));
    }

    @PostMapping
    @RequiresPerm("system:role:add")
    @OperLog(title = "角色管理", businessType = "INSERT")
    public R<Void> add(@RequestBody SysRole role) {
        roleService.add(role);
        if (role.getMenuIds() != null && !role.getMenuIds().isEmpty()) {
            roleService.saveMenus(role.getId(), role.getMenuIds());
        }
        if ("2".equals(role.getDataScope())) {
            roleService.saveDepts(role.getId(), role.getDeptIds());
        }
        return R.ok();
    }

    @PutMapping
    @RequiresPerm("system:role:edit")
    @OperLog(title = "角色管理", businessType = "UPDATE")
    public R<Void> update(@RequestBody SysRole role) {
        roleService.update(role);
        if (role.getMenuIds() != null) {
            roleService.saveMenus(role.getId(), role.getMenuIds());
        }
        if ("2".equals(role.getDataScope())) {
            roleService.saveDepts(role.getId(), role.getDeptIds());
        }
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @RequiresPerm("system:role:remove")
    @OperLog(title = "角色管理", businessType = "DELETE")
    public R<Void> delete(@PathVariable Long id) {
        roleService.delete(id);
        return R.ok();
    }

    @GetMapping("/{id}/menuIds")
    @RequiresPerm("system:role:query")
    public R<List<Long>> menuIds(@PathVariable Long id) {
        return R.ok(roleService.getById(id).getMenuIds());
    }

    @PutMapping("/{id}/menus")
    @RequiresPerm("system:role:edit")
    @OperLog(title = "角色管理-分配权限", businessType = "UPDATE")
    public R<Void> saveMenus(@PathVariable Long id, @RequestBody List<Long> menuIds) {
        roleService.saveMenus(id, menuIds);
        return R.ok();
    }

    @GetMapping("/{id}/deptIds")
    @RequiresPerm("system:role:query")
    public R<List<Long>> deptIds(@PathVariable Long id) {
        return R.ok(roleService.deptIdsOf(id));
    }

    @PutMapping("/{id}/depts")
    @RequiresPerm("system:role:edit")
    @OperLog(title = "角色管理-数据权限", businessType = "UPDATE")
    public R<Void> saveDepts(@PathVariable Long id, @RequestBody List<Long> deptIds) {
        roleService.saveDepts(id, deptIds);
        return R.ok();
    }
}
