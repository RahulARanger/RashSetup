param(
    [int]$mode = 0
) 

$ScriptPath = (Get-Location).Path
$PythonPath = Join-Path -Path $ScriptPath -ChildPath "Python";
$executable = Join-Path -Path $PythonPath -ChildPath "python.exe";

function Get-RunningProjects{
    $Pythons = Join-Path -Path $PythonPath -ChildPath "*";
    return  Get-WmiObject -Class "Win32_Process" -ComputerName "." | where-object {$_.Path -like $Pythons};
}


switch($mode){
    0 { 
        $store = @(Get-RunningProjects);
        if($store.length -gt 0){$store | Out-GridView -passthru -Title "These processes must be closed in-order to proceed forward!"}
        if($store.length -gt 0){exit 5} else {}  # exiting with the bad mood 😤
     }

     1{ 
        $pythonZip = Join-Path -Path $ScriptPath -ChildPath "python.zip";
        Expand-Archive -Path $pythonZip -DestinationPath $PythonPath;
        Remove-Item -Path $pythonZip;
     }

     2{
        $pipFile = Join-Path -Path $ScriptPath -ChildPath "get-pip.py";
        & $executable $pipFile;
        Remove-Item -Path $pipFile;
     }

     3{
         $sitePath = Get-ChildItem -Path $PythonPath -Filter "*._pth"
         Set-Content -Path $sitePath.FullName -Value "
Lib
Lib/site-packages
.
import site
"
         $sitePath = Join-Path -Path $PythonPath -ChildPath "sitecustomize.py"
         if(Test-Path -Path $sitePath) {Remove-Item -Path $sitePath} else {}
         New-Item -Path $sitePath -ItemType "file"
         
         Set-Content -Path $sitePath -Value "
import sys;
import sys;
sys.path = sys.path[: 3]
"}

     4{
        $internalModules = (Get-ChildItem -Path $PythonPath -Filter "*.zip")
        $unzipped = Join-Path -Path $PythonPath -ChildPath "Lib"
    
        Expand-Archive -Path $internalModules.FullName -DestinationPath $unzipped
        Remove-Item -Path $internalModules.Fullname
     }

     5{
        $requirements = Join-Path -Path (Join-Path -Path $ScriptPath -ChildPath "ProjectAnalysis") -ChildPath "requirements.txt";
        if (Test-Path -Path $requirements) {& $executable @("-m", "pip", "install", "-r", $requirements)} else {}
     }

     Default{

     }
}
