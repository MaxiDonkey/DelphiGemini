program GeminiGoogle;

uses
  Vcl.Forms,
  GeminiTest in 'GeminiTest.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows11 MineShaft');
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
