# Interactions


- [Introduction](#introduction)
- [Text generation](#text-generation)
  - [Non streamed](interactions-generation.md) 
  - [SSE Streaming](interactions-sse.md)
- [Stateful conversation](#stateful-conversation)


___

## Introduction
The **Gemini Interactions API** is an experimental API designed for building applications based on Gemini models. These models are natively multimodal and can process, combine, and generate information from multiple data types, including text, code, audio, images, and video.

The API supports a range of use cases such as joint text-and-image reasoning, content generation, conversational agents, and synthesis or classification pipelines. It provides a unified interface for accessing the multimodal reasoning and transformation capabilities of Gemini models.

<br>

## Text generation

This section describes text generation mechanisms using two execution modes: non-streamed and streamed, each available in both synchronous and asynchronous contexts.

This part is essential, as it goes beyond text generation itself and defines how requests are issued to Gemini models. In the remainder of this document, this approach will be used as a reference. However, for clarity and conciseness, only the JSON construction submitted to the model will be explicitly detailed.

For text content generation, refer to the following sections:
- [Non streamed](interactions-generation.md) 
- [SSE Streaming](interactions-sse.md)

We nonetheless provide two simple illustrative examples here.

### Synchronous

```pascal
// uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

//Synchronous example (non streamed)
  var Value := Client.Interactions.Create(
    procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('From which version of Delphi were multi-line strings introduced?' );
        end);

  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
```

```pascal
// uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

//Synchronous example (streamed)
Client.Interactions.CreateStream(
  procedure (Params: TInteractionParams)
  begin
    Params
      .Model('gemini-3-flash-preview')
      .Input('From which version of Delphi were multi-line strings introduced?' )
      .Stream;
  end,
  procedure (var Event: TInteractionStream; IsDone: Boolean; var Cancel: Boolean)
  begin
    if (not IsDone) and Assigned(Event) then
      begin
        DisplayStream(TutorialHub, Event);
      end;
  end);
```

<br>

___

### ASynchronous

```pascal
// uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

//Asynchronous (non streamed)
  var Promise := Client.Interactions.AsyncAwaitCreate(
    procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('From which version of Delphi were multi-line strings introduced?' );
        end);

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

```pascal
// uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*)

//Asynchronous (Streamed)
  var Promise := Client.Interactions.AsyncAwaitCreateStream(
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
        end,
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
___

<br>

## Stateful conversation
To continue a conversation, provide the identifier from the previous interaction via the `previous_interaction_id` parameter.

>[!NOTE]
> The code snippets will exclusively refer to the `procedure (Params: TInteractionParams)`, as introduced in the sections covering [non-streamed](interactions-generation.md) and [streamed](interactions-sse.md) generation.


```pascal
 var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model('gemini-3-flash-preview')
        .Input('' )
        .PreviousInteractionId('INTERACTION_ID'); //INTERACTION_ID was obtained from a previous interaction turn. 
    end;

```


#### You can manage conversation history manually on the client side. 

(Delphi `version 12 or later`)
```pascal
 var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model('gemini-3-flash-preview')
        .Input(
          '''
          [
              {
                  "role": "user",
                  "content": "What are the three largest cities in Spain?"
              },
              {
                  "role": "model",
                  "content": "The three largest cities in Spain are Madrid, Barcelona, and Valencia."
              },
              {
                  "role": "user",
                  "content": "What is the most famous landmark in the second one?"
              }
          ]
          '''
         );
    end;
```

<br>

>[!NOTE]
>- If you are using Delphi `version 12 or later`, you can use multiline strings to define certain parts of the request directly as valid JSON strings. 
>- This approach is fully supported by the wrapper.
>- In the remainder of this document, examples will continue to use JSON strings to ensure consistency across illustrations.

