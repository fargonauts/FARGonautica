unit ActivationTester;

interface

uses
  Activation1Unit,

  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    procedure Button1Click(Sender: TObject);
    procedure ActDraw;
    Procedure ActMemo;
    procedure Drawsizes;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  maxactivation:integer;
  Act, a1, a2, a3, a4, a5: TActivation;

implementation

{$R *.dfm}


Procedure Tform1.ActMemo;
var x:integer;  y: real;
s1, s2: string;
begin
     for x:= 1 to maxactivation do
     begin
          Act.increase(1);
          y:= Act.Get_Level;

          str(y:4:4, s1);
          str(x,s2);

          s1:= s1+ '  ' + s2;
          memo1.Lines.Add(s1) ;
     end;
end;

Procedure TForm1.DrawSizes;
var x:integer;
begin
     x:=round(a1.Get_Level);
     Shape1.height:=x; Shape1.Width:=x;
     x:=round(a2.Get_Level);
     Shape2.height:=x; Shape2.Width:=x;
     x:=round(a3.Get_Level);
     Shape3.height:=x; Shape3.Width:=x;
     x:=round(a4.Get_Level);
     Shape4.height:=x; Shape4.Width:=x;
     x:=round(a5.Get_Level);
     Shape5.height:=x; Shape5.Width:=x;

     form1.Refresh; 
end;

Procedure TForm1.ActDraw;
begin
     a1:=tactivation.Create(maxactivation);
     a2:=tactivation.Create(maxactivation);
     a3:=tactivation.Create(maxactivation);
     a4:=tactivation.Create(maxactivation);
     a5:=tactivation.Create(maxactivation);
     //TODO -oLinhares: make concepts vanish (implementing decay in the meantime)

     a1.increase(0);
     a2.increase(round(0.25*maxactivation));
     a3.increase(round(0.50*maxactivation));
     a4.increase(round(0.75*maxactivation));
     a5.increase(maxactivation);

     DrawSizes;

     while (a1.Get_Level+a2.Get_Level+a3.Get_Level+a4.Get_Level+a5.Get_Level>0) do
     begin
          a1.decay;
          a2.decay;
          a3.decay;
          a4.decay;
          a5.decay;

          Drawsizes;
     end;
end;



procedure TForm1.Button1Click(Sender: TObject);
begin
     maxactivation:=100;
     Act:=Tactivation.Create (maxactivation);
     Actmemo;
     ActDraw;
end;




end.
