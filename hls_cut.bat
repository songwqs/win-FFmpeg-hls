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

:: 遍历 video 目录中的视频文件，并为每个视频文件创建子目录并切片
for %%i in ("%VIDEO_DIR%\*.mp4") do (
    set "VIDEO_FILE=%%~ni"  :: 获取文件名（不带扩展名）
    set "SUB_DIR=%M3U8_DIR%\!VIDEO_FILE!"
    
    :: 如果子目录不存在，则创建
    if not exist "!SUB_DIR!" (
        mkdir "!SUB_DIR!"
        echo 已为视频文件 "%%i" 创建子目录 "!SUB_DIR!"。
    ) else (
        echo 子目录 "!SUB_DIR!" 已存在，跳过创建。
    )

    :: 切片命令
    echo 开始切片视频 "%%i" 并保存到子目录 "!SUB_DIR!"...

    ffmpeg -i "%%i" ^
           -c:v copy -c:a copy ^
           -hls_time %SEGMENT_DURATION% ^
           -hls_segment_filename "!SUB_DIR!\%HLS_SEGMENT_FILENAME%" ^
           -hls_list_size 0 ^
           "!SUB_DIR!\%PLAYLIST_NAME%"

    :: 检查切片是否成功
    if %ERRORLEVEL% EQU 0 (
        echo 切片完成！文件已保存至：!SUB_DIR!
    ) else (
        echo 切片失败，请检查 FFmpeg 配置或视频文件。
    )
)

pause
