"""初始化 rbac_demo 数据库：建表 + 灌种子数据 + 应用 V1.1 部门结构。可重复执行（先 DROP）。"""
import io
import os
import sys

import pymysql

HOST = "127.0.0.1"
USER = "root"
PWD = "123456"
DB = "rbac_demo"

BASE = os.path.dirname(os.path.abspath(__file__))
SQL_FILES = [
    os.path.join(BASE, "init.sql"),              # 建表 + 系统管理菜单基线
    os.path.join(BASE, "v1.1_departments.sql"),  # 16 部门 + 17 个一级菜单 + 部门管理员
]
OUT = os.path.join(BASE, "_dbinit.log")

SKIP = {"START TRANSACTION", "COMMIT", "SET NAMES utf8mb4"}


def load_statements(pwd_hash):
    statements = []
    for path in SQL_FILES:
        with io.open(path, "r", encoding="utf-8") as f:
            sql = f.read().replace("{{PWD}}", pwd_hash)
        lines = [ln for ln in sql.splitlines() if not ln.strip().startswith("--")]
        for st in "\n".join(lines).split(";"):
            st = st.strip()
            if st and st.upper() not in SKIP:
                statements.append(st)
    return statements


def main():
    try:
        import bcrypt
    except ImportError:
        print("need bcrypt", file=sys.stderr)
        sys.exit(2)

    pwd_hash = bcrypt.hashpw(b"123456", bcrypt.gensalt(rounds=10, prefix=b"2a")).decode()
    statements = load_statements(pwd_hash)

    boot = pymysql.connect(host=HOST, user=USER, password=PWD,
                           charset="utf8mb4", connect_timeout=15, autocommit=True)
    with boot.cursor() as cur:
        cur.execute(
            f"CREATE DATABASE IF NOT EXISTS `{DB}` "
            "DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
        )
    boot.close()

    conn = pymysql.connect(host=HOST, user=USER, password=PWD, database=DB,
                           charset="utf8mb4", connect_timeout=15, autocommit=False)
    ok = 0
    try:
        with conn.cursor() as cur:
            for st in statements:
                cur.execute(st)
                ok += 1
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"FAIL after {ok} statements: {type(e).__name__}: {e}")
        raise
    finally:
        conn.close()

    conn = pymysql.connect(host=HOST, user=USER, password=PWD, database=DB,
                           charset="utf8mb4", connect_timeout=15)
    report = [f"statements executed: {ok}", f"password hash: {pwd_hash}"]
    with conn.cursor() as cur:
        for t in ["sys_user", "sys_role", "sys_menu", "sys_dept", "sys_role_menu",
                  "sys_user_role", "sys_dict_data", "sys_oper_log"]:
            cur.execute(f"SELECT COUNT(*) FROM {t}")
            report.append(f"{t}: {cur.fetchone()[0]}")
        cur.execute("SELECT COUNT(*) FROM sys_menu WHERE parent_id = 0")
        report.append(f"top_menus: {cur.fetchone()[0]}")
        cur.execute("SELECT id, username, nickname, dept_id, is_admin FROM sys_user ORDER BY id")
        for row in cur.fetchall():
            report.append("user: " + str(row))
        cur.execute("SELECT id, dept_name FROM sys_dept ORDER BY order_num")
        for row in cur.fetchall():
            report.append("dept: " + str(row))
    conn.close()
    with io.open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
    print("done")


if __name__ == "__main__":
    main()
