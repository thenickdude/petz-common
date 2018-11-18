unit pfs;

interface

uses sysutils, classes, contnrs, pathparser;

type
  TPFSFileType = (pfsFile, pfsFolder);

  TPFSFile = class
  public
    name: string;
    ftype: TPFSFileType;
    constructor create; overload;
    constructor create(const aName: string; aType: TPFSFileType = pfsFile); overload;
  end;

  IPFSDevice = interface
    ['{7CAF9C94-9787-4470-B260-FAA2D2EEFEE2}']
    procedure SaveFileToStream(const path: string; stream: tstream);
    procedure LoadFileFromStream(const path: string; stream: tstream);
    procedure FindFiles(const path: string; list: TObjectList);
  end;

  TPFSDeviceLink = class
  public
    path: string;
    device: IPFSDevice;
  end;

  TPFS = class
  private
    fdevices: TObjectlist;
    function getdevice(index: integer): TPFSDeviceLink;
    procedure setdevice(index: integer; value: TPFSDeviceLink);
    property devices[index: integer]: TPFSDeviceLink read getdevice write setdevice;
  public
    procedure diagdump(list: tstrings);

    function FileExists(const name: string; device: IPFSDevice = nil): boolean;
    procedure FindFiles(const path: string; list: tobjectlist; device: IPFSDevice = nil);
    function Load(const name: string; stream: tstream; device: IPFSDevice = nil): boolean;
    procedure Save(const name: string; stream: tstream; device: IPFSDevice = nil);
    procedure Mount(device: IPFSDevice; const path: string);

    constructor create; reintroduce;
    destructor Destroy; override;
  end;

  EFileNotFound = class(exception)
  public
    constructor create(const filename: string); reintroduce;
  end;

var gPFS: TPFS;

procedure stripfirstslash(var path: string);

implementation

procedure stripfirstslash(var path: string);
begin
  if (length(path) > 0) and (path[1] in ['\', '/']) then
    path := copy(path, 2, length(path));
end;

constructor EFileNotFound.create(const filename: string);
begin
  inherited create('File not found (' + filename + ')');
end;

constructor tpfsfile.create;
begin
  //nop
end;

constructor tpfsfile.create(const aName: string; aType: TPFSFileType = pfsFile);
begin
  name := aname;
  ftype := aType;
end;

function tpfs.getdevice(index: integer): TPFSDeviceLink;
begin
  result := TPFSDeviceLink(fdevices.items[index]);
end;

procedure tpfs.setdevice(index: integer; value: TPFSDeviceLink);
begin
  fdevices.add(value);
end;

procedure recursedump(const rootpath: string; device: IPFSDevice; relpath: string; list: Tstrings; indent: integer = 0);
var temp: tobjectlist;
  t1: integer;
  f: tpfsfile;
begin
  indent := indent + 4;
  temp := tobjectlist.create;
  try
    device.FindFiles(relpath + '*.*', temp);
    for t1 := 0 to temp.count - 1 do begin
      f := TPFSFile(temp[t1]);

      if f.ftype = pfsFolder then begin
        list.add(stringofchar(' ', indent) + f.name + '\');
        recursedump(rootpath, device, relpath + f.name + '\', list, indent);
      end else
        list.add(stringofchar(' ', indent) + f.name);
    end;
  finally
    temp.free;
  end;
end;

procedure tpfs.diagdump(list: tstrings);
var t1: integer;
begin
  //dump the list of attached drives

  for t1 := 0 to fdevices.count - 1 do begin
    list.add('Device at: ' + devices[t1].path);
    recursedump(devices[t1].path, devices[t1].device, '\', list);
  end;
end;

constructor tpfs.create;
begin
  fdevices := TObjectList.create;
end;

destructor tpfs.destroy;
begin
  fdevices.free;
  inherited;
end;

function tpfs.FileExists(const name: string; device: IPFSDevice = nil): boolean;
var list: tobjectlist;
begin
  list := TObjectList.Create;
  try
    findfiles(name, list, device);
    result := list.count > 0;
  finally
    list.free;
  end;
end;

procedure tpfs.FindFiles(const path: string; list: tobjectlist; device: IPFSDevice = nil);
var relpart: string;
  t1: integer;
begin
  for t1 := fdevices.count - 1 downto 0 do //prefer newer devices
    if ((device = nil) or (device = devices[t1].device)) and
      TPathParser.pathischild(devices[t1].path, path, relpart) then begin
      devices[t1].device.findfiles(relpart, list);
    end;
end;

function tpfs.Load(const name: string; stream: tstream; device: IPFSDevice = nil): boolean;
var relpart: string;
  t1: integer;
begin
  result := false;
  for t1 := fdevices.count - 1 downto 0 do //prefer newer devices
    if ((device = nil) or (device = devices[t1].device)) and
      TPathParser.pathischild(devices[t1].path, name, relpart) then
      if FileExists(name, devices[t1].device) then begin
        devices[t1].device.SaveFileToStream(relpart, stream);
        result := true;
        exit;
      end;
end;

procedure tpfs.Save(const name: string; stream: tstream; device: IPFSDevice = nil);
var relpart: string;
  t1: integer;
begin
  for t1 := fdevices.count - 1 downto 0 do //prefer newer devices
    if ((device = nil) or (device = devices[t1].device)) and
      TPathParser.pathischild(devices[t1].path, name, relpart) and
      FileExists(name, devices[t1].device) then begin
      devices[t1].device.loadFilefromStream(relpart, stream);
      exit;
    end;
end;

procedure tpfs.Mount(device: IPFSDevice; const path: string);
var link: TPFSDeviceLink;
begin
  link := TPFSDeviceLink.Create;
  link.path := path;
  link.device := device;
  fdevices.add(link);
end;


end.

