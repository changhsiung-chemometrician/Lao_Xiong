function out=cell_unwrap(cstr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unwrap cells inside each cell element and output a col vector cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if false
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abd';'fasfda';'fsafda'};
    out=cell_unwrap(cstr)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={{'abd'};{'fasfda','fasfaasdsds'};{'fsafda'}};
    out=cell_unwrap(cstr)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={{'abd'};{'fasfdasffss';'dsds'};{'fsafda'}};
    out=cell_unwrap(cstr)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=[];
for i=1:length(cstr)
    if iscell(cstr(i)) && ischar(cstr{i})
        eacstr=cstr(i);
    elseif iscell(cstr(i)) && iscell(cstr{i})
        eacstr=cstr{i};
    else
        out=cstr;
        disp('can not unwrap');
        return
    end
    out=[out;col_vector_ALWAYS( eacstr)];
    
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
