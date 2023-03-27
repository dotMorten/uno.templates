﻿param(
    # Version of published Uno.Extensions packages
    [string]$ExtensionsVersion = "2.3.2",

    # Version of published Uno.WinUI packages
    [string]$UnoVersion = "4.8.15"
)

function RemoveNuGetPackage {
    param (
        [string]$PackageName
    )
    
    $installed = (dotnet new uninstall) -join ","
    if ($installed -like "*$PackageName*") {
        dotnet new uninstall $PackageName
    }
}

RemoveNuGetPackage -PackageName "Uno.Templates"

# Ensure legacy pacakges are removed
RemoveNuGetPackage -PackageName "Uno.Extensions.Templates"
RemoveNuGetPackage -PackageName "Uno.ProjectTemplates.Dotnet"

# Remove artifacts from previous builds
Get-ChildItem .\ -Include bin,obj -Recurse | ForEach-Object ($_) { Remove-Item $_.Fullname -Force -Recurse }

dotnet build -p:Version=$UnoVersion -p:UnoVersion=$UnoVersion -p:UnoExtensionsVersion=$ExtensionsVersion -c Release
if($LASTEXITCODE -ne 0) {
    Write-Error "Building NuGet Package failed."
    exit $LASTEXITCODE
}
dotnet new install $PSScriptRoot\bin\Release\Uno.Templates.$UnoVersion.nupkg

