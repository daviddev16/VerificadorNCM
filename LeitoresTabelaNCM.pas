unit LeitoresTabelaNCM;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Types,
  System.UITypes,
  System.Math,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.Net.HttpClient;

type

  EProcessoStreamException = class(Exception);

  { tipo uma struct hehe }
  TNCMUnTrib = record

    NCM            : Integer;
    UTribAbreviada : String;
    UTribDescricao : String;

  end;

  TLeitorCSVBase = class

    NCMUnTribLista : TList<TNCMUnTrib>;
    TextoSefaz     : String;
    Versao         : String;
    Autor          : String;

    private
      procedure ProcessarLinhaBase(ConteudoLinha : String);
      procedure ProcessarStreamBase(var Stream : TStream);
      function PesquisaBinaria(VlNCM : Integer; Min : Integer; Max : Integer) : Integer;

    public
      function Localizar(NCMStr : String) : TNCMUnTrib;
      constructor Create();
  end;

  TLeitorCSVWeb = class(TLeitorCSVBase)

    private
      NetHTTPClient  : TNetHTTPClient;
      ConnURL        : String;

    public
      procedure RequisitarInformacoes();
      constructor Create(ConnURL : String);

  end;

  TLeitorCSVArquivo = class(TLeitorCSVBase)
  {
    TODO: Armazenar dados localmente, apenas fazer a requisição novamente
          se for necessário.
  }
  end;

implementation

{ TLeitorCSVWeb }

constructor TLeitorCSVWeb.Create(ConnURL : String);
begin

  Self.ConnURL := ConnURL;
  NetHTTPClient := TNetHTTPClient.Create(nil);
  inherited Create;
end;

{
  Faz o processamentos das informações vindas de uma requisição GET, através
  da URL informada em ConnURL.
}
procedure TLeitorCSVWeb.RequisitarInformacoes();
var
  ContentStream : TStream;
begin
  if Assigned(NetHTTPClient) and not (String.IsNullOrEmpty(ConnURL)) then
  begin
    ContentStream := NetHTTPClient.Get(ConnURL).ContentStream;
    ProcessarStreamBase(ContentStream);
    FreeAndNil(ContentStream);
  end;
end;


{ TLeitorCSVBase }

constructor TLeitorCSVBase.Create();
begin
  NCMUnTribLista := TList<TNCMUnTrib>.Create;
end;

{
  Faz o processamento da Stream de origem por um TStreamReader que processa
  a informação linha-por-linha.
}
procedure TLeitorCSVBase.ProcessarStreamBase(var Stream : TStream);
var
  StreamReader : TStreamReader;
  ConteudoLinha : String;
begin
  if Not Assigned(Stream) then
    raise EProcessoStreamException.Create('Stream de dados base é nulo.');
  try
    try
      StreamReader := TStreamReader.Create(Stream);
      while StreamReader.EndOfStream do
      begin
        ConteudoLinha := StreamReader.ReadLine;
        ProcessarLinhaBase(ConteudoLinha);
      end;
    except
      on E:Exception do
        raise EProcessoStreamException.Create('Houve um erro no processamento da Stream -> ' + E.Message);
    end;
  finally
    StreamReader.Close;
    FreeAndNil(StreamReader);
  end;
end;

{
  Faz o processamento da String vinda do TStreamReader para inserir
  informações no TList como TNCMUnTrib.
}
procedure TLeitorCSVBase.ProcessarLinhaBase(ConteudoLinha : String);
var
  ValoresHeader   : TArray<String>;
  ValoresConteudo : TArray<String>;
  NCMUnTribAtual  : ^TNCMUnTrib;
begin
  if String.IsNullOrWhitespace(ConteudoLinha) then
    Exit;

  if ConteudoLinha.StartsWith('@') then
  begin
    { Processar informações do cabeçalho }
    ConteudoLinha := ConteudoLinha.Substring(1);
    ValoresHeader := ConteudoLinha.Split([':']);
    Autor := ValoresHeader[0];
    Versao := ValoresHeader[1];
    TextoSefaz := ValoresHeader[2];
  end
  else
  begin
    { Processar informações do NCM da linha }
    ValoresConteudo := ConteudoLinha.Split([',']);
    New(NCMUnTribAtual);
    NCMUnTribAtual^.NCM := StrToInt(ValoresConteudo[0]);
    NCMUnTribAtual^.UTribAbreviada := ValoresConteudo[3];
    NCMUnTribAtual^.UTribDescricao := ValoresConteudo[4];
    NCMUnTribLista.Add(NCMUnTribAtual^);
  end;
end;

{
  Executa uma pesquisa binária no TList que armazena os "valores" de NCN
}
function TLeitorCSVBase.PesquisaBinaria(VlNCM : Integer; Min : Integer; Max : Integer) : Integer;
var
  Medio : Integer;
begin
  if Max < Min then
    Exit( -1 );

  Medio := (Min + Max) div 2;

  if VlNCM = NCMUnTribLista[Medio].NCM then
    Exit( Medio );

  if VlNCM > NCMUnTribLista[Medio].NCM then
    Exit ( PesquisaBinaria(VlNCM, Medio + 1, Max) )
  else
    Exit ( PesquisaBinaria(VlNCM, Min, Medio - 1) );
end;

{
  Faz a localização do NCM passado em NCMStr
}
function TLeitorCSVBase.Localizar(NCMStr : String) : TNCMUnTrib;
var
  VlNCM  : Integer;
  Indice : Integer;
begin
  VlNCM := StrToInt(NCMStr);
  Indice := PesquisaBinaria(VlNCM, 0, NCMUnTribLista.Count - 1);
  if Indice <> -1 then
    Result := NCMUnTribLista[Indice];
end;

end.
