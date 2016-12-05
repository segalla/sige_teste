object frmRecuperaXML: TfrmRecuperaXML
  Left = 419
  Top = 261
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Recuperar XML NF-e'
  ClientHeight = 228
  ClientWidth = 611
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label6: TLabel
    Left = 4
    Top = 141
    Width = 40
    Height = 13
    Caption = 'Aten'#231#227'o'
  end
  object lblStatus: TLabel
    Left = 0
    Top = 108
    Width = 610
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Conectando ao SEFAZ'
    FocusControl = ProgressBar1
    Visible = False
  end
  object mAtencao: TMemo
    Left = 0
    Top = 156
    Width = 611
    Height = 72
    Align = alBottom
    Ctl3D = False
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    Lines.Strings = (
      
        '1 - O site da SEFAZ pode sofrer altera'#231#245'es inviabilizando a cria' +
        #231#227'o do arquivo XML.'
      ''
      
        '2 - OS ARQUIVOS GERADOS POR ESTE PROGRAMA N'#195'O SUBSTITUEM O XML O' +
        'RIGINAL DA NF-e!'
      
        'Solicite aos Fornecedores o envio do XML original conforme o AJU' +
        'STE SINIEF 12, DE 25 DE DEZEMBRO DE 2009.')
    ParentCtl3D = False
    ParentFont = False
    ReadOnly = True
    TabOrder = 0
  end
  object PageControl1: TPageControl
    Left = 46
    Top = 433
    Width = 643
    Height = 193
    ActivePage = TabSheet2
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Dados HTML'
      object Memo1: TMemo
        Left = 0
        Top = 0
        Width = 635
        Height = 165
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Dados XML'
      ImageIndex = 1
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 635
        Height = 165
        Align = alClient
        TabOrder = 0
        object WBXML: TWebBrowser
          Left = 1
          Top = 1
          Width = 633
          Height = 163
          Align = alClient
          TabOrder = 0
          ControlData = {
            4C0000006C410000D91000000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Sobre'
      ImageIndex = 2
      object Label4: TLabel
        Left = 0
        Top = 0
        Width = 635
        Height = 65
        Align = alClient
        Caption = 
          'Projeto Recuperar XML'#13#10#13#10'Seu uso tem por objetivo fornecer os da' +
          'dos de NF-e utilizando busca basedo no layout do site da NF-e. E' +
          'ste site sofre modifica'#231#245'es constantes o que na maioria das veze' +
          's faz com que este projeto se torne incompat'#237'vel, portanto n'#227'o h' +
          #225' garantias de continuidade e manuten'#231#227'o deste projeto, use-o po' +
          'r conta e risco.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object Label5: TLabel
        Left = 0
        Top = 139
        Width = 616
        Height = 26
        Align = alBottom
        Caption = 
          'OS ARQUIVOS GERADOS POR ESTE PROGRAMA N'#195'O SUBSTITUEM O XML ORIGI' +
          'NAL DA NF-E! Solicite aos fornecedores o envio do xml original, ' +
          'al'#233'm de obrigat'#243'rio, '#233' mais seguro.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 351
    Height = 80
    TabOrder = 2
    object Label1: TLabel
      Left = 8
      Top = 1
      Width = 155
      Height = 13
      Caption = 'Chave de acesso da nota fiscal: '
    end
    object Label2: TLabel
      Left = 8
      Top = 41
      Width = 169
      Height = 13
      Caption = 'Digite o c'#243'digo da imagem ao lado: '
    end
    object edtChaveNFe: TEdit
      Left = 8
      Top = 17
      Width = 329
      Height = 19
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      OnKeyUp = edtChaveNFeKeyUp
    end
    object edtCaptcha: TEdit
      Left = 8
      Top = 56
      Width = 73
      Height = 19
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 1
      OnKeyUp = edtCaptchaKeyUp
    end
  end
  object Panel4: TPanel
    Left = 351
    Top = -3
    Width = 260
    Height = 109
    TabOrder = 3
    object Label3: TLabel
      Left = 1
      Top = 92
      Width = 257
      Height = 16
      Cursor = crHandPoint
      Alignment = taCenter
      AutoSize = False
      Caption = 'Clique aqui caso n'#227'o consiga visualizar a imagem'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = Label3Click
    end
    object imgCaptcha: TImage
      Left = 1
      Top = 1
      Width = 258
      Height = 89
      Align = alTop
      Center = True
      Stretch = True
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 80
    Width = 351
    Height = 26
    TabOrder = 4
    object btnPegarHTML: TButton
      Left = 26
      Top = 1
      Width = 76
      Height = 27
      Caption = 'Pegar HTML'
      Enabled = False
      TabOrder = 0
      Visible = False
      OnClick = btnPegarHTMLClick
    end
    object btnNovaConsulta: TButton
      Left = 192
      Top = 1
      Width = 76
      Height = 27
      Caption = 'Nova Consulta'
      Enabled = False
      TabOrder = 1
      Visible = False
      OnClick = btnNovaConsultaClick
    end
    object btnGerarXML: TButton
      Left = 270
      Top = 1
      Width = 76
      Height = 27
      Caption = 'Gerar XML'
      Enabled = False
      TabOrder = 2
      Visible = False
      OnClick = btnGerarXMLClick
    end
    object btnSalvaConsulta: TBitBtn
      Left = 6
      Top = 1
      Width = 150
      Height = 22
      Cursor = crHandPoint
      Caption = 'Salvar XML'
      TabOrder = 3
      OnClick = btnSalvaConsultaClick
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333303
        333333333333337FF3333333333333903333333333333377FF33333333333399
        03333FFFFFFFFF777FF3000000999999903377777777777777FF0FFFF0999999
        99037F3337777777777F0FFFF099999999907F3FF777777777770F00F0999999
        99037F773777777777730FFFF099999990337F3FF777777777330F00FFFFF099
        03337F773333377773330FFFFFFFF09033337F3FF3FFF77733330F00F0000003
        33337F773777777333330FFFF0FF033333337F3FF7F3733333330F08F0F03333
        33337F7737F7333333330FFFF003333333337FFFF77333333333000000333333
        3333777777333333333333333333333333333333333333333333}
      NumGlyphs = 2
    end
    object cbDownloadXML: TCheckBox
      Left = 166
      Top = 4
      Width = 179
      Height = 17
      Caption = 'Download com Certificado Digital'
      TabOrder = 4
      OnClick = cbDownloadXMLClick
    end
  end
  object ProgressBar1: TProgressBar
    Left = 1
    Top = 122
    Width = 609
    Height = 17
    TabOrder = 5
    Visible = False
  end
  object WebBrowser1: TEmbeddedWB
    Left = 720
    Top = 264
    Width = 281
    Height = 297
    TabOrder = 6
    OnProgressChange = WebBrowser1ProgressChange
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
end
