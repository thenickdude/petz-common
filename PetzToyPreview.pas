unit PetzToyPreview;

interface

uses
  Windows, types, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  GR32_Image, spritedecoderunit, gr32, extctrls, math;

type
  TAnimFinishEvent = procedure(sender: tobject; var animate: boolean) of object;
  TPetzToyPreview = class(TCustomPaintBox32)
  private
    fanim: TGenanimation;
    fgridsize, frate: integer;
    fframeindex: integer;
    fanimate: boolean;
    fautocenter: boolean;
    fonanimfinish: tanimfinishevent;
    ftimer: ttimer;
  protected
    procedure ontimertick(sender: tobject);
    procedure setanimation(value: tgenanimation);
    procedure setframeindex(value: integer);
    procedure setgridsize(value: integer);
    procedure DoPaintBuffer; override;
    procedure setanimate(value: boolean);
    procedure setrate(value: integer);
    procedure setautocenter(value: boolean);
  public
    property FrameIndex: integer read fframeindex write setframeindex;
    property animation: TGenanimation read fanim write setanimation;
    constructor Create(aowner: tcomponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Align;
    property Rate: integer read frate write setrate;
    property GridSize: integer read fgridsize write setgridsize;
    property Animate: boolean read fanimate write setanimate;
    property AutoCenter: boolean read fautocenter write setautocenter;
    property onAnimFinish: tanimfinishevent read fonanimfinish write fonanimfinish;
    property Anchors;
  end;

procedure Register;

implementation

procedure tpetztoypreview.setautocenter(value: boolean);
begin
  if fautocenter = value then exit;
  fautocenter := value;
  Invalidate;
end;

procedure tpetztoypreview.ontimertick(sender: tobject);
begin
  frameindex := frameindex + 1;
end;

procedure tpetztoypreview.setrate(value: integer);
begin
  frate := value;
  ftimer.Interval := frate;
end;

destructor tpetztoypreview.destroy;
begin
  ftimer.free;
  inherited;
end;

procedure tpetztoypreview.setanimate(value: boolean);
begin
  fanimate := value;
  ftimer.enabled := fanimate;
end;

procedure tpetztoypreview.setanimation(value: tgenanimation);
begin
  fanim := value;
  fframeindex := 0;
  invalidate;
end;

procedure tpetztoypreview.setgridsize(value: integer);
begin
  if value < 1 then
    fgridsize := 20 else
    fgridsize := value;
end;

procedure tpetztoypreview.setframeindex(value: integer);
var anim: boolean;
begin
  if Assigned(animation) then begin
    if value > animation.framecount - 1 then begin
      fframeindex := 0;
      if assigned(onanimfinish) then begin
        anim := Animate;
        onAnimFinish(self, anim);
        animate := anim;
      end;
    end else
      if value < 0 then
        fframeindex := animation.framecount - 1 else
        fframeindex := value;
    invalidate;
  end else
    fframeindex := 0;
end;

constructor tpetztoypreview.create(aowner: tcomponent);
begin
  inherited create(aowner);
  fanim := nil;
  fgridsize := 20;
  fanimate := false;
  frate := 100;
  fframeindex := 0;
  fautocenter := true;

  ftimer := TTimer.Create(self);
  ftimer.Enabled := false;
  ftimer.Interval := frate;
  ftimer.OnTimer := ontimertick;
end;

procedure TPetzToyPreview.dopaintbuffer;
var t1, x, y: integer;
  temp: tbitmap32;
  frame: integer;
  origin, extent: tpoint;
begin
  inherited;
  Buffer.Clear(clwhite32);

  for y := 0 to buffer.height div gridsize do
    for x := 0 to buffer.width div gridsize do
      if odd(x + y) then
        buffer.FillRects(x * gridsize, y * gridsize, (x + 1) * gridsize, (y + 1) * gridsize, clLightGray32);

  if assigned(fanim) and (fanim.framecount > 0) then begin
    origin := fanim.frames[0].disppoint;
    extent := point(fanim.frames[0].disppoint.x + fanim.frames[0].width,
      fanim.frames[0].disppoint.y + fanim.frames[0].height);

    for t1 := 1 to fanim.framecount - 1 do begin
      origin := point(min(origin.x, fanim.frames[t1].disppoint.x), min(origin.y, fanim.frames[t1].disppoint.y));
      extent := point(max(extent.x, fanim.frames[t1].disppoint.x + fanim.frames[t1].width), max(extent.y, fanim.frames[t1].disppoint.y + fanim.frames[t1].height));
    end;

    frame := min(max(fframeindex, 0), fanim.framecount - 1);
    temp := tbitmap32.create;
    try
      fanim.frames[frame].decode(temp);
      temp.DrawMode := dmblend;
      if fautocenter then
        temp.DrawTo(buffer, (width - (extent.x - origin.x)) div 2 + (fanim.frames[frame].disppoint.x - origin.x),
          (height - (extent.y - origin.y)) div 2 + (fanim.frames[frame].disppoint.y - origin.y)) else
        temp.drawto(buffer, fanim.frames[frame].disppoint.x, fanim.frames[frame].disppoint.y);
    finally
      temp.free;
    end;
  end;
{  bmppreview.DrawMode := dmBlend;
  bmppreview.Drawto(pntpreview.buffer, px, py);}
end;

procedure Register;
begin
  RegisterComponents('Standard', [TPetzToyPreview]);
end;

end.

