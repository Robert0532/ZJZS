package com.example.rbac.entity;

import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_user")
public class SysUser extends BaseEntity {

    private Long deptId;

    private String username;

    private String nickname;

    @JsonIgnore
    private String password;

    private String email;

    private String phone;

    private String sex;

    private String avatar;

    private String status;

    private String isAdmin;

    private String remark;

    @TableLogic
    @JsonIgnore
    private String delFlag;

    /** 冗余展示字段，不落库 */
    @TableField(exist = false)
    private String deptName;

    /** 分配角色时使用，不落库 */
    @TableField(exist = false)
    private java.util.List<Long> roleIds;
}
