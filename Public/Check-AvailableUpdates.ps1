function Check-AvailableUpdates {
<#
.SYNOPSIS
Get available updates in Software Center

.DESCRIPTION
Using the ROOT\ccm\ClientSDK WMI namespace, this functions queries if their are any pending updates in Software Center

.PARAMETER ComputerName
Remote system to check against. Default value is localhost

#>
    param (
        [Parameter(ValueFromPipeline)]
        [String[]]
        $ComputerName = 'localhost'
    )

    begin {
        [System.Collections.ArrayList]$updateList = @()
    }
        
    process {
        foreach ($computer in $ComputerName){
            $updates =  Get-WmiObject -Namespace "root\ccm\clientsdk" -Class CCM_SoftwareUpdate -ComputerName $computer
            if ($updates) {
                foreach ($update in $updates) {
                    $EvState = Switch ( $update.EvaluationState ) {
                        '0'  { "None" } 
                        '1'  { "Available" } 
                        '2'  { "Submitted" } 
                        '3'  { "Detecting" } 
                        '4'  { "PreDownload" } 
                        '5'  { "Downloading" } 
                        '6'  { "WaitInstall" } 
                        '7'  { "Installing" } 
                        '8'  { "PendingSoftReboot" } 
                        '9'  { "PendingHardReboot" } 
                        '10' { "WaitReboot" } 
                        '11' { "Verifying" } 
                        '12' { "InstallComplete" } 
                        '13' { "Error" } 
                        '14' { "WaitServiceWindow" } 
                        '15' { "WaitUserLogon" } 
                        '16' { "WaitUserLogoff" } 
                        '17' { "WaitJobUserLogon" } 
                        '18' { "WaitUserReconnect" } 
                        '19' { "PendingUserLogoff" } 
                        '20' { "PendingUpdate" } 
                        '21' { "WaitingRetry" } 
                        '22' { "WaitPresModeOff" } 
                        '23' { "WaitForOrchestration" } 

                        DEFAULT { "Unknown" }
                    }

                    $updateObj = New-Object PSObject -Property ([ordered]@{      
                        ArticleId         = $update.ArticleID
                        Publisher         = $update.Publisher
                        Software          = $update.Name
                        Description       = $update.Description
                        State             = $EvState
                        StartTime         = Get-Date ([system.management.managementdatetimeconverter]::todatetime($($update.StartTime)))
                        Computer          = $computer
                    })
                    $updateList += $updateObj
                }
            } else {
                Write-Host "No pending updates found."
                return $null
            }
        }
    }

    end { return $updateList }
}