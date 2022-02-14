param (
    [int]$mode = 0
)


$ScriptPath = if($PSScriptRoot) {$PSScriptRoot} else {Split-Path -Parent (Get-Process -id $PID).Path};
$PythonPath = Join-Path -Path $ScriptPath -ChildPath "Python";
$executable = Join-Path -Path $PythonPath -ChildPath "python.exe";

switch ($mode) {
    0 { 
        # unzipping python zip
        $pythonZip = Join-Path -Path $ScriptPath -ChildPath "python.zip";
        Expand-Archive -Path $pythonZip -DestinationPath $PythonPath;
        Remove-Item -Path $pythonZip;
     }

     1{
        # Installing PIP
        $pipFile = Join-Path -Path $ScriptPath -ChildPath "get-pip.py";
        & $executable $pipFile;
        Remove-Item -Path $pipFile;
     }

     2{
        # settings the path for the site-packages, so scripts can use those 
        $sitePath = Get-ChildItem -Path $PythonPath -Filter "*._pth"
        (((Get-Content -Path $sitePath.FullName) -replace "#(?=import site)", "") -replace "^python.*\.zip$", "Lib") | Set-Content -Path $sitePath.Fullname
        
        $sitePath = Join-Path -Path $PythonPath -ChildPath "sitecustomize.py"
        New-Item -Path $sitePath -ItemType "file"
        
        Set-Content -Path $sitePath -Value "import sys;sys.path.insert(0, '');"
     }

     69{
        # this is for testing, downloading python and script for PIP
        Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.8.9/python-3.8.9-embed-amd64.zip" -OutFile (Join-Path -Path $ScriptPath -ChildPath "python.zip");
        Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile ( Join-Path -Path $ScriptPath -ChildPath "get-pip.py"); 
    }


     Default {
        $internalModules = (Get-ChildItem -Path $PythonPath -Filter "*.zip")
        $unzipped = Join-Path -Path $PythonPath -ChildPath "Lib"
    
        Expand-Archive -Path $internalModules.FullName -DestinationPath $unzipped
        Remove-Item -Path $internalModules.Fullname
    }

    90{
        # again this is for testing purposes, not really tested, it deletes installed python
        if (Test-Path -Path $PythonPath) {Remove-Item -Path $PythonPath -Recurse -Force} else {$false};
    }
}
