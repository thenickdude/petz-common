unit pfsresdevice;

interface

uses sysutils, contnrs, windows, classes, pfs,  proceduretomethod,
  madres, masks;

type
  TPFSResDevice = class(TInterfacedObject, IPFSDevice)
  protected
    ffilename, fextmask: string;
  private
    fsearchpath: string;
    flangstub, fresstub, ftypestub: pointer;
    function resenum(handle: THandle; ResType: PChar; ResName: Pchar; long: Lparam): bool; stdcall;
    function typeenum(handle: thandle; restype: pchar; long: lparam): bool; stdcall;
    function langenum(handle: THandle; ResType: PChar; ResName: Pchar; language: word; long: Lparam): bool; stdcall;
  public
    procedure SaveFileToStream(const path: string; stream: tstream);
    procedure LoadFileFromStream(const path: string; stream: tstream);
    procedure FindFiles(const path: string; list: TObjectList);
    constructor create(const filename: string; const extmask: string = '');
    destructor Destroy; override;
  end;

implementation

function isintresource(resname:pchar):boolean;
begin
  result:=false;
end;

constructor TPFSResDevice.create(const filename: string; const extmask: string = '');
begin
  ffilename := filename;
  fextmask := extmask;
  flangstub := CreateStub(self, @TPFSResDevice.langenum);
  fresstub := CreateStub(self, @TPFSResDevice.resenum);
  ftypestub := CreateStub(self, @TPFSResDevice.typeenum);
end;

destructor TPFSResDevice.destroy;
begin
  DisposeStub(flangstub);
  DisposeStub(fresstub);
  DisposeStub(ftypestub);
  inherited;
end;

procedure TPFSResDevice.SaveFileToStream(const path: string; stream: tstream);
var size, update: cardinal;
  data: pointer;
  resname, resext: string;
begin
  resext := uppercase(copy(extractfileext(path), 2, length(path)));
  resname := uppercase(copy(path, 1, length(path) - (length(resext) + 1)));

  update := BeginUpdateResourceW(pwidechar(widestring(ffilename)), false);
  if update = 0 then exit;
  try
    if GetResourceW(update, pwidechar(widestring(resext)), pwidechar(widestring(resname)), 1033, data, size) then begin
      stream.write(data^, size);
    end;
  finally
    endupdateresourcew(update, true);
  end;
end;

procedure TPFSResDevice.LoadFileFromStream(const path: string; stream: tstream);
var size, update: cardinal;
  data: pointer;
  resname, resext: string;
begin
  resext := uppercase(copy(extractfileext(path), 2, length(path)));
  resname := uppercase(copy(path, 1, length(path) - (length(resext) + 1)));

  update := BeginUpdateResourceW(pwidechar(widestring(ffilename)), false);
  if update = 0 then exit;
  try
    UpdateResourceW(update, pwidechar(widestring(resext)), pwidechar(widestring(resname)), 1033, tmemorystream(stream).memory, stream.size);
  finally
    endupdateresourcew(update, false);
  end;
end;

function TPFSResDevice.langenum(handle: THandle; ResType: PChar; ResName: Pchar; language: word; long: Lparam): bool; stdcall;
var newfile: TPFSFile;
  list: Tobjectlist;
  mask: TMask;
begin
  list := tobjectlist(long);

  if language = 1033 then begin

    mask := TMask.create(uppercase(fsearchpath));
    try
      if mask.Match(uppercase(resname + '.' + restype), 1) then begin
        newfile := TPFSFile.create;
        newfile.name := resname + '.' + restype;
        list.add(newfile);
      end;
    finally
      mask.free;
    end;

  end;
  result := true; {continue search}
end;

function TPFSResDevice.resenum(handle: THandle; ResType: PChar; ResName: Pchar; long: Lparam): bool; stdcall;
begin
  if not isintresource(resname) then
    EnumResourceLanguages(handle, restype, resname, flangstub, long);
  result := true; {continue search}
end;

function TPFSResDevice.typeenum(handle: thandle; restype: pchar; long: lparam): bool; stdcall;
begin
  if (not isintresource(restype)) and ((length(fextmask) = 0) or (ansicomparetext(fextmask, restype) = 0)) then
    EnumResourceNames(handle, restype, fresstub, long);
  result := true; {continue search}
end;

procedure TPFSResDevice.FindFiles(const path: string; list: TObjectList);
var h: hinst;
begin
  fsearchpath := extractfilename(path);
  h := LoadLibraryEX(pchar(ffilename), 0, LOAD_LIBRARY_AS_DATAFILE);
  if h = 0 then raise exception.create('Could not open file ''' + ffilename + '''');
  try
    EnumResourcetypes(h, ftypestub, integer(list));
  finally
    FreeLibrary(h);
  end;
end;

end.

