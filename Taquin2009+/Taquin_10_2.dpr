program Taquin_10_2;

{$R *.dres}

uses
  Vcl.Forms,
  UTaquin10_2 in 'UTaquin10_2.pas' {MainForm},
  PieceTaquin10_2 in 'PieceTaquin10_2.pas' {FPiece: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
