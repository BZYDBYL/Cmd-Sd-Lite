@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

:: ================== 基础配置 ==================
set "SCAN_DIR=C:\"
set "QUARANTINE_DIR=%SCAN_DIR%\Quarantine"
set "LOG_FILE=scan_log.txt"
set "VIRUS_DB=virus_db.txt"
set "WHITELIST=whitelist.txt"
set "USERS_DB=users.db"
set OFFICIAL_SITE=https://bzydbyl.github.io/Cmd-Sd-Lite/

set "REALTIME_MONITOR=0"
set "MODE=1"

set "EXTENSIONS=.exe .bat .cmd .ps1 .vbs .js .com .dll .scr .sys .lnk"

:: 创建隔离区
if not exist "%QUARANTINE_DIR%" mkdir "%QUARANTINE_DIR%"
if not exist "%WHITELIST%" echo .>>"%WHITELIST%"
if not exist "%VIRUS_DB%" (
    echo exe>>"%VIRUS_DB%"
    echo bat>>"%VIRUS_DB%"
    echo vbs>>"%VIRUS_DB%"
    echo js>>"%VIRUS_DB%"
    echo com>>"%VIRUS_DB%"
    echo dll>>"%VIRUS_DB%"
    echo ransom.lock>>"%VIRUS_DB%"
    echo wncry>>"%VIRUS_DB%"
    echo locky>>"%VIRUS_DB%"
    echo conficker>>"%VIRUS_DB%"
    echo mbr>>"%VIRUS_DB%"
)
if not exist "%USERS_DB%" echo ; username=password >"%USERS_DB%"

:: ================== 登录 / 注册 ==================
:AUTH_MENU
cls
echo ========= 账户中心 =========
echo 1. 登录
echo 2. 注册
echo 3. 退出
set /p auth=请选择(1-3)^> 
if "%auth%"=="1" goto LOGIN
if "%auth%"=="2" goto REGISTER
if "%auth%"=="3" exit
goto AUTH_MENU

:LOGIN
set "CUR_USER="
set /p u=用户名^> 
set /p p=密码^> 
for /f "tokens=1,2 delims==" %%a in (%USERS_DB%) do (
    if /i "%%a"=="%u%" if "%%b"=="%p%" set "CUR_USER=%u%"
)
if not defined CUR_USER (
    echo 登录失败！
    pause
    goto AUTH_MENU
)
echo 登录成功，欢迎 %CUR_USER%！
pause
goto MAIN_MENU

:REGISTER
set /p nu=新用户名^> 
for /f "tokens=1 delims==" %%a in (%USERS_DB%) do (
    if /i "%%a"=="%nu%" (
        echo 用户已存在！
        pause
        goto AUTH_MENU
    )
)
set /p np=新密码^> 
echo %nu%=%np%>>%USERS_DB%
echo 注册成功！
pause
goto AUTH_MENU

:: ================== 主菜单 ==================
:MAIN_MENU
cls
echo ========= CMD-SD 杀毒工具 =========
echo 当前用户：%CUR_USER%
echo 1. 快速扫描
echo 2. 深度扫描
echo 3. 安全模式
echo 4. 暴力模式
echo 5. 清理垃圾
echo 6. 打开官网
echo 7. 退出
set /p c=请选择(1-7)^> 

if "%c%"=="1" goto QUICK
if "%c%"=="2" goto DEEP
if "%c%"=="3" set MODE=1 & goto SCAN
if "%c%"=="4" set MODE=2 & goto SCAN
if "%c%"=="5" goto CLEAN
if "%c%"=="6" goto SITE
if "%c%"=="7" exit
goto MAIN_MENU

:: 扫描
:SCAN
set "TOTAL=0"
set "BAD=0"
if %MODE%==1 (
    for %%x in (%EXTENSIONS%) do (
        for /r "%SCAN_DIR%" %%f in (*%%x) do (
            set /a TOTAL+=1
            call :CHECK "%%f"
        )
    )
) else (
    for /r "%SCAN_DIR%" %%f in (*.*) do (
        set /a TOTAL+=1
        call :CHECK "%%f"
    )
)
echo 扫描完成，共扫描 %TOTAL% 个文件，隔离 %BAD% 个。
pause
goto MAIN_MENU

:QUICK
set "TOTAL=0"
set "BAD=0"
for %%x in (%EXTENSIONS%) do (
    for /r "%SCAN_DIR%" %%f in (*%%x) do (
        set /a TOTAL+=1
        call :CHECK "%%f"
    )
)
echo 快速扫描完成，共扫描 %TOTAL% 个文件，隔离 %BAD% 个。
pause
goto MAIN_MENU

:DEEP
set "TOTAL=0"
set "BAD=0"
for /r "%SCAN_DIR%" %%f in (*.*) do (
    set /a TOTAL+=1
    call :CHECK "%%f"
)
echo 深度扫描完成，共扫描 %TOTAL% 个文件，隔离 %BAD% 个。
pause
goto MAIN_MENU

:CHECK
set "f=%~1"
set "ISBAD=0"
for /f %%i in (%VIRUS_DB%) do (
    echo %f%| find /i "%%i" >nul && set ISBAD=1
)
if %ISBAD%==1 (
    move /y "%f%" "%QUARANTINE_DIR%">nul
    if not errorlevel 1 (
        set /a BAD+=1
        echo 隔离：%f%
    )
)
goto :eof

:: 清理垃圾
:CLEAN
echo 将永久删除系统临时文件、回收站等
set /p yn=确认吗?(Y/N)^> 
if /i not "%yn%"=="Y" goto MAIN_MENU
del /f /s /q "%TEMP%\*.*" >nul 2>&1
for /d %%d in ("%TEMP%\*") do rd /s /q "%%d" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d" >nul 2>&1
rd /s /q "C:\$Recycle.Bin" >nul 2>&1
echo 清理完成！
pause
goto MAIN_MENU

:: 打开官网
:SITE
start "" %OFFICIAL_SITE%
goto MAIN_MENU
