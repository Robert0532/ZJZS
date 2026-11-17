package com.example.rbac.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.common.R;
import com.example.rbac.entity.SysOperLog;
import com.example.rbac.log.OperLog;
import com.example.rbac.security.RequiresPerm;
import com.example.rbac.service.SysLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/system/log")
@RequiredArgsConstructor
public class SysLogController {

    private final SysLogService logService;

    @GetMapping("/page")
    @RequiresPerm("system:log:list")
    public R<Page<SysOperLog>> page(@RequestParam(defaultValue = "1") long pageNum,
                                    @RequestParam(defaultValue = "10") long pageSize,
                                    @RequestParam(required = false) String title,
                                    @RequestParam(required = false) String operName,
                                    @RequestParam(required = false) String status) {
        return R.ok(logService.page(pageNum, pageSize, title, operName, status));
    }

    @DeleteMapping("/clean")
    @RequiresPerm("system:log:remove")
    @OperLog(title = "操作日志-清空", businessType = "DELETE")
    public R<Void> clean() {
        logService.clean();
        return R.ok();
    }
}
