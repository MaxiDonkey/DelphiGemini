# Text generation (non-streamed interactions)

- [Overview](#overview)
- [Synchronous text generation](#1-synchronous-text-generation)
- [Asynchronous text generation (promise-based)](#2-asynchronous-text-generation-promise-based)
- [Promises and orchestration](#3-promises-and-orchestration)
- [Quick selection guide](#quick-selection-guide)
- [Practical notes](#practical-notes)
___

<br>

## Overview

The `Client.Interactions.Create` and `Client.Interactions.AsyncAwaitCreate` methods request a Gemini model to generate a single, non-streamed response.

Unlike SSE streaming:
- the model produces its full output in one response,
- no intermediate chunks or events are emitted,
- the resulting `TInteraction` object contains the complete generated content.

<br>

Two usage styles are available:
- **Synchronous:** blocking call, immediate result.
- **Asynchronous (promise-based):** non-blocking, composable with &Then / &Catch.

<br>

>[!NOTE] 
>**Tutorial support units**
>
>The `Display(...)` helper procedures used in the examples are provided by `Gemini.Tutorial.VCL` or `Gemini.Tutorial.FMX`, depending on the target platform.
>
>These units exist solely to keep tutorial code concise and readable. They are not **part of the core API**.
>In a real application, you are expected to replace them with your own UI, logging, or domain-specific logic.

<br>


## 1) Synchronous text generation

### When to use it
Use the synchronous API when:
- you want the simplest possible usage,
- blocking the current thread is acceptable,
- you are running in a background thread or a console-style workflow.

### How it works
- `ParamProc` configures the interaction request.
- `Create` performs a blocking HTTP call.
- The returned `TInteraction` must be freed by the caller.
<br>

  ```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

  var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model('gemini-3-flash-preview')
        .Input('From which version of Delphi were multi-line strings introduced?' );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  // Synchronous example
  var Value := Client.Interactions.Create(Params);

  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;

  ```

### Key points
- The call blocks until the model response is fully received.
- Memory ownership is explicit: you must free `TInteraction`.
- Errors are raised as exceptions.

<br>


## 2) Asynchronous text generation (promise-based)

### Why use the asynchronous variant
The asynchronous API:
- avoids blocking the calling thread,
- integrates naturally with UI applications,
- enables clean composition through promises.

### How it works
- `AsyncAwaitCreate` immediately returns a `TPromise<TInteraction>`.
- The request runs in the background.
- `&Then` is invoked on success.
- `&Catch` centralizes error handling. 
<br>

  ```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('From which version of Delphi were multi-line strings introduced?' );
          TutorialHub.JSONRequest := Params.ToFormat();
        end;


  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitCreate(Params);

  Promise
    .&Then<string>(
      function (Value: TInteraction): string
      begin
        Result := Value.Id;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
  
  ```

### Key points
- The returned `TInteraction` is owned by the promise chain.
- You do not manually free the object.
- The `&Then` handler may transform the result type.
- Exceptions are propagated to `&Catch`. 

<br>

### Asynchronous text generation with session callbacks
If you need lifecycle hooks (start / success / error) in addition to promise composition, you can provide a callback context to `AsyncAwaitCreate`.

This is useful when you want:
- UI tracing (start/end),
- centralized logging,
- side-effects that should occur regardless of the `&Then` chain logic.

<br>

  ```pascal
    // uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

    var Params: TProc<TInteractionParams> :=
          procedure (Params: TInteractionParams)
          begin
            Params
              .Model('gemini-3-flash-preview')
              .Input('From which version of Delphi were multi-line strings introduced?' );
            TutorialHub.JSONRequest := Params.ToFormat();
          end;

    var Callbacks: TFunc<TPromiseInteraction> :=
      function : TPromiseInteraction
      begin
        Result.Sender := TutorialHub;
        Result.OnStart := Start;
        Result.OnSuccess := DisplayIx;
        Result.OnError := DisplayIx;
      end;

    // Asynchronous promise example (with session callbacks)
    var Promise := Client.Interactions.AsyncAwaitCreate(Params, Callbacks);

    Promise
      .&Then<string>(
        function (Value: TInteraction): string
        begin
          Result := Value.Id;
          // Build a chain here with another promise if necessary 
        end)
      .&Catch(
        procedure (E: Exception)
        begin
          Display(TutorialHub, E.Message);
        end);
  ```
### Key points (callbacks variant)
- The callback context (`TPromiseInteraction`) is optional: use it when you need start/success/error hooks.
- `Sender` follows the same idea as in the tutorial streaming examples: it is a contextual object for UI/log helpers.
- The promise chain remains the primary composition mechanism (`&Then` / `&Catch`).

<br>

## 3) Promises and orchestration
Because `AsyncAwaitCreate` returns a `TPromise<TInteraction>`, it can be used as a building block for **asynchronous orchestration**.

### You can:
- post-process results,
- trigger dependent operations,
- chain multiple interactions sequentially,
- centralize error handling.

<br>

- Example: chaining two non-streamed requests

  - First promise parameters

    ```pascal
    var Params: TProc<TInteractionParams> :=
          procedure (Params: TInteractionParams)
          begin
            Params
              .Model('gemini-3-flash-preview')
              .Input('From which version of Delphi were multi-line strings introduced?' );
            TutorialHub.JSONRequest := Params.ToFormat();
          end;

    var Callbacks: TFunc<TPromiseInteraction> :=
      function : TPromiseInteraction
      begin
        Result.Sender := TutorialHub;
        Result.OnStart := Start;
        Result.OnSuccess := DisplayIx;
        Result.OnError := DisplayIx;
      end;
    ```

  - Linking two promises

    ```pascal
    var Promise := Client.Interactions.AsyncAwaitCreate(Params, Callbacks);

    Promise
      .&Then(
        function (First: TInteraction): TPromise<TInteraction>
        begin
          // Second promise
          Result := Client.Interactions.AsyncAwaitCreate(
            procedure (Params: TInteractionParams)
            begin
              Params
               .Model('gemini-3-flash-preview')
               .Input('Summarize the following answer: ' + First.Outputs[1].Text);
            end);
        end)
      .&Then(
        procedure (Second: TInteraction)
        begin
          Display(TutorialHub, '----- SUMMARY');
          Display(TutorialHub, Second);
        end)
      .&Catch(
        procedure (E: Exception)
        begin
          Display(TutorialHub, E.Message);
        end);
    ``` 
This approach avoids nested callbacks and produces a linear, readable control flow.

>[!NOTE]
> Using `TPromise<TInteraction>` requires adding the `Gemini.Async.Promise` unit to the `uses` clause.

<br>

## Quick selection guide
- Blocking call, simplest usage → `Create`
- UI-friendly, non-blocking → `AsyncAwaitCreate`
- Chained async workflows → `AsyncAwaitCreate` + `&Then`

<br>

## Practical notes
- These methods produce non-streamed responses only.
- Use streaming APIs if you need partial results or real-time rendering.
- `TInteractionParams` can be reused across sync and async variants.
- Promise-based APIs are recommended for VCL / FMX applications.