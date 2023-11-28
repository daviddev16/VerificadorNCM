unit LeitorWeb;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.Net.HttpClient;

type

  { tipo uma struct hehe }
  TNCMUnTrib = record

    NCM            : Integer;
    UTribAbreviada : String;
    UTribDescricao : String;

  end;

  TLeitorCSVWeb = class

  private

    NCMUnTribArray : TList<TNCMUnTrib>;

    NetHTTPClient  : TNetHTTPClient;
    ConnURL        : String;
    TextoSefaz     : String;
    Versao         : String;
    Autor          : String;


    procedure ProcessarLinha(ConteudoLinha : String);
    procedure ProcessarStreamRequisicao(var Stream : TStream);

    function Localizar(NCMStr : String) : TNCMUnTrib;

  public

    constructor Create(URL : String);
    procedure Executar();

  end;

implementation

{ TLeitorCSVWeb }


function PesquisaBinaria(VlNCM : Integer) : Integer;
begin

end;

function TLeitorCSVWeb.Localizar(NCMStr : String) : TNCMUnTrib;
var
  VlNCM : Integer;
begin

end;

constructor TLeitorCSVWeb.Create(URL : String);
begin
  ConnURL := URL;
  NetHTTPClient := TNetHTTPClient.Create(nil);
end;

procedure TLeitorCSVWeb.Executar();
var
  ContentStream : TStream;
  StreamReader  : TStreamReader;
  LinhaAtual    : String;
begin
  if not Assigned(NetHTTPClient) and not (String.IsNullOrEmpty(ConnURL)) then
  begin

    ContentStream := NetHTTPClient.Get(ConnURL).ContentStream;

    if Assigned(ContentStream) then
    begin

      StreamReader := TStreamReader.Create(ContentStream);

      while not StreamReader.EndOfStream do
      begin

        LinhaAtual := StreamReader.ReadLine;

        if Not String.IsNullOrWhitespace(LinhaAtual) then
        begin
          ProcessarLinha(LinhaAtual);
        end;

      end;

    end;

  end
  else
  begin
    raise Exception.Create('Não foi possível iniciar uma requisição web.');
  end;
end;

procedure TLeitorCSVWeb.ProcessarStreamRequisicao(var Stream : TStream);
var
  StreamReader : TStreamReader;
begin
  StreamReader := TStreamReader.Create(Stream);
end;

procedure TLeitorCSVWeb.ProcessarLinha(ConteudoLinha : String);
var
  ValoresHeader   : TArray<String>;
  ValoresConteudo : TArray<String>;
begin

  if ConteudoLinha.StartsWith('@') then
  begin

    ConteudoLinha := ConteudoLinha.Substring(1);
    ValoresHeader := ConteudoLinha.Split([':']);

    Autor := ValoresHeader[0];
    Versao := ValoresHeader[1];
    TextoSefaz := ValoresHeader[2];

  end
  else
  begin
    ValoresConteudo := ConteudoLinha.Split([',']);

  end;


end;


end.
