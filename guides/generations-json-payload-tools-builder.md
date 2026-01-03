# Tools

> [!NOTE]
> This document focuses exclusively on **payload construction** for tool-enabled generations.
> It does **not** cover:
> - model selection,
> - execution mode (non-streamed vs SSE),
> - response consumption or tool result handling.
>
> The examples below demonstrate how tools are **declared and configured** in the JSON payload.
> Execution flow and response parsing are documented in the generation execution chapters.

<br>

- [Google Search](#google-search)
- [Google Maps grounding](#google-maps-grounding)
- [Google URL](#google-url)
- [Code execution](#code-execution)
- [Tools vs Function calling](#tools-vs-Function-calling)
- [Response Parsing](#response-parsing)

___

> [!IMPORTANT]
> Tools are part of the **generation payload**, not the execution layer.
> Declaring a tool does not automatically invoke it; it only makes the tool available to the model during generation.

<br>

## Google Search

`google_search` is the simplest grounding tool for the `Generation` endpoint.
It is declared in the payload and becomes available to the model during generation.
Declaring the tool does not guarantee it will be used.

> [!TIP]
> Keep the prompt explicit about what should be grounded (e.g., “today”, “latest”, “from official sources”)
> if you want the model to rely on search rather than prior knowledge.

#### Expected JSON payload
```json
"contents": [{
    "parts": [
      {"text": "What are the news stories of the day?"}
    ]
  }],
  "tools": [
      { "google_search": {} }
    ]
```

> [!NOTE]
> This section demonstrates **payload construction only**. Execution and response handling are covered elsewhere.

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...
 
  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);
  var Prompt := 'What are the news stories of the day?';

  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        )
        .Tools( Tools
            .AddGoogleSearch()
         );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## Google Maps grounding
Grounding with Google Maps is particularly well suited for applications that require accurate, up-to-date, and location-specific information.
It enhances the user experience by delivering relevant and personalized content, leveraging the extensive Google Maps database, which includes more than 250 million places worldwide.

### Example 1:

> [!NOTE]
> The Google Maps tool allows the model to query geographic data during generation.
> From a payload perspective, this example illustrates **tool declaration only**.
> The decision to call the tool and how its results are used remains entirely model-driven.

#### Expected JSON payload
```json
"contents": [{
    "parts": [
      {"text": "Restaurants near Times Square."}
    ]
  }],
  "tools":  { "googleMaps": {} }
}
```

> [!TIP]
> Tools can be combined with system instructions to constrain how and when
> the model should rely on external data.

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);

  with Generation do
      Params
        .Contents( Contents
            .AddText('Restaurants near Times Square.')
        )
        .Tools( Tools
            .AddGoogleMaps
         );

  Memo1.Text := Params.ToFormat(True);
``` 

<br>

### Example 2:
The `googleMaps` tool can also accept a **boolean** parameter named `enableWidget`, which is used to control whether the `googleMapsWidgetContextToken` field is returned in the response.
#### Expected JSON payload
```json
{
"contents": [{
    "parts": [
      {"text": "Restaurants near Times Square."}
    ]
  }],
  "tools":  { "googleMaps": { "enableWidget": true } }
}
```

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);

  with Generation do
      Params
        .Contents( Contents
            .AddText('Restaurants near Times Square.')
        )
        .Tools( Tools
            .AddGoogleMaps( Tools.GoogleMaps
                .EnableWidget(True)
            )
         );

  Memo1.Text := Params.ToFormat(True);
```
>[!NOTE]
>This mechanism can be used to display a contextual Places widget.

<br>

### Example 3:
#### Expected JSON payload
```json
"contents": [{
    "parts": [
      {"text": "Restaurants near here."}
    ]
  }],
  "tools":  { "googleMaps": {} },
  "toolConfig":  {
    "retrievalConfig": {
      "latLng": {
        "latitude": 40.758896,
        "longitude": -73.985130
      }
    }
  }
```

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);
  var ToolConfig := Generation.ToolConfig;

  with Generation, ToolConfig do
      Params
        .Contents( Contents
            .AddText('Restaurants near here.')
        )
        .Tools( Tools
            .AddGoogleMaps
        )
        .ToolConfig( AddToolConfig
           .RetrievalConfig( AddRetrievalConfig
              .LatLng(
                  AddLatLng(40.758896, -73.985130)
              )
           )
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## Google URL

> [!NOTE]
> The `urlContext` tool allows the model to retrieve and analyze the content
> of one or more URLs provided implicitly in the prompt.
> At the payload level, this section illustrates **tool declaration only**.

#### Expected JSON payload

> [!IMPORTANT]
> URLs are not passed as structured parameters.
> They must be included directly in the prompt text so the model can decide
> which resources to retrieve using the `urlContext` tool.

```json
 "contents": [
        {
            "parts": [
                {
                    "text": "Compare the ingredients and cooking times from the recipes at https:\/\/www.foodnetwork.com\/recipes\/ina-garten\/perfect-roast-chicken-recipe-1940592 and https:\/\/www.allrecipes.com\/recipe\/21151\/simple-whole-roast-chicken\/"
                }
            ]
        }
    ],
    "tools": [
        {
            "urlContext": {
            }
        }
    ]
```

> [!NOTE]
> Declaring the `urlContext` tool makes URL retrieval available to the model,
> but does not guarantee that all referenced URLs will be fetched or used.

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);
  var Prompt := 'Compare the ingredients and cooking times from the recipes at https://www.foodnetwork.com/recipes/ina-garten/perfect-roast-chicken-recipe-1940592 and https://www.allrecipes.com/recipe/21151/simple-whole-roast-chicken/';

  with Generation do
      Params
        .Contents( Contents
            .AddParts( Parts
                .AddText(Prompt)
            )
        )
        .Tools( Tools
            .AddUrlContext()
         );

  Memo1.Text := Params.ToFormat(True);
```

> [!TIP]
> Keep the prompt explicit about the comparison or analysis you expect
> to help the model focus on relevant sections of the referenced URLs.

<br>

## Code execution

You can also use code execution as part of a chat.

> [!IMPORTANT]
> Code execution runs in a **sandboxed model-controlled environment**.
> The code shown in this payload is **not executed by the client** and has no access to local resources, files, or network unless explicitly allowed by the tool.

#### Expected JSON payload
```json
"tools": [{"code_execution": {}}],
    "contents": [
        {
            "role": "user",
            "parts": [{
                "text": "Can you print \"Hello world!\"?"
            }]
        },{
            "role": "model",
            "parts": [
              {
                "text": ""
              },
              {
                "executable_code": {
                  "language": "PYTHON",
                  "code": "\nprint(\"hello world!\")\n"
                }
              },
              {
                "code_execution_result": {
                  "outcome": "OUTCOME_OK",
                  "output": "hello world!\n"
                }
              },
              {
                "text": "I have printed \"hello world!\" using the provided python code block. \n"
              }
            ],
        },{
            "role": "user",
            "parts": [{
                "text": "What is the sum of the first 50 prime numbers? Generate and run code for the calculation, and make sure you get all 50."
            }]
        }
    ]
```

> [!NOTE]
> From the payload builder perspective, code execution is enabled by declaring the corresponding tool. The client is only responsible for providing the request configuration, not for orchestrating execution.

#### Construction using `TGeneration`
```pascal
  // uses Gemini, Gemini.Types, Gemini.Helpers ...

  var Params := TChatParams.Create;
  var Generation := Default(TGeneration);

  with Generation do
      Params
        .Tools( Tools
            .AddCodeExecution
        )
        .Contents( Contents
            .User( Parts
                .AddText('Can you print "Hello world!"?')
            )
            .Model( Parts
                .AddText('')
                .AddExecutableCode(TLanguageType.PYTHON, 'print("hello world!")')
                .AddCodeExecutionResult(TOutcomeType.OUTCOME_OK, 'hello world!')
                .AddText('I have printed "hello world!" using the provided python code block.')
            )
            .User('What is the sum of the first 50 prime numbers? Generate and run code for the calculation, and make sure you get all 50.')
        );

  Memo1.Text := Params.ToFormat(True);
```

<br>

## Tools vs Function calling
Tools and function calling share a similar conceptual role: they extend the model’s capabilities beyond pure text generation.

At the payload level, both are expressed as tool declarations. The exact invocation logic is handled internally by the model and reflected in the generation response.

<br>

## Response Parsing
When tools are enabled, generation responses may contain additional parts describing tool calls or tool outputs.

This document intentionally omits response parsing details, as they depend on the execution mode and are covered in the generation execution documentation.