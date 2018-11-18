unit pfsdirdevice;

interface

uses sysutils, contnrs, windows, classes, pfs;

type
  TPFSDirDevice = class(TInterfacedObject, IPFSDevice)
  private
    fdir: string;
  public
    procedure SaveFileToStream(const path: string; stream: tstream);
    procedure LoadFileFromStream(const path: string; stream: tstream);
    procedure FindFiles(const path: string; list: tobjectlist);
    constructor create(const dir: string);
  end;

implementation

constructor TPFSDirDevice.create(const dir: string);
begin
  fdir := dir;
end;

procedure TPFSDirDevice.SaveFileToStream(const path: string; stream: tstream);
var fs: TFileStream;
begin
  fs := TFileStream.Create(includetrailingbackslash(fdir) + path, fmopenread or fmsharedenynone);
  try
    stream.copyfrom(fs, 0);
  finally
    fs.free;
  end;
end;

procedure TPFSDirDevice.LoadFileFromStream(const path: string; stream: tstream);
begin
end;

procedure find(path: string; list: tobjectlist);
var r: TSearchRec;
  f: TPFSFile;
begin
  if findfirst(path, faAnyFile, r) = 0 then begin
    try
      repeat
        if (r.name <> '.') and (r.name <> '..') then
          if r.Attr and fadirectory <> 0 then begin
            f := TPFSFile.Create;
            f.ftype := pfsFolder;
            f.name := r.name;
            list.add(f);
          end else begin
            f := TPFSFile.create;
            f.ftype := pfsFile;
            f.name := r.name;
            list.add(f);
          end;
      until findnext(r) <> 0;
    finally
      sysutils.FindClose(r);
    end;
  end;
end;

procedure TPFSDirDevice.FindFiles(const path: string; list: tobjectlist);
begin
  find(includetrailingbackslash(fdir) + path, list);
end;

(*procedure recursivefind(path: string; folder: TPFSFolder; device: IPFSDevice);
var r: TSearchRec;
  f: TPFSFile;
  newfolder: TPFSFolder;
begin
  path := IncludeTrailingBackslash(path);

  if findfirst(path + '*.*', faAnyFile, r) = 0 then begin
    try
      repeat
        if (r.name <> '.') and (r.name <> '..') then
          if r.Attr and fadirectory <> 0 then begin
            newfolder := TPFSFolder.create(r.name, device, folder);
            folder.add(newfolder);
            recursivefind(path + r.Name, newfolder, device);
          end else begin
            f := TPFSFile.create(r.name, device, folder);
            folder.add(f);
          end;
      until findnext(r) <> 0;
    finally
      sysutils.FindClose(r);
    end;
  end;
end;          *)


end.

