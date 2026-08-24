function colvector=col_always(inputvector)
% can handle either 1D numeric array or cell array
% see also row_always
% e.g. col_always([1 2 3])
% e.g. col_always([1 ;2 ;3])
% e.g. col_always({'ab','bcd','efgg'})
% e.g. col_always([1 2 3; 4 5 6])

size_inputvector=size(inputvector);
if isempty(inputvector)
    colvector=inputvector;
elseif  size_inputvector(1)>1 & size_inputvector(2)>1
    error('inputvector is not a 1D vector');
else
    if size_inputvector(1)>1
        colvector=inputvector;
    else
        colvector=inputvector';
    end
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
