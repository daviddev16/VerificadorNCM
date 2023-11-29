program VerificadorNCMInvalido;

uses
  Vcl.Forms,
  Principal in 'Principal.pas' {MainForm},
  LeitoresTabelaNCM in 'LeitoresTabelaNCM.pas',
  GerenciadorLeitor in 'GerenciadorLeitor.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Verificador de NCM inexistente';
  TStyleManager.TrySetStyle('Luna');
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
