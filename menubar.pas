unit menubar;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ComCtrls, Menus;

type
  TMenuBar = class(TToolBar)
  private
    FMenu: TMainMenu;
    procedure SetMenu(const Value: TMainMenu);
    function HandleAppKeyDown(var Message: TWMKey): Boolean;
    procedure CMDialogKey(var Message: TWMKey); message CM_DIALOGKEY;
  protected
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Flat default True;
    property ShowCaptions default True;
    property EdgeBorders default [];
    property Menu: TMainMenu read FMenu write SetMenu;
  end;

procedure Register;

implementation

uses
  Forms;

procedure Register;
begin
  RegisterComponents('Samples', [TMenuBar]);
end;

{ TMenuBar }

procedure TMenuBar.CMDialogKey(var Message: TWMKey);
begin
  if not HandleAppKeyDown(Message) then inherited;
end;

constructor TMenuBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Flat := True;
  ShowCaptions := True;
  EdgeBorders := [];
  ControlStyle := [csCaptureMouse, csClickEvents,
    csDoubleClicks, csMenuEvents, csSetCaption];
end;

procedure TMenuBar.GetChildren(Proc: TGetChildProc; Root: TComponent);
begin
end;

function TMenuBar.HandleAppKeyDown(var Message: TWMKey): Boolean;
begin
  if Assigned(Menu) and Menu.IsShortCut(Message) then
  begin
    Message.Result := 1;
    Result := True;
  end
  else
    Result := False;
end;

procedure TMenuBar.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (AComponent = FMenu) and (Operation = opRemove) then
  begin
    SetMenu(nil);
  end;
  inherited;
end;

procedure TMenuBar.SetMenu(const Value: TMainMenu);
var
  i: Integer;
  Button: TToolButton;
begin
  if FMenu = Value then exit;
  if ButtonCount > 0 then
    for i := Pred(ButtonCount) downto 0 do
      Buttons[i].Free;
  FMenu := Value;
  if not Assigned(FMenu) then exit;
  for i := ButtonCount to Pred(FMenu.Items.Count) do
  begin
    Button := TToolButton.Create(Self);
    try
      Button.AutoSize := True;
      Button.Grouped := True;
      Button.Parent := Self;
      Buttons[i].MenuItem := FMenu.Items[i];
    except
      Button.Free;
      raise;
    end;
  end;
  { Copy attributes from each menu item }
  for i := 0 to Pred(FMenu.Items.Count) do
    Buttons[i].MenuItem := FMenu.Items[i];
end;

end.
