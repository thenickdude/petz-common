unit babydecoder;

interface

uses sysutils, windows, contnrs, classes, pfs, checksumstreamscommon;

type
  TBabyNode = class
  public
    data: tmemorystream;
      name: string;
    constructor create;
    destructor Destroy; override;
  end;

  TBabyDecoder = class(TObject, IPFSDevice)
  private
    spacer: longword;
    chkheader, chkmain: word;

    procedure SaveFileToStream(const path: string; stream: tstream);
    procedure LoadFileFromStream(const path: string; stream: tstream);
    procedure FindFiles(const path: string; list: TObjectList);

    procedure recalcheaderchecksum(stream: tmemorystream);
  public
    data: tobjectlist;

    class procedure decodeownerinfo(data:tstream; var ownername:string; var adoptdate:tdatetime);

    function getorcreatenode(const name: string): TBabyNode;
    function findnode(const name: string): TBabyNode;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function adultlnz: TMemoryStream;
    function childlnz: tmemorystream;
    procedure loadfromfile(const filename: string; verifychecksum: boolean = true);
    procedure loadfromstream(stream: tstream; verifychecksum: boolean); overload;
    procedure savetostream(stream: TStream); overload;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses petzcommon;

function TBabyDecoder.getorcreatenode(const name: string): TBabyNode;
begin
  result := findnode(name);
  if result = nil then begin
    result := TBabyNode.create;
    result.name := name;
    data.add(result);
  end;
end;

function TBabyDecoder.findnode(const name: string): TBabyNode;
var t1: integer;
begin
  result := nil;
  for t1 := 0 to data.count - 1 do
    if ansicomparetext(TBabyNode(data[t1]).name, name) = 0 then begin
      result := TBabyNode(data[t1]);
      exit;
    end;
end;

function TBabyDecoder.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TBabyDecoder._AddRef: integer;
begin
  result := -1;
end;

function TBabyDecoder._Release: integer;
begin
  result := -1;
end;

procedure TBabyDecoder.SaveFileToStream(const path: string; stream: tstream);
var s: string;
  node: TBabyNode;
begin
  s := path;
  stripfirstslash(s);
  if ansicomparetext(s, 'adult.lnz') = 0 then
    adultlnz.SaveToStream(stream) else
    if ansicomparetext(s, 'child.lnz') = 0 then
      childlnz.SaveToStream(stream) else begin
      node := findnode(path);
      if node <> nil then
        node.data.SaveToStream(stream);
    end;

end;

procedure TBabyDecoder.LoadFileFromStream(const path: string; stream: tstream);
var s: string;
  node: TBabyNode;
begin
  s := path;
  stripfirstslash(s);
  if ansicomparetext(s, 'adult.lnz') = 0 then
    adultlnz.LoadFromStream(stream) else
    if ansicomparetext(s, 'child.lnz') = 0 then
      childlnz.LoadFromStream(stream) else begin
      node := findnode(path);
      if node <> nil then
        node.data.LoadFromStream(stream);
    end;

end;

procedure TBabyDecoder.FindFiles(const path: string; list: TObjectList);
begin
  list.add(TPFSFile.create('adult.lnz'));
  list.add(TPFSFile.create('child.lnz'));
  list.add(TPFSFile.create('OwnerInfo'));
end;

constructor tbabynode.create;
begin
  inherited;
  Data := tmemorystream.create;
end;

destructor tbabynode.destroy;
begin
  data.free;
  inherited;
end;

destructor tbabydecoder.destroy;
begin
  data.free;
  inherited;
end;

constructor TBabyDecoder.create;
begin
  inherited;
  data := tobjectlist.create;
end;

function tbabydecoder.adultlnz: TMemoryStream;
begin
  result := findnode('Adult.LNZ').data;
end;

function tbabydecoder.childlnz: tmemorystream;
begin
  result := findnode('Child.LNZ').data;
end;

class procedure tbabydecoder.decodeownerinfo(data:tstream; var ownername:string; var adoptdate:tdatetime);
var
 l:longword;
begin
  data.seek(0,sofrombeginning);
  data.read(l,4); //rubbish, or at least unknown
  data.read(l,4); //length of owner name
  setlength(ownername,l);
  if l>0 then
   data.read(ownername[1],l);
  data.Read(l,4); //another unknown
  data.read(l,4); //adopt date
  adoptdate:=petdatetodelphidate(l);
end;

procedure tbabydecoder.loadfromfile(const filename: string; verifychecksum: boolean = true);
var stream: tfilestream;
begin
  stream := TFileStream.Create(filename, fmOpenRead or fmShareDenyWrite);
  try
    stream.seek(0, sofrombeginning);
    loadfromstream(stream, verifychecksum);
  finally
    stream.free;
  end;
end;

procedure tbabydecoder.loadfromstream(stream: tstream; verifychecksum: boolean);
var node: TBabyNode;
  oldchk, oldheadchk: word;
  temp: tmemorystream;
begin
  data.clear;

  node := getorcreatenode('LOADINFO');
  node.data.CopyFrom(stream, 1077);

  node.data.seek(796, sofrombeginning);
  node.data.read(chkheader, 2);
  node.data.read(chkmain, 2);

  stream.seek(9, sofromcurrent); // skip pf magic text

  node := getorcreatenode('ColourInfo');
  copyuntil(stream, node.data, 'pfmagic1' + #0);

  node := getorcreatenode('Adult.LNZ');
  copyuntil(stream, node.data, #0);

  stream.read(spacer, 4);

  node := getorcreatenode('Child.LNZ');
  copyuntil(stream, node.data, #0);

  node := getorcreatenode('CLOTHESETC');
  copyuntil(stream, node.data, 'pfmagic1' + #0);

  node := getorcreatenode('BLOCK1');
  copyuntil(stream, node.data, 'pfmagic1' + #0);

  node := getorcreatenode('Genome');
  copyuntil(stream, node.data, 'pfmagic3' + #0);

  node := getorcreatenode('OwnerInfo');
  copyuntil(stream, node.data, 'pfmagic2' + #0);

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

procedure TBabyDecoder.recalcheaderchecksum(stream: tmemorystream);
var c: longword;
  w: word;
begin
  c := checksum(stream.Memory, stream.size) - (pbyte(integer(stream.Memory) + 796)^ + pbyte(integer(stream.Memory) + 797)^);
  stream.Position := 796;
  w := c and $FFFF;
  stream.write(w, 2);
  chkheader := w;
end;

procedure TBabyDecoder.savetostream(stream: tstream);
var node: tbabynode;
  main: tmemorystream;
begin
  main := tmemorystream.create;
  try
    writestring(main, 'pfmagic1' + #0);

    main.copyfrom(getorcreatenode('ColourInfo').data, 0);
    writestring(main, 'pfmagic1' + #0);

    main.copyfrom(getorcreatenode('Adult.LNZ').data, 0);
    writestring(main, #0);

    main.write(spacer, 4);

    main.copyfrom(getorcreatenode('Child.LNZ').data, 0);
    writestring(main, #0);
    main.copyfrom(getorcreatenode('CLOTHESETC').data, 0);
    writestring(main, 'pfmagic1' + #0);
    main.copyfrom(getorcreatenode('BLOCK1').data, 0);
    writestring(main, 'pfmagic1' + #0);
    main.copyfrom(getorcreatenode('Genome').data, 0);
    writestring(main, 'pfmagic3' + #0);
    main.copyfrom(getorcreatenode('OwnerInfo').data, 0);

    chkmain := (checksum(main.Memory, main.size) and $FFFF);

    node := getorcreatenode('LOADINFO');
    node.data.Position := 798;
    node.data.write(chkmain, 2);

    recalcheaderchecksum(node.data);

    stream.copyfrom(node.data, 0);
    stream.copyfrom(main, 0);
    writestring(stream, 'pfmagic2' + #0);
    stream.copyfrom(getorcreatenode('Picture').data, 0);
  finally
    main.free;
  end;
end;

end.

