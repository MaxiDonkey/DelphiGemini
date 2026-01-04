# SSE Streaming (generations)

- [Terminology](#terminology)
- [Synchronous streaming (direct consumption)](#1-synchronous-streaming-direct-consumption)
- [Asynchronous streaming with session callbacks](#2-asynchronous-streaming-with-session-callbacks)
- [Promises and orchestration](#3-promises-and-orchestration)
- [Quick selection guide](#quick-selection-guide)
- [Practical notes](#practical-notes)

___

<br>

This section presents several ways to consume an SSE stream returned by `Client.Chat` (the Generations API style), with an intentional progression:
1. **Synchronous SSE:** the most direct approach, ideal for understanding the stream and quick debugging.
2. **Asynchronous SSE with session callbacks:** incremental rendering + final aggregated result via a promise.
3. **Promises and orchestration:** composition with `&Then / &Catch` to chain operations.

<br>

>[!NOTE]
>(tutorial support units)
>
>The `Display...` / `DisplayStream...` helper methods used in the examples are provided by `Gemini.Tutorial.VCL` or `Gemini.Tutorial.FMX` (depending on the target platform) to keep examples simple and readable.
>They are not part of the core API—you can replace them with your own UI/logging routines.

<br>

## Terminology
- **Chunk:** a response fragment decoded from the SSE stream. In Generations mode, you typically receive successive `TChat` objects (same “type” in the handler) until the stream ends.
- `IsDone:` indicates the end of the stream.
- **Session callbacks:** "global" stream tracking callbacks (start / progress / cancel / cancellation / completion) exposed through a `TPromiseChatStream` context.
- **Key difference vs `Client.Interactions`:** on the Interactions endpoint, SSE returns typed events (multiple distinct event shapes). On the Generations endpoint, consumption is usually more “linear”: you process homogeneous chunks (e.g., `TChat`) as the stream progresses.

<br>

## 1) Synchronous streaming (direct consumption)
#### When to use it
- When you want the simplest possible SSE consumption (no promises).
- For quick debugging.
- When consuming the stream on the current thread is acceptable.

#### How it works
- `ParamProc` builds the generation request body (the model is not in the JSON; it’s provided via the method).
- `ChatEvent` is invoked for each decoded chunk.
- When `IsDone=True`, the stream is finished.
- Cancellation is cooperative via `var Cancel: Boolean`.

  ```pascal
      var ModelName := 'gemini-3-flash-preview';

      var Params: TProc<TChatParams> :=
        procedure (Params: TChatParams)
        begin
          Params
            .SystemInstruction('You need to take a purely mathematical approach')
            .Contents(
              TGeneration.Contents
                .AddParts(
                  TGeneration.Parts
                    .AddText('How does AI work?')
                )
            )
            .GenerationConfig(
              TGeneration.AddConfig
                .MaxOutputTokens(2048)
                .ThinkingConfig(
                  TGeneration.Config.AddThinkingConfig
                    .ThinkingLevel('low')
                )
            );

          // JSON payload for the body (the model is provided via CreateStream)
          TutorialHub.JSONRequest := Params.ToFormat();
        end;

      var ChatEvent: TChatEvent :=
        procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
        begin
          if (not IsDone) and Assigned(Chat) then
          begin
            DisplayStream(TutorialHub, Chat);

            // Example: cancel based on a condition
            // if ShouldCancel then Cancel := True;
          end;
        end;

      // Synchronous example
      Client.Chat.CreateStream(ModelName, Params, ChatEvent);
  ```

>[!IMPORTANT]
>The examples below rely on **TutorialHub**, a utility component used exclusively for tutorial and demonstration purposes.
>
>- `TutorialHub` is used to centralize display, logging, and SSE request/response visualization.
>- It is **not part of the core API** and is **not required** to use `Client.Chat`.
>- These examples are **reproduced verbatim and fully runnable** in the provided **demonstration application**.
>
>In your own application, you are free to replace `TutorialHub` and the `Display...` / `DisplayStream...` helper methods with your own UI, logging, or tracing mechanisms.

<br>

#### Key points
- You can render incrementally as chunks arrive.
- `Cancel := True` requests the stream to stop (cooperative).
- The model is provided via `CreateStream(ModelName, ...)` (not in the body).

## 2) Asynchronous streaming with session callbacks
#### When to use it
- UI apps (VCL/FMX): don’t block the main thread.
- When you want structured lifecycle hooks: `OnStart`, `OnProgress`, cancellation…
- While still getting a **final aggregated result** via a promise.

#### How it works
- `AsyncAwaitCreateStream(ModelName, Params, SessionCallbacks)` immediately returns a `TPromise<...>`.
- `OnProgress` receives `TChat` chunks as they arrive.
- The promise resolves at the end (final aggregated value). In this example, `&Then` receives a `string` (final aggregation).

   ```pascal
      // uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

      var ModelName := 'gemini-3-flash-preview';

      var Params: TProc<TChatParams> :=
        procedure (Params: TChatParams)
        begin
          Params
            .SystemInstruction('You need to take a purely mathematical approach')
            .Contents(
              TGeneration.Contents
                .AddParts(
                  TGeneration.Parts
                    .AddText('How does AI work?')
                )
            )
            .GenerationConfig(
              TGeneration.AddConfig
                .MaxOutputTokens(2048)
                .ThinkingConfig(
                  TGeneration.Config.AddThinkingConfig
                    .ThinkingLevel('low')
                )
            );

          TutorialHub.JSONRequest := Params.ToFormat();
        end;

      var SessionCallbacks: TFunc<TPromiseChatStream> :=
        function : TPromiseChatStream
        begin
          Result.Sender := TutorialHub;
          Result.OnStart := Start;

          Result.OnProgress :=
            procedure (Sender: TObject; Chunk: TChat)
            begin
              DisplayStream(Sender, Chunk);
            end;

          Result.OnDoCancel := DoCancellation;

          Result.OnCancellation :=
            function (Sender: TObject): string
            begin
              Cancellation(Sender);
            end;
        end;

      // Asynchronous promise example
      var Promise := Client.Chat.AsyncAwaitCreateStream(ModelName, Params, SessionCallbacks);

      Promise
        .&Then<string>(
          function (Value: string): string
          begin
            Result := Value;
            ShowMessage(Value);
          end)
        .&Catch(
          procedure (E: Exception)
          begin
            Display(TutorialHub, E.Message);
          end);
   ```
>[!IMPORTANT]
>The examples below rely on **TutorialHub**, a utility component used exclusively for tutorial and demonstration purposes.
>
>- `TutorialHub` is used to centralize display, logging, and SSE request/response visualization.
>- It is **not part of the core API** and is **not required** to use `Client.Chat`.
>- These examples are **reproduced verbatim and fully runnable** in the provided **demonstration application**.
>
>In your own application, you are free to replace `TutorialHub` and the `Display...` / `DisplayStream...` helper methods with your own UI, logging, or tracing mechanisms.

<br>

#### Key points
- `OnProgress` is for incremental rendering (UI/log).
- Cancellation is driven via `OnDoCancel` / `OnCancellation` (cooperative).
- The promise yields a final value (here, a `string`) once the stream completes.

<br>

## 3) Promises and orchestration
Because asynchronous streaming returns a promise, we can build a readable pipeline:
- `&Then`: post-processing once the stream resolves.
- `&Catch`: centralized error handling.
- **Returning a new promise from** `&Then`: chaining asynchronous operations.

<br>

- Example: chaining streaming and then a non-streamed generation (pattern)

   ```pascal
      var Promise := Client.Chat.AsyncAwaitCreateStream(ModelName, Params, SessionCallbacks);

      Promise
        .&Then<TPromise<string>>(
          function (FirstText: string): TPromise<string>
          begin
            Result := Client.Chat.AsyncAwaitCreateStream(
              ModelName,
              procedure (Params: TChatParams)
              begin
                Params
                  .SystemInstruction('You need to take a purely mathematical approach')
                  .Contents(
                    TGeneration.Contents
                      .AddText('Summarize the following answer:'#10 + FirstText)
                  )
                  .GenerationConfig(
                    TGeneration.AddConfig
                      .MaxOutputTokens(1024)
                  );
              end,
              SessionCallbacks
            );
          end)
        .&Then(
          procedure (SecondText: string)
          begin
            ShowMessage('----- SUMMARY');
            ShowMessage(SecondText);
          end)
        .&Catch(
          procedure (E: Exception)
          begin
            Display(TutorialHub, E.Message);
          end);
   ``` 

>[!NOTE]
> The snippet above illustrates the pattern “stream → post-process → second request”. 

>[!IMPORTANT]
>The examples below rely on **TutorialHub**, a utility component used exclusively for tutorial and demonstration purposes.
>
>- `TutorialHub` is used to centralize display, logging, and SSE request/response visualization.
>- It is **not part of the core API** and is **not required** to use `Client.Chat`.
>- These examples are **reproduced verbatim and fully runnable** in the provided **demonstration application**.
>
>In your own application, you are free to replace `TutorialHub` and the `Display...` / `DisplayStream...` helper methods with your own UI, logging, or tracing mechanisms.


<br>

## Quick selection guide
- Direct / quick debugging → (1) `CreateStream`
- UI-friendly + incremental rendering + final result → (2) `AsyncAwaitCreateStream` + `OnProgress`
- Chaining / orchestration → (3) Promises + `&Then`

<br>

## Practical notes
- In **Generations**, the model is provided via the method (`CreateStream(ModelName, ...)`), not in the JSON body.
- Don’t keep chunk objects beyond callbacks—copy required fields if you need to persist them.
- Cancellation is cooperative (you request a stop; the library/server ends the stream cleanly).
- Keep `OnProgress` lightweight (UI/log): avoid heavy, blocking work there.