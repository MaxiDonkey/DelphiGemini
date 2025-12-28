# SSE Streaming (interactions)

- [Terminology](#terminology)
- [Synchronous streaming (direct stream consumption)](#1-synchronous-streaming-direct-stream-consumption)
- [“Mute” asynchronous streaming (aggregation only)](#2-mute-asynchronous-streaming-aggregation-only)
- [Asynchronous streaming with session callbacks](#3-asynchronous-streaming-with-session-callbacks)
- [Asynchronous streaming with event callbacks](#4-asynchronous-streaming-with-event-callbacks)
- [Promises and orchestration: chaining asynchronous operations](#5-promises-and-orchestration-chaining-asynchronous-operations)
- [Quick selection guide](#quick-selection-guide)
- [Practical notes](#practical-notes)

___

This section presents several ways to consume an SSE stream returned by `Client.Interactions`, with an intentional progression:
1. **Synchronous SSE:** the most direct approach, ideal to get to the point.
2. **“Mute” asynchronous SSE:** asynchronous, with no real-time tracking (final aggregated result only). 
3. **Asynchronous SSE with session callbacks:** simple tracking (`start/progress/cancel`).
4. **Asynchronous SSE with event callbacks:** fine-grained, event-by-event interception.
5. **Promises and orchestration:** composition with &Then / &Catch to chain asynchronous operations.

<br>

>[!NOTE] 
>**(tutorial support units)**
>
>The `Display...` / `DisplayStream...` helper methods used in the examples are provided by `Gemini.Tutorial.VCL` or `Gemini.Tutorial.FMX` (depending on the target platform) to keep examples simple and readable.
>They are not part of the core API—you can replace them with your own UI/logging routines.

<br>

## Terminology

- **Session callbacks** *(formerly “sequence callbacks”)*
  “Global” stream tracking: start, progress (chunks), cancellation, completion.
<br>

- **Event callbacks** *(formerly “event callbacks”)*
  Fine-grained interception by SSE event type: `interaction_start`, `content_delta`, `content_stop`, etc. 

<br>


## 1) Synchronous streaming (direct stream consumption)  

### When to use it
When you want a straightforward, immediate consumption of the SSE stream—no promise and no Then/Catch composition.

### How it works
- `ParamProc` builds the request (model, input, options, streaming).
- `Event` is called for each decoded SSE chunk.
- When `IsDone=True`, the stream is finished. 

  ```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model('gemini-3-flash-preview')
        .Input('From which version of Delphi were multi-line strings introduced?' )
        .Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  var InteractionEvent: TInteractionEvent :=
    procedure (var Event: TInteractionStream; IsDone: Boolean; var Cancel: Boolean)
    begin
      if (not IsDone) and Assigned(Event) then
        begin
          DisplayStream(TutorialHub, Event);
        end;
    end;

  //Synchronous example
  Client.Interactions.CreateStream(Params, InteractionEvent);
  ```

<br>


## 2) “Mute” asynchronous streaming (aggregation only)

Compared to the synchronous mode, this variant frees the calling thread (promise-based) but provides no real-time tracking: you only get the final aggregated result.

Important: this example is asynchronous (promise).
- “Mute” means no live callbacks, not “synchronous”.

  ```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model('gemini-3-flash-preview')
        .Input('From which version of Delphi were multi-line strings introduced?' )
        .GenerationConfig(
          TGenerationConfigIxParams.Create
            .ThinkingSummaries('auto')) // Include "thought"
        .Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  // Asynchronous promise example (mute: no live callbacks)
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Id);
        ShowMessage(Value.Thought);
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
  ``` 

Consequence
- No `OnProgress`: no incremental UI updates.
- The stream is consumed/aggregated internally → `TEventData` is available at completion.

<br>


## 3) Asynchronous streaming with session callbacks

Compared to the “mute” mode, this variant adds progressive tracking through session callbacks (`OnStart`, `OnProgress`, cancellation...), while still returning a promise for the final aggregated result.

**Recommended split**
- Session context (`TPromiseInteractionStream`): tracking logic.
- Parameters (`TProc<TInteractionParams>`): JSON request construction.

  ```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Params: TProc<TInteractionParams> :=
      procedure (Params: TInteractionParams)
      begin
        Params
          .Model('gemini-3-flash-preview')
          .Input('From which version of Delphi were multi-line strings introduced?' )
          .GenerationConfig(
            TGenerationConfigIxParams.Create
              .ThinkingSummaries('auto') //Include "thougth"
             )
          .Stream;
        TutorialHub.JSONRequest := Params.ToFormat();
      end;

  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
      function : TPromiseInteractionStream
      begin
        Result.Sender := TutorialHub;
        Result.OnStart := Start;
        Result.OnProgress := DisplayStream;
        Result.OnDoCancel := DoCancellation;
        Result.OnCancellation := DoCancellationStream;
      end;

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Id);
        ShowMessage(Value.Thought);
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
  ```

>[!WARNING] 
>**(Sender / TutorialHub dependency)**
>
> In these examples, `Result.Sender := TutorialHub;` is used because the tutorial relies on the `TTutorialHub` support class provided by `Gemini.Tutorial.VCL` or `Gemini.Tutorial.FMX`. This object is passed as the callback Sender so the helper procedures (such as `Display`... / `DisplayStream`...) can access the tutorial UI/log context.
>
> When integrating the library into your own project, you are not required to use `TTutorialHub`. You can set `Sender` to any object that makes sense for your application (for example, your main form, a view-model, a controller, or a custom context class), and implement your own display/log/cancellation handlers accordingly.
>
>You may also leave `Sender` as `nil`.

<br>


## 4) Asynchronous streaming with event callbacks

- Compared to session callbacks (which track the stream “as a whole”), this variant enables fine-grained interception per SSE event type (`content_start`, `content_delta`, `interaction_complete`, etc.), which is ideal for precise control (UI, logging, instrumentation).

  ```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('From which version of Delphi were multi-line strings introduced?' )
            .GenerationConfig(
              TGenerationConfigIxParams.Create
                .ThinkingSummaries('auto') //Include "thougth"
               )
            .Stream;
          TutorialHub.JSONRequest := Params.ToFormat();
        end;

  var EventCallbacks := TEventEngineManagerFactory.CreateInstance(
        function : TStreamEventCallBack
        begin
          Result.Sender := TutorialHub;
          Result.OnInteractionStart := DisplayInteractionStart;
          Result.OnInteractionStatusUpdate := DisplayInteractionStatusUpdate;
          Result.OnInteractionComplete := DisplayInteractionComplete;
          Result.OnContentStart := DisplayContentStart;
          Result.OnContentDelta := DisplayContentDelta;
          Result.OnContentStop := DisplayContentStop;
          Result.OnError := DisplayInteractionError;
          Result.OnCancellation := Cancellation;
          Result.OnDoCancel := DoCancellation;
        end);

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, EventCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Id);
        ShowMessage(Value.Thought);
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
  ```

<br>


## 5) Promises and orchestration: chaining asynchronous operations

The `AsyncAwait`... variants return a `TPromise<TEventData>`. Beyond streaming, this enables a readable processing pipeline:
- **`&Then`:** post-processing after resolution.
- **`&Catch`:** centralized error handling.
- Returning a new promise from a `&Then`: chaining asynchronous operations (pipeline).

<br>

- Example: chaining two asynchronous operations

  ```pascal
  var Promesse1 := Client.Interactions.AsyncAwaitCreateStream(Params1, SessionContext);

  Promesse1
    .&Then<TPromise<TEventData>>(
      function (First: TEventData): TPromise<TEventData>
      begin
        var Params2: TProc<TInteractionParams> :=
          procedure (Params: TInteractionParams)
          begin
            Params
             .Model('gemini-3-flash-preview')
             .Input('Summarize the following answer in 3 points:' + First.Text)
             .Stream;
          end;

        Result := Client.Interactions.AsyncAwaitCreateStream(Params2);
      end)
    .&Then<TEventData>(
      procedure (Second: TEventData)
      begin
        ShowMessage('Summary : ' + Second.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end); 
  ``` 

<br>

## Quick selection guide
- **Get to the point / quick debugging** → (1) Synchronous
- **Final result only** → (2) Async “mute”
- **Simple incremental rendering** → (3) Session callbacks
- **Fine-grained SSE event handling** → (4) Event callbacks
- **Chaining / orchestration** → (5) Promises + `&Then`

<br>

## Practical notes
- Make sure to call `.Stream` in your parameters (otherwise you are not using SSE).
- Do not keep chunk objects beyond callbacks—copy required fields.
- Cancellation is cooperative:
  - driven via `OnDoCancel / OnCancellation`, and/or
  - relayed by the dispatcher through `IEventEngineManager`.
