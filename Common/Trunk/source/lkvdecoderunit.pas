unit lkvdecoderunit;

interface

uses sysutils, windows, classes, contnrs,registry;

type TLKVDecoder = class(TStringList)
  public
    constructor create;
    destructor Destroy; override;
    procedure LoadFromStream(stream: tstream); override;
    procedure SaveToStream(stream: tstream); override;
    procedure updatecaseregistry;
  end;

implementation

constructor tlkvdecoder.create;
begin
  inherited;
end;

destructor tlkvdecoder.destroy;
begin
  inherited;
end;

procedure tlkvdecoder.loadfromstream(stream: tstream);
var buf:string;
lw1:longword;
begin
clear;
   stream.seek(0, sofrombeginning);
    while stream.position < stream.size - 1 do begin
      setlength(buf, 256);
      stream.read(buf[1], 256);
      if pos(#0, buf) > 0 then
        setlength(buf, pos(#0, buf) - 1);
      if length(extractfilename(buf))>0 then add(extractfilename(buf));
      stream.read(lw1, 4);
    end;
end;

procedure tlkvdecoder.updatecaseregistry;
var reg: tregistry;
  lw1:longword;
begin
  reg := tregistry.create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    if reg.openkey('SOFTWARE\StudioMythos\Petz 5\4.00.00', false) then begin
      lw1 := Count;
      reg.WriteBinaryData('Case ListSize', lw1, 4);
    end;
  finally
    reg.free;
  end;
end;


procedure tlkvdecoder.savetostream(stream: tstream);
var
  buf: string;
  t1: integer;
  lw1: longword;
begin
  for t1 := 0 to count - 1 do begin
    buf := '\Resource\Toyz\' + Strings[t1];
    if length(buf) < 256 then
      buf := buf + StringOfChar(#0, 256 - length(buf));
    stream.write(buf[1], 256);
    lw1 := 0;
    stream.write(lw1, 4);
  end;


end;


end.

