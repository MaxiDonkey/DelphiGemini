# Generation config

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model('gemini-3-flash-preview')
            .Input('Tell me a story about a brave knight.')
            .GenerationConfig(
               TGenerationConfigIxParams.Create
                 .Temperature(0.7)
                 .MaxOutputTokens(500)
                 .ThinkingLevel('low')
                 .ThinkingSummaries('auto') //Include "thougth"
             );
        end;
```

>[!NOTE]
>All parameters of the `TGenerationConfigIxParams` class are available in the [`Gemini.Interactions.GenerationConfig`](https://github.com/MaxiDonkey/DelphiGemini/blob/main/source/Gemini.Chat.Request.GenerationConfig.pas) unit.

<br>

The thinking_level parameter provides control over the reasoning depth and behavior of Gemini models starting from version 2.5.

| Level | Description | Supported Models|
| :---: | :--- | ---: |
| minimal | Matches the "no thinking" setting for most queries. In some cases, models may think very minimally. Minimizes latency and cost. | Flash Models Only (e.g. Gemini 3 Flash) |
| low | Light reasoning that prioritises latency and cost savings for simple instruction following and chat. | All Thinking Models |
| medium | Balanced thinking for most tasks. | Flash Models Only (e.g. Gemini 3 Flash) |
| high | (Default) Maximizes reasoning depth. The model may take significantly longer to reach a first token, but the output will be more carefully reasoned. | All Thinking Models |