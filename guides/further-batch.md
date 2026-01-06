# Batch

The Batch API is used to execute large volumes of non-urgent requests asynchronously, with a ~50% cost reduction compared to the interactive API and a target completion time of ≤24 hours. 

You submit many requests together as a single batch job (either inline or via a JSONL file), then wait for the job to complete and retrieve the aggregated results.

#### Restrictions
- **Asynchronous / turnaround:** designed for non-urgent workloads, target completion ≤ 24h (often faster).
- **Hard expiration:** if a job remains pending or running for > 48h, it enters JOB_STATE_EXPIRED ⇒ no results can be retrieved, and the job must be resubmitted (or split).
- **Input limits:**
  - Inline: total batch request size ≤ 20 MB.
  - File input: JSONL via File API, ≤ 2 GB per file.
- **Output / parsing:** for file output (JSONL), each line may be either a successful response or an error/status object ⇒ partial success must be handled explicitly.
- **Non-idempotent creation:** submitting the same creation request twice creates two distinct jobs (risk of duplicates).

<br>

- [Batch job Creation](#batch-job-creation)
- [Batch job Listing](#batch-job-listing)
- [Retrieve results](#retrieve-results)
- [Batch job Cancellation](#batch-job-cancellation)
- [Batch job Deletion](#batch-job-deletion)
- [Result file Uploading](#result-file-uploading)

___

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## Batch job Creation
Creates a content-generation batch job. The payload includes a `batch` object with `displayName` and `inputConfig`, which references either inline requests or an uploaded file (`file_name`) from the File API.

#### Step 1 : The content of the JSON file to be uploaded via the Files API.

```json
{"key": "request-1", "request": {"contents": [{"parts": [{"text": "Describe the process of photosynthesis."}]}], "generation_config": {"temperature": 0.7}}}
{"key": "request-2", "request": {"contents": [{"parts": [{"text": "What are the main ingredients in a Margherita pizza?"}]}]}}
```

Use the Files API to [retrieve the name <sup>2</sup>](further-file-managment.md#get-metadata-for-a-file) of the [uploaded file <sup>1</sup>](further-file-managment.md#upload-a-file), for example: `Name = 'files/frh6ua11nk3o'`

<br>

#### Step 2 : Create the Batch

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var ModelName := 'gemini-2.5-flash';
  var DisplayName := 'files/frh6ua11nk3o';
  var FileName := 'files/nst3vx34zemo';


  //Json Payload
  var Payload: TProc<TBatchParams> :=
    procedure (Params: TBatchParams)
    begin
      Params.Batch(
        TBatchContentParams.Create
          .DisplayName(DisplayName)
          .InputConfig(
             TInputConfigParams.Create
               .FileName(FileName)
           )
      );
    end;


  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitCreate(ModelName, Payload);

  Promise
    .&Then<string>(
      function (Value: TOperation): string
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
//  var Value := Client.Batch.Create(ModelName, Payload);
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
    "name": "batches\/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3",
    "metadata": {
        "@type": "type.googleapis.com\/google.ai.generativelanguage.v1main.GenerateContentBatch",
        "model": "models\/gemini-2.5-flash",
        "displayName": "my batch name",
        "inputConfig": {
            "fileName": "files\/frh6ua11nk3o"
        },
        "createTime": "2026-01-06T11:09:11.943530657Z",
        "updateTime": "2026-01-06T11:09:11.943530657Z",
        "batchStats": {
            "requestCount": "2",
            "pendingRequestCount": "2"
        },
        "state": "BATCH_STATE_PENDING",
        "name": "batches\/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3"
    }
}
```

>[!IMPORTANT]
>Take note of the `Name = 'batches/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3'` property value, as it allows you to retrieve the associated batch job.


<br>

## Batch job Listing
Retrieves the job status and metadata (including `JOB_STATE_*`). Used for polling until a terminal state (SUCCEEDED / FAILED / CANCELLED / EXPIRED).

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);


  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitList;

  Promise
    .&Then<string>(
      function (Value: TOperationList): string
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
//  var Value := Client.Batch.List;
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Retrieve results
Downloads the results file when the job output is file-based (typically **JSONL**).

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var BatchName := 'batches/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3';

  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitRetrieve(BatchName);

  Promise
    .&Then<string>(
      function (Value: TOperation): string
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
//  var Value := Client.Batch.Retrieve(BatchName);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

JSON Result
```json
{
    "name": "batches\/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3",
    "metadata": {
        "@type": "type.googleapis.com\/google.ai.generativelanguage.v1main.GenerateContentBatch",
        "model": "models\/gemini-2.5-flash",
        "displayName": "my batch name",
        "inputConfig": {
            "fileName": "files\/frh6ua11nk3o"
        },
        "output": {
            "responsesFile": "files\/batch-leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3"
        },
        "createTime": "2026-01-06T11:09:11.943530657Z",
        "endTime": "2026-01-06T11:10:19.736868930Z",
        "updateTime": "2026-01-06T11:10:19.736868797Z",
        "batchStats": {
            "requestCount": "2",
            "successfulRequestCount": "2"
        },
        "state": "BATCH_STATE_SUCCEEDED",
        "name": "batches\/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3"
    },
    "done": true,
    "response": {
        "@type": "type.googleapis.com\/google.ai.generativelanguage.v1main.GenerateContentBatchOutput",
        "responsesFile": "files\/batch-leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3"
    }
}
```

>[!NOTE]
>- Here, the batch processing has completed successfully, as indicated by the `"state": "BATCH_STATE_SUCCEEDED" value.`
>- The processing results can then be retrieved using the value of the responsesFile property, which in this case is :
>   - `"responsesFile": "files/batch-leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3".`




<br>

## Batch job Cancellation
Cancels a running job, stopping processing of remaining requests (final state `JOB_STATE_CANCELLED`).

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var BatchName := 'batches/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3';


  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitCancel(BatchName);

  Promise
    .&Then<string>(
      function (Value: TBatchCancel): string
      begin
        Result := 'cancelled';
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Batch.Cancel(BatchName);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Batch job Deletion
Deletes a job: stops processing and removes it from the batch job list.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var BatchName := 'batches/leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3';

  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitDelete(BatchName);

  Promise
    .&Then<string>(
      function (Value: TBatchDelete): string
      begin
        Result := 'deleted';
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Batch.Delete(BatchName);
//
//  try
//    Display(TutorialHub, 'Batch deleted');
//  finally
//    Value.Free;
//  end;
```

<br>

## Result file Uploading
Initiates a resumeable upload and returns an upload URL (x-goog-upload-url) in the response headers.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);
  

  var FileName := 'files/batch-leg9wy9p5df66syjxke2eq4xfjqcwp47ejv3';
  var OutFileName := 'Result.jsonl';


  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitJsonlDownload(FileName);

  Promise
    .&Then<string>(
      function (Value: TJsonlDownload): string
      begin
        Result := 'Downloaded';
        Value.SaveToJsonl(OutFileName);
        Display(TutorialHub, Result);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Batch.JsonlDownload(FileName);
//
//  try
//    Value.SaveToJsonl(OutFileName);
//    Display(TutorialHub, 'Downloaded');
//  finally
//    Value.Free;
//  end;
```

<br>
