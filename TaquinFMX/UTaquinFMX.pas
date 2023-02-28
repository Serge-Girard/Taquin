unit UTaquinFMX;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListBox, FMX.Edit, FMX.EditBox,
  FMX.SpinBox, System.ImageList, FMX.ImgList, FMX.Layouts, FMX.MultiView,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Objects, FMX.ExtCtrls;

type
  TForm17 = class(TForm)
    ToolBar1: TToolBar;
    btnDrawer: TSpeedButton;
    MultiView1: TMultiView;
    Layout1: TLayout;
    Glyph1: TGlyph;
    ImagesModeles: TImageList;
    NumeroImage: TSpinBox;
    ComboBox1: TComboBox;
    ImagesPieces: TImageList;
    TaquinBox: TScrollBox;
    btnMelanger: TButton;
    ScaledLayout1: TScaledLayout;
    procedure MultiView1Hidden(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnMelangerClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure NumeroImageChange(Sender: TObject);
  private
    { Déclarations privées }
    nbrMorceaux: word;
    doMelange: boolean;
    procedure Melange;
    procedure DrawScrollBox;
    function CanMove(morceau: word): boolean;
    Procedure MoveMorceau(morceau: word);
    procedure SplitImage(const IIndex: word);
    procedure StretchImage(const IIndex: word; var aBitmap : TBitmap);
  public
    { Déclarations publiques }
    procedure Move(Sender: TObject);
  end;

type
  TImageListHelper = class helper for TImageList
    function Add(aBitmap: TBitmap): integer;
  end;

var
  Form17: TForm17;
  morceaux: TDictionary<integer, integer>;

implementation

{$R *.fmx}

uses FTaquinFMX, FMX.MultiResBitmap, System.math;

procedure TForm17.btnMelangerClick(Sender: TObject);
begin
  doMelange := True;
  MultiView1.HideMaster;
end;

function TForm17.CanMove(morceau: word): boolean;
var
  l, c, lc: word;
  // vérification mouvement
begin
  result := false;
  lc := Trunc(sqrt(nbrMorceaux));
  c := morceau mod lc;
  l := (morceau div lc);
  if ((l - 1) > -1) AND (morceaux.Items[(l - 1) * lc + c] = -1) then
    exit(True);
  if (((l + 1) < lc)) AND (morceaux.Items[(l + 1) * lc + c] = -1) then
    exit(True);
  if (((c - 1) > -1)) AND (morceaux.Items[(l * lc) + (c - 1)] = -1) then
    exit(True);
  if (((c + 1) < lc)) AND (morceaux.Items[(l * lc) + (c + 1)] = -1) then
    exit(True);
end;

procedure TForm17.ComboBox1Change(Sender: TObject);
begin
  case ComboBox1.ItemIndex of
    0 : nbrMorceaux:=3*3;
    1 : nbrMorceaux:=4*4;
    2 : nbrMorceaux:=5*5;
    3 : nbrMorceaux:=6*6;
    else nbrMorceaux:=4*4;
  end;
  doMelange := True;
end;

procedure TForm17.DrawScrollBox;
// dessiner
var
  i, n: integer;
  p: TFPiece;
  ncl: integer;
  pl, ph: Single;
begin
  ncl := Trunc(sqrt(nbrMorceaux));
  TaquinBox.BeginUpdate;
  for i := TaquinBox.Content.ControlsCount - 1 downto 0 do
    TaquinBox.Content.Controls[i].Free;
  pl := 0;
  ph := 0;
  for i := 0 to nbrMorceaux - 1 do
  begin
    p := TFPiece.Create(Self);
    p.Width := 400 / sqrt(nbrMorceaux);
    p.Height := 400 / sqrt(nbrMorceaux);
    p.Name := 'P' + (i + 1).ToString;
    p.ImagePiece.Tag := i;
    n := morceaux.Items[i];
    if n >= 0 then
    begin
      p.ImagePiece.Fill.Kind := TBrushKind.Bitmap;
      p.ImagePiece.Fill.Bitmap.Bitmap :=
        ImagesPieces.Bitmap(TSizeF.Create(p.ImagePiece.Width,
        p.ImagePiece.Height), n);
    end;
    p.ImagePiece.OnClick := Move;
    p.Parent := TaquinBox;
    p.Position.X := pl;
    p.Position.Y := ph;
    pl := pl + p.Width;
    if (pl / p.Width) >= ncl then
    begin
      pl := 0;
      ph := ph + p.Height;
    end;
  end;
  TaquinBox.EndUpdate;
end;

procedure TForm17.FormCreate(Sender: TObject);
begin
  nbrMorceaux := 16;
  doMelange := True;
  SplitImage(0);
end;

procedure TForm17.Melange;
// Nouveau mélange de pièce
var
  i, p: integer;
  numeropieces: TList<integer>;
begin
  morceaux.Clear;
  numeropieces := TList<integer>.Create;
  try
    for i := -1 to nbrMorceaux - 2 do
      numeropieces.Add(i);
    randomize;
    for i := 0 to nbrMorceaux - 1 do
    begin
      p := Random(numeropieces.Count);
      morceaux.Add(i, numeropieces[p]);
      numeropieces.Delete(p);
    end;
  finally
    FreeAndNil(numeropieces);
  end;
  DrawScrollBox;
  doMelange := false;
end;

procedure TForm17.Move(Sender: TObject);
var
  Piece: integer;
begin
  Piece := TRectangle(Sender).Tag;
  if CanMove(Piece) then
    MoveMorceau(Piece);
end;

procedure TForm17.MoveMorceau(morceau: word);
// déplacer une pièce
var
  l, c: word;
  mt: word;
  pl: word;
begin
  pl := Trunc(sqrt(nbrMorceaux));
  c := morceau mod pl;
  l := (morceau div pl);
  mt := morceau;
  if ((l - 1) > -1) AND (morceaux.Items[(l - 1) * pl + c] = -1) then
    mt := (l - 1) * pl + c;
  if (((l + 1) < pl)) AND (morceaux.Items[(l + 1) * pl + c] = -1) then
    mt := (l + 1) * pl + c;
  if (((c - 1) > -1)) AND (morceaux.Items[(l * pl) + (c - 1)] = -1) then
    mt := (l * pl) + (c - 1);
  if (((c + 1) < pl)) AND (morceaux.Items[(l * pl) + (c + 1)] = -1) then
    mt := (l * pl) + (c + 1);
  morceaux.Items[mt] := morceaux.Items[morceau];
  morceaux.Items[morceau] := -1;
  DrawScrollBox;
end;

procedure TForm17.MultiView1Hidden(Sender: TObject);
begin
  if doMelange then
    SplitImage(Trunc(NumeroImage.Value));
end;

procedure TForm17.NumeroImageChange(Sender: TObject);
begin
  Glyph1.ImageIndex:=Trunc(NumeroImage.Value);
  doMelange := True
end;

procedure TForm17.SplitImage(const IIndex: word);
// éclater l'image
var
  cl: word;
//  sImage: TGlyph;
  sbitmap, pBitmap: TBitmap;
  c: integer;
  l: integer;
begin
  cl := Trunc(sqrt(nbrMorceaux));

  // effacer  le contenu de ImageList1
  if ImagesPieces.Destination.Count > 0 then
    ImagesPieces.Destination.Clear;

  // découper l'image choisie
  sbitmap:=TBitmap.Create(400, 400);
  try
    StretchImage(Trunc(NumeroImage.Value),sBitmap);
    if Assigned(sbitmap) then
    begin
      pBitmap := TBitmap.Create(400 div cl, 400 div cl);
      try
        for l := 0 to cl - 1 do
          for c := 0 to cl - 1 do
          begin
            var
              r: TRect := TRect.Create(pBitmap.Width * c, pBitmap.Height * l,
                pBitmap.Width * c + pBitmap.Width,
                pBitmap.Height * l + pBitmap.Height);
            pBitmap.CopyFromBitmap(sbitmap, r, 0, 0);
            ImagesPieces.Add(pBitmap);
          end;
      finally
       FreeAndNil(pBitmap)
      end;
    end;
  finally
    FreeAndNil(sBitmap);
  end;
  // supprimer un morceaux (toujours le coin en bas à droite
  ImagesPieces.Destination.Delete(nbrMorceaux - 1);
  if doMelange then
    Melange;
end;

procedure TForm17.StretchImage(const IIndex: word; var aBitmap : TBitmap);
// mettre l'image source en 400x400
const
  SCALE = 1;
var
  bmpA: TBitmap;
//  bmpSize : TSize;
//  nom : String;
//  Item: TCustomBitmapItem;
  vSource: TCustomSourceItem;
  sbitmap : TCustomBitmapItem;

//  Size: TSize;
  src, trg: TRectF;
begin
    vSource := ImagesModeles.Source.Items[IIndex];
    sbitmap := vSource.MultiResBitmap.ItemByScale(SCALE, True, True);
    bmpA:=sBitmap.Bitmap;
    src := TRectF.Create(0, 0, bmpa.Width,bmpa.Height);
    trg := RectF(0, 0, 400, 400);
    aBitmap.Canvas.BeginScene;
    aBitmap.Canvas.DrawBitmap(bmpA, src, trg, 1);
    aBitmap.Canvas.EndScene;
end;

{ TImageListHelper }

function TImageListHelper.Add(aBitmap: TBitmap): integer;
const
  SCALE = 1;
var
  vSource: TCustomSourceItem;
  vBitmapItem: TCustomBitmapItem;
  vDest: TCustomDestinationItem;
  vLayer: TLayer;
begin
  result := -1;
  if (aBitmap.Width = 0) or (aBitmap.Height = 0) then
    exit;

  // add source bitmap
  vSource := Source.Add;
  vSource.MultiResBitmap.TransparentColor := TColorRec.Fuchsia;
  vSource.MultiResBitmap.SizeKind := TSizeKind.Source;
  vSource.MultiResBitmap.Width := Round(aBitmap.Width / SCALE);
  vSource.MultiResBitmap.Height := Round(aBitmap.Height / SCALE);
  vBitmapItem := vSource.MultiResBitmap.ItemByScale(SCALE, True, True);
  if vBitmapItem = nil then
  begin
    vBitmapItem := vSource.MultiResBitmap.Add;
    vBitmapItem.SCALE := SCALE;
  end;
  vBitmapItem.Bitmap.Assign(aBitmap);

  vDest := Destination.Add;
  vLayer := vDest.Layers.Add;
  vLayer.SourceRect.Rect := TRectF.Create(TPoint.Zero,
    vSource.MultiResBitmap.Width, vSource.MultiResBitmap.Height);
  vLayer.Name := vSource.Name;
  result := vDest.Index;
end;

initialization

morceaux := TDictionary<integer, integer>.Create;

finalization

FreeAndNil(morceaux);

end.
