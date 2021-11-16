## Powershell script to run the RVTools extract
## Version 0.4 :: 10/19/2021 :: Initial version sent to Nitin@ABG
## Version 0.5 :: 10/21/2021 :: Reformatted; Added additional Exit statements in Try/Catch blocks

param (
    [Boolean]$DryRun = $true ,
    [String]$LogFile = "rvtools.log")

$ScriptVersion = "0.5"
$ScriptDate = "10/21/2021"

$VCUser =   "corpab\intelsvc"
$VCEncPwd = "_RVToolsPWDhQ7FUAs1e6eYAaCN8EiW8601lqxUB5oAhva7CMnodfzOXuexT+DrqC8/7ByK4BmP"
$BaseDir =  "F:\RVTools_86\current\"
$Site =     "BLD"
$VCNum = 	"86"
$VcenterIP = "161.178.200.86"

$RVToolsDir = "C:\Program Files (x86)\Robware\RVTools"
$RVToolsCommand = "ExportAll2csv"
$SleepSeconds = 60

Function Write-Log {
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

## Powershell script to run the RVTools extract
## Version 0.4 :: 10/19/2021 :: Initial version sent to Nitin@ABG
## Version 0.5 :: 10/21/2021 :: Reformatted; Added additional Exit statements in Try/Catch blocks

param (
    [Boolean]$DryRun = $true ,
    [String]$LogFile = "rvtools.log")

$ScriptVersion = "0.4"
$ScriptDate = "10/19/2021"

$VCUser =   "corpab\intelsvc"
$VCEncPwd = "_RVToolsPWDhQ7FUAs1e6eYAaCN8EiW8601lqxUB5oAhva7CMnodfzOXuexT+DrqC8/7ByK4BmP"
$BaseDir =  "F:\RVTools_86\current\"
$Site =     "BLD"
$VCNum = 	"86"
$VcenterIP = "161.178.200.86"

$RVToolsDir = "C:\Program Files (x86)\Robware\RVTools"
$RVToolsCommand = "ExportAll2csv"
$SleepSeconds = 60

Function Write-Log {
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyyMMdd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

Try {
    Write-Log "==> $PSCommandPath ScriptVersion:$ScriptVersion ScriptVersionDate:$ScriptDate `n" 

    $null = New-Item -path $BaseDir -ItemType Directory -Force

    if ( Test-Path $BaseDir -PathType Container) {
        Write-Log "==> Directory: $BaseDir exists.  Ready to proceed...`n"  
    }
    Else {
        Write-Log "==> Directory: $BaseDir not found.  Exiting!`n" 
        Exit 1
    }

    if ( -Not $DryRun ) {
        Write-Log "==> NOT a DryRun...`n" 
        Write-Log "==> Cleaning up $BaseDir`n" 
        Remove-Item -path $BaseDir -Recurse -Include *.csv, *.zip -Force -Verbose

        Try {
            Write-Log "==> Executing: $RVToolsDir\rvtools.exe -u $VCUser -p xxxxxxx -s $VcenterIP -c $RVToolsCommand -d $BaseDir `n" 
            & $RVToolsDir\rvtools.exe -u $VCUser -p $VCEncPwd -s $VcenterIP -c $RVToolsCommand -d $BaseDir
            Write-Log "rvtools.exe $RVToolsCommand Successful for VCNUM=$VCNum.`n" 
            Try {
                Write-Log "==> Waiting for rvtools to complete.  Sleeping for $($SleepSeconds) Seconds...`n"
                Start-Sleep -Seconds $SleepSeconds

                Write-Log "==> Creating ZIP Archive..." 
                $ZipFile = "$($BaseDir)\ABG_RVTools_$($Site)_$($VCNum).zip"
                Compress-Archive -Path "$BaseDir\*.csv" -CompressionLevel Fastest -Verbose -Force -DestinationPath "$ZipFile"
                Write-Log "==> ZIP Archive created successfully at $ZipFile`n"

                Remove-Item -path $BaseDir -Recurse -Include *.csv -Force -Verbose
                Exit 0
            }
            Catch {
                Write-Log "==> Failed to Create ZIP Archive... at $ZipFile`n" 
            } 
        }
        Catch {
            Write-Log $_
            Write-Log "$RvtoolsDir\rvtools.exe $RVToolsCommand Failed for VCNUM=$VCNum." 
            Exit 1
        }  
    }
    Else {
        Write-Log "==> This is a DryRun...`n"
        Write-Log "==> COMMAND: $RVToolsDir\rvtools.exe -u $VCUser -p xxxxxxx -s $VcenterIP -c $RVToolsCommand -d $BaseDir `n"
        Exit 0
    }
}
Catch {
    Write-Log $_
    Write-Log "==> Encountered some unknown error.  Exiting.`n"
    Exit 1
}
