{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pkviacep;

{$warn 5023 off : no warning about unused units}
interface

uses
  viacep, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('viacep', @viacep.Register);
end;

initialization
  RegisterPackage('pkviacep', @Register);
end.
