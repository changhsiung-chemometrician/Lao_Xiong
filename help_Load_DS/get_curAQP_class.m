function out=get_curAQP_class(handles)
% used inside AQP(pro) or AQPlite
% typical output should be pro or lite
if   iscell(handles.AQP_class.String) && length(handles.AQP_class.String)>1
    out=handles.AQP_class.String{handles.AQP_class.Value};
else
    out=handles.AQP_class.String;
end
end

%% ---------------------------------------------------------------
%% Split out of Load_DS.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Load_DS, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
