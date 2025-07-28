; Script Inno Setup atualizado por PHMP kkkkkkkkkk

#define MyAppName "Ahead Notificador"
#define MyAppVersion "1.0"
#define MyAppPublisher "Esse é da Ou kkkkkkkkkk By PHMP"
#define MyAppURL "https://www.ou.com.br/"
#define MyAppExeName "NotificadorAhead.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".myp"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
AppId={{10DD487A-9245-4A69-8B8B-726D59D14CBF}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={code:GetInstallDir}
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputBaseFilename=ByPHMP
SetupIconFile=C:\Users\pedro.pacheco\Desktop\ahead.ico
SolidCompression=yes
ChangesAssociations=yes
WizardStyle=modern
PrivilegesRequiredOverridesAllowed=dialog
AllowNoIcons=yes

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "C:\Program Files\Ahead\notificador\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Comum.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Erro.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Modelo.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Negocio.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\NotificadorAhead.exe.config"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Oracle.ManagedDataAccess.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Persistencia.BD.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Persistencia.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Program Files\Ahead\notificador\Persistencia.Sessao.dll"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AheadNotificador"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Check: not IsAdminInstallMode

Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AheadNotificador"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Check: IsAdminInstallMode

[Icons]
Name: "{code:GetProgramsFolder}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{userdesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// Decide o local de instalação baseado na escolha de privilégio
function GetInstallDir(Default: String): String;
begin
  if IsAdminInstallMode then
    Result := ExpandConstant('{autopf}\AheadNotificador')
  else
    Result := ExpandConstant('{localappdata}\AheadNotificador');
end;

// Decide onde colocar os atalhos (por usuário ou todos)
function GetProgramsFolder(Default: String): String;
begin
  if IsAdminInstallMode then
    Result := ExpandConstant('{autoprograms}')
  else
    Result := ExpandConstant('{userprograms}');
end;

// Decide qual raiz do registro usar para iniciar com o Windows
function GetRunKeyRoot(Default: Integer): Integer;
begin
  if IsAdminInstallMode then
    Result := HKEY_LOCAL_MACHINE
  else
    Result := HKEY_CURRENT_USER;
end;
