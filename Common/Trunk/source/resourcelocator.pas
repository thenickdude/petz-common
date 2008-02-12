unit resourcelocator;

interface
uses sysutils, windows, classes, contnrs, madres;

type
  TResourceType = (rtFile, rtNamedResource, rtNumberedResource);
  TResourceLocator = class(tmemorystream)
  private
  public
    frn,frt:widestring;
    ffilename: string;
    fresname, frestype: pwidechar;
    fresourcetype: tresourcetype;

    function identifier: string;
    procedure setnumberedresource(filename: string; restype: pwidechar; resnum: integer);
    procedure setfilename(filename: string);
    procedure setnamedresource(filename: string; restype, resname: widestring);
    procedure load(update: cardinal = 0);
    procedure save(update: cardinal = 0);
    constructor create; reintroduce;
    destructor Destroy; override;
  end;

implementation

function tresourcelocator.identifier: string;
begin
  case fresourcetype of
    rtfile: result := uppercase(ffilename);
    rtnamedresource: result := uppercase(ffilename) + '-' + uppercase(frestype) + '-' + uppercase(fresname);
    rtnumberedresource: result := uppercase(ffilename) + '-' + uppercase(frestype) + '-' + inttostr(integer(fresname));
  end;
end;

procedure tresourcelocator.load(update: cardinal = 0);
var ownupdate: boolean;
  data: pointer; fsize: cardinal;
begin
  clear;
  if fresourcetype = rtFile then loadfromfile(ffilename) else
  begin
    ownupdate := (update = 0);

    if ownupdate then
      update := BeginUpdateResourceW(pwidechar(widestring(ffilename)), false);
    try
      if GetResourceW(update, frestype, fresname, 1033, data, fsize) then begin
        clear;
        write(data^, fsize);
      end else raise exception.create('Resource locator: Couldn''t load resource "' + ffilename + '"!');
    finally
      if ownupdate then
        EndUpdateResourceW(update, true);
    end;
  end;
end;

procedure tresourcelocator.save(update: cardinal = 0);
var ownupdate: boolean;
  data: pointer; fsize: cardinal;
begin
  if fresourcetype = rtfile then savetofile(ffilename) else begin
    ownupdate := (update = 0);

    if ownupdate then
      update := BeginUpdateResourceW(pwidechar(widestring(ffilename)), false);
    try
      data := memory;
      fsize := Size;
      if not updateResourceW( update, frestype, fresname, 1033, data, fsize) then
        raise exception.create('Resource locator: Couldn''t save to resource "' + ffilename + '"!');
    finally
      if ownupdate then
        EndUpdateResourceW(update, false);
    end;
  end;
end;

constructor tresourcelocator.create;
begin
  inherited Create;
end;

destructor tresourcelocator.destroy;
begin
  inherited;
end;

procedure tresourcelocator.setnumberedresource(filename: string; restype: pwidechar; resnum: integer);
begin
  fresourcetype := rtNumberedResource;
  fresname := pwidechar(resnum);
  frestype := restype;
  ffilename := filename;
end;

procedure tresourcelocator.setfilename(filename: string);
begin
  fresourcetype := rtFile;
  ffilename := filename;
end;

procedure tresourcelocator.setnamedresource(filename: string; restype,resname:widestring);
begin
  fresourcetype := rtNamedResource;
  frn:=resname;
  frt:=restype;
  fresname := pwidechar(frn);
  frestype := pwidechar(frt);
  ffilename := filename;
end;


end.

