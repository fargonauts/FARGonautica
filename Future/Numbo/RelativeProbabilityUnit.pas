unit RelativeProbabilityUnit;

interface

uses math;

Const Sigmoid_Max_Steps=50;  

type

    TRelative_Probability = class
                                 My_initial_Run, sum_activation: real;

                                 Constructor create;
                                 Procedure feedback(f:real);
                                 function get_Fitness:real;
                                 Function Check_Range(Current_State:real):real;
                                 Function Sigmoid(x:real):Real;
                                 Procedure Add_Feedback(f:Real);
                                 Procedure DecayFitness;
                                 Function get_Success_Runs:real;
                                 Procedure Init_Sucess_Runs;
                             end;

implementation

var success_runs:real;


Procedure TRelative_Probability.DecayFitness;
begin
     Sum_Activation:= Sum_Activation*0.9;
end;

Procedure TRelative_Probability.Add_Feedback(f:Real);  {called once from macro.processfeedback}
begin
     if f>0 then success_runs:=success_runs+f else success_runs:=success_runs-f; 
end;

Procedure TRelative_Probability.feedback(f:real);      {called from macro.processfeedback FOR each pair of commands in the ACT}
begin
     Sum_Activation:=Sum_activation+F;
end;

Constructor TRelative_Probability.create;
begin
     {if success_runs=0 then success_runs:=1;}

     My_initial_Run:=success_runs-1;
     sum_activation:=0.1;
end;

Function TRelative_Probability.Check_Range(Current_State:real):real;
begin
     if Current_state<0.01 then Current_state:=0.01 else
        if Current_state>0.99 then current_state:=0.99;
     result:=Current_State;
end;

Function TRelative_Probability.Sigmoid(x:real):Real;  {Sigmoid code here!}
var pyramid, sum, t:real;  counter: integer;
begin
     Sum:=0;
     for counter:= 0 to floor (x*Sigmoid_max_Steps) do
     begin
          t:= counter/sigmoid_max_steps;
          If(t<0.5) then Pyramid:=t else pyramid :=1-t;
          Sum:=(4*(1/sigmoid_max_steps)* Pyramid) + Sum;
     end;
     REsult:= Sum;
end;



Function TRelative_Probability.get_Success_Runs:real;
begin
     result:= success_runs;
end;

Procedure TRelative_Probability.Init_Sucess_Runs;
begin
     Success_Runs:=-0.01;
end;

function TRelative_Probability.get_Fitness:real;
var f: real;
begin
     if (success_runs-my_initial_run)=0 then my_initial_run:=my_initial_run-1; {can't devide by zero anymore}
     f:=sum_activation/(success_runs-my_initial_run);
{     f:=sigmoid(f);}
     f:=Check_Range (f);
     result:=f;
end;






end.
