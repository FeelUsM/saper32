program P_saper;

uses
  Forms,
  U_saper in 'U_saper.pas' {Form1},
  U2saper in 'U2saper.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  ULogo in 'ULogo.pas' {Logo};

{$R *.res}
  //(c)������ ����� fel1992@mail.ru
begin
  Application.Initialize;
  Application.Title := 'SaperPro';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TLogo, Logo);
  InitSaper;
  Application.Run;

(*
interface//*********************************************************************
procedure InitSaper;
const hmax=1024;    lmax=1024;
const noIgr=16-1; //- � ���������� �� �����, �� ����� ���� ������������ maxKolvoIgr
      maxKolvoIgr=noIgr-1;
      mouseIgr=0;//-(������� 24.04.11)����� ��������, ����� �������� ��������
type TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude);
     TAutomaticMode=(amAllYouSelf,amAuto0,amAuto0andFlag,amAutoOpen,amAutoAllSimple);
     TKeys=record     Up,Down,Left,Right,Open,Flag: word;     end;
     TInterfaceIgrs=array[0..maxKolvoIgr]of
        record  x,y: integer; inputMode: TinputMode; Exist: boolean; keys: TKeys; name: string; end;
procedure GetSettings(var Lh0,Ll0,LKolvoMin: integer; var LAutomaticMode: TAutomaticMode;
              var LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              var Gamers: TInterfaceIgrs);
function CheckSettings(Lh0,Ll0,LKolvoMin: integer;
              const Gamers: TInterfaceIgrs; var s: string): boolean;
procedure SetSettings(Lh0,Ll0,LKolvoMin: integer; LAutomaticMode: TAutomaticMode;
              LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              const Gamers: TInterfaceIgrs);
implementation//****************************************************************
//---------------����������-------------
{$define dbgBase}
{$define dbgOut}
{$define dbgIn}

//{$define begin_End}                                 //������� ������ � ������ � ����������
                                                      //������� �������� � ������ ������
{$define dbgOnLine}
//{$define logSysEvents}
//log out0   (~513)
//log OutCurs(3��)(���-��)
//------------���������-�����������-------------
function minim(a,b: integer): integer;
function max(a,b: integer): integer;
function booltoStr(x: boolean):string;
//procedure delay(x: integer);       //����������� �� ������������
//---------------����������-----------------
procedure error(s: string);
procedure log(s: string);
  {$ifdef Begin_End}������� ������� ������ ������� ���������{$endif}
{$ifdef dbgonline}
forward; procedure dbgOnLine;
forward; procedure onlineDbgOut0(x,y: integer);
forward; procedure OnlineDbgFormPaint;
forward; procedure onlineDBGOutCurs(lx,ly: integer);
{$endif}
//------------��������-����������---------------{$ifdef begin_end}
//{$define LogOfDBG}      //������� ������� =)
procedure beginDBG(s: string);                     //������� ���� ����������
procedure endDBG(s: string);
procedure checkBeginEnd(x: Tobject; s: string);
//~~~~��� ������������� �������� form1.memo2~~~~
//==============================================================================
//--------���� ������--------------------
var GameMode: TGameMode;       type TGameMode=(gmStart,gmGame,gmFinish);
type Tkletka=record    num,   otv: byte;      end;
const cfNop  =9 ; cfFlag =10; cfFalseFlag=11; cfMine =12; cfLastMine=13; cfOther=14;
//const hmax=1024;  lmax=1024; - interface
var pole: array[1..lmax,1..hmax] of Tkletka;//����� ������ � _;-? �������� � �����: � ����, ������������� � ������
    h0,l0: integer;      //������� ����  //����� �����, �������� ������ � "������������� � ������"

function tInPole(x,y: integer; s: string):boolean;//������-�����������
{$ifdef dbgBase}
    forward;    function goodIgr(n: byte; noIgrIsGood: boolean; s: string): boolean; //���������-�����������
    forward;    function existIgr(n: byte; noIgrIsGood: boolean; s: string): boolean;//���������-�����������
{$endif}

function GetMina(x,y: integer): boolean;
function GetCifra(x,y: integer): byte;
function GetAutor(x,y: integer): byte;
function GetCursor(x,y: integer): byte;

procedure SetMina(x,y: integer; m: boolean);
procedure SetCifra(x,y: integer; z: byte);
procedure SetAutor(x,y: integer; z: byte);
procedure SetCursor(x,y: integer; z: byte);

function PoleIsOpen(x,y: integer): boolean;
//~~~~���������������� pole,h0,l0~~~~
//------------around-------------------------------------------
type kldetect  =function (x,y: integer)  :  boolean;
     kldoing   =procedure(x,y: integer;     data: byte);
     kldoingVar=procedure(x,y: integer; var data: byte);
procedure aroundKl(x,y: integer; data: byte; detect: kldetect; doing: kldoing);
procedure aroundKlvar(x,y: integer; var data: byte; detect: kldetect; doing: kldoingVar);
function All(x,y: integer): boolean;
const NoVar=0;
//~~~~���������������� �� ���� - ������ �������� �������~~~~
//==============================================================================
//----------------������-�������------------------------------------------------
type
     TIgrok=record
            //�������
            Mode: TModeIgr;
                          TModeIgr=(miIsDead,miInGame,miNotExist);//Exist - ���������� (��� ������ =) (24.04.11))
            //�����
            x,y: integer;  //���������� ������� � ������ ��������
            Outing: TOutingMode; //���������� ������� � ������ ��������
                          TOutingMode=(omSimple,omPressed,omSuperPressed);
            isMouse: boolean; //virtual
            //����
            InputMode: TInputMode;
                          TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude); - interface
            PressedOpenKey,PressedFlagKey: boolean;
            keys: TKeys;//�� ��� ����
                          TKeys=record  Up,Down,Left,Right,Open,Flag: word;  end; //-interface
            presseds: TPressedKeys;
                          TPressedKeys=set of(pkUp,pkDown,pkLeft,pkRight,pkOpen,pkFlag,pkMiddle);
            //����
            name: string;//������������ ������ � ����
            end;
//const noIgr=16-1;
//      maxKolvoIgr=noIgr-1; - interface
//      mouseIgr=0;
var Igr: array[0..maxKolvoIgr]of TIgrok;//0 - ����, ��������� - �����

function goodIgr(n: byte; noIgrIsGood: boolean ; s: string): boolean; //���������-�����������
function existIgr(n: byte; noIgrIsGood: boolean; s: string): boolean;//���������-�����������
//~~~~���������������� - ��� ����������, � ������������~~~~
//-------------�����-------------------------------------
var scrh,scrl: integer;  //������ � ReSetScrSize
    scrx,scry: integer;  //SetScrPosition, ������ � ReSetScrSize, ScrollBarG/VChange, ���������� ������������� (� ������?)
const otst=2;       //����� ����� ����������
      otstPixDown=45+20; otstPixR=26+20;    //�������� width->ClientWidth
var otstPixL,otstPixUp: integer;//��������� ���������, ����...???
    ImageSize: integer=16;   PixelPainting: boolean=false;   //...

function tInScr(x,y: integer):boolean; //������ ��������� �� scrh,scrl, scrx,scry
/////////////////////////////�����������//
procedure paintKl(x,y: integer; data: byte);
//���������� outing �����. ������
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

procedure paintKlpr(x,y: integer; data: byte);//x,y - � ����������� ����
//paintKl + tInScr
procedure RePaintScr;
//�������������� ����� + OnlineDbgRePaint;
procedure SetScrPosition(lscrx,lscry: integer);
//��������� ������������, ���� ���� - ������ ������� ������, � �������������� �����
procedure ReSetScrSize;
//���� ���� ������ ��������� ��������� sScrollBar'�� � �������������� �����, ������� ������
//�������� ��� ���������  h0,l0, ImageSize,  �������� �����

procedure TForm1.ScrollBarGChange(Sender: TObject);
procedure TForm1.ScrollBarVChange(Sender: TObject);
//�������� �������� scrx,scry , �������������� �����
procedure TForm1.FormPaint(Sender: TObject);//interface
//<=>RePaintScr
procedure TForm1.FormResize(Sender: TObject);//use onli for formResize(sys events)
//����������� ������������ ������� �����, �������� ������� ������ � LabelTime, ReSetScrSize
//~~~~??? ~~~~
//  - - - - - - - - - - - -��������� �������� - - - - - - - - - - - - - - - -\\
//private - ���������� ����������(������ �� ������� ���������) � �������
  //, ������������ OutCurs � eraseCurs
  var ochered: array[0..maxKolvoIgr]of byte;  //0-� ����� - ����
  procedure IgrNaVerh(n: byte);//n-�����
  function CursInScr(x,y: integer): boolean; //interface
  var formRepaint: boolean; OutPoint: byte;
      ChengedKl: array[1..16*9]of record x,y: integer; past,futur: byte; end;
  procedure vPaintCurs(x,y: integer; n: byte);
//public
procedure OutCurs(lx,ly: integer; outingMode: TOutingMode; n: byte; maskRepaint: boolean); //interface
procedure eraseCurs(n: byte);
//\\  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
var ShowAutomatic: boolean;

function AutomaticInScr(x,y: integer): boolean;




//�������� width->ClientWidth
// � height





{$define dbgKernel}
//{$define LogKernel}
//type TAutomaticMode=(amAllYouSelf,amAuto0,amAuto0andFlag,amAutoOpen,amAutoAllSimple); - interface
var autoMaticMode: TAutomaticMode;    {����� ����������}
    KolvoMin,km: integer;{���������� ��� �� ����(��������� � ������� ����)}
                         {km=kolvomin-���������� �������;- ������� �������� ���}
    kl,nopkl: integer;  {���������� (����� � ����������) ������ �� �����������
                          ���������� ���;}
    MyStack,ProtectFlags,VShirElseVGlub: boolean;
procedure SetCA(x,y: integer; c,a: byte);             //���������������� �������

//������ �������
function canBeOpen(x,y: integer): boolean;
function isFlag(x,y: integer): boolean;
function notIsOpen(x,y: integer): boolean;

procedure incz(x,y: integer; var z: byte);          //����� ������������ ��� ��������
procedure CheckWin(otv: byte);
procedure detonation        (x,y: integer; otv: byte);
forward; procedure autoFlag (x,y: integer; otv: byte);
forward; procedure autoOpen (x,y: integer; otv: byte);
forward; procedure auto0    (x,y: integer; otv: byte);
procedure automatic         (x,y: integer; otv: byte);
procedure VirtualAutomatic  (x,y: integer; otv: byte);
procedure PutOnFlag         (x,y: integer; otv: byte);
procedure open              (x,y: integer; otv: byte);
procedure autoFlag          (x,y: integer; otv: byte);
procedure autoOpen          (x,y: integer; otv: byte);
procedure auto0             (x,y: integer; otv: byte);
procedure initPole(otv: byte);//������� ���
procedure GameEvent(x,y: integer; otv: byte; PressK1: boolean);
//case GameMode
//if myStack
//if StackOwerFlow
//==============================================================================
//-------------������������� � ����������� �� ������� �������-----------------------------
{$ifdef DBGOnline} forward; procedure InitDBGOnline(repaint: boolean);
procedure TForm1.Button2Click(Sender: TObject);//������� ����� ������
  //��������� ����������!!!
procedure TForm1.Button1Click(Sender: TObject);  //���������
procedure TForm1.ButtonRestartClick(Sender: TObject);
  //��������� ��������� �������� ����
//- - - - - - - - - - - - - - - interface- - - - - - - - - - - - - - - - - - - -
{     TInterfaceIgrs=array[0..maxKolvoIgr]of record
                                           x,y: integer;
                                           inputMode: TinputMode;
                                           Exist: boolean;
                                           keys: TKeys;
                                           name: string;
                                           end;} //- �����������
procedure GetSettings(var Lh0,Ll0,LKolvoMin: integer; var LAutomaticMode: TAutomaticMode;
              var LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              var Gamers: TInterfaceIgrs);
function CheckSettings(Lh0,Ll0,LKolvoMin: integer;
              const Gamers: TInterfaceIgrs; var s: string): boolean;  //true - OK
procedure SetSettings(Lh0,Ll0,LKolvoMin: integer; LAutomaticMode: TAutomaticMode;
              LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              const Gamers: TInterfaceIgrs);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//TForm1.FormCreate(Sender: TObject);
procedure TForm1.FormShow(Sender: TObject);
//����� logo
procedure InitSaper;//sysEvents
{ randomize;
  OtstPixUp:=60;  OtstPixL:=25;//96;
  SetSettings
  form1.ButtonRestartClick(obj);
}
//--------------------------DBGonline--------------------------------------
procedure TForm1.CheckBox1Click(Sender: TObject);
//��������/������ ����������
{$ifdef DBGOnline}
var dbgcount: integer;
    RepaintOn: boolean;
procedure DBGOnLine;
//repaint'� labels'�� �������� ���
//repaint'� ����� ����� ���������� "�������" � ��� mouseMove
//��������� ��������� �� ��� �� ������, ����� ����� ������
//� ��������� � mouseMove
var countRePaint,countOut0: integer;
procedure OnlineDbgRePaint;
procedure onlineDBGOutCurs(lx,ly: integer);
procedure InitDBGOnline(repaint: boolean);
{$endif}

*)
end.

