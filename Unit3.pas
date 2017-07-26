unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  labels: array[1..4,1..10] of TLabel;
const labelsLength=48;

implementation
uses U_Saper;
{$R *.dfm}

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  form1.CheckBox1.Checked:=false;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  Top:=form1.Top;
  if form1.Left-250<0
  then left:=0
  else left:=form1.Left-250;
  //height:=500;
  //width:=225;
end;

procedure TForm3.CheckBox1Click(Sender: TObject);
begin
  memo1.Visible:=checkBox1.Checked;
  if checkBox1.Checked
  then height:=memo1.Top+memo1.Height+26
  else height:=memo1.Top+24;
end;

procedure TForm3.FormCreate(Sender: TObject);
  var i,j: integer;
begin
  for i:=1 to 4
  do for j:=1 to 10
     do begin
        labels[i,j]:=TLabel.Create(GroupBox1);
        labels[i,j].Parent:=GroupBox1;
        labels[i,j].Height:=13;
        labels[i,j].Width:=0;
        labels[i,j].Top:=j*16-4;
        labels[i,j].Left:=(i-1)*48+8;
        //labels[i,j].Caption:=inttostr(i)+'-'+inttostr(j);
        end;
end;

end.
