function lastfolder=find_lastfolder(pathname)
% e.g.
% pathname='G:\work\LACIS-III\G3_allr\allr_U3tset\Load-T-Dir_U3_LACIS-IIIa-G3';lastfolder=find_lastfolder(pathname)
% e.g. replace(lastfolder,'-','_');
if ischar(pathname)
    
    all_bs=find(pathname=='\');
    if length(all_bs)>0
        lastfolder=pathname(all_bs(end)+1:end);
    else
        lastfolder=pathname;
    end
    
elseif iscell(pathname)
    
    lastfolder=cellfun(@(x) find_lastfolder(x),pathname,'uniformoutput',false);
    
    
    
else
    error('datatype of pathname not supported');
    
end
end

%% ---------------------------------------------------------------
%% Split out of Cmp_Results.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
