function Install-PendingUpdates {
<#
.SYNOPSIS
Install available updates in Software Center

.DESCRIPTION
Using the ROOT\ccm\ClientSDK WMI namespace, this functions installs any pending updates in Software Center

.PARAMETER ComputerName
Remote system to check against. Default value is localhost

#>
    param (
        [Parameter(ValueFromPipeline)]
        [String[]]
        $ComputerName = 'localhost'
    )
    
    process {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            [System.Management.ManagementObject[]]$updates =  Get-WmiObject -Namespace "root\ccm\clientsdk" -Class CCM_SoftwareUpdate
            Write-Host "$(Hostname)"
            Write-Host "Installing [ $($updates.Count) ] Updates`n"
            ([wmiclass]'ROOT\ccm\ClientSDK:CCM_SoftwareUpdatesManager').InstallUpdates($updates)
        }
    }
}