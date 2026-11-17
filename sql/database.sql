-- MySQL dump 10.13  Distrib 8.0.16, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: rbac_demo
-- ------------------------------------------------------
-- Server version	8.0.16

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
 SET NAMES utf8mb4 ;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `rbac_demo`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `rbac_demo` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `rbac_demo`;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_dept` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) DEFAULT '0',
  `ancestors` varchar(500) DEFAULT '0,',
  `dept_name` varchar(64) NOT NULL,
  `order_num` int(11) DEFAULT '0',
  `leader` varchar(32) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `status` char(1) DEFAULT '0',
  `del_flag` char(1) DEFAULT '0',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_dept_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='部门';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES (1,0,'0,','硕果大数据',1,NULL,NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27');
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_data`
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_dict_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dict_type` varchar(64) NOT NULL,
  `dict_label` varchar(64) NOT NULL,
  `dict_value` varchar(64) NOT NULL,
  `order_num` int(11) DEFAULT '0',
  `css_class` varchar(64) DEFAULT NULL,
  `status` char(1) DEFAULT '0',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_dict_data_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,'sys_user_sex','男','1',1,'','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(2,'sys_user_sex','女','2',2,'','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(3,'sys_user_sex','未知','0',3,'','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(4,'sys_common_status','正常','0',1,'success','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(5,'sys_common_status','停用','1',2,'danger','0','2026-11-11 11:54:27','2026-11-11 11:54:27');
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_type`
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_dict_type` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dict_name` varchar(64) NOT NULL,
  `dict_type` varchar(64) NOT NULL,
  `status` char(1) DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dict_type` (`dict_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES (1,'用户性别','sys_user_sex','0','用户性别列表','2026-11-11 11:54:27','2026-11-11 11:54:27'),(2,'通用状态','sys_common_status','0','启用停用状态','2026-11-11 11:54:27','2026-11-11 11:54:27');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_menu` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent_id` bigint(20) DEFAULT '0',
  `menu_name` varchar(64) NOT NULL,
  `order_num` int(11) DEFAULT '0',
  `path` varchar(200) DEFAULT NULL,
  `component` varchar(200) DEFAULT NULL,
  `perms` varchar(100) DEFAULT NULL,
  `menu_type` char(1) DEFAULT 'C',
  `icon` varchar(64) DEFAULT NULL,
  `visible` char(1) DEFAULT '0',
  `status` char(1) DEFAULT '0',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_menu_parent` (`parent_id`)
) ENGINE=InnoDB AUTO_INCREMENT=203 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单与按钮权限';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,0,'系统管理',1,'/system',NULL,NULL,'M','Setting','0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(10,1,'用户管理',1,'user','system/user/index','system:user:list','C','User','0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(11,1,'角色管理',2,'role','system/role/index','system:role:list','C','UserFilled','0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(12,1,'菜单管理',3,'menu','system/menu/index','system:menu:list','C','Menu','0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(13,1,'部门管理',4,'dept','system/dept/index','system:dept:list','C','OfficeBuilding','0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(14,1,'字典管理',5,'dict','system/dict/index','system:dict:list','C','Collection','0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(15,1,'操作日志',6,'log','system/log/index','system:log:list','C','Tickets','0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(100,10,'查询',1,NULL,NULL,'system:user:query','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(101,10,'新增',2,NULL,NULL,'system:user:add','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(102,10,'修改',3,NULL,NULL,'system:user:edit','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(103,10,'删除',4,NULL,NULL,'system:user:remove','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(104,10,'重置密码',5,NULL,NULL,'system:user:resetPwd','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(105,10,'导出',6,NULL,NULL,'system:user:export','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(110,11,'查询',1,NULL,NULL,'system:role:query','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(111,11,'新增',2,NULL,NULL,'system:role:add','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(112,11,'修改',3,NULL,NULL,'system:role:edit','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(113,11,'删除',4,NULL,NULL,'system:role:remove','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(120,12,'查询',1,NULL,NULL,'system:menu:query','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(121,12,'新增',2,NULL,NULL,'system:menu:add','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(122,12,'修改',3,NULL,NULL,'system:menu:edit','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(123,12,'删除',4,NULL,NULL,'system:menu:remove','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(130,13,'查询',1,NULL,NULL,'system:dept:query','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(131,13,'新增',2,NULL,NULL,'system:dept:add','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(132,13,'修改',3,NULL,NULL,'system:dept:edit','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(133,13,'删除',4,NULL,NULL,'system:dept:remove','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(141,14,'新增',1,NULL,NULL,'system:dict:add','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(142,14,'修改',2,NULL,NULL,'system:dict:edit','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(143,14,'删除',3,NULL,NULL,'system:dict:remove','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27'),(150,15,'清空',1,NULL,NULL,'system:log:remove','F',NULL,'0','0','2026-11-11 11:54:27','2026-11-11 11:54:27');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_oper_log`
--

DROP TABLE IF EXISTS `sys_oper_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_oper_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(64) DEFAULT NULL,
  `business_type` varchar(20) DEFAULT NULL,
  `method` varchar(200) DEFAULT NULL,
  `request_method` varchar(10) DEFAULT NULL,
  `oper_name` varchar(32) DEFAULT NULL,
  `dept_name` varchar(64) DEFAULT NULL,
  `oper_url` varchar(255) DEFAULT NULL,
  `oper_ip` varchar(64) DEFAULT NULL,
  `oper_param` text,
  `json_result` text,
  `status` char(1) DEFAULT '0',
  `error_msg` varchar(500) DEFAULT NULL,
  `cost_time` bigint(20) DEFAULT '0',
  `oper_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_log_time` (`oper_time`),
  KEY `idx_log_name` (`oper_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_oper_log`
--

LOCK TABLES `sys_oper_log` WRITE;
/*!40000 ALTER TABLE `sys_oper_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_oper_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(64) NOT NULL,
  `role_key` varchar(64) NOT NULL,
  `data_scope` char(1) DEFAULT '1',
  `order_num` int(11) DEFAULT '0',
  `status` char(1) DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  `del_flag` char(1) DEFAULT '0',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_key` (`role_key`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'超级管理员','admin','1',1,'0','拥有全部权限','0','2026-11-11 11:54:27','2026-11-11 11:54:27');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_dept`
--

DROP TABLE IF EXISTS `sys_role_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_role_dept` (
  `role_id` bigint(20) NOT NULL,
  `dept_id` bigint(20) NOT NULL,
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色-自定义数据权限部门';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_dept`
--

LOCK TABLES `sys_role_dept` WRITE;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint(20) NOT NULL,
  `menu_id` bigint(20) NOT NULL,
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色-菜单';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES (1,1),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,100),(1,101),(1,102),(1,103),(1,104),(1,105),(1,110),(1,111),(1,112),(1,113),(1,120),(1,121),(1,122),(1,123),(1,130),(1,131),(1,132),(1,133),(1,141),(1,142),(1,143),(1,150);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dept_id` bigint(20) DEFAULT NULL,
  `username` varchar(32) NOT NULL,
  `nickname` varchar(32) NOT NULL,
  `password` varchar(100) NOT NULL,
  `email` varchar(64) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `sex` char(1) DEFAULT '2',
  `avatar` varchar(200) DEFAULT NULL,
  `status` char(1) DEFAULT '0',
  `is_admin` char(1) DEFAULT '0',
  `remark` varchar(255) DEFAULT NULL,
  `del_flag` char(1) DEFAULT '0',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_username` (`username`),
  KEY `idx_user_dept` (`dept_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,1,'admin','超级管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2','admin@example.com','13800000001','1',NULL,'0','1','内置账号','0','2026-11-11 11:54:27','2026-11-11 11:54:27');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_role`
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
 SET character_set_client = utf8mb4 ;
CREATE TABLE `sys_user_role` (
  `user_id` bigint(20) NOT NULL,
  `role_id` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户-角色';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_role`
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` VALUES (1,1);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'rbac_demo'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-17 20:02:49
