"""清理后的基线冒烟测试：只验系统管理模块 + 业务示例已彻底下线。"""
import io
import json
import urllib.error
import urllib.request

BASE = "http://localhost:8088/api"
out = []


def call(method, path, token=None, body=None):
    url = BASE + path
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Content-Type", "application/json")
    if token:
        req.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status, json.loads(r.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", "ignore")
        try:
            return e.code, json.loads(raw)
        except Exception:
            return e.code, {"raw": raw[:200]}


out.append("=== 1. 登录 ===")
st, res = call("POST", "/auth/login", body={"username": "admin", "password": "123456"})
if st != 200 or res.get("code") != 200:
    out.append(f"LOGIN FAIL {st} {res}")
    token = None
else:
    token = res["data"]["token"]
    out.append(f"admin 登录 OK, token 长度={len(token)}")

if token:
    out.append("")
    out.append("=== 2. 身份与菜单 ===")
    st, info = call("GET", "/auth/info", token)
    d = info["data"]
    out.append(f"用户={d['user']['username']}/{d['user']['nickname']} "
               f"部门={d['user'].get('deptName')} 角色={d['roles']} "
               f"顶级菜单={[m['menuName'] for m in d['menus']]} 权限数={len(d['perms'])}")

    out.append("")
    out.append("=== 3. 各模块数据量（应只剩系统内置） ===")
    st, u = call("GET", "/system/user/page?pageNum=1&pageSize=20", token)
    out.append(f"用户: total={u['data']['total']} -> "
               f"{[(r['username'], r['deptName']) for r in u['data']['records']]}")
    st, r = call("GET", "/system/role/page?pageNum=1&pageSize=20", token)
    out.append(f"角色: total={r['data']['total']} -> "
               f"{[(x['roleName'], x['roleKey']) for x in r['data']['records']]}")
    st, m = call("GET", "/system/menu/list", token)
    out.append(f"菜单/按钮: {len(m['data'])} 条")
    st, dp = call("GET", "/system/dept/tree", token)
    out.append(f"部门树: {[(x['deptName'], len(x.get('children') or [])) for x in dp['data']]}")
    st, dt = call("GET", "/system/dict/type/page?pageNum=1&pageSize=20", token)
    out.append(f"字典类型: total={dt['data']['total']} -> "
               f"{[x['dictType'] for x in dt['data']['records']]}")
    st, lg = call("GET", "/system/log/page?pageNum=1&pageSize=5", token)
    out.append(f"操作日志: total={lg['data']['total']}")

    out.append("")
    out.append("=== 4. 业务示例应已下线 ===")
    st, biz = call("GET", "/biz/demo/page?pageNum=1&pageSize=10", token)
    out.append(f"GET /biz/demo/page -> HTTP {st} {biz}")

    out.append("")
    out.append("=== 5. 鉴权边界 ===")
    st, res = call("GET", "/system/user/page", None)
    out.append(f"无 token -> HTTP {st} code={res.get('code')} msg={res.get('msg')}")

    out.append("")
    out.append("=== 6. 导出 ===")
    req = urllib.request.Request(BASE + "/system/user/export", method="GET")
    req.add_header("Authorization", "Bearer " + token)
    with urllib.request.urlopen(req, timeout=20) as r:
        csv_bytes = r.read()
    lines = [ln for ln in csv_bytes.decode("utf-8-sig", "ignore").splitlines() if ln.strip()]
    out.append(f"CSV {r.status} {r.headers.get('Content-Type')} {len(csv_bytes)}B "
               f"BOM={csv_bytes[:3].hex() == 'efbbbf'} 数据行={len(lines) - 1}")

with io.open(r"D:\workbuddy\2026-11-11-10-38-09\_apitest.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(out))
print("done")
