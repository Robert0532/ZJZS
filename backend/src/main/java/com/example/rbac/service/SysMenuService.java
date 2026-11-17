package com.example.rbac.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysMenu;
import com.example.rbac.entity.SysRoleMenu;
import com.example.rbac.mapper.SysMenuMapper;
import com.example.rbac.mapper.SysRoleMenuMapper;
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
public class SysMenuService {

    private final SysMenuMapper menuMapper;
    private final SysRoleMenuMapper roleMenuMapper;

    public List<SysMenu> listAll(String keyword) {
        QueryWrapper<SysMenu> wrapper = new QueryWrapper<>();
        if (keyword != null && !keyword.isBlank()) {
            wrapper.like("menu_name", keyword.trim());
        }
        wrapper.orderByAsc("parent_id", "order_num");
        return menuMapper.selectList(wrapper);
    }

    public List<SysMenu> tree(String keyword) {
        return buildTree(listAll(keyword));
    }

    public List<SysMenu> buildTree(List<SysMenu> menus) {
        Map<Long, SysMenu> index = new LinkedHashMap<>();
        for (SysMenu menu : menus) {
            menu.setChildren(new ArrayList<>());
            index.put(menu.getId(), menu);
        }
        List<SysMenu> roots = new ArrayList<>();
        for (SysMenu menu : menus) {
            Long parentId = menu.getParentId();
            SysMenu parent = parentId == null ? null : index.get(parentId);
            if (parent == null || parentId == null || parentId == 0L) {
                roots.add(menu);
            } else {
                parent.getChildren().add(menu);
            }
        }
        sort(roots);
        return roots;
    }

    private void sort(List<SysMenu> nodes) {
        nodes.sort(Comparator.comparing(m -> m.getOrderNum() == null ? 0 : m.getOrderNum()));
        for (SysMenu node : nodes) {
            sort(node.getChildren());
        }
    }

    public SysMenu getById(Long id) {
        SysMenu menu = menuMapper.selectById(id);
        if (menu == null) {
            throw new BizException("菜单不存在");
        }
        return menu;
    }

    @Transactional(rollbackFor = Exception.class)
    public void add(SysMenu menu) {
        validate(menu, null);
        if (menu.getParentId() == null) {
            menu.setParentId(0L);
        }
        if (menu.getMenuType() == null) {
            menu.setMenuType("C");
        }
        if (menu.getOrderNum() == null) {
            menu.setOrderNum(0);
        }
        if (menu.getVisible() == null) {
            menu.setVisible("0");
        }
        if (menu.getStatus() == null) {
            menu.setStatus("0");
        }
        menuMapper.insert(menu);
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(SysMenu menu) {
        if (menu.getId() == null) {
            throw new BizException("缺少菜单ID");
        }
        validate(menu, menu.getId());
        if (menu.getId().equals(menu.getParentId())) {
            throw new BizException("上级菜单不能是自己");
        }
        menuMapper.updateById(menu);
    }

    private void validate(SysMenu menu, Long selfId) {
        if (menu.getMenuName() == null || menu.getMenuName().isBlank()) {
            throw new BizException("菜单名称不能为空");
        }
        Long parentId = menu.getParentId();
        if (parentId != null && parentId != 0L) {
            if (selfId != null && parentId.equals(selfId)) {
                throw new BizException("上级菜单不能是自己");
            }
            if (menuMapper.selectById(parentId) == null) {
                throw new BizException("上级菜单不存在");
            }
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void delete(Long id) {
        if (menuMapper.countChildren(id) > 0) {
            throw new BizException("存在子菜单，不允许删除");
        }
        menuMapper.deleteById(id);
        roleMenuMapper.delete(new QueryWrapper<SysRoleMenu>().eq("menu_id", id));
    }
}
