unit pfstestunit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, pfs,
  StdCtrls, VirtualTrees,pathparser,pfsdirdevice,pfsresdevice;

type


  TForm1 = class(TForm)
    btnMount: TButton;
    vstFS: TVirtualStringTree;
    mmo1: TMemo;
    btnLoad: TButton;
    btnParsepath: TButton;
    procedure btnMountClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure vstFSGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure vstFSInitChildren(Sender: TBaseVirtualTree;
      Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstFSInitNode(Sender: TBaseVirtualTree; ParentNode,
      Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure vstFSChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btnLoadClick(Sender: TObject);
    procedure btnParsepathClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.btnMountClick(Sender: TObject);
var device: IPFSDevice;
begin
  device := tpfsdirdevice.create('C:\temp');
  gpfs.Mount(device, '\files');

  device := tpfsresdevice.create('c:\temp\emptydll.dll');
  gpfs.Mount(device, '\files');

//  vstFs.RootNodeCount := gpfs.count;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  gpfs := TPFS.create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  gpfs.free;
end;

(*function nodetoitem(tree: TBaseVirtualTree; node: PVirtualNode): TPFSItem;
var indexes: array of integer;
  t1: integer;
  n: PVirtualNode;
begin
  setlength(indexes, tree.getnodelevel(node) + 1);
  n := node;
  for t1 := high(indexes) downto 0 do begin
    indexes[t1] := n.index;
    n := n.parent;
  end;

//now find our item
  result := gpfs;
  for t1 := 0 to high(indexes) do
    result := TPFSFolder(result)[indexes[t1]];
end;                  *)

procedure TForm1.vstFSGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
//var item: TPFSItem;
begin
//  item := nodetoitem(sender, node);

//  celltext := item.name;
end;

procedure TForm1.vstFSInitChildren(Sender: TBaseVirtualTree;
  Node: PVirtualNode; var ChildCount: Cardinal);
//var item: TPFSItem;
begin
{  item := nodetoitem(sender, node);

  if item is TPFSFolder then
    childcount := tpfsfolder(item).count else
    childcount := 0;}
end;

procedure TForm1.vstFSInitNode(Sender: TBaseVirtualTree; ParentNode,
  Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
//var item: TPFSItem;
begin
{  item := nodetoitem(sender, node);

  if item is TPFSFolder then
    initialstates := initialstates + [ivshaschildren];}
end;

procedure TForm1.vstFSChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
(*var f: TPFSFile;
  stream: tmemorystream;*)
begin
(*  if node = nil then exit;
  if nodetoitem(sender, node) is TPFSFile then begin
    f := TPFSFile(nodetoitem(sender, node));
    stream := tmemorystream.create;
    try
      f.savetostream(stream);
      stream.seek(0, sofrombeginning);
      mmo1.lines.loadfromstream(stream);
    finally
      stream.free;
    end;
  end;   *)
end;

procedure TForm1.btnLoadClick(Sender: TObject);
var stream: tmemorystream;
begin
{  stream := tmemorystream.create;
  try
    gPFS.Findfile('\files\test.txt').savetostream(stream);
    stream.seek(0,sofrombeginning);
    mmo1.lines.loadfromstream(stream);
  finally
    stream.free;
  end;}
end;

procedure TForm1.btnParsepathClick(Sender: TObject);
begin
gpfs.diagdump(mmo1.lines);
end;

end.

