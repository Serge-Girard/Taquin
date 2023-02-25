unit UTaquin10_2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.ImageList,
  Vcl.Graphics, Vcl.Imaging.pngimage,Vcl.Imaging.jpeg,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TMainForm = class(TForm)
    ScrollBox1: TScrollBox;
    Image1: TImage;
    SpinEdit1: TSpinEdit;
    Melanger: TButton;
    RadioGroup1: TRadioGroup;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure MelangerClick(Sender: TObject);
  private
    { Déclarations privées }
    nbrMorceaux: word;
    frameSize: Integer;
    Morceaux: TDictionary<Integer, Integer>;
    procedure SplitImage;
    procedure Melange;
    procedure DrawScrollBox;
    function CanMove(morceau : Word) : Boolean;
    Procedure MoveMorceau(morceau : word);
  public
    { Déclarations publiques }
    procedure Move(Sender : TObject);
  end;

var
  MainForm: TMainForm;
  ressources : TStringList;
implementation

uses
  PieceTaquin10_2;

{$R *.dfm}

function EnumRCDataProc(hModule: hModule; lpszType, lpszName: PChar;
  lParam: NativeInt): BOOL; stdcall;
begin
  if String(lpszName).Contains('IMAGE') then
    TStrings(lParam).Add(lpszName);
  Result := True;
end;

function TMainForm.CanMove(morceau: Word): Boolean;
var l,c,lc : word;
    v : integer;
// vérification mouvement
begin
result:=false;
lc:=Trunc(sqrt(nbrMorceaux));
c:=morceau mod lc;
l:=(morceau div lc);
if ((l-1)>-1) AND (morceaux.Items[(l-1)*lc+c]=-1) then exit(true);
if (((l+1)<lc)) AND (morceaux.Items[(l+1)*lc+c]=-1) then exit(true);
if (((c-1)>-1)) AND (morceaux.Items[(l*lc)+(c-1)]=-1) then exit(true);
if (((c+1)<lc)) AND (morceaux.Items[(l*lc)+(c+1)]=-1) then exit(true);
end;

procedure TMainForm.DrawScrollBox;
var
  i, n: Integer;
  p: TFPiece;
  ncl: Integer;
  pl,ph : integer;
begin
  ncl := Trunc(Sqrt(nbrMorceaux));
  ScrollBox1.Update;
  for i :=  ScrollBox1.ControlCount - 1 downto 0 do
    ScrollBox1.Controls[i].Free;
  pl:=0; ph:=0;
  for i := 0 to nbrmorceaux - 1 do
  begin
    p := TFPiece.Create(Self);
    p.Width := ImageList1.Width;
    p.Height := ImageList1.Height;
    p.Name := 'P' + (i + 1).ToString;
    P.ImagePiece.Tag:=i;
    p.ImagePiece.OnClick:=Move;
    n := Morceaux.Items[i];
    if n >= 0 then
      ImageList1.GetBitmap(n, p.ImagePiece.Picture.Bitmap);
    p.Parent := ScrollBox1;
    p.Left := pl;
    p.Top := ph;
    inc(pl,p.Width);
    if (pl div p.width)>=ncl then
      begin
        pl:=0;
        inc(ph,imagelist1.Height);
      end;
  end;
  ScrollBox1.Invalidate;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var ExecutableHandle: HMODULE;
    aStream : TMemoryStream;
    aRes : TResourceStream;
begin
  nbrMorceaux := 16;
  SpinEdit1.Value:=0;
  Morceaux := TDictionary<Integer, Integer>.Create;
  ExecutableHandle := LoadLibraryEx(PChar(Application.ExeName), 0, LOAD_LIBRARY_AS_DATAFILE);
   try
     EnumResourceNames(ExecutableHandle, RT_RCDATA, @EnumRCDataProc, NativeInt(Ressources));
   finally
     FreeLibrary(ExecutableHandle);
   end;
   SpinEdit1.MaxValue:=ressources.Count-1;
   ares:=TResourceStream.Create(hinstance,ressources[SpinEdit1.Value],RT_RCDATA);
   aStream:=TMemoryStream.Create;
   try
   aRes.SaveToStream(aStream);
   aStream.Position:=0;
   Image1.Picture.LoadFromStream(aStream);
   finally
     aRes.Free;
     aStream.Free;
   end;
 SplitImage;
 DrawScrollBox;
end;

procedure TMainForm.Melange;
// Nouveau mélange de pièce
var
  i, p: Integer;
  numeropieces: TList<Integer>;
begin
  Morceaux.Clear;
  numeropieces := TList<Integer>.Create;
  try
    for i := -1 to nbrMorceaux - 2 do
      numeropieces.Add(i);
    randomize;
    for i := 0 to nbrMorceaux - 1 do
    begin
      p := Random(numeropieces.Count);
      Morceaux.Add(i, numeropieces[p]);
      numeropieces.Delete(p);
    end;
  finally
    numeropieces.Free;
  end;
  DrawScrollBox;
end;

procedure TMainForm.MelangerClick(Sender: TObject);
begin
Melange;
end;

procedure TMainForm.Move(Sender: TObject);
var Piece : Integer;
begin
Piece:=TImage(Sender).Tag;
if CanMove(Piece) then MoveMorceau(Piece);
end;

procedure TMainForm.MoveMorceau(morceau: word);
var l,c : word;
    mt : word;
    pl : word;
begin
pl:=Trunc(Sqrt(nbrMorceaux));
c:=morceau mod pl;
l:=(morceau div pl);
if ((l-1)>-1) AND (morceaux.Items[(l-1)*pl+c]=-1) then mt:=(l-1)*pl+c;
if (((l+1)<pl)) AND (morceaux.Items[(l+1)*pl+c]=-1) then mt:=(l+1)*pl+c;
if (((c-1)>-1)) AND (morceaux.Items[(l*pl)+(c-1)]=-1) then mt:=(l*pl)+(c-1);
if (((c+1)<pl)) AND (morceaux.Items[(l*pl)+(c+1)]=-1) then mt:=(l*pl)+(c+1);
Morceaux.Items[mt]:=morceaux.Items[morceau];
morceaux.Items[morceau]:=-1;
DrawScrollBox;
end;

procedure TMainForm.RadioGroup1Click(Sender: TObject);
begin
  case RadioGroup1.ItemIndex of
   0 : nbrMorceaux:=3*3;
   1 : nbrMorceaux:=4*4;
   2 : nbrMorceaux:=5*5;
   3 : nbrMorceaux:=6*6;
  end;
  SplitImage;
end;

procedure TMainForm.SpinEdit1Change(Sender: TObject);
var aRes : TResourceStream;
    aStream : TMemoryStream;
begin
   ares:=TResourceStream.Create(hinstance,ressources[SpinEdit1.Value],RT_RCDATA);
   aStream:=TMemoryStream.Create;
   try
   aRes.SaveToStream(aStream);
   aStream.Position:=0;
   Image1.Picture.LoadFromStream(aStream);
   finally
     aRes.Free;
     aStream.Free;
   end;
  SplitImage;
end;

procedure TMainForm.SplitImage;
var
  cl: word;
  ares : TResourceStream;
  aStream : TMemoryStream;
  aPicture : TImage;
  pBitmap,sBitmap: TBitmap;
  c: Integer;
  l: Integer;
begin
  cl := Trunc(Sqrt(nbrMorceaux));

  // effacer  le contenu de ImageList1
  for c := ImageList1.Count - 1 downto 0 do
    ImageList1.Delete(c);
  ImageList1.Height := 400 div cl; // 256 div cl;
  ImageList1.Width := 400 div cl; // 256 div cl;


  // découper l'image choisie
  aPicture:=TImage.Create(nil);
  try
    aPicture.Width:=400;
    aPicture.Height:=400;
    aPicture.Stretch:=True;
    ares:=TResourceStream.Create(hinstance,ressources[SpinEdit1.Value],RT_RCDATA);
    aStream:=TMemoryStream.Create;
     try
      aRes.SaveToStream(aStream);
      aStream.Position:=0;
      aPicture.Picture.LoadFromStream(aStream);
     finally
       aStream.Free;
       aRes.Free;
     end;
    sBitmap:=TBitmap.Create;
    sBitmap.Assign(aPicture.Picture.Graphic);
   finally
    aPicture.Free;
   end;
   pBitmap := TBitmap.Create;
    try
      pBitmap.Width:=Imagelist1.Width;
      pBitmap.Height:=ImageList1.Height;
      for l := 0 to cl - 1 do
        for c := 0 to cl - 1 do
        begin
          pBitmap.Canvas.CopyRect(TRect.Create(0, 0, ImageList1.Width,
            ImageList1.Height),sBitmap.Canvas,
            TRect.Create(ImageList1.Width * c, ImageList1.Height * l,
            ImageList1.Width * c + ImageList1.Width, ImageList1.Height * l +
            ImageList1.Height));
          ImageList1.Add(pBitmap, nil);
        end;
    finally
      pBitmap.Free;
    end;
  // supprimer un morceaux (toujours le coin en bas à droite
  ImageList1.Delete(nbrMorceaux - 1);
 Self.Refresh;
 Melange;
end;

initialization;
  ressources:=TStringList.Create;
finalization
  ressources.Free;
end.
