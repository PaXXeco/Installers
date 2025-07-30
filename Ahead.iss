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
var
  RollbackNeeded: Boolean;

type
  TArrayOfString = array of String;

// ==========================
// Função auxiliar Split
// ==========================
function Split(const S, Delimiter: String): TArrayOfString;
var
  P: Integer;
  Temp: String;
begin
  SetArrayLength(Result, 0);
  Temp := S;

  while True do
  begin
    P := Pos(Delimiter, Temp);
    if P = 0 then
    begin
      SetArrayLength(Result, GetArrayLength(Result) + 1);
      Result[GetArrayLength(Result) - 1] := Temp;
      Break;
    end;
    SetArrayLength(Result, GetArrayLength(Result) + 1);
    Result[GetArrayLength(Result) - 1] := Copy(Temp, 1, P - 1);
    Delete(Temp, 1, P);
  end;
end;

// ==========================
// Validação de hora hh:mm:ss
// ==========================
function IsValidTimeFormat(TimeStr: String): Boolean;
var
  Parts: TArrayOfString;
  Hour, Min, Sec: Integer;
begin
  Result := False;
  Parts := Split(TimeStr, ':');
  if GetArrayLength(Parts) <> 3 then Exit;

  if not TryStrToInt(Parts[0], Hour) then Exit;
  if not TryStrToInt(Parts[1], Min) then Exit;
  if not TryStrToInt(Parts[2], Sec) then Exit;

  if (Hour < 0) or (Hour > 23) then Exit;
  if (Min < 0) or (Min > 59) then Exit;
  if (Sec < 0) or (Sec > 59) then Exit;

  Result := True;
end;

// ==========================
// Normaliza hh:mm:ss
// ==========================
function NormalizeTimeFormat(TimeStr: String): String;
var
  Parts: TArrayOfString;
begin
  Parts := Split(TimeStr, ':');
  Result := Format('%.2d:%.2d:%.2d',
    [StrToIntDef(Parts[0], 0), StrToIntDef(Parts[1], 0), StrToIntDef(Parts[2], 0)]);
end;

// ==========================
// Validação de campos
// ==========================
function ValidateFields: Boolean;
begin
  Result := True;

  if (Trim(WizardForm.DirEdit.Text) = '') then
  begin
    MsgBox('O diretório de instalação não pode estar vazio.', mbError, MB_OK);
    Result := False;
    Exit;
  end;

  if (Trim(WizardForm.UserInfoPage.Values[0]) = '') then
  begin
    MsgBox('O campo "Servidor" não pode estar vazio.', mbError, MB_OK);
    Result := False;
    Exit;
  end;

  if (Trim(WizardForm.UserInfoPage.Values[1]) = '') then
  begin
    MsgBox('O campo "Banco de Dados" não pode estar vazio.', mbError, MB_OK);
    Result := False;
    Exit;
  end;

  if (Trim(WizardForm.UserInfoPage.Values[2]) = '') and
     (WizardForm.UserInfoPage.Values[2] <> 'ClientSettingsProvider') then
  begin
    MsgBox('O campo não pode estar vazio, exceto o ClientSettingsProvider.', mbError, MB_OK);
    Result := False;
    Exit;
  end;

  if not IsValidTimeFormat(WizardForm.UserInfoPage.Values[3]) then
  begin
    MsgBox('O formato da hora deve ser hh:mm:ss.', mbError, MB_OK);
    Result := False;
    Exit;
  end;
end;

// ==========================
// Antes de instalar
// ==========================
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;

  if CurPageID = wpUserInfo then
  begin
    Result := ValidateFields;
  end;
end;

// ==========================
// Instalação
// ==========================
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
  begin
    try
      // Exemplo de escrita de chave sem sobrescrever
      if not RegValueExists(HKLM, 'Software\MyApp', 'Servidor') then
        RegWriteStringValue(HKLM, 'Software\MyApp', 'Servidor', WizardForm.UserInfoPage.Values[0]);

      if not RegValueExists(HKLM, 'Software\MyApp', 'BancoDados') then
        RegWriteStringValue(HKLM, 'Software\MyApp', 'BancoDados', WizardForm.UserInfoPage.Values[1]);

      if not RegValueExists(HKLM, 'Software\MyApp', 'ClientSettingsProvider') then
        RegWriteStringValue(HKLM, 'Software\MyApp', 'ClientSettingsProvider', WizardForm.UserInfoPage.Values[2]);

      if not RegValueExists(HKLM, 'Software\MyApp', 'Horario') then
        RegWriteStringValue(HKLM, 'Software\MyApp', 'Horario', NormalizeTimeFormat(WizardForm.UserInfoPage.Values[3]));

      WizardForm.ProcessMessages;
    except
      RollbackNeeded := True;
      RaiseException('Erro ao gravar no registro. A instalação será revertida.');
    end;
  end;
end;

// ==========================
// Rollback
// ==========================
procedure DeinitializeSetup;
begin
  if RollbackNeeded then
  begin
    RegDeleteKeyIncludingSubkeys(HKLM, 'Software\MyApp');
  end;
end;
