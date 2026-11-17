package com.example.rbac.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.rbac.entity.SysMenu;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SysMenuMapper extends BaseMapper<SysMenu> {

    @Select("""
            SELECT DISTINCT m.perms FROM sys_menu m
            JOIN sys_role_menu rm ON m.id = rm.menu_id
            JOIN sys_user_role ur ON rm.role_id = ur.role_id
            JOIN sys_role r ON r.id = ur.role_id AND r.status = '0' AND r.del_flag = '0'
            WHERE ur.user_id = #{userId}
              AND m.status = '0'
              AND m.perms IS NOT NULL AND m.perms <> ''
            """)
    List<String> selectPermsByUserId(@Param("userId") Long userId);

    @Select("""
            SELECT DISTINCT m.* FROM sys_menu m
            JOIN sys_role_menu rm ON m.id = rm.menu_id
            JOIN sys_user_role ur ON rm.role_id = ur.role_id
            JOIN sys_role r ON r.id = ur.role_id AND r.status = '0' AND r.del_flag = '0'
            WHERE ur.user_id = #{userId}
              AND m.menu_type IN ('M', 'C')
              AND m.status = '0' AND m.visible = '0'
            ORDER BY m.parent_id, m.order_num
            """)
    List<SysMenu> selectMenusByUserId(@Param("userId") Long userId);

    @Select("SELECT COUNT(1) FROM sys_menu WHERE parent_id = #{menuId}")
    int countChildren(@Param("menuId") Long menuId);
}
