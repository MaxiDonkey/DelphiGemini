# GenerateContent

- [Introduction](#introduction)
- [Minimal generation example](#minimal-generation-example)
- [Executing a generation](#executing-a-generation)
  - [Non-streamed generation](#non-streamed-generation)
  - [SSE streamed generation](#sse-streamed-generation)
- [Building the JSON payload](#building-the-json-payload)
- [Extended inputs and capabilities](#extended-inputs-and-capabilities)

___

<br>

## Introduction

A generation is performed in two distinct steps:

1. **Building a JSON payload**, which describes the content sent to the model (prompt, context, configuration, media, tools).
2. **Executing the generation**, by sending this payload to a model and consuming the response, either as a single result or as a stream.

This document focuses on **how to execute a generation quickly**.
It starts with a minimal working example, then presents the available execution modes before introducing helper mechanisms for building more complex payloads.

<br>

## Minimal generation example
#### Expected JSON payload
```json
{
    "contents": [
        {
            "parts": [
                {
                    "text": "Write a story about a magic backpack."
                }
            ]
        }
    ],
    "generationConfig": {
        "temperature": 0.7
    }
}
```

<br>

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers;

  Client := TGeminiFactory.CreateInstance('GEMINI_API_KEY');

  //JSON payload generation
  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
         .Contents( TGeneration.Contents
             .AddText('Write a story about a magic backpack.') // AddText is a shortcut for a single text part
          )
         .GenerationConfig( TGeneration.AddConfig
             .Temperature(0.7)
          );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Synchronous example
  var Value := Client.Chat.Create('models/gemini-2.5-flash', Params); // The model is provided via the method, not inside the JSON payload

  try
    Memo1.Lines.Text := Value.Candidates[0].Content.Parts[0].Text;
  finally
    Value.Free;
  end;
```

>[!NOTE]
>```pascal 
>  //JSON payload generation
>  var Params: TProc<TChatParams> :=
>```   
>In this example, the request payload is defined as a procedure that receives a `TChatParams` instance, allowing deferred and reusable request construction. 


<br>

#### JSON Result
```json
{
    "candidates": [
        {
            "content": {
                "parts": [
                    {
                        "text": "Leo was a whirlwind of forgotten homework, ... a difference."
                    }
                ],
                "role": "model"
            },
            "finishReason": "STOP",
            "index": 0
        }
    ],
    "usageMetadata": {
        "promptTokenCount": 8,
        "candidatesTokenCount": 1177,
        "totalTokenCount": 2711,
        "promptTokensDetails": [
            {
                "modality": "TEXT",
                "tokenCount": 8
            }
        ],
        "thoughtsTokenCount": 1526
    },
    "modelVersion": "gemini-2.5-flash",
    "responseId": "SPFYaY2DDaWznsEPuKWFmQg"
}
```

<br>

- This example uses a **synchronous**, **non-streamed** generation.
- For alternative execution models, including streaming responses, see the following sections.

<br>

## Executing a generation

Once a JSON payload has been constructed, executing a generation consists in
sending this payload to a model and consuming the response produced by the model.

The execution mechanism is independent from payload construction:
the same payload can be used regardless of the execution mode.

Two execution modes are supported:

- [**Non-streamed generation**](generations-generation.md#text-generation-non-streamed-generations), which returns a complete response in a single step.
- [**SSE streamed generation**](generations-sse.md#sse-streaming-generations), which returns the response incrementally as it is generated.

The choice between these modes mainly impacts how the response is consumed,
not how the request is built.

<br>

### Non-streamed generation

In non-streamed mode, the generation is executed as a single request–response
operation. The model processes the entire input payload and returns a complete
response once generation is finished.

This mode is well suited for:

- simple or short generations,
- batch processing,
- scenarios where progressive output is not required.

The API provides both synchronous and asynchronous variants for non-streamed
generation. In both cases, the response is delivered as a fully constructed
generation result.

Detailed execution patterns, including synchronous and asynchronous usage,
error handling, and response lifetime management, are described in:

- [generations-generation.md](generations-generation.md#text-generation-non-streamed-generations)

<br>

### SSE streamed generation

In SSE (Server-Sent Events) mode, the generation result is delivered incrementally
as a stream of chunks. Each chunk represents a partial output produced by the
model, allowing the client to consume or display the response progressively.

This mode is particularly useful for:

- interactive user interfaces,
- long-running generations,
- early feedback or progressive rendering,
- cooperative cancellation during generation.

Streaming execution can also be performed in synchronous or asynchronous forms.
In asynchronous mode, callbacks are typically used to process incoming chunks,
while a final promise represents the completion of the stream.

A complete description of SSE streaming patterns, chunk handling, cancellation,
and orchestration is available in:

- [generations-sse.md](generations-sse.md#sse-streaming-generations)

<br>

## Building the JSON payload  

Writing JSON payloads manually quickly becomes error-prone as requests grow more complex (multi-turn, multimodal, tools).

For this reason, the [library](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Helpers.pas) provides the `TGeneration` helper, which offers a typed and fluent way to construct generation payloads.

See: [generations-json-payload-builder.md](generations-json-payload-builder.md#building-json-payloads-for-the-generation-endpoint)

<br>

## Extended inputs and capabilities

| Domain | supported* | payload patten | synchrone snippet | asynchrone snippet |   
| :--- | :---: | :---: | :---: | :---: |
| Text generation | ● | [**#section**](generations-json-payload-builder.md#expected-json-payload) | [**#non-streamed**](generations-generation.md#1-synchronous-text-generation) | [**#non-streamed**](generations-generation.md#2-asynchronous-text-generation-promise-based) |
| Text generation streamed | ● | [**#section**](generations-json-payload-builder.md#expected-json-payload) | [**#streamed**](generations-sse.md#1-synchronous-streaming-direct-consumption) | [**#streamed**](generations-sse.md#2-asynchronous-streaming-with-session-callbacks) |
| Image generation | ● | [**#section**](generations-json-payload-image-builder.md#image-generation) | ✔ | ✔ |
| Image understanding | ● | [**#section**](generations-json-payload-media-builder.md#inline-media-inline_data) | ✔ | ✔ |) |  
| Video understanding | ● | [**#section**](generations-json-payload-media-builder.md#inline-media-inline_data) | ✔ | ✔ |
| Document understanding | ● | [**#section**](generations-json-payload-media-builder.md#inline-media-inline_data) | ✔ | ✔ |
| Audio understanding | ● | [**#section**](generations-json-payload-media-builder.md#inline-media-inline_data) | ✔ | ✔ |
| Gemini thinking | ● | [**#section**](generations-json-payload-builder.md#reasoning-with-gemini-thinking) | ✔ | ✔ |
| Speech generation | ● |  | ✔ | ✔ |
| Structured Outputs | ● |  | ✔ | ✔ |
| Function calling | ● |  | ✔ | ✔ |
| Googgle search | ● | [**#section**](generations-json-payload-tools-builder.md#google-search) | ✔ | ✔ |
| Googgle Maps | ● | [**#section**](generations-json-payload-tools-builder.md#google-maps-grounding) | ✔ | ✔ |
| Code execution | ● | [**#section**](generations-json-payload-tools-builder.md#code-execution) | ✔ | ✔ |
| URL context | ● | [**#section**](generations-json-payload-tools-builder.md#google-url) | ✔ |✔  |
| File search | ● | interactions | ✔ | ✔ |
| Computer uses | ● | interactions | ✔ | ✔ |
| Deep Research | ● | interactions | ✔ | ✔ |

- supported* : supported*: support provided by DelphiGemini
- ✔ : compatible with both streaming and non-streaming processing

Please refer to the [detailed model specifications](https://ai.google.dev/gemini-api/docs/models) to identify the supported tools.