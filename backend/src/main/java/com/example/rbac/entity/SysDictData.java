package com.example.rbac.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("sys_dict_data")
public class SysDictData extends BaseEntity {

    private String dictType;

    private String dictLabel;

    private String dictValue;

    private Integer orderNum;

    private String cssClass;

    private String status;
}
