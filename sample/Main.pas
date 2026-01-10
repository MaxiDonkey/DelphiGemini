unit Main;

interface

uses
  Winapi.ShellAPI, Winapi.Windows,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.TabControl, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.DialogService, FMX.Objects, FMX.Edit, System.JSON, System.IOUtils,
  FMX.ComboEdit, FMX.ListBox,

  Sample.Key.Managment, Sample.UrlOpen, Sample.IniManagment,

  Gemini, Gemini.Types, Gemini.Helpers, Gemini.Functions.Example, Gemini.Tutorial.FMX,
  Gemini.Async.Promise,

  Sample.Audio.ConverterPcm2Wav;

const
  OPERATIONID_HINT =
    'Gets the latest state of a long-running operation.' + sLineBreak +
    'Clients can use this method to poll the operation result' + sLineBreak +
    'at intervals as recommended by the API service.';

  FILE_SEARCH_HINT =
    'See the next section : Files && Vector Store';

  FILE_SEARCH_HELP =
    'Go to the "Files & Vector Store" section' + sLineBreak +
    '  1. Upload a file - "Files Managment" section' + sLineBreak +
    '  2. Create a "Vector store file"' + sLineBreak +
    '  3. Import operation';

  BATCH_CREATION_HELP =
    'Go to the "Files & Vector Store" section' + sLineBreak +
    '  1. Upload a file - "Files Managment" section';

  BATCH_JSON_DOWNLOAD_HELP =
    'Use the "retrieve" function to retrieve the name of the file to download.';

type
  TForm1 = class(TForm)
    Panel2: TPanel;
    Memo1: TMemo;
    Memo2: TMemo;
    Button1: TButton;
    Splitter2: TSplitter;
    Panel3: TPanel;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Panel1: TPanel;
    TabItem2: TTabItem;
    Label1: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button6: TButton;
    Button7: TButton;
    Label2: TLabel;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Label3: TLabel;
    Button2: TButton;
    Button12: TButton;
    Button13: TButton;
    Label4: TLabel;
    Memo5: TMemo;
    TabItem3: TTabItem;
    Label5: TLabel;
    Button14: TButton;
    Memo6: TMemo;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Panel4: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    Button18: TButton;
    Button19: TButton;
    Label8: TLabel;
    Button20: TButton;
    Label9: TLabel;
    Button21: TButton;
    Button22: TButton;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    TabItem4: TTabItem;
    Label14: TLabel;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Label15: TLabel;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button30: TButton;
    Button31: TButton;
    Button32: TButton;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Button33: TButton;
    Label20: TLabel;
    Button34: TButton;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Button35: TButton;
    TabItem5: TTabItem;
    Label21: TLabel;
    Label29: TLabel;
    Text1: TText;
    Label30: TLabel;
    Button36: TButton;
    Button37: TButton;
    Button38: TButton;
    Button39: TButton;
    Label32: TLabel;
    Button40: TButton;
    Button41: TButton;
    Button42: TButton;
    Button43: TButton;
    Label31: TLabel;
    Button44: TButton;
    Button45: TButton;
    Button46: TButton;
    Label33: TLabel;
    Button47: TButton;
    Button48: TButton;
    Button49: TButton;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    OpenDialog1: TOpenDialog;
    VectorStoreID: TEdit;
    FileID: TEdit;
    OperationID: TEdit;
    TabItem6: TTabItem;
    Label37: TLabel;
    Label38: TLabel;
    TabItem7: TTabItem;
    Label39: TLabel;
    Label40: TLabel;
    Panel5: TPanel;
    Memo3: TMemo;
    Panel6: TPanel;
    Memo4: TMemo;
    Splitter1: TSplitter;
    Panel8: TPanel;
    Panel9: TPanel;
    Text2: TText;
    Text3: TText;
    Label41: TLabel;
    Label42: TLabel;
    Button50: TButton;
    Button51: TButton;
    Button5: TButton;
    Button52: TButton;
    Label43: TLabel;
    Button53: TButton;
    Button54: TButton;
    Label44: TLabel;
    Button55: TButton;
    Button56: TButton;
    Button57: TButton;
    Button58: TButton;
    Button59: TButton;
    Label45: TLabel;
    Button60: TButton;
    Button61: TButton;
    Button62: TButton;
    Button63: TButton;
    Button64: TButton;
    Button65: TButton;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    Label49: TLabel;
    Button66: TButton;
    Button67: TButton;
    Button68: TButton;
    Button69: TButton;
    Label50: TLabel;
    Button70: TButton;
    Button71: TButton;
    Label51: TLabel;
    Label52: TLabel;
    TabControl2: TTabControl;
    TabItem8: TTabItem;
    Label53: TLabel;
    Panel7: TPanel;
    Panel10: TPanel;
    Memo7: TMemo;
    Panel11: TPanel;
    Text4: TText;
    Panel12: TPanel;
    Memo8: TMemo;
    Panel13: TPanel;
    Text5: TText;
    Splitter3: TSplitter;
    TabItem9: TTabItem;
    Label54: TLabel;
    Button72: TButton;
    Button73: TButton;
    Button74: TButton;
    Button75: TButton;
    Label55: TLabel;
    Button76: TButton;
    Button77: TButton;
    Button78: TButton;
    Button79: TButton;
    Label56: TLabel;
    Button80: TButton;
    Button81: TButton;
    Button82: TButton;
    Label57: TLabel;
    Memo9: TMemo;
    Label58: TLabel;
    Label59: TLabel;
    Label60: TLabel;
    TabItem10: TTabItem;
    Label61: TLabel;
    Button83: TButton;
    Memo10: TMemo;
    Button84: TButton;
    Button85: TButton;
    Button86: TButton;
    Button87: TButton;
    Button88: TButton;
    Label62: TLabel;
    Button89: TButton;
    Label63: TLabel;
    Button90: TButton;
    Button91: TButton;
    Label64: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    Label67: TLabel;
    Label68: TLabel;
    TabItem11: TTabItem;
    Label69: TLabel;
    Button92: TButton;
    Button93: TButton;
    Button94: TButton;
    Button95: TButton;
    Label70: TLabel;
    Button96: TButton;
    Button97: TButton;
    Button98: TButton;
    Button99: TButton;
    Button100: TButton;
    Button101: TButton;
    Label71: TLabel;
    Label72: TLabel;
    Label73: TLabel;
    Label74: TLabel;
    Button102: TButton;
    Label75: TLabel;
    Button103: TButton;
    Label76: TLabel;
    Label77: TLabel;
    Button104: TButton;
    TabItem12: TTabItem;
    Label78: TLabel;
    Label79: TLabel;
    Label80: TLabel;
    Button105: TButton;
    Button106: TButton;
    Button107: TButton;
    Button108: TButton;
    Label81: TLabel;
    Button109: TButton;
    Button110: TButton;
    Button111: TButton;
    Button112: TButton;
    Label82: TLabel;
    Button113: TButton;
    Button114: TButton;
    Button115: TButton;
    Label83: TLabel;
    Button116: TButton;
    Button117: TButton;
    Button118: TButton;
    Label84: TLabel;
    Label85: TLabel;
    Label86: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    TabItem13: TTabItem;
    Label87: TLabel;
    Label88: TLabel;
    Label89: TLabel;
    Button119: TButton;
    Button120: TButton;
    Label90: TLabel;
    Button121: TButton;
    Button122: TButton;
    Label91: TLabel;
    Button123: TButton;
    Button124: TButton;
    Button125: TButton;
    Button126: TButton;
    Button127: TButton;
    Label92: TLabel;
    Button128: TButton;
    Button129: TButton;
    Button130: TButton;
    Button131: TButton;
    Button132: TButton;
    Button133: TButton;
    Label93: TLabel;
    Label94: TLabel;
    Label95: TLabel;
    Label96: TLabel;
    TabItem14: TTabItem;
    Label97: TLabel;
    Label98: TLabel;
    Label99: TLabel;
    Button134: TButton;
    Label100: TLabel;
    Button135: TButton;
    Button136: TButton;
    Label101: TLabel;
    Label102: TLabel;
    Label103: TLabel;
    Button137: TButton;
    Button138: TButton;
    Button139: TButton;
    Button140: TButton;
    Label104: TLabel;
    Label105: TLabel;
    Button141: TButton;
    Button142: TButton;
    Label106: TLabel;
    BatchFile: TEdit;
    VideoID: TEdit;
    VideoUri: TEdit;
    Label107: TLabel;
    Label108: TLabel;
    Text6: TText;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button4Click(Sender: TObject);
    procedure TabControl1Change(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label6Click(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Label10Click(Sender: TObject);
    procedure Label11Click(Sender: TObject);
    procedure Label12Click(Sender: TObject);
    procedure Label13Click(Sender: TObject);
    procedure Label16Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    procedure Label18Click(Sender: TObject);
    procedure Label20Click(Sender: TObject);
    procedure Button23Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button34Click(Sender: TObject);
    procedure Button33Click(Sender: TObject);
    procedure Label34Click(Sender: TObject);
    procedure Label35Click(Sender: TObject);
    procedure Label36Click(Sender: TObject);
    procedure Button37Click(Sender: TObject);
    procedure Button36Click(Sender: TObject);
    procedure Button38Click(Sender: TObject);
    procedure Button39Click(Sender: TObject);
    procedure Button40Click(Sender: TObject);
    procedure Button41Click(Sender: TObject);
    procedure Button42Click(Sender: TObject);
    procedure Button43Click(Sender: TObject);
    procedure Button44Click(Sender: TObject);
    procedure Button46Click(Sender: TObject);
    procedure OperationIDValidate(Sender: TObject; var Text: string);
    procedure Button45Click(Sender: TObject);
    procedure FileIDValidate(Sender: TObject; var Text: string);
    procedure VectorStoreIDValidate(Sender: TObject; var Text: string);
    procedure Button47Click(Sender: TObject);
    procedure Button48Click(Sender: TObject);
    procedure Button49Click(Sender: TObject);
    procedure Button35Click(Sender: TObject);
    procedure Button50Click(Sender: TObject);
    procedure Button51Click(Sender: TObject);
    procedure Button52Click(Sender: TObject);
    procedure Label46Click(Sender: TObject);
    procedure Label47Click(Sender: TObject);
    procedure Label48Click(Sender: TObject);
    procedure Label49Click(Sender: TObject);
    procedure Button66Click(Sender: TObject);
    procedure Button67Click(Sender: TObject);
    procedure Button68Click(Sender: TObject);
    procedure Label102Click(Sender: TObject);
    procedure Label103Click(Sender: TObject);
    procedure Label105Click(Sender: TObject);
    procedure Label106Click(Sender: TObject);
    procedure Button53Click(Sender: TObject);
    procedure Button54Click(Sender: TObject);
    procedure Button55Click(Sender: TObject);
    procedure Button56Click(Sender: TObject);
    procedure Button57Click(Sender: TObject);
    procedure Button58Click(Sender: TObject);
    procedure Button59Click(Sender: TObject);
    procedure Button60Click(Sender: TObject);
    procedure Button61Click(Sender: TObject);
    procedure Button62Click(Sender: TObject);
    procedure Button63Click(Sender: TObject);
    procedure Button64Click(Sender: TObject);
    procedure Button65Click(Sender: TObject);
    procedure Button134Click(Sender: TObject);
    procedure Button135Click(Sender: TObject);
    procedure Button136Click(Sender: TObject);
    procedure Button137Click(Sender: TObject);
    procedure Button138Click(Sender: TObject);
    procedure Button139Click(Sender: TObject);
    procedure Button140Click(Sender: TObject);
    procedure Label107Click(Sender: TObject);
    procedure Label108Click(Sender: TObject);
    procedure Button141Click(Sender: TObject);
    procedure Button142Click(Sender: TObject);
  private
    Client: IGemini;
    FPageIndex: Integer;
    procedure PageUpdate;
    procedure NextPage;
    procedure PreviousPage;
    function CanStore: Boolean;
    procedure SetPageIndex(const Value: Integer);
  public
    procedure PromptRefresh(const Value: string);
    procedure StartRun;
    procedure ContinueRun;
    procedure CallFunction(const Value: TFunctionCallPart; Func: IFunctionCore);
    function InteractionIDExists: Boolean;
    procedure OpenWithNotepad(const FileName: string);
    procedure OpenExternalWindows(const FileName: string);
    property PageIndex: Integer read FPageIndex write SetPageIndex;
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

function GetFunctionResult(const Value: TInteraction;
  out Name: string;
  out CallId: string;
  out Arguments: string): Boolean;
begin
  for var Item in Value.Outputs do
    begin
      case Item.&Type of
        TContentType.function_call:
          begin
            Arguments := Item.Arguments;
            Name := Item.Name;
            CallId := Item.Id;
            Exit(True);
          end;
      end;
    end;
  Result := False;
end;

function GetWeatherFromLocation(const JSONLocation: string): string;
begin
  // Do something
  Result := JSONLocation;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  StartRun;

  var AudioLocation := '..\media\Sample.wav';
  var Base64 := TMediaCodec.EncodeBase64(AudioLocation);
  var MimeType := TMediaCodec.GetMimeType(AudioLocation);

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Process the audio file and generate a transcription';
  PromptRefresh(Prompt);

  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
           .AddParts( Generation.Parts
               .AddInlineData(Base64, MimeType)
               .AddText(Prompt)
           )
        );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Synchronous example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Params);

  Promise
    .&Then(
      procedure (Value: TChat)
      begin
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button11Click(Sender: TObject);
begin
  StartRun;

  var PdfLocation := '..\media\File_Search_file.pdf';
  var Base64 := TMediaCodec.EncodeBase64(PdfLocation);
  var MimeType := TMediaCodec.GetMimeType(PdfLocation);

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What is the subject matter of this document and what areas does it cover?';
  PromptRefresh(Prompt);

  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
           .AddParts( Generation.Parts
               .AddInlineData(Base64, MimeType)
               .AddText(Prompt)
           )
        );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Synchronous example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Params);

  Promise
    .&Then(
      procedure (Value: TChat)
      begin
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button12Click(Sender: TObject);
begin
  StartRun;

  var ModelName := 'gemini-3-flash-preview';
  var Prompt := 'What is the sum of the first 50 prime numbers? Generate and run code for the calculation, and make sure you get all 50.';
  PromptRefresh(Prompt);

  //JSON payload generation
  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( TGeneration.Contents
            .AddParts( TGeneration.Parts
                .AddText(Prompt)
            )
         )
        .Tools( Generation.Tools
            .AddCodeExecution()
        )
        .GenerationConfig( TGeneration.AddConfig
           .ThinkingConfig(TGeneration.Config.AddThinkingConfig
               .ThinkingLevel('low')
               .IncludeThoughts(True)
           )
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Streaming Callback
  var SessionCallbacks: TFunc<TPromiseChatStream> :=
    function : TPromiseChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;

      Result.OnProgress :=
        procedure (Sender: TObject; Chunk: TChat)
        begin
          DisplayStream(Sender, Chunk);
        end;

      Result.OnDoCancel := DoCancellation;

      Result.OnCancellation :=
        function (Sender: TObject): string
        begin
          Cancellation(Sender);
        end
    end;

  //Asynchronous promise example
  var Promise := Client.Chat.AsyncAwaitCreateStream(ModelName, Params, SessionCallbacks);

  Promise
    .&Then<string>(
      function (Value: string): string
      begin
        Result := Value;
        ShowMessage(Value.Split(['.'])[0] + '...');
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button134Click(Sender: TObject);
begin
  StartRun;

  var Model := 'imagen-4.0-generate-001';
  var Filename := 'Imagen-4.0-sample01';
  var Prompt := 'A zoomed out photo of a small bag of coffee beans in a messy kitchen';
  PromptRefresh(Prompt);

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
         Display(TutorialHub, 'Image saved to: ' + LocalName + sLineBreak);
         OpenExternalWindows(LocalName);
         Inc(Cnt);
        end;
    end;


  //Asynchronous example
  var Promise := Client.Imagen.AsyncAwaitCreate(Model, Payload);

  Promise
  .&Then(
    procedure(Value: TImageGen)
    begin
      TutorialHub.JSONResponse := Value.JSONResponse;
      saveImagenToFile(Value);
      saveImagenToFile := nil;
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Display(TutorialHub, E.Message);
    end);
end;

procedure TForm1.Button135Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-pro-image-preview';
  var Prompt := 'Create a picture of a futuristic banana with neon lights in a cyberpunk city.';
  var OutputFileName := 'sample.png';
  PromptRefresh(Prompt);

  //JSON Payload
  var Payload: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
            .Addtext(Prompt)
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Image saveToFile
  var saveToFile: TProc<TChat> :=
    procedure (Value: TChat)
    begin
      for var Item in Value.Candidates do
       if Item.FinishReason = TFinishReason.STOP then
         for var SubItem in Item.Content.Parts do
           begin
             if Assigned(SubItem.InlineData) then
               begin
                 TMediaCodec.DecodeBase64ToFile(SubItem.InlineData.Data, OutputFileName);
                 Memo1.Lines.Text := Memo1.Text + sLineBreak + Format('Image saved as %s', [OutputFileName]);
                 OpenExternalWindows(OutputFileName);
               end;
           end;
    end;


  //Asynchronous Example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Payload);

  promise
    .&Then(
      procedure (Value: TChat)
      begin
        TutorialHub.JSONResponse := Value.JSONResponse;
        saveToFile(Value);
        saveToFile := nil;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

end;

procedure TForm1.Button136Click(Sender: TObject);
begin
  if not FileExists('sample.png') then
    begin
      ShowMessage('Use de "create" demonstration function before "editing" demonstration function.');
      Exit;
    end;

  StartRun;

  var Model := 'gemini-3-pro-image-preview';
  var Prompt := 'I want the banana to be smaller and suspended in the air above the city.';
  var ImageInFileName := 'sample.png';
  var ImageOutFileName := 'sampleModified.png';
  var Base64 := TMediaCodec.EncodeBase64(ImageInFileName);
  var MimeType := TMediaCodec.GetMimeType(ImageInFileName);
  PromptRefresh(Prompt);

  //JSON Payload
  var Payload: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
            .AddParts( Generation.Parts
              .AddInlineData(Base64, MimeType)
              .Addtext(Prompt)
            )
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Image saveToFile
  var saveToFile: TProc<TChat> :=
    procedure (Value: TChat)
    begin
      for var Item in Value.Candidates do
       if Item.FinishReason = TFinishReason.STOP then
         for var SubItem in Item.Content.Parts do
           begin
             if Assigned(SubItem.InlineData) then
               begin
                 TMediaCodec.DecodeBase64ToFile(SubItem.InlineData.Data, ImageOutFileName);
                 Memo1.Lines.Text := Memo1.Text + sLineBreak + Format('Image saved as %s', [ImageOutFileName]);
                 OpenExternalWindows(ImageOutFileName);
               end;
           end;
    end;


  //Asynchronous Example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Payload);

  promise
    .&Then(
      procedure (Value: TChat)
      begin
        OpenExternalWindows(ImageInFileName);
        TutorialHub.JSONResponse := Value.JSONResponse;
        saveToFile(Value);
        saveToFile := nil;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button137Click(Sender: TObject);
begin
  StartRun;

  var Model := 'veo-3.1-generate-preview';
  var Prompt := 'A close up of two people staring at a cryptic drawing on a wall, torchlight flickering. A man murmurs, This must be it. That''s the secret code. The woman looks at him and whispering excitedly, What did you find?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Payload: TProc<TVideoParams> :=
    procedure (Params: TVideoParams)
    begin
      Params
        .Instances( TVideoInstance.Create
            .AddItem( TVideoInstanceParams.Create
              .Prompt(Prompt)
             )
         )
        .Parameters( TVideoParameters.Create
             .DurationSeconds(8)
             .AspectRatio('16:9')
             .NegativePrompt('people, animals')
             .Resolution('1080p')
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous example
  var Promise := Client.Video.AsyncAwaitCreate(Model, Payload);

  Promise
    .&Then(
      procedure (Value: TVideoOpereration)
      begin
        TutorialHub.JSONResponse := Value.JSONResponse;
        Display(TutorialHub, Value.Name);
        TutorialHub.VideoID := Value.Name;
        VideoID.Text := TutorialHub.VideoID;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.VideoID := EmptyStr;
        VideoID.Text := TutorialHub.VideoID;
      end);
end;

procedure TForm1.Button138Click(Sender: TObject);
begin
  if TutorialHub.VideoID.IsEmpty then
      TutorialHub.VideoID := TInputContent.Text;

  if TutorialHub.VideoID.IsEmpty then
    Exit;

  StartRun;
  var Operation := TutorialHub.VideoID;


  //Asynchronous example
  var Promise := Client.Video.AsyncAwaitGetOperation(Operation);

  Promise
    .&Then(
      procedure (Value: TVideoOpereration)
      begin
        Display(TutorialHub, Value);

        if Value.Done then
          TutorialHub.VideoUri := Value.Uri[0]
        else
          TutorialHub.VideoUri := EMptyStr;

        VideoUri.Text := TutorialHub.VideoUri;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.VideoUri := EMptyStr;
        VideoUri.Text := TutorialHub.VideoUri;
      end);
end;

procedure TForm1.Button139Click(Sender: TObject);
begin
  if TutorialHub.VideoUri.IsEmpty then
      TutorialHub.VideoUri := TInputContent.Text;

  if TutorialHub.VideoUri.IsEmpty then
    Exit;

  StartRun;
  var Uri := TutorialHub.VideoUri;
  var OutFileName := 'Video_example.mp4';

  //Asynchronous Example
  var Promise := Client.Video.AsyncAwaitVideoDownload(Uri);

  Promise
    .&Then(
      procedure (Value: TVideo)
      begin
        Value.SaveToFile(OutFileName);
        Display(TutorialHub, Format('• OutFileName downloaded', [OutFileName]));
        OpenExternalWindows(OutFileName);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button13Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-2.5-flash-lite';
  var Prompt := 'What is the weather like in Paris, temperature in celcius?';
  PromptRefresh(Prompt);

  var Weather := TWeatherReportFunction.CreateInstance;

  var Chat := Client.Chat.Create(Model,
    procedure (Params: TChatParams)
    begin
      Params
        .Contents([TPayload.User(Prompt)])
        .Tools([Weather])
    end);
  try
    for var Item in Chat.Candidates do
      begin
        for var SubItem in Item.Content.Parts do
          begin
            if Assigned(SubItem.FunctionCall) then
              CallFunction(SubItem.FunctionCall, Weather)
            else
              Memo1.Lines.Text := Memo1.Text + #10 + SubItem.Text;
          end;
      end;
  finally
    Chat.Free;
  end;
end;

procedure TForm1.Button140Click(Sender: TObject);
begin
  StartRun;

  var FileName := 'dialogue_example.mp4';
  var Model := 'models/veo-3.1-generate-preview';
  var Prompt := 'A close up of two people staring at a cryptic drawing on a wall, torchlight flickering. A man murmurs, This must be it. That''s the secret code. The woman looks at him and whispering excitedly, What did you find?';
  PromptRefresh(Prompt);

  // JSON Payload
  var Payload: TProc<TVideoParams> :=
    procedure (Params: TVideoParams)
    begin
      Params
        .Instances(
          TVideoInstance.Create
            .AddItem( TVideoInstanceParams.Create
              .Prompt(Prompt)
             )
         )
        .Parameters(
           TVideoParameters.Create
             .DurationSeconds(8)
             .AspectRatio('16:9')
             .NegativePrompt('people, animals')
             .Resolution('1080p')
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous
  var Promise := Client.Video.AsyncAwaitGenerateToFile(Model, Payload, FileName);

  Promise
  .&Then(
    procedure(VideoStatus: TVideoStatus)
    begin
      Display(TutorialHub, 'Video saved to: ' + FileName);
      Display(TutorialHub, 'Operation: ' + VideoStatus.OperationName);
      Display(TutorialHub, 'Download URI: ' + VideoStatus.Uri[0]);
      OpenExternalWindows(FileName);
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Display(TutorialHub, E.Message);
    end);
end;

procedure TForm1.Button141Click(Sender: TObject);
begin
  StartRun;

  var Model       := 'gemini-2.5-flash-preview-tts';
  var Voice1      := 'Kore';
  var WavFileName := 'SingleSpeaker.wav';
  var Text := 'Say cheerfully: Have a wonderful day!';
  PromptRefresh(Text);

  //JSON Payload
  var Payload: TProc<TChatParams> :=
        procedure (Params: TChatParams)
        begin
          Params
            .Contents( Generation.Contents
                .AddParts( Generation.Parts
                    .AddText(Text)
                )
            )
            .GenerationConfig( SingleSpeakerConfig(Voice1) );
          TutorialHub.JSONRequest := Params.ToFormat();
        end;


  //Asynchronous Example
  var Promise := Client.Transcription.AsyncAwaitTextToSpeech(Model, Payload);

  Promise
  .&Then(
    procedure(Value: TTranscription)
    begin
      TutorialHub.JSONResponse := Value.JSONResponse;

      TMediaCodec.DecodeBase64ToFile(Value.WavBase64, WavFileName);

      Display(TutorialHub, Format('• %s generated', [WavFileName]));
      OpenExternalWindows(WavFileName);
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Memo1.Lines.Text := Memo1.Text +  E.Message;
    end);
end;

procedure TForm1.Button142Click(Sender: TObject);
begin
  StartRun;

  var Model       := 'gemini-2.5-flash-preview-tts';
  var Speaker1    := 'Jane';
  var Voice1      := 'Kore';
  var Speaker2    := 'Joe';
  var Voice2      := 'Sadaltager';
  var WavFileName := 'MultiSpeaker.wav';
  var Text := 'TTS the following conversation between Joe and Jane:' + sLineBreak +
              ' Joe: Hows it going today Jane? ' + sLineBreak +
              ' Jane: Not too bad, how about you?" ';
  PromptRefresh(Text);


  //JSON Payload
  var Payload: TProc<TChatParams> :=
        procedure (Params: TChatParams)
        begin
          Params
            .Contents( Generation.Contents
                .AddParts( Generation.Parts
                    .AddText(Text)
                )
            )
            .GenerationConfig( MultiSpeakerConfig(Speaker1, Voice1, Speaker2, Voice2) );
          TutorialHub.JSONRequest := Params.ToFormat();
        end;


  //Asynchronous Example
  var Promise := Client.Transcription.AsyncAwaitTextToSpeech(Model, Payload);

  Promise
  .&Then(
    procedure(Value: TTranscription)
    begin
      TutorialHub.JSONResponse := Value.JSONResponse;

      TMediaCodec.DecodeBase64ToFile(Value.WavBase64, WavFileName);

      Display(TutorialHub, Format('• %s generated', [WavFileName]));
      OpenExternalWindows(WavFileName);
    end)
  .&Catch(
    procedure(E: Exception)
    begin
      Memo1.Lines.Text := Memo1.Text + E.Message;
    end);
end;

procedure TForm1.Button14Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'From which version of Delphi were multi-line strings introduced?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
  procedure (Params: TInteractionParams)
  begin
    Params
      .Model(Model)
      .Input(Prompt);
    TutorialHub.JSONRequest := Params.ToFormat();
  end;


  // Synchronous example
  var Value := Client.Interactions.Create(Params);

  try
    Display(TutorialHub, Value);
  finally
    Value.Free;
  end;
end;

procedure TForm1.Button15Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'From which version of Delphi were multi-line strings introduced?';
  PromptRefresh(Prompt);


  //JSON Payload
  var Params: TProc<TInteractionParams> :=
  procedure (Params: TInteractionParams)
  begin
    Params
      .Model(Model)
      .Input(Prompt)
      .Stream;
    TutorialHub.JSONRequest := Params.ToFormat();
  end;

  //Streaming Callback
  var InteractionEvent: TInteractionEvent :=
    procedure (var Event: TInteractionStream; IsDone: Boolean; var Cancel: Boolean)
    begin
      if (not IsDone) and Assigned(Event) then
        begin
          DisplayStream(TutorialHub, Event);
        end;
    end;


  //Synchronous example
  Client.Interactions.CreateStream(Params, InteractionEvent);
end;

procedure TForm1.Button16Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'From which version of Delphi were multi-line strings introduced?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
      procedure (Params: TInteractionParams)
      begin
        Params
          .Model(Model)
          .Input(Prompt);
        TutorialHub.JSONRequest := Params.ToFormat();
      end;


  //Asynchronous promise example (MUTE)
  var Promise := Client.Interactions.AsyncAwaitCreate(Params); //NO Callback

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
end;

procedure TForm1.Button17Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What are the news stories of the day?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(Prompt)
            .Tools( Interactions.Tools
                .AddGoogleSearch()      //Google search enabled
            );
          TutorialHub.JSONRequest := Params.ToFormat();
        end;

  //Async Callbacks
  var Callbacks: TFunc<TPromiseInteraction> :=
    function : TPromiseInteraction
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnSuccess := DisplayIx;
      Result.OnError := DisplayIx;
    end;


  // Asynchronous promise example (with session callbacks)
  var Promise := Client.Interactions.AsyncAwaitCreate(Params, Callbacks);

  Promise
    .&Then<string>(
      function (Value: TInteraction): string
      begin
        Result := Value.Id;
        ShowMessage('ID = ' + Result);
        // Build a chain here with another promise if necessary
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button18Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What are the impacts of the SU(3) group in mathematics and then in physics?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
    procedure (Params: TInteractionParams)
    begin
      Params
        .Model(Model)
        .Input(Prompt)
        .GenerationConfig( Interactions.AddConfig
            .ThinkingSummaries('auto') //Include "thougth"
           )
        .Stream;
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Id);
        ShowMessage(Value.Thought);
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button19Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'How does AI work?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
  procedure (Params: TInteractionParams)
  begin
    Params
      .Model(Model)
      .Input(Prompt)
      .GenerationConfig( Interactions.AddConfig
          .ThinkingLevel('low')
          .ThinkingSummaries( TThinkingSummaries.auto )
      );
    TutorialHub.JSONRequest := Params.ToFormat();
  end;

  //Asynchronous promise example (MUTE)
  var Promise := Client.Interactions.AsyncAwaitCreate(Params);

  Promise
    .&Then<string>(
      function (Value: TInteraction): string
      begin
        Result := Value.Id;
        Display(TutorialHub, Value);
        TutorialHub.InteractionID := Value.Id;
        ShowMessage('interaction ID: ' + TutorialHub.InteractionID);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button20Click(Sender: TObject);
begin
  if not InteractionIDExists then
    Exit;

  ContinueRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Summarize your previous message in four relevant points.';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
  procedure (Params: TInteractionParams)
  begin
    Params
      .Model(Model)
      .Input(Prompt)
      .PreviousInteractionId(TutorialHub.InteractionID)  //Set the previous interaction ID
      .GenerationConfig( Interactions.AddConfig
          .ThinkingLevel('low')
          .ThinkingSummaries( TThinkingSummaries.auto )
      );
    TutorialHub.JSONRequest := Params.ToFormat();
  end;


  //Asynchronous promise example (MUTE)
  var Promise := Client.Interactions.AsyncAwaitCreate(Params);

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
end;

procedure TForm1.Button21Click(Sender: TObject);
begin
  if TutorialHub.InteractionID.IsEmpty then
    TutorialHub.InteractionID := TInputContent.Text;

  if TutorialHub.DeepResearchID.IsEmpty then
    Exit;

  StartRun;
  PromptRefresh(EmptyStr);

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitRetrieve(TutorialHub.InteractionID);

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
end;

procedure TForm1.Button22Click(Sender: TObject);
begin
  if TutorialHub.InteractionID.IsEmpty then
    TutorialHub.InteractionID := TInputContent.Text;

  StartRun;
  PromptRefresh(EmptyStr);

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitDelete(TutorialHub.InteractionID);

  Promise
    .&Then<string>(
      function (Value: TCRUDDeleted): string
      begin
        Result := 'Deleted';
        Display(TutorialHub, TutorialHub.InteractionID + '  deleted.');
        TutorialHub.InteractionID := EmptyStr;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button23Click(Sender: TObject);
begin
  StartRun;

  var ImageLocation := '..\media\Invoice.png';
  var Base64 := TMediaCodec.EncodeBase64(ImageLocation);
  var MimeType := TMediaCodec.GetMimeType(ImageLocation);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Describe the image in detail.';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs
                .AddImage(Base64, MimeType)
                .AddText(Prompt) )
            .GenerationConfig( Interactions.AddConfig
                .ThinkingSummaries( TThinkingSummaries.auto ) )
            .Stream;
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Thought);
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button24Click(Sender: TObject);
begin
  StartRun;

  var AudioLocation := '..\media\Sample.wav';
  var Base64 := TMediaCodec.EncodeBase64(AudioLocation);
  var MimeType := TMediaCodec.GetMimeType(AudioLocation);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What does this audio say?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs
                .AddAudio(Base64, MimeType)
                .AddText(Prompt) )
            .GenerationConfig( Interactions.AddConfig
                .ThinkingLevel('low') )
            .Stream;
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button25Click(Sender: TObject);
begin
  StartRun;

//  var VideoUri := 'https://www.youtube.com/watch?v=9hE5-98ZeCg';
//  var Model := 'gemini-3-flash-preview';
//  var Prompt := 'Please summarize the video in 3 sentences.';

  var VideoUri := '..\media\dialogue.mp4';
  var Base64 := TMediaCodec.EncodeBase64(VideoUri);
  var MimeType := TMediaCodec.GetMimeType(VideoUri);
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Please summarize the video in 3 sentences.';

  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs
                .AddVideo(Base64, MimeType)
                .AddText(Prompt)
             )
            .Stream;
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button26Click(Sender: TObject);
begin
  StartRun;

  var FilePath := '..\media\File_Search_file.pdf';
  var Base64 := TMediaCodec.EncodeBase64(FilePath);
  var MimeType := 'application/pdf';
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What is the subject matter of this document and what areas does it cover?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input( Interactions.Inputs
                .AddDocument(Base64, MimeType)
                .AddText(Prompt) )
            .GenerationConfig( Interactions.AddConfig
                .ThinkingSummaries( TThinkingSummaries.auto ) )
            .Stream;
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Thought);
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button27Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What is the weather in Paris?';
  PromptRefresh(Prompt);

  //JSON Paylod
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(Prompt)
            .Tools(
              TToolIx.Create()
                .AddFunction(
                  TfunctionIxParams.New
                    .Name('get_weather')
                    .Description('Gets the weather for a given location.')
                    .Parameters(
                      TSchemaParams.New
                        .&Type('object')
                        .Properties(
                          TSchemaParams.New
                            .Properties('location',
                              TSchemaParams.New
                                .&Type('string')
                                .Description('The city and state, e.g. San Francisco, CA')
                             )
                         )
                        .Required(['location'])
                     )
                 )
             );
          TutorialHub.JSONRequest := Params.ToFormat();
        end;


  // First Pass.
  var Promise := Client.Interactions.AsyncAwaitCreate(Params);

  Promise
    .&Then(
      // Extract function call + execute business logic
      function (Value: TInteraction): TPromise<TInteraction>
      var
        Id, Name, callId, Arguments: string;
      begin
        Id := Value.Id;

        if not GetFunctionResult(Value, Name, CallId, Arguments) then
          Exit(TPromise<TInteraction>.Resolved(nil));

        var Weather := GetWeatherFromLocation(Arguments);

        // Second Pass
        Result := Client.Interactions.AsyncAwaitCreate(
          procedure (Params: TInteractionParams)
             begin
               Params
                 .Model('gemini-3-flash-preview')
                 .Input(
                   TInput.Create()
                     .AddFunctionResult(Weather, Name, CallId)
                  )
                 .PreviousInteractionId(Id);
              end);
      end)
    .&Then(
      // Display final model response
      procedure (Value: TInteraction)
      begin
        if Assigned(Value) then
          Display(TutorialHub, Value)
        else
          Display(TutorialHub, 'no function called');
      end)
    .&Catch(
      // Error handling
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button28Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Who won the last Super Bowl?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(Prompt)
            .Tools( Interactions.Tools
                .AddGoogleSearch() )
            .Stream;
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button29Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Calculate the 50th Fibonacci number.';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(Prompt)
            .Tools( Interactions.Tools
                 .AddCodeExecution() )
            .Stream;
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What are the news stories of the day?';
  PromptRefresh(Prompt);

  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
           .AddParts( Generation.Parts
               .AddText(Prompt)
           )
        )
        .Tools( Generation.Tools
            .AddGoogleSearch()
        );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Synchronous example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Params);

  Promise
    .&Then(
      procedure (Value: TChat)
      begin
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button30Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Summarize the content of https://www.wikipedia.org/';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(Prompt)
            .Tools( Interactions.Tools
                .AddUrlContext() )
            .Stream;
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button31Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'What is the weather like in New York today?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
      procedure (Params: TInteractionParams)
      begin
        Params
          .Model(Model)
          .Input(Prompt)
          .Tools( Interactions.Tools
                .AddMcpServer(
                  TMcpServerIxParams.New
                    .Name('weather_service')
                    .Url('https://gemini-api-demos.uc.r.appspot.com/mcp')
                 )
             )
            .SystemInstruction('Today is ''' + FormatDateTime('dd"u"mmmm"t"yyyy', Date) +
                               ''' (' + FormatDateTime('yyyy-mm-dd', Date) + ').') ;
        TutorialHub.JSONRequest := Params.ToFormat();
      end;


  //Asynchronous promise example (MUTE)
  var Promise := Client.Interactions.AsyncAwaitCreate(Params); //NO Callback

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
end;

procedure TForm1.Button32Click(Sender: TObject);
begin
  StartRun;

  var Model := 'deep-research-pro-preview-12-2025';
  var Prompt := 'Explain what the SU(3) group is.';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Agent(Model)
            .Input(Prompt)
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
        TutorialHub.DeepResearchID := Result;
        Display(TutorialHub, Result);
        ShowMessage('Deep Research ID: ' + Value.Id);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button33Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Moderate the following content: ''Congratulations! You''ve won a free cruise. Click here to claim your prize: www.definitely-not-a-scam.com';
  PromptRefresh(Prompt);

  //JSON Payload
  var Params: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(Prompt)
            .ResponseFormat( TSchema.New
                 .&Type('object')
                 .Properties( TSchemaParams.New
                     .Properties('decision', TSchemaParams.New
                          .&Type('object')
                          .Properties( TJSONObject.Create
                               .AddPair('reason', TJSONObject.Create
                                   .AddPair('type', 'string')
                                   .AddPair('description', 'The reason why the content is considered spam.')
                                )
                               .AddPair('spam_type', TJSONObject.Create
                                   .AddPair('type', 'string')
                                   .AddPair('description', 'The type of spam.')
                                )
                           )
                          .Required(['reason', 'spam_type'])
                      )
                  )
                 .Required(['decision'])
             )
            .Stream;
          TutorialHub.JSONRequest := Params.ToFormat();
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Params, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button34Click(Sender: TObject);
begin
  if TutorialHub.DeepResearchID.IsEmpty then
    TutorialHub.DeepResearchID := TInputContent.Text;

  if TutorialHub.DeepResearchID.IsEmpty then
    Exit;

  StartRun;
  PromptRefresh(EmptyStr);

  //Asynchronous promise example
  var Promise := Client.Interactions.AsyncAwaitRetrieve(TutorialHub.DeepResearchID);

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
end;

procedure TForm1.Button35Click(Sender: TObject);
begin
  (*
      Files & Vector Store
        1. Upload à file
        2. Create a Vector store file
        3. Operation: Import
  *)

  if TutorialHub.VectorID.IsEmpty then
      TutorialHub.VectorID := TInputContent.Text;

  if TutorialHub.VectorID.IsEmpty then
    begin
      ShowMessage(FILE_SEARCH_HELP);
      Memo2.Text := FILE_SEARCH_HELP;
      Exit;
    end;

  StartRun;
  var StoreName := TutorialHub.VectorID;
  var Model := 'gemini-3-flash-preview';
  var Prompt := 'Was a differential geometry approach considered in this document, and if so, describe its nature.?';
  PromptRefresh(Prompt);

  //JSON Payload
  var Payload: TProc<TInteractionParams> :=
        procedure (Params: TInteractionParams)
        begin
          Params
            .Model(Model)
            .Input(Prompt)
            .Tools( Interactions.Tools
                .AddFileSearch( TFileSearchIxParams.New
                    .FileSearchStoreNames([StoreName])
                )
            )
            .Stream;
          TutorialHub.JSONRequest := Params.ToFormat();
        end;

  //Streaming SESSION callbacks
  var SessionCallbacks: TFunc<TPromiseInteractionStream> :=
    function : TPromiseInteractionStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;
      Result.OnProgress := DisplayStream;
      Result.OnDoCancel := DoCancellation;
      Result.OnCancellation := DoCancellationStream;
    end;


  //Asynchronous promise example with session callbacks
  var Promise := Client.Interactions.AsyncAwaitCreateStream(Payload, SessionCallbacks);

  Promise
    .&Then<TEventData>(
      function (Value: TEventData): TEventData
      begin
        Result := Value;
        ShowMessage(Value.Text);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button36Click(Sender: TObject);
begin
  StartRun;

  //Asynchronous promise example
  var Promise := Client.Files.AsyncAwaitList;

  Promise
    .&Then(
      procedure (Value: TFiles)
      begin
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button37Click(Sender: TObject);
begin
  var FilePath := EmptyStr;

  var BaseDir := ExtractFilePath(ParamStr(0));
  OpenDialog1.InitialDir := TPath.GetFullPath(TPath.Combine(BaseDir, '..\media'));
  if OpenDialog1.Execute then
    FilePath := OpenDialog1.FileName
  else
    Exit;

  StartRun;
  var DisplayName := 'document-pdf';

  //Asynchronous promise example
  var Promise := Client.Files.AsyncAwaitUpload(FilePath, DisplayName);

  Promise
    .&Then<string>(
      function (Value: TFile): string
      begin
        Result := Value.&File.Name;
        Display(TutorialHub, Value);
        TutorialHub.FileID := Value.&File.Name;
        FileID.Text := TutorialHub.FileID;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.FileID := EmptyStr;
        FileID.Text := TutorialHub.FileID;
      end);
end;

procedure TForm1.Button38Click(Sender: TObject);
begin
  if TutorialHub.FileID.IsEmpty then
      TutorialHub.FileID := TInputContent.Text;

  if TutorialHub.FileID.IsEmpty then
    Exit;

  StartRun;
  var Name := TutorialHub.FileID;

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
end;

procedure TForm1.Button39Click(Sender: TObject);
begin
  if TutorialHub.FileID.IsEmpty then
      TutorialHub.FileID := TInputContent.Text;

  if TutorialHub.FileID.IsEmpty then
    Exit;

  StartRun;
  var Name := TutorialHub.FileID;

  //Asynchronous promise example
  var Promise := Client.Files.AsyncAwaitDelete(Name);

  Promise
    .&Then<string>(
      function (Value: TFileDelete): string
      begin
        Result := 'File Deleted';
        Display(TutorialHub, Value);
        TutorialHub.FileID := EmptyStr;
        FileID.Text := TutorialHub.FileID;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.FileID := EmptyStr;
        FileID.Text := TutorialHub.FileID;
      end);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'From which version of Delphi were multi-line strings introduced?';
  PromptRefresh(Prompt);

  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
           .AddParts( Generation.Parts
               .AddText(Prompt)
           )
        );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Synchronous example
  var Chat := Client.Chat.Create(Model, Params);

  try
    Display(Memo1, Chat);
  finally
    Chat.Free;
  end;
end;

procedure TForm1.Button40Click(Sender: TObject);
begin
  StartRun;

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
        TutorialHub.VectorID := Value.Name;
        VectorStoreID.Text := TutorialHub.VectorID;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.VectorID := EmptyStr;
        VectorStoreID.Text := TutorialHub.VectorID;
      end);
end;

procedure TForm1.Button41Click(Sender: TObject);
begin
  StartRun;

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
end;

procedure TForm1.Button42Click(Sender: TObject);
begin
  if TutorialHub.VectorID.IsEmpty then
      TutorialHub.VectorID := TInputContent.Text;

  if TutorialHub.VectorID.IsEmpty then
    Exit;

  StartRun;
  var Name := TutorialHub.VectorID;

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
        TutorialHub.VectorID := EmptyStr;
      end);
end;

procedure TForm1.Button43Click(Sender: TObject);
begin
if TutorialHub.VectorID.IsEmpty then
      TutorialHub.VectorID := TInputContent.Text;

  if TutorialHub.VectorID.IsEmpty then
    Exit;

  StartRun;
  var Name := TutorialHub.VectorID;

  //Asynchronous promise example
  var Promise := Client.VectorFiles.AsyncAwaitDeleteForced(Name);

  Promise
    .&Then<string>(
      function (Value: TFileSearchStoreDelete): string
      begin
        Result := 'Deleted';
        Display(TutorialHub, Value);
        TutorialHub.VectorID := EmptyStr;
        VectorStoreID.Text := TutorialHub.VectorID;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.VectorID := EmptyStr;
        VectorStoreID.Text := TutorialHub.VectorID;
      end);
end;

procedure TForm1.Button44Click(Sender: TObject);
begin
  if not CanStore then
    Exit;

  StartRun;
  var VectorName := VectorStoreID.Text;
  var FileName := FileID.Text;

  //JSON Payload
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
end;

procedure TForm1.Button45Click(Sender: TObject);
begin
  if not CanStore then
    Exit;

  StartRun;
  var VectorName := VectorStoreID.Text;
  var FileName := FileID.Text;

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
        TutorialHub.OperationID := Value.Name;
        OperationID.Text := TutorialHub.OperationID;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.OperationID := EmptyStr;
        OperationID.Text := TutorialHub.OperationID;
      end);
end;

procedure TForm1.Button46Click(Sender: TObject);
begin
  if TutorialHub.OperationID.IsEmpty then
      TutorialHub.OperationID := TInputContent.Text;

  if TutorialHub.OperationID.IsEmpty then
    Exit;

  StartRun;
  var Operation := TutorialHub.OperationID;


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
end;

procedure TForm1.Button47Click(Sender: TObject);
begin
  if TutorialHub.VectorID.IsEmpty then
      TutorialHub.VectorID := TInputContent.Text;

  if TutorialHub.VectorID.IsEmpty then
    Exit;

  StartRun;
  var Name := TutorialHub.VectorID;


  //Asynchronous promise example
  var Promise := Client.Documents.AsyncAwaitList(Name);

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
end;

procedure TForm1.Button48Click(Sender: TObject);
begin
  if TutorialHub.DocumentID.IsEmpty then
      TutorialHub.DocumentID := TInputContent.Text;

  if TutorialHub.DocumentID.IsEmpty then
    Exit;

  StartRun;
  var Document := TutorialHub.DocumentID; //e.g. fileSearchStores/first-vectorstore-ze8442yz62gr/documents/9cdmcuon7j7s-sfy9opoobijs


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
end;

procedure TForm1.Button49Click(Sender: TObject);
begin
  if TutorialHub.DocumentID.IsEmpty then
      TutorialHub.DocumentID := TInputContent.Text;

  if TutorialHub.DocumentID.IsEmpty then
    Exit;

  StartRun;
  var Document := TutorialHub.DocumentID; //e.g. fileSearchStores/first-vectorstore-ze8442yz62gr/documents/9cdmcuon7j7s-sfy9opoobijs

  //Asynchronous promise example
  var Promise := Client.Documents.AsyncAwaitDeleteForced(Document);

  Promise
    .&Then<string>(
      function (Value: TDocumentDelete): string
      begin
        Result := 'Deleted';
        Display(TutorialHub, Value);
        TutorialHub.DocumentID := EmptyStr;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var SystemInstruction := 'You need to take a purely mathematical approach';
  var Prompt := 'How does AI work?';
  PromptRefresh(Prompt);

  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .SystemInstruction(SystemInstruction)
        .Contents( TGeneration.Contents
            .AddParts( TGeneration.Parts
                .AddText(Prompt)
            )
        )
        .GenerationConfig( TGeneration.AddConfig
           .ThinkingConfig(TGeneration.Config.AddThinkingConfig
               .ThinkingLevel('low')
               .IncludeThoughts(True) )
        );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Streaming Callback
  var ChatEvent: TChatEvent :=
    procedure (var Chat: TChat; IsDone: Boolean; var Cancel: Boolean)
    begin
      if (not IsDone) and Assigned(Chat) then
        begin
          DisplayStream(TutorialHub, Chat);
        end;
    end;

  //Synchronous example
  Client.Chat.CreateStream(Model, Params, ChatEvent);
end;

procedure TForm1.Button50Click(Sender: TObject);
begin
  StartRun;

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
end;

procedure TForm1.Button51Click(Sender: TObject);
begin
  var ModelName := TInputContent.Text;

  if ModelName.Trim.IsEmpty then
    Exit;

  StartRun;


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
end;

procedure TForm1.Button52Click(Sender: TObject);
begin
  TabControl1.TabIndex := 0;
end;

procedure TForm1.Button53Click(Sender: TObject);
begin
  StartRun;

  var ModelName := 'text-embedding-004';
  var StringArray: TArray<string> :=
    ['Hello', 'how', 'are you?'];

  //Json Paylod
  var Payload: TProc<TEmbeddingsParams> :=
    procedure (Params: TEmbeddingsParams)
    begin
      Params
        .Content(StringArray);
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous promise example
  var Promise := Client.Embeddings.AsyncAwaitCreate(ModelName, Payload);

  Promise
    .&Then<TArray<TArray<Double>>>(
       function (Value: TEmbedding): TArray<TArray<Double>>
       begin
         Display(TutorialHub, Value);
       end)
    .&Catch(
       procedure (E: Exception)
       begin
         Display(TutorialHub, E.Message);
       end);
end;

procedure TForm1.Button54Click(Sender: TObject);
begin
  StartRun;

  var ModelName := 'text-embedding-004';

  //Json Payload
  var Payload: TProc<TEmbeddingBatchParams> :=
    procedure (Params: TEmbeddingBatchParams)
    begin
      Params
        .Requests(
          TEmbeddingsBatch.Contents
            .AddItem(ModelName, ['Hello'])
            .AddItem(ModelName, ['how', 'are you?'])
          );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Asynchronous promise example
  var Promise := Client.Embeddings.AsyncAwaitCreateBatch(ModelName, Payload);

  Promise
    .&Then(
       procedure (Value: TEmbeddingList)
       begin
         Display(TutorialHub, Value);
       end)
    .&Catch(
       procedure (E: Exception)
       begin
         Display(TutorialHub, E.Message);
       end);
end;

procedure TForm1.Button55Click(Sender: TObject);
begin
  StartRun;

  var a11 := '..\media\a11.txt';
  var Base64 := TMediaCodec.EncodeBase64(a11);
  var MimeType := TMediaCodec.GetMimeType(a11);
  var systemInstruction := 'You are an expert on cache using with Claude (Anthropic).';
  var ttl := '800s';
  var Model := 'models/gemini-2.0-flash';

  // Json Payload
  var Payload: TProc<TCacheParams> :=
    procedure (Params: TCacheParams)
    begin
      Params.Contents( Generation.Contents
          .User( Generation.Parts
              .AddInlineData(Base64, MimeType)
          )
      );
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
        TutorialHub.CacheID := Value.Name;
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button56Click(Sender: TObject);
begin
  StartRun;

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

end;

procedure TForm1.Button57Click(Sender: TObject);
begin
  if TutorialHub.CacheID.IsEmpty then
      TutorialHub.CacheID := TInputContent.Text;

  if TutorialHub.CacheID.IsEmpty then
    Exit;

  StartRun;
  var CacheName := TutorialHub.CacheID;


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
end;

procedure TForm1.Button58Click(Sender: TObject);
begin
  if TutorialHub.CacheID.IsEmpty then
      TutorialHub.CacheID := TInputContent.Text;

  if TutorialHub.CacheID.IsEmpty then
    Exit;

  StartRun;
  var CacheName := TutorialHub.CacheID;
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
end;

procedure TForm1.Button59Click(Sender: TObject);
begin
  if TutorialHub.CacheID.IsEmpty then
      TutorialHub.CacheID := TInputContent.Text;

  if TutorialHub.CacheID.IsEmpty then
    Exit;

  StartRun;
  var CacheName := TutorialHub.CacheID;


  //Asynchronous promise example
  var Promise := Client.Caching.AsyncAwaitDelete(CacheName);

  Promise
    .&Then<string>(
      function (Value: TCacheDelete): string
      begin
        Result := 'Cache deleted';
        Display(TutorialHub, Result);
        TutorialHub.CacheID := EmptyStr;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.CacheID := EmptyStr;
      end);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  TabControl1.TabIndex := PageIndex;
end;

procedure TForm1.Button60Click(Sender: TObject);
begin
  Memo2.Lines.Text := BATCH_CREATION_HELP;

  if TutorialHub.FileID.IsEmpty then
      TutorialHub.FileID := TInputContent.Text;

  if TutorialHub.FileID.IsEmpty then
    Exit;

  StartRun;
  var ModelName := 'gemini-2.5-flash';
  var DisplayName := 'mybatch';
  var FileName := TutorialHub.FileID;

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
        TutorialHub.BatchID := Value.Name;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button61Click(Sender: TObject);
begin
  StartRun;

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
end;

procedure TForm1.Button62Click(Sender: TObject);
begin
  if TutorialHub.BatchID.IsEmpty then
      TutorialHub.BatchID := TInputContent.Text;

  if TutorialHub.BatchID.IsEmpty then
    Exit;

  StartRun;
  var BatchName := TutorialHub.BatchID;


  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitRetrieve(BatchName);

  Promise
    .&Then<string>(
      function (Value: TOperation): string
      begin
        Result := Value.Name;
        Display(TutorialHub, Value);
        if Value.Done then
          BatchFile.Text := Value.ResponseFile;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);

end;

procedure TForm1.Button63Click(Sender: TObject);
begin
  if TutorialHub.BatchID.IsEmpty then
      TutorialHub.BatchID := TInputContent.Text;

  if TutorialHub.BatchID.IsEmpty then
    Exit;

  StartRun;
  var BatchName := TutorialHub.BatchID;


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
end;

procedure TForm1.Button64Click(Sender: TObject);
begin
  if TutorialHub.BatchID.IsEmpty then
      TutorialHub.BatchID := TInputContent.Text;

  if TutorialHub.BatchID.IsEmpty then
    Exit;

  StartRun;
  var BatchName := TutorialHub.BatchID;

  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitDelete(BatchName);

  Promise
    .&Then<string>(
      function (Value: TBatchDelete): string
      begin
        Result := 'deleted';
        Display(TutorialHub, Value);
        TutorialHub.BatchID := EmptyStr;
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
        TutorialHub.BatchID := EmptyStr;
      end);
end;

procedure TForm1.Button65Click(Sender: TObject);
begin
  if BatchFile.Text.Trim.IsEmpty then
    begin
      Memo2.Text := BATCH_JSON_DOWNLOAD_HELP;
      Exit;
    end;

  if TutorialHub.BatchID.IsEmpty then
      TutorialHub.BatchID := TInputContent.Text;

  if TutorialHub.BatchID.IsEmpty then
    Exit;

  StartRun;
  var FileName := BatchFile.Text;
  var OutFileName := 'Result.jsonl';

  //Asynchronous promise example
  var Promise := Client.Batch.AsyncAwaitJsonlDownload(FileName);

  Promise
    .&Then<string>(
      function (Value: TJsonlDownload): string
      begin
        Result := Format('• %s downloaded', [OutFileName]);
        Value.SaveToJsonl(OutFileName);
        Display(TutorialHub, Result);
        Sleep(1000);
        OpenWithNotepad(OutFileName);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button66Click(Sender: TObject);
begin
  TabControl1.TabIndex := 1;
end;

procedure TForm1.Button67Click(Sender: TObject);
begin
  TabControl1.TabIndex := 2;
end;

procedure TForm1.Button68Click(Sender: TObject);
begin
  TabControl1.TabIndex := 4;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  StartRun;

  var Model := 'gemini-3-flash-preview';
  var Prompt := 'From which version of Delphi were multi-line strings introduced?';
  PromptRefresh(Prompt);

  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( Generation.Contents
           .AddParts( Generation.Parts
               .AddText(Prompt)
           )
        );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;


  //Synchronous example
  var Promise := Client.Chat.AsyncAwaitCreate(Model, Params);

  Promise
    .&Then(
      procedure (Value: TChat)
      begin
        Display(TutorialHub, Value);
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  StartRun;

  var ModelName := 'gemini-3-flash-preview';
  var SystemInstruction := 'You need to take a purely mathematical approach';
  var Prompt := 'How does AI work?';
  PromptRefresh(Prompt);

  //JSON payload generation
  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .SystemInstruction(SystemInstruction)
        .Contents( TGeneration.Contents
            .AddParts( TGeneration.Parts
                .AddText(Prompt)
            )
         )
        .GenerationConfig( TGeneration.AddConfig
           .ThinkingConfig(TGeneration.Config.AddThinkingConfig
               .ThinkingLevel('low')
               .IncludeThoughts(True)
           )
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Streaming Callback
  var SessionCallbacks: TFunc<TPromiseChatStream> :=
    function : TPromiseChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;

      Result.OnProgress :=
        procedure (Sender: TObject; Chunk: TChat)
        begin
          DisplayStream(Sender, Chunk);
        end;

      Result.OnDoCancel := DoCancellation;

      Result.OnCancellation :=
        function (Sender: TObject): string
        begin
          Cancellation(Sender);
        end
    end;

  //Asynchronous promise example
  var Promise := Client.Chat.AsyncAwaitCreateStream(ModelName, Params, SessionCallbacks);

  Promise
    .&Then<string>(
      function (Value: string): string
      begin
        Result := Value;
        ShowMessage(Value.Split(['.'])[0] + '...');
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  StartRun;

  var ImageLocation := '..\media\Invoice.png';
  var Base64 := TMediaCodec.EncodeBase64(ImageLocation);
  var MimeType := TMediaCodec.GetMimeType(ImageLocation);

  var ModelName := 'gemini-3-flash-preview';
  var Prompt := 'Describe the image.';
  PromptRefresh(Prompt);

  //JSON payload generation
  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( TGeneration.Contents
            .AddParts( TGeneration.Parts
                .AddInlineData(Base64, MimeType)
                .AddText(Prompt)
            )
         )
        .GenerationConfig( TGeneration.AddConfig
           .ThinkingConfig(TGeneration.Config.AddThinkingConfig
               .ThinkingLevel('low')
               .IncludeThoughts(True)
           )
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Streaming Callback
  var SessionCallbacks: TFunc<TPromiseChatStream> :=
    function : TPromiseChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;

      Result.OnProgress :=
        procedure (Sender: TObject; Chunk: TChat)
        begin
          DisplayStream(Sender, Chunk);
        end;

      Result.OnDoCancel := DoCancellation;

      Result.OnCancellation :=
        function (Sender: TObject): string
        begin
          Cancellation(Sender);
        end
    end;

  //Asynchronous promise example
  var Promise := Client.Chat.AsyncAwaitCreateStream(ModelName, Params, SessionCallbacks);

  Promise
    .&Then<string>(
      function (Value: string): string
      begin
        Result := Value;
        ShowMessage(Value.Split(['.'])[0] + '...');
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  StartRun;

  var VideoLocation := '..\media\dialogue.mp4';
  var Base64 := TMediaCodec.EncodeBase64(VideoLocation);
  var MimeType := TMediaCodec.GetMimeType(VideoLocation);

  var ModelName := 'gemini-3-flash-preview';
  var Prompt := 'Summarize this video. Then create a quiz with an answer key based on the information in this video.';
  PromptRefresh(Prompt);

  //JSON payload generation
  var Params: TProc<TChatParams> :=
    procedure (Params: TChatParams)
    begin
      Params
        .Contents( TGeneration.Contents
            .AddParts( TGeneration.Parts
                .AddInlineData(Base64, MimeType)
                .AddText(Prompt)
            )
         )
        .GenerationConfig( TGeneration.AddConfig
           .ThinkingConfig(TGeneration.Config.AddThinkingConfig
               .ThinkingLevel('low')
               .IncludeThoughts(True)
           )
         );
      TutorialHub.JSONRequest := Params.ToFormat();
    end;

  //Streaming Callback
  var SessionCallbacks: TFunc<TPromiseChatStream> :=
    function : TPromiseChatStream
    begin
      Result.Sender := TutorialHub;
      Result.OnStart := Start;

      Result.OnProgress :=
        procedure (Sender: TObject; Chunk: TChat)
        begin
          DisplayStream(Sender, Chunk);
        end;

      Result.OnDoCancel := DoCancellation;

      Result.OnCancellation :=
        function (Sender: TObject): string
        begin
          Cancellation(Sender);
        end
    end;


  //Asynchronous promise example
  var Promise := Client.Chat.AsyncAwaitCreateStream(ModelName, Params, SessionCallbacks);

  Promise
    .&Then<string>(
      function (Value: string): string
      begin
        Result := Value;
        ShowMessage(Value.Split(['.'])[0] + '...');
      end)
    .&Catch(
      procedure (E: Exception)
      begin
        Display(TutorialHub, E.Message);
      end);
end;

procedure TForm1.CallFunction(const Value: TFunctionCallPart;
  Func: IFunctionCore);
begin
  var ArgResult := Func.Execute(Value.Args); // Argument Processing by the Plugin

  Client.Chat.ASynCreateStream('gemini-2.5-flash-lite',
    procedure (Params: TChatParams)
    begin
      Params.Contents([TPayload.Add(ArgResult)]);
    end,
    function : TAsynChatStream
    begin
      Result.OnProgress :=
        procedure (Sender: TObject; Chat: TChat)
        begin
          Memo1.Lines.Text := Memo1.Text + Chat.Candidates[0].Content.Parts[0].Text;
        end;

      Result.OnError :=
        procedure (Sender: TObject; Error: string)
        begin
          Memo1.Lines.Text := Memo1.Text + #10 + Error;
        end;
    end);
end;

function TForm1.CanStore: Boolean;
begin
  Result := not VectorStoreID.Text.Trim.IsEmpty and
            not FileID.Text.Trim.IsEmpty;
  if not Result then
    TDialogService.MessageDialog(
    'Vector store ID and File ID can(t be null.',
    TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
     procedure (const AResult: TModalResult)
     begin
       if VectorStoreID.Text.Trim.IsEmpty then
         VectorStoreID.SetFocus
       else
         FileID.SetFocus;
     end
     );
end;

procedure TForm1.ContinueRun;
begin
  TabControl1.TabIndex := 0;
  Display(TutorialHub, sLineBreak + sLineBreak);
  Display(TutorialHub, 'The next turn. Please wait...' + sLineBreak);
end;

procedure TForm1.FileIDValidate(Sender: TObject; var Text: string);
begin
  TutorialHub.FileID := Text;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not HttpMonitoring.IsBusy;
  if not CanClose then
    TDialogService.MessageDialog(
    'Requests are still in progress. Please wait for them to complete before closing the application.',
    TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;

  Client := TGeminiFactory.CreateInstance(API_KEY);
  TutorialHub := TFMXTutorialHub.Create(Client, Memo1, Memo2, Memo3, Memo4, Button1);

  Width := 1600;
  Height := 900;
  PageIndex := TAppIni.ReadInteger('General', 'pageIndex', 1);
  TabControl1.TabIndex := PageIndex;
  PageUpdate;
  OperationID.Hint := OPERATIONID_HINT;
  Button35.Hint := FILE_SEARCH_HINT;
  Button60.Hint := BATCH_CREATION_HELP;
  Button65.Hint := BATCH_JSON_DOWNLOAD_HELP;
  Button1.Visible := False;

  {--- Define the audio converter PCM to WAV }
  Client.API.SetConverter(procedure(const InputPcmPath, OutputWavPath: string)
    begin
      TFfmpegConverter.ToWav(InputPcmPath, OutputWavPath);
    end);
end;

function TForm1.InteractionIDExists: Boolean;
begin
  if TutorialHub.InteractionID.Trim.IsEmpty then
    begin
      TDialogService.MessageDialog(
        'No ID was found, please run "First turn" first to obtain an ID.',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOk], TMsgDlgBtn.mbOk, 0, nil);

      Exit(False);
    end;

  Result := True;
end;

procedure TForm1.Label102Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-imagen.md#imagen');
end;

procedure TForm1.Label103Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-nano-banana.md');
end;

procedure TForm1.Label105Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-video-veo.md#video-with-veo');
end;

procedure TForm1.Label106Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-speech-generation.md#speech-generation-text-to-speech');
end;

procedure TForm1.Label107Click(Sender: TObject);
begin
  OpenUrl('https://ai.google.dev/gemini-api/docs/video?example=dialogue');
end;

procedure TForm1.Label108Click(Sender: TObject);
begin
  OpenUrl('https://ai.google.dev/gemini-api/docs/speech-generation');
end;

procedure TForm1.Label10Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/interactions.md#response-generation');
end;

procedure TForm1.Label11Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/interactions-conversations.md#stateful-conversation');
end;

procedure TForm1.Label12Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/interactions.md#interactions-crud');
end;

procedure TForm1.Label13Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/generations.md#executing-a-generation');
end;

procedure TForm1.Label16Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/interactions-multimodal-understanding.md#multimodal-understanding');
end;

procedure TForm1.Label17Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/interactions-tools.md#interactions-tools');
end;

procedure TForm1.Label18Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/interactions-agents.md#agents');
end;

procedure TForm1.Label20Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/interactions.json-format.md#structured-output-json-schema');
end;

procedure TForm1.Label34Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-file-managment.md');
end;

procedure TForm1.Label35Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-vector-store.md#vector-store');
end;

procedure TForm1.Label36Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-vector-store-document.md#vector-store-document');
end;

procedure TForm1.Label46Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-models.md#models');
end;

procedure TForm1.Label47Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-embeddings.md#embeddings');
end;

procedure TForm1.Label48Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-caching.md#caching');
end;

procedure TForm1.Label49Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/further-batch.md#batch');
end;

procedure TForm1.Label4Click(Sender: TObject);
begin
  OpenUrl('https://github.com/MaxiDonkey/DelphiGemini/blob/main/guides/generations.md');
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
  PreviousPage;
end;

procedure TForm1.Label7Click(Sender: TObject);
begin
  NextPage;
end;

procedure TForm1.NextPage;
begin
  if TabControl1.TabIndex >= TabControl1.TabCount - 1 then
    begin
      PageUpdate;
      Exit;
    end;

  TabControl1.TabIndex := TabControl1.TabIndex + 1;
  if TabControl1.TabIndex > 0 then
    PageIndex := TabControl1.TabIndex;

  PageUpdate;
end;

procedure TForm1.OpenExternalWindows(const FileName: string);
begin
  ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOWNORMAL);
end;

procedure TForm1.OpenWithNotepad(const FileName: string);
begin
  if ShellExecute(0, 'open', 'notepad.exe', PChar(AnsiQuotedStr(FileName, '"')), nil, SW_SHOWNORMAL) <= 32 then
    raise Exception.Create('Unable to launch Notepad.');
end;

procedure TForm1.OperationIDValidate(Sender: TObject; var Text: string);
begin
  TutorialHub.OperationID := Text;
end;

procedure TForm1.PageUpdate;
begin
  case TabControl1.TabIndex of
    0:
      Text1.Text := 'JSON';
    1:
      Text1.Text := 'generateContent';
    2..3:
      Text1.Text := 'interactions';
    4:
      Text1.Text := 'Files && Vector Store';
    5:
      Text1.Text := 'Models/Embeddings/Caching/Batching';
    6:
      Text1.Text := 'ImaGen 4/Nano Banana/Veo/Speech'
  end;
end;

procedure TForm1.PreviousPage;
begin
  if TabControl1.TabIndex = 0 then
    begin
      PageUpdate;
      Exit;
    end;

  TabControl1.TabIndex := TabControl1.TabIndex - 1;
  if TabControl1.TabIndex > 0 then
    PageIndex := TabControl1.TabIndex;

  PageUpdate;
end;

procedure TForm1.PromptRefresh(const Value: string);
begin
  Memo2.Text := Value;
end;

procedure TForm1.SetPageIndex(const Value: Integer);
begin
  FPageIndex := Value;
  TAppIni.WriteInteger('General', 'pageIndex', FPageIndex);
end;

procedure TForm1.StartRun;
begin
  Button1.Visible := False;
  TutorialHub.JSONUIClear;
  TabControl1.TabIndex := 0;
  Display(TutorialHub, 'This may take a few seconds. Please wait...' + sLineBreak);
  Display(TutorialHub, sLineBreak);
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin
  if TabControl1.TabIndex = 0 then
    begin
      PageUpdate;
      Exit;
    end;

  PageIndex := TabControl1.TabIndex;
  PageUpdate;
end;

procedure TForm1.VectorStoreIDValidate(Sender: TObject; var Text: string);
begin
  TutorialHub.VectorID := Text;
end;

end.
