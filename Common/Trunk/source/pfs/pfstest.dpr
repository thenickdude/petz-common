program pfstest;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  pfstestunit in 'pfstestunit.pas' {Form1},
  pfs in 'pfs.pas',
  pathparser in 'pathparser.pas',
  pfsdirdevice in 'pfsdirdevice.pas',
  pfsresdevice in 'pfsresdevice.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
