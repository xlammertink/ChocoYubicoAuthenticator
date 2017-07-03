﻿$ErrorActionPreference = 'Stop';

$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  softwareName  = 'yubikey piv manager*'
  fileType      = 'exe'
  silentArgs    = "/S"

  validExitCodes= @(0)
}

$uninstalled = $false
[array]$key = Get-UninstallRegistryKey @packageArgs

if ($key.Count -eq 1) {
  $key | % { 
    $packageArgs['file'] = "$($_.UninstallString)"
    if ($packageArgs['fileType'] -eq 'MSI') {
      $packageArgs['silentArgs'] = "$($_.PSChildName) $($packageArgs['silentArgs'])"
      $packageArgs['file'] = ''
    }

    Uninstall-ChocolateyPackage @packageArgs
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$env:ChocolateyPackageName has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$key.Count matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $_.DisplayName"}
}

# Remove shortcust created at install
$menuPath = (Join-Path -Path $env:APPDATA -ChildPath "Microsoft\Windows\Start Menu\Programs\Yubico\Yubikey PIV Manager")
Remove-Item $menuPath -Force -Recurse
