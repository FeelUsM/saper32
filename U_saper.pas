unit U_saper;

interface
            
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, ExtCtrls, StdCtrls, Ulogo;

type
  TForm1 = class(TForm)
    ImageList1: TImageList;
    ButtonRestart: TButton;
    Button1: TButton;
    ScrollBarG: TScrollBar;
    ScrollBarV: TScrollBar;
    Memo2: TMemo;
    Button2: TButton;
    CheckBox1: TCheckBox;
    LabelMine: TLabel;
    LabelTime: TLabel;

    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);

    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);

    procedure ButtonRestartClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);

    //procedure FormCreate(Sender: TObject);
    procedure ScrollBarGChange(Sender: TObject);
    procedure ScrollBarVChange(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
var
  Form1: TForm1;
procedure InitSaper;
const hmax=1024;
      lmax=1024;
const noIgr=16-1; //- в интерфейсе не нужен, но через него определяется maxKolvoIgr
      maxKolvoIgr=noIgr-1;
      mouseIgr=0;
type TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude);
     TAutomaticMode=(amAllYouSelf,amAuto0,amAuto0andFlag,amAutoOpen,amAutoAllSimple);
     TKeys=record
           Up,Down,Left,Right,Open,Flag: word;
           end;
     TInterfaceIgrs=array[0..maxKolvoIgr]of record
                                           x,y: integer;
                                           inputMode: TinputMode;
                                           Exist: boolean;
                                           keys: TKeys;
                                           name: string;
                                           end;
procedure GetSettings(var Lh0,Ll0,LKolvoMin: integer; var LAutomaticMode: TAutomaticMode;
              var LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              var Gamers: TInterfaceIgrs);
function CheckSettings(Lh0,Ll0,LKolvoMin: integer;
              const Gamers: TInterfaceIgrs; var s: string): boolean;
procedure SetSettings(Lh0,Ll0,LKolvoMin: integer; LAutomaticMode: TAutomaticMode;
              LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              const Gamers: TInterfaceIgrs);
//              ПЛАН:
//   вывод чуть чуть (whatOut->podsv), imagelist
//...улучшить вывод(сделать логичнее)
//OK линейки сделать по нормальному
//вроде OK, хотя... отдебагить линейки
//   сделать out0 и DBGonLine быстрее
//   сделать formResize по нормальному
//   сделать заставку
//   перевести все на вычисление мыши во время выполнения

//OK дописать whatOut=> дописать ввод
//OK оптимизировать OutCurs
//OK и отдебагить
//OK ввод с мышки отладить

//   ввод с клавы

//...инициализация всего - проверить
//...интерфейс настройки

//   ядро - оптимизировать стек
//   виртуальные флаги - новая функция
//
//   время
//   потоки(ни stream а thread)

//   сделать как в Windows сапере - реакцию на mouseUp вне формы
//   сделать pole  динамическим(если совсем нечего делать будет)
//   ...
//   СОДЕРЖАНИЕ В КОНЦЕ
//   (c)Филипп Усков fel1992@mail.ru
//==============================================================================
implementation
{$R *.dfm}
uses u2Saper, Unit3;
//---------------управление-------------
{$define dbgBase}
{$define dbgOut}
{$define dbgIn}

//{$define begin_End}

{$define dbgOnLine}
//{$define logSysEvents}
//log out0   (~513)
//log OutCurs(3шт)(где-то)
//------------глобально-примитивные-------------
function minim(a,b: integer): integer;
begin
  if a>b
  then result:=b
  else result:=a;
end;
function max(a,b: integer): integer;
begin
  if a>b
  then result:=a
  else result:=b;
end;
function booltoStr(x: boolean):string;
begin
  if x
  then result:='true'
  else result:='false';
end;
{procedure delay(x: integer);
  var i,j,k: integer;
begin
  k:=0;
  for i:=0 to x
  do for j:=0 to 1
     do inc(k);
  inttostr(k);
end;}
//---------------отладочные-----------------
procedure error(s: string);
  {$ifdef begin_end}  var i: integer;{$endif}
begin
  form3.Memo1.Lines.Add('ERROR:'+s+';');
  {$ifdef begin_end}
      for i:=0 to form1.Memo2.Lines.Count-1
      do form3.Memo1.Lines.Add('->'+form1.Memo2.Lines.Strings[i]+';');
      form3.Memo1.Lines.Add('END');
  {$endif}
end;
procedure log(s: string);
  {$ifdef begin_end}  var i: integer;{$endif}
begin
  //delay(1);
  form3.Memo1.Lines.Add('LOG:'+s+';');
  {$ifdef begin_end}
      for i:=0 to form1.Memo2.Lines.Count-1
      do form3.Memo1.Lines.Add('->'+form1.Memo2.Lines.Strings[i]+';');
      form3.Memo1.Lines.Add('END');
  {$endif}
end;

{$ifdef dbgonline}
procedure dbgOnLine;
forward;
procedure OnlineDbgRePaint;
forward;
procedure onlineDBGOutCurs(lx,ly: integer);
forward;
{$endif}
//------------поисково-отладочные---------------
//var dbgObj: Tobject;     -  отказались
//{$define LogOfDBG}   //отладка отладки)))
{$ifdef begin_end}//\\\\\\\\\\\\\\\\\\\\\\\\\\
procedure beginDBG(s: string);
begin
  form1.memo2.Lines.Add(s);
  {$ifdef logOfDBG}log('добавлена:'+s);{$endif}
end;
procedure endDBG(s: string);
begin
  if form1.Memo2.Lines.Count=0
  then error('нечего удалять из memo2')
  else if pos(s,form1.Memo2.Lines.Strings[form1.Memo2.Lines.Count-1])<>1
       then error('при удалении вместо '''+s+''' - '''
              +form1.Memo2.Lines.Strings[form1.Memo2.Lines.Count-1]+'''')
       else form1.Memo2.Lines.Delete(form1.Memo2.Lines.Count-1);
  {$ifdef logOfDBG}log('удалена:'+s);{$endif}
end;
procedure checkBeginEnd(s: string);
begin
  //if (form1.Memo2.Lines.Count<>0)and(x<>dbgObj) then
      error('по завершении memo2 не пусто - '+s);
end;
{$endif}//////////////////////
//==============================================================================
//--------база сапера--------------------
type TGameMode=(gmStart,gmGame,gmFinish);
var GameMode: TGameMode;
type Tkletka=record
             //isMina: boolean; // наличие мины ни от чего не зависит и ни на что не влияет
             num,//mina - старший бит , остальное число
             otv: byte;//старшая тетрада - автор , младшая - курсор
             end;
const //0..8 - цифры
      cfNop  =9 ; // клетка неоткрытая
      cfFlag =10; // клетка с флагом
      cfFalseFlag=11; // клетка с неверным флагом
      cfMine =12; // клетка с миной
      cfLastMine=13; // клетка с миной, на которой подорвались
      cfOther=14;
//const hmax=1024;
//      lmax=1024; - interface
var pole: array[1..lmax,1..hmax] of Tkletka;//видны выводу в _;-? меняется и видны: в ядре, инициализации и прочем
    //^property
    h0,l0: integer;      //размеры поля  //видны везде, меняются только в "инициализации и прочем"

function tInPole(x,y: integer; s: string):boolean;//отладо-проверочная
begin
  if (x>=1)and(x<=l0)and(y>=1)and(y<=h0)
  then result:=true
  else begin
       result:=false;
       error('выход за ганицы поля('+inttostr(x)+' '+inttostr(y)+')-'+s);
       end;
end;
{$ifdef dbgBase}
    function goodIgr(n: byte; noIgrIsGood: boolean ; s: string): boolean; //отладочно-проверочная
    forward;
    function existIgr(n: byte; noIgrIsGood: boolean; s: string): boolean;//отладочно-проверочная
    forward;
{$endif}

function GetMina(x,y: integer): boolean;
begin
  result:=(pole[x,y].num and $80)=$80;
  {$ifdef dbgBase}tInPole(x,y,'GetMina('+booltoStr(result)+')');{$endif}
end;
function GetCifra(x,y: integer): byte;
begin
  result:=pole[x,y].num and $7F;
  {$ifdef dbgBase}tInPole(x,y,'GetCifra('+inttostr(result)+')');{$endif}
end;
function GetAutor(x,y: integer): byte;
begin
  result:=(pole[x,y].otv shr 4) and $0F;
  {$ifdef dbgBase}
      if tInPole(x,y,'GetAutor('+inttostr(result)+')')
      then existIgr(result,true,'GetAutor');
  {$endif}
end;
function GetCursor(x,y: integer): byte;
begin
  result:=pole[x,y].otv and $0F;
  {$ifdef dbgBase}
      if tInPole(x,y,'GetCursor('+inttostr(result)+')')
      then existIgr(result,true,'GetCursor');
  {$endif}
end;

procedure SetMina(x,y: integer; m: boolean);
begin
  {$ifdef dbgBase}
      if tInPole(x,y,'SetMina')
  then{$endif}
  if m
  then pole[x,y].num:=pole[x,y].num or $80
  else pole[x,y].num:=pole[x,y].num and $7F;
end;
procedure SetCifra(x,y: integer; z: byte);
begin
  {$ifdef dbgBase}
      if z>$7F
      then begin
           error('SetCifra('+inttostr(z)+')');
           exit;
           end;
      if tInPole(x,y,'SetCifra')
  then
  {$endif}
  pole[x,y].num:=(pole[x,y].num and $80)or(z and $7F)
end;
procedure SetAutor(x,y: integer; z: byte);
begin
  {$ifdef dbgBase}
      if not existIgr(z,true,'SetAutor')
      then exit;
      if tInPole(x,y,'SetAutor')
  then{$endif}
  pole[x,y].otv:=(pole[x,y].otv and $0F)or((z shl 4)and $F0)
end;
procedure SetCursor(x,y: integer; z: byte);
begin
  {$ifdef dbgBase}
      if not existIgr(z,true,'SetCursor')
      then exit;
      if tInPole(x,y,'SetCursor')
  then{$endif}
  pole[x,y].otv:=(pole[x,y].otv and $F0)or(z and $0F)
end;

function PoleIsOpen(x,y: integer): boolean;
begin
  result:=GetCifra(x,y)<=8
  {$ifdef debug}tInPole(x,y,'PoleIsOpen('+booltostr(result)+')');{$endif}
end;
//------------around-------------------------------------------
type kldetect  =function (x,y: integer)  :  boolean;
     kldoing   =procedure(x,y: integer;     data: byte);
     kldoingVar=procedure(x,y: integer; var data: byte);
procedure aroundKl(x,y: integer; data: byte; detect: kldetect; doing: kldoing);
  procedure ifInMatr(x,y: integer);
  begin
    if (y>=1)and(y<=h0)and(x>=1)and(x<=l0)and detect(x,y)//tInPole, только без вызова ошибок
    then doing(x,y,data);
  end;
begin
  {$ifdef dbgBase}
      if not tInPole(x,y,'aroundKl')
      then exit;
  {$endif}
  {$ifdef begin_end}beginDBG('aroundKl '+inttostr(x)+','+inttostr(y)+','+inttostr(data));{$endif}
  ifinmatr(x-1,y  );
  ifinmatr(x  ,y+1);
  ifinmatr(x+1,y  );
  ifinmatr(x  ,y-1);
  ifinmatr(x-1,y-1);
  ifinmatr(x-1,y+1);
  ifinmatr(x+1,y+1);
  ifinmatr(x+1,y-1);
  {$ifdef begin_end}endDBG('aroundKl');{$endif}
end;
procedure aroundKlvar(x,y: integer; var data: byte; detect: kldetect; doing: kldoingVar);
  procedure ifInMatr(x,y: integer);
  begin
    if (y>=1)and(y<=h0)and(x>=1)and(x<=l0)and detect(x,y)//tInPole, только без вызова ошибок
    then doing(x,y,data);
  end;
begin
  {$ifdef dbgBase}
      if not tInPole(x,y,'aroundKlVar')
      then exit;
  {$endif}
  {$ifdef begin_end}beginDBG('aroundKlvar '+inttostr(x)+','+inttostr(y)+','+inttostr(data));{$endif}
  ifinmatr(x-1,y-1);
  ifinmatr(x-1,y  );
  ifinmatr(x-1,y+1);
  ifinmatr(x  ,y+1);
  ifinmatr(x+1,y+1);
  ifinmatr(x+1,y  );
  ifinmatr(x+1,y-1);
  ifinmatr(x  ,y-1);
  {$ifdef begin_end}endDBG('aroundKlvar');{$endif}
end;
function All(x,y: integer): boolean;
begin
  result:=true;
  {$ifdef dbgBase}
      if not tInPole(x,y,'All')
      then result:=false;
  {$endif}
end;
const NoVar=0;
//==============================================================================
//----------------игроки-курсоры------------------------------------------------
type TModeIgr=(miIsDead,miInGame,miNotExist);//Exist - существует
//     TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude); - interface
     TOutingMode=(omSimple,omPressed,omSuperPressed);
            //супероткрывание - когда курсор начинает занимать квадрат 3х3 клетки
//(TInputMode)кнопки: не работают, только открытие, без "колесика", ...
     TPressedKeys=set of(pkUp,pkDown,pkLeft,pkRight,     //не для мыши
                                          pkOpen,pkFlag,pkMiddle);
{     TKeys=record
           Up,Down,Left,Right,Open,Flag: word;
           end;} //-interface
     TIgrok=record
            //базовая
            Mode: TModeIgr;
            //вывод
            x,y: integer;  //изменяются торлько в выводе курсоров
            Outing: TOutingMode; //изменяется торлько в выводе курсоров
            isMouse: boolean;
            //ввод
            InputMode: TInputMode;
            PressedOpenKey,PressedFlagKey: boolean;
            keys: TKeys;//не для мыши
            presseds: TPressedKeys;
            //ядро
            name: string;//используется только в ядре
            end;
//const noIgr=16-1;
//      maxKolvoIgr=noIgr-1; - interface
//      mouseIgr=0;
var Igr: array[0..maxKolvoIgr]of TIgrok;//0 - мышь, остальные - клава

function goodIgr(n: byte; noIgrIsGood: boolean; s: string): boolean; //отладочно-проверочная
begin
  if (n<=maxKolvoIgr)or((n=noIgr)and noIgrIsGood)
  then result:=true
  else begin
       result:=false;
       error('неизвестный курсор('+inttostr(n)+')-'+s);
       end;
end;
function existIgr(n: byte; noIgrIsGood: boolean; s: string): boolean;   //отладочно проверочная
begin
  result:=goodIgr(n,noIgrIsGood,s);
  if result and (n<>noIgr)
  then if igr[n].Mode=miNotExist
       then begin
            result:=false;
            error('курсор '+inttostr(n)+' не существует - '+s);
            end;
end;
//-------------вывод-------------------------------------
var scrh,scrl: integer; //размер в клетках выводимой области //меняются только в form.resize
    scrx,scry: integer; //координата в клетках левого верхнего выводимого угла
const otst=2;
const otstPixDown=45+20;
      otstPixR=26+20;
var otstPixL,otstPixUp: integer; //координата левого верхнего пикселя, выводимого на форму
    ImageSize: integer=16;      // всё квадратное
    PixelPainting: boolean=false;

function tInScr(x,y: integer):boolean;
begin
  result:=
    {$ifdef dbgOut}tInPole(x,y,'tInScr(''false'')')and{$endif} //а 'false' зачем?
  (x>=scrx)and(x<scrx+scrl)and(y>=scry)and(y<scry+scrh)
end;

(*
/////////////////////////////независимый//
procedure out0(x,y: integer; n: integer); // в координатах экрана, не проверяет в экране точка, или нет
begin
  {$ifdef dbgOut}
      if(x<1)or(y<1)or(x>scrl)or(y>scrh)
      then error('выход за границы экрана out0('+inttostr(x)+','+inttostr(y)+')')
      else if n>=form1.ImageList1.Count
           then error('нет картинки №'+inttostr(n))
           else
  {$endif}
  if PixelPainting
  then form1.Canvas.Pixels[(x-1)*ImageSize+OtstPixL, (y-1)*ImageSize+OtstPixUp]:=n
  else Form1.ImageList1.DRAW(Form1.Canvas,(x-1)*ImageSize+OtstPixL, (y-1)*ImageSize+OtstPixUp, n);

  //log('Paint('+inttostr(x)+','+inttostr(y)+')');
  //onlineDbgOut0(x,y);
end;
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function WhatOut(x,y: integer): integer;  //можно засунуть прямо в out0
  function podsv(num,n: byte):byte;         //...
  begin
    if n=0
    then result:=num
    else result:=cfOther+n;
  end;
  function PressedKl(x,y: integer; n: byte):byte;
    var num: byte;
  begin
    num:=GetCifra(x,y);
    if num=cfNop   //если клетка не нажата
    then result:=podsv(0,n)//то как будто там стоит '0'
    else result:=podsv(num,n);
  end;
  var n: byte;
begin
  {$Ifdef dbgOut}
      if not tInPole(x,y,'WhatOut')
      then begin
           result:=cfOther;
           exit;
           end;
  {$endif}
  {$ifdef begin_end}beginDBG('WhatOut');{$endif}
  n:=GetCursor(x,y);
  {$ifdef dbgOut}
      if n<>noIgr
      then if not existIgr(n,'WhatOut')
           then n:=NoIgr;
  {$endif}               //а режим игры, а режим курсора - все ко вводу; - точнее к GetOutingMode
  if pixelPainting
  then if poleIsOpen(x,y)
       then result:=clWhite
       else case GetCifra(x,y)
            of cfNop: result:=clGray;//clBtnFace;
               cfFlag:result:=clSkyBlue;//clGreen;
               cfMine:result:=clBlack;
               cfLastMine:result:=clRed;
            else result:=clYellow;
            end
  else
    if n=NoIgr           //а автор...
    then result:=GetCifra(x,y)   //если здесь нет игрока
    else if igr[n].outing=omSimple//вычисление нажатости
         then result:=podsv(GetCifra(x,y),n)
         else result:=PressedKl(x,y,n);     //нажата

  {$ifdef begin_end}endDBG('WhatOut');{$endif}
end;
*)

/////////////////////////////независимый//
procedure paintKl(x,y: integer; data: byte);
  function podsv(num,n: byte):byte;//^для соответствия с KlDoing
  begin                   //...
    if n=0
    then result:=num
    else result:=cfOther+n;
  end;
  function PressedKl(x,y: integer; n: byte):byte;
    var num: byte;
  begin
    num:=GetCifra(x,y);
    if num=cfNop   //если клетка не нажата
    then result:=podsv(0,n)//то как будто там стоит '0'
    else result:=podsv(num,n);
  end;
(*  procedure out0(x,y: integer; n: integer);
  begin
    if PixelPainting
    then form1.Canvas.Pixels[(x-1)*ImageSize+OtstPixL, (y-1)*ImageSize+OtstPixUp]:=n
    else Form1.ImageList1.DRAW(Form1.Canvas,(x-1)*ImageSize+OtstPixL, (y-1)*ImageSize+OtstPixUp, n);
  end;*)
  var n: byte;
      rez: integer;
begin
  {$ifdef dbgOut}
      if not tInPole(x,y,'PaintKl')then
          exit;
  {$endif}
  {$ifdef dbgOut}
      if not tInScr(x,y)
      then begin
           error('неверное использование незащищенного вывода('+inttostr(x)+','+inttostr(y)+')');
           exit;
           end;
  {$endif}
  {$ifdef begin_end}
        beginDBG('PainKl('+inttostr(x)+','+inttostr(y)+'),'+inttostr(data)
              +','+BoolToStr(PixelPainting)+','+inttostr(ImageSize)
              +',('+inttostr(scrx)+','+inttostr(scry)+')');
  {$endif}

  n:=GetCursor(x,y);
  {$ifdef dbgOut}
      if not existIgr(n,true,'WhatOut')
      then n:=NoIgr;
  {$endif}               //а режим игры, а режим курсора - все ко вводу; - точнее к GetOutingMode
  if pixelPainting
  then begin
       if poleIsOpen(x,y)
       then rez:=clWhite
       else case GetCifra(x,y)
            of cfNop: rez:=clGray;//clBtnFace;
               cfFlag:rez:=clSkyBlue;//clGreen;
               cfMine:rez:=clBlack;
               cfLastMine:rez:=clRed;
            else rez:=clYellow;
            end;
       x:=x-scrx+1;
       y:=y-scry+1;
       form1.Canvas.Pixels[(x-1)*ImageSize+OtstPixL, (y-1)*ImageSize+OtstPixUp]:=rez;
       end
  else begin
       if n=NoIgr           //а автор...
       then rez:=GetCifra(x,y)   //если здесь нет игрока
       else if igr[n].outing=omSimple//вычисление нажатости
            then rez:=podsv(GetCifra(x,y),n)
            else rez:=PressedKl(x,y,n);     //нажата
       x:=x-scrx+1;
       y:=y-scry+1;
       Form1.ImageList1.DRAW(Form1.Canvas,(x-1)*ImageSize+OtstPixL, (y-1)*ImageSize+OtstPixUp, rez);
       end;
  {$ifdef begin_end}endDBG('PainKl');{$endif}
end;
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

procedure paintKlpr(x,y: integer; data: byte);
begin                           //^для соответствия с KlDoing
    {$ifdef dbgOut}
        if not tInPole(x,y,'PaintKlpr')then
            exit;
    {$endif}
    {$ifdef begin_end}beginDBG('PainKlpr('+inttostr(x)+','+inttostr(y)+'),'+inttostr(data));{$endif}
  if tInScr(x,y)
  then paintKl(x,y,data);
    {$ifdef begin_end}endDBG('PainKlpr');{$endif}
end;

procedure RePaintScr;
  var x,y: integer;
      fl: boolean;
      promS: string;
begin
    {$ifdef DBGOut}
        if (scrx+scrl-1>l0)or(scry+scrh-1>h0)
        then begin
             error('RePaintScr');
             exit;
             end;
    {$endIf}
    {$ifdef begin_end}
      beginDBG('RePaintScr('+inttostr(scrx)+','+inttostr(scry)
        +')('+inttostr(scrh)+','+inttostr(scrl)+')');
    {$endif}
  fl:=scrh*scrl>10000;
  if fl
  then begin
       PromS:=form1.Caption;
       form1.Caption:=form1.Caption+' RePaintScreen';
       end;
  for y:=scry to scry+scrh-1
  do for x:=scrx to scrx+scrl-1
     do paintKl(x,y,NoVar);
  if fl then
       form1.Caption:=PromS;
  OnlineDbgRePaint;
    {$ifdef begin_end}endDBG('RePaintScr');{$endif}
end;

procedure SetScrPosition(lscrx,lscry: integer);
  var fl: boolean;
begin
    {$ifdef DBGout}
        if (lscrx<1)or(lscry<1)or(lscrx+scrl-1>l0)or(lscry+scrh-1>h0)
        then begin
             error('неверная новая позиция экрана ('+inttostr(lscrx)+','+inttostr(lscry)+')');
             exit;
             end;
    {$endif}
    {$ifdef begin_end}
        beginDBG('SetScrPosition('+inttostr(lscrx)+','+inttostr(lscry)+')');
    {$endif}
  fl:=false;
  if lscrx<>scrx
  then begin
       fl:=true;
       scrx:=lscrx;
       form1.ScrollBarG.Position:=scrx;
       end;
  if lscry<>scry
  then begin
       fl:=true;
       scry:=lscry;
       form1.ScrollBarV.Position:=scry;
       end;
  if fl then
      RePaintScr;
    {$ifdef begin_end}endDBG('SetScrPosition');{$endif}
end;

procedure ReSetScrSize;
  var h,l: integer;
begin
    {$ifdef begin_end}
        beginDBG('ReSetScrSize('+inttostr(form1.ClientHeight)
            +','+inttostr(form1.ClientWidth)+')'+inttostr(imageSize)
            +'('+inttostr(h0)+','+inttostr(l0)+')');
    {$endif}
  //scrH,scrL меняются от :     (это когда надо вызывать)
  //h0,l0
  //ImageSize
  //размеров формы
  h:=minim(h0,(form1.ClientHeight-otstPixUp-otstPixDown)div ImageSize);
  l:=minim(l0,(form1.ClientWidth -otstPixL -otstPixR)   div ImageSize);
  {ShowMessage(inttostr(l0)+#13+inttostr((form1.ClientWidth -otstPixL -otstPixR)   div ImageSize)
    +#13+inttostr(l));}
  if h<>scrh
  then with form1.ScrollBarV
       do begin
          form1.ScrollBarG.Top :=OtstPixUp+ImageSize*h;
                           //Left:=OtstPixL +ImageSize*l;
          Top   :=OtstPixUp;
          Height:=ImageSize*h;
          Max:=h0;
          PageSize:=h;
          end;
  if l<>scrl
  then with form1.ScrollBarG
       do begin
          form1.ScrollBarV.Left:=OtstPixL +ImageSize*l;
                           //Top :=OtstPixUp+ImageSize*h;
          Left  :=OtstPixL;
          Width :=ImageSize*l;
          Max:=l0;
          PageSize:=l;
          end;
(*ScrollBarG.PageSize:=scrL;
ScrollBarG.SetParams(scrX,0,l0);
ScrollBarV.PageSize:=scrH;
ScrollBarV.SetParams(scrY,0,h0);
ScrollBarG.Show;
ScrollBarV.Show; *)
  if (h<>scrh)or(l<>scrl)
  then begin
       scrh:=h;
       scrl:=l;
       if scrx+scrl-1>l0
       then scrx:=l0-scrl+1;
       if scry+scrh-1>h0
       then scry:=h0-scrh+1;
       form1.Canvas.Pen.Color:=clBtnFace;
       form1.Canvas.Rectangle(otstPixL+scrl*ImageSize,OtstPixUp,form1.Width,form1.Height);
       form1.Canvas.Rectangle(-1,otstPixUp+scrh*ImageSize,form1.Width,form1.Height);
       RePaintScr;
       end;
    {$ifdef begin_end}endDBG('ReSetScrSize');{$endif}
end;

procedure TForm1.ScrollBarGChange(Sender: TObject);
  var x: integer;
begin
    {$ifdef logSysEvents}log('ScrollBarGChange');{$endif}
    {$ifdef begin_end}beginDBG('ScrollBarGChange');{$endif}
  x:=scrollBarG.Position;
  if x+scrl-1>l0
  then error('ошибка в горизонтальной прокрутке')
            //- реально возможна, всилу особенностей ScrollBar
  else scrx:=x;                     //напрямую

  RePaintScr;
    {$ifdef begin_end}
        endDBG('ScrollBarGChange');
        checkBeginEnd('ScrollBarGChange');
    {$endif}
end;
procedure TForm1.ScrollBarVChange(Sender: TObject);
  var y: integer;
begin
    {$ifdef logSysEvents}log('ScrollBarVChange');{$endif}
    {$ifdef begin_end}beginDBG('ScrollBarVChange');{$endif}
  y:=scrollBarV.Position;
  if y+scrh-1>h0
  then error('ошибка в вертикальной прокрутке')
            //- реально возможна, всилу особенностей ScrollBar
  else scry:=y;                 //напрямую

  RePaintScr;
    {$ifdef begin_end}
        endDBG('ScrollBarVChange');
        checkBeginEnd('ScrollBarVChange');
    {$endif}
end;

procedure TForm1.FormPaint(Sender: TObject);//interface
begin
    {$ifdef logSysEvents}log('FormPaint');{$endif}
    {$ifdef begin_end}beginDBG('formPaint');{$endif}
  RePaintScr;
    {$ifdef begin_end}
        endDBG('formPaint');
        checkBeginEnd('formPaint');
    {$endif}
end;
procedure TForm1.FormResize(Sender: TObject);//use onli for formResize(sys events)
begin
    {$ifdef logSysEvents}log('FormResize');{$endif}
    {$ifdef begin_end}beginDBG('formResize');{$endif}
  if form1.ClientHeight<OtstPixUp+otstPixDown+imagesize*2
    then form1.ClientHeight:=OtstPixUp+otstPixDown+imagesize*2;
  if form1.Width<240
    then form1.Width:=240;
  ButtonRestart.Left:=trunc((width-buttonRestart.Width)/2);
  LabelTime.Left:=Form1.ClientWidth-44;
  ReSetScrSize;
    {$ifdef begin_end}
        endDBG('formResize');
        checkBeginEnd('formResize');//также может вызываться только из formCreate
    {$endif}
end;

//  - - - - - - - - - - - -изменение курсоров - - - - - - - - - - - - - - - -\\
var ochered: array[0..maxKolvoIgr]of byte;  //0-е место - верх

procedure IgrNaVerh(n: byte);//n-игрок
  var i: byte;
begin
  {$ifdef DBGout}
      if not goodIgr(n,false,'IgrNaVerh')
      then exit;
  {$endif}
  {$ifdef begin_End}beginDBG('IgrNaVerh');{$endif}
  //log('IgrNaVerh');
  for i:=0 to maxKolvoIgr
  do if ochered[i]=n
     then break;
  for i:=i downto 1
  do ochered[i]:=ochered[i-1];
  ochered[0]:=n;
  {$ifdef begin_End}endDBG('IgrNaVerh');{$endif}
end;

function CursInScr(x,y: integer): boolean; //interface
begin
  result:=
    {$ifdef dbgOut}tInPole(x,y,'CursInScr(''false'')')and{$endif}
          ((scry=1)         and(y>=1) or(scry>1)        and(y>=scry+otst-1))
       and((scrx=1)         and(x>=1) or(scrx>1)        and(x>=scrx+otst-1))
       and((scry+scrh-1>=h0)and(y<=h0)or(scry+scrh-1<h0)and(y<=scry+scrh-otst))
       and((scrx+scrl-1>=l0)and(x<=l0)or(scrx+scrl-1<l0)and(x<=scrx+scrl-otst));
end;

var formRepaint: boolean;
    ChengedKl: array[1..16*9]of record
                                x,y: integer;
                                {outing,}past,futur: byte;
                                end;
    OutPoint: byte;

procedure vPaintCurs(x,y: integer; n: byte);
  var i: byte;
  label 1,2;
begin
  {$ifdef dbgOut}
      if not existIgr(n,true,'vPaintCurs')then
          exit;
      if  not tInPole(x,y,'vPaintCurs')then
          exit;
  {$endif}
  {$ifdef begin_end}beginDBG('vPaintCurs');{$endif}
  if formRePaint
  then SetCursor(x,y,n)
  else begin
       for i:=1 to OutPoint
       do if (ChengedKl[i].x=x)and(ChengedKl[i].y=y)
          then goto 1;
       //такой клетки в массиве еще нет
       {$ifdef DBGOut}
           if OutPoint>=16*9
           then begin
                error('переполнение в OutCurs');
                goto 2;
                end;
       {$endif}
       if (getCursor(x,y)<>n) then
          begin
          inc(OutPoint);
//                 log('в('+inttostr(x)+','+Inttostr(y)+')до:'+inttostr(WhatOut(x,y)));
//          ChengedKl[OutPoint].outing:=WhatOut(x,y);
          ChengedKl[OutPoint].x:=x;
          ChengedKl[OutPoint].y:=y;
          ChengedKl[OutPoint].past:=GetCursor(x,y);
          ChengedKl[OutPoint].futur:=n;
          SetCursor(x,y,n);
          end;
       goto 2;
  1:   //клетка в массиве уже есть
       ChengedKl[i].futur:=n;
       SetCursor(x,y,n);
  2:   //конец
       end;
{  if getCursor(x,y)<>n
  then begin
       setCursor(x,y,n);
       PaintKlpr(x,y,NoVar);
       end;}                      //старое
  {$ifdef begin_end}endDBG('vPaintCurs');{$endif}
end;

procedure OutCurs(lx,ly: integer; outingMode: TOutingMode; n: byte; maskRepaint: boolean); //interface
  var i: byte;
      lscrx,lscry: integer;
begin
  {$ifdef dbgOut}
      if  not tInPole(lx,ly,'OutCurs')then
          exit;
      if not existIgr(n,false,'OutCurs')then
          exit;
  {$endif}
  {$ifdef begin_end}beginDBG('outCurs');{$endif}
//                    log('OUT('+inttostr(lx)+','+inttostr(ly)+')');
                                              onlineDBGOutCurs(lx,ly);
  with igr[n]
  do begin
     formRepaint:=not cursInScr(lx,ly)and not maskRepaint;
     OutPoint:=0;

     vPaintCurs(x,y,noIgr);  //стерли старый курсор
     if outing=omSuperPressed
     then aroundKl(x,y,noIgr,All,vPaintCurs);   //log('2');
                             //теперь меняем его параметры
     x:=lx;
     y:=ly;        //x,y of igr[n]
     outing:=outingMode;
     igrNaVerh(n);

     if not FormRepaint
     then begin           //для ускорения вывести этот курсор сразу на экран
          SetCursor(x,y,n);
          paintKlpr(x,y,noVar);
          if outing=omSuperPressed then
              begin
              aroundKl(x,y,n,All,SetCursor);
              aroundKl(x,y,noVar,All,PaintKlpr);
              end;
          end;
     end;                                 //log('3');
   for i:=maxKolvoIgr downto 0
   do with igr[ochered[i]]    //выводим все курсоры в порядке очереди (виртуально)
      do if mode<>miNotExist then
              begin
              vPaintCurs(x,y,ochered[i]);
              if outing=omSuperPressed then
                  aroundKl(x,y,ochered[i],All,vPaintCurs);
              end;
                                 //log(inttostr(OutPoint));
  if formRepaint//если надо перерисовали форму
  then begin
       //scrx,scry<- :
       lscrx:=scrx;
       lscry:=scry;
       if lx-otst<scrx
       then lscrx:=max(lx-otst,1);
       if lx+otst-scrl+1>scrx
       then lscrx:=minim(lx+otst-scrl+1,l0-scrl+1);
       if ly-otst<scry
       then lscry:=max(ly-otst,1);
       if ly+otst-scrh+1>scry
       then lscry:=minim(ly+otst-scrh+1,h0-scrh+1);
       SetScrPosition(lscrx,lscry);
       end
  else for i:=1 to OutPoint            //вывести (реально) на экран измененные курсоры
       do with ChengedKl[i]
          do if past<>futur
             then PaintKlPr(x,y,NoVar);//x,y - of ChengedKl[i]
             {else begin
                  //log('клетка ('+inttostr(x)+','+inttostr(y)+')'+
                  //  inttostr(outing)+'->'+inttostr(WhatOut(x,y)) );
                  //if outing<>WhatOut(x,y) then
                        PaintKlPr(x,y,NoVar);
                  end //потомучто к этому моменту кнопка уже нажата(или утпущена)}


  {$ifdef begin_end}endDBG('outCurs');{$endif}
end;

procedure eraseCurs(n: byte);
  var i: byte;
begin
  {$ifdef dbgOut}
      if not existIgr(n,false,'eraseCurs')then
          exit;
  {$endif}
  {$ifdef begin_end}beginDBG('eraseCurs');{$endif}
//                    log('OUT('+inttostr(lx)+','+inttostr(ly)+')');
  with igr[n]
  do begin
     OutPoint:=0;

     vPaintCurs(x,y,noIgr);  //стерли старый курсор
     if outing=omSuperPressed
     then aroundKl(x,y,noIgr,All,vPaintCurs);   //log('2');
                             //теперь меняем его параметры
     end;                                 //log('3');
   for i:=maxKolvoIgr downto 0
   do if ochered[i]<>n
      then with igr[ochered[i]]    //выводим все курсоры в порядке очереди
           do if mode<>miNotExist then
                  begin
                  vPaintCurs(x,y,ochered[i]);
                  if outing=omSuperPressed then
                      aroundKl(x,y,ochered[i],All,vPaintCurs);
                  end;

  for i:=1 to OutPoint            //вывести на экран измененные курсоры
  do with ChengedKl[i]
          do if past<>futur
             then PaintKlPr(x,y,NoVar);//x,y - of ChengedKl[i]
             {else begin
                  //log('клетка ('+inttostr(x)+','+inttostr(y)+')'+
                  //  inttostr(outing)+'->'+inttostr(WhatOut(x,y)) );
                  //if outing<>WhatOut(x,y) then
                        PaintKlPr(x,y,NoVar);
                  end //потомучто к этому моменту кнопка уже нажата(или утпущена)}

  {$ifdef begin_end}endDBG('eraseCurs');{$endif}
end;
//\\  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
var ShowAutomatic: boolean;

function AutomaticInScr(x,y: integer): boolean;
begin
  result:=tInScr(x,y);
end;

procedure SetScrMode(lPixelPainting: boolean; x,y: integer);
begin

end;

procedure outKl(x,y: integer); //для запросов на вывод из ядра
  var LScrX,LScrY: integer;
  label LEND;
begin
  {$ifdef dbgOut}
      if  not tInPole(x,y,'OutKl')
      then exit;
  {$endif}
  {$ifdef begin_end}beginDBG('outKl');{$endif}
  if not ShowAutomatic
  then begin
       PaintKlpr(x,y,noVar);
       goto LEND;
       end;

  if tInScr(x,y)
  then paintKl(x,y,NoVar)
  else begin
       lscrx:=scrx;
       lscry:=scry;

       if x<scrx
       then Lscrx:=x;
       if x-scrl+1>scrx
       then Lscrx:=x-scrl+1;
       if y<scry
       then Lscry:=y;
       if y-scrh+1>scry
       then Lscry:=y-scrh+1;

       if ((abs(scrX-lscrx)>2)or(abs(scry-lscry)>2))and not PixelPainting
       then begin
            scrx:=1;
            scry:=1;
            ImageSize:=1;
            PixelPainting:=true;
            form1.Resize;
            end
       else begin
            scrx:=lscrx;
            scry:=lscry;
            end;
       RePaintScr;//Form1.FormPaint(form1);
       end;
LEND:
  {$ifdef begin_end}endDBG('outKl');{$endif}
end;

//            interface:
//function  tInScr   (x,y: integer): boolean;
//function  CursInScr(x,y: integer): boolean;
//function  SuperPressed(n: byte): boolean
//procedure WhatOut  (x,y: integer): byte;
//procrdure paintKl  (x,y: integer; var data: byte); ->WhatOut
//procrdure paintKlpr(x,y: integer; var data: byte); ->WhatOut
//procedure TForm1.FormPaint(Sender: TObject); ->paintKl
//procedure outKl    (x,y: integer; {var data: byte}); ->paintKl(pr),FormPaint
//procedure OutCurs(x1,y1: integer; var n: byte; ); ->paintKl(pr),FormPaint
//==============================================================================
//-------------------общий ввод-------------------------------------------------
procedure GameEvent(x,y: integer; otv: byte; PressK1(*else pressedK2*): boolean);
forward;

{          (напоминание)
type TModeIgr=(migrIsDead,migrInGame,migrNotExist);//Exist - существует
     TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude);
//кнопки: не работают, только открытие, без "колесика", ...
     TPressedKeys=set of(pkUp,pkDown,pkLeft,pkRight,     //не для мыши
                                          pkOpen,pkFlag,pkMiddle);
     TIgrok=record
            Mode: TModeIgr;
            x,y: integer;  //видны и изменяются торлько в выводе
            SuperOpeningIsOut: boolean; //виден и изменяется торлько в выводе
            //супероткрывание - когда курсор начинает занимать квадрат 3х3 клетки
            InputMode: TInputMode;
            PressedOpenKey,PressedFlagKey: boolean;
            KeyUp,KeyDown,KeyLeft,KeyRight,KeyO,KeyF: word;//не для мыши
            presseds:TPressedKeys;
            end;
}
function  GetOutingMode(n: byte; lx,ly: integer): TOutingMode;
begin
  result:=omSimple;//default
  {$ifdef dbgOut}
      if not tInPole(lx,ly,'GetSuperPressed')then
          exit;
      if not existIgr(n,false,'GetSuperPressed')then
          exit;
  {$endif}
  {$ifdef begin_End}beginDBG('GetSuperPressed');{$endif}
  with igr[n]
  do if (mode=miInGame)and(gameMode<>gmFinish)
     then begin
          if (inputMode<>imNothing)and(PressedOpenKey) then
              result:=omPressed;
          if inputMode=imStd then
               begin
               if PressedOpenKey and PressedFlagKey then
                    result:=omSuperPressed;
               end
          else if (inputMode=imOneButtonOpen)or(inputMode=imAllInclude)
                        and pressedOpenKey and poleIsOpen(lx,ly)    then
                    result:=omSuperPressed;
          end;
  {$ifdef begin_End}endDBG('GetSuperPressed');{$endif}
end;

function PressBoolToStr(x: boolean): string;  //отладочно-выводная
begin
  if x
  then result:='pressed'
  else result:='unpress'
end;
procedure InputError(s: string; a,b,c,d: boolean);//отладочно-выводная
begin
{$ifdef dbgIn}
  error(s+' '+PressBoolToStr(a)+','+PressBoolToStr(b)+'->'+PressBoolToStr(c)+','+PressBoolToStr(d));
{$endIf}
end;

procedure down(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);
begin
  {$ifdef begin_end}beginDBG('down');{$endif}
  {if PixelPainting and not (GameMode=gmStart)
  then begin
       ImageSize:=16;
       pixelPainting:=false;
       form1.FormResize(dbgObj);
       form1.FormPaint(dbgObj);
       outKl(lx,ly);
       end
  else}
  with igr[otv]
  do begin
     if (lx<>x)or(ly<>y)
     then error('down '+inttostr(x)+','+inttostr(y)+'->'+inttostr(lx)+','+inttostr(ly));

     {if not PressedOpenKey and not PressedFlagKey
      and not OpenPressed and flagPressed
     then begin
          if ((inputMode=imStd)or(inputMode=imNonFlag)or(inputMode=imOneButtonOpen)) and not poleIsOpen(lx,ly)
              or (inputMode=imAllInclude)
          then GameEvent(lx,ly,otv,false);
          end
     else if not PressedFlagKey and OpenPressed and FlagPressed
          then begin
               if inputMode=imAllInclude
               then GameEvent(lx,ly,otv,false);
               end
          else if not(not PressedOpenKey and OpenPressed and (pressedFlagKey=FlagPressed))
                  and not((otv=0)and(PressedOpenKey=OpenPressed)and(PressedFlagKey=FlagPressed))
               then error('down '+PressBoolToStr(PressedOpenKey)+','+PressBoolToStr(PressedFlagKey)+
                            '->'+PressBoolToStr(OpenPressed)+','+PressBoolToStr(FlagPressed));}
{     //     before                                        after
     if     PressedOpenKey and     PressedFlagKey and     OpenPressed and     flagPressed then
     if     PressedOpenKey and     PressedFlagKey and     OpenPressed and not flagPressed then
     if     PressedOpenKey and     PressedFlagKey and not OpenPressed and     flagPressed then
     if     PressedOpenKey and     PressedFlagKey and not OpenPressed and not flagPressed then
     if     PressedOpenKey and not PressedFlagKey and     OpenPressed and     flagPressed then
     if     PressedOpenKey and not PressedFlagKey and     OpenPressed and not flagPressed then
     if     PressedOpenKey and not PressedFlagKey and not OpenPressed and     flagPressed then
     if     PressedOpenKey and not PressedFlagKey and not OpenPressed and not flagPressed then
     if not PressedOpenKey and     PressedFlagKey and     OpenPressed and     flagPressed then
     if not PressedOpenKey and     PressedFlagKey and     OpenPressed and not flagPressed then
     if not PressedOpenKey and     PressedFlagKey and not OpenPressed and     flagPressed then
     if not PressedOpenKey and     PressedFlagKey and not OpenPressed and not flagPressed then
     if not PressedOpenKey and not PressedFlagKey and     OpenPressed and     flagPressed then
     if not PressedOpenKey and not PressedFlagKey and     OpenPressed and not flagPressed then
     if not PressedOpenKey and not PressedFlagKey and not OpenPressed and     flagPressed then
     if not PressedOpenKey and not PressedFlagKey and not OpenPressed and not flagPressed then
      InputError('',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed)
                   ^for copy->paste}
//-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
     //     before                                        after
     if     PressedOpenKey and     PressedFlagKey and     OpenPressed and     flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and     PressedFlagKey and     OpenPressed and not flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and     PressedFlagKey and not OpenPressed and     flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and     PressedFlagKey and not OpenPressed and not flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);

     if     PressedOpenKey and not PressedFlagKey and     OpenPressed and     flagPressed then
if (inputMode=imOneButtonOpen)or(inputMode=imAllInclude)
then GameEvent(lx,ly,otv,false);
     if     PressedOpenKey and not PressedFlagKey and     OpenPressed and not flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and not PressedFlagKey and not OpenPressed and     flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and not PressedFlagKey and not OpenPressed and not flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);

     if not PressedOpenKey and     PressedFlagKey and     OpenPressed and     flagPressed then
;
     if not PressedOpenKey and     PressedFlagKey and     OpenPressed and not flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and     PressedFlagKey and not OpenPressed and     flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and     PressedFlagKey and not OpenPressed and not flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);

     if not PressedOpenKey and not PressedFlagKey and     OpenPressed and     flagPressed then
if otv<>0
then InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed)
else ;
     if not PressedOpenKey and not PressedFlagKey and     OpenPressed and not flagPressed then
;
     if not PressedOpenKey and not PressedFlagKey and not OpenPressed and     flagPressed then
if (inputMode<>imNothing)and(inputMode<>imNonFlag)and not poleIsOpen(lx,ly) or (inputMode=imAllInclude)
then GameEvent(lx,ly,otv,false);
     if not PressedOpenKey and not PressedFlagKey and not OpenPressed and not flagPressed then
InputError('down',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
//  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

     PressedOpenKey:=OpenPressed;
     PressedFlagKey:=FlagPressed;

     outCurs(lx,ly,GetOutingMode(otv,lx,ly),otv,otv=0);
     end;
  {$ifdef begin_end}endDBG('down');{$endif}
end;

procedure Up(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);
begin
  {$ifdef begin_end}beginDBG('up');{$endif}
  with igr[otv]
  do begin
     if (lx<>x)or(ly<>y)
     then error('up '+inttostr(x)+','+inttostr(y)+'->'+inttostr(lx)+','+inttostr(ly));

{     if PressedOpenKey and not PressedFlagKey and not openPressed and not FlagPressed
     then begin
          if not PoleIsOpen(lx,ly)and
              ((inputMode=imStd)or(inputMode=imNonFlag)or(inputMode=imOnlyOpen))
          then GameEvent(lx,ly,otv,true);
          end
     else if PressedOpenKey and PressedFlagKey and not(openPressed and FlagPressed)
          then begin
               if (inputMode=imStd)and PoleIsOpen(lx,ly)
               then GameEvent(lx,ly,otv,true);
               end
          else if PressedOpenKey and not openPressed and (pressedFlagKey=flagPressed)
               then begin
                    if (inputMode=imOneButtonOpen)or (inputMode=imAllInclude)
                    then GameEvent(lx,ly,otv,true);
                    end
               else if not(not pressedOpenKey and PressedFlagKey and not openPressed and not flagPressed)
                      and not((otv=0)and(PressedOpenKey=OpenPressed)and(PressedFlagKey=FlagPressed))
                    then error('up '+PressBoolToStr(PressedOpenKey)+','+PressBoolToStr(PressedFlagKey)+
                            '->'+PressBoolToStr(OpenPressed)+','+PressBoolToStr(FlagPressed));
}

     if     PressedOpenKey and     PressedFlagKey and     OpenPressed and     flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and     PressedFlagKey and     OpenPressed and not flagPressed then
;
     if     PressedOpenKey and     PressedFlagKey and not OpenPressed and     flagPressed then
if (inputMode=imStd)and poleIsOpen(lx,ly) or (inputMode=imOneButtonOpen)or(inputMode=imAllInclude)
then GameEvent(lx,ly,otv,true);
     if     PressedOpenKey and     PressedFlagKey and not OpenPressed and not flagPressed then
if otv<>0
then InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed)
else if (inputMode=imStd)and poleIsOpen(lx,ly) or (inputMode=imOneButtonOpen)or(inputMode=imAllInclude)
     then GameEvent(lx,ly,otv,true);

     if     PressedOpenKey and not PressedFlagKey and     OpenPressed and     flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and not PressedFlagKey and     OpenPressed and not flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and not PressedFlagKey and not OpenPressed and     flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if     PressedOpenKey and not PressedFlagKey and not OpenPressed and not flagPressed then
if (inputMode<>imNothing)and not poleIsOpen(lx,ly) or (inputMode=imOneButtonOpen)or(inputMode=imAllInclude)
then GameEvent(lx,ly,otv,true);

     if not PressedOpenKey and     PressedFlagKey and     OpenPressed and     flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and     PressedFlagKey and     OpenPressed and not flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and     PressedFlagKey and not OpenPressed and     flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and     PressedFlagKey and not OpenPressed and not flagPressed then
;

     if not PressedOpenKey and not PressedFlagKey and     OpenPressed and     flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and not PressedFlagKey and     OpenPressed and not flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and not PressedFlagKey and not OpenPressed and     flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);
     if not PressedOpenKey and not PressedFlagKey and not OpenPressed and not flagPressed then
InputError('up',PressedOpenKey,PressedFlagKey,OpenPressed,flagPressed);

     PressedOpenKey:=OpenPressed;
     PressedFlagKey:=FlagPressed;

     outCurs(lx,ly,GetOutingMode(otv,lx,ly),otv,otv=0);
     end;
  {$ifdef begin_end}endDBG('up');{$endif}
end;

procedure move(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);
begin
  {$ifdef begin_end}beginDBG('move');{$endif}
  with igr[otv]
  do begin
     if ((PressedOpenKey<>OpenPressed) or (PressedFlagKey<>FlagPressed))
     then begin
          if otv<>0 then
              error('move '+PressBoolToStr(PressedOpenKey)+','+PressBoolToStr(PressedFlagKey)+
                            '->'+PressBoolToStr(OpenPressed)+','+PressBoolToStr(FlagPressed));
          PressedOpenKey:=OpenPressed;
          PressedFlagKey:=FlagPressed;
          end;

     outCurs(lx,ly,GetOutingMode(otv,lx,ly),otv,otv=0);
     end;
  {$ifdef begin_end}endDBG('move');{$endif}
end;

//---------------ввод с мышки-------------------------
function preobrMousePoint(var x,y: integer): boolean;
begin
  result:=(x>=otstPixL)and(y>=otstPixUp);
  if result
  then begin
       x:=(x-otstPixL) div Imagesize;
       y:=(y-otstPixUp)div ImageSize;
       result:=(x>=0)and(x<scrl)and(y>=0)and(y<scrh);
       if result
       then begin
            x:=x+scrx;
            y:=y+scry;
            end
       else begin
            if (scrx+scrl-1<l0)and(x>=scrl)
            then x:=scrx+1
            else x:=scrx;
            if (scry+scrh-1<h0)and(y>=scrh)
            then y:=scry+1
            else y:=scry;
            end;
       end
  else begin
       if (scrx>1)and(x<otstPixL)
       then x:=scrx-1
       else x:=scrx;
       if (scry>1)and(y<otstPixUp)
       then y:=scry-1
       else y:=scry;
       end;
end;
{
procedure DBGmouseKey(Shift: TShiftState);  //отладочно-выводная
begin
  if ssShift in shift
  then DBGonline(1,1,0)
  else DBGonline(1,0,0);
  if ssAlt in shift
  then DBGonline(2,1,0)
  else DBGonline(2,0,0);
  if ssCtrl in shift
  then DBGonline(3,1,0)
  else DBGonline(3,0,0);
  if ssLeft in shift
  then DBGonline(4,1,0)
  else DBGonline(4,0,0);
  if ssRight in shift
  then DBGonline(5,1,0)
  else DBGonline(5,0,0);
  if ssMiddle in shift
  then DBGonline(6,1,0)
  else DBGonline(6,0,0);
  //ssDouble
end;
}
procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
{                  //проверка работоспособности отладки
beginDBG('qwerty');
  beginDBG('zxcv');
  error('asdfg');
  endDBG;
endDBG;
CheckBeginEnd;
}

  {$ifdef logSysEvents}log('FormMouseDown');{$endif}
  {$ifdef begin_end}beginDBG('mouseDown');{$endif}
  //DBGmouseKey(shift);

  if preobrMousePoint(x,y)
  then down(0,x,y,(ssLeft in Shift)or(ssMiddle in Shift),(ssRight in Shift)or(ssMiddle in Shift));
  {$ifdef begin_end}
      endDBG('mouseDown');
      checkBeginEnd('mouseDown');
  {$endif}
end;

procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {$ifdef logSysEvents}log('FormMouseUp');{$endif}
  {$ifdef begin_end}beginDBG('mouseUp');{$endif}
  //DBGmouseKey(shift);

  if preobrMousePoint(x,y)
  then up(0,x,y,(ssLeft in Shift)or(ssMiddle in Shift),(ssRight in Shift)or(ssMiddle in Shift));
  {$ifdef begin_end}
      endDBG('mouseUp');
      checkBeginEnd('mouseUp');
  {$endif}
end;

procedure TForm1.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  {$ifdef logSysEvents}log('FormMouseMove');{$endif}
  {$ifdef begin_end}beginDBG('mouseMove');{$endif}
  {$ifdef DBGOnline}DBGOnLine;{$endif}
  //DBGmouseKey(shift);

  if preobrMousePoint(x,y)
  then move(0,x,y,(ssLeft in Shift)or(ssMiddle in Shift),(ssRight in Shift)or(ssMiddle in Shift))
  else if (x<>scrx)or(y<>scry)
       then begin
            SetScrPosition(x,y);
            EraseCurs(0);
            end;
  {$ifdef begin_end}
      endDBG('mouseMove');
      checkBeginEnd('mouseMove');
  {$endif}
end;
//-------------------ввод с клав-ы-------------------
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  {$ifdef logSysEvents}log('FormKeyDown');{$endif}
  {$ifdef begin_end}beginDBG('keyDown');{$endif}

  {$ifdef begin_end}
      endDBG('keyDown');
      checkBeginEnd('keyDown');
  {$endif}
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  {$ifdef logSysEvents}log('FormKeyUp');{$endif}
  {$ifdef begin_end}beginDBG('keyUp');{$endif}

  {$ifdef begin_end}
      endDBG('keyUp');
      checkBeginEnd('keyUp');
  {$endif}
end;

//==============================================================================
//--------ядро (,kernel типа)---------------------------------------------------
// - - - - - - - - - - стек-очередь - - - - - - - - - - - - - - - - - - - - - -
{$define dbgStack}
//{$define logStack}
//{$define DelayStack}
const lengthStack=3000;
var Stack: array[0..LengthStack]of record
                                   x,y: integer;
                                   otv: byte;
                                   end;
    Hpoint,Lpoint: integer;
    StackOwerFlow: boolean;
{$ifdef delayStack}
const
  StackDelay=1;
{$endif}
procedure ShowStack;   //отладочно-ненужная
  var i: integer;
begin
  log('--------------');
  for i:=0 to lengthStack
  do begin
     log('-'+inttostr(i)+':'+inttostr(Stack[i].x)+','+inttostr(Stack[i].y)+','+inttostr(Stack[i].otv));
     if hPoint=i
     then log('    ^Hpoint');
     if lPoint=i
     then log('    ^Lpoint');
     end;
  log('END Stack');
end;

procedure popUp(var lx,ly: integer; var lotv: byte);
begin
  with Stack[hPoint]
  do begin
     lx:=x;
     ly:=y;
     lOtv:=otv;
     end;
  if HPoint=0
  then hPoint:=LengthStack
  else dec(hPoint);
  {$ifdef logStack}
    log('('+inttostr(Hpoint)+','+inttostr(lPoint)+'):'+inttostr(lx)+','+inttostr(ly)+','+inttostr(lotv)+'- popUp');
 //   ShowStack;
  {$endif}
  {$ifdef dbgKernel}
    if not tInPole(lx,ly,'popUp('+inttostr(hPoint)+')')
    then begin
         lx:=1;
         ly:=1;
         lotv:=0;
         end;
  {$endif}
  {$ifdef DelayStack}
    delay(StackDelay);
  {$endif}
end;

procedure pushUp(lx,ly: integer; lotv: byte);
begin
  {$ifdef logStack}
    log('('+inttostr(Hpoint)+','+inttostr(lPoint)+'):'+inttostr(lx)+','+inttostr(ly)+','+inttostr(lotv)+'- pushUp');
 //   ShowStack;
  {$endif}
  {$ifdef delayStack}
    delay(StackDelay);
  {$endif}
  if hPoint=lengthStack
  then if lPoint=0
       then StackOwerFlow:=true//error('переполнение стека - PushUp')
       else begin
            hPoint:=0;
            with Stack[hPoint]
            do begin
               x:=lx;
               y:=ly;
               otv:=lotv;
               end;
            end
  else if lPoint=hPoint+1
       then StackOwerFlow:=true//error('переполнение стека - PushUp')
       else begin
            inc(hPoint);
            with Stack[hPoint]
            do begin
               x:=lx;
               y:=ly;
               otv:=lotv;
               end;
            end;
end;

procedure pushDown(lx,ly: integer; lotv: byte);
begin
  {$ifdef logStack}
    log('('+inttostr(Hpoint)+','+inttostr(lPoint)+'):'+inttostr(lx)+','+inttostr(ly)+','+inttostr(lotv)+'- pushDown');
  //  ShowStack;
  {$endif}
  {$ifdef delayStack}
    delay(StackDelay);
  {$endif}
  if lPoint=0
  then if hPoint=lengthStack
       then error('переполнение стека - PushDown')
       else begin
            lPoint:=lengthStack;
            with Stack[0]
            do begin
               x:=lx;
               y:=ly;
               otv:=lotv;
               end;
            end
  else if hPoint=lPoint-1
       then error('переполнение стека - PushDown')
       else begin
            dec(lPoint);
            with Stack[lPoint+1]
            do begin
               x:=lx;
               y:=ly;
               otv:=lotv;
               end;
            end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//{$define dbgCernel}
{const //0..8 - цифры
      cfNop  =9 ; // клетка неоткрытая
      cfFlag =10; // клетка с флагом
      cfFalseFlag=11; // клетка с неверным флагом
      cfMine =12; // клетка с миной
      cfLastMine=13; // клетка с миной, на которой подорвались
      cfOther=14;
}                   // - напоминание
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
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'SetCA')
    then exit;
  {$endif}
  SetCifra(x,y,c);
  SetAutor(x,y,a);
  outKl(x,y)
end;

function canBeOpen(x,y: integer): boolean;              //бытрые функции
begin
  result:=GetCifra(x,y)=cfNop;
end;
function isFlag(x,y: integer): boolean;
begin
  result:=GetCifra(x,y)=cfFlag;
end;
function notIsOpen(x,y: integer): boolean;
begin
  result:=not PoleIsOpen(x,y);
  //log('NotIsOpen('+inttostr(x)+','+inttostr(y)+'):'+booltostr(result));
end;
//а также PoleIsOpen(x,y);

procedure incz(x,y: integer; var z: byte);          //часто используемая для подсчета
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'incz')
    then exit;
  {$endif}
  inc(z);
  //log(inttostr(x)+','+inttostr(y)+':'+inttostr(z));
  //SetCifra(x,y,z);
  //paintKl(x,y,noVar);
end;

procedure CheckWin(otv: byte);
begin
  if nopkl=0
  then begin
       gameMode:=gmFinish;
       log('WIN '+igr[otv].name);
       end;                                                         DBGOnline;
end;
procedure detonation(x,y: integer; otv: byte);
  var lx,ly: integer;
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'detonation')
    then exit;
  {$endif}
  SetCA(x,y,cfLastMine,otv);
  for lx:=1 to l0
  do for ly:=1 to h0
     do if GetMina(lx,ly)and(GetCifra(lx,ly)<>cfLastMine)and(GetCifra(lx,ly)<>cfFlag)
        then begin
             SetCifra(lx,ly,cfMine);
             paintKlpr(lx,ly,noVar);
             end
        else if (GetCifra(lx,ly)=cfFlag)and not GetMina(lx,ly)
             then begin
                  SetCifra(lx,ly,cfFalseFlag);
                  paintKlpr(lx,ly,noVar)
                  end;
  gameMode:=gmFinish;
  log('осталось:'+inttostr(nopkl));
  DBGOnline;
end;

procedure autoFlag(x,y: integer; otv: byte);
forward;
procedure autoOpen(x,y: integer; otv: byte);
forward;
procedure auto0(x,y: integer; otv: byte);
forward;

procedure automatic(x,y: integer; otv: byte);
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'automatic')
    then exit;
  {$endif}
  {$ifdef LogKernel}
    log('AUTOMATIC:'+inttostr(x)+','+inttostr(y));
  {$endif}
  DbgOnLine;
  case AutomaticMode of
  amAllYouSelf   :;
  amAuto0        :auto0(x,y,otv);
  amAuto0andFlag :begin
                  auto0(x,y,otv);
                  autoFlag(x,y,otv);
                  end;
  amAutoOpen     :autoOpen(x,y,otv);
  amAutoAllSimple:begin
                  autoFlag(x,y,otv);//порядок не имеет значения
                  autoOpen(x,y,otv);
                  end;
  end;
end;

procedure VirtualAutomatic(x,y: integer; otv: byte);
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'virtualAutomatic')
    then exit;
  {$endif}
  {$ifdef LogKernel}
    log('VirtualAUTOMATIC:'+inttostr(x)+','+inttostr(y));
  {$endif}
  if myStack
  then if ShowAutomatic
       then if vShirElseVglub
            then pushDown(x,y,otv)
            else pushUp(x,y,otv)
       else if AutomaticInScr(x,y)
            then pushUp(x,y,otv)
            else pushDown(x,y,otv)
  else automatic(x,y,otv)
end;

procedure PutOnFlag(x,y: integer; otv: byte);
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'putOnFlag')
    then exit;
  {$endif}
  {$ifdef LogKernel}
    log('PutOnFLAG:'+inttostr(x)+','+inttostr(y));
  {$endif}
  dec(km);
  SetCA(x,y,cfFlag,otv);
  aroundKl(x,y,otv,PoleIsOpen,virtualAutomatic);
end;

procedure open(x,y: integer; otv: byte);
  var z: byte;
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'open')
    then exit;
  {$endif}
  {$ifdef LogKernel}
    log('OPEN:'+inttostr(x)+','+inttostr(y));
  {$endif}
  if GetCifra(x,y)=cfFlag
  then exit;
  if GetMina(x,y)
  then detonation(x,y,otv)
  else begin
          //log('OPEN:'+inttostr(x)+','+inttostr(y));
       z:=0;
       aroundKlvar(x,y,z,GetMina,incz);
       SetCA(x,y,z,otv);

       dec(nopkl);
       CheckWin(otv);

       virtualAutomatic(x,y,otv);
       aroundKl(x,y,otv,poleIsOpen,virtualAutomatic);
       end;
end;

procedure autoFlag(x,y: integer; otv: byte);
  var z: byte;
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'AutoFlag')
    then exit;
  {$endif}
  z:=0;
  aroundKlvar(x,y,z,notIsOpen,incz);
  {$ifdef LogKernel}
    log('AutoFlag:'+inttostr(x)+','+inttostr(y)+'('+inttostr(z)+'?'+inttostr(GetCifra(x,y))+')');
  {$endif}
  if z=GetCifra(x,y)
  then begin
       aroundKl(x,y,otv,CanBeOpen,putOnFlag);
       //log('autoFlagOk');
       end;
end;

procedure autoOpen(x,y: integer; otv: byte);
  var z: byte;
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'autoOpen')
    then exit;
  {$endif}
  z:=0;
  aroundKlvar(x,y,z,isFlag,incz);
  {$ifdef LogKernel}
    log('AutoOpen:'+inttostr(x)+','+inttostr(y)+'('+inttostr(z)+'?'+inttostr(GetCifra(x,y))+')');
  {$endif}
  if GetCifra(x,y)=z
  then aroundKl(x,y,otv,CanBeOpen,open);
end;

procedure auto0(x,y: integer; otv: byte);
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'auto0')
    then exit;
  {$endif}
  if GetCifra(x,y)=0
  then aroundKl(x,y,otv,canBeOpen,open);
end;


procedure initPole(otv: byte);//раздача мин
  var x,y,k: integer;
begin
  {$ifdef dbgKernel}
    if kolvoMin>=h0*l0
    then begin
         error('слишком много мин');
         exit;
         end;
  {$endif}
  k:=kolvomin;
  repeat
    x:=random(l0)+1;
    y:=random(h0)+1;
    if not((x=igr[otv].x)and(y=igr[otv].y)) and not GetMina(x,y)
    then begin
         SetMina(x,y,true);
         dec(k);
         end;
  until k=0;
          //стартовало время...
  GameMode:=gmGame;
end;

procedure GameEvent(x,y: integer; otv: byte; PressK1: boolean);
  function GameKey(x: boolean): string;
  begin
    if x
    then result:='LEFT'
    else result:='RIGHT';
  end;
  var lx,ly: integer;
      lotv: byte;
      Lflag: boolean;
      PromS: string;
  label 1,2;
begin
  {$ifdef dbgKernel}
    if not tInPole(x,y,'GameEvent')
    then exit;
  {$endif}
  {$ifdef begin_end}
    beginDBG('GameEvent('+inttostr(x)+','+inttostr(y)+
        ',('+inttostr(otv)+')-'+GameKey(pressK1)+')');
  {$endif}
  {$ifdef logKernel}
    log('GameEvent('+inttostr(x)+','+inttostr(y)+
        ',('+inttostr(otv)+')-'+GameKey(pressK1)+')');
  {$endif}
  StackOwerFlow:=false;
  if GameMode=gmGame then
    if PressK1
    then if poleIsOpen(x,y)
         then autoOpen(x,y,otv)
         else begin
              if CanBeopen(x,y)
              then open(x,y,otv);
              end
    else if poleIsOpen(x,y)
         then autoFlag(x,y,otv)
         else if GetCifra(x,y)=cfFlag
              then begin
                   SetCA(x,y,cfNop,otv);
                   inc(km);
                   end
              else begin
                   if CanBeOpen(x,y)
                   then if ProtectFlags
                        then begin
                             SetCA(x,y,cfFlag,otv);
                             dec(km);
                             end
                        else PutOnFlag(x,y,otv)
                   end
  else if GameMode=gmStart then
    if PressK1
    then if poleIsOpen(x,y)
         then autoOpen(x,y,otv)//невозможно
         else begin
              if CanBeopen(x,y)
              then begin
                   initPole(otv);
                   open(x,y,otv);
                   end;
              end
    else if poleIsOpen(x,y)
         then autoFlag(x,y,otv) //невозможно
         else if GetCifra(x,y)=cfFlag
              then SetCA(x,y,cfNop,otv)
              else begin
                   if CanBeOpen(x,y)
                   then if ProtectFlags
                        then SetCA(x,y,cfFlag,otv)
                        else PutOnFlag(x,y,otv)
                   end
  else ;//nothing

  PromS:=form1.Caption;
  if myStack
  then begin
       form1.Caption:=form1.Caption+' -automatic';
       while hPoint<>lPoint
       do begin
          PopUp(lx,ly,lotv);
          {$ifdef logKernel}
          //  log('promezhutochniy:'+inttostr(lx)+','+inttostr(ly)+','+inttostr(lotv));
          {$endif}
          automatic(lx,ly,lotv);
          {if hPoint mod 1000 =0
          then application.ProcessMessages;}
          end;
       end;

  if StackOwerFlow
  then repeat
         log(inttostr(nopkl)+'-nopkl');
         Lflag:=true;
         for lx:=1 to l0
         do for ly:=1 to h0
            do if poleIsOpen(lx,ly)
               then begin
                    Automatic(lx,ly,lotv);
                    if Hpoint<>lPoint
                    then goto 1;
                    end;
         goto 2;
         1:
         Lflag:=false;
         while hPoint<>lPoint
         do begin
            PopUp(lx,ly,lotv);
            automatic(lx,ly,lotv);
            end;
         2:
       until Lflag;

  form1.Caption:=PromS;
  {$ifdef begin_end}endDBG('GameEvent');{$endif}
end;
//==============================================================================
//-------------инициализация и обработчики не игровых событий-----------------------------
{$ifdef DBGOnline}
procedure InitDBGOnline(repaint: boolean);forward;
{$endif}

procedure TForm1.Button2Click(Sender: TObject);//сменить режим вывода
  var x,y: integer;
//  label 1,2,3;
begin
  if pixelPainting
  then begin
       ImageSize:=16;
       PixelPainting:=false;
       for x:=1 to l0
       do for y:=1 to h0
          do if CanBeOpen(x,y)
             then begin
                  ReSetScrSize;

                  if x<scrx
                  then scrx:=x;
                  if x-scrl+1>scrx
                  then scrx:=x-scrl+1;
                  if y<scry
                  then scry:=y;
                  if y-scrh+1>scry
                  then scry:=y-scrh+1;

                  RePaintScr;
                  exit;
                  end
       end
  else begin
       ImageSize:=1;
       PixelPainting:=true;
       SetScrPosition(1,1);
       ResetScrSize;
       end;

end;


procedure TForm1.Button1Click(Sender: TObject);  //настройки
begin
  {$ifdef logSysEvents}log('Button1Click');{$endif}
  {$ifdef begin_end}beginDBG('1Click');{$endif}
  form2.ShowModal;
  {$ifdef begin_end}
      endDBG('1Click');
      checkBeginEnd('1Click');
  {$endif}
end;


procedure TForm1.ButtonRestartClick(Sender: TObject);
  var x,y: integer;
      i: byte;
begin
  {$ifdef logSysEvents}log('ButtonRestartClick');{$endif}
  {$ifdef begin_end}beginDBG('RestartClick');{$endif}
  form3.Memo1.Lines.Add('--------LOG--------');
  {$ifdef DBGOnline}InitDBGOnline(true);{$endif}
  GameMode:=gmStart;
  for x:=1 to l0
  do for y:=1 to h0
     do begin
        SetCifra(x,y,cfnop);
        SetMina(x,y,false);
        SetAutor(x,y,noIgr);
        SetCursor(x,y,noIgr);
        end;

  for i:=0 to MaxKolvoIgr
  do ochered[i]:= i;
  for i:=0 to MaxKolvoIgr
  do with igr[i]
     do begin
        if mode=miIsDead
        then mode:=miInGame;
        end;

  km:=kolvoMin;
  kl:=h0*l0-kolvoMin;
  nopKl:=kl;

  SetScrPosition(1,1);
  if (width<1024)and(height<740)                         //развернуто-ли окно
  then begin
       if l0*imageSize+otstPixL+otstPixR<width
       then width:=l0*imageSize+otstPixL+otstPixR;
       if h0*imageSize+otstPixUp+otstPixDown<height
       then height:=h0*imageSize+otstPixUp+otstPixDown;
       end;
//  ReSetScrSize;     
  RePaintScr;
  eraseCurs(0);  //зачем?   -а не повредит
  {$ifdef begin_end}
      endDBG('RestartClick');
      checkBeginEnd('RestartClick');
  {$endif}
end;
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
  var i: integer;
begin
  Ll0            :=l0;
  Lh0            :=h0;
  LkolvoMin      :=KolvoMin;
  LAutomaticMode :=AutomaticMode;
  LMyStack       :=MyStack;
  LShowAutomatic :=ShowAutomatic;
  LProtectFlags  :=ProtectFlags;
  LvShirElseVglub:=vShirElseVglub;
  for i:=0 to MaxKolvoIgr
  do begin
     Gamers[i].Exist:=igr[i].Mode<>miNotExist;
     //Gamers[i].x:=igr[i].x;
     //Gamers[i].y:=igr[i].y;
     Gamers[i].InputMode:=igr[i].inputMode;
     Gamers[i].Keys:=igr[i].Keys;
     Gamers[i].name:=igr[i].name;
     end;
end;

function CheckSettings(Lh0,Ll0,LKolvoMin: integer;
              const Gamers: TInterfaceIgrs; var s: string): boolean;  //true - OK
  var i,j: byte;
      b: boolean;
      Lkeys: array[1..MaxKolvoIgr*6] of word;
      KeysPoint: integer;
  function PushCheck(x: word): boolean;
    var i: integer;
  begin
    inc(KeysPoint);
    LKeys[KeysPoint]:=x;
    result:=false;
    for i:=1 to KeysPoint-1
    do result:=result or (LKeys[i]=LKeys[KeysPoint]);
  end;
begin
  result:=
    (Ll0>=2)and(Ll0<=Lmax)and(Lh0>=2)and(Lh0<=Hmax)
    and(LKolvoMin>=1)and(LKolvoMin<Ll0*Lh0);

  if not result
  then begin
       s:='неверные параметры поля:'+inttostr(Ll0)+','+inttostr(Lh0)+','+inttostr(LKOlvoMin);
       exit;
       end;
  {
  b:=false;
  for i:=0 to MaxKolvoIgr
  do b:=b or Gamers[i].Exist;
  result:=not b;
  if not result
  then begin
       s:='должен существовать хотябы один игрок';
       exit;
       end;
   }
  b:=true;
  for i:=0 to MaxKolvoIgr
  do if Gamers[i].Exist
     then b:=b and (length(Gamers[i].name)<30)and(Gamers[i].name<>'');
  result:=b;
  if not result
  then begin
       s:='имена игроков должны быть непустыми и меньше 30 символов';
       exit;
       end;

  b:=true;
  for i:=0 to maxKolvoIgr
  do for j:=i+1 to MaxKolvoIgr
     do if Gamers[i].Exist and Gamers[j].Exist
        then b:=b and (Gamers[i].name<>Gamers[j].name);
  result:=b;
  if not result
  then begin
       s:='имена игроков должны быть различными';
       exit;
       end;

  b:=false;
  KeysPoint:=0;
  for i:=1 to MaxKolvoIgr
  do with Gamers[i]
     do if Exist
        then begin
             b:=b or PushCheck(keys.Up   );
             b:=b or PushCheck(keys.Down );
             b:=b or PushCheck(keys.Left );
             b:=b or PushCheck(keys.Right);
             b:=b or PushCheck(keys.Open );
             b:=b or PushCheck(keys.Flag );
             end;
  result:=not b;
  if not result
  then begin
       s:='кнопки игроков должны быть различными';
       exit;
       end;

  //Начальные координаты мышки не имеют значения
  b:=true;
  for i:=1 to MaxKolvoIgr
  do if Gamers[i].Exist
     then if Gamers[i].Exist
          then b:=b and (Gamers[i].x>=1)and(Gamers[i].x<=Ll0)and(Gamers[i].y>=1)and(Gamers[i].y<=Lh0);
  result:=b;
  if not result
  then begin
       s:='начальные позиции игроков должны быть внутри поля';
       exit;
       end;
end;

procedure SetSettings(Lh0,Ll0,LKolvoMin: integer; LAutomaticMode: TAutomaticMode;
              LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              const Gamers: TInterfaceIgrs);
  var i: byte;
      ErrS: string;
begin
  if not CheckSettings(Lh0,Ll0,LKolvoMin,Gamers,ErrS)
  then begin
       error(ErrS);
       exit;
       end;
  l0            :=Ll0;
  h0            :=Lh0;
  kolvoMin      :=LKolvoMin;
  AutomaticMode :=LAutomaticMode;
  MyStack       :=LMyStack;
  ShowAutomatic :=LShowAutomatic;
  ProtectFlags  :=LProtectFlags;
  vShirElseVglub:=LvShirElseVglub;
  for i:=0 to MaxKolvoIgr
  do if Gamers[i].exist
     then begin
          igr[i].Mode:=miInGame;
          igr[i].x:=Gamers[i].x;
          igr[i].y:=Gamers[i].y;
          igr[i].inputMode:=Gamers[i].InputMode;
          igr[i].Keys:=Gamers[i].Keys;
          igr[i].name:=Gamers[i].name;

          igr[i].PressedOpenKey:=false;
          igr[i].PressedFlagKey:=false;
          igr[i].presseds:=[];
          end
     else Igr[i].Mode:=miNotExist;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*TForm1.FormCreate(Sender: TObject);
begin
end;*)
procedure TForm1.FormShow(Sender: TObject);
begin
  logo.ShowModal;
end;

procedure InitSaper;
  var LGamers: TInterfaceIgrs;
      i: integer;
      obj: TObject;
begin
  {$ifdef logSysEvents}log('InitSaper');{$endif}
  //form3.Show;
  randomize;
  OtstPixUp:=60;
  OtstPixL:=25;//96;
  //form1.Height:=528+otstPixDown;//341;
  //form1.Width:=606;
  for i:=0 to 0
  do with LGamers[i]
     do begin
        exist:=true;
        Inputmode:=imStd;
        x:=5+i;
        y:=5+i;
        end;
  with LGamers[1].keys
  do begin
     Up    :=38;
     Down  :=40;
     Left  :=37;
     Right :=39;
     Open  :=191;
     Flag  :=190;
     end;
  with LGamers[2].keys
  do begin
     Up    :=82;
     Down  :=70;
     Left  :=68;
     Right :=71;
     Open  :=83;
     Flag  :=65;
     end;
  for i:=1 to MaxKolvoIgr
  do LGamers[i].Exist:=false;
  LGamers[0].name:='mouse';
  LGamers[1].name:='KeysFirs';
  LGamers[2].name:='KeysSecond';

  LGamers[0].InputMode:=imAllInclude;

  SetSettings(36,58,501,amAutoAllSimple,
      true,    //LMyStack
      false,   //LShowAutomatic
      false,   //LProtectFlags
      true,    //LvShirElseVglub
      LGamers);//
  obj:=form1;
  form1.ButtonRestartClick(obj);
end;
//--------------------------DBGonline--------------------------------------
procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked
  then form3.Show
  else form3.Close;
end;

{
1 . . . .
2 . . . .
3 . .
4 . .
5 . .
6 . .
7 .   . .
8 .   . .
9 .   . .
10.   . .
}
{$ifdef DBGOnline}
var dbgcount: integer;
    RepaintOn: boolean;
procedure DBGOnLine;
begin
with form3
do begin
   Labels[1,7].Caption:='V-cntdbg';
   inc(dbgcount);
   Labels[1,8].Caption:=inttostr(dbgcount);
   Labels[1,8].Repaint;//всегда!!!

   Labels[1,1].Caption:='V-scrl';
   Labels[2,1].Caption:='V-scrh';
   Labels[1,2].Caption:=inttostr(scrl);
   labels[2,2].Caption:=inttostr(scrh);

   Labels[1,3].Caption:='V-scrx';
   Labels[2,3].Caption:='V-scry';
   labels[1,4].Caption:=inttostr(scrx);
   labels[2,4].Caption:=inttostr(scry);

   Labels[3,1].Caption:='km ->';
   labels[4,1].Caption:=inttostr(km);
   Labels[3,2].Caption:='nopkl ->';
   labels[4,2].Caption:=inttostr(nopkl);

   Labels[4,7].Caption:='V-стек';
   labels[4,8].Caption:=inttostr(HPoint)+'     ';//пробелы нужны, чтобы затирать старое
   labels[4,9].Caption:=inttostr(LPoint)+'     ';
   if HPoint>=Lpoint
   then labels[4,10].Caption:=inttostr(HPoint-Lpoint)+'     '
   else labels[4,10].Caption:=inttostr(LengthStack-(LPoint-HPoint))+'     ';

   with form1.ScrollBarV
   do begin
      Labels[3,7].Caption:='V-В.линейка';
      Labels[3,8].Caption:=inttostr(max     )+'     ';
      Labels[3,9].Caption:=inttostr(PageSize)+'     ';
      Labels[3,10].Caption:=inttostr(Position)+'     ';
      if repaintOn then
        begin
        Labels[3,8].Repaint;
        Labels[3,9].Repaint;
        Labels[3,10].Repaint;
        end;
      end;
   //max PageSize Position

   //log(label18.Caption+label19.Caption+label20.Caption);
   if (Hpoint mod 100=0)and repaintOn then
     begin
     labels[4,7].Repaint;
     labels[4,8].Repaint;
     labels[4,9].Repaint;
     labels[4,10].Repaint;
     //labels[].Repaint;
     end;
   //GroupBox1.Repaint;
   //application.ProcessMessages;
  end;
end;
var countRePaint,countOut0: integer;

procedure OnlineDbgRePaint;
begin
  DBGOnLine;
with form3
do begin
   inc(CountRePaint);
   Labels[1,10].Caption:='RePaint:';
   labels[2,10].Caption:=inttostr(CountRePaint);
   end;
end;
procedure onlineDBGOutCurs(lx,ly: integer);
begin
with form3
do begin
   Labels[1,5].Caption:='V-курсор-V';
   Labels[2,5].Caption:='';
   labels[1,6].Caption:=inttostr(lx);
   labels[2,6].Caption:=inttostr(ly);
   end;
end;

procedure InitDBGOnline(repaint: boolean);
begin
  RepaintOn:=repaint;
  dbgcount:=0;
  countrepaint:=0;
  countOut0:=0;
end;
{$endif}

(*    - советовали использовать
{**** UBPFD *********** by delphibase.endimus.com ****
>> Замена штатного Application.ProcessMessages
Автор:       ssk, ucad@pisem.net, ICQ:166758074, Харьков
Copyright:   составлено из кусков кода Borland
Дата:        7 сентября 2004 г.
*****************************************************}
Uses Windows, Messages
procedure ProcessMessagesEx;
  function IsKeyMsg(var Msg: TMsg): Boolean;
    const
      CN_BASE = $BC00;
    var
      Wnd: HWND;
  begin
    Result:= false;
    with Msg do if
      (Message >= WM_KEYFIRST) and
      (Message <= WM_KEYLAST) then
    begin
      Wnd:= GetCapture;
      if Wnd = 0 then
        begin
        Wnd:= HWnd;
        if SendMessage(Wnd,CN_BASE+Message,WParam,LParam) <> 0 then
          Result:= true;
        end else
          if (LongWord(GetWindowLong(Wnd,GWL_HINSTANCE)) = HInstance) then
            if SendMessage(Wnd, CN_BASE + Message, WParam, LParam) <> 0 then
              Result:= true;
    end;
  end;
  function ProcessMessage(var Msg: TMsg): Boolean;
  begin
    Result:= false;
    if PeekMessage(Msg,0,0,0,PM_REMOVE) then
      begin
      Result:= true;
      if Msg.Message <> WM_QUIT then
        if not IsKeyMsg(Msg) then
          begin
          TranslateMessage(Msg);
          DispatchMessage(Msg);
          end;
      end;
  end;
  var
    Msg: TMsg;
begin
  while ProcessMessage(Msg) do {loop};
end;*)

//==============================================================================
//===============================содержание(31.12.10)===========================
(*
//---------------управление-------------                                        (78)
//---------------отладочные-----------------                                    (87)
procedure error(s: string);
procedure log(s: string);
procedure DBGOnLine(n,x,y: integer);
forward;
//------------поисково-отладочные---------------                                (110)
var dbgObj: Tobject;
{$ifdef begin_end}
procedure beginDBG(s: string);
procedure endDBG(s: string);
procedure checkBeginEnd(x: Tobject; s: string);
//------------глобально-примитивные-------------                                (134)
function minim(a,b: integer): integer;
function max(a,b: integer): integer;
function booltoStr(x: boolean):string;
  //отладка выше работает
  //чтение переменных разрешено везде, ниже их описания, а запись - указано
//==============================================================================(153)
//--------база сапера--------------------
var GameMode: TGameMode;
  //ядро и инициализация
const //0..8 cfNop  =9; cfFlag =10; cfFalseFlag=11; cfMine =12; cfLastMine=13; cfOther=14;
const hmax=1024;  lmax=1024;
var pole: array[1..lmax,1..hmax] of Tkletka;  h0,l0: integer;
  //ниже свойства                            ;  инициализация
function tInPole(x,y: integer; s: string):boolean;//отладо-проверочная
    function existIgr(n: byte; s: string): boolean;//отладочно-проверочная
    forward;   {$ifdef dbgBase}
    function goodIgr(n: byte; noIgrIsGood: boolean ; s: string): boolean; //отладочно-проверочная
    forward;   {$ifdef dbgBase}
function GetMina(x,y: integer): boolean;                                      (191)
function GetCifra(x,y: integer): byte;
function GetAutor(x,y: integer): byte;                   //goodIgr...
function GetCursor(x,y: integer): byte;

procedure SetMina(x,y: integer; m: boolean);                                  (218)
procedure SetCifra(x,y: integer; z: byte);
procedure SetAutor(x,y: integer; z: byte);
procedure SetCursor(x,y: integer; z: byte);

function PoleIsOpen(x,y: integer): boolean;
  //часто юзается
//------------around-------------------------------------------                 (268)
  //просто оч. полезные процедуры
procedure aroundKl(x,y: integer; data: byte; detect: kldetect; doing: kldoing);
procedure aroundKlvar(x,y: integer; var data: byte; detect: kldetect; doing: kldoingVar);
function All(x,y: integer): boolean;      const NoVar=0;
//==============================================================================(326)
//----------------игроки-курсоры------------------------------------------------
type TModeIgr=(migrIsDead,migrInGame,migrNotExist);//Exist - существует
     TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude);
     TPressedKeys=set of(pkUp,pkDown,pkLeft,pkRight,  pkOpen,pkFlag,pkMiddle);
     TOutingMode=(omSimple,omPressed,omSuperPressed);
  TIgrok=record
            Mode: TModeIgr;
  //ядро и инициализация
            x,y: integer; Outing: TOutingMode;
  //только вывод курсоров
            InputMode: TInputMode;  PressedOpenKey,PressedFlagKey: boolean;
  //инииализация                    ;  ввод
            KeyUp,KeyDown,KeyLeft,KeyRight,KeyO,KeyF: word;
  //инициализация
            presseds: TPressedKeys;  end;
  //ввод
const noIgr=16-1;    maxKolvoIgr=noIgr-1;
var Igr: array[0..maxKolvoIgr]of TIgrok;//0 - мышь, остальные - клава
    ochered: array[0..maxKolvoIgr]of byte;  //0-е место - верх
function goodIgr(n: byte; noIgrIsGood: boolean ; s: string): boolean; //отладочно-проверочная(347)
function existIgr(n: byte; s: string): boolean;   //отладочно проверочная
procedure IgrNaVerh(n: byte);//n-игрок
//-------------вывод-------------------------------------                       (383)
var scrh,scrl: integer;  scrx,scry: integer; const otst=2;
  //только в FormResize  ; везде
var otstPixL,otstPixUp: integer; const otstPixDown=45;  otstPixR=26;  ImageSize=16;
  //только в formCreate
/////////////////////////////независимый//
procedure out0(x,y: integer; n: byte); // в координатах экрана, не проверяет в экране точка, или нет
  //выводит на экран с координатами x,y отн. экрана в клетках n-ую картинку из imageList
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function tInScr(x,y: integer):boolean;//interface                             (409)
  //проверят, в экране ли точка (на основании h0,l0,scrx,scry,scrh,scrl)
function CursInScr(x,y: integer): boolean; //interface
  //проверяет в экране ли с отступом точка (на основании h0,l0,scrx,scry,scrh,scrl)
function WhatOut(x,y: integer): byte;
  //на основании цифры этой клетки, ее автора(...) и режима вывода курсора, который там стоит
  //вычисляет, какую картинку из imageList надо вывести в сответствии с этой клеткой
procedure paintKl(x,y: integer; data: byte);                                  (463)
  //выводит на экран клетку с кординатами x,y отн. поля (в экране ли точка - не проверяет)
procedure paintKlpr(x,y: integer; data: byte);
  //выводит на экран клетку с кординатами x,y отн. поля (в экране ли точка - проверяет)
procedure TForm1.FormPaint(Sender: TObject);//interface                       (491)
  //перерисовывает весь экран и меняет бегунки у линеек в соответствии со scrx,scry
procedure outKl(x,y: integer); //interface
  //если клетка в экране - paintKl, иначе сделать так, чтобы клетка оказалась в эране, и formPaint
//  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\\(557)
function  GetOutingMode(n: byte; lx,ly: integer): TOutingMode;
  //для n-ого игрока: на основании режима игры и игрока, его режима ввода и нажатых клавиш,
  //вычисляет вид вывода игрока, еслибы он находился в клетке с координатами lx,ly
var formRepaint: boolean;    OutPoint: byte;
    ChengedKl: array[1..16*9]of record  x,y: integer;      end;
procedure vPaintCurs(x,y: integer; n: byte);                                  (586)
  //локальная, снаружи НЕ ВЫЗЫВАТЬ, как и пред. переменные
procedure OutCurs(lx,ly: integer; outingMode: TOutingMode; n: byte; maskRepaint: boolean); //interface(636)
  //выводит курсор в новом месте с заданным режимом вывода,(в старом месте затирает, все как положено)
procedure eraseCurs(n: byte);                                                 (699)
  //затирает курсор в старом месте(как положено)
//\\  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -// (742)
procedure TForm1.ScrollBarGChange(Sender: TObject);
procedure TForm1.ScrollBarVChange(Sender: TObject);
procedure TForm1.FormResize(Sender: TObject);//use onli for formResize(sys events)
  //события - НЕ ВЫЗЫВАТЬ
//==============================================================================(805)
//-------------------общий ввод-------------------------------------------------
procedure GameEvent(x,y: integer; otv: byte; PressK1{else pressedK2}: boolean);
forward;
function PressBoolToStr(x: boolean): string;  //отладочно-выводная
procedure down(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);  (834)
procedure Up(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);    (867)
procedure move(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);  (904)
//---------------ввод с мышки-------------------------                          (923)
function preobrMousePoint(var x,y: integer): boolean;
procedure DBGmouseKey(Shift: TShiftState);  //отладочно-выводная
procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;         (971)
procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
procedure TForm1.FormMouseMove(Sender: TObject;
//-------------------ввод с клав-ы-------------------...                        (1025)
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
//==============================================================================(1048)
//--------ядро (,kernel типа)---------------------------------------------------
procedure PutOnFlag(x,y: integer; otv: byte);
procedure PutOffFlag(x,y: integer; otv: byte);
procedure open(x,y: integer; otv: byte);
procedure autoFlag(x,y: integer; otv: byte);
procedure autoOpen(x,y: integer; otv: byte);

procedure GameEvent(x,y: integer; otv: byte; PressK1: boolean);
//==============================================================================(1115)
//-------------инициализация и прочее-------------------------------------------
procedure TForm1.Button1Click(Sender: TObject);
procedure TForm1.ButtonRestartClick(Sender: TObject);
procedure TForm1.FormCreate(Sender: TObject);                                 (1194)

procedure DBGOnLine(n,x,y: integer);

*)

//==============================================================================
//===============================содержание(09.01.11)===========================
(*
interface;
const hmax=1024;     lmax=1024;
const noIgr=16-1;    maxKolvoIgr=noIgr-1;
type TInputMode=(imNothing,imOnlyOpen,imNonFlag,imStd,imOneButtonOpen,imAllInclude);
     TAutomaticMode=(amAllYouSelf,amAuto0,amAutoOpen,amAutoAll);
     TKeys=record     Up,Down,Left,Right,Open,Flag: word;     end;
     TInterfaceIgrs=array[0..maxKolvoIgr]of
     record  x,y: integer; inputMode: TinputMode;  Exist: boolean;   keys: TKeys;   name: string;  end;
procedure GetSettings(var Lh0,Ll0,LKolvoMin: integer; var LAutomaticMode: TAutomaticMode;
              var LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              var Gamers: TInterfaceIgrs);
function CheckSettings(Lh0,Ll0,LKolvoMin: integer;
              const Gamers: TInterfaceIgrs; var s: string): boolean;
procedure SetSettings(Lh0,Ll0,LKolvoMin: integer; LAutomaticMode: TAutomaticMode;
              LMyStack,LShowAutomatic,LProtectFlags,LvShirElseVglub: boolean;
              const Gamers: TInterfaceIgrs);
implementation;
//---------------управление-------------
//------------глобально-примитивные-------------
function minim(a,b: integer): integer;
function max(a,b: integer): integer;
function booltoStr(x: boolean):string;
procedure delay(x: integer);
//---------------отладочные-----------------
procedure error(s: string);
procedure log(s: string);
{$ifdef dbgonline}
forward;procedure dbgOnLine;
forward;procedure onlineDbgOut0(x,y: integer);
forward;procedure OnlineDbgFormPaint;
forward;procedure onlineDBGOutCurs(lx,ly: integer);
{$endif}
//------------поисково-отладочные---------------{$ifdef begin_end}\dbgObj
var dbgObj: Tobject;
procedure beginDBG(s: string);
procedure endDBG(s: string);
procedure checkBeginEnd(x: Tobject; s: string);
//==============================================================================
//--------база сапера--------------------
type TGameMode=(gmStart,gmGame,gmFinish);var GameMode: TGameMode;
type Tkletka=record  num,otv: byte;    end;
const cfNop  =9 ; cfFlag =10; cfFalseFlag=11; cfMine =12; cfLastMine=13; cfOther=14;
//const hmax=1024; lmax=1024; - interface
var pole: array[1..lmax,1..hmax] of Tkletka;    h0,l0: integer;
function tInPole(x,y: integer; s: string):boolean;//отладо-проверочная
{$ifdef dbgBase}
    forward;    function existIgr(n: byte; s: string): boolean;//отладочно-проверочная
    forward;    function goodIgr(n: byte; noIgrIsGood: boolean ; s: string): boolean; //отладочно-проверочная
{$endif}
function GetMina(x,y: integer): boolean;
function GetCifra(x,y: integer): byte;
function GetAutor(x,y: integer): byte;                   //goodIgr...
function GetCursor(x,y: integer): byte;
procedure SetMina(x,y: integer; m: boolean);
procedure SetCifra(x,y: integer; z: byte);
procedure SetAutor(x,y: integer; z: byte);
procedure SetCursor(x,y: integer; z: byte);
function PoleIsOpen(x,y: integer): boolean;
//------------around-------------------------------------------
procedure aroundKl(x,y: integer; data: byte; detect: kldetect; doing: kldoing);
procedure aroundKlvar(x,y: integer; var data: byte; detect: kldetect; doing: kldoingVar);
function All(x,y: integer): boolean; const NoVar=0;
//==============================================================================
//----------------игроки-курсоры------------------------------------------------
type TModeIgr=(migrIsDead,migrInGame,migrNotExist);//Exist - существует
     TOutingMode=(omSimple,omPressed,omSuperPressed);
     TPressedKeys=set of(pkUp,pkDown,pkLeft,pkRight,  pkOpen,pkFlag,pkMiddle);
{     TKeys=record...end;} //-interface
     TIgrok=record
            Mode: TModeIgr;
            x,y: integer;  Outing: TOutingMode;
            InputMode: TInputMode;   PressedOpenKey,PressedFlagKey: boolean;
            keys: TKeys;     presseds: TPressedKeys;
            name: string;
            end;
//const noIgr=16-1; maxKolvoIgr=noIgr-1; - interface
var Igr: array[0..maxKolvoIgr]of TIgrok;
    ochered: array[0..maxKolvoIgr]of byte;
function goodIgr(n: byte; noIgrIsGood: boolean ; s: string): boolean; //отладочно-проверочная
function existIgr(n: byte; s: string): boolean;   //отладочно проверочная
procedure IgrNaVerh(n: byte);//n-игрок
//-------------вывод-------------------------------------
var scrh,scrl: integer;    scrx,scry: integer; const otst=2;
var otstPixL,otstPixUp: integer; ImageSize: integer=16;  PixelPainting: boolean=false;
const otstPixDown=45+20;    otstPixR=26+20;
/////////////////////////////независимый//
procedure out0(x,y: integer; n: integer); // в координатах экрана, не проверяет в экране точка, или нет
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function tInScr(x,y: integer):boolean;//interface
function WhatOut(x,y: integer): integer;
procedure paintKl(x,y: integer; data: byte);
procedure paintKlpr(x,y: integer; data: byte);

procedure TForm1.FormPaint(Sender: TObject);//interface
procedure TForm1.FormResize(Sender: TObject);//use onli for formResize(sys events)
procedure TForm1.ScrollBarGChange(Sender: TObject);
procedure TForm1.ScrollBarVChange(Sender: TObject);

procedure outKl(x,y: integer); //interface
//  - - - - - - - - - - - -изменение курсоров - - - - - - - - - - - - - - - -\\
var formRepaint: boolean;    OutPoint: byte;
    ChengedKl: array[1..16*9]of record    x,y: integer;    past,futur: byte;    end;
procedure vPaintCurs(x,y: integer; n: byte);
procedure OutCurs(lx,ly: integer; outingMode: TOutingMode; n: byte; maskRepaint: boolean); //interface
procedure eraseCurs(n: byte);
//\\  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -//
//==============================================================================
//-------------------общий ввод-------------------------------------------------
forward; procedure GameEvent(x,y: integer; otv: byte; PressK1{else pressedK2}: boolean);
function  GetOutingMode(n: byte; lx,ly: integer): TOutingMode;
function PressBoolToStr(x: boolean): string;  //отладочно-выводная
procedure InputError(s: string; a,b,c,d: boolean);//отладочно-выводная
procedure down(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);
procedure Up(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);
procedure move(otv: byte; lx,ly: integer; OpenPressed,FlagPressed: boolean);
//---------------ввод с мышки-------------------------
function preobrMousePoint(var x,y: integer): boolean;
{procedure DBGmouseKey(Shift: TShiftState);  //отладочно-выводная}
procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
procedure TForm1.FormMouseMove(Sender: TObject;
//-------------------ввод с клав-ы-------------------
procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
//==============================================================================
//--------ядро (,kernel типа)---------------------------------------------------
// - - - - - - - - - - стек- - - - - - - - - - - - - - - - - - - - - - - - - -
{$}
const lengthStack=3000;
var Stack: array[0..LengthStack]of record  x,y: integer;   otv: byte;   end;
    Hpoint,Lpoint: integer;   StackOwerFlow: boolean;
const  StackDelay=1; {$ifdef delayStack}
procedure ShowStack;   //отладочно-ненужная
procedure popUp(var lx,ly: integer; var lotv: byte);
procedure pushUp(lx,ly: integer; lotv: byte);
procedure pushDown(lx,ly: integer; lotv: byte);
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$}
var autoMaticMode: TAutomaticMode;
    KolvoMin,km: integer;
    kl,nopkl: integer;
    MyStack,ShowAutomatic,ProtectFlags,VShirElseVGlub: boolean;
procedure SetCA(x,y: integer; c,a: byte);  //переопроеделение свойств
function canBeOpen(x,y: integer): boolean;
function isFlag(x,y: integer): boolean;
function notIsOpen(x,y: integer): boolean;
procedure incz(x,y: integer; var z: byte);//часто используемая для подсчета
procedure CheckWin(otv: byte);
procedure detonation(x,y: integer; otv: byte);
forward;procedure autoFlag(x,y: integer; otv: byte);
forward;procedure autoOpen(x,y: integer; otv: byte);
forward;procedure auto0(x,y: integer; otv: byte);
procedure automatic(x,y: integer; otv: byte);
procedure VirtualAutomatic(x,y: integer; otv: byte);
procedure PutOnFlag(x,y: integer; otv: byte);
procedure open(x,y: integer; otv: byte);
procedure autoFlag(x,y: integer; otv: byte);
procedure autoOpen(x,y: integer; otv: byte);
procedure auto0(x,y: integer; otv: byte);
procedure initPole(otv: byte);//раздача мин
procedure GameEvent(x,y: integer; otv: byte; PressK1: boolean);
//==============================================================================
//-------------инициализация и обработчики не игровых событий-----------------------------
procedure TForm1.Button2Click(Sender: TObject);
procedure TForm1.Button1Click(Sender: TObject);
procedure TForm1.ButtonRestartClick(Sender: TObject);
//- - - - - - - - - - - - - - - interface- - - - - - - - - - - - - - - - - - - -
procedure GetSettings(var Lh0,Ll0,LKolvoMin: integer; var LAutomaticMode: TAutomaticMode;...
function CheckSettings(Lh0,Ll0,LKolvoMin: integer;...
procedure SetSettings(Lh0,Ll0,LKolvoMin: integer; LAutomaticMode: TAutomaticMode;...
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TForm1.FormCreate(Sender: TObject);
//--------------------------DBGonline--------------------------------------{$ifdef DBGOnline}
procedure DBGOnLine;
var countFormPaint,countOut0: integer;
procedure onlineDbgOut0(x,y: integer);
procedure OnlineDbgFormPaint;
procedure onlineDBGOutCurs(lx,ly: integer);                                     (2130)
*)
end.



