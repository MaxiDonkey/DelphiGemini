# Media parts (multimodal)

>[!NOTE
>]This section describes how media inputs (documents, images, audio, and video) can be attached to a generation request.
>
>Media inputs are represented as parts within `contents` and can be provided either inline (base64-encoded) or by reference using the Files API.
>
>- Inline media is suitable for small payloads.
>- File-based media is recommended for large files or reusable assets.

<br>

- [Inline media (inline_data)](#inline-media-inline_data)
- [File-based media (file_data / file_uri)](#file-based-media-file_data--file_uri)
- [Multiple media items in one request](#multiple-media-items-in-one-request)
___

<br>




## Inline media (inline_data)
Inline media embeds the media data directly in the request payload using base64 encoding.

In line with Google’s recommendations, a **text-after-media** structure is adopted for image-and-text content, and the same policy applies to PDF documents, audio, and video media.

#### Expected JSON payload
```json
 "contents": [{
    "parts": [
      { "inline_data": { "mime_type": "application/pdf", "data": "<BASE64_PDF>" } },
      { "text": "Summarize this document" }
    ]
  }]
```

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...
  
  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);
  var Base64 := 'base64'; //TMediaCodec.EncodeBase64('filename or stream');
  var MimeType := 'application/pdf';  //TMediaCodec.GetMimeType('filename');
  var Prompt := 'Summarize this document';
```

```pascal
  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddInlineData(Base64, MimeType)
                .AddText(Prompt)
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

>[!NOTE]
>This pattern applies identically to PDF files, images, and audio or video media. Only the `mime_type` and the media source change; the payload structure remains the same.

<br>




## File-based media (file_data / file_uri)

File-based media references a previously uploaded file using the Files API.

This approach is recommended for large media files or when the same file is used across multiple requests.

#### Expected JSON payload
```json
"contents": [{
    "parts": [
      { "text": "Summarize this document" },
      { "file_data": { "mime_type": "application/pdf", "file_uri": "<FILE_URI>" } }
    ]
  }]
```

<br>

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...
  
  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);
  var Uri := 'https://website/document.pdf';
  var MimeType := 'application/pdf';
  var Prompt := 'Summarize this document';
```

```pascal
  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddFileData(Uri, MimeType)
                .AddText(Prompt)
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

>[!NOTE]
>This pattern applies to documents, images, audio, and video files. The only difference between media types is the `mime_type` value.

<br>


## Multiple media items in one request

A single generation request may reference multiple media items. Media parts can be mixed freely, regardless of whether they are provided inline or via file references.

#### Expected JSON payload
```json
"contents": [{
    "parts": [
      { "file_data": { "mime_type": "application/pdf", "file_uri": "<FILE_URI_1>" } },
      { "file_data": { "mime_type": "application/pdf", "file_uri": "<FILE_URI_2>" } },
      { "text": "What is the difference between each of the main benchmarks between these two papers? Output these in a table." }
    ]
  }]
```

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);

  var LocationFile1 := 'Local_File';
  var Base64_1 := 'base64_1';  //TMediaCodec.EncodeBase64(LocationFile1);
  var MimeType1 := 'application/pdf';

  var Uri := 'https://website/document.pdf';
  var MimeType2 := 'application/pdf';
  var Prompt := 'What is the difference between each of the main benchmarks between these two papers? Output these in a table.';
```

The pattern presented below applies to PDF files, images, and audio and video media. Only the code needs to be adapted to the relevant media type; the pattern itself remains unchanged.

```pascal
  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddInlineData(Base64_1, Mimetype1)
                .AddFileData(Uri, MimeType2)
                .AddText(Prompt)
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

>[!NOTE]
>Media parts can be combined freely within a single request. The order of parts determines how the model receives and interprets the input.



