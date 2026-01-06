# Video with Veo

**Veo** supports the generation of short videos with synchronized audio from *textual, image-based, or video-based inputs*, with an emphasis on photorealistic rendering.

Its purpose is to programmatically create, extend, or interpolate cinematic video sequences, offering strong creative control over style, camera, and sound.

#### Key constraints
- **Limited duration:** 4, 6, or 8 seconds (8s required for extension, interpolation, and reference images).
- **Resolution:** 720p or 1080p (1080p only for 8-second videos).
- **Asynchronous only:** every request returns an operation that must be polled.
- **Extension limits:** only Veo-generated videos, up to ~148s total after multiple extensions.
- **Regional restrictions:** strong limits on person generation (EU / UK / CH / MENA).
- **Short retention:** videos are deleted after 2 days if not downloaded.
- **Automatic watermarking:** SynthID is embedded and cannot be disabled.

<br>

- [Video Creation](#video-creation)
- [Get Operation](#get-operation)
- [Video Download](#video-download)
- [Asynchronous Video Creation and Retrieval](#asynchronous-video-creation-and-retrieval)
- [Critical warnings and recommendations](#critical-warnings-and-recommendations)

___

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## Video Creation
Generates a video from:
- a text prompt (text-to-video)
- an initial image (image-to-video)
- an existing video (extension)
- optionally using reference images, first frame, last frame, or a negativePrompt

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Model := 'veo-3.1-generate-preview';
  var Prompt := 'A close up of two people staring at a cryptic drawing on a wall, torchlight flickering. A man murmurs, This must be it. That''s the secret code. The woman looks at him and whispering excitedly, What did you find?';

  //JSON Payload
  var Payload: TProc<TVideoParams> :=
    procedure (Params: TVideoParams)
    begin
      Params
        .Instances( TVideoInstance.Create
            .AddItem( TVideoInstanceParams.Create
              .Prompt(Prompt)
             )
         )
        .Parameters( TVideoParameters.Create
             .DurationSeconds(8)
             .AspectRatio('16:9')
             .NegativePrompt('people, animals')
             .Resolution('1080p')
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous example
  var Promise := Client.Video.AsyncAwaitCreate(Model, Payload);

  Promise
    .&Then(
      procedure (Value: TVideoOpereration)
      begin
        Display(TutorialHub, Value.Name);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Video.Create(Model,  Payload);
//
//  try
//    Edit1.Text := Value.Name;
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

>[!NOTE]
>At this stage, the identifier of the video creation operation is retrieved. This identifier is used to track the progress of the generation process.
> e.g. models/veo-3.1-generate-preview/operations/t8iue9eni46i  

<br>

## Get Operation
Explicit polling of an asynchronous operation.
Used to check whether video generation is complete (`done = true`) and to access the final result.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Operation := 'models/veo-3.1-generate-preview/operations/t8iue9eni46i';

  //Asynchronous example
  var Promise := Client.Video.AsyncAwaitGetOperation(Operation);

  Promise
    .&Then(
      procedure (Value: TVideoOpereration)
      begin
        Display(TutorialHub, Value);
        if Value.Done then
          ShowMessage(Value.Uri[0]);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Video.GetOperation(Operation);
//
//  try
//    Display(TutorialHub, Value);
//    if Value.Done then
//      ShowMessage(Value.Uri[0]);
//  finally
//    Value.Free;
//  end;
```

>[!IMPORTANT]
>As soon as the JSON returns `Done = True`, the `uri` used to load the generated video can be retrieved.
>- e.g. https://generativelanguage.googleapis.com/v1beta/files/0gc6o1faxwse

<br>

## Video Download

Downloads a generated asset (video or image).
Essential because generated videos are ephemeral on the server side.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Uri := 'https://generativelanguage.googleapis.com/v1beta/files/0gc6o1faxwse';
  var OutFileName := 'dialogue_example8.mp4';

  //Asynchronous Example
  var Promise := Client.Video.AsyncAwaitVideoDownload(Uri);

  Promise
    .&Then(
      procedure (Value: TVideo)
      begin
        Value.SaveToFile(OutFileName);
        Display(TutorialHub, 'video downloaded');
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous Example
//  var Value := Client.Video.VideoDownload(Uri);
//
//  try
//    Value.SaveToFile(OutFileName);
//    Display(TutorialHub, 'video downloaded');
//  finally
//    Value.Free
//  end;
```

<br>

## Asynchronous Video Creation and Retrieval

This asynchronous method combines the create and retrieve calls until the uri is obtained, then handles the download and persistence of the generated video file.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var FileName := 'dialogue_example.mp4';
  var Model := 'models/veo-3.1-generate-preview';
  var Prompt := 'A close up of two people staring at a cryptic drawing on a wall, torchlight flickering. A man murmurs, This must be it. That''s the secret code. The woman looks at him and whispering excitedly, What did you find?';

  // JSON Payload
  var Payload: TProc<TVideoParams> :=
    procedure (Params: TVideoParams)
    begin
      Params
        .Instances(
          TVideoInstance.Create
            .AddItem(TVideoInstanceParams.Create
              .Prompt(Prompt)
             )
         )
        .Parameters(
           TVideoParameters.Create
             .DurationSeconds(8)
             .AspectRatio('16:9')
             .NegativePrompt('people, animals')
             .Resolution('720p')
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous
  var Promise := Client.Video.AsyncAwaitGenerateToFile(Model, Payload, FileName);

  Promise
  .&Then(
    procedure(VideoStatus: TVideoStatus)
    begin
      Display(TutorialHub, 'Video saved to: ' + FileName);
      Display(TutorialHub, 'Operation: ' + VideoStatus.OperationName);
      Display(TutorialHub, 'Download URI: ' + VideoStatus.Uri[0]);
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Display(TutorialHub, E.Message);
    end);
```

<br>

## Critical warnings and recommendations
- Audio is fragile: some generations fail solely due to audio issues.
- No guaranteed determinism: the seed parameter only slightly improves consistency.
- Voice cannot be extended if it is absent from the final second of a video.
- Hard safety blocking: some prompts are silently rejected by Gemini safety filters.
- Aspect-ratio coupling: certain features (e.g. reference images) enforce 16:9 only.