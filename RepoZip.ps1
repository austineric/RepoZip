
#powershell uses tls 1.0 by default so force it to use tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Clear-Host
$repo=Read-Host "Enter repo name"
$url="https://github.com/austineric/$repo/archive/master.zip"
$destination="C:$env:HOMEPATH\Documents"

If (Test-Path $destination\$repo) {
    Clear-Host
    $response=Read-Host "The destination $destination\$repo already exists. Delete and replace? (y/n)"
    If ($response -eq "y") {
        Remove-Item $destination\$repo -Recurse -Force
    }
    Elseif ($response -eq "n") {
        Write-Host "Cancelled. Exiting now." 
        Pause
        Exit
    }
    Else {Write-Host "Invalid response. Exiting now."
        Pause
        Exit
    }
}

Try {
    Invoke-WebRequest -Uri $url -OutFile "$destination\$repo.zip"
    Expand-Archive -Path "$destination\$repo.zip" -DestinationPath $destination
    Remove-Item "$destination\$repo.zip"
    Rename-Item -Path "$destination\$repo-master" -NewName $repo
    Write-Host "Completed."
    Pause
    Exit
}
Catch {
    Write-Host "Download failed. Ensure the repo name is entered correctly and try again."
    Pause
    Exit
}

