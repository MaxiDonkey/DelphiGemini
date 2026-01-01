unit Gemini.Chat.Request.Content;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.JSON, Gemini.API.Params, Gemini.Types,
  Gemini.Exceptions;

type
  TAttachedManager = record
  public
    class function ToJson(const FilePath: string): TJSONObject; static;
  end;

  TDataPartParams = class(TJSONParam);

  TInlineDataParams = class(TDataPartParams)
    /// <summary>
    /// The IANA standard MIME type of the source data.
    /// </summary>
    /// <remarks>
    /// Examples: - image/png - image/jpeg If an unsupported MIME type is provided, an error will be returned.
    /// </remarks>
    function MimeType(const Value: string): TInlineDataParams;

    /// <summary>
    /// Raw bytes for media formats.
    /// </summary>
    /// <remarks>
    /// A base64-encoded string.
    /// </remarks>
    function Data(const Value: string): TInlineDataParams;
  end;

  TFunctionCallParams = class(TDataPartParams)
    /// <summary>
    /// Optional. The unique id of the function call. If populated, the client to execute the functionCall
    /// and return the response with the matching id.
    /// </summary>
    function Id(const Value: string): TFunctionCallParams;

    /// <summary>
    /// Required. The name of the function to call. Must be a-z, A-Z, 0-9, or contain underscores and dashes,
    /// with a maximum length of 64.
    /// </summary>
    function Name(const Value: string): TFunctionCallParams;

    /// <summary>
    /// Optional. The function parameters and values in JSON object format.
    /// </summary>
    function Args(const Value: TJSONObject): TFunctionCallParams; overload;

    /// <summary>
    /// Optional. The function parameters and values in JSON object format.
    /// </summary>
    /// <param name="Value">
    /// A JSON string  
    /// </param>
    function Args(const Value: string): TFunctionCallParams; overload;
  end;

  TFunctionResponsePartParams = class(TJSONParam)
    /// <summary>
    /// Inline media bytes.
    /// </summary>
    function InlineData(const Value: TInlineDataParams): TFunctionResponsePartParams;
  end;

  TFunctionResponseParams = class(TDataPartParams)
    /// <summary>
    /// Optional. The id of the function call this response is for. Populated by the client to match
    /// the corresponding function call id.
    /// </summary>
    function Id(const Value: string): TFunctionResponseParams;

    /// <summary>
    /// Required. The name of the function to call. Must be a-z, A-Z, 0-9, or contain underscores and
    /// dashes, with a maximum length of 64.
    /// </summary>
    function Name(const Value: string): TFunctionResponseParams;

    /// <summary>
    /// Required. The function response in JSON object format. Callers can use any keys of their choice
    /// that fit the function's syntax to return the function output, e.g. "output", "result", etc.
    /// In particular, if the function call failed to execute, the response can have an "error" key to
    /// return error details to the model.
    /// </summary>
    function Response(const Value: TJSONObject): TFunctionResponseParams; overload;

    /// <summary>
    /// Required. The function response in JSON object format. Callers can use any keys of their choice
    /// that fit the function's syntax to return the function output, e.g. "output", "result", etc.
    /// In particular, if the function call failed to execute, the response can have an "error" key to
    /// return error details to the model.
    /// </summary>
    /// <param name="Value">
    /// A JSON string
    /// </param>
    function Response(const Value: string): TFunctionResponseParams; overload;

    /// <summary>
    /// Optional. Ordered Parts that constitute a function response. Parts may have different IANA MIME types.
    /// </summary>
    function Parts(const Value: TArray<TFunctionResponsePartParams>): TFunctionResponseParams; overload;

    /// <summary>
    /// Optional. Ordered Parts that constitute a function response. Parts may have different IANA MIME types.
    /// </summary>
    /// <param name="Value">
    /// A JSONArray string
    /// </param>
    function Parts(const Value: string): TFunctionResponseParams; overload;

    /// <summary>
    /// Optional. Signals that function call continues, and more responses will be returned, turning the
    /// function call into a generator. Is only applicable to NON_BLOCKING function calls, is ignored
    /// otherwise. If set to false, future responses will not be considered. It is allowed to return empty
    /// response with willContinue=False to signal that the function call is finished. This may still trigger
    /// the model generation. To avoid triggering the generation and finish the function call, additionally
    /// set scheduling to SILENT.
    /// </summary>
    function WillContinue(const Value: Boolean): TFunctionResponseParams;

    /// <summary>
    /// Optional. Specifies how the response should be scheduled in the conversation. Only applicable to
    /// NON_BLOCKING function calls, is ignored otherwise. Defaults to WHEN_IDLE.
    /// </summary>
    function Scheduling(const Value: TSchedulingType): TFunctionResponseParams;
  end;

  TFileDataParams = class(TDataPartParams)
    /// <summary>
    /// The IANA standard MIME type of the source data.
    /// </summary>
    function MimeType(const Value: string): TFileDataParams;

    /// <summary>
    /// Uri of thsdata
    /// </summary>
    function FileUri(const Value: string): TFileDataParams;
  end;

  TExecutableCodeParams = class(TDataPartParams)
    /// <summary>
    /// Required. Programming language of the code.
    /// </summary>
    function Language(const Value: TLanguageType): TExecutableCodeParams;

    /// <summary>
    /// Required. The code to be executed.
    /// </summary>
    function Code(const Value: string): TExecutableCodeParams;
  end;

  TCodeExecutionResultParams = class(TDataPartParams)
    /// <summary>
    /// Required. Outcome of the code execution.
    /// </summary>
    function Outcome(const Value: TOutcomeType): TCodeExecutionResultParams;

    /// <summary>
    /// Optional. Contains stdout when code execution is successful, stderr or other description otherwise.
    /// </summary>
    function Output(const Value: string): TCodeExecutionResultParams;
  end;

  TMetadataPartParams = class(TJSONParam);

  TVideoMetadata = class(TMetadataPartParams)
    /// <summary>
    /// Optional. The start offset of the video.
    /// </summary>
    /// <remarks>
    /// A duration in seconds with up to nine fractional digits,
    /// </remarks>
    function StartOffset(const Value: string): TVideoMetadata;

    /// <summary>
    /// Optional. The end offset of the video.
    /// </summary>
    /// <remarks>
    /// A duration in seconds with up to nine fractional digits, ending with 's'. Example: "3.5s".
    /// </remarks>
    function EndOffset(const Value: string): TVideoMetadata;

    /// <summary>
    /// Optional. The frame rate of the video sent to the model. If not specified, the default value will be 1.0.
    /// The fps range is (0.0, 24.0].
    /// </summary>
    function Fps(const Value: Double): TVideoMetadata;
  end;

  TPartParams = class(TJSONParam)
    /// <summary>
    /// Optional. Indicates if the part is thought from the model.
    /// </summary>
    function Thought(const Value: Boolean): TPartParams;

    /// <summary>
    /// Optional. An opaque signature for the thought so it can be reused in subsequent requests.
    /// </summary>
    /// <remarks>
    /// A base64-encoded string.
    /// </remarks>
    function ThoughtSignature(const Value: string): TPartParams;

    /// <summary>
    /// Custom metadata associated with the Part. Agents using genai.Part as content representation may need
    /// to keep track of the additional information. For example it can be name of a file/source from which
    /// the Part originates or a way to multiplex multiple Part streams.
    /// </summary>
    function PartMetadata(const Value: TJSONObject): TPartParams;

    /// <summary>
    /// Inline text.
    /// </summary>
    function Text(const Value: string): TPartParams;

    /// <summary>
    /// Inline media bytes.
    /// </summary>
    function InlineData(const Value: TInlineDataParams): TPartParams;

    /// <summary>
    /// A predicted FunctionCall returned from the model that contains a string representing
    /// the FunctionDeclaration.name with the arguments and their values.
    /// </summary>
    function FunctionCall(const Value: TFunctionCallParams): TPartParams; overload;

    /// <summary>
    /// A predicted FunctionCall returned from the model that contains a string representing
    /// the FunctionDeclaration.name with the arguments and their values.
    /// </summary>
    /// <param name="Value">
    /// A JSON string
    /// </param>
    function FunctionCall(const Value: string): TPartParams; overload;

    /// <summary>
    /// The result output of a FunctionCall that contains a string representing the FunctionDeclaration.name
    /// and a structured JSON object containing any output from the function is used as context to the model.
    /// </summary>
    function FunctionResponse(const Value: TFunctionResponseParams): TPartParams; overload;

    /// <summary>
    /// The result output of a FunctionCall that contains a string representing the FunctionDeclaration.name
    /// and a structured JSON object containing any output from the function is used as context to the model.
    /// </summary>
    /// <param name="Value">
    /// A JSON string
    /// </param>
    function FunctionResponse(const Value: string): TPartParams; overload;

    /// <summary>
    /// URI based data.
    /// </summary>
    function FileData(const Value: TFileDataParams): TPartParams;

    /// <summary>
    /// Code generated by the model that is meant to be executed.
    /// </summary>
    function ExecutableCode(const Value: TExecutableCodeParams): TPartParams; overload;

    /// <summary>
    /// Code generated by the model that is meant to be executed.
    /// </summary>
    /// <param name="Value">
    /// A JSON string  
    /// </param>
    function ExecutableCode(const Value: string): TPartParams; overload;

    /// <summary>
    /// Result of executing the ExecutableCode.
    /// </summary>
    function CodeExecutionResult(const Value: TCodeExecutionResultParams): TPartParams; overload;

    /// <summary>
    /// Result of executing the ExecutableCode.
    /// </summary>
    /// <param name="Value">
    /// A JSON string  
    /// </param>
    function CodeExecutionResult(const Value: string): TPartParams; overload;

    /// <summary>
    /// Optional. Video metadata. The metadata should only be specified while the video data is presented
    /// in inlineData or fileData.
    /// </summary>
    function VideoMetadata(const Value: TVideoMetadata): TPartParams;

    class function NewText(const Text: string; Thought: Boolean = False): TPartParams;
    class function NewInlineData(const Base64: string; const MimeType: string): TPartParams;
    class function NewFileData(const Uri: string; const MimeType: string): TPartParams;
    class function NewFunctionCall(const Name: string): TPartParams;
    class function NewFunctionResponse(const Name: string; const Response: TJSONObject): TPartParams;
    class function NewExecutableCode(const Language: TLanguageType; const Code: string): TPartParams;
    class function NewCodeExecutionResult(const Outcome: TOutcomeType): TPartParams;
  end;

implementation

uses
  Gemini.Net.MediaCodec;

{ TAttachedManager }

class function TAttachedManager.ToJson(const FilePath: string): TJSONObject;
begin
  if TMediaCodec.IsUri(FilePath) then
    begin
      Result := TFileDataParams.Create
        .FileUri(FilePath)
        .Detach;

      Result := TJSONObject.Create.AddPair('fileData', Result);
    end
  else
    begin
      Result := TInlineDataParams.Create
        .MimeType(TMediaCodec.GetMimeType(FilePath))
        .Data(TMediaCodec.EncodeBase64(FilePath))
        .Detach;

      Result := TJSONObject.Create.AddPair('inlineData', Result);
    end;
end;

{ TInlineDataParams }

function TInlineDataParams.Data(const Value: string): TInlineDataParams;
begin
  Result := TInlineDataParams(Add('data', Value));
end;

function TInlineDataParams.MimeType(const Value: string): TInlineDataParams;
begin
  Result := TInlineDataParams(Add('mimeType', Value));
end;


{ TFileDataParams }

function TFileDataParams.FileUri(const Value: string): TFileDataParams;
begin
  Result := TFileDataParams(Add('fileUri', Value));
end;

function TFileDataParams.MimeType(const Value: string): TFileDataParams;
begin
  Result := TFileDataParams(Add('mimeType', Value));
end;

{ TPartParams }

function TPartParams.CodeExecutionResult(
  const Value: TCodeExecutionResultParams): TPartParams;
begin
  Result := TPartParams(Add('codeExecutionResult', Value.Detach));
end;

function TPartParams.CodeExecutionResult(const Value: string): TPartParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TPartParams(Add('codeExecutionResult', JSONObject)));

  raise EGeminiException.Create('Invalid JSON Object');
end;

function TPartParams.ExecutableCode(const Value: TExecutableCodeParams): TPartParams;
begin
  Result := TPartParams(Add('executableCode', Value.Detach));
end;

function TPartParams.ExecutableCode(const Value: string): TPartParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TPartParams(Add('executableCode', JSONObject)));

  raise EGeminiException.Create('Invalid JSON Object');
end;

function TPartParams.FileData(const Value: TFileDataParams): TPartParams;
begin
  Result := TPartParams(Add('fileData', Value.Detach));
end;

function TPartParams.FunctionCall(const Value: TFunctionCallParams): TPartParams;
begin
  Result := TPartParams(Add('functionCall', Value.Detach));
end;

function TPartParams.FunctionCall(const Value: string): TPartParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TPartParams(Add('functionCall', JSONObject)));

  raise EGeminiException.Create('Invalid JSON Object');
end;

function TPartParams.FunctionResponse(const Value: string): TPartParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TPartParams(Add('functionResponse', JSONObject)));

  raise EGeminiException.Create('Invalid JSON Object');
end;

function TPartParams.FunctionResponse(
  const Value: TFunctionResponseParams): TPartParams;
begin
  Result := TPartParams(Add('functionResponse', Value.Detach));
end;

function TPartParams.InlineData(const Value: TInlineDataParams): TPartParams;
begin
  Result := TPartParams(Add('inlineData', Value.Detach));
end;

class function TPartParams.NewCodeExecutionResult(
  const Outcome: TOutcomeType): TPartParams;
begin
  Result := TPartParams.Create;

  var CodeExecutionResult :=
    TCodeExecutionResultParams.Create
      .Outcome(Outcome);

  Result.CodeExecutionResult(CodeExecutionResult);
end;

class function TPartParams.NewExecutableCode(const Language: TLanguageType;
  const Code: string): TPartParams;
begin
  Result := TPartParams.Create;

  var ExecutableCode :=
    TExecutableCodeParams.Create
      .Language(Language)
      .Code(Code);

  Result.ExecutableCode(ExecutableCode);
end;

class function TPartParams.NewFileData(const Uri: string; const MimeType: string): TPartParams;
begin
  Result := TPartParams.Create;

  var FileData :=
    TFileDataParams.Create
      .MimeType(MimeType)
      .FileUri(Uri);

  Result.FileData(FileData);
end;

class function TPartParams.NewFunctionCall(const Name: string): TPartParams;
begin
  Result := TPartParams.Create;

  var FunctionCall := TFunctionCallParams.Create.Name(Name);

  Result.FunctionCall(FunctionCall);
end;

class function TPartParams.NewFunctionResponse(const Name: string;
  const Response: TJSONObject): TPartParams;
begin
  Result := TPartParams.Create;

  var FunctionResponse := TFunctionResponseParams.Create
        .Name(Name)
        .Response(Response);

  Result.FunctionResponse(FunctionResponse);
end;

class function TPartParams.NewInlineData(
  const Base64, MimeType: string): TPartParams;
begin
  Result := TPartParams.Create;

  var InlineData :=
    TInlineDataParams.Create
      .MimeType(MimeType)
      .Data(Base64);

  Result.InlineData(InlineData);
end;

class function TPartParams.NewText(const Text: string; Thought: Boolean): TPartParams;
begin
  Result := TPartParams.Create;

  if Thought then
    Result.Thought(True);

  Result.Text(Text);
end;

function TPartParams.PartMetadata(const Value: TJSONObject): TPartParams;
begin
  Result := TPartParams(Add('partMetadata', Value));
end;

function TPartParams.Text(const Value: string): TPartParams;
begin
  Result := TPartParams(Add('text', Value));
end;

function TPartParams.Thought(const Value: Boolean): TPartParams;
begin
  Result := TPartParams(Add('thought', Value));
end;

function TPartParams.ThoughtSignature(const Value: string): TPartParams;
begin
  Result := TPartParams(Add('thoughtSignature', Value));
end;

function TPartParams.VideoMetadata(const Value: TVideoMetadata): TPartParams;
begin
  Result := TPartParams(Add('videoMetadata', Value.Detach));
end;

{ TFunctionCallParams }

function TFunctionCallParams.Args(const Value: TJSONObject): TFunctionCallParams;
begin
  Result := TFunctionCallParams(Add('args', Value));
end;

function TFunctionCallParams.Args(const Value: string): TFunctionCallParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TFunctionCallParams(Add('args', JSONObject)));

  raise EGeminiException.Create('Invalid JSON Object');
end;

function TFunctionCallParams.Id(const Value: string): TFunctionCallParams;
begin
  Result := TFunctionCallParams(Add('id', Value));
end;

function TFunctionCallParams.Name(const Value: string): TFunctionCallParams;
begin
  Result := TFunctionCallParams(Add('name', Value));
end;

{ TFunctionResponseParams }

function TFunctionResponseParams.Id(const Value: string): TFunctionResponseParams;
begin
  Result := TFunctionResponseParams(Add('id', Value));
end;

function TFunctionResponseParams.Name(const Value: string): TFunctionResponseParams;
begin
  Result := TFunctionResponseParams(Add('name', Value));
end;

function TFunctionResponseParams.Parts(
  const Value: string): TFunctionResponseParams;
var
  JSONArray: TJSONArray;
begin
  if TJSONHelper.TryGetArray(Value, JSONArray) then
    Exit(TFunctionResponseParams(Add('parts', JSONArray)));

  raise EGeminiException.Create('Invalid JSON Array');
end;

function TFunctionResponseParams.Parts(
  const Value: TArray<TFunctionResponsePartParams>): TFunctionResponseParams;
begin
  Result := TFunctionResponseParams(Add('parts',
    TJSONHelper.ToJsonArray<TFunctionResponsePartParams>(Value)));
end;

function TFunctionResponseParams.Response(
  const Value: string): TFunctionResponseParams;
var
  JSONObject: TJSONObject;
begin
  if TJSONHelper.TryGetObject(Value, JSONObject) then
    Exit(TFunctionResponseParams(Add('response', JSONObject)));

  raise EGeminiException.Create('Invalid JSON Object');
end;

function TFunctionResponseParams.Response(
  const Value: TJSONObject): TFunctionResponseParams;
begin
  Result := TFunctionResponseParams(Add('response', Value));
end;

function TFunctionResponseParams.Scheduling(
  const Value: TSchedulingType): TFunctionResponseParams;
begin
  Result := TFunctionResponseParams(Add('scheduling', Value.ToString));
end;

function TFunctionResponseParams.WillContinue(
  const Value: Boolean): TFunctionResponseParams;
begin
  Result := TFunctionResponseParams(Add('willContinue', Value));
end;

{ TFunctionResponsePartParams }

function TFunctionResponsePartParams.InlineData(
  const Value: TInlineDataParams): TFunctionResponsePartParams;
begin
  Result := TFunctionResponsePartParams(Add('inlineData', Value.Detach));
end;

{ TExecutableCodeParams }

function TExecutableCodeParams.Code(const Value: string): TExecutableCodeParams;
begin
  Result := TExecutableCodeParams(Add('code', Value));
end;

function TExecutableCodeParams.Language(const Value: TLanguageType): TExecutableCodeParams;
begin
  Result := TExecutableCodeParams(Add('language', Value.ToString));
end;

{ TCodeExecutionResultParams }

function TCodeExecutionResultParams.Outcome(
  const Value: TOutcomeType): TCodeExecutionResultParams;
begin
  Result := TCodeExecutionResultParams(Add('outcome', Value.ToString));
end;

function TCodeExecutionResultParams.Output(const Value: string): TCodeExecutionResultParams;
begin
  Result := TCodeExecutionResultParams(Add('output', Value));
end;

{ TVideoMetadata }

function TVideoMetadata.EndOffset(const Value: string): TVideoMetadata;
begin
  Result := TVideoMetadata(Add('endOffset', Value));
end;

function TVideoMetadata.Fps(const Value: Double): TVideoMetadata;
begin
  Result := TVideoMetadata(Add('fps', Value));
end;

function TVideoMetadata.StartOffset(const Value: string): TVideoMetadata;
begin
  Result := TVideoMetadata(Add('startOffset', Value));
end;

end.
