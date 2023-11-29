unit LeitoresTabelaNCM;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Types,
  System.UITypes,
  System.IOUtils,
  System.Math,
  System.Classes,
  System.Variants,
  System.Generics.Collections,
  System.Net.HttpClientComponent,
  System.Net.URLClient,
  System.Net.HttpClient;

type

  EProcessoStreamException = class(Exception);
  EInicializacaoStreamException = class(Exception);

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
      procedure CriarSeNecessario(CaminhoArquivo : String);
      function PesquisaBinaria(VlNCM : Integer; Min : Integer; Max : Integer) : Integer;

    public
      procedure ExportarParaArquivo(CaminhoArquivo : String);
      procedure Exportar(var Stream : TStream);
      function Localizar(NCMStr : String) : TNCMUnTrib;
      constructor Create();


  end;

  TLeitorCSVWeb = class(TLeitorCSVBase)

    public
      constructor Create(ConnURL : String);

  end;

  TLeitorCSVArquivo = class(TLeitorCSVBase)

    public
      constructor Create(ArquivoLocal : String);

  end;

implementation

{ TLeitorCSVArquivo }

constructor TLeitorCSVArquivo.Create(ArquivoLocal : String);
var
  ArquivoStream : TStream;
begin
  inherited Create;
  if not String.IsNullOrEmpty(ArquivoLocal) and TFile.Exists(ArquivoLocal) then
  begin
    ArquivoStream := TFileStream.Create(ArquivoLocal, fmOpenReadWrite);
    ProcessarStreamBase(ArquivoStream);
    ArquivoStream.Free;
  end
  else
    raise EInicializacaoStreamException.Create('Arquivo não existe ou campo informado é nulo.');
end;

{ TLeitorCSVWeb }

constructor TLeitorCSVWeb.Create(ConnURL : String);
var
  ContentStream : TStream;
  NetHTTPClient : TNetHTTPClient;
begin
  inherited Create;
  if not String.IsNullOrEmpty(ConnURL) then
  begin
    NetHTTPClient := TNetHTTPClient.Create(nil);
    ContentStream := NetHTTPClient.Get(ConnURL).ContentStream;
    ProcessarStreamBase(ContentStream);
  end
  else
    raise EInicializacaoStreamException.Create('URL inválida.');
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
      while Not StreamReader.EndOfStream do
      begin
        ConteudoLinha := StreamReader.ReadLine;
        ProcessarLinhaBase(ConteudoLinha);
      end;
    except
      on E:Exception do
        raise EProcessoStreamException.Create('Houve um erro no processamento da Stream -> ' + E.Message);
    end;
  finally
    if Assigned(StreamReader) then
    begin
      StreamReader.Free;
    end;
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
  Exporta a tabela de NCM e header para Stream
}
procedure TLeitorCSVBase.Exportar(var Stream : TStream);
var
  StreamWriter : TStreamWriter;
begin
  if Not Assigned(Stream) then
    raise EProcessoStreamException.Create('Stream de dados base é nulo.');
  try
    try
      StreamWriter := TStreamWriter.Create(Stream, TEncoding.UTF8);
      StreamWriter.AutoFlush := True;
      StreamWriter.WriteLine('@' + String.Join(':', [Autor, Versao, TextoSefaz]));
      for var NCMUbTribRec in NCMUnTribLista do
      begin
        StreamWriter.WriteLine(String.Join(',', [IntToStr(NCMUbTribRec.NCM), '', '',
          NCMUbTribRec.UTribAbreviada, NCMUbTribRec.UTribDescricao]));
      end;
    except
      on E:Exception do
        raise EProcessoStreamException.Create('Houve um erro na exportação da Stream -> ' + E.Message);
    end;
  finally
    if Assigned(StreamWriter) then
    begin
      StreamWriter.Free;
    end;
  end;
end;

{
  Exporta para arquivo informando apenas o diretório, sem precisar criar a Stream
  manualmente.
}
procedure TLeitorCSVBase.ExportarParaArquivo(CaminhoArquivo : String);
var
  ArquivoStream : TStream;
begin
  CriarSeNecessario(CaminhoArquivo);
  ArquivoStream := TFileStream.Create(CaminhoArquivo, fmOpenReadWrite);
  Exportar(ArquivoStream);
  ArquivoStream.Free;
end;

{
  Executa uma pesquisa binária no TList que armazena os "valores" de NCM
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

{
  Cria arquivo informado no caminho apenas se não existir.
}
procedure TLeitorCSVBase.CriarSeNecessario(CaminhoArquivo : String);
begin
  if Not String.IsNullOrEmpty(CaminhoArquivo) And Not TFile.Exists(CaminhoArquivo) then
    TFile.Create(CaminhoArquivo).Free;
end;

end.
