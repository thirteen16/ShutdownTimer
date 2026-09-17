# ShutdownTimer

Windows 11 定时关机工具，使用 PowerShell + WinForms 编写，可打包为单文件 EXE。

## 功能

- 设置 1～1440 分钟后自动关机
- 显示实时倒计时
- 支持取消已设置的关机
- 关闭程序后可恢复有效的定时任务
- 使用自定义 ICO 图标
- 记录设置/取消操作日志

## 使用

直接运行发布后的 `定时关机.exe`，输入分钟数后点击 **开始关机**。

点击 **取消关机** 可取消已设置的关机任务。

## 发布

需要安装 [PS2EXE](https://www.powershellgallery.com/packages/ps2exe)。

### 一键发布

双击：

```text
一键生成exe.bat
```

生成的 `定时关机.exe` 位于项目根目录。

### 命令行发布

在项目根目录执行：

```powershell
New-Item -ItemType Directory -Force publish | Out-Null
Invoke-PS2EXE '.\定时关机.ps1' '.\publish\定时关机.exe' -iconFile '.\cherries_256x256.ico' -noConsole
```

发布结果：

```text
publish/
└── 定时关机.exe
```

## 源码

主程序：`定时关机.ps1`

图标：`cherries_256x256.ico`

## License

暂未指定 License。
