package com.example.rbac.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.entity.SysOperLog;
import com.example.rbac.mapper.SysOperLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class SysLogService {

    private final SysOperLogMapper operLogMapper;

    public Page<SysOperLog> page(long pageNum, long pageSize, String title, String operName, String status) {
        QueryWrapper<SysOperLog> wrapper = new QueryWrapper<>();
        if (title != null && !title.isBlank()) {
            wrapper.like("title", title.trim());
        }
        if (operName != null && !operName.isBlank()) {
            wrapper.like("oper_name", operName.trim());
        }
        if (status != null && !status.isBlank()) {
            wrapper.eq("status", status);
        }
        wrapper.orderByDesc("id");
        return operLogMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    public void clean() {
        operLogMapper.delete(new QueryWrapper<SysOperLog>().ge("id", 0));
    }
}
