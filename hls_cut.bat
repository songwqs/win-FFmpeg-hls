@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 定义目录路径
set ROOT_DIR=%~dp0
set VIDEO_DIR=%ROOT_DIR%video
set M3U8_DIR=%ROOT_DIR%m3u8
set CONFIG_FILE=%ROOT_DIR%config.txt

:: 检查 video 目录是否存在
if not exist "%VIDEO_DIR%" (
    echo 视频目录不存在！请创建 video 目录。
    pause
    exit /b
)

:: 检查 m3u8 目录是否存在，不存在则创建
if not exist "%M3U8_DIR%" (
    mkdir "%M3U8_DIR%"
)

:: 获取最新视频文件
set LATEST_VIDEO=
for /f "delims=" %%i in ('dir "%VIDEO_DIR%\*" /b /o-d /a:-d') do (
    set LATEST_VIDEO=%%i
    goto :found_video
)
:found_video

if not defined LATEST_VIDEO (
    echo 视频目录为空，请放置视频文件。
    pause
    exit /b
)

:: 加载配置文件，设置默认参数
set SEGMENT_DURATION=10
set OUTPUT_FORMAT=hls
set HLS_SEGMENT_FILENAME=segment_%03d.ts
set PLAYLIST_NAME=playlist.m3u8

if exist "%CONFIG_FILE%" (
    for /f "tokens=1,2 delims==" %%i in (%CONFIG_FILE%) do (
        if "%%i"=="segment_duration" set SEGMENT_DURATION=%%j
        if "%%i"=="output_format" set OUTPUT_FORMAT=%%j
        if "%%i"=="hls_segment_filename" set HLS_SEGMENT_FILENAME=%%j
        if "%%i"=="playlist_name" set PLAYLIST_NAME=%%j
    )
) else (
    echo 配置文件 config.txt 不存在，使用默认参数。
)

:: 创建以时间戳命名的子目录
for /f "tokens=2 delims==" %%T in ('wmic os get localdatetime /value') do set TIMESTAMP=%%T
set TIMESTAMP=%TIMESTAMP:~0,8%_%TIMESTAMP:~8,6%
set OUTPUT_DIR=%M3U8_DIR%\%TIMESTAMP%
mkdir "%OUTPUT_DIR%"

:: 输出当前配置信息
echo 当前配置：
echo 视频文件：%LATEST_VIDEO%
echo 切片时长：%SEGMENT_DURATION% 秒
echo 输出格式：%OUTPUT_FORMAT%
echo 切片文件命名格式：%HLS_SEGMENT_FILENAME%
echo 播放列表文件名：%PLAYLIST_NAME%
echo 输出目录：%OUTPUT_DIR%

:: 执行切片
ffmpeg -i "%VIDEO_DIR%\%LATEST_VIDEO%" ^
       -c:v copy -c:a copy ^
       -hls_time %SEGMENT_DURATION% ^
       -hls_segment_filename "%OUTPUT_DIR%\%HLS_SEGMENT_FILENAME%" ^
       "%OUTPUT_DIR%\%PLAYLIST_NAME%"

:: 检查切片是否成功
if %ERRORLEVEL% EQU 0 (
    echo 切片完成！文件已保存至：%OUTPUT_DIR%
) else (
    echo 切片失败，请检查 FFmpeg 配置或视频文件。
)

pause
