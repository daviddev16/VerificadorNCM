unit Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Diagnostics,
  ShellAPI,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  LeitoresTabelaNCM,
  GerenciadorLeitor,
  Data.DB,
  DBClient,
  Vcl.Grids,
  Vcl.DBGrids,
  Xml.XMLDoc,
  Xml.XMLIntf,
  Vcl.ExtCtrls;

type

  TMainForm = class(TForm)

    BtnAtualizarTabela: TButton;
    DbGridNFe: TDBGrid;
    BtnDadosTabela: TButton;
    BtnAnalisarXml: TButton;
    OpenDialog1: TOpenDialog;
    LlkSobre: TLinkLabel;
    procedure FormCreate(Sender: TObject);
    procedure BtnAtualizarTabelaClick(Sender: TObject);
    procedure BtnDadosTabelaClick(Sender: TObject);
    procedure BtnAnalisarXmlClick(Sender: TObject);
    procedure LinkLabelClickEvent(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);

  private

    GridDataSet : TClientDataSet;
    LeitorCSV : TLeitorCSVBase;

    const nmCdProduto = 'Cd. Produto';
    const nmNomeProduto = 'Nome do Produto';
    const nmNCMProd = 'NCM';
    const nmStatus = 'Status';

    procedure CentralizarForm();
    procedure CriarDataSetSource();
    procedure InserirLinha(Dados : Array of TVarRec);
    procedure ProcessarProdutoDoXml(ProdNodeList : IXMLNodeList);
    procedure ProcessarXml(XmlDoc : IXMLDocument);
    procedure LimparTudo();

    function GetChildNode(Nome : String; ParenteNodeList : IXMLNodeList) : IXMLNodeList;

    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol:
      Integer; Column: TColumn; State: TGridDrawState);



  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}


procedure TMainForm.BtnAnalisarXmlClick(Sender: TObject);
var
  XmlDoc : IXMLDocument;
begin
  LimparTudo;
  OpenDialog1.Options := [TOpenOption.ofFileMustExist];
  OpenDialog1.DefaultExt := 'xml';
  OpenDialog1.Filter := 'Arquivo XML|*.xml|Todos os Arquivos|*.*';

  if OpenDialog1.Execute then
  begin
    XmlDoc := TXMLDocument.Create(OpenDialog1.FileName);
    ProcessarXml(XmlDoc);

    if GridDataSet.RecordCount > 0 then
    begin
      GridDataSet.RecNo := 1;
    end;

  end;
end;

procedure TMainForm.BtnAtualizarTabelaClick(Sender: TObject);
begin
  TGerenciador.LimparCacheLocal;
  MessageDlg('Será necessário reiniciar a aplicação.', TMsgDlgType.mtInformation,
    [TMsgDlgBtn.mbOK], 0, TMsgDlgBtn.mbOK);
  Application.Terminate;
end;

procedure TMainForm.BtnDadosTabelaClick(Sender: TObject);
begin
  if Assigned(LeitorCSV) then
  begin
    MessageDlg(
      'Dados da tabela NCM:' + sLineBreak +
      'Texto Sefaz: ' + LeitorCSV.TextoSefaz + sLineBreak +
      'Autor último upload: ' + LeitorCSV.Autor + sLineBreak +
      'Versão: ' + LeitorCSV.Versao,
      TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0, TMsgDlgBtn.mbOK);
  end;
end;

procedure TMainForm.DBGridDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  ValorCell : Variant;
begin

  { verificar se o data set está ativo antes }
  if not DbGridNFe.DataSource.DataSet.Active then
    Exit;

  if (DataCol >= 0) and (DataCol < DbGridNFe.Columns.Count) then
  begin
    { mudar cor da linha de acordo com o status }
    ValorCell := GridDataSet.FieldByName(nmStatus).Value;

    if ValorCell = 'Inexistente' then
    begin
      if gdSelected in State then
      begin
        DbGridNFe.Canvas.Brush.Color := clWebDarkRed;
        DbGridNFe.Canvas.Font.Color := clWebSalmon;
      end
      else
      begin
        DbGridNFe.Canvas.Brush.Color := clWebSalmon;
        DbGridNFe.Canvas.Font.Color := clWebDarkRed;
      end;

    end
    else
    begin
      if gdSelected in State then
      begin
        DbGridNFe.Canvas.Brush.Color := clWebGainsboro;
        DbGridNFe.Canvas.Font.Color := clBlack;
      end
      else
      begin
        DbGridNFe.Canvas.Brush.Color := clWhite;
        DbGridNFe.Canvas.Font.Color := clWebGreen;
      end;
    end;

  end;

  DbGridNFe.DefaultDrawColumnCell(Rect, DataCol, Column, State);

end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LeitorCSV := TGerenciador.GetLeitorBase;

  CriarDataSetSource;
  CentralizarForm;
end;

{ Centralizar tela }
procedure TMainForm.CentralizarForm();
begin
  Left :=(Screen.Width-Width)  div 2;
  Top :=(Screen.Height-Height) div 2;
end;

procedure TMainForm.CriarDataSetSource();
begin
  { inicializando DataSet/DataSource }
  GridDataSet := TClientDataSet.Create(nil);
  DbGridNFe.DataSource := TDataSource.Create(nil);
  DbGridNFe.DataSource.DataSet := GridDataSet;

  { inicializando colunas do DataSet }
  GridDataSet.FieldDefs.Add(nmCdProduto, ftString, 15);
  GridDataSet.FieldDefs.Add(nmNomeProduto, ftString, 50);
  GridDataSet.FieldDefs.Add(nmNCMProd, ftString, 15);
  GridDataSet.FieldDefs.Add(nmStatus, ftString, 15);
  GridDataSet.CreateDataSet;

  DbGridNFe.DefaultDrawing := False;
  DbGridNFe.OnDrawColumnCell := DBGridDrawColumnCell;
  GridDataSet.IndexFieldNames := nmNCMProd;
end;

{Inseri linha nova no TBDGrid }
procedure TMainForm.InserirLinha(Dados : Array of TVarRec);
begin
  GridDataSet.InsertRecord(Dados);
end;

{ processa as informações dos produtos do XML }
procedure TMainForm.ProcessarXml(XmlDoc : IXMLDocument);
var
  StrTotalizador    : TStringBuilder;
  InfNFeNodeList    : IXMLNodeList;
  ProdNodeList      : IXMLNodeList;
  ICMSTotalNodeList : IXMLNodeList;
  I, J              : Integer;
begin
  InfNFeNodeList  := GetChildNode('infNFe',
                     GetChildNode('NFe', XmlDoc.ChildNodes));

  { acessa tags <det> }
  for I := 0 to InfNFeNodeList.Count - 1 do
  begin
    if InfNFeNodeList[I].NodeName = 'det' then
    begin
      { acessa tags <prod> }
      for J := 0 to InfNFeNodeList[I].ChildNodes.Count - 1 do
      begin
        if InfNFeNodeList[I].ChildNodes[J].NodeName = 'prod' then
          ProcessarProdutoDoXml(InfNFeNodeList[I].ChildNodes[J].ChildNodes);
      end;
    end;
  end;

end;


{ processa as informações dos produtos do XML no TStringGrid }
procedure TMainForm.ProcessarProdutoDoXml(ProdNodeList : IXMLNodeList);
var
  CProdValor   : String;
  NCMStr       : String;
  NCMXmlVl     : Integer;
  Status       : String;
  NmProduto    : String;
  NCMUnTribRef : TNCMUnTrib;
begin

  CProdValor  := ProdNodeList['cProd'].Text;
  NmProduto   := ProdNodeList['xProd'].Text;
  NCMStr      := ProdNodeList['NCM'].Text;
  NCMXmlVl    := StrToInt(NCMStr);

  if LeitorCSV.Localizar(NCMStr, NCMUnTribRef) then
  begin
    Status := 'Valido';
  end
  else
    Status := 'Inexistente';

  InserirLinha([
    CProdValor,
    NmProduto,
    NCMStr,
    Status
  ]);

end;

{ Utilizado para acessar os filhos das tags com mais facilidade }
function TMainForm.GetChildNode(Nome : String; ParenteNodeList : IXMLNodeList) : IXMLNodeList;
var
  I : Integer;
begin
  for I := 0 to ParenteNodeList.Count - 1 do
  begin
    if ParenteNodeList[I].NodeName = Nome then
    begin
      Exit(ParenteNodeList[I].ChildNodes);
    end;
  end;
end;

procedure TMainForm.LimparTudo();
begin
  GridDataSet.EmptyDataSet;
end;

procedure TMainForm.LinkLabelClickEvent(Sender: TObject; const Link: string;
  LinkType: TSysLinkType);
begin
  ShellExecute(0, 'open', PChar(Link), nil, nil, SW_SHOWNORMAL);
end;

end.
