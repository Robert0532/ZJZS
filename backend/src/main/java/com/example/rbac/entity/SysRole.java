package com.example.rbac.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_role")
public class SysRole extends BaseEntity {

    private String roleName;

    private String roleKey;

    /** 1全部 2自定义 3本部门 4本部门及以下 5仅本人 */
    private String dataScope;

    private Integer orderNum;

    private String status;

    private String remark;

    @TableLogic
    @JsonIgnore
    private String delFlag;

    @TableField(exist = false)
    private List<Long> menuIds = new ArrayList<>();

    /** 自定义数据权限时使用，不落库 */
    @TableField(exist = false)
    private List<Long> deptIds = new ArrayList<>();
}
