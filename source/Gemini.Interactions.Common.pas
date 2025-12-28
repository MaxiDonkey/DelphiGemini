unit Gemini.Interactions.Common;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.JSON,
  Gemini.API.Params, Gemini.API, Gemini.Types, Gemini.Exceptions, Gemini.Types.EnumWire;

type
  TAllowedToolsIxParams = class(TJSONParam)
    /// <summary>
    /// The mode of the tool choice.
    /// </summary>
    function Mode(const Value: TToolChoiceType): TAllowedToolsIxParams;

    /// <summary>
    /// The names of the allowed tools.
    /// </summary>
    function Tools(const Value: TArray<string>): TAllowedToolsIxParams;
  end;

implementation

{ TAllowedToolsIxParams }

function TAllowedToolsIxParams.Mode(
  const Value: TToolChoiceType): TAllowedToolsIxParams;
begin
  Result := TAllowedToolsIxParams(Add('mode', Value.ToString));
end;

function TAllowedToolsIxParams.Tools(
  const Value: TArray<string>): TAllowedToolsIxParams;
begin
  Result := TAllowedToolsIxParams(Add('tools', Value));
end;

end.
