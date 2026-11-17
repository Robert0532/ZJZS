package com.example.rbac.controller;

import com.example.rbac.common.R;
import com.example.rbac.entity.SysMenu;
import com.example.rbac.log.OperLog;
import com.example.rbac.security.RequiresPerm;
import com.example.rbac.service.SysMenuService;
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
@RequestMapping("/system/menu")
@RequiredArgsConstructor
public class SysMenuController {

    private final SysMenuService menuService;

    @GetMapping("/tree")
    @RequiresPerm("system:menu:list")
    public R<List<SysMenu>> tree(@RequestParam(required = false) String keyword) {
        return R.ok(menuService.tree(keyword));
    }

    @GetMapping("/list")
    public R<List<SysMenu>> list(@RequestParam(required = false) String keyword) {
        return R.ok(menuService.listAll(keyword));
    }

    @GetMapping("/{id}")
    @RequiresPerm("system:menu:query")
    public R<SysMenu> detail(@PathVariable Long id) {
        return R.ok(menuService.getById(id));
    }

    @PostMapping
    @RequiresPerm("system:menu:add")
    @OperLog(title = "菜单管理", businessType = "INSERT")
    public R<Void> add(@RequestBody SysMenu menu) {
        menuService.add(menu);
        return R.ok();
    }

    @PutMapping
    @RequiresPerm("system:menu:edit")
    @OperLog(title = "菜单管理", businessType = "UPDATE")
    public R<Void> update(@RequestBody SysMenu menu) {
        menuService.update(menu);
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @RequiresPerm("system:menu:remove")
    @OperLog(title = "菜单管理", businessType = "DELETE")
    public R<Void> delete(@PathVariable Long id) {
        menuService.delete(id);
        return R.ok();
    }
}
