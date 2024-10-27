unit Gemini.API;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Net.Mime, System.JSON, System.SyncObjs, Gemini.API.Params, Gemini.Errors;

type
  GeminiException = class(Exception)
  private
    FCode: Int64;
    FMsg: string;
    FStatus: string;
  public
    constructor Create(const ACode: Int64; const AError: TErrorCore); reintroduce; overload;
    constructor Create(const ACode: Int64; const Value: string); reintroduce; overload;
    property Code: Int64 read FCode write FCode;
    property Msg: string read FMsg write FMsg;
    property Status: string read FStatus write FStatus;
  end;

  /// <summary>
  /// The `GeminiExceptionAPI` class represents a generic API-related exception.
  /// It is thrown when there is an issue with the API configuration or request process,
  /// such as a missing API token, invalid base URL, or other configuration errors.
  /// This class serves as a base for more specific API exceptions.
  /// </summary>
  GeminiExceptionAPI = class(Exception);

  /// <summary>
  /// An InvalidRequestError indicates that your request was malformed or
  /// missing some required parameters, such as a token or an input.
  /// This could be due to a typo, a formatting error, or a logic error in your code.
  /// </summary>
  GeminiExceptionInvalidRequestError = class(GeminiException);

  /// <summary>
  /// A `RateLimitError` indicates that you have hit your assigned rate limit.
  /// This means that you have sent too many tokens or requests in a given period of time,
  /// and our services have temporarily blocked you from sending more.
  /// </summary>
  GeminiExceptionRateLimitError = class(GeminiException);

  /// <summary>
  /// An `AuthenticationError` indicates that your API key or token was invalid,
  /// expired, or revoked. This could be due to a typo, a formatting error, or a security breach.
  /// </summary>
  GeminiExceptionAuthenticationError = class(GeminiException);

  /// <summary>
  /// This error message indicates that your account is not part of an organization
  /// </summary>
  GeminiExceptionPermissionError = class(GeminiException);

  /// <summary>
  /// An `InvalidResponse` error occurs when the API response is either empty or not in the expected format.
  /// This error indicates that the API did not return a valid response that can be processed, possibly due to a server-side issue,
  /// a malformed request, or unexpected input data.
  /// </summary>
  GeminiExceptionInvalidResponse = class(GeminiException);

  /// <summary>
  /// An `InvalidResponse` error occurs when the API response is either empty or not in the expected format.
  /// This error indicates that the API did not return a valid response that can be processed, possibly due to a server-side issue,
  /// a malformed request, or unexpected input data.
  /// </summary>
  GeminiExceptionNotFoundError = class(GeminiException);

  /// <summary>
  /// Une erreur `not_found_error` se produit lorsque la ressource demand�e n'a pas �t� trouv�e.
  /// Cette erreur indique que l'API n'a pas renvoy� de r�ponse valide pouvant �tre trait�e, probablement en raison d'un probl�me c�t� serveur,
  /// d'une demande mal formul�e ou de donn�es d'entr�e inattendues.
  /// </summary>
  GeminiExceptionRequestTooLarge = class(GeminiException);

  /// <summary>
  /// An `api_error` error occurs when an unexpected error has occurred internal to Gemini�s systems
  /// </summary>
  GeminiExceptionAPIError = class(GeminiException);

  /// <summary>
  /// An `overloaded_error` error occurs when Gemini�s API is temporarily overloaded.
  /// </summary>
  GeminiExceptionOverloadedError = class(GeminiException);

  TGeminiAPI = class
  public
    const
      URL_BASE = 'https://generativelanguage.googleapis.com';
  private
    FHTTPClient: THTTPClient;
    FToken: string;
    FBaseUrl: string;
    FOrganization: string;
    FCustomHeaders: TNetHeaders;
    procedure SetToken(const Value: string);
    procedure SetBaseUrl(const Value: string);
    procedure SetOrganization(const Value: string);
    procedure RaiseError(Code: Int64; Error: TErrorCore);
    procedure ParseError(const Code: Int64; const ResponseText: string);
    procedure SetCustomHeaders(const Value: TNetHeaders);

  private
    function ToStringValueFor(const Value: string): string; overload;
    function ToStringValueFor(const Value: string; const Field: string): string; overload;
    function ToStringValueFor(const Value: string; const Field: TArray<string>): string; overload;

  protected
    function GetHeaders: TNetHeaders;
    function GetFilesURL(const Path: string): string;
    function GetRequestURL(const Path: string): string; overload;
    function GetRequestURL(const Path, Params: string): string; overload;
    function GetRequestFilesURL(const Path: string): string;
    function GetPatchURL(const Path, Params: string): string;
    function Get(const Path, Params: string; Response: TStringStream): Integer; overload;
    function Delete(const Path: string; Response: TStringStream): Integer; overload;
    function Patch(const Path: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback = nil): Integer; overload;
    function Patch(const Path, UriParams: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback = nil): Integer; overload;
    function Post(const Path: string; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback = nil): Integer; overload;
    function Post(const Path: string; Body: TMultipartFormData; Response: TStringStream): Integer; overload;
    function Post(const Path: string; Body: TJSONObject; var ResponseHeader: TNetHeaders): Integer; overload;
    function ParseResponse<T: class, constructor>(const Code: Int64; const ResponseText: string): T;
    procedure CheckAPI;

  public
    function Find<TParams: TJSONParam>(const Path: string; KeyName: string; ParamProc: TProc<TParams>): string;
    function Get<TResult: class, constructor>(const Path: string; const Params: string = ''): TResult; overload;
    function Get(const Path: string; const Params: string = ''): string; overload;
    procedure GetFile(const Path: string; Response: TStream); overload;
    function Delete<TResult: class, constructor>(const Path: string): TResult; overload;
    function Patch<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function Patch<TResult: class, constructor; TParams: TJSONParam>(const Path, UriParams: string; ParamProc: TProc<TParams>): TResult; overload;
    function Patch<TResult: class, constructor>(const Path, Params: string; ParamJSON: TJSONObject): TResult; overload;

    function Patch<TResult: class, constructor>(const Path: string; ParamJSON: TJSONObject): TResult; overload;

    function Post<TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>; Response: TStringStream; Event: TReceiveDataCallback): Boolean; overload;
    function Post<TResult: class, constructor; TParams: TJSONParam>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function Post<TResult: class, constructor>(const Path: string; ParamJSON: TJSONObject): TResult; overload;
    function Post<TResult: class, constructor>(const Path: string): TResult; overload;
    function PostForm<TResult: class, constructor; TParams: TMultipartFormData, constructor>(const Path: string; ParamProc: TProc<TParams>): TResult; overload;
    function UploadRaw<TResult: class, constructor>(const Path: string; const FileName: string): TResult;

  public
    constructor Create; overload;
    constructor Create(const AToken: string); overload;
    destructor Destroy; override;
    property Token: string read FToken write SetToken;
    property BaseUrl: string read FBaseUrl write SetBaseUrl;
    property Organization: string read FOrganization write SetOrganization;
    property Client: THTTPClient read FHTTPClient;
    property CustomHeaders: TNetHeaders read FCustomHeaders write SetCustomHeaders;
  end;

  /// <summary>
  /// The <c>TGeminiAPIModel</c> class manages the configuration and state
  /// related to the language models used within the Gemini API framework.
  /// </summary>
  /// <remarks>
  /// This class handles the current model selection, ensures that model names
  /// adhere to the required formatting standards, and provides thread-safe
  /// access to the model configuration through the use of a critical section.
  /// It serves as a foundational class for managing model-specific operations
  /// within the Gemini API.
  /// </remarks>
  TGeminiAPIModel = class
    /// <summary>
    /// Holds the name of the currently active model used for embedding requests.
    /// </summary>
    /// <remarks>
    /// This class variable ensures that all embedding operations reference the
    /// correct model, maintaining consistency across API requests.
    /// </remarks>
    class var CurrentModel: string;
    /// <summary>
    /// A critical section object that ensures thread-safe access to model-related
    /// operations and variables.
    /// </summary>
    /// <remarks>
    /// The <c>GeminiLock</c> ensures that changes to the model configuration
    /// are performed atomically, preventing race conditions in multi-threaded
    /// environments.
    /// </remarks>
    class var GeminiLock: TCriticalSection;
  protected
    /// <summary>
    /// Sets the active model name after validating its format.
    /// </summary>
    /// <param name="ModelName">
    /// The name of the model to be set as active.
    /// </param>
    /// <param name="Supp">
    /// An optional supplementary string to append to the model name.
    /// </param>
    /// <returns>
    /// The finalized model name after formatting and appending the supplementary string.
    /// </returns>
    /// <remarks>
    /// This method not only sets the current model but also ensures that any
    /// supplementary information is correctly appended, maintaining the integrity
    /// of the model name within the API framework.
    /// </remarks>
    function SetModel(const ModelName: string; const Supp: string = ''): string;

    function SetFile(const Path: string): string;
  public
    /// <summary>
    /// Initializes the <c>TGeminiAPIModel</c> class by creating necessary
    /// synchronization objects.
    /// </summary>
    /// <remarks>
    /// The class constructor sets up the critical section used for thread-safe
    /// operations related to model management.
    /// </remarks>
    class constructor Create;
    /// <summary>
    /// Finalizes the <c>TGeminiAPIModel</c> class by releasing allocated resources.
    /// </summary>
    /// <remarks>
    /// The class destructor frees the critical section object, ensuring that
    /// all resources are properly released when the application terminates.
    /// </remarks>
    class destructor Destroy;
  end;

  /// <summary>
  /// Provides methods for building route parameters related to model retrieval in API requests.
  /// </summary>
  /// <remarks>
  /// The <c>TModelsRouteParams</c> class is responsible for constructing query parameters such as
  /// pagination settings, including page size and page token, for API calls that retrieve model data.
  /// This class extends <c>TGeminiAPIRoute</c> and is designed to be used by derived classes that
  /// perform specific API requests.
  /// </remarks>
  TGeminiAPIRequestParams = class(TGeminiAPIModel)
  protected
    /// <summary>
    /// Builds the query string parameters for pagination when fetching models.
    /// </summary>
    /// <param name="PageSize">
    /// The number of models to retrieve per page.
    /// </param>
    /// <param name="PageToken">
    /// An optional token used for fetching the next page of results.
    /// </param>
    /// <returns>
    /// A string containing the formatted query parameters, including the page size and optional page token.
    /// </returns>
    /// <remarks>
    /// The <c>ParamsBuilder</c> method constructs the query string for paginated model requests.
    /// The page size is mandatory, and the page token is optional but will be included in the query if provided.
    /// </remarks>
    function ParamsBuilder(const PageSize: Integer; const PageToken: string = ''): string; overload;
    function ParamsBuilder(const PageSize: Integer; const PageToken, Filter: string): string; overload;
  end;

  TGeminiAPIFileName = class(TGeminiAPIRequestParams)
  protected
    function CheckFileName(const Value: string): string;
  end;

  /// <summary>
  /// The <c>TGeminiAPIRoute</c> class represents a specific API route within
  /// the Gemini framework, encapsulating the necessary API client and route-specific
  /// configurations.
  /// </summary>
  /// <remarks>
  /// Inheriting from <c>TGeminiAPIModel</c>, this class leverages model management
  /// capabilities to handle route-specific operations. It manages an instance of
  /// <c>TGeminiAPI</c>, allowing for the execution of API requests tailored to
  /// the defined route.
  /// </remarks>
  TGeminiAPIRoute = class(TGeminiAPIFileName)
  private
    /// <summary>
    /// The instance of <c>TGeminiAPI</c> used to perform API requests for this route.
    /// </summary>
    /// <remarks>
    /// This field holds the reference to the API client, enabling the route to
    /// execute HTTP requests with the appropriate configurations and headers.
    /// </remarks>
    FAPI: TGeminiAPI;
    /// <summary>
    /// Sets the <c>FAPI</c> field to a new <c>TGeminiAPI</c> instance.
    /// </summary>
    /// <param name="Value">
    /// The new <c>TGeminiAPI</c> instance to be associated with this route.
    /// </param>
    /// <remarks>
    /// This method allows for updating the API client used by the route, providing
    /// flexibility in managing different API configurations or tokens.
    /// </remarks>
    procedure SetAPI(const Value: TGeminiAPI);
  public
    /// <summary>
    /// Gets or sets the <c>TGeminiAPI</c> instance associated with this route.
    /// </summary>
    /// <remarks>
    /// This property provides access to the API client, enabling the execution
    /// of API calls specific to the route's configuration.
    /// </remarks>
    property API: TGeminiAPI read FAPI write SetAPI;
    /// <summary>
    /// Creates a new instance of <c>TGeminiAPIRoute</c> associated with the specified API client.
    /// </summary>
    /// <param name="AAPI">
    /// The <c>TGeminiAPI</c> instance to be used by this route for API requests.
    /// </param>
    /// <remarks>
    /// The constructor initializes the route with the provided API client, ensuring
    /// that all subsequent API calls made through this route utilize the correct
    /// configurations and authentication tokens.
    /// </remarks>
    constructor CreateRoute(AAPI: TGeminiAPI); reintroduce;
    /// <summary>
    /// Destroys the <c>TGeminiAPIRoute</c> instance, releasing any associated resources.
    /// </summary>
    /// <remarks>
    /// The destructor ensures that all resources tied to the route, including the
    /// API client reference, are properly released to prevent memory leaks.
    /// </remarks>
    destructor Destroy; override;
  end;

implementation

uses
  REST.Json;

const
  FieldsToString : TArray<string> = ['"args": {'];

constructor TGeminiAPI.Create;
begin
  inherited Create;
  FHTTPClient := THTTPClient.Create;
  FToken := EmptyStr;
  FBaseUrl := URL_BASE;
end;

constructor TGeminiAPI.Create(const AToken: string);
begin
  Create;
  Token := AToken;
end;

destructor TGeminiAPI.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TGeminiAPI.Post(const Path: string; Body: TJSONObject; Response: TStringStream; OnReceiveData: TReceiveDataCallback): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
begin
  CheckAPI;
  Headers := GetHeaders;
  Stream := TStringStream.Create;
  FHTTPClient.ReceiveDataCallBack := OnReceiveData;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHTTPClient.Post(GetRequestURL(Path), Stream, Response, Headers).StatusCode;
  finally
    FHTTPClient.OnReceiveData := nil;
    Stream.Free;
  end;
end;

function TGeminiAPI.Get(const Path, Params: string; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
begin
  CheckAPI;
  Headers := GetHeaders;
  Result := FHTTPClient.Get(GetRequestURL(Path, Params), Response, Headers).StatusCode;
end;

function TGeminiAPI.Post(const Path: string; Body: TMultipartFormData; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
begin
  CheckAPI;
  Headers := GetHeaders;
  Result := FHTTPClient.Post(GetFilesURL(Path), Body, Response, Headers).StatusCode;
end;

function TGeminiAPI.Post(const Path: string; Body: TJSONObject;
  var ResponseHeader: TNetHeaders): Integer;
begin
  CheckAPI;
  var Headers := GetHeaders;
  var Stream: TStringStream := nil;
  try
    if Assigned(Body) then
      begin
        Stream := TStringStream.Create;
        Stream.WriteString(Body.ToJSON);
        Stream.Position := 0;
      end;
    var response := FHTTPClient.Post(GetRequestFilesURL(Path), Stream, nil, Headers);
    Result := Response.StatusCode;
    case Result of
       200..299:
         ResponseHeader := Response.Headers;
       else
         raise Exception.Create('Error on response headers');
    end;
  finally
    FHTTPClient.OnReceiveData := nil;
    Stream.Free;
  end;
end;

function TGeminiAPI.Find<TParams>(const Path: string;
  KeyName: string; ParamProc: TProc<TParams>): string;
var
  ResponseHeader: TNetHeaders;
begin
  var Params: TParams := nil;
  try
    if Assigned(ParamProc) then
      begin
        Params := TParams.Create;
        ParamProc(Params);
        Post(Path, Params.JSON, ResponseHeader);
      end
    else
      Post(Path, nil, ResponseHeader);
    for var Item in ResponseHeader do
      begin
        if Item.Name.ToLower = KeyName then
          begin
            Result := Item.Value;
            Break;
          end;
      end;
  finally
    Params.Free;
  end;
end;

function TGeminiAPI.Post(const Path: string; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
begin
  CheckAPI;
  Headers := GetHeaders;
  Stream := nil;
  try
    Result := FHTTPClient.Post(GetRequestURL(Path), Stream, Response, Headers).StatusCode;
  finally
  end;
end;

function TGeminiAPI.Post<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params.JSON, Response);
    Result := ParseResponse<TResult>(Code, ToStringValueFor(Response.DataString));
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TGeminiAPI.Post<TResult>(const Path: string;
  ParamJSON: TJSONObject): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Post(Path, ParamJSON, Response);
    Result := ParseResponse<TResult>(Code, ToStringValueFor(Response.DataString));
  finally
    Response.Free;
  end;
end;

function TGeminiAPI.Post<TParams>(const Path: string; ParamProc: TProc<TParams>;
  Response: TStringStream; Event: TReceiveDataCallback): Boolean;
var
  Params: TParams;
  Code: Integer;
begin
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params.JSON, Response, Event);
    case Code of
      200..299:
        Result := True;
    else
      begin
        Result := False;
        var Recieved := TStringStream.Create;
        try
          Response.Position := 0;
          Recieved.LoadFromStream(Response);
          ParseError(Code, Recieved.DataString);
        finally
          Recieved.Free;
        end;
      end;
    end;
  finally
    Params.Free;
  end;
end;

function TGeminiAPI.Post<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Post(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TGeminiAPI.Delete(const Path: string; Response: TStringStream): Integer;
var
  Headers: TNetHeaders;
begin
  CheckAPI;
  Headers := GetHeaders;
  Result := FHTTPClient.Delete(GetRequestURL(Path), Response, Headers).StatusCode;
end;

function TGeminiAPI.Delete<TResult>(const Path: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Delete(Path, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

function TGeminiAPI.PostForm<TResult, TParams>(const Path: string; ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Post(Path, Params, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Params.Free;
    Response.Free;
  end;
end;

procedure TGeminiAPI.RaiseError(Code: Int64; Error: TErrorCore);
begin
  case Code of
    400:
      raise GeminiExceptionInvalidRequestError.Create(Code, Error);
    401:
      raise GeminiExceptionAuthenticationError.Create(Code, Error);
    403:
      raise GeminiExceptionPermissionError.Create(Code, Error);
    404:
      raise GeminiExceptionNotFoundError.Create(Code, Error);
    413:
      raise GeminiExceptionRequestTooLarge.Create(Code, Error);
    429:
      raise GeminiExceptionRateLimitError.Create(Code, Error);
    500:
      raise GeminiExceptionAPIError.Create(Code, Error);
    529:
      raise GeminiExceptionOverloadedError.Create(Code, Error);
  else
    raise GeminiException.Create(Code, Error);
  end;
end;

function TGeminiAPI.Get(const Path: string; const Params: string): string;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Params, Response);
    case Code of
      200..299: ; //Success
    end;
    Result := Response.DataString;
  finally
    Response.Free;
  end;
end;

function TGeminiAPI.Get<TResult>(const Path: string; const Params: string): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Get(Path, Params, Response);
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    Response.Free;
  end;
end;

procedure TGeminiAPI.GetFile(const Path: string; Response: TStream);
var
  Headers: TNetHeaders;
  Code: Integer;
begin
  CheckAPI;
  Headers := GetHeaders;
  Code := FHTTPClient.Get(GetRequestURL(Path), Response, Headers).StatusCode;
  case Code of
    200..299:
      ; {success}
  else
    var Recieved := TStringStream.Create;
    try
      Response.Position := 0;
      Recieved.LoadFromStream(Response);
      ParseError(Code, Recieved.DataString);
    finally
      Recieved.Free;
    end;
  end;
end;

function TGeminiAPI.GetFilesURL(const Path: string): string;
begin
  Result := Format('%s/%s', [FBaseURL, Path]);
end;

function TGeminiAPI.GetHeaders: TNetHeaders;
begin
  Result := FCustomHeaders + [TNetHeader.Create('Content-Type', 'application/json')];
end;

function TGeminiAPI.GetPatchURL(const Path, Params: string): string;
begin
  Result := Format('%s/v1beta/%s?key=%s&&updateMask=%s', [FBaseURL, Path, Token, Params]);
end;

function TGeminiAPI.GetRequestURL(const Path, Params: string): string;
begin
  Result := Format('%s/v1beta/%s?key=%s%s', [FBaseURL, Path, Token, Params]);
end;

function TGeminiAPI.GetRequestFilesURL(const Path: string): string;
begin
  Result := Format('%s/%s?key=%s', [FBaseURL, Path, Token]);
end;

function TGeminiAPI.GetRequestURL(const Path: string): string;
begin
  Result := Format('%s/v1beta/%s?key=%s', [FBaseURL, Path, Token]);
end;

procedure TGeminiAPI.CheckAPI;
begin
  if FToken.IsEmpty then
    raise GeminiExceptionAPI.Create('Token is empty!');
  if FBaseUrl.IsEmpty then
    raise GeminiExceptionAPI.Create('Base url is empty!');
end;

procedure TGeminiAPI.ParseError(const Code: Int64; const ResponseText: string);
var
  Error: TErrorCore;
begin
  Error := nil;
  try
    try
      Error := TJson.JsonToObject<TError>(ResponseText);
    except
      Error := nil;
    end;
    if Assigned(Error) then
      RaiseError(Code, Error);
  finally
    if Assigned(Error) then
      Error.Free;
  end;
end;

function TGeminiAPI.ParseResponse<T>(const Code: Int64; const ResponseText: string): T;
begin
  Result := nil;
  case Code of
    200..299:
      try
        Result := TJson.JsonToObject<T>(ResponseText);
      except
        Result := nil;
      end;
    else
      ParseError(Code, ResponseText);
  end;
  if not Assigned(Result) then
    raise GeminiExceptionInvalidResponse.Create(Code, 'Empty or invalid response');
end;

function TGeminiAPI.Patch(const Path: string; Body: TJSONObject;
  Response: TStringStream; OnReceiveData: TReceiveDataCallback): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
begin
  CheckAPI;
  Headers := GetHeaders;
  Stream := TStringStream.Create;
  FHTTPClient.ReceiveDataCallBack := OnReceiveData;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHTTPClient.Patch(GetRequestURL(Path), Stream, Response, Headers).StatusCode;
  finally
    FHTTPClient.OnReceiveData := nil;
    Stream.Free;
  end;
end;

function TGeminiAPI.Patch(const Path, UriParams: string; Body: TJSONObject;
  Response: TStringStream; OnReceiveData: TReceiveDataCallback): Integer;
var
  Headers: TNetHeaders;
  Stream: TStringStream;
begin
  CheckAPI;
  Headers := GetHeaders;
  Stream := TStringStream.Create;
  FHTTPClient.ReceiveDataCallBack := OnReceiveData;
  try
    Stream.WriteString(Body.ToJSON);
    Stream.Position := 0;
    Result := FHTTPClient.Patch(GetPatchURL(Path, UriParams), Stream, Response, Headers).StatusCode;
  finally
    FHTTPClient.OnReceiveData := nil;
    Stream.Free;
  end;
end;

function TGeminiAPI.Patch<TResult, TParams>(const Path, UriParams: string;
  ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Patch(Path, UriParams, Params.JSON, Response);
    Result := ParseResponse<TResult>(Code, ToStringValueFor(Response.DataString));
  finally
    Params.Free;
    Response.Free;
  end;
end;

function TGeminiAPI.Patch<TResult>(const Path: string;
  ParamJSON: TJSONObject): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Patch(Path, ParamJSON, Response);
    Result := ParseResponse<TResult>(Code, ToStringValueFor(Response.DataString));
  finally
    Response.Free;
  end;
end;

function TGeminiAPI.Patch<TResult>(const Path, Params: string;
  ParamJSON: TJSONObject): TResult;
var
  Response: TStringStream;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := Patch(Path, Params, ParamJSON, Response);
    Result := ParseResponse<TResult>(Code, ToStringValueFor(Response.DataString));
  finally
    Response.Free;
  end;
end;

function TGeminiAPI.Patch<TResult, TParams>(const Path: string;
  ParamProc: TProc<TParams>): TResult;
var
  Response: TStringStream;
  Params: TParams;
  Code: Integer;
begin
  Response := TStringStream.Create('', TEncoding.UTF8);
  Params := TParams.Create;
  try
    if Assigned(ParamProc) then
      ParamProc(Params);
    Code := Patch(Path, Params.JSON, Response);
    Result := ParseResponse<TResult>(Code, ToStringValueFor(Response.DataString));
  finally
    Params.Free;
    Response.Free;
  end;
end;

procedure TGeminiAPI.SetBaseUrl(const Value: string);
begin
  FBaseUrl := Value;
end;

procedure TGeminiAPI.SetCustomHeaders(const Value: TNetHeaders);
begin
  FCustomHeaders := Value;
end;

procedure TGeminiAPI.SetOrganization(const Value: string);
begin
  FOrganization := Value;
end;

procedure TGeminiAPI.SetToken(const Value: string);
begin
  FToken := Value;
end;

function TGeminiAPI.ToStringValueFor(const Value: string): string;
begin
  Result := ToStringValueFor(Value, FieldsToString);
end;

function TGeminiAPI.ToStringValueFor(const Value, Field: string): string;
begin
  Result := Value;
  var i := Pos(Field, Result);
  while (i > 0) and (i < Result.Length) do
    begin
      i := i + Field.Length - 1;
      Result[i] := '"';
      Inc(i);
      var j := 0;
      while (j > 0) or ((j = 0) and not (Result[i] = '}')) do
        begin
          case Result[i] of
            '{':
              Inc(j);
            '}':
              j := j - 1;
            '"':
              Result[i] := '`';
          end;
          Inc(i);
          if i > Result.Length then
            raise Exception.Create('Invalid JSON string');
        end;
      Result[i] := '"';
      i := Pos(Field, Result);
    end;
end;

function TGeminiAPI.ToStringValueFor(const Value: string;
  const Field: TArray<string>): string;
begin
  Result := Value;
  if Length(Field) > 0 then
    begin
      for var Item in Field do
        Result := ToStringValueFor(Result, Item);
    end;
end;

function TGeminiAPI.UploadRaw<TResult>(const Path, FileName: string): TResult;
var
  Headers: TNetHeaders;
  Response: TStringStream;
  Code: integer;
begin
  CheckAPI;
  Headers := GetHeaders;
  var FileStream := TFileStream.Create(FileName, fmOpenRead);
  Response := TStringStream.Create('', TEncoding.UTF8);
  try
    Code := FHTTPClient.Post(Path, FileStream, Response, Headers).StatusCode;
    Result := ParseResponse<TResult>(Code, Response.DataString);
  finally
    FileStream.Free;
    Response.Free;
  end;
end;

{ GeminiException }

constructor GeminiException.Create(const ACode: Int64; const AError: TErrorCore);
begin
  Code := ACode;
  Msg := (AError as TError).Error.Message;
  Status := (AError as TError).Error.Status;

  inherited Create(Format('error (%d) %s: '+ sLineBreak + '     %s', [Code, Status, Msg]));
end;

constructor GeminiException.Create(const ACode: Int64; const Value: string);
begin
  Code := ACode;
  Msg := Value;
  inherited Create(Format('error %d: %s', [ACode, Msg]));
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


{ TGeminiAPIModel }

class constructor TGeminiAPIModel.Create;
begin
  GeminiLock := TCriticalSection.Create;
end;

class destructor TGeminiAPIModel.Destroy;
begin
  GeminiLock.Free;
end;

function TGeminiAPIModel.SetFile(const Path: string): string;
begin
  Result := Path;
end;

function TGeminiAPIModel.SetModel(const ModelName: string; const Supp: string): string;
begin
  if ModelName.Trim.IsEmpty then
    raise Exception.Create('Error: Unknown model name provided.');

  Result := ModelName.Trim;
  CurrentModel := Result;
  if not Supp.Trim.IsEmpty then
    Result := Result + Supp;
end;

{ TGeminiAPIRequestParams }

function TGeminiAPIRequestParams.ParamsBuilder(const PageSize: Integer;
  const PageToken: string): string;
begin
  Result := Format('&&pageSize=%d', [PageSize]);
  if not PageToken.IsEmpty then
    Result := Format('%s&&pageToken=%s', [Result, PageToken]);
end;

function TGeminiAPIRequestParams.ParamsBuilder(const PageSize: Integer;
  const PageToken, Filter: string): string;
begin
  Result := ParamsBuilder(PageSize, PageToken);
  if not Filter.IsEmpty then
    Result := Format('%s&&filter=%s', [Result, Filter]);
end;

{ TGeminiAPIFileName }

function TGeminiAPIFileName.CheckFileName(const Value: string): string;
begin
  Result := Value;
  if not Result.ToLower.StartsWith('files/') then
    Result := 'files/' + Result;
end;

end.

