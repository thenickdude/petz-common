unit spritedecoderunit;

interface
uses windows, types, graphics, sysutils, contnrs, classes, math, petzpaletteunit,
  gr32, dialogs;

type
  TGendecoder = class;
  TGenAnimation = class;

  TGenframe = class
  private
    fanim: TGenAnimation;
    function getpoint: tpoint; virtual; abstract;
    procedure setpoint(value: tpoint); virtual; abstract;
  public
    transindex: integer;
    palette: pgamepalette;
    framedata: tmemorystream;
    procedure encodeswatch; virtual; abstract;
    property anim: Tgenanimation read fanim write fanim;
    function decode(bmp: tbitmap32): boolean; virtual; abstract;
    procedure encode(bmp: tbitmap32); virtual; abstract;
    procedure assign(source: tgenframe); virtual;
    function width: integer; virtual; abstract;
    function height: integer; virtual; abstract;
    property disppoint: tpoint read getpoint write setpoint;
    constructor create(newpal: pgamepalette; atransindex: integer); virtual;
    destructor Destroy; override;
  end;

  TGenanimation = class
  private
    fframes: tobjectlist;
    fname: string;
    function getframe(index: integer): tgenframe;
    procedure setframe(index: integer; value: tgenframe);
  public
    procedure clear;
    procedure delete(index: integer);
    procedure remove(frame: TGenframe);
    procedure add(frame: tgenframe);
    procedure extract(frame: tgenframe);
    function indexof(frame: tgenframe): integer;
    procedure insert(index: integer; frame: TGenFrame);
    function framecount: integer;
    property frames[Index: integer]: TgenFrame read getframe write setframe; default;
    property name: string read fname write fname;
    constructor create;
    destructor Destroy; override;
  end;

  TGendecoder = class
  private
    fanims: tobjectlist;
    fpalette: PGamepalette;
    ftransindex: integer;
    procedure settransindex(value: integer);
    procedure setpalette(value: pgamepalette);
    function getanimation(index: integer): tgenanimation;
    procedure setanimation(index: integer; value: tgenanimation);
  public
    constructor create;
    destructor Destroy; override;
    function animcount: integer;
    procedure add(animation: tgenanimation);
    property transindex: integer read ftransindex write settransindex;
    property palette: pgamepalette read fpalette write setpalette;
    property anims[Index: integer]: tgenanimation read getanimation write setanimation; default;
  end;

  TFrameHeader = packed record
    xoffs, yoffs: word;
    mask1, mask2: word;
    height, width: word;
    ofs1, ofs2: longword;
    format: word;
    unknown: word;
  end;

  TSPRFrame = class(tgenframe)
  private
    function getpoint: tpoint; override;
    procedure setpoint(value: tpoint); override;
    procedure decode8bitmap(bmp: tbitmap32);
    procedure encode8bitmap(bmp: tbitmap32; stream: tmemorystream);
  public
    header: tframeheader;
    function width: integer; override;
    function height: integer; override;
    function decode(bmp: tbitmap32): boolean; override;
    procedure encode(bmp: tbitmap32); override;
    procedure encodeswatch; override;
    procedure assign(source: tgenframe); override;
    constructor create(newpal: pgamepalette; atransindex: integer); override;
  end;

  TSPRAnimation = class(tgenanimation)
  public
    r1: longword;
    nextspritejump: longword;
  end;

  TSPRDecoder = class(tgendecoder)
  public
    procedure encode(stream: tmemorystream);
    procedure decode(stream: tmemorystream);
  end;

type
  T3Frameheader = record
    data: packed record
      tlx, tly, brx, bry: word;
      zero: longword;
      effeff: longword;
    end;

    offset: longword;
  end;

  T3frame = class(tgenframe)
  private
    function getpoint: tpoint; override;
    procedure setpoint(value: tpoint); override;
  public
    flags: longword;
    header: t3frameheader;
    procedure encodeswatch; override;
    function width: integer; override;
    function height: integer; override;
    procedure assign(source: tgenframe); override;
    function decode(bmp: tbitmap32): boolean; override;
    procedure encode(bmp: tbitmap32); override;
  end;

  T3Animation = class(tgenanimation);

  T3FLMDecoder = class(tgendecoder)
  public
    procedure encode(flh, flm: tmemorystream);
    procedure decode(flh, flm: tmemorystream);
  end;


implementation


function t3frame.width: integer;
begin
  result := header.data.brx - header.data.tlx;
end;

function t3frame.height: integer;
begin
  result := header.data.bry - header.data.tly;
end;


function t3frame.getpoint: tpoint;
begin
  result := point(header.data.tlx, header.data.tly);
end;

procedure t3frame.setpoint(value: tpoint);
begin
  header.data.brx := header.data.brx - header.data.tlx + value.x;
  header.data.bry := header.data.bry - header.data.tly + value.y;
  header.data.tlx := value.x;
  header.data.tly := value.y;
end;

function t3frame.decode(bmp: tbitmap32): boolean;
var t1, x, y: integer;
  b: byte;
begin
  result := true;
  bmp.setsize(width, height);
  framedata.seek(0, sofrombeginning);
  for y := bmp.height - 1 downto 0 do
    for x := 0 to bmp.width - 1 do begin
      framedata.read(b, 1);
      if b = transindex then
        bmp.pixel[x, y] := setalpha(Color32(palette[b]), 0) else
        bmp.pixel[x, y] := Color32(palette[b]);
      if x = bmp.width - 1 then
        if bmp.width mod 4 <> 0 then begin
          for t1 := 1 to 4 - (bmp.width mod 4) do
            framedata.read(b, 1);
        end;
    end;
end;

procedure t3frame.encodeswatch;
var b: byte;
begin
  framedata.clear;
  header.data.brx := header.data.tlx + 16;
  header.data.bry := header.data.tly + 16;

  for b := 0 to 255 do
    framedata.write(b, 1); //write this colour from pal
end;

procedure t3frame.encode(bmp: tbitmap32);
var x, y: integer;
  b: byte;
  bitmap2: tbitmap;
  Row: pByteArray;
begin
  framedata.Clear;
  header.data.brx := header.data.tlx + bmp.width;
  header.data.bry := header.data.tly + bmp.height;

  bitmap2 := tbitmap.create;
  try
    reducecolours(bmp, bitmap2, palette^, 0, 255, transindex);
    for y := bitmap2.height - 1 downto 0 do begin
      row := bitmap2.ScanLine[y];
      framedata.Write(row[0], bitmap2.width);
      if bitmap2.width mod 4 <> 0 then begin
        b := transindex;
        for x := 1 to 4 - (bitmap2.width mod 4) do
          framedata.write(b, 1);
      end;
    end;
  finally
    bitmap2.free;
  end;
end;

procedure t3frame.assign(source: tgenframe);
var s1: tsprframe;
  s2: t3frame;
  bmp: tbitmap32;
begin
  inherited;

  if source is tsprframe then begin
    s1 := tsprframe(source);

    header.data.tlx := s1.header.xoffs; {assign before bmp copy so co-ords are right}
    header.data.tly := s1.header.yoffs;

    bmp := tbitmap32.create;
    try
      s1.decode(bmp);
      encode(bmp);
    finally
      bmp.free;
    end;
  end else if source is T3frame then begin
    s2 := t3frame(source);
    header.data := s2.header.data;

    if (s2.palette = palette) and (s2.transindex = transindex) then
      framedata.LoadFromStream(s2.framedata) else
    begin //Incompatible palette or transindex
      bmp := tbitmap32.create;
      try
        s2.decode(bmp);
        encode(bmp);
      finally
        bmp.free;
      end;
    end;
  end;
end;

procedure t3flmdecoder.encode(flh, flm: tmemorystream);
var t1, t2:cardinal;
  lA, lF: integer;
  lw1, flags: longword;
  frame: t3frame;
  maxwidth, maxheight, w1: word;
  ftemp: tobjectlist;
  buf: string;
begin
  ftemp := tobjectlist.create(false);
  try

    for la := 0 to animcount - 1 do
      for lf := 0 to anims[la].framecount - 1 do begin
        ftemp.add(anims[la].frames[lf]);
        t3frame(anims[la].frames[lf]).header.offset := flm.Position;
        flm.CopyFrom(t3frame(anims[la].frames[lf]).framedata, 0);
      end;

    lw1 := $65;
    flh.Write(lw1, 4);

    w1 := ftemp.count;
    flh.write(w1, 2); //write total framecount

    maxwidth := 0;
    for t1 := 0 to ftemp.count - 1 do
      maxwidth := max(t3frame(ftemp[t1]).header.data.brx - t3frame(ftemp[t1]).header.data.tlx, maxwidth);
    maxheight := 0;
    for t1 := 0 to ftemp.count - 1 do
      maxheight := max(t3frame(ftemp[t1]).header.data.bry - t3frame(ftemp[t1]).header.data.tly, maxheight);
    flh.write(maxwidth, 2);
    flh.write(maxheight, 2);

    w1 := $0000;
    flh.write(w1, 2);

    for t1 := 0 to animcount - 1 do
      for t2 := 0 to anims[t1].framecount - 1 do
      begin
        frame := t3frame(anims[t1].frames[t2]);
        flh.Write(frame.header.data, sizeof(frame.header.data));

        if t2 = 0 then begin {first frame of animation}
          buf := copy(anims[t1].name, 1, 16);
          while length(buf) < 16 do buf := buf + #0;
          flh.write(buf[1], 16);
        end else begin
          buf := stringofchar(#0, 16);
          flh.write(buf[1], 16);
        end;

        flags := 0;

        if (t2 = 0) then flags := flags or 2; // first frame of anim flag
        if (t2 = anims[t1].framecount - 1) then flags := flags or 4; // last frame of anim flag
        if (t1 = animcount - 1) and (t2 = anims[t1].framecount - 1) then flags := flags or 1; // last frame of file flag

        flh.write(flags, 4); // write that

        flh.write(frame.header.offset, 4);
      end;

  finally
    ftemp.free;
  end;
end;

function longwordbound(x: integer): integer;
begin
  if x mod 4 <> 0 then
    result := x + 4 - (x mod 4) else
    result := x;
end;

procedure t3flmdecoder.decode(flh, flm: tmemorystream);
var lw1, flags: longword;
  frcount, maxwidth, maxheight, nullz: word;
  anim: t3animation;
  frame: T3Frame;
  buf: string;
begin
  flh.seek(0, sofrombeginning);
  flh.read(lw1, 4);
  flh.read(frcount, 2);
  flh.read(maxwidth, 2);
  flh.read(maxheight, 2);
  flh.read(nullz, 2);

  fanims.clear;
  anim := nil;
  flags := 0;

  while ((flags and 1) = 0) do begin //1 is last frame of file
    frame := T3frame.create(palette, transindex);
    flh.read(frame.header.data, sizeof(frame.header.data));

    setlength(buf, 16);
    flh.read(buf[1], 16);

    if anim = nil then begin //create a new animation with the spec name and add this frame to it
      anim := T3animation.create;

      if pos(#0, buf) > 0 then
        setlength(buf, pos(#0, buf) - 1);

      anim.name := buf;

      fanims.add(anim);
    end;

    anim.add(frame); //add to the current anim

    flh.read(flags, 4);

    frame.flags := flags;

    flh.read(frame.header.offset, 4);

    flm.seek(frame.header.offset, sofrombeginning);
    frame.framedata.CopyFrom(flm,
      longwordbound(frame.header.data.brx - frame.header.data.tlx) *
      (frame.header.data.bry - frame.header.data.tly));

    if flags and 4 <> 0 then //last frame of animation
      anim := nil;
  end;
end;

function tsprframe.width: integer;
begin
  result := header.width;
end;

function tsprframe.height: integer;
begin
  result := header.height;
end;


function tsprframe.getpoint: tpoint;
begin
  result := point(header.xoffs, header.yoffs);
end;

procedure tsprframe.setpoint(value: tpoint);
begin
  header.xoffs := value.x;
  header.yoffs := value.y;
end;

procedure tsprframe.assign(source: tgenframe);
var s1: tsprframe;
  s2: t3frame;
  bmp: tbitmap32;
begin
  inherited;
  if source is tsprframe then begin
    s1 := tsprframe(source);
    header := s1.header;
    framedata.LoadFromStream(source.framedata);
  end else if source is T3frame then begin
    s2 := t3frame(source);
    bmp := tbitmap32.create;
    try
      s2.decode(bmp);
      encode(bmp);
    finally
      bmp.free;
    end;
    header.xoffs := s2.header.data.tlx;
    header.yoffs := s2.header.data.tly;
  end;
end;

constructor tsprframe.create;
begin
  inherited;
  header.xoffs := 0;
  header.yoffs := 0;
  header.mask1 := 0;
  header.mask2 := 0;
  header.unknown := 0;
  header.height := 0;
  header.width := 0;

end;

procedure decode241bitmap(frame: tsprframe; bmp: tbitmap32);
var t1, x, y: integer;
  b: byte;
  col: longword;
  trans: byte;
  count: byte;

  procedure checknextline;
  begin
    if x > bmp.width - 1 then begin
      x := x - bmp.width;
      y := y + 1;
    end;
  end;
begin
  frame.framedata.seek(0, sofrombeginning);
  bmp.setsize(frame.header.width, frame.header.height);
  bmp.clear(color32(0, 0, 0, 0));
  y := 0;
  x := 0;
  repeat
    frame.framedata.read(b, 1);
    trans := (b and $80) shr 7;
    count := (b and $7F);

    if (trans = 1) then begin

      if count = 0 then count := 128;

      inc(x, count); {low 7 bits}
      checknextline;
      continue; {read next header byte}
    end else begin

      if count = 0 then count := 128;

      for t1 := 0 to count - 1 do begin
        frame.framedata.read(col, 3);
        bmp.pixel[x, y] := color32((col and $FF0000) shr 16, (col and $FF00) shr 8, col and $FF);
        inc(x);
        checknextline;
      end;
    end;
  until y > bmp.height - 1;
end;


procedure decode242bitmap(frame: tsprframe; bmp: tbitmap32);
var t1, x, y: integer;
  b: byte;
  col: longword;
  alpha, count: byte;

  procedure checknextline;
  begin
    if x > bmp.width - 1 then begin
      x := 0;
      y := y + 1;
    end;
  end;
begin
  frame.framedata.seek(0, sofrombeginning);
  bmp.setsize(frame.header.width, frame.header.height);
  bmp.clear(color32(0, 0, 0, 0));
  y := 0;
  x := 0;
  repeat
    frame.framedata.read(b, 1);
    alpha := ((b and $C0) shr 6) * 85;
    count := (b and $3F);

    if (alpha = 0) then begin
     {top two bits clear. Low 6 bits skip count}
      if count = 0 then count := 64;
      inc(x, count); {low 6 bits}
      checknextline;
      continue; {read next header byte}
    end else begin {Top two bits alpha. Low 6 bits pixel count}
      if count = 0 then count := 64;
      for t1 := 0 to count - 1 do begin
        col := 0;
        frame.framedata.read(col, 3);
        bmp.pixel[x, y] := color32((col and $FF0000) shr 16, (col and $FF00) shr 8, col and $FF, alpha);
        inc(x);
        checknextline;
      end;
    end;
  until y > bmp.height - 1;
end;


procedure tsprframe.decode8bitmap(bmp: tbitmap32);
var t1, x, y: integer;
  b: byte;
  col: byte;
  alpha: byte;
  count: byte;

  procedure checknextline;
  begin
    if x > bmp.width - 1 then begin
      x := x - bmp.width;
      y := y + 1;
    end;
  end;

begin
  framedata.seek(0, sofrombeginning);
  bmp.setsize(header.width, header.height);
  bmp.clear(color32(0, 0, 0, 0));
  y := 0;
  x := 0;
  repeat
    framedata.read(b, 1);
    alpha := (b and $80) shr 7;
    count := (b and $7F);

    if (alpha = 1) then begin //Transparent

      if count = 0 then count := 128;

      inc(x, count); {count is low 7 bits of "b"}
      checknextline;
      continue; {read next header byte}
    end else begin

      if count = 0 then count := 128;

      for t1 := 0 to count - 1 do begin
        framedata.read(col, 1);
        bmp.pixel[x, y] := color32(palette[col]);
        inc(x);
        checknextline;
      end;
    end;
  until y > bmp.height - 1;
end;


function tsprframe.decode(bmp: tbitmap32): boolean;
begin
  result := true;
  case header.format of
    1: decode8bitmap(bmp);
    2: decode241bitmap(self, bmp);
    3: decode242bitmap(self, bmp);
  else result := false;
  end;
end;

function applyalphaerror(col: tcolor32; factor: single; err: integer): tcolor32;
begin
  result := SetAlpha(col, min(max(round(alphacomponent(col) + factor * err), 0), 255));
end;

procedure encode242bitmap(bmp: tbitmap32; stream: tmemorystream);
const alphamask = 128 or 64;
  countmask = not alphamask;
var t1, x, y: integer;
  runtype: integer;
  runcount: integer;
  {error, }alph: integer;
  b: byte;
  buffer: array[0..64 - 1] of tcolor32;
  buflen: integer;
  pixels: pcolor32;
  pixel: tcolor32;
begin
  pixels := bmp.PixelPtr[0, 0];
  pixel:=0;
  for y := 0 to bmp.height - 1 do begin
    runtype := -1;
    buflen := 0;
    runcount := 0;
    alph:=0;
    for x := 0 to bmp.width do begin

      if x <> bmp.width then begin
        pixel := pixels^;
        alph := (pixel shr 24) div 85 {div 1426063360;} {(pixel shr 24) div 85;} // == alpha/85
(*        error := alph * 85 - AlphaComponent(bmp.pixel[x, y]); //calculate alpha error
        if x + 1 < bmp.width - 1 then //distribute the error to surrounding pixels, Floyd-steinberg style
          bmp.pixel[x + 1, y] := applyalphaerror(bmp.Pixel[x + 1, y], 7 / 16, error);
        if y + 1 < bmp.height - 1 then begin
          if x - 1 > 0 then
            bmp.pixel[x - 1, y + 1] := applyalphaerror(bmp.pixel[x - 1, y + 1], 3 / 16, error);
          bmp.pixel[x, y + 1] := applyalphaerror(bmp.pixel[x, y + 1], 5 / 16, error);
          if x + 1 < bmp.width - 1 then
            bmp.pixel[x + 1, y + 1] := applyalphaerror(bmp.pixel[x + 1, y + 1], 1 / 16, error);
        end;   *)
      end;

      if runtype = -1 then begin
        runtype := alph;
      end;

      if (x = bmp.width) or (alph <> runtype) or (runcount = 64) then begin
        case runtype of
          0: begin
          {record 0 run}
              b := runcount and countmask;
              stream.write(b, 1);
            end;
          1, 2, 3: begin
         {record pixel run}
              b := (runtype shl 6) or (runcount and countmask);
              stream.write(b, 1);
              for t1 := 0 to buflen - 1 do
                stream.write(buffer[t1], 3);
              buflen := 0;
            end;
        end;
        runtype := alph;
        runcount := 0;
      end;

      if x <> bmp.width then begin
        case runtype of
          0: begin
              inc(runcount);
            end;
          1, 2, 3: begin {another pixel in this run..}
              buffer[buflen] := pixel;
              inc(buflen);
              inc(runcount);
            end;
        end;
        inc(pixels);
      end;
    end;
  end;
end;

procedure encode241bitmap(bmp: tbitmap32; stream: tmemorystream);
var t1, x, y: integer;
  runtype: integer;
  runcount: integer;
  alph: integer;
  b: byte;
  buffer: array of tcolor32;
begin
  for y := 0 to bmp.height - 1 do begin
    runtype := -1;
    setlength(buffer, 0);
    runcount := 0;
    alph:=0;
    for x := 0 to bmp.width do begin

      if x <> bmp.width then
        if AlphaComponent(bmp.pixel[x, y]) < 128 then
          alph := 1 else
          alph := 0;

      if runtype = -1 then begin
        runtype := alph;
      end;

      if (x = bmp.width) or (alph <> runtype) or (runcount = 128) then begin
        case runtype of
          1: begin
          {record transparent run}
              b := 128 or runcount;
              stream.write(b, 1);
            end;
          0: begin
         {record pixel run}
              b := runcount and not 128;
              stream.write(b, 1);
              for t1 := 0 to high(buffer) do
                stream.write(buffer[t1], 3);
              setlength(buffer, 0);
            end;
        end;
        runtype := alph;
        runcount := 0;
      end;

      if x <> bmp.width then
        case runtype of
          1: begin
              inc(runcount);
            end;
          0: begin {another pixel in this run..}
              setlength(buffer, length(buffer) + 1);
              buffer[high(buffer)] := bmp.pixel[x, y];
              inc(runcount);
            end;
        end;
    end;
  end;
end;

procedure tsprframe.encode8bitmap(bmp: tbitmap32; stream: tmemorystream);
var x, y: integer;
  runtype: integer;
  runcount: byte;
  alph: integer;
  b: byte;
  buffer: array of byte;
  bitmap: tbitmap;
  Row: pByteArray;
begin
  bitmap := tbitmap.create;
  try
    reducecolours(bmp, bitmap, palette^, 0, 255, transindex);

    for y := 0 to bitmap.height - 1 do begin
      runtype := -1;
      alph := -1;
      setlength(buffer, 0);
      runcount := 0;
      row := bitmap.ScanLine[y];
      for x := 0 to bitmap.width do begin

        if x <> bitmap.width then
          if row[x] = transindex then alph := 1 else alph := 0;

        if runtype = -1 then begin
          runtype := alph;
        end;

        if (x = bitmap.width) or (alph <> runtype) or (runcount = 128) then begin
          case runtype of
            1: begin
          {record 0 run}
                if runcount = 128 then b := (1 shl 7) else
                  b := (1 shl 7) or runcount;
                stream.write(b, 1);
              end;
            0: begin
         {record pixel run}
                if runcount = 128 then
                  b := 0 else
                  b := runcount;
                stream.write(b, 1);
                stream.write(buffer[0], length(buffer) * 1); {1 byte for each pixel}
                setlength(buffer, 0);
              end;
          else raise exception.create('');
          end;
          runtype := alph;
          runcount := 0;
        end;

        if x <> bitmap.width then
          case runtype of
            1: begin
                inc(runcount);
              end;
            0: begin {another pixel in this run..}
                setlength(buffer, length(buffer) + 1);
                buffer[high(buffer)] := row[x];
                inc(runcount);
              end;
          end;
      end;
    end;
  finally
    bitmap.free;
  end;
end;

procedure tsprframe.encodeswatch;
var x, y: integer;
  b: byte;
begin
  framedata.clear;

  for y := 0 to 16 - 1 do begin
    b := 16;
    framedata.write(b, 1); //write runcount for non-transparent pixel
    for x := 0 to 16 - 1 do begin
      b := y * 16 + x;
      framedata.write(b, 1); //write this colour from pal
    end;
  end;

  header.width := 16;
  header.height := 16;
end;

procedure tsprframe.encode(bmp: tbitmap32);
begin
  framedata.Clear;
  case header.format of
    1: encode8bitmap(bmp, framedata);
    2: encode241bitmap(bmp, framedata);
    3: encode242bitmap(bmp, framedata);
  else raise exception.create('Invalid frame format - Cannot encode input bitmap to match!');
  end;
  header.width := bmp.width;
  header.height := bmp.height;
end;

constructor tgenframe.create(newpal: pgamepalette; atransindex: integer);
begin
  framedata := tmemorystream.create;
  palette := newpal;
  transindex := atransindex;
end;

procedure tgenframe.assign(source: tgenframe);
begin
end;

destructor tgenframe.destroy;
begin
  framedata.free;
end;

procedure tgenanimation.clear;
begin
  fframes.clear;
end;

function tgenanimation.framecount: integer;
begin
  result := fframes.count;
end;

procedure tgenanimation.delete(index: integer);
begin
  fframes.delete(index);
end;

function tgenanimation.indexof(frame: tgenframe): integer;
begin
  result := fframes.IndexOf(frame);
end;

procedure tgenanimation.add(frame: tgenframe);
begin
  fframes.add(frame);
  frame.anim := self;
end;

procedure tgenanimation.insert(index: integer; frame: TGenFrame);
begin
  fframes.Insert(index, frame);
end;

procedure TGenAnimation.extract(frame: tgenframe);
begin
  fframes.Extract(frame);
end;

procedure TGenAnimation.remove(frame: TGenframe);
begin
  fframes.remove(frame);
end;

function tgenanimation.getframe(index: integer): tgenframe;
begin
  result := tgenframe(fframes[index]);
end;

procedure tgenanimation.setframe(index: integer; value: tgenframe);
begin
  fframes[index] := tgenframe(value);
end;

constructor tgenanimation.create;
begin
  fframes := tobjectlist.create;
end;

destructor tgenanimation.destroy;
begin
  fframes.free;
end;


procedure tgendecoder.settransindex(value: integer);
var anim, t1: integer;
begin
  ftransindex := value;
  for anim := 0 to animcount - 1 do
    for t1 := 0 to anims[anim].framecount - 1 do
      anims[anim].frames[t1].transindex := value;
end;

procedure tgendecoder.setpalette(value: pgamepalette);
var anim, t1: integer;
begin
  fpalette := value;
  for anim := 0 to animcount - 1 do
    for t1 := 0 to anims[anim].framecount - 1 do
      anims[anim].frames[t1].palette := value;
end;

constructor tgendecoder.create;
begin
  fanims := tobjectlist.create;
  palette := @palpetz;
  ftransindex := petztransparentindex;
end;

destructor tgendecoder.destroy;
begin
  fanims.free;
end;

function tgendecoder.animcount: integer;
begin
  result := fanims.count;
end;

function tgendecoder.getanimation(index: integer): tgenanimation;
begin
  result := tgenanimation(fanims[index]);
end;

procedure tgendecoder.setanimation(index: integer; value: tgenanimation);
begin
  fanims[index] := tgenanimation(value);
end;

procedure tgendecoder.add(animation: tgenanimation);
begin
  fanims.add(animation);
end;

procedure tsprdecoder.encode(stream: tmemorystream);
var oAnimTable: integer;
  oAnimoffsets: array of integer;
  oldpos, oAnimSize: integer;
  t1, t2, t3: integer;
  animsstart: integer;
  l: longword;
  b: byte;
begin

  l := fanims.count;

  stream.write(l, 4);
  setlength(oanimoffsets, l);
  oAnimTable := stream.position;

  for t1 := 0 to fanims.count - 1 do begin
    l := 0;
    stream.write(l, 4); {go back later}
  end;

  animsstart := stream.position;
  for t1 := 0 to fanims.count - 1 do begin
    oanimoffsets[t1] := stream.position - animsstart;
    b := length(anims[t1].name) and $FF;
    stream.write(b, 1);
    if b > 0 then
      stream.write(anims[t1].name[1], b);
    b := 0;
    stream.write(b, 1); {trailing zero}
    stream.write(tspranimation(anims[t1]).r1, 4); {Bitdepth, but seems to be ignored by Petz}
    l := anims[t1].framecount;
    stream.write(l, 4); {frame count}

    for t2 := 0 to anims[t1].framecount - 1 do begin
      tsprframe(anims[t1].frames[t2]).header.ofs2 := 0;
      if t2 >= 0 then
        for t3 := 0 to t2 - 1 do
          tsprframe(anims[t1].frames[t2]).header.ofs2 := tsprframe(anims[t1].frames[t2]).header.ofs2 +
            tsprframe(anims[t1].frames[t3]).header.width * tsprframe(anims[t1].frames[t3]).header.height * 4;
      tsprframe(anims[t1].frames[t2]).header.ofs1 := 0;
      if t2 >= 0 then
        for t3 := 0 to t2 - 1 do
          tsprframe(anims[t1].frames[t2]).header.ofs1 := tsprframe(anims[t1].frames[t2]).header.ofs1 +
            tsprframe(anims[t1].frames[t3]).framedata.size + 4;

      stream.write(tsprframe(anims[t1].frames[t2]).header, sizeof(tframeheader));
    end;
    oanimsize := stream.position;
    l := 0; {anim frames total length}
    stream.write(l, 4);

    for t2 := 0 to anims[t1].framecount - 1 do begin
      l := anims[t1].frames[t2].framedata.size + 4;
      stream.write(l, 4);
      stream.copyfrom(anims[t1].frames[t2].framedata, 0);
    end;
    oldpos := stream.position;
    stream.seek(oAnimSize, sofrombeginning);
    l := oldpos - oanimsize - 4;
    stream.write(l, 4);

    stream.seek(oldpos, sofrombeginning);
  end;
  stream.seek(oanimtable, sofrombeginning);
  for t1 := 0 to High(oanimoffsets) do
    stream.write(oanimoffsets[t1], 4);
end;

procedure noop;
begin
end;

procedure tsprdecoder.decode(stream: tmemorystream);
var b: byte; l: longword;
  t1, t2: integer;
  startjump: cardinal;
  framelength, framecount: longword;
  animoffsets: array of longword;
  anim: TSPRAnimation;
  frame: tsprframe;
begin
  fanims.Clear;
  stream.seek(0, sofrombeginning);
  stream.read(l, 4);
  setlength(animoffsets, l);
  for t1 := 0 to high(animoffsets) do
    stream.read(animoffsets[t1], 4);

  startjump := stream.position;

  for t1 := 0 to l - 1 do begin
    anim := TSPRAnimation.create;
    add(anim);
    stream.seek(animoffsets[t1] + startjump, sofrombeginning);
    stream.read(b, 1);
    setlength(anim.fname, b);
    stream.read(anim.fname[1], b);
    stream.read(b, 1); {assume trailing zero..}

    stream.read(anim.r1, 4); {unknown use}
    stream.read(framecount, 4); {framecount}

    for t2 := 0 to framecount - 1 do begin
      frame := tsprframe.create(palette, transindex);
      anim.add(frame);
      stream.read(frame.header, sizeof(frame.header));
    end;

    stream.Read(tspranimation(anims[t1]).nextspritejump, 4);

    for t2 := 0 to framecount - 1 do
    {     if not ((frame.header.width=0) and (frame.header.height=0)) then }begin
      stream.read(framelength, 4);
      anims[t1].frames[t2].framedata.CopyFrom(stream, framelength - 4);
    end;

  end;

end;


end.

