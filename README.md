# 硕果大数据测试服 · 后台管理系统（Spring Boot + MySQL + Vue3）

> 仓库：`ZJZS` · 版本：**V3.0 前台上线**
> 线上地址：**http://111.228.23.195:3001/**（前台：`/portal`）

对标 JeePlus 后台管理能力的可运行系统：**用户 / 角色 / 菜单 / 部门 / 字典 / 操作日志** 六个系统模块 + **17 个部门数据模块** + **五种行级数据权限** + **菜单驱动的动态路由** + **前台驾驶舱大厅**。

已连接真实 MySQL、完成接口联调，并**部署为单个 jar + 单端口（前端页面与 API 同源）对外提供服务**。

## 0. 版本沿革

| 版本 | 提交 | 内容 |
|---|---|---|
| V1.0 | `30ea610` | 后台初始化：RBAC 六模块 + 纯净数据基线 |
| V1.1 | `f106655` | 部门数据管理结构：17 个一级菜单 / 16 部门 / 15 部门管理员 |
| V1.2 | `db9460b` | 侧边栏支持拖拽调宽 |
| V1.2.1 / V1.2.2 | `684e40e` / `6014f4a` | 首页精简 |
| V1.3 | `ce6351d` | 单端口同源部署（API 挂 `/api`，根路径发前端页 + SPA 回退） |
| V2.0 | `4fb531f` | 后台上线：部署到服务器、上线手册入库 |
| V2.0.1 | `fd0ca6a` | 登录页区分「登录后台 / 登录前台」双入口 |
| V2.1 | `f881d56` · `3cd90f4` | 前台数据驾驶舱：领导舱通栏 + 15 部门 5×3 宫格，舱内按数据权限过滤 |
| **V3.0** | 本版 | **前台上线**：前后台同源对外提供服务，代码与数据库基线一并入库 |

---

## 1. 技术栈

| 层 | 选型 |
|---|---|
| 后端 | Spring Boot 3.2.5 · MyBatis-Plus 3.5.5 · Hutool(JWT/BCrypt) · AOP |
| 数据库 | MySQL 8.0.16（本地 `127.0.0.1:3306/rbac_demo`） |
| 前端 | Vue 3.4 · Vite 5 · Element Plus 2.7 · Pinia · Vue Router 4 · axios |
| 鉴权 | 无状态 JWT + HandlerInterceptor（不引 Spring Security，降低排障成本） |

> 建表脚本保持向下兼容（不用 JSON 字段、窗口函数、生成列），MySQL 5.6 / 5.7 / 8.0 均可直接执行；索引列长度控制在 191 字符以内，避免 utf8mb4 的 767 字节索引上限问题。

---

## 2. 目录结构

```
rbac-skeleton/
├─ backend/
│  ├─ pom.xml
│  └─ src/main/
│     ├─ java/com/example/rbac/
│     │  ├─ common/      R / BizException / GlobalExceptionHandler
│     │  ├─ config/      MybatisPlus / Web(CORS+拦截器) / Jackson
│     │  ├─ security/    JwtService / LoginUser / AuthInterceptor
│     │  │               LoginUserLoader / RequiresPerm / DataScopeHelper
│     │  ├─ log/         @OperLog 注解 + OperLogAspect
│     │  ├─ entity/      11 个实体
│     │  ├─ mapper/      11 个 Mapper（少量 @Select，无 XML）
│     │  ├─ service/     8 个 Service
│     │  └─ controller/  9 个 Controller
│     └─ resources/application.yml
├─ frontend/
│  └─ src/
│     ├─ api/           按模块拆分的请求函数
│     ├─ layout/        侧边栏 + 顶栏
│     ├─ router/        常量路由 + 菜单转动态路由
│     ├─ store/         pinia 用户态
│     ├─ utils/request.js
│     ├─ directive/perm.js   v-perm 按钮级权限
│     ├─ views/
│     │  ├─ login / dashboard / error
│     │  ├─ portal/           前台：驾驶舱大厅 + 舱内页 + 缩略图组件
│     │  ├─ system/          用户 / 角色 / 菜单 / 部门 / 字典 / 日志
│     │  └─ modules/         16 个部门模块（shared 壳 + finance…project 薄包装）
│     └─ styles/index.css
├─ docs/
│  ├─ 菜单与部门结构方案_V1.1.md   17 个一级菜单 / 16 部门的 ID 与权限规划
│  ├─ 前台驾驶舱_V2.1.md          大厅布局、接口契约与权限口径
│  ├─ 发布说明_V3.0.md            V3.0 前台上线的范围、数据库基线与升级方式
│  └─ 上线部署手册_V2.0.md        线上服务器结构、运维命令、更新流程
├─ sql/
│  ├─ init.sql              建表 + 种子数据（可重复执行，纯净基线）
│  ├─ v1.1_departments.sql  V1.1 部门结构迁移（菜单 46 条 + 部门 16 + 角色 16）
│  ├─ gen_v11.py            上面那个 SQL 的生成器（改部门/菜单时重跑）
│  ├─ database.sql          当前运行库的完整导出（结构 + 数据）
│  └─ init_db.py            依次执行 init.sql + v1.1，注入 BCrypt 密码哈希
```

---

## 3. 启动

### 3.1 初始化数据库

```bash
python sql/init_db.py
```

脚本会：自动 `CREATE DATABASE IF NOT EXISTS rbac_demo`（utf8mb4）→ 执行 `init.sql` 建表 + 系统管理基线 → 再执行 `v1.1_departments.sql` 建 16 个部门、17 个一级菜单、部门管理员账号 → 把 `{{PWD}}` 替换为 `BCrypt("123456")` → 回读表行数校验（日志写到 `sql/_dbinit.log`）。
重复执行安全（`init.sql` 内先 `DROP TABLE`，`v1.1` 内按 ID 区间先删后插）。需要 `pymysql` 与 `bcrypt`。

也可以直接用仓库里的现成导出恢复（结构与数据同 `init.sql` 基线一致）：

```bash
mysql -h 127.0.0.1 -P 3306 -u root -p < sql/database.sql
```

### 3.2 启动后端

```bash
cd backend
mvn spring-boot:run
```

默认 `http://localhost:8088/api`，健康检查 `GET /api/health`。

数据库连接在 `backend/src/main/resources/application.yml`，当前指向本地：

```
jdbc:mysql://127.0.0.1:3306/rbac_demo
user=root  password=123456
```

### 3.2.1 一键启停（推荐）

本机 PowerShell 执行策略禁止 `.ps1`，所以用 `.bat`：

| 脚本 | 作用 |
|---|---|
| `start-backend.bat` | 优先 `java -jar target/rbac-skeleton-1.0.0.jar`，jar 不存在则先 `mvn package` |
| `start-frontend.bat` | `node node_modules\vite\bin\vite.js --port 5173 --strictPort` |
| `stop-services.bat` | 结束计划任务 + 按端口精确 kill 8088 / 5173 |

> **为什么用计划任务托管**：Agent 会话里启动的进程会在会话结束时被进程树回收（`run_in_background` 和 `Start-Process` 都一样）。用 `schtasks` 注册任务后，进程挂在任务计划程序下，与终端会话无关，可长期驻留：
>
> ```
> schtasks /create /tn "RBAC-Backend"  /tr "<项目路径>\start-backend.bat"  /sc once /st 23:59 /f
> schtasks /create /tn "RBAC-Frontend" /tr "<项目路径>\start-frontend.bat" /sc once /st 23:59 /f
> schtasks /run /tn "RBAC-Backend"
> schtasks /run /tn "RBAC-Frontend"
> ```
>
> 注意 `schtasks /end` 只结束批处理宿主，java / node 子进程会残留，所以 `stop-services.bat` 里补了按端口 `Stop-Process`。

**生产环境请把账号密码移出配置文件（环境变量/配置中心），并用 BCrypt 重设所有初始密码。**

### 3.3 启动前端

```bash
cd frontend
npm install
npm run dev
```

访问 `http://localhost:5173`，Vite 已把 `/api` 代理到 `8088`。

---

## 4. 菜单结构与初始账号

### 4.1 菜单（17 个一级 / 53 个可见页面）

| 序号 | 一级菜单 | 子菜单 |
|---|---|---|
| 0 | 领导数据驾驶舱 | 单页，无子菜单 |
| 1–15 | 财务部 / 商务法务部 / 市场部 / 采购管理部 / 安全生产监督管理部 / 技术质量部 / 工程管理部 / 人力资源部 / 项目技术支撑中心 / 科创与产品部 / 党建工作部 / 办公室 / 设计院 / 经理部与事业部 / 项目部，各为「XX数据管理」 | 每个下面固定两个：**数据填报**、**数据驾驶舱** |
| 16 | 系统管理 | 用户 / 角色 / 菜单 / 部门 / 字典 / 操作日志 |

### 4.2 账号（密码统一 `123456`）

| 账号 | 部门 | 角色 | 数据权限 |
|---|---|---|---|
| admin | 硕果大数据 | 超级管理员 | 全部数据 |
| finance / legal / market / purchase / safety | 财务部 / 商务法务部 / 市场部 / 采购管理部 / 安全生产监督管理部 | 对应部门管理员 | 本部门 |
| quality / engineering / hr / support / innovation | 技术质量部 / 工程管理部 / 人力资源部 / 项目技术支撑中心 / 科创与产品部 | 对应部门管理员 | 本部门 |
| party / office / design / division / project | 党建工作部 / 办公室 / 设计院 / 经理部与事业部 / 项目部 | 对应部门管理员 | 本部门 |

另有一个「公司领导（只读）」角色（`leader_readonly`，全公司只读），当前未绑定账号，需要时在用户管理里建。

**部门管理员登录后侧边栏只有自己那一个模块**（1 个目录 + 2 个页面），访问 `/system/*` 一律 403；admin 可见全部 17 个一级菜单。

> ⚠️ 拿到仓库后第一件事：用 admin 登录 → 用户管理 → 修改密码。`123456` 仅用于本地初始化。

---

## 5. 关键实现说明（也是这套骨架的重点）

### 5.1 权限三层

1. **菜单级**：`sys_menu` 决定侧边栏与路由，前端按 `/auth/info` 返回的菜单树 `addRoute`
2. **接口级**：`@RequiresPerm("system:user:add")`，拦截器比对当前用户 perms 集合，不匹配直接 403
3. **按钮级**：`v-perm="'system:user:add'"`，无权限直接移除 DOM（仅体验优化，真正的边界在后端）

`perms` 字符串必须与 `sys_menu.perms` **逐字符一致**，差一个字符就是 403——这是最常见的"配了权限还是不显示"的原因。

### 5.2 行级数据权限

`sys_role.data_scope` 五档：

| 值 | 含义 | 追加的 SQL 条件 |
|---|---|---|
| 1 | 全部数据 | 无 |
| 2 | 自定义部门 | `dept_id IN (sys_role_dept)` |
| 3 | 本部门 | `dept_id = 当前用户部门` |
| 4 | 本部门及以下 | `dept_id IN (本部门 + ancestors 命中本部门的子孙)` |
| 5 | 仅本人 | `owner_id = 当前用户` |

多角色时取**最宽**口径（`Math.min`）。实现见 `DataScopeHelper`。

**为什么不用 AOP**：`@DataScope` 注解切面在 Service 内部自调用时不经过代理，会**静默失效**——这是数据权限最常见的线上事故（测试环境全对，生产偶发越权）。这里改成显式调用 `dataScopeHelper.apply(wrapper, "dept_id", "owner_id")`，牺牲一点优雅换取"看得见、可断点"。

### 5.3 部门 ancestors

`sys_dept.ancestors` 存完整层级链（如 `0,1,5,`）。上级部门变更时，`refreshChildrenAncestors` 递归重算整棵子树——否则"本部门及以下"会漏数据。删除部门前校验子部门与用户，避免脏数据。

### 5.4 鉴权为什么每次查库

`AuthInterceptor` 每次请求按 `userId` 重新装配权限，不把权限塞进 token。代价是每请求 3~4 次查询（可用 Redis 缓存优化），收益是**停用账号、改权限、改部门立即生效**。骨架优先保证行为正确，缓存留作扩展点。

### 5.5 操作日志

`@OperLog(title="用户管理", businessType="INSERT")`，AOP 记录：入参、返回、耗时、IP、操作人/部门、异常信息。
日志写入包在 try-catch 里，**写日志失败不影响业务**；参数序列化会过滤掉 `MultipartFile` / Servlet 对象。

### 5.6 前台驾驶舱的权限口径

大厅对**所有登录账号返回完整的 16 张卡片**（领导舱 + 15 个部门），是否能看到舱内数据由 `data_scope` 决定：

- `PortalService` 用 `DataScopeHelper.visibleDeptIds()` 算出当前账号可见部门集合（`null` 表示不限部门）
- 卡片带 `accessible` 标记；不可见的卡片**照常展示、照常可点**，只是左上有「受限」角标
- 点进受限的舱不会跳 403，而是返回 `accessible=false` + 原因 + 当前账号**有权限的舱**（`peers`），让用户不至于走进死胡同
- 舱内数字只统计数据范围内的部门，`/api/portal/*` **不挂 `@RequiresPerm`**——权限过滤发生在 Service 层，而不是靠接口级拒绝

这样部门账号（`finance` 等）登录前台仍能看到 5×3 的完整宫格，但只有自己那一格能出数据，其余 14 格是"看得见、进不去"。

---

## 6. 接口清单（前缀 `/api`）

| 模块 | 方法 | 路径 | 权限标识 |
|---|---|---|---|
| 认证 | POST | `/auth/login` | 免登录 |
| | GET | `/auth/info` | 登录即可 |
| 用户 | GET | `/system/user/page` | `system:user:list` |
| | GET | `/system/user/{id}` | `system:user:query` |
| | POST/PUT/DELETE | `/system/user` | `add/edit/remove` |
| | PUT | `/system/user/{id}/password` | `system:user:resetPwd` |
| | GET | `/system/user/export` | `system:user:export`（CSV，带 BOM 可直接用 Excel 打开） |
| 角色 | GET | `/system/role/page` | `system:role:list` |
| | PUT | `/system/role/{id}/menus` | `system:role:edit` |
| | PUT | `/system/role/{id}/depts` | `system:role:edit`（自定义数据权限） |
| 菜单 | GET | `/system/menu/tree` | `system:menu:list` |
| 部门 | GET | `/system/dept/tree` | `system:dept:list` |
| 字典 | GET | `/system/dict/data/{dictType}` | 登录即可 |
| 日志 | GET | `/system/log/page` | `system:log:list` |

---

## 7. 已验证（当前基线 V3.0）

**本地构建与数据**

- `mvn clean package` 通过，产出 `target/rbac-skeleton-1.0.0.jar`（31.5MB）
- `vite build` 通过，0 错误；31 个部门页面全部编译进产物
- 基线数据：**17 部门 / 17 角色 / 16 账号 / 75 菜单（17 一级 + 30 部门二级 + 6 系统管理二级 + 22 按钮）/ 121 条授权 / 0 日志**
- 菜单表里 37 个 `component` 路径全部能落到实际 `.vue` 文件（脚本校验，0 缺失）
- `sql/init_db.py` 全量重建后可复现上述全部数字（163 条语句，一次执行通过）

**权限**

- admin 登录 → 17 个一级菜单，53 个可见页面；顺序与序号 0–16 一致
- `finance` / `quality` / `project` / `office` / `division` 登录 → 侧边栏仅本部门 1 个目录 + 2 个页面，访问 `/system/user/page` 返回 **403**
- 无 token 访问受保护接口返回 **401**；导出 CSV 带 UTF-8 BOM

**线上（服务器本机 + 公网双路验证）**

| 检查 | 结果 |
|---|---|
| 公网 `http://111.228.23.195:3001/` | **200** |
| `/api/health` | `{"code":200,...,"status":"UP"}` |
| 直接访问 `/finance/report` | 200 HTML（SPA 回退生效，刷新不 404） |
| admin 登录 | 200，17 个一级菜单 |
| finance 登录 | 仅「财务部数据管理」 |
| finance 访问 `/api/system/user/page` | **403** |
| 无 token 访问 | **401** |

**前台驾驶舱（V2.1 / V3.0 上线）**

| 检查 | 结果 |
|---|---|
| `admin` → `/api/portal/overview` | 200，`scopeLabel=全部数据`，16 张卡片全部 `accessible=true` |
| `finance` → 同一接口 | 200，`scopeLabel=本部门`，16 张卡片中 **1 张可用 / 15 张受限** |
| `finance` → `/api/portal/cockpit/finance` | 200，`accessible=true`，`userCount=1`、`visibleDeptCount=1` |
| `finance` → `/api/portal/cockpit/legal` | 200，`accessible=false`，提示「当前账号的数据范围为「本部门」，无权查看「商务法务部」的数据」 |
| 公网 `/portal` 与 `/portal/cockpit/finance` | 200 HTML（SPA 回退生效） |
| 无 token 调 `/api/portal/overview` | **401** |

---

## 8. 已知限制（做生产前必须补）

| 项 | 现状 | 生产建议 |
|---|---|---|
| 密码策略 | 仅校验长度 ≥6 | 加复杂度、登录失败锁定、90 天强制改密 |
| Token | 无刷新、无黑名单，登出仅前端清 token | 加 refresh token + Redis 黑名单 |
| 权限缓存 | 每请求查库 | Redis 缓存 + 变更时主动失效 |
| 前端路由 | 菜单最多支持两级嵌套 | 递归渲染侧边栏 |
| 导出 | CSV（手写，零依赖） | 大数据量换 EasyExcel 流式导出 |
| 数据权限 | 单表字段级 | 多表 JOIN 场景需扩展成 JSqlParser 改写 |
| 租户隔离 | 未实现 | 加 `tenant_id` + MyBatis-Plus 租户插件 |
| 单元测试 | 无 | 至少补权限与数据权限的用例（这部分最容易出越权） |
| 审计 | 操作日志 | 加登录日志、数据变更留痕 |

---

## 9. 部署形态（V2.0 起）

**单 jar + 单端口**：内嵌 Tomcat 同时提供前端页面与 API。

```
http://host:3001/            → /ZJZS/static/index.html（SPA，未命中路由回退到 index）
http://host:3001/api/**      → Spring MVC 接口
```

实现要点（见 `config/WebConfig.java`）：

- 用 `addPathPrefix("/api", @RestController.class)` 给**所有 Controller** 统一加前缀，而不是 `server.servlet.context-path`——后者会把静态资源也压进 `/api`，根路径就出不了页面
- 静态资源指向 `file:/ZJZS/static/` 与 `classpath:/static/`，本地开发时找不到目录也不报错
- SPA 回退：`/finance/report` 这类前端路由直接刷新时返回 `index.html`，否则 404
- 鉴权拦截器只拦 `/api/**`，静态资源不再被 401

服务器结构、systemd 单元、日志位置、更新流程见 **[docs/上线部署手册_V2.0.md](docs/上线部署手册_V2.0.md)**。

本地开发仍是前后端分离两端：后端 `8088`、前端 `5173` 代理 `/api`（第 3 节）。
