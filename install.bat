@echo off
setlocal enabledelayedexpansion
title Cocos PSD Namer - 一键安装

rem ============================================================
rem  一键安装 Cocos PSD Namer (Photoshop CEP 扩展)
rem  做两件事:
rem    1) 把本文件夹拷到 CEP 扩展目录 com.cocos.psdnamer
rem    2) 给 CSXS.6 ~ CSXS.12 写 PlayerDebugMode=1 (允许未签名扩展)
rem  全程写 HKCU + %APPDATA%, 不需要管理员权限。
rem ============================================================

set "SRC=%~dp0"
set "DEST=%APPDATA%\Adobe\CEP\extensions\com.cocos.psdnamer"

echo.
echo   源目录 : %SRC%
echo   安装到 : %DEST%
echo.

echo [1/3] 复制扩展文件...
robocopy "%SRC%." "%DEST%" /E /XD ".git" /XF "install.bat" "uninstall.bat" "*.zxp" >nul
if errorlevel 8 (
  echo   复制失败, 请检查权限或路径。
  goto :end
)
echo   完成。

echo [2/3] 开启 PlayerDebugMode (CSXS.6 ~ CSXS.12)...
for %%V in (6 7 8 9 10 11 12) do (
  reg add "HKCU\Software\Adobe\CSXS.%%V" /v PlayerDebugMode /t REG_SZ /d 1 /f >nul 2>&1
)
echo   完成。

echo [3/3] 校验...
if exist "%DEST%\CSXS\manifest.xml" (
  echo   已就绪。
) else (
  echo   警告: 没找到 manifest.xml, 安装可能不完整。
)

echo.
echo ============================================================
echo   安装完成! 请完全退出并重启 Photoshop,
echo   然后在菜单: 窗口 / 扩展功能(旧版) ^> Cocos PSD Namer
echo   (Window ^> Extensions (legacy)) 打开面板。
echo ============================================================
echo.

:end
pause
endlocal