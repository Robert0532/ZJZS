package com.example.rbac.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.rbac.common.BizException;
import com.example.rbac.entity.SysDept;
import com.example.rbac.mapper.SysDeptMapper;
import com.example.rbac.security.DataScopeHelper;
import com.example.rbac.vo.PortalCardVO;
import com.example.rbac.vo.PortalCockpitVO;
import com.example.rbac.vo.PortalOverviewVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Set;

/**
 * 前台数据驾驶舱。
 *
 * 大厅采用"全部可见可点"：16 张卡片对任何登录账号都返回，
 * 是否能看到舱内数据由 data_scope 决定（accessible 字段），前端据此提示而不是隐藏卡片。
 */
@Service
@RequiredArgsConstructor
public class PortalService {

    /** key 与后台一级菜单 path 一致，保证前后台对同一个部门用同一个标识 */
    private record ModuleDef(String key, String deptName, boolean leader) {
    }

    private static final List<ModuleDef> MODULES = List.of(
            new ModuleDef("leader", "公司领导", true),
            new ModuleDef("finance", "财务部", false),
            new ModuleDef("legal", "商务法务部", false),
            new ModuleDef("market", "市场部", false),
            new ModuleDef("purchase", "采购管理部", false),
            new ModuleDef("safety", "安全生产监督管理部", false),
            new ModuleDef("quality", "技术质量部", false),
            new ModuleDef("engineering", "工程管理部", false),
            new ModuleDef("hr", "人力资源部", false),
            new ModuleDef("support", "项目技术支撑中心", false),
            new ModuleDef("innovation", "科创与产品部", false),
            new ModuleDef("party", "党建工作部", false),
            new ModuleDef("office", "办公室", false),
            new ModuleDef("design", "设计院", false),
            new ModuleDef("division", "经理部与事业部", false),
            new ModuleDef("project", "项目部", false)
    );

    private final SysDeptMapper deptMapper;
    private final DataScopeHelper dataScopeHelper;

    /** 大厅卡片：领导舱 + 15 个部门，顺序与后台序号 0-15 一致 */
    public List<PortalCardVO> cards() {
        Set<Long> scope = dataScopeHelper.visibleDeptIds();
        String scopeLabel = dataScopeHelper.dataScopeLabel();
        List<PortalCardVO> list = new ArrayList<>(MODULES.size());
        for (ModuleDef def : MODULES) {
            list.add(toCard(def, scope, scopeLabel));
        }
        return list;
    }

    public PortalOverviewVO overview() {
        List<PortalCardVO> cards = cards();
        PortalOverviewVO vo = new PortalOverviewVO();
        vo.setScopeLabel(dataScopeHelper.dataScopeLabel());
        vo.setCards(cards);
        return vo;
    }

    public PortalCockpitVO cockpit(String key) {
        ModuleDef def = MODULES.stream()
                .filter(m -> m.key().equals(key))
                .findFirst()
                .orElseThrow(() -> new BizException("驾驶舱不存在：" + key));

        Set<Long> scope = dataScopeHelper.visibleDeptIds();
        String scopeLabel = dataScopeHelper.dataScopeLabel();
        PortalCardVO card = toCard(def, scope, scopeLabel);

        PortalCockpitVO vo = new PortalCockpitVO();
        vo.setKey(key);
        vo.setTitle(card.getTitle());
        vo.setDeptName(card.getDeptName());
        vo.setDeptId(card.getDeptId());
        vo.setLeader(def.leader());
        vo.setAccessible(card.isAccessible());
        vo.setScopeLabel(scopeLabel);
        fillVisibleDepts(vo, scope);
        vo.setPeers(cards().stream().filter(PortalCardVO::isAccessible).toList());

        if (!card.isAccessible()) {
            vo.setMessage(card.getRestrictedHint());
            return vo;
        }
        if (card.getDeptId() != null) {
            vo.setUserCount(deptMapper.countUsers(card.getDeptId()));
        }
        return vo;
    }

    private PortalCardVO toCard(ModuleDef def, Set<Long> scope, String scopeLabel) {
        SysDept dept = deptByName(def.deptName());
        Long deptId = dept == null ? null : dept.getId();
        boolean accessible = deptId != null && (scope == null || scope.contains(deptId));

        PortalCardVO vo = new PortalCardVO();
        vo.setKey(def.key());
        vo.setDeptName(def.deptName());
        vo.setDeptId(deptId);
        vo.setLeader(def.leader());
        vo.setTitle(def.leader() ? "领导数据驾驶舱" : def.deptName() + "数据驾驶舱");
        vo.setSubtitle(def.leader() ? "全公司数据汇总" : "部门数据填报与汇总");
        vo.setAccessible(accessible);
        if (!accessible) {
            vo.setRestrictedHint(deptId == null
                    ? "系统中未找到「" + def.deptName() + "」部门，无法展示该驾驶舱"
                    : "当前账号的数据范围为「" + scopeLabel + "」，无权查看「" + def.deptName() + "」的数据");
        }
        return vo;
    }

    /** 当前账号可见的部门（不含根部门），供驾驶舱展示"我的数据范围" */
    private void fillVisibleDepts(PortalCockpitVO vo, Set<Long> scope) {
        List<SysDept> depts;
        if (scope == null) {
            depts = deptMapper.selectList(new QueryWrapper<SysDept>().ne("parent_id", 0));
        } else if (scope.isEmpty()) {
            depts = List.of();
        } else {
            depts = deptMapper.selectBatchIds(scope);
        }
        depts = new ArrayList<>(depts).stream()
                .filter(d -> d.getParentId() != null && d.getParentId() != 0)
                .sorted(Comparator.comparing(SysDept::getOrderNum, Comparator.nullsLast(Integer::compareTo)))
                .toList();
        vo.setVisibleDeptCount(depts.size());
        vo.setVisibleDepts(depts.stream().map(SysDept::getDeptName).toList());
    }

    private SysDept deptByName(String name) {
        return deptMapper.selectOne(new QueryWrapper<SysDept>()
                .eq("dept_name", name)
                .last("limit 1"));
    }
}
