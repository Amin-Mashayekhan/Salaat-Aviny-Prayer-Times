; Inno Setup script for Salaat | Aviny Prayer Times (per-user install, no administrator rights).
;
; Build first:   flutter build windows --release        (inside app/)
; Then compile:  iscc /DAppVersion=1.0.0 app\windows\installer\salaat.iss
; Output:        app\build\installer\Salaat-Setup.exe
;
; The release workflow (.github/workflows/release.yml) does both steps and passes the
; version of the tag. Without /DAppVersion the default below is used.
;
; The data folder below must match Runner.rc (CompanyName\ProductName), because
; path_provider stores application support data in %APPDATA%\<Company>\<Product>.

#define AppName "Salaat"
; Shown in the installer and in Add/Remove Programs. It contains a pipe, so it is
; never used for a file, folder or shortcut name (AppName is used for those).
#define AppTitle "Salaat | Aviny Prayer Times"
#define AppExe "salaat.exe"
#ifndef AppVersion
#define AppVersion "1.0.0"
#endif
#define AppPublisher "Salaat"
#define AppDataSub "Salaat\Salaat"
#define BuildDir "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{6B1F2C0E-7D5A-4F36-9A3B-2C1E8D4F7A90}
AppName={#AppTitle}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL=https://github.com/Amin-Mashayekhan/Salaat-Aviny-Prayer-Times
AppSupportURL=https://github.com/Amin-Mashayekhan/Salaat-Aviny-Prayer-Times/issues
AppUpdatesURL=https://amin-mashayekhan.github.io/Salaat-Aviny-Prayer-Times/
SetupIconFile=..\runner\resources\app_icon.ico
DefaultDirName={localappdata}\Programs\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\..\build\installer
OutputBaseFilename=Salaat-Setup
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
; The Persian wizard texts are not part of every Inno Setup release.
#if FileExists(CompilerPath + "Languages\Farsi.isl")
Name: "persian"; MessagesFile: "compiler:Languages\Farsi.isl"
#endif

[Tasks]
Name: "autostart"; Description: "Start {#AppTitle} with Windows"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{userprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"

[Registry]
; The app itself manages this value through its settings screen; the installer
; only offers it as an initial choice and always removes it on uninstall.
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "{#AppName}"; ValueData: """{app}\{#AppExe}"" --minimized"; Tasks: autostart; Flags: uninsdeletevalue

[Run]
Filename: "{app}\{#AppExe}"; Description: "Launch {#AppTitle}"; Flags: nowait postinstall skipifsilent

[UninstallRun]
; Remove every wake-up task the app registered, then the autostart entry.
Filename: "powershell.exe"; Parameters: "-NoProfile -NonInteractive -Command ""Get-ScheduledTask -TaskPath '\Salaat\' -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false"""; Flags: runhidden; RunOnceId: "RemoveWakeTasks"
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
      if MsgBox('Keep your Salaat settings and saved locations?' + #13#10 +
                '(They are stored in ' + DataDir + ')',
                mbConfirmation, MB_YESNO) = IDNO then
        DelTree(DataDir, True, True, True);
    end;
  end;
end;
