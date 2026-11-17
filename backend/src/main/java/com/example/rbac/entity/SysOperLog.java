package com.example.rbac.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@TableName("sys_oper_log")
public class SysOperLog implements Serializable {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String title;

    private String businessType;

    private String method;

    private String requestMethod;

    private String operName;

    private String deptName;

    private String operUrl;

    private String operIp;

    private String operParam;

    private String jsonResult;

    /** 0成功 1失败 */
    private String status;

    private String errorMsg;

    private Long costTime;

    private LocalDateTime operTime;
}
