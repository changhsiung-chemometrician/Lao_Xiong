function result=color_CH__strcmp_CI(str1,str2)
%Case Insensitive version of strcmp
% e.g.  strcmp_CI('good','Good')
% strcmp_CI('good','bad')

result=strcmp(lower(str1),lower(str2));
end

%% ---------------------------------------------------------------
%% Split out of StepbyStep_plots.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
