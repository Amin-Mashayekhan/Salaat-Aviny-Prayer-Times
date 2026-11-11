; Inno Setup 7 script for Owghat (per-user install, no administrator rights).
;
; Build first:   flutter build windows --release        (inside app/)
; Then compile:  iscc app\windows\installer\owghat.iss
; Output:        app\build\installer\Owghat-Setup-<version>.exe
;
; The data folder below must match Runner.rc (CompanyName\ProductName), because
; path_provider stores application support data in %APPDATA%\<Company>\<Product>.

#define AppName "Owghat"
#define AppExe "owghat.exe"
#define AppVersion "1.0.0"
#define AppPublisher "Owghat"
#define AppDataSub "Owghat\Owghat"
#define BuildDir "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{6B1F2C0E-7D5A-4F36-9A3B-2C1E8D4F7A90}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={localappdata}\Programs\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\..\build\installer
OutputBaseFilename=Owghat-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#AppExe}
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "persian"; MessagesFile: "compiler:Languages\Farsi.isl"

[Tasks]
Name: "autostart"; Description: "Start {#AppName} with Windows"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{userprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"

[Registry]
; The app itself manages this value through its settings screen; the installer
; only offers it as an initial choice and always removes it on uninstall.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#AppName}"; ValueData: """{app}\{#AppExe}"" --minimized"; Tasks: autostart; Flags: uninsdeletevalue

[Run]
Filename: "{app}\{#AppExe}"; Description: "Launch {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; Remove every wake-up task the app registered, then the autostart entry.
Filename: "powershell.exe"; Parameters: "-NoProfile -NonInteractive -Command ""Get-ScheduledTask -TaskPath '\Owghat\' -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false"""; Flags: runhidden; RunOnceId: "RemoveWakeTasks"
Filename: "reg.exe"; Parameters: "delete ""HKCU\Software\Microsoft\Windows\CurrentVersion\Run"" /v {#AppName} /f"; Flags: runhidden; RunOnceId: "RemoveAutostart"

[Code]
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DataDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    DataDir := ExpandConstant('{userappdata}\{#AppDataSub}');
    if DirExists(DataDir) then
    begin
      if MsgBox('Keep your Owghat settings and saved locations?' + #13#10 +
                '(They are stored in ' + DataDir + ')',
                mbConfirmation, MB_YESNO) = IDNO then
        DelTree(DataDir, True, True, True);
    end;
  end;
end;
