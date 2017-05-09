unit DownloadXMLApp;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Button4: TButton;
    Memo1: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  DLL        : THandle;
  Proc       : Function  (PathCAPTCHA : PChar; Var Error : PChar) : Boolean; Stdcall;
  Proc2      : Function  (PathXMP, ChaveXML, Captcha : PChar; Var Error : PChar) : Boolean; Stdcall;
  Proc3      : Procedure (PathXML, PathCAPTCHA : PChar); Stdcall;
  Proc4      : Function  (ChaveXML, Captcha : PChar; Var XMLString, Error : PChar) : Boolean; Stdcall;
  ProcFinish : Procedure; Stdcall;

implementation

{$R *.dfm}

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 If DLL <> 0 Then
  Begin
   //Isso aqui e altamente necessario para nao ter access violation, pois o Form de Consulta nao pode ser fechado...
   ProcFinish;
   FreeLibrary(DLL);
  End;
 Form1 := Nil;
 Release;
end;

procedure TForm1.Button2Click(Sender: TObject);
Var
 vError : PChar;
Begin
 If Not Proc('C:\temp\captcha\captchateste.png', vError) Then
  Showmessage('Captcha na pasta')
 Else
  Showmessage('Erro no download do Captcha');
End;

procedure TForm1.Button3Click(Sender: TObject);
Var
 vError : PChar;
Begin
 Proc2(PChar('C:\temp'), PChar(Edit2.Text), PChar(Edit1.Text), vError);
 Showmessage(PChar(vError));
End;

procedure TForm1.FormCreate(Sender: TObject);
begin
 DLL         := LoadLibrary(PChar(ExtractFilePath(Application.ExeName) + 'DownloadXML.dll'));
 @Proc       := GetProcAddress(DLL, 'RecuperaCaptchaDelphi');    // A Função para CPP e outros C's é "RecuperaCaptchaCPP"
 @Proc2      := GetProcAddress(DLL, 'RecuperaArquivoXMLDelphi'); // A Função para CPP e outros C's é "RecuperaArquivoXMLCPP"
 @Proc3      := GetProcAddress(DLL, 'RecuperaXMLDelphi');        // A Função para CPP e outros C's é "RecuperaXMLCPP"
 @Proc4      := GetProcAddress(DLL, 'RecuperaXMLStringDelphi');  // A Função para CPP e outros C's é "RecuperaXMLStringCPP"
 @ProcFinish := GetProcAddress(DLL, 'DestroyFormDelphi');        // A Função para CPP e outros C's é "DestroyFormCPP"
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 Proc3(PChar('C:\temp'), PChar('C:\temp\captcha'));
end;

procedure TForm1.Button4Click(Sender: TObject);
Var
 vResult, vError : PChar;
Begin
 Memo1.Lines.Clear;
 Proc4(PChar(Edit2.Text), PChar(Edit1.Text), vResult, vError);
 Memo1.Lines.Text := vResult;
End;

end.
