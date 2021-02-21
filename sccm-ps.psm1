<#
    Purpose: This module holds common functions used to interface with Software Center via powershell
    Author: Chris Herrera
    Version: 1.0.0

    Note: Please keep functions listed in alphabetical order and try to maintain proper coding conventions.
#>

<#
    .SYNOPSIS  
        This module holds common functions used to interface with Software
        Center via powershell.
    .DESCRIPTION  
        This module is a collection of public and private functions with
        various use-cases. Each function is segmented into their own files and
        sourced as part of this module. Public functions are those that are to
        be exposed to the end-user or script, while private functions are those
        that are only to be used within other functions. All functions are
        recursively sourced by this module, so they only need to be added to
        either the public or private folder to be utilized in this module.
    .NOTES
        File Name    : sccm-ps.psm1
        Author       : Chris Herrera
        Requires     : PowerShell V3
        Version      : 1.0.0

        Copyright (C) 2021 Chris Herrera
#>

# Get public and private function definition files.
$Public  = @( Get-ChildItem -Path "$PSScriptRoot\Public\" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\Private\" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($import in @($Public + $Private)){
    try {
        . $import.fullname
    } catch {
        Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    }
}
