function rowvector=row_always(inputvector)
% can handle either 1D numeric array or cell array
% see also col_always
% e.g. row_always([1 2 3])
% e.g. row_always([1 ;2 ;3])
% e.g. row_always({'ab';'bcd';'efgg'})
% e.g. row_always([1 2 3; 4 5 6])
%
%%%%%%%%%%%%%%%%%%%%%
size_inputvector=size(inputvector);
if isempty(inputvector)
    rowvector=inputvector;
elseif  size_inputvector(1)>1 & size_inputvector(2)>1
    error('inputvector is not a 1D vector');
else
    if size_inputvector(1)>1
       rowvector=inputvector';
    else
         rowvector=inputvector;
    end
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
