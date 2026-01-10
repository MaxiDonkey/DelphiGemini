program Sample;

uses
  System.StartUpCopy,
  FMX.Forms,
  Main in 'Main.pas' {Form1},
  Sample.UrlOpen in 'Sample.UrlOpen.pas',
  Sample.IniManagment in 'Sample.IniManagment.pas',
  Sample.Audio.ConverterPcm2Wav in 'Sample.Audio.ConverterPcm2Wav.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
