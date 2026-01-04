# Image generation and editing

> [!NOTE]
> This document focuses on **payload construction** for image-related use cases.
> The **model selection** (e.g., `gemini-*-image` vs `gemini-*`) and the **execution mode**
> (non-streamed vs SSE) are handled at the request/transport layer and are documented elsewhere.
>
> The examples below assume you already know how to execute a generation and simply want to build
> the correct JSON payload for image output and image editing.

- [Image generation](#image-generation)
- [Multi-turn image editing](#multi-turn-image-editing)

___

<br>

# Image generation

> [!IMPORTANT]
> This example configures **image output**. Depending on the model endpoint you call, the response may contain
> image data as `inline_data` (base64) parts. The payload shown here focuses on the request-side fields
> (`generationConfig.imageConfig`) and does not prescribe how you parse the response.

#### Expected JSON payload
```json
"contents": [{
    "parts": [
      { "text": "Create a picture of a nano banana dish in a fancy restaurant with a Gemini theme" }
    ]
  }],
  "generationConfig": {
    "imageConfig": { "aspectRatio": "16:9" }
  }
```

> [!TIP]
> If you also want textual output alongside the generated image, use `responseModalities` (see the editing examples below)
> and parse multiple parts in the response.

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Prompt := 'Create a picture of a nano banana dish in a fancy restaurant with a Gemini theme';

  with Generation, Generation.Config do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        )
        .GenerationConfig( AddConfig
            .ImageConfig( AddImageConfig
                .AspectRatio('16:9')
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## Multi-turn image editing
You can continue generating and editing images in a conversational manner.
Interactions may rely on chat mode or multi-turn conversations to progressively refine or transform images.

The following example illustrates a request used to generate an infographic.

<br>

> [!NOTE]
> In multi-turn image workflows, `responseModalities` is the key switch:
> it tells the API to return both **text** and **image** parts in the response.
> This makes the conversation history reusable for subsequent editing steps.

### Step 1

___

#### Expected JSON payload
```json
"contents": [{
      "role": "user",
      "parts": [
        {"text": "Create a vibrant infographic that explains photosynthesis as if it were a recipe for a plants favorite food. Show the \"ingredients\" (sunlight, water, CO2) and the \"finished dish\" (sugar/energy). The style should be like a page from a colorful kids cookbook, suitable for a 4th grader."}
      ]
    }],
    "generationConfig": {
      "responseModalities": ["TEXT", "IMAGE"]
    }
```

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Prompt :=
         '''
         Create a vibrant infographic that explains photosynthesis as if it were a recipe for a plants
         favorite food. Show the "ingredients" (sunlight, water, CO2) and the "finished dish"
         (sugar/energy). The style should be like a page from a colorful kids cookbook, suitable for a
         4th grader.
         ''';

  with Generation do
      Params
        .Contents( Contents
            .User( Prompt )
        )
        .GenerationConfig( AddConfig
            .ResponseModalities([TModalityType.TEXT, TModalityType.IMAGE])
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

> [!NOTE]
> The `google_search` tool is optional and depends on your use case.
> It can help grounding facts or finding references, but the **core editing mechanism**
> remains the image-in-history + constrained edit prompt.

### Step 2
___

You can then use the same conversation to change the language of the graphic and switch it to Spanish.

> [!IMPORTANT]
> Step 2 reuses the **previous image output** as an input of the next turn.
> The image is placed in a `model` message, and the next `user` message describes the edit.
> This pattern is what makes iterative editing possible without re-uploading a separate asset store.

#### Expected JSON payload
```json
"contents": [
      {
        "role": "user",
        "parts": [{"text": "Create a vibrant infographic that explains photosynthesis..."}]
      },
      {
        "role": "model",
        "parts": [{"inline_data": {"mime_type": "image/png", "data": "<PREVIOUS_IMAGE_DATA>"}}]
      },
      {
        "role": "user",
        "parts": [{"text": "Update this infographic to be in Spanish. Do not change any other elements of the image."}]
      }
    ],
    "tools": [{"google_search": {}}],
    "generationConfig": {
      "responseModalities": ["TEXT", "IMAGE"],
      "imageConfig": {
        "aspectRatio": "16:9",
        "imageSize": "2K"
      }
    }
```

> [!NOTE]
> Keep the editing instruction as **constrained** as possible ("Do not change any other elements...").
> This reduces unintended changes when the model applies the transformation.


#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Prompt := 'Create a vibrant infographic that explains ...';
  var Prompt2 := 'Update this infographic to be in Spanish. Do not change any other elements of the image.';

  var Base64 := 'previous image';  //TMediaCodec.EncodeBase64('previous image');
  var MimeType := 'image/png';     //TMediaCodec.GetMimeType('previous image');

  with Generation do 
      Params
        .Contents( Contents
            .User( Prompt )
            .Model( Parts
                .AddInlineData(Base64, MimeType)
            )
            .User(Prompt2)
        )
        .Tools( Tools
            .AddGoogleSearch
         )
        .GenerationConfig( AddConfig
            .ResponseModalities([TModalityType.TEXT, TModalityType.IMAGE])
            .ImageConfig( Config.AddImageConfig
                .AspectRatio('16:9')
                .ImageSize('2K')
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

> [!NOTE]
> Response parsing for image workflows usually requires iterating over `content.parts` and handling:
> - `text` parts (human-readable descriptions / confirmations)
> - `inline_data` parts (base64-encoded PNG/JPEG images)
>
> The builder examples here focus on request construction; response handling is documented in the execution chapters.


