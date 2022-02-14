#define Name="RashSolo"

[Setup]
AppName="{#Name}"
AppVersion="0.1.0"
AppPublisher="RahulARanger"
AppPublisherURL="https://github.com/RahulARanger"
AppSupportURL="https://github.com/RahulARanger/RashSetup"
AppContact="https://github.com/RahulARanger/RashSetup"
ChangesAssociations=yes
ChangesEnvironment=yes

; Show Selected Directory
AlwaysShowDirOnReadyPage=yes
AppComments="This Instsaller downloads an Application but for it's functioning it requires python Interpreter for which this installer aims to provide it"

; WHERE TO SAVE AFTER INSTALLATION
DefaultDirName="{autopf}\{#Name}"


OutputDir="Test"
OutputBaseFilename="RashSolo"


; Compression Things
Compression=lzma
SolidCompression=yes

; Uses Windows Vista style
WizardStyle=modern
WindowResizable="no"

; RUNS AND SAVES IN 64 bit dir
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

DisableWelcomePage=no
; This is the first page up until now, it just shows the LICENSE and makes sure user accepts it
LicenseFile="../LICENSE"

SetupMutex="RashSoloMUTEX"


[Files]
Source: "setup.ps1"; DestDir: "{app}"; flags: deleteafterinstall; 
Source: "{tmp}\python.zip"; DestDir: "{app}"; flags: external skipifsourcedoesntexist;
Source: "{tmp}\get-pip.py"; DestDir: "{app}"; flags: external skipifsourcedoesntexist;
Source: "helper.ps1"; DestDir: "{app}";

[UninstallDelete]
Type: filesandordirs; Name: "{app}\python"
Type: files; Name: "{app}\python.zip"
Type: files; Name: "{app}\get-pip.py"
Type: files; Name: "{app}\helper.ps1"


[Code]

// This is where we actually initalize pages 
// for now we need a single extra for ProgressBar 
// In that Page, we downlaod Python and set some things
// you can replicate/ replace this to download even more files    

var
  DownloadPage: TDownloadWizardPage; 
  MiscProgress: TOutputProgressWizardPage;
  Downloaded: Boolean;
  EC: Integer;


function OnDownloadProgress(const Url, FileName: String; const Progress, ProgressMax: Int64): Boolean;
begin
  if Progress = ProgressMax then
    Log(Format('Successfully downloaded file to {tmp}: %s', [FileName]));
  Result := True;
end;


// runs the Helper powershell script in Mode 0
// which checks for applications running in the path inside the python so it asks for them to close
// Returns True if not running else False
function CheckRunning(): Boolean;
var
ErrorCode: Integer;

begin
  Result := True;
  if not ShellExec('', 'powershell', ExpandConstant('-ExecutionPolicy ByPass -File "{app}\helper.ps1" -Mode 0'), ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ErrorCode) then begin
      Result := False;
    end;
end;


procedure InitializeWizard;
begin
    DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), @OnDownloadProgress);
    MiscProgress := CreateOutputProgressPage(SetupMessage(msgWizardPreparing), 'Extracting Python Zip and preparing PIP')
end;


function PrepareToInstall(var NeedsRestart: Boolean): String;

begin
  Result := '';
  Downloaded := DirExists(ExpandConstant('{app}/python'));

  if Downloaded then 
      if CheckRunning() then
        begin
          Result := '';
        end     // not for using else make sure not to have ;, this thing killed lot of my time
        // and brain cells
      else 
        Result := 'Internal Application is Running, Close them and try again!';

  if not Downloaded then 
    begin
  
      Downloaded := True;
      DownloadPage.Clear;
      DownloadPage.Add('https://www.python.org/ftp/python/3.8.9/python-3.8.9-embed-amd64.zip', 'python.zip', '');
      DownloadPage.Add('https://bootstrap.pypa.io/get-pip.py', 'get-pip.py', '');
      DownloadPage.Show;

      try
        DownloadPage.Download;
      except
        Result := AddPeriod(GetExceptionMessage);
        SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
      finally
        DownloadPage.Hide;
      end;
     
    end;

end;
                                           
procedure CurStepChanged(CurStep: TSetupStep);

  var
  
  Done : Boolean;
  ErrorCode: Integer;
  Mode: Integer;

  begin

    if CurStep = ssPostInstall then 
      begin

        
        MiscProgress.Show;
        MiscProgress.setText('Downloading Python', 'Downloads and Extracts Python Zip and then also sets up PIP!');
        MiscProgress.setProgress(0, 100);
        
        if Downloaded then 
          // i know we can use loop but still i am not that good in pascal.
          
          MiscProgress.setProgress(25, 100);
          MiscProgress.setText('Unzipping python zip', ExpandConstant('{app}/python.zip'));
          ShellExec('', 'powershell', ExpandConstant('-ExecutionPolicy Bypass -File "{app}/setup.ps1" -mode 0'), ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ErrorCode);
          Log(SysErrorMessage(ErrorCode));
          
          MiscProgress.setProgress(50, 100);
          MiscProgress.setText('Setting PIP', ExpandConstant('{app}/get-pip.py'));
          ShellExec('', 'powershell', ExpandConstant('-ExecutionPolicy Bypass -File "{app}/setup.ps1" -mode 1'), ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ErrorCode);
          
          MiscProgress.setProgress(75, 100);
          MiscProgress.setText('Saving SitePackages', ExpandConstant('{app}/python'));
          ShellExec('', 'powershell', ExpandConstant('-ExecutionPolicy Bypass -File "{app}/setup.ps1" -mode 2'), ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ErrorCode);
          
          
          MiscProgress.setText('Final Touch', ExpandConstant('{app}/python'));
          ShellExec('', 'powershell', ExpandConstant('-ExecutionPolicy Bypass -File "{app}/setup.ps1" -mode 3'), ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ErrorCode);
          MiscProgress.setProgress(100, 100);

        MiscProgress.hide;

      end;

  end;  


function InitializeUninstall: Boolean;
begin
  Result := CheckRunning();
end;                              
  