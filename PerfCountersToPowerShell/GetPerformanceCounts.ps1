[CmdletBinding()]
param(
    [string]$IncludeContinuous = $False
)

function SanitizeNames($fileName)
{
    $name = $fileName.ToString()
    $characters = "*","=",">"," ","<","/","\",",","(",")"
    foreach($character in $characters)
    {
        $name = $name.Replace($character,"")
    }
    return $name
}

function WriteLog($message, $file)
{
    $message = "[$(Get-Date)] " + $message
    Add-Content -Path $file $message
}

$logLocation = ".\logOut.txt"
Write-Verbose "[$(Get-Date)] Starting Script"
WriteLog "Starting Script" $logLocation

Write-Verbose "[$(Get-Date)] Getting Counters"
WriteLog "Getting Counters" $logLocation
$counterSetNames = (Get-Counter -ListSet *).CounterSetName

foreach($counterSetName in $counterSetNames)
{
    $counters = (Get-Counter -ListSet $counterSetName).Counter
    Write-Verbose "[$(Get-Date)] CounterSetName: $counters"
    WriteLog "CounterSetName: $counters" $logLocation
    $counterSetName = SanitizeNames $counterSetName

    Write-Verbose "[$(Get-Date)] Creating Directory: $counterSetName"
    WriteLog "Creating Directory: $counterSetName" $logLocation
    New-Item -Path .\Counters -Name $counterSetName -ItemType "directory" -Force | Out-Null
    foreach($counter in $counters)
    {
        $counterName = $counter.Substring(1)
        $counterName = SanitizeNames $counterName
        Write-Verbose "[$(Get-Date)] Counter: $counter"
        WriteLog "Counter: $counter" $logLocation        
        
        $counterFileName = ".\Counters\" + $counterSetName + "\" + $counterName + ".ps1"
        if($IncludeContinuous -eq $True)
        {
            $contents = 'Get-Counter -Counter ' + '"' + $counter + '"' + ' -Continuous'
        }else {
            $contents = 'Get-Counter -Counter ' + '"' + $counter + '"'
        }

        Write-Verbose "[$(Get-Date)] Creating File: $counterFileName"
        WriteLog "Creating File: $counterFileName" $logLocation        
        Set-Content -Path $counterFileName $contents
    }
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');