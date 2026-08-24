function disp_cstr(cstr)
% e.g. cstr{1}='fafaffa';cstr{2}='fafdsffafaffa';disp_cstr(cstr)
% e.g. cstr{1}='C:\work\fafaffa.mat';cstr{2}='C:\work\fafdsffafaffa.mat';disp_cstr(cstr)

cellfun(@(x) disp(x),cstr);
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
