unit Gemini.Chat.Request.ToolConfig;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  Gemini.API.Params, Gemini.Types;

type
  TFunctionCallingConfig = class(TJSONParam)
    /// <summary>
    /// Optional. Specifies the mode in which function calling should execute. If unspecified, the default
    /// value will be set to AUTO.
    /// </summary>
    function Mode(const Value: TToolConfigMode): TFunctionCallingConfig;

    /// <summary>
    /// Optional. A set of function names that, when provided, limits the functions the model will call.
    /// </summary>
    /// <remarks>
    /// This should only be set when the Mode is ANY or VALIDATED. Function names should match
    /// [FunctionDeclaration.name]. When set, model will predict a function call from only allowed function
    /// names.
    /// </remarks>
    function AllowedFunctionNames(const Value: TArray<string>): TFunctionCallingConfig;
  end;

  TLatLng = class(TJSONParam)
    /// <summary>
    /// The latitude in degrees. It must be in the range [-90.0, +90.0].
    /// </summary>
    function Latitude(const Value: Double): TLatLng;

    /// <summary>
    /// The longitude in degrees. It must be in the range [-180.0, +180.0].
    /// </summary>
    function Longitude(const Value: Double): TLatLng;
  end;

  TRetrievalConfig = class(TJSONParam)
    /// <summary>
    /// Optional. The location of the user.
    /// </summary>
    function LatLng(const Value: TLatLng): TRetrievalConfig;

    /// <summary>
    /// Optional. The language code of the user. Language code for content. Use language tags defined by BCP47.
    /// </summary>
    /// <remarks>
    /// https://www.rfc-editor.org/rfc/bcp/bcp47.txt
    /// </remarks>
    function LanguageCode(const Value: string): TRetrievalConfig;

  end;

  TToolConfig = class(TJSONParam)
    /// <summary>
    /// Optional. Function calling config.
    /// </summary>
    function FunctionCallingConfig(const Value: TFunctionCallingConfig): TToolConfig;

    /// <summary>
    /// Optional. Retrieval config.
    /// </summary>
    function RetrievalConfig(const Value: TRetrievalConfig): TToolConfig;
  end;

implementation

{ TFunctionCallingConfig }

function TFunctionCallingConfig.AllowedFunctionNames(
  const Value: TArray<string>): TFunctionCallingConfig;
begin
  Result := TFunctionCallingConfig(Add('allowedFunctionNames', Value));
end;

function TFunctionCallingConfig.Mode(
  const Value: TToolConfigMode): TFunctionCallingConfig;
begin
  Result := TFunctionCallingConfig(Add('mode', Value.ToString));
end;

{ TToolConfig }

function TToolConfig.FunctionCallingConfig(
  const Value: TFunctionCallingConfig): TToolConfig;
begin
  Result := TToolConfig(Add('functionCallingConfig', Value.Detach));
end;

function TToolConfig.RetrievalConfig(
  const Value: TRetrievalConfig): TToolConfig;
begin
  Result := TToolConfig(Add('retrievalConfig', Value.Detach));
end;

{ TLatLng }

function TLatLng.Latitude(const Value: Double): TLatLng;
begin
  Result := TLatLng(Add('latitude', Value));
end;

function TLatLng.Longitude(const Value: Double): TLatLng;
begin
  Result := TLatLng(Add('longitude', Value));
end;

{ TRetrievalConfig }

function TRetrievalConfig.LanguageCode(const Value: string): TRetrievalConfig;
begin
  Result := TRetrievalConfig(Add('languageCode', Value));
end;

function TRetrievalConfig.LatLng(const Value: TLatLng): TRetrievalConfig;
begin
  Result := TRetrievalConfig(Add('latLng', Value.Detach));
end;

end.
