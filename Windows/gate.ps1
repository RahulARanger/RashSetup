param(
    [int]$mode=0,
    [switch]$update,
    [String[]]$arguments
)

$DebugPreference = 'Continue'
$ErrorActionPreference = "Stop"


# Some Dynamic Constants

$ScriptPath = (Get-Location).Path
$PythonPath = Join-Path -Path $ScriptPath -ChildPath "Python";
$executable = Join-Path -Path $PythonPath -ChildPath "python.exe";
$Test = Join-Path -Path $ScriptPath -ChildPath "Test_Module"


function Get-RunningProjects{
    $Pythons = Join-Path -Path $PythonPath -ChildPath "*";
    return  Get-WmiObject -Class "Win32_Process" -ComputerName "." | where-object {$_.Path -like $Pythons};
}


function Get-ProjectPyPath{
    param(
        [string]$file
    )
    return '"' + (Join-Path -Path $Test -ChildPath "$file.py") + '" '
}

function Start-PythonScript{
    param(
        [String]$file="test_script",
        [String[]]$arg_s=@()
    )

    $arg_s = (Get-ProjectPyPath -file $file) + $arg_s
    Start-Process $executable -WindowStyle Maximized -WorkingDirectory $ScriptPath -ArgumentList ($arg_s -Join " ")
}


function Get-Update{
        
    $response = Invoke-RestMethod -Uri "https://api.github.com/repos/Tangellapalli-Srinivas/CO-PO-Mapping/releases/latest" -Method "GET"
    $update_it = $response.tag_name -ne $arguments[0]

    if (-not $update_it){
        return
    }


    $download_url = $response.assets.browser_download_url
    $temp = Join-Path -Path $env:TEMP -ChildPath $response.assets.Name
    write-Output $temp

    Invoke-WebRequest -Uri $download_url -OutFile $temp

    Start-Process -FilePath $temp -Wait
    Remove-Item -Path $temp
}


switch($mode){
    0 { 
        $store = @(Get-RunningProjects);
        if($store.length -gt 0){
            $store | Out-GridView -passthru -Title "These processes must be closed in-order to proceed forward!"
            exit 5
        }
     }

     1{ 
        Start-PythonScript
     }

     2{
         Write-Debug "Removing Python Directory"
         $host.UI.RawUI.WindowTitle = "Don't close this window, Closing this would affect the uninstallation process."
         Write-Debug "Collecting INFO..."
         
         
         $collected = Get-ChildItem -Path $PythonPath -Recurse -File | ForEach-Object {$_.FullName}
         
         $index = 0
         $total = $collected.Length
         foreach ($file in $collected) {
            Remove-Item -path $file -Force
            $index += 1;
            Write-Progress -Activity "Removing Components of Python...`nDeleted:$file" -Status "Deleted Files $index / $total" -PercentComplete (($index / $total) * 100)
         }

         Write-Debug "Completed..."
     }

    Default{
      [console]::beep(2000,500)
     }
}

$DebugPreference = 'SilentlyContinue'
$ErrorActionPreference = "Continue"
