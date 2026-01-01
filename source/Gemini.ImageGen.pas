unit Gemini.ImageGen;

interface

uses
  System.SysUtils, System.JSON,
  REST.JsonReflect, REST.Json.Types,
  Gemini.API, Gemini.API.Params, Gemini.Types,
  Gemini.Async.Support, Gemini.Async.Promise, Gemini.Exceptions, Gemini.Operation,
  Gemini.Net.MediaCodec, Gemini.Models, Gemini.JsonPathHelper;

type
  TImageGenInstanceParams = class(TJSONParam)
    /// <summary>
    /// Required. The text prompt for the image.
    /// </summary>
    function Prompt(const Value: string): TImageGenInstanceParams;

    /// <summary>
    /// Optional. An optional parameter to use an LLM-based prompt rewriting feature to deliver higher
    /// quality images that better reflect the original prompt's intent. Disabling this feature may
    /// impact image quality and prompt adherence.
    /// </summary>
    function EnhancePrompt(const Value: Boolean): TImageGenInstanceParams;

    /// <summary>
    /// Optional. Add an invisible watermark to the generated images.
    /// </summary>
    /// <remarks>
    /// The default value is true.
    /// </remarks>
    function AddWatermark(const Value: Boolean): TImageGenInstanceParams;

    class function New(const Value: TImageGenInstanceParams): TImageGenInstanceParams;
  end;

  TImageGenParameters = class(TJSONParam)
    /// <summary>
    /// Optional. Changes the aspect ratio of the generated image
    /// </summary>
    /// <param name="Value">
    /// Supported values are "1:1", "3:4", "4:3", "9:16", and "16:9". The default is "1:1"
    /// </param>
    function AspectRatio(const Value: string): TImageGenParameters;

    /// <summary>
    /// Optional. Specifies the generated image's output resolution.
    /// </summary>
    /// <param name="Value">
    /// The accepted values are "1K" or "2K". The default value is "1K".
    /// </param>
    function ImageSize(const Value: string): TImageGenParameters;

    /// <summary>
    /// Required. The number of images to generate.
    /// </summary>
    /// <param name="Value">
    /// From 1 to 4 (inclusive). The default is 4.
    /// </param>
    function NumberOfImages(const Value: Integer): TImageGenParameters;

    /// <summary>
    /// Optional. Allow generation of people by the model.
    /// </summary>
    /// <param name="Value">
    /// The following values are supported:
    /// <para>
    /// • "dont_allow": Disallow the inclusion of people or faces in images.
    /// </para>
    /// <para>
    /// • "allow_adult": Allow generation of adults only.
    /// </para>
    /// <para>
    /// • "allow_all": Allow generation of people of all ages.
    /// </para>
    /// </param>
    /// <remarks>
    /// The default value is "allow_adult".
    /// </remarks>
    function PersonGeneration(const Value: string): TImageGenParameters;
  end;

  TImageGenParams = class(TPredictParams)
    /// <summary>
    /// Required. The instances that are the input to the prediction call.
    /// </summary>
    function Instances(const Value: TArray<TJSONObject>): TImageGenParams; overload;

    /// <summary>
    /// Required. The instances that are the input to the prediction call.
    /// </summary>
    /// <param name="Value">
    /// A JSONArray string
    /// </param>
    function Instances(const Value: string): TImageGenParams; overload;

    /// <summary>
    /// Required. The instances that are the input to the prediction call.
    /// </summary>
    function Instances(const Value: TArray<TImageGenInstanceParams>): TImageGenParams; overload;

    /// <summary>
    /// Optional. The parameters that govern the prediction call.
    /// </summary>
    function Parameters(const Value: TJSONObject): TImageGenParams; overload;

    /// <summary>
    /// Optional. The parameters that govern the prediction call.
    /// </summary>
    /// <param name="Value">
    /// A JSON string
    /// </param>
    function Parameters(const Value: string): TImageGenParams; overload;

    /// <summary>
    /// Optional. The parameters that govern the prediction call.
    /// </summary>
    function Parameters(const Value: TImageGenParameters): TImageGenParams; overload;
  end;

  TImageGenPrediction = class
  private
    FBytesBase64Encoded: string;
    FMimeType: string;
    FPrompt: string;
  public
    /// <summary>
    /// The base64 encoded generated image. Not present if the output image did not pass responsible AI
    /// filters.
    /// </summary>
    property BytesBase64Encoded: string read FBytesBase64Encoded write FBytesBase64Encoded;

    /// <summary>
    /// The type of the generated image. Not present if the output image did not pass responsible AI filters.
    /// </summary>
    property MimeType: string read FMimeType write FMimeType;

    /// <summary>
    /// If you use a model that supports prompt enhancement, the response includes an additional prompt
    /// field with the enhanced prompt used for generation:
    /// </summary>
    property Prompt: string read FPrompt write FPrompt;
  end;

  TImageGen = class(TJSONFingerprint)
  private
    FPredictions: TArray<TImageGenPrediction>;
  public
    property Predictions: TArray<TImageGenPrediction> read FPredictions write FPredictions;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Asynchronous callback record specialized for image generation operations.
  /// </summary>
  /// <remarks>
  /// <c>TAsynImageGen</c> is an alias of <see cref="TAsynCallBack{T}"/> specialized with
  /// <see cref="TImageGen"/>. It is used to receive lifecycle notifications for an asynchronous
  /// image generation request:
  /// <para>
  /// • <c>OnStart</c> is invoked when the request begins.
  /// </para>
  /// <para>
  /// • <c>OnSuccess</c> is invoked when the request completes successfully and provides the resulting
  /// <see cref="TImageGen"/> instance.
  /// </para>
  /// <para>
  /// • <c>OnError</c> is invoked when the request fails and provides an error message.
  /// </para>
  /// The <c>Sender</c> property can be used to carry context about the originator of the operation.
  /// </remarks>
  TAsynImageGen = TAsynCallback<TImageGen>;

  /// <summary>
  /// Promise-style callback record specialized for image generation operations.
  /// </summary>
  /// <remarks>
  /// <c>TPromiseImageGen</c> is an alias of <see cref="TPromiseCallBack{T}"/> specialized with
  /// <see cref="TImageGen"/>. It is used to define promise-style lifecycle handlers for an
  /// asynchronous image generation request:
  /// <para>
  /// • <c>OnStart</c> is invoked when the request begins.
  /// </para>
  /// <para>
  /// • <c>OnSuccess</c> is invoked when the request completes successfully and can return a string
  /// derived from the resolved <see cref="TImageGen"/> (for logging/UI messaging).
  /// </para>
  /// <para>
  /// • <c>OnError</c> is invoked when the request fails and can return a string derived from the error
  /// message (for normalization or user-facing messaging).
  /// </para>
  /// The <c>Sender</c> property can be used to carry context about the originator of the operation.
  /// </remarks>
  TPromiseImageGen = TPromiseCallback<TImageGen>;

  TAbstractSupport = class(TGeminiAPIRoute)
  protected
    function Create(const ModelName: string; ParamProc: TProc<TImageGenParams>): TImageGen; virtual; abstract;
  end;

  TAsynchronousSupport = class(TAbstractSupport)
  protected
    procedure AsynCreate(const ModelName: string;
      const ParamProc: TProc<TImageGenParams>;
      const CallBacks: TFunc<TAsynImageGen>);
  end;

  TImageGenRoute = class(TAsynchronousSupport)
    /// <summary>
    /// Creates an image generation request and returns a <see cref="TImageGen"/> instance containing
    /// the model's predictions.
    /// </summary>
    /// <param name="ModelName">
    /// The image generation model name to use (for example, <c>imagen-3.0-generate-001</c>).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the <see cref="TImageGenParams"/> sent to the model (instances,
    /// parameters, etc.).
    /// </param>
    /// <returns>
    /// A <see cref="TImageGen"/> instance representing the model response.
    /// <para>
    /// • The returned response typically contains one or more items in <c>Predictions</c>, where each
    /// prediction may include <c>BytesBase64Encoded</c>, <c>MimeType</c>, and (when supported) the
    /// enhanced <c>Prompt</c>.
    /// </para>
    /// <para>
    /// • If responsible AI filters block an output, the corresponding prediction may omit the image
    /// bytes and mime type.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This is the synchronous (blocking) version of image generation. For non-blocking usage,
    /// prefer <see cref="AsyncAwaitCreate"/>.
    /// </para>
    /// <para>
    /// • The returned instance must be freed by the caller.
    /// </para>
    /// </remarks>
    function Create(const ModelName: string; ParamProc: TProc<TImageGenParams>): TImageGen; override;

    /// <summary>
    /// Creates an image generation request asynchronously and resolves with the resulting
    /// <see cref="TImageGen"/> instance returned by the API.
    /// </summary>
    /// <param name="ModelName">
    /// The image generation model name to use (for example, <c>imagen-3.0-generate-001</c>).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the <see cref="TImageGenParams"/> sent to the model (instances,
    /// parameters, etc.).
    /// </param>
    /// <param name="Callbacks">
    /// Optional promise-style callbacks invoked during the request lifecycle.
    /// <para>
    /// • <c>OnStart</c> is called when the request begins.
    /// </para>
    /// <para>
    /// • <c>OnSuccess</c> can be used to produce a string message from the resolved <see cref="TImageGen"/>.
    /// </para>
    /// <para>
    /// • <c>OnError</c> can be used to produce a string message from an error.
    /// </para>
    /// </param>
    /// <returns>
    /// A promise that resolves to a <see cref="TImageGen"/> instance representing the model response.
    /// <para>
    /// • The resolved response typically contains one or more items in <c>Predictions</c>, where each
    /// prediction may include <c>BytesBase64Encoded</c>, <c>MimeType</c>, and (when supported) the
    /// enhanced <c>Prompt</c>.
    /// </para>
    /// <para>
    /// • If the request fails, the promise is rejected with an exception.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method performs the request asynchronously. The resolved <see cref="TImageGen"/> instance
    /// is released by the async support layer after callbacks complete. If you need to keep the data,
    /// copy out the relevant fields (for example, copy <c>Predictions</c> content) within the promise chain
    /// or inside <c>OnSuccess</c>.
    /// </para>
    /// </remarks>
    function AsyncAwaitCreate(
      const ModelName: string;
      const ParamProc: TProc<TImageGenParams>;
      const Callbacks: TFunc<TPromiseImageGen> = nil): TPromise<TImageGen>;
  end;

implementation

{ TImageGenParams }

function TImageGenParams.Instances(
  const Value: TArray<TJSONObject>): TImageGenParams;
begin
  Result := TImageGenParams(inherited Instances(Value));
end;

function TImageGenParams.Instances(const Value: string): TImageGenParams;
begin
  Result := TImageGenParams(inherited Instances(Value));
end;

function TImageGenParams.Instances(
  const Value: TArray<TImageGenInstanceParams>): TImageGenParams;
begin
  Result := TImageGenParams(Add('instances',
    TJSONHelper.ToJsonArray<TImageGenInstanceParams>(Value)));
end;

function TImageGenParams.Parameters(
  const Value: TImageGenParameters): TImageGenParams;
begin
  Result := TImageGenParams(Add('parameters', Value.Detach));
end;

function TImageGenParams.Parameters(const Value: string): TImageGenParams;
begin
  Result := TImageGenParams(inherited Parameters(Value));
end;

function TImageGenParams.Parameters(const Value: TJSONObject): TImageGenParams;
begin
  Result := TImageGenParams(inherited Parameters(Value));
end;

{ TImageGen }

destructor TImageGen.Destroy;
begin
  for var Item in FPredictions do
    Item.Free;
  inherited;
end;

{ TImageGenRoute }

function TImageGenRoute.AsyncAwaitCreate(const ModelName: string;
  const ParamProc: TProc<TImageGenParams>;
  const Callbacks: TFunc<TPromiseImageGen>): TPromise<TImageGen>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TImageGen>(
    procedure(const CallbackParams: TFunc<TAsynImageGen>)
    begin
      Self.AsynCreate(ModelName, ParamProc, CallbackParams);
    end,
    Callbacks);
end;

function TImageGenRoute.Create(const ModelName: string;
  ParamProc: TProc<TImageGenParams>): TImageGen;
begin
  Result := API.Post<TImageGen, TImageGenParams>(
    ModelNormalize(ModelName) + ':predict',
    ParamProc, True);
end;

{ TImageGenInstanceParams }

function TImageGenInstanceParams.AddWatermark(
  const Value: Boolean): TImageGenInstanceParams;
begin
  Result := TImageGenInstanceParams(Add('addWatermark', Value));
end;

function TImageGenInstanceParams.EnhancePrompt(
  const Value: Boolean): TImageGenInstanceParams;
begin
  Result := TImageGenInstanceParams(Add('enhancePrompt', Value));
end;

class function TImageGenInstanceParams.New(
  const Value: TImageGenInstanceParams): TImageGenInstanceParams;
begin
  Result := Value;
end;

function TImageGenInstanceParams.Prompt(
  const Value: string): TImageGenInstanceParams;
begin
  Result := TImageGenInstanceParams(Add('prompt', Value));
end;

{ TImageGenParameters }

function TImageGenParameters.AspectRatio(
  const Value: string): TImageGenParameters;
begin
  Result := TImageGenParameters(Add('aspectRatio', Value));
end;

function TImageGenParameters.ImageSize(
  const Value: string): TImageGenParameters;
begin
  Result := TImageGenParameters(Add('sampleImageSize', Value));
end;

function TImageGenParameters.NumberOfImages(
  const Value: Integer): TImageGenParameters;
begin
  Result := TImageGenParameters(Add('sampleCount', Value));
end;

function TImageGenParameters.PersonGeneration(
  const Value: string): TImageGenParameters;
begin
  Result := TImageGenParameters(Add('personGeneration', Value));
end;

{ TAsynchronousSupport }

procedure TAsynchronousSupport.AsynCreate(const ModelName: string;
  const ParamProc: TProc<TImageGenParams>;
  const CallBacks: TFunc<TAsynImageGen>);
begin
  with TAsynCallBackExec<TAsynImageGen, TImageGen>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TImageGen
      begin
        Result := Self.Create(ModelName, ParamProc);
      end);
  finally
    Free;
  end;
end;

end.
