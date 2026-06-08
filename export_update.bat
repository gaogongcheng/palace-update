@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================
:: 《成哥出品》热更新 PCK 导出工具
:: 用法：双击运行此脚本
:: ============================================

echo.
echo ========================================
echo    🎮 成哥出品 - 热更新导出工具
echo ========================================
echo.

:: ---------- 配置区 ----------
:: Godot 编辑器的路径（根据你的安装位置修改）
set "GODOT=C:\Program Files\Godot\Godot_v4.6-stable_win64.exe"

:: Godot 项目路径
set "PROJECT=%USERPROFILE%\Documents\godot-open-rpg"

:: GitHub 仓库路径（就是本脚本所在的目录）
set "REPO=%~dp0"

:: 版本号文件
set "VERSION_FILE=%REPO%version.json"
:: ---------- 配置结束 ----------

:: 检查 Godot 是否存在
if not exist "%GODOT%" (
    echo [错误] 找不到 Godot 编辑器！
    echo 请修改脚本中的 GODOT 变量,指向你的 Godot 可执行文件
    echo.
    echo 常用路径：
    echo   Godot 4.x 标准安装: C:\Program Files\Godot\Godot_v4.6-stable_win64.exe
    echo   Steam 安装: C:\Program Files (x86)\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe
    echo.
    pause
    exit /b 1
)

:: 检查项目是否存在
if not exist "%PROJECT%\project.godot" (
    echo [错误] 找不到 Godot 项目！请确认 PROJECT 路径正确
    pause
    exit /b 1
)

:: 检查版本文件
if not exist "%VERSION_FILE%" (
    echo [错误] 找不到 version.json！
    pause
    exit /b 1
)

:: 读取当前版本号
for /f "tokens=*" %%i in ('powershell -Command "(Get-Content '%VERSION_FILE%' | ConvertFrom-Json).version" 2^>nul') do set CURRENT_VER=%%i
echo [信息] 当前版本: v%CDROM_VER%%CURRENT_VER%

:: 询问新版本号
set /p NEW_VER="请输入新版本号 (如 1.1): "
if "%NEW_VER%"=="" (
    echo [取消] 未输入版本号
    pause
    exit /b 0
)

echo.
echo [步骤 1/3] 正在更新 version.json ...

:: 更新 version.json
powershell -Command "$json = Get-Content '%VERSION_FILE%' | ConvertFrom-Json; $json.version = '%NEW_VER%'; $json.release_date = (Get-Date -Format 'yyyy-MM-dd'); $json | ConvertTo-Json | Set-Content '%VERSION_FILE%'"
if %errorlevel% neq 0 (
    echo [错误] 更新 version.json 失败！
    pause
    exit /b 1
)
echo [完成] version.json 已更新为 v%NEW_VER%

:: 同时更新 Godot 项目的版本号
echo.
echo [步骤 2/3] 正在导出 PCK 文件 ...

set "PCK_OUTPUT=%REPO%update.pck"

:: 使用 Godot 命令行导出 PCK
:: --headless 模式导出（不打开编辑器界面）
"%GODOT%" --headless --path "%PROJECT%" --export-pack "%PCK_OUTPUT%"

if %errorlevel% neq 0 (
    echo [错误] PCK 导出失败！请检查 Godot 编辑器路径和项目路径
    pause
    exit /b 1
)

if not exist "%PCK_OUTPUT%" (
    echo [错误] PCK 文件未生成！
    pause
    exit /b 1
)

:: 获取文件大小
for %%A in ("%PCK_OUTPUT%") do set "FILESIZE=%%~zA"
echo [完成] PCK 文件已导出: %PCK_OUTPUT% (%FILESIZE% 字节)

:: 更新 version.json 中的文件大小
powershell -Command "$json = Get-Content '%VERSION_FILE%' | ConvertFrom-Json; $json.filesize = %FILESIZE%; $json.file = 'update.pck'; $json | ConvertTo-Json | Set-Content '%VERSION_FILE%'"

echo.
echo [步骤 3/3] 准备提交到 GitHub ...
echo.
echo ========================================
echo    ✅ 导出成功！
echo.
echo    新版本: v%NEW_VER%
echo    文件: %PCK_OUTPUT%
echo    大小: %FILESIZE% 字节
echo.
echo    接下来请运行以下命令提交到 GitHub:
echo.
echo    cd "%REPO%"
echo    git add update.pck version.json
echo    git commit -m "发布 v%NEW_VER%"
echo    git push
echo ========================================

:: 询问是否自动提交
set /p AUTO_COMMIT="是否自动提交到 GitHub? (Y/N): "
if /i "%AUTO_COMMIT%"=="Y" (
    echo.
    echo [Git] 正在提交...
    cd /d "%REPO%"
    git add update.pck version.json
    git commit -m "发布 v%NEW_VER%"
    git push
    if %errorlevel% equ 0 (
        echo [完成] 已推送到 GitHub！等待 1-2 分钟后玩家即可收到更新。
    ) else (
        echo [错误] Git 推送失败，请手动执行上述命令
    )
)

echo.
pause
