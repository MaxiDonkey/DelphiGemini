# Multimodal generation

The Interactions API supports the generation of multimodal outputs across supported media types.

- Image generation

  ```pascal
    var Params: TProc<TInteractionParams> :=
          procedure (Params: TInteractionParams)
          begin
            Params
              .Model('nano-banana-pro-preview')
              .Input('Generate an image of a futuristic city.' )
              .ResponseModalities([TResponseModality.image, TResponseModality.text]);
            TutorialHub.JSONRequest := Params.ToFormat();
          end;


    //Asynchronous promise example
    var Promise := Client.Interactions.AsyncAwaitCreate(Params);

    Promise
      .&Then<string>(
        function (Value: TInteraction): string
        begin
          Result := Value.Id;

          Display(TutorialHub, Value);
        
          for var Item in Value.Outputs do
            begin
              case Item.&Type of
                TContentType.image:
                  TMediaCodec.TryDecodeBase64ToFile(Item.Data, 'MyFile.jpg');
              end;
            end;

        end)
      .&Catch(
        procedure (E: Exception)
        begin
          Display(TutorialHub, E.Message);
        end);
  ```
