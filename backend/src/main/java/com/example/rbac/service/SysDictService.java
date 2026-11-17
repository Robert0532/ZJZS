package com.example.rbac.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysDictData;
import com.example.rbac.entity.SysDictType;
import com.example.rbac.mapper.SysDictDataMapper;
import com.example.rbac.mapper.SysDictTypeMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SysDictService {

    private final SysDictTypeMapper typeMapper;
    private final SysDictDataMapper dataMapper;

    public Page<SysDictType> typePage(long pageNum, long pageSize, String keyword) {
        QueryWrapper<SysDictType> wrapper = new QueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like("dict_name", keyword.trim()).or().like("dict_type", keyword.trim()));
        }
        wrapper.orderByDesc("id");
        return typeMapper.selectPage(new Page<>(pageNum, pageSize), wrapper);
    }

    @Transactional(rollbackFor = Exception.class)
    public void addType(SysDictType type) {
        if (type.getDictType() == null || type.getDictType().isBlank()) {
            throw new BizException("字典类型不能为空");
        }
        if (typeMapper.selectCount(new QueryWrapper<SysDictType>().eq("dict_type", type.getDictType().trim())) > 0) {
            throw new BizException("字典类型已存在");
        }
        type.setDictType(type.getDictType().trim());
        type.setStatus(type.getStatus() == null ? "0" : type.getStatus());
        typeMapper.insert(type);
    }

    @Transactional(rollbackFor = Exception.class)
    public void updateType(SysDictType type) {
        if (type.getId() == null) {
            throw new BizException("缺少字典ID");
        }
        if (type.getDictType() != null) {
            Long count = typeMapper.selectCount(new QueryWrapper<SysDictType>()
                    .eq("dict_type", type.getDictType().trim()).ne("id", type.getId()));
            if (count > 0) {
                throw new BizException("字典类型已存在");
            }
        }
        typeMapper.updateById(type);
    }

    @Transactional(rollbackFor = Exception.class)
    public void deleteType(Long id) {
        SysDictType type = typeMapper.selectById(id);
        if (type == null) {
            throw new BizException("字典不存在");
        }
        typeMapper.deleteById(id);
        dataMapper.delete(new QueryWrapper<SysDictData>().eq("dict_type", type.getDictType()));
    }

    public List<SysDictData> dataByType(String dictType) {
        return dataMapper.selectList(new QueryWrapper<SysDictData>()
                .eq("dict_type", dictType)
                .eq("status", "0")
                .orderByAsc("order_num"));
    }

    public void addData(SysDictData data) {
        if (data.getDictType() == null || data.getDictType().isBlank()) {
            throw new BizException("字典类型不能为空");
        }
        data.setStatus(data.getStatus() == null ? "0" : data.getStatus());
        data.setOrderNum(data.getOrderNum() == null ? 0 : data.getOrderNum());
        dataMapper.insert(data);
    }

    public void updateData(SysDictData data) {
        if (data.getId() == null) {
            throw new BizException("缺少字典数据ID");
        }
        dataMapper.updateById(data);
    }

    public void deleteData(Long id) {
        dataMapper.deleteById(id);
    }
}
