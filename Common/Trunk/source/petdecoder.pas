unit petdecoder;

interface

uses classes, contnrs, sysutils, windows, offlinefamilytreeunit, pfs, petzcommon,
  checksumstreamscommon;

type
  TPetNode = class
  public
    data: tmemorystream;
      name: string;
    constructor create;
    destructor Destroy; override;
  end;

  TPetDecoder = class(TObject, IPFSDevice)
  private
    spacer: longword;
    chkheader, chkmain: word;
    procedure recalcheaderchecksum(data: tmemorystream);
    procedure loadfamilytree(stream: tmemorystream);
    function getspecies: TSpecies;

    procedure SaveFileToStream(const path: string; stream: tstream);
    procedure LoadFileFromStream(const path: string; stream: tstream);
    procedure FindFiles(const path: string; list: TObjectList);

    function getownername: string;
    function getbreedname: string;
    function getpetname: string;
    function getisfemale:boolean;
    procedure setpetname(const name: string);
  public
    data: TObjectlist;

    familytree: TOfflineAncestryInfo;

    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function adultlnz: TMemoryStream;
    function childlnz: tmemorystream;

    property species: tspecies read getspecies;

    property Name: string read getpetname write setpetname;
    property BreedName: string read getbreedname;
    property OwnerName: string read getownername;
    property Female:boolean read getisfemale;

    procedure loadfromfile(const filename: string; verifychecksum: boolean = true);
    procedure loadfromstream(stream: tstream; verifychecksum: boolean); overload;
    procedure savetostream(stream: TStream); overload;
    function getorcreatenode(const name: string): tpetnode;
    function findnode(const name: string): tpetnode;
    constructor create;
    destructor Destroy; override;
  end;

implementation

procedure tpetdecoder.SaveFileToStream(const path: string; stream: tstream);
var s: string;
begin
  s := path;
  stripfirstslash(s);
  if ansicomparetext(s, 'adult.lnz') = 0 then
    adultlnz.SaveToStream(stream) else
    if ansicomparetext(s, 'child.lnz') = 0 then
      childlnz.SaveToStream(stream);
end;

procedure tpetdecoder.LoadFileFromStream(const path: string; stream: tstream);
var s: string;
begin
  s := path;
  stripfirstslash(s);
  if ansicomparetext(s, 'adult.lnz') = 0 then
    adultlnz.LoadFromStream(stream) else
    if ansicomparetext(s, 'child.lnz') = 0 then
      childlnz.LoadFromStream(stream);
end;

function readpaddedstring(stream: TStream; len: integer): string;
begin
  setlength(result, len);
  if len > 0 then begin
    stream.Read(Result[1], len);
    if pos(#0, result) > 0 then
      SetLength(result, pos(#0, result) - 1);
  end;
end;

procedure writepaddedstring(stream: TStream; s: string; len: integer);
begin
  if length(s) < len then
    s := s + stringofchar(#0, len - length(s));
  if length(s) > 0 then begin
    s[len] := #0; //force string is len-1 bytes plus a null terminator
    stream.write(s[1], len);
  end;
end;

function TPetDecoder.getownername: string;
begin
  if familytree = nil then result:='';

  result:=familytree.adopter;
end;

function TPetDecoder.getbreedname: string;
var node: TPetNode;
begin
  node := findnode('LOADINFO');
  if node = nil then raise exception.Create('Missing LOADINFO!');

  node.data.Position := 258;

  result := readpaddedstring(node.data, 256);
end;

function TPetDecoder.getisfemale:boolean;
var node: TPetNode;
b:byte;
begin
  node := findnode('Petz info');
  if node = nil then raise exception.Create('Missing Petz info!');

  node.data.Position := 0;
  node.data.read(b, 1);
  result:=not (b = 0);
end;


function TPetDecoder.getpetname: string;
var node: TPetNode;
begin
  node := findnode('LOADINFO');
  if node = nil then raise exception.Create('Missing LOADINFO!');

  node.data.Position := 2;

  result := readpaddedstring(node.data, 256);
end;

procedure TPetDecoder.setpetname(const name: string);
var node: TPetNode;
begin
  node := findnode('LOADINFO');
  if node = nil then raise exception.Create('Missing LOADINFO!');

  node.data.Position := 2;
  writepaddedstring(node.data, name, 256);

end;

procedure tpetdecoder.FindFiles(const path: string; list: TObjectList);
begin
  list.add(TPFSFile.create('adult.lnz'));
  list.add(TPFSFile.create('child.lnz'));
end;

function TPetDecoder.getorcreatenode(const name: string): tpetnode;
begin
  result := findnode(name);
  if result = nil then begin
    result := TPetNode.create;
    result.name := name;
    data.add(result);
  end;
end;

function TPetDecoder.findnode(const name: string): TPetNode;
var t1: integer;
begin
  result := nil;
  for t1 := 0 to data.count - 1 do
    if ansicomparetext(TPetNode(data[t1]).name, name) = 0 then begin
      result := TPetNode(data[t1]);
      exit;
    end;
end;

function TPetDecoder.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TPetDecoder._AddRef: integer;
begin
  result := -1;
end;

function TPetDecoder._Release: integer;
begin
  result := -1;
end;

constructor tpetnode.create;
begin
  inherited;
  Data := tmemorystream.create;
end;

destructor tpetnode.destroy;
begin
  data.free;
  inherited;
end;

function tpetdecoder.getspecies: TSpecies;
var node: TPetNode;
  spec: integer;
begin
  node := findnode('LOADINFO');
  if node = nil then
    result := sNone else begin
    node.data.seek(784, sofrombeginning);
    node.data.read(spec, 4);
    case spec of
      0: result := sCat;
      1: result := sDog;
    else result := snone;
    end;
  end;
end;

function tpetdecoder.adultlnz: TMemoryStream;
begin
  result := findnode('Adult.LNZ').data;
end;

function tpetdecoder.childlnz: tmemorystream;
begin
  result := findnode('Child.LNZ').data;
end;


procedure tpetdecoder.loadfamilytree(stream: tmemorystream);
var rubbish: longword;
begin
  stream.seek(0, sofrombeginning);
  stream.read(rubbish, 4);
  familytree.loadfromstream(stream);
end;

constructor tpetdecoder.create;
begin
  inherited;
  data := tobjectlist.create;
  familytree := TOfflineAncestryInfo.create;
end;

destructor tpetdecoder.destroy;
begin
  data.free;
  familytree.free;
  inherited;
end;

procedure tpetdecoder.loadfromfile(const filename: string; verifychecksum: boolean = true);
var stream: tmemorystream;
begin
  stream := TMemoryStream.create;
  try
    stream.loadfromfile(filename);
    stream.position := 0;
    loadfromstream(stream, verifychecksum);
  finally
    stream.free;
  end;
end;


{$R-}

procedure TPetDecoder.recalcheaderchecksum(data: tmemorystream);
var c: longword;
  w: word;
begin
  c := checksum(data.Memory, data.size) - (pbyte(integer(data.Memory) + 796)^ + pbyte(integer(data.Memory) + 797)^);
  data.Position := 796;
  w := c and $FFFF;
  data.write(w, 2);
  chkheader := w;
end;
{$R+}

procedure TPetDecoder.savetostream(stream: tstream);
var node: tpetnode;
  main: tmemorystream;
begin
  main := tmemorystream.create;
  try
    writestring(main, 'p.f.magicpetzIII' + #0);

    main.copyfrom(getorcreatenode('MISC').data, 0);
    writestring(main, 'p.f.magicpetzIII' + #0);

    main.copyfrom(adultlnz, 0);
    writestring(main, #0);

    main.write(spacer, 4);

    main.copyfrom(childlnz, 0);
    writestring(main, #0);
    main.copyfrom(getorcreatenode('CLOTHESETC').data, 0);
    writestring(main, 'p.f.magicpetzIII' + #0);
    main.copyfrom(getorcreatenode('Petz info').data, 0);
    writestring(main, 'p.f.magicpetzIII' + #0);
    main.copyfrom(getorcreatenode('Genome').data, 0);
    writestring(main, 'PfMaGiCpEtZIII' + #0);
    main.copyfrom(getorcreatenode('FAMILYTREE').data, 0);

    chkmain := (checksum(main.Memory, main.size) and $FFFF);

    node := getorcreatenode('LOADINFO');
    node.data.Position := 798;
    node.data.write(chkmain, 2);

    recalcheaderchecksum(node.data);
    stream.copyfrom(node.data, 0);
    stream.copyfrom(main, 0);
    writestring(stream, 'PFMAGICPETZIII' + #0);
    stream.copyfrom(getorcreatenode('Picture').data, 0);
  finally
    main.free;
  end;
end;

procedure tpetdecoder.loadfromstream(stream: tstream; verifychecksum: boolean);
var ver: longword;
  node: tpetnode;
  oldchk, oldheadchk: word;
  temp: tmemorystream;
begin
  data.Clear;
  stream.seek(0, sofrombeginning);

  node := getorcreatenode('LOADINFO');
  node.data.CopyFrom(stream, 800);
  node.data.Position := 792;
  node.data.read(ver, 4);
  if (ver = $ACB0002) or (ver = $ACB0003) then begin
    node.data.seek(0, sofromend);
    node.data.CopyFrom(stream, 16); //GUID
  end;

  node.data.seek(796, sofrombeginning);
  node.data.read(chkheader, 2);
  node.data.read(chkmain, 2);

  stream.seek(17, sofromcurrent); // skip pf magic text

  node := getorcreatenode('MISC');
  copyuntil(stream, node.data, 'p.f.magicpetzIII' + #0);

  node := getorcreatenode('Adult.LNZ');
  copyuntil(stream, node.data, #0);

  stream.read(spacer, 4);

  node := getorcreatenode('Child.LNZ');
  copyuntil(stream, node.data, #0);

  node := getorcreatenode('CLOTHESETC');
  copyuntil(stream, node.data, 'p.f.magicpetzIII' + #0);

{    node := rootnode.getorcreatenode('childthing');
    node.viewer := TViewFrameHexEditor;
    copyuntil(stream, node.data, 'p.f.magicpetzIII' + #0);}

  node := getorcreatenode('Petz info');
  copyuntil(stream, node.data, 'p.f.magicpetzIII' + #0);

  node := getorcreatenode('Genome');
  copyuntil(stream, node.data, 'PfMaGiCpEtZIII' + #0);

  node := getorcreatenode('FamilyTree');
  copyuntil(stream, node.data, 'PFMAGICPETZIII' + #0);
  loadfamilytree(node.data);

  node := getorcreatenode('Picture');
  node.data.CopyFrom(stream, stream.size - stream.position);

  oldchk := chkmain;
  oldheadchk := chkheader;

  if verifychecksum then begin
    temp := TMemoryStream.Create;
    try
      savetostream(temp);
      if (chkmain <> oldchk) or (oldheadchk <> chkheader) then begin
        raise eDamagedFile.create('File is damaged or invalid');
      end;
    finally
      temp.free;
    end;
  end;
end;


end.

