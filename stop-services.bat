@echo off
chcp 65001 >nul
echo [RBAC] stopping services ...
schtasks /end /tn "RBAC-Backend" >nul 2>&1
schtasks /end /tn "RBAC-Frontend" >nul 2>&1
powershell -NoProfile -Command "$p=@(8088,5173); foreach($x in $p){ $c=Get-NetTCPConnection -LocalPort $x -State Listen -ErrorAction SilentlyContinue; foreach($i in $c){ try{ Stop-Process -Id $i.OwningProcess -Force -ErrorAction Stop; Write-Host ('  killed port ' + $x + ' pid=' + $i.OwningProcess) }catch{} } }"
echo [RBAC] done. ports 8088 / 5173 released.
timeout /t 2 >nul
