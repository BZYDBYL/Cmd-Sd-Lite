@echo off
chcp 936 >nul
setlocal enabledelayedexpansion

:: ================== �������� ==================
set "SCAN_DIR=C:\"
set "QUARANTINE_DIR=%SCAN_DIR%\Quarantine"
set "LOG_FILE=scan_log.txt"
set "VIRUS_DB=virus_db.txt"
set "WHITELIST=whitelist.txt"
set "USERS_DB=users.db"
set "OFFICIAL_SITE=https://www.cmd-sd.com"

set "REALTIME_MONITOR=0"
set "MODE=1"

set "EXTENSIONS=.exe .bat .cmd .ps1 .vbs .js .com .dll .scr .sys .lnk"

:: ����������
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

:: ================== ��¼ / ע�� ==================
:AUTH_MENU
cls
echo ========= �˻����� =========
echo 1. ��¼
echo 2. ע��
echo 3. �˳�
set /p auth=��ѡ��(1-3)^> 
if "%auth%"=="1" goto LOGIN
if "%auth%"=="2" goto REGISTER
if "%auth%"=="3" exit
goto AUTH_MENU

:LOGIN
set "CUR_USER="
set /p u=�û���^> 
set /p p=����^> 
for /f "tokens=1,2 delims==" %%a in (%USERS_DB%) do (
    if /i "%%a"=="%u%" if "%%b"=="%p%" set "CUR_USER=%u%"
)
if not defined CUR_USER (
    echo ��¼ʧ�ܣ�
    pause
    goto AUTH_MENU
)
echo ��¼�ɹ�����ӭ %CUR_USER%��
pause
goto MAIN_MENU

:REGISTER
set /p nu=���û���^> 
for /f "tokens=1 delims==" %%a in (%USERS_DB%) do (
    if /i "%%a"=="%nu%" (
        echo �û��Ѵ��ڣ�
        pause
        goto AUTH_MENU
    )
)
set /p np=������^> 
echo %nu%=%np%>>%USERS_DB%
echo ע��ɹ���
pause
goto AUTH_MENU

:: ================== ���˵� ==================
:MAIN_MENU
cls
echo ========= CMD-SD ɱ������ =========
echo ��ǰ�û���%CUR_USER%
echo 1. ����ɨ��
echo 2. ���ɨ��
echo 3. ��ȫģʽ
echo 4. ����ģʽ
echo 5. ��������
echo 6. �򿪹���
echo 7. �˳�
set /p c=��ѡ��(1-7)^> 

if "%c%"=="1" goto QUICK
if "%c%"=="2" goto DEEP
if "%c%"=="3" set MODE=1 & goto SCAN
if "%c%"=="4" set MODE=2 & goto SCAN
if "%c%"=="5" goto CLEAN
if "%c%"=="6" goto SITE
if "%c%"=="7" exit
goto MAIN_MENU

:: ɨ��
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
echo ɨ����ɣ���ɨ�� %TOTAL% ���ļ������� %BAD% ����
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
echo ����ɨ����ɣ���ɨ�� %TOTAL% ���ļ������� %BAD% ����
pause
goto MAIN_MENU

:DEEP
set "TOTAL=0"
set "BAD=0"
for /r "%SCAN_DIR%" %%f in (*.*) do (
    set /a TOTAL+=1
    call :CHECK "%%f"
)
echo ���ɨ����ɣ���ɨ�� %TOTAL% ���ļ������� %BAD% ����
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
        echo ���룺%f%
    )
)
goto :eof

:: ��������
:CLEAN
echo ������ɾ��ϵͳ��ʱ�ļ�������վ��
set /p yn=ȷ����?(Y/N)^> 
if /i not "%yn%"=="Y" goto MAIN_MENU
del /f /s /q "%TEMP%\*.*" >nul 2>&1
for /d %%d in ("%TEMP%\*") do rd /s /q "%%d" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d" >nul 2>&1
rd /s /q "C:\$Recycle.Bin" >nul 2>&1
echo ������ɣ�
pause
goto MAIN_MENU

:: �򿪹���
:SITE
start "" %OFFICIAL_SITE%
goto MAIN_MENU
