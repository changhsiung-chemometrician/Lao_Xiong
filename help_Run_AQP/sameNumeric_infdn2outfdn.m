function outval= sameNumeric_infdn2outfdn(x,infdn,inval,outfdn)
% find same numeric vector

if all(x.(infdn)==inval)
    outval=x.(outfdn);
else
    outval=[];
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
