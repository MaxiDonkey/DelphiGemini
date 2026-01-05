# GenerateContent - Function Calling

- [Intoduction](#introduction)
- [Prepare the Plugin](#prepare-the-plugin)
- [Recall Function](#recall-function)
- [Call the Function](#call-the-function)

___

>[!NOTE]
>Historically, the **DelphiGemini** wrapper relied on a plugin-based architecture. This approach proved to be particularly effective when a clear separation is required between the business logic of a feature and the handling of JSON request submission, reception, and processing.
>
>This architecture is retained in the present section. However, an alternative method based on a different approach, and not relying on a plugin mechanism, is also available. This method is used for the interactions endpoint; the corresponding implementation can be accessed via [the following link](interactions-tools.md#function-calling).

<br>

## Introduction

The Gemini API, through its function calling capability, allows you to define custom functions that the model can suggest based on context. It returns a structured output that includes the function name along with the recommended arguments.

Although the model does not execute these functions directly, it generates actionable suggestions, enabling you to trigger external API calls with the appropriate parameters. This approach makes it possible to integrate real-time data from external sources; such as databases, CRM systems, or document repositories; thereby enhancing the relevance and effectiveness of the model’s responses.

<br>

## Prepare the Plugin

The [`Gemini.Functions.Core`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Functions.Core.pas) unit defines the `IFunctionCore` interface. This interface must be implemented by the plugin class responsible for the business logic. For a concrete example of this mechanism, please refer to the [`Gemini.Functions.Example`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Functions.Example.pas) unit.

<br>

## Recall Function

The callback function is a method to which the function arguments are passed when, during the previous turn, the model has determined that a function call was required with those parameters.

For example, the callback function can be defined as follows:

```pascal
//Asynchonous method
procedure TForm1.CallFunction(const Client: IGemini;
  const Value: TFunctionCallPart; Func: IFunctionCore);
begin
  var ArgResult := Func.Execute(Value.Args);
  Client.Chat.ASynCreateStream('gemini-2.5-flash-lite',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add(ArgResult)]);
    end,
    function : TAsynChatStream
    begin
      Result.OnProgress :=
        procedure (Sender: TObject; Chat: TChat)
        begin
          Memo1.Lines.Text := Memo1.Text + Chat.Candidates[0].Content.Parts[0].Text;
        end;

      Result.OnError :=
        procedure (Sender: TObject; Error: string)
        begin
          Memo1.Lines.Text := Memo1.Text + #10 + Error;
        end;
    end);
end;  
```

<br>

## Call the Function

The plugin-based mechanism is relatively straightforward and can be summarized by the method shown below. In practice, the entire process is handled within the unit where the plugin is defined, namely the [`Gemini.Functions.Example`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Functions.Example.pas) unit.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Functions.Example;

  var Weather := TWeatherReportFunction.CreateInstance;

  var Chat := Client.Chat.Create('gemini-2.5-flash-lite',
    procedure (Params: TChatParams)
    begin
      Params
        .Contents([TPayload.User('What is the weather like in Paris, temperature in celcius?')])
        .Tools([Weather])
    end);
  try
    for var Item in Chat.Candidates do
      begin
        for var SubItem in Item.Content.Parts do
          begin
            if Assigned(SubItem.FunctionCall) then
              CallFunction(Client, SubItem.FunctionCall, Weather)
            else
              Memo1.Lines.Text := Memo1.Text + #10 + SubItem.Text;
          end;
      end;
  finally
    Chat.Free;
  end;
``` 