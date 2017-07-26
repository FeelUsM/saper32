object Form3: TForm3
  Left = 692
  Top = 92
  BorderStyle = bsToolWindow
  Caption = #1087#1086#1082#1072#1079#1072#1090#1077#1083#1080
  ClientHeight = 572
  ClientWidth = 215
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 209
    Height = 177
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 3
    Top = 204
    Width = 209
    Height = 365
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -5
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object CheckBox1: TCheckBox
    Left = 0
    Top = 184
    Width = 105
    Height = 17
    Caption = #1087#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1083#1086#1075
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = CheckBox1Click
  end
end
