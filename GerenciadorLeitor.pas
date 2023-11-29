unit GerenciadorLeitor;

interface

uses
  LeitoresTabelaNCM,
  System.SysUtils,
  System.Classes,
  System.IOUtils;

type
  TGerenciador = class

    private
      const WebNCMURL = 'https://raw.githubusercontent.com/daviddev16/VerificadorNCM/master/Tabela/TabelaNCMAtualizado.csv';

    public
      class function GetLeitorBase() : TLeitorCSVBase;
      class function GetCaminhoTabelaLocal() : String;
      class function GetUserDirectory() : String;
      class procedure LimparCacheLocal();
  end;

implementation

{
  Limpa a tabela local para carregar as informações online, atualizadas.
}
class procedure TGerenciador.LimparCacheLocal();
var
  CaminhoTabelaLocal : String;
begin
  CaminhoTabelaLocal := GetCaminhoTabelaLocal;
  if TFile.Exists(CaminhoTabelaLocal) then
  begin
    TFile.Delete(CaminhoTabelaLocal);
  end;
end;

{
  Decide se a instância do TLeitorCSVBase vai ser um leitor web ou leitor de
  arquivo local.
}
class function TGerenciador.GetLeitorBase() : TLeitorCSVBase;
var
  CaminhoTabelaLocal : String;
begin
  CaminhoTabelaLocal := GetCaminhoTabelaLocal;
  if TFile.Exists(CaminhoTabelaLocal) then
  begin
    Exit( TLeitorCSVArquivo.Create(CaminhoTabelaLocal) );
  end;
  Result := TLeitorCSVWeb.Create(WebNCMURL);
  Result.ExportarParaArquivo(CaminhoTabelaLocal);
end;

{
  Retorna o caminho do usuário + o nome do arquivo da tabela de ncm local em
  combinados.
}
class function TGerenciador.GetCaminhoTabelaLocal() : String;
begin
  Result := TPath.Combine(GetUserDirectory, 'TabelaNCMLocal.csv');
end;

{
  Retorna o valor da home do usuário
}
class function TGerenciador.GetUserDirectory(): string;
begin
  Result := GetEnvironmentVariable('USERPROFILE');
end;


end.
