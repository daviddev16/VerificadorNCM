object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Verificador de NCM vencido'
  ClientHeight = 607
  ClientWidth = 410
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object BtnAtualizarTabela: TButton
    Left = 8
    Top = 574
    Width = 172
    Height = 25
    Caption = 'Atualizar tabela de NCM'
    TabOrder = 0
    OnClick = BtnAtualizarTabelaClick
  end
  object DbGridNFe: TDBGrid
    Left = 8
    Top = 48
    Width = 385
    Height = 520
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    StyleElements = [seClient, seBorder]
  end
  object BtnDadosTabela: TButton
    Left = 186
    Top = 574
    Width = 31
    Height = 25
    Caption = '?'
    TabOrder = 2
    OnClick = BtnDadosTabelaClick
  end
  object BtnAnalisarXml: TButton
    Left = 8
    Top = 17
    Width = 172
    Height = 25
    Caption = 'Analisar XML'
    TabOrder = 3
    OnClick = BtnAnalisarXmlClick
  end
  object OpenDialog1: TOpenDialog
    Left = 200
    Top = 304
  end
end
