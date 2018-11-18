unit PetzColourPicker;

interface

uses
  Windows, types, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gr32_polygons, GR32_Image, gr32_blend, petzpaletteunit, gr32, StdCtrls,
{$IFDEF fake}PetzColourPicker, {$ENDIF}
  extctrls;

type
  TPetzColourGrid = class(tcustompaintbox32)
  private
    fpalette: TPFPaltype;
    fcellheight, fcellwidth, fcols, fcolour, fgap: integer;
    procedure myfillline(Dst: PColor32; DstX, DstY, Length: Integer; AlphaValues: PColor32);
    procedure drawcell(index, x, y: integer);
    function getcolour: integer;
    procedure setcolour(value: integer);
    function getpetzpalette: tpfpaltype;
    procedure setpetzpalette(value: TPFPaltype);
    procedure setcolumns(value: integer);
    function cellrect(index: integer): trect;
  protected
    procedure SetEnabled(value: boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoPaintBuffer; override;
  public
    stipplestart: single;
    procedure animate;
    constructor Create(aowner: tcomponent); override;
    property colour: integer read getcolour write setcolour;
  published
    property columns: integer read fcols write setcolumns;
    property cellwidth: integer read fcellwidth write fcellwidth;
    property cellheight: integer read fcellheight write fcellheight;
    property gap: integer read fgap write fgap;
    property palette: TPFPaltype read getpetzpalette write setpetzpalette;
  end;

  TfrmColourPicker = class(TForm)
    Button1: TButton;
    btnOk: TButton;
    rdoNone: TRadioButton;
    rdoPick: TRadioButton;
    grid: TPetzColourGrid;
    Timer1: TTimer;
    cmbPalette: TComboBox;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure DrawGrid1DblClick(Sender: TObject);
    procedure rdoNoneClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbPaletteChange(Sender: TObject);
  private
    fallownone: boolean;
    fallowchoosepal: boolean;
  public
    { Public declarations }
    colour: integer;
    palette: TPFPalType;
    constructor create(aowner: Tcomponent; icolour: integer; allownone, allowchoosepal: boolean); reintroduce;
  end;

  TPetzColourPicker = class(TCustomPaintBox32)
  private
    fpalette: TPFPaltype;
    fcolour: integer;
    fonchange: tnotifyevent;
    fallownone, fnocolour: boolean;
    procedure myonenter(sender: tobject);
    procedure myonexit(sender: tobject);
    function getcolour: integer;
    procedure setcolour(value: integer);
    function getpetzpalette: tpfpaltype;
    procedure setpetzpalette(value: TPFPaltype);
  protected
    procedure SetEnabled(value: boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DoPaintBuffer; override;
  public
    { Public declarations }
    property colour: integer read getcolour write setcolour;
    constructor Create(aowner: tcomponent); override;
  published
    { Published declarations }
    property allowNone: boolean read fallownone write fallownone;
    property onChange: tnotifyevent read fonchange write fonchange;
    property palette: TPFPaltype read getpetzpalette write setpetzpalette;
    property Enabled;
  end;

{$R *.DFM}

function pickpetzcolour(var colour: integer; palette: TPFPalType = pfpPetz; allownone: boolean = false; allowchoosepal: boolean = false): boolean;

procedure Register;

implementation
uses math;

function pickpetzcolour(var colour: integer; palette: TPFPalType = pfpPetz; allownone: boolean = false; allowchoosepal: boolean = false): boolean;
var pick: TfrmColourPicker;
begin
  pick := TfrmColourPicker.create(application, colour, allownone, allowchoosepal);
  try
    pick.showmodal;
    result := (pick.modalresult = mrok);
    if result then colour := pick.colour;
  finally
    pick.free;
  end;
end;

function dimcolour(dim: boolean; colour: tcolor32): tcolor32;
var i: byte;
begin
  if dim then begin
    i := intensity(colour);
    result := color32(
      (redcomponent(colour) + i * 3) div 4,
      (greencomponent(colour) + i * 3) div 4,
      (bluecomponent(colour) + i * 3) div 4
      );
  end else
    result := colour;
end;

{********************* TPetzColourGrid start ********************}

procedure tpetzcolourgrid.animate;
var r: trect;
begin
  if enabled then begin
    stipplestart := stipplestart + 1;
    if (colour >= 0) and (colour <= 255) then begin
      r := cellrect(colour);
      drawcell(colour, r.left, r.top);
      Flush(r);
    end;
  end;
end;

procedure tpetzcolourgrid.setcolumns(value: integer);
begin
  if value <= 0 then fcols := 16 else fcols := value;
  invalidate;
end;

procedure tpetzcolourgrid.setenabled(value: boolean);
begin
  inherited;
  Invalidate;
end;

procedure tpetzcolourgrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var cx, cy, index: integer;
begin
  inherited;
  cx := (x - 1) div (cellwidth + gap);
  cy := (y - 1) div (cellheight + gap);

  index := (cy * columns) + cx;

  if (index >= 0) and (index <= 255) then begin
    colour := index;
  end;
end;

var acol: tcolor32;
  origin: tpoint;

procedure tpetzcolourgrid.myfillline(Dst: PColor32; DstX, DstY, Length: Integer; AlphaValues: PColor32);
const plat = 4;
var amount: integer;
begin
  while length > 1 do begin


    amount := dsty - (origin.y + plat);
    if dsty - origin.y > plat then amount := 0;

    dst^ := lighten(acol, -amount * 5);
    inc(dst);
    dec(length);
  end;
end;

procedure tpetzcolourgrid.drawcell(index, x, y: integer);
const bevel = 3;
  framegap = 2;
var newcolour: tcolor32;
  ppal: PGamepalette;
  cltrans32, focuscolour, textcolour: tcolor32;
  s: string;
  points: tarrayoffixedpoint;
  dark: boolean;
begin
  cltrans32 := color32(0, 0, 0, 0);
  ppal := pickpalette(palette);

  newcolour := dimcolour(not enabled, color32(ppal^[index]));
  dark := (intensity(newcolour) < 128);

  setlength(points, 5);
  points[0] := fixedpoint(x, y);
  points[1] := fixedpoint(x + cellwidth - bevel, y);
  points[2] := fixedpoint(x + cellwidth, y + bevel);
  points[3] := fixedpoint(x + cellwidth, y + cellheight);
  points[4] := fixedpoint(x, y + cellheight);

  acol := newcolour;
  origin := point(x, y);
  PolygonXS(buffer, points, myfillLine);
  PolylineXS(buffer, points, clwhite32, true);

  if colour = index then begin
    if dark then
      focuscolour := clwhite32 else
      focuscolour := clblack32;
    buffer.SetStipple([focuscolour, focuscolour, cltrans32]);
    Buffer.StippleCounter := stipplestart;
    buffer.FrameRectTSP(x + framegap, y + framegap, x + cellwidth - framegap + 1, y + cellheight - framegap + 1);
  end;

  if dark then
    textcolour := clwhite32 else
    textcolour := clblack32;
  s := inttostr(index);
  buffer.font.name := 'Arial';
  buffer.Font.size := -10;
  buffer.RenderText(
    (cellwidth - 1 - Buffer.TextWidth(s)) div 2 + x + 1,
    (cellheight - 1 - Buffer.TextHeight(s)) div 2 + y + 1,
    s,
    0,
    textcolour
    );
end;

function tpetzcolourgrid.cellrect(index: integer): trect;
begin
  result.left := (index mod columns) * (cellwidth + gap) + 1;
  result.top := (index div columns) * (cellheight + gap) + 1;
  result.right := result.left + cellwidth;
  result.bottom := result.top + cellheight;
end;

procedure tpetzcolourgrid.dopaintbuffer;
var t1: integer;
begin
  inherited;
  buffer.clear(clblack32);

  for t1 := 0 to 255 do
    drawcell(t1, cellrect(t1).left, cellrect(t1).top);
end;

function tpetzcolourgrid.getcolour: integer;
begin
  result := fcolour;
end;

procedure tpetzcolourgrid.setcolour(value: integer);
var oldcell: integer;
begin
  oldcell := fcolour;
  fcolour := value;
  if (oldcell >= 0) and (oldcell <= 255) then begin
    drawcell(oldcell, cellrect(oldcell).left, cellrect(oldcell).top); //draw old cell
    Flush(cellrect(oldcell));
  end;
  drawcell(fcolour, cellrect(fcolour).left, cellrect(fcolour).top); //draw new cell
  Flush(cellrect(fcolour));
end;

function tpetzcolourgrid.getpetzpalette: tpfpaltype;
begin
  result := fpalette;
end;

procedure tpetzcolourgrid.setpetzpalette(value: TPFPaltype);
begin
  fpalette := value;
  invalidate;
end;

constructor tpetzcolourgrid.create(aowner: tcomponent);
begin
  inherited create(aowner);
  stipplestart := 0;
  fcolour := 0;
  fpalette := pfpPetz;
  fcellwidth := 30;
  fcellheight := 25;
  fcols := 16;
  fgap := 3;
end;


{*************Colour picker form*************}

constructor tfrmcolourpicker.create(aowner: Tcomponent; icolour: integer; allownone, allowchoosepal: boolean);
begin
  inherited create(aowner);
  colour := icolour;
  fallownone := allownone;
  fallowchoosepal := allowchoosepal;
end;

procedure TfrmColourPicker.btnOkClick(Sender: TObject);
begin
  if rdopick.checked then
    colour := grid.colour else
    colour := -1;
  ModalResult := mrOk;
end;

procedure TfrmColourPicker.FormShow(Sender: TObject);
begin
  if colour > -1 then
    grid.colour := colour;
  rdonone.enabled := fallownone;
  grid.palette:=palette;
end;

procedure TfrmColourPicker.Button1Click(Sender: TObject);
begin
  ModalResult := mrcancel;
end;

procedure TfrmColourPicker.DrawGrid1DblClick(Sender: TObject);
begin
  btnok.click;
end;

procedure TfrmColourPicker.rdoNoneClick(Sender: TObject);
begin
  grid.enabled := rdoPick.checked;
end;

{***************************TPetzColourPicker BEGINS *************************}

procedure tpetzcolourpicker.myonenter(sender: tobject);
begin
  Invalidate;
end;

procedure tpetzcolourpicker.myonexit(sender: tobject);
begin
  invalidate;
end;

procedure tpetzcolourpicker.setenabled(value: boolean);
begin
  inherited;
  invalidate;
end;


function tpetzcolourpicker.getcolour: integer;
begin
  result := fcolour;
end;

procedure tpetzcolourpicker.setcolour(value: integer);
begin
  fnocolour := (value < 0) or (value > 255);
  if fnocolour then
    fcolour := -1 else
    fcolour := value;
  invalidate;
end;



procedure tpetzcolourpicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var picker: Tfrmcolourpicker;
begin
  inherited;
  picker := Tfrmcolourpicker.Create(application, colour, fallownone, false);
  try
    setfocus;
    paint;
    picker.palette := palette;
    picker.ShowModal;
    if picker.ModalResult = mrok then begin
      SetFocus;
      colour := picker.colour;
      if assigned(onchange) then
        onchange(self);
    end;
  finally
    picker.free;
  end;
end;

function tpetzcolourpicker.getpetzpalette: tpfpaltype;
begin
  result := fpalette;
end;

procedure tpetzcolourpicker.setpetzpalette(value: TPFPaltype);
begin
  fpalette := value;
end;

procedure tpetzcolourpicker.dopaintbuffer;
const border = 3;
var c: tcolor32;
  cltrans32: tcolor32;
  r: trect;
  points: Tarrayoffixedpoint;
  s: string;
  dark: boolean;
  ppal: PGamepalette;
begin
  inherited;

  if fnocolour then
    c := clwhite32 else begin
    ppal := pickpalette(palette);
    c := color32(ppal^[fcolour]);
  end;
  c := dimcolour(not enabled, c);
  buffer.clear(c);
  dark := (Intensity(c) < 128);

  if fnocolour then begin //draw red slash
    setlength(points, 4);
    points[0] := fixedpoint(0, 0);
    points[1] := fixedpoint(width, height - 6);
    points[2] := fixedpoint(width, height);
    points[3] := fixedpoint(0, 6);
    PolygonXS(buffer, points, dimcolour(not enabled, clred32));
  end else begin //draw number
    s := inttostr(colour);
    Font.size := 12;
    font.Name := 'Arial';
    if dark then c := clwhite32 else c := clblack32;
    buffer.RenderText(
      (width - Buffer.TextWidth(s)) div 2,
      (height - Buffer.Textheight(s)) div 2,
      s,
      0,
      c);
  end;

  buffer.FrameRectTS(getviewportrect, color32(0, 0, 0, 100));

  if focused and enabled then begin
    cltrans32 := Color32(0, 0, 0, 0);
    buffer.SetStipple([clgray32, cltrans32]);
    r := getviewportrect;
    InflateRect(r, -border, -border);
    buffer.FrameRectTSP(r.left, r.top, r.right, r.bottom);
  end;
end;

constructor tpetzcolourpicker.create(aowner: tcomponent);
begin
  inherited;
  onchange := nil;
  allownone := true;
  Width := 50;
  height := 33;
  cursor := crHandPoint;
  fcolour := -1;
  fnocolour := true;
  OnEnter := myOnEnter;
  onexit := myonexit;
end;

procedure Register;
begin
  RegisterComponents('Standard', [TPetzColourPicker, TPetzColourGrid]);
end;

procedure TfrmColourPicker.Timer1Timer(Sender: TObject);
begin
  grid.animate;
end;

procedure TfrmColourPicker.FormCreate(Sender: TObject);
var p: TPFPalType;
begin
  cmbPalette.Visible := fallowchoosepal;
  for p := low(p) to high(p) do
    cmbpalette.items.add(paltostr(p));
  cmbpalette.itemindex := 0;
end;

procedure TfrmColourPicker.cmbPaletteChange(Sender: TObject);
begin
  grid.palette := tpfpaltype(cmbpalette.itemindex);
end;

end.

