unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Menus;

type
  TSettingsForm = class(TForm)
    btnYes: TBitBtn;
    lbledtPath: TLabeledEdit;
    btnChoose: TButton;
    dlgSave: TSaveDialog;
    trnMain: TTrayIcon;
    pmMain: TPopupMenu;
    PtrSc1: TMenuItem;
    N1: TMenuItem;
    S1: TMenuItem;
    A1: TMenuItem;
    N2: TMenuItem;
    Q1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure btnChooseClick(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure PrintScreen(Sender: TObject);
    procedure S1Click(Sender: TObject);
    procedure A1Click(Sender: TObject);
    procedure Q1Click(Sender: TObject);
  private
    { Private declarations }
    procedure HotKay(var Msg: TMessage); message WM_HOTKEY;
  public
    { Public declarations }
    SavePath: string;
    procedure ShowHint(const ATitle, AHint: string; const AFlag: TBalloonFlags = bfNone);
    function GetFileName: string;
  end;

var
  SettingsForm: TSettingsForm;

implementation

uses
  jpeg, superobject;
{$R *.dfm}

function CharReplace(const S: string; const OldChar, NewChar: Char): string;
var
  c: Char;
begin
  Result := '';
  for c in S do
    if c = OldChar then
      Result := Result + NewChar
    else
      Result := Result + c;
end;

procedure TSettingsForm.A1Click(Sender: TObject);
begin
  ShowHint('关于',
    '本程序由:'#10#13'百度 @aaa5555554，'#10#13'CnBlog @灵悦，'#10#13'QQ @忘忧·北萱草'#10#13'制作(虽然都是同一个人)',
    bfInfo);
end;

procedure TSettingsForm.btnChooseClick(Sender: TObject);
begin
  if dlgSave.Execute then
  begin
    SavePath := ExtractFileDir(dlgSave.FileName);
    lbledtPath.Text := SavePath;
    dlgSave.InitialDir := SavePath;
  end;
  ChDir(ExtractFileDir(ParamStr(0))); // SaveDialog会改变当前文件夹,强行改回来
end;

procedure TSettingsForm.btnYesClick(Sender: TObject);
begin
  Hide;
end;

procedure TSettingsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Config: ISuperObject;
begin
  // 释放热键
  UnregisterHotKey(Handle, 115);
  // 保存配置文件
  Config := TSuperObject.ParseFile('Config.json', False);
  Config.S['SavePath'] := CharReplace(SavePath, '\', '/'); // 使用 / 代替 \ 以避免转义
  Config.SaveTo('Config.json');
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
var
  Config: ISuperObject;
begin
  // 加载配置文件
  if not FileExists('Config.json') then
    SO('{"SavePath":"C:/PtrScreen"}').SaveTo('Config.json'); // 使用 / 代替 \ 以避免转义
  Config := TSuperObject.ParseFile('Config.json', False);
  SavePath := CharReplace(Config.S['SavePath'], '/', '\');
  lbledtPath.Text := SavePath;
  dlgSave.InitialDir := SavePath;
  //注册热键
  RegisterHotKey(Handle, 115, 0, VK_SNAPSHOT);
  // 显示气泡
  ShowHint('提示', '加载成功');
end;

function TSettingsForm.GetFileName: string;
var
  i: Integer;
begin
  if not DirectoryExists(SavePath) then
    if not ForceDirectories(SavePath) then
      raise Exception.Create('创建目录失败!');
  for i := 1 to MaxInt do
  begin
    Result := SavePath + '\' + 'Delphi截图_' + IntToStr(i) + '.jpg';
    if not FileExists(Result) then // 如果找到可用的文件名
      Exit;
  end;
  // 如果从1到2147483647都被占用(好恐怖的样子)
  Result := '';
  raise Exception.Create('文件夹已满!');
end;

procedure TSettingsForm.HotKay(var Msg: TMessage);
begin
  if Msg.LParamHi = VK_SNAPSHOT then
    PrintScreen(Self);
end;

procedure TSettingsForm.PrintScreen(Sender: TObject);
var
  ScCanvas: TCanvas;
  DC: HDC;
  ScRect: TRect;
  JPG: TJPEGImage;
  BMP: TBitmap;
begin
  try
    ScCanvas := TCanvas.Create;
    DC := GetDC(0); // 屏幕的DC是0
    ScCanvas.Handle := DC;
    ScRect := Rect(0, 0, Screen.Width, Screen.Height);
    BMP := TBitmap.Create;
    BMP.Width := Screen.Width;
    BMP.Height := Screen.Height;
    BMP.Canvas.CopyRect(ScRect, ScCanvas, ScRect);
    JPG := TJPEGImage.Create;
    JPG.Assign(BMP);
    JPG.SaveToFile(GetFileName);
    ShowHint('提示', '截图成功!');
  finally
    ScCanvas.Free; // Canvas在析构时不会释放DC
    ReleaseDC(0, DC);
    JPG.Free;
  end;
end;

procedure TSettingsForm.Q1Click(Sender: TObject);
begin
  Close;
end;

procedure TSettingsForm.S1Click(Sender: TObject);
begin
  Show;
end;

procedure TSettingsForm.ShowHint(const ATitle, AHint: string; const AFlag:
  TBalloonFlags = bfNone);
begin
  with trnMain do
  begin
    BalloonTitle := ATitle;
    BalloonHint := AHint;
    BalloonFlags := AFlag;
    ShowBalloonHint;
  end;
end;

end.

