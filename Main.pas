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
  ShowHint('����',
    '��������:'#10#13'�ٶ� @aaa5555554��'#10#13'CnBlog @���ã�'#10#13'QQ @���ǡ������'#10#13'����(��Ȼ����ͬһ����)',
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
  ChDir(ExtractFileDir(ParamStr(0))); // SaveDialog��ı䵱ǰ�ļ���,ǿ�иĻ���
end;

procedure TSettingsForm.btnYesClick(Sender: TObject);
begin
  Hide;
end;

procedure TSettingsForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Config: ISuperObject;
begin
  // �ͷ��ȼ�
  UnregisterHotKey(Handle, 115);
  // ���������ļ�
  Config := TSuperObject.ParseFile('Config.json', False);
  Config.S['SavePath'] := CharReplace(SavePath, '\', '/'); // ʹ�� / ���� \ �Ա���ת��
  Config.SaveTo('Config.json');
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
var
  Config: ISuperObject;
begin
  // ���������ļ�
  if not FileExists('Config.json') then
    SO('{"SavePath":"C:/PtrScreen"}').SaveTo('Config.json'); // ʹ�� / ���� \ �Ա���ת��
  Config := TSuperObject.ParseFile('Config.json', False);
  SavePath := CharReplace(Config.S['SavePath'], '/', '\');
  lbledtPath.Text := SavePath;
  dlgSave.InitialDir := SavePath;
  //ע���ȼ�
  RegisterHotKey(Handle, 115, 0, VK_SNAPSHOT);
  // ��ʾ����
  ShowHint('��ʾ', '���سɹ�');
end;

function TSettingsForm.GetFileName: string;
var
  i: Integer;
begin
  if not DirectoryExists(SavePath) then
    if not ForceDirectories(SavePath) then
      raise Exception.Create('����Ŀ¼ʧ��!');
  for i := 1 to MaxInt do
  begin
    Result := SavePath + '\' + 'Delphi��ͼ_' + IntToStr(i) + '.jpg';
    if not FileExists(Result) then // ����ҵ����õ��ļ���
      Exit;
  end;
  // �����1��2147483647����ռ��(�ÿֲ�������)
  Result := '';
  raise Exception.Create('�ļ�������!');
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
    DC := GetDC(0); // ��Ļ��DC��0
    ScCanvas.Handle := DC;
    ScRect := Rect(0, 0, Screen.Width, Screen.Height);
    BMP := TBitmap.Create;
    BMP.Width := Screen.Width;
    BMP.Height := Screen.Height;
    BMP.Canvas.CopyRect(ScRect, ScCanvas, ScRect);
    JPG := TJPEGImage.Create;
    JPG.Assign(BMP);
    JPG.SaveToFile(GetFileName);
    ShowHint('��ʾ', '��ͼ�ɹ�!');
  finally
    ScCanvas.Free; // Canvas������ʱ�����ͷ�DC
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

