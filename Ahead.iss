; By PHMP 

#define MyAppName "Notificador Ahead Installer"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Notificador Ahead, Installer By PHMP"
#define MyAppURL "https://github.com/PaXXeco"
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
OutputBaseFilename=NotificadorAheadInstallerByPHMP
SetupIconFile=C:\Users\pedro.pacheco\Desktop\Ahead\notificador\ahead.ico
SolidCompression=yes
ChangesAssociations=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
AllowNoIcons=yes

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Files]
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Comum.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Erro.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Modelo.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Negocio.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\NotificadorAhead.exe.config"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Oracle.ManagedDataAccess.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Persistencia.BD.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Persistencia.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\pedro.pacheco\Desktop\Ahead\notificador\Persistencia.Sessao.dll"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
; Associação de arquivos híbrida (funciona para admin ou usuário normal)
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

; Inicialização automática dependendo do modo
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AheadNotificador"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Check: not IsAdminInstallMode
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AheadNotificador"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Check: IsAdminInstallMode

[Icons]
Name: "{code:GetProgramsFolder}\Notificador Ahead"; Filename: "{app}\{#MyAppExeName}"
Name: "{userdesktop}\Notificador Ahead"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
// 1 Variáveis globais
var
  UserPage: TInputQueryWizardPage;
  CustomUserName: String;

// 2 Funções utilitárias
function IsAdminInstallMode: Boolean;
begin
  Result := IsAdminLoggedOn;
end;

function GetInstallDir(Default: String): String;
begin
  if IsAdminInstallMode then
    Result := ExpandConstant('{autopf}\Ahead\Notificador')
  else
    Result := ExpandConstant('{localappdata}\Ahead\Notificador');
end;

function GetProgramsFolder(Default: String): String;
begin
  if IsAdminInstallMode then
    Result := ExpandConstant('{autoprograms}')
  else
    Result := ExpandConstant('{userprograms}');
end;

// 3 Inicialização do assistente
procedure InitializeWizard;
begin
  UserPage := CreateInputQueryPage(wpSelectDir,
    'Configuração de Usuário',
    'Defina o usuário',
    'Se a instalação for para todos os usuários, informe o nome do usuário. ' +
    'Se for apenas para você, o nome padrão será usado, mas pode ser alterado.');

  UserPage.Add('Nome do usuário:', False);
  UserPage.Values[0] := ExpandConstant('{username}');
end;

// 4 Validação da página
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = UserPage.ID then
  begin
    if Trim(UserPage.Values[0]) = '' then
    begin
      MsgBox('É necessário informar um nome de usuário para continuar!', mbError, MB_OK);
      Result := False;
    end
    else
      CustomUserName := UserPage.Values[0];
  end;
end;

// 5 Modificações pós-instalação
procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigFile, LogPath, ConfigText: String;
  ConfigContent: TStringList;
begin
  if CurStep = ssPostInstall then
  begin
    ConfigFile := ExpandConstant('{app}\NotificadorAhead.exe.config');

    if IsAdminInstallMode then
      LogPath := ExpandConstant('{commonappdata}\Ahead\Notificador\logs')
    else
      LogPath := ExpandConstant('{localappdata}\Ahead\Notificador\logs');

    ForceDirectories(LogPath);

    ConfigContent := TStringList.Create;
    try
      ConfigContent.LoadFromFile(ConfigFile);
      ConfigText := ConfigContent.Text;

      StringChangeEx(ConfigText, '<add key="LogDeErroCaminhoDoArquivo" value=', '<add key="LogDeErroCaminhoDoArquivo" value="' + LogPath + '"', True);
      StringChangeEx(ConfigText, '<add key="Usuario" value=', '<add key="Usuario" value="' + CustomUserName + '"', True);

      ConfigContent.Text := ConfigText;
      ConfigContent.SaveToFile(ConfigFile);
    finally
      ConfigContent.Free;
    end;
  end;
end;
