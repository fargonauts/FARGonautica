unit ExternalMemoryClass;

interface

uses ChunkTheoryUnit;

type
    TExt_Mem= Class
        bricks: array[1..5] of integer;
        taken: array[1..5] of boolean;
        target, FreeBricks: integer;
        Constructor create;
    end;
                                           

var ExtMem:TExt_Mem;

implementation

Constructor TExt_Mem.create;
begin


 //FCCA 1    "6x20" problem
 bricks[1] := 6; bricks[2] := 1; bricks[3] := 7; bricks[4] := 20; bricks[5] := 11; target := 114;

 //FCCA 2
 bricks[1] := 8; bricks[2] := 3; bricks[3] := 7; bricks[4] := 10;  bricks[5] := 9;  target := 87;

 //FCCA 3
 bricks[1] := 3; bricks[2] := 5; bricks[3] := 24; bricks[4] := 3;  bricks[5] := 14;  target := 31;

 //FCCA 4
 bricks[1] := 5; bricks[2] := 8; bricks[3] := 5; bricks[4] := 11;  bricks[5] := 2;  target := 25;

 //FCCA 5    "6x17" problem   VERY PROBLEMATIC
 bricks[1] := 6; bricks[2] := 17; bricks[3] := 2; bricks[4] := 1;  bricks[5] := 4;  target := 102;

 //FCCA 6
 bricks[1] := 12; bricks[2] := 2; bricks[3] := 5; bricks[4] := 7;  bricks[5] := 18;  target := 146;

 //FCCA 7    goes in loop...
 //bricks[1] := 3; bricks[2] := 3; bricks[3] := 17; bricks[4] := 11;  bricks[5] := 22;  target := 6;

 //FCCA 8    OOOOHHHH Order os creation in the slipnet put 11 and 110 close!!!
 bricks[1] := 2; bricks[2] := 5; bricks[3] := 1; bricks[4] := 25;  bricks[5] := 23;  target := 11;

 //FCCA 9     Horrible!!!!
 bricks[1] := 20; bricks[2] := 2; bricks[3] := 16; bricks[4] := 14;  bricks[5] := 6;  target := 116;

 //FCCA 10    solve others first...
 bricks[1] := 6; bricks[2] := 4; bricks[3] := 22; bricks[4] := 5;  bricks[5] := 7;  target := 127;

 //FCCA 11
 bricks[1] := 5; bricks[2] := 16; bricks[3] := 22; bricks[4] := 25;  bricks[5] := 1;  target := 41;

 //Test problem
 //bricks[1] := 5; bricks[2] := 3; bricks[3] := 7; bricks[4] := 1;  bricks[5] := 2;  target := 49;

  taken[1]:=false;
  taken[2]:=false;
  taken[3]:=false;
  taken[4]:=false;
  taken[5]:=false;
  FreeBricks:=5;


end;




end.
