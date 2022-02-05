#define Name="RashSetup"

[Setup]
AppName="RashSetup"
AppVersion="0.1.0"
AppPublisher="RahulARanger"
AppPublisherURL="https://github.com/RahulARanger"
AppSupportURL="https://github.com/RahulARanger/RashSetup"

; WHERE TO SAVE AFTER INSTALLATION
DefaultDirName="{autopf}\{#Name}"


OutputDir="Test"
OutputBaseFilename="RashSetup"


; Compression Things
Compression=lzma
SolidCompression=yes

; Uses Windows Vista style
WizardStyle=modern

; RUNS AND SAVES IN 64 bit dir
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

DisableWelcomePage=no
; This is the first page up until now, it just shows the LICENSE and makes sure user accepts it
LicenseFile="../LICENSE"


[Files]
Source: "setup.ps1"; DestDir: "{app}";

[UninstallDelete]
Type: filesandordirs; Name: "{app}\python"

[Run]
Filename: "powershell.exe"; \
  Description: "Downloads Python 3.8.9 After Setup"; \
  WorkingDir: "{app}"; \
  StatusMsg: "Setting Embedded Python 3.8.9"; \
  Flags: waituntilterminated; \
  Parameters: "-file ""{app}/setup.ps1"""
