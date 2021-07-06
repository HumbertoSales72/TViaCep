unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  fphttpclient, fpjson, jsonparser, jsonscanner,
  laz2_XMLRead, Laz2_DOM,
  XMLRead,Dom,
  FileUtil, TextStrings, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, viacep;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button7: TButton;
    Edit10: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    ViaCep1: TViaCep;
    procedure Button7Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button7Click(Sender: TObject);
begin
  With ViaCep1 do
      begin
         cep           := edit10.text;
         //Formato_Dados := fdJon; {fdxml,fdJson(padrao),fdpiped} ;
         executar;
         Edit2.text    := Logradouro;
         Edit3.text    := complemento;
         Edit4.text    := bairro;
         Edit5.text    := Localidade;
         Edit6.text    := uf;
         Edit8.text    := Ibge;
         Edit9.text    := gia;
         Memo1.text    := retorno;  //retorno do envio
      end;
end;

end.

