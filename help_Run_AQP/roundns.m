function y = roundns(x,d)


if false
    %%%%%%%%%%%%%%%%
    roundns(2.3348,3)
    
   %%%%%%%%%%%%%%%%%%%%% 
     roundns(2.3343)
   %%%%%%%%%%%%%%%%%%%%%%%
   
    roundns(2.5543)
   %%%%%%%%%%%%%%%%%%%%%%%
   
   
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 1
    y = round(x);
    y=deblank(num2str(y));

else
   
    y = round(10^d*x)/10^d;
    y=deblank(num2str(y));
      
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
