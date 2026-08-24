function [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(targetPathname,keyword_inside_wildcards,sext)
% this one should be the most useful one for finding files under a folder
% similar to fdir_wildcard_wPath, but user can specify filename ext
% similar to fdir but use wildcard to find all file with certain keywords
%-----------------------------------------------------------------------
% this one should be the most useful one for finding files under a folder
%------------------------------------------------------------------------
% see also fdir_wildcard_ext_woPath  fdir_wildcard_wPath  wfdir_wPath (alias) ,  fdir, fdir_wildcard, fdir_wPath
%  see also: example_recursiveDir
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% this one should be the most useful one to acquire files under a folder
% this one should be the most useful one to acquire files under a folder
%========================================================================

%======================================================================
if false
    
[clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath('C:\work\Ames\SVM_PLS\test_CAalgo\AmiSept9CL2','AmiSept9CL2','csv');
disp_cstr(clistfilename_out);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[clistfilename, nfile]=fdir_wildcard(targetPathname,keyword_inside_wildcards);

% clistfilename_wMatch_ext=clistfilename(cellfun(@(x) strcmp(x(end-length(sext):end),['.',sext]),clistfilename));

clistfilename_wMatch_ext=clistfilename(cellfun(@(x) ~isempty(strfind(x,['.',sext])),clistfilename));

clistfilename_out=cellfun(@(x) [targetPathname,'\',x],clistfilename_wMatch_ext,'uniformoutput',false);
nfile_out=length(clistfilename_out);
end

%% ---------------------------------------------------------------
%% Split out of StepbyStep_plots.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 3 of the four AQP action mains: Cmp_Results, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
