# Replace content in a file
param (
    [Parameter(Mandatory, Position=0)]
    [string] $FilePath,

    [Parameter(Mandatory, Position=1)]
    [string] $ReplaceThis,

    [Parameter(Mandatory, Position=2)]
    [string] $WithThat
)
echo $FilePath
echo $ReplaceThis
echo $WithThat

(Get-Content $FilePath) -replace $ReplaceThis, $WithThat | Set-Content $FilePath