@echo off
chcp 65001 >nul
echo 正在刷新图标缓存...

REM 结束资源管理器
taskkill /f /im explorer.exe >nul

REM 删除图标缓存文件
del /f /q "%userprofile%\AppData\Local\IconCache.db" 2>nul
del /f /q "%userprofile%\AppData\Local\Microsoft\Windows\Explorer\iconcache*" 2>nul

REM 重启资源管理器
start explorer.exe

echo 刷新完成！
timeout /t 2 >nul