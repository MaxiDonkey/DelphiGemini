unit Gemini.Helpers;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  Gemini.API.Params, Gemini.Types, Gemini.API.ArrayBuilder,
  Gemini.Chat.Request, Gemini.Chat.Request.Content,
  Gemini.Chat.Request.GenerationConfig, Gemini.Chat.Request.Tools,
  Gemini.Embeddings, Gemini.Batch, Gemini.Interactions, Gemini.Interactions.Content,
  Gemini.Interactions.Tools, Gemini.Video, Gemini.ImageGen;

type

{$REGION 'Gemini.Chat.Request.Content'}

  TParts = TArrayBuilder<TPartParams>;

  TPartsHelper = record Helper for TParts
    function AddText(const Text: string; Thought: Boolean = False): TParts;
    function AddInlineData(const Base64: string; const MimeType: string): TParts; overload;
    function AddFileData(const Uri: string; const MimeType: string): TParts;
    function AddFunctionCall(const Name: string): TParts;
    function AddFunctionResponse(const Name: string; const Response: TJSONObject): TParts;
    function AddExecutableCode(const Language: TLanguageType; const Code: string): TParts;
    function AddCodeExecutionResult(const Outcome: TOutcomeType): TParts;
  end;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request'}

  TContent = TArrayBuilder<TContentPayload>;

  TContentHelper = record Helper for TContent
    function AddText(const Value: string): TContent; overload;

    function User(const Parts: TParts): TContent; overload;

    function User(const Value: string; const Attached: TArray<string> = []): TContent; overload;

    function User(const Attached: TArray<string>): TContent; overload;

    function Assistant(const Parts: TParts): TContent; overload;

    function Assistant(const Value: string; const Attached: TArray<string> = []): TContent; overload;
  end;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.GenerationConfig'}

  TSpeakerVoice = TArrayBuilder<TSpeakerVoiceConfig>;

  TSpeakerVoiceHelper = record Helper for TSpeakerVoice
    function AddItem(const Speaker: string; const VoiceConfig: TVoiceConfig): TSpeakerVoice; overload;
    function AddItem(const Speaker: string; const VoiceName: string): TSpeakerVoice; overload;
  end;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.Tools'}

  TFunction = TArrayBuilder<TFunctionDeclarations>;

  TFunctionHelper = record Helper for TFunction
    function AddFunction(const Name: string; const Description: string): TFunction;
  end;

  TTools = TArrayBuilder<TToolParams>;

  TToolsHelper = record Helper for TTools
    function AddFunctionDeclarations(const Value: TArray<TFunctionDeclarations>): TTools;
    function AddGoogleSearchRetrieval(const Value: TGoogleSearchRetrieval): TTools;
    function AddCodeExecution(const Value: TCodeExecution = nil): TTools;
    function AddGoogleSearch(const Value: TGoogleSearch = nil): TTools;
    function AddUrlContext(const Value: TUrlContext = nil): TTools;
    function AddComputerUse(const Value: TComputerUse): TTools;
    function AddFileSearch(const Value: TFileSearch): TTools;
    function AddGoogleMaps(const Value: TGoogleMaps): TTools;
  end;

{$ENDREGION}

{$REGION 'Gemini.Embeddings'}
  TBatchEmbeddings = TArrayBuilder<TEmbedContentParams>;

  TBatchEmbeddingsHelper = record Helper for TBatchEmbeddings
    function AddItem(const Model: string; const Content: TArray<string>): TBatchEmbeddings; overload;
    function AddItem(const Model: string; const Content: TContentPayload): TBatchEmbeddings; overload;
  end;

{$ENDREGION}

{$REGION 'Gemini.Batch'}

  TInlineRequest = TArrayBuilder<TInlinedRequestParams>;

  TInlineRequestHelper = record Helper for TInlineRequest
    function AddItem(const Value: TGenerateContentRequestParams): TInlineRequest; overload;
    function AddItem(const Key: string; const Value: TGenerateContentRequestParams): TInlineRequest; overload;
  end;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Content'}

  TThoughtSummary = TArrayBuilder<TThoughtSummaryIxParams>;

  TThoughtSummaryHelper = record Helper for TThoughtSummary
    function AddText(const Value: string): TThoughtSummary;
  end;

  TGoogleSearchResult = TArrayBuilder<TGoogleSearchResultIxParams>;

  TGoogleSearchResultHelper = record Helper for TGoogleSearchResult
    function AddItem: TGoogleSearchResult;
  end;

  TFileSearchResult = TArrayBuilder<TFileSearchResultIxParams>;

  TFileSearchResultHelper = record Helper for TFileSearchResult
    function AddItem: TFileSearchResult; overload;
    function AddItem(const Text: string): TFileSearchResult; overload;
    function AddItem(const Text, Store: string): TFileSearchResult; overload;
    function AddItem(const Title, Text, Store: string): TFileSearchResult; overload;
  end;

  TUrlContextResult = TArrayBuilder<TUrlContextResultIxParams>;

  TUrlContextResultHelper = record Helper for TUrlContextResult
    function AddItem: TUrlContextResult;
  end;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Tools'}

  TToolIx = TArrayBuilder<TToolIxParams>;

  TToolIxHelper = record Helper for TToolIx
    function AddFunction(const Value: TFunctionIxParams): TToolIx;
    function AddGoogleSearch(const Value: TGoogleSearchIxParams = nil): TToolIx;
    function AddCodeExecution(const Value: TCodeExecutionIxParams = nil): TToolIx;
    function AddUrlContext(const Value: TUrlContextIxParams = nil): TToolIx;
    function AddComputerUse(const Value: TComputerUseIxParams): TToolIx;
    function AddMcpServer(const Value: TMcpServerIxParams): TToolIx;
    function AddFileSearch(const Value: TFileSearchIxParams): TToolIx;
  end;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Content'}

  TTurn = TArrayBuilder<TTurnParams>;

  TInputContentHelper = record Helper for TTurn
    function AddUser(const Value: string): TTurn; overload;
    function AddUser(const Content: TArray<TInputParams>): TTurn; overload;
    function AddAssistant(const Value: string): TTurn;
  end;

  TInput = TArrayBuilder<TInputParams>;

  TInputHelper = record Helper for TInput
    function AddText(const Value: string): TInput;
    function AddAudio(const Data64: string; const MimeType: string): TInput; overload;
    function AddAudio(const Uri: string): TInput; overload;
    function AddAudio(const Value: TAudioContentIxParams): TInput; overload;

    function AddDocument(const Data64: string; const MimeType: string): TInput; overload;
    function AddDocument(const Uri: string): TInput; overload;
    function AddDocument(const Value: TDocumentContentIxParams): TInput; overload;

    function AddImage(const Data64: string; const MimeType: string): TInput; overload;
    function AddImage(const Uri: string): TInput; overload;
    function AddImage(const Value: TImageContentIxParams): TInput; overload;

    function AddVideo(const Data64: string; const MimeType: string): TInput; overload;
    function AddVideo(const Uri: string): TInput; overload;
    function AddVideo(const Value: TVideoContentIxParams): TInput; overload;

    function AddFileSearchResult(const Value: TFileSearchResultContentIxParams): TInput; overload;
    function AddFileSearchResult(const AResult: TArray<TFileSearchResultIxParams>): TInput; overload;

    function AddFunctionCall(const Name, Id: string; const Arguments: TJSONObject): TInput; overload;
    function AddFunctionCall(const Name, Id: string; const Arguments: string): TInput; overload;

    function AddFunctionResult(const AResult: string; const Name, CallId: string): TInput; overload;
    function AddFunctionResult(const AResult: TJSONObject; const Name, CallId: string): TInput; overload;

    function AddRaw(const Value: TContentIxParams): TInput;
  end;

{$ENDREGION}

{$REGION 'Gemini.Video'}

  TVideoInstance = TArrayBuilder<TVideoInstanceParams>;

  TInstanceHelper = record Helper for TVideoInstance
    function AddItem(const Value: TVideoInstanceParams): TVideoInstance;
  end;

  TReference = TArrayBuilder<TReferenceImages>;

  TReferenceHelper = record Helper for TReference
    function AddItem(const Image: TImageInstanceParams; ReferenceType: string = ''): TReference;
  end;

  TVideoMedia = record
    class function InstanceList: TVideoInstance; static;
    class function AddInstance: TVideoInstanceParams; static;
    class function ReferenceList: TReference; static;
    class function Base64(const Value64: string; const MimeType: string): TImageInstanceParams; static;
    class function Uri(const Uri: string; const MimeType: string): TImageInstanceParams; static;
    class function MaskBase64(const Value64: string; const MimeType: string; const MaskMode: string): TImageInstanceParams; static;
    class function MaskUri(const Uri: string; const MimeType: string; const MaskMode: string): TImageInstanceParams; static;
  end;

{$ENDREGION}

{$REGION 'Gemini.ImageGen'}

  TImageGenInstance = TArrayBuilder<TImageGenInstanceParams>;

  TImageGenInstanceHelper = record Helper for TImageGenInstance
    function AddItem(const Value: TImageGenInstanceParams): TImageGenInstance;
  end;

  TImageGenMedia = record
    class function InstanceList: TImageGenInstance; static;
    class function Prompt(const Value: string): TImageGenInstanceParams; static;
  end;

{$ENDREGION}

implementation

{$REGION 'dev note'}

(*

  The Gemini.Helpers unit provides fluent helper records around TArrayBuilder<T>
  to streamline the construction of chat request payloads. The goal is to let
  callers assemble complex, JSON-ready structures (parts, content messages,
  speaker configurations, tool declarations, etc.) using a natural chained
  syntax without manually managing dynamic array growth or dealing with the
  underlying JSON representation.

  Each helper wraps specific payload types (TPartParams, TContentPayload,
  TSpeakerVoiceConfig, TFunctionDeclarations, TToolParams) and exposes
  expressive AddXXX() methods that append elements via TArrayBuilder<T>.
  This allows developers to focus on the semantic structure they want to build
  rather than on the container mechanics.

  The result is a higher-level, declarative API that keeps user code compact,
  readable, and less error-prone, especially when producing nested arrays that
  map directly to the final JSON structures consumed by the API.

*)

{$ENDREGION}

{ TContentHelper }

function TContentHelper.Assistant(const Parts: TParts): TContent;
begin
  Result := Self.Add(TContentPayload.Assistant(TArray<TPartParams>(Parts)));
end;

function TContentHelper.AddText(const Value: string): TContent;
begin
  Result := Self.Add(TContentPayload.Add(Value));
end;

function TContentHelper.Assistant(const Value: string;
  const Attached: TArray<string>): TContent;
begin
  Result := Self.Add(TContentPayload.Assistant(Value, Attached));
end;

function TContentHelper.User(const Parts: TParts): TContent;
begin
  Result := Self.Add(TContentPayload.User(TArray<TPartParams>(Parts)));
end;

function TContentHelper.User(const Value: string;
  const Attached: TArray<string>): TContent;
begin
  Result := Self.Add(TContentPayload.User(Value, Attached));
end;

function TContentHelper.User(const Attached: TArray<string>): TContent;
begin
  Result := Self.Add(TContentPayload.User(Attached));
end;

{ TPartsHelper }

function TPartsHelper.AddInlineData(const Base64, MimeType: string): TParts;
begin
  Result := Self.Add(TPartParams.NewInlineData(MimeType, Base64));
end;

function TPartsHelper.AddCodeExecutionResult(
  const Outcome: TOutcomeType): TParts;
begin
  Result := Self.Add(TPartParams.NewCodeExecutionResult(Outcome));
end;

function TPartsHelper.AddExecutableCode(const Language: TLanguageType;
  const Code: string): TParts;
begin
  Result := Self.Add(TPartParams.NewExecutableCode(Language, Code));
end;

function TPartsHelper.AddFileData(const Uri: string; const MimeType: string): TParts;
begin
  Result := Self.Add(TPartParams.NewFileData(Uri, MimeTYpe));
end;

function TPartsHelper.AddFunctionCall(const Name: string): TParts;
begin
  Result := Self.Add(TPartParams.NewFunctionCall(Name));
end;

function TPartsHelper.AddFunctionResponse(const Name: string;
  const Response: TJSONObject): TParts;
begin
  Result := Self.Add(TPartParams.NewFunctionResponse(Name, Response));
end;

function TPartsHelper.AddText(const Text: string; Thought: Boolean): TParts;
begin
  Result := Self.Add(TPartParams.NewText(Text, Thought));
end;

{ TSpeakerVoiceHelper }

function TSpeakerVoiceHelper.AddItem(const Speaker: string;
  const VoiceConfig: TVoiceConfig): TSpeakerVoice;
begin
  Result := Self.Add(TSpeakerVoiceConfig.NewSpeakerVoiceConfig(Speaker, VoiceConfig));
end;

function TSpeakerVoiceHelper.AddItem(const Speaker,
  VoiceName: string): TSpeakerVoice;
begin
  Result := Self.Add(TSpeakerVoiceConfig.NewSpeakerVoiceConfig(Speaker, VoiceName));
end;

{ TFunctionHelper }

function TFunctionHelper.AddFunction(const Name,
  Description: string): TFunction;
begin
  Result := Self.Add(TFunctionDeclarations.NewFunction(Name, Description));
end;

{ TToolsHelper }

function TToolsHelper.AddCodeExecution(const Value: TCodeExecution): TTools;
begin
  Result := Self.Add(TToolParams.NewCodeExecution(Value));
end;

function TToolsHelper.AddComputerUse(const Value: TComputerUse): TTools;
begin
  Result := Self.Add(TToolParams.NewComputerUse(Value));
end;

function TToolsHelper.AddFileSearch(const Value: TFileSearch): TTools;
begin
  Result := Self.Add(TToolParams.NewFileSearch(Value));
end;

function TToolsHelper.AddFunctionDeclarations(
  const Value: TArray<TFunctionDeclarations>): TTools;
begin
  Result := Self.Add(TToolParams.NewFunctionDeclarations(Value));
end;

function TToolsHelper.AddGoogleSearchRetrieval(
  const Value: TGoogleSearchRetrieval): TTools;
begin
  Result := Self.Add(TToolParams.NewGoogleSearchRetrieval(Value));
end;

function TToolsHelper.AddUrlContext(const Value: TUrlContext): TTools;
begin
  Result := Self.Add(TToolParams.NewUrlContext(Value));
end;

function TToolsHelper.AddGoogleMaps(const Value: TGoogleMaps): TTools;
begin
  Result := Self.Add(TToolParams.NewGoogleMaps(Value));
end;

function TToolsHelper.AddGoogleSearch(const Value: TGoogleSearch): TTools;
begin
  Result := Self.Add(TToolParams.NewGoogleSearch(Value));
end;

{ TBatchEmbeddingsHelper }

function TBatchEmbeddingsHelper.AddItem(const Model: string;
  const Content: TArray<string>): TBatchEmbeddings;
begin
  Result := Self.Add(TEmbedContentParams.NewEmbedContentParams(Model, Content));
end;

function TBatchEmbeddingsHelper.AddItem(const Model: string;
  const Content: TContentPayload): TBatchEmbeddings;
begin
  Result := Self.Add(TEmbedContentParams.NewEmbedContentParams(Model, Content));
end;


{ TInlineRequestHelper }

function TInlineRequestHelper.AddItem(
  const Value: TGenerateContentRequestParams): TInlineRequest;
begin
  Result := Self.Add(TInlinedRequestParams.NewRequest(Value));
end;

function TInlineRequestHelper.AddItem(const Key: string;
  const Value: TGenerateContentRequestParams): TInlineRequest;
begin
  Result := Self.Add(TInlinedRequestParams.NewRequest(Key, Value));
end;

{ TThoughtSummaryHelper }

function TThoughtSummaryHelper.AddText(
  const Value: string): TThoughtSummary;
begin
  Result := Self.Add(TThoughtSummaryIxParams.New(Value));
end;

{ TGoogleSearchResultHelper }

function TGoogleSearchResultHelper.AddItem: TGoogleSearchResult;
begin
  Result := Self.Add(TGoogleSearchResultIxParams.New);
end;

{ TFileSearchResultHelper }

function TFileSearchResultHelper.AddItem: TFileSearchResult;
begin
  Result := Self.Add(TFileSearchResultIxParams.New);
end;

function TFileSearchResultHelper.AddItem(const Text: string): TFileSearchResult;
begin
  Result := Self.Add(TFileSearchResultIxParams.New(Text));
end;

function TFileSearchResultHelper.AddItem(const Text,
  Store: string): TFileSearchResult;
begin
  Result := Self.Add(TFileSearchResultIxParams.New(Text, Store));
end;

function TFileSearchResultHelper.AddItem(const Title, Text,
  Store: string): TFileSearchResult;
begin
  Result := Self.Add(TFileSearchResultIxParams.New(Title, Text, Store));
end;

{ TUrlContextResultHelper }

function TUrlContextResultHelper.AddItem: TUrlContextResult;
begin
  Result := Self.Add(TUrlContextResultIxParams.New);
end;

{ TToolIxHelper }

function TToolIxHelper.AddCodeExecution(
  const Value: TCodeExecutionIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddCodeExecution(Value));
end;

function TToolIxHelper.AddComputerUse(
  const Value: TComputerUseIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddComputerUse(Value));
end;

function TToolIxHelper.AddFileSearch(const Value: TFileSearchIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddFileSearch(Value));
end;

function TToolIxHelper.AddFunction(const Value: TFunctionIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddFunction(Value));
end;

function TToolIxHelper.AddGoogleSearch(
  const Value: TGoogleSearchIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddGoogleSearch(Value));
end;

function TToolIxHelper.AddMcpServer(
  const Value: TMcpServerIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddMcpServer(Value));
end;

function TToolIxHelper.AddUrlContext(const Value: TUrlContextIxParams): TToolIx;
begin
  Result := Self.Add(TToolIxParams.AddUrlContext(Value));
end;

{ TInputContentHelper }

function TInputContentHelper.AddAssistant(const Value: string): TTurn;
begin
  Result := Self.Add(TTurnParams.AddAssistant(Value));
end;

function TInputContentHelper.AddUser(const Value: string): TTurn;
begin
  Result := Self.Add(TTurnParams.AddUser(Value));
end;

function TInputContentHelper.AddUser(
  const Content: TArray<TInputParams>): TTurn;
begin
  Result := Self.Add(TTurnParams.AddUser(Content));
end;

{ TInputHelper }

function TInputHelper.AddAudio(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddAudio(Uri));
end;

function TInputHelper.AddAudio(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddAudio(Data64, MimeType));
end;

function TInputHelper.AddAudio(const Value: TAudioContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddAudio(Value));
end;


function TInputHelper.AddDocument(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddDocument(Data64, MimeType));
end;

function TInputHelper.AddDocument(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddDocument(Uri));
end;

function TInputHelper.AddDocument(
  const Value: TDocumentContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddDocument(Value));
end;

function TInputHelper.AddFileSearchResult(
  const AResult: TArray<TFileSearchResultIxParams>): TInput;
begin
  Result := Self.Add(TInputParams.AddFileSearchResult(AResult));
end;

function TInputHelper.AddFileSearchResult(
  const Value: TFileSearchResultContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddFileSearchResult(Value));
end;

function TInputHelper.AddFunctionCall(const Name, Id,
  Arguments: string): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionCall(Name, Id, Arguments));
end;

function TInputHelper.AddFunctionCall(const Name, Id: string;
  const Arguments: TJSONObject): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionCall(Name, Id, Arguments));
end;

function TInputHelper.AddFunctionResult(const AResult: TJSONObject;
  const Name, CallId: string): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionResult(AResult, Name, CallId));
end;

function TInputHelper.AddFunctionResult(const AResult, Name, CallId: string): TInput;
begin
  Result := Self.Add(TInputParams.AddFunctionResult(AResult, Name, CallId));
end;

function TInputHelper.AddImage(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddImage(Uri));
end;

function TInputHelper.AddImage(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddImage(Data64, MimeType));
end;

function TInputHelper.AddImage(const Value: TImageContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddImage(Value));
end;

function TInputHelper.AddRaw(const Value: TContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddRaw(Value));
end;

function TInputHelper.AddText(const Value: string): TInput;
begin
  Result := Self.Add(TInputParams.AddText(Value));
end;

function TInputHelper.AddVideo(const Data64, MimeType: string): TInput;
begin
  Result := Self.Add(TInputParams.AddVideo(Data64, MimeType));
end;

function TInputHelper.AddVideo(const Uri: string): TInput;
begin
  Result := Self.Add(TInputParams.AddVideo(Uri));
end;

function TInputHelper.AddVideo(const Value: TVideoContentIxParams): TInput;
begin
  Result := Self.Add(TInputParams.AddVideo(Value));
end;

{ TInstanceHelper }

function TInstanceHelper.AddItem(const Value: TVideoInstanceParams): TVideoInstance;
begin
  Result := Self.Add(TVideoInstanceParams.New(Value));
end;

{ TReferenceHelper }

function TReferenceHelper.AddItem(const Image: TImageInstanceParams;
  ReferenceType: string): TReference;
begin
  Result := Self.Add(TReferenceImages.NewReference(Image, ReferenceType));
end;

{ TVideoMedia }

class function TVideoMedia.InstanceList: TVideoInstance;
begin
  Result := TVideoInstance.Create();
end;

class function TVideoMedia.AddInstance: TVideoInstanceParams;
begin
  Result := TVideoInstanceParams.Create;
end;

class function TVideoMedia.ReferenceList: TReference;
begin
  Result := TReference.Create();
end;

class function TVideoMedia.Base64(const Value64,
  MimeType: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
    .BytesBase64Encoded(Value64)
    .MimeType(MimeType)
end;

class function TVideoMedia.Uri(const Uri,
  MimeType: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
    .GcsUri(Uri)
    .MimeType(MimeType)
end;

class function TVideoMedia.MaskBase64(const Value64,
  MimeType: string;
  const MaskMode: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
     .BytesBase64Encoded(Value64)
     .MimeType(MimeType);

  if not MaskMode.IsEmpty then
    Result.MaskMode(MaskMode);
end;

class function TVideoMedia.MaskUri(const Uri, MimeType,
  MaskMode: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
     .BytesBase64Encoded(Uri)
     .MimeType(MimeType);

  if not MaskMode.IsEmpty then
    Result.MaskMode(MaskMode);
end;

{ TImageGenInstanceHelper }

function TImageGenInstanceHelper.AddItem(
  const Value: TImageGenInstanceParams): TImageGenInstance;
begin
  Result := Self.Add(TImageGenInstanceParams.New(Value));
end;

{ TImageGenMedia }

class function TImageGenMedia.InstanceList: TImageGenInstance;
begin
  Result := TImageGenInstance.Create;
end;

class function TImageGenMedia.Prompt(
  const Value: string): TImageGenInstanceParams;
begin
  Result := TImageGenInstanceParams.Create
    .Prompt(Value);
end;

end.
