unit Gemini.Tools;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, REST.Json.Types,
  Gemini.API.Params, Gemini.Schema, Gemini.Functions.Core;

type
  /// <summary>
  /// Defines the execution behavior for function calling by defining the execution mode.
  /// </summary>
  TToolMode = (
    /// <summary>
    /// Unspecified function calling mode. This value should not be used.
    /// </summary>
    MODE_UNSPECIFIED,
    /// <summary>
    /// Default model behavior, model decides to predict either a function call or a natural language response.
    /// </summary>
    AUTO,
    /// <summary>
    /// Model is constrained to always predicting a function call only. If "allowedFunctionNames" are set, the
    //// predicted function call will be limited to any one of "allowedFunctionNames", else the predicted function
    /// call will be any one of the provided "functionDeclarations".
    /// </summary>
    ANY,
    /// <summary>
    /// Model will not predict any function call. Model behavior is same as when not passing any function declarations.
    /// </summary>
    NONE
  );

  /// <summary>
  /// Helper record for the <c>TToolMode</c> enumeration, providing utility methods for converting
  /// between <c>TToolMode</c> values and their string representations.
  /// </summary>
  TToolModeHelper = record helper for TToolMode
    /// <summary>
    /// Converts the current <c>TToolMode</c> value to its corresponding string representation.
    /// </summary>
    /// <returns>
    /// A string representing the current <c>TToolMode</c> value.
    /// </returns>
    function ToString: string;
  end;

  /// <summary>
  /// Represents the parameters for a tool plugin, encapsulating a function core instance.
  /// </summary>
  /// <remarks>
  /// This record holds a function core instance that can be converted to a JSON object for integration with tool plugins.
  /// </remarks>
  TToolPluginParams = record
  private
    FFunction: IFunctionCore;
  public
    /// <summary>
    /// Converts the encapsulated function core instance to a JSON object.
    /// </summary>
    /// <returns>
    /// A <c>TJSONObject</c> representing the function core instance.
    /// </returns>
    /// <remarks>
    /// If an error occurs during conversion, the JSON object is deleted and the exception is re-raised.
    /// </remarks>
    function ToJson: TJSONObject;
    /// <summary>
    /// Gets or sets the function core instance.
    /// </summary>
    property &Function: IFunctionCore read FFunction write FFunction;
    /// <summary>
    /// Creates a new <c>TToolPluginParams</c> with the specified function core instance.
    /// </summary>
    /// <param name="AFunction">
    /// The function core instance to include in the plugin parameters.
    /// </param>
    /// <returns>
    /// A new <c>TToolPluginParams</c> containing the specified function core instance.
    /// </returns>
    class function Add(const AFunction: IFunctionCore): TToolPluginParams; static;
  end;

  /// <summary>
  /// Represents the Schema Object in OpenAPI, enabling the definition of input and output data types.
  /// These types can be objects, primitives, or arrays. This class provides methods to build and
  /// configure schema definitions as per the OpenAPI 3.0 Specification.
  /// </summary>
  /// <remarks>
  /// The Schema Object allows the definition of input and output data types in the OpenAPI Specification.
  /// This class provides a fluent interface to construct schema definitions programmatically.
  /// </remarks>
  TSchema = TSchemaParams;

  /// <summary>
  /// Structured representation of a function declaration as defined by the OpenAPI 3.03 specification.
  /// </summary>
  /// <remarks>
  /// Included in this declaration are the function name and parameters. This FunctionDeclaration is a representation of a block of code that can be used as a Tool by the model and executed by the client.
  /// </remarks>
  TFunctionDeclaration = class
  private
    FName: string;
    FDescription: string;
    FParameters: TSchema;
  public
    /// <summary>
    /// Required. The name of the function.
    /// </summary>
    /// <remarks>
    /// Must be a-z, A-Z, 0-9, or contain underscores and dashes, with a maximum length of 63.
    /// </remarks>
    property Name: string read FName write FName;
    /// <summary>
    /// Required. A brief description of the function.
    /// </summary>
    property Description: string read FDescription write FDescription;
    /// <summary>
    /// Optional. Describes the parameters to this function.
    /// </summary>
    /// <remarks>
    /// Reflects the Open API 3.03 Parameter Object string Key: the name of the parameter. Parameter names are case sensitive. Schema Value: the Schema defining the type used for the parameter.
    /// </remarks>
    property Parameters: TSchema read FParameters write FParameters;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Tool details that the model may use to generate response.
  /// </summary>
  /// <remarks>
  /// A Tool is a piece of code that enables the system to interact with external systems to perform an action, or set of actions, outside of knowledge and scope of the model.
  /// </remarks>
  TTool = class
  private
    FFunctionDeclarations: TArray<TFunctionDeclaration>;
  public
    /// <summary>
    /// Optional. A list of FunctionDeclarations available to the model that can be used for function calling.
    /// </summary>
    /// <remarks>
    /// The model or system does not execute the function. Instead the defined function may be returned as a FunctionCall with arguments to the client side for execution. The model may decide to call a subset of these functions by populating FunctionCall in the response. The next conversation turn may contain a FunctionResponse with the Content.role "function" generation context for the next model turn.
    /// </remarks>
    property FunctionDeclarations: TArray<TFunctionDeclaration> read FFunctionDeclarations write FFunctionDeclarations;
    destructor Destroy; override;
  end;

  /// <summary>
  /// Configuration for specifying function calling behavior.
  /// </summary>
  TFunctionCallingConfig = class
  private
   FMode: string;
   FAllowedFunctionNames: TArray<string>;
  public
    /// <summary>
    /// Optional. Specifies the mode in which function calling should execute.
    /// </summary>
    /// <remarks>
    /// If unspecified, the default value will be set to AUTO.
    /// </remarks>
    property Mode: string read FMode write FMode;
    /// <summary>
    /// Optional. A set of function names that, when provided, limits the functions the model will call.
    /// </summary>
    /// <remarks>
    /// This should only be set when the Mode is ANY. Function names should match [FunctionDeclaration.name]. With mode set to ANY, model will predict a function call from the set of function names provided.
    /// </remarks>
    property AllowedFunctionNames: TArray<string> read FAllowedFunctionNames write FAllowedFunctionNames;
  end;

  /// <summary>
  /// The Tool configuration containing parameters for specifying Tool use in the request.
  /// </summary>
  TToolConfig = class
  private
    FFunctionCallingConfig: TFunctionCallingConfig;
  public
    /// <summary>
    /// Optional. Function calling config.
    /// </summary>
    property FunctionCallingConfig: TFunctionCallingConfig read FFunctionCallingConfig write FFunctionCallingConfig;
    destructor Destroy; override;
  end;

implementation

uses
  System.StrUtils;

{ TToolModeHelper }

function TToolModeHelper.ToString: string;
begin
  case Self of
    MODE_UNSPECIFIED:
      Exit('MODE_UNSPECIFIED');
    AUTO:
      Exit('AUTO');
    ANY:
      Exit('ANY');
    NONE:
      Exit('NONE');
  end;
end;

{ TToolPluginParams }

class function TToolPluginParams.Add(const AFunction: IFunctionCore): TToolPluginParams;
begin
  Result.&Function := AFunction;
end;

function TToolPluginParams.ToJson: TJSONObject;
begin
  Result := FFunction.ToJson;
end;

{ TTool }

destructor TTool.Destroy;
begin
  for var Item in FFunctionDeclarations do
    Item.Free;
  inherited;
end;

{ TFunctionDeclaration }

destructor TFunctionDeclaration.Destroy;
begin
  if Assigned(FParameters) then
    FParameters.Free;
  inherited;
end;

{ TToolConfig }

destructor TToolConfig.Destroy;
begin
  if Assigned(FFunctionCallingConfig) then
    FFunctionCallingConfig.Free;
  inherited;
end;

end.
