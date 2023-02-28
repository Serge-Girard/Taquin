program TaquinFMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  UTaquinFMX in 'UTaquinFMX.pas' {Form17},
  FTaquinFMX in 'FTaquinFMX.pas' {FPiece: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm17, Form17);
  Application.Run;
  {$IFDEF MSWINDOWS}
   ReportMemoryLeaksOnShutdown:=Debughook<>0;
  {$ENDIF}
end.
