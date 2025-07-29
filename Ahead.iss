; By PHMP
#define MyAppName "Notificador Ahead Installer"
#define MyAppVersion "1.0"
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
OutputBaseFilename=ByPHMP
SetupIconFile=C:\Users\pedro.pacheco\Desktop\Ahead\notificador\ahead.ico
SolidCompression=yes
ChangesAssociations=yes
WizardStyle=modern
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
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AheadNotificador"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Check: not IsAdminInstallMode
Root: HKLM; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "AheadNotificador"; ValueData: """{app}\{#MyAppExeName}"""; Flags: uninsdeletevalue; Check: IsAdminInstallMode

[Icons]
Name: "{code:GetProgramsFolder}\Notificador Ahead"; Filename: "{app}\{#MyAppExeName}"
Name: "{userdesktop}\Notificador Ahead"; Filename: "{app}\{#MyAppExeName}"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
var
  CustomUserName: String;

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

procedure InitializeWizard;
begin
  if IsAdminInstallMode then
  begin
    if not InputQuery('Configuração de Usuário',
      'Digite o nome do usuário para os logs:', False, CustomUserName) then
    begin
      MsgBox('É necessário informar um nome de usuário para continuar!', mbError, MB_OK);
      Abort;
    end;
  end
  else
  begin
    CustomUserName := ExpandConstant('{username}');
    InputQuery('Configuração de Usuário',
      'Confirme ou altere o nome do usuário para os logs:', False, CustomUserName);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigFile, LogPath: String;
  ConfigContent: TStringList;
  i: Integer;
  FoundLogKey, FoundUserKey: Boolean;
begin
  if CurStep = ssPostInstall then
  begin
    ConfigFile := ExpandConstant('{app}\NotificadorAhead.exe.config');

    if FileExists(ConfigFile) then
    begin
      ConfigContent := TStringList.Create;
      try
        ConfigContent.LoadFromFile(ConfigFile);

        if IsAdminInstallMode then
          LogPath := 'C:\ProgramData\Ahead\Notificador\logs'
        else
          LogPath := ExpandConstant('{localappdata}\Ahead\Notificador\logs');

        ForceDirectories(LogPath);

        FoundLogKey := False;
        FoundUserKey := False;

        for i := 0 to ConfigContent.Count - 1 do
        begin
          if Pos('LogDeErroCaminhoDoArquivo', ConfigContent[i]) > 0 then
          begin
            ConfigContent[i] := '    <add key="LogDeErroCaminhoDoArquivo" value="' + LogPath + '" />';
            FoundLogKey := True;
          end
          else if Pos('Usuario', ConfigContent[i]) > 0 then
          begin
            ConfigContent[i] := '    <add key="Usuario" value="' + CustomUserName + '" />';
            FoundUserKey := True;
          end;
        end;

        if not FoundLogKey then
          ConfigContent.Insert(ConfigContent.Count - 1, '    <add key="LogDeErroCaminhoDoArquivo" value="' + LogPath + '" />');

        if not FoundUserKey then
          ConfigContent.Insert(ConfigContent.Count - 1, '    <add key="Usuario" value="' + CustomUserName + '" />');

        ConfigContent.SaveToFile(ConfigFile);
      finally
        ConfigContent.Free;
      end;
    end;
  end;
end;
