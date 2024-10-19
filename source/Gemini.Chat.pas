unit Gemini.Chat;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, System.Threading,
  REST.Json.Types, Gemini.API.Params, Gemini.API, Gemini.Safety, Gemini.Schema,
  Gemini.Tools,

  Vcl.Dialogs;

type
  TMessageRole = (
    user,
    model
  );

  TFinishReason = (
    /// <summary>
    /// Default value. This value is unused.
    /// </summary>
    FINISH_REASON_UNSPECIFIED,
    /// <summary>
    /// Natural stop point of the model or provided stop sequence.
    /// </summary>
    STOP,
    /// <summary>
    /// The maximum number of tokens as specified in the request was reached.
    /// </summary>
    MAX_TOKENS,
    /// <summary>
    /// The response candidate content was flagged for safety reasons.
    /// </summary>
    SAFETY,
    /// <summary>
    /// The response candidate content was flagged for recitation reasons.
    /// </summary>
    RECITATION,
    /// <summary>
    /// The response candidate content was flagged for using an unsupported language.
    /// </summary>
    LANGUAGE,
    /// <summary>
    ///  Unknown reason.
    /// </summary>
    OTHER,
    /// <summary>
    /// Token generation stopped because the content contains forbidden terms.
    /// </summary>
    BLOCKLIST,
    /// <summary>
    /// Token generation stopped for potentially containing prohibited content.
    /// </summary>
    PROHIBITED_CONTENT,
    /// <summary>
    /// Token generation stopped because the content potentially contains Sensitive Personally Identifiable Information (SPII).
    /// </summary>
    SPII,
    /// <summary>
    /// The function call generated by the model is invalid.
    /// </summary>
    MALFORMED_FUNCTION_CALL
  );

  TFinishReasonHelper = record helper for TFinishReason
    function ToString: string;
    class function Create(const Value: string): TFinishReason; static;
  end;

  TFinishReasonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TMessageRoleHelper = record helper for TMessageRole
    function ToString: string;
  end;

  TContentPayload = record
  private
    FRole: TMessageRole;
    FText: string;
  public
    function Role(const Value: TMessageRole): TContentPayload;
    function Text(const Value: string): TContentPayload;
    function ToJSON: TJSONObject;
    class function New(Role: TMessageRole; Text: string): TContentPayload; static;
  end;

  TGenerationConfig = class(TJSONParam)
  public
    function StopSequences(const Value: TArray<string>): TGenerationConfig;
    function ResponseMimeType(const Value: string): TGenerationConfig;
    function ResponseSchema(const Value: TSchemaParams): TGenerationConfig; overload;
    function ResponseSchema(const ParamProc: TProcRef<TSchemaParams>): TGenerationConfig; overload;
    function CandidateCount(const Value: Integer): TGenerationConfig;
    function MaxOutputTokens(const Value: Integer): TGenerationConfig;
    function Temperature(const Value: Double): TGenerationConfig;
    function TopP(const Value: Double): TGenerationConfig;
    function TopK(const Value: Integer): TGenerationConfig;
    function PresencePenalty(const Value: Double): TGenerationConfig;
    function FrequencyPenalty(const Value: Double): TGenerationConfig;
    function ResponseLogprobs(const Value: Boolean): TGenerationConfig;
    function Logprobs(const Value: Integer): TGenerationConfig;
    class function New: TGenerationConfig; overload;
    class function New(const ParamProc: TProcRef<TGenerationConfig>): TGenerationConfig; overload;
  end;

  TChatParams = class(TJSONParam)
    function Contents(const Value: TArray<TContentPayload>): TChatParams;
    function Tools(const Value: TArray<TToolParams>): TChatParams;
    function ToolConfig(const Value: TToolConfig): TChatParams;
    function SafetySettings(const Value: TArray<TSafetyParams>): TChatParams;
    function SystemInstruction(const Value: string): TChatParams;
    function GenerationConfig(const ParamProc: TProcRef<TGenerationConfig>): TChatParams;
    function CachedContent(const Value: string): TChatParams;
    class function New: TChatParams; overload;
    class function New(const ParamProc: TProcRef<TChatParams>): TChatParams; overload;
  end;

  TChatPart = class
  private
    FText: string;
  public
    property Text: string read FText write FText;
  end;

  TChatContent = class
  private
    FParts: TArray<TChatPart>;
  public
    property Parts: TArray<TChatPart> read FParts write FParts;
    destructor Destroy; override;
  end;

  TSafetyRatings = class
  private
    [JsonReflectAttribute(ctString, rtString, THarmCategoryInterceptor)]
    FCategory: THarmCategory;
    [JsonReflectAttribute(ctString, rtString, THarmProbabilityInterceptor)]
    FProbability: THarmProbability;
    FBlocked: Boolean;
  public
    property Category: THarmCategory read FCategory write FCategory;
    property Probability: THarmProbability read FProbability write FProbability;
    property Blocked: Boolean read FBlocked write FBlocked;
  end;

  TCitationSource = class
  private
    FStartIndex: Int64;
    FEndIndex: Int64;
    FUri: string;
    FLicense: string;
  public
    property StartIndex: Int64 read FStartIndex write FStartIndex;
    property EndIndex: Int64 read FEndIndex write FEndIndex;
    property Uri: string read FUri write FUri;
    property License: string read FLicense write FLicense;
  end;

  TCitationMetadata = class
  private
    FCitationSources: TArray<TCitationSource>;
  public
    property CitationSources: TArray<TCitationSource> read FCitationSources write FCitationSources;
    destructor Destroy; override;
  end;

  TCandidate = class
  private
    FToken: string;
    FTokenId: Int64;
    FLogProbability: Double;
  public
    property Token: string read FToken write FToken;
    property TokenId: Int64 read FTokenId write FTokenId;
    property LogProbability: Double read FLogProbability write FLogProbability;
  end;

  TTopCandidates = class
  private
    FCandidates: TArray<TCandidate>;
  public
    property Candidates: TArray<TCandidate> read Fcandidates write Fcandidates;
  end;

  TLogprobsResult = class
  private
    FTopCandidates: TArray<TTopCandidates>;
    FChosenCandidates: TArray<TCandidate>;
  public
    property TopCandidates: TArray<TTopCandidates> read FTopCandidates write FTopCandidates;
    property ChosenCandidates: TArray<TCandidate> read FChosenCandidates write FChosenCandidates;
    destructor Destroy; override;
  end;

  TChatCandidate = class
  private
    FContent: TChatContent;
    [JsonReflectAttribute(ctString, rtString, TFinishReasonInterceptor)]
    FFinishReason: TFinishReason;
    FSafetyRatings: TArray<TSafetyRatings>;
    FCitationMetadata: TCitationMetadata;
    FTokenCount: Int64;
    FAvgLogprobs: Double;
    FLogprobsResult: TLogprobsResult;
    FIndex: Int64;
  public
    property Content: TChatContent read FContent write FContent;
    property FinishReason: TFinishReason read FFinishReason write FFinishReason;
    property SafetyRatings: TArray<TSafetyRatings> read FSafetyRatings write FSafetyRatings;
    property CitationMetadata: TCitationMetadata read FCitationMetadata write FCitationMetadata;
    property TokenCount: Int64 read FTokenCount write FTokenCount;
    property AvgLogprobs: Double read FAvgLogprobs write FAvgLogprobs;
    property LogprobsResult: TLogprobsResult read FLogprobsResult write FLogprobsResult;
    property Index: Int64 read FIndex write FIndex;
    destructor Destroy; override;
  end;

  TPromptFeedback = class
  private
    [JsonReflectAttribute(ctString, rtString, TBlockReasonInterceptor)]
    FBlockReason: TBlockReason;
    FSafetyRatings: TArray<TsafetyRatings>;
  public
    property BlockReason: TBlockReason read FBlockReason write FBlockReason;
    property SafetyRatings: TArray<TsafetyRatings> read FSafetyRatings write FSafetyRatings;
    destructor Destroy; override;
  end;

  TUsageMetadata = class
  private
    FPromptTokenCount: Int64;
    FCachedContentTokenCount: Int64;
    FCandidatesTokenCount: Int64;
    FTotalTokenCount: Int64;
  public
    property PromptTokenCount: Int64 read FPromptTokenCount write FPromptTokenCount;
    property CachedContentTokenCount: Int64 read FCachedContentTokenCount write FCachedContentTokenCount;
    property CandidatesTokenCount: Int64 read FCandidatesTokenCount write FCandidatesTokenCount;
    property TotalTokenCount: Int64 read FTotalTokenCount write FTotalTokenCount;
  end;

  TChat = class
  private
    FCandidates: TArray<TChatCandidate>;
    FPromptFeedback: TPromptFeedback;
    FUsageMetadata: TUsageMetadata;
  public
    property Candidates: TArray<TChatCandidate> read FCandidates write FCandidates;
    property PromptFeedback: TPromptFeedback read FPromptFeedback write FPromptFeedback;
    property UsageMetadata: TUsageMetadata read FUsageMetadata write FUsageMetadata;
    destructor Destroy; override;
  end;

  TChatRoute = class(TGeminiAPIRoute)
  public
    function Create(const ModelName: string; ParamProc: TProc<TChatParams>): TChat;
  end;

implementation

uses
  System.StrUtils, System.Math, System.Rtti, Rest.Json;

{ TChatRoute }

function TChatRoute.Create(const ModelName: string; ParamProc: TProc<TChatParams>): TChat;
begin
  GeminiLock.Acquire;
  try
    Result := API.Post<TChat, TChatParams>(SetModel(ModelName, ':generateContent'), ParamProc);
  finally
    GeminiLock.Release;
  end;
end;

{ TChatParams }

function TChatParams.CachedContent(const Value: string): TChatParams;
begin
  Result := TChatParams(Add('cachedContent', Format('cachedContents/%s', [Value])));
end;

function TChatParams.Contents(
  const Value: TArray<TContentPayload>): TChatParams;
begin
  var JSONContents := TJSONArray.Create;
  for var Item in Value do
    JSONContents.Add(Item.ToJSON);

  Result := TChatParams(Add('contents', JSONContents));
end;

function TChatParams.GenerationConfig(const ParamProc: TProcRef<TGenerationConfig>): TChatParams;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TGenerationConfig.Create;
      ParamProc(Value);
      Result := TChatParams(Add('generationConfig', Value.Detach));
    end
  else Result := Self;
end;

class function TChatParams.New(
  const ParamProc: TProcRef<TChatParams>): TChatParams;
begin
  Result := TChatParams.Create;
  if Assigned(ParamProc) then
    begin
      ParamProc(Result);
    end;
end;

class function TChatParams.New: TChatParams;
begin
  Result := TChatParams.Create;
end;

function TChatParams.SafetySettings(
  const Value: TArray<TSafetyParams>): TChatParams;
begin
  var JSONSafetySettings := TJSONArray.Create;
  for var Item in Value do
    JSONSafetySettings.Add(Item.ToJson);
  Result := TChatParams(Add('safetySettings', JSONSafetySettings));
end;

function TChatParams.SystemInstruction(const Value: string): TChatParams;
begin
  var PartsJSON := TJSONObject.Create.AddPair('parts', TJSONObject.Create.AddPair('text', Value));
  Result := TChatParams(Add('system_instruction', PartsJSON));
end;

function TChatParams.ToolConfig(const Value: TToolConfig): TChatParams;
begin
  Result := TChatParams(Add('toolConfig', Value.Detach));
end;

function TChatParams.Tools(const Value: TArray<TToolParams>): TChatParams;
begin
  var JSONTools := TJSONArray.Create;
  for var Item in Value do
    begin
      JSONTools.Add(Item.Detach);
    end;
  Result := TChatParams(Add('tools', JSONTools));
end;

{ TMessageRoleHelper }

function TMessageRoleHelper.ToString: string;
begin
  case Self of
    user:
      Exit('user');
    model:
      Exit('model');
  end;
end;

{ TContentPayload }

class function TContentPayload.New(Role: TMessageRole;
  Text: string): TContentPayload;
begin
  Result := Result.Role(Role).Text(Text);
end;

function TContentPayload.Role(const Value: TMessageRole): TContentPayload;
begin
  FRole := Value;
  Result := Self;
end;

function TContentPayload.Text(const Value: string): TContentPayload;
begin
  FText := Value;
  Result := Self;
end;

function TContentPayload.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('role', FRole.ToString);
  Result.AddPair('parts',
    TJSONArray.Create.Add(
      TJSONObject.Create.AddPair('text', FText)));
end;

{ TChat }

destructor TChat.Destroy;
begin
  for var Item in FCandidates do
    Item.Free;
  if Assigned(FPromptFeedback) then
    FPromptFeedback.Free;
  if Assigned(FUsageMetadata) then
    FUsageMetadata.Free;
  inherited;
end;

{ TChatCandidate }

destructor TChatCandidate.Destroy;
begin
  if Assigned(FContent) then
    FContent.Free;
  for var Item in FSafetyRatings do
    Item.Free;
  if Assigned(FCitationMetadata) then
    FCitationMetadata.Free;
  if Assigned(FlogprobsResult) then
    FlogprobsResult.Free;
  inherited;
end;

{ TChatContent }

destructor TChatContent.Destroy;
begin
  for var Item in FParts do
    Item.Free;
  inherited;
end;

{ TPromptFeedback }

destructor TPromptFeedback.Destroy;
begin
  for var Item in FSafetyRatings do
    Item.Free;
  inherited;
end;

{ TFinishReasonHelper }

class function TFinishReasonHelper.Create(const Value: string): TFinishReason;
begin
  var Index := IndexStr(AnsiUpperCase(Value), [
         'FINISH_REASON_UNSPECIFIED', 'STOP', 'MAX_TOKENS', 'SAFETY',
         'RECITATION', 'LANGUAGE', 'OTHER', 'BLOCKLIST', 'PROHIBITED_CONTENT',
         'SPII', 'MALFORMED_FUNCTION_CALL']);
  if Index = -1 then
    raise Exception.CreateFmt('"FinishReason" unknown : %s', [Value]);
  Result := TFinishReason(Index);
end;

function TFinishReasonHelper.ToString: string;
begin
  case Self of
    FINISH_REASON_UNSPECIFIED:
      Exit('FINISH_REASON_UNSPECIFIED');
    STOP:
      Exit('STOP');
    MAX_TOKENS:
      Exit('MAX_TOKENS');
    SAFETY:
      Exit('SAFETY');
    RECITATION:
      Exit('RECITATION');
    LANGUAGE:
      Exit('LANGUAGE');
    OTHER:
      Exit('OTHER');
    BLOCKLIST:
      Exit('BLOCKLIST');
    PROHIBITED_CONTENT:
      Exit('PROHIBITED_CONTENT');
    SPII:
      Exit('SPII');
    MALFORMED_FUNCTION_CALL:
      Exit('MALFORMED_FUNCTION_CALL');
  end;
end;

{ TFinishReasonInterceptor }

function TFinishReasonInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TFinishReason>.ToString;
end;

procedure TFinishReasonInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TFinishReason.Create(Arg)));
end;

{ TCitationMetadata }

destructor TCitationMetadata.Destroy;
begin
  for var Item in FCitationSources do
    Item.Free;
  inherited;
end;

{ TLogprobsResult }

destructor TLogprobsResult.Destroy;
begin
  for var Item in FTopCandidates do
    Item.Free;
  for var Item in FChosenCandidates do
    Item.Free;
  inherited;
end;

{ TGenerationConfig }

function TGenerationConfig.CandidateCount(
  const Value: Integer): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('candidateCount', Value));
end;

function TGenerationConfig.FrequencyPenalty(
  const Value: Double): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('frequencyPenalty', Value));
end;

function TGenerationConfig.Logprobs(const Value: Integer): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('logprobs', Value));
end;

function TGenerationConfig.MaxOutputTokens(const Value: Integer): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('maxOutputTokens', Value));
end;

class function TGenerationConfig.New(
  const ParamProc: TProcRef<TGenerationConfig>): TGenerationConfig;
begin
  Result := TGenerationConfig.Create;
  if Assigned(ParamProc) then
    begin
      ParamProc(Result);
    end;
end;

function TGenerationConfig.PresencePenalty(
  const Value: Double): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('presencePenalty', Value));
end;

class function TGenerationConfig.New: TGenerationConfig;
begin
  Result := TGenerationConfig.Create;
end;

function TGenerationConfig.ResponseLogprobs(
  const Value: Boolean): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('responseLogprobs', Value));
end;

function TGenerationConfig.ResponseMimeType(const Value: string): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('responseMimeType', Value));
end;

function TGenerationConfig.ResponseSchema(
  const ParamProc: TProcRef<TSchemaParams>): TGenerationConfig;
begin
  if Assigned(ParamProc) then
    begin
      var Value := TSchemaParams.Create;
      ParamProc(Value);
      Result := TGenerationConfig(Add('responseSchema', Value.Detach));
    end
  else Result := Self;
end;

function TGenerationConfig.ResponseSchema(
  const Value: TSchemaParams): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('responseSchema', Value.Detach));
end;

function TGenerationConfig.StopSequences(
  const Value: TArray<string>): TGenerationConfig;
begin
  if Length(Value) = 0 then
    Exit(Self);

  Result := TGenerationConfig(Add('stopSequences', Value));
end;

function TGenerationConfig.Temperature(const Value: Double): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('temperature', Value));
end;

function TGenerationConfig.TopK(const Value: Integer): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('topK', Value));
end;

function TGenerationConfig.TopP(const Value: Double): TGenerationConfig;
begin
  Result := TGenerationConfig(Add('topP', Value));
end;

end.
