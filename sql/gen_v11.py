# -*- coding: utf-8 -*-
"""生成 V1.1 部门数据管理改造的 SQL 迁移脚本。"""
import io

PWD = "$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2"  # BCrypt("123456")

MODULES = [
    (0,  "公司领导",        "领导数据驾驶舱",   "leader",     "DataLine"),
    (1,  "财务部",          "财务部数据管理",   "finance",    "Money"),
    (2,  "商务法务部",      "商务法务部数据管理", "legal",     "Document"),
    (3,  "市场部",          "市场部数据管理",   "market",     "TrendCharts"),
    (4,  "采购管理部",      "采购管理部数据管理", "purchase",  "ShoppingCart"),
    (5,  "安全生产监督管理部", "安全生产监督管理部数据管理", "safety", "Warning"),
    (6,  "技术质量部",      "技术质量部数据管理", "quality",   "Medal"),
    (7,  "工程管理部",      "工程管理部数据管理", "engineering", "Tools"),
    (8,  "人力资源部",      "人力资源部数据管理", "hr",        "User"),
    (9,  "项目技术支撑中心", "项目技术支撑中心数据管理", "support", "Connection"),
    (10, "科创与产品部",    "科创与产品部数据管理", "innovation", "MagicStick"),
    (11, "党建工作部",      "党建工作部数据管理", "party",     "Flag"),
    (12, "办公室",          "办公室数据管理",   "office",     "OfficeBuilding"),
    (13, "设计院",          "设计院数据管理",   "design",     "Picture"),
    (14, "经理部与事业部",  "经理部与事业部数据管理", "division", "Grid"),
    (15, "项目部",          "项目部数据管理",   "project",    "MapLocation"),
]
DEPTS = MODULES  # 序号 0-15 一一对应

TOP_ID = lambda n: 1000 + n if n > 0 else 1000
CHILD_ID = lambda n, i: 2000 + n * 10 + i

out = io.StringIO()
w = out.write

w("""-- ============================================================
-- V1.1 部门数据管理改造
-- 目标库：rbac_demo  (MySQL 8.0)
-- 内容：17 个一级菜单 / 30 个部门二级 / 16 个部门 / 15 个部门管理员 + 1 个领导只读角色
-- 可重复执行：先按 ID 区间清理，再写入
-- 说明：所有部门管理员账号初始密码 123456（BCrypt 复用 admin 的哈希）
-- ============================================================
SET NAMES utf8mb4;

START TRANSACTION;

-- ---------- 1. 清理（幂等） ----------
DELETE FROM sys_role_menu WHERE role_id >= 2 OR menu_id >= 1000;
DELETE FROM sys_user_role WHERE user_id >= 2 OR role_id >= 2;
DELETE FROM sys_user  WHERE id >= 2;
DELETE FROM sys_role  WHERE id >= 2;
DELETE FROM sys_menu  WHERE id >= 1000;
DELETE FROM sys_dept  WHERE id >= 2;

-- ---------- 2. 系统管理排到最后 ----------
UPDATE sys_menu SET order_num = 16 WHERE id = 1;

-- ---------- 3. 一级菜单 ----------
""")

# 一级
for n, dept, menu, key, icon in MODULES:
    if n == 0:
        w(f"INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) "
          f"VALUES (1000,0,'{menu}',0,'/{key}','modules/{key}/cockpit/index','{key}:cockpit:view','C','{icon}','0','0',NOW());\n")
    else:
        w(f"INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) "
          f"VALUES ({TOP_ID(n)},0,'{menu}',{n},'/{key}',NULL,NULL,'M','{icon}','0','0',NOW());\n")

w("\n-- ---------- 4. 二级菜单：数据填报 / 数据驾驶舱 ----------\n")
for n, dept, menu, key, icon in MODULES:
    if n == 0:
        continue
    w(f"INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) "
      f"VALUES ({CHILD_ID(n,1)},{TOP_ID(n)},'数据填报',1,'report','modules/{key}/report/index','{key}:report:list','C',NULL,'0','0',NOW());\n")
    w(f"INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) "
      f"VALUES ({CHILD_ID(n,2)},{TOP_ID(n)},'数据驾驶舱',2,'cockpit','modules/{key}/cockpit/index','{key}:cockpit:view','C',NULL,'0','0',NOW());\n")

w("\n-- ---------- 5. 部门（平铺在根部门 id=1 下） ----------\n")
for n, dept, menu, key, icon in DEPTS:
    w(f"INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) "
      f"VALUES ({n+2},1,'0,1,','{dept}',{n},NULL,NULL,'0','0',NOW());\n")

w("\n-- ---------- 6. 角色 ----------\n")
for n, dept, menu, key, icon in DEPTS:
    if n == 0:
        w(f"INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) "
          f"VALUES (17,'公司领导（只读）','leader_readonly','1',0,'0','全公司只读，仅看驾驶舱','0',NOW());\n")
    else:
        w(f"INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) "
          f"VALUES ({n+1},'{dept}管理员','dept_admin_{key}','3',{n},'0','本部门数据','0',NOW());\n")

w("\n-- ---------- 7. 账号（密码统一 123456） ----------\n")
for n, dept, menu, key, icon in DEPTS:
    if n == 0:
        continue
    w(f"INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) "
      f"VALUES ({n+1},{n+2},'{key}','{dept}管理员','{PWD}',NULL,NULL,'2','0','0','部门管理员','0',NOW());\n")

w("\n-- ---------- 8. 用户-角色 ----------\n")
for n, dept, menu, key, icon in DEPTS:
    if n == 0:
        continue
    w(f"INSERT INTO sys_user_role (user_id,role_id) VALUES ({n+1},{n+1});\n")

w("\n-- ---------- 9. 角色-菜单授权 ----------\n")
# 部门管理员：本部门一级 + 2 个二级
for n, dept, menu, key, icon in DEPTS:
    if n == 0:
        continue
    w(f"INSERT INTO sys_role_menu (role_id,menu_id) VALUES ({n+1},{TOP_ID(n)}),({n+1},{CHILD_ID(n,1)}),({n+1},{CHILD_ID(n,2)});\n")
# 领导只读：领导舱
w("INSERT INTO sys_role_menu (role_id,menu_id) VALUES (17,1000);\n")
# admin：全部新增菜单
w("INSERT INTO sys_role_menu (role_id,menu_id) SELECT 1, id FROM sys_menu WHERE id >= 1000;\n")

w("""
COMMIT;

-- ---------- 10. 校验 ----------
SELECT '菜单总数' AS item, COUNT(*) AS cnt FROM sys_menu
UNION ALL SELECT '一级菜单', COUNT(*) FROM sys_menu WHERE parent_id = 0
UNION ALL SELECT '部门总数', COUNT(*) FROM sys_dept
UNION ALL SELECT '角色总数', COUNT(*) FROM sys_role
UNION ALL SELECT '账号总数', COUNT(*) FROM sys_user
UNION ALL SELECT '授权总数', COUNT(*) FROM sys_role_menu;
""")

open("sql/v1.1_departments.sql", "w", encoding="utf-8", newline="\n").write(out.getvalue())
print("written, lines =", out.getvalue().count("\n"))
