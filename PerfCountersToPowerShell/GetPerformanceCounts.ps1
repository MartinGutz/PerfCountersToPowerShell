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

Write-Verbose "[$(Get-Date)] Starting Script"
$counterSetNames = (Get-Counter -ListSet *).CounterSetName
foreach($counterSetName in $counterSetNames)
{
    $counters = (Get-Counter -ListSet $counterSetName).Counter
    $counterSetName = SanitizeNames $counterSetName

    New-Item -Path .\Counters -Name $counterSetName -ItemType "directory" -Force 
    foreach($counter in $counters)
    {
        $counterName = $counter.Substring(1)
        $counterName = SanitizeNames $counterName
        $counterFileName = ".\Counters\" + $counterSetName + "\" + $counterName + ".ps1"
        #Write-Host $counterName
        #Write-Host "VERBOSE: IncludeContinuous: " $IncludeContinuous 
        if($IncludeContinuous -eq $True)
        {
            $contents = 'Get-Counter -Counter ' + '"' + $counter + '"' + ' -Continuous'
        }else {
            $contents = 'Get-Counter -Counter ' + '"' + $counter + '"'
        }
        
        #Write-Host $contents
        # powershell.exe -command "& {get-eventlog -logname security}"
        Set-Content -Path $counterFileName $contents
    }
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');