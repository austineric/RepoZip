
#powershell uses tls 1.0 by default so force it to use tls 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo=""
$url=""

$username="USERNAME HERE"
$destination="C:$env:HOMEPATH\Documents"

Clear-Host

#handles three entry types:
#repo name: RepoZip
#github URL: https://github.com/austineric/RepoZip
#clone or download URL: https://github.com/austineric/RepoZip.git

Write-Host ""
[string]$response=Read-Host "Enter repo name or GitHub URL."

#clone or download URL
If ($response -like "*github.com*.git") {

    #split the url entered by the forward slash into an array, get the last value in the array, and replace the .git
    $repo=@($response.Split("/"))[-1]
    $repo=$repo.Replace(".git","")

    #prepare url
    $url=$response.Replace(".git","")
    $url=$url + "/archive/master.zip"
    
    }

#github URL
Elseif ($response -like "*github.com*") {

    #split the url entered by the forward slash into an array and get the last value in the array
    $repo=@($response.Split("/"))[-1]
    
    $url=$response + "/archive/master.zip"
    
    }

#repo name
Else {
    
    #exit if not entered
    If ($response -eq "") {
        Write-Host "Invalid entry. Exiting now."
        Pause
        Exit
        }
    Else {$repo=$response}

    #prompt for username if it hasn't been hardcoded
    If ($username -eq "USERNAME HERE") {
        
        Write-Host ""
        Write-Host 'It appears you have entered a repo name.'
        Write-Host 'Enter the GitHub username for the repo (ie "austineric" is the username for https://github.com/austineric/RepoZip).'
        Write-Host 'To hard-code a username, close this window and add the username to the RepoZip.ps1 file where it says "USERNAME HERE".'
        Write-Host ""
        
        $username=Read-Host "Enter username"
        
        #exit if not entered
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

#check if destination directory already exists
If (Test-Path $destination\$repo) {
    Clear-Host

    #confirm before deleting and replacing
    Write-Host ""
    $response=Read-Host "The destination $destination\$repo already exists. Delete and replace? (y/n)"
    If ($response -eq "y") {
        Remove-Item $destination\$repo -Recurse -Force
        }
    Elseif ($response -eq "n") {
        Write-Host ""
        Write-Host "Cancelled. Exiting now." 
        Write-Host ""
        Pause
        Exit
        }
    Else {
        Write-Host ""
        Write-Host "Invalid response. Exiting now."
        Write-Host ""
        Pause
        Exit
    }
}

#retrieve the zip file
Try {
    Invoke-WebRequest -Uri $url -OutFile "$destination\$repo.zip"
    Expand-Archive -Path "$destination\$repo.zip" -DestinationPath $destination
    Remove-Item "$destination\$repo.zip"
    
    #remove the "-master" from the folder name
    Get-ChildItem -Path "$destination" -Filter "$repo-master" | ForEach {
        Rename-Item -Path $_.FullName -NewName ($_.Name).Replace("-master","")
        }
    
    #remove .git files and README.md file
    Remove-Item -Path $destination\$repo\*.git*
    Remove-Item -Path $destination\$repo\README.md

    Write-Host ""
    Write-Host "Completed."
    Write-Host ""
    Pause
    Exit
}
Catch {

    Write-Host ""
    Write-Host "Download failed. Ensure the repo name or URL gets entered correctly and the repo is not set to private and try again."
    Write-Host ""
    Pause
    Exit
}

