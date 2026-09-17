Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


# ==============================
# 获取程序目录
# ==============================

$appPath = Split-Path -Parent (
    [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
)


$timeFile = Join-Path $appPath "shutdown_time.txt"



# ==============================
# 创建窗口
# ==============================

$form = New-Object System.Windows.Forms.Form

$form.Text = "定时关机工具"

$form.Size = New-Object System.Drawing.Size(420,260)

$form.MinimumSize =
New-Object System.Drawing.Size(420,260)

$form.StartPosition =
"CenterScreen"


$form.Font =
New-Object System.Drawing.Font(
    "Microsoft YaHei",
    10
)



# ==============================
# 从exe自身加载图标
# ==============================

try
{
    $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath)
}
catch
{
    # 如果是ps1直接运行，从外部ico加载
    $ico = Get-ChildItem -Path $appPath -Filter "*.ico" | Select-Object -First 1
    if($null -ne $ico)
    {
        $form.Icon = New-Object System.Drawing.Icon($ico.FullName)
    }
}



# ==============================
# 标题
# ==============================

$title =
New-Object System.Windows.Forms.Label

$title.Text =
"定时关机工具"

$title.Font =
New-Object System.Drawing.Font(
    "Microsoft YaHei",
    14,
    [System.Drawing.FontStyle]::Bold
)

$title.AutoSize = $true

$title.Location =
New-Object System.Drawing.Point(
    130,
    20
)



# ==============================
# 输入分钟
# ==============================

$label =
New-Object System.Windows.Forms.Label

$label.Text =
"关机时间："

$label.AutoSize = $true

$label.Location =
New-Object System.Drawing.Point(
    50,
    75
)



$numMinute =
New-Object System.Windows.Forms.NumericUpDown


$numMinute.Location =
New-Object System.Drawing.Point(
    140,
    70
)


$numMinute.Size =
New-Object System.Drawing.Size(
    100,
    30
)


$numMinute.Minimum = 1

$numMinute.Maximum = 1440

$numMinute.Value = 60



$unit =
New-Object System.Windows.Forms.Label


$unit.Text =
"分钟"

$unit.AutoSize = $true


$unit.Location =
New-Object System.Drawing.Point(
    250,
    75
)



# ==============================
# 按钮
# ==============================

$btnStart =
New-Object System.Windows.Forms.Button


$btnStart.Text =
"开始关机"


$btnStart.Size =
New-Object System.Drawing.Size(
    120,
    40
)


$btnStart.Location =
New-Object System.Drawing.Point(
    60,
    125
)



$btnCancel =
New-Object System.Windows.Forms.Button


$btnCancel.Text =
"取消关机"


$btnCancel.Size =
New-Object System.Drawing.Size(
    120,
    40
)


$btnCancel.Location =
New-Object System.Drawing.Point(
    220,
    125
)



# ==============================
# 状态
# ==============================

$status =
New-Object System.Windows.Forms.Label


$status.Text =
"状态：未设置"


$status.AutoSize = $true


$status.Location =
New-Object System.Drawing.Point(
    50,
    190
)



# ==============================
# 倒计时变量
# ==============================

$script:targetTime = $null



# ==============================
# 读取第一行（当前有效时间）
# ==============================

function Get-ValidTime
{
    if (-not (Test-Path $timeFile))
    {
        return $null
    }

    try
    {
        $lines = Get-Content $timeFile -Encoding UTF8
        if ($lines.Count -eq 0)
        {
            return $null
        }

        $firstLine = $lines[0].Trim()
        if ([string]::IsNullOrEmpty($firstLine))
        {
            return $null
        }

        $oldTime = [datetime]::Parse($firstLine)
        if ($oldTime -gt (Get-Date))
        {
            return $oldTime
        }
        else
        {
            # 时间已过期，清空第一行
            Update-FirstLine -NewTime $null
            return $null
        }
    }
    catch
    {
        return $null
    }
}



# ==============================
# 更新第一行（当前有效时间）
# ==============================

function Update-FirstLine
{
    param(
        [string]$NewTime  # 新时间字符串，或 $null 表示清空
    )

    $lines = @()

    if (Test-Path $timeFile)
    {
        # 读取现有内容
        $lines = Get-Content $timeFile -Encoding UTF8
    }

    # 保留第一行之外的日志行
    $logLines = @()
    if ($lines.Count -gt 1)
    {
        $logLines = $lines[1..($lines.Count - 1)]
    }

    # 构造新内容：第一行 + 日志
    $newContent = @()
    if ($NewTime)
    {
        $newContent += $NewTime
    }
    else
    {
        $newContent += ""  # 空行占位，表示无有效定时
    }
    $newContent += $logLines

    $newContent | Set-Content $timeFile -Encoding UTF8
}



# ==============================
# 追加日志（从第二行开始）
# ==============================

function Write-Log
{
    param(
        [string]$Action,      # "SET" 或 "CANCEL"
        [string]$SetTime,
        [string]$ScheduledTime,
        [int]$Minutes = 0
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    if ($Action -eq "SET")
    {
        $logLine = "[$timestamp] 设置关机 | 设定: $SetTime | 预定: $ScheduledTime | 倒计时: ${Minutes}分钟"
    }
    else
    {
        $logLine = "[$timestamp] 取消关机 | 原定: $ScheduledTime"
    }

    # 追加到文件（不影响第一行）
    Add-Content -Path $timeFile -Value $logLine -Encoding UTF8
}



# ==============================
# 更新时间
# ==============================

function Update-Countdown
{

    if($null -eq $script:targetTime)
    {
        return
    }



    $remain =
    $script:targetTime - (Get-Date)



    if($remain.TotalSeconds -le 0)
    {

        $timer.Stop()

        $status.Text =
        "状态：等待关机"

        return
    }



    $hours =
    [int][Math]::Floor(
        $remain.TotalHours
    )


    $minutes =
    [int]$remain.Minutes


    $seconds =
    [int]$remain.Seconds



    $time =
    "{0:D2}:{1:D2}:{2:D2}" -f `
    $hours,
    $minutes,
    $seconds



    $status.Text =
    "状态：剩余 $time"



    $form.Text =
    "定时关机 - $time"

}



# ==============================
# Timer
# ==============================

$timer =
New-Object System.Windows.Forms.Timer


$timer.Interval = 1000


$timer.Add_Tick({

    Update-Countdown

})



# ==============================
# 启动恢复
# ==============================

$recovered = Get-ValidTime
if ($recovered -ne $null)
{
    $script:targetTime = $recovered
    $timer.Start()
    Update-Countdown
}
else
{
    $status.Text = "状态：未设置"
}



# ==============================
# 开始按钮
# ==============================

$btnStart.Add_Click({

    $minute =
    [int]$numMinute.Value


    $seconds =
    $minute * 60



    $script:targetTime =
    (Get-Date).AddMinutes($minute)


    $setTimeStr = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $targetTimeStr = $script:targetTime.ToString("yyyy-MM-dd HH:mm:ss")


    # 更新第一行（有效时间）
    Update-FirstLine -NewTime $targetTimeStr

    # 追加日志（第二行及以后）
    Write-Log -Action "SET" -SetTime $setTimeStr -ScheduledTime $targetTimeStr -Minutes $minute


    shutdown /s /t $seconds



    $timer.Start()


    Update-Countdown

})



# ==============================
# 取消按钮
# ==============================

$btnCancel.Add_Click({

    shutdown /a *> $null


    $timer.Stop()


    # 记录取消日志（使用当前 targetTime）
    if ($script:targetTime -ne $null)
    {
        $cancelTimeStr = $script:targetTime.ToString("yyyy-MM-dd HH:mm:ss")
        Write-Log -Action "CANCEL" -ScheduledTime $cancelTimeStr
    }
    else
    {
        Write-Log -Action "CANCEL" -ScheduledTime "无活跃定时任务"
    }


    $script:targetTime = $null

    # 清空第一行（无有效时间）
    Update-FirstLine -NewTime $null


    $status.Text =
    "状态：已取消关机"



    $form.Text =
    "定时关机工具"

})



# ==============================
# 添加控件
# ==============================

$form.Controls.Add($title)

$form.Controls.Add($label)

$form.Controls.Add($numMinute)

$form.Controls.Add($unit)

$form.Controls.Add($btnStart)

$form.Controls.Add($btnCancel)

$form.Controls.Add($status)



# ==============================
# 显示
# ==============================

[void]$form.ShowDialog()