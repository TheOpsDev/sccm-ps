function Get-InstalledUpdates {
<#
.SYNOPSIS
Get update history. By default it pulls the last 15. Max 50

.DESCRIPTION
Using a update session, query the last request updates.

.PARAMETER Last
Number of updates to return. Default 15, max 100

.PARAMETER ComputerName
Remote system to check against. Default value is localhost
#>
    [CmdletBinding()]
    param (
        [Int]
        [ValidateRange(1,100)]
        $Last=15,
        [Parameter(ValueFromPipeline)]
        [String[]]
        $ComputerName = 'localhost'
    )

    process {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            function Convert-ResultCodeToName {
                param( 
                    [Parameter(Mandatory)]
                    [int]
                    $ResultCode
                )
                $Result = $ResultCode
                switch($ResultCode) {
                    2 { $Result = "Succeeded" }
                    3 { $Result = "Succeeded With Errors" }
                    4 { $Result = "Failed" }
                }
                return $Result
            }
            # Get a Update Session
            $session = (New-Object -ComObject 'Microsoft.Update.Session')
        
            # Query the last request History starting with the first recordp
            $history = $session.QueryHistory("",0,$using:Last) | ForEach-Object {
                $Result = Convert-ResultCodeToName -ResultCode $_.ResultCode
                # Make the properties hidden in com properties visible.
                $_ | Add-Member -MemberType NoteProperty -Value $Result -Name Result
                $Product = $_.Categories | Where-Object {$_.Type -eq 'Product'} | Select-Object -First 1 -ExpandProperty Name
                $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.UpdateId -Name UpdateId
                $_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.RevisionNumber -Name RevisionNumber
                $_ | Add-Member -MemberType NoteProperty -Value $Product -Name Product -PassThru
            }
            
            #Remove null records and only return the fields we want
            return $history | Where-Object {![String]::IsNullOrWhiteSpace($_.title)} | Select-Object Result, Date, Title, SupportUrl, Product, UpdateId, RevisionNumber
        }
    }
}