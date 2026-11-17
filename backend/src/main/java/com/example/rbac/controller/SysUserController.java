package com.example.rbac.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.common.R;
import com.example.rbac.entity.SysUser;
import com.example.rbac.log.OperLog;
import com.example.rbac.security.RequiresPerm;
import com.example.rbac.service.SysUserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/system/user")
@RequiredArgsConstructor
public class SysUserController {

    private final SysUserService userService;

    @GetMapping("/page")
    @RequiresPerm("system:user:list")
    public R<Page<SysUser>> page(@RequestParam(defaultValue = "1") long pageNum,
                                 @RequestParam(defaultValue = "10") long pageSize,
                                 @RequestParam(required = false) String username,
                                 @RequestParam(required = false) String status,
                                 @RequestParam(required = false) Long deptId) {
        return R.ok(userService.page(pageNum, pageSize, username, status, deptId));
    }

    @GetMapping("/{id}")
    @RequiresPerm("system:user:query")
    public R<SysUser> detail(@PathVariable Long id) {
        SysUser user = userService.getById(id);
        user.setRoleIds(userService.roleIdsOf(id));
        return R.ok(user);
    }

    @PostMapping
    @RequiresPerm("system:user:add")
    @OperLog(title = "用户管理", businessType = "INSERT")
    public R<Void> add(@RequestBody SysUser user) {
        userService.add(user, user.getRoleIds());
        return R.ok();
    }

    @PutMapping
    @RequiresPerm("system:user:edit")
    @OperLog(title = "用户管理", businessType = "UPDATE")
    public R<Void> update(@RequestBody SysUser user) {
        userService.update(user, user.getRoleIds());
        return R.ok();
    }

    @DeleteMapping("/{id}")
    @RequiresPerm("system:user:remove")
    @OperLog(title = "用户管理", businessType = "DELETE")
    public R<Void> delete(@PathVariable Long id) {
        userService.delete(id);
        return R.ok();
    }

    @PutMapping("/{id}/password")
    @RequiresPerm("system:user:resetPwd")
    @OperLog(title = "用户管理-重置密码", businessType = "UPDATE")
    public R<Void> resetPassword(@PathVariable Long id, @RequestParam String password) {
        userService.resetPassword(id, password);
        return R.ok();
    }

    @PutMapping("/{id}/status")
    @RequiresPerm("system:user:edit")
    @OperLog(title = "用户管理-状态变更", businessType = "UPDATE")
    public R<Void> changeStatus(@PathVariable Long id, @RequestParam String status) {
        userService.changeStatus(id, status);
        return R.ok();
    }

    @GetMapping("/export")
    @RequiresPerm("system:user:export")
    @OperLog(title = "用户管理-导出", businessType = "EXPORT")
    public ResponseEntity<byte[]> export(@RequestParam(required = false) String username,
                                         @RequestParam(required = false) String status) {
        Page<SysUser> page = userService.page(1, 5000, username, status, null);
        StringBuilder sb = new StringBuilder();
        sb.append("ID,用户名,昵称,部门,手机号,状态,创建时间\n");
        for (SysUser u : page.getRecords()) {
            sb.append(csv(u.getId())).append(',')
                    .append(csv(u.getUsername())).append(',')
                    .append(csv(u.getNickname())).append(',')
                    .append(csv(u.getDeptName())).append(',')
                    .append(csv(u.getPhone())).append(',')
                    .append(csv("0".equals(u.getStatus()) ? "正常" : "停用")).append(',')
                    .append(csv(u.getCreateTime() == null ? "" : u.getCreateTime().toString()))
                    .append('\n');
        }
        byte[] bom = new byte[]{(byte) 0xEF, (byte) 0xBB, (byte) 0xBF};
        byte[] body = sb.toString().getBytes(StandardCharsets.UTF_8);
        byte[] out = new byte[bom.length + body.length];
        System.arraycopy(bom, 0, out, 0, bom.length);
        System.arraycopy(body, 0, out, bom.length, body.length);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=users.csv")
                .contentType(MediaType.parseMediaType("text/csv;charset=UTF-8"))
                .body(out);
    }

    private String csv(Object value) {
        if (value == null) {
            return "";
        }
        String s = String.valueOf(value).replace("\"", "\"\"");
        return "\"" + s + "\"";
    }
}
