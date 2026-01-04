# Building JSON Payloads for the `Generation` Endpoint

- [Text Generation](#text-generation)
- [System instructions and other configurations](#system-instructions-and-other-configurations)
- [Reasoning with Gemini (Thinking)](#reasoning-with-gemini-thinking)
- [Media parts (multimodal)](#media-parts-multimodal)
- [Multimodal inputs](#multimodal-inputs)
- [Multi-turn conversations (chat)](#multi-turn-conversations-chat)
- [Image generation and editing](#image-generation-and-editing)
- [Tools](#tools)

___

<br>

This section describes the mechanism used to build JSON payloads submitted to a model through the Generation endpoint.

This mechanism is provided by the `Gemini.Helpers` unit, which must be added to the uses clause in order to be available.

It is based on a main record named `TGeneration`. This record provides:
- methods for constructing and decorating each node of the JSON document;
- a fluent mechanism for building JSON arrays, relying on the implementation available in the `Gemini.API.arrayBuilder` unit.

In the following examples, we first present the JSON structure expected by the API, followed by its equivalent construction using `TGeneration`.

<br>

## Text Generation
#### Expected JSON payload
```json
"contents": [
  {
    "parts": [
      {
        "text": "How does AI work?"
      }
    ]
  }
]
```

#### Construction using `TGeneration` helper
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...
  
  var Prompt := 'How does AI work?';
  var Params := TChatParams.Create;

  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

### Alternative: Using a Raw JSON String

It is also possible to provide the contents directly as a JSON string corresponding to a fragment of the expected payload.

Additionally, starting with Delphi 12 and later, multiline string literals can be used to embed JSON content in a clear and readable way:

```pascal
  var Params := TChatParams.Create
        .Contents(
          '''
          [
            {
              "parts": [
                {
                  "text": "How does AI work?"
                }
              ]
            }
          ]

          '''
        );
```
This approach may be useful for quick experiments, prototyping, or when working with externally generated JSON.
However, the `TGeneration` helper remains the recommended solution for type safety, composability, and long-term maintainability of request construction.

<br>

## System instructions and other configurations

You can guide the behavior of Gemini models with system instructions. To do so, pass a GenerateContentConfig object.

#### Expected JSON payload
```json
"system_instruction": {
      "parts": [
        {
          "text": "You are a cat. Your name is Neko."
        }
      ]
    },
    "contents": [
      {
        "parts": [
          {
            "text": "Hello there"
          }
        ]
      }
    ]
```

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Instructions := 'You are a cat. Your name is Neko.';
  var Prompt := 'Hello there';

  with Generation do
      Params
        .SystemInstruction(Instructions)
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

Other configuration

#### Expected JSON payload
```json
"contents": [
      {
        "parts": [
          {
            "text": "Explain how AI works"
          }
        ]
      }
    ],
    "generationConfig": {
      "stopSequences": [
        "Title"
      ],
      "temperature": 1.0,
      "topP": 0.8,
      "topK": 10
    }
```

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Prompt := 'How does AI work?';

  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        )
        .GenerationConfig( AddConfig
            .StopSequences(['Title'])
            .Temperature(1.0)
            .TopP(0.8)
            .TopK(10)
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## Reasoning with Gemini (Thinking)
### ThinkingBudget
___

#### Expected JSON payload
```json
"contents": [
  {
    "parts": [
      {
        "text": "How does AI work?"
      }
    ]
  }
],
"generationConfig": {
  "thinkingConfig": {
    "thinkingBudget": 0
  }
}
```

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Prompt := 'How does AI work?';

  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        )
        .GenerationConfig( AddConfig
            .ThinkingConfig( Config.AddThinkingConfig
                .ThinkingBudget(0)
            )
        );

  Memo1.Text := Params.ToFormat(True);
```
>[!NOTE]
>This example demonstrates how factoring `TGeneration` into a local variable can further simplify the construction of complex JSON requests and improve overall readability.

<br>

### ThinkingLevel

___

>[!IMPORTANT]
>`ThinkingLevel` and `ThinkingBudget` cannot be used together in the same request.

#### Expected JSON payload
```json
  "contents": [{
    "parts": [{ "text": "How does AI work?" }]
  }],
  "generationConfig": {
    "thinkingConfig": {
      "thinkingLevel": "low"
    }
  }
```

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Prompt := 'How does AI work?';

  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        )
        .GenerationConfig( AddConfig
            .ThinkingConfig( Config.AddThinkingConfig
                .ThinkingLevel('low')
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## [Media parts (multimodal)](generations-json-payload-media-builder.md#media-parts-multimodal)

- [Inline media (inline_data)](generations-json-payload-media-builder.md#inline-media-inline_data)
- [File-based media (file_data / file_uri)](generations-json-payload-media-builder.md#file-based-media-file_data--file_uri)
- [Multiple media items in one request](generations-json-payload-media-builder.md#multiple-media-items-in-one-request)

<br>

## Multimodal inputs
The Gemini API supports multimodal inputs, allowing you to combine text with media files. The following example demonstrates providing an image:

#### Expected JSON payload
```json
"contents": [
    {
      "parts": [
        {
          "text": "Tell me about this instrument"
        },
        {
          "inline_data": {
            "mime_type": "image/jpeg",
            "data": "$(cat "$TEMP_B64")"
          }
        }
      ]
    }
  ]
```

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;

  var FileLocation := 'Z:\File\my_file.png';
  var Base64 := TMediaCodec.EncodeBase64(FileLocation);
  var MimeType := TMediaCodec.GetMimeType(FileLocation);
  var Prompt := 'Tell me about this instrument';

  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
                .AddInlineData(Base64, MimeType)
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## Multi-turn conversations (chat)
#### Expected JSON payload
```json
"contents": [
      {
        "role": "user",
        "parts": [
          {
            "text": "Hello"
          }
        ]
      },
      {
        "role": "model",
        "parts": [
          {
            "text": "Great to meet you. What would you like to know?"
          }
        ]
      },
      {
        "role": "user",
        "parts": [
          {
            "text": "I have two dogs in my house. How many paws are in my house?"
          }
        ]
      }
    ]
```

#### Construction using `TGeneration` helper.
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;

  with Generation do
      Params
        .Contents( Contents
            .User( Parts
                .AddText('Hello')
            )
            .Model( parts
                .AddText('Great to meet you. What would you like to know?')
            )
            .User( Parts
                .AddText('I have two dogs in my house. How many paws are in my house?')
            )
        );

  Memo1.Text := Params.ToFormat(True);
```

With this approach, it is possible to attach functions, PDF documents, or media content to each request.

<br>

When the multi-turn conversation consists exclusively of text:

```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;

  with Generation do
      Params
        .Contents( Contents
            .User( 'Hello')
            .Model('Great to meet you. What would you like to know?')
            .User( 'I have two dogs in my house. How many paws are in my house?')
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## [Image generation and editing](generations-json-payload-image-builder.md#image-generation-and-editing)

- [Image generation](generations-json-payload-image-builder.md#image-generation)
- [Multi-turn image editing](generations-json-payload-image-builder.md#multi-turn-image-editing)

<br>

## [Tools](generations-json-payload-tools-builder.md#tools)

- [Google Search](generations-json-payload-tools-builder.md#google-search)
- [Google Maps grounding](generations-json-payload-tools-builder.md#google-maps-grounding)
- [Code execution](generations-json-payload-tools-builder.md#code-execution)
