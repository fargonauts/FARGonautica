unit NumboConnotations;

interface

uses ExternalMemoryClass, FARG_Framework_Chunk, classes, graphics;

type
  TMultiplication=class;

  TNumber = Class (TValue)
      Value: integer;
      Constructor Create;
      Function GetValue: integer;  virtual; 
      Function ExactValueCheck(N:TValue):boolean; override;
  End;

  TString = class (TValue)
    Value: String;
    Function GetValue: string; overload;  virtual;
    Function ExactValueCheck (N:TValue): boolean; override; {maybe create a class similarity type??}
  end;

  TBitmapView = Class (TValue)
    Bitmap: TBitmap;
    Function GetValue: TBitmap; overload; virtual;
  End;

  TBrick = Class (TNumber)
    Procedure SearchForInstance; override;
  End;

  TTarget = Class (TNumber)
    Procedure SearchForInstance; Override;
  End;

  TResult = Class (TNumber)
    Procedure SearchForInstance; Override;
  End;

  TOperations = class (TRelation)
  public
    Function ConditionsAreSatisfied: boolean; override;
    Procedure GetAcceptableConnotationsTypes; override;
    Function ComputeRelation (RelatedItems: TList):TList;override;
    Function Compute (N1, N2: TNumber):TResult; virtual; abstract;
  end;

  TStringName = class (TRelation)
  public
    Name: TString;
    Function ConditionsAreSatisfied: boolean; override;
    Procedure GetAcceptableConnotationsTypes; override;
    Function ComputeRelation (RelatedItems: TList):TList;override;
    Function Compute (C: TChunk):TString; overload;
    Function Compute (C: TNumber):TString; overload;
    Function Compute (C: TMultiplication):TString; overload;
    Function GetStringLength: integer;
  end;

(*  TChunkTopology = class (TRelation)
    Width, Depth: TNumber;
    ConnotationsInLevel: TList {of TNumber};
    Level:integer;

    Function ConditionsAreSatisfied: boolean; override;
    Procedure GetAcceptableConnotationsTypes; override;
    Function ComputeRelation (RelatedItems: TList):TList;override;
    Function GetNumConnotationsInLevel(C:TChunk): integer;
    Function GetStringLength: integer;

  end;*)


  TBitmapCreator = class (TRelation)
  public
    Bitmap: TBitMapView;
    Function ConditionsAreSatisfied: boolean; override;
    Procedure GetAcceptableConnotationsTypes; override;
    Function ComputeRelation (RelatedItems: TList):TList;override;
    Function Compute (C: TChunk):TBitmapView; overload;
    Function Compute (C: TNumber):TBitmapView; overload;
    Function Compute (C: TMultiplication):TBitmapView; overload;
  end;


  TMultiplication = class (TOperations)
    Function Compute (N1, N2: TNumber):TResult; override;
  end;



implementation
{
Here's an idea: perhaps we could have even TIncognita from TNumber, which might strugle between
top-down desires and bottom-up information.  Moreover, perhaps, instead of incognita
we should have a class named "Template", and a subclass named "CuriousTemplate",
which should apply the IDEA behind incognita to any type of abstraction--a simple
number, a simple operation, a letter string, a chunk in chess, etc.

I guess the best road to this is to implement incognita, then refactor the code for a class
template, and then curioustemplate.  By implementing curiousincognita, we will know how template
works much better.

The drawback?  More work now than simply doing NUMBO...
}


{ TNumber }

Constructor TNumber.create;
begin
    State:=Propose;
end;

function TNumber.ExactValueCheck(N: TValue): boolean;
begin
   {TypeCast Needed to escape abstract error}
   result:= (TNumber(N).GetValue=GetValue);
end;

function TNumber.GetValue: integer;
begin
    result:=Value;
end;

{ TBrick }

procedure TBrick.SearchForInstance;
var x: integer;
begin
     x:= random(5)+1;
     {number coming from external memory}
     if not ExtMem.taken[x] then
        begin
            Value:=extmem.bricks[x]; {FLAG: duplicate code with TTarget.SearchForInstance}
            Relevance:=1;
            State:= Propose;        {call TResult.create; if it is TResult...}

            ExtMem.taken[x]:=true;
            ExtMem.FreeBricks:=ExtMem.FreeBricks-1;
        end;
end;


{ TTarget }
procedure TTarget.SearchForInstance;
begin
     Value:=extmem.target;   {FLAG: duplicate code with TBrick.SearchForInstance}
     Relevance:=1;
     State:=Propose;
end;

{ TResult }

procedure TResult.SearchForInstance;
begin

end;

{ TOperation }
Function TOperations.ConditionsAreSatisfied: boolean;
begin
  result:= (Elements.Count>1);
end;


procedure TOperations.GetAcceptableConnotationsTypes;
begin
    AcceptableConnotations:=Tlist.Create;
    AcceptableConnotations.add(TBrick);
    AcceptableConnotations.add(TResult);
end;


function TOperations.ComputeRelation(RelatedItems: TList): TList;
var R: TResult; O1,O2: TObject; N1, N2: TNumber;
begin
    {ComputeValue makes a downcast to typenumber--multiplication methods know
    that they are working with numbers, after all, so no problem in coding to
    an implementation here}
    O1:=RelatedItems.Items[0];  {Change to a Get method, obviously}
    O2:=RelatedItems.Items[1];  {Don't code to implementation!}

    if O1.ClassType=TChunk then
    begin
      N1:=TResult(TChunk(O1).GetConnotationOfType(TResult));
    end else N1:=TNumber(O1);

    if O2.ClassType=TChunk then
    begin
      N2:=TResult(TChunk(O2).GetConnotationOfType(TResult)) ;
    end else N2:=TNumber(O2);

    R:=Compute(N1,N2);

    {RelatedItems.add(R);}
    NewElements.Add(R);

    result:= RelatedItems;
end;

{ TMultiplication }
Function TMultiplication.Compute(N1,N2:TNumber):TResult;
var N3: TResult;
begin
  N3:=TResult.Create;
  N3.Value:= (N1.GetValue) * (N2.GetValue);
  result:= N3;
end;



{ TString }

function TString.ExactValueCheck(N: TValue): boolean;
begin
   {TypeCast Needed to escape abstract error}
   result:= (TString(N).GetValue=GetValue);
end;

function TString.GetValue: string;
begin
     result:=Value;
end;


{ TStringName }
function TStringName.Compute(C: TNumber): TString;
Var R: TString; S:String;
begin
    Str(C.Value, S);
    R:=TString.Create;
    R.Value:=S;
    Result:=R;
end;


function TStringName.Compute(C: TChunk): TString;
Var R: TString; S, S2:String; N:TNumber; O:TConnotation; I:integer;
begin
    R:=TString.Create;
    S:='(';
    for I := 0 to C.Elements.Count - 1 do
    begin
      O:=C.Elements.items[i];
      if (O.ClassType=TMultiplication) then
      begin
          R:=Compute(TMultiplication(O));
            S:=S+R.Value;
      end;
      S:=S+S2;
    end;
    S:=S+')';
    R.Value:=S;
    result:=R;
end;


function TStringName.Compute(C: TMultiplication): TString;
Var R: TString; S, S2:String; N:TNumber; O:TConnotation; I:integer;
begin
    R:=TString.Create;
    for I := 0 to C.Elements.Count - 1 do
    begin
      O:=C.Elements.items[i];
      if (O.ClassParent=TNumber) and (O.ClassType<>TResult) then
      begin
          R:=Compute(TNumber(O));
          S:=S+R.Value;
      end else
      if (O.ClassType=TChunk) then
      begin
          R:=Compute(TChunk(O));
          S:=S+R.Value;
      end;
      if i<C.Elements.Count - 1 then
         S:=S+'x';
    end;
    R.Value:=S;
    result:=R;
end;


function TStringName.ComputeRelation(RelatedItems: TList): TList;
var R: TString; O: TObject; N1, N2: TNumber;
begin
    O:=RelatedItems.Items[0];
    {downcast}
    if (O.ClassType=TChunk) then R:=Compute(TChunk(O));
    if (O.InheritsFrom(TNumber)) then R:=Compute(TNumber(O));
    if (O.ClassType=TMultiplication) then R:=Compute(TMultiplication(O));

    NewElements.Add(R);
    Name:=R;
    result:= RelatedItems;
end;

function TStringName.ConditionsAreSatisfied: boolean;
begin
    result:= (Elements.Count=1);
end;

procedure TStringName.GetAcceptableConnotationsTypes;
begin
  AcceptableConnotations:=Tlist.Create;
  AcceptableConnotations.add(TNumber);
  AcceptableConnotations.add(TOperations);
  AcceptableConnotations.add(TChunk);
end;

function TStringName.GetStringLength: integer;
begin
    Result:=length(Name.GetValue);
end;




{ TBitmapView }

function TBitmapView.GetValue: TBitmap;
begin
  result:=Bitmap;
end;



{ TBitmapViewer }

function TBitmapCreator.Compute(C: TChunk): TBitmapView;
begin

end;


function TBitmapCreator.Compute(C: TMultiplication): TBitmapView;
begin

end;


function TBitmapCreator.Compute(C: TNumber): TBitmapView;
begin
                                
end;


function TBitmapCreator.ComputeRelation(RelatedItems: TList): TList;
var R: TBitmapView; O: TObject; N1, N2: TNumber;
begin
    O:=RelatedItems.Items[0];
    {downcast}
    if (O.ClassType=TChunk) then R:=Compute(TChunk(O));
    if (O.InheritsFrom(TNumber)) then R:=Compute(TNumber(O));
    if (O.ClassType=TMultiplication) then R:=Compute(TMultiplication(O));

    NewElements.Add(R);
    Bitmap:=R;
    result:= RelatedItems;
end;


function TBitmapCreator.ConditionsAreSatisfied: boolean;
begin
    result:= (Elements.Count=1);
end;


procedure TBitmapCreator.GetAcceptableConnotationsTypes;
begin
  inherited;
  AcceptableConnotations:=Tlist.Create;
  AcceptableConnotations.add(TNumber);
  AcceptableConnotations.add(TOperations);
  AcceptableConnotations.add(TChunk);
end;



{ TChunkTopology }
(*
Put Depth and Width in the chunk object itself, then (maybe) move it to an
independent TRelation

function TChunkTopology.ComputeRelation(RelatedItems: TList): TList;
begin
  Level:=0;


end;

function TChunkTopology.ConditionsAreSatisfied: boolean;
var C:TConnotation;
begin
   C:=Elements.items[0];
   Result:= (C.classtype=Tchunk) and (Elements.Count=1);
end;

procedure TChunkTopology.GetAcceptableConnotationsTypes;
begin
  inherited;
  AcceptableConnotations:=Tlist.Create;
  AcceptableConnotations.add(TChunk);
end;

function TChunkTopology.GetNumConnotationsInLevel(C: TChunk): integer;


begin
   Connotations[Level]:=self.ConnotationsAtThisLevel.Count;


end;

function TChunkTopology.GetStringLength: integer;
begin

end;
*)



end.

