{$DEFINE  ViaCep}
unit viacep;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, TextStrings, fphttpclient, XMLRead, Dom, strutils
  ,JsonTools;

///////////////////////////TViaCep/////////////////////////////////
//   Desenvolvedor: Humberto Sales                               //
//   Email        : humbertoliveira@hotmail.com                  //
//   Telegram     : https://t.me/joinchat/CSQp_RFqlyfvOQYE5oKKZw //
//   Colaboradores:                                              //
//        (informe nomes aqui - caso seja um colaborador)        //
//        *                                                      //
//        *                                                      //
//                                                               //
///////////////////////////////////////////////////////////////////


Type

  TAbout = class(TPersistent)
  private
    FContato       : String;
    FData          : String;
    fDesenvolvedor : String;
    FLicenca       : String;
    FVersao        : String;
    FAgradecimento : String;
  public
      procedure Assign(Source: TPersistent); override;
      constructor Create;
  published
    property Desenvolvedor : String read fDesenvolvedor;
    property Contato       : String read FContato;
    property Data          : String read FData;
    property Versao        : String read FVersao;
    property Licenca       : String read FLicenca;
    property Agradecimento : String read FAgradecimento;
  end;

  TFormatodados = (fdxml,fdJson,fdpiped);
  TCaixa = (cMaiuscula,cMinuscula,cIniciais);

  { TViaCep }

   TViaCep = Class(TComponent)
  private
    Fbairro        : string;
    FCaracter: Tcaixa;
    Fcep           : String;
    Fcomplemento   : string;
    FFormatoDados : TFormatoDados;
    Fgia           : string;
    Fibge          : string;
    Flocalidade    : string;
    Flogradouro    : string;
    Fretorno: string;
    Fuf            : string;
    FSobre         : TAbout;
    Const
    Furl           = 'http://www.viacep.com.br/ws/';
    procedure SetCaracter(AValue: Tcaixa);
    procedure Setcep(AValue: String);
    procedure subtrairdados(fd: TformatoDados; informacao: String);
    public
      constructor Create(theOwner: TComponent);override;
      destructor Destroy; override;
      procedure executar;
      procedure procurar;
      procedure ativar;
    published
      property FormatoDados : TFormatoDados read FFormatoDados write FFormatoDados;
      property cep           : String read Fcep write Setcep;
      property logradouro    : string read Flogradouro;
      property complemento   : string read Fcomplemento;
      property bairro        : string read Fbairro;
      property localidade    : string read Flocalidade;
      property uf            : string read Fuf;
      property ibge          : string read Fibge;
      property gia           : string read Fgia;
      property retorno       : string read Fretorno;
      property caracter      : Tcaixa read FCaracter write SetCaracter;
      property Sobre         : TAbout read FSobre;
  end;

  procedure register;

implementation

procedure register;
begin
  {$i viacep.lrs}    //LResources
  RegisterComponents('Humberto', [TViaCep]);
end;


procedure TAbout.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TAbout) then
  begin
    fDesenvolvedor := TAbout(Source).Desenvolvedor;
    fContato       := TAbout(Source).Contato;
    fData          := TAbout(Source).Data;
    fVersao        := TAbout(Source).fVersao;
    fAgradecimento := TAbout(Source).fAgradecimento;
    Exit;
  end;
  inherited Assign(Source);
end;

constructor TAbout.Create;
begin
  FDesenvolvedor := 'Humberto Sales de Oliveira';
  FContato       := '+55 (34) 99973-1581';
  FData          := '05/08/2017';
  FVersao        := '1.0';
  FLicenca       := 'Usar a vontade';
  FAgradecimento := 'http://viacep.com.br/ sem vocês esse componente não seria possível!';
end;

constructor TViaCep.Create(theOwner: TComponent);
begin
    inherited create(TheOwner);
    FFormatoDados := fdJson;
    FCaracter     := cIniciais;
    FSobre        := TAbout.create;
end;

destructor TViaCep.Destroy;
begin
  FreeAndNil(FSobre);
  inherited Destroy;
end;

procedure TViaCep.Setcep(AValue: String);
   function soNumeros(valor : String) : String;
        var
          i : byte;
        begin
            for i := 1 to length(valor) do
                    if valor[i] in ['0'..'9'] then
                         result := result + valor[i];
        end;
begin
  if Fcep=AValue then Exit;

  Fcep:= soNumeros(AValue);
end;

procedure TViaCep.SetCaracter(AValue: Tcaixa);
begin
  if FCaracter=AValue then Exit;
  FCaracter:=AValue;
end;

procedure TViaCep.executar;
begin
  With Tfphttpclient.create(Nil) do
          begin
               //AddHeader('Content-Type','application/json; charset=utf-8');
               AllowRedirect := true;
               try
                   case FormatoDados of
                       fdxml   :  SubtrairDados(fdXml, Get( fUrl + fcep +'/xml/' ) );
                       fdJson  :  SubtrairDados(fdJson , Get( fUrl + fcep +'/json/' ) );
                       fdpiped :  SubtrairDados(fdpiped, Get( fUrl + fcep +'/piped/' ) );
                   end;
               except
                   raise Exception.Create('Houve um erro ao procurar o cep');
                   Free;
               end;
               Free;
          end;
end;

procedure TViaCep.procurar;
begin
  executar;
end;

procedure TViaCep.ativar;
begin
  executar;
end;

procedure TViaCep.subtrairdados(fd : TformatoDados;informacao : String);
 function caracteres(Valor : String; Caixa : TCaixa) : String;
    begin
        Case Caixa of
            cMaiuscula : result := UpperCase(Valor);
            cMinuscula : result := LowerCase(Valor);
            cIniciais  : result := Valor;
        end;
    end;
var
  i: Integer;
  JsDados : TJsonNode; // jsontools;
  Doc: TXMLDocument;   //XMLRead,Dom,
  Node: TDOMNode;
  M  : TStringStream;
begin
      FRetorno :=  informacao ;
      //strutils
      if AnsiContainsText(informacao,'<erro>') = true
        or AnsiContainsText(informacao,'"erro"') = true
        or AnsiContainsText(informacao,'erro:true') = true   then
             begin
                   raise Exception.Create('Houve um erro. Cep inválido!');
             end;
      case fd of
          fdxml   :
                 begin
                     try
                       M            := TStringStream.Create(Informacao);
                       M.Position   :=0;
                       ReadXMLFile(Doc, M);
                       Node         := Doc.DocumentElement.FindNode('cep');
                       Fcep         := Caracteres( Node.TextContent, fCaracter );
                       Node         := Doc.DocumentElement.FindNode('logradouro');
                       Flogradouro  := Caracteres( Node.TextContent,fCaracter );
                       Node         := Doc.DocumentElement.FindNode('complemento');
                       Fcomplemento := Caracteres( Node.TextContent,fCaracter );
                       Node         := Doc.DocumentElement.FindNode('bairro');
                       Fbairro      := Caracteres( Node.TextContent,fCaracter );
                       Node         := Doc.DocumentElement.FindNode('localidade');
                       Flocalidade  := Caracteres( Node.TextContent,fCaracter );
                       Node         := Doc.DocumentElement.FindNode('uf');
                       fuf          := Caracteres( Node.TextContent,fCaracter );
                       Node         := Doc.DocumentElement.FindNode('ibge');
                       Fibge        := Caracteres( Node.TextContent,fCaracter );
                       Node         := Doc.DocumentElement.FindNode('gia');
                       Fgia         := Caracteres( Node.TextContent,fCaracter );
                     finally
                       Doc.Free;
                       M.free;
                     end;
                 end;
          fdJson  :
                 begin
                     try
                        JsDados      := TJsonNode.Create;
                        JsDados.Parse( Informacao );
                        Fcep         := Caracteres( JsDados.Find('cep').AsString,fCaracter );
                        Flogradouro  := Caracteres( JsDados.Find('logradouro').AsString,fCaracter );
                        Fcomplemento := Caracteres( JsDados.Find('complemento').AsString,fCaracter );
                        Fbairro      := Caracteres( JsDados.Find('bairro').AsString,fCaracter );
                        Flocalidade  := Caracteres( JsDados.Find('localidade').AsString,fCaracter );
                        fuf          := Caracteres( JsDados.Find('uf').AsString,fCaracter );
                        Fibge        := Caracteres( JsDados.Find('ibge').AsString,fCaracter );
                        fgia         := Caracteres( JsDados.Find('gia').AsString,fCaracter );

                     finally
                       JsDados.Free;
                     end;


                 end;
          fdpiped :
                 begin
                     delete(informacao,1,pos(':',informacao));
                     Fcep         := Caracteres( copy(Informacao,1,pos('|',Informacao) -1 ), fCaracter );
                     delete(informacao,1,pos(':',informacao));
                     Flogradouro  := Caracteres( copy(Informacao,1,pos('|',Informacao) -1 ), fCaracter );
                     delete(informacao,1,pos(':',informacao));
                     Fcomplemento := Caracteres( copy(Informacao,1,pos('|',Informacao) -1 ), fCaracter );
                     delete(informacao,1,pos(':',informacao));
                     Fbairro      := Caracteres( copy(Informacao,1,pos('|',Informacao) -1 ), fCaracter );
                     delete(informacao,1,pos(':',informacao));
                     Flocalidade  := Caracteres( copy(Informacao,1,pos('|',Informacao) -1 ), fCaracter );
                     delete(informacao,1,pos(':',informacao));
                     Fuf          := Caracteres( copy(Informacao,1,pos('|',Informacao) -1 ), fCaracter );
                     delete(informacao,1,pos(':',informacao));
                     Fibge        := Caracteres( copy(Informacao,1,pos('|',Informacao) -1 ), fCaracter );
                     delete(informacao,1,pos(':',informacao));
                     Fgia         :=Caracteres( Informacao, fCaracter );
                 end;
      end;
end;


end.

