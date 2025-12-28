unit Gemini.Chat.Request.Tools;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

{$REGION 'dev note'}

(*

  Delphi code to JSON when TToolParams used

  TChatParams.Create
    .Tools(
      TTools.Create
        .AddFunctionDeclarations(
          TFunction.Create
            .AddFunction('myName', 'myDescription')
            .AddFunction('mysecondfunc', 'Seconde fonction')
          )
        .AddNewGoogleSearchRetrieval(
          TGoogleSearchRetrieval.Create
            .DynamicRetrievalConfig(
               TDynamicRetrievalConfig.Create
                 .Mode(TModeType.MODE_DYNAMIC)
              )
          )
        .AddCodeExecution(TCodeExecution.Create)
        .AddGoogleSearch(TGoogleSearch.Create)
        .AddComputerUse(TComputerUse.Create.Environment(TEnvironmentType.ENVIRONMENT_BROWSER))
        .AddUrlContext(TUrlContext.Create)
        .AddFileSearch(TFileSearch.Create.FileSearchStoreNames(['myFiles', 'TodoList']))
        .AddGoogleMaps(TGoogleMaps.Create)
     );

  JSON result:

  {
    "tools": [
        {
            "functionDeclarations": [
                {
                    "name": "myName",
                    "description": "myDescription"
                },
                {
                    "name": "mysecondfunc",
                    "description": "Seconde fonction"
                }
            ]
        },
        {
            "googleSearchRetrieval": {
                "dynamicRetrievalConfig": {
                    "mode": "MODE_DYNAMIC"
                }
            }
        },
        {
            "codeExecution": {
            }
        },
        {
            "googleSearch": {
            }
        },
        {
            "computerUse": {
                "environment": "ENVIRONMENT_BROWSER"
            }
        },
        {
            "urlContext": {
            }
        },
        {
            "fileSearch": {
                "fileSearchStoreNames": [
                    "myFiles",
                    "TodoList"
                ]
            }
        },
        {
            "googleMaps": {
            }
        }
    ]
  }

*)

{$ENDREGION}

uses
  System.SysUtils, System.JSON,
  Gemini.API.Params, Gemini.Types, Gemini.Schema, Gemini.Exceptions;

type
  TFunctionDeclarations = class(TJSONParam)
    /// <summary>
    /// Required. The name of the function. Must be a-z, A-Z, 0-9, or contain underscores, colons, dots, 
    /// and dashes, with a maximum length of 64.  
    /// </summary>
    function Name(const Value: string): TFunctionDeclarations;

    /// <summary>
    /// Required. A brief description of the function.  
    /// </summary>
    function Description(const Value: string): TFunctionDeclarations;

    /// <summary>
    /// Optional. Specifies the function Behavior. Currently only supported by the BidiGenerateContent method.  
    /// </summary>
    function Behavior(const Value: TBehaviorType): TFunctionDeclarations;

    /// <summary>
    /// Optional. Describes the parameters to this function. Reflects the Open API 3.03 Parameter Object 
    /// string Key: the name of the parameter. Parameter names are case sensitive. Schema Value: the 
    /// Schema defining the type used for the parameter.  
    /// </summary>
    function Parameters(const Value: TSchemaParams): TFunctionDeclarations;

    /// <summary>
    /// Optional. Describes the parameters to the function in JSON Schema format. The schema must describe 
    /// an object where the properties are the parameters to the function. For example:  
    /// </summary>
    function ParametersJsonSchema(const Value: TJSONObject): TFunctionDeclarations; overload;

    /// <summary>
    /// Optional. Describes the parameters to the function in JSON Schema format. The schema must describe 
    /// an object where the properties are the parameters to the function. For example:  
    /// </summary>
    function ParametersJsonSchema(const Value: string): TFunctionDeclarations; overload;

    /// <summary>
    /// Optional. Describes the output from this function in JSON Schema format. Reflects the Open API 3.03 
    /// Response Object. The Schema defines the type used for the response value of the function.  
    /// </summary>
    function Response(const Value: TSchemaParams): TFunctionDeclarations;

    /// <summary>
    /// Optional. Describes the output from this function in JSON Schema format. The value specified by 
    /// the schema is the response value of the function.
    /// </summary>
    /// <remarks>
    /// This field is mutually exclusive with response.    
    /// </remarks>
    function ResponseJsonSchema(const Value: TJSONObject): TFunctionDeclarations; overload;

    /// <summary>
    /// Optional. Describes the output from this function in JSON Schema format. The value specified by 
    /// the schema is the response value of the function.
    /// </summary>
    /// <remarks>
    /// This field is mutually exclusive with response.    
    /// </remarks>
    function ResponseJsonSchema(const Value: string): TFunctionDeclarations; overload;

    class function NewFunction(const Name: string; const Description: string): TFunctionDeclarations; 
  end;

  TDynamicRetrievalConfig = class(TJSONParam)
    /// <summary>
    /// The mode of the predictor to be used in dynamic retrieval.  
    /// </summary>
    function Mode(const Value: TModeType): TDynamicRetrievalConfig;

    /// <summary>
    /// The threshold to be used in dynamic retrieval. If not set, a system default value is used.  
    /// </summary>
    function DynamicThreshold(const Value: Double): TDynamicRetrievalConfig;
  end;
  
  TGoogleSearchRetrieval = class(TJSONParam)
    /// <summary>
    /// Specifies the dynamic retrieval configuration for the given source.  
    /// </summary>
    function DynamicRetrievalConfig(const Value: TDynamicRetrievalConfig): TGoogleSearchRetrieval; 
  end;

  TCodeExecution = class(TJSONParam) 
  {$REGION 'dev note'}
   (*
     This type has no fields.
     Tool that executes code generated by the model, and automatically returns the result to the model.
     See also ExecutableCode and CodeExecutionResult which are only generated when using this tool.
   *)
  {$ENDREGION}
  end;

  TInterval = class(TJSONParam)
    /// <summary>
    /// Optional. Inclusive start of the interval. 
    /// </summary>
    /// <param name="Value">
    /// Uses RFC 3339, where generated output will always be Z-normalized and use 0, 3, 6 or 9 fractional 
    /// digits. Offsets other than "Z" are also accepted. Examples: "2014-10-02T15:01:23Z", 
    /// "2014-10-02T15:01:23.045123456Z" or "2014-10-02T15:01:23+05:30".  
    /// </param>
    /// <remarks>
    /// If specified, a Timestamp matching this interval will have to be the same or after the start. 
    /// </remarks>
    function StartTime(const Value: string): TInterval;

    /// <summary>
    /// Optional. Exclusive end of the interval.
    /// </summary>
    /// <param name="Value">
    /// Uses RFC 3339, where generated output will always be Z-normalized and use 0, 3, 6 or 9 fractional 
    /// digits. Offsets other than "Z" are also accepted. Examples: "2014-10-02T15:01:23Z", 
    /// "2014-10-02T15:01:23.045123456Z" or "2014-10-02T15:01:23+05:30".  
    /// </param>
    /// <remarks>
    /// If specified, a Timestamp matching this interval will have to be before the end.
    /// </remarks>
    function EndTime(const Value: string): TInterval;
  end;
  
  TGoogleSearch = class(TJSONParam)
    /// <summary>
    /// Optional. Filter search results to a specific time range. If customers set a start time, 
    /// they must set an end time (and vice versa).
    /// </summary>
    function TimeRangeFilter(const Value: TInterval): TGoogleSearch;
  end;

  TComputerUse = class(TJSONParam)
    /// <summary>
    /// Required. The environment being operated.  
    /// </summary>
    function Environment(const Value: TEnvironmentType): TComputerUse;

    /// <summary>
    /// Optional. By default, predefined functions are included in the final model call.  
    /// </summary>
    /// <remarks>
    /// Some of them can be explicitly excluded from being automatically included. This can serve two
    /// purposes: 1. Using a more restricted / different action space. 2. 
    /// Improving the definitions / instructions of predefined functions.  
    /// </remarks>
    function ExcludedPredefinedFunctions(const Value: TArray<string>): TComputerUse;
  end;

  TUrlContext = class(TJSONParam) 
  {$REGION 'dev note'}
   (*
     This type has no fields.
     Tool to support URL context retrieval.
   *)
  {$ENDREGION}
  end;

  TFileSearch = class(TJSONParam) 
    /// <summary>
    /// Required. The names of the fileSearchStores to retrieve from. 
    /// <para>
    /// • Example: fileSearchStores/my-file-search-store-123  
    /// </para>
    /// </summary>
    function FileSearchStoreNames(const Value: TArray<string>): TFileSearch;

    /// <summary>
    /// Optional. Metadata filter to apply to the semantic retrieval documents and chunks.
    /// </summary>
    function MetadataFilter(const Value: string): TFileSearch;
    
    /// <summary>
    /// Optional. The number of semantic retrieval chunks to retrieve.  
    /// </summary>
    function TopK(const Value: Integer): TFileSearch;
  end;

  TGoogleMaps = class(TJSONParam)
    /// <summary>
    /// Optional. Whether to return a widget context token in the GroundingMetadata of the response.   
    /// </summary>
    /// <remarks>
    /// Developers can use the widget context token to render a Google Maps widget with geospatial context 
    /// related to the places that the model references in the response.  
    /// </remarks>
    function EnableWidget(const Value: Boolean): TGoogleMaps;
  end;

  TToolParams = class(TJSONParam)
    /// <summary>
    /// Optional. A list of FunctionDeclarations available to the model that can be used for function calling.  
    /// </summary>
    /// <remarks>
    /// The model or system does not execute the function. Instead the defined function may be returned as a 
    /// FunctionCall with arguments to the client side for execution. The model may decide to call a subset 
    /// of these functions by populating FunctionCall in the response. The next conversation turn may contain 
    /// a FunctionResponse with the Content.role "function" generation context for the next model turn.  
    /// </remarks>
    function FunctionDeclarations(const Value: TArray<TFunctionDeclarations>): TToolParams;

    /// <summary>
    /// Optional. Retrieval tool that is powered by Google search.  
    /// </summary>
    function GoogleSearchRetrieval(const Value: TGoogleSearchRetrieval): TToolParams;

    /// <summary>
    /// Optional. Enables the model to execute code as part of generation.  
    /// </summary>
    function CodeExecution(const Value: TCodeExecution): TToolParams;

    /// <summary>
    /// Optional. GoogleSearch tool type. Tool to support Google Search in Model. Powered by Google.  
    /// </summary>
    function GoogleSearch(const Value: TGoogleSearch): TToolParams;

    /// <summary>
    /// Optional. Tool to support the model interacting directly with the computer. If enabled, 
    /// it automatically populates computer-use specific Function Declarations.  
    /// </summary>
    function ComputerUse(const Value: TComputerUse): TToolParams;

    /// <summary>
    /// Optional. Tool to support URL context retrieval.  
    /// </summary>
    function UrlContext(const Value: TUrlContext): TToolParams;

    /// <summary>
    /// Optional. FileSearch tool type. Tool to retrieve knowledge from Semantic Retrieval corpora.  
    /// </summary>
    function FileSearch(const Value: TFileSearch): TToolParams;

    /// <summary>
    /// Optional. Tool that allows grounding the model's response with geospatial context related to 
    /// the user's query.  
    /// </summary>
    function GoogleMaps(const Value: TGoogleMaps): TToolParams;

    class function NewFunctionDeclarations(const Value: TArray<TFunctionDeclarations>): TToolParams;
    class function NewGoogleSearchRetrieval(const Value: TGoogleSearchRetrieval): TToolParams;
    class function NewCodeExecution(const Value: TCodeExecution): TToolParams;
    class function NewGoogleSearch(const Value: TGoogleSearch): TToolParams;
    class function NewComputerUse(const Value: TComputerUse): TToolParams;
    class function NewUrlContext(const Value: TUrlContext): TToolParams;
    class function NewFileSearch(const Value: TFileSearch): TToolParams;
    class function NewGoogleMaps(const Value: TGoogleMaps): TToolParams;
  end;

implementation

{ TfunctionDeclarations }

function TFunctionDeclarations.Behavior(
  const Value: TBehaviorType): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations(Add('behavior', Value.ToString));
end;

function TFunctionDeclarations.Description(
  const Value: string): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations(Add('description', Value));
end;

function TFunctionDeclarations.Name(const Value: string): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations(Add('name', Value));
end;

class function TFunctionDeclarations.NewFunction(const Name,
  Description: string): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations.Create
    .Name(Name)
    .Description(Description);
end;

function TFunctionDeclarations.Parameters(
  const Value: TSchemaParams): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations(Add('parameters', Value.Detach));
end;

function TFunctionDeclarations.ParametersJsonSchema(
  const Value: string): TFunctionDeclarations;
begin
  Result := ParametersJsonSchema(TJSONHelper.StringToJson(Value));
end;

function TFunctionDeclarations.ParametersJsonSchema(
  const Value: TJSONObject): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations(Add('parametersJsonSchema', Value));
end;

function TFunctionDeclarations.Response(
  const Value: TSchemaParams): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations(Add('response', Value.Detach));
end;

function TFunctionDeclarations.ResponseJsonSchema(
  const Value: string): TFunctionDeclarations;
begin
  Result := ResponseJsonSchema(TJSONHelper.StringToJson(Value))
end;

function TFunctionDeclarations.ResponseJsonSchema(
  const Value: TJSONObject): TFunctionDeclarations;
begin
  Result := TFunctionDeclarations(Add('responseJsonSchema', Value));
end;

{ TDynamicRetrievalConfig }

function TDynamicRetrievalConfig.DynamicThreshold(
  const Value: Double): TDynamicRetrievalConfig;
begin
  Result := TDynamicRetrievalConfig(Add('dynamicThreshold', Value));
end;

function TDynamicRetrievalConfig.Mode(
  const Value: TModeType): TDynamicRetrievalConfig;
begin
  Result := TDynamicRetrievalConfig(Add('mode', Value.ToString));
end;

{ TGoogleSearchRetrieval }

function TGoogleSearchRetrieval.DynamicRetrievalConfig(
  const Value: TDynamicRetrievalConfig): TGoogleSearchRetrieval;
begin
  Result := TGoogleSearchRetrieval(Add('dynamicRetrievalConfig', Value.Detach));
end;

{ TInterval }

function TInterval.EndTime(const Value: string): TInterval;
begin
  Result := TInterval(Add('endTime', Value));
end;

function TInterval.StartTime(const Value: string): TInterval;
begin
  Result := TInterval(Add('startTime', Value)); 
end;

{ TGoogleSearch }

function TGoogleSearch.TimeRangeFilter(const Value: TInterval): TGoogleSearch;
begin
  Result := TGoogleSearch(Add('timeRangeFilter', Value.Detach)); 
end;

{ TComputerUse }

function TComputerUse.Environment(const Value: TEnvironmentType): TComputerUse;
begin
  Result := TComputerUse(Add('environment', Value.ToString)); 
end;

function TComputerUse.ExcludedPredefinedFunctions(
  const Value: TArray<string>): TComputerUse;
begin
  Result := TComputerUse(Add('excludedPredefinedFunctions', Value)); 
end;

{ TFileSearch }

function TFileSearch.FileSearchStoreNames(
  const Value: TArray<string>): TFileSearch;
begin
  Result := TFileSearch(Add('fileSearchStoreNames', Value)); 
end;

function TFileSearch.MetadataFilter(const Value: string): TFileSearch;
begin
  Result := TFileSearch(Add('metadataFilter', Value));
end;

function TFileSearch.TopK(const Value: Integer): TFileSearch;
begin
  Result := TFileSearch(Add('topK', Value));
end;

{ TGoogleMaps }

function TGoogleMaps.EnableWidget(const Value: Boolean): TGoogleMaps;
begin
  Result := TGoogleMaps(Add('enableWidget', Value)); 
end;

{ TToolParams }

function TToolParams.CodeExecution(const Value: TCodeExecution): TToolParams;
begin
  Result := TToolParams(Add('codeExecution', Value.Detach));
end;

function TToolParams.ComputerUse(const Value: TComputerUse): TToolParams;
begin
  Result := TToolParams(Add('computerUse', Value.Detach));
end;

function TToolParams.FileSearch(const Value: TFileSearch): TToolParams;
begin
  Result := TToolParams(Add('fileSearch', Value.Detach));
end;

function TToolParams.FunctionDeclarations(const Value: TArray<TFunctionDeclarations>): TToolParams;
begin
  Result := TToolParams(Add('functionDeclarations',
    TJSONHelper.ToJsonArray<TFunctionDeclarations>(Value)));
end;

function TToolParams.GoogleMaps(const Value: TGoogleMaps): TToolParams;
begin
  Result := TToolParams(Add('googleMaps', Value.Detach));
end;

function TToolParams.GoogleSearch(const Value: TGoogleSearch): TToolParams;
begin
  Result := TToolParams(Add('googleSearch', Value.Detach));
end;

function TToolParams.GoogleSearchRetrieval(
  const Value: TGoogleSearchRetrieval): TToolParams;
begin
  Result := TToolParams(Add('googleSearchRetrieval', Value.Detach));
end;

class function TToolParams.NewCodeExecution(
  const Value: TCodeExecution): TToolParams;
begin
  Result := TToolParams.Create.CodeExecution(Value);
end;

class function TToolParams.NewComputerUse(
  const Value: TComputerUse): TToolParams;
begin
  Result := TToolParams.Create.ComputerUse(Value);
end;

class function TToolParams.NewFileSearch(const Value: TFileSearch): TToolParams;
begin
  Result := TToolParams.Create.FileSearch(Value);
end;

class function TToolParams.NewFunctionDeclarations(
  const Value: TArray<TFunctionDeclarations>): TToolParams;
begin
  Result := TToolParams.Create.FunctionDeclarations(Value);
end;

class function TToolParams.NewGoogleMaps(const Value: TGoogleMaps): TToolParams;
begin
  Result := TToolParams.Create.GoogleMaps(Value);
end;

class function TToolParams.NewGoogleSearch(
  const Value: TGoogleSearch): TToolParams;
begin
  Result := TToolParams.Create.GoogleSearch(Value);
end;

class function TToolParams.NewGoogleSearchRetrieval(
  const Value: TGoogleSearchRetrieval): TToolParams;
begin
  Result := TToolParams.Create.GoogleSearchRetrieval(Value);
end;

class function TToolParams.NewUrlContext(const Value: TUrlContext): TToolParams;
begin
  Result := TToolParams.Create.UrlContext(Value);
end;

function TToolParams.UrlContext(const Value: TUrlContext): TToolParams;
begin
  Result := TToolParams(Add('urlContext', Value.Detach));
end;

end.
