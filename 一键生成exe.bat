@echo off
chcp 65001 >nul
title 定时关机工具 - EXE打包程序

echo.
echo ====================================
echo        定时关机工具 EXE 打包
echo ====================================
echo.


REM 进入当前目录
cd /d "%~dp0"


REM 检查源码

if not exist "定时关机.ps1" (
    echo [错误] 未找到 定时关机.ps1
    pause
    exit /b 1
)

echo [1/4] 找到程序源码


REM 查找ICO

set "ICON="

for %%i in (*.ico) do (
    set "ICON=%%i"
)


if not defined ICON (
    echo [错误] 未找到 ICO 图标文件
    pause
    exit /b 1
)


echo [2/4] 使用图标：
echo        %ICON%



REM 删除旧EXE

if exist "定时关机.exe" (
    echo [3/4] 删除旧版本...
    del /f /q "定时关机.exe"
) else (
    echo [3/4] 没有旧版本
)



echo [4/4] 正在生成程序...


powershell -NoProfile -ExecutionPolicy Bypass -Command "Import-Module PS2EXE; Invoke-PS2EXE '.\定时关机.ps1' '.\定时关机.exe' -iconFile '.\%ICON%' -noConsole" >nul 2>&1

echo.


if exist "定时关机.exe" (

    echo ====================================
    echo   生成成功！
    echo ====================================

) else (

    echo ====================================
    echo   生成失败！
    echo ====================================

)

echo.
timeout /t 3 
::>nul

exit