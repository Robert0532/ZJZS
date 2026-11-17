-- 硕果大数据测试服 · RBAC 基线初始化脚本
-- 密码占位符 {{PWD}} 由 init_db.py 替换为 BCrypt("123456") 的哈希
-- 基线原则：只保留系统管理模块与超级管理员，不包含任何业务示例数据

SET NAMES utf8mb4;

DROP TABLE IF EXISTS sys_user_role;
DROP TABLE IF EXISTS sys_role_menu;
DROP TABLE IF EXISTS sys_role_dept;
DROP TABLE IF EXISTS sys_user;
DROP TABLE IF EXISTS sys_role;
DROP TABLE IF EXISTS sys_menu;
DROP TABLE IF EXISTS sys_dept;
DROP TABLE IF EXISTS sys_dict_type;
DROP TABLE IF EXISTS sys_dict_data;
DROP TABLE IF EXISTS sys_oper_log;

CREATE TABLE sys_dept (
  id BIGINT NOT NULL AUTO_INCREMENT,
  parent_id BIGINT DEFAULT 0,
  ancestors VARCHAR(500) DEFAULT '0,',
  dept_name VARCHAR(64) NOT NULL,
  order_num INT DEFAULT 0,
  leader VARCHAR(32) DEFAULT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  del_flag CHAR(1) DEFAULT '0',
  create_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_dept_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门';

CREATE TABLE sys_user (
  id BIGINT NOT NULL AUTO_INCREMENT,
  dept_id BIGINT DEFAULT NULL,
  username VARCHAR(32) NOT NULL,
  nickname VARCHAR(32) NOT NULL,
  password VARCHAR(100) NOT NULL,
  email VARCHAR(64) DEFAULT NULL,
  phone VARCHAR(20) DEFAULT NULL,
  sex CHAR(1) DEFAULT '2',
  avatar VARCHAR(200) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  is_admin CHAR(1) DEFAULT '0',
  remark VARCHAR(255) DEFAULT NULL,
  del_flag CHAR(1) DEFAULT '0',
  create_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_username (username),
  KEY idx_user_dept (dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户';

CREATE TABLE sys_role (
  id BIGINT NOT NULL AUTO_INCREMENT,
  role_name VARCHAR(64) NOT NULL,
  role_key VARCHAR(64) NOT NULL,
  data_scope CHAR(1) DEFAULT '1',
  order_num INT DEFAULT 0,
  status CHAR(1) DEFAULT '0',
  remark VARCHAR(255) DEFAULT NULL,
  del_flag CHAR(1) DEFAULT '0',
  create_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_role_key (role_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色';

CREATE TABLE sys_menu (
  id BIGINT NOT NULL AUTO_INCREMENT,
  parent_id BIGINT DEFAULT 0,
  menu_name VARCHAR(64) NOT NULL,
  order_num INT DEFAULT 0,
  path VARCHAR(200) DEFAULT NULL,
  component VARCHAR(200) DEFAULT NULL,
  perms VARCHAR(100) DEFAULT NULL,
  menu_type CHAR(1) DEFAULT 'C',
  icon VARCHAR(64) DEFAULT NULL,
  visible CHAR(1) DEFAULT '0',
  status CHAR(1) DEFAULT '0',
  create_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_menu_parent (parent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单与按钮权限';

CREATE TABLE sys_user_role (
  user_id BIGINT NOT NULL,
  role_id BIGINT NOT NULL,
  PRIMARY KEY (user_id, role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户-角色';

CREATE TABLE sys_role_menu (
  role_id BIGINT NOT NULL,
  menu_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, menu_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色-菜单';

CREATE TABLE sys_role_dept (
  role_id BIGINT NOT NULL,
  dept_id BIGINT NOT NULL,
  PRIMARY KEY (role_id, dept_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色-自定义数据权限部门';

CREATE TABLE sys_dict_type (
  id BIGINT NOT NULL AUTO_INCREMENT,
  dict_name VARCHAR(64) NOT NULL,
  dict_type VARCHAR(64) NOT NULL,
  status CHAR(1) DEFAULT '0',
  remark VARCHAR(255) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_dict_type (dict_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典类型';

CREATE TABLE sys_dict_data (
  id BIGINT NOT NULL AUTO_INCREMENT,
  dict_type VARCHAR(64) NOT NULL,
  dict_label VARCHAR(64) NOT NULL,
  dict_value VARCHAR(64) NOT NULL,
  order_num INT DEFAULT 0,
  css_class VARCHAR(64) DEFAULT NULL,
  status CHAR(1) DEFAULT '0',
  create_time DATETIME DEFAULT NULL,
  update_time DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_dict_data_type (dict_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典数据';

CREATE TABLE sys_oper_log (
  id BIGINT NOT NULL AUTO_INCREMENT,
  title VARCHAR(64) DEFAULT NULL,
  business_type VARCHAR(20) DEFAULT NULL,
  method VARCHAR(200) DEFAULT NULL,
  request_method VARCHAR(10) DEFAULT NULL,
  oper_name VARCHAR(32) DEFAULT NULL,
  dept_name VARCHAR(64) DEFAULT NULL,
  oper_url VARCHAR(255) DEFAULT NULL,
  oper_ip VARCHAR(64) DEFAULT NULL,
  oper_param TEXT,
  json_result TEXT,
  status CHAR(1) DEFAULT '0',
  error_msg VARCHAR(500) DEFAULT NULL,
  cost_time BIGINT DEFAULT 0,
  oper_time DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_log_time (oper_time),
  KEY idx_log_name (oper_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志';

-- ============ 部门（仅根节点，子部门由用户自行维护） ============
INSERT INTO sys_dept (id, parent_id, ancestors, dept_name, order_num, leader, phone, status, del_flag, create_time, update_time) VALUES
(1, 0, '0,', '硕果大数据', 1, NULL, NULL, '0', '0', NOW(), NOW());

-- ============ 用户（仅内置超级管理员，密码 123456） ============
INSERT INTO sys_user (id, dept_id, username, nickname, password, email, phone, sex, status, is_admin, remark, del_flag, create_time, update_time) VALUES
(1, 1, 'admin', '超级管理员', '{{PWD}}', NULL, NULL, '1', '0', '1', '内置账号', '0', NOW(), NOW());

-- ============ 角色（仅内置超级管理员角色） ============
INSERT INTO sys_role (id, role_name, role_key, data_scope, order_num, status, remark, del_flag, create_time, update_time) VALUES
(1, '超级管理员', 'admin', '1', 1, '0', '拥有全部权限', '0', NOW(), NOW());

INSERT INTO sys_user_role (user_id, role_id) VALUES (1, 1);

-- ============ 菜单与按钮（仅系统管理） ============
INSERT INTO sys_menu (id, parent_id, menu_name, order_num, path, component, perms, menu_type, icon, visible, status, create_time, update_time) VALUES
(1, 0, '系统管理', 1, '/system', NULL, NULL, 'M', 'Setting', '0', '0', NOW(), NOW()),

(10, 1, '用户管理', 1, 'user', 'system/user/index', 'system:user:list', 'C', 'User', '0', '0', NOW(), NOW()),
(11, 1, '角色管理', 2, 'role', 'system/role/index', 'system:role:list', 'C', 'UserFilled', '0', '0', NOW(), NOW()),
(12, 1, '菜单管理', 3, 'menu', 'system/menu/index', 'system:menu:list', 'C', 'Menu', '0', '0', NOW(), NOW()),
(13, 1, '部门管理', 4, 'dept', 'system/dept/index', 'system:dept:list', 'C', 'OfficeBuilding', '0', '0', NOW(), NOW()),
(14, 1, '字典管理', 5, 'dict', 'system/dict/index', 'system:dict:list', 'C', 'Collection', '0', '0', NOW(), NOW()),
(15, 1, '操作日志', 6, 'log', 'system/log/index', 'system:log:list', 'C', 'Tickets', '0', '0', NOW(), NOW()),

(100, 10, '查询', 1, NULL, NULL, 'system:user:query', 'F', NULL, '0', '0', NOW(), NOW()),
(101, 10, '新增', 2, NULL, NULL, 'system:user:add', 'F', NULL, '0', '0', NOW(), NOW()),
(102, 10, '修改', 3, NULL, NULL, 'system:user:edit', 'F', NULL, '0', '0', NOW(), NOW()),
(103, 10, '删除', 4, NULL, NULL, 'system:user:remove', 'F', NULL, '0', '0', NOW(), NOW()),
(104, 10, '重置密码', 5, NULL, NULL, 'system:user:resetPwd', 'F', NULL, '0', '0', NOW(), NOW()),
(105, 10, '导出', 6, NULL, NULL, 'system:user:export', 'F', NULL, '0', '0', NOW(), NOW()),

(110, 11, '查询', 1, NULL, NULL, 'system:role:query', 'F', NULL, '0', '0', NOW(), NOW()),
(111, 11, '新增', 2, NULL, NULL, 'system:role:add', 'F', NULL, '0', '0', NOW(), NOW()),
(112, 11, '修改', 3, NULL, NULL, 'system:role:edit', 'F', NULL, '0', '0', NOW(), NOW()),
(113, 11, '删除', 4, NULL, NULL, 'system:role:remove', 'F', NULL, '0', '0', NOW(), NOW()),

(120, 12, '查询', 1, NULL, NULL, 'system:menu:query', 'F', NULL, '0', '0', NOW(), NOW()),
(121, 12, '新增', 2, NULL, NULL, 'system:menu:add', 'F', NULL, '0', '0', NOW(), NOW()),
(122, 12, '修改', 3, NULL, NULL, 'system:menu:edit', 'F', NULL, '0', '0', NOW(), NOW()),
(123, 12, '删除', 4, NULL, NULL, 'system:menu:remove', 'F', NULL, '0', '0', NOW(), NOW()),

(130, 13, '查询', 1, NULL, NULL, 'system:dept:query', 'F', NULL, '0', '0', NOW(), NOW()),
(131, 13, '新增', 2, NULL, NULL, 'system:dept:add', 'F', NULL, '0', '0', NOW(), NOW()),
(132, 13, '修改', 3, NULL, NULL, 'system:dept:edit', 'F', NULL, '0', '0', NOW(), NOW()),
(133, 13, '删除', 4, NULL, NULL, 'system:dept:remove', 'F', NULL, '0', '0', NOW(), NOW()),

(141, 14, '新增', 1, NULL, NULL, 'system:dict:add', 'F', NULL, '0', '0', NOW(), NOW()),
(142, 14, '修改', 2, NULL, NULL, 'system:dict:edit', 'F', NULL, '0', '0', NOW(), NOW()),
(143, 14, '删除', 3, NULL, NULL, 'system:dict:remove', 'F', NULL, '0', '0', NOW(), NOW()),

(150, 15, '清空', 1, NULL, NULL, 'system:log:remove', 'F', NULL, '0', '0', NOW(), NOW());

-- 超级管理员不依赖 sys_role_menu，代码里直接放行；这里仍全量授予便于查看
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 1, id FROM sys_menu;

-- ============ 字典（仅系统内置） ============
INSERT INTO sys_dict_type (id, dict_name, dict_type, status, remark, create_time, update_time) VALUES
(1, '用户性别', 'sys_user_sex', '0', '用户性别列表', NOW(), NOW()),
(2, '通用状态', 'sys_common_status', '0', '启用停用状态', NOW(), NOW());

INSERT INTO sys_dict_data (dict_type, dict_label, dict_value, order_num, css_class, status, create_time, update_time) VALUES
('sys_user_sex', '男', '1', 1, '', '0', NOW(), NOW()),
('sys_user_sex', '女', '2', 2, '', '0', NOW(), NOW()),
('sys_user_sex', '未知', '0', 3, '', '0', NOW(), NOW()),
('sys_common_status', '正常', '0', 1, 'success', '0', NOW(), NOW()),
('sys_common_status', '停用', '1', 2, 'danger', '0', NOW(), NOW());
