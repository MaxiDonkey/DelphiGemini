# Interactions


- [Introduction](#introduction)
- [Response generation](#response-generation)
  - [Non streamed](interactions-generation.md#text-generation-non-streamed-interactions) 
  - [SSE Streaming](interactions-sse.md#sse-streaming-interactions)
- [Stateful conversation](interactions-conversations.md)
- [Multimodal capabilities](#multimodal-capabilities)
- [Agentic capabilities](#agentic-capabilities)
- [Structured output (JSON schema)](#structured-output-json-schema))

___

## Introduction
The **Gemini Interactions API** is an experimental API designed for building applications based on Gemini models. These models are natively multimodal and can process, combine, and generate information from multiple data types, including text, code, audio, images, and video.

The API supports a range of use cases such as joint text-and-image reasoning, content generation, conversational agents, and synthesis or classification pipelines. It provides a unified interface for accessing the multimodal reasoning and transformation capabilities of Gemini models.

<br>

## Response generation

This section describes response generation mechanisms using two execution modes: non-streamed and streamed, each available in both synchronous and asynchronous contexts.

This part is essential, as it goes beyond text generation itself and defines how requests are issued to Gemini models. In the remainder of this document, this approach will be used as a reference. However, for clarity and conciseness, only the JSON construction submitted to the model will be explicitly detailed.

For response content generation, refer to the following sections:
- [Non streamed](interactions-generation.md#text-generation-non-streamed-interactions) 
- [SSE Streaming](interactions-sse.md#sse-streaming-interactions)

We nonetheless provide two simple illustrative examples here for text generation.

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

<br>

## Multimodal capabilities

The Interactions API supports multimodal use cases, including image understanding and video generation.

- [Multimodal understanding](interactions-multimodal-understanding.md#multimodal-understanding)
- [Multimodal generation](interactions-multimodal-generation.md#multimodal-generation)

<br>

## Agentic capabilities

The Interactions API is designed to support the construction and execution of agent-based workflows. It provides capabilities such as function calling, access to built-in tools, structured output generation, and integration with the Model Context Protocol (MCP).

- [Agents](interactions-agents.md#agents)
- [Tools](interactions-tools.md#interactions-tools)

<br>

## Structured output (JSON schema)

A specific JSON output structure can be enforced by providing a JSON schema via the `response_format` parameter, which is suitable for moderation, classification, and data extraction workflows.

- [Structured output](interaction.json-format.md#structured-output-json-schema)
