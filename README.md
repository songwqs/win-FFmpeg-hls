win下 批命令执行视频切片hls

需要 FFmpeg支持 确保环境变量配置好了FFmpeg

FFmpeg-win下载：FFmpeg-Builds(https://github.com/BtbN/FFmpeg-Builds)

ffmpeg-master-latest-win64-gpl.zip(https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip)

根目录/

├── video/      # 存放原视频文件，取最新的一个视频进行处理

├── m3u8/       # 存放切片的HLS目录，每次切片产生子目录

│   ├── 子目录1/  # 以时间戳命名，包含切片后的.ts文件和.m3u8文件

│   ├── 子目录2/

├── config.txt  # 配置文件，包含切片时长和其他参数

└── hls_cut.bat # 批处理脚本，执行切片工作

