# Speech generation (Text-to-speech)

The **Text-to-Speech (TTS)** feature in ***Gemini 2.5*** enables the generation of an audio signal from a provided text using language models with native speech synthesis capabilities.
It is designed for the controlled vocal rendering of fixed text, allowing the speaking style *(tone, pace, accent, delivery)* to be influenced through natural language instructions.

**TTS targets** non-interactive audio production use cases, such as ***narration, voice-over, or scripted dialogue***, and is distinct from real-time conversational audio generation mechanisms.

#### Key constraints
- Text-only input
- Audio-only output
- Faithful reading of the provided text (no verbal improvisation)
- Expressive control via prompting, without low-level acoustic parameters
- Support limited to one or two speakers
- Voices restricted to a predefined catalog
- Context window limited to 32k tokens
- Non-interactive generation (no real-time conversational streaming)

<br>

- [Single-speaker speech synthesis](#single-speaker-speech-synthesis)
- [Multi-speaker speech synthesis](#multi-speaker-speech-synthesis)
- [Controlling speech style via prompts](#controlling-speech-style-via-prompts)
- [Voice options](#voice-options)

___

<br>

## Single-speaker speech synthesis

This feature enables the generation of audio from a text using a single synthetic voice.
It is intended for straightforward *narration scenarios* where one speaker reads a fixed script with optional expressive guidance provided through the prompt.

Typical use cases include **voice-over, audiobook narration**, and **monologue-style** audio content.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers;

  var Model       := 'gemini-2.5-flash-preview-tts';
  var Voice1      := 'Kore';
  var WavFileName := 'SingleSpeaker.wav';
  var Text :=
       '''
       Say cheerfully: Have a wonderful day!
       ''';

  //JSON Payload
  var Payload: TProc<TChatParams> :=
        procedure (Params: TChatParams)
        begin
          Params
            .Contents( Generation.Contents
                .AddParts( Generation.Parts
                    .AddText(Text)
                )
            )
            .GenerationConfig( SingleSpeakerConfig(Voice1) );
        end;


  //Asynchronous Example
  var Promise := Client.Transcription.AsyncAwaitTextToSpeech(Model, Payload);

  Promise
  .&Then(
    procedure(Value: TTranscription)
    begin
      TMediaCodec.DecodeBase64ToFile(Value.WavBase64, WavFileName);

      Memo1.Lines.Text := Memo1.Text + WavFileName + ' generated';
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Memo1.Lines.Text := Memo1.Text +  E.Message;
    end);
```

>[!NOTE]
>The `SingleSpeakerConfig(Voice1)` method is used to configure the `GenerationConfig` property of `TChatParams`.
>
>It is defined in the `Gemini.Helpers` unit and provides a standard configuration for single-speaker audio generation.

<br>

## Multi-speaker speech synthesis

This feature supports the generation of audio involving two distinct speakers, each associated with a predefined voice.
The text is structured as a dialogue, where speaker identifiers in the transcript determine which voice is used for each utterance.

This mode is designed for short, scripted conversations rather than complex multi-party dialogue.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers;

  var Model       := 'gemini-2.5-flash-preview-tts';
  var Speaker1    := 'Jane';
  var Voice1      := 'Kore';
  var Speaker2    := 'Joe';
  var Voice2      := 'Sadaltager';
  var WavFileName := 'MultiSpeaker.wav';
  var Text :=
       '''
       TTS the following conversation between Joe and Jane:
                Joe: Hows it going today Jane?
                Jane: Not too bad, how about you?"
       ''';

  //JSON Payload
  var Payload: TProc<TChatParams> :=
        procedure (Params: TChatParams)
        begin
          Params
            .Contents( Generation.Contents
                .AddParts( Generation.Parts
                    .AddText(Text)
                )
            )
            .GenerationConfig( MultiSpeakerConfig(Speaker1, Voice1, Speaker2, Voice2) );
        end;


  //Asynchronous Example
  var Promise := Client.Transcription.AsyncAwaitTextToSpeech(Model, Payload);

  Promise
  .&Then(
    procedure(Value: TTranscription)
    begin
      TMediaCodec.DecodeBase64ToFile(Value.WavBase64, WavFileName);

      Memo1.Lines.Text := Memo1.Text + WavFileName + ' generated';
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Memo1.Lines.Text := Memo1.Text + E.Message;
    end);
```

>[!NOTE]
>The `MultiSpeakerConfig(Speaker1, Voice1, Speaker2, Voice2)` method is used to configure the `GenerationConfig` property of `TChatParams`.
>
>It is defined in the `Gemini.Helpers` unit and provides a standard configuration for single-speaker audio generation.

<br>

## Controlling speech style via prompts

Speech delivery can be influenced using natural language instructions embedded in the prompt.
These instructions allow control over style, tone, pace, accent, and expressive qualities without relying on low-level acoustic parameters.

This mechanism enables the model to adapt vocal performance to narrative intent, emotional context, or character identity while preserving the original text.

See [Official documentation](https://ai.google.dev/gemini-api/docs/speech-generation?hl=fr#controllable)

<br>

## Voice options

Text-to-Speech models provide access to a fixed catalog of predefined voices, each characterized by distinct vocal qualities (e.g., clarity, warmth, energy, breathiness).
Voices are selected explicitly and cannot be customized beyond the expressive control achieved through prompting.

See [Official documentation](https://ai.google.dev/gemini-api/docs/speech-generation?hl=fr#voices)
