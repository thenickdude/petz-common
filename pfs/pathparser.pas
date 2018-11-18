unit pathparser;

interface

uses sysutils, classes, windows;

type
  TPathParser = class
  private
    fparts: TStringlist;
  public
    class function pathIsChild(const root: string; const path: string; out relpart: string): boolean;
    function empty: boolean;
    procedure decode(path: string);
    function encode: string;
    function count: integer;
    function pop: string;
    procedure push(const part: string);
    procedure clear;
    constructor create(const path: string);
    destructor Destroy; override;
  end;

implementation

function bite(var path: string; out name: string): boolean;
var slashpos: integer;
begin
  result := (pos('\', path) > 0) or (pos('/', path) > 0);
  if result then begin
    if pos('\', path) > 0 then
      slashpos := pos('\', path) else
      if pos('/', path) > 0 then
        slashpos := pos('/', path) else
        slashpos := 0; //cant happen

    name := copy(path, 1, slashpos - 1);
    path := copy(path, slashpos + 1, length(path));
  end;
end;

function tpathparser.empty: boolean;
begin
  result := (count = 0);
end;

procedure tpathparser.decode(path: string);
const slashes = ['\', '/'];
var slashpos: integer;
begin
  clear;
  if length(path) = 0 then exit;
  if path[1] in slashes then //remove first slash
    path := copy(path, 2, length(path));

  while length(path) > 0 do begin
    if (pos('\', path) > 0) or (pos('/', path) > 0) then begin
      if pos('\', path) > 0 then
        slashpos := pos('\', path) else
        if pos('/', path) > 0 then
          slashpos := pos('/', path) else
          slashpos := 0; //cant happen
      push(copy(path, 1, slashpos - 1));
      path := copy(path, slashpos + 1, length(path));
    end else begin
      push(path);
      path := '';
    end;
  end;
end;

function tpathparser.encode: string;
var t1:integer;
begin
result:='';
for t1:=0 to count-1 do
 result:=result+fparts[t1]+'\';
setlength(result,length(result)-1);
end;

class function tpathparser.pathIsChild(const root: string; const path: string; out relpart: string): boolean;
var p1, p2: TPathParser;
  t1: integer;
begin
  relpart := '';
  p1 := TPathParser.create(root);
  p2 := TPathParser.create(path);
  try
    if p2.count < p1.count then result := false else begin

      result := true;
      for t1 := 0 to p1.count - 1 do
        if (ansicomparetext(p1.pop, p2.pop) <> 0) then begin
          result := false;
          exit;
        end;
      if result then
        relpart := p2.encode;
    end;
  finally
    p1.free;
    p2.free;
  end;
end;

function tpathparser.count: integer;
begin
  result := fparts.count;
end;

procedure tpathparser.push(const part: string);
begin
  fparts.add(part);
end;

function tpathparser.pop: string;
begin
  if fparts.count > 0 then begin
    result := fparts[0];
    fparts.delete(0);
  end else begin
    result := '';
  end;
end;

procedure tpathparser.clear;
begin
  fparts.clear;
end;

constructor tpathparser.create(const path: string);
begin
  fparts := tstringlist.create;
  decode(path);
end;

destructor tpathparser.destroy;
begin
  fparts.free;
  inherited;
end;


end.

