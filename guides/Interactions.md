# Interactions


- [Introduction](#introduction)
- [Text generation](#text-generation)
  - [Non streamed](interactions-generation.md) 
  - [SSE Streaming](interactions-sse.md)
- [Stateful conversation](#stateful-conversation)
- [Multimodal capabilities](#multimodal-capabilities)
- [Agentic capabilities](#agentic-capabilities)


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
        .Input('new message in the conversation')
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

<br>

## Multimodal capabilities

The Interactions API supports multimodal use cases, including image understanding and video generation.

- [Multimodal understanding](#multimodal-understanding)
- [Multimodal generation](#multimodal-generation)

___

<br>

### Multimodal understanding
Multimodal data may be supplied inline as `base64-encoded` content or via the Files API for larger files.

- [Image understanding](#image-understanding)
- [Audio understanding](#audio-understanding)
- [Video understanding](#video-understanding)
- [Document (PDF) understanding](#document-pdf-understanding)
___

<br>

#### Image understanding

The wrapper provides full support for handling base64-encoded content as well as DATA URI formats. For more details, refer to the [`Gemini.Net.MediaCodec`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Net.MediaCodec.pas) unit, which includes the `TMediaCodec` helper, or to the Codec management section.

```pascal
  var ImageLocation := 'Z:\Images\Invoice.png';


  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              TInput.Create()
                .AddText('Describe the image.')
                .AddImage(TMediaCodec.EncodeBase64(ImageLocation), TMediaCodec.GetMimeType(ImageLocation))
             );
        end;
```

- The `TInput` helper class provides a convenient way to add various types of inputs, including images, documents, audio data, and video. It is also possible to supply only a document URI, without embedding the content itself.

```pascal
  var ImageUri := 'https://assets.visitorscoverage.com/production/wp-content/uploads/2024/04/AdobeStock_626542468-min-1024x683.jpeg'; 

  ...
    .Input(
      TInput.Create()
        .AddText('Compare the two images')
        .AddImage(TMediaCodec.EncodeBase64(ImageLocation), TMediaCodec.GetMimeType(ImageLocation))
        .AddImage(ImageUri)
     )
  ...
```

- The `TInput` helper class is available in the [`Gemini.Helpers`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Helpers.pas) unit. This unit contains several helper classes designed to simplify the construction of JSON structures.

<br>

##### Delphi `version 12 or later`
 
```pascal
  var ImageLocation := 'Z:\Images\Invoice.png';
  var Base64 := TMediaCodec.EncodeBase64(ImageLocation);

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              Format(
                '''
                [
                    {"type": "text", "text": "Describe the image."},
                    {"type": "image", "data": "%s", "mime_type": "image/png"}
                ]
                ''',
                [Base64])
             )
            .Stream;
        end;
```

___

<br>

#### Audio understanding

```pascal
  var AudioLocation := 'Z:\Audio\VoiceRecorded.wav';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              TInput.Create()
                .AddText('What does this audio say?')
                .AddAudio(TMediaCodec.EncodeBase64(AudioLocation), 'audio/wav')
             );
        end;
```

<br>

##### Delphi `version 12 or later`
 
```pascal
  var AudioLocation := 'Z:\Audio\VoiceRecorded.wav';
  var Base64 := TMediaCodec.EncodeBase64(AudioLocation);
  var MimeType := TMediaCodec.GetMimeType(AudioLocation);

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              Format(
                '''
                [
                    {"type": "text", "text": "What does this audio say?"},
                    {"type": "audio", "data": "%s", "mime_type": "%s"}
                ]
                ''',
                [Base64, Mimetype])
             );
        end;
```

___

<br>

#### Video understanding
As an alternative to uploading video files via the Files API, smaller video assets can be included directly in the `generateContent` request. This approach is intended for short videos and is subject to a total request size limit of 20 MB.

YouTube video URLs can also be provided directly to the Gemini API as part of the request payload.

Limitations
- Free tier: Uploads are limited to a total of 8 hours of YouTube video per day.
- Paid tier: No restrictions apply based on video length.
- Model constraints:
  - For models prior to Gemini 2.5, only one video may be included per request.
  - For Gemini 2.5 and later models, up to 10 videos may be included per request.
- Only publicly accessible YouTube videos are supported; private or unlisted videos cannot be used.

<br>

```pascal
  var VideoUri := 'https://www.youtube.com/watch?v=9hE5-98ZeCg';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              TInput.Create()
                .AddText('Please summarize the video in 3 sentences.')
                .AddVideo(VideoUri)
             );
        end;
```

<br>

##### Delphi `version 12 or later`
 
```pascal
  var VideoUri := 'Z:\Audio\Video.mp4';
  var Base64 := TMediaCodec.EncodeBase64(VideoUri);

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              Format(
                '''
                [{
                  "parts":[
                      {
                        "inline_data": {
                          "mime_type":"video/mp4",
                          "data": "%s"
                        }
                      },
                      {"text": "Please summarize the video in 3 sentences."}
                  ]
                }]
                ''',
                [Base64])
             );
        end;
```

##### Using Files

Upload a video file using the File API before making a request. Use this approach for files larger than 20MB, videos longer than approximately 1 minute, or when you want to reuse the file across multiple requests.

___

<br>

#### Document (PDF) understanding

Document Processing with Gemini Models

`Gemini models` can process documents in `PDF` format using native vision capabilities to understand the document as a whole, rather than relying solely on text extraction. This enables advanced document-level analysis, including:
- Analyzing and interpreting content that combines text, images, diagrams, charts, and tables, even in long documents of up to **1,000 pages**.
- Extracting information into structured output formats.
- Generating summaries and answering questions based on both visual and textual elements.
- Transcribing document content (for example, to HTML) while preserving layout and formatting for downstream use.

Non-PDF documents can also be provided using the same mechanism; however, in this case, Gemini processes them as plain text, which means visual context such as charts, layout, and formatting is not preserved.

<br>

Passing PDF data inline

```pascal
  var FilePath := 'Z:\PDF\File_Search_file.pdf';
  var Base64 := TMediaCodec.EncodeBase64(FilePath);

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              TInput.Create()
                .AddText('What is this document about?')
                .AddDocument(Base64, 'application/pdf')
             )
            .Stream;
          TutorialHub.JSONRequest := Params.ToFormat();
        end;
```

<br>

Passing PDF by URI

##### Delphi `version 12 or later`

```pascal
  var PDFUri := 'https://discovery.ucl.ac.uk/id/eprint/10089234/1/343019_3_art_0_py4t4l_convrt.pdf';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input(
              Format(
                '''
                [
                    {"type": "text", "text": "What is this document about?"},
                    {"type": "document", "uri": "%s", "mime_type": "application/pdf"}
                ]
                ''',
                [PDFUri])
             )
            .Stream;
          TutorialHub.JSONRequest := Params.ToFormat();
        end;
```

##### PDF Size and Processing Limits
Gemini supports PDF documents up to **50 MB** in size or a maximum of **1,000 pages**. These limits apply to both inline submissions and uploads performed through the Files API. Each document page is internally accounted for as **258 tokens**.

There are no explicit constraints on document pixel dimensions beyond the model’s overall context window. During processing, pages are automatically resized as follows:
- Large pages are scaled down to a maximum resolution of **3072 × 3072 pixels**, while preserving the original aspect ratio.
- Smaller pages are scaled up to a minimum resolution of **768 × 768 pixels**.

Using lower-resolution pages does not reduce token costs beyond bandwidth considerations, nor does providing higher-resolution pages result in performance improvements.

___

<br>

### Multimodal generation

The Interactions API supports the generation of multimodal outputs across supported media types.

- Image generation

  ```pascal
    var Params: TProc<TInteractionParams> :=
          procedure (Params: TInteractionParams)
          begin
            Params
              .Model('nano-banana-pro-preview')
              .Input('Generate an image of a futuristic city.' )
              .ResponseModalities([TResponseModality.image, TResponseModality.text]);
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
        
          for var Item in Value.Outputs do
            begin
              case Item.&Type of
                TContentType.image:
                  TMediaCodec.TryDecodeBase64ToFile(Item.Data, 'MyFile.jpg');
              end;
            end;

        end)
      .&Catch(
        procedure (E: Exception)
        begin
          Display(TutorialHub, E.Message);
        end);
  ```

<br>

## Agentic capabilities

The Interactions API is designed to support the construction and execution of agent-based workflows. It provides capabilities such as function calling, access to built-in tools, structured output generation, and integration with the Model Context Protocol (MCP).

- [Agents](#agents)
- [Tools and function calling](#tools-and-function-calling)

___

<br>

### Agents
Specialized agents, such as `deep-research-pro-preview-12-2025`, can be used to handle complex or multi-step tasks. For additional details, refer to the Deep Research guide.

>[!WARNING]
>- **Google Deep Research** is currently in beta. As such, users may encounter instability issues, including 504 errors, especially when submitting resource-intensive or highly complex research queries. In these situations, retrying the request or reformulating it to reduce computational demands is recommended.
>
>- The service appears to rely on infrastructure that is not yet fully isolated. It should therefore be treated as a best-effort or batch-oriented service.
>
>- In its current state, Google Deep Research is comparatively less mature, particularly when contrasted with an integration of OpenAI Deep Research that supports streaming execution with visible tool usage.  

<br>

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Agent('deep-research-pro-preview-12-2025')
            .Input('Explain what the SU(3) group is.' )
            .Background(true);
          TutorialHub.JSONRequest := Params.ToFormat();
        end;

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitCreate(Params);

  Promise
    .&Then<string>(
      function (Value: TInteraction): string
      begin
        Result := Value.Id;
        Display(TutorialHub, Result);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
```

Once the request has been submitted, wait for the `INTERACTION_ID` (e.g. v1_ChcybEZSYWJt...ZpUUU) to be returned, indicating that the request is being processed.

This identifier must then be used to poll the status and retrieve the result using the `Client.Interactions.AsyncAwaitRetrieve(INTERACTION_ID)` method.

Result : status in progress

```json
{
    "agent": "deep-research-pro-preview-12-2025",
    "created": "2025-12-28T15:50:51Z",
    "id": "v1_ChcybEZSYWJtM05hZVVrZFVQcXFxNmlRRRIXMmxGUmFibTNOYWVVa2RVUHFxcTZpUUU",
    "object": "interaction",
    "role": "agent",
    "status": "in_progress",
    "updated": "2025-12-28T15:50:51Z"
}
```

Result : status completed

```json
{
    "agent": "deep-research-pro-preview-12-2025",
    "created": "2025-12-28T15:50:51Z",
    "id": "v1_ChcybEZSYWJtM05hZVVrZFVQcXFxNmlRRRIXMmxGUmFibTNOYWVVa2RVUHFxcTZpUUU",
    "object": "interaction",
    "outputs": [
        {
            "text": "# Le Groupe SU(3) : Structure Mathématique ...
```

>[!NOTE]
>It is currently not possible to monitor the progress of the research in real time.

___

<br>

### Tools and function calling

This section describes how to define custom tools using function calling and how to leverage Google’s built-in tools within the Interactions API.

