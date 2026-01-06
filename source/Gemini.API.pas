unit Gemini.API;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.URLClient, System.Net.Mime, System.JSON,
  System.SyncObjs, System.Net.HttpClient, System.NetEncoding,
  REST.Json,
  Gemini.API.Params, Gemini.Exceptions, Gemini.Errors, Gemini.API.SSEDecoder,
  Gemini.HttpClientInterface, Gemini.HttpClientAPI, Gemini.Monitoring,
  Gemini.API.Utils, Gemini.API.Url;

type
  /// <summary>
  /// Represents the configuration settings for the Gemini API.
  /// </summary>
  /// <remarks>
  /// This class provides properties and methods to manage the API key, base URL,
  /// organization identifier, and custom headers for communicating with the Gemini API.
  /// It also includes utility methods for building headers and endpoint URLs.
  /// </remarks>
  TGeminiSettings = class
  const
    URL_BASE     = 'https://generativelanguage.googleapis.com';
    VERSION_BASE = 'v1beta';
  private
    FToken: string;
    FBaseUrl: string;
    FVersion: string;
    FOrganization: string;
    FCustomHeaders: TNetHeaders;
    procedure SetToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    procedure SetVersion(const Value: string);
    procedure SetOrganization(const Value: string);
    procedure SetCustomHeaders(const Value: TNetHeaders);

  public
    constructor Create; overload;

    /// <summary>
    /// The API key used for authentication.
    /// </summary>
    property Token: string read FToken write SetToken;

    /// <summary>
    /// Gets or sets the base URL for all API requests.
    /// </summary>
    /// <remarks>
    /// This value defines the root endpoint used to build request URLs
    /// (for example, <c>https://generativelanguage.googleapis.com</c>). It is combined with
    /// relative paths to form the final request URL.
    /// </remarks>
    property BaseUrl: string read FBaseUrl write SetBaseUrl;

    /// <summary>
    /// Gets or sets the version base for all API requests.
    /// </summary>
    property Version: string read FVersion write SetVersion;

    /// <summary>
    /// The organization identifier used for the API.
    /// </summary>
    property Organization: string read FOrganization write SetOrganization;

    /// <summary>
    /// Custom headers to include in API requests.
    /// </summary>
    property CustomHeaders: TNetHeaders read FCustomHeaders write SetCustomHeaders;
  end;

  /// <summary>
  /// Handles HTTP requests and responses for the Gemini API.
  /// </summary>
  /// <remarks>
  /// This class extends <c>TGeminiSettings</c> and provides a mechanism to
  /// manage HTTP client interactions for the API, including configuration and request execution.
  /// </remarks>
  TApiHttpHandler = class(TGeminiSettings)
  private
    /// <summary>
    /// The HTTP client interface used for making API calls.
    /// </summary>
    FHttpClient: IHttpClientAPI;

  protected
    /// <summary>
    /// Validates that the API settings required to issue requests are present.
    /// </summary>
    /// <remarks>
    /// This routine checks the configuration held by <see cref="TGeminiSettings"/> before performing
    /// an HTTP request. It is typically invoked by the underlying HTTP client implementation prior to
    /// sending a request.
    /// <para>
    /// • Validation rule: <see cref="TGeminiSettings.Token"/> must be non-empty.
    /// </para>
    /// <para>
    /// • Validation rule: <see cref="TGeminiSettings.BaseUrl"/> must be non-empty.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised when a required setting is missing or empty (for example, an empty token or base URL).
    /// </exception>
    procedure VerifyApiSettings;

    /// <summary>
    /// Creates and returns a new HTTP client instance configured for Gemini API requests.
    /// </summary>
    /// <returns>
    /// A newly created instance implementing <see cref="IHttpClientAPI"/> that is ready to issue requests
    /// using the current API settings.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • The returned client is created via <c>THttpClientAPI.CreateInstance(VerifyApiSettings)</c>,
    /// so API settings validation (token/base URL) can be enforced by the underlying implementation.
    /// </para>
    /// <para>
    /// • If <see cref="HttpClient"/> is assigned, this method copies runtime configuration to the new instance
    /// (timeouts and proxy settings): <c>SendTimeOut</c>, <c>ConnectionTimeout</c>, <c>ResponseTimeout</c>,
    /// and <c>ProxySettings</c>.
    /// </para>
    /// <para>
    /// • This method always returns a fresh instance; it does not reuse <see cref="HttpClient"/>.
    /// <see cref="HttpClient"/> is treated as a template for configuration values.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised when required API settings are missing or empty (for example, an empty token or base URL),
    /// depending on when the underlying HTTP client invokes the provided validation callback.
    /// </exception>
    function NewHttpClient: IHttpClientAPI; virtual;
  public
    constructor Create;

    /// <summary>
    /// The HTTP client used to send requests to the API.
    /// </summary>
    /// <value>
    /// An instance of a class implementing <c>IHttpClientAPI</c>.
    /// </value>
    property HttpClient: IHttpClientAPI read FHttpClient write FHttpClient;
  end;

  /// <summary>
  /// Manages and processes errors from the Gemini API responses, and deserializes JSON payloads
  /// into strongly typed Delphi objects.
  /// </summary>
  /// <remarks>
  /// <para>
  /// • This class extends <c>TApiHttpHandler</c> and provides error-handling capabilities by parsing
  /// error data and raising appropriate exceptions.
  /// </para>
  /// <para>
  /// • <b>Global configuration / thread-safety notice</b><br/>
  /// <see cref="MetadataAsObject"/> and <see cref="MetadataManager"/> are process-wide (static) settings.
  /// They are <b>not thread-safe</b>: changing them while other threads are deserializing may lead to
  /// inconsistent behavior or failures.
  /// </para>
  /// <para>
  /// • <b>Initialization rule</b><br/>
  /// These settings should be configured <b>once</b> during process startup (before any concurrent use),
  /// and then treated as immutable for the remainder of the process lifetime.
  /// </para>
  /// <para>
  /// • <b>Testing rule</b><br/>
  /// Unit/integration tests may override these settings, but only in a controlled manner:
  /// set them <b>once at test process start</b> (or in a one-time suite setup) before any tests that
  /// perform deserialization are executed. Avoid modifying them per-test case, especially when tests
  /// may run in parallel.
  /// </para>
  /// </remarks>
  TApiDeserializer = class(TApiHttpHandler)
  strict private
    class var FMetadataManager: ICustomFieldsPrepare;
    class var FMetadataAsObject: Boolean;
  protected
    /// <summary>
    /// Parses the error data from the API response.
    /// </summary>
    /// <param name="Code">
    /// The HTTP status code returned by the API.
    /// </param>
    /// <param name="ResponseText">
    /// The response body containing error details.
    /// </param>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if the error response cannot be parsed or contains invalid data.
    /// </exception>
    procedure DeserializeErrorData(const Code: Int64; const ResponseText: string); virtual;

    /// <summary>
    /// Raises an exception corresponding to the API error code.
    /// </summary>
    /// <param name="Code">
    /// The HTTP status code returned by the API.
    /// </param>
    /// <param name="Error">
    /// The deserialized error object containing error details.
    /// </param>
    procedure RaiseError(Code: Int64; Error: TErrorCore);

    /// <summary>
    /// Deserializes an HTTP response payload into a strongly typed Delphi object, or raises
    /// a structured exception when the response represents an API error.
    /// </summary>
    /// <typeparam name="T">
    /// The target type to deserialize into. Must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Code">
    /// The HTTP status code returned by the server.
    /// </param>
    /// <param name="ResponseText">
    /// The response body as a JSON string (success payload or error payload).
    /// </param>
    /// <param name="DisabledShield">
    /// When <c>True</c>, disables metadata preprocessing and performs a direct JSON-to-object
    /// conversion (see <c>Parse{T}</c>). When <c>False</c> (default), parsing follows the global
    /// metadata configuration (<c>MetadataAsObject</c>/<c>MetadataManager</c>).
    /// </param>
    /// <returns>
    /// A deserialized instance of <typeparamref name="T"/> when <paramref name="Code"/> indicates success (2xx).
    /// <para>
    /// • If <typeparamref name="T"/> inherits from <c>TJSONFingerprint</c>, the original JSON payload is
    /// normalized (formatted) and stored in <c>JSONResponse</c>, then propagated to nested fingerprint
    /// instances in the object graph.
    /// </para>
    /// </returns>
    /// <remarks>
    /// <para>
    /// • Success path: for HTTP status codes in the range 200..299, this method maps
    /// <paramref name="ResponseText"/> into <typeparamref name="T"/> by calling <c>Parse{T}</c>.
    /// </para>
    /// <para>
    /// • Error path: for any non-2xx code, this method delegates to <c>DeserializeErrorData</c>,
    /// which attempts to parse the API error payload and raises an appropriate <c>GeminiException</c>
    /// subtype. This method does not return normally in that case.
    /// </para>
    /// <para>
    /// • This method does not validate transport-level concerns (timeouts, connectivity). It only
    /// interprets the HTTP status code and JSON payload already obtained by the caller.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the server returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EGeminiExceptionAPI">
    /// Raised when the server returns an error payload that is not parseable as a structured error object.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the JSON success payload cannot be mapped to <typeparamref name="T"/> under the active
    /// parsing mode (for example metadata preprocessing requirements not satisfied).
    /// </exception>
    function Deserialize<T: class, constructor>(const Code: Int64;
      const ResponseText: string; DisabledShield: Boolean = False): T;
  public
    class constructor Create;

    /// <summary>
    /// Gets or sets whether the deserializer treats the "metadata" payload as a JSON object.
    /// </summary>
    /// <remarks>
    /// When set to <c>True</c>, deserialization expects metadata fields to be represented as proper JSON objects
    /// and mapped to the corresponding Delphi types (for example, a dedicated metadata class with matching fields).
    /// <para>
    /// • When set to <c>False</c> (default), metadata fields are treated as raw JSON text and preprocessed through
    /// <see cref="MetadataManager"/> before the final object mapping occurs. This mode is intended for scenarios
    /// where the metadata schema is variable across response types and cannot be bound reliably to a single class.
    /// </para>
    /// <para>
    /// • This setting is process-wide (static) and affects all calls that use <see cref="Parse{T}(string)"/> and
    /// <see cref="Deserialize{T}(Int64,string)"/> within this unit.
    /// </para>
    /// </remarks>
    class property MetadataAsObject: Boolean read FMetadataAsObject write FMetadataAsObject;

    /// <summary>
    /// Gets or sets the global metadata preprocessor used during JSON deserialization.
    /// </summary>
    /// <remarks>
    /// This property holds an implementation of <c>ICustomFieldsPrepare</c> responsible for preparing and/or
    /// transforming JSON payloads before they are mapped to Delphi objects.
    /// <para>
    /// • When <see cref="MetadataAsObject"/> is <c>False</c> (default), the deserializer invokes
    /// <c>MetadataManager.Convert(...)</c> to normalize metadata fields that may contain variable or untyped
    /// structures, enabling stable deserialization without requiring a dedicated metadata class.
    /// </para>
    /// <para>
    /// • When <see cref="MetadataAsObject"/> is <c>True</c>, the metadata preprocessor is typically not required
    /// because metadata is expected to be represented as proper JSON objects and mapped directly to Delphi types.
    /// </para>
    /// <para>
    /// • This setting is process-wide (static). Assigning a new manager affects all subsequent calls to
    /// <see cref="Parse{T}(string)"/> and <see cref="Deserialize{T}(Int64,string)"/> within this unit.
    /// </para>
    /// <para>
    /// • If set to <c>nil</c>, and <see cref="MetadataAsObject"/> is <c>False</c>, deserialization may fail for
    /// responses that rely on metadata preprocessing.
    /// </para>
    /// </remarks>
    class property MetadataManager: ICustomFieldsPrepare read FMetadataManager write FMetadataManager;

    /// <summary>
    /// Parses a JSON payload and maps it to a strongly typed Delphi object.
    /// </summary>
    /// <typeparam name="T">
    /// The target type to deserialize into. Must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Value">
    /// The JSON payload to parse.
    /// </param>
    /// <param name="DisabledShield">
    /// When <c>True</c>, performs a direct JSON-to-object conversion without applying the metadata
    /// preprocessing pipeline. When <c>False</c> (default), parsing follows the global metadata
    /// configuration (<see cref="MetadataAsObject"/> / <see cref="MetadataManager"/>).
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="T"/> populated from <paramref name="Value"/>.
    /// <para>
    /// • If <typeparamref name="T"/> inherits from <c>TJSONFingerprint</c>, the original JSON payload
    /// is normalized (formatted) and stored in <c>JSONResponse</c>, then propagated to nested
    /// <c>TJSONFingerprint</c> instances in the object graph.
    /// </para>
    /// </returns>
    /// <remarks>
    /// Parsing behavior depends on the global deserialization configuration:
    /// <para>
    /// • If <paramref name="NullConversion"/> is <c>True</c>, this method calls <c>TJson.JsonToObject&lt;T&gt;</c>
    /// directly on <paramref name="Value"/> (no metadata conversion).
    /// </para>
    /// <para>
    /// • Otherwise, when <see cref="MetadataAsObject"/> is <c>True</c>, metadata fields are expected to
    /// be proper JSON objects and parsing is direct.
    /// </para>
    /// <para>
    /// • When <see cref="MetadataAsObject"/> is <c>False</c>, <see cref="MetadataManager"/> is used to
    /// preprocess/normalize metadata fields before mapping to <typeparamref name="T"/>. If
    /// <see cref="MetadataManager"/> is <c>nil</c> in this mode, parsing raises an invalid-response
    /// exception.
    /// </para>
    /// <para>
    /// This method is a pure deserialization utility: it does not interpret HTTP status codes.
    /// Error payload handling is performed by higher-level routines (for example
    /// <c>Deserialize{T}</c>/<c>DeserializeErrorData</c>).
    /// </para>
    /// </remarks>
    /// <exception cref="EInvalidResponse">
    /// Raised when <see cref="MetadataAsObject"/> is <c>False</c> and <see cref="MetadataManager"/> is <c>nil</c>,
    /// or when the JSON payload cannot be mapped to <typeparamref name="T"/> under the active mode.
    /// </exception>
    class function Parse<T: class, constructor>(const Value: string; DisabledShield: Boolean = False): T;
  end;

  TGeminiAPI = class(TApiDeserializer)
  private
    function GetDefaultHeaders: TNetHeaders;
    function GetJsonHeaders: TNetHeaders;
    function GetFilesURL(const Path: string): string;
    function GetRequestURL(const Path: string): string; overload;
    function GetRequestURL(const Path, Params: string): string; overload;
    function GetRequestFilesURL(const Path: string): string;
    function GetPatchURL(const Path, Params: string): string;
    function MockJsonFile(const FieldName: string; Response: TStringStream): string; overload;
    function MockJsonFile(const FieldName: string; Response: TStream): string; overload;

  public
    /// <summary>
    /// Executes a request expected to return information in the HTTP response headers and extracts a header value.
    /// </summary>
    /// <typeparam name="TParams">
    /// A JSON-parameter builder type deriving from <c>TJSONParam</c>, used to build the request body.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL) used to build the request URL.
    /// </param>
    /// <param name="KeyName">
    /// The name of the HTTP header to search for (case-insensitive).
    /// </param>
    /// <param name="ParamProc">
    /// An optional procedure invoked to populate an instance of <typeparamref name="TParams"/> before sending the request.
    /// If <c>nil</c>, the request is sent without a JSON body.
    /// </param>
    /// <returns>
    /// The value of the matching response header, or an empty string if the header is not present.
    /// </returns>
    /// <remarks>
    /// This method issues a POST request using <see cref="GetRequestFilesURL"/> (API key in query string) and JSON headers.
    /// It is intended for endpoints that return key information in headers (for example, a resource identifier or location).
    /// <para>
    /// • On success (HTTP 2xx), it scans the returned headers using a case-insensitive comparison and returns the first match.
    /// </para>
    /// <para>
    /// • On non-success status codes, this method currently raises a generic exception (<c>Exception</c>) indicating that
    /// the response headers could not be retrieved.
    /// </para>
    /// </remarks>
    /// <exception cref="Exception">
    /// Raised when the HTTP status code is not in the 2xx range.
    /// </exception>
    function Find<TParams: TJSONParam>(const Path: string; KeyName: string;
      ParamProc: TProc<TParams>): string;

    /// <summary>
    /// Sends a GET request to the specified API endpoint and deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="Params">
    /// Optional query-string suffix appended to the request URL.
    /// This value is concatenated as-is by <see cref="GetRequestURL(string,string)"/> and is expected to start with
    /// <c>&amp;</c> when non-empty.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This method builds the request URL using the configured <see cref="TGeminiSettings.BaseUrl"/>,
    /// <see cref="TGeminiSettings.Version"/>, and <see cref="TGeminiSettings.Token"/> (API key in query string),
    /// then performs the request through the decoupled <see cref="IHttpClientAPI"/> implementation.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. For non-2xx status codes,
    /// deserialization triggers error processing and raises a corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns an error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is not compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Get<TResult: class, constructor>(const Path: string;
      const Params: string = ''): TResult; overload;

    /// <summary>
    /// Sends a GET request to the specified API endpoint, using URL query parameters built by a
    /// <see cref="TUrlParam"/>-derived parameter object, and deserializes the JSON response into a
    /// strongly typed result object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type to deserialize into. Must be a class type with a parameterless
    /// constructor.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// A URL-parameter builder type deriving from <see cref="TUrlParam"/>. It is instantiated by this
    /// method and used to produce the query string (via <c>ToQueryString</c>).
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate the <typeparamref name="TParams"/> instance (for example
    /// setting page size, filters, or other query fields). If <c>nil</c>, an empty/default parameter
    /// instance is used.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// <para>
    /// • On HTTP 2xx responses, the JSON is deserialized into <typeparamref name="TResult"/>.
    /// </para>
    /// <para>
    /// • On deserialization failure for a successful response, a new <typeparamref name="TResult"/>
    /// instance is still returned and, when it inherits from <c>TJSONFingerprint</c>, the raw JSON
    /// response is stored in <c>JSONResponse</c>.
    /// </para>
    /// </returns>
    /// <remarks>
    /// The request URL is built by combining the API settings (base URL + version) with the given
    /// <paramref name="Path"/> and the query string produced by <typeparamref name="TParams"/>:
    /// <para>
    /// <c>{BaseUrl}/{Version}/{Path}?key={Token}{TParams.ToQueryString}</c>
    /// </para>
    /// This overload is intended for endpoints that expose their parameters via query strings rather
    /// than JSON bodies (typical for list/retrieve operations with pagination, filters, or masks).
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a
    /// known Gemini error type.
    /// </exception>
    /// <exception cref="EGeminiExceptionAPI">
    /// Raised if API settings are invalid (for example, missing API key or base URL) when validated
    /// prior to the request.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the server response is non-compliant or cannot be deserialized into
    /// <typeparamref name="TResult"/> (depending on error parsing / deserialization mode).
    /// </exception>
    function Get<TResult: class, constructor; TParams: TUrlParam>(const Path: string;
      ParamProc: TProc<TParams>): TResult; overload;

    /// <summary>
    /// Sends a GET request to the specified API endpoint and returns the raw response body as a string.
    /// </summary>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="Params">
    /// Optional query-string suffix appended to the request URL.
    /// This value is concatenated as-is by <see cref="GetRequestURL(string,string)"/> and is expected to start with
    /// <c>&amp;</c> when non-empty.
    /// </param>
    /// <returns>
    /// The raw response body returned by the API (typically JSON) as a UTF-8 string.
    /// </returns>
    /// <remarks>
    /// This overload is useful when the caller wants to handle JSON parsing manually or when the response does not map
    /// directly to a known DTO type.
    /// <para>
    /// • For HTTP 2xx responses, the method returns the response body unchanged. For non-2xx responses, it attempts to
    /// parse the error payload via <see cref="ParseError(Int64,string)"/> and raises the corresponding exception when possible.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised by downstream logic when the server response is non-compliant (depending on error parsing behavior).
    /// </exception>
    function Get(const Path: string; const Params: string = ''): string; overload;

    /// <summary>
    /// Sends a GET request to the specified API endpoint and writes the raw response body to the provided stream.
    /// </summary>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// The final request URL is built with <see cref="GetRequestURL(string)"/> (base URL + version + API key).
    /// </param>
    /// <param name="Response">
    /// Destination stream that receives the response body. The stream is not created or freed by this method.
    /// The caller is responsible for providing a writable stream positioned as desired before the call.
    /// </param>
    /// <returns>
    /// The HTTP status code returned by the server.
    /// On success (HTTP 2xx), the payload has been written to <paramref name="Response"/>.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload is intended for raw downloads (binary or text) where the caller wants direct access to the payload.
    /// It does not attempt to interpret or decode the response body.
    /// </para>
    /// <para>
    /// • Success path:<br/>
    /// For HTTP 2xx status codes, the method returns immediately after the underlying HTTP client has written the
    /// response body into <paramref name="Response"/>.
    /// </para>
    /// <para>
    /// • Error path:<br/>
    /// For non-2xx status codes, this method rewinds <paramref name="Response"/> to position 0, copies its contents into a
    /// temporary UTF-8 string stream, and attempts to parse a structured error payload via
    /// <see cref="DeserializeErrorData(Int64,string)"/>. When an error payload is recognized, the corresponding exception
    /// is raised and the method does not return normally.
    /// </para>
    /// <para>
    /// • Stream position:<br/>
    /// On error handling, <paramref name="Response"/> is explicitly rewound (<c>Position := 0</c>) before reading.
    /// On success, the stream position is left as written by the HTTP client (typically at end-of-stream).
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if configuration is invalid (for example, missing API key or base URL) when validated prior to the request.
    /// </exception>
    function GetFile(const Path: string; Response: TStream): Integer; overload;

    /// <summary>
    /// Downloads a raw payload from the specified endpoint into memory, wraps it into a minimal JSON object as a
    /// Base64-encoded string under a single field, and deserializes that JSON into <typeparamref name="TResult"/>.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// The generated JSON must be compatible with the DTO mapping for <typeparamref name="TResult"/>.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative API endpoint path (without the base URL) to download from.
    /// This value is combined with <see cref="GetRequestURL(string)"/> (base URL + version + API key) to form the final URL.
    /// </param>
    /// <param name="JSONFieldName">
    /// The name of the JSON field that will receive the downloaded payload as a Base64-encoded string.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the generated JSON payload containing the
    /// Base64-encoded download.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This overload is a convenience wrapper around <see cref="GetFile(string,TStream)"/>:
    /// it downloads the raw response body into an in-memory string stream, Base64-encodes the payload,
    /// then builds a minimal JSON object and calls <see cref="Deserialize{T}(Int64,string)"/>.
    /// </para>
    /// <para>
    /// • Default/assumption:<br/>
    /// This method assumes the downloaded payload can be represented safely as text before encoding.
    /// If the endpoint returns binary content (e.g., video, audio, images, PDF), using a text stream may corrupt data
    /// or raise encoding errors. Prefer <see cref="GetMedia{TResult}(string,string)"/> (binary-safe) for media/binary payloads.
    /// </para>
    /// <para>
    /// • The generated JSON has the form <c>{"&lt;JSONFieldName&gt;":"&lt;base64&gt;"}</c> and is intended for DTOs that
    /// expose a single Base64 string field mapped to <paramref name="JSONFieldName"/>.
    /// </para>
    /// <para>
    /// • Memory note:<br/>
    /// The entire response body is buffered in memory before encoding and deserialization.
    /// Base64 increases size by ~33% and may create additional temporary copies during JSON serialization/deserialization.
    /// For large payloads, prefer <see cref="GetFile(string,TStream)"/> to stream to a caller-managed destination.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if configuration is invalid (for example, missing API key or base URL) when validated prior to the request.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response cannot be wrapped/decoded as expected or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function GetFile<TResult: class, constructor>(const Endpoint: string;
      const JSONFieldName: string):TResult; overload;

    /// <summary>
    /// Downloads a raw (binary) payload from the specified endpoint, wraps it into a minimal JSON object as a
    /// Base64-encoded string under a single field, and deserializes that JSON into <typeparamref name="TResult"/>.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// The generated JSON must be compatible with the DTO mapping for <typeparamref name="TResult"/>.
    /// </typeparam>
    /// <param name="Endpoint">
    /// The relative API endpoint path (without the base URL) to download from.
    /// This value is combined with <see cref="GetRequestURL(string)"/> (base URL + version + API key) to form the final URL.
    /// </param>
    /// <param name="JSONFieldName">
    /// The name of the JSON field that will receive the downloaded payload as a Base64-encoded string.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the generated JSON payload containing the
    /// Base64-encoded download.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • This method is intended for media and other binary payloads (e.g., video, audio, images, PDF) returned as raw bytes
    /// (for example with <c>alt=media</c>).
    /// </para>
    /// <para>
    /// • Internally, it downloads the response body into an in-memory stream, Base64-encodes the raw bytes,
    /// builds a JSON object of the form <c>{"&lt;JSONFieldName&gt;":"&lt;base64&gt;"}</c>, then calls
    /// <see cref="Deserialize{T}(Int64,string)"/>.
    /// </para>
    /// <para>
    /// • Memory note:<br/>
    /// The entire payload is buffered in memory and expanded by Base64 (~33% larger) before JSON deserialization.
    /// For large payloads, prefer streaming APIs that write to a caller-managed destination (e.g. <see cref="GetFile(string,TStream)"/>)
    /// and avoid wrapping binary data into JSON.
    /// </para>
    /// <para>
    /// • Content-type note:<br/>
    /// This method does not attempt to interpret the payload as text; it always treats the response body as raw bytes.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if configuration is invalid (for example, missing API key or base URL) when validated prior to the request.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response cannot be wrapped/decoded as expected or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function GetMedia<TResult: class, constructor>(const Endpoint: string;
      const JSONFieldName: string):TResult; overload;

    /// <summary>
    /// Sends a DELETE request to the specified API endpoint and deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This method builds the request URL using the configured <see cref="TGeminiSettings.BaseUrl"/>,
    /// <see cref="TGeminiSettings.Version"/>, and <see cref="TGeminiSettings.Token"/> (API key in query string),
    /// then performs the request through the decoupled <see cref="IHttpClientAPI"/> implementation.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. For non-2xx status codes,
    /// deserialization triggers error processing and raises a corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns an error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is not compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Delete<TResult: class, constructor>(const Path: string; const
      Params: string = ''): TResult; overload;

    /// <summary>
    /// Sends a PATCH request to the specified API endpoint using a JSON body built by a parameter object,
    /// then deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// A JSON-parameter builder type deriving from <c>TJSONParam</c>, used to build the PATCH request body.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate an instance of <typeparamref name="TParams"/> before the request is sent.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload builds the request URL with <see cref="GetRequestURL(string)"/> (API key in query string),
    /// serializes the parameters object to JSON, and executes the request through the configured
    /// <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Patch<TResult: class, constructor; TParams: TJSONParam>(const Path: string;
      ParamProc: TProc<TParams>): TResult; overload;

    /// <summary>
    /// Sends a PATCH request to the specified API endpoint using an update mask in the URL and a JSON body built by a
    /// parameter object, then deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// A JSON-parameter builder type deriving from <c>TJSONParam</c>, used to build the PATCH request body.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="UriParams">
    /// The update mask value appended to the request URL as the <c>updateMask</c> query parameter.
    /// The string is inserted as-is by <see cref="GetPatchURL(string,string)"/> and must follow the format expected by Gemini.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate an instance of <typeparamref name="TParams"/> before the request is sent.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload targets endpoints that require an <c>updateMask</c> query parameter when performing partial updates.
    /// The request URL is built via <see cref="GetPatchURL(string,string)"/> (API key in query string), the request body is
    /// produced from <typeparamref name="TParams"/>, and the call is executed through the configured
    /// <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Patch<TResult: class, constructor; TParams: TJSONParam>(const Path, UriParams: string;
      ParamProc: TProc<TParams>): TResult; overload;

    /// <summary>
    /// Sends a PATCH request to the specified API endpoint using an update mask in the URL and a JSON payload,
    /// then deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="Params">
    /// The update mask value appended to the request URL as the <c>updateMask</c> query parameter.
    /// The string is inserted as-is by <see cref="GetPatchURL(string,string)"/> and must follow the format expected by Gemini.
    /// </param>
    /// <param name="ParamJSON">
    /// The JSON object to send as the PATCH request body. Ownership remains with the caller.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload targets partial-update endpoints that require an <c>updateMask</c> query parameter.
    /// The request URL is built via <see cref="GetPatchURL(string,string)"/> (API key in query string) and the request is
    /// executed through the configured <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Patch<TResult: class, constructor>(const Path, Params: string;
      ParamJSON: TJSONObject): TResult; overload;

    /// <summary>
    /// Sends a PATCH request to the specified API endpoint using the provided JSON payload,
    /// then deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="ParamJSON">
    /// The JSON object to send as the PATCH request body. Ownership remains with the caller.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload performs a standard PATCH request (no <c>updateMask</c> parameter) to the given endpoint.
    /// The request URL is built via <see cref="GetRequestURL(string)"/> (API key in query string) and the request is
    /// executed through the configured <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Patch<TResult: class, constructor>(const Path: string;
      ParamJSON: TJSONObject): TResult; overload;

    /// <summary>
    /// Sends a POST request to the specified API endpoint using a JSON body built by a parameter object,
    /// then deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// A JSON-parameter builder type deriving from <c>TJSONParam</c>, used to build the POST request body.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate an instance of <typeparamref name="TParams"/> before the request is sent.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload builds the request URL with <see cref="GetRequestURL(string)"/> (API key in query string),
    /// serializes the parameters object to JSON, and executes the request through the configured
    /// <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// T• he response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Post<TResult: class, constructor; TParams: TJSONParam>(const Path: string;
      ParamProc: TProc<TParams>;
      NullConversion: Boolean = False): TResult; overload;

    /// <summary>
    /// Sends a POST request to the specified API endpoint using the provided JSON payload,
    /// then deserializes the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="ParamJSON">
    /// The JSON object to send as the POST request body. Ownership remains with the caller.
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload performs a standard JSON POST request. The request URL is built via
    /// <see cref="GetRequestURL(string)"/> (API key in query string) and the request is executed through the configured
    /// <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Post<TResult: class, constructor>(const Path: string;
      ParamJSON: TJSONObject): TResult; overload;

    /// <summary>
    /// Sends a POST request to the specified API endpoint without a request body and deserializes the JSON response
    /// into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload is intended for endpoints that accept an empty POST body.
    /// The request URL is built via <see cref="GetRequestURL(string)"/> (API key in query string) and the request is
    /// executed through the configured <see cref="IHttpClientAPI"/> implementation using the default headers.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function Post<TResult: class, constructor>(const Path: string): TResult; overload;

    /// <summary>
    /// Sends a POST request with a JSON body built by a parameter object and streams the response into a string stream,
    /// optionally reporting received data through a callback.
    /// </summary>
    /// <typeparam name="TParams">
    /// A JSON-parameter builder type deriving from <c>TJSONParam</c>, used to build the POST request body.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate an instance of <typeparamref name="TParams"/> before the request is sent.
    /// </param>
    /// <param name="Response">
    /// The destination <c>TStringStream</c> that will receive the response body (typically JSON or SSE chunks).
    /// The stream is not created or freed by this method.
    /// </param>
    /// <param name="Event">
    /// An optional receive-data callback invoked by the underlying HTTP client as data is received.
    /// This is typically used for progressive/streaming responses.
    /// </param>
    /// <returns>
    /// <c>True</c> if the HTTP status code is in the 2xx range; otherwise <c>False</c>.
    /// </returns>
    /// <remarks>
    /// This overload is designed for scenarios where the caller wants direct access to the raw response stream and/or
    /// incremental receive notifications (for example, server-sent events).
    /// The request URL is built via <see cref="GetRequestURL(string)"/> (API key in query string) and the request is
    /// executed through the configured <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// • On non-2xx responses, this method rewinds <paramref name="Response"/> to position 0, loads it into a temporary
    /// UTF-8 stream, and calls <see cref="ParseError(Int64,string)"/> to raise the corresponding exception when possible.
    /// In this case, the function returns <c>False</c>.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if configuration is invalid (for example, missing API key or base URL) when the HTTP client validates settings.
    /// </exception>
    function Post<TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>;
      Response: TStringStream; Event: TReceiveDataCallback): Boolean; overload;

    /// <summary>
    /// Sends a POST request with a JSON body built by a parameter object, appends extra query parameters to the URL,
    /// and streams the response into the provided stream while optionally reporting received data through a callback.
    /// </summary>
    /// <typeparam name="TParams">
    /// A JSON-parameter builder type deriving from <c>TJSONParam</c>, used to build the POST request body.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="Params">
    /// Optional query-string suffix appended to the request URL.
    /// This value is concatenated as-is by <see cref="GetRequestURL(string,string)"/> and is expected to start with
    /// <c>&amp;</c> when non-empty.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate an instance of <typeparamref name="TParams"/> before the request is sent.
    /// </param>
    /// <param name="Response">
    /// The destination stream that will receive the response body (binary or text).
    /// The stream is not created or freed by this method.
    /// </param>
    /// <param name="Event">
    /// An optional receive-data callback invoked by the underlying HTTP client as data is received.
    /// This is typically used for progressive/streaming responses.
    /// </param>
    /// <returns>
    /// <c>True</c> if the HTTP status code is in the 2xx range; otherwise <c>False</c>.
    /// </returns>
    /// <remarks>
    /// This overload is intended for endpoints that require additional query parameters and/or return large or streaming
    /// payloads that should be written directly to <paramref name="Response"/>.
    /// The request URL is built via <see cref="GetRequestURL(string,string)"/> (API key in query string) and the request is
    /// executed through the configured <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// <para>
    /// • On non-2xx responses, this method rewinds <paramref name="Response"/> to position 0, copies it into a temporary
    /// UTF-8 string stream, and calls <see cref="ParseError(Int64,string)"/> to raise the corresponding exception when possible.
    /// In this case, the function returns <c>False</c>.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if configuration is invalid (for example, missing API key or base URL) when the HTTP client validates settings.
    /// </exception>
    function Post<TParams: TJSONParam>(const Path, Params: string; ParamProc: TProc<TParams>;
      Response: TStream; Event: TReceiveDataCallback): Boolean; overload;

    /// <summary>
    /// Sends a POST request with a JSON body built by a parameter object and streams the response body into
    /// the provided destination stream, optionally reporting incremental receive progress through a callback.
    /// </summary>
    /// <typeparam name="TParams">
    /// A JSON-parameter builder type deriving from <c>TJSONParam</c>, used to build the POST request body.
    /// It must provide a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL).
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate an instance of <typeparamref name="TParams"/> before the request is sent.
    /// If <c>nil</c>, an empty/default instance is used and its JSON is sent.
    /// </param>
    /// <param name="Response">
    /// The destination stream that will receive the response body (text or binary). The stream is not created
    /// or freed by this method.
    /// </param>
    /// <param name="Event">
    /// Optional receive-data callback invoked by the underlying HTTP client as data is received. This is typically
    /// used for progressive/streaming responses (for example, SSE) to decode chunks incrementally and/or to abort
    /// the transfer by setting the callback's abort flag.
    /// </param>
    /// <returns>
    /// <c>True</c> if the HTTP status code is in the 2xx range; otherwise <c>False</c>.
    /// </returns>
    /// <remarks>
    /// This overload is intended for endpoints that return large or streaming payloads that should be written
    /// directly to a caller-managed stream.
    /// <para>
    /// • The request URL is built via <see cref="GetRequestURL(string)"/> (base URL + version + API key in query string),
    /// and the call is executed through the configured <see cref="IHttpClientAPI"/> implementation using JSON headers.
    /// </para>
    /// <para>
    /// • Error handling: on non-2xx status codes, this method rewinds <paramref name="Response"/> to position 0,
    /// copies it into a temporary UTF-8 string stream, and invokes <see cref="DeserializeErrorData(Int64,string)"/>
    /// to raise the corresponding exception when the payload is parseable. When an exception is raised, control does
    /// not return normally.
    /// </para>
    /// <para>
    /// • Streaming: when <paramref name="Event"/> is assigned, it is invoked as data arrives so that callers can
    /// process incremental chunks (for example, feeding an SSE decoder) without waiting for the full response.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if configuration is invalid (for example, missing API key or base URL) when the HTTP client validates settings.
    /// </exception>
    function Post<TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>;
      Response: TStream; Event: TReceiveDataCallback): Boolean; overload;

    /// <summary>
    /// Sends a multipart/form-data POST request to the specified endpoint and deserializes the JSON response
    /// into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <typeparam name="TParams">
    /// A multipart/form-data builder type deriving from <c>TMultipartFormData</c>, used to build the request body.
    /// It must provide a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The relative API endpoint path (without the base URL). For file endpoints, it is combined with
    /// <see cref="GetFilesURL"/> to build the final URL.
    /// </param>
    /// <param name="ParamProc">
    /// A procedure invoked to populate an instance of <typeparamref name="TParams"/> before the request is sent
    /// (for example, adding fields and files to the multipart payload).
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// This overload is intended for endpoints that require <c>multipart/form-data</c> payloads, typically for file uploads.
    /// The request is executed through the configured <see cref="IHttpClientAPI"/> implementation using the default headers.
    /// The multipart boundary and content type are handled by the multipart implementation passed as <typeparamref name="TParams"/>.
    /// <para>
    /// • The response is deserialized using <see cref="Deserialize{TResult}(Int64,string)"/>. Any non-2xx status code
    /// triggers error processing and raises the corresponding exception.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiException">
    /// Raised when the API returns a structured error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised when the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(
      const Path: string; ParamProc: TProc<TParams>): TResult; overload;

    /// <summary>
    /// Uploads a local file as raw bytes (<c>application/octet-stream</c>) and deserializes
    /// the JSON response into a strongly typed object.
    /// </summary>
    /// <typeparam name="TResult">
    /// The target result type. It must be a class type with a parameterless constructor.
    /// </typeparam>
    /// <param name="Path">
    /// The request URL used <b>as-is</b> by the underlying HTTP client.
    /// This method does not build the URL (no base URL/version concatenation) and does not append
    /// the API key automatically. If the endpoint requires query parameters (for example <c>?key=...</c>),
    /// they must already be present in <paramref name="Path"/>.
    /// </param>
    /// <param name="FileName">
    /// Full path to the local file to upload. The file is opened read-only (shared read).
    /// </param>
    /// <returns>
    /// An instance of <typeparamref name="TResult"/> populated from the JSON response body.
    /// </returns>
    /// <remarks>
    /// The file is streamed directly to the server without JSON wrapping.
    /// The request is sent with <c>Content-Type: application/octet-stream</c>.
    /// <para>
    /// • Before sending the request, API settings are validated (token and base URL must be set),
    /// even though <paramref name="Path"/> is not derived from those settings.
    /// </para>
    /// </remarks>
    /// <exception cref="GeminiExceptionAPI">
    /// Raised if API settings are invalid (for example, missing API key or base URL) when validated prior to the request.
    /// </exception>
    /// <exception cref="GeminiException">
    /// Raised when the API returns an error payload that can be parsed and mapped to a known error type.
    /// </exception>
    /// <exception cref="EInvalidResponse">
    /// Raised if the response is non-compliant or cannot be deserialized into <typeparamref name="TResult"/>.
    /// </exception>
    /// <exception cref="EFOpenError">
    /// Raised if the file specified by <paramref name="FileName"/> cannot be opened.
    /// </exception>
    function UploadRaw<TResult: class, constructor>(const Path: string; const FileName: string): TResult;

    constructor Create; overload;
  end;

  /// <summary>
  /// Holds the process-wide "current model" selection used to build Gemini request routes.
  /// </summary>
  /// <remarks>
  /// This class centralizes the model identifier shared across API route builders.
  /// The selected model is stored in the class variable <c>CurrentModel</c>.
  /// <para>
  /// • Thread-safety: writes performed by <see cref="SetModel"/> and reads performed by
  /// <see cref="GetCurrentModel"/> are protected by <c>GeminiLock</c>. If you access
  /// <c>CurrentModel</c> directly, you must apply the same locking discipline.
  /// </para>
  /// <para>
  /// • Lifecycle: <c>GeminiLock</c> is created in the class constructor and released in the class destructor.
  /// </para>
  /// </remarks>
  TGeminiAPIModel = class
  protected
    /// <remarks>
    /// Thread-safety: updates to <c>CurrentModel</c> are protected by <c>GeminiLock</c>.
    /// <para>
    /// • <c>Supp</c> is treated as an optional suffix and is trimmed before concatenation.
    /// The stored <c>CurrentModel</c> is the effective value returned by this function.
    /// </para>
    /// </remarks>
    function SetModel(const ModelName: string; const Supp: string = ''): string;

  public
    /// <summary>
    /// Normalizes a Gemini model identifier to the canonical form expected by route builders.
    /// </summary>
    /// <param name="ModelName">
    /// The model name to normalize (for example, <c>gemini-1.5-pro</c> or <c>models/gemini-1.5-pro</c>).
    /// Leading slashes are tolerated.
    /// </param>
    /// <returns>
    /// The normalized model identifier, guaranteed to start with <c>models/</c>.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • If <paramref name="ModelName"/> already starts with <c>models/</c>, it is returned unchanged.
    /// </para>
    /// <para>
    /// • Otherwise, the function prefixes <c>models/</c> and trims leading <c>'/'</c> characters and surrounding whitespace.
    /// </para>
    /// <para>
    /// • This routine does not validate that the resulting model exists; it only normalizes the identifier format.
    /// </para>
    /// </remarks>
    class function ModelNormalize(const ModelName: string): string;
  end;

  TGeminiAPIRequestParams = class(TGeminiAPIModel)
  protected
    /// <summary>
    /// Builds the query-string portion used for paginated list requests.
    /// </summary>
    /// <param name="PageSize">
    /// The maximum number of items to request per page.
    /// </param>
    /// <param name="PageToken">
    /// An optional pagination token returned by a previous request, used to retrieve the next page.
    /// </param>
    /// <returns>
    /// A query-string suffix containing <c>pageSize</c> and, when provided, <c>pageToken</c>.
    /// The returned value is formatted to be appended directly after the API key query parameter.
    /// </returns>
    /// <remarks>
    /// The returned string always starts with <c>&amp;pageSize=</c>.
    /// When <paramref name="PageToken"/> is not empty, it is URL-encoded and appended as
    /// <c>&amp;pageToken=...</c>.
    /// </remarks>
    function ParamsBuilder(const PageSize: Integer; const PageToken: string = ''): string; overload;

    /// <summary>
    /// Builds the query-string portion used for paginated list requests, with an optional filter expression.
    /// </summary>
    /// <param name="PageSize">
    /// The maximum number of items to request per page.
    /// </param>
    /// <param name="PageToken">
    /// An optional pagination token returned by a previous request, used to retrieve the next page.
    /// </param>
    /// <param name="Filter">
    /// An optional filter expression used to restrict the returned items according to API-specific criteria.
    /// </param>
    /// <returns>
    /// A query-string suffix containing <c>pageSize</c> and, when provided, <c>pageToken</c> and <c>filter</c>.
    /// The returned value is formatted to be appended directly after the API key query parameter.
    /// </returns>
    /// <remarks>
    /// This overload composes the pagination parameters using
    /// <see cref="ParamsBuilder(Integer,string)"/> and, when <paramref name="Filter"/> is not empty,
    /// appends <c>&amp;filter=...</c> with the filter value URL-encoded.
    /// </remarks>
    function ParamsBuilder(const PageSize: Integer; const PageToken, Filter: string): string; overload;

    /// <summary>
    /// Builds the query-string portion used to force an operation when supported by the target endpoint.
    /// </summary>
    /// <param name="Force">
    /// Indicates whether the <c>force</c> query parameter should be included.
    /// </param>
    /// <returns>
    /// A query-string suffix suitable for appending directly after the API key query parameter:
    /// <c>&amp;force=true</c> when <paramref name="Force"/> is <c>True</c>, otherwise an empty string.
    /// </returns>
    /// <remarks>
    /// <para>
    /// • When <paramref name="Force"/> is <c>False</c>, this function returns <c>''</c> (no query parameters added).
    /// </para>
    /// <para>
    /// • When <paramref name="Force"/> is <c>True</c>, this function returns <c>&amp;force=true</c>.
    /// </para>
    /// <para>
    /// • The returned value is formatted to be concatenated to an existing query string that already contains
    /// the API key parameter (for example, <c>?key=...</c>), therefore it starts with <c>&amp;</c>.
    /// </para>
    /// </remarks>
    function ParamsBuilder(const Force: Boolean): string; overload;
  end;

  TGeminiAPIRoute = class(TGeminiAPIRequestParams)
  private
    FAPI: TGeminiAPI;
    procedure SetAPI(const Value: TGeminiAPI);
  public
    /// <summary>
    /// Gets or sets the <c>TGeminiAPI</c> instance used by this route to execute HTTP requests.
    /// </summary>
    /// <value>
    /// A configured <c>TGeminiAPI</c> instance providing transport, authentication, URL building, and
    /// JSON (de)serialization services.
    /// </value>
    /// <remarks>
    /// Route classes delegate all network operations to this API object (for example <c>Get</c>, <c>Post</c>,
    /// <c>Delete</c>, streaming POST overloads, and error handling).
    /// <para>
    /// • The route does not take ownership of the assigned instance; lifecycle management is expected to be handled
    /// by the caller or the component that constructs the routes.
    /// </para>
    /// <para>
    /// • Assigning a different instance at runtime redirects subsequent route calls to the new API object.
    /// </para>
    /// </remarks>
    property API: TGeminiAPI read FAPI write SetAPI;

    /// <summary>
    /// Creates a new route instance bound to the specified <c>TGeminiAPI</c> executor.
    /// </summary>
    /// <param name="AAPI">
    /// The <c>TGeminiAPI</c> instance that will be used by this route to execute requests.
    /// </param>
    /// <remarks>
    /// This constructor binds the route to an API executor and initializes inherited request-parameter helpers.
    /// <para>
    /// • The provided <paramref name="AAPI"/> is stored in the <see cref="API"/> property and is used for all
    /// subsequent route calls.
    /// </para>
    /// <para>
    /// • This constructor uses <c>reintroduce</c> to hide an inherited <c>Create</c> constructor. Callers should
    /// prefer <c>CreateRoute</c> to ensure the route is correctly associated with an API instance.
    /// </para>
    /// </remarks>
    constructor CreateRoute(AAPI: TGeminiAPI); reintroduce;

    destructor Destroy; override;
  end;

implementation

uses
  Gemini.Api.JsonFingerprintBinder;

{ TGeminiAPI }

constructor TGeminiAPI.Create;
begin
  inherited Create;

end;

function TGeminiAPI.GetDefaultHeaders: TNetHeaders;
begin
  Result :=
    FCustomHeaders +
    [TNetHeader.Create('Accept', 'application/json')];
end;

function TGeminiAPI.GetFilesURL(const Path: string): string;
begin
  Result := TGeminiUrl.Create(FBaseURL, FVersion, Token).FilesUrl(Path);
end;

function TGeminiAPI.GetJsonHeaders: TNetHeaders;
begin
  Result :=
    GetDefaultHeaders +
    [TNetHeader.Create('Content-Type', 'application/json')];
end;

function TGeminiAPI.GetRequestFilesURL(const Path: string): string;
begin
  Result := TGeminiUrl.Create(FBaseURL, FVersion, Token).RequestFilesUrl(Path);
end;

function TGeminiAPI.GetRequestURL(const Path: string): string;
begin
  Result := TGeminiUrl.Create(FBaseURL, FVersion, Token).RequestUrl(Path);
end;

function TGeminiAPI.GetRequestURL(const Path, Params: string): string;
begin
  Result := TGeminiUrl.Create(FBaseURL, FVersion, Token).RequestUrl(Path, Params);
end;

function TGeminiAPI.MockJsonFile(const FieldName: string;
  Response: TStream): string;
var
  Bytes: TBytes;
  B64: string;
  Obj: TJSONObject;
begin
  Response.Position := 0;
  SetLength(Bytes, Response.Size);
  if Length(Bytes) > 0 then
    Response.ReadBuffer(Bytes[0], Length(Bytes));

  B64 := TNetEncoding.Base64.EncodeBytesToString(Bytes);

  Obj := TJSONObject.Create;
  try
    Obj.AddPair(FieldName, B64);     // JSON escaping géré
    Result := Obj.ToString;
  finally
    Obj.Free;
  end;
end;

function BytesToString(const Value: TBytes): string;
begin
  if Length(Value) = 0 then
    raise Exception.Create('BytesToString is empty.');
  var MemStream := TMemoryStream.Create;
  try
    MemStream.WriteBuffer(Value[0], Length(Value));
    MemStream.Position := 0;
    var Reader := TStreamReader.Create(MemStream, TEncoding.UTF8);
    try
      Result := Reader.ReadToEnd;
    finally
      Reader.Free;
    end;
  finally
    MemStream.Free;
  end;
end;

function EncodeBase64(const Value: TStream): string; overload;
begin
  var Stream := TMemoryStream.Create;
  var StreamOutput := TStringStream.Create('', TEncoding.UTF8);
  try
    Stream.LoadFromStream(Value);
    Stream.Position := 0;
    {$IF RTLVersion >= 35.0}
    TNetEncoding.Base64String.Encode(Stream, StreamOutput);
    {$ELSE}
    TNetEncoding.Base64.Encode(Stream, StreamOutput);
    {$ENDIF}
    Result := StreamOutput.DataString;
  finally
    Stream.Free;
    StreamOutput.Free;
  end;
end;

function TGeminiAPI.MockJsonFile(const FieldName: string;
  Response: TStringStream): string;
begin
  Response.Position := 0;
  var Data := TStringStream.Create(BytesToString(Response.Bytes).TrimRight([#0]));
  try
    Result := Format('{"%s":"%s"}', [FieldName, EncodeBase64(Data)]);
  finally
    Data.Free;
  end;
end;

function TGeminiAPI.GetPatchURL(const Path, Params: string): string;
begin
  Result := Format('%s/%s/%s?key=%s&updateMask=%s', [FBaseURL, Fversion, Path, Token, Params]);
end;

function TGeminiAPI.Find<TParams>(const Path: string; KeyName: string; ParamProc: TProc<TParams>): string;
var
  ResponseHeader: TNetHeaders;
  Params: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  Result := '';
  Params := nil;
  try
    var Http := NewHttpClient;
    if Assigned(ParamProc) then
      begin
        Params := TParams.Create;
        ParamProc(Params);
        Code := Http.PostHeaders(GetRequestFilesURL(Path), Params.JSON, GetJsonHeaders, ResponseHeader);
      end
    else
      Code := Http.PostHeaders(GetRequestFilesURL(Path), nil, GetJsonHeaders, ResponseHeader);

    case Code of
      200..299: {success};
    else
      raise EGeminiException.Create('Error on response headers');
    end;

    for var Item in ResponseHeader do
      if SameText(Item.Name, KeyName) then
      begin
        Result := Item.Value;
        Break;
      end;
  finally
    Params.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Get(const Path: string; const Params: string): string;
var
  Response: TStringStream;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    Code := Http.Get(GetRequestURL(Path, Params), Response, GetDefaultHeaders);
    case code of
      200..299: {success};
      else
        DeserializeErrorData(Code, Response.DataString);
    end;
    Result := Response.DataString;
  finally
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Get<TResult, TParams>(const Path: string;
  ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Code: Integer;
  Params: TParams;
begin
  Monitoring.Inc;
  Params := TParams.Create;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    if Assigned(ParamProc) then
      ParamProc(Params);

    var Http := NewHttpClient;
    Code := Http.Get(GetRequestURL(Path, Params.ToQueryString), Response, GetDefaultHeaders);
    case Code of
      200..299:
        try
          Result := Deserialize<TResult>(Code, Response.DataString);
        except
          Result := TResult.Create;
          (Result as TJSONFingerprint).JSONResponse := Response.DataString;
        end;
      else
        begin
          DeserializeErrorData(Code, Response.DataString);
          Result := nil;
        end;
    end;
  finally
    Params.Free;
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Get<TResult>(const Path: string; const Params: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    Code := Http.Get(GetRequestURL(Path, Params), Response, GetDefaultHeaders);
    case Code of
      200..299:
        try
          Result := Deserialize<TResult>(Code, Response.DataString);
        except
          Result := TResult.Create;
          (Result as TJSONFingerprint).JSONResponse := Response.DataString;
        end;
      else
        begin
          DeserializeErrorData(Code, Response.DataString);
          Result := nil;
        end;
    end;
  finally
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.GetFile(const Path: string; Response: TStream): Integer;
begin
  Monitoring.Inc;
  try
    var Http := NewHttpClient;
    Result := Http.Get(GetRequestURL(Path), Response, GetDefaultHeaders);
    case Result of
      200..299: {success};
      else
        begin
          var Recieved := TStringStream.Create('', TEncoding.UTF8);
          try
            Response.Position := 0;
            Recieved.LoadFromStream(Response);
            DeserializeErrorData(Result, Recieved.DataString);
          finally
            Recieved.Free;
          end;
        end;
    end;
  finally
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.GetFile<TResult>(const Endpoint,
  JSONFieldName: string): TResult;
begin
  Monitoring.Inc;
  var Stream := TStringStream.Create;
  try
    var Code := GetFile(Endpoint, Stream);
    Result := Deserialize<TResult>(Code, MockJsonFile(JSONFieldName, Stream));
  finally
    Stream.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.GetMedia<TResult>(const Endpoint,
  JSONFieldName: string): TResult;
begin
  Monitoring.Inc;
  var Stream := TMemoryStream.Create;
  try
    var Code := GetFile(Endpoint, Stream);
    Result := Deserialize<TResult>(Code, MockJsonFile(JSONFieldName, Stream));
  finally
    Stream.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Delete<TResult>(const Path: string; const Params: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    Code := Http.Delete(GetRequestURL(Path, Params), Response, GetDefaultHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Post<TParams>(const Path: string; ParamProc: TProc<TParams>;
  Response: TStringStream; Event: TReceiveDataCallback): Boolean;
var
  Params: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);

    var Http := NewHttpClient;
    Code := Http.Post(GetRequestURL(Path), Params.JSON, Response, GetJsonHeaders, Event);
    case code of
      200..299:
        Result := True;
      else
        begin
          var Recieved := TStringStream.Create('', TEncoding.UTF8);
          try
            Response.Position := 0;
            Recieved.LoadFromStream(Response);
            DeserializeErrorData(Code, Recieved.DataString);
            Result := False;
          finally
            Recieved.Free;
          end;
        end;
    end;
  finally
    Params.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Post<TParams>(const Path, Params: string; ParamProc: TProc<TParams>;
  Response: TStream; Event: TReceiveDataCallback): Boolean;
var
  P: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  P := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(P);

    var Http := NewHttpClient;
    Code := Http.Post(GetRequestURL(Path, Params), P.JSON, Response, GetJsonHeaders, Event);
    case Code of
      200..299:
        Result := True;
      else
        begin
          var Recieved := TStringStream.Create('', TEncoding.UTF8);
          try
            Response.Position := 0;
            Recieved.LoadFromStream(Response);
            DeserializeErrorData(Code, Recieved.DataString);
            Result := False;
          finally
            Recieved.Free;
          end;
        end;
    end;
  finally
    P.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Post<TParams>(const Path: string; ParamProc: TProc<TParams>;
  Response: TStream; Event: TReceiveDataCallback): Boolean;
var
  P: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  P := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(P);

    var Http := NewHttpClient;
    Code := Http.Post(GetRequestURL(Path), P.JSON, Response, GetJsonHeaders, Event);
    case Code of
      200..299:
        Result := True;
      else
        begin
          var Recieved := TStringStream.Create('', TEncoding.UTF8);
          try
            Response.Position := 0;
            Recieved.LoadFromStream(Response);
            DeserializeErrorData(Code, Recieved.DataString);
            Result := False;
          finally
            Recieved.Free;
          end;
        end;
    end;
  finally
    P.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Post<TResult, TParams>(const Path: string;
  ParamProc: TProc<TParams>;
  NullConversion: Boolean): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Http := NewHttpClient;
    Code := Http.Post(GetRequestURL(Path), Params.JSON, Response, GetJsonHeaders, nil);
    Result := Deserialize<TResult>(Code, Response.DataString, NullConversion);
  finally
    Params.Free;
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Post<TResult>(const Path: string; ParamJSON: TJSONObject): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    Code := Http.Post(GetRequestURL(Path), ParamJSON, Response, GetJsonHeaders, nil);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Post<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    Code := Http.Post(GetRequestURL(Path), Response, GetDefaultHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.PostForm<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Http := NewHttpClient;
    Code := Http.Post(GetFilesURL(Path), Params, Response, GetDefaultHeaders);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Patch<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Http := NewHttpClient;
    Code := Http.Patch(GetRequestURL(Path), Params.JSON, Response, GetJsonHeaders, nil);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Patch<TResult, TParams>(const Path, UriParams: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    var Http := NewHttpClient;
    Code := Http.Patch(GetPatchURL(Path, UriParams), Params.JSON, Response, GetJsonHeaders, nil);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Patch<TResult>(const Path: string; ParamJSON: TJSONObject): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    Code := Http.Patch(GetRequestURL(Path), ParamJSON, Response, GetJsonHeaders, nil);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.Patch<TResult>(const Path, Params: string; ParamJSON: TJSONObject): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Monitoring.Inc;
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    var Http := NewHttpClient;
    Code := Http.Patch(GetPatchURL(Path, Params), ParamJSON, Response, GetJsonHeaders, nil);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    Response.Free;
    Monitoring.Dec;
  end;
end;

function TGeminiAPI.UploadRaw<TResult>(const Path, FileName: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
  Headers: TNetHeaders;
begin
  Monitoring.Inc;
  VerifyApiSettings;
  Headers := GetDefaultHeaders + [TNetHeader.Create('Content-Type', 'application/octet-stream')];

  Response := TStringStream.Create('', TEncoding.UTF8);
  var FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    var Http := NewHttpClient;
    Code := Http.Post(Path, FileStream, Response, Headers);
    Result := Deserialize<TResult>(Code, Response.DataString);
  finally
    FileStream.Free;
    Response.Free;
    Monitoring.Dec;
  end;
end;

{ TGeminiAPIRoute }

constructor TGeminiAPIRoute.CreateRoute(AAPI: TGeminiAPI);
begin
  inherited Create;
  FAPI := AAPI;
end;

destructor TGeminiAPIRoute.Destroy;
begin
  inherited;
end;

procedure TGeminiAPIRoute.SetAPI(const Value: TGeminiAPI);
begin
  FAPI := Value;
end;

class function TGeminiAPIModel.ModelNormalize(const ModelName: string): string;
begin
  if not ModelName.StartsWith('models/') then
    Result := 'models/' + ModelName.TrimLeft(['/']).Trim
  else
    Result := ModelName;
end;

function TGeminiAPIModel.SetModel(const ModelName: string; const Supp: string): string;
begin
  var Base := ModelName.Trim;
  if Base.IsEmpty then
    raise Exception.Create('Error: Unknown model name provided.');

  Base := ModelNormalize(Base);

  var Suffix := Supp.Trim;

  Result := Base;
  if not Suffix.IsEmpty then
    Result := Result + Suffix;
end;

{ TGeminiAPIRequestParams }

function TGeminiAPIRequestParams.ParamsBuilder(const PageSize: Integer; const PageToken: string): string;
begin
  Result := Format('&pageSize=%d', [PageSize]);
  if not PageToken.IsEmpty then
    Result := Result + '&pageToken=' + TNetEncoding.URL.Encode(PageToken);
end;

function TGeminiAPIRequestParams.ParamsBuilder(const PageSize: Integer; const PageToken, Filter: string): string;
begin
  Result := ParamsBuilder(PageSize, PageToken);
  if not Filter.IsEmpty then
    Result := Result + '&filter=' + TNetEncoding.URL.Encode(Filter);
end;

function TGeminiAPIRequestParams.ParamsBuilder(const Force: Boolean): string;
begin
  if not Force then
    Exit('');

  Result := '&force=true';
end;

{ TGeminiSettings }

constructor TGeminiSettings.Create;
begin
  inherited Create;
  FToken := EmptyStr;
  FBaseUrl := URL_BASE;
  FVersion := VERSION_BASE;
  FCustomHeaders := [];
end;

procedure TGeminiSettings.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TGeminiSettings.SetCustomHeaders(const Value: TNetHeaders);
begin
  FCustomHeaders := Value;
end;

procedure TGeminiSettings.SetOrganization(const Value: string);
begin
  FOrganization := Value;
end;

procedure TGeminiSettings.SetToken(const Value: string);
begin
  FToken := Value;
end;

procedure TGeminiSettings.SetVersion(const Value: string);
begin
  FVersion := Value;
end;

{ TApiHttpHandler }

function TApiHttpHandler.NewHttpClient: IHttpClientAPI;
begin
  Result := THttpClientAPI.CreateInstance(VerifyApiSettings);

  if Assigned(FHttpClient) then
    begin
      Result.SendTimeOut        := FHttpClient.SendTimeOut;
      Result.ConnectionTimeout  := FHttpClient.ConnectionTimeout;
      Result.ResponseTimeout    := FHttpClient.ResponseTimeout;
      Result.ProxySettings      := FHttpClient.ProxySettings;
    end;
end;

procedure TApiHttpHandler.VerifyApiSettings;
begin
  if FToken.IsEmpty or FBaseUrl.IsEmpty then
    raise EGeminiExceptionAPI.Create('Invalid API key or base URL.');
end;

constructor TApiHttpHandler.Create;
begin
  inherited Create;

  {--- TEMPLATE de config, exposé via IGemini.HttpClient }
  FHttpClient := THttpClientAPI.CreateInstance(VerifyApiSettings);
end;

{ TApiDeserializer }

class constructor TApiDeserializer.Create;
begin
  FMetadataManager := TDeserializationPrepare.CreateInstance;
  FMetadataAsObject := False;
end;

function TApiDeserializer.Deserialize<T>(const Code: Int64;
  const ResponseText: string; DisabledShield: Boolean): T;
begin
  Result := nil;
  case Code of
    200..299:
      try
        Result := Parse<T>(ResponseText, DisabledShield);
      except
        raise;
      end;
    else
      DeserializeErrorData(Code, ResponseText);
  end;
end;

procedure TApiDeserializer.DeserializeErrorData(const Code: Int64;
  const ResponseText: string);
var
  Error: TError;
begin
  Error := nil;
  try
    try
      Error := TJson.JsonToObject<TError>(ResponseText);
    except
      Error := nil;
    end;
    if Assigned(Error) then
      RaiseError(Code, Error)
    else
      raise EGeminiExceptionAPI.CreateFmt(
        'Server returned error code %d but response was not parseable: %s', [Code, ResponseText]);
  finally
    if Assigned(Error) then
      Error.Free;
  end;
end;

class function TApiDeserializer.Parse<T>(const Value: string; DisabledShield: Boolean): T;
{$REGION 'Dev note'}
  (*
    • If MetadataManager are to be treated as objects, a dedicated TMetadata class is required, containing
      all properties corresponding to the specified JSON fields.

    • However, if MetadataManager are not treated as objects, they will be temporarily handled as a string
      and subsequently converted back into a valid JSON string during deserialization using the
      Revert method of the interceptor.

    By default, MetadataManager are treated as strings rather than objects to handle cases where multiple
    classes to be deserialized may contain variable data structures. Refer to the global variable
    MetadataAsObject.

    • JSON fingerprint propagation:
      If the target type inherits from TJSONFingerprint, the original JSON payload is normalized
      (formatted) and stored into JSONResponse. The formatted JSON is then propagated to all
      TJSONFingerprint instances found in the resulting object graph via
      TJSONFingerprintBinder.Bind(Result, Formatted). The binder traverses RTTI fields only (no
      properties evaluated) and is cycle-safe.

    • Exception safety:
      Post-processing (formatting/binding) may raise (e.g., truncation handler in DEBUG). On any
      exception after allocation, the partially created instance is freed before re-raising to
      prevent leaks.
  *)
{$ENDREGION}
var
  Obj: TObject;
begin
  Result := Default(T);
  try
    if DisabledShield then
      begin
        Result := TJson.JsonToObject<T>(Value);
      end
    else
      case MetadataAsObject of
        True:
          Result := TJson.JsonToObject<T>(Value);
        else
          begin
            if MetadataManager = nil then
              raise EInvalidResponse.Create('MetadataManager is nil while MetadataAsObject=False');
            try
              Result := TJson.JsonToObject<T>(MetadataManager.Convert(Value));
            except

            end;
          end;
      end;

    {--- Add JSON response if class inherits from TJSONFingerprint class. }
    if Assigned(Result) and (Result is TJSONFingerprint) then
      begin
        var JSONValue := TJSONObject.ParseJSONValue(Value);
        try
          var Formatted := JSONValue.Format();

          (Result as TJSONFingerprint).JSONResponse := Formatted;
          TJSONFingerprintBinder.Bind(Result, Formatted);
        finally
          JSONValue.Free;
        end;
      end;
  except
    Obj := TObject(Result);
    if Obj <> nil then
      Obj.Free;
//    raise;
  end;
end;

procedure TApiDeserializer.RaiseError(Code: Int64; Error: TErrorCore);
begin
  case Code of
    400: raise EInvalidArgument.Create(Code, Error);
    403: raise EPermissionDenied.Create(Code, Error);
    404: raise EResourceNotFound.Create(Code, Error);
    429: raise EResourceExhausted.Create(Code, Error);
    500: raise EInternalError.Create(Code, Error);
    503: raise ETryAgain.Create(Code, Error);
    504: raise EDeadlineExceeded.Create(Code, Error);
  else
    raise EGeminiException.Create(Code, Error);
  end;
end;

end.

