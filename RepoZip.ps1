
#powershell uses tls 1.0 by default so force it to use tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$username="USERNAME HERE"
$destination="C:$env:HOMEPATH\Documents"

Clear-Host

[int]$method=Read-Host "Enter 1 to use a GitHub URL or 2 to use a GitHub repo name."
If ($method -eq 1) {
    $url=Read-Host "Enter GitHub URL"
    $repo=@($url.Split("/"))[-1]
    $url="$url/archive/master.zip"
}
Elseif ($method -eq 2) {
    If ($username="Username here") {
        Write-Host 'Please add GitHub username to the RepoZip.ps1 file where it says "USERNAME HERE". Exiting now.'
        Pause
        Exit
    }
    Else {
        $repo=Read-Host "Enter repo name"
        $url="https://github.com/$username/$repo/archive/master.zip"
    }    
}
Else {Write-Host "Invalid response. Exiting now."
        Pause
        Exit
}


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
    Write-Host "Download failed. Ensure the repo name or URL is entered correctly and try again."
    Pause
    Exit
}

