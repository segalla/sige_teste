unit uDownloadMem;

interface

uses
  Windows, Messages,     SysUtils, Variants, Classes,     Graphics, Controls, Forms,
  Dialogs, EmbeddedWB,   IniFiles, PNGImage, LMDPNGImage, MSHTML,   WinInet,  ExtCtrls,
  SHDocVw, EwbCore,      ActiveX,  UrlMon,   ACBrUtil,    ACBrHTMLtoXML,
  OleCtrls, SHDocVw_EWB, StdCtrls, pcnAuxiliar;

Type
 TEventHandler = class
  Class Procedure OnFileDownload(Sender: TCustomEmbeddedWB; pmk: IMoniker; pbc: IBindCtx; dwBindVerb,
                                 grfBINDF: Cardinal; pBindInfo: PBindInfo; pszHeaders,
                                 pszRedir: PWideChar; uiCP: Cardinal; var Rezult: HRESULT);
  Class Procedure OnDocumentComplete(ASender: TObject; const pDisp: IDispatch; var URL: OleVariant);
End;


Const
 TimeOut = 20000;

type
  TfDownload = class(TForm)
    WebBrowser1: TEmbeddedWB;
    WBXML: TWebBrowser;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure WebBrowser1FileDownload(Sender: TCustomEmbeddedWB;
      pmk: IMoniker; pbc: IBindCtx; dwBindVerb, grfBINDF: Cardinal;
      pBindInfo: PBindInfo; pszHeaders, pszRedir: PWideChar;
      uiCP: Cardinal; var Rezult: HRESULT);
    procedure WebBrowser1DocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure WBXMLDocumentComplete(Sender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
  private
    { Private declarations }
   vCaminhoDados,
   vCaminhoCaptcha,
   vChaveNFe,
   vLastErrorString,
   vCaptcha,
   vStringXMLD      : String;
   vShowErrors,
   vError           : Boolean;
   vtextoNFe        : IHTMLDocument2;
   Procedure ScriptErrorAction(Sender: TObject;
                               ErrorLine, ErrorCharacter,
                               ErrorCode, ErrorMessage,
                               ErrorUrl                   : String;
                               Var ScriptErrorAction      : TScriptErrorAction);
   procedure MostrarImagem;
   procedure GeraXml;
   Procedure NovaConsulta;
   procedure PegarHTML;
  public
    { Public declarations }
   Function  GetCaptcha : Boolean;
   Function  GetXMLNfe  : Boolean;
   Property  CaminhoDados    : String         Read vCaminhoDados    Write vCaminhoDados;
   Property  CaminhoCaptcha  : String         Read vCaminhoCaptcha  Write vCaminhoCaptcha;
   Property  ChaveNFe        : String         Read vChaveNFe        Write vChaveNFe;
   Property  Captcha         : String         Read vCaptcha         Write vCaptcha;
   Property  LastErrorString : String         Read vLastErrorString Write vLastErrorString;
   Property  textoNFe        : IHTMLDocument2 Read vtextoNFe        Write vtextoNFe;
   Property  Error           : Boolean        Read vError           Write vError;
   Property  StringXML       : String         Read vStringXMLD      Write vStringXMLD;
  end;

Var
 Memo1             : TStringList;
 imgCaptcha        : TImage;
 vStringXML,
 FPath             : String;
 dest,
 WinTempDir        : String;
 vDocumentHold     : Boolean = False;
 vNavigateComplete : Boolean = False;
 vGetXML           : Boolean = False;

implementation

{$R *.dfm}

Function StripHTML(S : String) : String;
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

Procedure DeleteIECache;
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

procedure TfDownload.PegarHTML;
Var
 vTempValue,
 vTempValue2 : String;
begin
 vGetXML     := True;
 vTempValue  := OnlyNumber(vChaveNFe);
 vTempValue2 := vCaptcha;
 vError     := False;
 vDocumentHold := True;
// vChaveNFe  := PChar(OnlyNumber(vTempValue));
 If (not (ValidarChave('NFe'+vChaveNFe))) Or
    (Trim(vChaveNFe) = '') then
  Begin
   vLastErrorString := 'Chave Inválida.';
   vError           := True;
   vDocumentHold    := False;
   exit;
  End;
 If trim(vCaptcha) = '' Then
  Begin
   vLastErrorString := 'A Captcha nao foi enviada';
   vError           := True;
   vDocumentHold    := False;
   exit;
  End;
 Memo1.Clear;
 Try
  WebBrowser1.OleObject.Document.all.Item('ctl00$ContentPlaceHolder1$txtChaveAcessoCompleta', 0).Value := vTempValue;
  WebBrowser1.OleObject.Document.all.Item('ctl00$ContentPlaceHolder1$txtCaptcha', 0).value             := vTempValue2;
  WebBrowser1.OleObject.Document.all.Item('ctl00$ContentPlaceHolder1$btnConsultar', 0).click;
 Except
  Raise;
 End;
end;

Function  TfDownload.GetXMLNfe : Boolean;
Begin
 vDocumentHold     := True;
 vNavigateComplete := False;
 vError := False;
 vStringXML        := '';
// WebBrowser1.LoadFromString(vtextoNFe.body.innerHTML);
 If WebBrowser1.Document = Nil Then
  NovaConsulta;
 Try
  PegarHTML;
 Except
 End;
 While vDocumentHold Do
  Begin
   Application.ProcessMessages;
   Sleep(5);
  End;
 Result := Not vError;
End;

Function  TfDownload.GetCaptcha : Boolean;
Begin
 vNavigateComplete := False;
 vError  := False;
 vGetXML := False;
 DeleteFile(IncludeTrailingPathDelimiter(vCaminhoCaptcha) + 'captcha.png');
 NovaConsulta;
 While vDocumentHold Do
  Begin
   Application.ProcessMessages;
   Sleep(5);
  End;
 Result := vError;
End;

procedure TfDownload.MostrarImagem;
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
 vDocumentHold := False;
end;

Procedure TfDownload.NovaConsulta;
begin
 DeleteIECache;
 Try
//  WBXML.Navigate('http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=');
  WebBrowser1.Navigate('http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=');
  If Not WebBrowser1.WaitWhileBusy(TimeOut) Then
   Begin
    vDocumentHold := False;
    vError        := True;
    vLastErrorString := 'Request TimeOut';
   End;
 Except
 End;
end;

procedure TfDownload.GeraXml;
begin
 If Pos('NF-e INEXISTENTE', vStringXML) > 0 Then
  Begin
   vLastErrorString := 'A NF-e digitada não existe na base nacional do SEFAZ.';
   vError           := True;
   Exit;
  End
 Else
  Begin
   FPath := GerarXML(vStringXML, vCaminhoDados, vStringXMLD);
//   WBXML.Navigate(FPath);
   vLastErrorString := PChar('XML '+ FPath + ' gerado com sucesso!');
   vError           := False;
//   NovaConsulta;
  End;
end;

Function DownloadFile(SourceFile, DestFile : String) : Boolean;
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

Class Procedure TEventHandler.OnFileDownload(
  Sender: TCustomEmbeddedWB; pmk: IMoniker; pbc: IBindCtx; dwBindVerb,
  grfBINDF: Cardinal; pBindInfo: PBindInfo; pszHeaders,
  pszRedir: PWideChar; uiCP: Cardinal; var Rezult: HRESULT);
Begin
end;

Class Procedure TEventHandler.OnDocumentComplete(ASender: TObject; const pDisp: IDispatch; var URL: OleVariant);
begin
end;

Procedure TfDownload.ScriptErrorAction(Sender: TObject;
                                       ErrorLine, ErrorCharacter,
                                       ErrorCode, ErrorMessage,
                                       ErrorUrl                   : String;
                                       Var ScriptErrorAction      : TScriptErrorAction);
Begin
 If (vError) And (vLastErrorString = '') Then
  vLastErrorString := ErrorMessage;
End;

procedure TfDownload.FormCreate(Sender: TObject);
begin
 vError                        := False;
 vShowErrors                   := False;
 Memo1                         := TStringList.Create;
 imgCaptcha                    := TImage.Create(Self);
 vDocumentHold                 := True;
 WebBrowser1.Silent            := True;
 WebBrowser1.OnScriptError     := ScriptErrorAction;
 WebBrowser1.ScriptErrorAction := eaCancel;
end;

procedure TfDownload.WebBrowser1FileDownload(Sender: TCustomEmbeddedWB;
  pmk: IMoniker; pbc: IBindCtx; dwBindVerb, grfBINDF: Cardinal;
  pBindInfo: PBindInfo; pszHeaders, pszRedir: PWideChar; uiCP: Cardinal;
  var Rezult: HRESULT);
Var
 CaminhoXML : String;
begin
 CaminhoXML := PathWithDelim(vCaminhoDados) + vChaveNFe + '-nfe.xml';
 DownloadFile(pszRedir, CaminhoXML); // Aqui é um componente para fazer download, mas existe vários meios de fazer o download. Onde (pszRedir é arquivo xml , Diretório + nome do arquivo
 Rezult      := S_FALSE; /// A grande sacada esta aqui: S_FALSE significa que não pedir para a caixinha de onde salvar.
 If FileExists(CaminhoXML) Then
  Begin
   vLastErrorString := PChar(Format('NF-e salva em %s.', [CaminhoXML]));
   vError           := False;
  End
 Else
  Begin
   vLastErrorString := 'Erro baixando a NF-e';
   vError           := True;
  End;
 NovaConsulta;
end;

procedure TfDownload.WebBrowser1DocumentComplete(ASender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
 Source   : string;
begin
 Application.ProcessMessages;
 If (vDocumentHold) And
    (WebBrowser1.LocationURL <> 'http://www.nfe.fazenda.gov.br/portal/consultaCompleta.aspx?tipoConteudo=XbSeqxE8pl8=') Then
  Begin
   vtextoNFe := WebBrowser1.Document as IHTMLDocument2;
   Source   := StripHTML(vtextoNFe.body.innerHTML);
   Source   := StringReplace(Source, '&nbsp;','',[rfReplaceAll, rfIgnoreCase]);
   If Pos('Há um problema no certificado de segurança', Source) > 0 Then
    Begin
     vLastErrorString := 'Erro no certificado, verifique se o certificado de segurança está corretamente instalado e tente novamente.';
     vError           := True;
     vDocumentHold    := False;
     NovaConsulta;
    End
   Else If Pos('não está autorizado a fazer o download do documento', Source) > 0 Then
    Begin
     vLastErrorString := 'Este Certificado não está autorizado a fazer o download do documento selecionado.';
     vError           := True;
     vDocumentHold    := False;
     NovaConsulta;
    End
   Else If Pos('Código da Imagem inválido.', Source) > 0 Then
    Begin
     vLastErrorString := 'Captcha inválida...';
     vError           := True;
     vDocumentHold    := False;
     NovaConsulta;
    End;
  End
 Else If WebBrowser1.LocationURL = 'http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=' Then
  Begin
//   btnPegarHTML.Enabled := True;
   vDocumentHold := False;
  End
 Else If WebBrowser1.LocationURL = 'https://www.nfe.fazenda.gov.br/portal/visualizacaoNFe/completa/Default.aspx' Then
  Begin
   WebBrowser1.Navigate('https://www.nfe.fazenda.gov.br/PORTAL/visualizacaoNFe/completa/impressao.aspx');
   vDocumentHold := False;
  End
 Else if WebBrowser1.LocationURL = 'http://www.nfe.fazenda.gov.br/portal/consultaCompleta.aspx?tipoConteudo=XbSeqxE8pl8=' then
  Begin
   vtextoNFe := WebBrowser1.Document as IHTMLDocument2;
   Repeat
    Application.ProcessMessages;
   Until Assigned(vtextoNFe.body);
   vStringXML := StripHTML(vtextoNFe.body.innerHTML);
   vStringXML := StringReplace(vStringXML, '&nbsp;','',[rfReplaceAll, rfIgnoreCase]);
   {
   i := 0;
   While i < Memo1.Count-1 do
    Begin
     If trim(Memo1[i]) = '' Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('function',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('document',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('{',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     i := i + 1;
    End;
   }
   imgCaptcha.Picture      := nil;
   GeraXml;
   vDocumentHold := False;
  End
 Else If WebBrowser1.LocationURL = 'https://www.nfe.fazenda.gov.br/portal/inexistente_completa.aspx' Then
  Begin
   vLastErrorString := 'NF-e INEXISTENTE na base nacional, favor consultar esta NF-e no site da SEFAZ de origem.';
   imgCaptcha.Picture          := nil;
   vDocumentHold := False;
   vError        := True;
  End
 Else
  Begin
   vLastErrorString := 'Erro no captcha, digite corretamente ou atualize a imagem e tente novamente.';
   imgCaptcha.Picture          := nil;
   vDocumentHold := False;
   vError        := True;
  End;
 If Not vGetXML Then
  MostrarImagem;
end;

procedure TfDownload.WBXMLDocumentComplete(Sender: TObject;
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
   If Pos('Há um problema no certificado de segurança', Source) > 0 Then
    Begin
     vLastErrorString := 'Erro no certificado, verifique se o certificado de segurança está corretamente instalado e tente novamente.';
     vError           := True;
     NovaConsulta;
    End
   Else If Pos('não está autorizado a fazer o download do documento', Source) > 0 Then
    Begin
     vLastErrorString := 'Este Certificado não está autorizado a fazer o download do documento selecionado.';
     vError           := True;
     NovaConsulta;
    End;
   vDocumentHold     := False;
  End
 Else If WebBrowser1.LocationURL = 'http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=completa&tipoConteudo=XbSeqxE8pl8=' Then
  Begin
//   btnPegarHTML.Enabled := True;
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
   Repeat
    Application.ProcessMessages;
   Until Assigned(textoNFe.body);
   Memo1.Text := StripHTML(textoNFe.body.innerHTML);
   Memo1.Text := StringReplace(Memo1.Text,'&nbsp;','',[rfReplaceAll, rfIgnoreCase]);
   i := 0;
   While i < Memo1.Count-1 do
    Begin
     If trim(Memo1[i]) = '' Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('function',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('document',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('{',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     If Pos('}',Memo1[i]) > 0 Then
      Begin
       Memo1.Delete(i);
       i := i - 1;
      End;
     i := i + 1;
    End;
   imgCaptcha.Picture      := nil;
   GeraXml;
  End
 Else If WebBrowser1.LocationURL = 'https://www.nfe.fazenda.gov.br/portal/inexistente_completa.aspx' Then
  Begin
   vLastErrorString := 'NF-e INEXISTENTE na base nacional, favor consultar esta NF-e no site da SEFAZ de origem.';
   imgCaptcha.Picture          := nil;
   vDocumentHold := False;
   vError        := True;
  End
 Else
  Begin
   vLastErrorString := 'Erro no captcha, digite corretamente ou atualize a imagem e tente novamente.';
   imgCaptcha.Picture          := nil;
   vDocumentHold := False;
   vError        := True;
  End;
 MostrarImagem;
end;

end.
