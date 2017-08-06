unit FARG_Framework_Chunk;

interface

 uses classes;

type
  TChunk = class;

  EnumState = (Propose, CheckStrength, CommitToMemory);  {"Expect" for top-down, "register" synonym for bottom-up?}

  TConnotation = class {(TinterfacedObject)}
                    ExtMemoryRef: TObject;
                    ExpectedConnotation, ExpectedConnotationFound: TConnotation;
                    Relevance: real;
                    State: EnumState;   

                    Function Contains (ConnotationType:TClass):boolean; virtual;
                    Procedure Codelet; {Change to state pattern and template pattern later on}

                    {supporting actors}

                    {== codelets, MM style}
                    Function TopDownSeekFor(C: TConnotation):TConnotation;   virtual;
                    Procedure BottomUpPropose; virtual;  {This may be unnecessary (trade for searchforinstance?}
                    Procedure SearchForInstance; virtual; abstract; {NOT SURE THIS IS NEEDED, maybe only BottomUpPropose??}
                    Procedure CheckCurrentStrength; virtual; abstract;
                    Procedure CommitToSTM; virtual; abstract;
                    Procedure Destroyer; virtual; abstract;
                end;

  TValue = class (TConnotation)
                 {incognita? UndefinedValue:boolean???}

                 Function GetValue: TObject; virtual; abstract;
                 Procedure SetValue(V: TObject); virtual; abstract;
                 Function {refactor to TSimilarity?} ExactValueCheck(N:TValue):boolean; virtual; abstract;

                 {== codelets, MM style}
                 Function TopDownSeekFor(C: TConnotation):TConnotation; override;
              end;

  TRelation = class (TConnotation)
                  Elements: tlist;
                  NewElements: tlist;
                  AcceptableConnotations:TList;

                  Constructor create;

                  Procedure GetOriginalElements; virtual;
                  Function ConnotationIsAcceptable(C:TConnotation):boolean; virtual;
                  function GetConnotationOfType(T: TClass): TConnotation;
                  Procedure GetAcceptableConnotationsTypes; virtual; abstract;
                  Function ComputeRelation (RelatedItems: TList):TList; virtual; abstract;
                  Function ConditionsAreSatisfied: boolean; virtual; abstract;

                  {== codelets, MM style}
                  Procedure SearchForInstance; override;
                  Procedure CommitToSTM; override;
              end;

  TChunk  = class (TRelation)
              ElementsAtAllChunkLevels: Tlist;

              Constructor Create;  overload;
              Procedure CreateFromList (L: TList);  overload;

             {FROM TRELATION}

                  Procedure GetOriginalElements; virtual;
                  Function ConnotationIsAcceptable(C:TConnotation):boolean; virtual;
                  function GetConnotationOfType(T: TClass): TConnotation;
                  Procedure GetAcceptableConnotationsTypes; virtual; abstract;
                  {Function ComputeRelation (RelatedItems: TList):TList; virtual;}
                  Function ConditionsAreSatisfied: boolean; virtual; abstract;
                  {NOT IMPLEMENTED! CHECK! Procedure SearchForInstance; override;}
                  Procedure CommitToSTM; override;

             {END FROM TRELATION}


              Procedure ChunkRelation(R:TRelation); {REFACTOR: difference interface!, goes to Commit to STM}
              Function Contains (ConnotationType:TClass):boolean; override;
              Function GetRelationsThatBindChunk: TList;
              Function GetConnotationsFromTheseRelations(Relations:TList):TList;

              {== codelets, MM style}
              Function TopDownSeekFor(C: TConnotation):TConnotation; override;
              Procedure Destroyer; override;
            end;

  TChunkInfo = class                 
                constructor create (C:TChunk);
                function GetChunkDepth(Chunk:TChunk):integer;
                function GetChunkWidth(Chunk: TChunk): integer;
                function GetChunkWidthInLevelX(Chunk: TChunk; X:Integer): integer;

  end;

{===========================================}

var     STM_Content: TList;

implementation

{ TConnotation }

procedure TConnotation.Codelet;
{THIS SHOULD BE REFACTORED TO STATE PATTERN SOMEDAY}
begin
    Case State of
      Propose:
          begin
              if ExpectedConnotation<>nil then
                TopDownSeekFor(ExpectedConnotation) else
                BottomUpPropose;
          end;

      CheckStrength: CheckCurrentStrength;

      CommitToMemory: CommitToSTM;
      end;
end;

Procedure TConnotation.BottomUpPropose;
begin
  SearchForInstance;
end;

function TConnotation.Contains(ConnotationType: TClass): boolean;
begin
    if self.ClassType<>ConnotationType then
      result:= false else result:=true;
end;

Function TConnotation.TopDownSeekFor(C: TConnotation):TConnotation;
begin
    {This method looks for a sentconnotation and creates a scout (proposal)}
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

   {TCHUNK calls this for each internal connotation}
   ExpectedConnotation:=C;
   ExpectedConnotationFound:=nil;
   if ExpectedConnotation.ClassType=Self.ClassType then   {Checking exact classes here}
   begin
      ExpectedConnotationFound:=self;
   end;
   result:=ExpectedConnotationFound;
end;


{ TChunk }

Function TChunk.TopDownSeekFor(C: TConnotation):TConnotation;
var
  I: Integer;
  Aux: TConnotation;
begin
  ExpectedConnotation:=C;
  {looks for the conotation inside the chunk (but should also look if the chunk is a perfect match)}
  if (ExpectedConnotationFound<>self) then
  begin
    for I := 0 to Elements.Count - 1 do
    begin
      aux:=Elements.Items[i];
      ExpectedConnotationFound := aux.TopDownSeekFor (ExpectedConnotation);
    end;
  end;
  result:=ExpectedConnotationFound;
end;


procedure TChunk.GetOriginalElements;
begin

end;

function TChunk.ConnotationIsAcceptable(C: TConnotation): boolean;
begin

end;

function TChunk.Contains(ConnotationType: TClass): boolean;
var C: TConnotation;
    I: integer;
    res:boolean;
begin
    res:=false;
    for I := 0 to ElementsAtAllChunkLevels.Count - 1 do
    begin
       C:=ElementsAtAllChunkLevels.Items[i];
       if C.ClassType=ConnotationType then
          res:= true;
    end;
    result:=res;
end;

constructor TChunk.Create;
begin
    NewElements:=Tlist.Create;
    ElementsAtAllChunkLevels:=Tlist.Create;
    Elements:= Tlist.Create;
end;

Procedure TChunk.CreateFromList(L: TList);  {COMPARE TO CHUNKRELATION!}
var
  I, I2: Integer;
  C, C2: TConnotation;
begin
     {This metod Receives a List of Connotations to chunk, perhaps including
      relations and other chunks inside the new chunk}
     for I := 0 to L.Count - 1 do
     begin
       C:=L.Items[i];
       Elements.add(C);

       {the whole structure--including subchunks}
       ElementsAtAllChunkLevels.Add(C);
       if C.ClassType=TChunk then
       begin
          for I2 := 0 to TChunk(C).ElementsAtAllChunkLevels.Count - 1 do
          begin
            C2:=TChunk(C).ElementsAtAllChunkLevels.Items[i];
            ElementsAtAllChunkLevels.Add(C2);
          end;
       end;
     end;
end;


Procedure TChunk.ChunkRelation(R:TRelation);
Var L:TList;
  I: Integer;
begin
    L:=TList.Create;
    L.add(R);

    {either we put the relation with its original elements and the new ones,
    or we just put the relation.  Either way, the chunk must delete from STM
    the relation & its original elements}

    for I := 0 to R.NewElements.Count - 1 do
      L.Add(R.NewElements.Items[i]);
    for I := 0 to R.Elements.Count - 1 do
      L.Add(R.Elements.Items[i]);

    CreateFromList(L);
    CommitToSTM;
end;

procedure TChunk.CommitToSTM;
var
  I, J: Integer;
  C, C2: TConnotation;
begin
  for I := 0 to Elements.Count - 1 do
  begin
    {When a chunk is perceived, it withdraws its elements from STM, then chunks them
     then throws the chunk in STM}
    {Withdrawing elements from STM}
    C:= Elements.items[I];
    if (STM_Content.IndexOf(C)>=0) then
    begin
        STM_Content.Remove(C);
        STM_Content.Pack;
    end else
    if C.InheritsFrom(TRelation) then
         begin
           for J := 0 to TRelation(C).Elements.Count - 1 do
           begin
               C2:= TRelation(C).Elements.items[j];
               if (STM_Content.IndexOf(C2)>=0) then
               begin
                  STM_Content.Remove(C2);
                  STM_Content.Pack;
              end;
           end;

           for J := 0 to TRelation(C).NewElements.Count - 1 do
           begin
               C2:= TRelation(C).NewElements.items[j];
               if (STM_Content.IndexOf(C2)>=0) then
               begin
                  STM_Content.Remove(C2);
                  STM_Content.Pack;
              end;
           end;

         end;
  end;

  STM_Content.Add(self);
end;

procedure TChunk.Destroyer;
var Relations, Connotations: TList;
    C: TConnotation;
    I: integer;
begin
    {First:  find the relations binding the stuff inside the chunk}
    Relations:=GetRelationsThatBindChunk;

    {Second: find the set of Connotations these relations are using.
    Notice that not all connotations are used: for example, 2x5 creates
    a 10 as a TResult, but the 10 should not go back to STM}

    Connotations:=GetConnotationsFromTheseRelations(Relations);
    {Third: Commit these Connotations back to STM; destroy everything in
    the Chunk
    Scan the chunk, deleting everything for which the template does not match
    the desired set of connotations}

    STM_Content.Remove(self);
    STM_Content.Pack;

    {put the items back in STM}
    for I := 0 to Connotations.Count - 1 do
    begin
        C:=Connotations.Items[i];
        STM_Content.Add(C);
    end;
    {We are not _yet_ commiting these relations to memory... so not needed now...}
    for I := 0 to Relations.Count - 1 do
    begin
        C:=Relations.Items[i];
        STM_Content.Add(C);
    end;{}

    {Now delete the chunk baby!}
    Elements.Clear;
    Destroy;
end;

function TChunk.GetConnotationsFromTheseRelations(Relations: TList): TList;
var I, I2:integer;
    R:TRelation;
    C:TConnotation;
    List:TList;
begin
    List:=Tlist.Create;
    For I:=0 to Relations.Count-1 do
    begin
         R:=Relations.Items[I];

         {or simply List:=R.BottomUpItems ???}
         for I2 := 0 to R.Elements.Count - 1 do
         begin
             C:=R.Elements.Items[I2];
             List.Add(C);
         end;
    end;
    result:=list;
end;


function TChunk.GetRelationsThatBindChunk: TList;
var L:TList;
  I: Integer;
  C: TConnotation;
begin
    L:=Tlist.Create;
    for I := 0 to Elements.Count - 1 do
    begin
        C:=Elements.Items[i];
        if C.InheritsFrom(TRelation) then
          L.Add(C);
    end;
    Result:=L;
end;

function TChunk.GetConnotationOfType(T: TClass): TConnotation;
Var C:TConnotation; I: integer;
begin
   for I := 0 to Elements.Count - 1 do
   begin
     C:=Elements.Items[i];
     if C.ClassType=T then
        result:=C;
   end;
end;



{ TRelation }

Constructor TRelation.create;
begin
    Inherited;
    AcceptableConnotations:=Tlist.Create;
    GetAcceptableConnotationsTypes;
    {AcceptableConnotations:=}

    Elements:=TList.Create;
    NewElements:=TList.Create;
end;

function TRelation.GetConnotationOfType(T: TClass): TConnotation;
Var C:TConnotation; I: integer; List:TList;
begin
   List:=TList.Create;
   for I := 0 to Elements.Count - 1 do
      List.add(Elements.items[i]);
   for I := 0 to NewElements.Count - 1 do
      List.add(NewElements.items[i]);
   for I := 0 to List.Count - 1 do
   begin
     C:=List.Items[i];
     if C.ClassType=T then
        result:=C;
   end;
end;

procedure TRelation.SearchForInstance;
begin
     {Refactor to codelet state; this thing is jumping steps ahead...}
     GetOriginalElements; {finds related stuff}
     CommitToSTM; {generates new connotation & chunks it up}
end;

Function TRelation.ConnotationIsAcceptable(C:TConnotation):boolean;
var ConnotationIsValid:boolean; y:integer;
begin
     ConnotationIsValid:=False;
     GetAcceptableConnotationsTypes;
     for y:=0 to AcceptableConnotations.count-1 do
        if C.Contains(AcceptableConnotations.items[y]) then
            ConnotationIsValid:=true;
     Result:=ConnotationIsValid;
end;

Procedure TRelation.GetOriginalElements;
var C: TConnotation;
begin
    {looks into STM for random connotations... i.e., bricks/results, etc}
    {Currently NOT looking into ExternalMemory, but it should, and perhaps the
    change can be made simply by changing the List from STM_content to EM_Content
    A simple function call could return the appropriate lists on which a connotation
    may be found}
    Elements:=Tlist.Create;
    While (not ConditionsAreSatisfied) do
    begin
         C:=STM_Content.items[Random(STM_Content.Count)];
         if (ConnotationIsAcceptable(C)) and (Elements.IndexOf(C)<0) then
               Elements.Add(C);
    end;
end;

procedure TRelation.CommitToSTM;
var C: TChunk; L:TList;
begin
    if ConditionsAreSatisfied then
    begin
         {(i) computes the relation, which creates new elements with the correct value and type}
          ComputeRelation(Elements);

         {(REFACTOR!!!) Commit the RELATION TO STM
          Then, Change the Client to Chunk Things up later on}

         C:=TChunk.Create;
         C.ChunkRelation(self);

         {A Relation should be committed to STM as a tentative structure(not as a chunk)}
    end;
end;

{ TValue }

Function TValue.TopDownSeekFor(C: TConnotation):TConnotation;
begin
     ExpectedConnotation:=C;
     ExpectedConnotationFound:=nil;

     if ExpectedConnotation.InheritsFrom(TValue) then
     begin
        if (ExactValueCheck(TValue(ExpectedConnotation))) then {EXACT VALUE CHECKING}
        begin
          {result must point to the right connotation where the thing was found!}
          ExpectedConnotationFound := self;
        end;
     end;
     result:=ExpectedConnotationFound;
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
    or maybe in chess (attacks, etc.) So perhaps we could have a commit for
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


{ TChunkInfo }
{This class can enable clients to get info on chunks without having to
change the TChunk interface, which can in this way be cleaned up

Also, subclasses might need to extend the interface here for specific
applications running on top of the framework, if that was done in the
TConnotation class structure, things might lose generality

This class structure does seems to be more loosely coupled

Why isn't it merely a set of TRelations?  Because some of the methods here
just feel better placed as method calls than TRelations creating new structures
that do not necessarily affect memory structures (such as the size of the
strings of connotations)}

constructor TChunkInfo.create(C: TChunk);
begin
end;

function TChunkInfo.GetChunkDepth(Chunk: TChunk): integer;
var Depth, maxDepth, subTreeDepth, I:integer;
    C: TConnotation; ChunkInfo: TChunkInfo;
begin
  Depth:=1;
  maxDepth:=1;
  {needs to traverse the chunk tree to compute the maximum depth size}
  for I := 0 to Chunk.Elements.Count - 1 do
  begin
       C:=Chunk.Elements.items[i];
       if (C.Classtype=TChunk) then
       begin
         ChunkInfo:=TChunkInfo.Create(TChunk(C));
         subTreeDepth:=ChunkInfo.GetChunkDepth(TChunk(C));
         Depth:=Depth+subTreeDepth;
         if Depth>MaxDepth then MaxDepth:=Depth;
         Depth:=Depth-subTreeDepth;
       end;
  end;
  result:=maxDepth;
end;

function TChunkInfo.GetChunkWidth(Chunk: TChunk): integer;
var Depth, maxDepth, subTreeDepth, I:integer;
    C: TConnotation; ChunkInfo: TChunkInfo;
begin
  Depth:=1;
  maxDepth:=1;
  {needs to traverse the chunk tree to compute the maximum depth size}
  for I := 0 to Chunk.Elements.Count - 1 do
  begin
       C:=Chunk.Elements.items[i];
       if (C.Classtype=TChunk) then
       begin
         ChunkInfo:=TChunkInfo.Create(TChunk(C));
         subTreeDepth:=ChunkInfo.GetChunkDepth(TChunk(C));
         Depth:=Depth+subTreeDepth;
         if Depth>MaxDepth then MaxDepth:=Depth;
         Depth:=Depth-subTreeDepth;
       end;
  end;
  result:=maxDepth;
end;


function TChunkInfo.GetChunkWidthInLevelX(Chunk: TChunk; X: Integer): integer;
begin


end;

end.
