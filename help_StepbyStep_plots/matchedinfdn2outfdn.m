function outval= matchedinfdn2outfdn(x,infdn,inval,outfdn)
% find matching string

if color_CH__strcmp_CI(x.(infdn),inval)
    outval=x.(outfdn);
else
    outval=[];
end
end

%% ---------------------------------------------------------------
%% Split out of StepbyStep_plots.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
