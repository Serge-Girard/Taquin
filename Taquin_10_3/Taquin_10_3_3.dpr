program Taquin_10_3_3;



uses
  Vcl.Forms,
  UTaquin in 'UTaquin.pas' {FTaquin},
  PieceTaquin in 'PieceTaquin.pas' {FPiece: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFTaquin, FTaquin);
  Application.Run;
end.
