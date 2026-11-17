package com.example.rbac.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 单个驾驶舱的详情。不可访问时不返回任何业务数字，只回传原因和可去的地方。
 */
@Data
public class PortalCockpitVO {

    private String key;

    private String title;

    private String deptName;

    private Long deptId;

    private boolean leader;

    /** 当前账号的数据范围是否覆盖该部门 */
    private boolean accessible;

    /** 不可访问时的说明 */
    private String message;

    /** 当前账号的数据范围文案，如「本部门」「全部数据」 */
    private String scopeLabel;

    /** 该部门账号数（仅 accessible 时有值） */
    private Integer userCount;

    /** 当前账号可见的部门数 */
    private Integer visibleDeptCount;

    /** 当前账号可见的部门名称 */
    private List<String> visibleDepts = new ArrayList<>();

    /** 当前账号还能进入的其他驾驶舱，给越权页面提供"可去的地方" */
    private List<PortalCardVO> peers = new ArrayList<>();

    /** 指标项数量，业务表接入前为 null */
    private Integer indicatorCount;
}
