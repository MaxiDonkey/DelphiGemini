# Interactions-CRUD

- [Retrieving an interaction](#retrieving-an-interaction) 
- [Deleting an interaction](#deleting-an-interaction)
- [Canceling an interaction](#canceling-an-interaction)

___

<br>

## Retrieving an interaction
Retrieves the full details of a single interaction based on its `Interaction.id`.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL or Gemini.Tutorial.FMX

  var InteractionId := 'e.g. v1_ChdVd2xZYWJqRk1lYWZrZFVQdkdxdWtBZxIXVXdsWEGFiakZNZWFma2RVUHZLcXVrQWc';

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitRetrieve(InteractionId);

  Promise
    .&Then<string>(
      function (Value: TInteraction): string
      begin
        Result := Value.Id;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Interactions.Retrieve(InteractionId);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Deleting an interaction
Deletes the interaction by id.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL or Gemini.Tutorial.FMX

  var InteractionId := 'e.g. v1_ChdVd2xZYWJqRk1lYWZrZFVQdkdxdWtBZxIXVXdsWEGFiakZNZWFma2RVUHZLcXVrQWc';

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitDelete(InteractionId);

  Promise
    .&Then<string>(
      function (Value: TCRUDDeleted): string
      begin
        Result := 'Deleted';
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Interactions.Delete(InteractionId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Canceling an interaction
Cancels an interaction by id. This only applies to `background` interactions that are still running.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL or Gemini.Tutorial.FMX

  var InteractionId := 'e.g. v1_ChdVd2xZYWJqRk1lYWZrZFVQdkdxdWtBZxIXVXdsWEGFiakZNZWFma2RVUHZLcXVrQWc';

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitCancel(InteractionId);

  Promise
    .&Then<string>(
      function (Value: TInteraction): string
      begin
        Result := Value.Id;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Interactions.Cancel(InteractionId);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
