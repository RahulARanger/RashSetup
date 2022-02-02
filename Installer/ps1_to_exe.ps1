$title = "Rash"
$version = "0.0.1"
$copyright = "MIT License"
$product = "Rash"

$inputFile = Join-Path -Path $PSScriptRoot -ChildPath ".\setup.ps1"
$outputFile = Join-Path -Path $PSScriptRoot -ChildPath "Rash.exe"

$description = "Rash is a Qt-Py Application Which enables us to execute python plugins on our system. Based on certain Date or Time Or may Startup-Script. For more information visit: Repo"

# Note: For now it's Single Threaded it might be MTA in the future


ps2exe -inputFile $inputFile -outputFile $outputFile -title $title  -version $version -copyright $copyright -product $product -description $description
