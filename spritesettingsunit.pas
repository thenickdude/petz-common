unit spritesettingsunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  spriteRCDataunit, StdCtrls, petzcommon, madres, Spin;

type
  TfrmSpriteSettings = class(TForm)
    Label1: TLabel;
    lstSprites: TListBox;
    btnSave: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    lblSpriteName: TLabel;
    edtDisplayName: TEdit;
    Label4: TLabel;
    spnID: TSpinEdit;
    chkShowToybox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lstSpritesClick(Sender: TObject);
    procedure edtDisplayNameChange(Sender: TObject);
    procedure spnIDChange(Sender: TObject);
    procedure chkShowToyboxClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    filename: widestring;
  end;

var
  frmSpriteSettings: TfrmSpriteSettings;
  spritercdecoder: TSpriteRCdecoder;
  ignoreupdate: boolean;

implementation

{$R *.DFM}

procedure TfrmSpriteSettings.FormCreate(Sender: TObject);
begin
  spritercdecoder := tspritercdecoder.create;
end;

procedure TfrmSpriteSettings.FormDestroy(Sender: TObject);
begin
  spritercdecoder.free;
end;

procedure TfrmSpriteSettings.FormShow(Sender: TObject);
var update: cardinal;
  data: pointer;
  size: cardinal;
  stream: tmemorystream;
  t1: integer;
begin
  ignoreupdate := false;
  lstSprites.Items.Clear;

  update := BeginUpdateResourceW(pwidechar(filename), false);
  if update = 0 then begin
    showmessage('The toy couldn''t be opened for editing. Make sure that you don''t have Petz open and try again');
    close;
    exit;
  end;
  try
    stream := tmemorystream.create;
    try
      if GetResourceW(update, pwidechar(rt_rcdata), pwidechar($3EB), 1033, data, size) then begin
        stream.Write(data^, size);
        stream.seek(0, sofrombeginning);
        spritercdecoder.decode(stream);
        for t1 := 0 to spritercdecoder.sprites.count - 1 do begin
          lstSprites.Items.add(TSpriteRC(spritercdecoder.sprites[t1]).sprname);
        end;
        lstsprites.itemindex := 0;
        lstsprites.onclick(self);
      end else begin
        showmessage('There was a problem reading the file');
        close;
        exit;
      end;
    finally
      stream.free;
    end;
  finally
    EndUpdateResourceW(update, false);
  end;
end;

procedure TfrmSpriteSettings.lstSpritesClick(Sender: TObject);
var sprite: TSpriteRC;
begin
  if lstSprites.itemindex < 0 then exit;
  ignoreupdate := true;
  sprite := tspriterc(spritercdecoder.sprites[lstsprites.itemindex]);
  try
    lblSpriteName.caption := sprite.sprname;
    edtDisplayName.text := sprite.displayname;
    spnID.value := sprite.id;
    chkShowToybox.Checked := (sprite.avail > 1);
  finally
    ignoreupdate := false;
  end;
end;

procedure TfrmSpriteSettings.edtDisplayNameChange(Sender: TObject);
begin
  if not ignoreupdate then
    tspriterc(spritercdecoder.sprites[lstsprites.itemindex]).displayname := edtDisplayName.text;
end;

procedure TfrmSpriteSettings.spnIDChange(Sender: TObject);
begin
  if not ignoreupdate then
    tspriterc(spritercdecoder.sprites[lstsprites.itemindex]).id := spnid.Value;

end;

procedure TfrmSpriteSettings.chkShowToyboxClick(Sender: TObject);
begin
  if not ignoreupdate then
    if chkShowToybox.Checked then
      tspriterc(spritercdecoder.sprites[lstsprites.itemindex]).avail := 3 else
      tspriterc(spritercdecoder.sprites[lstsprites.itemindex]).avail := 0;
end;

procedure TfrmSpriteSettings.btnSaveClick(Sender: TObject);
var update: cardinal;
  stream: tmemorystream;
begin
  try
    update := BeginUpdateResourceW(pwidechar(widestring(filename)), false);
    try
      stream := tmemorystream.create;
      try
        spritercdecoder.encode(stream);
        UpdateResourceW(update, pwidechar(rt_rcdata), pwidechar(1003), 1033, stream.memory, stream.size);
      finally
        stream.free;
      end;
    finally
      EndUpdateResourceW(update, false);
    end;
  except
    showmessage('There was a problem writing to the file');
    raise;
  end;
end;


end.
