unit Gemini.Audio.Transcription;

{-------------------------------------------------------------------------------

      Github repository :  https://github.com/MaxiDonkey/DelphiGemini
      Visit the Github repository for the documentation and use examples

 ------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,  System.IOUtils,
  Gemini.API, Gemini.Async.Support, Gemini.Async.Promise, Gemini.Chat.Request,
  Gemini.Chat.Response, Gemini.Chat, Gemini.Exceptions;

type
  TTranscription = class(TChat)
  private
    FWavBase64: string;
    function GetPcmBase64: string;
  public
    property PcmBase64: string read GetPcmBase64;

    property WavBase64: string read FWavBase64 write FWavBase64;
  end;

  TAsynTranscription = TAsynCallBack<TTranscription>;

  TPromiseTranscription = TPromiseCallback<TTranscription>;

  TAbstractSupport = class(TGeminiAPIRoute)
  protected
    function TextToSpeech(const ModelName: string;
      const ParamProc: TProc<TChatParams>): TTranscription; virtual; abstract;
  end;

  TAsynchronousSupport = class(TAbstractSupport)
  protected
    procedure AsynTextToSpeech(const ModelName: string;
      const ParamProc: TProc<TChatParams>;
      const CallBacks: TFunc<TAsynTranscription>);
 end;

  TTranscriptionRoute = class(TAsynchronousSupport)
    function TextToSpeech(const ModelName: string;
      const ParamProc: TProc<TChatParams>): TTranscription; override;

    function AsyncAwaitTextToSpeech(const ModelName: string;
      const ParamProc: TProc<TChatParams>;
      const Callbacks: TFunc<TPromiseTranscription> = nil): TPromise<TTranscription>;
  end;

implementation

uses
  Gemini.Net.MediaCodec;

{ TTranscriptionRoute }

function TTranscriptionRoute.AsyncAwaitTextToSpeech(const ModelName: string;
  const ParamProc: TProc<TChatParams>;
  const Callbacks: TFunc<TPromiseTranscription>): TPromise<TTranscription>;
begin
  Result := TAsyncAwaitHelper.WrapAsyncAwait<TTranscription>(
    procedure(const CallbackParams: TFunc<TAsynTranscription>)
    begin
      AsynTextToSpeech(ModelName, ParamProc, CallbackParams);
    end,
    Callbacks);
end;

function TTranscriptionRoute.TextToSpeech(const ModelName: string;
  const ParamProc: TProc<TChatParams>): TTranscription;
begin
  Result := API.Post<TTranscription, TChatParams>(SetModel(ModelName, ':generateContent'), ParamProc);

  if Assigned(Result) then
    Result.WavBase64 := API.PcmB64ToWavFile(Result.PcmBase64);
end;

{ TAsynchronousSupport }

procedure TAsynchronousSupport.AsynTextToSpeech(const ModelName: string;
  const ParamProc: TProc<TChatParams>; const CallBacks: TFunc<TAsynTranscription>);
begin
  with TAsynCallBackExec<TAsynTranscription, TTranscription>.Create(CallBacks) do
  try
    Sender := Use.Param.Sender;
    OnStart := Use.Param.OnStart;
    OnSuccess := Use.Param.OnSuccess;
    OnError := Use.Param.OnError;
    Run(
      function: TTranscription
      begin
        Result := Self.TextToSpeech(ModelName, ParamProc);
      end);
  finally
    Free;
  end;
end;

{ TTranscription }

function TTranscription.GetPcmBase64: string;
begin
  Result := EmptyStr;
  if Length(Candidates) > 0 then
    if Assigned(Candidates[0].Content) and (Length(Candidates[0].Content.Parts) > 0) then
      Result := Candidates[0].Content.parts[0].InlineData.Data;
end;

end.
