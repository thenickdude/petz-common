unit petzresourcestoreunit;

interface
uses sysutils, classes, contnrs, resourceaccessunit, windows, madres;
type
  TPetzResType = (rtFile, rtDLL, rtFolder);

  TPetzResourceItem = class
    name: string;
  end;

  TPetzResourceFile = class(TPetzResourceItem)
  public
    filename: string;
    indll: boolean;
    function savetostream(stream: tstream): boolean;
    constructor create(const afilename, aname: string; aindll: boolean = true);
  end;

  TPetzResourceFolder = class(TPetzResourceItem)
  private
    flist: tobjectlist;
    function getitem(index: integer): TPetzResourceItem;
    procedure setitem(index: integer; value: TPetzResourceItem);
  public
    function getfile(const name: string): TPetzResourceFile;
    function getfolder(const name: string): tpetzresourcefolder;
    function recursegetfolder(path: string): TPetzresourcefolder;
    function recursegetfile(path: string): TPetzResourceFile;
    function forcepath(path: string): TPetzResourceFolder;

    property items[index: integer]: TPetzResourceItem read getitem write setitem; default;
    function count: integer;
    procedure add(item: TPetzResourceItem);

    constructor create(const aname: string);
    destructor Destroy; override;
  end;

  TPetzResourceStore = class
  private
    fRoot: TPetzResourceFolder;
  public
    procedure displaycontents(list: tstrings);
    function load(const path: string; stream: tmemorystream): boolean;
    function getfolder(const path: string): TPetzResourceFolder;
    procedure mount(const filename: string; allowedext: string; mountpath: string; restype: TPetzResType);
    constructor create;
    destructor Destroy; override;
  end;

var PetzResourceStore: TPetzResourceStore;

implementation

function tpetzresourcefile.savetostream(stream: tstream): boolean;
var f: tfilestream;
  sname, stype: string;
  size, update: cardinal;
  data: pointer;
begin
  result := false;
  if indll then begin
    stype := extractfileext(name);
    sname := uppercase(copy(name, 1, length(name) - length(stype)));
    stype := uppercase(copy(stype, 2, length(stype)));

    update := BeginUpdateResourceW(pwidechar(widestring(filename)), false);
    if update = 0 then exit;
    try
      if GetResourceW(update, pwidechar(widestring(stype)), pwidechar(widestring(sname)), 1033, data, size) then begin
        stream.write(data^, size);
        result := true;
      end;

    finally
      endupdateresourcew(update, true);
    end;
  end else begin
    try
      f := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
      try
        stream.copyfrom(f, 0);
      finally
        f.free;
      end;
      result := true;
    except
    end;
  end;
end;

constructor tpetzresourcefile.create(const afilename, aname: string; aindll: boolean = true);
begin
  filename := afilename;
  name := aname;
  indll := aindll;
end;

procedure tpetzresourcefolder.add(item: TPetzResourceItem);
begin
  flist.add(item);
end;

function tpetzresourcefolder.count: integer;
begin
  result := flist.count;
end;

function tpetzresourcefolder.getitem(index: integer): TPetzResourceItem;
begin
  result := TPetzResourceItem(flist.items[index]);
end;

procedure tpetzresourcefolder.setitem(index: integer; value: TPetzResourceItem);
begin
  flist.items[index] := value;
end;

function tpetzresourcefolder.getfile(const name: string): TPetzResourceFile;
var t1: integer;
begin
  result := nil;
  for t1 := 0 to count - 1 do
    if (Items[t1] is TPetzResourceFile) and (ansicomparetext(TPetzResourceFile(items[t1]).name, name) = 0) then begin
      result := TPetzResourceFile(items[t1]);
      exit;
    end;
end;

function tpetzresourcefolder.getfolder(const name: string): tpetzresourcefolder;
var t1: integer;
begin
  result := nil;
  for t1 := 0 to count - 1 do
    if (Items[t1] is TPetzResourceFolder) and (ansicomparetext(TPetzResourceFolder(items[t1]).name, name) = 0) then begin
      result := TPetzResourceFolder(items[t1]);
      exit;
    end;
end;

function tpetzresourcefolder.recursegetfolder(path: string): TPetzresourcefolder;
var slashpos: integer;
  folder: TPetzResourceFolder;
begin
  slashpos := pos('\', path);
  if slashpos = 0 then
    slashpos := pos('/', path);

  if slashpos = 0 then begin {No blackslash, do we have this folder?}
    result := getfolder(path);
  end else begin
    folder := getfolder(copy(path, 1, slashpos - 1));
    if folder <> nil then
      result := folder.recursegetfolder(copy(path, slashpos + 1, length(path))) else
      result := nil; //The path doesn't exist.
  end;
end;

function tpetzresourcefolder.recursegetfile(path: string): TPetzResourceFile;
var slashpos: integer;
  folder: TPetzResourceFolder;
begin
  slashpos := pos('\', path);
  if slashpos = 0 then
    slashpos := pos('/', path);

  if slashpos = 0 then begin {No blackslash, do we have this file?}
    result := getfile(path);
  end else begin
    folder := getfolder(copy(path, 1, slashpos - 1));
    if folder <> nil then
      result := folder.recursegetfile(copy(path, slashpos + 1, length(path))) else
      result := nil; //The path doesn't exist.
  end;
end;

constructor tpetzresourcefolder.create(const aname: string);
begin
  inherited create;
  name := aname;
  flist := tobjectlist.create;
end;

destructor tpetzresourcefolder.destroy;
begin
  flist.free;
  inherited;
end;

function tpetzresourcefolder.forcepath(path: string): TPetzResourceFolder;
var slashpos: integer;
  folder: TPetzResourceFolder;
begin
  slashpos := pos('\', path);
  if slashpos = 0 then
    slashpos := pos('/', path);

  if slashpos = 0 then begin {No blackslash, all that remains is to create the last folder}
    folder := getfolder(path);
    if folder = nil then begin
      folder := TPetzResourceFolder.create(path);
      Add(folder);
    end;
    result := folder;
  end else begin
    folder := getfolder(copy(path, 1, slashpos - 1));
    if folder = nil then begin
      folder := TPetzResourceFolder.create(copy(path, 1, slashpos - 1));
      add(folder);
    end;
    result := folder.forcepath(copy(path, slashpos + 1, length(path)));
  end;
end;

function stripbeginningslash(const s: string): string;
begin
  if (length(S) > 0) and ((s[1] = '\') or (s[1] = '/')) then
    result := copy(s, 2, length(s)) else
    result := s;
end;

procedure recursedisplay(folder: TPetzResourceFolder; list: tstrings; margin: string);
var t1: integer;
begin
  list.add(margin + folder.name);
  margin := '  ' + margin;
  for t1 := 0 to folder.count - 1 do
    if (folder[t1] is TPetzResourceFile) then
      list.add(margin + tpetzresourcefile(folder[t1]).name) else
      recursedisplay(tpetzresourcefolder(folder[t1]), list, margin);
end;

procedure tpetzresourcestore.displaycontents(list: tstrings);
begin
  recursedisplay(froot, list, '');
end;

function tpetzresourcestore.getfolder(const path: string): TPetzResourceFolder;
begin
  result := fRoot.recursegetfolder(stripbeginningslash(path));
end;

function tpetzresourcestore.load(const path: string; stream: tmemorystream): boolean;
var f: TPetzResourceFile;
begin
  f := froot.recursegetfile(stripbeginningslash(path));
  if f = nil then result := false else
    result := f.savetostream(stream);
end;

var searchdllname: string;
  searchext: string;

function langenum(handle: THandle; ResType: PChar; ResName: Pchar; language: word; long: Lparam): bool; stdcall;
var folder: TPetzResourceFolder;
  f: TPetzResourceFile;
begin
  if language = 1033 then begin
    folder := TPetzResourceFolder(long);
    f := TPetzResourceFile.create(searchdllname, resname + '.' + restype, true);
    folder.add(f);
  end;
  result := true; {continue search}
end;

function resenum(handle: THandle; ResType: PChar; ResName: Pchar; long: Lparam): bool; stdcall;
begin
  if not isintresource(resname) then
    EnumResourceLanguages(handle, restype, resname, @langenum, long);
  result := true; {continue search}
end;

function typeenum(handle: thandle; restype: pchar; long: lparam): bool; stdcall;
begin
  if not isintresource(restype) and ((length(searchext) = 0) or (ansicomparetext(restype, searchext) = 0)) then
    EnumResourceNames(handle, restype, @resenum, long);
  result := true; {continue search}
end;

procedure recursivefind(path, allowedext: string; folder: TPetzResourceFolder);
var r: TSearchRec;
  f: TPetzResourceFile;
  newfolder: TPetzResourceFolder;
begin
  path := IncludeTrailingBackslash(path);

  if findfirst(path + '*.' + allowedext, faAnyFile, r) = 0 then begin
    try
      repeat
        if r.Attr and fadirectory <> 0 then begin
          newfolder := TPetzResourceFolder.create(r.name);
          folder.add(newfolder);
          recursivefind(path + r.Name, allowedext, newfolder);
        end else begin
          f := TPetzResourceFile.create(path + r.name, r.name, false);
          folder.add(f);
        end;
      until findnext(r) <> 0;
    finally
      sysutils.FindClose(r);
    end;
  end;
end;

procedure tpetzresourcestore.mount(const filename: string; allowedext: string; mountpath: string; restype: TPetzResType);
var folder: TPetzResourceFolder;
  f: TPetzResourceFile;
  h: hwnd;
begin
  if (length(mountpath) > 0) then begin
    if (mountpath[1] = '\') or (mountpath[1] = '/') then
      mountpath := copy(mountpath, 2, length(mountpath));
    folder := froot.forcepath(mountpath);
  end else folder := froot;

  case restype of
    rtfile: begin
        f := TPetzResourceFile.Create(filename, extractfilename(filename), false);
        folder.add(f);
      end;
    rtFolder: begin
        if length(allowedext) = 0 then
          allowedext := '*';
        recursivefind(filename, allowedext, folder);
      end;
    rtdll: begin
        searchdllname := filename;
        searchext := allowedext;
        h := LoadLibraryEX(pchar(filename), 0, LOAD_LIBRARY_AS_DATAFILE);
        if h = 0 then exit;
        try
          EnumResourcetypes(h, @typeenum, integer(folder));
        finally
          FreeLibrary(h);
        end;
      end;
  end;
end;

constructor tpetzresourcestore.create;
begin
  inherited;
  froot := TPetzResourceFolder.Create('');
end;

destructor tpetzresourcestore.destroy;
begin
  froot.free;
  inherited;
end;

end.

