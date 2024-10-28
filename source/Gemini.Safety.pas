unit Gemini.Safety;

interface

uses
  System.SysUtils, System.Classes, REST.JsonReflect, System.JSON, REST.Json.Types,
  Gemini.API.Params;

type
  /// <summary>
  /// Block at and beyond a specified harm probability.
  /// </summary>
  THarmBlockThreshold = (
    /// <summary>
    /// Threshold is unspecified.
    /// </summary>
    HARM_BLOCK_THRESHOLD_UNSPECIFIED,
    /// <summary>
    /// Content with NEGLIGIBLE will be allowed.
    /// </summary>
    BLOCK_LOW_AND_ABOVE,
    /// <summary>
    /// Content with NEGLIGIBLE and LOW will be allowed.
    /// </summary>
    BLOCK_MEDIUM_AND_ABOVE,
    /// <summary>
    /// Content with NEGLIGIBLE, LOW, and MEDIUM will be allowed.
    /// </summary>
    BLOCK_ONLY_HIGH,
    /// <summary>
    /// All content will be allowed.
    /// </summary>
    BLOCK_NONE,
    /// <summary>
    /// Turn off the safety filter.
    /// </summary>
    OFF
  );

  THarmBlockThresholdHelper = record helper for THarmBlockThreshold
    function ToString: string;
  end;

  /// <summary>
  /// The category of a rating.
  /// </summary>
  /// <remarks>
  /// These categories cover various kinds of harms that developers may wish to adjust.
  /// </remarks>
  THarmCategory = (
    /// <summary>
    /// Harassment content.
    /// </summary>
    /// <remarks>
    /// Works only with a Gemini-type model.
    /// </remarks>
    HARM_CATEGORY_HARASSMENT,
    /// <summary>
    /// Hate speech and content.
    /// </summary>
    /// <remarks>
    /// Works only with a Gemini-type model.
    /// </remarks>
    HARM_CATEGORY_HATE_SPEECH,
    /// <summary>
    /// Sexually explicit content.
    /// </summary>
    /// <remarks>
    /// Works only with a Gemini-type model.
    /// </remarks>
    HARM_CATEGORY_SEXUALLY_EXPLICIT,
    /// <summary>
    /// Dangerous content.
    /// </summary>
    /// <remarks>
    /// Works only with a Gemini-type model.
    /// </remarks>
    HARM_CATEGORY_DANGEROUS_CONTENT,
    /// <summary>
    /// Content that may be used to harm civic integrity.
    /// </summary>
    /// <remarks>
    /// Works only with a Gemini-type model.
    /// </remarks>
    HARM_CATEGORY_CIVIC_INTEGRITY
  );

  THarmCategoryHelper = record helper for THarmCategory
    function ToString: string;
    class function Create(const Value: string): THarmCategory; static;
  end;

  THarmCategoryInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// Specifies the reason why the prompt was blocked.
  /// </summary>
  TBlockReason = (
    /// <summary>
    /// Default value. This value is unused.
    /// </summary>
    BLOCK_REASON_UNSPECIFIED,
    /// <summary>
    /// Prompt was blocked due to safety reasons. Inspect safetyRatings to understand which safety category blocked it.
    /// </summary>
    SAFETY,
    /// <summary>
    /// Prompt was blocked due to unknown reasons.
    /// </summary>
    OTHER,
    /// <summary>
    /// Prompt was blocked due to the terms which are included from the terminology blocklist.
    /// </summary>
    BLOCKLIST,
    /// <summary>
    /// Prompt was blocked due to prohibited content.
    /// </summary>
    PROHIBITED_CONTENT
  );

  TBlockReasonHelper = record helper for TBlockReason
    function ToString: string;
    class function Create(const Value: string): TBlockReason; static;
  end;

  TBlockReasonInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  /// <summary>
  /// The probability that a piece of content is harmful.
  /// </summary>
  /// <remarks>
  /// The classification system gives the probability of the content being unsafe. This does not indicate the severity of harm for a piece of content.
  /// </remarks>
  THarmProbability = (
    /// <summary>
    /// Probability is unspecified.
    /// </summary>
    HARM_PROBABILITY_UNSPECIFIED,
    /// <summary>
    /// Content has a negligible chance of being unsafe.
    /// </summary>
    NEGLIGIBLE,
    /// <summary>
    /// Content has a low chance of being unsafe.
    /// </summary>
    LOW,
    /// <summary>
    /// Content has a medium chance of being unsafe.
    /// </summary>
    MEDIUM,
    /// <summary>
    /// Content has a high chance of being unsafe.
    /// </summary>
    HIGH
  );

  THarmProbabilityHelper = record helper for THarmProbability
    function ToString: string;
    class function Create(const Value: string): THarmProbability; static;
  end;

  THarmProbabilityInterceptor = class(TJSONInterceptorStringToString)
    function StringConverter(Data: TObject; Field: string): string; override;
    procedure StringReverter(Data: TObject; Field: string; Arg: string); override;
  end;

  TSafety = record
  private
    FCategory: THarmCategory;
    FThreshold: THarmBlockThreshold;
  public
    function Category(Value: THarmCategory): TSafety;
    function Threshold(Value: THarmBlockThreshold): TSafety;
    function ToJson: TJSONObject;
    class function New(Category: THarmCategory; Threshold: THarmBlockThreshold): TSafety; static;
    class function DontBlock: TArray<TSafety>; static;
    class function SexuallyExplicit(const Value: THarmBlockThreshold): TSafety; static;
    class function HateSpeech(const Value: THarmBlockThreshold): TSafety; static;
    class function Harassment(const Value: THarmBlockThreshold): TSafety; static;
    class function DangerousContent(const Value: THarmBlockThreshold): TSafety; static;
    class function CivicIntegrity(const Value: THarmBlockThreshold): TSafety; static;
  end;

implementation

uses
  System.StrUtils, System.Rtti, Rest.Json;

{ THarmBlockThresholdHelper }

function THarmBlockThresholdHelper.ToString: string;
begin
  case Self of
    HARM_BLOCK_THRESHOLD_UNSPECIFIED:
      Exit('HARM_BLOCK_THRESHOLD_UNSPECIFIED');
    BLOCK_LOW_AND_ABOVE:
      Exit('BLOCK_LOW_AND_ABOVE');
    BLOCK_MEDIUM_AND_ABOVE:
      Exit('BLOCK_MEDIUM_AND_ABOVE');
    BLOCK_ONLY_HIGH:
      Exit('BLOCK_ONLY_HIGH');
    BLOCK_NONE:
      Exit('BLOCK_NONE');
    OFF:
      Exit('OFF');
  end;
end;

{ THarmCategoryHelper }

class function THarmCategoryHelper.Create(const Value: string): THarmCategory;
begin
  var Index := IndexStr(AnsiUpperCase(Value), [
        'HARM_CATEGORY_HARASSMENT', 'HARM_CATEGORY_HATE_SPEECH',
        'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'HARM_CATEGORY_DANGEROUS_CONTENT',
        'HARM_CATEGORY_CIVIC_INTEGRITY' ]);
  if Index = -1 then
    raise Exception.CreateFmt('"HarmCategory" unknown : %s', [Value]);
  Result := THarmCategory(Index);
end;

function THarmCategoryHelper.ToString: string;
begin
  case Self of
    HARM_CATEGORY_HARASSMENT:
      Exit('HARM_CATEGORY_HARASSMENT');
    HARM_CATEGORY_HATE_SPEECH:
      Exit('HARM_CATEGORY_HATE_SPEECH');
    HARM_CATEGORY_SEXUALLY_EXPLICIT:
      Exit('HARM_CATEGORY_SEXUALLY_EXPLICIT');
    HARM_CATEGORY_DANGEROUS_CONTENT:
      Exit('HARM_CATEGORY_DANGEROUS_CONTENT');
    HARM_CATEGORY_CIVIC_INTEGRITY:
      Exit('HARM_CATEGORY_CIVIC_INTEGRITY');
  end;
end;

{ THarmCategoryInterceptor }

function THarmCategoryInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<THarmCategory>.ToString;
end;

procedure THarmCategoryInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(THarmCategory.Create(Arg)));
end;

{ TBlockReasonHelper }

class function TBlockReasonHelper.Create(const Value: string): TBlockReason;
begin
  var Index := IndexStr(AnsiUpperCase(Value), [
        'BLOCK_REASON_UNSPECIFIED', 'SAFETY', 'OTHER', 'BLOCKLIST', 'PROHIBITED_CONTENT' ]);
  if Index = -1 then
    raise Exception.CreateFmt('"BlockReason" unknown : %s', [Value]);
  Result := TBlockReason(Index);
end;

function TBlockReasonHelper.ToString: string;
begin
  case Self of
    BLOCK_REASON_UNSPECIFIED:
      Exit('BLOCK_REASON_UNSPECIFIED');
    SAFETY:
      Exit('SAFETY');
    OTHER:
      Exit('OTHER');
    BLOCKLIST:
      Exit('BLOCKLIST');
    PROHIBITED_CONTENT:
      Exit('PROHIBITED_CONTENT');
  end;
end;

{ TBlockReasonInterceptor }

function TBlockReasonInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<TBlockReason>.ToString;
end;

procedure TBlockReasonInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(TBlockReason.Create(Arg)));
end;

{ THarmProbabilityHelper }

class function THarmProbabilityHelper.Create(
  const Value: string): THarmProbability;
begin
  var Index := IndexStr(AnsiUpperCase(Value), [
         'HARM_PROBABILITY_UNSPECIFIED', 'NEGLIGIBLE', 'LOW', 'MEDIUM', 'HIGH']);
  if Index = -1 then
    raise Exception.CreateFmt('"HarmProbability" unknown : %s', [Value]);
  Result := THarmProbability(Index);
end;

function THarmProbabilityHelper.ToString: string;
begin
  case Self of
    HARM_PROBABILITY_UNSPECIFIED:
      Exit('HARM_PROBABILITY_UNSPECIFIED');
    NEGLIGIBLE:
      Exit('NEGLIGIBLE');
    LOW:
      Exit('LOW');
    MEDIUM:
      Exit('MEDIUM');
    HIGH:
      Exit('HIGH');
  end;
end;

{ THarmProbabilityInterceptor }

function THarmProbabilityInterceptor.StringConverter(Data: TObject;
  Field: string): string;
begin
  Result := RTTI.GetType(Data.ClassType).GetField(Field).GetValue(Data).AsType<THarmProbability>.ToString;
end;

procedure THarmProbabilityInterceptor.StringReverter(Data: TObject; Field,
  Arg: string);
begin
  RTTI.GetType(Data.ClassType).GetField(Field).SetValue(Data, TValue.From(THarmProbability.Create(Arg)));
end;

{ TSafety }

function TSafety.Category(Value: THarmCategory): TSafety;
begin
  FCategory := Value;
  Result := Self;
end;

class function TSafety.CivicIntegrity(
  const Value: THarmBlockThreshold): TSafety;
begin
  Result := TSafety.New(HARM_CATEGORY_CIVIC_INTEGRITY, Value);
end;

class function TSafety.DangerousContent(
  const Value: THarmBlockThreshold): TSafety;
begin
  Result := TSafety.New(HARM_CATEGORY_DANGEROUS_CONTENT, Value);
end;

class function TSafety.DontBlock: TArray<TSafety>;
begin
  Result := [
    SexuallyExplicit(BLOCK_NONE),
    HateSpeech(BLOCK_NONE),
    Harassment(BLOCK_NONE),
    DangerousContent(BLOCK_NONE),
    CivicIntegrity(BLOCK_NONE)];
end;

class function TSafety.Harassment(
  const Value: THarmBlockThreshold): TSafety;
begin
  Result := TSafety.New(HARM_CATEGORY_HARASSMENT, Value);
end;

class function TSafety.HateSpeech(
  const Value: THarmBlockThreshold): TSafety;
begin
  Result := TSafety.New(HARM_CATEGORY_HATE_SPEECH, Value);
end;

class function TSafety.New(Category: THarmCategory;
  Threshold: THarmBlockThreshold): TSafety;
begin
  Result := Result.Category(Category).Threshold(Threshold);
end;

class function TSafety.SexuallyExplicit(
  const Value: THarmBlockThreshold): TSafety;
begin
  Result := TSafety.New(HARM_CATEGORY_SEXUALLY_EXPLICIT, Value);
end;

function TSafety.Threshold(Value: THarmBlockThreshold): TSafety;
begin
  FThreshold := Value;
  Result := Self;
end;

function TSafety.ToJson: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.
    AddPair('category', FCategory.ToString).
    AddPair('threshold', FThreshold.ToString);
end;

end.
