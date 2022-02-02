param(
    [String]$Setup="",  ## Setup Argument
    [Array]$rargs  ## Rash Arguments
)

# some ps preferences
$ProgressPreference="Continue"

# Root of the Working Directory
$ScriptPath = if($PSScriptRoot) {$PSScriptRoot} else {Split-Path -Parent (Get-Process -id $PID).Path}

# Path where the Python Lives
$PythonPath = Join-Path -Path $ScriptPath -ChildPath "Python"
$PythonExecutable = Join-Path -Path $PythonPath -ChildPath "Python.exe"
$RashExecutable = Join-Path -Path (Join-Path -Path $PythonPath -ChildPath "Scripts") -ChildPath "Rash.exe"


# if someone runs this script not in file, then it will be installed in the current working directory

# Show Things in the Center, Not to be used directly
function Show-Center{
    param(
        $Message
    )

    $size = [Math]::Max($Host.UI.RawUI.BufferSize.Width - 1, 0)
    $left = [System.Int32]([Math]::Ceiling(($size - $Message.Length) / 2))
    $right = " " * ($size - ($left + $Message.Length))
    $left = " " * $left

    $Message = "{0}{1}{0}" -f $left, $Message, $right
    return @($size, $Message)
}


function Show-Safe{
    param(
        $Message,
        $Warning=$false,
        $clear=$false,
        $lines=2
    )

    if($clear) {Clear-Host} else {}
    
    $Host.UI.RawUI.WindowTitle = $Message

    $size, $Message= Show-Center $Message

    $foreground_color = if($Warning) {"White"} else {"Black"}
    $background_color = if ($Warning) {"Red"} else {"DarkGreen"}
    
    Write-Host $Message -ForegroundColor $foreground_color -BackgroundColor $background_color 
    
    for($i=0; $i -lt $lines; $i++){
        Write-Host (" " * $size) -BackgroundColor "DarkBlue"
    }
}


# Confirms whether user really wants to restore RashSetup
function Get-Confirmation{

    return $Host.UI.PromptForChoice(
        "Note: It might delete all the work you have referred or created until now!",  ## title
        "Are you sure, you want to restore to start?",  ## question
        @([System.Management.Automation.Host.ChoiceDescription]::new("&Yes", "Uninstalls Embedded Python If any, and also Rash package.")
        [System.Management.Automation.Host.ChoiceDescription]::new("&No", "Safe, right? :)")), ## options
        1
    ) -eq 0
}



function Invoke-WebRequestFile{
    param(
        $Url,
        $Output,
        [int]$_tried=0
    )

    if ($_tried -eq 0){
        Show-Safe("Downloading {0}" -f $Url)
        
    }
    else{
        Show-Safe -Warning $true -Message ("Retrying after {0} times" -f $_tried) 
    }
    
    try{
        Invoke-WebRequest -Uri $Url -OutFile $Output
        Show-Safe -clear $true -Message ("Saved in {0}" -f $Output)
    }
    catch{
        Show-Safe -Warning $true $Message ("Failed to download {0}" -f $Url)
        
        if($_tried -eq 2){
            Show-Safe "Max Tries exceeded, Please try again!" -Warning $true
            exit
        }

        Invoke-WebRequestFile -Url $Url -Output $Output -_tried ($_tried + 1)
    }
}


function Get-Python{
    Show-Safe "Downloading Embdeded Package of Python 3.8.9..." -clear $true
    
    
    $temp = Join-Path -Path $ScriptPath -ChildPath "python.zip"
    Invoke-WebRequestFile -Url "https://www.python.org/ftp/python/3.8.9/python-3.8.9-embed-amd64.zip" -Output $temp

    Show-Safe "Extracing Python Zip File"
    Expand-Archive -Path $temp -DestinationPath $PythonPath
    
    Show-Safe "Deleting Zip file"
    Remove-Item -Path $temp 

    $executable = Join-Path -Path $PythonPath -ChildPath 'python.exe'

    # ADJUSTMENT: 1

    Show-Safe "Arranging Pip for the python" -clear $true
    $temp = Join-Path -Path $PythonPath -ChildPath "get-pip.py"
    Invoke-WebRequestFile -Url "https://bootstrap.pypa.io/get-pip.py" -Output $temp

    & $executable $temp
    Show-Safe "Pip Arranged" -clear $true
    Remove-Item -Path $temp

    # ADJUSTMENT: 2 
    
    Show-Safe "Attaching the site packages to intepreter" -clear $true

    $temp = Get-ChildItem -Path $PythonPath -Filter "*._pth"
    (((Get-Content -Path $temp.FullName) -replace "#(?=import site)", "") -replace "^python.*\.zip$", "Lib") | Set-Content -Path $temp.Fullname

    $temp = Join-Path -Path $PythonPath -ChildPath "sitecustomize.py"
    New-Item -Path $temp -ItemType "file"
    Set-Content -Path $temp -Value "import sys;sys.path.insert(0, '');"

    
    # ADJUSTMENT: 3
    Show-Safe "Solving for the lib2to3 issue" -clear $true

    $temp = (Get-ChildItem -Path $PythonPath -Filter "*.zip")
    $unzipped = Join-Path -Path $PythonPath -ChildPath "Lib"
    
    Expand-Archive -Path $temp.FullName -DestinationPath $unzipped
    Remove-Item -Path $temp.Fullname
}


function Get-Rash{
    & $PythonExecutable @("-m", "pip", "install", "git+https://github.com/RahulARanger/Rash.git")
}

function Remove-Python{
    Remove-Item -Path $PythonPath -Recurse
}

$result = @(
            (Test-Path -Path $PythonExecutable),
            (Test-Path -Path $RashExecutable)
        )

switch($Setup){
    "python"{
        & $PythonExecutable
        break

    }
    "restore"{
        Remove-Python
    }

    "uninstall"{
        break
    }

    {$_ -eq "" -or $_ -eq "check"}{    ## we check before starting rash too

        if($result[0]) {Show-Safe "You have Embedded Python that Rash needs"} else {Show-Safe "You have not Downloaded Python" -Warning $true}
        if($result[1]) {Show-Safe "You have Rash Package"} else {Show-Safe "You have not Downloaded Rash" -Warning $true}
    }

    "check"{
        Show-Safe "Execute this Script without any arguments for setting up all necessities"
        break
    }
    
    {$result[0] -eq $false}{
        ## if result is false we download python in the current working directory or directory of this file
        Get-Python
    }
    {$result[1] -eq $false}{
        Get-Rash
    }

    "" {
        & $RashExecutable $rargs
    }
}