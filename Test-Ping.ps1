function Test-Ping
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String[]]$EndPointName
    )

    Begin
    {
        Clear-Host
        Write-Verbose "Testing the connection to see if the endpoint is online or offline..."

        $EndPointTotal = $EndPointName.Count
        $EndPointCounter = 0

        $MyPSObject = [PsCustomObject][ordered]@{
            EndPointName = $Null
            Status       = $Null
        }
    }

    Process
    {
        foreach ($EndPoint in $EndPointName)
        {
            $EndPointCounter = $EndPointCounter + 1
            if (Test-Connection $EndPoint -Count 1 -Quiet -ErrorAction SilentlyContinue)
            {
                Write-Verbose "[$EndPointCounter of $EndPointTotal] $EndPoint"
                $MyPSObject.EndPointName = $EndPoint.ToUpper()
                $MyPSObject.Status = "UP"
            }
            else
            {
                Write-Verbose "[$EndPointCounter of $EndPointTotal] OFFLINE: $EndPoint"
                $MyPSObject.EndPointName = $EndPoint.ToUpper()
                $MyPSObject.Status = "DOWN"
            }
            # NOTE: Add a switch here so this just outputs to a file
            # if it's called with the switch so it doesn't display to the screen
            # so I can use the verbose to display to screen.  Just an idea.  if it will work.
            $MyPSObject | Export-Csv -Path 'C:\Temp\Test-Ping-Results.csv' -Append -NoTypeInformation
        }
    }

    End
    {
    }
}




#$Array = @(
#"tech-tv2",
#"tech-tv3",
#"tech-tv1"
#)
#Test-Ping -EndPointName $Array -Verbose


#$pclist = Get-Content -Path 'C:\Temp\pclist.txt'
#Test-Ping -EndPointName $pclist


#do {
#$Ping = Test-Ping -EndPointName (Get-Content -Path 'C:\Users\david.newsom\Desktop\PCList.txt') -Verbose
#$Ping
#sleep 5
#}
#until ($Ping.status -notcontains 'down')


# Gets all computers active within the last 30 days. If you want inactive then you need to use "-lt" instead of "-gt".
#$Time = [datetime]::Today.AddDays(-60)
#$PCListAD = Get-ADComputer -Filter { (OperatingSystem -like "*Windows 10*") -and (Enabled -eq "True") -and (Name -ne "tech-dave-w") -and (LastLogonDate -gt $Time) } -Properties Name, LastLogonDate
#$PCList = $PCListAD | Select-Object -ExpandProperty Name | Sort

#Test-Ping -EndPointName $pclist -Verbose









<#

#Ping using jobs so it pings in parallel

function Test-Ping
{
    [CmdletBinding()]
    
    Param(
        [Parameter(Mandatory = $True,Position = 0)]
        [string[]]$ComputerName
    )
    
    Begin{}
    
    Process{
        $Connectivity = @()
        
        $Connectivity += Test-Connection -ComputerName $ComputerName -Count 1 -AsJob | Wait-Job | Receive-Job

        $Results = $Connectivity.where({
                $_.StatusCode -eq 0
        },'Split')

        ForEach($Item in $Results[1])
        {
            Write-Warning -Message "Unable to ping $($Item.Address)."
        }

        $Results[0].Address
    }
    
    End{}
}

#Test-Ping -ComputerName $Switch_IPs

#>






<#

# Another way of using jobs.

Function Get-Pingables {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory=$True, ValueFromPipeline = $True, Position = 0)]
        [String[]]$ComputerName,
        [string]$FilePath = "C:\Users\david.newsom\Desktop\Network-Switch-Ping-Report.txt"
    )

if (-not (Test-Path -Path $FilePath)) {
    New-Item -Path $FilePath -ItemType 'File'
}

    $pingables = @()
    $notpingables = @()

    $ComputerName | ForEach-Object {
        Set-Variable -Name "Status_$_" -Value (Test-Connection -ComputerName $_ -AsJob -Count 1)
    }

    Get-Variable "Status_*" -ValueOnly | ForEach-Object {
        $Status = Wait-Job $_ | Receive-Job 
        if ($Status.ResponseTime -ne $null ) {
            $pingables += @($Status.Address)
        }
        else {
            $notpingables += @($Status.Address)
            Add-Content $FilePath -Value "$((Get-Date).ToString("yyyy/MM/dd-HH:mm:ss")) | Not Pingable: $($Status.Address)"
        }
    }

    #Return $pingables
    "" # Blank Line
    Write-Warning -Message "Not Pingable" -Verbose
    Return $notpingables
}


#do {
Get-Pingables -ComputerName $Switch_IPs
#sleep 5
#}
#until ($exit)



#Get-Content -path C:\Utilities\servers.txt | ForEach-Object {
#    Test-Connection -ComputerName $_ -Count 1 -AsJob
#} | Get-Job | Receive-Job -Wait | Select-Object @{Name='ComputerName';Expression={$_.Address}},@{Name='Reachable';Expression={if ($_.StatusCode -eq 0) { $true } else { $false }}} | ft -AutoSize

#>
