unit Gemini.Operation;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  REST.JsonReflect, REST.Json.Types,
  Gemini.API.Params, Gemini.Types, Gemini.Types.EnumWire,
  Gemini.Async.Support, Gemini.Async.Promise;

type
  /// <summary>
  /// The Status class <c>TStatus</c> defines a logical error model that is suitable for different programming environments, including REST APIs and RPC APIs. It is used by gRPC. Each Status message contains three pieces of data: error code, error message, and error details.
  /// </summary>
  /// <remarks>
  /// You can find out more about this error model and how to work with it in the API Design Guide.
  /// <para>
  /// - https://google.aip.dev/193
  /// </para>
  /// </remarks>
  TStatus = class
  private
    FCode: Int64;
    FMessage: string;
  public
    /// <summary>
    /// The status code, which should be an enum value of google.rpc.Code.
    /// </summary>
    /// <remarks>
    /// https://github.com/grpc
    /// </remarks>
    property Code: Int64 read FCode write FCode;

    /// <summary>
    /// A developer-facing error message, which should be in English.
    /// </summary>
    /// <remarks>
    /// Any user-facing error message should be localized and sent in the google.rpc.Status.details field, or localized by the client.
    /// </remarks>
    property Message: string read FMessage write FMessage;
  end;

  TOperation = class(TJSONFingerprint)
  strict private
    function JsonStrOf(const FieldName: TBatchOperationType): string; inline;
  private
    FName: string;
    FDone: Boolean;
    FError: TStatus;
    function GetResponseFile: string;
    function GetState: TBatchStateType;
    function GetModel: string;
    function GetDisplayName: string;
    function GetFileName: string;
    function GetCreateTime: string;
    function GetEndTime: string;
    function GetUpdateTime: string;
    function GetRequestCount: string;
    function GetPendingRequestCount: string;
    function GetSuccessfulRequestCount: string;
    function GetFailedRequestCount: string;
    function GetType: string;
  public
    /// <summary>
    /// The server-assigned name, which is only unique within the same service that originally returns it.
    /// </summary>
    /// <remarks>
    /// If you use the default HTTP mapping, the name should be a resource name ending with operations/{unique_id}.
    /// </remarks>
    property Name: string read FName write FName;

    /// <summary>
    /// If the value is false, it means the operation is still in progress.
    /// </summary>
    /// <remarks>
    /// If true, the operation is completed, and either error or response is available.
    /// </remarks>
    property Done: Boolean read FDone write FDone;

    /// <summary>
    /// The error result of the operation in case of failure or cancellation.
    /// </summary>
    property Error: TStatus read FError write FError;

    /// <summary>
    /// contains a URI identifying the type.
    /// </summary>
    /// <remarks>
    /// Example: { "id": 1234, "@type": "types.example.com/standard/id" }.
    /// </remarks>
    property &Type: string read GetType;

    /// <summary>
    /// Required. The name of the Model to use for generating the completion.
    /// </summary>
    /// <remarks>
    /// Format: models/{model}.
    /// </remarks>
    property Model: string read GetModel;

    /// <summary>
    /// Required. The user-defined name of this batch.
    /// </summary>
    property DisplayName: string read GetDisplayName;

    /// <summary>
    /// The name of the File containing the input requests.
    /// </summary>
    property FileName: string read GetFileName;

    /// <summary>
    /// Output only. The time at which the batch was created.
    /// </summary>
    property CreateTime: string read GetcreateTime;

    /// <summary>
    /// Output only. The time at which the batch processing completed.
    /// </summary>
    property EndTime: string read GetEndTime;

    /// <summary>
    /// Output only. The time at which the batch was last updated.
    /// </summary>
    property UpdateTime: string read GetUpdateTime;

    /// <summary>
    /// Output only. The number of requests in the batch.
    /// </summary>
    property RequestCount: string read GetRequestCount;

    /// <summary>
    /// Output only. The number of requests that were successfully processed.
    /// </summary>
    property SuccessfulRequestCount: string read GetSuccessfulRequestCount;

    /// <summary>
    /// Output only. The number of requests that failed to be processed.
    /// </summary>
    property FailedRequestCount: string read GetFailedRequestCount;

    /// <summary>
    /// Output only. The number of requests that are still pending processing.
    /// </summary>
    property PendingRequestCount: string read GetPendingRequestCount;

    /// <summary>
    /// Output only. The file ID of the file containing the responses. The file will be a JSONL file with
    /// a single response per line. The responses will be GenerateContentResponse messages formatted as JSON.
    ///The responses will be written in the same order as the input requests.
    /// </summary>
    property ResponseFile: string read GetResponseFile;

    /// <summary>
    /// Output only. The state of the batch.
    /// </summary>
    property State: TBatchStateType read GetState;

    destructor Destroy; override;
  end;

  TOperationList = class(TJSONFingerprint)
  private
    FOperations: TArray<TOperation>;
    FNextPageToken: string;
  public
    property Operations: TArray<TOperation> read FOperations write FOperations;

    property NextPageToken: string read FNextPageToken write FNextPageToken;

    destructor Destroy; override;
  end;

  /// <summary>
  /// Asynchronous callback container for operations that return a <c>TOperation</c>.
  /// </summary>
  /// <remarks>
  /// <c>TAsynOperation</c> is an alias of <c>TAsynCallBack&lt;TOperation&gt;</c> and is used to configure
  /// the lifecycle callbacks for long-running operations (LRO) returned by File Search Store endpoints
  /// (for example, <c>Import</c>, <c>UploadToFileSearchStore</c>, or <c>OperationsGet</c>).
  /// <para>
  /// • Common handlers are <c>OnStart</c> (invoked when the asynchronous work begins), <c>OnSuccess</c>
  /// (invoked with the resulting <c>TOperation</c>), and <c>OnError</c> (invoked with an error message
  /// if the call fails).
  /// </para>
  /// <para>
  /// • The returned <c>TOperation</c> may indicate completion via <c>Done</c>, and can include either an
  /// error (<c>Error</c>) or a successful payload (<c>Response</c>) depending on the endpoint semantics.
  /// </para>
  /// </remarks>
  TAsynOperation = TAsynCallBack<TOperation>;

  /// <summary>
  /// Promise-style callback container for operations that return a <c>TOperation</c>.
  /// </summary>
  /// <remarks>
  /// <c>TPromiseOperation</c> is an alias of <c>TPromiseCallback&lt;TOperation&gt;</c> and is intended for
  /// promise-based APIs that expose long-running operations (LRO), such as File Search Store upload,
  /// import, or operation polling endpoints.
  /// <para>
  /// • It allows callers to register lifecycle callbacks that are invoked while the promise is pending
  /// and when it settles, either resolved with a <c>TOperation</c> or rejected with an error.
  /// </para>
  /// <para>
  /// • The resolved <c>TOperation</c> instance can be inspected to determine whether the operation has
  /// completed (<c>Done</c>) and whether it resulted in an error (<c>Error</c>) or a successful
  /// response payload (<c>Response</c>), depending on the originating API method.
  /// </para>
  /// <para>
  /// • This type only defines the callback bundle and does not execute any asynchronous work by itself.
  /// </para>
  /// </remarks>
  TPromiseOperation = TPromiseCallback<TOperation>;

  /// <summary>
  /// Asynchronous callback container for endpoints that return an <c>TOperationList</c>.
  /// </summary>
  /// <remarks>
  /// <c>TAsynOperationList</c> is an alias of <c>TAsynCallBack&lt;TOperationList&gt;</c> and is used to configure
  /// lifecycle callbacks for asynchronous requests that list long-running operations (LRO), typically via
  /// the Operations/List endpoint.
  /// <para>
  /// • Common handlers include <c>OnStart</c> (invoked when the asynchronous work begins), <c>OnSuccess</c>
  /// (invoked with the resulting <c>TOperationList</c>), and <c>OnError</c> (invoked with an error message
  /// if the call fails).
  /// </para>
  /// <para>
  /// • The resulting <c>TOperationList</c> exposes <c>Operations</c> (the current page of <c>TOperation</c> items)
  /// and <c>NextPageToken</c> for pagination.
  /// </para>
  /// <para>
  /// • This type only defines the callback bundle and does not execute any asynchronous work by itself.
  /// </para>
  /// </remarks>
  TAsynOperationList = TAsynCallBack<TOperationList>;

  /// <summary>
  /// Promise-style callback container for endpoints that return an <c>TOperationList</c>.
  /// </summary>
  /// <remarks>
  /// <c>TPromiseOperationList</c> is an alias of <c>TPromiseCallback&lt;TOperationList&gt;</c> and is intended for
  /// promise-based APIs that list long-running operations (LRO), typically via the Operations/List endpoint.
  /// <para>
  /// • It allows callers to register lifecycle callbacks that are invoked while the promise is pending
  /// and when it settles, either resolved with a <c>TOperationList</c> or rejected with an error.
  /// </para>
  /// <para>
  /// • The resolved <c>TOperationList</c> instance can be inspected to access <c>Operations</c> (the current page of
  /// <c>TOperation</c> items) and <c>NextPageToken</c> for pagination.
  /// </para>
  /// <para>
  /// • This type only defines the callback bundle and does not execute any asynchronous work by itself.
  /// </para>
  /// </remarks>
  TPromiseOperationList = TPromiseCallback<TOperationList>;

implementation

uses
  Gemini.JsonPathHelper;

{ TOperation }

destructor TOperation.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

function TOperation.GetCreateTime: string;
begin
  Result := JsonStrOf(bo_createTime);
end;

function TOperation.GetDisplayName: string;
begin
  Result := JsonStrOf(bo_displayName);
end;

function TOperation.GetEndTime: string;
begin
  Result := JsonStrOf(bo_endTime);
end;

function TOperation.GetFailedRequestCount: string;
begin
  Result := JsonStrOf(bo_failedRequestCount);
end;

function TOperation.GetFileName: string;
begin
  Result := JsonStrOf(bo_inputFileName);
end;

function TOperation.GetModel: string;
begin
  Result := JsonStrOf(bo_model);
end;

function TOperation.GetPendingRequestCount: string;
begin
  Result := JsonStrOf(bo_pendingRequestCount);
end;

function TOperation.GetRequestCount: string;
begin
  Result := JsonStrOf(bo_requestCount);
end;

function TOperation.GetResponseFile: string;
begin
  Result := JsonStrOf(bo_responsesFile);
end;

function TOperation.GetState: TBatchStateType;
begin
  var S := JsonStrOf(bo_state);
  try
    Result := TBatchStateType.Parse(S);
  except
    Result := TBatchStateType(0);
  end;
end;

function TOperation.GetSuccessfulRequestCount: string;
begin
  Result := JsonStrOf(bo_successfulRequestCount);
end;

function TOperation.GetType: string;
begin
  Result := JsonStrOf(bo_type);
end;

function TOperation.GetUpdateTime: string;
begin
  Result := JsonStrOf(bo_updateTime);
end;

function TOperation.JsonStrOf(const FieldName: TBatchOperationType): string;
begin
  Result := TJsonReader
    .Parse(JSONResponse)
    .AsString(FieldName.ToString);
end;

{ TOperationList }

destructor TOperationList.Destroy;
begin
  for var Item in FOperations do
    Item.Free;
  inherited;
end;

end.
