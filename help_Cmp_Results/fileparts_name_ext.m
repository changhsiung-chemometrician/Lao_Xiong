function filename= fileparts_name_ext(file)
% modified by Chang to handle the case when file is cell of str
% June 24, 2016
if iscell(file)
    cfilename=[];
    for ifile=1:length(file)
        [PATHSTR,NAME,EXT]=fileparts(file{ifile});
        cfilename=[cfilename;{[NAME,EXT]}];
    end
    filename=cfilename;
    
elseif ischar(file)
    [PATHSTR,NAME,EXT]=fileparts(file);
    filename=[NAME,EXT];
    
else
    error('input file should be cell of str or str')
end
end

%% ---------------------------------------------------------------
%% Split out of Cmp_Results.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
