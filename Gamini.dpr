program Gamini;

uses
  Vcl.Forms,
  GeminiTest in 'GeminiTest.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles,
  Unit2 in 'Unit2.pas' {Form2},
  Gemini.GoogleSearch in 'source\Gemini.GoogleSearch.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows11 MineShaft');
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
