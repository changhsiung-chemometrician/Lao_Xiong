function [clistfilename, nfile]=fdir_wildcard(targetPathname,keyword_inside_wildcards,inp)
% similar to fdir but use wildcard to find all file with certain keywords
% if no "*" found in keyword_inside_wildcards, it will use ['*',keyword_inside_wildcards,'*']
% see also wfdir(alias) , fdir , fdir_wPath  , fdir_wildcard_wPath

% e.g. fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','svm')
% e.g.inp.fullpath_yes=1; fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','svm',inp)
% e.g. fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','*svm*zip')
% e.g. fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','*svm*mht')
% e.g. fdir_wildcard_wPath('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','*svm*mht')

prev_dir=pwd;
cd (targetPathname);
% [OPEN ITEM 3, 20 Aug 2026] Backstop for the cd pair below. The explicit
% cd(prev_dir) a few lines down still runs on the normal path; this only
% fires if dir() or arrayfun() throws in between, which would otherwise
% strand the session inside targetPathname.
cleanupObj_fdir_wildcard = onCleanup(@() cd(prev_dir));  %#ok<NASGU>

if isempty(strfind(keyword_inside_wildcards,'*'))
SAlist=dir(['*',keyword_inside_wildcards,'*']);
else
SAlist=dir([keyword_inside_wildcards]);
end

clistfilename=arrayfun(@(x) x.name,SAlist,'uniformoutput',false);
cd (prev_dir);
nfile=length(clistfilename);

 if exist('inp','var') && isfield(inp,'fullpath_yes') && inp.fullpath_yes==1
   clistfilename=cellfun(@(x) [targetPathname,'\',x],clistfilename,'uniformoutput',false);
 end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from StepbyStep_plots.m.
%% ---------------------------------------------------------------
