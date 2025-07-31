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
  BackupFile: String;

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

  UserPage := CreateInputQueryPage(wpSelectDir, 'Configuração de Usuário', 'Defina o usuário', 'Informe o nome do usuário para a instalação. Também é possível habilitar configurações avançadas.');
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
var
  i: Integer;
begin
  Result := True;

  if CurPageID = UserPage.ID then
  begin
    if Trim(UserPage.Values[0]) = '' then
    begin
      MsgBox('É obrigatório informar um nome de usuário.', mbError, MB_OK);
      Result := False;
      Exit;
    end;
    CustomUserName := UserPage.Values[0];
    EnableAdvanced := EnableAdvancedCheckBox.Checked;
  end;

  if (CurPageID = ConnectionPage.ID) and EnableAdvanced then
  begin
    for i := 0 to 4 do
    begin
      if Trim(ConnectionPage.Values[i]) = '' then
      begin
        MsgBox('Todos os campos de conexão são obrigatórios.', mbError, MB_OK);
        Result := False;
        Exit;
      end;
    end;
    if StrToIntDef(ConnectionPage.Values[3], -1) < 0 then
    begin
      MsgBox('A porta deve ser um número válido.', mbError, MB_OK);
      Result := False;
      Exit;
    end;
  end;

  if (CurPageID = CredentialsPage.ID) and EnableAdvanced then
  begin
    if Trim(CredentialsPage.Values[0]) = '' then
    begin
      MsgBox('Usuário do banco de dados não pode estar vazio.', mbError, MB_OK);
      Result := False;
      Exit;
    end;
    if Trim(CredentialsPage.Values[1]) = '' then
    begin
      MsgBox('Senha do banco de dados não pode estar vazia!', mbError, MB_OK);
      Result := False;
      Exit;
    end;
  end;

  if (CurPageID = AppConfigPage.ID) and EnableAdvanced then
  begin
    if Trim(AppConfigPage.Values[0]) = '' then
    begin
      MsgBox('Tempo para iniciar não pode estar vazio!', mbError, MB_OK);
      Result := False;
      Exit;
    end;
    if Trim(AppConfigPage.Values[1]) = '' then
    begin
      MsgBox('Link Web não pode estar vazio!', mbError, MB_OK);
      Result := False;
      Exit;
    end;

    DBName := ConnectionPage.Values[0];
    DBProvider := ConnectionPage.Values[1];
    CustomDataSource := ConnectionPage.Values[2];
    CustomPort := ConnectionPage.Values[3];
    CustomBase := ConnectionPage.Values[4];
    CustomUserId := CredentialsPage.Values[0];
    CustomPassword := CredentialsPage.Values[1];
    TempoIniciarExecucao := AppConfigPage.Values[0];
    LinkWeb := AppConfigPage.Values[1];
    ClientSettingsProvider := AppConfigPage.Values[2];
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
  ConfigFile, ConfigText: String;
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
          MsgBox('Configuração cancelada. Restaurando arquivo original...', mbError, MB_OK);
          if FileExists(BackupFile) then
            FileCopy(BackupFile, ConfigFile, True);
          ConfigContent.Free;
          ConfigPage.Hide;
          Exit;
        end;
        
        Sleep(5)
        ConfigPage.SetProgress(I, 100);
        ConfigPage.SetText('Aplicando alterações... ' + IntToStr(I) + '%', '');

        if I = 10 then
          StringChangeEx(ConfigText, '<add key="LogDeErroCaminhoDoArquivo" value=', '<add key="LogDeErroCaminhoDoArquivo" value="' + ExpandConstant('{app}\logs') + '" />', True);

        if I = 30 then
          StringChangeEx(ConfigText, '<add name="GoAheadBD"', '<add name="' + DBName + '" providerName="' + DBProvider +'" connectionString="Data Source=' + CustomDataSource + ':' + CustomPort + '/' + CustomBase + ';User Id=' + CustomUserId + ';Password=' + CustomPassword + ';" />', True);

        if I = 50 then
          StringChangeEx(ConfigText, '<add key="Usuario" value=', '<add key="Usuario" value="' + CustomUserName + '" />', True);

        if I = 70 then
        begin
          StringChangeEx(ConfigText, '<add key="TempoIniciarExecucao" value=', '<add key="TempoIniciarExecucao" value="' + TempoIniciarExecucao + '" />', True);
          StringChangeEx(ConfigText, '<add key="LinkWeb" value=', '<add key="LinkWeb" value="' + LinkWeb + '" />', True);
          StringChangeEx(ConfigText, '<add key="ClientSettingsProvider.ServiceUri" value=', '<add key="ClientSettingsProvider.ServiceUri" value="' + ClientSettingsProvider + '" />', True);
        end;
      end;

      ConfigContent.Text := ConfigText;
      ConfigContent.SaveToFile(ConfigFile);
    finally
      ConfigContent.Free;
    end;

    ConfigPage.Hide;
    MsgBox('Configuração concluí­da!', mbInformation, MB_OK);
  end;
end;

function IsAppRunning: Boolean;
begin
  Result := (FindWindowByClassName('NotificadorAhead') <> 0) or (Exec('tasklist', '/FI "IMAGENAME eq NotificadorAhead.exe"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0));
end;

procedure InitializeUninstallProgressForm();
var
  KeepBackup: Integer;
  BackupFilePath: String;
begin
  while IsAppRunning do
  begin
    if MsgBox('O Notificador Ahead está em execução e precisa ser fechado antes da desinstalação.'#13#10 +
              'Deseja que o instalador feche o aplicativo automaticamente?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      Exec('taskkill', '/IM NotificadorAhead.exe /F', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    end
    else
    begin
      MsgBox('Feche o aplicativo manualmente e clique em OK para continuar.', mbInformation, MB_OK);
    end;
  end;

  BackupFilePath := ExpandConstant('{app}\NotificadorAhead.exe.config.bak');
  if FileExists(BackupFilePath) then
  begin
    KeepBackup := MsgBox('Um arquivo de backup (.bak) foi encontrado.'#13#10 + 'Deseja manter este arquivo após a desinstalação?', mbConfirmation, MB_YESNO);
    if KeepBackup = IDNO then
      DeleteFile(BackupFilePath);
  end;
end;
