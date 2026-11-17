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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='部门';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES (1,0,'0,','硕果大数据',1,NULL,NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(2,1,'0,1,','公司领导',0,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(3,1,'0,1,','财务部',1,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(4,1,'0,1,','商务法务部',2,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(5,1,'0,1,','市场部',3,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(6,1,'0,1,','采购管理部',4,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(7,1,'0,1,','安全生产监督管理部',5,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(8,1,'0,1,','技术质量部',6,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(9,1,'0,1,','工程管理部',7,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(10,1,'0,1,','人力资源部',8,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(11,1,'0,1,','项目技术支撑中心',9,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(12,1,'0,1,','科创与产品部',10,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(13,1,'0,1,','党建工作部',11,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(14,1,'0,1,','办公室',12,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(15,1,'0,1,','设计院',13,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(16,1,'0,1,','经理部与事业部',14,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL),(17,1,'0,1,','项目部',15,NULL,NULL,'0','0','2026-11-17 20:57:00',NULL);
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
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_data`
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` VALUES (1,'sys_user_sex','男','1',1,'','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(2,'sys_user_sex','女','2',2,'','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(3,'sys_user_sex','未知','0',3,'','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(4,'sys_common_status','正常','0',1,'success','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(5,'sys_common_status','停用','1',2,'danger','0','2026-11-17 20:57:00','2026-11-17 20:57:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_type`
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` VALUES (1,'用户性别','sys_user_sex','0','用户性别列表','2026-11-17 20:57:00','2026-11-17 20:57:00'),(2,'通用状态','sys_common_status','0','启用停用状态','2026-11-17 20:57:00','2026-11-17 20:57:00');
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
) ENGINE=InnoDB AUTO_INCREMENT=2153 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单与按钮权限';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,0,'系统管理',16,'/system',NULL,NULL,'M','Setting','0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(10,1,'用户管理',1,'user','system/user/index','system:user:list','C','User','0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(11,1,'角色管理',2,'role','system/role/index','system:role:list','C','UserFilled','0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(12,1,'菜单管理',3,'menu','system/menu/index','system:menu:list','C','Menu','0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(13,1,'部门管理',4,'dept','system/dept/index','system:dept:list','C','OfficeBuilding','0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(14,1,'字典管理',5,'dict','system/dict/index','system:dict:list','C','Collection','0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(15,1,'操作日志',6,'log','system/log/index','system:log:list','C','Tickets','0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(100,10,'查询',1,NULL,NULL,'system:user:query','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(101,10,'新增',2,NULL,NULL,'system:user:add','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(102,10,'修改',3,NULL,NULL,'system:user:edit','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(103,10,'删除',4,NULL,NULL,'system:user:remove','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(104,10,'重置密码',5,NULL,NULL,'system:user:resetPwd','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(105,10,'导出',6,NULL,NULL,'system:user:export','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(110,11,'查询',1,NULL,NULL,'system:role:query','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(111,11,'新增',2,NULL,NULL,'system:role:add','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(112,11,'修改',3,NULL,NULL,'system:role:edit','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(113,11,'删除',4,NULL,NULL,'system:role:remove','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(120,12,'查询',1,NULL,NULL,'system:menu:query','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(121,12,'新增',2,NULL,NULL,'system:menu:add','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(122,12,'修改',3,NULL,NULL,'system:menu:edit','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(123,12,'删除',4,NULL,NULL,'system:menu:remove','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(130,13,'查询',1,NULL,NULL,'system:dept:query','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(131,13,'新增',2,NULL,NULL,'system:dept:add','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(132,13,'修改',3,NULL,NULL,'system:dept:edit','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(133,13,'删除',4,NULL,NULL,'system:dept:remove','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(141,14,'新增',1,NULL,NULL,'system:dict:add','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(142,14,'修改',2,NULL,NULL,'system:dict:edit','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(143,14,'删除',3,NULL,NULL,'system:dict:remove','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(150,15,'清空',1,NULL,NULL,'system:log:remove','F',NULL,'0','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(1000,0,'领导数据驾驶舱',0,'/leader','modules/leader/cockpit/index','leader:cockpit:view','C','DataLine','0','0','2026-11-17 20:57:00',NULL),(1001,0,'财务部数据管理',1,'/finance',NULL,NULL,'M','Money','0','0','2026-11-17 20:57:00',NULL),(1002,0,'商务法务部数据管理',2,'/legal',NULL,NULL,'M','Document','0','0','2026-11-17 20:57:00',NULL),(1003,0,'市场部数据管理',3,'/market',NULL,NULL,'M','TrendCharts','0','0','2026-11-17 20:57:00',NULL),(1004,0,'采购管理部数据管理',4,'/purchase',NULL,NULL,'M','ShoppingCart','0','0','2026-11-17 20:57:00',NULL),(1005,0,'安全生产监督管理部数据管理',5,'/safety',NULL,NULL,'M','Warning','0','0','2026-11-17 20:57:00',NULL),(1006,0,'技术质量部数据管理',6,'/quality',NULL,NULL,'M','Medal','0','0','2026-11-17 20:57:00',NULL),(1007,0,'工程管理部数据管理',7,'/engineering',NULL,NULL,'M','Tools','0','0','2026-11-17 20:57:00',NULL),(1008,0,'人力资源部数据管理',8,'/hr',NULL,NULL,'M','User','0','0','2026-11-17 20:57:00',NULL),(1009,0,'项目技术支撑中心数据管理',9,'/support',NULL,NULL,'M','Connection','0','0','2026-11-17 20:57:00',NULL),(1010,0,'科创与产品部数据管理',10,'/innovation',NULL,NULL,'M','MagicStick','0','0','2026-11-17 20:57:00',NULL),(1011,0,'党建工作部数据管理',11,'/party',NULL,NULL,'M','Flag','0','0','2026-11-17 20:57:00',NULL),(1012,0,'办公室数据管理',12,'/office',NULL,NULL,'M','OfficeBuilding','0','0','2026-11-17 20:57:00',NULL),(1013,0,'设计院数据管理',13,'/design',NULL,NULL,'M','Picture','0','0','2026-11-17 20:57:00',NULL),(1014,0,'经理部与事业部数据管理',14,'/division',NULL,NULL,'M','Grid','0','0','2026-11-17 20:57:00',NULL),(1015,0,'项目部数据管理',15,'/project',NULL,NULL,'M','MapLocation','0','0','2026-11-17 20:57:00',NULL),(2011,1001,'数据填报',1,'report','modules/finance/report/index','finance:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2012,1001,'数据驾驶舱',2,'cockpit','modules/finance/cockpit/index','finance:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2021,1002,'数据填报',1,'report','modules/legal/report/index','legal:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2022,1002,'数据驾驶舱',2,'cockpit','modules/legal/cockpit/index','legal:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2031,1003,'数据填报',1,'report','modules/market/report/index','market:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2032,1003,'数据驾驶舱',2,'cockpit','modules/market/cockpit/index','market:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2041,1004,'数据填报',1,'report','modules/purchase/report/index','purchase:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2042,1004,'数据驾驶舱',2,'cockpit','modules/purchase/cockpit/index','purchase:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2051,1005,'数据填报',1,'report','modules/safety/report/index','safety:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2052,1005,'数据驾驶舱',2,'cockpit','modules/safety/cockpit/index','safety:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2061,1006,'数据填报',1,'report','modules/quality/report/index','quality:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2062,1006,'数据驾驶舱',2,'cockpit','modules/quality/cockpit/index','quality:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2071,1007,'数据填报',1,'report','modules/engineering/report/index','engineering:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2072,1007,'数据驾驶舱',2,'cockpit','modules/engineering/cockpit/index','engineering:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2081,1008,'数据填报',1,'report','modules/hr/report/index','hr:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2082,1008,'数据驾驶舱',2,'cockpit','modules/hr/cockpit/index','hr:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2091,1009,'数据填报',1,'report','modules/support/report/index','support:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2092,1009,'数据驾驶舱',2,'cockpit','modules/support/cockpit/index','support:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2101,1010,'数据填报',1,'report','modules/innovation/report/index','innovation:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2102,1010,'数据驾驶舱',2,'cockpit','modules/innovation/cockpit/index','innovation:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2111,1011,'数据填报',1,'report','modules/party/report/index','party:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2112,1011,'数据驾驶舱',2,'cockpit','modules/party/cockpit/index','party:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2121,1012,'数据填报',1,'report','modules/office/report/index','office:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2122,1012,'数据驾驶舱',2,'cockpit','modules/office/cockpit/index','office:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2131,1013,'数据填报',1,'report','modules/design/report/index','design:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2132,1013,'数据驾驶舱',2,'cockpit','modules/design/cockpit/index','design:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2141,1014,'数据填报',1,'report','modules/division/report/index','division:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2142,1014,'数据驾驶舱',2,'cockpit','modules/division/cockpit/index','division:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2151,1015,'数据填报',1,'report','modules/project/report/index','project:report:list','C',NULL,'0','0','2026-11-17 20:57:00',NULL),(2152,1015,'数据驾驶舱',2,'cockpit','modules/project/cockpit/index','project:cockpit:view','C',NULL,'0','0','2026-11-17 20:57:00',NULL);
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志';
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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'超级管理员','admin','1',1,'0','拥有全部权限','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(2,'财务部管理员','dept_admin_finance','3',1,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(3,'商务法务部管理员','dept_admin_legal','3',2,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(4,'市场部管理员','dept_admin_market','3',3,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(5,'采购管理部管理员','dept_admin_purchase','3',4,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(6,'安全生产监督管理部管理员','dept_admin_safety','3',5,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(7,'技术质量部管理员','dept_admin_quality','3',6,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(8,'工程管理部管理员','dept_admin_engineering','3',7,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(9,'人力资源部管理员','dept_admin_hr','3',8,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(10,'项目技术支撑中心管理员','dept_admin_support','3',9,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(11,'科创与产品部管理员','dept_admin_innovation','3',10,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(12,'党建工作部管理员','dept_admin_party','3',11,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(13,'办公室管理员','dept_admin_office','3',12,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(14,'设计院管理员','dept_admin_design','3',13,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(15,'经理部与事业部管理员','dept_admin_division','3',14,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(16,'项目部管理员','dept_admin_project','3',15,'0','本部门数据','0','2026-11-17 20:57:00',NULL),(17,'公司领导（只读）','leader_readonly','1',0,'0','全公司只读，仅看驾驶舱','0','2026-11-17 20:57:00',NULL);
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
INSERT INTO `sys_role_menu` VALUES (1,1),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,100),(1,101),(1,102),(1,103),(1,104),(1,105),(1,110),(1,111),(1,112),(1,113),(1,120),(1,121),(1,122),(1,123),(1,130),(1,131),(1,132),(1,133),(1,141),(1,142),(1,143),(1,150),(1,1000),(1,1001),(1,1002),(1,1003),(1,1004),(1,1005),(1,1006),(1,1007),(1,1008),(1,1009),(1,1010),(1,1011),(1,1012),(1,1013),(1,1014),(1,1015),(1,2011),(1,2012),(1,2021),(1,2022),(1,2031),(1,2032),(1,2041),(1,2042),(1,2051),(1,2052),(1,2061),(1,2062),(1,2071),(1,2072),(1,2081),(1,2082),(1,2091),(1,2092),(1,2101),(1,2102),(1,2111),(1,2112),(1,2121),(1,2122),(1,2131),(1,2132),(1,2141),(1,2142),(1,2151),(1,2152),(2,1001),(2,2011),(2,2012),(3,1002),(3,2021),(3,2022),(4,1003),(4,2031),(4,2032),(5,1004),(5,2041),(5,2042),(6,1005),(6,2051),(6,2052),(7,1006),(7,2061),(7,2062),(8,1007),(8,2071),(8,2072),(9,1008),(9,2081),(9,2082),(10,1009),(10,2091),(10,2092),(11,1010),(11,2101),(11,2102),(12,1011),(12,2111),(12,2112),(13,1012),(13,2121),(13,2122),(14,1013),(14,2131),(14,2132),(15,1014),(15,2141),(15,2142),(16,1015),(16,2151),(16,2152),(17,1000);
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
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,1,'admin','超级管理员','$2a$10$9fLybHA21fBRfsGw7CqzPe2X/xaqTcZ8RrHtTK.a/UAn.j.WFRgLi',NULL,NULL,'1',NULL,'0','1','内置账号','0','2026-11-17 20:57:00','2026-11-17 20:57:00'),(2,3,'finance','财务部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(3,4,'legal','商务法务部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(4,5,'market','市场部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(5,6,'purchase','采购管理部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(6,7,'safety','安全生产监督管理部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(7,8,'quality','技术质量部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(8,9,'engineering','工程管理部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(9,10,'hr','人力资源部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(10,11,'support','项目技术支撑中心管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(11,12,'innovation','科创与产品部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(12,13,'party','党建工作部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(13,14,'office','办公室管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(14,15,'design','设计院管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(15,16,'division','经理部与事业部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL),(16,17,'project','项目部管理员','$2a$10$coA1rQ6IWnl3ERv24QUIcOem4fdwmI7MZEK4psx8bUBaqSM0H0Re2',NULL,NULL,'2',NULL,'0','0','部门管理员','0','2026-11-17 20:57:00',NULL);
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
INSERT INTO `sys_user_role` VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(11,11),(12,12),(13,13),(14,14),(15,15),(16,16);
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

-- Dump completed on 2026-11-17 21:50:51
