package com.example.rbac.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

/**
 * 前台驾驶舱大厅：卡片列表 + 当前账号的数据范围说明
 */
@Data
public class PortalOverviewVO {

    /** 当前账号的数据范围文案，如「全部数据」「本部门」 */
    private String scopeLabel;

    private List<PortalCardVO> cards = new ArrayList<>();
}
