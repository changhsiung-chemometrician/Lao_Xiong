function cstr=color_CH__remove_empty_cell(cstr)
% output string if cstr become single cell !!!
loc=cellfun(@(x) isempty(x),cstr);
cstr(loc)=[];

if iscell(cstr) && length(cstr)==1
    cstr=cstr{1};        % output the content if cstr become single cell !!!
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
