# 硕果大数据测试服 · 后台管理骨架（Spring Boot + MySQL + Vue3）

> 仓库：`ZJZS` · 版本：**V1.0 后台初始化**

对标 JeePlus 后台管理能力的可运行骨架：**用户 / 角色 / 菜单 / 部门 / 字典 / 操作日志** 六个系统模块 + **五种行级数据权限** + **菜单驱动的动态路由**。

已连接真实 MySQL 并完成初始化与接口联调，不是"能编译的示例"。

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
│     └─ views/         login / dashboard / system(6 个系统模块) / error
└─ sql/
   ├─ init.sql           建表 + 种子数据（可重复执行，纯净基线）
   ├─ database.sql       当前运行库的完整导出（结构 + 数据）
   └─ init_db.py         执行 init.sql 并注入 BCrypt 密码哈希
```

---

## 3. 启动

### 3.1 初始化数据库

```bash
python sql/init_db.py
```

脚本会：自动 `CREATE DATABASE IF NOT EXISTS rbac_demo`（utf8mb4）→ 读取 `init.sql` → 把 `{{PWD}}` 替换为 `BCrypt("123456")` → 逐条执行 → 回读表行数校验。
重复执行安全（脚本内先 `DROP TABLE`）。

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

## 4. 初始账号

| 账号 | 密码 | 部门 | 角色 | 数据权限 |
|---|---|---|---|---|
| admin | `123456` | 总公司 | 超级管理员 | 全部数据 |

初始化后库内**只保留超级管理员一个账号**，其余演示用户、演示角色、业务示例菜单与业务表均已清空。数据权限（五种口径）的代码能力保留，新建账号并配置 `sys_role.data_scope` 即可生效。

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

## 7. 已验证（当前基线）

- `mvn clean package` 通过，产出 `target/rbac-skeleton-1.0.0.jar`（31.5MB）
- `vite build` 通过，1697 个模块，0 错误
- 基线数据：1 用户 / 1 角色 / 29 菜单（含 22 个按钮）/ 1 部门 / 29 条角色-菜单 / 2 字典类型 / 0 日志
- admin 登录 → 菜单树仅「系统管理」六个子模块；用户、角色、部门、字典、日志各模块接口均返回符合预期的数据
- 业务示例已彻底下线：`/biz/demo/page` 返回 **HTTP 404**（不再是 200 + code 500）
- 无 token 访问受保护接口返回 401；导出 CSV 带 UTF-8 BOM

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
