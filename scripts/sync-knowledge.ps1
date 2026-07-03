# sync-knowledge.ps1
# 同步 17work 业务沉淀到本地 knowledge/ 目录
#
# 用法：
#   powershell scripts/sync-knowledge.ps1                     # 同步默认节点
#   powershell scripts/sync-knowledge.ps1 -PostsId 200181     # 同步指定节点
#   powershell scripts/sync-knowledge.ps1 -Quiet              # 静默模式（用于定时任务）
#
# 定时调用（Windows 任务计划程序）：
#   每周日 02:00 执行 powershell scripts/sync-knowledge.ps1 -Quiet
#   创建任务命令：
#     $action = New-ScheduledTaskAction -Execute 'powershell' -Argument 'D:\Trae CN\projects\testcase\scripts\sync-knowledge.ps1 -Quiet'
#     $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 02:00
#     Register-ScheduledTask -TaskName 'Testcase-Sync-Knowledge' -Action $action -Trigger $trigger

param(
    [int]$PostsId = 200181,
    [string]$BookId = "70",
    [string]$Source = "https://17work.dc.servyou-it.com/read/book/$BookId/$PostsId",
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RawDir = Join-Path $ProjectRoot "knowledge\_raw"
$LogFile = Join-Path $ProjectRoot "knowledge\_sync.log"
$TempDir = Join-Path $ProjectRoot "knowledge\_tmp_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

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
    Write-Log "========== 开始同步 =========="
    Write-Log "来源: $Source"
    Write-Log "目标: $RawDir"

    # 1. 检查前置条件
    if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
        throw "npx 未安装或不在 PATH 中。请先安装 Node.js。"
    }

    # 2. 备份当前 _raw（保留最近 1 份作为回滚）
    $BackupDir = Join-Path $ProjectRoot "knowledge\_raw_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    if (Test-Path $RawDir) {
        Write-Log "备份当前 _raw → $BackupDir"
        Move-Item $RawDir $BackupDir -Force
    }

    # 3. 执行 17work CLI 下载
    Write-Log "执行 17work CLI 下载 postsId=$PostsId (最长 5 分钟)..."
    $npxArgs = @(
        "-y"
        "--registry=http://npm.dc.servyou-it.com"
        "@servyou-ai/17work-cli@latest"
        "docs", "download", "$PostsId"
        "--recursive"
        "--output", $TempDir
    )

    $process = Start-Process -FilePath "npx" -ArgumentList $npxArgs -NoNewWindow -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "17work CLI 执行失败，退出码: $($process.ExitCode)"
    }

    # 4. 验证下载结果
    $downloadedRoot = Get-ChildItem -Path $TempDir -Directory | Select-Object -First 1
    if (-not $downloadedRoot) {
        throw "下载完成但未找到内容目录"
    }

    $mdCount = (Get-ChildItem -Path $downloadedRoot.FullName -Recurse -Filter "*.md" | Measure-Object).Count
    Write-Log "下载完成，共 $mdCount 个 .md 文件" "OK"

    if ($mdCount -lt 10) {
        Write-Log "下载文件数过少（$mdCount），可能下载不完整" "WARN"
    }

    # 5. 移动到 _raw 目录
    if (Test-Path $RawDir) {
        Remove-Item $RawDir -Recurse -Force
    }
    Move-Item $downloadedRoot.FullName $RawDir -Force
    Write-Log "已移动到 $RawDir" "OK"

    # 6. 清理临时目录
    $remainingInTemp = Get-ChildItem -Path $TempDir -ErrorAction SilentlyContinue
    if ($remainingInTemp) {
        Remove-Item $TempDir -Recurse -Force
    }

    # 7. 删除旧备份（保留最近 3 份）
    $oldBackups = Get-ChildItem -Path (Join-Path $ProjectRoot "knowledge") -Directory -Filter "_raw_backup_*" |
        Sort-Object CreationTime -Descending |
        Select-Object -Skip 3
    foreach ($old in $oldBackups) {
        Remove-Item $old.FullName -Recurse -Force
        Write-Log "清理旧备份: $($old.Name)"
    }

    # 8. 输出统计
    $totalSize = (Get-ChildItem -Path $RawDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
    $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
    Write-Log "本次同步完成。文件数: $mdCount, 大小: ${totalSizeMB}MB" "OK"
    Write-Log "========== 同步结束 =========="

    # 9. 静默模式不提示，非静默模式提示用户
    if (-not $Quiet) {
        Write-Host ""
        Write-Host "✅ 知识库同步成功！" -ForegroundColor Green
        Write-Host "   文件数: $mdCount"
        Write-Host "   大小: ${totalSizeMB}MB"
        Write-Host ""
        Write-Host "下一步：" -ForegroundColor Cyan
        Write-Host "  1. 检查 knowledge/README.md 和 glossary.md 是否需要更新"
        Write-Host "  2. 如有变化，更新后提交到 git"
    }
}
catch {
    Write-Log "同步失败: $_" "ERROR"
    Write-Log "Stack: $($_.ScriptStackTrace)" "ERROR"

    # 回滚
    if (Test-Path $BackupDir) {
        if (Test-Path $RawDir) { Remove-Item $RawDir -Recurse -Force }
        Move-Item $BackupDir $RawDir -Force
        Write-Log "已回滚到备份版本" "WARN"
    }

    exit 1
}
