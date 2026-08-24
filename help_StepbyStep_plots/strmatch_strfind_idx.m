function out=strmatch_strfind_idx(str,cstr)
% strmatch that "index" output same size as cstr with logical true/false, similar to FIND
% can handle first input is cstr and 2nd input is str too
% strmatch_findstr_idx and strmatch_strfind_idx are the SAME
% see also strfind_cstr  strmatch_findstr_idx  containstr  strmatch_findstr
% updated by CH, Feb 3, 2020
if ischar(cstr) && iscell(str)
out=cellfun(@(x) ~isempty(strfind(x,cstr)),str);
elseif ischar(str) && iscell(cstr)
out=cellfun(@(x) ~isempty(strfind(x,str)),cstr);
else
    error('can not handle this case of str and cstr')
end
end

%% ---------------------------------------------------------------
%% Split out of StepbyStep_plots.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
