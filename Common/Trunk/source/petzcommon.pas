unit petzcommon;

interface

uses sysutils, windows, classes, contnrs, registry, madres, graphics, math,
  petzpaletteunit, gr32;

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
type TPetzName = record
    name: string;
    num: string;
  end;
const petznames: array[2..5] of TPetzName =
  ((name: '\SOFTWARE\PF.Magic\Petz II\1.00.01'; num: 'II'),
    (name: '\SOFTWARE\PF.Magic\Petz 3\3.00.01'; num: '3'),
    (name: '\SOFTWARE\PF.Magic\Petz 4\4.00.00'; num: '4'),
    (name: '\SOFTWARE\StudioMythos\Petz 5\4.00.00'; num: '5'));
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

