# Vector Store Document

**Documents** are the persistent, File Search–side representations of imported files, broken into chunks that semantic retrieval can use.
They exist to organize, query, and manage the actually indexed data (embeddings), independently from the temporary raw files.

#### Structural constraints and limitations
- A **Document** belongs to a **File Search Store** and is made of ***Chunks***.

- **Conditional deletion:** you can’t delete a Document if it contains Chunks unless you set force=true.
- **Metadata limit:** at most 20 custom metadata entries per Document.
- **ID rules:** ID up to 40 characters, lowercase alphanumeric or hyphens, and cannot start/end with a hyphen.
- **Document lifecycle states:** *PENDING, ACTIVE, FAILED*

<br>

- [Document Listing](#document-listing)
- [Retrieve a document](#retrieve-a-document)
- [Delete a document](#delete-a-document)

___

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## Document Listing

Lists Documents in a **File Search Store**, with pagination.
Documents are sorted by ascending `document.create_time`.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var VectorName := 'fileSearchStores/first-vectorstore-hh58fgddzd0w';


  //Asynchronous promise example
  var Promise := Client.Documents.AsyncAwaitList(VectorName);

  Promise
    .&Then<string>(
      function (Value: TDocumentList): string
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
//  var Value := Client.Documents.List(VectorName);
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
    "documents": [
        {
            "name": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/documents\/k1lmltked3tp-d9144s0drobd",
            "updateTime": "2026-01-06T14:42:34.874697Z",
            "createTime": "2026-01-06T14:42:33.314253Z",
            "state": "STATE_ACTIVE",
            "sizeBytes": "37",
            "mimeType": "application\/json"
        },
        {
            "name": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/documents\/yso23muqnzd8-6ze3m0bgjh0a",
            "displayName": "yso23muqnzd8",
            "updateTime": "2026-01-06T15:03:51.801760Z",
            "createTime": "2026-01-06T15:03:49.700665Z",
            "state": "STATE_ACTIVE",
            "sizeBytes": "334640",
            "mimeType": "application\/pdf"
        }
    ]
}
``` 

>[!NOTE]
> The list of documents in the vector store is then retrieved.

<br>

## Retrieve a document

Fetches full information about a specific Document *(metadata, size, MIME type, timestamps, state)*.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Document := 'fileSearchStores/first-vectorstore-hh58fgddzd0w/documents/yso23muqnzd8-6ze3m0bgjh0a';


  //Asynchronous promise example
  var Promise := Client.Documents.AsyncAwaitRetrieve(Document);

  Promise
    .&Then<string>(
      function (Value: TDocument): string
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
//  var Value := Client.Documents.Retrieve(Document);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

JSON Result
```json
{
    "name": "fileSearchStores\/first-vectorstore-hh58fgddzd0w\/documents\/yso23muqnzd8-6ze3m0bgjh0a",
    "displayName": "yso23muqnzd8",
    "updateTime": "2026-01-06T15:03:51.801760Z",
    "createTime": "2026-01-06T15:03:49.700665Z",
    "state": "STATE_ACTIVE",
    "sizeBytes": "334640",
    "mimeType": "application\/pdf"
}
```

<br>

## Delete a document

Deletes a Document from a File Search Store.
If `force=true`, it also deletes all related Chunks; otherwise the call fails if Chunks exist.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var Document := 'fileSearchStores/first-vectorstore-hh58fgddzd0w/documents/yso23muqnzd8-6ze3m0bgjh0a';


  //Asynchronous promise example
  var Promise := Client.Documents.AsyncAwaitDeleteForced(Document);

  Promise
    .&Then<string>(
      function (Value: TDocumentDelete): string
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
//  var Value := Client.Documents.DeleteForced(Document);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```



