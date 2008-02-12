unit xmlassist;

interface
uses sysutils;

function strtointfb(const s: string; i: integer): integer;
function isnumeric(const s: string): boolean;
function require(item: TObject; const message: string): tobject;

implementation

function require(item: TObject; const message: string): tobject;
begin
  if item = nil then raise exception.Create(message) else result := item;
end;

function strtointfb(const s: string; i: integer): integer;
begin
  if length(s) = 0 then result := i else result := strtoint(s);
end;

function isnumeric(const s: string): boolean;
begin
  result := false;
  if length(s) = 0 then exit;
  try
    strtoint(s);
    result := true;
  except
  end;
end;

end.

