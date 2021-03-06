unit uRecuperaXML;

interface

uses GifImage ,UrlMon, MSHtml, ACBrUtil, pcnAuxiliar, ActiveX, JPEG,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, SHDocVw, ExtCtrls, ComCtrls, WinInet, Menus,
  Buttons, SHDocVw_EWB, EwbCore, EmbeddedWB, IniFiles, PNGImage, LMDPNGImage;

type
  TfrmRecuperaXML = class(TForm)
    Label6: TLabel;
    mAtencao: TMemo;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Memo1: TMemo;
    TabSheet2: TTabSheet;
    Panel1: TPanel;
    WBXML: TWebBrowser;
    TabSheet3: TTabSheet;
    Label4: TLabel;
    Label5: TLabel;
    lblStatus: TLabel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    edtChaveNFe: TEdit;
    edtCaptcha: TEdit;
    Panel4: TPanel;
    Label3: TLabel;
    Panel3: TPanel;
    btnPegarHTML: TButton;
    btnNovaConsulta: TButton;
    btnGerarXML: TButton;
    btnSalvaConsulta: TBitBtn;
    ProgressBar1: TProgressBar;
    cbDownloadXML: TCheckBox;
    WebBrowser1: TEmbeddedWB;
    imgCaptcha: TImage;
    procedure btnPegarHTMLClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnNovaConsultaClick(Sender: TObject);
    procedure btnGerarXMLClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label3Click(Sender: TObject);
    procedure edtChaveNFeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtCaptchaKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSalvaConsultaClick(Sender: TObject);
    procedure WebBrowser1ProgressChange(ASender: TObject; Progress,
      ProgressMax: Integer);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure WebBrowser1FileDownload(Sender: TCustomEmbeddedWB;
      pmk: IMoniker; pbc: IBindCtx; dwBindVerb, grfBINDF: Cardinal;
      pBindInfo: PBindInfo; pszHeaders, pszRedir: PWideChar;
      uiCP: Cardinal; var Rezult: HRESULT);
    procedure cbDownloadXMLClick(Sender: TObject);
  private
    { Private declarations }
    vTries        : Integer;
    vCaminhoDados,
    vCaminhoCaptcha,
    vStringXMLD,
    FPath         : String;
    vShowErrors,
    vImport       : Boolean;
    Function  DownloadFile(SourceFile, DestFile : String) : Boolean;
    Function  StripHTML(S : String) : String;
    procedure DeleteIECache;
    procedure PegarHTML;
    procedure GeraXml;
    procedure NovaConsulta;
    procedure MostrarImagem;
  public
    { Public declarations }
   Property Import         : Boolean Read vImport         Write vImport;
   Property CaminhoDados   : String  Read vCaminhoDados   Write vCaminhoDados;
   Property CaminhoCaptcha : String  Read vCaminhoCaptcha Write vCaminhoCaptcha;
   Property ShowErrors     : Boolean Read vShowErrors     Write vShowErrors;
   Property StringXML      : String  Read vStringXMLD     Write vStringXMLD;
  end;

var
//  frmRecuperaXML : TfrmRecuperaXML;
  dest,
  WinTempDir     : String;
  vDocumentHold  : Boolean = False;

implementation

uses pcnConversaoNFe, ACBrHTMLtoXML;

{$R *.dfm}

procedure TfrmRecuperaXML.DeleteIECache;
Var
 lpEntryInfo : PInternetCacheEntryInfo;
 hCacheDir   : LongWord;
 dwEntrySize : LongWord;
begin
 dwEntrySize := 0;
 FindFirstUrlCacheEntry(nil, TInternetCacheEntryInfo(nil^), dwEntrySize);
 GetMem(lpEntryInfo, dwEntrySize);
 If dwEntrySize > 0 Then
  lpEntryInfo^.dwStructSize := dwEntrySize;
 hCacheDir := FindFirstUrlCacheEntry(nil, lpEntryInfo^, dwEntrySize);
 If hCacheDir <> 0 Then
  Begin
   Repeat
    DeleteUrlCacheEntry(lpEntryInfo^.lpszSourceUrlName);
    FreeMem(lpEntryInfo, dwEntrySize);
    dwEntrySize := 0;
    FindNextUrlCacheEntry(hCacheDir, TInternetCacheEntryInfo(nil^), dwEntrySize);
    GetMem(lpEntryInfo, dwEntrySize);
    If dwEntrySize > 0 Then
     lpEntryInfo^.dwStructSize := dwEntrySize;
   Until Not FindNextUrlCacheEntry(hCacheDir, lpEntryInfo^, dwEntrySize);
  End;
 FreeMem(lpEntryInfo, dwEntrySize);
 FindCloseUrlCache(hCacheDir);
end;

Function TfrmRecuperaXML.DownloadFile(SourceFile, DestFile : String) : Boolean;
const BufferSize = 1024;
Var
 hSession,
 hURL      : HInternet;
 Buffer    : Array[1..BufferSize] Of Byte;
 BufferLen : DWORD;
 f         : File;
 sAppName  : string;
begin
 sAppName := ExtractFileName(Application.ExeName);
 hSession := InternetOpen(PChar(sAppName),INTERNET_OPEN_TYPE_PRECONFIG,nil, nil, 0);
 Try
  hURL := InternetOpenURL(hSession,PChar(SourceFile),nil,0,0,0);
  Try
   AssignFile(f, DestFile);
   Rewrite(f,1);
   Repeat
    InternetReadFile(hURL, @Buffer,SizeOf(Buffer), BufferLen);
    BlockWrite(f, Buffer, BufferLen)
   Until BufferLen = 0;
   CloseFile(f);
   Result := True;
  Finally
   InternetCloseHandle(hURL);
  End;
 Finally
  InternetCloseHandle(hSession);
 End;
end;

Function TfrmRecuperaXML.StripHTML(S : String) : String;
Var
 TagBegin, TagEnd, TagLength: integer;
begin
 TagBegin := Pos( '<', S);      // search position of first <
 While (TagBegin > 0) Do
  Begin  // while there is a < in S
   TagEnd    := Pos('>', S);              // find the matching >
   TagLength := TagEnd - TagBegin + 1;
   Delete(S, TagBegin, TagLength);     // delete the tag
   TagBegin := Pos( '<', S);            // search for next <
  End;
 Result := S;                   // give the result
end;

procedure TfrmRecuperaXML.btnPegarHTMLClick(Sender: TObject);
begin
 PegarHTML;
end;

procedure TfrmRecuperaXML.PegarHTML;
begin
 edtChaveNFe.Text := OnlyNumber(edtChaveNFe.Text);
 If (not (ValidarChave('NFe'+edtChaveNFe.Text))) Or
    (Trim(edtChaveNFe.Text) = '') then
  Begin
   If vShowErrors Then
    MessageBox(Self.Handle, 'Chave Inv�lida.', 'Error...', MB_ICONERROR + mb_ok);
   edtChaveNFe.SetFocus;
   exit;
  End;
 If trim(edtCaptcha.Text) = '' Then
  Begin
   If vShowErrors Then
    MessageBox(Self.Handle, 'Digite o valor da imagem.', 'Error...', MB_ICONERROR + mb_ok);
   edtCaptcha.SetFocus;
   exit;
  End;
 Memo1.Lines.Clear;
 btnSalvaConsulta.Enabled := False;
 btnPegarHTML.Enabled    := False;
 btnNovaConsulta.Enabled := False;
 btnGerarXML.Enabled     := False;
 Try
  WebBrowser1.OleObject.Document.all.Item('ctl00$ContentPlaceHolder1$txtChaveAcessoCompleta', 0).value := edtChaveNFe.Text;
  WebBrowser1.OleObject.Document.all.Item('ctl00$ContentPlaceHolder1$txtCaptcha', 0).value := edtCaptcha.Text;
  WebBrowser1.OleObject.Document.all.Item('ctl00$ContentPlaceHolder1$btnConsultar', 0).click;
 Except
  btnSalvaConsulta.Enabled := True;
  btnNovaConsulta.Enabled := True;
  Raise;
 End;
 PageControl1.ActivePageIndex := 0;
end;

procedure TfrmRecuperaXML.FormCreate(Sender: TObject);
Var
 ArqIni : TiniFile;
 vCheck : Boolean;
begin
 vTries := 0;
 ArqIni := TIniFile.Create('downloadnfe.ini');
 vCheck := ArqIni.ReadBool('MARCA', 'CHECK', False);
 vShowErrors := False;
 NovaConsulta;
 cbDownloadXML.Checked := vCheck;
 ArqIni.Free;
end;

Function GetURLCacheFile(AURL : String; const AData : TMemoryStream) : Integer;
Var
 ice        : PInternetCacheEntryInfo;
 iceSize,
 CacheEntry,
 DataSize   : Cardinal;
 Buffer     : Pointer;
begin
 iceSize := MAX_CACHE_ENTRY_INFO_SIZE;
 Result  := -1;
 GetMem(ice, iceSize);
 Try
  CacheEntry := RetrieveUrlCacheEntryStream(PChar(AUrl), ice^, iceSize, false, 0);
  Try
   If CacheEntry > 0 Then
    Begin
     DataSize:=ice.dwSizeLow;
     Adata.Clear;
     AData.SetSize(DataSize);
     Buffer := AData.Memory;
     If ReadUrlCacheEntryStream(CacheEntry, 0, Pointer(Buffer^), DataSize, 0) Then
      Result := DataSize
     Else
      RaiseLastOSError;
    End;
  Finally
   UnlockUrlCacheEntryStream(CacheEntry, 0);
  End;
 Finally
  FreeMem(ice, iceSize);
 End;
end;

Procedure Base64ToImage(data, path : string);
Var
 x, i, len: integer;
 c1, c2, c3, c4, v: LongWord;
 b : array[0..2] of byte;
 map, d: string;
 f : File;
Begin
 map := 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
 x   := pos(',', data);
 d   := copy(data, x + 1, 65536);
 len := Length(d);
 ForceDirectories(ExtractFilePath(path));
 AssignFile(f, path);
 ReWrite(f, 3);
 i := 1;
 While i <= len Do
  Begin
   c1   := Pos(d[i + 0], map) - 1;
   c2   := Pos(d[i + 1], map) - 1;
   c3   := Pos(d[i + 2], map) - 1;
   c4   := Pos(d[i + 3], map) - 1;
   v    := (c1 Shl 18) or (c2 Shl 12) or (c3 Shl 6) or c4;
   b[0] := (v and $ff0000) Shr 16;
   b[1] := (v and $ff00) Shr 8;
   b[2] := (v and $ff);
   BlockWrite(f, b, 1);
   i := i + 4;
  End;
 CloseFile(F);
end;

procedure TfrmRecuperaXML.MostrarImagem;
Var
 k : Integer;
 Source, Dest : String;
 png: TLMDPNGObject;
begin
 If WebBrowser1.Document <> Nil Then
  Begin
   Dest := '';
   For k := 0 to WebBrowser1.OleObject.Document.Images.Length - 1 do
    Begin
     Source := WebBrowser1.OleObject.Document.Images.Item(k).Src;
     If Pos('data:image/png;', Source) > 0 Then
      Begin
       Source := StringReplace(Source, 'data:image/png;base64,', '', [rfReplaceAll, rfIgnoreCase]);
       try
        If vCaminhoCaptcha[Length(vCaminhoCaptcha)] = '\' Then
         dest := IncludeTrailingPathDelimiter(vCaminhoCaptcha) + 'captcha.png'
        Else
         dest := vCaminhoCaptcha;
        Base64ToImage(Source, dest);
        Break;
       except
        application.ProcessMessages;
       end;
      End;
    End;
   If dest <> '' Then
    Begin
     If FileExists(dest) Then
      Begin
       png := TLMDPNGObject.create;
       png.LoadFromFile(dest);
       imgCaptcha.Picture.Assign(png);
       png.Free;
       //Picture.LoadFromFile(dest)
      End
     Else
      imgCaptcha.Picture := Nil;
    End;
  End;
end;

procedure TfrmRecuperaXML.btnNovaConsultaClick(Sender: TObject);
begin
 NovaConsulta;
end;

procedure TfrmRecuperaXML.NovaConsulta;
begin
 btnSalvaConsulta.Enabled := False;
 btnNovaConsulta.Enabled := False;
 btnGerarXML.Enabled     := False;
 edtChaveNFe.Clear;
 edtcaptcha.Clear;
 DeleteIECache;
 Memo1.Lines.Clear;
 Try
  WebBrowser1.Navigate('http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=');
 Except
  Raise;
 End;
 btnSalvaConsulta.Enabled := True;
end;

procedure TfrmRecuperaXML.btnGerarXMLClick(Sender: TObject);
begin
 GeraXML;
end;

procedure TfrmRecuperaXML.GeraXml;
begin
 If Pos('NF-e INEXISTENTE', Memo1.Lines.Text) > 0 Then
  Begin
   If vShowErrors Then
    MessageBox(Self.Handle, 'A NF-e digitada n�o existe na base nacional do SEFAZ.', 'Erro.', mb_IconError + mb_Ok);
   Exit;
  End
 Else
  Begin
   FPath := GerarXML(Memo1.Lines.Text, vCaminhoDados, vStringXMLD);
   WBXML.Navigate(FPath);
   vImport                  := True;
   If vShowErrors Then
    MessageBox(Self.Handle, PChar('XML '+ FPath + ' gerado com sucesso!'), 'Informa��o', MB_ICONINFORMATION + MB_TASKMODAL);
   btnNovaConsulta.Enabled  := True;
   btnSalvaConsulta.Enabled := True;
   btnPegarHTML.Enabled     := True;
   edtChaveNFe.Clear;
   edtCaptcha.Clear;
   NovaConsulta;
  End; 
end;

procedure TfrmRecuperaXML.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Key = vk_escape Then
  Close;
end;

procedure TfrmRecuperaXML.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
 Action := caFree;
end;

procedure TfrmRecuperaXML.Label3Click(Sender: TObject);
begin
 NovaConsulta;
end;

procedure TfrmRecuperaXML.edtChaveNFeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If Length(edtChaveNFe.Text) = 44 Then
  Perform(WM_NEXTDLGCTL, 0, 0);
end;

procedure TfrmRecuperaXML.edtCaptchaKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 If key = vk_Return Then PegarHTML;
end;

procedure TfrmRecuperaXML.btnSalvaConsultaClick(Sender: TObject);
begin
 PegarHTML;
end;

procedure TfrmRecuperaXML.WebBrowser1ProgressChange(ASender: TObject;
  Progress, ProgressMax: Integer);
begin
 If ProgressMax = 0 Then
  Begin
   ProgressBar1.Visible := False;
   lblStatus.Visible    := False;
   Exit;
  End
 Else
  Begin
   ProgressBar1.Visible := True;
   lblStatus.Visible    := True;
   Try
    ProgressBar1.Max    := ProgressMax;
    If (Progress <> -1) And (Progress <= ProgressMax) Then
     ProgressBar1.Position := Progress
    Else
     Begin
      ProgressBar1.Visible := False;
      lblStatus.Visible    := False;
     End;
   Except
    On EDivByZero Do
     Exit;
   End;
  end;
end;

procedure TfrmRecuperaXML.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
 i        : Integer;
 Source   : string;
 textoNFe : IHTMLDocument2;
begin
 Application.ProcessMessages;
 If vDocumentHold Then
  Begin
   textoNFe := WebBrowser1.Document as IHTMLDocument2;
   Source   := StripHTML(textoNFe.body.innerHTML);
   Source   := StringReplace(Source, '&nbsp;','',[rfReplaceAll, rfIgnoreCase]);
   If Pos('H� um problema no certificado de seguran�a', Source) > 0 Then
    Begin
     If vShowErrors Then
      MessageBox(Self.Handle, 'Erro no certificado, verifique se o certificado de seguran�a est� corretamente instalado e tente novamente.', 'Erro...', MB_ICONERROR + mb_ok);
     NovaConsulta;
    End
   Else If Pos('n�o est� autorizado a fazer o download do documento', Source) > 0 Then
    Begin
     If vShowErrors Then
      MessageBox(Self.Handle, 'Este Certificado n�o est� autorizado a fazer o download do documento selecionado.', 'Erro...', MB_ICONERROR + mb_ok);
     NovaConsulta;
    End;
   vDocumentHold := False;
  End
 Else If WebBrowser1.LocationURL = 'http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=' Then
  Begin
   btnPegarHTML.Enabled := True;
   vDocumentHold := False;
  End
 Else If WebBrowser1.LocationURL = 'https://www.nfe.fazenda.gov.br/portal/visualizacaoNFe/completa/Default.aspx' Then
  Begin
   WebBrowser1.Navigate('https://www.nfe.fazenda.gov.br/PORTAL/visualizacaoNFe/completa/impressao.aspx');
   vDocumentHold := False;
  End
 Else if WebBrowser1.LocationURL = 'http://www.nfe.fazenda.gov.br/portal/consultaCompleta.aspx?tipoConteudo=XbSeqxE8pl8=' then
  Begin
   textoNFe := WebBrowser1.Document as IHTMLDocument2;
   If Not cbDownloadXML.Checked Then
    Begin
     Repeat
      Application.ProcessMessages;
     Until Assigned(textoNFe.body);
     Memo1.Lines.Text := StripHTML(textoNFe.body.innerHTML);
     Memo1.Lines.Text := StringReplace(Memo1.Lines.Text,'&nbsp;','',[rfReplaceAll, rfIgnoreCase]);
     i := 0;
     While i < Memo1.Lines.Count-1 do
      Begin
       If trim(Memo1.Lines[i]) = '' Then
        Begin
         Memo1.Lines.Delete(i);
         i := i - 1;
        End;
       If Pos('function',Memo1.lines[i]) > 0 Then
        Begin
         Memo1.Lines.Delete(i);
         i := i - 1;
        End;
       If Pos('document',Memo1.lines[i]) > 0 Then
        Begin
         Memo1.Lines.Delete(i);
         i := i - 1;
        End;
       If Pos('{',Memo1.lines[i]) > 0 Then
        Begin
         Memo1.Lines.Delete(i);
         i := i - 1;
        End;
       If Pos('}',Memo1.lines[i]) > 0 Then
        Begin
         Memo1.Lines.Delete(i);
         i := i - 1;
        End;
       i := i + 1;
      End;
     imgCaptcha.Picture      := nil;
     btnGerarXML.Enabled := True;
     GeraXml;
    End
   Else
    Begin
     Try
      WebBrowser1.OleObject.Document.all.Item('ctl00$ContentPlaceHolder1$btnDownload', 0).Click;
      vDocumentHold := True;
      Exit;
     Except
     End;
    End;
  End
 Else If WebBrowser1.LocationURL = 'https://www.nfe.fazenda.gov.br/portal/inexistente_completa.aspx' Then
  Begin
   If vShowErrors Then
    MessageBox(Self.Handle, 'NF-e INEXISTENTE na base nacional, favor consultar esta NF-e no site da SEFAZ de origem.', 'Erro...', MB_ICONERROR + mb_ok);
   imgCaptcha.Picture          := nil;
   btnGerarXML.Enabled     := True;
   btnSalvaConsulta.Enabled := True;
   btnNovaConsulta.Enabled := True;
   vDocumentHold := False;
  End
 Else
  Begin
   If vShowErrors Then
    MessageBox(Self.Handle, 'Erro no captcha, digite corretamente ou atualize a imagem e tente novamente.', 'Erro...', MB_ICONERROR + mb_ok);
   imgCaptcha.Picture          := nil;
   btnGerarXML.Enabled     := True;
   btnNovaConsulta.Enabled := True;
   btnSalvaConsulta.Enabled := True;
   vDocumentHold := False;
  End;
 edtChaveNFe.SetFocus;
 MostrarImagem;
end;

procedure TfrmRecuperaXML.WebBrowser1FileDownload(
  Sender: TCustomEmbeddedWB; pmk: IMoniker; pbc: IBindCtx; dwBindVerb,
  grfBINDF: Cardinal; pBindInfo: PBindInfo; pszHeaders,
  pszRedir: PWideChar; uiCP: Cardinal; var Rezult: HRESULT);
Var
 CaminhoXML : String;
begin
 CaminhoXML := PathWithDelim(vCaminhoDados) + edtChaveNFe.Text + '-nfe.xml';
 DownloadFile(pszRedir, CaminhoXML); // Aqui � um componente para fazer download, mas existe v�rios meios de fazer o download. Onde (pszRedir � arquivo xml , Diret�rio + nome do arquivo
 Rezult      := S_FALSE; /// A grande sacada esta aqui: S_FALSE significa que n�o pedir para a caixinha de onde salvar.
 If FileExists(CaminhoXML) Then
  Begin
   vImport  := True;
   If vShowErrors Then
    MessageBox(Self.Handle, PChar(Format('NF-e salva em %s.', [CaminhoXML])), 'Informa��o !!!', MB_ICONINFORMATION + mb_ok);
  End
 Else
  If vShowErrors Then
   MessageBox(Self.Handle, 'Erro baixando a NF-e', 'Erro...', MB_ICONERROR + mb_ok);
 NovaConsulta;
end;

procedure TfrmRecuperaXML.cbDownloadXMLClick(Sender: TObject);
Var
 ArqIni : TiniFile;
begin
 ArqIni := TIniFile.Create('downloadnfe.ini');
 ArqIni.WriteBool('MARCA', 'CHECK', cbDownloadXML.Checked);
 ArqIni.Free;
 mAtencao.Lines.Clear;
 If cbDownloadXML.Checked Then
  Begin
   mAtencao.Lines.Add('1 - Com esse m�todo, o XML original � baixado da Receita Federal com validade jur�dica...');
   mAtencao.Lines.Add('');
   mAtencao.Lines.Add('2 - AVISO : Esse m�todo requer que o Certificado Digital utilizado seja o do Cliente da NFe.');
   mAtencao.Lines.Add('Tamb�m � necess�rio que o Certificado Digital esteja instalado e funcionando no Internet Explorer.');
  End
 Else
  Begin
   mAtencao.Lines.Add('1 - O site da SEFAZ pode sofrer altera��es inviabilizando a cria��o do arquivo XML.');
   mAtencao.Lines.Add('');
   mAtencao.Lines.Add('2 - OS ARQUIVOS GERADOS POR ESTE PROGRAMA N�O SUBSTITUEM O XML ORIGINAL DA NF-e!');
   mAtencao.Lines.Add('Solicite aos Fornecedores o envio do XML original conforme o AJUSTE SINIEF 12, DE 25 DE DEZEMBRO DE 2009.');
  End;
end;

end.


