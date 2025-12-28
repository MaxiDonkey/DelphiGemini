unit Gemini.Interactions.Stream;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  REST.JsonReflect, REST.Json.Types,
  Gemini.API.Params, Gemini.Types, Gemini.Interactions.ResponsesContent,
  Gemini.Async.Support, Gemini.Async.Promise, Gemini.Interactions.Responses;

type
  TStreamContent = class(TIxImageContent);

  TIxCustomDeltaContent = class(TIxContent);

  {$REGION 'ThoughtContent add-on for delta events'}

  TIxThoughtSummaryDelta = class(TIxCustomDeltaContent)
  private
    FContent: TStreamContent;
  public
    property Content: TStreamContent read FContent write FContent;

    destructor Destroy; override;
  end;

  TIxThoughtSignatureDelta = class(TIxThoughtSummaryDelta)
  end;

  {$ENDREGION}

  TInteractionDelta = class(TIxThoughtSignatureDelta);

  TCommonInteractionSseEvent = class(TJSONFingerprint)
  private
    [JsonNameAttribute('event_type')]
    [JsonReflectAttribute(ctString, rtString, TEventTypeInterceptor)]
    FEventType: TEventType;
  public
    property EventType: TEventType read FEventType write FEventType;
  end;

  {$REGION 'InteractionEvent'}

  TIxInteractionEvent = class(TCommonInteractionSseEvent)
  private
    FInteraction: TInteraction;
    [JsonNameAttribute('event_id')]
    FEventId: string;
  public
    property Interaction: TInteraction read FInteraction write FInteraction;

    /// <summary>
    /// The event_id token to be used to resume the interaction stream, from this event.
    /// </summary>
    property EventId: string read FEventId write FEventId;

    destructor Destroy; override;
  end;

  {$ENDREGION}

  {$REGION 'InteractionStatusUpdate'}

  TIxInteractionStatusUpdate = class(TIxInteractionEvent)
  private
    [JsonNameAttribute('interaction_id')]
    FInteractionId: string;
    [JsonReflectAttribute(ctString, rtString, TInteractionStatusTypeInterceptor)]
    FStatus: TInteractionStatusType;
  public
    property InteractionId: string read FInteractionId write FInteractionId;

    property Status: TInteractionStatusType read FStatus write FStatus;
  end;

  {$ENDREGION}

  {$REGION 'ContentStart'}

  TIxContentStart = class(TIxInteractionStatusUpdate)
  private
    FIndex: Int64;
    FContent: TIxContent;
  public
    property Index: Int64 read FIndex write FIndex;

    property Content: TIxContent read FContent write FContent;

    destructor Destroy; override;
  end;

  {$ENDREGION}

  {$REGION 'ContentDelta'}

  TIxContentDelta = class(TIxContentStart)
  private
    FDelta: TInteractionDelta;
  public
    property Delta: TInteractionDelta read FDelta write FDelta;

    destructor Destroy; override;
  end;

  {$ENDREGION}

  {$REGION 'ContentStop'}

  TIxContentStop = class(TIxContentDelta)
  end;

  {$ENDREGION}

  {$REGION 'ErrorEvent'}

  TIxError = class
  private
    FCode: string;
    FMessage: string;
  public
    /// <summary>
    /// A URI that identifies the error type.
    /// </summary>
    property Code: string read FCode write FCode;

    /// <summary>
    /// A human-readable error message.
    /// </summary>
    property Message: string read FMessage write FMessage;
  end;

  TIxErrorEvent = class(TIxContentStop)
  private
    FError: TIxError;
  public
    property Error: TIxError read FError write FError;

    destructor Destroy; override;
  end;

  {$ENDREGION}

  /// <summary>
  /// Streamed Server-Sent Event (SSE) container for interaction operations.
  /// </summary>
  /// <remarks>
  /// <c>TInteractionStream</c> is a concrete event payload type used by the interaction streaming API.
  /// It inherits from <c>TIxErrorEvent</c> and therefore includes the common event envelope fields
  /// (such as <c>EventType</c>, <c>EventId</c>, and the associated <c>Interaction</c>) as well as
  /// optional error details (<c>Error</c>) when a failure occurs.
  /// <para>
  /// • Each streamed message represents a snapshot of an SSE event emitted by the server while an
  /// interaction is running (e.g., status updates and content lifecycle events).
  /// </para>
  /// <para>
  /// • Depending on <c>EventType</c>, the payload may provide:
  /// <c>Status</c> and <c>InteractionId</c> (status updates), <c>Index</c> and <c>Content</c>
  /// (content start), <c>Delta</c> (incremental content), or a terminal event (content stop).
  /// </para>
  /// <para>
  /// • When an error is emitted, <c>Error</c> is populated with a machine-readable <c>Code</c> and a
  /// human-readable <c>Message</c>. Consumers should treat error events as terminal for the stream.
  /// </para>
  /// <para>
  /// • This type is a data container only; it does not perform any streaming I/O by itself.
  /// It is typically delivered to user code through <c>TAsynInteractionStream</c> or
  /// <c>TPromiseInteractionStream</c> callbacks.
  /// </para>
  /// </remarks>
  TInteractionStream = class(TIxErrorEvent);

  /// <summary>
  /// Asynchronous callback container for interaction streaming operations.
  /// </summary>
  /// <remarks>
  /// <c>TAsynInteractionStream</c> is an alias of <c>TAsynStreamCallBack&lt;TInteractionStream&gt;</c> and is used to
  /// configure lifecycle callbacks for asynchronous calls that consume an interaction SSE stream.
  /// <para>
  /// • Typical handlers include <c>OnStart</c> (invoked when the stream subscription begins),
  /// <c>OnProgress</c> (invoked for each incoming <c>TInteractionStream</c> event), <c>OnSuccess</c>
  /// (invoked when the stream completes normally), and <c>OnError</c> (invoked with an error message
  /// if the streaming call fails).
  /// </para>
  /// <para>
  /// • The <c>TInteractionStream</c> payload represents a streamed Server-Sent Event (SSE) emitted while
  /// an interaction is running, including content start/delta/stop events, status updates, and optional
  /// error details (<c>Error</c>) for terminal failures.
  /// </para>
  /// <para>
  /// • This type only defines the callback bundle and does not execute any asynchronous work by itself.
  /// </para>
  /// </remarks>
  TAsynInteractionStream = TAsynStreamCallBack<TInteractionStream>;

  /// <summary>
  /// Promise-style callback container for interaction streaming operations.
  /// </summary>
  /// <remarks>
  /// <c>TPromiseInteractionStream</c> is an alias of <c>TPromiseStreamCallback&lt;TInteractionStream&gt;</c> and is intended
  /// for promise-based APIs that consume an interaction SSE stream.
  /// <para>
  /// • It allows callers to register lifecycle callbacks that are invoked while the promise is pending
  /// and as streaming events arrive, then when it settles, either resolved on normal completion or
  /// rejected on failure.
  /// </para>
  /// <para>
  /// • Typical handlers include <c>OnStart</c> (invoked when the stream subscription begins),
  /// <c>OnProgress</c> (invoked for each incoming <c>TInteractionStream</c> event), <c>OnSuccess</c>
  /// (invoked when the stream completes normally), and <c>OnError</c> (invoked with an error message
  /// if the streaming call fails).
  /// </para>
  /// <para>
  /// • Each <c>TInteractionStream</c> instance represents a streamed Server-Sent Event (SSE) emitted while
  /// an interaction is running, including status updates, content start/delta/stop events, and optional
  /// error details (<c>Error</c>) for terminal failures.
  /// </para>
  /// <para>
  /// • This type only defines the callback bundle and does not execute any streaming I/O by itself.
  /// </para>
  /// </remarks>
  TPromiseInteractionStream = TPromiseStreamCallback<TInteractionStream>;

implementation

{ TIxThoughtSummaryDelta }

destructor TIxThoughtSummaryDelta.Destroy;
begin
  if Assigned(FContent) then
    FContent.Free;
  inherited;
end;

{ TIxContentStart }

destructor TIxContentStart.Destroy;
begin
  if Assigned(FContent) then
    FContent.Free;
  inherited;
end;

{ TIxInteractionEvent }

destructor TIxInteractionEvent.Destroy;
begin
  if Assigned(FInteraction) then
    FInteraction.Free;
  inherited;
end;

{ TIxContentDelta }

destructor TIxContentDelta.Destroy;
begin
  if Assigned(FDelta) then
    FDelta.Free;
  inherited;
end;

{ TIxErrorEvent }

destructor TIxErrorEvent.Destroy;
begin
  if Assigned(FError) then
    FError.Free;
  inherited;
end;

end.
