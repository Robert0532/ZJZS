package com.example.rbac.controller;

import com.example.rbac.common.R;
import com.example.rbac.entity.SysDept;
import com.example.rbac.log.OperLog;
import com.example.rbac.security.RequiresPerm;
import com.example.rbac.service.SysDeptService;
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
@RequestMapping("/system/dept")
@RequiredArgsConstructor
public class SysDeptController {

    private final SysDeptService deptService;

    @GetMapping("/tree")
    @RequiresPerm("system:dept:list")
    public R<List<SysDept>> tree(@RequestParam(required = false) String keyword) {
        return R.ok(deptService.tree(keyword));
    }

    /** 供用户管理等下拉选择使用，不需要菜单权限 */
    @GetMapping("/options")
    public R<List<SysDept>> options() {
        return R.ok(deptService.tree(null));
    }

    @GetMapping("/{id}")
    @RequiresPerm("system:dept:query")
    public R<SysDept> detail(@PathVariable Long id) {
        return R.ok(deptService.getById(id));
    }

    @PostMapping
    @RequiresPerm("system:dept:add")
    @OperLog(title = "部门管理", businessType = "INSERT")
    public R<Void> add(@RequestBody SysDept dept) {
        deptService.add(dept);
        return R.ok();
    }

    @PutMapping
    @RequiresPerm("system:dept:edit")
    @OperLog(title = "部门管理", businessType = "UPDATE")
    public R<Void> update(@RequestBody SysDept dept) {
        deptService.update(dept);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @RequiresPerm("system:dept:remove")
    @OperLog(title = "部门管理", businessType = "DELETE")
    public R<Void> delete(@PathVariable Long id) {
        deptService.delete(id);
        return R.ok();
    }
}
