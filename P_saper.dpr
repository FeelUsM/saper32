program P_saper;

uses
  Forms,
  U_saper in 'U_saper.pas' {Form1},
  U2saper in 'U2saper.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  ULogo in 'ULogo.pas' {Logo};

{$R *.res}
  //(c)Филипп Усков fel1992@mail.ru
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
const noIgr=16-1; //- в интерфейсе не нужен, но через него определяется maxKolvoIgr
      maxKolvoIgr=noIgr-1;
      mouseIgr=0;//-(создана 24.04.11)везде заменить, потом изменить значение
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
//---------------управление-------------
{$define dbgBase}
{$define dbgOut}
{$define dbgIn}

//{$define begin_End}                                 //сделать только в выводе и отдебагить
                                                      //сделать отдельно в других местах
{$define dbgOnLine}
//{$define logSysEvents}
//log out0   (~513)
//log OutCurs(3шт)(где-то)
//------------глобально-примитивные-------------
function minim(a,b: integer): integer;
function max(a,b: integer): integer;
function booltoStr(x: boolean):string;
//procedure delay(x: integer);       //практически не используется
//---------------отладочные-----------------
procedure error(s: string);
procedure log(s: string);
  {$ifdef Begin_End}выводят историю откуда вызвана процедура{$endif}
{$ifdef dbgonline}
forward; procedure dbgOnLine;
forward; procedure onlineDbgOut0(x,y: integer);
forward; procedure OnlineDbgFormPaint;
forward; procedure onlineDBGOutCurs(lx,ly: integer);
{$endif}
//------------поисково-отладочные---------------{$ifdef begin_end}
//{$define LogOfDBG}      //отладка отладки =)
procedure beginDBG(s: string);                     //сделать ввод параметров
procedure endDBG(s: string);
procedure checkBeginEnd(x: Tobject; s: string);
//~~~~при инициализации очистить form1.memo2~~~~
//==============================================================================
//--------база сапера--------------------
var GameMode: TGameMode;       type TGameMode=(gmStart,gmGame,gmFinish);
type Tkletka=record    num,   otv: byte;      end;
const cfNop  =9 ; cfFlag =10; cfFalseFlag=11; cfMine =12; cfLastMine=13; cfOther=14;
//const hmax=1024;  lmax=1024; - interface
var pole: array[1..lmax,1..hmax] of Tkletka;//видны выводу в _;-? меняется и видны: в ядре, инициализации и прочем
    h0,l0: integer;      //размеры поля  //видны везде, меняются только в "инициализации и прочем"

function tInPole(x,y: integer; s: string):boolean;//отладо-проверочная
{$ifdef dbgBase}
    forward;    function goodIgr(n: byte; noIgrIsGood: boolean; s: string): boolean; //отладочно-проверочная
    forward;    function existIgr(n: byte; noIgrIsGood: boolean; s: string): boolean;//отладочно-проверочная
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
//~~~~инициализировать pole,h0,l0~~~~
//------------around-------------------------------------------
type kldetect  =function (x,y: integer)  :  boolean;
     kldoing   =procedure(x,y: integer;     data: byte);
     kldoingVar=procedure(x,y: integer; var data: byte);
procedure aroundKl(x,y: integer; data: byte; detect: kldetect; doing: kldoing);
procedure aroundKlvar(x,y: integer; var data: byte; detect: kldetect; doing: kldoingVar);
function All(x,y: integer): boolean;
const NoVar=0;
//~~~~инициализировать не надо - просто полезные функции~~~~
//==============================================================================
//----------------игроки-курсоры------------------------------------------------
type
     TIgrok=record
            //базовая
            Mode: TModeIgr;
                          TModeIgr=(miIsDead,miInGame,miNotExist);//Exist - существует (уже выучил =) (24.04.11))
            //вывод
            x,y: integer;  //изменяются торлько в выводе курсоров
            Outing: TOutingMode; //изменяется торлько в выводе курсоров
                          TOutingMode=(omSimple,omPressed,omSuperPressed);
            isMouse: boolean; //virtual
            //ввод
            InputMode: TInputMode;
                          TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude); - interface
            PressedOpenKey,PressedFlagKey: boolean;
            keys: TKeys;//не для мыши
                          TKeys=record  Up,Down,Left,Right,Open,Flag: word;  end; //-interface
            presseds: TPressedKeys;
                          TPressedKeys=set of(pkUp,pkDown,pkLeft,pkRight,pkOpen,pkFlag,pkMiddle);
            //ядро
            name: string;//используется только в ядре
            end;
//const noIgr=16-1;
//      maxKolvoIgr=noIgr-1; - interface
//      mouseIgr=0;
var Igr: array[0..maxKolvoIgr]of TIgrok;//0 - мышь, остальные - клава

function goodIgr(n: byte; noIgrIsGood: boolean ; s: string): boolean; //отладочно-проверочная
function existIgr(n: byte; noIgrIsGood: boolean; s: string): boolean;//отладочно-проверочная
//~~~~инициализировать - кто существует, и существующих~~~~
//-------------вывод-------------------------------------
var scrh,scrl: integer;  //только в ReSetScrSize
    scrx,scry: integer;  //SetScrPosition, иногда в ReSetScrSize, ScrollBarG/VChange, изначально неприхотливые (в смысле?)
const otst=2;       //может стать переменной
      otstPixDown=45+20; otstPixR=26+20;    //заменить width->ClientWidth
var otstPixL,otstPixUp: integer;//впринципе константы, хотя...???
    ImageSize: integer=16;   PixelPainting: boolean=false;   //...

function tInScr(x,y: integer):boolean; //просто проверяет по scrh,scrl, scrx,scry
/////////////////////////////независимый//
procedure paintKl(x,y: integer; data: byte);
//использует outing соотв. игрока
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

procedure paintKlpr(x,y: integer; data: byte);//x,y - в координатах поля
//paintKl + tInScr
procedure RePaintScr;
//перерисовавает экран + OnlineDbgRePaint;
procedure SetScrPosition(lscrx,lscry: integer);
//проверяет правильность, если надо - меняет позиции линеек, и перерисовывает экран
procedure ReSetScrSize;
//если надо меняет постоянне параметры sScrollBar'ов и перерисовавает экран, затирая лишнее
//вызывать при изменении  h0,l0, ImageSize,  размеров формы

procedure TForm1.ScrollBarGChange(Sender: TObject);
procedure TForm1.ScrollBarVChange(Sender: TObject);
//напрямую изменяют scrx,scry , перерисовывают экран
procedure TForm1.FormPaint(Sender: TObject);//interface
//<=>RePaintScr
procedure TForm1.FormResize(Sender: TObject);//use onli for formResize(sys events)
//ограничение минимального размера формы, движение большой кнопки и LabelTime, ReSetScrSize
//~~~~??? ~~~~
//  - - - - - - - - - - - -изменение курсоров - - - - - - - - - - - - - - - -\\
//private - глобальные переменные(только по области видимости) и функции
  //, используемые OutCurs и eraseCurs
  var ochered: array[0..maxKolvoIgr]of byte;  //0-е место - верх
  procedure IgrNaVerh(n: byte);//n-игрок
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




//заменить width->ClientWidth
// и height





{$define dbgKernel}
//{$define LogKernel}
//type TAutomaticMode=(amAllYouSelf,amAuto0,amAuto0andFlag,amAutoOpen,amAutoAllSimple); - interface
var autoMaticMode: TAutomaticMode;    {режим автоматики}
    KolvoMin,km: integer;{количество мин на поле(константа в течении игры)}
                         {km=kolvomin-количество флажков;- сколько осталось мин}
    kl,nopkl: integer;  {количество (всего и неоткрытых) клеток за исключением
                          количества мин;}
    MyStack,ProtectFlags,VShirElseVGlub: boolean;
procedure SetCA(x,y: integer; c,a: byte);             //переопроеделение свойств

//бытрые функции
function canBeOpen(x,y: integer): boolean;
function isFlag(x,y: integer): boolean;
function notIsOpen(x,y: integer): boolean;

procedure incz(x,y: integer; var z: byte);          //часто используемая для подсчета
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
procedure initPole(otv: byte);//раздача мин
procedure GameEvent(x,y: integer; otv: byte; PressK1: boolean);
//case GameMode
//if myStack
//if StackOwerFlow
//==============================================================================
//-------------инициализация и обработчики не игровых событий-----------------------------
{$ifdef DBGOnline} forward; procedure InitDBGOnline(repaint: boolean);
procedure TForm1.Button2Click(Sender: TObject);//сменить режим вывода
  //полностью переделать!!!
procedure TForm1.Button1Click(Sender: TObject);  //настройки
procedure TForm1.ButtonRestartClick(Sender: TObject);
  //исправить изменение размеров окна
//- - - - - - - - - - - - - - - interface- - - - - - - - - - - - - - - - - - - -
{     TInterfaceIgrs=array[0..maxKolvoIgr]of record
                                           x,y: integer;
                                           inputMode: TinputMode;
                                           Exist: boolean;
                                           keys: TKeys;
                                           name: string;
                                           end;} //- напоминание
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
//вызов logo
procedure InitSaper;//sysEvents
{ randomize;
  OtstPixUp:=60;  OtstPixL:=25;//96;
  SetSettings
  form1.ButtonRestartClick(obj);
}
//--------------------------DBGonline--------------------------------------
procedure TForm1.CheckBox1Click(Sender: TObject);
//показать/скрыть показатели
{$ifdef DBGOnline}
var dbgcount: integer;
    RepaintOn: boolean;
procedure DBGOnLine;
//repaint'ы labels'ов тормозят все
//repaint'ы нужны когда приложение "зависло" и при mouseMove
//повестить некоторые из них на таймер, когда будут потоки
//а некоторые в mouseMove
var countRePaint,countOut0: integer;
procedure OnlineDbgRePaint;
procedure onlineDBGOutCurs(lx,ly: integer);
procedure InitDBGOnline(repaint: boolean);
{$endif}

*)
end.

