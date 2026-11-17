package com.example.rbac.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.rbac.entity.SysDept;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SysDeptMapper extends BaseMapper<SysDept> {

    @Select("""
            SELECT id FROM sys_dept
            WHERE del_flag = '0' AND (id = #{deptId} OR ancestors LIKE CONCAT('%,', #{deptId}, ',%'))
            """)
    List<Long> selectSelfAndChildIds(@Param("deptId") Long deptId);

    @Select("SELECT COUNT(1) FROM sys_dept WHERE parent_id = #{deptId} AND del_flag = '0'")
    int countChildren(@Param("deptId") Long deptId);

    @Select("SELECT COUNT(1) FROM sys_user WHERE dept_id = #{deptId} AND del_flag = '0'")
    int countUsers(@Param("deptId") Long deptId);
}
