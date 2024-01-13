<#
.SYNOPSIS
    Get the AD status of a computer or list of computers
.DESCRIPTION
    Get the AD status of a computer or list of computers
.NOTES
    Created by Michael English
.LINK
    https://learn.microsoft.com/en-us/powershell/module/activedirectory/get-adcomputer?view=windowsserver2022-ps
.EXAMPLE
    .\Get-ADComputerStatus.ps1 -Identity VDIP-W10-013
    Get the AD Status of a single computer.
.EXAMPLE
    .\Get-ADComputerStatus.ps1 -Identity VDIP-W10-013, VDIP-W10-041
    Get the AD Status of multiple computers.
.EXAMPLE
    .\Get-ADComputerStatus.ps1 (Get-Content .\ServerList.txt)
    Get the AD Status of multiple computers in a txt file.
.EXAMPLE
    $test = .\Get-ADComputerStatus.ps1 -Identity VDIP-W10-013
    Assign output to a variable.
.EXAMPLE
    .\Get-ADComputerStatus.ps1 (Get-Content .\ServerList.txt) | Export-Csv .\AdStatus.csv -NoTypeInformation
    Get the AD Status from a list of computers in ServerList.txt and export to a CSV file.
.EXAMPLE
    .\Get-ADComputerStatus.ps1 (Get-Content .\ServerList.txt) | Where-Object {$_.Status -eq $false} | Export-Csv .\AdStatusFalse.csv -NoTypeInformation
    Get the AD Status from a list of computers in ServerList.txt, filter the results, and export to a CSV file.
    
#>

[CmdletBinding()]
param (
    [Parameter(   
        Position = 0,
        Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        ValueFromPipeline = $true
    )]
    [string[]]
    $Identity
)

# Import AD Module
Import-Module ActiveDirectory

# Create an array for objects
$ArrayAdComputerData = @()
$Progress = 0

# Try checking Ad for computer name Write to host any that error
foreach ($Device in $Identity) {
    $Progress++
    $Completed = ($Progress/$Identity.Count) * 100
    Write-Progress -Activity "Working on:" -Status "$Device" -PercentComplete $Completed

    try{
        $null = Get-ADComputer -Identity $Device -ErrorAction Stop
        $ArrayAdComputerData += @(
            [PSCustomObject]@{
                Identity = $Device;
                Status   = $true
            }
        )
        
    }
    catch{ 
        $ArrayAdComputerData += @(
            [PSCustomObject]@{
                Identity = $Device;
                Status   = $false
            }
        )
    }
}

return $ArrayAdComputerData
