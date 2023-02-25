unit crOwnedList;

interface
uses Classes{, RTLConsts};

type
  TOwnedList = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  end;

  TIntegerList = class(TObject)
    FIntArr: array of Integer;
  protected
    function Get(Index: Integer): Integer;
    function GetCount: Integer;
    procedure Put(Index: Integer; Item: Integer);
  public
    destructor Destroy; override;
    function Add(Item: Integer): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function IndexOf(Value: Integer): Integer;
    procedure Swap(Index1, Index2: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: Integer read Get write Put; default;
  end;

implementation

{ TOwnedList }

procedure TOwnedList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  case Action of
    lnDeleted: try FreeMem(Ptr) except end;
  end;
end;

{ TIntegerList }

function TIntegerList.Add(Item: Integer): Integer;
begin
try
  SetLength(FIntArr, Length(FIntArr)+1);
  Result := High(FIntArr);
  FIntArr[Result] := Item;
  except
Result := -1;
  end;
end;

procedure TIntegerList.Clear;
begin
  SetLength(FIntArr, 0);
end;

procedure TIntegerList.Delete(Index: Integer);
var FCount: Integer;
begin
try
  FCount := Count;
  if (Index < 0) or (Index >= FCount) then Exit;

  Dec(FCount);
  if Index < FCount then
    System.Move(FIntArr[Index + 1], FIntArr[Index],
      (FCount - Index) * SizeOf(Integer));
  SetLength(FIntArr, FCount);
  except

  end;
end;

destructor TIntegerList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TIntegerList.Get(Index: Integer): Integer;
begin
  Result := -2;
  if (Index > -1) and (Index < Count) then
    Result := FIntArr[Index];
end;

function TIntegerList.GetCount: Integer;
begin
  Result := Length(FIntArr);
end;

function TIntegerList.IndexOf(Value: Integer): Integer;
var I: Integer;
begin
  Result := -1;
  for I := 0 to High(FIntArr) do
    if FIntArr[I] = Value then
    begin
      Result := I;
      Break;
    end;
end;

procedure TIntegerList.Put(Index, Item: Integer);
begin
  if (Index > -1) and (Index < Count) then
    FIntArr[Index] := Item;
end;

procedure TIntegerList.Swap(Index1, Index2: Integer);
var
  TmpValue: Integer;
begin
  if ((Index1 > -1) and (Index1 < Count)) and ((Index2 > -1) and (Index2 < Count)) and (Index1 <> Index2)then
  begin
    TmpValue := Items[Index1];
    Items[Index1] := Items[Index2];
    Items[Index2] := TmpValue;
  end;
end;

end.
