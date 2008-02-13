unit lnzparser;

interface

uses sysutils, types, windows, classes, ecxmlparser, gr32, petzcommon,
 petzresourcestoreunit, xmlassist, MadRes;

type
  TReferencetype = (rtTextures, rtBallnum);

  EParseError = class(exception);
  EPEWrongNum = class(eparseerror)
  public
    constructor create(found, req: integer); reintroduce;
  end;

  ETexturenotfound = class(exception)
  public
    name: string;
    constructor create(aname: string); reintroduce;
  end;

  ECantAssign = class(exception)
  public
    constructor create(obj, source: tobject); reintroduce;
  end;

  TUpdateOP = (uopDelete, uopAdd);

  IPFLine = interface
    ['{34113CC7-7417-415D-A462-F0C3BEF27324}']
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
  end;

  IXLine = interface
    ['{7B29DAEF-B400-426B-82BD-BCD0C66C027D}']
    procedure loadfromnode(node: txmlitem);
    procedure savetonode(node: txmlitem);
  end;

  TRefChange = record
    oldref, newref: string;
  end;
  TRefChangeArray = array of TRefChange;

  IBallRef = interface
    ['{8A3E8F60-4D6F-45CE-B864-E39195A65ECD}']
    function QueryBallRef(const aname: string): boolean;
    procedure UpdateBallRef(var ref: TRefChangeArray);
  end;

  ITexRef = interface
    ['{0A0ADCEB-9476-46DA-B8B7-659B79D29587}']
    function QueryTexRef(const aname: string): boolean;
    procedure UpdateTexRef(var ref: TRefChangeArray);
  end;

  IDescriptive = interface
    ['{89F2656B-F836-4750-94FB-D3198744960E}']
    function Descriptive: string;
  end;

  TLNZLine = class(TObject, IUnknown)
  public
    parent:TObject;
    
    precomments, comments: string;
    constructor Create; virtual; {Important to declare a create/destroy so right constructor is called on class instance!!!}
    destructor Destroy; override;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; virtual;
    procedure Assign(source: tlnzline); virtual;
    procedure AssignTo(dest: TLNZLine); virtual;
    class function comment: string; virtual;
    function _AddRef: integer; stdcall;
    function _Release: integer; stdcall;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  end;

  TLNZBallRef = class(TLNZLine, IBallRef)
  public
    ballnum: integer;
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
  end;

  TXLNZBallRef = class(TLNZLine, IBallRef)
  public
    ballname: string;
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
  end;

  TPFGenericLine = class(TLNZLine, IPFLine) //For unsupported entries
  public
    contents: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    constructor createcontents(const aContents: string);
  end;

  TXGenericLine = class(TLNZLine, IXLine)
  public
    contents: TXMLItem;
    procedure loadfromnode(node: txmlitem);
    procedure savetonode(node: txmlitem);
    constructor Create; override;
    destructor Destroy; override;
  end;

  TLNZWhiskers = class(tlnzline, IPFLine, IBallRef, IDescriptive)
  public
    startball, endball: integer;
    colour: integer;
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    constructor Create; override;
    destructor Destroy; override;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZThinfat = class(TLNZBallRef, IPFLine, IBallRef, IDescriptive)
  public
    min, max: integer;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZOutlineoverride = class(TLNZBallRef, IPFLine, IBallRef, IDescriptive)
  public
    colour: integer;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZOmissions = class(TLNZBallRef, IPFLine, IBallRef, IDescriptive)
  public
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TXLNZOmissions = class(TXLNZBallRef, IXLine, IBallRef)
  public
    procedure Assign(source: TLNZLine); override;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
  end;

  TLNZBallinfo = class(tlnzline, IPFLine, ITexRef, IDescriptive)
  public
    colour: integer;
    outlinecolour: integer;
    specklecolour: integer;
    fuzz: integer;
    outlinetype: integer;
    sizediff: integer;
    group: integer;
    texture: integer;
    function QueryTexRef(const aname: string): boolean;
    procedure UpdateTexRef(var ref: TRefChangeArray);
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TStringColour = class
  private
    fcolour: string;
    fcolour32: tcolor32;
    fresolved: Boolean;
    procedure setcolour(const value: string);
    procedure setcolour32(const value: tcolor32);
  public
    function assigned: boolean;
    function resolved: boolean;
    property colour: string read fcolour write setcolour;
    property colour32: tcolor32 read fcolour32 write setcolour32;
  end;

  TXLNZBallInfo = class(TLNZLine, IXLine)
  private
  public
    colour, outlinecolour: TStringColour;
    sizediff, outlinetype, fuzz: integer;
    texture: string;
    group: integer;
    procedure Assign(source: TLNZLine); override;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
    constructor Create; override;
    destructor Destroy; override;
  end;

  TXLNZScales = class(TLNZLine, IXLine)
  public
    scale, fatness: integer;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
  end;

  TXLNZColour = class(TLNZLine, IXline)
  public
    name: string;
    colour: TColor32;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
  end;

  TXLNZLinez = class(TLNZLine, IXLine, IBallRef)
  public
    startball, endball: string;
    startthick, endthick, fuzz: integer;
    colour, leftcolour, rightcolour: tstringcolour;
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    procedure Assign(source: TLNZLIne); override;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
    constructor Create; override;
    destructor Destroy; override;
  end;

  TLNZLinez = class(tlnzline, IPFLine, IBallRef, IDescriptive)
  public
    startball, endball: integer;
    fuzz, colour: integer;
    leftcolour, rightcolour: integer;
    startthick, endthick: integer;
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZPaintball = class(TLNZBallRef, IPFLine, IBallRef, IDescriptive)
  public
    diameter: integer;
    x, y, z: single;
    colour, outlinecolour, fuzz, outlinetype, group, texture: integer;
    constructor Create; override;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TXLNZPaintBall = class(TXLNZBallRef, IXLine, IBallRef)
  public
    diameter: integer;
    x, y, z: Single;
    colour, outlinecolour: TStringColour;
    fuzz, outlinetype, group: integer;
    texture: string;
    procedure Assign(source: TLNZLIne); override;
    constructor Create; override;
    destructor Destroy; override;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
  end;

  TLNZprojection = class(tlnzline, IPFLine, IBallRef, IDescriptive)
  public
    ball, anchor, distance: integer;
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZColourOverride = class(TLNZBallRef, IPFLine, IBallRef, IDescriptive)
  public
    uGroup: boolean;
    uTexture: boolean;
    colour: integer;
    group: integer;
    texture: integer;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    constructor Create; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZfuzzoverride = class(TLNZBallRef, IPFLine, IBallRef, IDescriptive)
  public
    fuzz: integer;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZballsizeoverride = class(TLNZBallRef, IPFLine, IBallRef, IDescriptive)
  public
    size: integer;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TXLNZBallOverride = class(TXLNZBallRef, IXLine, IBallRef)
  public
    texture: string;
    fuzz, group, size: integer;
    outlinecolour, colour: TStringColour;
    oSize, oColour, oOutlineColour, oGroup, oTexture, oFuzz: boolean;
    constructor Create; override;
    destructor Destroy; override;
    procedure loadfromnode(node: txmlitem);
    procedure savetonode(node: txmlitem);
  end;

  TLNZEyelidcolour = class(tlnzline, IPFLine, IDescriptive)
    colour: integer;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TLNZAddball = class(tlnzline, IPFLine, IBallRef, ITexRef, IDescriptive)
  public
    relative: boolean;
    relball: integer;
    baseball: integer;
    x, y, z: integer;
    colour, outlinecolour, specklecolour: integer;
    fuzz: integer;
    group: integer;
    outlinetype: integer;
    size: integer;
    bodyarea, addgroup: integer;
    texture: integer;
    function QueryTexRef(const aname: string): boolean;
    procedure UpdateTexRef(var ref: TRefChangeArray);
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    class function comment: string; override;
  end;

  TXLNZAddBall = class(TLNZLine, IXLine, IBallRef)
  public
    relative: boolean;
    baseball, relball: string;
    fuzz, group, outlinetype, Size, bodyarea, addgroup, x, y, z: integer;
    colour, outlinecolour: TStringColour;
      name, texture: string;
    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
    constructor Create; override;
    destructor Destroy; override;
  end;

  TXLNZMove = class(TLNZLine, IXLine, IBallRef)
  public
    ball, rel: string;
    x, y, z: integer;

    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    function relative: boolean;
    procedure Assign(source: TLNZLine); override;
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
  end;

  TLNZmove = class(tlnzline, IPFLine, IBallRef, IDescriptive)
  public
    ballnum: integer;
    x, y, z: integer;
    relnum: integer;
    relative: boolean;

    procedure UpdateBallRef(var ref: TRefChangeArray);
    function queryballref(const aname: string): boolean;
    function UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean; override;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    constructor Create; override;
    class function comment: string; override;
  end;

  TLNZtexturelist = class(TLNZLine, IPFLine, IXLine, IDescriptive)
  public
    name, texname: string;
    texture: tbitmap32;
    argument: integer;
    function descriptive: string;
    procedure loadfromstring(const s: string);
    procedure savetostring(var dest: string);
    procedure loadfromnode(node: TXMLItem);
    procedure savetonode(node: TXMLItem);
    constructor Create; override;
    destructor Destroy; override;
    procedure loadtexture;
    procedure loadintexture(filename: string);
    class function comment: string; override;
  end;

  TLNZlineclass = class of tlnzline;

  function sttoclass(secttype: TSecttype): TLNZlineclass;

implementation

function upballref(var ref: TRefChangeArray; ball: integer): integer; overload;
var t1: integer;
  s: string;
begin
  result := ball;
  s := inttostr(ball);
  for t1 := 0 to high(ref) do
    if ref[t1].oldref = s then begin
      result := strtoint(ref[t1].newref);
      exit;
    end;
end;

function upballref(var ref: TRefChangeArray; const ball: string): string; overload;
var t1: integer;
begin
  result := ball;
  for t1 := 0 to high(ref) do
    if ref[t1].oldref = ball then begin
      result := ref[t1].newref;
      exit;
    end;
end;

function uptexref(var ref: TRefChangeArray; const texture: string): string; overload;
var t1: integer;
begin
  result := texture;
  for t1 := 0 to high(ref) do
    if ref[t1].oldref = texture then begin
      result := ref[t1].newref;
      exit;
    end;
end;

function uptexref(var ref: TRefChangeArray; texture: integer): integer; overload;
var t1: integer;
  s: string;
begin
  result := texture;
  s := inttostr(texture);
  for t1 := 0 to high(ref) do
    if ref[t1].oldref = s then begin
      result := StrToInt(ref[t1].newref);
      exit;
    end;
end;

constructor ecantassign.create(obj, source: tobject);
begin
  Message := 'Can''t assign a ' + source.ClassName + ' to a ' + obj.ClassName;
end;

function tstringcolour.resolved: boolean;
begin
  result := fresolved;
end;

function tstringcolour.assigned: boolean;
begin
  result := length(fcolour) > 0;
end;

procedure tstringcolour.setcolour(const value: string);
begin
  if fcolour <> value then begin

    if length(value) = 0 then begin
      fcolour := '';
      fcolour32 := gray32(128); //grey default
      fresolved := true;
    end else
      if (length(value) = 7) and (value[1] = '#') then begin
        fcolour32 := color32(StrToInt('$' + copy(value, 2, 2)), StrToInt('$' + copy(value, 4, 2)), StrToInt('$' + copy(value, 6, 2)));
        fcolour := value;
        fresolved := true;
      end else
        if isnumeric(value) then begin
          if (strtoint(value) <= 255) and (strtoint(value) >= 0) then begin
            fcolour := value;
            fcolour32 := petzcolourto32(strtoint(value), gray32(128));
            fresolved := true;
          end else begin
            fcolour := ''; //invalid colour, assume -1, we want no colour. Not assigned.
            fresolved := true;
          end;
        end else begin
          //we don't yet know what this colour is
          fcolour := value;
          fresolved := false;
          fcolour32 := Gray32(128);
        end;
  end;
end;

procedure tstringcolour.setcolour32(const value: tcolor32);
begin
  fcolour32 := value;
  fcolour := '#' + IntToHex(redcomponent(fcolour32), 2) + IntToHex(greencomponent(fcolour32), 2) + IntToHex(bluecomponent(fcolour32), 2);
end;

constructor etexturenotfound.create(aname: string);
begin
  name := aname;
  inherited create('Texture ''' + name + ''' not found!');
end;

constructor epewrongnum.create(found, req: integer);
begin
  inherited create('Wrong number of parameters: ' + inttostr(found) + ' found, ' + inttostr(req) + ' required.');
end;

function sttoclass(secttype: TSecttype): TLNZlineclass;
begin
  case secttype of
    stOmissions: result := TLNZOmissions;
    stEyeLidColor: result := TLNZEyelidcolour;
    stthinfat: result := TLNZThinfat;
    stMove: result := TLNZmove;
    stProjectball: result := tLNZprojection;
    staddball: result := TLNZAddball;
    stlinez: result := TLNZlinez;
    stpaintballz: result := TLNZPaintball;
    stballzinfo: result := TLNZBallinfo;
    stfuzzoverride: result := TLNZfuzzoverride;
    stcoloroverride: result := TLNZColourOverride;
    stballsizeoverride: result := TLNZballsizeoverride;
    sttexturelist: result := TLNZTextureList;
  else result := TPFGenericLine;
  end;
end;

constructor tpfgenericline.createcontents(const aContents: string);
begin
  inherited create;
  contents := contents;
end;

procedure tpfgenericline.loadfromstring(const s: string);
begin
  contents := s;
end;

procedure tpfgenericline.savetostring(var dest: string);
begin
  dest := contents;
end;

constructor txgenericline.create;
begin
  inherited;
  contents := TXMLItem.Create;
end;

destructor txgenericline.destroy;
begin
  contents.free;
  inherited;
end;

procedure txgenericline.loadfromnode(node: txmlitem);
begin
//contents.AsString:=node.AsString;
end;

procedure txgenericline.savetonode(node: txmlitem);
begin
 //node.Assign(contents);
end;

function tlnzline.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
end;

function TLNZLine.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TLNZLine._AddRef: integer;
begin
  result := -1;
end;

function TLNZLine._Release: integer;
begin
  result := -1;
end;

constructor tlnzline.create;
begin
  precomments := '';
  comments := '';
end;

destructor tlnzline.destroy;
begin
  inherited;
end;

class function tlnzline.comment: string;
begin
  result := '';
end;

procedure tlnzline.assignto(dest: TLNZLine);
var s: string;
  pfself, pfsource: IPFline;
begin
  if supports(tobject(self), IPFLine, pfself) and
    supports(tobject(dest), IPFLine, pfsource) then begin
    pfself.savetostring(s);
    pfsource.loadfromstring(s);
  end else
    raise eCantAssign.create(self, dest);
end;

procedure tlnzline.assign(source: tlnzline);
begin
  source.assignto(self);
end;

function txlnzaddball.queryballref(const aname: string): boolean;
begin
  result := (baseball = aname) or (relative and (relball = aname));
end;

procedure txlnzaddball.UpdateBallRef(var ref: TRefChangeArray);
begin
  baseball := upballref(ref, baseball);
  if relative then
    relball := upballref(ref, relball);
end;

procedure txlnzaddball.loadfromnode(node: TXMLItem);
var list: tstringlist;
begin
  baseball := node.params.values['baseball'];
  if length(baseball) = 0 then
    raise EParseError.Create('Add ball: Base ball name missing');

  if node.params.indexofname('pos') <> -1 then begin
    list := TStringList.Create;
    try
      list.commatext := node.params.Values['pos'];
      if list.count <> 3 then raise EParseError.Create('Add ball: ''Pos'' coordinates are incomplete');
      x := strtoint(list[0]);
      y := strtoint(list[1]);
      z := strtoint(list[2]);
    finally
      list.free;
    end;
  end else begin
    if (node.params.IndexOfName('x') = -1) or (node.params.IndexOfName('y') = -1) or
      (node.params.IndexOfName('z') = -1) then
      raise EParseError.Create('Add ball: Missing x,y,z coordinates');

    x := strtoint(node.params.values['x']);
    y := strtoint(node.params.values['y']);
    z := strtoint(node.params.values['z']);
  end;

  if node.Params.IndexOfName('relball') = -1 then
    relative := false else begin
    relative := true;
    relball := node.params.values['relball'];
  end;

  addgroup := strtointfb(node.params.values['addgroup'], 0);
  group := strtointfb(node.params.values['group'], -1);
  size := strtointfb(node.params.values['size'], 0);
  fuzz := strtointfb(node.params.values['fuzz'], 0);
  bodyarea := strtointfb(node.params.values['bodyarea'], -1);
  outlinetype := strtointfb(node.params.values['outlinetype'], -1);

  texture := node.params.values['texture'];
  name := node.params.values['name'];

  colour.colour := node.params.values['color'];

  if node.Params.IndexOfName('outlinecol') = -1 then
    outlinecolour.colour32 := clblack32 else
    outlinecolour.colour := node.params.values['outlinecol'];
end;

procedure txlnzaddball.savetonode(node: TXMLItem);
begin
end;

constructor txlnzaddball.create;
begin
  inherited;
  colour := TStringColour.Create;
  outlinecolour := TStringColour.Create;
end;

destructor txlnzaddball.destroy;
begin
  colour.free;
  outlinecolour.free;
  inherited;
end;

constructor txlnzballoverride.create;
begin
  inherited;
  osize := false; ocolour := false; ooutlinecolour := false; ogroup := false; otexture := false; ofuzz := false;
  outlinecolour := TStringColour.Create;
  colour := TStringColour.Create;
end;

destructor txlnzballoverride.destroy;
begin
  outlinecolour.Free;
  colour.Free;
  inherited;
end;

procedure txlnzballoverride.loadfromnode(node: txmlitem);
begin
  if node.params.IndexOfName('ball') = -1 then
    raise EParseError.Create('Ball override: Missing ''Ball'' tag!') else
    ballname := node.params.Values['ball'];

  osize := (node.params.indexofname('size') <> -1);
  if osize then
    size := strtoint(node.params.values['size']);

  ogroup := (node.params.indexofname('group') <> -1);
  if ogroup then
    group := strtoint(node.params.values['group']);

  texture := node.params.values['texture'];
  oTexture := length(texture) > 0;

  oFuzz := (node.params.indexofname('fuzz') <> -1);
  if oFuzz then
    fuzz := strtoint(node.params.values['fuzz']);

  osize := (node.params.indexofname('size') <> -1);
  if osize then
    size := strtoint(node.params.values['size']);

  oColour := (node.params.indexofname('color') <> -1);
  if ocolour then
    colour.colour := node.Params.Values['color'];

  oOutlineColour := (node.params.indexofname('Outlinecolor') <> -1);
  if oOutlinecolour then
    Outlinecolour.colour := node.Params.Values['Outlinecolor'];
end;

procedure txlnzballoverride.savetonode(node: txmlitem);
begin
end;

procedure txlnzpaintball.assign(source: TLNZLine);
var info: TLNZPaintball;
begin
  if source is TLNZPaintball then begin
    info := TLNZPaintball(source);
    ballname := inttostr(info.ballnum);
    diameter := info.diameter;
    colour.colour := inttostr(info.colour);
    outlinecolour.colour := inttostr(info.outlinecolour);
    x := info.x;
    y := info.y;
    z := info.z;
    fuzz := info.fuzz;
    outlinetype := info.outlinetype;
    group := info.group;
    texture := inttostr(info.texture);
  end else inherited assign(source);
end;

constructor txlnzpaintball.create;
begin
  inherited;
  colour := TStringColour.create;
  outlinecolour := TStringColour.create;
end;

destructor txlnzpaintball.destroy;
begin
  colour.free;
  outlinecolour.free;
  inherited;
end;

procedure txlnzpaintball.loadfromnode(node: TXMLItem);
var list: tstringlist;
begin
  ballname := node.Params.values['Ball'];
  if length(ballname) = 0 then raise EParseError.create('Paintball: No ball specified!');

  if node.params.indexofname('pos') <> -1 then begin
    list := TStringList.Create;
    try
      list.commatext := node.params.Values['pos'];
      if list.count <> 3 then raise EParseError.Create('Paint ball: ''Pos'' coordinates are incomplete');
      x := StrToFloat(list[0]);
      y := strtofloat(list[1]);
      z := strtofloat(list[2]);
    finally
      list.free;
    end;
  end else begin
    if (node.params.IndexOfName('x') = -1) or (node.params.IndexOfName('y') = -1) or
      (node.params.IndexOfName('z') = -1) then
      raise EParseError.Create('Paint ball: Missing x,y,z coordinates');

    x := strtofloat(node.params.values['x']);
    y := strtofloat(node.params.values['y']);
    z := strtofloat(node.params.values['z']);
  end;

  diameter := strtointfb(node.Params.values['Size'], 20);
  group := strtointfb(node.params.values['group'], -1);
  fuzz := strtointfb(node.params.values['fuzz'], 0);
  outlinetype := strtointfb(node.params.values['outlinetype'], -1);

  texture := node.params.values['texture'];

  colour.colour := node.params.values['color'];
  outlinecolour.colour := node.params.values['outlinecol'];
end;

procedure txlnzpaintball.savetonode(node: TXMLItem);
var n: txmlitem;
begin
  n := node.new;
  n.name := 'Paintball';
  n.params.add('Ball=' + ballname);
  n.Params.Add('X=' + FloatToStrf(x, ffgeneral, 7, 3));
  n.Params.Add('Y=' + FloatToStrf(y, ffgeneral, 7, 3));
  n.Params.Add('Z=' + FloatToStrf(z, ffgeneral, 7, 3));
  n.Params.add('Size=' + inttostr(diameter));
  if group <> -1 then
    n.params.add('Group=' + inttostr(group));
  if fuzz <> 0 then
    n.params.add('Fuzz=' + inttostr(fuzz));
  if outlinetype <> -1 then
    n.params.add('OutlineType=' + inttostr(outlinetype));
  if length(texture) > 0 then
    n.params.add('Texture=' + texture);
  n.params.add('Color=' + colour.colour);
  if outlinecolour.assigned then
    n.params.add('OutlineColor=' + outlinecolour.colour);


end;

function tlnzballsizeoverride.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then
    if op = uopdelete then
    begin
      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false; {we need to be deleted. ball referenced no longer exists}
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
    end;
end;

class function tlnzballsizeoverride.comment: string;
begin
  result := ';Ball number,size';
end;

procedure tlnzballsizeoverride.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 2) then raise EPEWrongNum.create(list.count, 2);

    ballnum := strtoint(list[0]);
    size := strtoint(list[1]);

  finally
    list.free;
  end;
end;

procedure tlnzballsizeoverride.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(ballnum));
    list.add(inttostr(size));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function tlnzballsizeoverride.descriptive: string;
begin
  result := 'Ball: ' + inttostr(ballnum) + ' Size: ' + inttostr(size);
end;

procedure txlnzomissions.assign(source: TLNZLine);
var info: TLNZOmissions;
begin
  if source is TLNZOmissions then begin
    info := TLNZOmissions(source);
    ballname := inttostr(info.ballnum);
  end else inherited assign(source);
end;

procedure txlnzomissions.loadfromnode(node: TXMLItem);
begin
  ballname := node.Params.values['Ball'];
  if length(ballname) = 0 then raise EParseError.create('Omission: No ball specified!');

end;

procedure txlnzomissions.savetonode(node: TXMLItem);
var n: txmlitem;
begin
  n := node.new;
  n.name := 'Omit';
  n.params.Add('Ball=' + ballname);
end;

function tlnzomissions.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then
    if op = uopdelete then begin
      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false; {we need to be deleted. ball referenced no longer exists}
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
    end;
end;

class function tlnzomissions.comment: string;
begin
  result := ';Ball number';
end;

procedure tlnzomissions.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 1) then raise EPEWrongNum.create(list.count, 1);
    ballnum := strtoint(list[0]);
  finally
    list.free;
  end;
end;

procedure tlnzomissions.savetostring(var dest: string);
begin
  dest := inttostr(ballnum);
end;

function tlnzomissions.descriptive: string;
begin
  result := 'Ball: ' + inttostr(ballnum);
end;

function tlnzballinfo.QueryTexRef(const aname: string): boolean;
begin
  result := IntToStr(texture) = aname;
end;

procedure tlnzballinfo.UpdateTexRef(var ref: TRefChangeArray);
begin
  texture := uptexref(ref, texture);
end;

function tlnzballinfo.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rttextures then
    if op = uopdelete then begin
      if texture > start then texture := texture - 1 else
        if texture = start then texture := -1;
    end else begin
      if texture >= start then texture := texture + 1;
    end;
end;

class function tlnzballinfo.comment: string;
begin
  result := ';-1 = no outline, 0 = half outline, > 0 = outline thickness'#13#10 +
    ';Color,outline color,speckle color,fuzz,outline type,size difference,group,texture,ball number';
end;

procedure txlnzscales.loadfromnode(node: TXMLItem);
begin
  scale := strtointfb(node.params.values['Size'], 100);
  fatness := strtointfb(node.params.values['Fatness'], 100);
end;

procedure txlnzscales.savetonode(node: TXMLItem);
begin
end;

procedure txlnzcolour.loadfromnode(node: TXMLItem);
var s: string;
begin
  name := node.params.Values['Name'];
  if length(name) = 0 then
    raise EParseError.Create('Color list: Missing a name!');

  s := node.params.values['Color'];

  if length(S) = 0 then
    raise eparseerror.create('Color list: ''Color'' is missing!');

  try
    if (length(S) <> 7) or (s[1] <> '#') then raise Exception.create('');
    colour := color32(StrToInt('$' + copy(s, 2, 2)), StrToInt('$' + copy(s, 4, 2)), StrToInt('$' + copy(s, 6, 2)));
  except
    raise EParseError.Create('Color list: Color is in the wrong format!');
  end;

end;

procedure txlnzcolour.savetonode(node: TXMLItem);
begin
end;

procedure txlnzlinez.UpdateBallRef(var ref: TRefChangeArray);
begin
  startball := upballref(ref, startball);
  endball := upballref(ref, endball);
end;


function TXLNZLinez.queryballref(const aname: string): boolean;
begin
  result := (startball = aname) or (endball = aname);
end;


procedure txlnzlinez.assign(source: TLNZLine);
var info: TLNZLinez;
begin
  if source is TLNZLinez then begin
    info := tlnzlinez(source);
    startball := IntToStr(info.startball);
    endball := IntToStr(info.endball);
    startthick := info.startthick;
    endthick := info.endthick;
    fuzz := info.fuzz;
    colour.colour := inttostr(info.colour);
    leftcolour.colour := inttostr(info.leftcolour);
    rightcolour.colour := inttostr(info.rightcolour);
  end else inherited assign(source);
end;


procedure txlnzlinez.loadfromnode(node: TXMLItem);
begin
  if node.Params.IndexOfName('Start') = -1 then
    raise EParseError.Create('Line: Missing start ball!') else
    startball := node.params.values['Start'];

  if node.Params.IndexOfName('End') = -1 then
    raise EParseError.Create('Line: Missing end ball!') else
    endball := node.params.values['End'];

  startthick := strtointfb(node.params.values['startthick'], 100);
  endthick := strtointfb(node.params.values['endthick'], 100);

  colour.colour := node.params.values['color'];
  leftcolour.colour := node.params.values['leftcolor'];
  rightcolour.colour := node.params.values['rightcolor'];
end;

procedure txlnzlinez.savetonode(node: TXMLItem);
var n: txmlitem;
begin
  n := node.New;
  n.name := 'Line';
  n.Params.Add('Start=' + startball);
  n.params.add('End=' + endball);
  if startthick <> 100 then n.Params.add('StartThick=' + IntToStr(startthick));
  if endthick <> 100 then n.Params.add('EndThick=' + IntToStr(endthick));
  if colour.assigned then n.params.add('Color=' + colour.colour);
  if leftcolour.assigned then n.params.add('LeftColor=' + leftcolour.colour);
  if rightcolour.assigned then n.params.add('RightColor=' + rightcolour.colour);
end;

constructor txlnzlinez.create;
begin
  inherited;
  colour := TStringColour.create;
  leftcolour := TStringColour.create;
  rightcolour := TStringColour.create;
end;

destructor txlnzlinez.destroy;
begin
  inherited;
  colour.free;
  leftcolour.free;
  rightcolour.free;
end;


constructor txlnzballinfo.create;
begin
  inherited;
  colour := TStringColour.Create;
  outlinecolour := TStringColour.Create;
end;

destructor txlnzballinfo.destroy;
begin
  colour.free;
  outlinecolour.free;
  inherited;
end;

procedure TXLNZBallInfo.assign(source: TLNZLine);
var info: TLNZBallinfo;
begin
  if source is TLNZBallinfo then begin
    info := TLNZBallinfo(source);
    colour.colour := IntToStr(info.colour);
    outlinecolour.colour := inttostr(info.outlinecolour);
    sizediff := info.sizediff;
    fuzz := info.fuzz;
    outlinetype := info.outlinetype;
    group := info.group;
    texture := inttostr(info.texture);
  end else
    inherited Assign(source);
end;

procedure TXlnzballinfo.loadfromnode(node: txmlitem);
begin

  sizediff := strtointfb(node.params.values['size'], 0);
  outlinetype := strtointfb(node.params.values['outlinetype'], -1);

  texture := node.params.values['texture'];

  colour.colour := node.params.values['color'];

  if node.Params.IndexOfName('outlinecol') = -1 then
    outlinecolour.colour32 := clblack32 else
    outlinecolour.colour := node.params.values['outlinecol'];

end;

procedure tXlnzballinfo.savetonode(node: txmlitem);
var n: TXMLItem;
begin
  n := node.New;
  n.name := 'BallInfo';

  if sizediff <> 0 then
    n.Params.Add('Size=' + inttostr(sizediff));
  if colour.assigned then
    n.params.add('Color=' + colour.colour);
  if outlinecolour.assigned then
    n.Params.add('OutlineCol=' + outlinecolour.colour);
  if outlinetype <> -1 then
    n.Params.add('OutlineType=' + IntToStr(outlinetype));
  if length(texture) > 0 then
    n.params.add('Texture=' + texture);
end;

procedure tlnzballinfo.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 8) then raise EPEWrongNum.create(list.count, 8);
    colour := strtoint(list[0]);
    outlinecolour := strtoint(list[1]);
    specklecolour := strtoint(list[2]);
    fuzz := strtoint(list[3]);
    outlinetype := strtoint(list[4]);
    sizediff := strtoint(list[5]);
    group := strtoint(list[6]);
    texture := strtoint(list[7]);
{    ballnum := strtoint(list[8]);}
  finally
    list.free;
  end;
end;

procedure tlnzballinfo.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(colour));
    list.add(inttostr(outlinecolour));
    list.add(inttostr(specklecolour));
    list.add(inttostr(fuzz));
    list.add(inttostr(outlinetype));
    list.add(inttostr(sizediff));
    list.add(inttostr(group));
    list.add(inttostr(texture));
{    list.add(inttostr(ballnum));}
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function tlnzballinfo.descriptive: string;
begin
  result := 'Col' + inttostr(colour) + ' OutCol' + inttostr(outlinecolour) + ' SpkCol' + inttostr(specklecolour) + ' Fuzz' + inttostr(fuzz);
end;

procedure tlnzwhiskers.UpdateBallRef(var ref: TRefChangeArray);
begin
  startball := upballref(ref, startball);
  endball := upballref(ref, endball);
end;

function tlnzwhiskers.queryballref(const aname: string): boolean;
begin
  result := (IntToStr(startball) = aname) or (IntToStr(endball) = aname);
end;

constructor tlnzwhiskers.create;
begin
  inherited;
  colour := -1;
end;

destructor tlnzwhiskers.destroy;
begin
  inherited;
end;

function tlnzwhiskers.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtBallnum then
    if op = uopdelete then begin
      if startball > start then startball := startball - 1 else
        if startball = start then result := false;
      if endball > start then endball := endball - 1 else
        if endball = start then result := false;
    end else begin
      if startball >= start then startball := startball + 1;
      if endball >= start then endball := endball + 1;
    end;
end;

function tlnzwhiskers.descriptive: string;
begin
  result := 'Start ball:' + inttostr(startball) + ' End ball:' + inttostr(endball);
end;

procedure tlnzwhiskers.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.CommaText := s;
    if list.count < 2 then raise epewrongnum.create(list.count, 2);
    startball := strtoint(list[0]);
    endball := strtoint(list[1]);
    if list.count > 2 then
      colour := strtoint(list[2]) else
      colour := 0;
  finally
    list.free;
  end;
end;

procedure tlnzwhiskers.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(startball));
    list.add(inttostr(endball));
    list.add(inttostr(colour));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

class function tlnzwhiskers.comment: string;
begin
  result := ';Start,end,color';
end;

function tlnzthinfat.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;

  if ref = rtBallnum then
    if op = uopdelete then begin
      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false;
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
    end;
end;

function tlnzthinfat.descriptive: string;
begin
  result := 'Ball ' + inttostr(ballnum) + ' Min ' + inttostr(min) + ' Max ' + inttostr(max);
end;

procedure tlnzthinfat.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if list.count < 3 then raise epewrongnum.create(list.count, 3);
    ballnum := strtoint(list[0]);
    min := strtoint(list[1]);
    max := strtoint(list[2]);
  finally
    list.free;
  end;
end;

procedure tlnzthinfat.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(ballnum));
    list.add(inttostr(min));
    list.add(inttostr(max));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

class function tlnzthinfat.comment: string;
begin
  result := ';Ball num,smallest change,biggest change';
end;

function tlnzoutlineoverride.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;

  if ref = rtballnum then
    if op = uopdelete then begin
      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false;
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
    end;
end;

class function tlnzoutlineoverride.comment: string;
begin
  result := ';Ball number,Colour';
end;

function tlnzoutlineoverride.descriptive: string;
begin
  result := 'Ball ' + inttostr(ballnum) + ' Color ' + inttostr(colour);
end;

procedure tlnzoutlineoverride.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 2) then raise EPEWrongNum.create(list.count, 2);

    ballnum := strtoint(list[0]);
    colour := strtoint(list[1]);

  finally
    list.free;
  end;
end;

procedure tlnzoutlineoverride.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.Add(inttostr(ballnum));
    list.Add(inttostr(colour));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function tlnzlinez.queryballref(const aname: string): boolean;
begin
  result := (inttostr(startball) = aname) or (inttostr(endball) = aname);
end;

procedure tlnzlinez.UpdateBallRef(var ref: TRefChangeArray);
begin
  startball := upballref(ref, startball);
  endball := upballref(ref, endball);
end;

function tlnzlinez.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;

  if ref = rtballnum then
    if op = uopdelete then begin

      if startball > start then startball := startball - 1 else
        if startball = start then result := false;

      if endball > start then endball := endball - 1 else
        if endball = start then result := false;

    end else begin
      if startball >= start then startball := startball + 1;
      if endball >= start then endball := endball + 1;
    end;
end;

class function tlnzlinez.comment: string;
begin
  result := ';Start ball,end ball,fuzz,colour,left colour,right colour,start thickness,end thickness';
end;

procedure tlnzlinez.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 8) then raise EPEWrongNum.create(list.count, 8);
    startball := strtoint(list[0]);
    endball := strtoint(list[1]);
    fuzz := strtoint(list[2]);
    colour := strtoint(list[3]);
    leftcolour := strtoint(list[4]);
    rightcolour := strtoint(list[5]);
    startthick := strtoint(list[6]);
    endthick := strtoint(list[7]);
    if startthick = -1 then
      startthick := 100;
    if endthick = -1 then
      endthick := 100;
  finally
    list.free;
  end;
end;

procedure tlnzlinez.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(startball));
    list.add(inttostr(endball));
    list.add(inttostr(fuzz));
    list.add(inttostr(colour));
    list.add(inttostr(leftcolour));
    list.add(inttostr(rightcolour));
    list.add(inttostr(startthick));
    list.add(inttostr(endthick));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function tlnzlinez.descriptive: string;
begin
  result := 'Start ' + inttostr(startball) + ' End ' + inttostr(endball);
end;

class function tlnzeyelidcolour.comment: string;
begin
  result := ';Colour,group';
end;

function tlnzeyelidcolour.descriptive: string;
begin
  result := 'Color ' + inttostr(colour);
end;

procedure tlnzeyelidcolour.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 1) then raise EPEWrongNum.create(list.count, 1);
    colour := strtoint(list[0]);
  finally
    list.free;
  end;
end;

procedure tlnzeyelidcolour.savetostring(var dest: string);
begin
  dest := inttostr(colour);
end;

constructor tlnzpaintball.create;
begin
  inherited;
  texture := -1;
  group := -1;
  outlinetype := -1;
  outlinecolour := -1;
end;

function tlnzpaintball.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then
    if op = uopdelete then begin

      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false;
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
    end;

  if ref = rttextures then
    if op = uopdelete then begin
      if texture > start then texture := texture - 1 else
        if texture = start then texture := -1;
    end else begin
      if texture >= start then texture := texture + 1;
    end;
end;

class function tlnzpaintball.comment: string;
begin
  result := ';Base ball,diameter(% of baseball),direction (x,y,z),colour,outline colour,fuzz,outline,group,texture';
end;

function tlnzpaintball.descriptive: string;
begin
  result := 'Base ' + inttostr(ballnum);
end;

procedure tlnzpaintball.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(ballnum));
    list.add(inttostr(diameter));
    list.add(FloatToStrf(x, ffgeneral, 7, 3));
    list.add(FloatToStrf(y, ffgeneral, 7, 3));
    list.add(FloatToStrf(z, ffgeneral, 7, 3));
    list.add(inttostr(colour));
    list.add(inttostr(outlinecolour));
    list.add(inttostr(fuzz));
    list.add(inttostr(outlinetype));
    list.add(inttostr(group));
    list.add(inttostr(texture));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

procedure tlnzpaintball.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 11) then raise EPEWrongNum.create(list.count, 11);
    ballnum := strtoint(list[0]);
    diameter := strtoint(list[1]);
    x := StrToFloat(list[2]);
    y := StrToFloat(list[3]);
    z := StrToFloat(list[4]);
    colour := strtoint(list[5]);
    outlinecolour := strtoint(list[6]);
    fuzz := strtoint(list[7]);
    outlinetype := strtoint(list[8]);
    group := strtoint(list[9]);
    texture := strtoint(list[10]);
  finally
    list.free;
  end;
end;

function tlnzaddball.QueryTexRef(const aname: string): boolean;
begin
  result := aname = inttostr(texture);
end;

procedure tlnzaddball.UpdateTexRef(var ref: TRefChangeArray);
begin
  texture := uptexref(ref, texture);
end;

function tlnzaddball.queryballref(const aname: string): boolean;
begin
  result := (inttostr(baseball) = aname) or (relative and (IntToStr(relball) = aname));
end;

procedure tlnzaddball.UpdateBallRef(var ref: TRefChangeArray);
begin
  if relative then
    relball := upballref(ref, relball);
  baseball := upballref(ref, baseball);
end;

function tlnzaddball.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then

    if op = uopdelete then begin
      if baseball > start then baseball := baseball - 1 else
        if baseball = start then result := false;

      if relative and (relball > start) then relball := relball - 1 else
        if relative and (relball = start) then relative := False;

    end else begin
      if baseball >= start then baseball := baseball + 1;
      if relative and (relball >= start) then relball := relball + 1;
    end;

  if ref = rttextures then
    if op = uopdelete then begin
      if texture > start then texture := texture - 1 else
        if texture = start then texture := -1;
    end else begin
      if texture >= start then texture := texture + 1;
    end;
end;

class function tlnzaddball.comment: string;
begin
  result := ';Base,x,y,z,color,outline color,speckle color,fuzz,group,outline,ballsize,bodyarea,addGroup,texture';
end;

procedure tlnzaddball.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 13) then raise EPEWrongNum.create(list.count, 13);
    baseball := strtoint(list[0]);
    x := strtoint(list[1]);
    y := strtoint(list[2]);
    z := strtoint(list[3]);
    colour := strtoint(list[4]);
    outlinecolour := strtoint(list[5]);
    specklecolour := strtoint(list[6]);
    fuzz := strtoint(list[7]);
    group := strtoint(list[8]);
    outlinetype := strtoint(list[9]);
    size := strtoint(list[10]);
    bodyarea := strtoint(list[11]);
    addgroup := strtoint(list[12]);
    if list.count >= 14 then
      texture := strtoint(list[13]) else
      texture := -1;
    relative := (list.count >= 15);
    if relative then begin
      relball := strtoint(list[14]);
      if relball < 0 then relative := false;
    end;
  finally
    list.free;
  end;
end;

procedure tlnzaddball.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(baseball));
    list.add(inttostr(x));
    list.add(inttostr(y));
    list.add(inttostr(z));
    list.add(inttostr(colour));
    list.add(inttostr(outlinecolour));
    list.add(inttostr(specklecolour));
    list.add(inttostr(fuzz));
    list.add(inttostr(group));
    list.add(inttostr(outlinetype));
    list.add(inttostr(size));
    list.add(inttostr(bodyarea));
    list.add(inttostr(addgroup));
    list.add(inttostr(texture));
    if relative then list.add(inttostr(relball));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function tlnzaddball.descriptive: string;
begin
  result := 'Base ' + inttostr(baseball);
end;

class function tlnztexturelist.comment: string;
begin
  result := ';Name,argument';
end;

constructor tlnztexturelist.create;
begin
  texture := TBitmap32.create;
end;

destructor tlnztexturelist.destroy;
begin
  texture.free;
end;

procedure tlnztexturelist.loadtexture;
var stream: TMemoryStream;
begin
  stream := tmemorystream.create;
  try
    if petzresourcestore.load(name, stream) then begin
      stream.position := 0;
      texture.LoadFromStream(stream);
    end else begin
      raise exception.create('Texture: Texture is missing!');
      texture.Clear;
    end;
  finally
    stream.free;
  end;
end;

procedure tlnztexturelist.loadintexture;
var
  update: cardinal;
  stream: tmemorystream;
  data: pointer;
  size: cardinal;
  loc: TTexturelocationrecord;
begin
  loc := findtexture(filename, name);
  case loc.sourcetype of
    tsNotfound: raise eTextureNotFound.create(name);
    tsDLL: begin
        update := BeginUpdateResourceW(pwidechar(widestring(loc.sourcelocation)), false);
        try
          GetResourceW(update, 'BMP', pwidechar(widestring(loc.name)), 1033, data, size);
          stream := tmemorystream.create;
          try
            stream.write(data^, size);
            stream.seek(0, sofrombeginning);
            texture.loadfromstream(stream);
          finally
            stream.free;
          end;
        finally
          EndUpdateResourceW(update, true);
        end;
      end;
    tsDisk: begin
        stream := tmemorystream.create;
        try
          stream.loadfromfile(loc.sourcelocation);
          stream.seek(0, sofrombeginning);
          texture.loadfromstream(stream);
        finally
          stream.free;
        end;
      end;
  end;
end;

procedure tlnztexturelist.loadfromnode(node: TXMLItem);
begin
  texname := node.Params.Values['Name'];
  if length(texname) = 0 then
    raise EParseError.Create('Texture list: Missing texture name');

  name := node.params.values['Path'];
  if length(name) = 0 then
    raise EParseError.Create('Texture list: Missing texture path');

  if node.Params.IndexOfName('BlendMode') = -1 then
    argument := 1 else
    argument := strtoint(node.params.values['BlendMode']);
end;

procedure tlnztexturelist.savetonode(node: TXMLItem);
var n: txmlitem;
begin
  n := node.new;
  n.name := 'Texture';

  n.Params.add('Name=' + texname);
  n.Params.Add('Path=' + name);
  if argument <> 1 then
    n.params.add('BlendMode=' + inttostr(argument));
end;

procedure tlnztexturelist.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 1) then raise EPEWrongNum.create(list.count, 1);

    name := list[0];
    argument := strtoint(list[1]);
{    loadintexture(filename);}

  finally
    list.free;
  end;
end;

procedure tlnztexturelist.savetostring(var dest: string);
begin
  dest := name + '  ' + IntToStr(argument);
end;

function tlnztexturelist.descriptive: string;
begin
  result := '"' + name + '" Argument ' + inttostr(argument);
end;

procedure txlnzballref.UpdateBallRef(var ref: TRefChangeArray);
begin
  ballname := upballref(ref, ballname);
end;

function txlnzballref.queryballref(const aname: string): boolean;
begin
  result := aname = ballname;
end;


procedure tlnzballref.UpdateBallRef(var ref: TRefChangeArray);
begin
  ballnum := upballref(ref, ballnum);
end;

function tlnzballref.queryballref(const aname: string): boolean;
begin
  result := IntToStr(ballnum) = aname;
end;


function tlnzfuzzoverride.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then
    if op = uopdelete then begin
      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false;
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
    end;
end;

class function tlnzfuzzoverride.comment: string;
begin
  result := ';Ball number,fuzz';
end;

function tlnzfuzzoverride.descriptive: string;
begin
  result := 'Ball ' + inttostr(ballnum) + ' Fuzz ' + inttostr(fuzz);
end;


procedure tlnzfuzzoverride.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 2) then raise EPEWrongNum.create(list.count, 2);
    ballnum := strtoint(list[0]);
    fuzz := strtoint(list[1]);
  finally
    list.free;
  end;
end;

procedure tlnzfuzzoverride.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(ballnum));
    list.add(inttostr(fuzz));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function txlnzmove.queryballref(const aname: string): boolean;
begin
  result := (ball = aname) or (relative and (rel = aname));
end;

procedure txlnzmove.UpdateBallRef(var ref: TRefChangeArray);
begin
  ball := upballref(ref, ball);
  if relative then
    rel := upballref(ref, rel);
end;

procedure txlnzmove.assign(source: TLNZLine);
var info: TLNZMove;
begin
  if source is TLNZmove then begin
    info := TLNZmove(source);
    ball := inttostr(info.ballnum);
    x := info.x;
    y := info.y;
    z := info.z;
  end else inherited assign(source);
end;

function txlnzmove.relative: boolean;
begin
  result := Length(rel) > 0;
end;

procedure txlnzmove.loadfromnode(node: TXMLItem);
begin
  ball := node.Params.values['Ball'];
  if length(ball) = 0 then
    raise EParseError.Create('Move: Ball name not found!');
  x := strtointfb(node.params.values['x'], 0);
  y := strtointfb(node.params.values['y'], 0);
  z := strtointfb(node.params.values['z'], 0);

  rel := node.params.values['Relative'];
end;

procedure txlnzmove.savetonode(node: TXMLItem);
var n: txmlitem;
begin
  n := node.new;
  n.Name := 'Move';
  n.Params.Add('Ball=' + ball);
  n.params.add('X=' + inttostr(x));
  n.params.add('Y=' + inttostr(y));
  n.params.add('Z=' + inttostr(z));
  if relative then
    n.params.add('Relative=' + rel);
end;

function tlnzmove.queryballref(const aname: string): boolean;
begin
  result := (inttostr(ballnum) = aname) or (relative and (IntToStr(relnum) = aname));
end;

procedure tlnzmove.UpdateBallRef(var ref: TRefChangeArray);
begin
  ballnum := upballref(ref, ballnum);
  if relative then
    relnum := upballref(ref, relnum);
end;

function tlnzmove.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then
    if op = uopdelete then begin

      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false;

      if relative and (relnum > start) then relnum := relnum - 1 else
        if relative and (relnum = start) then relative := false;
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
      if relative and (relnum >= start) then relnum := relnum + 1;
    end;
end;

class function tlnzmove.comment: string;
begin
  result := ';Ball number,x,y,z,(relative ball num)';
end;

constructor tlnzmove.create;
begin
  inherited;
  x := 0; y := 0; z := 0;
  relative := false;
end;

procedure tlnzmove.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 4) then raise EPEWrongNum.create(list.count, 4);
    ballnum := strtoint(list[0]);
    x := strtoint(list[1]);
    y := strtoint(list[2]);
    z := strtoint(list[3]);
    relative := (list.count >= 5);
    if relative then begin
      relnum := strtoint(list[4]);
    end;
  finally
    list.free;
  end;
end;

procedure tlnzmove.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(ballnum));
    list.add(inttostr(x));
    list.add(inttostr(y));
    list.add(inttostr(z));
    if relative then
      list.add(inttostr(relnum));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function tlnzmove.descriptive: string;
begin
  result := 'Ball ' + inttostr(ballnum) + ' X ' + inttostr(x) + ' Y ' + inttostr(y) + ' Z ' + inttostr(z);
  if relative then result := result + ' Relative ' + inttostr(relnum);
end;

function tlnzprojection.queryballref(const aname: string): boolean;
begin
  result := (inttostr(anchor) = aname) or (inttostr(ball) = aname);
end;

procedure tlnzprojection.UpdateBallRef(var ref: TRefChangeArray);
begin
  anchor := upballref(ref, anchor);
  ball := upballref(ref, ball);
end;

function tlnzprojection.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then
    if op = uopdelete then begin
      if anchor > start then anchor := anchor - 1 else
        if anchor = start then result := false;

      if ball > start then ball := ball - 1 else
        if ball = start then result := false;
    end else begin
      if anchor >= start then anchor := anchor + 1;
      if ball >= start then ball := ball + 1;
    end;
end;

class function tlnzprojection.comment: string;
begin
  result := ';Anchor,ball,distance';
end;

procedure tlnzprojection.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 3) then raise EPEWrongNum.create(list.count, 3);
    anchor := StrToInt(list[0]);
    ball := strtoint(list[1]);
    distance := strtoint(list[2]);
  finally
    list.free;
  end;
end;

procedure tlnzprojection.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(anchor));
    list.add(inttostr(ball));
    list.add(inttostr(distance));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

function tlnzprojection.descriptive: string;
begin
  result := 'Anchor ' + inttostr(anchor) + ' Ball ' + inttostr(ball) + ' Distance ' + inttostr(distance) + '%';
end;


function tlnzcolouroverride.descriptive: string;
begin
  result := 'Ball ' + inttostr(ballnum) + ' Color ' + inttostr(colour);
  if ugroup then result := result + ' Group ' + inttostr(group);
  if utexture then result := result + ' Texture ' + inttostr(texture);
end;

constructor tlnzcolouroverride.create;
begin
  inherited;
  uGroup := false;
  uTexture := false;
end;

function tlnzcolouroverride.UpdateReference(ref: treferencetype; start: integer; op: tupdateop): boolean;
begin
  result := true;
  if ref = rtballnum then
    if op = uopdelete then begin
      if ballnum > start then ballnum := ballnum - 1 else
        if ballnum = start then result := false;
    end else begin
      if ballnum >= start then ballnum := ballnum + 1;
    end;
end;

class function tlnzcolouroverride.comment: string;
begin
  result := ';Ball number,colour,(group),(texture)';
end;

procedure tlnzcolouroverride.loadfromstring(const s: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.commatext := s;
    if (list.count < 2) then raise EPEWrongNum.create(list.count, 2);

    ballnum := strtoint(list[0]);
    colour := strtoint(list[1]);
    uGroup := (list.count >= 3);
    uTexture := (list.count >= 4);
    if ugroup then
      group := strtoint(list[2]);
    if uTexture then
      texture := strtoint(list[3]);
  finally
    list.free;
  end;
end;

procedure tlnzcolouroverride.savetostring(var dest: string);
var list: tstringlist;
begin
  list := tstringlist.create;
  try
    list.add(inttostr(ballnum));
    list.add(inttostr(colour));
    if ugroup then
      list.add(inttostr(group));
    if utexture then
      list.add(inttostr(texture));
    dest := tabformat(list);
  finally
    list.free;
  end;
end;

end.
