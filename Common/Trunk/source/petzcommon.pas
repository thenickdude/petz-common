unit petzcommon;

interface

uses sysutils, windows, classes, contnrs, registry, gr32, madres, graphics, math,
  petzpaletteunit, ecxmlparser;

type
  TKeyBallName = (kbHead, kbChest, kbNeck, kbJaw, kbTongue1, kbTongue2, kbChin, kbNose, kbButt, kbBelly, kbReye, kbLeye, kbRIris, kbLIris);

  TTexsourcetype = (tsNotfound, tsDLL, tsDisk);
  TTexturelocationrecord = record
    sourcetype: ttexsourcetype;
    sourcelocation: string;
    name: string;
  end;

  TScalesrecord = record
    height, fatness: integer;
  end;

  TPetzOutlineType = (otNone, otBoth, otLeft, otRight, otNose);

  TOutlineDescriptor = record
    outlinetype: TPetzOutlineType;
    size: integer;
  end;

  TSpecies = (sNone, sDog, sCat, sOddball, sBaby);

  TReferencetype = (rtTextures, rtBallnum);

  TSecttype = (stUnknown, stUnnamed, stOmissions, stEyeLidColor, stMove, stProjectball, staddball,
    stlinez, stpaintballz, stballzinfo, sttexturelist, stcoloroverride, stfuzzoverride, stballsizeoverride,
    stthinfat);

  TPetzTextureBlendType = (tbBlend, tbSingleColour, tbUnchanged);
  TPetzTextureBlend = record
    BlendType: TPetzTextureBlendType;
    col: byte;
  end;

  tconvrecord = record
    id: tsecttype;
    name: string;
  end;

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

const
  convarray: array[0..74] of tconvrecord = (
    (Id: stUnnamed; name: 'Ear Extension'),
    (Id: stUnnamed; name: 'Eyes'),
    (Id: steyelidcolor; name: '256 Eyelid Color'),
    (Id: stUnnamed; name: 'Face Extension'),
    (Id: stUnnamed; name: 'Body Extension'),
    (Id: stUnnamed; name: 'Draw Small Balls'),
    (Id: stUnnamed; name: 'Force To Male'),
    (Id: stUnnamed; name: 'Force To Female'),
    (Id: stUnnamed; name: 'Z Shade Slope'),
    (Id: stUnnamed; name: 'Default Glue Ball'),
    (Id: stUnnamed; name: 'Line Render Mode'),
    (Id: stUnnamed; name: 'Circle Render Mode'),
    (Id: stUnnamed; name: 'Draw Linez Before Ballz'),
    (Id: stUnnamed; name: 'Species'),
    (Id: stUnnamed; name: 'Lnz Version'),
    (Id: stUnnamed; name: 'Num Ballz'),
    (Id: stUnnamed; name: 'Additional Frames'),
    (Id: stUnnamed; name: 'Little one'),
    (Id: stUnnamed; name: 'Default Linez File'),
    (Id: stUnnamed; name: 'Breed Name'),
    (Id: stUnnamed; name: 'Sounds'),
    (Id: stUnnamed; name: 'Default Scales'),
    (Id: stUnnamed; name: 'Feet Enlargement'),
    (Id: stUnnamed; name: 'Head Enlargement'),
    (Id: stUnnamed; name: 'Leg Extension'),
    (Id: stUnnamed; name: 'Head Tilt Limits'),
    (Id: stUnnamed; name: 'Head Rotation Limits'),
    (Id: stpaintballz; name: 'Paint Ballz'),
    (Id: stUnnamed; name: 'Whiskers'),
    (Id: stballzinfo; name: 'Ballz Info'),
    (Id: stlinez; name: 'Linez'),
    (Id: stUnnamed; name: 'Default Linez Thickness'),
    (Id: stOmissions; name: 'Omissions'),
    (Id: stprojectball; name: 'Project Ball'),
    (Id: stMove; name: 'Move'),
    (Id: stthinfat; name: 'Thin/Fat'),
    (Id: staddball; name: 'Add Ball'),
    (Id: stUnnamed; name: 'Head Shot'),
    (Id: stUnnamed; name: 'No Texture Rotate'),
    (Id: sttexturelist; name: 'Texture List'),
    (Id: stcoloroverride; name: 'Outline Color Override'),
    (Id: stfuzzoverride; name: 'Fuzz Override'),
    (Id: stballsizeoverride; name: 'Ball Size Override'),
    (Id: stcoloroverride; name: 'Color Info Override'),
    (Id: stUnnamed; name: 'Add Ball Override'),
    (Id: stUnnamed; name: 'Extra Head Balls'),
    (Id: stUnnamed; name: 'Extra Balls'),
    (Id: stUnnamed; name: 'Left Brow Balls'),
    (Id: stUnnamed; name: 'Right Brow Balls'),
    (Id: stUnnamed; name: 'Jowlz Balls'),
    (Id: stUnnamed; name: 'Whisker Balls'),
    (Id: stUnnamed; name: 'Tail Balls'),
    (Id: stUnnamed; name: 'Left Ear Balls'),
    (Id: stUnnamed; name: 'Right Ear Balls'),
    (Id: stUnnamed; name: 'Left Arm Balls'),
    (Id: stUnnamed; name: 'Right Arm Balls'),
    (Id: stUnnamed; name: 'Head Balls'),
    (Id: stUnnamed; name: 'Left Foot Balls'),
    (Id: stUnnamed; name: 'Right Foot Balls'),
    (Id: stUnnamed; name: 'Left Hand Balls'),
    (Id: stUnnamed; name: 'Right Hand Balls'),
    (Id: stUnnamed; name: 'Left Leg Balls'),
    (Id: stUnnamed; name: 'Right Leg Balls'),
    (Id: stUnnamed; name: 'Body Balls'),
    (Id: stUnnamed; name: 'Key Balls'),
    (Id: stUnnamed; name: 'Fur Color Areas'),
    (Id: stUnnamed; name: 'Fur Pattern Balls'),
    (Id: stUnnamed; name: 'Fur Markings'),
    (Id: stUnnamed; name: 'Marking Factor'),
    (Id: stUnnamed; name: 'Spot Factor'),
    (Id: stUnnamed; name: 'Adjust Clothing'),
    (Id: stUnnamed; name: 'Flat Clothing'),
    (Id: stUnnamed; name: 'Add Clothing'),
    (Id: stUnnamed; name: 'Polygons'),
    (Id: stUnnamed; name: 'Eyelash Info'));
  ballnames: array[0..66] of string = ('L ankle', 'L eyebrow1', 'L eyebrow2', 'L eyebrow3',
    'L ear1', 'L ear2', 'L ear3', 'L elbow', 'L eye', 'L finger1', 'L finger2', 'L finger3', 'L foot',
    'L hand', 'L iris', 'L jowl', 'L knee', 'L nostril', 'L shoulder', 'L hip', 'L toe1', 'L toe2',
    'L toe3', 'L wrist', 'R ankle', 'R eyebrow1', 'R eyebrow2', 'R eyebrow3', 'R ear1', 'R ear2',
    'R ear3', 'R elbow', 'R eye', 'R finger1', 'R finger2', 'R finger3', 'R foot', 'R hand', 'R iris',
    'R jowl', 'R knee', 'R nostril', 'R shoulder', 'R hip', 'R toe1', 'R toe2', 'R toe3', 'R wrist',
    'Belly', 'Butt', 'Chest', 'Chin', 'Head', 'Jaw', 'Neck', 'Nose (bottom)', 'Snout', 'Tail1', 'Tail2',
    'Tail3', 'Tail4', 'Tail5', 'Tail6', 'Tongue1', 'Tongue2', 'Z-trans', 'Z-orient');
  catzballnames: array[0..66] of string = ('ankleL', 'ankleR', 'belly', 'butt', 'cheekL',
    'cheekR', 'chest', 'chin', 'earL1', 'earL2', 'earR1', 'earR2', 'elbowL', 'elbowR', 'eyeL',
    'eyeR', 'fingerL1', 'fingerL2', 'fingerL3', 'fingerR1', 'fingerR2', 'fingerR3',
    'handL', 'handR', 'head', 'hipL', 'hipR', 'irisL', 'irisR', 'jaw', 'jowlL', 'jowlR',
    'kneeL', 'kneeR', 'knuckleL', 'knuckleR', 'neck', 'nose', 'shoulderL', 'shoulderR',
    'snout', 'soleL', 'soleR', 'tail1', 'tail2', 'tail3', 'tail4', 'tail5',
    'tail6', 'toeL1', 'toeL2', 'toeL3', 'toeR1', 'toeR2', 'toeR3', 'tongue1', 'tongue2',
    'whiskerL1', 'whiskerL2', 'whiskerL3', 'whiskerR1', 'whiskerR2', 'whiskerR3', 'wristL',
    'wristR', 'zorient', 'ztrans');
  babyzballnames: array[0..119] of string = (
    'ankleL', 'ankleR', 'archL', 'archR', 'belly', 'bigtoeL', 'bigtoeR', 'bridge', 'cheekL',
    'cheekR', 'chestL', 'chestR', 'chin1', 'chin2', 'chin3', 'chin4', 'ear1L', 'ear1R', 'ear2L',
    'ear2R', 'ear3L', 'ear3R', 'ear4L', 'ear4R', 'ear5L', 'ear5R', 'ear6L', 'ear6R', 'earcenterL',
    'earcenterR', 'elbowL', 'elbowR', 'extra1', 'extra2', 'extra3', 'eyeL', 'eyeR', 'eyebrow1L',
    'eyebrow1R', 'eyebrow2L', 'eyebrow2R', 'eyebrow3L', 'eyebrow3R', 'eyebrow4L', 'eyebrow4R',
    'eyebrow5L', 'eyebrow5R', 'finger_index1L', 'finger_index1R', 'finger_index2L', 'finger_index2R',
    'finger_middle1L', 'finger_middle1R', 'finger_middle2L', 'finger_middle2R', 'finger_pinky1L',
    'finger_pinky1R', 'finger_pinky2L', 'finger_pinky2R', 'football1L', 'football1R', 'football2L',
    'football2R', 'head', 'heelL', 'heelR', 'hipL', 'hipR', 'irisL', 'irisR', 'jock', 'kneeL',
    'kneeR', 'lowerLip1', 'lowerLip2', 'lowerLip3', 'lowerLip4', 'lowerLip5', 'lowerLip6',
    'mouthTopL', 'mouthTopR', 'neck', 'nose1', 'nose2', 'nosemiddle', 'nostrilL', 'nostrilR',
    'origin', 'palm1L', 'palm1R', 'palm2L', 'palm2R', 'palm3L', 'palm3R', 'shoulderL', 'shoulderR',
    'templeL', 'templeR', 'thumb1L', 'thumb1R', 'thumb2L', 'thumb2R', 'toe_indexL', 'toe_indexR',
    'toe_middleL', 'toe_middleR', 'toe_pinkyL', 'toe_pinkyR', 'tongue1', 'underchin', 'upperLip1',
    'upperLip2', 'upperLip3', 'upperLip4', 'upperLip5', 'upperLip6', 'wristL', 'wristR', 'zorient',
    'ztrans');

function filenametospecies(const filename: string): TSpecies;

function sttoclass(secttype: TSecttype): TLNZlineclass;
function translatetextureargument(argument: integer): TPetzTextureBlend;
function findtexture(filename, name: string): ttexturelocationrecord;
procedure enumerateresources(dll: string; restype: string; list: tstrings);
procedure enumerateresourcesp(dll: string; restype: pchar; list: tstrings);
procedure enumerateresourcetypes(dll: string; list: tstrings);
function firstnumber(s: string): integer;
function stripcomments(const s: string): string;
function getcomments(const s: string): string;
function stringtosectiontype(s: string): tsecttype;
function sectiontypetostring(s: tsecttype): string;
procedure reducecolours(orig: tbitmap32; dest: tbitmap; pal: TGamePalette; pmin, pmax: byte; trans: byte);
procedure setpetzpalettetobitmap(bmp: tbitmap; pal: tgamepalette);
procedure magentatotransparent(bmp: tbitmap32);

function petdatetodelphidate(p: longword): tdatetime;
function delphidatetopetdate(d: TDateTime): longword;

function outlinedesctotype(outlinetype: TPetzOutlineType; size: integer): integer;
function outlinetypetodesc(outline: integer): TOutlineDescriptor;

procedure findpetzfiles;
function petzcolourto32(petzcolour: integer; fallback: TColor32 = clblack32): tcolor32;

function tabformat(list: tstrings): string;

var dogzfolder, catzfolder, babyzfolder, catzdll, dogzdll, petzdll, babyzdll: string;
  petzfolders: array[2..5] of string;
  dogzver, catzver: integer;

implementation

uses petzresourcestoreunit, xmlassist;

type tcolrecord = record
    index: byte;
    er, eg, eb: Smallint;
  end;

function petdatetodelphidate(p: longword): tdatetime;
begin                                         
  result := encodedate(1970, 1, 1) + (p / 86400);
end;

function delphidatetopetdate(d: TDateTime): longword;
begin
  result := round((d - encodedate(1970, 1, 1)) * 86400);
end;

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

function petzcolourto32(petzcolour: integer; fallback: TColor32 = clblack32): tcolor32;
begin
  if (petzcolour < 0) or (petzcolour > 255) then result := fallback else
    result := color32(colours[petzcolour]);
end;

function translatetextureargument(argument: integer): TPetzTextureBlend;
begin
  if argument = 1 then begin
    result.BlendType := tbBlend;
    result.col := 0;
  end else
    if (argument = 0) or ((argument >= 2) and (argument <= 9)) or (argument >= 150) then begin
      result.blendtype := tbUnchanged;
      result.col := 0;
    end else begin
      result.blendtype := tbSingleColour;
      result.col := argument;
    end;
end;

function outlinedesctotype(outlinetype: TPetzOutlineType; size: integer): integer;
begin
  result := -1;
  case outlinetype of
    otNone: result := -1;
    otLeft: result := 0;
    otRight: result := -2;
    otBoth: result := max(1, size - 1);
    otNose: result := -3;
  end;
end;

function outlinetypetodesc(outline: integer): TOutlineDescriptor;
begin
  if outline = 0 then begin
    result.outlinetype := otLeft;
    result.size := 1;
  end else
    if outline = -1 then begin
      result.outlinetype := otNone;
      result.size := 0;
    end else
      if outline = -2 then begin
        result.outlinetype := otRight;
        result.size := 1;
      end else
        if outline = -3 then begin
          result.outlinetype := otNose;
          result.size := 0;
        end else
          if outline >= 0 then begin
            result.outlinetype := otBoth;
            result.size := max(outline - 1, 1);
          end else begin
           {<-3 and unknown}
            result.outlinetype := otboth;
            result.size := 1;
          end;

end;

function filenametospecies(const filename: string): TSpecies;
var ext: string;
begin
  ext := uppercase(extractfileext(filename));

  if ext = '.DOG' then result := sDog else
    if ext = '.CAT' then result := sCat else
      result := sNone;
end;

procedure magentatotransparent(bmp: tbitmap32);
var pix: integer;
  pixels: PColor32;
begin
  pixels := bmp.PixelPtr[0, 0];

  for pix := 0 to bmp.width * bmp.height - 1 do begin
    if pixels^ = clfuchsia32 then
      pixels^ := 0;
    inc(pixels);
  end;
end;

procedure setpetzpalettetobitmap(bmp: graphics.tbitmap; pal: tgamepalette);
var
  i: integer;
  ColorTable: array[byte] of TRGBQuad;
begin
  for i := 0 to 255 do
    with ColorTable[i] do
    begin
      rgbBlue := (pal[i] and $FF0000) shr 16;
      rgbGreen := (pal[i] and $FF00) shr 8;
      rgbRed := pal[i] and $FF;
      rgbReserved := 0;
    end;

  SetDIBColorTable(bmp.Canvas.Handle, 0, 256, ColorTable);
end;

procedure reducecolours(orig: tbitmap32; dest: tbitmap; pal: TGamePalette; pmin, pmax: byte; trans: byte);
var x, y: integer;
  col: tcolrecord;
  row: pbytearray;
  src: tbitmap32;

  function nearestcolour(col: longword): tcolrecord;
  var t1: byte;
    temperr, err: integer;
    fr, fg, fb, pr, pg, pb: byte;
  begin
    result.index := 0;

    Color32ToRGB(col, fr, fg, fb);

    err := maxint;
    for t1 := pmin to pmax do
      if t1 <> trans then begin
        pr := pal[t1] and $FF;
        pg := (pal[t1] and $FF00) shr 8;
        pb := (pal[t1] and $FF0000) shr 16;

        temperr := (pr - fr) * (pr - fr) + (pg - fg) * (pg - fg) + (pb - fb) * (pb - fb);
        if temperr < err then begin
          err := temperr;
          result.index := t1;
        end;
      end;

    pr := pal[result.index] and $FF; //record RGB of chosen colour from palette
    pg := (pal[result.index] and $FF00) shr 8;
    pb := (pal[result.index] and $FF0000) shr 16;

    result.er := fr - pr; {error is original colour minus the chosen colour}
    result.eg := fg - pg;
    result.eb := fb - pb;
  end;

  function applyerror(col: tcolor32; factor: single; err: tcolrecord): tcolor32;
  var r, g, b: byte;
  begin
    Color32ToRGB(col, r, g, b);
    result := Color32(min(max(r + round(factor * err.er), 0), 255),
      min(max(g + round(factor * err.eg), 0), 255),
      min(max(b + round(factor * err.eb), 0), 255), AlphaComponent(col));
  end;

begin

  dest.pixelformat := pf1bit;
  dest.width := orig.width;
  dest.height := orig.height;
  dest.PixelFormat := pf8bit;
  setpetzpalettetobitmap(dest, pal);

  src := tbitmap32.Create;
  try
    src.assign(orig);
    for y := 0 to src.height - 1 do begin
      row := dest.scanline[y];
      for x := 0 to src.width - 1 do
        if AlphaComponent(orig.pixel[x, y]) < 128 then begin
          row[x] := trans;
        end else begin
          col := nearestcolour(src.pixel[x, y]); // find the nearest colour and compute error
          row[x] := col.index; // set the new pixel colour to the output

          if x + 1 < src.width - 1 then
            src.pixel[x + 1, y] := applyerror(src.Pixel[x + 1, y], 7 / 16, col); //apply error
          if y + 1 < src.height - 1 then begin
            if x - 1 > 0 then
              src.pixel[x - 1, y + 1] := applyerror(src.pixel[x - 1, y + 1], 3 / 16, col);
            src.pixel[x, y + 1] := applyerror(src.pixel[x, y + 1], 5 / 16, col);
            if x + 1 < src.width - 1 then
              src.pixel[x + 1, y + 1] := applyerror(src.pixel[x + 1, y + 1], 1 / 16, col);
          end;
        end;
    end;
  finally
    src.free;
  end;
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

function tabformat(list: tstrings): string;
var t1: integer;
begin
  result := ''; // <-- this line important!!
  for t1 := 0 to list.count - 1 do
    if t1 = list.count - 1 then
      result := result + list[t1] else
      result := result + list[t1] + ',' + #9;
end;


procedure findpetzfiles;
type TPetzName=record
 name:string;
 num:string;
 end;
const petznames: array[2..5] of TPetzName=
  ((name:'\SOFTWARE\PF.Magic\Petz II\1.00.01'; num:'II'),
   (name:'\SOFTWARE\PF.Magic\Petz 3\3.00.01'; num:'3'),
   (name: '\SOFTWARE\PF.Magic\Petz 4\4.00.00'; num:'4'),
   (name:'\SOFTWARE\StudioMythos\Petz 5\4.00.00'; num:'5'));
var reg: tregistry;
  root: string;
  i: integer;
begin
  dogzver := 0;
  catzver := 0;
  dogzdll := '';
  catzdll := '';
  petzdll := '';
  dogzfolder := '';
  catzfolder := '';
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_LOCAL_MACHINE;
    for i := high(petznames) downto low(petznames) do begin

    //if user has specified a valid path, use that
      if fileexists(petzfolders[i] + '\resource\petz ' + petznames[i].num + ' rez.dll') then
        root := ExcludeTrailingBackslash(petzfolders[i]) else
        if reg.OpenKey(petznames[i].name, false) then
    //otherwise try to load from Petz
          root := excludetrailingbackslash(reg.ReadString('Petz Root Path')) else
    //otherwise, no path
          root := '';

      if fileexists(root + '\resource\petz ' + petznames[i].num + ' rez.dll') then
        petzfolders[i] := root else
        petzfolders[i] := ''; // user specified invalid, clear

      if dogzdll = '' then
        if fileexists(root + '\resource\dogz ' + petznames[i].num + ' rez.dll') then begin
          dogzdll := root + '\resource\dogz ' + petznames[i].num + ' rez.dll';
          dogzfolder := root;
          dogzver := i;
        end;
      if catzdll = '' then
        if fileexists(root + '\resource\catz ' + petznames[i].num + ' rez.dll') then begin
          catzdll := root + '\resource\catz ' + petznames[i].num + ' rez.dll';
          catzfolder := root;
          catzver := i;
        end;
      if petzdll = '' then
        if fileexists(root + '\resource\petz ' + petznames[i].num + ' rez.dll') then
          petzdll := root + '\resource\petz ' + petznames[i].num + ' rez.dll';
    end;

  finally
    reg.free;
  end;
end;


var texsearch: string;
  texfound: boolean;

function stringtosectiontype(s: string): tsecttype;
var t1: integer;
begin
  result := stunknown;
  for t1 := 0 to high(convarray) do
    if s = convarray[t1].name then begin
      result := convarray[t1].id;
      exit;
    end;
end;

function sectiontypetostring(s: tsecttype): string;
var t1: integer;
begin
  result := 'Unknown';
  for t1 := 0 to high(convarray) do
    if s = convarray[t1].id then begin
      result := convarray[t1].name;
      exit;
    end;
end;


function stripcomments(const s: string): string;
begin
  if pos(';', s) > 0 then
    result := trim(copy(s, 1, pos(';', s) - 1)) else
    result := s;
end;

function getcomments(const s: string): string;
begin
  if pos(';', s) > 0 then
    result := trim(copy(s, pos(';', s) + 1, length(s))) else
    result := '';
end;

function firstnumber(s: string): integer;
const numset = ['0'..'9', '-'];
var start, endpos: integer;
  found: boolean;
begin
  result := 0;

  start := 0;
  found := false;
  repeat
    inc(start);
    if s[start] in numset then begin
      found := true;
      break;
    end;
  until start = length(s);
  if not found then exit;

  endpos := start;
  while (endpos <= length(s)) and (s[endpos] in numset) do inc(endpos);
  dec(endpos);
  result := strtoint(copy(s, start, endpos - start + 1));
end;


function containstexenum(handle: THandle; ResType: PChar; ResName: Pchar; long: Lparam): bool; stdcall;
var s: string;
begin
  s := resname;
  if ansicomparetext(s, texsearch) = 0 then begin
    texfound := true;
    result := false;
  end else result := true;
end;

function DLLcontainsresource(dll: string; resname, restype: string): boolean;
var h: hmodule;
begin
  result := false;
  if not fileexists(dll) then exit;

  texsearch := resname;
  texfound := false;
  h := LoadLibraryEX(pchar(DLL), 0, LOAD_LIBRARY_AS_DATAFILE);
  try
    EnumResourceNames(h, pchar(restype), @containstexenum, 0);
  finally
    FreeLibrary(h);
  end;
  result := texfound;
end;

function findtexture(filename, name: string): ttexturelocationrecord;
var
  dllname: string;
  s: string;
begin
  result.sourcetype := tsNotFound;

  if fileexists(dogzfolder + name) then begin
    result.sourcetype := tsDisk;
    result.sourcelocation := dogzfolder + name;
    result.name := extractfilename(name);
    exit; {wohooo!}
  end;

  if fileexists(catzfolder + name) then begin
    result.sourcetype := tsDisk;
    result.sourcelocation := catzfolder + name;
    result.name := extractfilename(name);
    exit; {wohooo!}
  end;

  s := extractfilename(name);
  s := uppercase(copy(s, 1, length(s) - length(extractfileext(s)))); {remove file extension}
  dllname := '';
  if (length(filename) > 0) and dllcontainsresource(filename, s, 'BMP') then dllname := filename else
    if dllcontainsresource(dogzdll, s, 'BMP') then dllname := dogzdll else
      if dllcontainsresource(catzdll, s, 'BMP') then dllname := catzdll else
        if dllcontainsresource(petzdll, s, 'BMP') then dllname := petzdll;
  if dllname <> '' then begin
    result.sourcetype := tsDLL;
    result.sourcelocation := dllname;
    result.name := s;
  end;
end;



var texenumlist: tstrings;

function texenum(handle: THandle; ResType: PChar; ResName: Pchar; long: Lparam): bool; stdcall;
begin
  texenumlist.add(resname);
  result := true; {continue search}
end;

function typeenum(handle: thandle; restype: pchar; long: lparam): bool; stdcall;
begin
  texenumlist.add(restype);
  result := true; {continue search}
end;

procedure enumerateresources(dll: string; restype: string; list: tstrings);
var h: hmodule;
begin
  texenumlist := list;
  h := LoadLibraryEX(pchar(DLL), 0, LOAD_LIBRARY_AS_DATAFILE);
  try
    EnumResourceNames(h, pchar(restype), @texenum, 0);
  finally
    FreeLibrary(h);
  end;
end;

procedure enumerateresourcesp(dll: string; restype: pchar; list: tstrings);
var h: hmodule;
begin
  texenumlist := list;
  h := LoadLibraryEX(pchar(DLL), 0, LOAD_LIBRARY_AS_DATAFILE);
  try
    EnumResourceNames(h, restype, @texenum, 0);
  finally
    FreeLibrary(h);
  end;
end;

procedure enumerateresourcetypes(dll: string; list: tstrings);
var h: hmodule;
begin
  texenumlist := list;
  h := LoadLibraryEX(pchar(DLL), 0, LOAD_LIBRARY_AS_DATAFILE);
  try
    EnumResourcetypes(h, @typeenum, 0);
  finally
    FreeLibrary(h);
  end;
end;

initialization
  colours := @palpetz;
end.

