package com.example.rbac.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysDept;
import com.example.rbac.mapper.SysDeptMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SysDeptService {

    private final SysDeptMapper deptMapper;

    public List<SysDept> list(String keyword) {
        QueryWrapper<SysDept> wrapper = new QueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.like("dept_name", keyword.trim());
        }
        wrapper.orderByAsc("parent_id", "order_num");
        return deptMapper.selectList(wrapper);
    }

    public List<SysDept> tree(String keyword) {
        List<SysDept> list = list(keyword);
        Map<Long, SysDept> index = new LinkedHashMap<>();
        for (SysDept dept : list) {
            dept.setChildren(new ArrayList<>());
            index.put(dept.getId(), dept);
        }
        List<SysDept> roots = new ArrayList<>();
        for (SysDept dept : list) {
            Long parentId = dept.getParentId();
            SysDept parent = parentId == null ? null : index.get(parentId);
            if (parent == null) {
                roots.add(dept);
            } else {
                parent.getChildren().add(dept);
            }
        }
        sortTree(roots);
        return roots;
    }

    private void sortTree(List<SysDept> nodes) {
        nodes.sort(Comparator.comparing(d -> d.getOrderNum() == null ? 0 : d.getOrderNum()));
        for (SysDept node : nodes) {
            sortTree(node.getChildren());
        }
    }

    public SysDept getById(Long id) {
        SysDept dept = deptMapper.selectById(id);
        if (dept == null) {
            throw new BizException("部门不存在");
        }
        return dept;
    }

    @Transactional(rollbackFor = Exception.class)
    public void add(SysDept dept) {
        if (dept.getDeptName() == null || dept.getDeptName().isBlank()) {
            throw new BizException("部门名称不能为空");
        }
        if (dept.getParentId() == null) {
            dept.setParentId(0L);
        }
        dept.setAncestors(buildAncestors(dept.getParentId()));
        if (dept.getOrderNum() == null) {
            dept.setOrderNum(0);
        }
        if (dept.getStatus() == null) {
            dept.setStatus("0");
        }
        if (dept.getDelFlag() == null) {
            dept.setDelFlag("0");
        }
        deptMapper.insert(dept);
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(SysDept dept) {
        if (dept.getId() == null) {
            throw new BizException("缺少部门ID");
        }
        if (dept.getId().equals(dept.getParentId())) {
            throw new BizException("上级部门不能是自己");
        }
        if (dept.getParentId() != null && dept.getParentId() != 0L) {
            List<Long> childIds = deptMapper.selectSelfAndChildIds(dept.getId());
            if (childIds.contains(dept.getParentId())) {
                throw new BizException("上级部门不能是自己的下级");
            }
        }
        String ancestors = buildAncestors(dept.getParentId());
        dept.setAncestors(ancestors);
        deptMapper.updateById(dept);
        refreshChildrenAncestors(dept.getId(), ancestors + dept.getId() + ",");
    }

    /** 父级变更后，整棵子树的 ancestors 必须重算，否则数据权限按 ancestors 查会漏 */
    private void refreshChildrenAncestors(Long deptId, String parentAncestors) {
        List<SysDept> children = deptMapper.selectList(
                new QueryWrapper<SysDept>().eq("parent_id", deptId));
        for (SysDept child : children) {
            String ancestors = parentAncestors + child.getId() + ",";
            SysDept update = new SysDept();
            update.setId(child.getId());
            update.setAncestors(ancestors);
            deptMapper.updateById(update);
            refreshChildrenAncestors(child.getId(), ancestors);
        }
    }

    private String buildAncestors(Long parentId) {
        if (parentId == null || parentId == 0L) {
            return "0,";
        }
        SysDept parent = deptMapper.selectById(parentId);
        if (parent == null) {
            throw new BizException("上级部门不存在");
        }
        String pa = parent.getAncestors() == null ? "0," : parent.getAncestors();
        return pa + parent.getId() + ",";
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        if (deptMapper.countChildren(id) > 0) {
            throw new BizException("存在下级部门，不允许删除");
        }
        if (deptMapper.countUsers(id) > 0) {
            throw new BizException("部门下存在用户，不允许删除");
        }
        deptMapper.deleteById(id);
    }
}
