# Stateful conversation

To continue a conversation, provide the identifier from the previous interaction via the `previous_interaction_id` parameter.

>[!NOTE]
> The code snippets will exclusively refer to the `procedure (Params: TInteractionParams)`, as introduced in the sections covering [non-streamed](interactions-generation.md#text-generation-non-streamed-interactions) and [streamed](interactions-sse.md#sse-streaming-interactions) generation.


```pascal
 var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model('gemini-3-flash-preview')
        .Input('new message in the conversation')
        .PreviousInteractionId('INTERACTION_ID'); //INTERACTION_ID was obtained from a previous interaction turn. 
    end;

```


#### You can manage conversation history manually on the client side. 

(Delphi `version 12 or later`)
```pascal
 var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model('gemini-3-flash-preview')
        .Input(
          '''
          [
              {
                  "role": "user",
                  "content": "What are the three largest cities in Spain?"
              },
              {
                  "role": "model",
                  "content": "The three largest cities in Spain are Madrid, Barcelona, and Valencia."
              },
              {
                  "role": "user",
                  "content": "What is the most famous landmark in the second one?"
              }
          ]
          '''
         );
    end;
```

<br>

>[!NOTE]
>- If you are using Delphi `version 12 or later`, you can use multiline strings to define certain parts of the request directly as valid JSON strings. 
>- This approach is fully supported by the wrapper.
>- In the remainder of this document, examples will continue to use JSON strings to ensure consistency across illustrations.

<br>

There is also a method based on the use of `TTurns`, more specifically on the `TInteractionTurn` record, defined in the `Gemini.Helpers` unit.
This unit brings together numerous utility methods designed to simplify and make more reliable the construction of JSON payloads.


```pascal
 var FileLocation := 'Z:\Images\Invoice.png';
 var Base64 := TMediaCodec.EncodeBase64(FileLocation);
 var MimeType := TMediaCodec.GetMimeType(FileLocation);

 var Params: TProc<TInteractionParams> :=
       procedure (Params: TInteractionParams)
       begin
         Params
           .Model('gemini-3-flash-preview')
           .Input( TInteractionTurn.Turns
             .AddUser(    'What are the three largest cities in Spain?')
             .AddModel(   'The three largest cities in Spain are Madrid, Barcelona, and Valencia.')
             .AddUser(TInteractionInput.Inputs
                .AddText( 'Describe this image')
                .AddImage(Base64, Mimetype)
             )
           )
           .Stream;
       end;
```

<br>

For further information, please refer to the [`Gemini.Helpers`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Helpers.pas) unit.

```pacal

...

  TInteractionTurn = record
    class function Turns: TTurn; static;
  end;
...

  TInteractionInput = record
    class function Inputs: TInput; static;
    class function AddInput: TInputParams; static;
  end;

```

<br>

The final code example produces the following JSON, which is used as the payload of the request submitted to the model.

```json
{
    "model": "gemini-3-flash-preview",
    "input": [
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "What are the three largest cities in Spain?"
                }
            ]
        },
        {
            "role": "model",
            "content": [
                {
                    "type": "text",
                    "text": "The three largest cities in Spain are Madrid, Barcelona, and Valencia."
                }
            ]
        },
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "Describe this image"
                },
                {
                    "type": "image",
                    "data": "iVBORw0KGgoAAAANSUhEUgAAArwAAAPTCAIAAADdDU0vAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGMWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDEgNzkuMTQ2Mjg5OSw...\/aDUvyupvTGacYJKk0CrKVve7ObIGMs7c/3cK5yEBgG0ZI2jM6cPVS3REKLZ2dUZawTSRrxzP4P9627gM5Hi9YosNlX9vwH0mnOepMvjDgAAAABJRU5ErkJggg==",
                    "mime_type": "image\/png"
                }
            ]
        }
    ],
    "stream": true
}
```