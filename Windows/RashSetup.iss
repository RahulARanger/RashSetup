#include "misc.iss"

#define Name="RashSetup"
#define Repo="https://github.com/RahulARanger/RashSetup"
#define Author="RahulARanger"
#define Version="0.4.0"
#define StartScript = "../Test_Module/test_script.py"
#define PyRoot = "{app}/python"

[Setup]
; Basic Meta
AppName="{#Name}"
AppVersion="{#Version}"
AppPublisher="{#Author}"
AppPublisherURL="{#Repo}"
AppSupportURL="{#Repo}"
AppContact="{#Repo}"
AppUpdatesURL="{#Repo}/releases/latest"


; IMPORTANT
; though default yes, don't change this, else we won't be able to quit even if install fails
AllowCancelDuringInstall=yes

; This DEMO doesn't add registry keys 
; like does it add some registry keys
ChangesEnvironment=yes  

; 64 Bit Application, this changes lot of constants like the fodler for {app} its in program files
; instead of programe files (x86)
; refer: https://jrsoftware.org/ishelp/topic_consts.htm
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; makes installer not fully resizable (it still has some max and min sizes)
WindowResizable=no

; Group Name on starts folder
DefaultGroupName="{#Name}"                                                 

; Show Selected Directory
AlwaysShowDirOnReadyPage=yes
AppComments="This Installer is only for demo, doesn't do anything other show the latest release of this {#Repo}"

; WHERE TO SAVE AFTER INSTALLATION
DefaultDirName="{autopf}\{#Name}"


OutputDir="Test"
OutputBaseFilename="{#Name}"

; uninstall exe file name 
UninstallDisplayName="{#Name}-Uninstall"

; Compression Things
Compression=lzma
SolidCompression=yes

; Uses Windows Vista style
WizardStyle=modern

DisableWelcomePage=no
; This is the first page up until now, it just shows the LICENSE and makes sure user accepts it
LicenseFile="../LICENSE"
InfoBeforeFile="README.rtf"

; doesn't allow more than one setup to run at the same time
SetupMutex="{#Name}-MUTEX"

; Below Values are Oberserved Values
ExtraDiskSpaceRequired=40022016
ReserveBytes=58576896


[Files]
Source: "{tmp}\python.zip"; DestDir: "{app}"; flags: external skipifsourcedoesntexist;
Source: "{tmp}\get-pip.py"; DestDir: "{app}"; flags: external skipifsourcedoesntexist;
Source: "./setup.ps1"; DestDir: "{app}"; Permissions: users-modify; Flags: deleteafterinstall;
; don't delete this ps1 file, it does some reliable work
Source: "./gate.ps1"; DestDir: "{app}";

Source: "../requirements.txt"; DestDir: "{app}"; Permissions: users-modify; AfterInstall: PostInstall; 
; Below this are not available while Application is executing PostInstall procedure

Source: "../Test_Module\*"; DestDir: "{app}/Test_Module";


[UninstallDelete]
; files which have been skipped must be explicitly mentioned in this section 
Type: filesandordirs; Name: "{#PyRoot}";
Type: files; Name: "{app}\python.zip";
Type: files; Name: "{app}\get-pip.py";
Type: files; Name: "{app}\setup.ps1";

[Dirs]
Name: "{app}/python"; Permissions: everyone-full


[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Icons]
Name: "{group}\{#Name}"; Filename: "{#PyRoot}/python.exe"; Parameters: "{#StartScript}"; WorkingDir: "{#PyRoot}"; Comment: "Starts the Demo Script"; Flags: runminimized
Name: "{autodesktop}\{#Name}"; Filename: "{#PyRoot}/python.exe"; Parameters: "{#StartScript}"; WorkingDir: "{#PyRoot}"; Comment: "Starts the Demo Script"; Flags: runminimized; Tasks: desktopicon 

[Run]
// any other than powershell.exe will trigger false positive virus test.
Filename: "powershell.exe"; Description: "Starts the Demo Script"; Parameters: "-file ""{app}\gate.ps1"" -mode 1"; WorkingDir: "{app}"; Flags: postinstall runasoriginaluser runminimized;


[Code]
// https://stackoverflow.com/questions/28221394/proper-structure-syntax-for-delphi-pascal-if-then-begin-end-and
// we start with this event
procedure InitializeWizard;
begin
  Ask := True;
  ImplicitExitCode := -1073741510;
  Downloaded := True;
  DownloadPage := CreateDownloadPage('Downloading Python...', 'Downloading & Extracting Embedded python 3.8.9.zip', @OnDownloadProgress);
  DataOutDated := False;
end;
                                    
function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  if CheckAndQuit() <> 0 then 
    Result := 'Please Close the necessary running applications to proceed forward'
  else
    Result := CheckAndDownloadPython();
end;


// one needs to copy this event function as it is or modify them as they need
procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := Confirm and Ask;
end;


function InitializeUninstall: Boolean;
begin
  Result := CheckAndQuit() = 0;
  if not Result then
      MsgBox('Please close the necessary applications before uninstalling this application!', mbError, MB_OK)
end;      



procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
ResultCode: Integer;
begin
  if CurUninstallStep = usUninstall then
  begin
    ExecPSScript('gate.ps1', True, '-mode 2', ResultCode);
  end;
end;
