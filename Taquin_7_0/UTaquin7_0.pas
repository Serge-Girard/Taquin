unit UTaquin7_0;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes,
  {System.Generics.Collections, ImageList,}
  Graphics, { Vcl.Imaging.pngimage,Vcl.Imaging.jpeg,}
  Controls, Forms, Dialogs, ImgList,
  StdCtrls, ExtCtrls, Spin, crOwnedList, Execute.GDIPBitmap;

type
  TMainForm = class(TForm)
    ScrollBox1: TScrollBox;
    Image1: TImage;
    SpinEdit1: TSpinEdit;
    Melanger: TButton;
    RadioGroup1: TRadioGroup;
    ImageList1: TImageList;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure MelangerClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
    nbrMorceaux: word;
    Morceaux: TIntegerList;
    procedure SplitImage;
    procedure Melange;
    procedure DrawScrollBox;
    function CanMove(morceau: Word): Boolean;
    procedure MoveMorceau(morceau: word);
    procedure Log;
  public
    { Déclarations publiques }
    procedure Move(Sender: TObject);
  end;

var
  MainForm     : TMainForm;
  ressources   : TStringList;
implementation

uses
  StrUtils;

{$R *.dfm}

function EnumRCDataProc(hModule: hModule; lpszType, lpszName: PChar;
  lParam: NativeInt): BOOL; stdcall;
begin
  if AnsiContainsText(lpszName, 'IMAGE') then
    TStrings(lParam).Add(lpszName);
  Result := True;
end;

function TMainForm.CanMove(morceau: Word): Boolean;
var
  l, c, lc     : word;
// vérification mouvement
begin
  result := True;

  lc := Trunc(sqrt(nbrMorceaux));
  c := morceau mod lc;
  l := (morceau div lc);
  if ((l - 1) > -1) and (morceaux.Items[(l - 1) * lc + c] = -1) then exit;
  if (((l + 1) < lc)) and (morceaux.Items[(l + 1) * lc + c] = -1) then exit;
  if (((c - 1) > -1)) and (morceaux.Items[(l * lc) + (c - 1)] = -1) then exit;
  if (((c + 1) < lc)) and (morceaux.Items[(l * lc) + (c + 1)] = -1) then exit;
  result := false;
end;

procedure TMainForm.DrawScrollBox;
var
  i, n         : Integer;
  p            : TImage;
  ncl          : Integer;
  pl, ph       : integer;
begin
    ncl := Trunc(Sqrt(nbrMorceaux));
  ScrollBox1.Update;
    for i := ScrollBox1.ControlCount - 1 downto 0 do
      TImage(ScrollBox1.Controls[i]).Free;

    pl := 0;
    ph := 0;
    for i := 0 to nbrmorceaux - 1 do
    begin
      p := TImage.Create(Self);
      p.Width := ImageList1.Width;
      p.Height := ImageList1.Height;
      p.Name := 'P' + IntToStr(i + 1);
      P.Tag := i;
      p.OnClick := Move;
      n := Morceaux.Items[i];
      if (n >= 0) and (n < ImageList1.Count) then
        ImageList1.GetBitmap(n, p.Picture.Bitmap);
      p.Parent := ScrollBox1;
      p.Left := pl;
      p.Top := ph;
      inc(pl, p.Width);
      if (pl div p.width) >= ncl then
      begin
        pl := 0;
        inc(ph, imagelist1.Height);
      end;
    end;
  ScrollBox1.Invalidate;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  ExecutableHandle: HMODULE;
  aRes         : TResourceStream;
begin
  //ReportMemoryLeaksOnShutdown := True;
  nbrMorceaux := 9;
  SpinEdit1.Value := 0;
  Morceaux := TIntegerList.Create;
  ExecutableHandle := LoadLibraryEx(PChar(Application.ExeName), 0, LOAD_LIBRARY_AS_DATAFILE);
  try
    EnumResourceNames(ExecutableHandle, RT_RCDATA, @EnumRCDataProc, NativeInt(Ressources));
  finally
    FreeLibrary(ExecutableHandle);
  end;
  SpinEdit1.MaxValue := ressources.Count - 1;
  ares := TResourceStream.Create(hinstance, ressources[SpinEdit1.Value], RT_RCDATA);
  try
    ares.Position := 0;
    TBitmap(Image1.Picture.Bitmap).GDIPLoadFromStream(ares);
  finally
    aRes.Free;
  end;
  SplitImage;
  DrawScrollBox;
end;

procedure TMainForm.Log;
var I: Integer;
    S: string;
begin
  S := '';
  for I := 0 to Morceaux.Count-1 do
  S := S + IntToStr(Morceaux[I])+', ';
  Memo1.Lines.Add(S);
end;

(*procedure TMainForm.Melange;
// Nouveau mélange de pièce
var
  i, p         : Integer;
  numeropieces : TIntegerList;
begin
  Memo1.Clear;
  Morceaux.Clear;
  numeropieces := TIntegerList.Create;
  try
    for i := -1 to nbrMorceaux - 2 do
      numeropieces.Add(i);
    randomize;
    for i := 0 to nbrMorceaux - 1 do
    begin
      p := Random(numeropieces.Count);
      Morceaux.Add(numeropieces[p]);
      numeropieces.Delete(p);
    end;
  finally
    numeropieces.Free;
  end;
  DrawScrollBox;
  Log;
end;*)

procedure TMainForm.Melange;
// Nouveau mélange de pièce
var
  i, p, pl, pv, Prev, Mov         : Integer;
begin
  Memo1.Clear;
  Morceaux.Clear;
  for i := 0 to nbrMorceaux - 1 do
  begin
    if I = nbrMorceaux - 1 then
      Morceaux.Add(-1)
    else
      Morceaux.Add(I);
  end;

  pl := Trunc(Sqrt(nbrMorceaux));
  Randomize;
  prev := -1;
  Mov := -1;
  for I := 0 to nbrMorceaux * 10 do
  begin
    pv := Morceaux.IndexOf(-1);
    repeat
      p := Random(4);
      case p of
        0: if (CanMove(pv - 1)) and (Morceaux[pv - 1] > -1) then Mov := pv - 1;
        1: if (CanMove(pv + 1)) and (Morceaux[pv + 1] > -1) then Mov := pv + 1;
        2: if (CanMove(pv - pl)) and (Morceaux[pv - pl] > -1) then Mov := pv - pl;
        3: if (CanMove(pv + pl)) and (Morceaux[pv + pl] > -1) then Mov := pv + pl;
      end;
    until Mov <> Prev;
    Morceaux.Swap(Mov, pv);
    Prev := Mov;
  end;
  DrawScrollBox;
  Log;
end;


procedure TMainForm.MelangerClick(Sender: TObject);
begin
  Melange;
end;

procedure TMainForm.Move(Sender: TObject);
var
  Piece        : Integer;
begin
  Piece := TImage(Sender).Tag;
  if CanMove(Piece) then
    MoveMorceau(Piece);
end;

procedure TMainForm.MoveMorceau(morceau: word);
var
  //l, c         : word;
  mt           : Integer;
  pl           : word;
begin
  pl := Trunc(Sqrt(nbrMorceaux));
  //c := morceau mod pl;
  //l := (morceau div pl);
  //if ((l - 1) > -1) and (morceaux.Items[(l - 1) * pl + c] = -1) then mt := (l - 1) * pl + c;
  //if (((l + 1) < pl)) and (morceaux.Items[(l + 1) * pl + c] = -1) then mt := (l + 1) * pl + c;
  //if (((c - 1) > -1)) and (morceaux.Items[(l * pl) + (c - 1)] = -1) then mt := (l * pl) + (c - 1);
  //if (((c + 1) < pl)) and (morceaux.Items[(l * pl) + (c + 1)] = -1) then mt := (l * pl) + (c + 1);
  mt := -1;
  if Morceaux[Morceau-1] = -1 then mt := Morceau-1;
  if Morceaux[Morceau+1] = -1 then mt := Morceau+1;
  if Morceaux[Morceau-pl] = -1 then mt := Morceau-pl;
  if Morceaux[Morceau+pl] = -1 then mt := Morceau+pl;
  Morceaux.Swap(mt, morceau);
  //Morceaux.Items[mt] := morceaux.Items[morceau];
  //morceaux.Items[morceau] := -1;
  Log;
  timer1.Enabled := True;
  //DrawScrollBox;
end;

procedure TMainForm.RadioGroup1Click(Sender: TObject);
begin
  case RadioGroup1.ItemIndex of
    0: nbrMorceaux := 3 * 3;
    1: nbrMorceaux := 4 * 4;
    2: nbrMorceaux := 5 * 5;
    3: nbrMorceaux := 6 * 6;
  end;
  SplitImage;
end;

procedure TMainForm.SpinEdit1Change(Sender: TObject);
var
  aRes         : TResourceStream;
begin
  ares := TResourceStream.Create(hinstance, ressources[SpinEdit1.Value], RT_RCDATA);
  try
    ares.Position := 0;
    TBitmap(Image1.Picture.Bitmap).GDIPLoadFromStream(ares);
  finally
    aRes.Free;
  end;
  SplitImage;
end;


//*************************************************************
function UpdateRectForProportionalSize(ARect: TRect; AWidth, AHeight: Integer; AStretch: Boolean): TRect;
var
  w, h, cw, ch: Integer;
  xyaspect: Double;
begin
  Result := ARect;
  if AWidth * AHeight = 0 then
    Exit;

  w := AWidth;
  h := AHeight;
  cw := ARect.Right - aRect.Left;
  ch := ARect.Bottom + aRect.Top;

  if AStretch or ((w > cw) or (h > ch)) then
  begin
    xyaspect := w / h;
    if w > h then
    begin
      w := cw;
      h := Trunc(cw / xyaspect);
      if h > ch then
      begin
        h := ch;
        w := Trunc(ch * xyaspect);
      end;
     end
     else
     begin
       h := ch;
       w := Trunc(ch * xyaspect);
       if w > cw then
       begin
         w := cw;
         h := Trunc(cw / xyaspect);
       end;
     end;
  end;

  Result := Rect(0, 0, w, h);
  OffsetRect(Result, ARect.Left + (cw - w) div 2, ARect.Top + (ch - h) div 2);
end;
//*************************************************************

//*************************************************************
procedure CopyAndCenterBitmap(const bSource, bDest: TBitmap);
var
  aRect        : TRect;
  Pt: TPoint;
begin
    if GetStretchBltMode(bDest.Canvas.Handle) <> HalfTone then
    begin
      GetBrushOrgEx(bDest.Canvas.Handle, Pt);
      SetStretchBltMode(bDest.Canvas.Handle, HalfTone); { }
      SetBrushOrgEx(bDest.Canvas.Handle, Pt.x, Pt.y, @Pt);
    end;
  bDest.Canvas.Brush.Style := bsClear;
  bDest.Canvas.Pen.Style := psClear;
  bDest.Canvas.Rectangle(bDest.Canvas.ClipRect);
  aRect := UpdateRectForProportionalSize(bDest.Canvas.ClipRect, bSource.Width, bSource.Height, False);
  bDest.Canvas.StretchDraw(aRect, bSource);
end;
//*************************************************************

procedure TMainForm.SplitImage;
var
  cl           : word;
  pBitmap, sBitmap: TBitmap;
  c            : Integer;
  l            : Integer;
begin
  cl := Trunc(Sqrt(nbrMorceaux));

  // effacer  le contenu de ImageList1
  for c := ImageList1.Count - 1 downto 0 do
    ImageList1.Delete(c);
  ImageList1.Height := 400 div cl; // 256 div cl;
  ImageList1.Width := 400 div cl; // 256 div cl;


  // découper l'image choisie
    sBitmap := TBitmap.Create;
    try
    sBitmap.Width := 400;
    sBitmap.Height := 400;
    CopyAndCenterBitmap(TBitmap(Image1.Picture.Bitmap), sBitmap);
    //sBitmap.Assign(Image1.Picture.Graphic);
  pBitmap := TBitmap.Create;
  try
    pBitmap.Width := Imagelist1.Width;
    pBitmap.Height := ImageList1.Height;
    for l := 0 to cl - 1 do
      for c := 0 to cl - 1 do
      begin
        pBitmap.Canvas.CopyRect(Rect(0, 0, ImageList1.Width,
          ImageList1.Height), sBitmap.Canvas,
          Rect(ImageList1.Width * c, ImageList1.Height * l,
          ImageList1.Width * c + ImageList1.Width, ImageList1.Height * l +
          ImageList1.Height));
        ImageList1.Add(pBitmap, nil);
      end;
  finally
    pBitmap.Free;
  end;
  finally
    sBitmap.Free;
  end;
  // supprimer un morceaux (toujours le coin en bas à droite
  ImageList1.Delete(nbrMorceaux - 1);
  Self.Refresh;
  Melange;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  timer1.Enabled := False;
  DrawScrollBox;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Morceaux.Free;
end;

initialization;
  ressources := TStringList.Create;
finalization
  ressources.Free;
end.

