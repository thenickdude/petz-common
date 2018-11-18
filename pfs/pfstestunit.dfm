object Form1: TForm1
  Left = 277
  Top = 214
  Width = 870
  Height = 640
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnMount: TButton
    Left = 80
    Top = 24
    Width = 75
    Height = 25
    Caption = 'btnMount'
    TabOrder = 0
    OnClick = btnMountClick
  end
  object vstFS: TVirtualStringTree
    Left = 16
    Top = 64
    Width = 305
    Height = 505
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'MS Sans Serif'
    Header.Font.Style = []
    Header.MainColumn = -1
    Header.Options = [hoColumnResize, hoDrag]
    TabOrder = 1
    OnChange = vstFSChange
    OnGetText = vstFSGetText
    OnInitChildren = vstFSInitChildren
    OnInitNode = vstFSInitNode
    Columns = <>
  end
  object mmo1: TMemo
    Left = 336
    Top = 64
    Width = 489
    Height = 473
    Lines.Strings = (
      'mmo1')
    TabOrder = 2
  end
  object btnLoad: TButton
    Left = 160
    Top = 24
    Width = 75
    Height = 25
    Caption = 'btnLoad'
    TabOrder = 3
    OnClick = btnLoadClick
  end
  object btnParsepath: TButton
    Left = 240
    Top = 24
    Width = 75
    Height = 25
    Caption = 'dump'
    TabOrder = 4
    OnClick = btnParsepathClick
  end
end
