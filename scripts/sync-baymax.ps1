# sync-baymax.ps1
# 同步 Baymax 团队级用例库到本地 _history/
#
# 用法：
#   powershell scripts/sync-baymax.ps1            # 同步默认团队
#   powershell scripts/sync-baymax.ps1 -Quiet     # 静默模式
#
# 定时调用（Windows 任务计划程序）：
#   每周一 03:00 执行 powershell scripts/sync-baymax.ps1 -Quiet
#   创建任务命令：
#     $action = New-ScheduledTaskAction -Execute 'powershell' -Argument 'D:\Trae CN\projects\testcase\scripts\sync-baymax.ps1 -Quiet'
#     $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 03:00
#     Register-ScheduledTask -TaskName 'Testcase-Sync-Baymax' -Action $action -Trigger $trigger

param(
    [int]$TeamId = 251,
    [string]$BusinessId = "271",
    [string]$CenterId = "261",
    [string[]]$TreeKeys = @("142954", "142727"),
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$HistoryDir = Join-Path $ProjectRoot "_history"
$IndexDir = Join-Path $ProjectRoot "knowledge\_index"
$LogFile = Join-Path $HistoryDir "_sync.log"
$BaymaxCli = "C:/Users/wuwy/.claude/skills/usecase-skill/scripts/cli.cjs"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    if (-not $Quiet) {
        switch ($Level) {
            "ERROR" { Write-Host $line -ForegroundColor Red }
            "WARN"  { Write-Host $line -ForegroundColor Yellow }
            "OK"    { Write-Host $line -ForegroundColor Green }
            default { Write-Host $line }
        }
    }
}

try {
    Write-Log "========== 开始同步 Baymax =========="
    Write-Log "teamId: $TeamId, businessId: $BusinessId, centerId: $CenterId"
    Write-Log "treeKeys: $($TreeKeys -join ', ')"

    # 1. 检查前置
    if (-not (Test-Path $BaymaxCli)) {
        throw "Baymax CLI 未找到: $BaymaxCli"
    }
    if (-not (Test-Path $HistoryDir)) {
        New-Item -ItemType Directory -Path $HistoryDir -Force | Out-Null
    }

    $totalCases = 0

    # 2. 拉取每个 treeKey
    foreach ($treeKey in $TreeKeys) {
        $url = "http://baymax.dc.servyou-it.com/usecase/library?businessId=$BusinessId&centerId=$CenterId&teamId=$TeamId&treeKey=$treeKey"
        $outputFile = Join-Path $HistoryDir "baymax-team$TeamId-tree$treeKey.md"

        Write-Log "拉取 treeKey=$treeKey ..."

        # 备份现有
        $backupFile = "$outputFile.bak"
        if (Test-Path $outputFile) {
            Copy-Item $outputFile $backupFile -Force
        }

        # 执行 node CLI
        $process = Start-Process -FilePath "node" -ArgumentList @(
            $BaymaxCli, "usecase", "url", "`"$url`""
        ) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $outputFile

        if ($process.ExitCode -ne 0) {
            throw "Baymax CLI 退出码: $($process.ExitCode) (treeKey=$treeKey)"
        }

        $fileSize = (Get-Item $outputFile).Length
        Write-Log "treeKey=$treeKey 拉取完成: $([math]::Round($fileSize/1KB, 1))KB" "OK"

        # 删除备份（成功后）
        if (Test-Path $backupFile) {
            Remove-Item $backupFile -Force
        }
    }

    # 3. 重新构建功能映射
    Write-Log "重建功能→用例映射..."
    $indexProcess = Start-Process -FilePath "python" -ArgumentList @(
        "scripts/build-baymax-index.py"
    ) -NoNewWindow -Wait -PassThru -WorkingDirectory $ProjectRoot

    if ($indexProcess.ExitCode -ne 0) {
        Write-Log "功能映射重建失败（但用例已更新，不影响同步）" "WARN"
    } else {
        Write-Log "功能映射重建完成" "OK"
    }

    # 4. 统计
    $mdFiles = Get-ChildItem -Path $HistoryDir -Filter "baymax-*.md"
    Write-Log "本次同步完成。文件: $($mdFiles.Count), 总大小: $([math]::Round((($mdFiles | Measure-Object Length -Sum).Sum)/1MB, 2))MB" "OK"
    Write-Log "========== 同步结束 =========="

    if (-not $Quiet) {
        Write-Host ""
        Write-Host "✅ Baymax 同步成功！" -ForegroundColor Green
        Write-Host ""
        Write-Host "下一步：" -ForegroundColor Cyan
        Write-Host "  1. 用例已更新到 _history/"
        Write-Host "  2. 功能映射已重建到 knowledge/_index/"
        Write-Host "  3. 下次按需索引会自动用上最新数据"
    }
}
catch {
    Write-Log "同步失败: $_" "ERROR"
    Write-Log "Stack: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}
