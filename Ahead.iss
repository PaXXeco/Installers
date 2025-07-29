; By PHMP 

#define MyAppName "Notificador Ahead - Installer"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Notificador Ahead Installer By PHMP"
#define MyAppURL "https://github.com/PaXXeco"
#define MyAppExeName "NotificadorAhead.exe"
#define WorkFolderTemp "C:\Temp\Workfolder\Ahead\notificador"

[Setup]
AppId={{10DD487A-9245-4A69-8B8B-726D59D14CBF}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ArchitecturesInstallIn64BitMode=x64compatible
DefaultDirName={code:GetInstallDir}
DefaultGroupName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
OutputBaseFilename=InstallerByPHMP
SetupIconFile={#WorkFolderTemp}\ahead.ico
SolidCompression=yes
ChangesAssociations=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
AllowNoIcons=yes

[Languages]
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Files]
Source: "{#WorkFolderTemp}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Comum.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Erro.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Modelo.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Negocio.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\NotificadorAhead.exe.config"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Oracle.ManagedDataAccess.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Persistencia.BD.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Persistencia.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#WorkFolderTemp}\Persistencia.Sessao.dll"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
Name: "{app}\logs"

[Registry]
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
  AdvancedConfigPage: TInputQueryWizardPage;
  CustomUserName: String;
  ConfigPage: TOutputProgressWizardPage;
  CancelConfig: Boolean;

  // Configurações Avançadas
  DBName, DBProvider, CustomDataSource, CustomPort, CustomBase, CustomUserId, CustomPassword: String;
  TempoIniciarExecucao, LinkWeb, ClientSettingsProvider: String;

// 2 Funções utilitárias
function IsAdminInstallMode: Boolean;
begin
  Result := IsAdmin;
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
  // Página para usuário
  UserPage := CreateInputQueryPage(wpSelectDir,
    'Configuração de Usuário',
    'Defina o usuário',
    'Se a instalação for para todos os usuários, informe o nome do usuário. ' +
    'Se for apenas para você, o nome padrão será usado, mas pode ser alterado.');
  UserPage.Add('Nome do usuário:', False);
  UserPage.Values[0] := ExpandConstant('{username}');

  // Página de configurações avançadas
  AdvancedConfigPage := CreateInputQueryPage(UserPage.ID,
    'Configurações Avançadas',
    'Configurações opcionais de conexão e aplicativo',
    'Se preferir, altere as configurações abaixo. Caso contrário, os valores padrão serão aplicados.');

  // Configurações de banco
  AdvancedConfigPage.Add('Nome da conexão (DBName):', False);
  AdvancedConfigPage.Add('Provider (DBProvider):', False);
  AdvancedConfigPage.Add('Data Source:', False);
  AdvancedConfigPage.Add('Porta:', False);
  AdvancedConfigPage.Add('Base:', False);
  AdvancedConfigPage.Add('User Id:', False);
  AdvancedConfigPage.Add('Password:', True);

  // Configurações do aplicativo
  AdvancedConfigPage.Add('Tempo para iniciar (hh:mm:ss):', False);
  AdvancedConfigPage.Add('Link Web:', False);
  AdvancedConfigPage.Add('ClientSettingsProvider:', False);

  // Valores padrão
  AdvancedConfigPage.Values[0] := 'GoAheadBD';
  AdvancedConfigPage.Values[1] := 'Oracle.DataAccess.Client';
  AdvancedConfigPage.Values[2] := '192.168.0.124';
  AdvancedConfigPage.Values[3] := '1522';
  AdvancedConfigPage.Values[4] := 'prod.ou.local';
  AdvancedConfigPage.Values[5] := 'AHEAD';
  AdvancedConfigPage.Values[6] := 'AHEAD';
  AdvancedConfigPage.Values[7] := '00:01:00';
  AdvancedConfigPage.Values[8] := 'www.google.com.br';
  AdvancedConfigPage.Values[9] := '';

  // Inicializa página de progresso
  ConfigPage := CreateOutputProgressPage('Atualizando variáveis do arquivo de configuração', 'Aguarde enquanto as alterações são aplicadas.');
  CancelConfig := False;
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

  if CurPageID = AdvancedConfigPage.ID then
  begin
    DBName := AdvancedConfigPage.Values[0];
    DBProvider := AdvancedConfigPage.Values[1];
    CustomDataSource := AdvancedConfigPage.Values[2];
    CustomPort := AdvancedConfigPage.Values[3];
    CustomBase := AdvancedConfigPage.Values[4];
    CustomUserId := AdvancedConfigPage.Values[5];
    CustomPassword := AdvancedConfigPage.Values[6];
    TempoIniciarExecucao := AdvancedConfigPage.Values[7];
    LinkWeb := AdvancedConfigPage.Values[8];
    ClientSettingsProvider := AdvancedConfigPage.Values[9];
  end;
end;

// 5 Cancelamento
procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if CurPageID = ConfigPage.ID then
  begin
    CancelConfig := True;
    Confirm := False;
  end;
end;

// 6 Modificações pós-instalação
procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigFile, ConfigText: String;
  ConfigContent: TStringList;
  I: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    ConfigFile := ExpandConstant('{app}\NotificadorAhead.exe.config');

    ConfigPage.Show;
    ConfigPage.SetProgress(0, 100);

    ConfigContent := TStringList.Create;
    ConfigContent.LoadFromFile(ConfigFile);
    ConfigText := ConfigContent.Text;

    for I := 1 to 100 do
    begin
      if CancelConfig then
      begin
        MsgBox('Configuração cancelada pelo usuário.', mbError, MB_OK);
        ConfigContent.Free;
        ConfigPage.Hide;
        Exit;
      end;

      Sleep(20);
      ConfigPage.SetProgress(I, 100);
      ConfigPage.SetText('Aplicando alterações... ' + IntToStr(I) + '%', '');

      if I = 10 then
      begin
        StringChangeEx(ConfigText, '<add key="LogDeErroCaminhoDoArquivo" value=',
          '<add key="LogDeErroCaminhoDoArquivo" value="' + ExpandConstant('{app}\logs') + '" />', True);
      end;

      if I = 30 then
      begin
        StringChangeEx(ConfigText, '<add name="GoAheadBD" providerName="Oracle.DataAccess.Client" connectionString="',
          '<add name="' + DBName + '" providerName="' + DBProvider +
          '" connectionString="Data Source=' + CustomDataSource + ':' + CustomPort +
          '/' + CustomBase + ';User Id=' + CustomUserId + ';Password=' + CustomPassword + ';"', True);
      end;

      if I = 50 then
      begin
        StringChangeEx(ConfigText, '<add key="Usuario" value=',
          '<add key="Usuario" value="' + CustomUserName + '" />', True);
      end;

      if I = 70 then
      begin
        StringChangeEx(ConfigText, '<add key="TempoIniciarExecucao" value=',
          '<add key="TempoIniciarExecucao" value="' + TempoIniciarExecucao + '" />', True);

        StringChangeEx(ConfigText, '<add key="LinkWeb" value="',
          '<add key="LinkWeb" value="' + LinkWeb + '" />', True);

        StringChangeEx(ConfigText, '<add key="ClientSettingsProvider.ServiceUri" value="',
          '<add key="ClientSettingsProvider.ServiceUri" value="' + ClientSettingsProvider + '" />', True);
      end;
    end;

    ConfigContent.Text := ConfigText;
    ConfigContent.SaveToFile(ConfigFile);
    ConfigContent.Free;

    ConfigPage.Hide;
    MsgBox('Configuração concluída.', mbInformation, MB_OK);
  end;
end;
