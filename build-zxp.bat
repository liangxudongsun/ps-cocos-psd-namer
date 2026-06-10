@echo off
setlocal
title Cocos PSD Namer - 打包 ZXP

rem ============================================================
rem  把扩展打包成已签名的 .zxp (自签证书)
rem  团队成员用 ZXP Installer / Anastasiy's Extension Manager
rem  拖一下即可安装, 不需要开 PlayerDebugMode。
rem  依赖: Adobe ZXPSignCmd.exe (脚本会自动查找)。
rem ============================================================

set "ROOT=%~dp0"
set "NAME=com.cocos.psdnamer"
set "OUT=%ROOT%cocos-psd-namer.zxp"
set "CERT=%ROOT%cert.p12"
set "PW=cocospsd"
set "STAGE=%ROOT%_zxp_build\%NAME%"

rem --- 1. 查找 ZXPSignCmd.exe ---
set "ZXP="
for /f "delims=" %%I in ('where ZXPSignCmd.exe 2^>nul') do set "ZXP=%%I"
if not defined ZXP if exist "%ROOT%ZXPSignCmd.exe" set "ZXP=%ROOT%ZXPSignCmd.exe"
if not defined ZXP if exist "%ROOT%tools\ZXPSignCmd.exe" set "ZXP=%ROOT%tools\ZXPSignCmd.exe"
if not defined ZXP (
  echo.
  echo   没找到 ZXPSignCmd.exe。请到 Adobe 下载后, 放到:
  echo     - 本文件夹旁边, 或 tools\ 子目录, 或加入 PATH
  echo   下载: https://github.com/Adobe-CEP/CEP-Resources  ^(ZXPSignCmd^)
  echo.
  goto :end
)
echo   使用: %ZXP%

rem --- 2. 没有证书就生成一个自签证书 ---
if not exist "%CERT%" (
  echo [1/3] 生成自签证书 cert.p12 ...
  "%ZXP%" -selfSignedCert CN Shanghai Cocos "Cocos PSD Namer" %PW% "%CERT%"
) else (
  echo [1/3] 已有 cert.p12, 跳过。
)

rem --- 3. 暂存扩展文件 (排除脚本/证书/zxp/.git) ; 镜像模式会清理上次残留 ---
echo [2/3] 暂存扩展文件 ...
robocopy "%ROOT%." "%STAGE%" /MIR /XD ".git" "_zxp_build" /XF "*.bat" "*.p12" "*.zxp" >nul

rem --- 4. 签名打包 ---
echo [3/3] 签名打包 ...
if exist "%OUT%" del "%OUT%"
"%ZXP%" -sign "%STAGE%" "%OUT%" "%CERT%" %PW% -tsa http://timestamp.digicert.com

echo.
if exist "%OUT%" (
  echo ============================================================
  echo   打包完成: %OUT%
  echo   分发: 把 .zxp 发给同事, 用 ZXP Installer 拖入安装即可。
  echo   注: _zxp_build\ 是临时暂存目录, 可删可留 (已被 git 忽略)。
  echo ============================================================
) else (
  echo   打包失败, 请检查上面的 ZXPSignCmd 输出。
)
echo.

:end
pause
endlocal
