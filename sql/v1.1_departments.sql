-- ============================================================
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
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1000,0,'领导数据驾驶舱',0,'/leader','modules/leader/cockpit/index','leader:cockpit:view','C','DataLine','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1001,0,'财务部数据管理',1,'/finance',NULL,NULL,'M','Money','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1002,0,'商务法务部数据管理',2,'/legal',NULL,NULL,'M','Document','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1003,0,'市场部数据管理',3,'/market',NULL,NULL,'M','TrendCharts','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1004,0,'采购管理部数据管理',4,'/purchase',NULL,NULL,'M','ShoppingCart','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1005,0,'安全生产监督管理部数据管理',5,'/safety',NULL,NULL,'M','Warning','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1006,0,'技术质量部数据管理',6,'/quality',NULL,NULL,'M','Medal','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1007,0,'工程管理部数据管理',7,'/engineering',NULL,NULL,'M','Tools','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1008,0,'人力资源部数据管理',8,'/hr',NULL,NULL,'M','User','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1009,0,'项目技术支撑中心数据管理',9,'/support',NULL,NULL,'M','Connection','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1010,0,'科创与产品部数据管理',10,'/innovation',NULL,NULL,'M','MagicStick','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1011,0,'党建工作部数据管理',11,'/party',NULL,NULL,'M','Flag','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1012,0,'办公室数据管理',12,'/office',NULL,NULL,'M','OfficeBuilding','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1013,0,'设计院数据管理',13,'/design',NULL,NULL,'M','Picture','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1014,0,'经理部与事业部数据管理',14,'/division',NULL,NULL,'M','Grid','0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (1015,0,'项目部数据管理',15,'/project',NULL,NULL,'M','MapLocation','0','0',NOW());

-- ---------- 4. 二级菜单：数据填报 / 数据驾驶舱 ----------
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2011,1001,'数据填报',1,'report','modules/finance/report/index','finance:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2012,1001,'数据驾驶舱',2,'cockpit','modules/finance/cockpit/index','finance:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2021,1002,'数据填报',1,'report','modules/legal/report/index','legal:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2022,1002,'数据驾驶舱',2,'cockpit','modules/legal/cockpit/index','legal:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2031,1003,'数据填报',1,'report','modules/market/report/index','market:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2032,1003,'数据驾驶舱',2,'cockpit','modules/market/cockpit/index','market:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2041,1004,'数据填报',1,'report','modules/purchase/report/index','purchase:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2042,1004,'数据驾驶舱',2,'cockpit','modules/purchase/cockpit/index','purchase:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2051,1005,'数据填报',1,'report','modules/safety/report/index','safety:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2052,1005,'数据驾驶舱',2,'cockpit','modules/safety/cockpit/index','safety:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2061,1006,'数据填报',1,'report','modules/quality/report/index','quality:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2062,1006,'数据驾驶舱',2,'cockpit','modules/quality/cockpit/index','quality:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2071,1007,'数据填报',1,'report','modules/engineering/report/index','engineering:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2072,1007,'数据驾驶舱',2,'cockpit','modules/engineering/cockpit/index','engineering:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2081,1008,'数据填报',1,'report','modules/hr/report/index','hr:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2082,1008,'数据驾驶舱',2,'cockpit','modules/hr/cockpit/index','hr:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2091,1009,'数据填报',1,'report','modules/support/report/index','support:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2092,1009,'数据驾驶舱',2,'cockpit','modules/support/cockpit/index','support:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2101,1010,'数据填报',1,'report','modules/innovation/report/index','innovation:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2102,1010,'数据驾驶舱',2,'cockpit','modules/innovation/cockpit/index','innovation:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2111,1011,'数据填报',1,'report','modules/party/report/index','party:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2112,1011,'数据驾驶舱',2,'cockpit','modules/party/cockpit/index','party:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2121,1012,'数据填报',1,'report','modules/office/report/index','office:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2122,1012,'数据驾驶舱',2,'cockpit','modules/office/cockpit/index','office:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2131,1013,'数据填报',1,'report','modules/design/report/index','design:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2132,1013,'数据驾驶舱',2,'cockpit','modules/design/cockpit/index','design:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2141,1014,'数据填报',1,'report','modules/division/report/index','division:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2142,1014,'数据驾驶舱',2,'cockpit','modules/division/cockpit/index','division:cockpit:view','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2151,1015,'数据填报',1,'report','modules/project/report/index','project:report:list','C',NULL,'0','0',NOW());
INSERT INTO sys_menu (id,parent_id,menu_name,order_num,path,component,perms,menu_type,icon,visible,status,create_time) VALUES (2152,1015,'数据驾驶舱',2,'cockpit','modules/project/cockpit/index','project:cockpit:view','C',NULL,'0','0',NOW());

-- ---------- 5. 部门（平铺在根部门 id=1 下） ----------
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (2,1,'0,1,','公司领导',0,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (3,1,'0,1,','财务部',1,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (4,1,'0,1,','商务法务部',2,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (5,1,'0,1,','市场部',3,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (6,1,'0,1,','采购管理部',4,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (7,1,'0,1,','安全生产监督管理部',5,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (8,1,'0,1,','技术质量部',6,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (9,1,'0,1,','工程管理部',7,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (10,1,'0,1,','人力资源部',8,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (11,1,'0,1,','项目技术支撑中心',9,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (12,1,'0,1,','科创与产品部',10,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (13,1,'0,1,','党建工作部',11,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (14,1,'0,1,','办公室',12,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (15,1,'0,1,','设计院',13,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (16,1,'0,1,','经理部与事业部',14,NULL,NULL,'0','0',NOW());
INSERT INTO sys_dept (id,parent_id,ancestors,dept_name,order_num,leader,phone,status,del_flag,create_time) VALUES (17,1,'0,1,','项目部',15,NULL,NULL,'0','0',NOW());

-- ---------- 6. 角色 ----------
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (17,'公司领导（只读）','leader_readonly','1',0,'0','全公司只读，仅看驾驶舱','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (2,'财务部管理员','dept_admin_finance','3',1,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (3,'商务法务部管理员','dept_admin_legal','3',2,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (4,'市场部管理员','dept_admin_market','3',3,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (5,'采购管理部管理员','dept_admin_purchase','3',4,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (6,'安全生产监督管理部管理员','dept_admin_safety','3',5,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (7,'技术质量部管理员','dept_admin_quality','3',6,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (8,'工程管理部管理员','dept_admin_engineering','3',7,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (9,'人力资源部管理员','dept_admin_hr','3',8,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (10,'项目技术支撑中心管理员','dept_admin_support','3',9,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (11,'科创与产品部管理员','dept_admin_innovation','3',10,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (12,'党建工作部管理员','dept_admin_party','3',11,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (13,'办公室管理员','dept_admin_office','3',12,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (14,'设计院管理员','dept_admin_design','3',13,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (15,'经理部与事业部管理员','dept_admin_division','3',14,'0','本部门数据','0',NOW());
INSERT INTO sys_role (id,role_name,role_key,data_scope,order_num,status,remark,del_flag,create_time) VALUES (16,'项目部管理员','dept_admin_project','3',15,'0','本部门数据','0',NOW());

-- ---------- 7. 账号（密码统一 123456） ----------
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (2,3,'finance','财务部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (3,4,'legal','商务法务部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (4,5,'market','市场部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (5,6,'purchase','采购管理部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (6,7,'safety','安全生产监督管理部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (7,8,'quality','技术质量部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (8,9,'engineering','工程管理部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (9,10,'hr','人力资源部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (10,11,'support','项目技术支撑中心管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (11,12,'innovation','科创与产品部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (12,13,'party','党建工作部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (13,14,'office','办公室管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (14,15,'design','设计院管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (15,16,'division','经理部与事业部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());
INSERT INTO sys_user (id,dept_id,username,nickname,password,email,phone,sex,status,is_admin,remark,del_flag,create_time) VALUES (16,17,'project','项目部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2','0','0','部门管理员','0',NOW());

-- ---------- 8. 用户-角色 ----------
INSERT INTO sys_user_role (user_id,role_id) VALUES (2,2);
INSERT INTO sys_user_role (user_id,role_id) VALUES (3,3);
INSERT INTO sys_user_role (user_id,role_id) VALUES (4,4);
INSERT INTO sys_user_role (user_id,role_id) VALUES (5,5);
INSERT INTO sys_user_role (user_id,role_id) VALUES (6,6);
INSERT INTO sys_user_role (user_id,role_id) VALUES (7,7);
INSERT INTO sys_user_role (user_id,role_id) VALUES (8,8);
INSERT INTO sys_user_role (user_id,role_id) VALUES (9,9);
INSERT INTO sys_user_role (user_id,role_id) VALUES (10,10);
INSERT INTO sys_user_role (user_id,role_id) VALUES (11,11);
INSERT INTO sys_user_role (user_id,role_id) VALUES (12,12);
INSERT INTO sys_user_role (user_id,role_id) VALUES (13,13);
INSERT INTO sys_user_role (user_id,role_id) VALUES (14,14);
INSERT INTO sys_user_role (user_id,role_id) VALUES (15,15);
INSERT INTO sys_user_role (user_id,role_id) VALUES (16,16);

-- ---------- 9. 角色-菜单授权 ----------
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (2,1001),(2,2011),(2,2012);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (3,1002),(3,2021),(3,2022);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (4,1003),(4,2031),(4,2032);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (5,1004),(5,2041),(5,2042);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (6,1005),(6,2051),(6,2052);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (7,1006),(7,2061),(7,2062);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (8,1007),(8,2071),(8,2072);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (9,1008),(9,2081),(9,2082);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (10,1009),(10,2091),(10,2092);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (11,1010),(11,2101),(11,2102);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (12,1011),(12,2111),(12,2112);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (13,1012),(13,2121),(13,2122);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (14,1013),(14,2131),(14,2132);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (15,1014),(15,2141),(15,2142);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (16,1015),(16,2151),(16,2152);
INSERT INTO sys_role_menu (role_id,menu_id) VALUES (17,1000);
INSERT INTO sys_role_menu (role_id,menu_id) SELECT 1, id FROM sys_menu WHERE id >= 1000;

COMMIT;

-- ---------- 10. 校验 ----------
SELECT '菜单总数' AS item, COUNT(*) AS cnt FROM sys_menu
UNION ALL SELECT '一级菜单', COUNT(*) FROM sys_menu WHERE parent_id = 0
UNION ALL SELECT '部门总数', COUNT(*) FROM sys_dept
UNION ALL SELECT '角色总数', COUNT(*) FROM sys_role
UNION ALL SELECT '账号总数', COUNT(*) FROM sys_user
UNION ALL SELECT '授权总数', COUNT(*) FROM sys_role_menu;
