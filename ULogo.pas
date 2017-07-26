unit ULogo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TLogo = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Logo: TLogo;

implementation

{$R *.dfm}

procedure TLogo.Timer1Timer(Sender: TObject);
begin
  close;
end;

procedure TLogo.FormKeyPress(Sender: TObject; var Key: Char);
begin
  close;
end;

procedure TLogo.FormClick(Sender: TObject);
begin
  close;
end;

procedure TLogo.Image1Click(Sender: TObject);
begin
  close;
end;

end.
