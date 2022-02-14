param(
    [int]$mode = 0
)   

# HELPER SCRIPT CHECKS FOR UNPLEASANT SITUATIONS AND SOMETIMES HELPS US TO OVERCOME IT
# ERROR CODES: https://docs.microsoft.com/en-us/windows/win32/debug/system-error-code-lookup-tool

function Get-RunningProjects{
    # Assuming Innosetup runs this by setting {app} as current working director
    # using w32process https://docs.microsoft.com/en-us/windows/win32/wmisdk/wmi-tasks--processes
    
    # all applications inside the Python directory
    $PythonPath = Join-Path -Path (Join-Path -Path (Get-Location).Path -ChildPath "Python") -ChildPath "*";
    
    return  Get-WmiObject -Class "Win32_Process" -ComputerName "." | where-object {$_.Path -like $PythonPath};
}


switch ($mode) {
    0 { 
        $store = @(Get-RunningProjects);
        
        if($store.length -gt 0){
            # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-gridview?view=powershell-7.2
            $store | Out-GridView -passthru -Title "These processes must be closed in-order to proceed forward!"
        }
     }
     1{
         # killing the running processes
         # NOT RECOMMENDED
         # NOT TESTED

         foreach($id in (Get-RunningProjects).id){
             Stop-Process -Id $id;
        }
     }
    Default {}
}

