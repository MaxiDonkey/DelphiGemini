# Delphi Gemini API

___
![GitHub](https://img.shields.io/badge/IDE%20Version-Delphi%2010.3/11/12-yellow)
![GitHub](https://img.shields.io/badge/platform-all%20platforms-green)
![GitHub](https://img.shields.io/badge/Updated%20the%2010/15/2024-blue)

<br/>
<br/>

- [Introduction](#Introduction)
- [Remarks](#remarks)
- [Usage](#usage)
    - [Initialization](#initialization)
    - [Asynchronous callback mode management](#Asynchronous-callback-mode-management)
    - [Gemini Models Overview](#Gemini-Models-Overview)
    - [Embeddings](#embeddings)
    - [Generate text](#Generate-text)
        - [Generate text from text-only input](#Generate-text-from-text-only-input)
        - [Generate text from text-and-image input](#Generate-text-from-text-and-image-input)
        - [Generate a text stream](#Generate-a-text-stream)
        - [Build an interactive chat](#Build-an-interactive-chat)
        - [Configure text generation](#Configure-text-generation)
    - [Document processing](#Document-processing)
        - [Upload a document and generate content](#Upload-a-document-and-generate-content)
        - [Get metadata for a file](#Get-metadata-for-a-file)
        - [List files](#List-files)
        - [Delete files](#Delete-files)
    - [System instructions](#System-instructions)
    - [Vision](#Vision)
        - [Prompting with images](#Prompting-with-images)
        - [Prompting with video](#Prompting-with-video)
    - [Audio](#Audio)
        - [Speech-to-text](#Speech-to-text)
        - [Text-to-speech](#Text-to-speech)
    - [Long context](#Long-context)
    - [Code execution](#Code-execution)
    - [Function calling](#Function-calling)
    - ... TODO
- [Contributing](#contributing)
- [License](#license)

<br/>

# Introduction

Welcome to the unofficial Delphi Gemini API library! This project is designed to offer a seamless interface for Delphi developers to interact with the Gemini public API, enabling easy integration of advanced natural language processing capabilities into your Delphi applications. Whether you're looking to generate text, create embeddings, use conversational models, or generate code, this library provides a straightforward and efficient solution.

Gemini is a robust natural language processing API that empowers developers to add sophisticated AI features to their applications. For more information, refer to the official [Gemini documentation](https://ai.google.dev/gemini-api/docs).

<br/>

# Remarks

> [!IMPORTANT]
>
> This is an unofficial library. **Google** does not provide any official library for `Delphi`.
> This repository contains `Delphi` implementation over [Gemini](https://ai.google.dev/api) public API.

<br/>

# Usage

<br/>

## Initialization

To initialize the API instance, you need to [obtain an API key from Google](https://aistudio.google.com/app/apikey?hl=fr).

Once you have a token, you can initialize `IGemini` interface, which is an entry point to the API.

Due to the fact that there can be many parameters and not all of them are required, they are configured using an anonymous function.

> [!NOTE]
>```Pascal
>uses Gemini;
>
>var Gemini := TGeminiFactory.CreateInstance(API_KEY);
>```

<br/>

## Asynchronous callback mode management

In the context of asynchronous methods, for a method that does not involve streaming, callbacks use the following generic record: `TAsynCallBack<T> = record` defined in the `Gemini.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnSuccess: TProc<TObject, T>;
       OnError: TProc<TObject, string>; 
```
<br/>

For methods requiring streaming, callbacks use the generic record `TAsynStreamCallBack<T> = record`, also defined in the `Gemini.Async.Support.pas` unit. This record exposes the following properties:

```Pascal
   TAsynCallBack<T> = record
   ... 
       Sender: TObject;
       OnStart: TProc<TObject>;
       OnSuccess: TProc<TObject, T>;
       OnProgress: TProc<TObject, T>;
       OnError: TProc<TObject, string>;
       OnCancellation: TProc<TObject>;
       OnDoCancel: TFunc<Boolean>;
```

The name of each property is self-explanatory; if needed, refer to the internal documentation for more details.

<br/>

## Gemini Models Overview

List the various models available in the API. You can refer to the Models documentation to understand what models are available. See [Models Documentation](https://ai.google.dev/gemini-api/docs/models/gemini?hl=fr).

Alongside its standard models, the `Gemini` API also includes experimental models offered in Preview mode. These models are intended for testing and feedback purposes and are not suitable for production use. `Google` releases these experimental models to gather insights from users, but there's no commitment that they will be developed into stable models in the future.

Retrieving the list of available models through the API.

1. **Synchronously**

```Pascal
// uses Gemini, Gemini.Models;

  var List := Gemini.Models.List;
  try
    for var Item in List.Models do
      WriteLn( Item.DisplayName );
  finally
    List.Free;
  end;
```

2. **Asynchronously** : Using query parameters

```Pascal
// uses Gemini, Gemini.Models;

// Declare "Next" a global variable, var Next: string;

  Gemini.Models.AsynList(5, Next,
    function : TAsynModels
    begin
      Result.Sender := Memo1;   // Set a TMemo on the form

      Result.OnStart :=
        procedure (Sender: TObject)
        begin
          // Handle the start
        end;

      Result.OnSuccess :=
        procedure (Sender: TObject; List: TModels)
        begin
          var M := Sender as TMemo;
          for var Item in List.Models do
            begin
              M.Text := M.Text + sLineBreak + Item.DisplayName;
              Next := List.NextPageToken;
            end;
          M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
        end;

      Result.OnError :=
        procedure (Sender: TObject; Error: string)
        begin
          //Handle the error message
        end
    end);
```
The previous example displays the models in batches of 5.

3. **Asynchronously** : Retrive a model.

```Pascal
// uses Gemini, Gemini.Models;

// Set a TMemo on the form

  Gemini.Models.AsynList('models/Gemini-1.5-flash',
    function : TAsynModel
    begin
      Result.OnSuccess :=
        procedure (Sender: TObject; List: TModel)
        begin
          Memo1.Text := Memo1.Text + sLineBreak + List.DisplayName;
          M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
        end;
    end);
```

<br/>

## Embeddings

**Embeddings** are numerical representations of text inputs that enable a variety of unique applications, including *clustering*, *measuring similarity*, and *information retrieval*. For an introduction, take a look at the [Embeddings guide](https://ai.google.dev/gemini-api/docs/embeddings). <br/>
See also the [embeddings models](https://ai.google.dev/gemini-api/docs/models/gemini#text-embedding).

In the following examples, we will use the procedures 'Display' to simplify the examples.

> [!TIP]
>```Pascal
>  procedure Display(Sender: TObject; Embed: TEmbeddingValues); overload;
>  begin
>    var M := Sender as TMemo;
>    for var Item in Embed.Values do
>      begin
>        M.Lines.Text := M.Text + sLineBreak + Item.ToString;
>      end;
>    M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>  end;
>```
>
>```Pascal
>  procedure Display(Sender: TObject; Embed: TEmbeddings); overload;
>  begin
>    var M := Sender as TMemo;
>    for var Item in Embed.Embeddings do
>      begin
>        Display(Sender, Item);
>        M.Lines.Text := M.Text + sLineBreak;
>      end;
>    M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>  end;
>```

1. **Synchronously** : Get the vector representation of the text *'This is an example'*.

```Pascal
// uses Gemini, Gemini.Embeddings; 

  var Integration := Gemini.Embeddings.Create('models/text-embedding-004',
            procedure (Params: TEmbeddingParams)
            begin
              Params.Content(['This is an example']);
            end);
  // For displaying, add a TMemo on the form
  try
    Display(Memo1, Integration.Embedding)
  finally
    Integration.Free;
  end;
```

2. **Asynchronously** : Get the vector representation of the text *'This is an example'* and *'Second example'*.<br/>
 - The vectors will be of reduced dimension (20).

```Pascal
// uses Gemini, Gemini.Embeddings; 

    Gemini.Embeddings.AsynCreateBatch('models/text-embedding-004',
       procedure (Parameters: TEmbeddingBatchParams)
       begin
         Parameters.Requests(
           [
            TEmbeddingRequestParams.Create(
              procedure (var Params: TEmbeddingRequestParams)
              begin
                Params.Content(['This is an example']);
                Params.OutputDimensionality(20);
              end),

              TEmbeddingRequestParams.Create(
              procedure (var Params: TEmbeddingRequestParams)
              begin
                Params.Content(['Second example']);
                Params.OutputDimensionality(20);
              end)
           ]);
       end,
       // For displaying, add a TMemo on the form
       function : TAsynEmbeddings
       begin
         Result.Sender := Memo1; // Set a TMemo on the form
         Result.OnSuccess := Display;
       end);  
```
<br/>

## Generate text

The Gemini API enables [`text generation`](https://ai.google.dev/api/generate-content#method:-models.generatecontent) from a variety of inputs, including text, images, video, and audio. It can be used for a range of applications, such as:

- Creative writing
- Describing or interpreting media assets
- Text completion
- Summarizing open-form text
- Translating between languages
- Chatbots
- Your own unique use cases

In the following examples, we will use the procedures 'Display' to simplify the examples.
> [!TIP] 
>```Pascal
>  procedure Display(Sender: TObject; Chat: TChat); overload;
>  begin
>    var M := Sender as TMemo;
>    for var Item in Chat.Candidates do
>      begin
>        if Item.FinishReason = STOP then
>          for var SubItem in Item.Content.Parts do
>            begin
>              M.Lines.Text := M.Text + sLineBreak + SubItem.Text;
>            end;
>        M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>      end;
>  end;
>```
>
>```Pascal
>  procedure Display(Sender: TObject; Error: string); overload;
>  begin
>    var M := Sender as TMemo;
>    M.Lines.Text := M.Text + sLineBreak + Error;
>    M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>  end;  
>```

<br/>

### Generate text from text-only input

Synchronous mode
```Pascal
// uses Gemini, Gemini.Chat;

  var Chat := Gemini.Chat.Create('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Write a story about a magic backpack.')]);
    end);
  // For displaying, add a TMemo on the form
  try
    Display(Memo1, Chat);
  finally
    Chat.Free;
  end;
```

Asynchronous mode
```Pascal
// uses Gemini, Gemini.Chat;

  Gemini.Chat.AsynCreate('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Write a story about a magic backpack.')]);
    end,
    // For displaying, add a TMemo on the form
    function : TAsynChat
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

In this example, the prompt ("Write a story about a magic backpack") doesn’t include output examples, system instructions, or formatting details, making it a [`zero-shot`](https://ai.google.dev/gemini-api/docs/models/generative-models#zero-shot-prompts) approach. In some cases, using a [`one-shot`](https://ai.google.dev/gemini-api/docs/models/generative-models#one-shot-prompts) or [`few-shot`](https://ai.google.dev/gemini-api/docs/models/generative-models#few-shot-prompts) prompt could generate responses that better match user expectations. You might also consider adding [`system instructions`](https://ai.google.dev/gemini-api/docs/system-instructions?lang=rest) to guide the model in understanding the task or following specific guidelines.

<br/>

### Generate text from text-and-image input

The Gemini API supports multimodal inputs that combine text with media files. The example below demonstrates how to generate text from an input that includes both text and images.

```Pascal
  var Ref := 'D:\MyFolder\Images\Image.png';
  Gemini.Chat.AsynCreate('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Describe this image.', [Ref])]);
    end,
    // For displaying, add a TMemo on the form
    function : TAsynChat
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

In multimodal prompting, as with text-only prompting, various strategies and refinements can be applied. Based on the results from this example, you may want to add additional steps to the prompt or provide more specific instructions. For further information, [refer to strategies for file-based prompting](https://ai.google.dev/gemini-api/docs/file-prompting-strategies).

<br/>

### Generate a text stream

The model typically returns a response only after finishing the entire text generation process. Faster interactions can be achieved by enabling streaming, allowing partial results to be handled as they’re generated.

The example below demonstrates how to implement streaming using the [`streamGenerateContent`](https://ai.google.dev/api/generate-content#method:-models.streamgeneratecontent) method to generate text from a text-only input prompt.

Declare this method for displaying.

> [!TIP]
>```Pascal
>  procedure DisplayStream(Sender: TObject; const Buffer: string); overload;
>  begin
>  var M := Sender as TMemo;
>  for var i := 1 to Length(Buffer) do
>    begin
>      M.Lines.Text := M.Text + Buffer[i];
>      M.Lines.BeginUpdate;
>      try
>        Application.ProcessMessages;
>        M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>      finally
>        M.Lines.EndUpdate;
>      end;
>    end;
>  end;
>```
>
>```Pascal
>  procedure Display(Sender: TObject; Candidate: TChatCandidate); overload;
>  begin
>    for var Item in Candidate.Content.Parts do
>      if Assigned(Item) then
>        DisplayStream(Sender, Item.Text);
>  end;
>```
>
>```Pascal
>  procedure Display(Sender: TObject); overload;
>  begin
>    var M := Sender as TMemo;
>    M.Lines.Text := M.Text + sLineBreak;
>    M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>  end;
>

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Safety;

  Gemini.Chat.CreateStream('models/gemini-1.5-flash',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Write a story about a magic backpack.')]);
    end,
    // For displaying, add a TMemo on the form
    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    begin
      if IsDone then
        begin
          Display(Memo1);
        end;
      if Assigned(Chat) then
        begin
          for var Item in Chat.Candidates do
            begin
              if Item.FinishReason <> TFinishReason.SAFETY then
                begin
                  Display(Memo1, Item);
                end;
            end;
        end;
    end);
```

<br/>

### Build an interactive chat

You can leverage the Gemini API to create interactive chat experiences tailored for your users. By using the API’s chat feature, you can gather multiple rounds of questions and responses, enabling users to progress gradually toward their answers or receive assistance with complex, multi-part issues. This functionality is especially useful for applications that require continuous communication, such as chatbots, interactive learning tools, or customer support assistants.

Here’s an example of a basic chat implementation:

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Safety;

  Gemini.Chat.CreateStream('models/gemini-1.5-flash',
    procedure (Params: TChatParams)
    begin
      Params.Contents([
        TPayload.User('Hello'),
        TPayload.Assistant('Great to meet you. What would you like to know?'),
        TPayload.User('I have two dogs in my house. How many paws are in my house?')
      ]);
    end,
    // For displaying, add a TMemo on the form
    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    begin
      if IsDone then
        begin
          Display(Memo1);
        end;
      if Assigned(Chat) then
        begin
          for var Item in Chat.Candidates do
            begin
              if Item.FinishReason <> TFinishReason.SAFETY then
                begin
                  Display(Memo1, Item);
                end;
            end;
        end;
    end);  
```
<br/>

Here’s an example of a asynchronous chat implementation

Declare this method for displaying.
> [!TIP]
>```Pascal
>  procedure DisplayStream(Sender: TObject; Chat: TChat); overload;
>  begin
>    Display(Sender, Chat.Candidates[0]);
>  end;
>```

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Safety;

  Gemini.Chat.AsynCreateStream('models/gemini-1.5-flash',
    procedure (Params: TChatParams)
    begin
      Params.Contents([
        TPayload.User('Hello'),
        TPayload.Assistant('Great to meet you. What would you like to know?'),
        TPayload.User('I have two dogs in my house. How many paws are in my house?')
      ]);
    end,
    // For displaying, add a TMemo on the form    
    function : TAsynChatStream
    begin
      Result.Sender := Memo1;
      Result.OnProgress := DisplayStream;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

### Configure text generation

Each prompt sent to the model includes settings that control how responses are generated. You can adjust these settings using the `GenerationConfig`, which allows you to customize various [parameters](https://ai.google.dev/gemini-api/docs/models/generative-models#model-parameters). If no configurations are applied, the model will rely on default settings, which may differ depending on the model.
 
Here's an example demonstrating how to adjust several of these options.

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Safety;
  var GenerateContent := Gemini.Chat.Create('models/gemini-1.5-flash',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Write a story about a magic backpack.')]);

      {--- Specifies safety settings to block unsafe content. }
      Params.SafetySettings([
        TSafety.DangerousContent(BLOCK_ONLY_HIGH),
        TSafety.HateSpeech(BLOCK_MEDIUM_AND_ABOVE) ]);

      {--- Configures generation options for the model's outputs. }
      Params.GenerationConfig(
        procedure (var Params: TGenerationConfig)
        begin
          Params.StopSequences(['Title']);
          Params.Temperature(1.0);
          Params.MaxOutputTokens(800);
          Params.TopP(0.8);
          Params.TopK(10);
        end);
    end);
```

- The Gemini API offers adjustable safety settings that you can configure during the prototyping phase to decide if your application needs a stricter or more flexible safety setup. [Refer to the official documentation](https://ai.google.dev/gemini-api/docs/safety-settings).
See also the `Gemini.Safety.pas` unit and the `TSafety` record.

- The generation configuration allows for setting up the output production of a model. A complete description of the manageable parameters can be found at the following [`GitHub address`](https://github.com/google-gemini/generative-ai-python/blob/main/docs/api/google/generativeai/types/GenerationConfig.md). Internally, these parameters are defined within the `TGenerationConfig` class, which extends TJSONParam in the `Gemini.Chat.pas` unit.

<br/>

## Document processing

The Gemini API can handle and perform inference on uploaded PDF documents. Once a PDF is provided, the Gemini API can:

- Describe or answer questions about the content
- Summarize the content
- Generate extrapolations based on the content

This guide illustrates various methods for prompting the Gemini API using uploaded PDF documents. All outputs are text-only.

The `Gemini 1.5 Pro` and `1.5 Flash` models can handle up to **3,600 pages** per document. Supported file types for text data include:

- **PDF**: `application/pdf`
- **JavaScript**: `application/x-javascript, text/javascript`
- **Python**: `application/x-python, text/x-python`
- **TXT**: `text/plain`
- **HTML**: `text/html`
- **CSS**: `text/css`
- **Markdown**: `text/md`
- **CSV**: `text/csv`
- **XML**: `text/xml`
- **RTF**: `text/rtf`
Each page consists of **258 tokens**.

To achieve optimal results:

Ensure pages are oriented correctly before uploading. Use **high-quality images** without blurring. If uploading a single page, add the text prompt following the page.

There aren’t any strict pixel limits for documents beyond the model’s context capacity. Larger pages are scaled down to a maximum of **3072x3072 pixels** while keeping their aspect ratio, whereas smaller pages are scaled up to **768x768 pixels**. However, there’s no cost savings for using smaller images, other than reduced bandwidth, nor any performance boost for higher-resolution pages.

<br/>

### Upload a document and generate content

You can upload documents of any size by using the File API. Always rely on the File API whenever the combined size of the request—including files, text prompt, system instructions, and any other data—exceeds 20 MB.

> [!NOTE]
> You can use the File API to store files for up to 48 hours, with a storage limit of 20 GB per project and a maximum of 2 GB per file. During this time, files are accessible with your API key but are not downloadable through the API. The File API is free to use and available in all regions where the Gemini API operates.
>

Use the asynchronous methods `Gemini.Files.Upload` or `Gemini.Files.AsyncUpload` to upload a file with the File API. The following code uploads a document file and then uses it in a call to `models.generateContent`.

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Files;

  var FileUri := '';
  {--- Upload file and get its uri }
  var MyFile := Gemini.Files.UpLoad('Z:\my_folder\document\My_document.PDF', 'MyFile');
  try
    FileUri := MyFile.&File.URI;
    Display(Memo1, FileUri);
  finally
    MyFile.Free;
  end;
 
  {--- Generate text from a document using its URI. }
  Gemini.Chat.AsynCreate('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Summarize the document.', [FileUri])]);
    end,
    function : TAsynChat
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

### Get metadata for a file

You can confirm that the API successfully saved the uploaded file and retrieve its metadata by using `Gemini.Files.Retrieve` or `Gemini.Files.AsynRetrieve`. Only the name (and therefore, the URI) is unique.

```Pascal
// uses Gemini, Gemini.Files;

  var FileCode := 'files/{code}'  //e.g. 'files/yrsihy2hdyz7'
  var GetFile := Gemini.Files.Retrieve(FileCode);

  try
    Display(Memo1, GetFile.Name + ' : ' + GetFile.MimeType + ' : ' + GetFile.DisplayName);
  finally
    GetFile.Free;
  end;
```

<br/>

### List files

You can list all files uploaded using the File API and their URIs using `Gemini.Files.List` or `Gemini.Files.AsynList`.

Declare this method for displaying.
> [!TIP]
> ```Pascal
>   procedure Display(Sender: TObject; Files: TFiles); overload;
>   begin
>     var M := Sender as TMemo;
>     for var Item in Files.Files do
>       begin
>         M.Text := M.Text + sLineBreak + Item.Name + '   ' + Item.MimeType + '   ' + Item.Uri + sLineBreak;
>         M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>       end;
>     M.Text := M.Text + sLineBreak;
>     M.Perform(WM_VSCROLL, SB_BOTTOM, 0);
>   end;
> ```

```Pascal
// uses Gemini, Gemini.Files;

  Gemini.Files.AsynList(
     function : TAsynFiles
     begin
       Result.Sender := Memo1;
       Result.OnSuccess := Display;
       Result.OnError := Display;
     end);  
```

By default, a list of 10 elements will be retrieved. We can refine the process of obtaining the list of files using the following methods:

- `List(const PageSize: Integer; const PageToken: string);`
- `AsyncList(const PageSize: Integer; const PageToken: string; Callbacks: TFunc<TAsyncFiles>);`

These methods allow for more precise control over pagination and callback handling.

<br/>

### Delete files

Files uploaded with the File API are automatically removed **after 48 hours**. You can also delete them manually using either `Gemini.Files.Delete` or `Gemini.Files.Delete`.

Declare this method for displaying.
> [!TIP]
>```Pascal
>  procedure Display(Sender: TObject; Delete: TFileDelete); overload;
>  begin
>    Display(Sender, 'deleted');
>  end;
>```

```Pascal
// uses Gemini, Gemini.Files;

  var FileCode := 'files/{code}';  // e.g. files/yrsihy2hdyz7
  Gemini.Files.AsynDelete(FileCode,
    function : TAsynFileDelete
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## System instructions

When setting up an AI model, you can define guidelines for how it should respond, like assigning it a specific role `you are a rocket scientist` or instructing it on a particular tone `speak like a pirate`. These parameters are established by configuring the system instructions during the model's initialization.

System instructions let you shape the model’s behavior to fit specific needs and use cases. When set, they provide added context that guides the model to perform tasks in a more tailored way, adjusting its responses to meet particular guidelines across the entire interaction. These instructions apply across multiple exchanges with the model.

System instructions can be used for various purposes, such as:

- **Defining a persona or role** (e.g., setting the model to act as a customer service chatbot)
- **Specifying output format** (like Markdown, JSON, or YAML)
- **Setting output style and tone** (for example, adjusting verbosity, formality, or reading level)
- **Outlining goals or rules for the task** (for instance, delivering a code snippet without extra explanation)
- **Providing relevant context** (such as a knowledge cutoff date)

You can configure these instructions when initializing the model, and they will persist throughout the session, guiding the model’s responses. They form part of the model’s prompts and are governed by standard data use policies.

```Pascal
// uses Gemini, Gemini.Chat;

  Gemini.Chat.AsynCreateStream('models/gemini-1.5-flash-001',
    procedure (Params: TChatParams)
    begin
      Params.SystemInstruction('you are a rocket scientist');
      Params.Contents([ TPayload.Add('What are the differences between the Saturn 5 rocket and the Saturn 1 rocket?') ]);
    end,
    function : TAsynChatStream
    begin
      Result.Sender := Memo1;
      Result.OnProgress := DisplayStream;
      Result.OnError := Display;
    end);
```

> [!CAUTION]
> System instructions can guide the model to follow directions but don’t fully safeguard against jailbreaks or leaks. We recommend being cautious about including any sensitive information in these instructions.
>

See [More examples](https://ai.google.dev/gemini-api/docs/system-instructions?lang=rest#more-examples) on official site.

<br/>

## Vision

The Gemini API can perform inference on both images and videos provided to it. When given a single image, a sequence of images, or a video, Gemini can:

- Describe or respond to questions about the content,
- Provide a summary of the content,
- Make inferences based on the content.

All outputs are text-based only.

<br/>

### Prompting with images

The Gemini 1.5 Pro and 1.5 Flash models can support up to **3,600 image files**.

Supported image **MIME types** include the following formats:

- **PNG** - `image/png`
- **JPEG** - `image/jpeg`
- **WEBP** - `image/webp`
- **HEIC** - `image/heic`
- **HEIF** - `image/heif`

Each image counts as **258 tokens**.

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Files;

  var FileUri := '';
  {--- Upload file and get its uri }
  var MyFile := Gemini.Files.UpLoad('Z:\my_folder\image\my_image.png', 'MyFile');
  try
    FileUri := MyFile.&File.URI;
    Display(Memo1, FileUri);
  finally
    MyFile.Free;
  end;
 
  {--- Generate text from an image using its Uri. }
  Gemini.Chat.AsynCreate('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Describe this image.', [FileUri])]);
    end,
    function : TAsynChat
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

### Prompting with video

Gemini 1.5 Pro and Flash can process up to about one hour of video content.

Supported video formats include the following MIME types:

- `video/mp4`
- `video/mpeg`
- `video/mov`
- `video/avi`
- `video/x-flv`
- `video/mpg`
- `video/webm`
- `video/wmv`
- `video/3gpp`

Through the File API service, frames are extracted from videos at a rate of 1 frame per second (FPS), and audio is extracted at 1Kbps in single-channel mode, with timestamps marked every second. These rates may be adjusted in the future to enhance processing capabilities.

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Files;

  var FileUri := '';
  {--- Upload file and get its uri }
  var MyFile := Gemini.Files.UpLoad('Z:\my_folder\video\my_video.mp4', 'MyFile');
  try
    FileUri := MyFile.&File.URI;
    Display(Memo1, FileUri);
  finally
    MyFile.Free;
  end;
 
  {--- Generate text from a video using its Uri. }
  Gemini.Chat.AsynCreate('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Describe this video clip.', [FileUri])]);
    end,
    function : TAsynChat
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

## Audio

Gemini can handle audio prompts by:

- Describing, summarizing, or answering questions about audio content
- Providing a transcription of the audio
- Offering answers or a transcription for a specific part of the audio

> [!IMPORTANT]
> The Gemini API doesn't support audio output generation.
>

Gemini is compatible with the following audio format MIME types:

- **WAV**: `audio/wav`
- **MP3**: `audio/mp3`
- **AIFF**: `audio/aiff`
- **AAC**: `audio/aac`
- **OGG** `Vorbis: audio/ogg`
- **FLAC**: `audio/flac`

Here’s a rephrased version of the technical details:

Gemini processes audio by breaking it down into **25 tokens per second**, so one minute of audio translates to **1,500 tokens**. The system currently only interprets spoken English but can recognize non-verbal sounds like birdsong or sirens. For a single input, Gemini supports a maximum audio length of **9.5 hours**. While there’s no restriction on the number of files per prompt, their total length combined cannot exceed 9.5 hours. All audio is downsampled to a **16 Kbps data rate**, and if the audio has multiple channels, they’re merged into a single channel.

```Pascal
// uses Gemini, Gemini.Chat, Gemini.Files;

  var FileUri := '';
  {--- Upload file and get its uri }
  var MyFile := Gemini.Files.UpLoad('Z:\my_folder\sound\my_sound.wav', 'MyFile');
  try
    FileUri := MyFile.&File.URI;
    Display(Memo1, FileUri);
  finally
    MyFile.Free;
  end;
 
  {--- Generate text from an audio record using its Uri. }
  Gemini.Chat.AsynCreate('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Describe this audio clip.', [FileUri])]);
    end,
    function : TAsynChat
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

### Speech-to-text

The primary purpose of speech-to-text technology is to provide a text transcription of a voice recording, which is inherently temporary in nature. Therefore, uploading this audio file is unnecessary, as it will be used only once for transcription.

To perform the transcription, simply follow the example below, assuming the audio file has already been provided through a prior recording process.

```Pascal
// uses Gemini, Gemini.Chat;

  var SpeechSource := 'Z:\my_folder\sound\my_speech.wav';
  {--- Transcribe the audio recording into a text. }
  Gemini.Chat.AsynCreate('models/gemini-1.5-pro',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('Transcribe the audio recording into English.', [SpeechSource])]);
    end,
    function : TAsynChat
    begin
      Result.Sender := Memo1;
      Result.OnSuccess := Display;
      Result.OnError := Display;
    end);
```

<br/>

### Text-to-speech

As stated above, the Gemini API doesn't support audio output generation, and the Gemini APIs do not provide any method to transcribe text into an audio file. On the other hand, Google Cloud offers an alternative, which you can find [here](https://cloud.google.com/text-to-speech/?utm_source=google&utm_medium=cpc&utm_campaign=emea-gb-all-en-dr-bkws-all-all-trial-%7Bmatchtype%7D-gcp-1707574&utm_content=text-ad-none-any-DEV_%7Bdevice%7D-CRE_%7Bcreative%7D-ADGP_%7B_dsadgroup%7D-KWID_%7B_dstrackerid%7D-%7Btargetid%7D-userloc_%7Bloc_physical_ms%7D&utm_term=KW_%7Bkeyword%7D-NET_%7Bnetwork%7D-PLAC_%7Bplacement%7D&%7B_dsmrktparam%7D%7Bignore%7D&%7B_dsmrktparam%7D&gclsrc=aw.ds&gad_source=1&gclid=Cj0KCQjw1Yy5BhD-ARIsAI0RbXZf2NNU_LQ_rYqNEeTpm3Q0QPI83Jap8PAIl6ZFzulFAD3cY-z487oaAvk0EALw_wcB&gclsrc=aw.ds&hl=en).

<br/>

## Long context

See the [official documentation](https://ai.google.dev/gemini-api/docs/long-context).

<br/>

## Code execution

The Gemini API’s code execution feature allows the model to generate and execute Python code, enabling it to learn iteratively from the results until it reaches a final output. This capability can be applied to build applications that benefit from code-based reasoning and produce text-based results. For instance, code execution could be utilized in applications designed for solving equations or text processing.

Code execution is available in both AI Studio and the Gemini API. In AI Studio, it can be enabled within Advanced settings. With the Gemini API, code execution functions as a tool similar to function calling, allowing the model to decide when to use it.

> [!NOTE]
> The code execution environment has the NumPy and SymPy libraries available. You aren’t able to install additional libraries.
>
<br/>

Declare this method for displaying.
> [!TIP]
> ```Pascal
>  procedure DisplayCode(Sender: TObject; Chat: TChat); 
>  begin
>  var M := Sender as TMemo;
>  for var Candidate in Chat.Candidates do
>    begin
>      for var Part in Candidate.Content.Parts do
>        begin
>          if Assigned(Part.ExecutableCode) then
>            DisplayStream(Sender, Part.ExecutableCode.Code)
>          else
>            DisplayStream(Sender, Part.Text);
>        end;
>    end;
>  end;
> ```

```Pascal
// uses Gemini, Gemini.Chat;

  Gemini.Chat.ASynCreateStream('models/gemini-1.5-flash',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add('What is the sum of the first 50 prime numbers? Generate and run code for the calculation, and make sure you get all 50.')]);
      Params.Tools(True);  // Enable code execution
    end,
    function : TAsynChatStream
    begin
      Result.Sender := Memo1;
      Result.OnProgress := DisplayCode;
      Result.OnError := Display;
    end);
```

Code execution and function calling are similar features with distinct use cases:

Code execution allows the model to run code directly in the API backend within a controlled, isolated environment. Function calling enables running functions that the model requests in a separate, customizable environment of your choice.

Generally, code execution is preferable if it meets your requirements, as it’s simpler to enable and completes within a single GenerateContent request, resulting in a single charge. In contrast, function calling requires an additional GenerateContent request to return each function’s output, leading to multiple charges.

Typically, use function calling if you need to run custom functions locally. For cases where the API should generate and execute Python code and deliver results, code execution is often the best fit.

<br/>

## Function calling

The Gemini API’s function calling feature allows you to define custom functions that the model can suggest, providing structured output that includes the function name and recommended arguments. While the model doesn’t execute these functions directly, it outputs suggestions, allowing you to trigger an external API call with those parameters. This approach enables you to bring real-time data from external sources, such as databases, CRM systems, or document repositories, into the conversation, allowing the model to deliver more contextually relevant and actionable responses.

Please refer to the [official documentation](https://ai.google.dev/gemini-api/docs/function-calling#how_it_works) for more information.

```Pascal
// uses Gemini, Gemini.Chat, Gemini.tools, Gemini.Functions.Core, Gemini.Functions.Example;

  var Weather := TWeatherReportFunction.CreateInstance;

  var Chat := Gemini.Chat.Create('models/gemini-1.5-flash',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.User('What is the weather like in Paris?')]);
      Params.Tools([Weather]);
      Params.ToolConfig(AUTO);
    end);
  try
    for var Item in Chat.Candidates do
      begin
        for var SubItem in Item.Content.Parts do
          begin
            if Assigned(SubItem.FunctionCall) then
              CallFunction(SubItem.FunctionCall, Weather) else
              DisplayStream(Memo1, SubItem.Text);
          end;
      end;
  finally
    Chat.Free;
  end;

...

  procedure TForm.CallFunction(const Value: TFunctionCall; Func: IFunctionCore);
  begin
    var ArgResult := Func.Execute(Value.Args);
    Gemini.Chat.ASynCreateStream('models/gemini-1.5-flash',
      procedure (Params: TChatParams)
      begin
        Params.Contents([TPayload.Add(ArgResult)]);
      end,
      function : TAsynChatStream
      begin
        Result.Sender := Memo1;
        Result.OnProgress := DisplayStream;
        Result.OnError := Display;
      end);
  end;
```

<br/>

# Contributing

Pull requests are welcome. If you're planning to make a major change, please open an issue first to discuss your proposed changes.

# License

This project is licensed under the [MIT](https://choosealicense.com/licenses/mit/) License.