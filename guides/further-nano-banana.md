# Nano Banana (Image generation)

**Nano Banana** refers to the set of image generation capabilities natively integrated into the Gemini models. This designation currently encompasses two distinct architectures accessible through the Gemini API.

- The first model, **Gemini 2.5 Flash Image** (gemini-2.5-flash-image), prioritizes fast execution and reduced computational cost. It is suited to use cases requiring high request throughput and minimal latency, at the expense of more advanced reasoning capabilities.

- The second model, **Gemini 3 Pro Image Preview** (gemini-3-pro-image-preview), emphasizes visual fidelity and the ability to satisfy complex constraints. It incorporates explicit reasoning mechanisms (*"thinking"*) intended to improve semantic coherence and rendering accuracy, particularly for text generation and structured compositions.

<br>

- [Image Creation](#image-creation)
- [Image Editing](#image-editing)
- [Official vendor documentation](https://ai.google.dev/gemini-api/docs/image-generation)

___

<br>

## Image Creation

Image generation is performed via the `Client.Chat.Create` (or asynchronous method `Client.Chat.AsyncAwaitCreate`) method, with the specific model selected by specifying the corresponding version identifier.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers;

  var Model := 'gemini-3-pro-image-preview';
  var Prompt := 'Create a picture of a futuristic banana with neon lights in a cyberpunk city.';
  var OutputFileName := 'sample.png';

  //JSON Payload
  var Payload: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
            .Addtext(Prompt)
         );
    end;

  //Image saveToFile
  var saveToFile: TProc<TChat> :=
    procedure (Value: TChat)
    begin
      for var Item in Value.Candidates do
       if Item.FinishReason = TFinishReason.STOP then
         for var SubItem in Item.Content.Parts do
           begin
             if Assigned(SubItem.InlineData) then
               begin
                 TMediaCodec.DecodeBase64ToFile(SubItem.InlineData.Data, OutputFileName);
                 Memo1.Lines.Text := Memo1.Text + #10 + Format('Image saved as %s', [OutputFileName]);
               end;
           end;
    end;


  //Asynchronous Example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Payload);

  promise
    .&Then(
      procedure (Value: TChat)
      begin
        saveToFile(Value);
        saveToFile := nil;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous Example
//  var Value := Client.Chat.Create(Model, Payload);
//
//  try
//    saveToFile(Value);
//    saveToFile := nil;
//  finally
//    Value.Free;
//  end;
```

<br>

## Image Editing

An input image may be provided and combined with textual prompts to add, remove, or modify visual elements, alter stylistic attributes, or adjust color properties.

The following example demonstrates the submission of images encoded in base64 format.

#### JSON expected
```json
{
    "contents": [{
      "parts":[
          {"text": "I want the banana to be smaller and suspended in the air above the city."},
          {
            "inline_data": {
              "mime_type": "image/jpeg",
              "data": "<BASE64_IMAGE_DATA>"
            }
          }
      ]
    }]
}
```


#### JSON Payload creating and running
```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers;

  var Model := 'gemini-3-pro-image-preview';
  var Prompt := 'I want the banana to be smaller and suspended in the air above the city.';
  var ImageInFileName := 'sample.png';
  var ImageOutFileName := 'sampleModified.png';
  var Base64 := TMediaCodec.EncodeBase64(ImageInFileName);
  var MimeType := TMediaCodec.GetMimeType(ImageInFileName);

  //JSON Payload
  var Payload: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
            .AddParts( Generation.Parts
              .AddInlineData(Base64, MimeType)
              .Addtext(Prompt)
            )
         );
    end;

  //Image saveToFile 
  var saveToFile: TProc<TChat> :=
    procedure (Value: TChat)
    begin
      for var Item in Value.Candidates do
       if Item.FinishReason = TFinishReason.STOP then
         for var SubItem in Item.Content.Parts do
           begin
             if Assigned(SubItem.InlineData) then
               begin
                 TMediaCodec.DecodeBase64ToFile(SubItem.InlineData.Data, ImageOutFileName);
                 Memo1.Lines.Text := Memo1.Text + #10 + Format('Image saved as %s', [ImageOutFileName]);
               end;
           end;
    end;


  //Asynchronous Example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Payload);

  promise
    .&Then(
      procedure (Value: TChat)
      begin
        saveToFile(Value);
        saveToFile := nil;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous Example
//  var Value := Client.Chat.Create(Model, Payload);
//
//  try
//    saveToFile(Value);
//    saveToFile := nil;
//  finally
//    Value.Free;
//  end;
```
