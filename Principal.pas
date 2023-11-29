unit Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Diagnostics,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  LeitoresTabelaNCM,
  GerenciadorLeitor;

type
  TForm2 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);

  private

    LeitorCSV : TLeitorCSVBase;

  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}


procedure TForm2.Button1Click(Sender: TObject);
begin
  TGerenciador.LimparCacheLocal;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  LeitorCSV := TGerenciador.GetLeitorBase;
  ShowMessage(LeitorCSV.ClassName);
end;

end.
