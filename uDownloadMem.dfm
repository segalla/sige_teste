object fDownload: TfDownload
  Left = 456
  Top = 329
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'Aguarde...'
  ClientHeight = 30
  ClientWidth = 409
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 409
    Height = 25
    Align = alTop
    Alignment = taCenter
    Caption = 'Por favor, aguarde a consulta ao SEFAZ...'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object WebBrowser1: TEmbeddedWB
    Left = 631
    Top = 144
    Width = 281
    Height = 297
    TabOrder = 0
    Silent = False
    OnDocumentComplete = WebBrowser1DocumentComplete
    OnFileDownload = WebBrowser1FileDownload
    DisableCtrlShortcuts = 'N'
    UserInterfaceOptions = [EnablesFormsAutoComplete, EnableThemes]
    About = ' EmbeddedWB http://bsalsa.com/'
    HTMLCode.Strings = (
      'http://bsalsa.com/test/FlashTest.htm')
    PrintOptions.HTMLHeader.Strings = (
      '<HTML></HTML>')
    PrintOptions.Orientation = poPortrait
    ControlData = {
      4C000000F7260000B21E00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object WBXML: TWebBrowser
    Left = 40
    Top = 272
    Width = 633
    Height = 163
    TabOrder = 1
    OnDocumentComplete = WBXMLDocumentComplete
    ControlData = {
      4C0000006C410000D91000000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
