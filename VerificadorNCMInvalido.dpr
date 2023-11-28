program VerificadorNCMInvalido;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {Form2},
  LeitoresTabelaNCM in 'LeitoresTabelaNCM.pas';

{$R *.res}
{$APPTYPE CONSOLE}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
