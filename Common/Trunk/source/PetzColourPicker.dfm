object frmColourPicker: TfrmColourPicker
  Left = 328
  Top = 281
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Colour Picker'
  ClientHeight = 451
  ClientWidth = 477
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 392
    Top = 424
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = Button1Click
  end
  object btnOk: TButton
    Left = 312
    Top = 424
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 1
    OnClick = btnOkClick
  end
  object rdoNone: TRadioButton
    Left = 8
    Top = 4
    Width = 137
    Height = 17
    Caption = 'No colour/default colour'
    TabOrder = 2
    OnClick = rdoNoneClick
  end
  object rdoPick: TRadioButton
    Left = 8
    Top = 20
    Width = 137
    Height = 17
    Caption = 'Pick a colour:'
    Checked = True
    TabOrder = 3
    TabStop = True
    OnClick = rdoNoneClick
  end
  object grid: TPetzColourGrid
    Left = 16
    Top = 48
    Width = 448
    Height = 368
    columns = 16
    cellwidth = 25
    cellheight = 20
    gap = 3
    palette = pfpPetz
  end
  object cmbPalette: TComboBox
    Left = 96
    Top = 22
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemHeight = 0
    TabOrder = 5
    Visible = False
    OnChange = cmbPaletteChange
  end
  object Timer1: TTimer
    Interval = 200
    OnTimer = Timer1Timer
    Left = 224
    Top = 24
  end
end
