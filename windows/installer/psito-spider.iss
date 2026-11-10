; O instalador do Psito Spider no Windows, gerado no CI com o Inno Setup.
;
;   ISCC /DAppVersion=1.2.3 windows\installer\psito-spider.iss
;
; Instala só para quem está usando, sem pedir administrador, e quem quiser pode
; instalar para todos no diálogo.
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define AppName "Psito Spider"
#define AppExe "psito_spider.exe"
#define AppModelId "Psito.Spider"
#define Release "..\..\build\windows\x64\runner\Release"

[Setup]
AppId={{ED4B6739-316A-4261-81C8-1774E10EF8D7}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Psito Spider contributors
AppPublisherURL=https://francisceioseph.github.io/psito-spider/
AppSupportURL=https://github.com/francisceioseph/psito-spider/issues
AppUpdatesURL=https://github.com/francisceioseph/psito-spider/releases
VersionInfoVersion={#AppVersion}
DefaultDirName={autopf}\{#AppName}
DisableProgramGroupPage=yes
DisableDirPage=auto
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
OutputDir=Output
OutputBaseFilename=psito-spider-windows-x64-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=force
RestartApplications=no

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "pt"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#Release}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\LICENSE"; DestDir: "{app}\licenses"; DestName: "LICENSE.txt"; Flags: ignoreversion
Source: "..\..\THIRD_PARTY_LICENSES.md"; DestDir: "{app}\licenses"; Flags: ignoreversion
Source: "..\..\assets\LICENSE.md"; DestDir: "{app}\licenses"; DestName: "ART-LICENSE.md"; Flags: ignoreversion
Source: "..\..\assets\fonts\OFL.txt"; DestDir: "{app}\licenses"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"; AppUserModelID: "{#AppModelId}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; AppUserModelID: "{#AppModelId}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent

; O desinstalador não fecha o jogo sozinho, e o arquivo aberto ficaria para trás
[UninstallRun]
Filename: "{sys}\taskkill.exe"; Parameters: "/f /im {#AppExe}"; Flags: runhidden; RunOnceId: "StopGame"
