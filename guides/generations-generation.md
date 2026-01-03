# Text generation (non-streamed generations)

- [Overview](#overview)
- [Synchronous text generation](#1-synchronous-text-generation)
- [Asynchronous text generation (promise-based)](#2-asynchronous-text-generation-promise-based)
- [Promises and orchestration](#3-promises-and-orchestration)
- [Quick selection guide](#quick-selection-guide)
- [Practical notes](#practical-notes)

___

<br>

## Overview

The `Client.Chat.Create` and `Client.Chat.AsyncAwaitCreate` methods request a Gemini model to generate a single, non-streamed response using the **Generation API** style (the “original” Gemini mode).

#### Unlike SSE streaming:
- the model produces its full output in one response,
- no intermediate chunks or events are emitted,
- the resulting `TChat` object contains the complete generated content.

<br>

#### Key difference vs Interactions
- **Generations:** the model name is provided via the method / URL, not inside the JSON body.
- **Generations:** prompts + context are passed via `Contents(...)`.
- **Interactions:** the request body typically includes `.Model(...)` and uses `.Input(...)`, which is more convenient for flexible/agentic routing.

<br>

>[!NOTE]
>**Tutorial support units**
>
>The `Display(...)` helper procedures used in the examples are provided by `Gemini.Tutorial.VCL` or `Gemini.Tutorial.FMX`, depending on the target platform.
>
>These units exist solely to keep tutorial code concise and readable. They are not part of the core API.
>In a real application, you are expected to replace them with your own UI, logging, or domain-specific logic.


<br>

## 1) Synchronous text generation

#### When to use it
Use the synchronous API when:
- you want the simplest possible usage,
- blocking the current thread is acceptable,
- you are running in a background thread or a console-style workflow.

#### How it works 
- `ParamProc` configures the generation request body (no `.Model(...)` here).
- `Create(ModelName, ParamProc)` performs a blocking HTTP call.
- The returned `TChat` must be freed by the caller.

  
   ```pascal
     // uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

     var ModelName := 'gemini-3-pro-preview';

     //JSON payload generation
     var Params: TProc<TChatParams> :=
       procedure (Params: TChatParams)
       begin
         Params
            .Contents( TGeneration.Contents
                .AddText('Write a story about a magic backpack.')
             )
            .GenerationConfig( TGeneration.AddConfig
                .Temperature(0.7)
             );

         //Displays the JSON payload
         TutorialHub.JSONRequest := Params.ToFormat();
       end;


     //Synchronous example
     var Value := Client.Chat.Create(ModelName, Params);

     try
       Display(Memo1, Value);

       // Example: extract the first text part
       Display(TutorialHub, Value.Candidates[0].Content.Parts[0].Text);
     finally
       Value.Free;
     end;
   ```

#### Key points
- The call blocks until the model response is fully received.
- Memory ownership is explicit: you must free `TChat`.
- Errors are raised as exceptions.

<br>

## 2) Asynchronous text generation (promise-based)
#### Why use the asynchronous variant
The asynchronous API:
- avoids blocking the calling thread,
- integrates naturally with UI applications,
- enables clean composition through promises.

#### How it works
- `AsyncAwaitCreate(ModelName, ParamProc)` immediately returns a `TPromise<TChat>`.
- The request runs in the background.
- `&Then` is invoked on success.
- `&Catch` centralizes error handling.

  ```pascal
    // uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)
  
    var ModelName := 'gemini-3-pro-preview';

    var Document := '..\..\images\Invoice.png';
    var base64 := TMediaCodec.EncodeBase64(Document);
    var mimeType := TMediaCodec.GetMimeType(Document);

    //JSON payload generation
    var Params: TProc<TChatParams> :=
      procedure (Params: TChatParams)
      begin
        Params
          .Contents( TGeneration.Contents
              .AddParts( TGeneration.Parts
                  .AddText('Décrire l''image en détails')
                  .AddInlineData(base64, mimeType)
               )
           );
       TutorialHub.JSONRequest := Params.ToFormat();
      end;

    // Asynchronous generation (promise-based)
    var Promise := Client.Chat.AsyncAwaitCreate(ModelName, Params);

    Promise
      .&Then<string>(
        function (Value: TChat): string
        begin
          Result := Value.Candidates[0].Content.Parts[0].Text;
          Display(TutorialHub, Value);
        end)
      .&Catch(
        procedure (E: Exception)
        begin
          Display(TutorialHub, E.Message);
        end);
  ```
#### Key points
- The returned `TChat` is owned by the promise chain.
- You do not manually free the object.
- The `&Then` handler may transform the result type.
- Exceptions are propagated to `&Catch`.

<br>

### Asynchronous text generation with session callbacks

If you need lifecycle hooks (start / success / error) in addition to promise composition, you can provide a callback context to `AsyncAwaitCreate`.

This is useful when you want:
- UI tracing (start/end),
- centralized logging,
- side-effects that should occur regardless of the &Then chain logic.

   ```pascal
     // uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

     var ModelName := 'gemini-3-pro-preview';

     var Params: TProc<TChatParams> :=
     procedure (Params: TChatParams)
     begin
       Params
         .Contents(
           TGeneration.Contents
             .AddText('Write a short story about a magic backpack.')
         );

       TutorialHub.JSONRequest := Params.ToFormat();
     end;

     var Callbacks: TFunc<TPromiseChat> :=
       function : TPromiseChat
       begin
         Result.Sender := TutorialHub;
         Result.OnStart := Start;
         Result.OnSuccess := DisplayChat;
         Result.OnError := DisplayChat;
       end;

     // Asynchronous generation (with session callbacks)
     var Promise := Client.Chat.AsyncAwaitCreate(ModelName, Params, Callbacks);

     Promise
       .&Then<string>(
         function (Value: TChat): string
         begin
           Result := Value.Candidates[0].Content.Parts[0].Text;
         end)
       .&Catch(
         procedure (E: Exception)
         begin
           Display(TutorialHub, E.Message);
         end);
   ```

#### Key points (callbacks variant)
- The callback context (`TPromiseChat`) is optional: use it when you need start/success/error hooks.
- `Sender` follows the same idea as in the tutorial streaming examples: it is a contextual object for UI/log helpers.
- The promise chain remains the primary composition mechanism (`&Then` / `&Catch`).

<br>

## 3) Promises and orchestration
Because `AsyncAwaitCreate` returns a `TPromise<TChat>`, it can be used as a building block for asynchronous orchestration.

#### You can:
- post-process results,
- trigger dependent operations,
- chain multiple generations sequentially,
- centralize error handling.

<br>

- Example: chaining two non-streamed generation requests
  - First promise parameters

    ```pascal
     var ModelName := 'gemini-3-pro-preview';

     var Params: TProc<TChatParams> :=
       procedure (Params: TChatParams)
       begin
         Params.Contents(
           TGeneration.Contents
             .AddText('Explain the difference between monads and applicatives.')
         );
       end;

     var Callbacks: TFunc<TPromiseChat> :=
       function : TPromiseChat
       begin
         Result.Sender := TutorialHub;
         Result.OnStart := Start;
         Result.OnSuccess := DisplayChat;
         Result.OnError := DisplayChat;
       end; 
    ```


   - Linking two promises 

     ```pascal
      var Promise := Client.Chat.AsyncAwaitCreate(ModelName, Params, Callbacks);

      Promise
        .&Then(
          function (First: TChat): TPromise<TChat>
          var
            Answer: string;
          begin
            Answer := First.Candidates[0].Content.Parts[0].Text;

            // Second promise
            Result := Client.Chat.AsyncAwaitCreate(
              ModelName,
              procedure (Params: TChatParams)
              begin
                Params.Contents(
                  TGeneration.Contents
                    .AddText('Summarize the following answer in 5 bullet points:'#10 + Answer)
                );
              end
            );
          end)
        .&Then(
          procedure (Second: TChat)
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
>Using `TPromise<TChat>` requires adding the `Gemini.Async.Promise` unit to the `uses` clause. 

<br>²

## Quick selection guide
- Blocking call, simplest usage → `Client.Chat.Create(ModelName, Params)`
- UI-friendly, non-blocking → `Client.Chat.AsyncAwaitCreate(ModelName, Params)`
- Chained async workflows → `AsyncAwaitCreate` + `&Then`

<br>

## Practical notes
- These methods produce non-streamed responses only.
- Use streaming APIs if you need partial results or real-time rendering.
- `TChatParams` can be reused across sync and async variants.
- In **Generations**, keep the request body model-agnostic: the model is provided outside the JSON payload.
