$counterSetNames = (Get-Counter -ListSet *).CounterSetName

foreach($counterSetName in $counterSetNames)
{
    $counters = (Get-Counter -ListSet $counterSetName).Counter
    New-Item -Path .\Counters -Name $counterSetName -ItemType "directory" -Force
    foreach($counter in $counters)
    {
        $counterName = $counter.Substring(1)
        $counterName = $counterName.Replace("*","").Replace("/","-").Replace("\","").Replace("(","").Replace(")","")
        $counterFileName = ".\Counters\" + $counterSetName + "\" + $counterName + ".ps1"
        #Write-Host $counterName
        $contents = 'Get-Counter -Counter ' + '"' + $counter + '"' + ' -Continuous'
        #$contents = 'powershell.exe -command &{' + '"Get-Counter -Counter ' + '"' + $counter + '"' + ' -Continuous}"'
        Write-Host $contents
        # powershell.exe -command "& {get-eventlog -logname security}"
        Set-Content -Path $counterFileName $contents
    }
}