package com.example.rbac.security;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysRole;
import com.example.rbac.mapper.SysDeptMapper;
import com.example.rbac.mapper.SysRoleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 行级数据权限。在 Service 里显式调用，而不是用 AOP——
 * 因为 Service 内部方法自调用不会经过代理，注解会静默失效，这是数据权限最常见的线上事故。
 *
 * sys_role.data_scope: 1全部 2自定义部门 3本部门 4本部门及以下 5仅本人
 */
@Component
@RequiredArgsConstructor
public class DataScopeHelper {

    private final SysRoleMapper roleMapper;
    private final SysDeptMapper deptMapper;

    public <T> void apply(QueryWrapper<T> wrapper, String deptColumn, String userColumn) {
        LoginUser user = LoginUserHolder.get();
        if (user == null) {
            // 失败关闭：拿不到登录上下文时宁可直接报错，也不能退化成"查全部"
            throw new BizException("数据权限上下文缺失，拒绝执行查询");
        }
        if (user.isAdmin()) {
            return;
        }

        List<SysRole> roles = user.getRoleList();
        if (roles == null || roles.isEmpty()) {
            wrapper.apply("1 = 0");
            return;
        }

        // 多角色取最宽的口径。初值必须是最大档，否则 Math.min 会被初值钉死成 1（全部数据）
        int scope = Integer.MAX_VALUE;
        for (SysRole role : roles) {
            scope = Math.min(scope, parseScope(role.getDataScope()));
        }
        if (scope == Integer.MAX_VALUE) {
            scope = 1;
        }

        switch (scope) {
            case 1 -> {
                // 全部数据，不加条件
            }
            case 2 -> {
                Set<Long> deptIds = new HashSet<>();
                for (SysRole role : roles) {
                    if (parseScope(role.getDataScope()) == 2) {
                        deptIds.addAll(roleMapper.selectDeptIdsByRoleId(role.getId()));
                    }
                }
                if (deptIds.isEmpty()) {
                    wrapper.apply("1 = 0");
                } else {
                    wrapper.in(deptColumn, deptIds);
                }
            }
            case 3 -> {
                if (user.getDeptId() == null) {
                    wrapper.apply("1 = 0");
                } else {
                    wrapper.eq(deptColumn, user.getDeptId());
                }
            }
            case 4 -> {
                if (user.getDeptId() == null) {
                    wrapper.apply("1 = 0");
                    return;
                }
                List<Long> ids = new ArrayList<>(deptMapper.selectSelfAndChildIds(user.getDeptId()));
                if (ids.isEmpty()) {
                    wrapper.apply("1 = 0");
                } else {
                    wrapper.in(deptColumn, ids);
                }
            }
            case 5 -> wrapper.eq(userColumn, user.getUserId());
            default -> wrapper.apply("1 = 0");
        }
    }

    /**
     * 当前登录账号可见的部门 ID 集合。
     * 返回 null 表示"不限部门"（全部数据），调用方必须区分 null 与空集合：
     * null = 全放行，空集合 = 一个都看不到（失败关闭）。
     */
    public Set<Long> visibleDeptIds() {
        LoginUser user = LoginUserHolder.get();
        if (user == null) {
            throw new BizException("数据权限上下文缺失，拒绝执行查询");
        }
        if (user.isAdmin()) {
            return null;
        }
        List<SysRole> roles = user.getRoleList();
        if (roles == null || roles.isEmpty()) {
            return Set.of();
        }
        return switch (widestScope(roles)) {
            case 1 -> null;
            case 2 -> {
                Set<Long> deptIds = new HashSet<>();
                for (SysRole role : roles) {
                    if (parseScope(role.getDataScope()) == 2) {
                        deptIds.addAll(roleMapper.selectDeptIdsByRoleId(role.getId()));
                    }
                }
                yield deptIds;
            }
            // 仅本人：部门维度上等同于本部门，个人维度的收窄由 apply() 的 userColumn 负责
            case 3, 5 -> user.getDeptId() == null ? Set.of() : Set.of(user.getDeptId());
            case 4 -> {
                if (user.getDeptId() == null) {
                    yield Set.of();
                }
                yield new HashSet<>(deptMapper.selectSelfAndChildIds(user.getDeptId()));
            }
            default -> Set.of();
        };
    }

    /** 当前账号的数据范围文案，用于驾驶舱顶部展示 */
    public String dataScopeLabel() {
        LoginUser user = LoginUserHolder.get();
        if (user == null) {
            throw new BizException("数据权限上下文缺失，拒绝执行查询");
        }
        if (user.isAdmin()) {
            return "全部数据";
        }
        List<SysRole> roles = user.getRoleList();
        if (roles == null || roles.isEmpty()) {
            return "无数据权限";
        }
        return switch (widestScope(roles)) {
            case 1 -> "全部数据";
            case 2 -> "自定义部门";
            case 3 -> "本部门";
            case 4 -> "本部门及以下";
            case 5 -> "仅本人";
            default -> "无数据权限";
        };
    }

    /** 多角色取最宽口径：数值越小范围越大 */
    private int widestScope(List<SysRole> roles) {
        int scope = Integer.MAX_VALUE;
        for (SysRole role : roles) {
            scope = Math.min(scope, parseScope(role.getDataScope()));
        }
        return scope == Integer.MAX_VALUE ? 1 : scope;
    }

    private int parseScope(String value) {
        try {
            return value == null ? 1 : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 1;
        }
    }
}
