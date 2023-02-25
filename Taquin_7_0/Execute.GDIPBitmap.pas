unit Execute.GDIPBitmap;

{
   GDI+ LoadFromStream helper for TBitmap (c)2017 Execute SARL
   http://www.execute.fr

https://www.developpez.net/forums/d1783447/environnements-developpement/delphi/contribuez/lire-fichiers-jpg-png-tif-quelques-lignes-code/

Code modifié par Cirec pour fonctionner de D7 à Tokyo 
}

interface

uses
  Windows,
  ActiveX,
  Classes,
  Graphics;

type
{$if Compilerversion >= 20.0} // les class helper existent depuis D2009
  TBitmapGDIHelper = class helper for TBitmap
  public
    function GDIPLoadFromFile(const FileName: string): Boolean;
    function GDIPLoadFromStream(Stream: TStream): Boolean; // Loads BMP, JPG, PNG and TIF
  end;
{$else}
  TBitmap = class(Graphics.TBitmap)
  public
    function GDIPLoadFromFile(const FileName: string): Boolean;
    function GDIPLoadFromStream(Stream: TStream): Boolean; // Loads BMP, JPG, PNG and TIF
  end;
{$ifend}

implementation

const
  GDIP = 'gdiplus.dll';

type
  TGdiplusStartupInput = packed record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : Pointer;        // Ignored on free builds
    SuppressBackgroundThread: BOOL;           // FALSE unless you're prepared to call
                                              // the hook/unhook functions properly
    SuppressExternalCodecs  : BOOL;           // FALSE unless you want GDI+ only to use
  end;

  TStatus = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiPlusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported,
    ProfileNotFound
  );

  ARGB = Cardinal;

{$if Compilerversion >= 20.0}
  TGpBitmap = record
  private
    Handle: Pointer;
  public
    function CreateFromStream(stream: IStream): TStatus; inline;
    function GetHBitmap(var aHandle: HBitmap; Background: ARGB): TStatus; inline;
    function Free: TStatus; inline;
  end;

{$else}

  TGpBitmap = class
  private
    Handle: Pointer;
  public
    destructor Destroy; override;
    function CreateFromStream(stream: IStream): TStatus;
    function GetHBitmap(var aHandle: HBitmap; Background: ARGB): TStatus;
  end;
{$ifend}



function GdiplusStartup(out token: ULONG; const input: TGdiplusStartupInput; output: Pointer): TStatus; stdcall; external GDIP;
function GdipCreateBitmapFromStream(stream: IStream; out image: Pointer): TStatus; stdcall; external GDIP;
function GdipCreateHBITMAPFromBitmap(const Bitmap: Pointer; var Handle: HBitmap; Background: ARGB): TStatus; stdcall; external GDIP;
function GdipDisposeImage({const }Image: Pointer): TStatus; stdcall; external GDIP;


var
  GdiplusToken: ULONG = 0;

function InitGDIPlus: Boolean;
var
  StartupInput: TGdiplusStartupInput;
begin
  if GdiplusToken = 0 then
  begin
    FillChar(StartupInput, SizeOf(StartupInput), 0);
    StartupInput.GdiplusVersion := 1;
    Result := GdiplusStartup(GdiplusToken, StartupInput, nil) = TStatus(Ok);
  end else begin
    Result := True;
  end;
end;

{ TGpBitmap }

function TGpBitmap.CreateFromStream(stream: IStream): TStatus;
begin
  Result := GdipCreateBitmapFromStream(stream, Handle);
end;

function TGpBitmap.GetHBitmap(var aHandle: HBitmap; Background: ARGB): TStatus;
begin
  Result := GdipCreateHBITMAPFromBitmap(Handle, aHandle, Background);
end;

{$if Compilerversion >= 20.0}
function TGpBitmap.Free: TStatus;
begin
  Result := GdipDisposeImage(Handle);
end;

{$else}
destructor TGpBitmap.Destroy;
begin
  GdipDisposeImage(Handle);
  inherited;
end;
{$ifend}

{ TBitmapHelper }
{$if Compilerversion >= 20.0}
function TBitmapGDIHelper.GDIPLoadFromFile(const FileName: string): Boolean;
{$else}
function TBitmap.GDIPLoadFromFile(const FileName: string): Boolean;
{$ifend}
const
  fmOpenRead = 0;
var
  FS: TFileStream;
begin
  //Result := False;
  FS := TFileStream.Create(FileName, fmOpenRead);
  try
    Result := GDIPLoadFromStream(FS);
  finally
    FS.Free;
  end;
end;

{$if Compilerversion >= 20.0}
function TBitmapGDIHelper.GDIPLoadFromStream(Stream: TStream): Boolean;
{$else}
function TBitmap.GDIPLoadFromStream(Stream: TStream): Boolean;
{$ifend}
var
  Bitmap : TGpBitmap;
  HBmp   : HBitmap;
begin
  Result := False;
  if not InitGDIPlus then
    Exit;
{$if Compilerversion < 20.0}
  Bitmap := TGpBitmap.Create;
{$ifend}
  if Bitmap.CreateFromStream(TStreamAdapter.Create(Stream)) = TStatus(Ok) then
  begin
    if Bitmap.GetHBitmap(HBmp, $FFFFFFFF) = TStatus(Ok) then
    begin
      Handle := HBmp;
      Result := True;
    end;
    Bitmap.Free;
  end;
end;

initialization
  TPicture.RegisterFileFormat('ico', 'Images ICO', TBitmap);
  TPicture.RegisterFileFormat('gif', 'Images GIF', TBitmap);
  TPicture.RegisterFileFormat('png', 'Portable Network Graphic Images PNG', TBitmap);
  TPicture.RegisterFileFormat('jpg', 'Images JPG', TBitmap);
  TPicture.RegisterFileFormat('jpeg', 'Images JPEG', TBitmap);
  TPicture.RegisterFileFormat('tif','Images TIF',TBitmap);
  TPicture.RegisterFileFormat('tiff','Images TIFF',TBitmap);
finalization
  TPicture.UnregisterGraphicClass(TBitmap);
end.
