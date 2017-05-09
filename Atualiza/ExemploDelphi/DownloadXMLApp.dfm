object Form1: TForm1
  Left = 452
  Top = 212
  Width = 356
  Height = 473
  BorderIcons = [biSystemMenu]
  Caption = 'Executar Download XML'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 27
    Top = 78
    Width = 40
    Height = 13
    Caption = 'Captcha'
  end
  object Label2: TLabel
    Left = 27
    Top = 117
    Width = 84
    Height = 13
    Caption = 'Chave de Acesso'
  end
  object Button1: TButton
    Left = 24
    Top = 8
    Width = 113
    Height = 25
    Caption = 'Executar Delphi'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 24
    Top = 48
    Width = 169
    Height = 25
    Caption = 'GetCaptcha Executar Delphi'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 24
    Top = 160
    Width = 169
    Height = 25
    Caption = 'GetXML Executar Delphi'
    TabOrder = 2
    OnClick = Button3Click
  end
  object Edit1: TEdit
    Left = 27
    Top = 95
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object Edit2: TEdit
    Left = 27
    Top = 134
    Width = 286
    Height = 21
    TabOrder = 4
    Text = '32151210268390000139550010000096921000096927'
  end
  object Button4: TButton
    Left = 24
    Top = 192
    Width = 169
    Height = 25
    Caption = 'GetXML String Delphi'
    TabOrder = 5
    OnClick = Button4Click
  end
  object Memo1: TMemo
    Left = 8
    Top = 224
    Width = 321
    Height = 201
    ScrollBars = ssVertical
    TabOrder = 6
  end
end
