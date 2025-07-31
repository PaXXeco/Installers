;By PHMP 
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
var
  UserPage: TInputQueryWizardPage;
  EnableAdvancedCheckBox: TNewCheckBox;
  ConnectionPage: TInputQueryWizardPage;
  CredentialsPage: TInputQueryWizardPage;
  AppConfigPage: TInputQueryWizardPage;
  ConfigPage: TOutputProgressWizardPage;
  CancelConfig: Boolean;  
  DBName, DBProvider, CustomDataSource, CustomPort, CustomBase: String;
  CustomUserId, CustomPassword: String;
  TempoIniciarExecucao, LinkWeb, ClientSettingsProvider: String;
  CustomUserName: String;
  EnableAdvanced: Boolean;
  BackupFile, ConfigFile: String;

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

procedure InitializeWizard;
begin
  DBName := 'GoAheadBD';
  DBProvider := 'Oracle.DataAccess.Client';
  CustomDataSource := '192.168.0.214';
  CustomPort := '1522';
  CustomBase := 'prod.ou.local';
  CustomUserId := 'AHEAD';
  CustomPassword := 'AHEAD';
  TempoIniciarExecucao := '00:01:00';
  LinkWeb := 'www.google.com.br';
  ClientSettingsProvider := '';

  UserPage := CreateInputQueryPage(wpSelectDir, 'Configuração de Usuário', 'Defina o usuário', 'Informe o nome do usuário para a instalação.');
  UserPage.Add('Nome do usuário:', False);
  UserPage.Values[0] := ExpandConstant('{username}');

  EnableAdvancedCheckBox := TNewCheckBox.Create(WizardForm);
  EnableAdvancedCheckBox.Parent := UserPage.Surface;
  EnableAdvancedCheckBox.Caption := 'Avançado';
  EnableAdvancedCheckBox.Top := UserPage.Edits[0].Top + 30;
  EnableAdvancedCheckBox.Left := UserPage.Edits[0].Left;
  EnableAdvancedCheckBox.Checked := False;

  ConnectionPage := CreateInputQueryPage(UserPage.ID, 'Configurações de Conexão', 'Conexão com o banco de dados', 'Altere os parâmetros de conexão se necessário.');
  ConnectionPage.Add('Nome da conexão (DBName):', False);
  ConnectionPage.Add('Provider (DBProvider):', False);
  ConnectionPage.Add('Data Source:', False);
  ConnectionPage.Add('Porta:', False);
  ConnectionPage.Add('Base:', False);
  ConnectionPage.Values[0] := DBName;
  ConnectionPage.Values[1] := DBProvider;
  ConnectionPage.Values[2] := CustomDataSource;
  ConnectionPage.Values[3] := CustomPort;
  ConnectionPage.Values[4] := CustomBase;

  CredentialsPage := CreateInputQueryPage(ConnectionPage.ID, 'Credenciais', 'Acesso ao banco de dados', 'Informe o usuário e senha do banco de dados.');
  CredentialsPage.Add('User Id:', False);
  CredentialsPage.Add('Password:', True);
  CredentialsPage.Values[0] := CustomUserId;
  CredentialsPage.Values[1] := CustomPassword;

  AppConfigPage := CreateInputQueryPage(CredentialsPage.ID, 'Configurações do Aplicativo', 'Configurações adicionais', 'Altere parâmetros do aplicativo, se necessário.');
  AppConfigPage.Add('Tempo para iniciar (hh:mm:ss):', False);
  AppConfigPage.Add('Link Web:', False);
  AppConfigPage.Add('ClientSettingsProvider:', False);
  AppConfigPage.Values[0] := TempoIniciarExecucao;
  AppConfigPage.Values[1] := LinkWeb;
  AppConfigPage.Values[2] := ClientSettingsProvider;

  ConfigPage := CreateOutputProgressPage('Atualizando variáveis do arquivo de configuração', 'Aguarde enquanto as alterações são aplicadas.');
  CancelConfig := False;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if (PageID = ConnectionPage.ID) or (PageID = CredentialsPage.ID) or (PageID = AppConfigPage.ID) then
    Result := not EnableAdvanced
  else
    Result := False;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;

  case CurPageID of
    { Validação por página }
    UserPage.ID:
      begin
        if Trim(UserPage.Values[0]) = '' then
        begin
          MsgBox('É necessário informar um nome de usuário!', mbError, MB_OK);
          Result := False;
        end
        else
        begin
          CustomUserName := UserPage.Values[0];
          EnableAdvanced := EnableAdvancedCheckBox.Checked;
        end;
      end;

    ConnectionPage.ID:
      if EnableAdvanced then
      begin
        if (Trim(ConnectionPage.Values[0]) = '') or
           (Trim(ConnectionPage.Values[1]) = '') or
           (Trim(ConnectionPage.Values[2]) = '') or
           (Trim(ConnectionPage.Values[3]) = '') or
           (Trim(ConnectionPage.Values[4]) = '') then
        begin
          MsgBox('Todos os campos de conexão são obrigatórios!', mbError, MB_OK);
          Result := False;
        end
        else if StrToIntDef(ConnectionPage.Values[3], -1) < 0 then
        begin
          MsgBox('A porta deve ser um número válido!', mbError, MB_OK);
          Result := False;
        end;
      end;

    CredentialsPage.ID:
      if EnableAdvanced then
      begin
        if Trim(CredentialsPage.Values[0]) = '' then
        begin
          MsgBox('Usuário do banco de dados não pode estar vazio!', mbError, MB_OK);
          Result := False;
        end
        else if Trim(CredentialsPage.Values[1]) = '' then
        begin
          MsgBox('Senha do banco de dados não pode estar vazia!', mbError, MB_OK);
          Result := False;
        end;
      end;

    AppConfigPage.ID:
      if EnableAdvanced then
      begin
        if Trim(AppConfigPage.Values[0]) = '' then
        begin
          MsgBox('Tempo para iniciar não pode estar vazio!', mbError, MB_OK);
          Result := False;
        end
        else if Trim(AppConfigPage.Values[1]) = '' then
        begin
          MsgBox('Link Web não pode estar vazio!', mbError, MB_OK);
          Result := False;
        end
        else
        begin
          { Salva valores finais }
          DBName := ConnectionPage.Values[0];
          DBProvider := ConnectionPage.Values[1];
          CustomDataSource := ConnectionPage.Values[2];
          CustomPort := ConnectionPage.Values[3];
          CustomBase := ConnectionPage.Values[4];
          CustomUserId := CredentialsPage.Values[0];
          CustomPassword := CredentialsPage.Values[1];
          TempoIniciarExecucao := AppConfigPage.Values[0];
          LinkWeb := AppConfigPage.Values[1];
          ClientSettingsProvider := AppConfigPage.Values[2]; // pode estar vazio
        end;
      end;
  end;
end;

procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
begin
  if CurPageID = ConfigPage.ID then
  begin
    CancelConfig := True;
    Confirm := False;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigText: String;
  ConfigContent: TStringList;
  I: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    ConfigFile := ExpandConstant('{app}\NotificadorAhead.exe.config');
    BackupFile := ConfigFile + '.bak';

    if FileExists(ConfigFile) then
      FileCopy(ConfigFile, BackupFile, False);

    ConfigPage.Show;
    ConfigPage.SetProgress(0, 100);

    ConfigContent := TStringList.Create;
    try
      ConfigContent.LoadFromFile(ConfigFile);
      ConfigText := ConfigContent.Text;

      for I := 1 to 100 do
      begin
        if CancelConfig then
        begin
          { Rollback }
          if FileExists(BackupFile) then
            FileCopy(BackupFile, ConfigFile, True);

          MsgBox('Configuração cancelada e arquivo restaurado.', mbError, MB_OK);
          ConfigPage.Hide;
          Exit;
        end;

        ConfigPage.SetProgress(I, 100);
        ConfigPage.SetText('Aplicando alterações... ' + IntToStr(I) + '%', '');
        Sleep(5); // apenas para mostrar progresso sem travar

        case I of
          10: StringChangeEx(ConfigText, '<add key="LogDeErroCaminhoDoArquivo" value=',
              '<add key="LogDeErroCaminhoDoArquivo" value="' + ExpandConstant('{app}\logs') + '" />', True);
          30: StringChangeEx(ConfigText, '<add name="GoAheadBD"',
              '<add name="' + DBName + '" providerName="' + DBProvider +
              '" connectionString="Data Source=' + CustomDataSource + ':' + CustomPort + '/' +
              CustomBase + ';User Id=' + CustomUserId + ';Password=' + CustomPassword + ';" />', True);
          50: StringChangeEx(ConfigText, '<add key="Usuario" value=',
              '<add key="Usuario" value="' + CustomUserName + '" />', True);
          70:
            begin
              StringChangeEx(ConfigText, '<add key="TempoIniciarExecucao" value=',
                '<add key="TempoIniciarExecucao" value="' + TempoIniciarExecucao + '" />', True);
              StringChangeEx(ConfigText, '<add key="LinkWeb" value=',
                '<add key="LinkWeb" value="' + LinkWeb + '" />', True);
              StringChangeEx(ConfigText, '<add key="ClientSettingsProvider.ServiceUri" value=',
                '<add key="ClientSettingsProvider.ServiceUri" value="' + ClientSettingsProvider + '" />', True);
            end;
        end;
      end;

      ConfigContent.Text := ConfigText;
      ConfigContent.SaveToFile(ConfigFile);
    finally
      ConfigContent.Free;
    end;

    ConfigPage.Hide;
    MsgBox('Configuração concluída!', mbInformation, MB_OK);
  end;
end;
