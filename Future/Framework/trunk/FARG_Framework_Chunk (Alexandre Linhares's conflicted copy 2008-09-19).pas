unit FARG_Framework_Chunk;

interface

uses classes, graphics, sysutils, ibutils;

type
  TChunk = class;  TConnotation=class;
  TAtribute = class;


  EnumState = (Propose, CheckStrengthState, CommitToMemory);  {"Imagine" for top-down, "interpret" synonym for bottom-up?}

                    //MAJOR REFACTORING: LIST PROCESSING!!!
                    //THEN EXTERNALMEMORY AND SHORT-TERM MEMORY AND EXPECTATIONS CAN BE HAPPY!


  TConnotation = class
                    ExpectedConnotation, ExpectedConnotationFound: TConnotation;
                    State: EnumState;
                    Active, Available: real;

                    //function GetCopyOf(C:TAtribute):TAtribute; virtual; abstract;
                    //Function GetInstanceOfClass(kind:Tclass):TConnotation; virtual; abstract;

                    Procedure DeleteItemsThatIncludeMe(L:Tlist); virtual;
                    Function Imagined: real; virtual; abstract;
                    Function Desirability(Goal:TConnotation): real; virtual; abstract;
                    Function Relevance(Goal:TConnotation; Availability:Real):real;
                    function InstancesOfConnotation (C:TConnotation):integer; virtual;
                    function ListAllConnotations(L: Tlist): Tlist; virtual;
                    Function GetBasicElements(L:TList):TList; virtual; abstract;
                    //function GetValue: TObject; virtual; abstract;    //try to include: REMEMBER SUBSTITUTION PRINCIPLE //why not TConnotation, returning self?
                    Function ExactValueCheck(N:TConnotation):boolean; overload; virtual; //abstract;
                    Function ExactValueCheck(N:TAtribute):boolean; overload; virtual; //abstract;
                    {supporting actors}

                    {== codelets, MM style}
                    Procedure Codelet; //Change to state pattern and template pattern later on
                    Function TopDownSeekFor(C: TConnotation):TConnotation;   virtual;
                    Procedure BottomUpPropose; virtual; abstract;
                    //Procedure CheckStrength; virtual; abstract;
                    Procedure CommitToSTM; virtual; abstract;
                    Procedure DeleteFromSTM; virtual;
                    Function  GetMyExpectations:Tlist; virtual; abstract;
                 end;



  TAtribute = class (TConnotation)
                 Function GetValue: TObject; virtual; abstract; //why not TConnotation, returning self?
                 Procedure SetValue(V: TObject); virtual; abstract;
                 Function ExactValueCheck(N:TAtribute):boolean; overload; virtual;
                 Function Imagined: real; override;
                 //function GetCopyOf(C:TAtribute):TAtribute; override;


                 Function GetBasicElements(L:TList):TList; override;
                 //Function GetMyExpectations:Tlist; virtual; abstract;
                 //I don't think we can pull this here, but maybe...

                 {== codelets, MM style}
                 Function TopDownSeekFor(C: TConnotation):TConnotation; override;
              end;


  TRelation = class (TConnotation)
                  Elements: tlist;
                  NewElements: tlist;
                  AcceptableConnotations:TList;

                  Constructor create; virtual;
                  Function Imagined: real; override;
                  //function GetCopyOf(C:TRelation):TRelation; overload;
                  //Function GetInstanceOfClass(kind:Tclass):TRelation; virtual; abstract;


                  //List-related methods... perhaps refactor as extract class?
                  Function InstancesOfConnotation (C:TConnotation):integer;    override;
                  Procedure DeleteItemsThatIncludeMe(L:Tlist); override;
                  function ListAllConnotations(L: Tlist): Tlist;  override;
                  function GetFirstConnotationOfType(T: TClass): TConnotation; virtual;
                  Function GetBasicElements(L:TList):TList;  override;
                  //end list-related methods


                  //Function Contains (ConnotationType:TClass):boolean;  override;
                  Procedure GetOriginalElements; virtual;
                  Function ConnotationIsAcceptable(C:TConnotation):boolean; virtual;
                  Procedure SetAcceptableConnotationTypes; virtual; abstract;
                  Procedure ComputeRelation; virtual; abstract;
                  Function ConditionsAreSatisfied: boolean; virtual; abstract;

                  {== codelets, MM style}
                  Procedure BottomUpPropose; override;
                  Procedure CommitToSTM; override;
                  Procedure DeleteFromSTM; override;
              end;

  TChunk  = class (TRelation)
                    Function Imagined: real; override;
                    Function Desirability(Goal:TConnotation): real; Override;


                 {== codelets, MM style}
              Procedure BottomUpPropose; override;
              Procedure CommitToSTM; override;
            end;




{===========================================}

var     STM, Expectations: TList;

implementation

{ TConnotation }

procedure TConnotation.Codelet;
{THIS SHOULD BE REFACTORED TO STATE PATTERN SOON}
begin
    Case State of
      Propose:
          begin
              if ExpectedConnotation<>nil then
                TopDownSeekFor(ExpectedConnotation) else
                BottomUpPropose;
          end;

//      CheckStrengthState: CheckStrength;

      CommitToMemory: CommitToSTM;
      end;
end;

function TConnotation.InstancesOfConnotation(C: TConnotation): integer;
begin
    if self=C then result:=1 else result:=0;
end;

{Class function TConnotation.GetInstanceOfClass(kind: Tclass): TConnotation;
begin
end;}

function TConnotation.ListAllConnotations(L: Tlist): Tlist;
begin                                           
    L:=Tlist.Create;
    L.add(self);
    result:=L;
end;

function TConnotation.Relevance(Goal:TConnotation; Availability:Real): real;
begin
    result:=Availability*desirability(Goal)*Imagined;
end;

{function TConnotation.Contains(ConnotationType: TClass): boolean;
begin
    if self.ClassType<>ConnotationType then
      result:= false else result:=true;
end; }

Function TConnotation.TopDownSeekFor(C: TConnotation):TConnotation;
begin

   {TCHUNK calls this for each internal connotation}
   ExpectedConnotation:=C;
   ExpectedConnotationFound:=nil;
   if ExpectedConnotation.ClassType=Self.ClassType then   {Checking exact classes here}
   begin
      ExpectedConnotationFound:=self;
   end;
   result:=ExpectedConnotationFound;
end;

Procedure TConnotation.DeleteFromSTM;
begin
    //does nothing
end;

procedure TConnotation.DeleteItemsThatIncludeMe(L: Tlist);
begin
    L.Remove(self);
end;


function TConnotation.ExactValueCheck(N: TConnotation): boolean;
begin
   result:=false;
end;

function TConnotation.ExactValueCheck(N: TAtribute): boolean;
begin
   result:=false;
end;


(*function TConnotation.ExactValueCheck(N: TConnotation): boolean;
begin
    result:= ({TNumberInteger(self).GetValue}TValue(N).GetValue=2);
end;*)

{function TConnotation.GetValue: TObject;
begin
    result:=self;
end;}

{ TRelation }

Constructor TRelation.create;
begin
    Inherited;
    AcceptableConnotations:=Tlist.Create;
    SetAcceptableConnotationTypes;

    Elements:=TList.Create;
    NewElements:=TList.Create;
end;

Function Trelation.ConnotationIsAcceptable(C:TConnotation):boolean;
var ConnotationIsValid:boolean; y:integer;
begin
     ConnotationIsValid:=False;
     for y:=0 to AcceptableConnotations.count-1 do
        if (C.Classtype=AcceptableConnotations.items[y]) then
            ConnotationIsValid:=true;
     Result:=ConnotationIsValid;
end;

{function TRelation.Contains(ConnotationType: TClass): boolean;
var C: TConnotation;
    I: integer;
    res:boolean;
begin
    res:=false;
    for I := 0 to Elements.Count - 1 do
    begin
       C:=Elements.Items[i];
       if C.ClassType=ConnotationType then
          res:= true;
    end;
    result:=res;
end;}

function TRelation.Imagined: real;
var x: integer; R:real;
begin
    R:=0;
    for x := 0 to Elements.Count - 1 do
      R:=R+TConnotation(Elements[x]).Imagined;
    {for x := 0 to NewElements.Count - 1 do
      R:=R+TConnotation(NewElements.items[x]).Imagined;}
    result:=R/(Elements.Count{+NewElements.Count});
end;

procedure TRelation.BottomUpPropose;
begin
     //VERY BAD METHOD NAME in this specific call!!!
     GetOriginalElements; //Template method: call handled by subclasses
end;

Procedure TRelation.GetOriginalElements;
var c1, c2:TConnotation; L1, L2, Intersection:TList;
begin
    {get 2 elements from STM; they must be different and with good connotations}
    While (Elements.count<2) do
    begin
        ConditionsAreSatisfied;  //terrible name in this use here.  REFACTOR
        c1:=elements.items[0];
        c2:=elements.items[1];
        L1:=Tlist.create;
        L2:=TList.create;
        Intersection:=TList.create;
        L1:=C1.ListAllConnotations(L1);
        L2:=C2.ListAllConnotations(L2);
        Intersection.Assign(L1, laAnd, L2);
        if Intersection.Count>0 then
            Elements.Clear;
    end;
end;

procedure TRelation.CommitToSTM;
// Template method (subclasses handle the calls)
begin
    if ConditionsAreSatisfied then
    begin
         ComputeRelation;
         STM.Add(self);
    end;
end;

Procedure TRelation.DeleteFromSTM;
begin
end;


//LIST RELATED Methods... extract class refactoring?
procedure TRelation.DeleteItemsThatIncludeMe(L: Tlist);
var c: TConnotation; j:integer;
begin
     For J:= 0 to elements.count-1 do
     begin
        C:= elements.Items[j];
        if C.InheritsFrom(TChunk) then
        begin
            Tchunk(C).DeleteItemsThatIncludeMe(L);
        end else if C.InheritsFrom(TRelation) then
              TRelation(C).DeleteItemsThatIncludeMe(L)
        else L.Remove(C);
     end;
end;

Function TRelation.GetBasicElements(L:TList):TList;
var x: integer; C:TConnotation;
begin
    for x := 0 to Elements.Count - 1 do
    begin
      c:=Elements[x];
      L.Add(C);
      if C.InheritsFrom(TRelation) then
         L:=TRelation(C).GetBasicElements(L);
    end;

    result:=L;
end;



function TRelation.ListAllConnotations(L: Tlist): Tlist;
var
  I: Integer; Caux:TConnotation;
begin
    for I := 0 to Elements.Count - 1 do
    begin
      Caux:=Elements.items[i];
      L.add(Caux);
      if Caux.InheritsFrom(TRelation) then
          L:=TRelation(Caux).ListAllConnotations(L);
    end;
    for I := 0 to NewElements.Count - 1 do
    begin
      Caux:=NewElements.items[i];
      L.add(Caux);
      if Caux.InheritsFrom(TRelation) then
          L:=TRelation(Caux).ListAllConnotations(L);
    end;
    result:=L;
end;

function TRelation.InstancesOfConnotation(C: TConnotation): integer;
var
  I: Integer; Caux:TConnotation;
begin   //return the instances of connotation C found inside the relation
    result:=0;
    for I := 0 to Elements.Count - 1 do
    begin
      Caux:=Elements.items[i];
      if Caux=C then
        result:=result+1
      else if Caux.InheritsFrom(TRelation) then
          result:=result+TRelation(Caux).InstancesOfConnotation(C);
    end;
end;


function TRelation.GetFirstConnotationOfType(T: TClass): TConnotation;
Var C:TConnotation; I: integer; List:TList;
begin
   Result:=nil;
   List:=TList.Create;
   List:=Self.ListAllConnotations(List);
   for I := 0 to List.Count - 1 do
   begin
     C:=List.Items[i];
     if C.inheritsFrom(T) then
        result:=C;
   end;
end;


{ TChunk }

function TChunk.Imagined: real;
begin
    result:=0.1; //REFACTOR!!!
end;

function TChunk.Desirability(Goal: TConnotation): real;
begin
    result:=0.1;  //REFACTOR!!!
end;


Procedure TChunk.BottomUpPropose;
Var C:Tconnotation; R:TRelation; I:integer;
begin
    //maybe this should be refactored to a template method
    //the question is: do ALL chunks behave like this?
    //I think so...

    //looks for an acceptable connotation in STM
    C:=STM.Items[random(STM.count)];
    if ConnotationIsAcceptable(c) then
    begin
       elements.add(C);
       if (C.InheritsFrom(Tchunk)) then //tchunk with newelements??? Refactor???
       begin
            R:=TRelation(C);
            for I := 0 to R.NewElements.Count - 1 do
                Elements.Add(R.NewElements.Items[i]);
            for I := 0 to R.Elements.Count - 1 do
                Elements.Add(R.Elements.Items[i]);
       end;
       state:=CommitToMemory;
    end;
end;

procedure TChunk.CommitToSTM;
var i: integer; L1, L2, Intersection:TList; C:TConnotation;
begin
    If State=CommitToMemory then
    begin
        {2 parts: (i) withdraw elements from STM, and (ii) insert chunk in STM}
        {PART (i)}
        L1:=TList.Create;
        L1:=self.ListAllConnotations(L1);
        i:=0;
        while (i<STM.Count) do
        begin
            C:=STM.items[i];
            L2:=TList.Create;
            L2:=C.ListAllConnotations(L2);
            Intersection:=TList.Create;
            Intersection.Assign(L1, laAnd, L2);
            if Intersection.Count>0 then
            begin
                STM.Remove(C);
                i:=i-1;
            end;
            i:=i+1;
        end;
        {Part (ii)}
        STM.Add(self);
        State:=propose;
    end;
end;

{ TValue }

Function TAtribute.ExactValueCheck(N:TAtribute):boolean;
begin
  if (getvalue=N.getvalue) then result:=true else
  result:=false;
end;

{function TAtribute.GetCopyOf(C: TAtribute): TAtribute;
begin

end;  }

function TAtribute.GetBasicElements(L: TList): TList;
begin
    L.add(self);
    result:=L;
end;

Function TAtribute.Imagined:Real;
begin
  result:=1;
end;

Function TAtribute.TopDownSeekFor(C: TConnotation):TConnotation;
begin
     (*ExpectedConnotation:=C;
     ExpectedConnotationFound:=nil;

     if ExpectedConnotation.InheritsFrom(TValue) then
     begin
        if (ExactValueCheck(TValue(ExpectedConnotation))) then {EXACT VALUE CHECKING}
        begin
          {result must point to the right connotation where the thing was found!}
          ExpectedConnotationFound := self;
        end;
     end;
     result:=ExpectedConnotationFound;*)
end;


{
Thoughts on the STATE refactoring...
(i) how to include proposed structures without chunking them up?
        just create the list in a proposal object
(ii) how to accept proposed structures?
        check the proposal's value, and, if accepted, create a chunk?

CAN IT WORK FOR ALL CONNOTATIONS?  ONLY RELATIONS?

    well, I can have 50 copies of random proposals full of lists
    running around, as long as they don't change STM.  As long as
    nothing is taken from STM, and no chunk is created, thousands of
    proposals can be pointing to some cool stuff to do there, irresponsibly

    But sometimes we do create a bond without chunking it up in copycat,
    or maybe in chess (attacks, etc.) So we could have a commit for
    some relations.

    A new TRelation: How is it attached to anything?  Well, it
    has a List of the original connotations, and a list of the newly created
    connotations.

    A new Chunk: It either groups things based on some (set of) relations. Are
    chunks also relations?  What would the advantages be?  Interface advantages?

    A new Property:  Created when a new relation or a new chunk is created,
    automaticaly bound to a relation or a chunk

We have to do it bottom-up & top-down!

When Bottom-up, we just get things from EM and STM (never inside chunks)

When top-down, we also look inside the chunks, because we might want to
break them apart (and maybe recreate directly the new interpretation? like
a necker cube or a faces/vases illusion)?

1. TRelation should NOT create a chunk: it should be created when
    TCHUNK.conditions are satisfied;
2. A Chunk should find its own properties and relations (and chunks) and Commit
3. TRelation should commit to STM (just like chunks; but without deleting
    anything)
4. Separation of Creation to Commit to STM
5. Shared interface between TRelation and TChunk?
    does a chunk have EVERYTHING that a relation has????
    A chunk has a crucial difference, as it actually deletes stuff from STM
}

    {The method Tconnotation.TopDownSeekFor looks for a sentconnotation and creates a scout (proposal)}
    {one connotation is being searched... it could have a value,
     or it could have an UndefinedValue (only the type is being searched for)}
    {How do we know if the connotation is there? We must look into STM}
    {Is there a difference between finding a specific value OR only a type?}

    {How to check if two objects are equal?  Let's say we're looking for a number
    in Numbo... then that's easy: check the value; but what if we're looking for
    a 100+10=110 chunk? How to compare whole structures? Maybe AllChunkConnotations
    can be used?  this has many levels and many connotations and values,
    which make the test much harder...}

    {examples of method in action, different hierarchical levels:

    NUMBO:    looks for a particular number or result
              looks whether a particular number can result from some operation
              Jarbas system; looks for a particular type of operation? x+y=z ?

    Copycat:  looks for a successorship_relation between any two letters
              looks for a chunk of a certain type (sameness, successorship, etc)

    Chess:    looks for upcoming moves of a certain piece
              looks for interceptions of certain relations

    Bongard Problems: looks for certain types of geometrical objects
                      looks for certain types of relations between objects

    So,
    (i) we have a certain connotation which is expected to be found in STM or external memory
    (ii) With this SentConnotation, we browse memory systems in search of it...
    (iii) How do we browse memory systems?
      (a) each ExpectedConnotation can only be found in a certain types of conotations
          (e.g., it is useless to browse a tbrick for a multiplication, or a letter for
           a sucessorship group, or a chess queen for an attack, or a triangle for a bigger-than
           relation)
           So, for each ExpectedConnotation, we should define a method like
           ToScan:=CanBeFoundIn(ExpectedConnotations):Tlist;
      (b) after we have a set of things ToScan, we should, perhaps, apply this:
           C:=ToScan.Items[x];  (C=random item of a good connotation type)
           C.SearchForInstance; (This method is type-only, value neutral... so
                                 there should be another method in which the VALUE
                                 is being searched for.)

                                 BRAINSTORM: How does this compare to the idea of an incognita???

      So what is the difference between bottom-up and top-down codelets?

      bottom up just SearchForInstance
      top-down have to scan a list of good connotations???  IN STM alone?  Or in EM also?
    }



{ TConnotationFactory }



end.                                                                                            
