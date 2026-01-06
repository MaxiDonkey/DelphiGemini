# Models

The models endpoint allows you to programmatically list available models and retrieve detailed metadata, such as supported capabilities and context window size.

<br>

- [List of Models](#list-of-models)
- [Model retrieving](#model-retrieving)

___

<br>

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## List of Models

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  TutorialHub.JSONRequestClear;

  //Asynchronous promise example
  var Promise := Client.Models.AsyncAwaitList;

  Promise
    .&Then<TModels>(
      function (Value: TModels): TModels
      begin
        Display(TutorialHub, Value);
        Result := Value;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Models.List;
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Model retrieving

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var ModelName := 'models/gemini-2.5-flash';

  //Asynchronous promise example
  var Promise := Client.Models.AsyncAwaitRetrieve(ModelName);

  Promise
    .&Then<string>(
      function (Value: TModel): string
      begin
        Result := Value.Name;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Models.Retrieve(ModelName);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
