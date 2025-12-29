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
