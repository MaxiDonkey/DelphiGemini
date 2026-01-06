# Vector Store

The `File Search` of the Gemini API is a ***Retrieval Augmented Generation (RAG)*** mechanism that indexes documents as embeddings in order to provide relevant excerpts to the model during response generation.

Its goal is to improve the relevance, reliability, and traceability of generated answers by grounding them in a controlled document corpus.

#### Structural constraints and limitations
- **Data persistence:** Raw files uploaded through the Files API are deleted after 48 hours, while data imported into a File Search store is retained indefinitely until explicitly deleted.

- **Size limits**:
   - *Maximum file size: 100 MB*
   - *Project-wide quota (tier-dependent): from **1 GB** to **1 TB***
   - *Operational recommendation: keep each store **under 20 GB** to maintain **good retrieval latency**.*
- **Tool incompatibilities**: The `File Search` tool cannot be combined with other Gemini tools *(Google Search grounding, URL Context, etc.)*.
- **Cost model**:
   - *Embedding generation is billed only at indexing time*
   - *Storage and query-time embeddings are free of charge*
   - *Retrieved passages are billed as model context tokens

<br>

- [Vector store Creation](#vector-store-creation)
- [Vector store Listing](#vector-store-listing)
- [Vector store Retrieving](#vector-store-retrieving)
- [Vector store Deletion](#vector-store-deletion)
- [Upload](#upload)
- [Import](#import)
- [Asynchronous operation tracking](#asynchronous-operation-tracking)

___

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## Vector store Creation
Creates a persistent container used to store and index embeddings derived from documents.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);
  var DisplayName := 'first VectorStore';

  //Json Payload
  var Payload: TProc<TFileSearchStoreParams> :=
    procedure (Params: TFileSearchStoreParams)
    begin
      Params
        .DisplayName(DisplayName);
    end;


  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitCreate(Payload);

  Promise
    .&Then<string>(
      function (Value: TFileSearchStore): string
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
//  var Value := Client.VectorFiles.Create(Payload);
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
    "name": "fileSearchStores\/first-vectorstore-ovrri9954z60",
    "displayName": "first VectorStore",
    "createTime": "2026-01-06T14:13:13.323639Z",
    "updateTime": "2026-01-06T14:13:13.323639Z"
}
```

>[!IMPORTANT]
>- In the returned JSON, the name of the vector store is provided by the value of the Name property, in this case:
>  - name = 'fileSearchStores/first-vectorstore-ovrri9954z60'

<br>

## Vector store Listing
Lists all File Search stores associated with a project.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);


  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitList;

  Promise
    .&Then<string>(
      function (Value: TFileSearchStoreList): string
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
//  var Value := Client.VectorFiles.List;
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Vector store Retrieving
Retrieves metadata and configuration information for a specific store.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Name := 'fileSearchStores/first-vectorstore-ovrri9954z60';


  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitRetrieve(Name);

  Promise
    .&Then<string>(
      function (Value: TFileSearchStore): string
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
//  var Value := Client.VectorFiles.Retrieve(Name);
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
    "name": "fileSearchStores\/first-vectorstore-ovrri9954z60",
    "displayName": "first VectorStore",
    "createTime": "2026-01-06T14:13:13.323639Z",
    "updateTime": "2026-01-06T14:13:13.323639Z"
}
```

<br>

## Vector store Deletion
Deletes a store along with all associated embeddings and indexes.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var VectorName := 'fileSearchStores/first-vectorstore-ovrri9954z60';


  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitDeleteForced(VectorName);

  Promise
    .&Then<string>(
      function (Value: TFileSearchStoreDelete): string
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
//  var Value := Client.VectorFiles.DeleteForced(VectorName);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Upload
Uploads a file and directly imports it into a store in a single operation (chunking, embedding generation, and indexing).

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);


  var VectorName := 'fileSearchStores/first-vectorstore-hh58fgddzd0w';
  var FileName := 'files/frh6ua11nk3o';

  //Json Payload
  var Payload: TProc<TUploadFileParams> :=
    procedure (Params: TUploadFileParams)
    begin
      Params
        .DisplayName(FileName);
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitUpload(VectorName, Payload);

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
//  var Value := Client.VectorFiles.Upload(VectorName, Payload);
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
    "name": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/upload\/operations\/k1lmltked3tp-d9144s0drobd",
    "response": {
        "@type": "type.googleapis.com\/google.ai.generativelanguage.v1main.UploadToFileSearchStoreResponse",
        "parent": "fileSearchStores\/first-vectorstore-hh58fgddzd0w",
        "documentName": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/documents\/k1lmltked3tp-d9144s0drobd",
        "mimeType": "application\/json",
        "sizeBytes": "37"
    }
}
```

<br>

## Import
Imports into a store a file that was previously uploaded via the Files API.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var VectorName := 'fileSearchStores/first-vectorstore-hh58fgddzd0w';
  var FileName := 'files/yso23muqnzd8'; 

  var Payload: TProc<TImportFileParams> :=
    procedure (Params: TImportFileParams)
    begin
      Params
        .FileName(FileName);
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitImport(VectorName, Payload);

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
//  var Value := Client.VectorFiles.Import(VectorName, Payload);
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
    "name": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/upload\/operations\/krtddxmd74p0-vaklqxyw0zbd",
    "response": {
        "@type": "type.googleapis.com\/google.ai.generativelanguage.v1main.UploadToFileSearchStoreResponse",
        "parent": "fileSearchStores\/first-vectorstore-hh58fgddzd0w",
        "documentName": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/documents\/krtddxmd74p0-vaklqxyw0zbd",
        "mimeType": "application\/json",
        "sizeBytes": "37"
    }
}
```

>[!IMPORTANT]
>- The returned JSON provides an operation identifier:
>   - name = 'fileSearchStores/first-vectorstore-hh58fgddzd0w/operations/krtddxmd74p0-vaklqxyw0zbd'

<br>

## Asynchronous operation tracking
Polls the status of a long-running operation such as upload, import, or indexing.


```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Operation := 'fileSearchStores/first-vectorstore-hh58fgddzd0w/operations/krtddxmd74p0-vaklqxyw0zbd';


  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitOperationsGet(Operation);

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
//  var Value := Client.VectorFiles.OperationsGet(Operation);
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
    "name": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/operations\/krtddxmd74p0-vaklqxyw0zbd",
    "done": true,
    "response": {
        "@type": "type.googleapis.com\/google.ai.generativelanguage.v1main.ImportFileResponse",
        "parent": "first-vectorstore-hh58fgddzd0w",
        "documentName": "krtddxmd74p0-vaklqxyw0zbd"
    }
}
```

