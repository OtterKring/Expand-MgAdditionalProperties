<#
.SYNOPSIS
Expands the attribute "AdditionalProperties" returned by cmdlets like Get-MgUserMember

.DESCRIPTION
Expands the attribute "AdditionalProperties" returned by cmdlets like Get-MgUserMember and converts the dictionary to a standard PSCustomObject

.PARAMETER AdditionalProperties
takes the data from the AdditionalProperties attribute returned by cmdlets like Get-MgUserMember as input

.PARAMETER DoNotConvertToDateTime
turn off automatic conversion of everything that looks like '2022-05-16T06:33:45Z' to a [datetime] object

.EXAMPLE
Get-MgUserMember -UserId albert@einstein.net | Expand-MgAdditionalProperties | Format-Table

.EXAMPLE
Get-MgUser -UserId albert@einstein.net | Foreach-Object { Get-MgUserOwnedDevice -UserId $_.id | Expand-MgAdditionalProperties} | ? {$_.DeviceCategory -eq "mobile" -and $_.approximateLastSigninDateTime -gt (Get-Date).AddMonths(-1)}

This examples takes advantage of the automatic datetime conversion, which enabled a direct comparison with (Get-Date).AddMonths(-1)

.NOTES
2022-04-14 ... initial version by Maximilian Otter
2022-05-25 ... added optional (default=on) conversion of date/time strings to [datetime] objects
#>
function Expand-MgAdditionalProperties {
    param (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        $AdditionalProperties,
        [switch]
        $DoNotConvertToDateTime
    )

    process {
        $hash = @{}
        foreach ($key in $AdditionalProperties.Keys) {
            if (!$DoNotConvertDateTime -and $AdditionalProperties.$key -match '^\d{4}(-\d\d){2}T\d\d(:\d\d){2}Z$') {
                $hash.Add($key,[datetime]$AdditionalProperties.$key)
            } else {
                $hash.Add($key,$AdditionalProperties.$key)
            }
        }
        [PSCustomObject]$hash
    }
}