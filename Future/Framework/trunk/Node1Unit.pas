unit Node1Unit;

interface

uses FARG_Framework_Chunk, Activation1Unit, Classes;

type

        IObserverActivation = Interface
                  procedure Update(A: Real);
           end;


        ISubjectActivation =   Interface
                      procedure RegisterObserver(const Observer: TObject);
                      procedure UnRegisterObserver(const Observer: TObject);
                      procedure Notify (A: TActivation);
                end;


         TActivationObserverClass = Class (TInterfacedObject, IObserverActivation)
                                          {Observer Interface here}
                                          procedure Update(Received_Activation: Real);  virtual;abstract;
                                    end;


         KernelNode = class (TInterfacedObject, ISubjectActivation)
                      Content:TConnotation;
                      associations: tlist;
                      activation: Tactivation;//refactor: REMOVE!


                      constructor create;
                      function GetFullConnotationStructure: TList;
                      Function GetAssociationsOfType(C:TClass):TList;

                      {Observable (Subject) interface here}
                      procedure RegisterObserver(const Observer: TObject);
                      procedure UnRegisterObserver(const Observer: TObject);
                      procedure Notify (Sent_Activation: Tactivation);
                 end;



         KernelLink = Class (TActivationObserverClass)
                 protected
                      //link_drag: real;
                      Dest_Node: KernelNode;

                 public
                      constructor create (origin, destination: KernelNode);
                      Function GetDestinationNode:KernelNode;

                      //Observer Interface here
                      procedure Update(Received_Activation: Real);  override;
                 end;


implementation


Function KernelLink.GetDestinationNode:KernelNode;
begin
     result:= Dest_Node;
end;

constructor KernelNode.create;
begin
     //Activation:= Tactivation.Create;
     Associations:= tlist.Create;
end;

procedure KernelNode.RegisterObserver(const Observer: TObject);
Begin
     Associations.Add(Observer);
end;

function KernelNode.GetFullConnotationStructure: TList;
Var FullContent: TList;
begin
    //gets the FULL content of the node
    FullContent:=TList.Create;
    FullContent:= Content.ListAllConnotations(FullContent);
    result:=FullContent;
end;                                         

function KernelNode.GetAssociationsOfType(C: TClass): TList;
var L:TList;
    x:integer;
    Connotation:TConnotation;
    Link: KernelLink;
begin
    L:=TList.Create;
    for x := 0 to Associations.Count - 1 do
    begin
        Link:=Associations.items[x];
        Connotation:=Link.Dest_Node.Content;
        if (Connotation.InheritsFrom(C)) then
           L.Add(Connotation);
    end;
    result:=L;
end;

procedure KernelNode.UnRegisterObserver(const Observer: TObject);
var x:integer;
begin
     x:=Associations.IndexOf(Observer);
     if x>=0 then Associations.Delete(x);
end;


procedure KernelNode.Notify (Sent_Activation: TActivation);
var  i: Integer; x: KernelLink;
begin
     for i := 0 to Associations.Count-1 do
     begin
          x:= Associations.Items[i];
          X.Update(Activation.Get_Increment/({2*}associations.Count));
     end;
end;

constructor KernelLink.create (origin, destination: KernelNode);
begin
     //Link_drag:= drag;
     Dest_Node:=destination;
     Origin.RegisterObserver(self);
end;

Procedure KernelLink.Update(Received_Activation: real);
//this method received the signal of activation propagation}
var step: real;
begin
     //this method can be refactored to strategy pattern to include other possibilities
     step:= Received_Activation;
     if (step>0) then
     begin
          Dest_node.activation.increase(step);
     end;
end;

end.
