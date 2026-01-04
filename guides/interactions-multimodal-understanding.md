# Multimodal understanding
Multimodal data may be supplied inline as `base64-encoded` content or via the Files API for larger files.

- [Image understanding](#image-understanding)
- [Audio understanding](#audio-understanding)
- [Video understanding](#video-understanding)
- [Document (PDF) understanding](#document-pdf-understanding)
___

>[!NOTE]
> The code snippets will exclusively refer to the `procedure (Params: TInteractionParams)`, as introduced in the sections covering [non-streamed](interactions-generation.md#text-generation-non-streamed-interactions) and [streamed](interactions-sse.md#sse-streaming-interactions) generation.



<br>

## Image understanding

The wrapper provides full support for handling base64-encoded content as well as DATA URI formats. For more details, refer to the [`Gemini.Net.MediaCodec`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Net.MediaCodec.pas) unit, which includes the `TMediaCodec` helper, or to the Codec management section.

```pascal
  var ImageLocation := '..\..\media\Invoice.png';
  var Base64 := TMediaCodec.EncodeBase64(ImageLocation);
  var MimeType := TMediaCodec.GetMimeType(ImageLocation);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Describe the image.';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs
                .AddImage(Base64, MimeType)
                .AddText(Prompt)
             )
            //.Stream;  //Optional: only when streaming mode
        end;
```

- The `TInput` helper class provides a convenient way to add various types of inputs, including images, documents, audio data, and video. It is also possible to supply only a document URI, without embedding the content itself.

```pascal
  var ImageUri := 'https://assets.visitorscoverage.com/production/wp-content/uploads/2024/04/AdobeStock_626542468-min-1024x683.jpeg'; 
  var Prompt := 'Compare images';

  ...
    .Input( Interactions.Inputs
        .AddImage(Base64, MimeType)
        .AddImage(ImageUri)
        .AddText(Prompt)
     )
  ...
```

- The `TInput` helper class is available in the [`Gemini.Helpers`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Helpers.pas) unit. This unit contains several helper classes designed to simplify the construction of JSON structures.

<br>

### Delphi `version 12 or later`
 
```pascal
  var ImageLocation := 'Z:\Images\Invoice.png';
  var Base64 := TMediaCodec.EncodeBase64(ImageLocation);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Describe the image.';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(
              Format(
                '''
                [
                    {"type": "text", "text": "%s"},
                    {"type": "image", "data": "%s", "mime_type": "image/png"}
                ]
                ''',
                [Prompt, Base64])
             )
            .Stream;
        end;
```

<br>

## Audio understanding

```pascal
  var AudioLocation := '..\..\media\Sample.wav';
  var Base64 := TMediaCodec.EncodeBase64(AudioLocation);
  var MimeType := TMediaCodec.GetMimeType(AudioLocation);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What does this audio say?';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs
                .AddAudio(Base64, MimeType)
                .AddText(Prompt)
             )
            //.Stream;  //Optional: only when streaming mode
        end;
```

<br>

### Delphi `version 12 or later`
 
```pascal
  var AudioLocation := '..\..\media\Sample.wav';
  var Base64 := TMediaCodec.EncodeBase64(AudioLocation);
  var MimeType := TMediaCodec.GetMimeType(AudioLocation);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What does this audio say?';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(
              Format(
                '''
                [
                    {"type": "audio", "data": "%s", "mime_type": "%s"},
                    {"type": "text", "text": "%s"}
                ]
                ''',
                [Base64, Mimetype, Prompt])
            )
            //.Stream;  //Optional: only when streaming mode 
        end;
```


<br>

## Video understanding
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
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Please summarize the video in 3 sentences.';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs 
                .AddVideo(VideoUri)
                .AddText(Prompt)
             )
            //.Stream;  //Optional: only when streaming mode
        end;
```

<br>

### Delphi `version 12 or later` by "inline_data" encoding
 
```pascal
  var VideoUri := '..\..\media\dialogue.mp4';
  var Base64 := TMediaCodec.EncodeBase64(VideoUri);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Please summarize the video in 3 sentences.';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(
              Format(
                '''
                [
                    {
                        "type": "video",
                        "mime_type": "video/mp4",
                        "data": "%s"},
                    {
                        "type": "text",
                        "text": "%s"
                    }
                ]
                ''',
                [Base64, Prompt])
             )
            //.Stream;  //Optional: only when streaming mode
        end;
```

### Using Files

Upload a video file using the File API before making a request. Use this approach for files larger than 20MB, videos longer than approximately 1 minute, or when you want to reuse the file across multiple requests.


<br>

## Document (PDF) understanding

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
  var FilePath := '..\..\media\File_Search_file.pdf';
  var Base64 := TMediaCodec.EncodeBase64(FilePath);
  var MimeType := 'application/pdf';
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What is this document about?';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs
                .AddDocument(Base64, MimeType)
                .AddText(Prompt)
             )
            //.Stream;  //Optional: only when streaming mode
        end;
```

<br>

Passing PDF by URI

### Delphi `version 12 or later`

```pascal
  var PDFUri := 'https://discovery.ucl.ac.uk/id/eprint/10089234/1/343019_3_art_0_py4t4l_convrt.pdf';
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What is this document about?';

  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(
              Format(
                '''
                [
                    {"type": "document", "uri": "%s", "mime_type": "application/pdf"},
                    {"type": "text", "text": "%s"}
                ]
                ''',
                [PDFUri, Prompt])
             )
            .Stream;
          TutorialHub.JSONRequest := Params.ToFormat();
        end;
```

### PDF Size and Processing Limits
Gemini supports PDF documents up to **50 MB** in size or a maximum of **1,000 pages**. These limits apply to both inline submissions and uploads performed through the Files API. Each document page is internally accounted for as **258 tokens**.

There are no explicit constraints on document pixel dimensions beyond the model’s overall context window. During processing, pages are automatically resized as follows:
- Large pages are scaled down to a maximum resolution of **3072 × 3072 pixels**, while preserving the original aspect ratio.
- Smaller pages are scaled up to a minimum resolution of **768 × 768 pixels**.

Using lower-resolution pages does not reduce token costs beyond bandwidth considerations, nor does providing higher-resolution pages result in performance improvements.


