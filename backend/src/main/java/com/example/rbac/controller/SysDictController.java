package com.example.rbac.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.common.R;
import com.example.rbac.entity.SysDictData;
import com.example.rbac.entity.SysDictType;
import com.example.rbac.log.OperLog;
import com.example.rbac.security.RequiresPerm;
import com.example.rbac.service.SysDictService;
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
@RequestMapping("/system/dict")
@RequiredArgsConstructor
public class SysDictController {

    private final SysDictService dictService;

    @GetMapping("/type/page")
    @RequiresPerm("system:dict:list")
    public R<Page<SysDictType>> typePage(@RequestParam(defaultValue = "1") long pageNum,
                                         @RequestParam(defaultValue = "10") long pageSize,
                                         @RequestParam(required = false) String keyword) {
        return R.ok(dictService.typePage(pageNum, pageSize, keyword));
    }

    @PostMapping("/type")
    @RequiresPerm("system:dict:add")
    @OperLog(title = "字典管理", businessType = "INSERT")
    public R<Void> addType(@RequestBody SysDictType type) {
        dictService.addType(type);
        return R.ok();
    }

    @PutMapping("/type")
    @RequiresPerm("system:dict:edit")
    @OperLog(title = "字典管理", businessType = "UPDATE")
    public R<Void> updateType(@RequestBody SysDictType type) {
        dictService.updateType(type);
        return R.ok();
    }

    @DeleteMapping("/type/{id}")
    @RequiresPerm("system:dict:remove")
    @OperLog(title = "字典管理", businessType = "DELETE")
    public R<Void> deleteType(@PathVariable Long id) {
        dictService.deleteType(id);
        return R.ok();
    }

    /** 字典数据，前端下拉框使用，不校验菜单权限 */
    @GetMapping("/data/{dictType}")
    public R<List<SysDictData>> data(@PathVariable String dictType) {
        return R.ok(dictService.dataByType(dictType));
    }

    @PostMapping("/data")
    @RequiresPerm("system:dict:add")
    @OperLog(title = "字典数据", businessType = "INSERT")
    public R<Void> addData(@RequestBody SysDictData data) {
        dictService.addData(data);
        return R.ok();
    }

    @PutMapping("/data")
    @RequiresPerm("system:dict:edit")
    @OperLog(title = "字典数据", businessType = "UPDATE")
    public R<Void> updateData(@RequestBody SysDictData data) {
        dictService.updateData(data);
        return R.ok();
    }

    @DeleteMapping("/data/{id}")
    @RequiresPerm("system:dict:remove")
    @OperLog(title = "字典数据", businessType = "DELETE")
    public R<Void> deleteData(@PathVariable Long id) {
        dictService.deleteData(id);
        return R.ok();
    }
}
