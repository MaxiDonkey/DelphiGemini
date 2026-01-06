# Caching

Many applications repeatedly send the same input data to a model. To limit redundant processing and reduce costs, the Gemini API offers two complementary caching mechanisms.

- `Implicit caching` works automatically on most ***Gemini models*** and requires no configuration. When a request is served from cache, any associated cost savings are applied transparently, although savings are not guaranteed.

- `Explicit caching` allows input tokens to be stored once and reused across subsequent requests, ensuring predictable cost savings for sufficiently large inputs. Cached data is retained for a configurable time-to-live (TTL), which defaults to one hour, and `pricing depends` on both `input size` and `retention duration`.

<br>

- [Cache Creating](#cache-creating)
- [Cache listing](#cache-listing)
- [Cache Retrieving](#cache-retrieving)
- [Cache Updating](#cache-updating)
- [Cache Deletion](#cache-deletion)

___

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## Cache Creating

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  TutorialHub.JSONUIClear;
  var a11 := '..\..\media\a11.txt';
  var systemInstruction := 'You are an expert on cache using with Claude (Anthropic).';
  var ttl := '800s';
  var Model := 'models/gemini-2.0-flash';

  // Json Payload
  var Payload: TProc<TCacheParams> :=
    procedure (Params: TCacheParams)
    begin
      Params.Contents([TPayload.User([a11])]);
      Params.SystemInstruction(systemInstruction);
      Params.ttl(ttl);
      Params.Model(Model);
    end;

  //Asynchronous promise example
  var Promise := Client.Caching.AsyncAwaitCreate(Payload);

  Promise
    .&Then<string>(
      function (Value: TCache): string
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
//  var Value := Client.Caching.Create(Payload);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

JSON Result
```json
{
    "name": "cachedContents\/y3flvs2o4bc75v5esfc7gfbs1yqhgiujrtbsfo1w",
    "model": "models\/gemini-2.0-flash",
    "createTime": "2026-01-05T17:10:15.802595Z",
    "updateTime": "2026-01-05T17:10:15.802595Z",
    "expireTime": "2026-01-05T17:23:35.017454921Z",
    "displayName": "",
    "usageMetadata": {
        "totalTokenCount": 5819
    }
}
```

<br>

>[!WARNING]
> Since `models/gemini-2.0-flash` was selected when creating the cache, any request that reuses that cache must use the same model (`models/gemini-2.0-flash`). Otherwise, the API will return an error indicating the mismatch.

<br>

To use the cache, simply trigger a content generation through the generateContent endpoint by calling Client.Chat.Create (*synchronous or asynchronous, non-streaming or streaming*) and providing the following minimum payload:

```pascal
  var Model := 'models/gemini-2.0-flash';
  var Prompt := 'Provide a summary of cache management';

  var JsonChatPayload: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents(Prompt)
        .CachedContent('cachedContents/y3flvs2o4bc75v5esfc7gfbs1yqhgiujrtbsfo1w');
    end;

  // Cache using 
  var Caching := Client.Chat.Create(Model, JsonChatPayload);
  ...
```

>[!TIP]
>Media files audio, video, or images can also be cached, with or without associated system instructions.

<br>

## Cache listing

Cached content cannot be retrieved or viewed. However, cache metadata can be accessed, including the name, model, `displayName`, `usageMetadata`, and the `createTime`, `updateTime`, and `expireTime` timestamps.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  TutorialHub.JSONUIClear;

  //Asynchronous promise example
  var Promise := Client.Caching.AsyncAwaitList;

  Promise
    .&Then<string>(
      function (Value: TCacheContents): string
      begin
        Result := Value.NextPageToken;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Caching.List;
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Cache Retrieving

It is entirely possible to retrieve a cache entry using its identifier.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  TutorialHub.JSONUIClear;
  var CacheName := 'cachedContents/y3flvs2o4bc75v5esfc7gfbs1yqhgiujrtbsfo1w';

  //Asynchronous promise example
  var Promise := Client.Caching.AsyncAwaitRetrieve(CacheName);

  Promise
    .&Then<string>(
      function (Value: TCache): string
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
//  var Value := Client.Caching.Retrieve(CacheName);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Cache Updating

You can update a cache by setting a new `ttl` or `expireTime`. Modifying any other cache properties is not supported.

The following example demonstrates how to update the cache `ttl`.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  TutorialHub.JSONUIClear;
  var CacheName := 'cachedContents/y3flvs2o4bc75v5esfc7gfbs1yqhgiujrtbsfo1w';
  var TimeOut := '2700s';

  //Asynchronous promise example
  var Promise := Client.Caching.AsyncAwaitUpdate(CacheName, TimeOut);

  Promise
    .&Then<string>(
      function (Value: TCache): string
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
//  var Value := Client.Caching.Update(CacheName, TimeOut);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Cache Deletion

Content can be manually removed from the cache using the delete operation. The following example demonstrates how to delete a cache entry.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  TutorialHub.JSONUIClear;
  var CacheName := 'cachedContents/y3flvs2o4bc75v5esfc7gfbs1yqhgiujrtbsfo1w';

  //Asynchronous promise example
  var Promise := Client.Caching.AsyncAwaitDelete(CacheName);

  Promise
    .&Then<string>(
      function (Value: TCacheDelete): string
      begin
        Result := 'deleted';
        Display(TutorialHub, Result);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

  //Synchronous example
//  var Value := Client.Caching.Delete(CacheName);
//
//  try
//    Display(TutorialHub, 'deleted');
//  finally
//    Value.Free;
//  end;
```