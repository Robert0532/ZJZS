package com.example.rbac.vo;

import lombok.Data;

/**
 * 前台驾驶舱大厅里的一张卡片（领导舱通栏 / 部门宫格共用）
 */
@Data
public class PortalCardVO {

    /** 模块 key，同时是前端路由参数 */
    private String key;

    /** 卡片标题，如「财务部数据驾驶舱」 */
    private String title;

    private String deptName;

    private Long deptId;

    /** 卡片副标题 */
    private String subtitle;

    /** 是否在全公司汇总口径（领导舱） */
    private boolean leader;

    /** 当前账号的数据范围是否覆盖该部门。false 时卡片仍然展示、可点，进舱后按权限拦截 */
    private boolean accessible;

    /** 不可见时的提示语 */
    private String restrictedHint;
}
