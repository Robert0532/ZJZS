package com.example.rbac.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.rbac.entity.SysRole;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SysRoleMapper extends BaseMapper<SysRole> {

    @Select("""
            SELECT r.* FROM sys_role r
            JOIN sys_user_role ur ON r.id = ur.role_id
            WHERE ur.user_id = #{userId} AND r.status = '0' AND r.del_flag = '0'
            ORDER BY r.order_num
            """)
    List<SysRole> selectRolesByUserId(@Param("userId") Long userId);

    @Select("""
            SELECT r.role_key FROM sys_role r
            JOIN sys_user_role ur ON r.id = ur.role_id
            WHERE ur.user_id = #{userId} AND r.status = '0' AND r.del_flag = '0'
            """)
    List<String> selectRoleKeysByUserId(@Param("userId") Long userId);

    @Select("SELECT menu_id FROM sys_role_menu WHERE role_id = #{roleId}")
    List<Long> selectMenuIdsByRoleId(@Param("roleId") Long roleId);

    @Select("SELECT dept_id FROM sys_role_dept WHERE role_id = #{roleId}")
    List<Long> selectDeptIdsByRoleId(@Param("roleId") Long roleId);
}
