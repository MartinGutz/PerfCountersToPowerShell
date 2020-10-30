function SanitizeNames($fileName)
{
    $name = $fileName.ToString()
    $characters = "*","=",">"," "
    foreach($character in $characters)
    {
        $name = $name.Replace($character,"")
    }
    return $name
}

$counterSetNames = (Get-Counter -ListSet *).CounterSetName

foreach($counterSetName in $counterSetNames)
{
    $counters = (Get-Counter -ListSet $counterSetName).Counter
    $counterSetName = SanitizeNames $counterSetName

    New-Item -Path .\Counters -Name $counterSetName -ItemType "directory" -Force -Verbose
    foreach($counter in $counters)
    {
        $counterName = $counter.Substring(1)
        $counterName = $counterName.Replace("*","").Replace("/","-").Replace("\","").Replace("(","").Replace(")","")
        $counterName = $counterName.Replace(">","").Replace("=","")
        $counterFileName = ".\Counters\" + $counterSetName + "\" + $counterName + ".ps1"
        #Write-Host $counterName
        $contents = 'Get-Counter -Counter ' + '"' + $counter + '"' + ' -Continuous'
        #$contents = 'powershell.exe -command &{' + '"Get-Counter -Counter ' + '"' + $counter + '"' + ' -Continuous}"'
        Write-Host $contents
        # powershell.exe -command "& {get-eventlog -logname security}"
        Set-Content -Path $counterFileName $contents
    }
}

Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');