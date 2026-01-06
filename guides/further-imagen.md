# Imagen

Imagen is a text-to-image generative model based on language-conditioned diffusion architectures.

Its purpose is to generate visual content from textual descriptions, enabling the study and practical use of semantic, stylistic, and compositional control through explicit parameters.

#### Key constraints
- Input language: textual descriptions must be written exclusively in English.
- Prompt length: maximum 480 tokens.
- Output volume: generation of 1 to 4 images per request.
- Human depiction: subject to explicit configuration (personGeneration) and regulatory geographic restrictions (EU, UK, Switzerland, MENA).
- Text within images: experimental capability, recommended for short strings (≤ 25 characters).
- Watermarking: all generated images include a SynthID watermark.
- Formats: image sizes and aspect ratios are discrete and predefined, with no continuous control.

<br>

- [Imagen Creation](#imagen-creation)
- [Cross-cutting warnings and recommendations](#cross-cutting warnings-and-recommendations)

___

## Imagen Creation
- Core API function for generating images from a textual prompt.
- Returns one or more encoded images (base64), according to the specified generation parameters.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Model := 'imagen-4.0-generate-001';
  var Filename := 'Imagen-4.0-sample05';
  var Prompt := 'A zoomed out photo of a small bag of coffee beans in a messy kitchen';

  //JSON Payload
  var Payload: TProc<TImageGenParams> :=
    procedure (Params: TImageGenParams)
    begin
      Params
        .Instances( TImageGenMedia.Instances
          .AddItem( TImageGenMedia.Prompt(Prompt))
         )
        .Parameters(
          TImageGenParameters.Create
            .NumberOfImages(4)
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  var saveImagenToFile: TProc<TImageGen> :=
    procedure (Value: TImageGen)
    var LocalName: string;
    begin
      var Cnt := 0;
      for var Item in Value.Predictions do
        begin
          Display(TutorialHub, Item.MimeType);
          if Cnt = 0 then
            LocalName := Filename + '.png'
          else
            LocalName := FileName + Cnt.ToString + '.png' ;

         TMediaCodec.DecodeBase64ToFile(Item.BytesBase64Encoded, LocalName);
         Display(TutorialHub, 'Video saved to: ' + LocalName);
         Inc(Cnt);
        end;
    end;


  //Asynchronous example
  var Promise := Client.Imagen.AsyncAwaitCreate(Model, Payload);

  Promise
  .&Then(
    procedure(Value: TImageGen)
    begin
      saveImagenToFile(Value);
      saveImagenToFile := nil;
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Display(TutorialHub, E.Message);
    end);


  //Synchronous example
//  var Value := Client.Imagen.Create(Model, Payload);
//
//  try
//    saveImagenToFile(Value);
//    saveImagenToFile := nil;
//  finally
//    Value.Free;
//  end;
```

<br>

## Cross-cutting warnings and recommendations

- Non-determinism: generation is stochastic; identical requests may yield different outputs.
- Iterative process: achieving a result aligned with a precise intention generally requires multiple prompt refinements.
- Indirect control: parameters influence generation without guaranteeing strict compliance (e.g. text placement, typography, fine composition).
- Stylistic references: artistic or historical style references are interpreted approximately and are not intended for faithful reproduction.
- Photorealism: largely depends on lexical precision in the prompt (optics, lighting, framing), rather than on the model alone.
