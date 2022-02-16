#define Name="RashSolo"
#define Repo="https://github.com/RahulARanger"
#define Author="RahulARanger"
#define Version="0.2.0"

[Setup]
; Basic Meta
AppName="{#Name}"
AppVersion="{#Version}"
AppPublisher="{#Author}"
AppPublisherURL="{#Repo}"
AppSupportURL="{#Repo}"
AppContact="{#Repo}"


; IMPORTANT
AllowCancelDuringInstall=yes
; tho default yes, don't change this, else we won't be able to quit even if install fails I GUESS

; does it add some registry keys
ChangesEnvironment=yes  

; 64 Bit Application, this changes lot of constants like the fodler for {app} its in program files
; instead of programe files (x86)
; refer: https://jrsoftware.org/ishelp/topic_consts.htm
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

; makes installer not fully resizable (it still has some max and min sizes)
WindowResizable=no

; Group Name on starts folder
DefaultGroupName="Project-Analysis"                                                 

; Show Selected Directory
AlwaysShowDirOnReadyPage=yes
AppComments="This Instsaller downloads an Application but for it's functioning it requires python Interpreter for which this installer aims to provide it"

; WHERE TO SAVE AFTER INSTALLATION
DefaultDirName="{autopf}\{#Name}"


OutputDir="Test"
OutputBaseFilename="{#Name}Solo"

; uninstall exe file name 
UninstallDisplayName="RashSolo-Uninstall"

; Compression Things
Compression=lzma
SolidCompression=yes

; Uses Windows Vista style
WizardStyle=modern

DisableWelcomePage=no
; This is the first page up until now, it just shows the LICENSE and makes sure user accepts it
LicenseFile="../LICENSE"

; doesn't allow more than one setup to run at the same time
SetupMutex="RashSoloMUTEX"


[Files]
Source: "{tmp}\python.zip"; DestDir: "{app}"; flags: external skipifsourcedoesntexist;
Source: "{tmp}\get-pip.py"; DestDir: "{app}"; flags: external skipifsourcedoesntexist;

; don't delete this ps1 file, it does some reliable work
Source: "helper.ps1"; DestDir: "{app}";


[UninstallDelete]
; files which have been skipped must be explicitly mentioned in this section 
Type: filesandordirs; Name: "{app}\python"
Type: files; Name: "{app}\python.zip"
Type: files; Name: "{app}\get-pip.py"

[Dirs]
Name: "{app}/python"; Permissions: everyone-full



[Code]

// https://stackoverflow.com/questions/28221394/proper-structure-syntax-for-delphi-pascal-if-then-begin-end-and

var                                                         
  DownloadPage: TDownloadWizardPage;  // downloads packages
  SettingThingsUp: TOutputMarqueeProgressWizardPage; // loading ===== progress bar 
  Downloaded: Boolean; // downloaded python or not 
  EC: Integer;   // temp for Error Code
  Prefix: String; // prefix for powershell script params
  Ask: Boolean;


// handles progress for the Downlaod Page 
function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;

// just init for pages
procedure CreatePages;
begin
  Ask := True;
  DownloadPage := CreateDownloadPage('Downloading Python... 😀', 'Downloading & Extracting Embedded python 3.8.9.zip 😊', @OnDownloadProgress);
  SettingThingsUp := CreateOutputMarqueeProgressPage('Setting up Python Environment 😁', 'Setting up PIP and site-packages😊');
end;


procedure CloseSetup(CancelMsg: String);
begin 
  MsgBox(CancelMsg, mbCriticalError, MB_OK);
  Ask := False;
  WizardForm.Close();
end;


procedure SetPrefix;
begin
  Prefix := ExpandConstant('-ExecutionPolicy ByPass -File "{app}\helper.ps1" -Mode ');
end;


function PSScript(params: String; AppDir: String): Boolean;
  begin
    if not ShellExec('', 'powershell', params, AppDir, SW_HIDE, ewWaitUntilTerminated, EC) then
    begin
      CloseSetup('Unable to find one of the very important and basic and atomic hwlper file 😭, who deleted that. Detactive is already dead 😭');
    end;
    Result := EC = 0;

    // returns True if executed successfully else False
  end;
  

// runs the internal powershell script "helper.ps1" along with some mode, not meant to be used without
// modifying helper.ps1 if custom modes are send i.e., mode > 4 
// returns False if failed else True
function RunPSScript(mode: Int64; title: String; desc: String): Boolean;
begin
  Result := PSScript(Prefix + IntToStr(mode), ExpandConstant('{app}'))
  SettingThingsUp.setText(title, desc);
end;


// runs the Helper powershell script in Mode 0
// which checks for applications running in the path inside the python so it asks for them to close
// Returns True if not running else False
function CheckRunning(FromUninstaller: Boolean): Boolean;
var 
AppDir: String;

begin

  Result := True;

  if FromUninstaller then
    AppDir := ExpandConstant('{app}') // no semicolon here
  else
    AppDir := WizardDirValue();

  // {app} == WizardDirValue but doesn't fail in beginning wizard case
  if not PSScript(Format('-ExecutionPolicy ByPass -File "%s\helper.ps1" -Mode 0', [AppDir]), AppDir) then 
  begin
   
    if not FromUninstaller then
      CloseSetup('Application is Running in background, check the processes and close them and try again!')
      // raises Null Pointer Exception in case of the Uninstaller
    else
      MsgBox('Rash Application is Running, Please close them and try again!', mbError, MB_OK);

    Result := False;

  end;
end;

function CheckAndDownloadPython(): String;
begin
    Downloaded := DirExists(ExpandConstant('{app}/python'));
    Result := '';

    if not Downloaded then
    begin

      SetPrefix;
      DownloadPage.Clear;
      
      DownloadPage.Add('https://www.python.org/ftp/python/3.8.9/python-3.8.9-embed-amd64.zip', 'python.zip', '');
      DownloadPage.Add('https://bootstrap.pypa.io/get-pip.py', 'get-pip.py', '');

      DownloadPage.Show;

      try
        DownloadPage.Download;
      except 
        Result := AddPeriod(GetExceptionMessage);
      finally
        DownloadPage.Hide;
      end;
    end;
end;


function SetThingsUp(): Boolean;

begin 
  Result := True
  
  if not Downloaded then begin
    SettingThingsUp.Show;
    SettingThingsUp.setText('Extracting Python', 'Setting up python Environment 😗');

    Result := Result and RunPSScript(1, 'Unzipping Python Package', 'Extracing python 3.8.9.zip,...');
    Result := Result and RunPSScript(2, 'Setting PIP', 'Downloading & Executing get-pip.py...');
    Result := Result and RunPSScript(3, 'Saving Site-Packages', 'Isolating This env to this particular applicaiton');
    Result := Result and RunPSScript(4, 'Extracting LIB package', 'Extracing internal .pyc modules to Lib');
    Result := Result and RunPSScript(5, 'Looking for requirements.txt', 'Downloading PIP requirements if any provided...');
      
    SettingThingsUp.Hide;
  end;
end;



// EVENT FUNCTIONS: https://jrsoftware.org/ishelp/topic_scriptevents.htm
procedure InitializeWizard;
begin
    CreatePages;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;

begin
  Result := CheckAndDownloadPython();
end;
                                           
procedure CurStepChanged(CurStep: TSetupStep);

var                          
DontAbort: Boolean;

begin
  DontAbort := True
  
  if CurStep = ssPostInstall then begin
    DontAbort := DontAbort and SetThingsUp();
  end;
end;  

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID <> 1 then begin
  // don't check before evening starting that's BAD 🥲
  CheckRunning(False);
  end;
end;

function InitializeUninstall: Boolean;
begin
  Result := CheckRunning(True);
end;                              

// one needs to copy this event function as it is or modify them as they need
procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  Confirm := Confirm and Ask;
end;
    