function name = filename(file)
    [~, name, ~] = fileparts(file);
end

%% ---------------------------------------------------------------
%% Split out of Cmp_Results.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
