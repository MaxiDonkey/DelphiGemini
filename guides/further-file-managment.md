# Files Managment

Files lets you upload multimodal files (audio, images, video, documents, etc.) and reuse them inside prompts sent to Gemini models.

It is mainly intended for cases where the total request size exceeds 20 MB or when the same file needs to be referenced across multiple requests.

>[!NOTE]
>The typical flow is: upload file → get a file URI → use it in content generation.

#### Restrictions
- Maximum file size: 2 GB per file
- Maximum storage per project: 20 GB
- Retention period: 48 hours (automatic deletion)
- File download: not supported (files are only accessible via the API)
- Cost: free (in regions where the Gemini API is available)

<br>

- [Upload a file](#upload-a-file)
- [List uploaded files](#list-uploaded-files)
- [Get metadata for a file](#get-metadata-for-a-file)
- [Generate content with file](#generate-content-with-file)
- [Delete uploaded files](#delete-uploaded-files)

___

>[!IMPORTANT]
>These examples use TutorialHub. If needed, simply adapt the `Display` or `DisplayStream` display methods to fit your context.
>
>These examples can be found in the test application provided in the repository’s `sample` directory.

<br>

## Upload a file

Uploads a media file (audio, image, video, document) and returns a URI that can be reused in prompts.

### Upload example

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);

  var FilePath := '..\..\media\File_Search_file.pdf';
  var DisplayName := 'batch_file';


  //Asynchronous promise example
  var Promise := Client.Files.AsyncAwaitUpload(FilePath, DisplayName);

  Promise
    .&Then<string>(
      function (Value: TFile): string
      begin
        Result := Value.&File.Name;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Files.UpLoad(FilePath, DisplayName);
//  try
//    Display(Memo1, Value);
//  finally
//    Value.Free;
//  end;
```

JSON Result
```json
{
    "file": {
        "name": "files\/nst3vx34zemo",
        "displayName": "batch_file",
        "mimeType": "application\/pdf",
        "sizeBytes": "334640",
        "createTime": "2026-01-06T08:17:49.426944Z",
        "updateTime": "2026-01-06T08:17:49.426944Z",
        "expirationTime": "2026-01-08T08:17:48.680029535Z",
        "sha256Hash": "OTIwMWEzZTFlNTFjOTU0OTU3ZTFkYmM4MWU4ZmZkZWVmZDU1YWJkOWUzMWUzMmE0MGFlMmNmZmVmMmI4N2VmMg==",
        "uri": "https:\/\/generativelanguage.googleapis.com\/v1beta\/files\/nst3vx34zemo",
        "state": "ACTIVE",
        "source": "UPLOADED"
    }
}
```

<br>

## List uploaded files

Lists all files currently stored for a project.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);


  //Asynchronous promise example
  var Promise := Client.Files.AsyncAwaitList;

  Promise
    .&Then<string>(
      function (Value: TFiles): string
      begin
        Result := '';
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Files.List;
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

<br>

## Get metadata for a file

Retrieves metadata and status information for an uploaded file.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);  

  var Name := 'files/nst3vx34zemo';


  //Asynchronous promise example
  var Promise := Client.Files.AsyncAwaitRetrieve(Name);

  Promise
    .&Then<string>(
      function (Value: TFileContent): string
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
//  var Value := Client.Files.Retrieve(Name);
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```

JSON Result
```json
{
    "name": "files\/nst3vx34zemo",
    "displayName": "batch_file",
    "mimeType": "application\/pdf",
    "sizeBytes": "334640",
    "createTime": "2026-01-06T08:17:49.426944Z",
    "updateTime": "2026-01-06T08:17:49.426944Z",
    "expirationTime": "2026-01-08T08:17:48.680029535Z",
    "sha256Hash": "OTIwMWEzZTFlNTFjOTU0OTU3ZTFkYmM4MWU4ZmZkZWVmZDU1YWJkOWUzMWUzMmE0MGFlMmNmZmVmMmI4N2VmMg==",
    "uri": "https:\/\/generativelanguage.googleapis.com\/v1beta\/files\/nst3vx34zemo",
    "state": "ACTIVE",
    "source": "UPLOADED"
}
```

>[!IMPORTANT]
>The value of the `uri` property is the identifier to provide when using this file. 
>(*Make sure to remove any escape characters if present.*) 


<br>

## Generate content with file

Using the `uri` property value to reference the uploaded file in a JSON payload.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);  

  var Model := 'models/gemini-2.0-flash';
  var Prompt := 'Provide a summary of the attached document.';
  var Uri := 'https://generativelanguage.googleapis.com/v1beta/files/nst3vx34zemo';
  var TypeMime := 'application/pdf';


  // Json Payload
  var Payload: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
           .AddParts( Generation.Parts
               .AddText(Prompt)
               .AddFileData(Uri, TypeMime)
           )
        );
    end;


  //Synchronous example
  var Chat := Client.Chat.Create(Model, Payload);

  try
    Display(Memo1, Chat);
  finally
    Chat.Free;
  end;
```

<br>

## Delete uploaded files

Explicitly deletes an uploaded file before the automatic 48-hour expiration.

```pascal
  //uses Gemini, Gemini.Types, Gemini.Helpers, Gemini.Tutorial.VCL (*or Gemini.Tutorial.FMX*);  

  var Name := 'files/nst3vx34zemo';


  //Asynchronous promise example
  var Promise := Client.Files.AsyncAwaitDelete(Name);

  Promise
    .&Then<string>(
      function (Value: TFileDelete): string
      begin
        Result := 'File Deleted';
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);


  //Synchronous example
//  var Value := Client.Files.Delete(Name);
//
//  try
//    Display(TutorialHub, Value);
//  finally
//    Value.Free;
//  end;
```
