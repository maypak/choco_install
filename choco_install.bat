@echo off
CLS
ECHO **************************************
ECHO * Start Chocolatey Batch
ECHO **************************************

:::::::::::::::::::::::::::::::::::::::::
:: 체크 및 관리자 권한 가져 오기
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
:::::::::::::::::::::::::::::::::::::::::
:: UAC를 사용해서 관리자 권한으로 전환
if '%1'=='ELEV' (shift & goto gotPrivileges)
ECHO.
ECHO **************************************
ECHO * Use UAC, switch to admin
ECHO **************************************

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", "ELEV", "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%temp%\OEgetPrivileges.vbs"
exit /B

:gotPrivileges
:::::::::::::::::::::::::::::::::::::::::
:: 시작 하기
setlocal & pushd .

WHERE choco 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto chocoInstalled ) else ( goto chocoMissing )

:chocoMissing
::::::::::::::::::::::::::::
:: Chocolatey가 없을 경우 설치
::::::::::::::::::::::::::::
ECHO.
choice /M "Chocolatey not found. Install now?"
IF '%errorlevel%' == '2' exit /B
ECHO.
ECHO **************************************
ECHO * Chocolatey install
ECHO **************************************

@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))))" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

:chocoInstalled
ECHO.
ECHO **************************************
ECHO * Packages install
ECHO **************************************

@echo on

:: 항상 자동으로 yes를 선택하도록 설정
choco feature enable --name=allowGlobalConfirmation

:: 먼저 기존 패키지 업데이트
choco upgrade all -y

:: 사용할 어플리케이션 설치
set choco_install=choco install -fy
%choco_install% bandizip
%choco_install% googlechrome
%choco_install% javaruntime
%choco_install% python
%choco_install% nodejs
%choco_install% microsoft-windows-terminal
%choco_install% vscode
%choco_install% mysql
%choco_install% sublimetext2
%choco_install% dbeaver
%choco_install% choco install github-desktop
%choco_install% git.install --params "/GitAndUnixToolsOnPath /NoShellIntegration /NoGuiHereIntegration /WindowsTerminal"

:: 항상 자동으로 yes를 선택하는 옵션 끄기
choco feature disable --name=allowGlobalConfirmation

:: 업데이트 된 설정 다시 읽기
RefreshEnv.cmd

pause

:: 수정 전 원본 출처 https://gyuha.tistory.com/531