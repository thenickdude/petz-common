object frmSpriteSettings: TfrmSpriteSettings
  Left = 476
  Top = 521
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Sprite Settings'
  ClientHeight = 245
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 35
    Height = 13
    Caption = 'Sprites:'
  end
  object lstSprites: TListBox
    Left = 16
    Top = 24
    Width = 145
    Height = 185
    ItemHeight = 13
    TabOrder = 0
    OnClick = lstSpritesClick
  end
  object btnSave: TButton
    Left = 352
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Save'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object Button2: TButton
    Left = 272
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 168
    Top = 8
    Width = 257
    Height = 201
    Caption = 'Sprite Properties'
    TabOrder = 3
    object Label2: TLabel
      Left = 8
      Top = 16
      Width = 59
      Height = 13
      Caption = 'Sprite name:'
    end
    object Label3: TLabel
      Left = 8
      Top = 48
      Width = 66
      Height = 13
      Caption = 'Display name:'
    end
    object lblSpriteName: TLabel
      Left = 16
      Top = 32
      Width = 5
      Height = 13
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 8
      Top = 96
      Width = 54
      Height = 13
      Caption = 'ID Number:'
    end
    object edtDisplayName: TEdit
      Left = 16
      Top = 64
      Width = 233
      Height = 21
      MaxLength = 32
      TabOrder = 0
      OnChange = edtDisplayNameChange
    end
    object spnID: TSpinEdit
      Left = 16
      Top = 112
      Width = 97
      Height = 22
      MaxValue = 16777215
      MinValue = 0
      TabOrder = 1
      Value = 0
      OnChange = spnIDChange
    end
    object chkShowToybox: TCheckBox
      Left = 8
      Top = 144
      Width = 97
      Height = 17
      Caption = 'Show in toybox'
      TabOrder = 2
      OnClick = chkShowToyboxClick
    end
  end
end
