unit Gemini.Functions.Example;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, Gemini.Functions.Core, Gemini.Schema;

type
  TWeatherReportFunction = class(TFunctionCore)
  protected
    function GetDescription: string; override;
    function GetName: string; override;
    function GetInputSchema: string; override;
  public
    function Execute(const Arguments: string): string; override;
    class function CreateInstance: IFunctionCore;
  end;

implementation

uses
  System.StrUtils, System.JSON;

{ TWeatherReportFunction }

class function TWeatherReportFunction.CreateInstance: IFunctionCore;
begin
  Result := TWeatherReportFunction.create;
end;

function TWeatherReportFunction.Execute(const Arguments: string): string;

  procedure AddToReport(const Value: TJSONObject;
    Temperature: Integer; UnitType: string; Forecast: TArray<string>);
  begin
    Value.AddPair('temperature', TJSONString.Create(Temperature.ToString + UnitType));
    Value.AddPair('forecast', TJSONArray.Create(Forecast[0], Forecast[1]));
  end;

begin
  Result := EmptyStr;
  var Location := EmptyStr;
  var TempUnit := EmptyStr;
  var index := -1;

  {--- Parse arguments to retrieve parameters }
  var JSON := TJSONObject.ParseJSONValue(Arguments) as TJSONObject;
  try
    if Assigned(JSON) then
    try
      Location := JSON.GetValue('location', '');
      TempUnit := JSON.GetValue('unit', '');
    finally
      JSON.Free;
    end;
  except
    Location := EmptyStr;
  end;

  {--- Stop the treatment if location is empty }
  if Location.IsEmpty then
    Exit;

  {--- Build the response }
  JSON := TJSONObject.Create;
  try
    JSON.AddPair('location', Location);
    if AnsiLowerCase(Location).Contains('san francisco') then
      index := 0 else
    if AnsiLowerCase(Location).Contains('paris') then
      index := 1;
    case index of
      0 :
        AddToReport(JSON, 21, '�' + TempUnit, [
          'sunny',
          'windy']);
      1 :
        AddToReport(JSON, 7, '�' + TempUnit, [
          'rainy',
          'low visibility but sunny in the late afternoon or early evening']);
    end;
    Result := JSON.ToJSON;
  finally
    JSON.Free;
  end;
end; {Execute}

function TWeatherReportFunction.GetDescription: string;
begin
  Result := 'Get the current weather or meteo in a given location';
end;

function TWeatherReportFunction.GetName: string;
begin
  Result := 'get_weather';
end;

function TWeatherReportFunction.GetInputSchema: string;
begin
//  Result :=
//    '{'+
//    '"type": "object",'+
//    '"properties": {'+
//         '"location": {'+
//             '"type": "string",'+
//             '"description": "The city and state, e.g. San Francisco, CA"'+
//           '}'+
//     '},'+
//     '"required": ["location"]'+
//    '}';

  var Schema := TSchemaParams.New(
    procedure (var Params: TSchemaParams)
    begin
      Params.&Type(stOBJECT);
      Params.Properties('properties',
        procedure (var Params: TSchemaParams)
        begin
          Params.Properties('location',
            procedure (var Params: TSchemaParams)
            begin
              Params.&Type(stSTRING);
              Params.Description('The city and state, e.g. San Francisco, CA');
            end);
          Params.Properties('unit',
            procedure (var Params: TSchemaParams)
            begin
              Params.&Type(stSTRING);
              Params.Enum(['C','F']);
            end);
        end);
      Params.Required(['location', 'unit']);
    end);
  Result := Schema.ToJsonString(True);
end;

end.
