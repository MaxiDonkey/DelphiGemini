# DelphiGemini – Google Gemini API Wrapper for Delphi

![Delphi async/await supported](https://img.shields.io/badge/Delphi%20async%2Fawait-supported-blue)
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.4/11/12-ffffba)
[![GetIt – Available](https://img.shields.io/badge/GetIt-Available-baffc9?logo=delphi&logoColor=white)](https://getitnow.embarcadero.com/gemini-api-wrapper-for-delphi/)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-baffc9)

___

### New
- GetIt current version: 1.0.0
- [Changelog v1.1.0](changelog.md) updated on January 7, 2026
- [Interactions](guides/interactions.md#interactions)
- [Summary](#summary)

___

## Two simple illustrative examples of synchronous text generation.

>[!TIP]
>To obtain a Google API key, please refer to the [following link](https://aistudio.google.com/api-keys).

<br>

- Non streamed example :

  ```pascal
    // uses Gemini, Gemini.Types, Gemini.Helpers
    // Client: IGemini;

    Client := TGeminiFactory.CreateInstance('GEMINI_API_KEY');

    // Json Payload
    var Params: TProc<TInteractionParams> :=
      procedure (Params: TInteractionParams)
      begin
        Params
          .Model('gemini-3-flash-preview')
          .Input('From which version of Delphi were multi-line strings introduced?' );
      end;

    Memo1.Lines.Add('Please wait...');

    //Synchronous example (non streamed)
    var Value := Client.Interactions.Create(Params);

    try
      for var Output in Value.Outputs do
        if Output.&Type = TContentType.text then
          Memo1.Lines.Text := Memo1.Text + Output.Text;
    finally
      Value.Free;
    end;
  ```

<br>

- Streamed example


  ```pascal
    // uses Gemini, Gemini.Types, Gemini.Helpers;
    // Client: IGemini;

    Client := TGeminiFactory.CreateInstance('GEMINI_API_KEY');

    // Json Payload
    var Params: TProc<TInteractionParams> :=
      procedure (Params: TInteractionParams)
      begin
        Params
          .Model('gemini-3-flash-preview')
          .Input('From which version of Delphi were multi-line strings introduced?' )
          .Stream;
      end;

    // Stream Callback
    var StreamCallBack: TInteractionEvent :=
      procedure (var Event: TInteractionStream; IsDone: Boolean; var Cancel: Boolean)
      begin
        if (not IsDone) and Assigned(Event) then
          begin
            if Event.EventType = content_delta then
              if Event.Delta.&Type = TContentType.Text then
                begin
                  Memo1.Lines.Text := Memo1.Text + Event.Delta.Text;
                  Application.ProcessMessages;
                end;
          end;
      end;

    //Synchronous example (streamed)
    Client.Interactions.CreateStream(Params, StreamCallBack);
  ```

<br>

___

# Summary


- [Introduction](#introduction)
- [Philosophy and Scope](#philosophy-and-scope)
- [Documentation – Overview](#documentation--overview)
- [Going Further](#going-further)
- [Functional Coverage](#functional-coverage)
- [Project Status](#project-status)
- [License](#license)


## Introduction
    
> **Built with Delphi 12 Community Edition** (v12.1 Patch 1)  
>The wrapper itself is MIT-licensed.  
>You can compile and test it **free of charge with Delphi CE**; any recent commercial Delphi edition works as well.

<br>

**Delphi** wrapper for the **Google Gemini API**, covering both direct generation *generatedContent* and advanced agentic workflows *interactions*.

This project provides a clear and structured Delphi abstraction over the public Gemini APIs, with native support for synchronous, asynchronous, and streaming execution.

<br>

> [!IMPORTANT]
>
> This is an unofficial library. **Google** does not provide an official **Delphi SDK for Gemini**.
> This repository contains **Delphi** implementation over [Google Gemini](https://ai.google.dev/gemini-api/docs) public API.


<br>

## Philosophy and Scope

The wrapper is built around a clear and intentional separation between Gemini’s two main endpoints, which serve fundamentally different purposes.

#### GenerateContent
- direct generation
- stateless execution
- text and multimodal inputs
- simple SSE streaming
- limited built-in tools

This endpoint is well suited for immediate generation scenarios, interactive user interfaces, and straightforward processing pipelines.

<br>

### Interactions
- resource-oriented API
- server-side persistent conversations
- agents and advanced tools
- structured outputs (JSON schema)
- orchestration and background execution
- event-based SSE streaming

This endpoint is designed for more complex workflows such as agent-based systems, research tasks, structured extraction, automation, and multi-step processing.

This distinction shapes the entire documentation structure and all provided examples.

<br>

## Documentation – Overview

The documentation is organized as a set of independent Markdown files, each covering a specific functional area.

### Main Entry Points
- [**GenerateContent**](guides/generations.md#generatecontent)
  Text and multimodal generation, synchronous and asynchronous calls, streaming, payload construction, and basic tools.

- [**Interactions**](guides/interactions.md#interactions)
  Stateful conversations, agents, tools, structured outputs, orchestration, and advanced streaming

<br>

## Going Further

Some cross-cutting or advanced features are intentionally documented outside the main sections to keep the core documentation focused and readable.

A dedicated entry point groups these topics: [Going Further](guides/going-further.md)

This section links to documents covering:
- Model discovery 
- Embeddings
- File management
- Caching
- Batch processing
- Video generation (Veo)
- Image generation (Imagen 4)
- Vector stores
- Vectorized documents and fileSearch (Interactions)

Each topic is documented in its own Markdown file.

<br>

## Functional Coverage

| Domain / Feature            | Supported |
|----------------------------|:---------:|
| Text generation            | ● |
| Multimodal (image, audio, video, PDF) | ● |
| SSE streaming              | ● |
| Persistent conversations   | ● |
| Agents                     | ● |
| Deep Research              | ● |
| Structured outputs         | ● |
| Model discovery            | ● |
| Batch processing           | ● |
| Caching                    | ● |
| File management            | ● |
| Embeddings                 | ● |
| Vector search / FileSearch | ● |
| Video generation (Veo)     | ● |
| Image generation (Imagen)  | ● |
| Function calling           | ● |
| Grounding with Google Search | ● |
| Grounding with Google Map  | ● |
| Url context                | ● |
| File search                | ● |
| Code execution             | ● |
| Computer Use               | ● |
| Thinking and thought Signatures | ● |


<br>

## Project Status
- The Google Gemini API is evolving rapidly
- The Interactions endpoint is still in beta on Google’s side
- The wrapper follows a pragmatic approach:
  - document what is stable
  - isolate what is evolving
  - avoid unnecessary duplication of the official documentation

<br>

## License


This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.