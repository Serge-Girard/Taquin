object MainForm: TMainForm
  Left = 204
  Top = 139
  Width = 801
  Height = 640
  Caption = 'Taquin Delphi 7.0'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 552
    Top = 48
    Width = 121
    Height = 121
    Stretch = True
  end
  object ScrollBox1: TScrollBox
    Left = 24
    Top = 24
    Width = 400
    Height = 400
    HorzScrollBar.Visible = False
    VertScrollBar.Visible = False
    TabOrder = 0
  end
  object SpinEdit1: TSpinEdit
    Left = 576
    Top = 184
    Width = 81
    Height = 22
    MaxValue = 4
    MinValue = 0
    TabOrder = 1
    Value = 0
    OnChange = SpinEdit1Change
  end
  object Melanger: TButton
    Left = 568
    Top = 224
    Width = 75
    Height = 25
    Caption = 'M'#233'langer'
    TabOrder = 2
    OnClick = MelangerClick
  end
  object RadioGroup1: TRadioGroup
    Left = 552
    Top = 296
    Width = 137
    Height = 73
    Caption = 'Nombre de pi'#233'ces'
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      '9'
      '16'
      '25'
      '36')
    TabOrder = 3
    OnClick = RadioGroup1Click
  end
  object Memo1: TMemo
    Left = 24
    Top = 440
    Width = 401
    Height = 129
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object ImageList1: TImageList
    AllocBy = 1
    Left = 472
    Top = 456
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 50
    OnTimer = Timer1Timer
    Left = 456
    Top = 296
  end
end
