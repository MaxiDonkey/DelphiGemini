# Agents

- [Deep Research](#deep-research)

___

>[!NOTE]
> The code snippets will exclusively refer to the `procedure (Params: TInteractionParams)`, as introduced in the sections covering [non-streamed](interactions-generation.md#text-generation-non-streamed-interactions) and [streamed](interactions-sse.md#sse-streaming-interactions) generation.


<br>

## Deep Research

Specialized agents, such as `deep-research-pro-preview-12-2025`, can be used to handle complex or multi-step tasks. For additional details, refer to the Deep Research guide.

>[!WARNING]
>- **Google Deep Research** is currently in beta. As such, users may encounter instability issues, including 504 errors, especially when submitting resource-intensive or highly complex research queries. In these situations, retrying the request or reformulating it to reduce computational demands is recommended.
>
>- The service appears to rely on infrastructure that is not yet fully isolated. It should therefore be treated as a best-effort or batch-oriented service.
>
>- In its current state, Google Deep Research is comparatively less mature, particularly when contrasted with an integration of OpenAI Deep Research that supports streaming execution with visible tool usage.  

<br>

```pascal
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Agent('deep-research-pro-preview-12-2025')
            .Input('Explain what the SU(3) group is.' )
            .Background(true);
          TutorialHub.JSONRequest := Params.ToFormat();
        end;

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitCreate(Params);

  Promise
    .&Then<string>(
      function (Value: TInteraction): string
      begin
        Result := Value.Id;
        Display(TutorialHub, Result);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
```

Once the request has been submitted, wait for the `INTERACTION_ID` (e.g. v1_ChcybEZSYWJt...ZpUUU) to be returned, indicating that the request is being processed.

This identifier must then be used to poll the status and retrieve the result using the [`Client.Interactions.AsyncAwaitRetrieve(INTERACTION_ID)`](interactions-CRUD.md#retrieving-an-interaction) method.

Result : status in progress

```json
{
    "agent": "deep-research-pro-preview-12-2025",
    "created": "2025-12-28T15:50:51Z",
    "id": "v1_ChcybEZSYWJtM05hZVVrZFVQcXFxNmlRRRIXMmxGUmFibTNOYWVVa2RVUHFxcTZpUUU",
    "object": "interaction",
    "role": "agent",
    "status": "in_progress",
    "updated": "2025-12-28T15:50:51Z"
}
```

Result : status completed

```json
{
    "agent": "deep-research-pro-preview-12-2025",
    "created": "2025-12-28T15:50:51Z",
    "id": "v1_ChcybEZSYWJtM05hZVVrZFVQcXFxNmlRRRIXMmxGUmFibTNOYWVVa2RVUHFxcTZpUUU",
    "object": "interaction",
    "outputs": [
        {
            "text": "# Le Groupe SU(3) : Structure Mathématique ...
```

>[!NOTE]
>It is currently not possible to monitor the progress of the research in real time.

