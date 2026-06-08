@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================
:: 《成哥出品》热更新 PCK 导出工具 v2.0
:: 导出 → 上传到 GitHub Releases → 玩家自动更新
:: ============================================

echo.
echo ========================================
echo    🎮 成哥出品 - 热更新导出工具
echo ========================================
echo.

:: ---------- 配置 ----------
set "GODOT=C:\Godot\Godot_v4.6.3-stable_win64.exe"
set "PROJECT=%USERPROFILE%\Documents\godot-open-rpg"
set "REPO=%~dp0"
set "VERSION_FILE=%REPO%version.json"
:: --------------------------

if not exist "%GODOT%" (
    echo [错误] 找不到 Godot！请编辑此脚本修改 GODOT 路径
    pause & exit /b 1
)
if not exist "%PROJECT%\project.godot" (
    echo [错误] 找不到 Godot 项目！
    pause & exit /b 1
)

:: 读取当前版本
for /f "tokens=*" %%i in ('powershell -Command "(Get-Content '%VERSION_FILE%' | ConvertFrom-Json).version" 2^>nul') do set OLD_VER=%%i
echo [信息] 线上当前版本: v%OLD_VER%

:: 输入新版本号
set /p NEW_VER="请输入新版本号 (如 1.2): "
if "%NEW_VER%"=="" (echo [取消] & pause & exit /b 0)

:: 输入更新说明
set /p DESC="请输入更新说明: "
if "%DESC%"=="" set "DESC=版本更新"

echo.
echo ========================================
echo   准备发布 v%NEW_VER%
echo   更新内容: %DESC%
echo ========================================
echo.

:: 1. 更新 version.json
echo [1/4] 更新 version.json ...
powershell -Command ^
  "$json = Get-Content '%VERSION_FILE%' | ConvertFrom-Json; ^
   $json.version = '%NEW_VER%'; ^
   $json.description = '%DESC%'; ^
   $json.release_date = (Get-Date -Format 'yyyy-MM-dd'); ^
   $json.url = 'https://github.com/gaogongcheng/palace-update/releases/download/v' + '%NEW_VER%' + '/update.pck'; ^
   $json | ConvertTo-Json | Set-Content '%VERSION_FILE%'"
echo [完成]

:: 2. 导出 PCK
echo [2/4] 导出 PCK 文件 (可能需要 1-2 分钟)...
set "PCK_OUTPUT=%USERPROFILE%\Desktop\update_v%NEW_VER%.pck"
"%GODOT%" --headless --path "%PROJECT%" --export-pack "PCK" "%PCK_OUTPUT%"
if %errorlevel% neq 0 (
    echo [错误] PCK 导出失败！
    pause & exit /b 1
)
for %%A in ("%PCK_OUTPUT%") do set "FILESIZE=%%~zA"

:: 更新文件大小
powershell -Command "$json = Get-Content '%VERSION_FILE%' | ConvertFrom-Json; $json.filesize = %FILESIZE%; $json | ConvertTo-Json | Set-Content '%VERSION_FILE%'"

echo [完成] PCK 已导出到: %PCK_OUTPUT% (%FILESIZE% 字节)

:: 3. 提交 version.json 到仓库
echo [3/4] 提交版本信息到 GitHub...
cd /d "%REPO%"
git add version.json
git commit -m "发布 v%NEW_VER% - %DESC%"
git push
if %errorlevel% neq 0 (
    echo [警告] Git 推送失败，请手动执行
)

:: 4. 提示创建 Release
echo.
echo ========================================
echo [4/4] ⚠️  最后一步：上传 PCK 到 Release
echo ========================================
echo.
echo 请打开以下链接创建 Release 并上传 PCK 文件:
echo.
echo 🔗 https://github.com/gaogongcheng/palace-update/releases/new?tag=v%NEW_VER%&title=v%NEW_VER%%20-%20%DESC%
echo.
echo 操作步骤:
echo   ① 点击上面的链接
echo   ② Release title 已自动填写
echo   ③ 把桌面上的 %PCK_OUTPUT% 拖入 "Attach binaries" 区域
echo   ④ 点击 "Publish release" 按钮
echo.
echo ========================================
echo   ✅ 完成后，玩家重启游戏即可收到更新！
echo ========================================

start "" "https://github.com/gaogongcheng/palace-update/releases/new?tag=v%NEW_VER%&title=v%NEW_VER%%20-%20%DESC%"

echo.
pause
