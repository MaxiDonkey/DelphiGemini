unit Gemini.JsonPathHelper;
interface

uses
  System.SysUtils, System.JSON, System.Generics.Collections;

type
  TJSONValueHelper = class helper for TJSONValue
  public
    function GetPathValue(const Path: string): TJSONValue;
    function GetPathString(const Path: string; const Default: string = ''): string;
    function GetPathInteger(const Path: string; const Default: Integer = 0): Integer;
    function GetPathBoolean(const Path: string; const Default: Boolean = False): Boolean;
    function GetPathDouble(const Path: string; const Default: Double = 0.0): Double;
    function GetPathObjectText(const Path: string; const Default: string = ''): string;
    function GetPathArrayText(const Path: string; const Default: string = ''): string;
    function GetPathCount(const Path: string; const Default: Integer = 0): Integer;
  end;

  TJsonReader = record
  private
    type
      IJsonRootHolder = interface
        ['{0E6D8A89-2DA5-4A5A-8E1B-9C0C8F2D0C77}']
        function Root: TJSONValue;
      end;

      TJsonRootHolder = class(TInterfacedObject, IJsonRootHolder)
      private
        FRoot: TJSONValue;
      public
        constructor Create(const JsonText: string);
        destructor Destroy; override;
        function Root: TJSONValue;
      end;

  private
    FHolder: IJsonRootHolder;
    function Root: TJSONValue; inline;

  public
    class function Parse(const JsonText: string): TJsonReader; static;

    class operator Initialize(out Dest: TJsonReader);

    function IsValid: Boolean; inline;

    function Value(const Path: string): TJSONValue; inline;

    function AsString(const Path: string; const Default: string = ''): string;
    function AsInteger(const Path: string; const Default: Integer = 0): Integer;
    function AsBoolean(const Path: string; const Default: Boolean = False): Boolean;
    function AsDouble(const Path: string; const Default: Double = 0.0): Double;

    function ObjectText(const Path: string; const Default: string = ''): string;
    function ArrayText(const Path: string; const Default: string = ''): string;
    function Count(const Path: string; const Default: Integer = 0): Integer;
    function Format(const Format: Integer = 4): string;
  end;

implementation

function NextToken(const S: string; var Index: Integer): string;
begin
  while (Index <= S.Length) and (S[Index] = '.') do
    Inc(Index);

  var Start := Index;

  while (Index <= S.Length) and (S[Index] <> '.') do
    Inc(Index);

  Result := S.Substring(Start - 1, Index - Start);

  if (Index <= S.Length) and (S[Index] = '.') then
    Inc(Index);
end;

function ParseArrayIndex(const Token: string; out Name: string; out HasIndex: Boolean; out Index: Integer): Boolean;
var
  Left, Right: Integer;
begin
  Name := Token;
  HasIndex := False;
  Index := -1;

  Left := Token.IndexOf('[');
  if Left < 0 then
    Exit(True);

  Right := Token.IndexOf(']', Left + 1);
  if Right < 0 then
    Exit(False);

  Name := Token.Substring(0, Left);
  var IndexStr := Token.Substring(Left + 1, Right - (Left + 1));
  HasIndex := True;
  Result := TryStrToInt(IndexStr, Index) and (Index >= 0);
end;

{ TJSONValueHelper }

function TJSONValueHelper.GetPathValue(const Path: string): TJSONValue;
var
  ArrIndex: Integer;
  Name: string;
  HasIndex: Boolean;
begin
  Result := nil;

  var Current := Self;
  if (Current = nil) or Path.IsEmpty then
    Exit;

  var I := 1;
  while I <= Path.Length do
    begin
      var Token := NextToken(Path, I);
      if Token.IsEmpty then
        Break;

      if not ParseArrayIndex(Token, Name, HasIndex, ArrIndex) then
        Exit(nil);

      if not Name.IsEmpty then
        begin
          if not (Current is TJSONObject) then
            Exit(nil);

          var Obj := TJSONObject(Current);
          Current := Obj.GetValue(Name);
          if Current = nil then
            Exit(nil);
        end;

      if HasIndex then
        begin
          if not (Current is TJSONArray) then
            Exit(nil);

          var Arr := TJSONArray(Current);
          if (ArrIndex < 0) or (ArrIndex >= Arr.Count) then
            Exit(nil);

          Current := Arr.Items[ArrIndex];
          if Current = nil then
            Exit(nil);
        end;
    end;

  Result := Current;
end;

function TJSONValueHelper.GetPathString(const Path: string; const Default: string): string;
begin
  var JSONValue := GetPathValue(Path);
  if JSONValue = nil then
    Exit(Default);

  if JSONValue is TJSONString then
    Exit(TJSONString(JSONValue).Value);

  if JSONValue is TJSONNumber then
    Exit(TJSONNumber(JSONValue).ToString);

  Result := JSONValue.Value;
  if Result.IsEmpty then
    Result := JSONValue.ToString;
end;

function TJSONValueHelper.GetPathInteger(const Path: string; const Default: Integer): Integer;
begin
  var S := GetPathString(Path, '');
  if (S <> '') and TryStrToInt(S, Result) then
    Exit;

  Result := Default;
end;

function TJSONValueHelper.GetPathBoolean(const Path: string; const Default: Boolean): Boolean;
begin
  var S := GetPathString(Path, '');
  if SameText(S, 'true') then
    Exit(True);

  if SameText(S, 'false') then
    Exit(False);

 Result := Default;
end;

function TJSONValueHelper.GetPathDouble(const Path: string; const Default: Double): Double;
begin
  var S := GetPathString(Path, '');
  var FS := TFormatSettings.Invariant;
  if (S <> '') and TryStrToFloat(S, Result, FS) then
    Exit;

  Result := Default;
end;

function TJSONValueHelper.GetPathObjectText(const Path, Default: string): string;
begin
  var V := GetPathValue(Path);
  if (V <> nil) and (V is TJSONObject) then
    Exit(TJSONObject(V).ToJSON);

  Result := Default;
end;

function TJSONValueHelper.GetPathArrayText(const Path, Default: string): string;
begin
  var V := GetPathValue(Path);
  if (V <> nil) and (V is TJSONArray) then
    Exit(TJSONArray(V).ToJSON);

  Result := Default;
end;

function TJSONValueHelper.GetPathCount(const Path: string; const Default: Integer): Integer;
begin
  var V := GetPathValue(Path);
  if V = nil then
    Exit(Default);

  if V is TJSONArray then
    Exit(TJSONArray(V).Count);

  if V is TJSONObject then
    Exit(TJSONObject(V).Count);

  Result := Default;
end;

{ TJsonReader.TJsonRootHolder }

constructor TJsonReader.TJsonRootHolder.Create(const JsonText: string);
begin
  inherited Create;
  FRoot := TJSONObject.ParseJSONValue(JsonText);
end;

destructor TJsonReader.TJsonRootHolder.Destroy;
begin
  FRoot.Free;
  inherited;
end;

function TJsonReader.TJsonRootHolder.Root: TJSONValue;
begin
  Result := FRoot;
end;

{ TJsonReader }

class operator TJsonReader.Initialize(out Dest: TJsonReader);
begin
  Dest.FHolder := nil;
end;

function TJsonReader.Root: TJSONValue;
begin
  if FHolder = nil then
    Exit(nil);

  Result := FHolder.Root;
end;

class function TJsonReader.Parse(const JsonText: string): TJsonReader;
begin
  Result.FHolder := TJsonRootHolder.Create(JsonText);
end;

function TJsonReader.IsValid: Boolean;
begin
  Result := Root <> nil;
end;

function TJsonReader.Value(const Path: string): TJSONValue;
begin
  var R := Root;
  if R = nil then
    Exit(nil);

  Result := R.GetPathValue(Path);
end;

function TJsonReader.AsString(const Path: string; const Default: string): string;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathString(Path, Default);
end;

function TJsonReader.AsInteger(const Path: string; const Default: Integer): Integer;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathInteger(Path, Default);
end;

function TJsonReader.AsBoolean(const Path: string; const Default: Boolean): Boolean;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathBoolean(Path, Default);
end;

function TJsonReader.AsDouble(const Path: string; const Default: Double): Double;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathDouble(Path, Default);
end;

function TJsonReader.ObjectText(const Path: string; const Default: string): string;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathObjectText(Path, Default);
end;

function TJsonReader.ArrayText(const Path: string; const Default: string): string;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathArrayText(Path, Default);
end;

function TJsonReader.Count(const Path: string; const Default: Integer): Integer;
begin
  var R := Root;
  if R = nil then
    Exit(Default);

  Result := R.GetPathCount(Path, Default);
end;

function TJsonReader.Format(const Format: Integer): string;
begin
  var R := Root;
  if R = nil then
    Exit('');

  Result := R.Format(Format);
end;

end.
