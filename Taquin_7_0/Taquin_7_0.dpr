program Taquin_7_0;

{$R *.dres}

uses
  Forms,
  UTaquin7_0 in 'UTaquin7_0.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
