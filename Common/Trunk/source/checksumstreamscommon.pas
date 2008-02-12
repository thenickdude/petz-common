unit checksumstreamscommon;

interface

uses sysutils,classes,contnrs;

type EDamagedfile = class(exception);

function checksum(data: pbytearray; size: integer): longword;
procedure writestring(stream: tstream; const s: string);
procedure copyuntil(source: tstream; dest: tmemorystream; key: string);

implementation

procedure copyuntil(source: tstream; dest: tmemorystream; key: string);
var t1: integer;
  comp: string;
  startpos, endpos: integer;
begin
  startpos := source.position;
  setlength(comp, length(key));

  for t1 := startpos + 1 {don't check the first position..} to source.size - length(key) do begin
    source.Seek(t1, sofrombeginning);
    endpos := t1;
    source.Read(comp[1], length(key));
    if comp = key then begin
      source.position := startpos;
      dest.copyfrom(source, endpos - startpos);
      source.position := endpos + length(key);
      exit;
    end;
  end;
end;

procedure writestring(stream: tstream; const s: string);
begin
  if length(s) > 0 then
    stream.write(s[1], length(s));
end;

{$R-}
function checksum(data: pbytearray; size: integer): longword;
begin
  result := 0;
  while size > 0 do begin
    dec(size);
    result := result + data^[size];
  end;
end;
{$R+}

end.
