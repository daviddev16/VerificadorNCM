object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Verificador de NCM inexistente'
  ClientHeight = 606
  ClientWidth = 644
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
    Top = 573
    Width = 172
    Height = 25
    Caption = 'Atualizar tabela de NCM'
    TabOrder = 0
    OnClick = BtnAtualizarTabelaClick
  end
  object DbGridNFe: TDBGrid
    Left = 8
    Top = 48
    Width = 628
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
  object LlkSobre: TLinkLabel
    Left = 602
    Top = 579
    Width = 34
    Height = 19
    Caption = '<a href="https://github.com/daviddev16/VerificadorNCM">Sobre</a>'
    TabOrder = 4
    OnLinkClick = LinkLabelClickEvent
  end
  object OpenDialog1: TOpenDialog
    Left = 200
    Top = 304
  end
end
