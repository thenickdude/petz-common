unit spriteRCDATAunit;

interface

uses windows, sysutils, classes, contnrs, madres;

type
  TSpriteRC = class
  public
    sprname, displayname: string;
    avail: longword;
    id: word; // Petz stores as longword in file but only word significant (breed ids)
  end;

  TSpriteList = class
  private
    flist: TObjectList;

    function getSprite(index: integer): TSpriteRC;
    procedure setSprite(index: integer; value: TSpriteRC);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(sprite: TSpriteRC);
    procedure Clear;
    function Count: integer;
    property Sprites[index: integer]: TSpriteRC read getSprite write setSprite; default;
  end;

  TSpriteRCdecoder = class
  public
    sprites: TSpriteList;
    procedure encode(stream: tmemorystream);
    procedure decode(stream: tmemorystream); overload;
    function decode(filename: string): boolean; overload;
    constructor create;
    destructor Destroy; override;
  end;

  TStringtabledecoder = class
  private
    ftablenum: integer;
  public
    strings: array[0..15] of string;
    class function TableNum(id: integer): integer;
    class function StringNum(id: integer): integer;
    function getstring(id: integer): string;
    procedure setstring(id: integer; value: string);
    procedure decode(stream: tmemorystream);
    procedure encode(stream: tmemorystream);
    constructor create(tablenum: integer);
  end;

function GetResourceString(id: word; update: cardinal = 0; const filename: string = ''): string;

implementation

function TSpriteList.getSprite(index: integer): TSpriteRC;
begin
  result := TSpriteRC(flist[index]);
end;

procedure TSpriteList.setSprite(index: integer; value: TSpriteRC);
begin
  flist[index] := value;
end;

constructor TSpriteList.Create;
begin
  inherited;
  flist := TObjectList.Create;
end;

destructor TSpriteList.Destroy;
begin
  flist.free;
  inherited;
end;

procedure TSpriteList.Add(sprite: TSpriteRC);
begin
  flist.add(sprite);
end;

procedure TSpriteList.Clear;
begin
  flist.clear;
end;

function TSpriteList.Count: integer;
begin
  result := flist.count;
end;

function GetResourceString(id: word; update: cardinal = 0; const filename: string = ''): string;
var needtoclose: boolean;
  stream: tmemorystream;
  stdecoder: TStringtabledecoder;
  data: pointer;
  size: cardinal;
begin
  needtoclose := false;

  if update = 0 then begin
    needtoclose := true;
    update := BeginUpdateResourceW(pwidechar(widestring(filename)), false);
  end;
  try
    if GetResourceW(update, pwidechar(rt_string), pwidechar(TStringtabledecoder.TableNum(id)), 1033, data, size) then begin
      stream := tmemorystream.create;
      try
        stream.write(data^, size);
        stream.seek(0, sofrombeginning);
        stdecoder := TStringtabledecoder.create(TStringtabledecoder.TableNum(id));
        try
          stdecoder.decode(stream);
          result := stdecoder.getstring(id);
        finally
          stdecoder.free;
        end;
      finally
        stream.free;
      end;
    end else result := '';
  finally
    if needtoclose then
      EndUpdateResourceW(update, true);
  end;
end;

class function tstringtabledecoder.TableNum(id: integer): integer;
begin
  result := id and $FFF0 shr 4 + 1;
end;

class function tstringtabledecoder.StringNum(id: integer): integer;
begin
  result := id and $F;
end;


function tstringtabledecoder.getstring(id: integer): string;
var l, h: integer;
begin
  l := stringnum(id);
  h := tablenum(id);
  if h <> ftablenum then
    raise exception.create('ID not in current table');
  result := strings[l];
end;

procedure tstringtabledecoder.setstring(id: integer; value: string);
var l, h: integer;
begin
  l := id and $F;
  h := id and $FFF0 shr 4 + 1;
  if h <> ftablenum then
    raise exception.create('ID not in current table');
  strings[l] := value;
end;

procedure tstringtabledecoder.decode(stream: tmemorystream);
var t1: integer;
  l: word;
  buf: widestring;
begin
  for t1 := 0 to 15 do begin

    if stream.size - stream.position < 2 then begin
      strings[t1] := '';
      continue;
    end;

    stream.read(l, 2);
    if (l = 0) or (stream.size - stream.position < l * 2) then
      strings[t1] := '' else begin
      setlength(buf, l);
      stream.read(buf[1], l * 2);
      strings[t1] := buf;
      if pos(#0, strings[t1]) > 0 then
        strings[t1] := copy(strings[t1], 1, pos(#0, strings[t1]) - 1); //mimmic C++ programs for hex edited files
    end;
  end;
end;

procedure tstringtabledecoder.encode(stream: tmemorystream);
var t1: integer;
  w: word;
  buf: widestring;
begin
  for t1 := 0 to 15 do begin
    w := length(strings[t1]);
    stream.write(w, 2);
    if w > 0 then begin
      buf := strings[t1];
      stream.write(buf[1], w * 2);
    end;
  end;
end;

constructor tstringtabledecoder.create(tablenum: integer);
begin
  ftablenum := tablenum;
end;

procedure tspritercdecoder.encode(stream: tmemorystream);
var spcount: longword;
  sprite: tspriterc;
  t1: integer;
  buf: string;
  l: longword;
begin
  spcount := sprites.Count;
  stream.write(spcount, 4);
  for t1 := 0 to spcount - 1 do begin
    sprite := TSpriteRC(sprites[t1]);

    if length(sprite.sprname) < 32 then
      buf := sprite.sprname + stringofchar(#0, 32 - length(sprite.sprname)) else
      buf := sprite.sprname;
    stream.write(buf[1], 32);

    if length(sprite.displayname) < 32 then
      buf := sprite.displayname + stringofchar(#0, 32 - length(sprite.displayname)) else
      buf := sprite.displayname;
    stream.write(buf[1], 32);

    l := sprite.id;
    stream.write(l, 4);
    stream.write(sprite.avail, 4);
  end;
end;

function tspritercdecoder.decode(filename: string): boolean;
var update, size: cardinal;
  data: pointer;
  stream: tmemorystream;
begin
  result := false;
  update := BeginUpdateResourceW(pwidechar(widestring(filename)), false);
  try
    if GetResourceW(update, pwidechar(RT_RCDATA), pwidechar(1003), 1033, data, size) then begin
      stream := tmemorystream.create;
      try
        stream.Write(data^, size);
        stream.seek(0, sofrombeginning);
        decode(stream);
      finally
        stream.free;
      end;
      result := true;
    end;
  finally
    EndUpdateResourceW(update, true);
  end;
end;

procedure tspritercdecoder.decode(stream: tmemorystream);
var spcount: longword;
  t1: integer;
  sprite: tspriterc;
  l: longword;
begin
  sprites.clear;
  stream.read(spcount, 4);
  for t1 := 0 to spcount - 1 do begin
    sprite := TSpriteRC.Create;

    setlength(sprite.sprname, 32);
    stream.read(sprite.sprname[1], 32);
    setlength(sprite.sprname, pos(#0, sprite.sprname) - 1);

    setlength(sprite.displayname, 32);
    stream.read(sprite.displayname[1], 32);
    setlength(sprite.displayname, pos(#0, sprite.displayname) - 1);

    stream.read(l, 4);
    sprite.id := l and $FFFF;
    stream.read(sprite.avail, 4);
    sprites.add(sprite);
  end;
end;

constructor tspritercdecoder.create;
begin
  sprites := TSpriteList.create;
end;

destructor tspritercdecoder.destroy;
begin
  sprites.free;
end;

end.

