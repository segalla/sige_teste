library DownloadXML;

uses
  Sharemem,
  Forms,
  SysUtils,
  Classes,
  Windows,
  MSHTML,
  SHDocVw_EWB,
  EmbeddedWB,
  uRecuperaXML in 'uRecuperaXML.pas' {frmRecuperaXML},
  ACBrHTMLtoXML in 'ACBrHTMLtoXML.pas',
  uDownloadMem in 'uDownloadMem.pas' {fDownload};

Var
 vDownload   : TfDownload;

{$R *.res}

Procedure DestroyFormDelphi;stdcall;export;
Begin
 FreeAndNil(vDownload);
End;

Procedure DestroyFormCPP;cdecl;export;
Begin
 FreeAndNil(vDownload);
End;

Function RecuperaArquivoXMLDelphi(PathXMP, ChaveXML, Captcha : PChar; Var Error : PChar) : Boolean; stdcall;export;
Begin
 Result := False;
 If vDownload <> Nil Then
  Begin
   If Length(Captcha) <> 6 Then
    Begin
     Result               := False;
     Error                := 'Captcha com tamanho inválido';
     Exit;
    End;
   vDownload.CaminhoDados := PathXMP;
   vDownload.Captcha      := Captcha;
   vDownload.ChaveNFe     := ChaveXML;
   vDownload.Show;
   Result                 := vDownload.GetXMLNfe;
   Error                  := PChar(vDownload.LastErrorString);
   vDownload.Hide;
  End;
End;

Function RecuperaXMLStringDelphi(ChaveXML, Captcha : PChar; Var XMLString, Error : PChar) : Boolean; stdcall;export;
Begin
 Result := False;
 If vDownload <> Nil Then
  Begin
   If Length(Captcha) <> 6 Then
    Begin
     Result               := False;
     Error                := 'Captcha com tamanho inválido';
     Exit;
    End;
//   vDownload.CaminhoDados := PathXMP;
   vDownload.Captcha      := Captcha;
   vDownload.ChaveNFe     := ChaveXML;
   vDownload.Show;
   Result                 := vDownload.GetXMLNfe;
   XMLString              := PChar(vDownload.StringXML);
   Error                  := PChar(vDownload.LastErrorString);
   vDownload.Hide;
  End;
End;

Function RecuperaXMLStringCPP(ChaveXML, Captcha : PChar; Var XMLString, Error : PChar) : Boolean; cdecl;export;
Begin
 Result := False;
 If vDownload <> Nil Then
  Begin
   If Length(Captcha) <> 6 Then
    Begin
     Result               := False;
     Error                := 'Captcha com tamanho inválido';
     Exit;
    End;
//   vDownload.CaminhoDados := PathXMP;
   vDownload.Captcha      := Captcha;
   vDownload.ChaveNFe     := ChaveXML;
   vDownload.Show;
   Result                 := vDownload.GetXMLNfe;
   XMLString              := PChar(vDownload.StringXML);
   Error                  := PChar(vDownload.LastErrorString);
   vDownload.Hide;
  End;
End;

Function RecuperaArquivoXMLCPP(PathXMP, ChaveXML, Captcha : PChar; Var Error : PChar) : Boolean; cdecl;export;
Begin
 Result := False;
 If vDownload <> Nil Then
  Begin
   If Length(Captcha) <> 6 Then
    Begin
     Result               := False;
     Error                := 'Captcha com tamanho inválido';
     Exit;
    End;
   vDownload.CaminhoDados := PathXMP;
   vDownload.Captcha      := Captcha;
   vDownload.ChaveNFe     := ChaveXML;
   vDownload.Show;
//   XMLString              := PChar(vDownload.StringXML);
   Result                 := vDownload.GetXMLNfe;
   Error                  := PChar(vDownload.LastErrorString);
   vDownload.Hide;
  End;
End;

Function RecuperaCaptchaDelphi(PathCAPTCHA : PChar; Var Error : PChar) : Boolean; stdcall;export;
Begin
 Result := False;
 If vDownload <> Nil Then
  Begin
   vDownload.CaminhoCaptcha := PathCAPTCHA;
   vDownload.Show;
   Result   := vDownload.GetCaptcha;
   Error    := PChar(vDownload.LastErrorString);
   vDownload.Hide;
  End;
End;

Function RecuperaCaptchaCPP(PathCAPTCHA : PChar; Var Error : PChar) : Boolean; cdecl;export;
Begin
 Result := False;
 If vDownload <> Nil Then
  Begin
   vDownload.CaminhoCaptcha := PathCAPTCHA;
   vDownload.Show;
   Result := vDownload.GetCaptcha;
   Error  := PChar(vDownload.LastErrorString);
   vDownload.Hide;
  End;
End;

Procedure RecuperaXMLDelphi(PathXML, PathCAPTCHA : PChar); stdcall;export;
Var
 vfrmRecuperaXML : TfrmRecuperaXML;
Begin
 vfrmRecuperaXML                := TfrmRecuperaXML.Create(Nil);
 vfrmRecuperaXML.ShowErrors     := True;
 vfrmRecuperaXML.CaminhoDados   := PathXML;
 If (Trim(PathCAPTCHA)) = '' Then
  vfrmRecuperaXML.CaminhoCaptcha := PathXML
 Else
  vfrmRecuperaXML.CaminhoCaptcha := PathCAPTCHA;
 vfrmRecuperaXML.ShowModal;
 vfrmRecuperaXML.Free;
End;

Procedure RecuperaXMLCPP(PathXML, PathCAPTCHA : PChar); cdecl;export;
Var
 vfrmRecuperaXML : TfrmRecuperaXML;
Begin
 vfrmRecuperaXML              := TfrmRecuperaXML.Create(Nil);
 vfrmRecuperaXML.ShowErrors   := True;
 vfrmRecuperaXML.CaminhoDados := PathXML;
 If (Trim(PathCAPTCHA)) = '' Then
  vfrmRecuperaXML.CaminhoCaptcha := PathXML
 Else
  vfrmRecuperaXML.CaminhoCaptcha := PathCAPTCHA;
 vfrmRecuperaXML.ShowModal;
 vfrmRecuperaXML.Free;
End;

Exports
 RecuperaXMLDelphi,
 RecuperaXMLCPP,
 RecuperaCaptchaDelphi,
 RecuperaCaptchaCPP,
 RecuperaXMLStringDelphi,
 RecuperaArquivoXMLDelphi,
 RecuperaXMLStringCPP,
 RecuperaArquivoXMLCPP,
 DestroyFormDelphi,
 DestroyFormCPP;

Begin
 vDownload := TfDownload.Create(Nil);

end.


