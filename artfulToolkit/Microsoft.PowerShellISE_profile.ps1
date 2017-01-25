$Global:ProgressPreference = 'SilentlyContinue'

if (Test-NetConnection -ComputerName bing.com -Port 80 -InformationLevel Quiet -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {

    $Now = Get-Date
    $Date = Get-Date -Month $Now.Month -Day 1
    
    while ($Date.DayOfWeek -ne 'Tuesday') {$Date = $Date.AddDays(1)}
        
    if ($Date.ToShortDateString() -eq $Now.ToShortDateString()) {

        $PSLUPath = "$env:ProgramFiles\WindowsPowerShell\Configuration\pshelp-lastupdated.txt"

        $PSHelpLastUpdate = (Get-ChildItem -Path $PSLUPath -ErrorAction SilentlyContinue).LastWriteTime 

        if ($PSHelpLastUpdate.Month -ne $Now.Month) {

            if ((New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {

                New-Item -Path $PSLUPath -ItemType File -Force | Out-Null
                
                Start-Job {
                    Update-Module -Force
                    Update-Help -ErrorAction SilentlyContinue
                } | Out-Null
            }
            else {
                Write-Warning -Message 'Aborting PowerShell Module and Help update due to PowerShell not being run as a local administrator!'
            }
        }
    }
}

$Global:ProgressPreference = 'Continue'

Start-Steroids

Set-Location -Path $env:SystemDrive\Development
Clear-Host
$Error.Clear()
Import-Module -Name posh-git -ErrorAction SilentlyContinue
if (-not($Error[0])) {
    $DefaultTitle = $Host.UI.RawUI.WindowTitle
    $GitPromptSettings.BeforeText = '('
    $GitPromptSettings.BeforeForegroundColor = [ConsoleColor]::Cyan
    $GitPromptSettings.AfterText = ')'
    $GitPromptSettings.AfterForegroundColor = [ConsoleColor]::Cyan
    function prompt {
        if (-not(Get-GitDirectory)) {
            $Host.UI.RawUI.WindowTitle = $DefaultTitle
            "PS $($executionContext.SessionState.Path.CurrentLocation)$('>' * ($nestedPromptLevel + 1)) "
        }
        else {
            $realLASTEXITCODE = $LASTEXITCODE
            Write-Host 'PS ' -ForegroundColor Green -NoNewline
            Write-Host "$($executionContext.SessionState.Path.CurrentLocation) " -ForegroundColor Yellow -NoNewline
            Write-VcsStatus
            $LASTEXITCODE = $realLASTEXITCODE
            return "`n$('$' * ($nestedPromptLevel + 1)) "
        }
    }
}
else {
    Write-Warning -Message 'Unable to load the Posh-Git PowerShell Module'
}