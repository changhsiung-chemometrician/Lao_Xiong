function out=done_with_this_function()
% put this at end of any function to show which function is this
% see also: PLOT_MCC_ML_OCM_ScanThru_AUCthres
% see also: mfilename, me, find_parent_calling_function, PLOT_MCC_ML_OCM_ScanThru_AUCthres, test_me, predict_gnb_NaiveBayes, RUN_XGB_CmpClsfr

aStack = dbstack;
if length(aStack)>1
    aName = aStack(2).name;   % this (or "2") is the parent function that is calling this current function and in case there is "3" that will be the grandparent
  disp(['done with --> ',aName]);  
  out=aName;
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
