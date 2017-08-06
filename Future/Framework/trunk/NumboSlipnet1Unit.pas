unit NumboSlipnet1Unit;

interface

uses     FARG_Framework_Chunk, NumboConnotations, Node1Unit, Activation1Unit, Classes, sysutils;

//const //NormalDragConstant = 0.1;
      //high_drag_Multiplication_Node=0.1;
      //Salient_Multiples_10_drag=0.1;
                                                          
type     KernelSlipnet = class
                         nodes: tlist;
                         constructor Create; virtual;
                         Function CreateNode(N:TConnotation):KernelNode; virtual;
                         procedure ExplodeConnotationsOfNode(ReceivedNode:KernelNode);  virtual;
                         function  GetNode(C:TConnotation):KernelNode; virtual;
                         Procedure SpreadActivation; virtual;
                         Procedure LinkNodes (NOrigin, NDest: KernelNode); virtual;
                         procedure decay; virtual;
                    end;

          TNumboSlipnet = class (KernelSlipnet)
                              Constructor Create; override;
                              Function GetNewOperation(x, y: integer; kind: TClass):TOperations; //refactor; then move up
                              Function GetSlipnetNodeWithValue(i:integer):KernelNode;
                              Function GetOrCreateNewNumberNode(i:Integer):KernelNode;

                              Procedure CreateDefaysNumboSlipnetNodes;
                              Function ExplodeNumber(i:integer):TList;
                              Function GetNodesWhichResultIn(i:integer):TList;

                              procedure ExplodeConnotationsOfInteger(x: integer);
                              procedure ExplodeConnotationsOfIntegerNode(ReceivedNode:KernelNode);

                              Function GetNodesThatExplodeFrom(C:TnumberInteger):TList; overload;
                              Function GetNodesThatExplodeFrom(C:TOperations):TList; overload;

                              Function ExplodeConnotations(Op: TOperations):TList; overload;
                              Function ExplodeConnotations(C: TNumberInteger):TList; overload;
                              Function ExplodeConnotations(C: TConnotation):TList; overload;

                              Function GetExplodedNodesFromConnotationList(ConnotationList: TList): TList;
                        end;

implementation



function TNumboSlipnet.GetNodesThatExplodeFrom(C: TnumberInteger): TList;
begin
    result:=GetNodesWhichResultIn(C.GetValue);
end;


Function TNumboSlipnet.ExplodeNumber(i:integer):TList;
var N:KernelNode;
begin
    ExplodeConnotationsOfInteger(i);
    N:=GetSlipnetNodeWithValue(i);
    Result:=N.associations;
end;


function TNumboSlipnet.GetNodesThatExplodeFrom(C: TOperations): TList;
var L:TList;
begin
    L:=tlist.create;
    //Get Result of C


    //Get


    result:=L;
end;


Function TNumboSlipnet.GetExplodedNodesFromConnotationList(ConnotationList: TList): TList;
var
  i: Integer;
  c: TConnotation;
  AssociatedNodes:TList;
begin
  AssociatedNodes:=TList.create;
  for i := 0 to ConnotationList.count - 1 do
  begin
        C := ConnotationList.items[i];
        if C.InheritsFrom(TRelation) then
            AssociatedNodes.Assign(GetNodesThatExplodeFrom(TOperations(C)), laOr)
        else AssociatedNodes.Assign(GetNodesThatExplodeFrom(TNumberInteger(C)), laOr);
  end;
  Result:=AssociatedNodes;
end;




Function TNumboSlipnet.ExplodeConnotations(Op: TOperations):TList;
var AssociatedNodes, L: TList;
  i, j: Integer;
  NewOp:TOperations;
  C, C2: TConnotation;
begin
    L:=TList.Create;
    AssociatedNodes:=TList.Create;

    For i:= 0 to Op.Elements.Count-1 do
    begin
        C:=Op.Elements[i];
        if C.InheritsFrom(TNumberInteger) then
            AssociatedNodes:=ExplodeConnotations(C)
        else AssociatedNodes.Assign (ExplodeConnotations(C),laOr);

        for j := 0 to AssociatedNodes.Count - 1 do
        begin
            NewOp:=Op.GetCopyOf(Op);  //maybe (probably?) the reason for the nil error lies here...
            C2:= AssociatedNodes[j];  //associatednodes MUST be a connotation
            NewOp.Elements[i] := C2;  //error!!!!!! this is NIL!!!! but why?
            NewOp.Compute(TNumberInteger(NewOp.Elements[0]),TNumberInteger(NewOp.Elements[1]));
            if L.indexof(NewOp)<0 then
               L.Add(NewOp);
        end;
    end;
    Result:=L;
end;






Function TNumboSlipnet.ExplodeConnotations(C: TNumberInteger):TList;
var x:integer; List, List2, Associations:TList;
  I: Integer; Node:KernelNode;
begin
    List:=TList.Create;
    x:=C.GetValue;
    Node:=GetSlipnetNodeWithValue(X);
    Associations:=Node.GetAssociationsOfType(TConnotation);
    for i := 0 to Associations.Count - 1 do
    begin
        Node:=GetNode(Associations[i]);
        if List.indexof(Node.Content)<0 then
            List.add(Node.Content);
    end;

    result:=List;
end;




Function TNumboSlipnet.ExplodeConnotations(C: TConnotation):TList;
var List:TList;
begin
    If C.InheritsFrom(TOperations) then
        List:=ExplodeConnotations(TOperations(C))
    else List:=ExplodeConnotations(TNumberInteger(C));
    result:=List;
end;



//RENAME!!! DOES NOT RETURN NODES! RETURNS CONNOTATIONS! REFACTOR!!!
Function TNumboSlipnet.GetNodesWhichResultIn(i:integer):TList;
Var x:integer;
    Connotations:TList;
    Node:KernelNode;
begin
    Connotations:=Tlist.Create;
    for x := 0 to Nodes.Count - 1 do
    begin
       Node:=Nodes.items[x];
       if Node.content.InheritsFrom(TOperations) then
          if TOperations(Node.content).GetMyResult=i then
              Connotations.add(Node.Content);
    end;
    result:=Connotations;
end;


Function TNumboSlipnet.GetOrCreateNewNumberNode(i:Integer):KernelNode;
var FoundNode:KernelNode;
    C:TConnotation;
begin
     FoundNode:=GetSlipnetNodeWithValue(i);
     if FoundNode=nil then
     begin
       C:=TNumberInteger.GetNew(i);
       FoundNode:=CreateNode(C);
     end;
     result:=FoundNode;
end;


Function TNumboSlipnet.GetSlipnetNodeWithValue(i:integer):KernelNode;
var NodeAuxContent:TConnotation;
    NodeAux, FoundNode:KernelNode;
    CurrentContent: TNumberInteger;
    x:integer;
begin
     FoundNode:=nil;
     for x := 0 to Nodes.Count - 1 do
     begin
         NodeAux:=Nodes.items[x];
         NodeAuxContent:=NodeAux.Content;
         If NodeAuxContent.InheritsFrom(TNumberInteger) then
         begin
            CurrentContent:=TNumberInteger(NodeAuxContent);
            if (CurrentContent.GetValue=i) then
                FoundNode:=NodeAux;
         end;
     end;
     Result:=FoundNode;
end;


Function TNumboSlipnet.GetNewOperation(x, y: integer; kind: TClass):TOperations;
//Does it accept TConnotation?
var R:TRelation;
    C:Tconnotation;
    N1, N2: KernelNode;
    I: Integer;
begin
     //in the slipnet, there will be ONLY one element, so you have to find it,
     //instead of creating them here
     N1:=GetSlipnetNodeWithValue(x);
     if N1=nil then N1:=GetOrCreateNewNumberNode(x);

     N2:=GetSlipnetNodeWithValue(y);
     if N2=nil then N2:=GetOrCreateNewNumberNode(y);
     R:=nil;
     if (n1<>nil) and (n2<>nil) then
     begin
        R:=TOperations.GetInstanceOfClass(kind); //gets the right subclass
        R.Elements.add(N1.content);
        R.Elements.Add(N2.content);
        R.ComputeRelation;
     end;
     //at the end, find the element N3/TResult in SlipnetSpace
     //and change them to this decomposition
     for I := 0 to R.NewElements.Count - 1 do
     begin
         C:=R.NewElements.items[i];
         if C.InheritsFrom(TRelation) then
            N1:=GetNode(C) else
            N1:=GetOrCreateNewNumberNode(TNumberInteger(C).GetValue);
         if N1<>nil then
         begin
            R.NewElements.Remove(R.NewElements.Items[i]);
            R.NewElements.add(N1.Content);
         end;
     end;
     result:=TOperations(R);
end;


Constructor KernelSlipnet.create;
begin
     Nodes:=tlist.Create;
end;


Procedure KernelSlipnet.decay;
var x:integer; Node: KernelNode;
begin
     for x:= 0 to nodes.count-1 do
     begin
          //This is beggining to look unnecessary...
          //Node:= nodes.items[x];
          //Node.activation.decay;
     end;
end;

function KernelSlipnet.GetNode(C: TConnotation): KernelNode;
var x:integer; N_Aux: KernelNode;
begin
    result:=nil;
    for x := 0 to Nodes.Count - 1 do
    begin
        N_Aux:=Nodes.items[x];
        if N_Aux.Content=C then
          result:=Nodes.items[x];
    end;
end;

Function NumberOnSTM(i:integer):TNumberInteger;
var x:integer;
    N: TNumberInteger;
begin
    result:=nil;
    for x := 0 to STM.Count - 1 do
    begin
      N:=TNumberInteger(STM[x]);
      if (N.GetValue=i) then
          result:=N;
    end;
end;

function KernelSlipnet.createNode(N: TConnotation): KernelNode;
var NewNode:KernelNode;
begin
    NewNode:=KernelNode.create;
    If N.InheritsFrom(TAtribute) then
    begin
        if NumberOnSTM(TNumberInteger(N).value)<>nil then
            N.Active:=1;
    end;
    NewNode.Content:=N;
    Nodes.Add(NewNode);

    //NOW LINK all connotations except for N to NewNode

    Result:=NewNode;
end;

Procedure KernelSlipnet.LinkNodes (NOrigin, NDest: KernelNode);
Var Link: KernelLink; 
begin
     Link:= KernelLink.create (NOrigin, NDest);
     if  NOrigin.associations.IndexOf(Link)<0 then
        NOrigin.associations.Add(Link);
end;


procedure KernelSlipnet.ExplodeConnotationsOfNode(ReceivedNode:KernelNode);
var NodeContent: TList;
    i: integer;
    C:TConnotation;
    OriginNode: KernelNode;
begin
    //THE NEURONS ARE COMING!!!!
    //LINKING INPUT TO NEURONS???







    NodeContent:=ReceivedNode.GetFullConnotationStructure;
    //Now it should find the corresponding nodes in the Slipnet
    for I := 0 to NodeContent.Count - 1 do
    begin
        C:=NodeContent.items[i];
        OriginNode:=GetNode(C); //Finds the SlipnetNode with connotation C

        //and link (which ways? maybe varies according to type)
        if (OriginNode<>nil) and (OriginNode<>ReceivedNode) then
        begin
            LinkNodes(OriginNode,ReceivedNode);
        end;
    end;
end;


procedure TNumboSlipnet.ExplodeConnotationsOfInteger(x: integer);
Var Node: KernelNode;
    C:TNumberInteger;
begin
    Node:=GetSlipnetNodeWithValue(x);
    if Node=nil then
    begin
        C:=TNumberInteger.GetNew(x);
        //creates node in SlipnetSpace
        Node:=CreateNode(C);
        Nodes.add(Node);  //why wasn't this here before?
    end;
    ExplodeConnotationsOfIntegerNode(Node);
end;



procedure TNumboSlipnet.ExplodeConnotationsOfIntegerNode(ReceivedNode: KernelNode);
//links number x with 2 smaller numbers and 2 larger numbers (if and when available)
var NodeContent: TNumberInteger;
    x, i, associated: integer;
    OriginNode: KernelNode;
begin
    Nodecontent:=TNumberInteger(ReceivedNode.Content);
    x:=NodeContent.Getvalue;
    i:=x+1;
    associated:=0;
    While (i<=150) and (associated<=1) do
    begin
        OriginNode:=GetSlipnetNodeWithValue(i);
        if OriginNode<>nil then
        begin
            associated:=associated+1;
            LinkNodes(ReceivedNode, OriginNode);
        end;
        i:=i+1;
    end;

    i:=x-1;
    associated:=0;
    While (i>=0) and (associated<=1) do
    begin
        OriginNode:=GetSlipnetNodeWithValue(i);
        if OriginNode<>nil then
        begin
            associated:=associated+1;
            LinkNodes(ReceivedNode, OriginNode);
        end;
        i:=i-1;
    end;
end;

Procedure KernelSlipnet.SpreadActivation;
var x:integer; N: KernelNode;
begin
     {Let's spread activation from the top to bottom of the node list first...}
     for x:= nodes.Count-1 downto 0 do
     begin
          N:= Nodes.items[x];
          //N.Notify(N.activation);
     end;

     {Now, nodes that just received some activation can propagate it, right, so we
      now propagate the other way around}
     for x:= 0 to nodes.Count-1 do
     begin
          N:= Nodes.items[x];
          //N.Notify(N.activation);
     end;

     {Now we need to reset the activations, deploying the changes
     //(I really need to blog about this one)}
     for x:=0 to nodes.Count-1 do
     begin
          N:= Nodes.items[x];
          //N.activation.DeployChange;
     end;
end;

{ TNumboSlipnet }
{ =================================================== }

constructor TNumboSlipnet.Create;
begin
  inherited;
  CreateDefaysNumboSlipnetNodes;
end;

Procedure TNumboSlipnet.CreateDefaysNumboSlipnetNodes;
var Op:TConnotation;
  I: Integer;
  NewNode: KernelNode;
begin
    //DEFAYS SLIPNET
    //Used to be C:=TNumberInteger.GetNew(1); CreateNode(C);

    GetOrCreateNewNumberNode(1);
    GetOrCreateNewNumberNode(2);
    GetOrCreateNewNumberNode(3);
    GetOrCreateNewNumberNode(4);
    GetOrCreateNewNumberNode(5);
    GetOrCreateNewNumberNode(6);
    GetOrCreateNewNumberNode(7);
    GetOrCreateNewNumberNode(8);
    GetOrCreateNewNumberNode(9);
    GetOrCreateNewNumberNode(10);
    GetOrCreateNewNumberNode(11);
    GetOrCreateNewNumberNode(12);
    GetOrCreateNewNumberNode(13);
    GetOrCreateNewNumberNode(14);
    GetOrCreateNewNumberNode(15);
    GetOrCreateNewNumberNode(16);
    GetOrCreateNewNumberNode(20);
    GetOrCreateNewNumberNode(25);
    GetOrCreateNewNumberNode(30);
    GetOrCreateNewNumberNode(36);
    GetOrCreateNewNumberNode(40);
    GetOrCreateNewNumberNode(49);
    GetOrCreateNewNumberNode(49);
    GetOrCreateNewNumberNode(49);
    GetOrCreateNewNumberNode(49);
    GetOrCreateNewNumberNode(49);
    GetOrCreateNewNumberNode(49);
    GetOrCreateNewNumberNode(49);
    GetOrCreateNewNumberNode(50);
    GetOrCreateNewNumberNode(60);
    GetOrCreateNewNumberNode(64);
    GetOrCreateNewNumberNode(70);
    GetOrCreateNewNumberNode(80);
    GetOrCreateNewNumberNode(81);
    GetOrCreateNewNumberNode(90);
    GetOrCreateNewNumberNode(100);
    GetOrCreateNewNumberNode(110);
    GetOrCreateNewNumberNode(120);
    GetOrCreateNewNumberNode(130);
    GetOrCreateNewNumberNode(140);
    GetOrCreateNewNumberNode(150);
    GetOrCreateNewNumberNode(160);

    //Addition nodes
    Op:=GetNewOperation(1,1, TAddition);CreateNode(Op);
    Op:=GetNewOperation(1,2, TAddition); CreateNode(Op);
    Op:=GetNewOperation(1,3, TAddition); CreateNode(Op);
    Op:=GetNewOperation(1,4, TAddition); CreateNode(Op);
    Op:=GetNewOperation(1,5, TAddition); CreateNode(Op);
    Op:=GetNewOperation(1,6, TAddition); CreateNode(Op);
    Op:=GetNewOperation(1,7, TAddition); CreateNode(Op);
    Op:=GetNewOperation(1,8, TAddition); CreateNode(Op);
    Op:=GetNewOperation(1,9, TAddition); CreateNode(Op);
    Op:=GetNewOperation(2,2, TAddition); CreateNode(Op);
    Op:=GetNewOperation(2,3, TAddition); CreateNode(Op);
    Op:=GetNewOperation(2,4, TAddition); CreateNode(Op);
    Op:=GetNewOperation(2,5, TAddition); CreateNode(Op);
    Op:=GetNewOperation(2,6, TAddition); CreateNode(Op);
    Op:=GetNewOperation(2,7, TAddition); CreateNode(Op);
    Op:=GetNewOperation(2,8, TAddition); CreateNode(Op);
    Op:=GetNewOperation(3,3, TAddition); CreateNode(Op);
    Op:=GetNewOperation(3,4, TAddition); CreateNode(Op);
    Op:=GetNewOperation(3,5, TAddition); CreateNode(Op);
    Op:=GetNewOperation(3,6, TAddition); CreateNode(Op);
    Op:=GetNewOperation(3,7, TAddition); CreateNode(Op);
    Op:=GetNewOperation(4,4, TAddition); CreateNode(Op);
    Op:=GetNewOperation(4,5, TAddition); CreateNode(Op);
    Op:=GetNewOperation(4,6, TAddition); CreateNode(Op);
    Op:=GetNewOperation(5,5, TAddition); CreateNode(Op);
    Op:=GetNewOperation(5,6, TAddition); CreateNode(Op);
    Op:=GetNewOperation(5,7, TAddition); CreateNode(Op);
    Op:=GetNewOperation(6,6, TAddition); CreateNode(Op);
    Op:=GetNewOperation(6,7, TAddition); CreateNode(Op);
    Op:=GetNewOperation(7,7, TAddition); CreateNode(Op);
    Op:=GetNewOperation(7,8, TAddition); CreateNode(Op);
    Op:=GetNewOperation(5,10, TAddition); CreateNode(Op);

    //Subtraction Nodes
    Op:=GetNewOperation(2,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(3,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(4,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(5,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(6,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(7,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(8,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(9,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(3,2, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(4,2, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(5,2, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(6,2, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(7,2, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(8,2, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(4,3, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(5,3, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(6,3, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(7,3, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(5,4, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(6,4, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(8,7, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,1, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,2, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,3, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,4, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,5, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,6, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,7, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,8, TSubtraction); CreateNode(Op);
    Op:=GetNewOperation(10,9, TSubtraction); CreateNode(Op);

    //Multiplication nodes
    Op:=GetNewOperation(2,2, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,3, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,4, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,5, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,6, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,7, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,8, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,9, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,12, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(2,20, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,3, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,4, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,5, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,6, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,7, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,8, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,9, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(3,20, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(4,4, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(4,5, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(4,6, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(4,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(4,20, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(5,5, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(5,6, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(5,8, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(5,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(5,20, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(6,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(6,20, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(7,7, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(7,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(8,8, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(8,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(9,9, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(9,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(10,10, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(11,11, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(10,11, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(12,12, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(10,12, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(10,13, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(10,14, TMultiplication); CreateNode(Op);
    Op:=GetNewOperation(10,15, TMultiplication); CreateNode(Op);


    for I := 0 to Nodes.Count - 1 do
    begin
        NewNode :=Nodes.Items[i];
        ExplodeConnotationsOfNode(NewNode);
        //Automating similarity by finding the nearest numbers on SlipnetSpace
        if NewNode.Content.InheritsFrom(TNumberInteger) then
            ExplodeConnotationsOfIntegerNode(NewNode);
    end;
end;



end.
