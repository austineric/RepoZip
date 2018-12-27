
#powershell uses tls 1.0 by default so force it to use tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo="SimpleSQLServerSourceControl"
$url="https://github.com/austineric/$repo/archive/master.zip"
$destination="C:$env:HOMEPATH\Documents"

If (Test-Path $destination\$repo) {
    Remove-Item $destination\$repo -Recurse -Force
}

Invoke-WebRequest -Uri $url -OutFile "$destination\$repo.zip"
Expand-Archive -Path "$destination\$repo.zip" -DestinationPath $destination
Remove-Item "$destination\$repo.zip"
Rename-Item -Path "$destination\$repo-master" -NewName $repo