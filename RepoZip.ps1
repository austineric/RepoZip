
#powershell uses tls 1.0 by default so force it to use tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$username="USERNAME HERE"
$destination="C:$env:HOMEPATH\Documents"

Clear-Host

#need the repo name (and if only repo name was entered then also need user name)

#handle three entry types:
#repo name: RepoZip
#GitHub URL: https://github.com/austineric/RepoZip
#Clone or download URL: https://github.com/austineric/RepoZip.git

[string]$response=Read-Host "Enter repo name or GitHub URL."

#clone or download URL
If ($response -like "*github.com*.git") {
    
    #remove .git
    $url=$response.Replace(".git","")
    $url=$url + "/archive/master.zip"

    #split the url entered by the forward slash into an array, get the last value in the array, and remove the .git
    $repo=@($url.Split("/"))[-1]
    $repo=$repo.Replace(".git","")
    }

#github URL
Elseif ($response -like "*github.com*") {

    $url=$response + "/archive/master.zip"

    #split the url entered by the forward slash into an array and get the last value in the array
    $repo=@($url.Split("/"))[-1]
    }

#repo name
Else {
    
    If ($response -eq "") {
        Write-Host "Invalid entry. Exiting now."
        Pause
        Exit
        }
    Else {$repo=$response}

    #prompt for username if it hasn't been hardcoded
    If ($username -eq "USERNAME HERE") {
        Write-Host 'It appears you have entered a repo name. Enter the GitHub username for the repo (ie austineric is the username for https://github.com/austineric/RepoZip). To hard-code a username, close this window and add the username to the RepoZip.ps1 file where it says "USERNAME HERE".'
        $username=Read-Host "Enter username"
        If ($username -eq "") {
            Write-Host "Invalid entry. Exiting now."
            Pause
            Exit
            }  
        Else {
            $url="https://github.com/$username/$repo/archive/master.zip"
            }      
        }
    }

Write-Host $url



[int]$method=Read-Host "Enter 1 to use a GitHub URL or 2 to use a GitHub repo name."
If ($method -eq 1) {
    $url=Read-Host "Enter GitHub URL"
    $repo=@($url.Split("/"))[-1]
    $url="$url/archive/master.zip"
}
Elseif ($method -eq 2) {
    If ($username -eq "Username here") {
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

#check if destination directory already exists
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

#retrieve the zip file
Try {
    Invoke-WebRequest -Uri $url -OutFile "$destination\$repo.zip"
    Expand-Archive -Path "$destination\$repo.zip" -DestinationPath $destination
    Remove-Item "$destination\$repo.zip"
    Rename-Item -Path "$destination\$repo-master" -NewName $repo
    
    #remove .gitignore, .gitattributes, etc, and README.md
    Remove-Item -Path "$destination\$repo\*.git*"
    Remove-Item -Path "$destination\$repo\README.md"
    
    Write-Host "Completed."
    Pause
    Exit
}
Catch {
    Write-Host "Download failed. Ensure the repo name or URL is entered correctly and the repo is not set to private and try again."
    Pause
    Exit
}

