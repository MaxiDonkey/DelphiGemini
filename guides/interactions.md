# Interactions


- [Introduction](#introduction)
- [Response generation](#response-generation)
  - [Non streamed](interactions-generation.md#text-generation-non-streamed-interactions) 
  - [SSE Streaming](interactions-sse.md#sse-streaming-interactions)
- [Stateful conversation](interactions-conversations.md)
- [Multimodal capabilities](#multimodal-capabilities)
- [Agentic capabilities](#agentic-capabilities)
- [Structured output (JSON schema)](#structured-output-json-schema)
- [Configuration](#configuration)
- [Supported models & agents](#supported-models--agents)
- [Key Takeaways](#key-takeaways)

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

<br>

## Configuration
Customize the model's behavior with `generation_config`.

- [Generation config](interactions-generation-config.md#generation-config)

<br>

## Supported models & agents

| Model name | Type | Model ID |
| :---: | :---: | :---: |
| Gemini 2.5 Pro | Model | gemini-2.5-pro |
| Gemini 2.5 Flash | Model | gemini-2.5-flash |
| Gemini 2.5 Flash-lite | Model | gemini-2.5-flash-lite |
| Gemini 3 Pro Preview | Model | gemini-3-pro-preview |
| Gemini 3 Flash Preview | Model | gemini-3-flash-preview |
| Deep Research Preview | Agent | deep-research-pro-preview-12-2025 |

<br>

## Key Takeaways

### Interaction Resource Overview
The Interactions API is centered around a core resource called an Interaction. An Interaction represents a single turn in a conversation or task execution. It serves as a session record that captures the full interaction context, including user inputs, model reasoning steps, tool invocations, tool results, and final model outputs.

Calling `interactions.create` creates a new Interaction resource.

To continue an existing conversation, you may optionally supply the identifier of a previous Interaction using the `previous_interaction_id` parameter. The server uses this identifier to restore the full interaction context, eliminating the need to resend the entire conversation history. This server-side state management is optional; the API also supports stateless operation by providing the complete conversation context with each request.

<br>

### Data Storage and Retention

By default, Interaction objects are stored (`store=true`) to enable server-side state management (`previous_interaction_id`), background execution (`background=true`), and observability features.

Retention policies vary by tier:
- Paid tier: Interactions are retained for 55 days
- Free tier: Interactions are retained for 1 day

To disable storage, set `store=false` in the request. This option is independent of state management but comes with the following constraints:
- `store=false` is incompatible with `background=true`
- Stored state cannot be reused via `previous_interaction_id` in subsequent requests

Stored interactions can be deleted at any time using the delete method described in the API Reference, provided the interaction ID is known. After the applicable retention period, stored data is automatically deleted.

All Interaction objects are processed in accordance with the applicable terms.

<br>

### Best Practices
- **Cache efficiency:** Continuing conversations using `previous_interaction_id` improves cache utilization, which can reduce latency and overall cost.

- **Interaction composition:** Agent-based and model-based interactions can be combined within the same conversation flow. For example, a specialized agent (such as a Deep Research agent) may be used for initial data gathering, followed by a standard Gemini model for downstream tasks like summarization or reformatting, with continuity maintained via `previous_interaction_id`.