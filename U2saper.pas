unit U2saper;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, ComCtrls;

type
  TForm2 = class(TForm)
    ButtonOk: TButton;
    ButtonCansel: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    PageControl1: TPageControl;
    TabSheet0: TTabSheet;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    TabSheet9: TTabSheet;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    GroupBox3: TGroupBox;
    SpinEditH: TSpinEdit;
    SpinEditL: TSpinEdit;
    SpinEditMine: TSpinEdit;
    Label1: TLabel;
    RadioGroup1: TRadioGroup;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    CheckBox4: TCheckBox;
    CheckBox3: TCheckBox;
    RadioButton5: TRadioButton;
    SpinEditPercent: TSpinEdit;
    Label4: TLabel;
    LabelErr: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    procedure ButtonCanselClick(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure SpinEditPercentChange(Sender: TObject);
    procedure SpinEditMineChange(Sender: TObject);
    procedure SpinEditHChange(Sender: TObject);
    procedure SpinEditLChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}
uses U_saper;

var h0,l0,KolvoMin: integer;
    AutomaticMode: TAutomaticMode;
    MyStack,ShowAutomatic,ProtectFlags,vShirElseVglub: boolean;
    Gamers: TInterfaceIgrs;

var sinhro: boolean;
    ActiveMine: boolean;

//будем считать, что параметры, уже укстановленные в игре не противоречивы
//Начальные координаты мышки не имеют значения
procedure TForm2.FormShow(Sender: TObject);
begin
  sinhro:=true;
  GetSettings(h0,l0,KolvoMin,AutomaticMode,
              MyStack,
              ShowAutomatic,
              ProtectFlags,
              vShirElseVglub,
              Gamers);
  spinEditH.MinValue:=2;
  spinEditL.MinValue:=2;
  SpinEditH.MaxValue:=U_Saper.Hmax;
  SpinEditL.MaxValue:=U_Saper.Lmax;
  SpinEditH.Value:=h0;
  SpinEditL.Value:=l0;

  SpinEditMine.MinValue:=1;
  //SpinEditMine.MaxValue:=h0*l0-1; - автоматически
  SpinEditMine.Value:=KolvoMin;
//     TAutomaticMode=(amAllYouSelf,amAuto0,amAuto0andFlag,amAutoOpen,amAutoAllSimple);
  case AutomaticMode
  of amAllYouSelf   :RadioButton1.Checked:=true;
     amAuto0        :RadioButton2.Checked:=true;
     amAuto0andFlag :RadioButton5.Checked:=true;
     amAutoOpen     :RadioButton3.Checked:=true;
     amAutoAllSimple:RadioButton4.Checked:=true;
  end;
  LabelErr.Caption:='';
end;

procedure TForm2.ButtonOkClick(Sender: TObject);
  var ErrS: string;
begin
  if CheckSettings(SpinEditH.Value,SpinEditL.Value,SpinEditMine.Value,Gamers,ErrS)
  then begin
       if RadioButton1.Checked
       then AutomaticMode:=amAllYouSelf;
       if RadioButton2.Checked
       then AutomaticMode:=amAuto0;
       if RadioButton5.Checked
       then AutomaticMode:=amAuto0andFlag;
       if RadioButton3.Checked
       then AutomaticMode:=amAutoOpen;
       if RadioButton4.Checked
       then AutomaticMode:=amAutoAllSimple;

       ProtectFlags:=CheckBox4.Checked;
       MyStack:=CheckBox1.Checked;
       ShowAutomatic:=CheckBox2.Checked;
       vShirElseVglub:=CheckBox3.Checked;

       SetSettings(SpinEditH.Value,SpinEditL.Value,SpinEditMine.Value,AutomaticMode,
              MyStack,
              ShowAutomatic,
              ProtectFlags,
              vShirElseVglub,
              Gamers);
       close;
       Form1.ButtonRestartClick(Sender);
       end
  else LabelErr.Caption:=ErrS;
end;

procedure TForm2.ButtonCanselClick(Sender: TObject);
begin
  close;
end;


procedure TForm2.SpinEditPercentChange(Sender: TObject);
  var x,e: integer;
      s: string;
begin
  if sinhro
  then begin
       sinhro:=false;
       SpinEditMine.MaxValue:=SpinEditH.Value*SpinEditL.Value-1;
       if length(SpinEditPercent.Text)>9
       then begin
            s:=SpinEditPercent.Text;
            delete(s,9,1);
            SpinEditPercent.Text:=s;
            end;
       val(SpinEditPercent.Text,x,e);
       if (x>=SpinEditPercent.MinValue)and(x<=SpinEditPercent.MaxValue)and(e=0)
       then SpinEditMine.Value:=trunc(SpinEditH.Value*SpinEditL.Value*x/100);
       ActiveMine:=false;
       sinhro:=true;
       end;
end;

procedure TForm2.SpinEditMineChange(Sender: TObject);
  var x,e: integer;
      s: string;
begin
  if sinhro
  then begin
       sinhro:=false;
       SpinEditMine.MaxValue:=SpinEditH.Value*SpinEditL.Value-1;
       if length(SpinEditMine.Text)>9
       then begin
            s:=SpinEditMine.Text;
            delete(s,9,1);
            SpinEditMine.Text:=s;
            end;
       val(SpinEditMine.Text,x,e);
       if (x>=SpinEditMine.MinValue)and(x<=SpinEditMine.MaxValue)and(e=0)
       then SpinEditPercent.Value:=trunc(x/(SpinEditH.Value*SpinEditL.Value)*100);
       ActiveMine:=true;
       sinhro:=true;
       end;
end;

procedure TForm2.SpinEditHChange(Sender: TObject);
  var x,e: integer;
      s: string;
begin
  if length(SpinEditH.Text)>9
  then begin
       s:=SpinEditH.Text;
       delete(s,9,1);
       SpinEditH.Text:=s;
       end;
  val(SpinEditH.Text,x,e);
  if (x>=SpinEditH.MinValue)and(x<=SpinEditH.MaxValue)and(e=0)
  then begin
       if ActiveMine
       then SpinEditMineChange(Sender)
       else SpinEditPercentChange(Sender);
       SpinEditMine.MaxValue:=x*spinEditL.Value-1;
       if SpinEditMine.Value>SpinEditMine.MaxValue
       then SpinEditMine.Value:=SpinEditMine.MaxValue;
       end;
end;

procedure TForm2.SpinEditLChange(Sender: TObject);
  var x,e: integer;
      s: string;
begin
  if length(SpinEditL.Text)>9
  then begin
       s:=SpinEditL.Text;
       delete(s,9,1);
       SpinEditL.Text:=s;
       end;
  val(SpinEditL.Text,x,e);
  if (x>=SpinEditL.MinValue)and(x<=SpinEditL.MaxValue)and(e=0)
  then begin
       if ActiveMine
       then SpinEditMineChange(Sender)
       else SpinEditPercentChange(Sender);
       SpinEditMine.MaxValue:=x*spinEditH.Value-1;
       if SpinEditMine.Value>SpinEditMine.MaxValue
       then SpinEditMine.Value:=SpinEditMine.MaxValue;
       end;
end;

end.




