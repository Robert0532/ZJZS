"""初始化 rbac_demo 数据库：建表 + 灌种子数据。可重复执行（先 DROP）。"""
import io
import sys

import pymysql

HOST = "127.0.0.1"
USER = "root"
PWD = "123456"
DB = "rbac_demo"
SQL_FILE = r"D:\workbuddy\2026-11-11-10-38-09\rbac-skeleton\sql\init.sql"
OUT = r"D:\workbuddy\2026-11-11-10-38-09\_dbinit.log"


def main():
    try:
        import bcrypt
    except ImportError:
        print("need bcrypt", file=sys.stderr)
        sys.exit(2)

    pwd_hash = bcrypt.hashpw(b"123456", bcrypt.gensalt(rounds=10, prefix=b"2a")).decode()
    with io.open(SQL_FILE, "r", encoding="utf-8") as f:
        sql = f.read().replace("{{PWD}}", pwd_hash)

    lines = [ln for ln in sql.splitlines() if not ln.strip().startswith("--")]
    statements = [s.strip() for s in "\n".join(lines).split(";") if s.strip()]

    # 本地首次运行需要先建库（不指定 database 连接）
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

    # 校验
    conn = pymysql.connect(host=HOST, user=USER, password=PWD, database=DB,
                           charset="utf8mb4", connect_timeout=15)
    report = [f"statements executed: {ok}", f"password hash: {pwd_hash}"]
    with conn.cursor() as cur:
        for t in ["sys_user", "sys_role", "sys_menu", "sys_dept", "sys_role_menu",
                  "sys_dict_data", "sys_oper_log"]:
            cur.execute(f"SELECT COUNT(*) FROM {t}")
            report.append(f"{t}: {cur.fetchone()[0]}")
        cur.execute("SELECT id, username, nickname, dept_id, is_admin FROM sys_user ORDER BY id")
        for row in cur.fetchall():
            report.append("user: " + str(row))
    conn.close()
    with io.open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
    print("done")


if __name__ == "__main__":
    main()
