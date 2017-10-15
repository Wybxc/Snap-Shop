program PtrScreen;

uses
  Forms,
  Main in 'Main.pas' {SettingsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.ShowMainForm := False;
  Application.CreateForm(TSettingsForm, SettingsForm);
  Application.Run;
end.

