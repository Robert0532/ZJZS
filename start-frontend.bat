@echo off
chcp 65001 >nul
setlocal
set "NODE_HOME=C:\Users\Administrator\.workbuddy\binaries\node\versions\22.22.2-3"
set "PATH=%NODE_HOME%;%PATH%"
cd /d "%~dp0frontend"
if not exist "node_modules" (
  echo [RBAC] node_modules not found, installing from npmmirror ...
  call "%NODE_HOME%\npm.cmd" install --registry=https://registry.npmmirror.com --no-audit --no-fund
)
echo [RBAC] frontend dev server starting on http://localhost:5173
"%NODE_HOME%\node.exe" "node_modules\vite\bin\vite.js" --port 5173 --strictPort
endlocal
