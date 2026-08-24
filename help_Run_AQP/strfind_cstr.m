function out=strfind_cstr(PATTERN,cstr)
% Note that input variables' seq is different from strfind !!!
% see -->  IND = STRFIND(TEXT,PATTERN)
%-------------------------------------------------------------------------------
% alias as strmatch_strfind_idx or strmatch_findstr_idx
% strmatch that "index" output same size as cstr with logical true/false, similar to FIND
% can handle first input is cstr and 2nd input is str too
% strmatch_findstr_idx and strmatch_strfind_idx are the SAME
% see also strmatch_strfind_idx
% updated May 21, 2020
out=strmatch_strfind_idx(PATTERN,cstr);
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
