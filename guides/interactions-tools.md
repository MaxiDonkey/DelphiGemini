# Interactions Tools

- [Function Calling](#function-calling)
- [Built-in tools](#built-in-tools)
  - [Grounding with Google search](#grounding-with-google-search)
  - [Code execution](#code-execution)
  - [URL context](#url-context)
- [Remote Model context protocol (MCP)](#remote-model-context-protocol-mcp)
___

>[!NOTE]
> The code snippets will exclusively refer to the `procedure (Params: TInteractionParams)`, as introduced in the sections covering [non-streamed](interactions-generation.md#text-generation-non-streamed-interactions) and [streamed](interactions-sse.md#sse-streaming-interactions) generation.

This section describes how to define custom tools using function calling and how to leverage Google’s built-in tools within the Interactions API.

<br>

## Function Calling
Function calling follows a two-step workflow:
- **Step 1 - definition and tool selection:** you build a JSON request that includes the user question and one or more function definitions. The model decides whether a function call is required and, if so, returns the function name to invoke along with the corresponding arguments. When multiple functions are provided, the model selects the one it considers the most appropriate.

- **Step 2: - execution and final response:** you submit a second request that injects the selected function name and the arguments returned in the previous step. This second pass produces a final response that incorporates the values obtained from Step 1.

- Step details
  - [Step1: Construct the JSON payload](#step1-construct-the-json-payload)
  - [Step2: Fetch weather information](#step2-fetch-weather-information)
  - [Key Takeaways](#key-takeaways)
  - [Implementation Checklist](#implementation-checklist)

<br>

The `DelphiGemini` wrapper supports two ways to handle function calling:
- a **plugin-based** approach, which is well-suited for large catalogs of functions with more complex processing;
- a **direct approach**, where the function is implemented explicitly in application code.

With the direct approach, the developer is responsible for interpreting the arguments returned in Step 1 and producing consistent data to feed into Step 2.

<br>

This section focuses only on the direct approach. The plugin-based approach has already been covered in the “content generation” section and can be applied here with minimal adaptation.

The example used throughout this section is: **"What’s the weather in Paris?"** For Step 1, three variants are presented to illustrate the flexibility of `DelphiGemini` in this workflow.

<br>

### Step1: Construct the JSON payload

#### Approach using the `TSchemaParams` class.

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('What is the weather in Paris?' )
            .Tools(
              TToolIx.Create()
                .AddFunction(
                  TfunctionIxParams.New
                    .Name('get_weather')
                    .Description('Gets the weather for a given location.')
                    .Parameters(
                      TSchemaParams.New
                        .&Type('object')
                        .Properties(
                          TSchemaParams.New
                            .Properties('location',
                              TSchemaParams.New
                                .&Type('string')
                                .Description('The city and state, e.g. San Francisco, CA')
                             )
                         )
                        .Required(['location'])
                     )
                 )
             );
        end;
```

<br>

#### Approach using the `TToolIX` record helper.

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('What is the weather in Paris?' )
            .Tools(
              TToolIx.Create()
                .AddFunction(
                  TfunctionIxParams.New
                    .Name('get_weather')
                    .Description('Gets the weather for a given location.')
                    .Parameters(
                      '''
                      {
                          "type": "object",
                          "properties": {
                              "location": {"type": "string", "description": "The city and state, e.g. San Francisco, CA"}
                          },
                          "required": ["location"]
                      }
                      '''
                    )
                 )
             );

        end;
```

With this approach, declaring multiple functions is both efficient and visually clear. Additional functions can be added easily by calling `.AddFunction(...)`.

<br>

#### Approach based on using a string.

```pascal
    var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('What is the weather in Paris?' )
            .Tools(
              '''
              [{
                  "type": "function",
                  "name": "get_weather",
                  "description": "Gets the weather for a given location.",
                  "parameters": {
                      "type": "object",
                      "properties": {
                          "location": {"type": "string", "description": "The city and state, e.g. San Francisco, CA"}
                      },
                      "required": ["location"]
                  }
              }]
              '''
             );

          TutorialHub.JSONRequest := Params.ToFormat();
        end;
```

This multiline string–based approach is only applicable when using Delphi version 12 or later. Otherwise, you can still rely on an external string in which the JSON payload is explicitly defined.

<br>

### Step2: Fetch weather information

By leveraging promise orchestration, you can significantly reduce boilerplate and keep the entire flow within a single instruction chain.
Each Then corresponds to one phase: extraction → execution → final rendering.

Start by defining the following two routines to simplify the examples:

```pascal
function GetFunctionResult(const Value: TInteraction;
  out Name: string;
  out CallId: string;
  out Arguments: string): Boolean;
begin
  for var Item in Value.Outputs do
    begin
      case Item.&Type of
        TContentType.function_call:
          begin
            Arguments := Item.Arguments;
            Name := Item.Name;
            CallId := Item.Id;
            Exit(True);
          end;
      end;
    end;
  Result := False;
end

function GetWeatherFromLocation(const JSONLocation: string): string;
begin
  // Do something
  Result := JSONLocation;
end;
```

<br>

Now define the method that orchestrates the two promises required to retrieve the weather for Paris.

```pascal
  // First pass. 
  var Promise := Client.Interactions.AsyncAwaitCreate(Params);

  Promise
    .&Then(
      // Extract function call + execute business logic
      function (Value: TInteraction): TPromise<TInteraction>
      var
        Id, Name, callId, Arguments: string;
      begin
        Id := Value.Id;

        if not GetFunctionResult(Value, Name, CallId, Arguments) then
          Exit(TPromise<TInteraction>.Resolved(nil));

        var Weather := GetWeatherFromLocation(Arguments);

        Result := Client.Interactions.AsyncAwaitCreate(
          procedure (Params: TInteractionParams)
             begin
               Params
                 .Model('gemini-3-flash-preview')
                 .Input(
                   TInput.Create()
                     .AddFunctionResult(Weather, Name, CallId)
                  )
                 .PreviousInteractionId(Id);
              end);
      end)
    .&Then(
      // Display final model response
      procedure (Value: TInteraction)
      begin
        if Assigned(Value) then
          Display(TutorialHub, Value)
        else
          Display(TutorialHub, 'no function called');
      end)
    .&Catch(
      // Error handling
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
```
 
<br>

The JSON result.

```json
{
    "created": "2025-12-29T11:06:25Z",
    "id": "v1_ChdybUJTYVppakdlanJrZFVQMVBPWHlRdxIXc0dCU2FhUFZLTE9ja2RVUG9KajUTQ",
    "model": "gemini-3-flash-preview",
    "object": "interaction",
    "outputs": [
        {
            "signature": "EiYKJGUyNDgzMGE3LTVjZDYtNDJmZS05OThiLWVlNTM5Z..ljMw==",
            "type": "thought"
        },
        {
            "text": "The current weather in Paris, France is 14°C (57°F) with moderate rain. The wind is blowing at 26 km\/h, and the humidity is at 88%.",
            "type": "text"
        }
    ],
    "role": "model",
    "status": "completed",
    "updated": "2025-12-29T11:06:25Z",
    "usage": {
        "input_tokens_by_modality": [
            {
                "modality": "text",
                "tokens": 42
            }
        ],
        "total_cached_tokens": 0,
        "total_input_tokens": 42,
        "total_output_tokens": 44,
        "total_thought_tokens": 0,
        "total_tokens": 86,
        "total_tool_use_tokens": 0
    }
}
```

<br>

### Key Takeaways
- Function calling always uses two interactions with the model.
- The model describes a function call; the Delphi application executes it.
- Each function exposes a name, a description, and a parameter schema.
- Results are returned using `AddFunctionResult(...)` with `PreviousInteractionId`.
- Schema quality directly impacts call accuracy and stability.

<br>

### Implementation Checklist
- Define the function (name + description + parameters).
- Provide the list of tools in the initial interaction.
- Detect a `function_call` in the model response.
- Extract `Name`, `CallId`, and `Arguments`.
- Execute the corresponding business logic.
- Return the result using `AddFunctionResult(...)`.
- Start a new interaction with `PreviousInteractionId`.
- Handle errors via `Catch`.

___

<br>

## Built-in tools
Gemini includes built-in tools for grounding responses with Google Search, executing code, and incorporating external URL context.

### Grounding with Google search

Grounding with Google Search connects Gemini models to real-time web content and is supported across all available languages. This capability enables models to generate responses that go beyond their static knowledge cutoff by incorporating up-to-date, verifiable information.

Grounding enables applications to:
- Improve factual accuracy: Reduce hallucinations by anchoring responses in real-world data.
- Access real-time information: Answer questions related to recent events or evolving topics.

<br>

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Who won the last Super Bowl?')
            .Tools(
              TToolIx.Create()
                .AddGoogleSearch()
            );
        end;
```

or

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Who won the last Super Bowl?')
            .Tools(
              '''
              [{"type": "google_search"}]
              '''
            );
        end;  
```

<br>

### Code execution

The Gemini API provides a code execution tool that allows the model to generate and run Python code. The model can iteratively leverage execution results to refine its reasoning and produce a final outcome.

Code execution enables the development of applications based on computational reasoning, such as solving equations, performing calculations, or processing and transforming text. The execution environment also includes a set of libraries that support more specialized tasks.

Gemini can only execute Python code. While the model can generate code in other programming languages, such code cannot be executed using the built-in code execution tool.

<br>

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Calculate the 50th Fibonacci number.')
            .Tools(
              TToolIx.Create()
                .AddCodeExecution()
            );
        end;
```

or

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Calculate the 50th Fibonacci number.')
            .Tools(
              '''
              [{"type": "code_execution"}]
              '''
            );
        end;
```

<br>

### URL context
The URL context tool allows you to provide additional context to models in the form of URLs. When URLs are included in a request, the model can access the corresponding content (provided the URLs are not of a type listed in the [Limitations section](https://ai.google.dev/gemini-api/docs/url-context#limitations)) to enrich and ground its response.

This tool is useful for tasks such as:
- **Data extraction:** retrieving specific information such as prices, names, or key results from multiple URLs.
- **Document comparison:** analyzing multiple reports, articles, or PDF files to identify differences or track trends.
- **Content synthesis and generation:** combining information from several source URLs to produce summaries, blog posts, or structured reports.
- **Code and documentation analysis:** pointing to a GitHub repository or technical documentation to explain code, generate installation instructions, or answer targeted questions.

<br>

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Summarize the content of https://www.wikipedia.org/')
            .Tools(
              TToolIx.Create()
                .AddUrlContext()
            );
        end;
```

or

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Summarize the content of https://www.wikipedia.org/')
            .Tools(
              '''
              [{"type": "url_context"}]
              '''
            );
        end;
```

<br>

## Remote Model context protocol (MCP)
The **Model Context Protocol (MCP)** is an open-source standard designed to connect AI applications to external systems.

With MCP, AI applications such as Claude, ChatGPT or Gemini can interact with data sources (local files, databases, etc.), tools (search engines, calculators, and similar services), and workflows (custom prompts, automations, and more). This enables them to access relevant contextual information and perform tasks in a structured and extensible manner.

MCP can be compared to a **USB-C** port for AI applications. Just as USB-C provides a standardized interface for connecting electronic devices, MCP defines a standardized protocol for connecting AI applications to external systems and services.

Refer to the [document](https://modelcontextprotocol.io/docs/getting-started/intro).

<br>

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('What is the weather like in New York today?')
            .Tools(
              TToolIx.Create()
                .AddMcpServer(
                  TMcpServerIxParams.New
                    .Name('weather_service')
                    .Url('https://gemini-api-demos.uc.r.appspot.com/mcp')
                 )
             )
            .SystemInstruction('Today is ''' + FormatDateTime('dd"u"mmmm"t"yyyy', Date) +
                               ''' (' + FormatDateTime('yyyy-mm-dd', Date) + ').') ;
        end;
```

or

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('What is the weather like in New York today?')
            .Tools(
              '''
              [{
                  "type": "mcp_server",
                  "name": "weather_service",
                  "url": "https://gemini-api-demos.uc.r.appspot.com/mcp"
              }]
              '''
             )
            .SystemInstruction('Today is ''' + FormatDateTime('dd"u"mmmm"t"yyyy', Date) +
                               ''' (' + FormatDateTime('yyyy-mm-dd', Date) + ').') ;
        end;
```

<br>

>[!IMPORTANT]
>- Remote MCP is supported only with **Streamable HTTP servers; SSE servers are not supported.**
>- Remote MCP is not currently compatible with Gemini 3 models (support is planned for a future release).
>- MCP server names must not include the `-` character; use snake_case naming instead. 