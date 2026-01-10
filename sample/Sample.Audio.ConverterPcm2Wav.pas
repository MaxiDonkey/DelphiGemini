unit Sample.Audio.ConverterPcm2Wav;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.IOUtils;

type
  TFfmpegConverter = record
  public
    class function ExecAndWait(const Command, Params: string): Boolean; static;
    class procedure ToWav(const AudioInput, AudioOutput: string;
      const Path: string = ''); static;
  end;

implementation

{ TFfmpegConverter }

class function TFfmpegConverter.ExecAndWait(const Command, Params: string): Boolean;
var
  SeI: TShellExecuteInfo;
begin
  ZeroMemory(@SeI, SizeOf(SeI));
  SeI.cbSize := SizeOf(SeI);
  SeI.fMask := SEE_MASK_NOCLOSEPROCESS;
  SeI.Wnd := 0;
  SeI.lpFile := PChar(Command);
  SeI.lpParameters := PChar(Params);
  SeI.nShow := SW_HIDE;

  Result := ShellExecuteEx(@SeI);
  if Result then
    begin
      WaitForSingleObject(sei.hProcess, INFINITE);
      CloseHandle(SeI.hProcess);
    end;
end;

class procedure TFfmpegConverter.ToWav(const AudioInput, AudioOutput, Path: string);
begin
  var ffmpegExe := TPath.Combine(ExpandFileName(Path), 'ffmpeg.exe');
  if not FileExists(ffmpegExe) then
    raise Exception.CreateFmt('ffmpeg.exe converter not found. Invalid path : %s', [path]);

  var params := Format('-f s16le -ar 24000 -ac 1 -i "%s" "%s"', [AudioInput, AudioOutput]);

  if not TFfmpegConverter.ExecAndWait(ffmpegExe, params) then
    raise Exception.CreateFmt('Error while executing %s', [ffmpegExe]);
end;

end.
