unit Gemini;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.URLClient,
  Gemini.API, Gemini.API.Params, Gemini.Types.EnumWire, Gemini.Types.Rtti,
  Gemini.HttpClientInterface, Gemini.Monitoring,
  Gemini.Chat, Gemini.Chat.Request, Gemini.Chat.Request.Content,
  Gemini.Chat.Request.GenerationConfig, Gemini.Chat.Request.Tools,
  Gemini.Chat.Request.ToolConfig, Gemini.Chat.Response,
  Gemini.Net.MediaCodec, Gemini.Safety, Gemini.Schema,
  Gemini.Models, Gemini.Embeddings, Gemini.Files, Gemini.Caching,
  Gemini.Tools, Gemini.Functions.Core, Gemini.VectorFiles, Gemini.VectorFiles.Documents,
  Gemini.FineTunings, Gemini.Operation, Gemini.Batch, Gemini.JsonPathHelper,
  Gemini.Interactions, Gemini.Interactions.Common, Gemini.Interactions.Content,
  Gemini.Interactions.GenerationConfig, Gemini.Interactions.Tools,
  Gemini.Interactions.Request, Gemini.Interactions.ResponsesContent,
  Gemini.Interactions.Responses, Gemini.Interactions.Stream,
  Gemini.Interactions.StreamEngine, Gemini.Interactions.StreamCallbacks,
  Gemini.Video, Gemini.ImageGen, Gemini.Audio.Transcription;

const
  VERSION = 'Geminiv1.1.1';

type
  /// <summary>
  /// The <c>IGemini</c> interface provides access to the various features and routes of the Gemini AI API.
  /// This interface allows interaction with different services such as agents, chat, code completion,
  /// embeddings, file management, fine-tuning, and model information.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • This interface should be implemented by any class that wants to provide a structured way of accessing
  /// the Gemini AI services. It includes methods and properties for authenticating with an API key,
  /// configuring the base URL, and accessing different API routes.
  /// </para>
  /// <para>
  /// • To use this interface, instantiate a class that implements it, set the required properties such as
  /// <see cref="Token"/> and <see cref="BaseURL"/>, and call the relevant methods for the desired operations.
  /// </para>
  /// <para>
  /// • Example
  /// </para>
  /// <code>
  ///   var Gemini: IGemini;
  ///   Gemini := TGeminiFactory.CreateInstance(API_TOKEN);
  /// </code>
  /// </remarks>
  IGemini = interface
    ['{7E69221E-3C24-4B38-9AE9-894714CA9A47}']
    function GetAPI: TGeminiAPI;
    procedure SetToken(const Value: string);
    function GetToken: string;
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetHttpClientAPI: IHttpClientAPI;
    function GetVersion: string;
    function GetChatRoute: TChatRoute;
    function GetModelsRoute: TModelsRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetCachingRoute: TCachingRoute;
    function GetFineTuneRoute: TFineTuneRoute;
    function GetVectorFilesRoute: TVectorFilesRoute;
    function GetDocumentsRoute: TDocumentsRoute;
    function GetBatchRoute: TBatchRoute;
    function GetInteractionsRoute: TInteractionsRoute;
    function GetVideoRoute: TVideoRoute;
    function GetImageGenRoute: TImageGenRoute;
    function GetTranscriptionRoute: TTranscriptionRoute;

    /// <summary>
    /// The HTTP client used to send requests to the API.
    /// </summary>
    /// <value>
    /// An instance of a class implementing <c>IHttpClientAPI</c>.
    /// </value>
    property HttpClient: IHttpClientAPI read GetHttpClientAPI;

    /// <summary>
    /// the main API object used for making requests.
    /// </summary>
    /// <returns>
    /// An instance of TGeminiAPI for making API calls.
    /// </returns>
    property API: TGeminiAPI read GetAPI;

    /// <summary>
    /// Provides access to the Batch API route for asynchronous batch content generation.
    /// </summary>
    /// <remarks>
    /// Use this route to submit and manage batch generation jobs, including:
    /// <para>
    /// • Create a new batch request that returns a long-running operation (LRO)
    /// (<c>Create</c> / <c>AsynCreate</c> / <c>AsyncAwaitCreate</c>).
    /// </para>
    /// <para>
    /// • List existing batch operations (<c>List</c> / <c>AsynList</c> / <c>AsyncAwaitList</c>).
    /// </para>
    /// <para>
    /// • Retrieve a batch operation snapshot by name (<c>Retrieve</c> / <c>AsynRetrieve</c> / <c>AsyncAwaitRetrieve</c>).
    /// </para>
    /// <para>
    /// • Cancel a batch by name (<c>Cancel</c> / <c>AsynCancel</c> / <c>AsyncAwaitCancel</c>).
    /// </para>
    /// <para>
    /// • Delete a batch by name (<c>Delete</c> / <c>AsynDelete</c> / <c>AsyncAwaitDelete</c>).
    /// </para>
    /// <para>
    /// • Download a batch response file as JSONL (<c>JsonlDownload</c> / <c>AsynJsonlDownload</c> / <c>AsyncAwaitJsonlDownload</c>).
    /// </para>
    /// <para>
    /// Name format:
    /// • Batch/operation: <c>batches/{id}</c> (a raw identifier may be accepted and normalized).
    /// </para>
    /// <para>
    /// The returned <c>TBatchRoute</c> instance is created lazily and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Batch: TBatchRoute read GetBatchRoute;

    /// <summary>
    /// Provides access to the caching management API.
    /// </summary>
    /// <returns>
    /// An instance of TFilesRoute for file-related operations.
    /// </returns>
    property Caching: TCachingRoute read GetCachingRoute;

    /// <summary>
    /// Provides access to the chat completion API.
    /// Allows for interaction with models fine-tuned for instruction-based dialogue.
    /// </summary>
    /// <returns>
    /// An instance of TChatRoute for chat-related operations.
    /// </returns>
    property Chat: TChatRoute read GetChatRoute;

    /// <summary>
    /// Provides access to the File Search Store Documents API route.
    /// </summary>
    /// <remarks>
    /// Use this route to manage <c>Document</c> resources within a File Search Store, including:
    /// <para>
    /// • Retrieve a single document by resource name (<c>Retrieve</c> / <c>AsynRetrieve</c> / <c>AsyncAwaitRetrieve</c>).
    /// </para>
    /// <para>
    /// • List documents in a store, with optional pagination (<c>List</c> / <c>AsynList</c> / <c>AsyncAwaitList</c>).
    /// </para>
    /// <para>
    /// • Delete a document, optionally forcing deletion of related chunks when supported
    /// (<c>Delete</c>/<c>AsynDelete</c>/<c>AsyncAwaitDelete</c> and <c>DeleteForced</c>/<c>AsynDeleteForced</c>/<c>AsyncAwaitDeleteForced</c>).
    /// </para>
    /// <para>
    /// Resource name formats:
    /// • Store: <c>fileSearchStores/{storeId}</c>
    /// • Document: <c>fileSearchStores/{storeId}/documents/{documentId}</c>
    /// </para>
    /// <para>
    /// The returned <c>TDocumentsRoute</c> instance is created lazily and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Documents: TDocumentsRoute read GetDocumentsRoute;

    /// <summary>
    /// Provides access to the embeddings API.
    /// Allows for generating vector embeddings from text input, useful for tasks like semantic search and similarity comparisons.
    /// </summary>
    /// <returns>
    /// An instance of TEmbeddingsRoute for embedding-related operations.
    /// </returns>
    property Embeddings: TEmbeddingsRoute read GetEmbeddingsRoute;

    /// <summary>
    /// Provides access to the file management API.
    /// </summary>
    /// <returns>
    /// An instance of TFilesRoute for file-related operations.
    /// </returns>
    property Files: TFilesRoute read GetFilesRoute;

    /// <summary>
    /// Provides access to the Image Generation API route.
    /// </summary>
    /// <remarks>
    /// Use this route to generate images from text prompts, including synchronous and asynchronous workflows:
    /// <para>
    /// • Create an image generation request (<c>Create</c> / <c>AsyncAwaitCreate</c>).
    /// </para>
    /// <para>
    /// • Configure request payloads via <see cref="TImageGenParams"/> (instances and parameters), including
    /// prompt enhancement, aspect ratio, output size, sample count, and person generation policy.
    /// </para>
    /// <para>
    /// The returned <see cref="TImageGenRoute"/> instance is created lazily and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Imagen: TImageGenRoute read GetImageGenRoute;

    /// <summary>
    /// Provides access to the Interactions API route.
    /// </summary>
    /// <remarks>
    /// Use this route to create and manage multi-turn interactions, including streaming workflows and
    /// tool-enabled execution. Typical capabilities include:
    /// <para>
    /// • Create interaction requests (synchronous/asynchronous variants exposed by <see cref="TInteractionsRoute"/>).
    /// </para>
    /// <para>
    /// • Stream interaction responses (SSE) to receive incremental content and status updates.
    /// </para>
    /// <para>
    /// • Use built-in tools such as Google Search, URL Context, Code Execution, Computer Use, and File Search
    /// when enabled by your request configuration.
    /// </para>
    /// <para>
    /// • Control generation via interaction-specific generation config (for example, tool choice, speech config,
    /// and modality settings) and consume structured response content blocks.
    /// </para>
    /// <para>
    /// The returned <see cref="TInteractionsRoute"/> instance is created lazily and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Interactions: TInteractionsRoute read GetInteractionsRoute;

    /// <summary>
    /// Provides access to the models API.
    /// Allows for retrieving and managing available models, including those fine-tuned for specific tasks.
    /// </summary>
    /// <returns>
    /// An instance of TModelsRoute for model-related operations.
    /// </returns>
    property Models: TModelsRoute read GetModelsRoute;

    property Transcription: TTranscriptionRoute read GetTranscriptionRoute;

    /// <summary>
    /// Provides access to the File Search Store (vector files) API route.
    /// </summary>
    /// <remarks>
    /// Use this route to manage <c>FileSearchStore</c> resources and their documents, including:
    /// <para>
    /// • Create, retrieve, list (with pagination), and delete stores.
    /// </para>
    /// <para>
    /// • Upload raw data into a store or import an existing <c>File</c> resource.
    /// </para>
    /// <para>
    /// • Poll long-running operations (LRO) returned by upload/import endpoints until completion.
    /// </para>
    /// <para>
    /// The returned <c>TVectorFilesRoute</c> instance is created lazily and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property VectorFiles: TVectorFilesRoute read GetVectorFilesRoute;

    /// <summary>
    /// Provides access to the Video Generation API route.
    /// </summary>
    /// <remarks>
    /// Use this route to generate and manage videos using Veo models, including long-running operations (LRO)
    /// and media downloads:
    /// <para>
    /// • Start a long-running video generation request that returns an operation
    /// (<c>Create</c> / <c>AsynCreate</c> / <c>AsyncAwaitCreate</c>).
    /// </para>
    /// <para>
    /// • Poll an operation until completion and read generated sample URIs
    /// (<c>GetOperation</c> / <c>AsynGetOperation</c> / <c>AsyncAwaitGetOperation</c>).
    /// </para>
    /// <para>
    /// • Download generated video media payloads (Base64) from a file resource or URI
    /// (<c>VideoDownload</c> / <c>AsynVideoDownload</c> / <c>AsyncAwaitVideoDownload</c>).
    /// </para>
    /// <para>
    /// • Generate, poll, download, and save an MP4 in a single promise workflow
    /// (<c>AsyncAwaitGenerateToFile</c>).
    /// </para>
    /// <para>
    /// The returned <see cref="TVideoRoute"/> instance is created lazily and reused for subsequent calls.
    /// </para>
    /// </remarks>
    property Video: TVideoRoute read GetVideoRoute;

    /// <summary>
    /// Sets or retrieves the base URL for API requests.
    /// Default is https://api.Gemini.com/v1
    /// </summary>
    /// <param name="Value">
    /// The base URL as a string.
    /// </param>
    /// <returns>
    /// The current base URL.
    /// </returns>
    property BaseURL: string read GetBaseUrl write SetBaseUrl;

    /// <summary>
    /// Sets or retrieves the API token for authentication.
    /// </summary>
    /// <param name="Value">
    /// The API token as a string.
    /// </param>
    /// <returns>
    /// The current API token.
    /// </returns>
    property Token: string read GetToken write SetToken;

    /// <summary>
    /// Gets or sets the API version segment used to build Gemini request URLs.
    /// </summary>
    /// <value>
    /// The version path component inserted between <see cref="BaseUrl"/> and the route path
    /// (default: <c>v1beta</c>).
    /// </value>
    /// <remarks>
    /// This property controls the API version prefix used by URL builders (see
    /// <c>TGeminiUrl.Create(BaseUrl, Version, Token)</c>) to produce request URLs such as:
    /// <para>
    /// <c>{BaseUrl}/{Version}/{Path}?key={Token}</c>
    /// </para>
    /// <para>
    /// • Default initialization: <c>VERSION_BASE = 'v1beta'</c>.
    /// </para>
    /// <para>
    /// • Changing this value redirects all subsequent HTTP requests to the selected API
    /// version namespace (for example switching from <c>v1beta</c> to <c>v1</c> if/when supported).
    /// </para>
    /// <para>
    /// • This is independent from the library version string exposed elsewhere (e.g. the
    /// root unit <c>VERSION</c> constant).
    /// </para>
    /// </remarks>
    property Version: string read GetVersion;

    /// <summary>
    /// Provides access to fine-tuning API for user and organization.
    /// Allows managing fine-tuning jobs.
    /// </summary>
    /// <returns>
    /// An instance of TFineTuningRoute for fine-tuning operations.
    /// </returns>
    property FineTune: TFineTuneRoute read GetFineTuneRoute;
  end;

  /// <summary>
  /// The <c>TGeminiFactory</c> class is responsible for creating instances of
  /// the <see cref="IGemini"/> interface. It provides a factory method to instantiate
  /// the interface with a provided API token and optional header configuration.
  /// </summary>
  /// <remarks>
  /// This class provides a convenient way to initialize the <see cref="IGemini"/> interface
  /// by encapsulating the necessary configuration details, such as the API token and header options.
  /// By using the factory method, users can quickly create instances of <see cref="IGemini"/> without
  /// manually setting up the implementation details.
  /// </remarks>
  TGeminiFactory = class
    /// <summary>
    /// Creates an instance of the <see cref="IGemini"/> interface with the specified API token
    /// and optional header configuration.
    /// </summary>
    /// <param name="AToken">
    /// The API token as a string, required for authenticating with Gemini API services.
    /// </param>
    /// <param name="Option">
    /// An optional header configuration of type <see cref="THeaderOption"/> to customize the request headers.
    /// The default value is <c>THeaderOption.none</c>.
    /// </param>
    /// <returns>
    /// An instance of <see cref="IGemini"/> initialized with the provided API token and header option.
    /// </returns>
    class function CreateInstance(const AToken: string): IGemini;
  end;

  TLazyRouteFactory = class(TInterfacedObject)
  protected
    FChatLock: TObject;
    FModelsLock: TObject;
    FEmbeddingsLock: TObject;
    FFilesLock: TObject;
    FCachingLock: TObject;
    FFineTuneLock: TObject;
    FVectorFilesLock: TObject;
    FDocumentsLock: TObject;
    FBatchLock: TObject;
    FInteractionsLock: TObject;
    FVideoLock: TObject;
    FImageGenLock: TObject;
    FTranscriptionLock: TObject;

    function Lazy<T: class>(var AField: T; const ALock: TObject;
      const AFactory: TFunc<T>): T; inline;

  public
    constructor Create;
    destructor Destroy; override;
  end;

  /// <summary>
  /// The TGemini class provides access to the various features and routes of the Gemini AI API.
  /// This class allows interaction with different services such as agents, chat, code completion,
  /// embeddings, file management, fine-tuning, and model information.
  /// </summary>
  /// <remarks>
  /// This class should be implemented by any class that wants to provide a structured way of accessing
  /// the Gemini AI services. It includes methods and properties for authenticating with an API key,
  /// configuring the base URL, and accessing different API routes.
  /// <seealso cref="TGemini"/>
  /// </remarks>
  TGemini = class(TLazyRouteFactory, IGemini)
  private
    FAPI: TGeminiAPI;

    FChatRoute: TChatRoute;
    FModelsRoute: TModelsRoute;
    FEmbeddingsRoute: TEmbeddingsRoute;
    FFilesRoute: TFilesRoute;
    FCachingRoute: TCachingRoute;
    FFineTuneRoute: TFineTuneRoute;
    FVectorFilesRoute: TVectorFilesRoute;
    FDocumentsRoute: TDocumentsRoute;
    FBatchRoute: TBatchRoute;
    FInteractionsRoute: TInteractionsRoute;
    FVideoRoute: TVideoRoute;
    FImageGenRoute: TImageGenRoute;
    FTranscriptionRoute: TTranscriptionRoute;

    function GetAPI: TGeminiAPI;
    function GetToken: string;
    procedure SetToken(const Value: string);
    function GetBaseUrl: string;
    procedure SetBaseUrl(const Value: string);
    function GetHttpClientAPI: IHttpClientAPI;
    function GetVersion: string;

    function GetChatRoute: TChatRoute;
    function GetModelsRoute: TModelsRoute;
    function GetEmbeddingsRoute: TEmbeddingsRoute;
    function GetFilesRoute: TFilesRoute;
    function GetCachingRoute: TCachingRoute;
    function GetFineTuneRoute: TFineTuneRoute;
    function GetVectorFilesRoute: TVectorFilesRoute;
    function GetDocumentsRoute: TDocumentsRoute;
    function GetBatchRoute: TBatchRoute;
    function GetInteractionsRoute: TInteractionsRoute;
    function GetVideoRoute: TVideoRoute;
    function GetImageGenRoute: TImageGenRoute;
    function GetTranscriptionRoute: TTranscriptionRoute;

  public
    property API: TGeminiAPI read GetAPI;

    property Token: string read GetToken write SetToken;

    property BaseURL: string read GetBaseUrl write SetBaseUrl;

    constructor Create; overload;

    constructor Create(const AToken: string); overload;

    destructor Destroy; override;
  end;

{$REGION 'Gemini.API.Params'}

  TJSONFingerprint = Gemini.API.Params.TJSONFingerprint;
  TUrlParam = Gemini.API.Params.TUrlParam;
  TJSONParam = Gemini.API.Params.TJSONParam;
  TJSONHelper = Gemini.API.Params.TJSONHelper;

{$ENDREGION}

{$REGION 'Gemini.API'}

  TGeminiSettings = Gemini.API.TGeminiSettings;
  TApiHttpHandler = Gemini.API.TApiHttpHandler;
  TApiDeserializer = Gemini.API.TApiDeserializer;
  TGeminiAPI = Gemini.API.TGeminiAPI;
  TGeminiAPIModel = Gemini.API.TGeminiAPIModel;
  TGeminiAPIRequestParams = Gemini.API.TGeminiAPIRequestParams;


{$ENDREGION}

{$REGION 'Gemini.HttpClientInterface'}

  IHttpClientParam = Gemini.HttpClientInterface.IHttpClientParam;
  IHttpClientAPI = Gemini.HttpClientInterface.IHttpClientAPI;

{$ENDREGION}

{$REGION 'Gemini.JsonPathHelper'}

  TJsonReader = Gemini.JsonPathHelper.TJsonReader;

{$ENDREGION}

{$REGION 'Gemini.Types.EnumWire'}

  EEnumWireError = Gemini.Types.EnumWire.EEnumWireError;
  TEnumWire = Gemini.Types.EnumWire.TEnumWire;

{$ENDREGION}

{$REGION 'Gemini.Types.Rtti'}

  TRttiMemberAccess = Gemini.Types.Rtti.TRttiMemberAccess;

{$ENDREGION}

{$REGION 'Gemini.Net.MediaCodec'}

  TMediaCodec = Gemini.Net.MediaCodec.TMediaCodec;

{$ENDREGION}

{$REGION 'Gemini.Tools'}

  TToolPluginParams = Gemini.Tools.TToolPluginParams;
  TSchema = Gemini.Tools.TSchema;
  TFunctionDeclaration = Gemini.Tools.TFunctionDeclaration;
  TTool = Gemini.Tools.TTool;
  TToolConfiguration = Gemini.Tools.TToolConfiguration;

{$ENDREGION}

{$REGION 'Gemini.Functions.Core'}

  IFunctionCore = Gemini.Functions.Core.IFunctionCore;
  TFunctionCore = Gemini.Functions.Core.TFunctionCore;

{$ENDREGION}

{$REGION 'Gemini.Safety'}

  TSafety = Gemini.Safety.TSafety;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.Content'}

  TAttachedManager = Gemini.Chat.Request.Content.TAttachedManager;
  TDataPartParams = Gemini.Chat.Request.Content.TDataPartParams;
  TInlineDataParams = Gemini.Chat.Request.Content.TInlineDataParams;
  TFunctionCallParams = Gemini.Chat.Request.Content.TFunctionCallParams;
  TFunctionResponsePartParams = Gemini.Chat.Request.Content.TFunctionResponsePartParams;
  TFunctionResponseParams = Gemini.Chat.Request.Content.TFunctionResponseParams;
  TFileDataParams = Gemini.Chat.Request.Content.TFileDataParams;
  TExecutableCodeParams = Gemini.Chat.Request.Content.TExecutableCodeParams;
  TCodeExecutionResultParams = Gemini.Chat.Request.Content.TCodeExecutionResultParams;
  TMetadataPartParams = Gemini.Chat.Request.Content.TMetadataPartParams;
  TPartParams = Gemini.Chat.Request.Content.TPartParams;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.GenerationConfig'}

  TPrebuiltVoiceConfig = Gemini.Chat.Request.GenerationConfig.TPrebuiltVoiceConfig;
  TVoiceConfig = Gemini.Chat.Request.GenerationConfig.TVoiceConfig;
  TSpeakerVoiceConfig = Gemini.Chat.Request.GenerationConfig.TSpeakerVoiceConfig;
  TMultiSpeakerVoiceConfig = Gemini.Chat.Request.GenerationConfig.TMultiSpeakerVoiceConfig;
  TSpeechConfig = Gemini.Chat.Request.GenerationConfig.TSpeechConfig;
  TThinkingConfig = Gemini.Chat.Request.GenerationConfig.TThinkingConfig;
  TImageConfig = Gemini.Chat.Request.GenerationConfig.TImageConfig;
  TGenerationConfig = Gemini.Chat.Request.GenerationConfig.TGenerationConfig;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.Tools'}

  TFunctionDeclarations = Gemini.Chat.Request.Tools.TFunctionDeclarations;
  TDynamicRetrievalConfig = Gemini.Chat.Request.Tools.TDynamicRetrievalConfig;
  TGoogleSearchRetrieval = Gemini.Chat.Request.Tools.TGoogleSearchRetrieval;
  TCodeExecution = Gemini.Chat.Request.Tools.TCodeExecution;
  TInterval = Gemini.Chat.Request.Tools.TInterval;
  TGoogleSearch = Gemini.Chat.Request.Tools.TGoogleSearch;
  TComputerUse = Gemini.Chat.Request.Tools.TComputerUse;
  TUrlContext = Gemini.Chat.Request.Tools.TUrlContext;
  TFileSearch = Gemini.Chat.Request.Tools.TFileSearch;
  TGoogleMaps = Gemini.Chat.Request.Tools.TGoogleMaps;
  TToolParams = Gemini.Chat.Request.Tools.TToolParams;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request.ToolConfig'}

  TFunctionCallingConfig = Gemini.Chat.Request.ToolConfig.TFunctionCallingConfig;
  TLatLng = Gemini.Chat.Request.ToolConfig.TLatLng;
  TRetrievalConfig = Gemini.Chat.Request.ToolConfig.TRetrievalConfig;
  TToolConfig = Gemini.Chat.Request.ToolConfig.TToolConfig;

{$ENDREGION}

{$REGION 'Gemini.Chat.Request'}

  TContentPayload = Gemini.Chat.Request.TContentPayload;
  TPayLoad = Gemini.Chat.Request.TPayLoad;
  TUsageMetadataParams = Gemini.Chat.Request.TUsageMetadataParams;
  TChatParams = Gemini.Chat.Request.TChatParams;

{$ENDREGION}

{$REGION 'Gemini.Chat.Response'}

  TFunctionCallPart = Gemini.Chat.Response.TFunctionCallPart;
  TInlineDataPart = Gemini.Chat.Response.TInlineDataPart;
  TFileDataPart = Gemini.Chat.Response.TFileDataPart;
  TFunctionResponseBlob = Gemini.Chat.Response.TFunctionResponseBlob;
  TFunctionResponsePartItem = Gemini.Chat.Response.TFunctionResponsePartItem;
  TFunctionResponsePart = Gemini.Chat.Response.TFunctionResponsePart;
  TExecutableCodePart = Gemini.Chat.Response.TExecutableCodePart;
  TCodeExecutionResult = Gemini.Chat.Response.TCodeExecutionResult;
  TVideoMetadata = Gemini.Chat.Response.TVideoMetadata;
  TChatPart = Gemini.Chat.Response.TChatPart;
  TChatContent = Gemini.Chat.Response.TChatContent;
  TSafetyRatings = Gemini.Chat.Response.TSafetyRatings;
  TCitationSource = Gemini.Chat.Response.TCitationSource;
  TCitationMetadata = Gemini.Chat.Response.TCitationMetadata;
  TCandidate = Gemini.Chat.Response.TCandidate;
  TTopCandidates = Gemini.Chat.Response.TTopCandidates;
  TLogprobsResult = Gemini.Chat.Response.TLogprobsResult;
  TGroundingPassageId = Gemini.Chat.Response.TGroundingPassageId;
  TSemanticRetrieverChunk = Gemini.Chat.Response.TSemanticRetrieverChunk;
  TAttributionSourceId = Gemini.Chat.Response.TAttributionSourceId;
  TGroundingAttribution = Gemini.Chat.Response.TGroundingAttribution;
  TUrlMetadata = Gemini.Chat.Response.TUrlMetadata;
  TUrlContextMetadata = Gemini.Chat.Response.TUrlContextMetadata;
  TChatCandidate = Gemini.Chat.Response.TChatCandidate;
  TPromptFeedback = Gemini.Chat.Response.TPromptFeedback;
  TModalityTokenCount = Gemini.Chat.Response.TModalityTokenCount;
  TUsageMetadata = Gemini.Chat.Response.TUsageMetadata;
  TChat = Gemini.Chat.Response.TChat;

{$ENDREGION}

{$REGION 'Gemini.Chat'}

  TChatEvent = Gemini.Chat.TChatEvent;
  TAsynChat = Gemini.Chat.TAsynChat;
  TPromiseChat = Gemini.Chat.TPromiseChat;
  TAsynChatStream = Gemini.Chat.TAsynChatStream;
  TPromiseChatStream = Gemini.Chat.TPromiseChatStream;

{$ENDREGION}

{$REGION 'Gemini.Schema'}

  TSchemaParams = Gemini.Schema.TSchemaParams;

{$ENDREGION}

{$REGION 'Gemini.Models'}

  TModel = Gemini.Models.TModel;
  TAsynModel = Gemini.Models.TAsynModel;
  TPromiseModel = Gemini.Models.TPromiseModel;
  TModels = Gemini.Models.TModels;
  TAsynModels = Gemini.Models.TAsynModels;
  TPromiseModels = Gemini.Models.TPromiseModels;
  TPredictParams = Gemini.Models.TPredictParams;
  TPredict = Gemini.Models.TPredict;

{$ENDREGION}

{$REGION 'Gemini.Embeddings'}

  TEmbeddingsParams = Gemini.Embeddings.TEmbeddingsParams;
  TEmbedContentParams = Gemini.Embeddings.TEmbedContentParams;
  TEmbeddingBatchParams = Gemini.Embeddings.TEmbeddingBatchParams;

  TEmbedContent = Gemini.Embeddings.TEmbedContent;
  TEmbedding = Gemini.Embeddings.TEmbedding;
  TPromiseEmbedding = Gemini.Embeddings.TPromiseEmbedding;
  TEmbeddingList = Gemini.Embeddings.TEmbeddingList;
  TAsynEmbedding = Gemini.Embeddings.TAsynEmbedding;
  TAsynEmbeddingList = Gemini.Embeddings.TAsynEmbeddingList;
  TPromiseEmbeddingList = Gemini.Embeddings.TPromiseEmbeddingList;

{$ENDREGION}

{$REGION 'Gemini.Caching'}

  TCacheParams = Gemini.Caching.TCacheParams;
  TCacheUpdateParams = Gemini.Caching.TCacheUpdateParams;
  TCacheUsageMetadata = Gemini.Caching.TCacheUsageMetadata;
  TCache = Gemini.Caching.TCache;
  TCacheContents = Gemini.Caching.TCacheContents;
  TCacheDelete = Gemini.Caching.TCacheDelete;
  TAsynCache = Gemini.Caching.TAsynCache;
  TPromiseCache = Gemini.Caching.TPromiseCache;
  TAsynCacheContents = Gemini.Caching.TAsynCacheContents;
  TPromiseCacheContents = Gemini.Caching.TPromiseCacheContents;
  TAsynCacheDelete = Gemini.Caching.TAsynCacheDelete;
  TPromiseCacheDelete = Gemini.Caching.TPromiseCacheDelete;

{$ENDREGION}

{$REGION 'Gemini.Operation'}

  TStatus = Gemini.Operation.TStatus;
  TOperation = Gemini.Operation.TOperation;
  TAsynOperation = Gemini.Operation.TAsynOperation;
  TPromiseOperation = Gemini.Operation.TPromiseOperation;
  TOperationList = Gemini.Operation.TOperationList;
  TAsynOperationList = Gemini.Operation.TAsynOperationList;
  TPromiseOperationList = Gemini.Operation.TPromiseOperationList;

{$ENDREGION}

{$REGION 'Gemini.Files'}

  TFileParams = Gemini.Files.TFileParams;
  TFileVideoFileMetadata = Gemini.Files.TFileVideoFileMetadata;
  TFileContent = Gemini.Files.TFileContent;
  TFile = Gemini.Files.TFile;
  TFiles = Gemini.Files.TFiles;
  TFileDelete = Gemini.Files.TFileDelete;
  TAsynFile = Gemini.Files.TAsynFile;
  TPromiseFile = Gemini.Files.TPromiseFile;
  TAsynFiles = Gemini.Files.TAsynFiles;
  TPromiseFiles = Gemini.Files.TPromiseFiles;
  TAsynFileDelete = Gemini.Files.TAsynFileDelete;
  TPromiseFileDelete = Gemini.Files.TPromiseFileDelete;
  TAsynFileContent = Gemini.Files.TAsynFileContent;
  TPromiseFileContent = Gemini.Files.TPromiseFileContent;

{$ENDREGION}

{$REGION 'Gemini.VectorFiles'}

  TFileSearchStoreParams = Gemini.VectorFiles.TFileSearchStoreParams;
  TCustomMetadata = Gemini.VectorFiles.TCustomMetadata;
  TChunkingConfig = Gemini.VectorFiles.TChunkingConfig;
  TUploadFileParams = Gemini.VectorFiles.TUploadFileParams;
  TImportFileParams = Gemini.VectorFiles.TImportFileParams;
  TFileSearchStore = Gemini.VectorFiles.TFileSearchStore;
  TFileSearchStoreList = Gemini.VectorFiles.TFileSearchStoreList;
  TFileSearchStoreDelete = Gemini.VectorFiles.TFileSearchStoreDelete;
  TAsynFileSearchStore = Gemini.VectorFiles.TAsynFileSearchStore;
  TPromiseFileSearchStore = Gemini.VectorFiles.TPromiseFileSearchStore;
  TAsynFileSearchStoreDelete = Gemini.VectorFiles.TAsynFileSearchStoreDelete;
  TPromiseFileSearchStoreDelete = Gemini.VectorFiles.TPromiseFileSearchStoreDelete;
  TAsynFileSearchStoreList = Gemini.VectorFiles.TAsynFileSearchStoreList;
  TPromiseFileSearchStoreList = Gemini.VectorFiles.TPromiseFileSearchStoreList;

{$ENDREGION}

{$REGION 'Gemini.VectorFiles.Documents'}

  TDocument = Gemini.VectorFiles.Documents.TDocument;
  TDocumentList = Gemini.VectorFiles.Documents.TDocumentList;
  TDocumentDelete = Gemini.VectorFiles.Documents.TDocumentDelete;
  TAsynDocument = Gemini.VectorFiles.Documents.TAsynDocument;
  TPromiseDocument = Gemini.VectorFiles.Documents.TPromiseDocument;
  TAsynDocumentList = Gemini.VectorFiles.Documents.TAsynDocumentList;
  TPromiseDocumentList = Gemini.VectorFiles.Documents.TPromiseDocumentList;
  TAsynDocumentDelete = Gemini.VectorFiles.Documents.TAsynDocumentDelete;
  TPromiseDocumentDelete = Gemini.VectorFiles.Documents.TPromiseDocumentDelete;

{$ENDREGION}

{$REGION 'Gemini.Batch'}

  TGenerateContentRequestParams = Gemini.Batch.TGenerateContentRequestParams;
  TInlinedRequestParams = Gemini.Batch.TInlinedRequestParams;
  TInlinedRequestsParams = Gemini.Batch.TInlinedRequestsParams;
  TInputConfigParams = Gemini.Batch.TInputConfigParams;
  TBatchContentParams = Gemini.Batch.TBatchContentParams;
  TBatchParams = Gemini.Batch.TBatchParams;
  TBatchCancel = Gemini.Batch.TBatchCancel;
  TBatchDelete = Gemini.Batch.TBatchDelete;
  TJsonlDownload = Gemini.Batch.TJsonlDownload;
  TAsynBatchCancel = Gemini.Batch.TAsynBatchCancel;
  TPromiseBatchCancel = Gemini.Batch.TPromiseBatchCancel;
  TAsynBatchDelete = Gemini.Batch.TAsynBatchDelete;
  TPromiseBatchDelete = Gemini.Batch.TPromiseBatchDelete;
  TAsynJsonlDownload = Gemini.Batch.TAsynJsonlDownload;
  TPromiseJsonlDownload = Gemini.Batch.TPromiseJsonlDownload;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Common'}

  TAllowedToolsIxParams = Gemini.Interactions.Common.TAllowedToolsIxParams;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Content'}

  TTurnIxParams = Gemini.Interactions.Content.TTurnIxParams;
  TAnnotationsIxParams = Gemini.Interactions.Content.TAnnotationsIxParams;
  TTextContentIxParams = Gemini.Interactions.Content.TTextContentIxParams;
  TImageContentIxParams = Gemini.Interactions.Content.TImageContentIxParams;
  TAudioContentIxParams = Gemini.Interactions.Content.TAudioContentIxParams;
  TDocumentContentIxParams = Gemini.Interactions.Content.TDocumentContentIxParams;
  TVideoContentIxParams = Gemini.Interactions.Content.TVideoContentIxParams;
  TThoughtSummaryIxParams = Gemini.Interactions.Content.TThoughtSummaryIxParams;
  TThoughtContentIxParams = Gemini.Interactions.Content.TThoughtContentIxParams;
  TFunctionCallContentIxParams = Gemini.Interactions.Content.TFunctionCallContentIxParams;
  TFunctionResultContentIxParams = Gemini.Interactions.Content.TFunctionResultContentIxParams;
  TCodeExecutionCallArgumentsIxParams = Gemini.Interactions.Content.TCodeExecutionCallArgumentsIxParams;
  TCodeExecutionCallContentIxParams = Gemini.Interactions.Content.TCodeExecutionCallContentIxParams;
  TCodeExecutionResultContentIxParams = Gemini.Interactions.Content.TCodeExecutionResultContentIxParams;
  TUrlContextCallArgumentsIxParams = Gemini.Interactions.Content.TUrlContextCallArgumentsIxParams;
  TUrlContextCallContentIxParams = Gemini.Interactions.Content.TUrlContextCallContentIxParams;
  TUrlContextResultIxParams = Gemini.Interactions.Content.TUrlContextResultIxParams;
  TUrlContextResultContentIxParams = Gemini.Interactions.Content.TUrlContextResultContentIxParams;
  TGoogleSearchCallArgumentsIxParams = Gemini.Interactions.Content.TGoogleSearchCallArgumentsIxParams;
  TGoogleSearchCallContentIxParams = Gemini.Interactions.Content.TGoogleSearchCallContentIxParams;
  TGoogleSearchResultIxParams = Gemini.Interactions.Content.TGoogleSearchResultIxParams;
  TGoogleSearchResultContentIxParams = Gemini.Interactions.Content.TGoogleSearchResultContentIxParams;
  TMcpServerToolCallContentIxParams = Gemini.Interactions.Content.TMcpServerToolCallContentIxParams;
  TMcpServerToolResultContentIxParams = Gemini.Interactions.Content.TMcpServerToolResultContentIxParams;
  TFileSearchResultIxParams = Gemini.Interactions.Content.TFileSearchResultIxParams;
  TFileSearchResultContentIxParams = Gemini.Interactions.Content.TFileSearchResultContentIxParams;
  TTurnParams = Gemini.Interactions.Content.TTurnParams;
  TInputParams = Gemini.Interactions.Content.TInputParams;

{$ENDREGION}

{$REGION 'Gemini.Interactions.GenerationConfig'}

  TToolChoiceTypeIxParams = Gemini.Interactions.GenerationConfig.TToolChoiceTypeIxParams;
  TSpeechConfigIxParams = Gemini.Interactions.GenerationConfig.TSpeechConfigIxParams;
  TGenerationConfigIxParams = Gemini.Interactions.GenerationConfig.TGenerationConfigIxParams;


{$ENDREGION}

{$REGION 'Gemini.Interactions.Tools'}

  TCustomToolIxParams = Gemini.Interactions.Tools.TCustomToolIxParams;
  TFunctionIxParams = Gemini.Interactions.Tools.TFunctionIxParams;
  TGoogleSearchIxParams = Gemini.Interactions.Tools.TGoogleSearchIxParams;
  TCodeExecutionIxParams = Gemini.Interactions.Tools.TCodeExecutionIxParams;
  TUrlContextIxParams = Gemini.Interactions.Tools.TUrlContextIxParams;
  TComputerUseIxParams = Gemini.Interactions.Tools.TComputerUseIxParams;
  TMcpServerIxParams = Gemini.Interactions.Tools.TMcpServerIxParams;
  TFileSearchIxParams = Gemini.Interactions.Tools.TFileSearchIxParams;
  TToolIxParams = Gemini.Interactions.Tools.TToolIxParams;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Request'}

  TDynamicAgentConfigIxParams = Gemini.Interactions.Request.TDynamicAgentConfigIxParams;
  TDeepResearchAgentConfigIxParams = Gemini.Interactions.Request.TDeepResearchAgentConfigIxParams;
  TInteractionParams = Gemini.Interactions.Request.TInteractionParams;

{$ENDREGION}

{$REGION 'Gemini.Interactions.ResponsesContent'}

  TIxCommonContent = Gemini.Interactions.ResponsesContent.TIxCommonContent;
  TIxAnnotations = Gemini.Interactions.ResponsesContent.TIxAnnotations;
  TIxTextContent = Gemini.Interactions.ResponsesContent.TIxTextContent;
  TIxImageContent = Gemini.Interactions.ResponsesContent.TIxImageContent;
  TIxAudioContent = Gemini.Interactions.ResponsesContent.TIxAudioContent;
  TIxDocumentContent = Gemini.Interactions.ResponsesContent.TIxDocumentContent;
  TIxVideoContent = Gemini.Interactions.ResponsesContent.TIxVideoContent;
  TIxThoughtSummary = Gemini.Interactions.ResponsesContent.TIxThoughtSummary;
  TIxThoughtContent = Gemini.Interactions.ResponsesContent.TIxThoughtContent;
  TIxFunctionCallContent = Gemini.Interactions.ResponsesContent.TIxFunctionCallContent;
  TIxFunctionResultContent = Gemini.Interactions.ResponsesContent.TIxFunctionResultContent;
  TIxCodeExecuteArguments = Gemini.Interactions.ResponsesContent.TIxCodeExecuteArguments;
  TIxCodeExecutionCallContent = Gemini.Interactions.ResponsesContent.TIxCodeExecutionCallContent;
  TIxCodeExecutionResultContent = Gemini.Interactions.ResponsesContent.TIxCodeExecutionResultContent;
  TIxUrlContextArguments = Gemini.Interactions.ResponsesContent.TIxUrlContextArguments;
  TIxUrlContextCallContent = Gemini.Interactions.ResponsesContent.TIxUrlContextCallContent;
  TIxUrlContextResult = Gemini.Interactions.ResponsesContent.TIxUrlContextResult;
  TIxUrlContextResultList = Gemini.Interactions.ResponsesContent.TIxUrlContextResultList;
  TIxUrlContextResultContent = Gemini.Interactions.ResponsesContent.TIxUrlContextResultContent;
  TIxGoogleSearchCallArguments = Gemini.Interactions.ResponsesContent.TIxGoogleSearchCallArguments;
  TIxGoogleSearchCallContent = Gemini.Interactions.ResponsesContent.TIxGoogleSearchCallContent;
  TIxGoogleSearchResult = Gemini.Interactions.ResponsesContent.TIxGoogleSearchResult;
  TIxGoogleSearchResultList = Gemini.Interactions.ResponsesContent.TIxGoogleSearchResultList;
  TIxGoogleSearchResultContent = Gemini.Interactions.ResponsesContent.TIxGoogleSearchResultContent;
  TIxMcpServerToolCallContent = Gemini.Interactions.ResponsesContent.TIxMcpServerToolCallContent;
  TIxMcpServerToolResultContent = Gemini.Interactions.ResponsesContent.TIxMcpServerToolResultContent;
  TIxFileSearchResult = Gemini.Interactions.ResponsesContent.TIxFileSearchResult;
  TIxFileSearchResultList = Gemini.Interactions.ResponsesContent.TIxFileSearchResultList;
  TIxFileSearchResultContent = Gemini.Interactions.ResponsesContent.TIxFileSearchResultContent;
  TIxContent = Gemini.Interactions.ResponsesContent.TIxContent;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Responses'}

  TIxModalityTokens = Gemini.Interactions.Responses.TIxModalityTokens;
  TIxUsage = Gemini.Interactions.Responses.TIxUsage;
  TInteraction = Gemini.Interactions.Responses.TInteraction;
  TAsynInteraction = Gemini.Interactions.Responses.TAsynInteraction;
  TPromiseInteraction = Gemini.Interactions.Responses.TPromiseInteraction;

{$ENDREGION}

{$REGION 'Gemini.Interactions'}

  TUrlRetrieving = Gemini.Interactions.TUrlRetrieving;
  TInteractionEvent = Gemini.Interactions.TInteractionEvent;
  TCRUDDeleted = Gemini.Interactions.TCRUDDeleted;
  TAsynCRUDDeleted = Gemini.Interactions.TAsynCRUDDeleted;
  TPromiseCRUDDeleted = Gemini.Interactions.TPromiseCRUDDeleted;

{$ENDREGION}

{$REGION 'Gemini.Interactions.Stream'}

  TStreamContent = Gemini.Interactions.Stream.TStreamContent;
  TIxCustomDeltaContent = Gemini.Interactions.Stream.TIxCustomDeltaContent;
  TIxThoughtSummaryDelta = Gemini.Interactions.Stream.TIxThoughtSummaryDelta;
  TIxThoughtSignatureDelta = Gemini.Interactions.Stream.TIxThoughtSignatureDelta;
  TInteractionDelta = Gemini.Interactions.Stream.TInteractionDelta;
  TCommonInteractionSseEvent = Gemini.Interactions.Stream.TCommonInteractionSseEvent;
  TIxInteractionEvent = Gemini.Interactions.Stream.TIxInteractionEvent;
  TIxInteractionStatusUpdate = Gemini.Interactions.Stream.TIxInteractionStatusUpdate;
  TIxContentStart = Gemini.Interactions.Stream.TIxContentStart;
  TIxContentDelta = Gemini.Interactions.Stream.TIxContentDelta;
  TIxContentStop = Gemini.Interactions.Stream.TIxContentStop;
  TIxError = Gemini.Interactions.Stream.TIxError;
  TIxErrorEvent = Gemini.Interactions.Stream.TIxErrorEvent;
  TInteractionStream = Gemini.Interactions.Stream.TInteractionStream;
  TAsynInteractionStream = Gemini.Interactions.Stream.TAsynInteractionStream;
  TPromiseInteractionStream = Gemini.Interactions.Stream.TPromiseInteractionStream;

{$ENDREGION}

{$REGION 'Gemini.Interactions.StreamEngine'}

  IStreamEventHandler = Gemini.Interactions.StreamEngine.IStreamEventHandler;
  IEventEngineManager = Gemini.Interactions.StreamEngine.IEventEngineManager;
  TEventEngineManagerFactory = Gemini.Interactions.StreamEngine.TEventEngineManagerFactory;
  TInteractionStart = Gemini.Interactions.StreamEngine.TInteractionStart;
  TInteractionComplete = Gemini.Interactions.StreamEngine.TInteractionComplete;
  TInteractionStatusUpdate = Gemini.Interactions.StreamEngine.TInteractionStatusUpdate;
  TContentStart = Gemini.Interactions.StreamEngine.TContentStart;
  TContentDelta = Gemini.Interactions.StreamEngine.TContentDelta;
  TContentStop = Gemini.Interactions.StreamEngine.TContentStop;
  TErrorEvent = Gemini.Interactions.StreamEngine.TErrorEvent;

{$ENDREGION}

{$REGION 'Gemini.Interactions.StreamCallbacks'}

  TEventData = Gemini.Interactions.StreamCallbacks.TEventData;
  TStreamEventCallBack = Gemini.Interactions.StreamCallbacks.TStreamEventCallBack;
  IStreamEventDispatcher = Gemini.Interactions.StreamCallbacks.IStreamEventDispatcher;
  TStreamEventDispatcher = Gemini.Interactions.StreamCallbacks.TStreamEventDispatcher;

{$ENDREGION}

{$REGION 'Gemini.Video'}

  TVideoParameters = Gemini.Video.TVideoParameters;
  TImageInstanceParams = Gemini.Video.TImageInstanceParams;
  TReferenceImages = Gemini.Video.TReferenceImages;
  TVideoInstanceParams = Gemini.Video.TVideoInstanceParams;
  TVideoParams = Gemini.Video.TVideoParams;
  TVideo = Gemini.Video.TVideo;
  TVideoOpereration = Gemini.Video.TVideoOpereration;
  TAsynVideoOpereration = Gemini.Video.TAsynVideoOpereration;
  TPromiseVideoOpereration = Gemini.Video.TPromiseVideoOpereration;
  TAsynVideo = Gemini.Video.TAsynVideo;
  TPromiseVideo = Gemini.Video.TPromiseVideo;
  TVideoStatus = Gemini.Video.TVideoStatus;

{$ENDREGION}

{$REGION 'Gemini.ImageGen'}

  TImageGenInstanceParams = Gemini.ImageGen.TImageGenInstanceParams;
  TImageGenParameters= Gemini.ImageGen.TImageGenParameters;
  TImageGenParams= Gemini.ImageGen.TImageGenParams;
  TImageGenPrediction = Gemini.ImageGen.TImageGenPrediction;
  TImageGen = Gemini.ImageGen.TImageGen;
  TAsynImageGen = Gemini.ImageGen.TAsynImageGen;
  TPromiseImageGen = Gemini.ImageGen.TPromiseImageGen;

{$ENDREGION}

{$REGION 'Gemini.Audio.Transcription'}

  TTranscription = Gemini.Audio.Transcription.TTranscription;
  TAsynTranscription = Gemini.Audio.Transcription.TAsynTranscription;
  TPromiseTranscription = Gemini.Audio.Transcription.TPromiseTranscription;

{$ENDREGION}

function HttpMonitoring: IRequestMonitor;
function CurrentVersion: string;
function NewBatchContent(const DisplayName: string; const FileURI: string): TBatchContentParams;

implementation

function HttpMonitoring: IRequestMonitor;
begin
  Result := Monitoring;
end;

function CurrentVersion: string;
begin
  Result := VERSION;
end;

function NewBatchContent(const DisplayName: string; const FileURI: string): TBatchContentParams;
begin
  Result :=
    TBatchContentParams.Create
      .DisplayName(DisplayName)
      .InputConfig(
         TInputConfigParams.Create
           .FileName(FileURI)
       );
end;

{ TLazyRouteFactory }

constructor TLazyRouteFactory.Create;
begin
  inherited Create;
  FChatLock := TObject.Create;
  FModelsLock := TObject.Create;
  FEmbeddingsLock := TObject.Create;
  FFilesLock := TObject.Create;
  FCachingLock := TObject.Create;
  FFineTuneLock := TObject.Create;
  FVectorFilesLock := TObject.Create;
  FDocumentsLock := TObject.Create;
  FBatchLock := TObject.Create;
  FInteractionsLock := TObject.Create;
  FVideoLock := TObject.Create;
  FImageGenLock := TObject.Create;
  FTranscriptionLock := TObject.Create;
end;

destructor TLazyRouteFactory.Destroy;
begin
  FChatLock.Free;
  FModelsLock.Free;
  FEmbeddingsLock.Free;
  FFilesLock.Free;
  FCachingLock.Free;
  FFineTuneLock.Free;
  FVectorFilesLock.Free;
  FDocumentsLock.Free;
  FBatchLock.Free;
  FInteractionsLock.Free;
  FVideoLock.Free;
  FImageGenLock.Free;
  FTranscriptionLock.Free;
  inherited;
end;

function TLazyRouteFactory.Lazy<T>(var AField: T; const ALock: TObject;
  const AFactory: TFunc<T>): T;
begin
  Result := AField;
  if Result <> nil then
    Exit;

  TMonitor.Enter(ALock);
  try
    if AField = nil then
      AField := AFactory();
    Result := AField;
  finally
    TMonitor.Exit(ALock);
  end;
end;

{ TGemini }

constructor TGemini.Create;
begin
  inherited Create;
  FAPI := TGeminiAPI.Create;
end;

constructor TGemini.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor TGemini.Destroy;
begin
  FChatRoute.Free;
  FModelsRoute.Free;
  FEmbeddingsRoute.Free;
  FFilesRoute.Free;
  FCachingRoute.Free;
  FFineTuneRoute.Free;
  FVectorFilesRoute.Free;
  FDocumentsRoute.Free;
  FBatchRoute.Free;
  FInteractionsRoute.Free;
  FVideoRoute.Free;
  FImageGenRoute.Free;
  FTranscriptionRoute.Free;
  FAPI.Free;
  inherited;
end;

function TGemini.GetAPI: TGeminiAPI;
begin
  Result := FAPI;
end;

function TGemini.GetBaseUrl: string;
begin
  Result := FAPI.BaseURL;
end;

function TGemini.GetBatchRoute: TBatchRoute;
begin
  Result := Lazy<TBatchRoute>(FBatchRoute, FBatchLock,
    function: TBatchRoute
    begin
      Result := TBatchRoute.CreateRoute(API);
    end);
end;

function TGemini.GetCachingRoute: TCachingRoute;
begin
  Result := Lazy<TCachingRoute>(FCachingRoute, FCachingLock,
    function: TCachingRoute
    begin
      Result := TCachingRoute.CreateRoute(API);
    end);
end;

function TGemini.GetChatRoute: TChatRoute;
begin
  Result := Lazy<TChatRoute>(FChatRoute, FChatLock,
    function: TChatRoute
    begin
      Result := TChatRoute.CreateRoute(API);
    end);
end;

function TGemini.GetDocumentsRoute: TDocumentsRoute;
begin
  Result := Lazy<TDocumentsRoute>(FDocumentsRoute, FDocumentsLock,
    function: TDocumentsRoute
    begin
      Result := TDocumentsRoute.CreateRoute(API);
    end);
end;

function TGemini.GetEmbeddingsRoute: TEmbeddingsRoute;
begin
  Result := Lazy<TEmbeddingsRoute>(FEmbeddingsRoute, FEmbeddingsLock,
    function: TEmbeddingsRoute
    begin
      Result := TEmbeddingsRoute.CreateRoute(API);
    end);
end;

function TGemini.GetFilesRoute: TFilesRoute;
begin
  Result := Lazy<TFilesRoute>(FFilesRoute, FFilesLock,
    function: TFilesRoute
    begin
      Result := TFilesRoute.CreateRoute(API);
    end);
end;

function TGemini.GetFineTuneRoute: TFineTuneRoute;
begin
  Result := Lazy<TFineTuneRoute>(FFineTuneRoute, FFineTuneLock,
    function: TFineTuneRoute
    begin
      Result := TFineTuneRoute.CreateRoute(API);
    end);
end;

function TGemini.GetHttpClientAPI: IHttpClientAPI;
begin
  Result := API.HttpClient;
end;

function TGemini.GetImageGenRoute: TImageGenRoute;
begin
  Result := Lazy<TImageGenRoute>(FImageGenRoute, FImageGenLock,
    function: TImageGenRoute
    begin
      Result := TImageGenRoute.CreateRoute(API);
    end);
end;

function TGemini.GetInteractionsRoute: TInteractionsRoute;
begin
  Result := Lazy<TInteractionsRoute>(FInteractionsRoute, FInteractionsLock,
    function: TInteractionsRoute
    begin
      Result := TInteractionsRoute.CreateRoute(API);
    end);
end;

function TGemini.GetModelsRoute: TModelsRoute;
begin
  Result := Lazy<TModelsRoute>(FModelsRoute, FModelsLock,
    function: TModelsRoute
    begin
      Result := TModelsRoute.CreateRoute(API);
    end);
end;

function TGemini.GetToken: string;
begin
  Result := FAPI.Token;
end;

function TGemini.GetTranscriptionRoute: TTranscriptionRoute;
begin
  Result := Lazy<TTranscriptionRoute>(FTranscriptionRoute, FTranscriptionLock,
    function: TTranscriptionRoute
    begin
      Result := TTranscriptionRoute.CreateRoute(API);
    end);
end;

function TGemini.GetVectorFilesRoute: TVectorFilesRoute;
begin
  Result := Lazy<TVectorFilesRoute>(FVectorFilesRoute, FVectorFilesLock,
    function: TVectorFilesRoute
    begin
      Result := TVectorFilesRoute.CreateRoute(API);
    end);
end;

function TGemini.GetVersion: string;
begin
  Result := VERSION;
end;

function TGemini.GetVideoRoute: TVideoRoute;
begin
  Result := Lazy<TVideoRoute>(FVideoRoute, FVideoLock,
    function: TVideoRoute
    begin
      Result := TVideoRoute.CreateRoute(API);
    end);
end;

procedure TGemini.SetBaseUrl(const Value: string);
begin
  FAPI.BaseURL := Value;
end;

procedure TGemini.SetToken(const Value: string);
begin
  FAPI.Token := Value;
end;

{ TGeminiFactory }

class function TGeminiFactory.CreateInstance(const AToken: string): IGemini;
begin
  Result := TGemini.Create(AToken);
end;

end.
