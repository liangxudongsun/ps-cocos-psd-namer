@echo off
setlocal
title Cocos PSD Namer - 卸载

set "DEST=%APPDATA%\Adobe\CEP\extensions\com.cocos.psdnamer"

echo.
echo   将删除: %DEST%
echo.

if exist "%DEST%" (
  rmdir /s /q "%DEST%"
  echo   已删除扩展文件。
) else (
  echo   未找到已安装的扩展, 跳过。
)

echo.
echo   注: 为不影响你其它未签名扩展, 不会自动关闭 PlayerDebugMode。
echo   如需关闭, 手动删除注册表 HKCU\Software\Adobe\CSXS.* 下的 PlayerDebugMode。
echo.
echo   卸载完成。请重启 Photoshop。
echo.
pause
endlocal