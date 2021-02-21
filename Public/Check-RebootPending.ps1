function Check-RebootPending {
    param (
        [Parameter(ValueFromPipeline)]
        [String[]]
        $ComputerName = 'localhost'
    )
    
    process {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            $state = ((Get-WmiObject -Namespace 'ROOT\ccm\ClientSDK' -Class 'CCM_ClientUtilities' -list).DetermineIfRebootPending().RebootPending)
            return $state
        }
    }
}