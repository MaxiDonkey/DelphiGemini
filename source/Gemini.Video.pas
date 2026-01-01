unit Gemini.Video;

interface

uses
  System.SysUtils, System.JSON,
  REST.JsonReflect, REST.Json.Types,
  Gemini.API, Gemini.API.Params, Gemini.Types,
  Gemini.Async.Support, Gemini.Async.Promise, Gemini.Exceptions, Gemini.Operation,
  Gemini.Net.MediaCodec, Gemini.Models, Gemini.JsonPathHelper;

type
  TVideoParameters = class(TJSONParam)
    /// <summary>
    /// TOptional. Specifies the aspect ratio of generated videos. The following are accepted values:
    /// </summary>
    /// <param name="paramname">
    /// <para>
    /// • 16:9 (default, 720p and 1080p)
    /// </para>
    /// <para>
    /// • 9:16 (720p and 1080p)
    /// </para>
    /// </param>
    /// <remarks>
    /// The default value is "16:9"
    /// </remarks>
    function AspectRatio(const Value: TVideoAspectRatio): TVideoParameters; overload;

    /// <summary>
    /// TOptional. Specifies the aspect ratio of generated videos. The following are accepted values:
    /// </summary>
    /// <param name="paramname">
    /// <para>
    /// • 16:9 (default, 720p and 1080p)
    /// </para>
    /// <para>
    /// • 9:16 (720p and 1080p)
    /// </para>
    /// </param>
    /// <remarks>
    /// The default value is "16:9"
    /// </remarks>
    function AspectRatio(const Value: string): TVideoParameters; overload;

    /// <summary>
    /// Optional. Specifies the compression quality of the generated videos.
    /// </summary>
    /// <param name="Value">
    /// The accepted values are "optimized" or "lossless".  
    /// </param>
    /// <remarks>
    /// The devault is "optimized".
    /// </remarks>
    function CompressionQuality(const Value: string): TVideoParameters;

    /// <summary>
    /// Required. The length in seconds of video files that you want to generate.
    /// </summary>
    /// <param name="Value">
    /// <para>
    /// • Veo 2 models: 5-8. The default is 8.
    /// </para>
    /// <para>
    /// • Veo 3 models: 4,6, or 8. The default is 8.
    /// </para>
    /// <para>
    /// • When using referenceImages: 8.
    /// </para>
    /// </param>
    /// <remarks>
    /// Must be "8" when using extension or interpolation (supports both 16:9 and 9:16), and when using
    /// referenceImages (only supports 16:9)
    /// </remarks>
    function DurationSeconds(const Value: Integer): TVideoParameters;

    /// <summary>
    /// Optional. Use Gemini to enhance your prompts.
    /// </summary>
    /// <param name="Value">
    /// Accepted values are true or false.
    /// </param>
    /// <remarks>
    /// The default value is true. enhancePrompt is supported by the following models:
    /// <para>
    /// • veo-2.0-generate-001
    /// </para>
    /// <para>
    /// • veo-2.0-generate-preview
    /// </para>
    /// <para>
    /// • veo-2.0-generate-exp
    /// </para>
    /// </remarks>
    function EnhancePrompt(const Value: Boolean): TVideoParameters;

    /// <summary>
    /// Required for Veo 3 models. Generate audio for the video.
    /// </summary>
    /// <param name="Value">
    /// Accepted values are true or false.
    /// </param>
    /// <remarks>
    /// generateAudio isn't supported by veo-2.0-generate-001 or veo-2.0-generate-exp.
    /// </remarks>
    function GenerateAudio(const Value: Boolean): TVideoParameters;

    /// <summary>
    /// Optional. A text string that describes anything you want to discourage the model from generating.
    /// </summary>
    /// <remarks>
    /// For example:
    /// <para>
    /// • overhead lighting, bright colors
    /// </para>
    /// <para>
    /// • people, animals
    /// </para>
    /// <para>
    /// • multiple cars, wind
    /// </para>
    /// </remarks>
    function NegativePrompt(const Value: string): TVideoParameters;

    /// <summary>
    /// Optional. The safety setting that controls whether people or face generation is allowed. One of the following:
    /// </summary>
    /// <param name="Value">
    /// <para>
    /// • "allow_adult" (default value): allow generation of adults only
    /// </para>
    /// <para>
    /// • "dont_allow": disallows inclusion of people/faces in images
    /// </para>
    /// <para>
    /// • "allow_all": Allows the generation of people of all ages. To use this value, your project must be on an allowlist.
    /// </para>
    /// </param>
    function PersonGeneration(const Value: string): TVideoParameters;

    /// <summary>
    /// Optional. Used with image for image-to-video. The resize mode that the model uses to resize the video
    /// </summary>
    /// <param name="Value">
    /// Accepted values:
    /// <para>
    /// • "pad" (default)
    /// </para>
    /// <para>
    /// • "crop"
    /// </para>
    /// </param>
    /// <remarks>
    /// Veo 3 models only.
    /// </remarks>
    function ResizeMode(const Value: string): TVideoParameters;

    /// <summary>
    /// Optional. The resolution of the generated video
    /// </summary>
    /// <param name="Value">
    /// Accepted values:
    /// <para>
    /// • "720p" (default)
    /// </para>
    /// <para>
    /// • "1080p"
    /// </para>
    /// </param>
    /// <remarks>
    /// Veo 3 models only.
    /// </remarks>
    function Resolution(const Value: string): TVideoParameters;

    /// <summary>
    /// Optional. The number of output videos requested.
    /// </summary>
    /// <param name="Value">
    /// Accepted values are 1-4.
    /// </param>
    function SampleCount(const Value: Integer): TVideoParameters;

    /// <summary>
    /// Optional. A number to request to make generated videos deterministic.
    /// </summary>
    /// <param name="Value">
    /// The accepted range is 0-4,294,967,295
    /// </param>
    /// <remarks>
    /// Adding a seed number with your request without changing other parameters will cause the model
    /// to produce the same videos
    /// </remarks>
    function Seed(const Value: Integer): TVideoParameters;

    /// <summary>
    /// Optional. A Cloud Storage bucket URI to store the output video, in the format
    /// gs://BUCKET_NAME/SUBDIRECTORY. If a Cloud Storage bucket isn't provided,
    /// base64-encoded video bytes are returned in the response.
    /// </summary>
    function StorageUri(const Value: string): TVideoParameters;
  end;

  TImageInstanceParams = class(TJSONParam)
    /// <summary>
    /// A bytes base64-encoded string of an image or video file.
    /// </summary>
    function BytesBase64Encoded(const Value: string): TImageInstanceParams;

    /// <summary>
    /// A string URI to a Cloud Storage bucket location.
    /// </summary>
    function GcsUri(const Value: string): TImageInstanceParams;

    /// <summary>
    /// Specifies the mime type of a video or image.
    /// </summary>
    function MimeType(const Value: string): TImageInstanceParams;

    function MaskMode(const Value: string): TImageInstanceParams;

    class function AddBase64(const Base64, MimeType: string; const MaskMode: string = ''): TImageInstanceParams;
    class function AddUri(const Uri, MimeType: string; const MaskMode: string = ''): TImageInstanceParams;
  end;

  TReferenceImages = class(TJSONParam)
    /// <summary>
    /// Optional. Contains the reference images to use as subject matter input. Each image can be either
    /// a bytesBase64Encoded string that encodes an image or a gcsUri string URI to a Cloud Storage bucket
    /// location.
    /// </summary>
    function Image(const Value: TImageInstanceParams): TReferenceImages;

    /// <summary>
    /// Required in a referenceImages object. Specifies the type of reference image provided. The following
    /// values are supported:
    /// </summary>
    /// <param name="Value">
    /// <para>
    /// • "asset": The reference image provides assets for the generated video, such as: the scene, an object,
    /// or a character.
    /// </para>
    /// <para>
    /// • "style": The reference image provides style information for the generated videos, such as: scene
    /// colors, lighting, or texture.
    /// </para>
    /// </param>
    /// <remarks>
    /// IMPORTANT: Veo 3.1 models don't support referenceImages.style. Use veo-2.0-generate-exp when using style
    /// images.
    /// </remarks>
    function ReferenceType(const Value: string): TReferenceImages;

    class function NewReference(const Image: TImageInstanceParams; ReferenceType: string = ''): TReferenceImages;
  end;

  TVideoInstanceParams = class(TJSONParam)
    /// <summary>
    /// <para>
    /// • Required for text-to-video.
    /// </para>
    /// <para>
    /// • Optional if an input image prompt is provided (image-to-video).
    /// </para>
    /// </summary>
    /// <remarks>
    /// A text string to guide the first eight seconds in the video. For example:
    /// <para>
    /// • A fast-tracking shot through a bustling dystopian sprawl with bright neon signs, flying cars and
    /// mist, night, lens flare, volumetric lighting
    /// </para>
    /// <para>
    /// • A neon hologram of a car driving at top speed, speed of light, cinematic, incredible details,
    /// volumetric lighting
    /// </para>
    /// <para>
    /// • Many spotted jellyfish pulsating under water. Their bodies are transparent and glowing in deep
    /// ocean
    /// </para>
    /// <para>
    /// • extreme close-up with a shallow depth of field of a puddle in a street. reflecting a busy
    ///  futuristic Tokyo city with bright neon signs, night, lens flare
    /// </para>
    /// <para>
    /// • Timelapse of the northern lights dancing across the Arctic sky, stars twinkling, snow-covered
    /// landscape
    /// </para>
    /// <para>
    /// •A lone cowboy rides his horse across an open plain at beautiful sunset, soft light, warm colors
    /// </para>
    /// </remarks>
    function Prompt(const Value: string): TVideoInstanceParams;

    /// <summary>
    /// Optional. An image to guide video generation, which can be either a bytesBase64Encoded string
    /// that encodes an image or a gcsUri string URI to a Cloud Storage bucket location.
    /// </summary>
    function Image(const Value: TImageInstanceParams): TVideoInstanceParams;

    /// <summary>
    /// Optional. An image of the last frame of a video to fill the space between. lastFrame can be either
    /// a bytesBase64Encoded string that encodes an image or a gcsUri string URI to a Cloud Storage bucket
    /// location.
    /// </summary>
    /// <remarks>
    /// lastFrame is supported by the following models:
    /// <para>
    /// • veo-2.0-generate-001
    /// </para>
    /// <para>
    /// • veo-3.0-generate-exp
    /// </para>
    /// <para>
    /// • veo-3.1-generate-previe
    /// </para>
    /// <para>
    /// • veo-3.1-fast-generate-preview
    /// </para>
    /// <para>
    /// • veo-3.1-generate-001
    /// </para>
    /// <para>
    /// • veo-3.1-fast-generate-001
    /// </para>
    /// </remarks>
    function LastFrame(const Value: TImageInstanceParams): TVideoInstanceParams;

    /// <summary>
    /// Optional. A Veo generated input video to extend in length. The input video is subject to the
    /// following limitations:
    /// <para>
    /// • The input file must be MP4.
    /// </para>
    /// <para>
    /// • The length must be 1 to 30 seconds.
    /// </para>
    /// <para>
    /// • The frame rate must be 24 frames per second.
    /// </para>
    /// <para>
    /// • The resolution must be either 720p or 1080p.
    /// </para>
    /// <para>
    /// ___________________________________________________________
    /// </para>
    /// <para>
    /// The output video is subject to the following limitations:
    /// </para>
    /// <para>
    /// • The output file is MP4.
    /// </para>
    /// <para>
    /// • The extended length is 7 seconds.
    /// </para>
    /// <para>
    /// • The frame rate is 24 frames per second.
    /// </para>
    /// <para>
    /// • The resolution is 720p.
    /// </para>
    /// </summary>
    /// <remarks>
    /// You can provide either a bytesBase64Encoded string that encodes a video or a gcsUri string URI
    /// to a Cloud Storage bucket location.
    /// <para>
    /// Video is supported by the following models:
    /// </para>
    /// <para>
    /// • veo-2.0-generate-001
    /// </para>
    /// <para>
    /// • veo-3.1-generate-preview
    /// </para>
    /// <para>
    /// • veo-3.1-fast-generate-preview
    /// </para>
    /// </remarks>
    function Video(const Value: TImageInstanceParams): TVideoInstanceParams;

    /// <summary>
    /// Optional. An image of a mask to apply to a video to add or remove an object from a video. mask can
    /// be either a bytesBase64Encoded string that encodes an image or a gcsUri string URI to a Cloud
    /// Storage bucket location.
    /// </summary>
    /// <remarks>
    /// mask is supported by veo-2.0-generate-preview in Preview.
    /// </remarks>
    function Mask(const Value: TImageInstanceParams): TVideoInstanceParams;

    /// <summary>
    /// Optional. A list of up to three asset images or at most one style images that describes the
    /// referenceImages for the model to use when generating videos.
    /// </summary>
    /// <remarks>
    /// <para>
    /// referenceImages is supported by the following models:
    /// </para>
    /// <para>
    /// • veo-2.0-generate-exp
    /// </para>
    /// <para>
    /// • veo-3.1-generate-preview
    /// </para>
    /// <para>
    /// IMPORTANT: Veo 3.1 models don't support referenceImages.style. Use veo-2.0-generate-exp when
    /// using style images.
    /// </para>
    /// </remarks>
    function ReferenceImages(const Value: TArray<TReferenceImages>): TVideoInstanceParams;

    class function New(const Value: TVideoInstanceParams): TVideoInstanceParams;
  end;

  TVideoParams = class(TPredictParams)
    /// <summary>
    /// Required. The instances that are the input to the prediction call.
    /// </summary>
    function Instances(const Value: TArray<TJSONObject>): TVideoParams; overload;

    /// <summary>
    /// Required. The instances that are the input to the prediction call.
    /// </summary>
    /// <param name="Value">
    /// A JSONArray string
    /// </param>
    function Instances(const Value: string): TVideoParams; overload;

    /// <summary>
    /// Required. The instances that are the input to the prediction call.
    /// </summary>
    function Instances(const Value: TArray<TVideoInstanceParams>): TVideoParams; overload;

    /// <summary>
    /// Optional. The parameters that govern the prediction call.
    /// </summary>
    function Parameters(const Value: TJSONObject): TVideoParams; overload;

    /// <summary>
    /// Optional. The parameters that govern the prediction call.
    /// </summary>
    /// <param name="Value">
    /// A JSON string
    /// </param>
    function Parameters(const Value: string): TVideoParams; overload;

    /// <summary>
    /// Optional. The parameters that govern the prediction call.
    /// </summary>
    function Parameters(const Value: TVideoParameters): TVideoParams; overload;
  end;

  TVideo = class
  private
    FBase64: string;
  public
    procedure SaveToFile(const FileName: string);

    property Base64: string read FBase64 write FBase64;
  end;

  TVideoOpereration = class(TJSONFingerprint)
  strict private
    function JsonStrOf(const FieldName: TVideoOperation): string; overload; inline;
    function JsonStrOf(const FieldName: string): string; overload; inline;

  private
    FName: string;
    FDone: Boolean;
    FError: TStatus;
    function GetType: string;
    function GetUriCount: Integer;
    function GetUri(index: Integer): string;

  public
    property Name: string read FName write FName;

    property Done: Boolean read FDone write FDone;

    property Error: TStatus read FError write FError;

    property &Type: string read GetType;

    property UriCount: Integer read GetUriCount;

    property Uri[index: Integer]: string read GetUri;

    destructor Destroy; override;
  end;

  TVideoStatus = record
  private
    FOperationName: string;
    FDone: Boolean;
    FCount: Integer;
    FUri: TArray<string>;
  public
    property OperationName: string read FOperationName write FOperationName;
    property Done: Boolean read FDone write FDone;
    property Count: Integer read FCount write FCount;
    property Uri: TArray<string> read FUri write FUri;
    class function Aggregate(const Operation: TVideoOpereration): TVideoStatus; static;
  end;

  /// <summary>
  /// Asynchronous callback record specialized for video operation requests.
  /// </summary>
  /// <remarks>
  /// <c>TAsynVideoOpereration</c> is an alias of <see cref="TAsynCallBack{T}"/> specialized with
  /// <see cref="TVideoOpereration"/>. It is used to receive lifecycle notifications for an asynchronous
  /// long-running video operation request:
  /// <para>
  /// • <c>OnStart</c> is invoked when the request begins.
  /// </para>
  /// <para>
  /// • <c>OnSuccess</c> is invoked when the request completes successfully and provides the resulting
  /// <see cref="TVideoOpereration"/> instance (for example, containing the operation name and completion status).
  /// </para>
  /// <para>
  /// • <c>OnError</c> is invoked when the request fails and provides an error message.
  /// </para>
  /// The <c>Sender</c> property can be used to carry context about the originator of the operation.
  /// </remarks>
  TAsynVideoOpereration = TAsynCallBack<TVideoOpereration>;

  /// <summary>
  /// Promise-style callback record specialized for video operation requests.
  /// </summary>
  /// <remarks>
  /// <c>TPromiseVideoOpereration</c> is an alias of <see cref="TPromiseCallBack{T}"/> specialized with
  /// <see cref="TVideoOpereration"/>. It is used to define promise-style lifecycle handlers for an
  /// asynchronous long-running video operation request:
  /// <para>
  /// • <c>OnStart</c> is invoked when the request begins.
  /// </para>
  /// <para>
  /// • <c>OnSuccess</c> is invoked when the request completes successfully and can return a string
  /// derived from the resolved <see cref="TVideoOpereration"/> (for logging/UI messaging), such as the
  /// operation name or completion status.
  /// </para>
  /// <para>
  /// • <c>OnError</c> is invoked when the request fails and can return a string derived from the error
  /// message (for normalization or user-facing messaging).
  /// </para>
  /// The <c>Sender</c> property c
  /// </remarks>
  TPromiseVideoOpereration = TPromiseCallback<TVideoOpereration>;

  /// <summary>
  /// Asynchronous callback record specialized for video download operations.
  /// </summary>
  /// <remarks>
  /// <c>TAsynVideo</c> is an alias of <see cref="TAsynCallBack{T}"/> specialized with
  /// <see cref="TVideo"/>. It is used to receive lifecycle notifications for an asynchronous
  /// video media download request:
  /// <para>
  /// • <c>OnStart</c> is invoked when the download begins.
  /// </para>
  /// <para>
  /// • <c>OnSuccess</c> is invoked when the download completes successfully and provides the resulting
  /// <see cref="TVideo"/> instance (typically containing the Base64 payload).
  /// </para>
  /// <para>
  /// • <c>OnError</c> is invoked when the download fails and provides an error message.
  /// </para>
  /// The <c>Sender</c> property can be used to carry context about the originator of the operation.
  /// </remarks>
  TAsynVideo = TAsynCallBack<TVideo>;

  /// <summary>
  /// Promise-style callback record specialized for video download operations.
  /// </summary>
  /// <remarks>
  /// <c>TPromiseVideo</c> is an alias of <see cref="TPromiseCallBack{T}"/> specialized with
  /// <see cref="TVideo"/>. It is used to define promise-style lifecycle handlers for an asynchronous
  /// video media download request:
  /// <para>
  /// • <c>OnStart</c> is invoked when the download begins.
  /// </para>
  /// <para>
  /// • <c>OnSuccess</c> is invoked when the download completes successfully and can return a string
  /// derived from the resolved <see cref="TVideo"/> (for logging/UI messaging), for example a file path
  /// after saving, or a short status message.
  /// </para>
  /// <para>
  /// • <c>OnError</c> is invoked when the download fails and can return a string derived from the error
  /// message (for normalization or user-facing messaging).
  /// </para>
  /// The <c>Sender</c> property can be used to carry context about the originator of the operation.
  /// </remarks>
  TPromiseVideo = TPromiseCallback<TVideo>;

  TAbstractSupport = class(TGeminiAPIRoute)
  protected
    function Create(const ModelName: string;
      const ParamProc: TProc<TVideoParams>): TVideoOpereration; virtual; abstract;

    function VideoDownload(const FileId: string): TVideo; virtual; abstract;

    function GetOperation(const Value: string): TVideoOpereration; virtual; abstract;
  end;

  TAsynchronousSupport = class(TAbstractSupport)
  protected
    procedure AsynCreate(const ModelName: string;
      const ParamProc: TProc<TVideoParams>;
      const CallBacks: TFunc<TAsynVideoOpereration>);

    procedure AsynVideoDownload(const FileId: string;
      const CallBacks: TFunc<TAsynVideo>);

    procedure AsynGetOperation(const Value: string;
      const CallBacks: TFunc<TAsynVideoOpereration>);

    function CreateOperationName(
      const ModelName: string;
      const ParamProc: TProc<TVideoParams>): TPromise<string>;

    function GetStatus(const OperationName: string): TPromise<TVideoStatus>;

    function DownloadToFile(
      const UriOrFileId, FileName: string): TPromise<string>;
  end;

  TVideoRoute = class(TAsynchronousSupport)
  private
    function UriNormalize(const Value: string): string;

  public
    /// <summary>
    /// Starts a long-running video generation request and returns the initial
    /// <see cref="TVideoOpereration"/> instance created by the API.
    /// </summary>
    /// <param name="ModelName">
    /// The Veo model name to use (for example, <c>veo-3.1-generate-preview</c>).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the <see cref="TVideoParams"/> sent to the model (instances, parameters, etc.).
    /// </param>
    /// <returns>
    /// A <see cref="TVideoOpereration"/> instance representing the newly created long-running operation.
    /// <para>
    /// • The returned operation typically contains the operation name in <c>Name</c>, which can be used to poll status.
    /// </para>
    /// <para>
    /// • Use <see cref="GetOperation"/> to retrieve updated status, or <c>AsyncAwaitCreate</c> for non-blocking usage.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This is the synchronous (blocking) version of operation creation.
    /// </para>
    /// <para>
    /// • The returned instance must be freed by the caller.
    /// </para>
    /// </remarks>
    function Create(const ModelName: string;
      const ParamProc: TProc<TVideoParams>): TVideoOpereration; override;

    /// <summary>
    /// Downloads a generated video media payload and returns a <see cref="TVideo"/> instance containing the video data.
    /// </summary>
    /// <param name="FileId">
    /// The file identifier or file resource to retrieve.
    /// <para>
    /// • Typically a file resource such as <c>files/d01u20yso0sn</c>.
    /// </para>
    /// <para>
    /// • The implementation normalizes the value to a <c>:download?alt=media</c> form when needed.
    /// </para>
    /// </param>
    /// <returns>
    /// A <see cref="TVideo"/> instance containing the downloaded video payload.
    /// <para>
    /// • The video content is provided as Base64 in <c>TVideo.Base64</c>.
    /// </para>
    /// <para>
    /// • Use <see cref="TVideo.SaveToFile"/> to write the content to disk.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This is the synchronous (blocking) version of the download operation. For non-blocking usage,
    /// prefer <c>AsyncAwaitVideoDownload</c>.
    /// </para>
    /// <para>
    /// • The returned instance must be freed by the caller.
    /// </para>
    /// </remarks>
    function VideoDownload(const FileId: string): TVideo; override;

    /// <summary>
    /// Retrieves a long-running video operation by its resource name and returns the corresponding
    /// <see cref="TVideoOpereration"/> instance.
    /// </summary>
    /// <param name="Value">
    /// The operation resource name to query (for example,
    /// <c>models/veo-3.1-generate-preview/operations/ly7n6mqctypc</c>).
    /// </param>
    /// <returns>
    /// A <see cref="TVideoOpereration"/> instance representing the current operation status.
    /// <para>
    /// • Use <c>Done</c> to determine whether the operation has completed.
    /// </para>
    /// <para>
    /// • When <c>Done</c> is <c>True</c>, generated sample URIs can be accessed through <c>Uri[index]</c>.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This is the synchronous (blocking) version of operation retrieval. For non-blocking usage,
    /// prefer <c>AsyncAwaitGetOperation</c>.
    /// </para>
    /// <para>
    /// • The returned instance must be freed by the caller.
    /// </para>
    /// </remarks>
    function GetOperation(const Value: string): TVideoOpereration; override;

    /// <summary>
    /// Starts a long-running video generation request asynchronously and resolves with the initial
    /// <see cref="TVideoOpereration"/> instance returned by the API.
    /// </summary>
    /// <param name="ModelName">
    /// The Veo model name to use (for example, <c>veo-3.1-generate-preview</c>).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the <see cref="TVideoParams"/> sent to the model (instances, parameters, etc.).
    /// </param>
    /// <param name="Callbacks">
    /// Optional promise-style callbacks invoked during the request lifecycle.
    /// <para>
    /// • <c>OnStart</c> is called when the request begins.
    /// </para>
    /// <para>
    /// • <c>OnSuccess</c> can be used to produce a string message from the resolved operation.
    /// </para>
    /// <para>
    /// • <c>OnError</c> can be used to produce a string message from an error.
    /// </para>
    /// </param>
    /// <returns>
    /// A promise that resolves to the created <see cref="TVideoOpereration"/> instance.
    /// <para>
    /// • The resolved operation typically contains the operation name (<c>Name</c>) that can be used later
    /// to poll the status via <see cref="AsyncAwaitGetOperation"/>.
    /// </para>
    /// <para>
    /// • If the request fails, the promise is rejected with an exception.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method only starts the long-running operation; it does not wait for completion.
    /// Use <c>AsyncAwaitGenerateToFile</c> or poll with <see cref="AsyncAwaitGetOperation"/> until <c>Done</c> is <c>True</c>.
    /// </para>
    /// <para>
    /// • The returned <see cref="TVideoOpereration"/> instance is released by the async support layer after callbacks complete.
    /// If you need to keep operation data beyond the callback, copy it out (for example, store <c>Name</c> as a string).
    /// </para>
    /// </remarks>
    function AsyncAwaitCreate(
      const ModelName: string;
      const ParamProc: TProc<TVideoParams>;
      const Callbacks: TFunc<TPromiseVideoOpereration> = nil): TPromise<TVideoOpereration>;

    /// <summary>
    /// Downloads a generated video asynchronously and resolves with a <see cref="TVideo"/> instance
    /// containing the video payload (Base64).
    /// </summary>
    /// <param name="FileId">
    /// The file identifier or file download resource to retrieve.
    /// <para>
    /// • Typically a file resource such as <c>files/d01u20yso0sn</c>.
    /// </para>
    /// <para>
    /// • The implementation normalizes the value to a <c>:download?alt=media</c> form when needed.
    /// </para>
    /// </param>
    /// <param name="Callbacks">
    /// Optional promise-style callbacks invoked during the request lifecycle.
    /// <para>
    /// • <c>OnStart</c> is called when the request begins.
    /// </para>
    /// <para>
    /// • <c>OnSuccess</c> can be used to produce a string message from the resolved video.
    /// </para>
    /// <para>
    /// • <c>OnError</c> can be used to produce a string message from an error.
    /// </para>
    /// </param>
    /// <returns>
    /// A promise that resolves to a <see cref="TVideo"/> instance containing the downloaded video data.
    /// <para>
    /// • The video content is provided as Base64 in <c>TVideo.Base64</c>. Use <see cref="TVideo.SaveToFile"/> to persist it.
    /// </para>
    /// <para>
    /// • If the download fails, the promise is rejected with an exception.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method only downloads the media payload; it does not write any file by itself.
    /// Use <see cref="TVideo.SaveToFile"/> (or <c>AsyncAwaitGenerateToFile</c>) to save the content.
    /// </para>
    /// <para>
    /// • The returned <see cref="TVideo"/> instance is released by the async support layer after callbacks complete.
    /// If you need to keep the bytes, save the file (or copy the Base64) within the promise chain.
    /// </para>
    /// </remarks>
    function AsyncAwaitVideoDownload(
      const FileId: string;
      const Callbacks: TFunc<TPromiseVideo> = nil): TPromise<TVideo>;

    /// <summary>
    /// Retrieves a long-running video operation status asynchronously and resolves with the corresponding
    /// <see cref="TVideoOpereration"/> instance.
    /// </summary>
    /// <param name="FileId">
    /// The operation resource name to query (for example,
    /// <c>models/veo-3.1-generate-preview/operations/ly7n6mqctypc</c>).
    /// </param>
    /// <param name="Callbacks">
    /// Optional promise-style callbacks invoked during the request lifecycle.
    /// <para>
    /// • <c>OnStart</c> is called when the request begins.
    /// </para>
    /// <para>
    /// • <c>OnSuccess</c> can be used to produce a string message from the resolved operation.
    /// </para>
    /// <para>
    /// • <c>OnError</c> can be used to produce a string message from an error.
    /// </para>
    /// </param>
    /// <returns>
    /// A promise that resolves to a <see cref="TVideoOpereration"/> instance representing the current operation status.
    /// <para>
    /// • When the promise resolves, the returned instance is owned by the promise pipeline and will be released according
    /// to the async support layer behavior after callbacks complete. If you need to keep data, copy it out (for example,
    /// into a record) rather than storing the object reference.
    /// </para>
    /// <para>
    /// • If the request fails, the promise is rejected with an exception.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method is typically used to poll an operation until <c>Done</c> is <c>True</c>, then read the generated
    /// sample URIs from <c>Uri[index]</c>.
    /// </para>
    /// <para>
    /// • The <paramref name="FileId"/> parameter is expected to be the operation name (not a file download URI).
    /// </para>
    /// </remarks>
    function AsyncAwaitGetOperation(
      const FileId: string;
      const Callbacks: TFunc<TPromiseVideoOpereration> = nil): TPromise<TVideoOpereration>;

    /// <summary>
    /// Generates a video using a long-running Veo operation, polls until the operation completes,
    /// downloads the resulting video, saves it to an MP4 file, and resolves with the final operation status.
    /// </summary>
    /// <param name="ModelName">
    /// The Veo model name to use (for example, <c>veo-3.1-generate-preview</c>).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure that configures the <see cref="TVideoParams"/> sent to the model (instances, parameters, etc.).
    /// </param>
    /// <param name="FileName">
    /// The target file path where the generated video will be saved (typically an <c>.mp4</c> file).
    /// </param>
    /// <param name="FirstDelayMs">
    /// Initial delay, in milliseconds, before the first polling retry when the operation is not yet done.
    /// Default is <c>500</c>.
    /// </param>
    /// <param name="MaxDelayMs">
    /// Maximum delay, in milliseconds, between polling attempts. The delay grows using the backoff policy and is capped
    /// by this value. Default is <c>5000</c>.
    /// </param>
    /// <param name="MaxTries">
    /// Maximum number of polling attempts before timing out. Default is <c>90</c>.
    /// </param>
    /// <returns>
    /// A promise that resolves to a <see cref="TVideoStatus"/> record once the video has been downloaded and saved.
    /// <para>
    /// • The resolved status contains the operation name (<c>OperationName</c>), completion flag (<c>Done</c>),
    /// and the generated sample URIs (<c>Uri</c>).
    /// </para>
    /// <para>
    /// • If the generation operation fails, the download fails, or polling exceeds <paramref name="MaxTries"/>,
    /// the promise is rejected with an exception.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method starts a long-running video generation request and obtains an operation name.
    /// </para>
    /// <para>
    /// • It then polls the operation status using an exponential backoff strategy, starting at
    /// <paramref name="FirstDelayMs"/> and increasing up to <paramref name="MaxDelayMs"/>, until the operation reports
    /// <c>Done = True</c> or the number of attempts reaches <paramref name="MaxTries"/>.
    /// </para>
    /// <para>
    /// • When the operation completes, the method downloads the first generated sample (<c>Uri[0]</c>) and saves it to
    /// <paramref name="FileName"/> before resolving the returned promise.
    /// </para>
    /// </remarks>
    function AsyncAwaitGenerateToFile(
      const ModelName: string;
      const ParamProc: TProc<TVideoParams>;
      const FileName: string;
      const FirstDelayMs: Cardinal = 500;
      const MaxDelayMs: Cardinal = 5000;
      const MaxTries: Integer = 90): TPromise<TVideoStatus>;
  end;

implementation

{ TVideo }

procedure TVideo.SaveToFile(const FileName: string);
begin
  TMediaCodec.DecodeBase64ToFile(Base64, FileName)
end;

{ TVideoRoute }

function TVideoRoute.AsyncAwaitCreate(const ModelName: string;
  const ParamProc: TProc<TVideoParams>;
  const Callbacks: TFunc<TPromiseVideoOpereration>): TPromise<TVideoOpereration>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoOpereration>(
    procedure(const CallbackParams: TFunc<TAsynVideoOpereration>)
    begin
      Self.AsynCreate(ModelName, ParamProc, CallbackParams);
    end,
    Callbacks);
end;

function TVideoRoute.AsyncAwaitGenerateToFile(const ModelName: string;
  const ParamProc: TProc<TVideoParams>; const FileName: string;
  const FirstDelayMs, MaxDelayMs: Cardinal;
  const MaxTries: Integer): TPromise<TVideoStatus>;
begin
  Result :=
    CreateOperationName(ModelName, ParamProc)
      .&Then<TVideoStatus>(
        function(OperationName: string): TPromise<TVideoStatus>
        begin
          Result :=
            TAsynchronousHelper.PollUntil<TVideoStatus, TVideoStatus>(
              function: TPromise<TVideoStatus>
              begin
                Result := GetStatus(OperationName);
              end,

              function(VideoStatus: TVideoStatus): Boolean
              begin
                Result := VideoStatus.Done;
              end,

              function(VideoStatus: TVideoStatus): TVideoStatus
              begin
                Result := VideoStatus;
              end,

              FirstDelayMs,
              MaxTries,

              function(Attempt: Integer; CurrentDelayMs: Cardinal): Cardinal
              begin
                Result := TAsynchronousHelper.DefaultBackoff(CurrentDelayMs, MaxDelayMs);
              end
            )
            .&Then<TVideoStatus>(
              function(VideoStatus: TVideoStatus): TPromise<TVideoStatus>
              begin
                Result :=
                  DownloadToFile(VideoStatus.Uri[0], FileName)
                    .&Then<TVideoStatus>(
                      function(Dummy: string): TPromise<TVideoStatus>
                      begin
                        Result := TPromise<TVideoStatus>.Resolved(VideoStatus);
                      end
                    );
              end);
        end
      );
end;

function TVideoRoute.AsyncAwaitGetOperation(const FileId: string;
  const Callbacks: TFunc<TPromiseVideoOpereration>): TPromise<TVideoOpereration>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideoOpereration>(
    procedure(const CallbackParams: TFunc<TAsynVideoOpereration>)
    begin
      Self.AsynGetOperation(FileId, CallbackParams);
    end,
    Callbacks);
end;

function TVideoRoute.AsyncAwaitVideoDownload(const FileId: string;
  const Callbacks: TFunc<TPromiseVideo>): TPromise<TVideo>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TVideo>(
    procedure(const CallbackParams: TFunc<TAsynVideo>)
    begin
      Self.AsynVideoDownload(FileId, CallbackParams);
    end,
    Callbacks);
end;

function TVideoRoute.Create(const ModelName: string;
  const ParamProc: TProc<TVideoParams>): TVideoOpereration;
begin
  Result := API.Post<TVideoOpereration, TVideoParams>(
    ModelNormalize(ModelName) + ':predictLongRunning',
    ParamProc);
end;

function TVideoRoute.GetOperation(const Value: string): TVideoOpereration;
begin
  Result := API.Get<TVideoOpereration>(Value);
end;

function TVideoRoute.UriNormalize(const Value: string): string;
const
  DownloadSuffix = ':download?alt=media';
begin
  var Pos := Value.IndexOf('files/', 0);
  Result := Value.Substring(Pos);

  if Result.EndsWith(DownloadSuffix, True) then
    Exit(Result);

  if Result.Contains(':') then
    Exit(Result.Split([':'])[0] + DownloadSuffix);

  Result := Result + DownloadSuffix;
end;

function TVideoRoute.VideoDownload(const FileId: string): TVideo;
begin
  Result := API.GetMedia<TVideo>(UriNormalize(FileId), 'Base64');
end;

{ TVideoOpereration }

destructor TVideoOpereration.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

function TVideoOpereration.GetType: string;
begin
  Result := JsonStrOf(vo_type);
end;

function TVideoOpereration.GetUri(index: Integer): string;
begin
  Result := JsonStrOf(Format(vo_uri_fmt.ToString, [index]));
end;

function TVideoOpereration.GetUriCount: Integer;
begin
  Result := TJsonReader
    .Parse(JSONResponse)
    .Count(vo_uri_count.ToString, 0);
end;

function TVideoOpereration.JsonStrOf(const FieldName: string): string;
begin
  Result := TJsonReader
    .Parse(JSONResponse)
    .AsString(FieldName);
end;

function TVideoOpereration.JsonStrOf(
  const FieldName: TVideoOperation): string;
begin
  Result := TJsonReader
    .Parse(JSONResponse)
    .AsString(FieldName.ToString);
end;

{ TVideoParams }

function TVideoParams.Instances(const Value: TArray<TJSONObject>): TVideoParams;
begin
  Result := TVideoParams(inherited Instances(Value));
end;

function TVideoParams.Instances(const Value: string): TVideoParams;
begin
  Result := TVideoParams(inherited Instances(Value));
end;

function TVideoParams.Instances(
  const Value: TArray<TVideoInstanceParams>): TVideoParams;
begin
  Result := TVideoParams(Add('instances',
    TJSONHelper.ToJsonArray<TVideoInstanceParams>(Value)));
end;

function TVideoParams.Parameters(const Value: TVideoParameters): TVideoParams;
begin
  Result := TVideoParams(Add('parameters', Value.Detach));
end;

function TVideoParams.Parameters(const Value: string): TVideoParams;
begin
  Result := TVideoParams(inherited Parameters(Value));
end;

function TVideoParams.Parameters(const Value: TJSONObject): TVideoParams;
begin
  Result := TVideoParams(inherited Parameters(Value));
end;

{ TVideoParameters }

function TVideoParameters.AspectRatio(
  const Value: TVideoAspectRatio): TVideoParameters;
begin
  Result := TVideoParameters(Add('aspectRatio', Value.ToString));
end;

function TVideoParameters.AspectRatio(const Value: string): TVideoParameters;
begin
  Result := Self.AspectRatio(TVideoAspectRatio.Parse(Value));
end;

function TVideoParameters.CompressionQuality(
  const Value: string): TVideoParameters;
begin
  Result := TVideoParameters(Add('compressionQuality', Value));
end;

function TVideoParameters.DurationSeconds(
  const Value: Integer): TVideoParameters;
begin
  Result := TVideoParameters(Add('durationSeconds', Value));
end;

function TVideoParameters.EnhancePrompt(const Value: Boolean): TVideoParameters;
begin
  Result := TVideoParameters(Add('enhancePrompt', Value));
end;

function TVideoParameters.GenerateAudio(const Value: Boolean): TVideoParameters;
begin
  Result := TVideoParameters(Add('generateAudio', Value));
end;

function TVideoParameters.NegativePrompt(const Value: string): TVideoParameters;
begin
  Result := TVideoParameters(Add('negativePrompt', Value));
end;

function TVideoParameters.PersonGeneration(
  const Value: string): TVideoParameters;
begin
  Result := TVideoParameters(Add('personGeneration', Value));
end;

function TVideoParameters.ResizeMode(const Value: string): TVideoParameters;
begin
  Result := TVideoParameters(Add('resizeMode', Value));
end;

function TVideoParameters.Resolution(const Value: string): TVideoParameters;
begin
  Result := TVideoParameters(Add('resolution', Value));
end;

function TVideoParameters.SampleCount(const Value: Integer): TVideoParameters;
begin
  Result := TVideoParameters(Add('sampleCount', Value));
end;

function TVideoParameters.Seed(const Value: Integer): TVideoParameters;
begin
  Result := TVideoParameters(Add('seed', Value));
end;

function TVideoParameters.StorageUri(const Value: string): TVideoParameters;
begin
  Result := TVideoParameters(Add('storageUri', Value));
end;

{ TVideoInstanceParams }

function TVideoInstanceParams.Image(
  const Value: TImageInstanceParams): TVideoInstanceParams;
begin
  Result := TVideoInstanceParams(Add('image', Value.Detach));
end;

function TVideoInstanceParams.LastFrame(
  const Value: TImageInstanceParams): TVideoInstanceParams;
begin
  Result := TVideoInstanceParams(Add('lastFrame', Value.Detach));
end;

function TVideoInstanceParams.Mask(
  const Value: TImageInstanceParams): TVideoInstanceParams;
begin
  Result := TVideoInstanceParams(Add('mask', Value.Detach));
end;

class function TVideoInstanceParams.New(const Value: TVideoInstanceParams): TVideoInstanceParams;
begin
  Result := Value;
end;

function TVideoInstanceParams.Prompt(const Value: string): TVideoInstanceParams;
begin
  Result := TVideoInstanceParams(Add('prompt', Value));
end;

function TVideoInstanceParams.ReferenceImages(
  const Value: TArray<TReferenceImages>): TVideoInstanceParams;
begin
  Result := TVideoInstanceParams(Add('referenceImages',
    TJSONHelper.ToJsonArray<TReferenceImages>(Value)));
end;

function TVideoInstanceParams.Video(
  const Value: TImageInstanceParams): TVideoInstanceParams;
begin
  Result := TVideoInstanceParams(Add('video', Value.Detach));
end;

{ TImageInstanceParams }

class function TImageInstanceParams.AddBase64(const Base64,
  MimeType: string; const MaskMode: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
    .BytesBase64Encoded(Base64)
    .MimeType(MimeType);

  if not MaskMode.IsEmpty then
    Result.MaskMode(MaskMode);
end;

class function TImageInstanceParams.AddUri(const Uri,
  MimeType: string; const MaskMode: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams.Create
    .GcsUri(Uri)
    .MimeType(MimeType);

  if not MaskMode.IsEmpty then
    Result.MaskMode(MaskMode);
end;

function TImageInstanceParams.BytesBase64Encoded(
  const Value: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams(Add('bytesBase64Encoded', Value));
end;

function TImageInstanceParams.GcsUri(const Value: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams(Add('gcsUri', Value));
end;

function TImageInstanceParams.MaskMode(const Value: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams(Add('maskMode', Value));
end;

function TImageInstanceParams.MimeType(
  const Value: string): TImageInstanceParams;
begin
  Result := TImageInstanceParams(Add('mimeType', Value));
end;

{ TReferenceImages }

function TReferenceImages.Image(
  const Value: TImageInstanceParams): TReferenceImages;
begin
  Result := TReferenceImages(Add('image', Value.Detach));
end;

class function TReferenceImages.NewReference(const Image: TImageInstanceParams;
  ReferenceType: string): TReferenceImages;
begin
  Result := TReferenceImages.Create
    .Image(Image);

  if not ReferenceType.IsEmpty then
    Result.ReferenceType(ReferenceType);
end;

function TReferenceImages.ReferenceType(const Value: string): TReferenceImages;
begin
  Result := TReferenceImages(Add('referenceType', Value));
end;

{ TAsynchronousSupport }

procedure TAsynchronousSupport.AsynCreate(const ModelName: string;
  const ParamProc: TProc<TVideoParams>;
  const CallBacks: TFunc<TAsynVideoOpereration>);
begin
  with TAsynCallBackExec<TAsynVideoOpereration, TVideoOpereration>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoOpereration
      begin
        Result := Self.Create(ModelName, ParamProc);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynGetOperation(const Value: string;
  const CallBacks: TFunc<TAsynVideoOpereration>);
begin
  with TAsynCallBackExec<TAsynVideoOpereration, TVideoOpereration>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideoOpereration
      begin
        Result := Self.GetOperation(Value);
      end);
  finally
    Free;
  end;
end;

procedure TAsynchronousSupport.AsynVideoDownload(const FileId: string;
  const CallBacks: TFunc<TAsynVideo>);
begin
  with TAsynCallBackExec<TAsynVideo, TVideo>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TVideo
      begin
        Result := Self.VideoDownload(FileId);
      end);
  finally
    Free;
  end;
end;

function TAsynchronousSupport.CreateOperationName(const ModelName: string;
  const ParamProc: TProc<TVideoParams>): TPromise<string>;
begin
  Result := TPromise<string>.Create(
    procedure(Resolve: TProc<string>; Reject: TProc<Exception>)
    begin
      Self.AsynCreate(ModelName, ParamProc,
        function: TAsynVideoOpereration
        begin
          Result := Default(TAsynVideoOpereration);

          Result.OnSuccess :=
            procedure(Sender: TObject; Op: TVideoOpereration)
            begin
              Resolve(Op.Name);
            end;

          Result.OnError :=
            procedure(Sender: TObject; ErrorMessage: string)
            begin
              Reject(Exception.Create(ErrorMessage));
            end;
        end);
    end);
end;

function TAsynchronousSupport.DownloadToFile(const UriOrFileId,
  FileName: string): TPromise<string>;
begin
  Result := TPromise<string>.Create(
    procedure(Resolve: TProc<string>; Reject: TProc<Exception>)
    begin
      Self.AsynVideoDownload(UriOrFileId,
        function: TAsynVideo
        begin
          Result := Default(TAsynVideo);

          Result.OnSuccess :=
            procedure(Sender: TObject; V: TVideo)
            begin
              V.SaveToFile(FileName);
              Resolve(FileName);
            end;

          Result.OnError :=
            procedure(Sender: TObject; ErrorMessage: string)
            begin
              Reject(Exception.Create(ErrorMessage));
            end;
        end);
    end);
end;

function TAsynchronousSupport.GetStatus(
  const OperationName: string): TPromise<TVideoStatus>;
begin
  Result := TPromise<TVideoStatus>.Create(
    procedure(Resolve: TProc<TVideoStatus>; Reject: TProc<Exception>)
    begin
      Self.AsynGetOperation(OperationName,
        function: TAsynVideoOpereration
        begin
          Result := Default(TAsynVideoOpereration);

          Result.OnSuccess :=
            procedure(Sender: TObject; Operation: TVideoOpereration)
            begin
              var Buffer := TVideoStatus.Aggregate(Operation);
              Resolve(Buffer);
            end;

          Result.OnError :=
            procedure(Sender: TObject; ErrorMessage: string)
            begin
              Reject(Exception.Create(ErrorMessage));
            end;
        end);
    end);
end;

{ TVideoStatus }

class function TVideoStatus.Aggregate(
  const Operation: TVideoOpereration): TVideoStatus;
begin
  Result := Default(TVideoStatus);
  Result.OperationName := Operation.Name;
  Result.Done := Operation.Done;

  if Result.Done then
    begin
      Result.Count := Operation.UriCount;
      if Result.Count > 0 then
        for var Item := 0 to Result.Count - 1 do
          Result.Uri := Result.Uri + [Operation.Uri[Item]];
    end
  else
    Result.Count := 0;
end;

end.
