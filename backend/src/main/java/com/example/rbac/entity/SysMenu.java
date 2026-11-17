package com.example.rbac.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_menu")
public class SysMenu extends BaseEntity {

    private Long parentId;

    private String menuName;

    private Integer orderNum;

    /** 路由地址 */
    private String path;

    /** 组件路径，如 system/user/index */
    private String component;

    /** 权限标识，如 system:user:list */
    private String perms;

    /** M目录 C菜单 F按钮 */
    private String menuType;

    private String icon;

    private String visible;

    private String status;

    @TableField(exist = false)
    private List<SysMenu> children = new ArrayList<>();
}
