object Form2: TForm2
  Left = 267
  Top = 169
  Width = 659
  Height = 507
  Caption = #1085#1072#1089#1090#1088#1086#1081#1082#1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LabelErr: TLabel
    Left = 8
    Top = 456
    Width = 3
    Height = 13
  end
  object Label5: TLabel
    Left = 0
    Top = 464
    Width = 45
    Height = 13
    Caption = '(c)FeelUs'
  end
  object ButtonOk: TButton
    Left = 568
    Top = 448
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 0
    OnClick = ButtonOkClick
  end
  object ButtonCansel: TButton
    Left = 472
    Top = 448
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = ButtonCanselClick
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 609
    Height = 217
    Caption = #1086#1073#1097#1080#1077
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 128
      Width = 84
      Height = 13
      Caption = #1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1084#1080#1085':'
    end
    object Label4: TLabel
      Left = 16
      Top = 168
      Width = 58
      Height = 13
      Caption = #1074' '#1087#1088#1086#1094#1077#1090#1072#1093':'
    end
    object GroupBox3: TGroupBox
      Left = 8
      Top = 16
      Width = 105
      Height = 105
      Caption = #1088#1072#1079#1084#1077#1088#1099' '#1087#1086#1083#1103
      TabOrder = 0
      object Label2: TLabel
        Left = 8
        Top = 16
        Width = 37
        Height = 13
        Caption = #1074#1099#1089#1086#1090#1072
      end
      object Label3: TLabel
        Left = 8
        Top = 56
        Width = 38
        Height = 13
        Caption = #1096#1080#1088#1080#1085#1072
      end
      object SpinEditH: TSpinEdit
        Left = 8
        Top = 32
        Width = 89
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 0
        OnChange = SpinEditHChange
      end
      object SpinEditL: TSpinEdit
        Left = 8
        Top = 72
        Width = 89
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 0
        OnChange = SpinEditLChange
      end
    end
    object SpinEditMine: TSpinEdit
      Left = 16
      Top = 144
      Width = 89
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
      OnChange = SpinEditMineChange
    end
    object RadioGroup1: TRadioGroup
      Left = 120
      Top = 16
      Width = 161
      Height = 193
      Caption = #1088#1077#1078#1080#1084' '#1072#1074#1090#1086#1084#1072#1090#1080#1082#1080
      TabOrder = 2
    end
    object RadioButton1: TRadioButton
      Left = 128
      Top = 32
      Width = 113
      Height = 17
      Caption = #1042#1089#1077' '#1089#1072#1084
      TabOrder = 3
    end
    object RadioButton2: TRadioButton
      Left = 128
      Top = 56
      Width = 145
      Height = 17
      Caption = #1040#1074#1090#1086' '#1086#1090#1082#1088#1099#1074#1072#1085#1080#1077' '#1085#1091#1083#1077#1081
      TabOrder = 4
    end
    object RadioButton3: TRadioButton
      Left = 128
      Top = 112
      Width = 145
      Height = 17
      Caption = #1040#1074#1090#1086' '#1090#1086#1083#1100#1082#1086' '#1086#1090#1082#1088#1099#1074#1072#1085#1080#1077
      TabOrder = 5
    end
    object RadioButton4: TRadioButton
      Left = 128
      Top = 136
      Width = 145
      Height = 25
      Caption = #1055#1086#1083#1085#1072#1103' '#1087#1088#1086#1089#1090#1072#1103' '#1072#1074#1090#1086#1084#1072#1090#1080#1082#1072
      TabOrder = 6
      WordWrap = True
    end
    object CheckBox1: TCheckBox
      Left = 304
      Top = 40
      Width = 97
      Height = 17
      Caption = #1089#1074#1086#1081' '#1089#1090#1077#1082
      TabOrder = 7
    end
    object CheckBox2: TCheckBox
      Left = 304
      Top = 56
      Width = 233
      Height = 17
      Caption = #1087#1086#1082#1072#1079#1099#1074#1072#1090#1100' '#1087#1088#1086#1094#1077#1089#1089' '#1088#1072#1073#1086#1090#1099' '#1072#1074#1090#1086#1084#1072#1090#1080#1082#1080
      TabOrder = 8
    end
    object CheckBox4: TCheckBox
      Left = 304
      Top = 24
      Width = 121
      Height = 17
      Caption = #1073#1077#1079#1086#1087#1072#1089#1085#1099#1077' '#1092#1083#1072#1075#1080
      TabOrder = 9
    end
    object CheckBox3: TCheckBox
      Left = 328
      Top = 72
      Width = 193
      Height = 17
      Caption = #1086#1073#1093#1086#1076': '#1074' '#1075#1083#1091#1073#1080#1085#1091'('#1080#1085#1072#1095#1077' '#1074' '#1096#1080#1088#1080#1085#1091')'
      TabOrder = 10
    end
    object RadioButton5: TRadioButton
      Left = 128
      Top = 80
      Width = 145
      Height = 25
      Caption = #1040#1074#1090#1086' '#1086#1090#1082#1088#1074#1072#1085#1080#1077' '#1085#1091#1083#1077#1081' + '#1087#1088#1086#1089#1090#1072#1074#1083#1077#1085#1080#1077' '#1092#1083#1072#1075#1086#1074
      TabOrder = 11
      WordWrap = True
    end
    object SpinEditPercent: TSpinEdit
      Left = 16
      Top = 184
      Width = 89
      Height = 22
      MaxValue = 99
      MinValue = 1
      TabOrder = 12
      Value = 1
      OnChange = SpinEditPercentChange
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 224
    Width = 649
    Height = 217
    Caption = #1080#1075#1088#1086#1082#1080' ('#1090#1086#1078#1077' '#1087#1086#1082#1072' '#1085#1077' '#1092#1091#1088#1099#1095#1080#1090')'
    TabOrder = 3
    object PageControl1: TPageControl
      Left = 8
      Top = 16
      Width = 633
      Height = 193
      ActivePage = TabSheet14
      TabOrder = 0
      object TabSheet0: TTabSheet
        Caption = '0'
      end
      object TabSheet1: TTabSheet
        Caption = '1'
        ImageIndex = 1
      end
      object TabSheet2: TTabSheet
        Caption = '2'
        ImageIndex = 2
      end
      object TabSheet3: TTabSheet
        Caption = '3'
        ImageIndex = 3
      end
      object TabSheet4: TTabSheet
        Caption = '4'
        ImageIndex = 4
      end
      object TabSheet5: TTabSheet
        Caption = '5'
        ImageIndex = 5
      end
      object TabSheet6: TTabSheet
        Caption = '6'
        ImageIndex = 6
      end
      object TabSheet7: TTabSheet
        Caption = '7'
        ImageIndex = 7
      end
      object TabSheet8: TTabSheet
        Caption = '8'
        ImageIndex = 8
      end
      object TabSheet9: TTabSheet
        Caption = '9'
        ImageIndex = 9
      end
      object TabSheet10: TTabSheet
        Caption = '10'
        ImageIndex = 10
      end
      object TabSheet11: TTabSheet
        Caption = '11'
        ImageIndex = 11
      end
      object TabSheet12: TTabSheet
        Caption = '12'
        ImageIndex = 12
      end
      object TabSheet13: TTabSheet
        Caption = '13'
        ImageIndex = 13
      end
      object TabSheet14: TTabSheet
        Caption = '14'
        ImageIndex = 14
        object Label7: TLabel
          Left = 0
          Top = 152
          Width = 203
          Height = 13
          Caption = '('#1089')FeelUs '#1060#1080#1083#1080#1087#1087' '#1059#1089#1082#1086#1074' fel1992@mail.ru'
        end
      end
    end
  end
end
