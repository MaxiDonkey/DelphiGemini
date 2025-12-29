# Structured output (JSON schema)

- [Response Format](#response-format)
- [Combining tools and structured output](#combining-tools-and-structured-output)

___

>[!NOTE]
> The code snippets will exclusively refer to the `procedure (Params: TInteractionParams)`, as introduced in the sections covering [non-streamed](interactions-generation.md#text-generation-non-streamed-interactions) and [streamed](interactions-sse.md#sse-streaming-interactions) generation.



## Response Format
A specific JSON output structure can be enforced by supplying a JSON schema through the response_format parameter, which is commonly used for moderation, classification, and data extraction workflows.

<br>

### Approach using the `TSchemaParams` class.
```pascal
    var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Moderate the following content: ''Congratulations! You''ve won a free cruise. Click here to claim your prize: www.definitely-not-a-scam.com')
            .ResponseFormat(
               TSchema.New
                 .&Type('object')
                 .Properties(
                   TSchemaParams.New
                     .Properties('decision',

                        TSchemaParams.New
                          .&Type('object')
                          .Properties(

                             TJSONObject.Create
                               .AddPair('reason',
                                 TJSONObject.Create
                                   .AddPair('type', 'string')
                                   .AddPair('description', 'The reason why the content is considered spam.')
                                )
                               .AddPair('spam_type',
                                 TJSONObject.Create
                                   .AddPair('type', 'string')
                                   .AddPair('description', 'The type of spam.')
                                )
                           )
                          .Required(['reason', 'spam_type'])
                      )
                  )
                 .Required(['decision'])
             );
        end;
```

or

### Approach based on using a string.
```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Moderate the following content: ''Congratulations! You''ve won a free cruise. Click here to claim your prize: www.definitely-not-a-scam.com')
            .ResponseFormat(
               '''
               {
                   "type": "object",
                   "properties": {
                       "decision": {
                           "type": "object",
                           "properties": {
                               "reason": {"type": "string", "description": "The reason why the content is considered spam."},
                               "spam_type": {"type": "string", "description": "The type of spam."}
                           },
                          "required": ["reason", "spam_type"]
                       }
                   },
                   "required": ["decision"]
               }
               '''
             );
        end;
```
This multiline string–based approach is only applicable when using Delphi version 12 or later. Otherwise, you can still rely on an external string in which the JSON payload is explicitly defined.

<br>

The JSON result

```json
{
    "created": "2025-12-29T14:33:22Z",
    "id": "v1_ChdNWkZTYWItZUo2bWt2ZElQMi1hU...1rdmRJUDItYVEyQTA",
    "model": "gemini-3-flash-preview",
    "object": "interaction",
    "outputs": [
        {
            "signature": "EuYFCuMFAXLI2nzrTAWmNXOZNPNo+eu60\/5gKGw8oWjeGykxgrMm1...MzTJbG\/xWBe6SOYuxgQ==",
            "type": "thought"
        },
        {
            "text": "{\"decision\":{\"reason\":\"The content is a classic example of a phishing scam, using a fake prize notification and a suspicious URL to lure users into clicking.\",\"spam_type\":\"Phishing\/Scam\"}}",
            "type": "text"
        }
    ],
    "role": "model",
    "status": "completed",
    "updated": "2025-12-29T14:33:22Z",
    "usage": {
        "input_tokens_by_modality": [
            {
                "modality": "text",
                "tokens": 37
            }
        ],
        "total_cached_tokens": 0,
        "total_input_tokens": 37,
        "total_output_tokens": 42,
        "total_thought_tokens": 177,
        "total_tokens": 256,
        "total_tool_use_tokens": 0
    }
}
```

<br>

## Combining tools and structured output
Built-in tools can be combined with structured output to generate a deterministic JSON object from tool-retrieved data.

<br>

```pascal
    var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Who won the last euro?')
            .Tools(
              '''
              [{"type": "google_search"}]
              '''
             )
            .ResponseFormat(
              '''
              {
                  "type": "object",
                  "properties": {
                      "winning_team": {"type": "string"},
                      "score": {"type": "string"}
                  }
              }
              '''
             );
        end;
```

