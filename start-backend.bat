@echo off
chcp 65001 >nul
setlocal
set "JAVA_HOME=D:\workbuddy\tools\jdk\jdk-17.0.21+9"
set "MVN_HOME=D:\workbuddy\tools\mvn\apache-maven-3.9.9"
set "PATH=%JAVA_HOME%\bin;%MVN_HOME%\bin;%PATH%"
cd /d "%~dp0backend"

if exist "target\rbac-skeleton-1.0.0.jar" goto runjar
echo [RBAC] jar not found, packaging ...
call "%MVN_HOME%\bin\mvn.cmd" -B -DskipTests package
if errorlevel 1 goto fail

:runjar
echo [RBAC] backend starting on http://localhost:8088/api
"%JAVA_HOME%\bin\java.exe" -jar "target\rbac-skeleton-1.0.0.jar" --server.port=8088
goto end

:fail
echo [RBAC] package failed, abort.
pause

:end
endlocal
