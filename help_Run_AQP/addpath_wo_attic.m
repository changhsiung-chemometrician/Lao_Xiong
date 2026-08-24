function addpath_wo_attic(varargin)
% a new version that will show which folder can not be added
% e.g addpath_wo_attic('G:\work\Mfiles')
% see also genpath_wo_attic
%
% genpath_wo_attic: generate clist of all subfolders exclude all "attic"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    
start_path=uigetdir(pwd, 'Pick a starting path to add with subfolders');
else
 start_path=  varargin{1}; 
end

list_dir=genpath(start_path);
clist_dir=strread(list_dir,'%s','delimiter',';');

loc_attic=[];
for idir=1:length(clist_dir)
if length(findstr('attic',lower(clist_dir{idir})))>0
loc_attic=[loc_attic;idir];    
end
    
end
clist_dir(loc_attic)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
slist_dir=strwrite_all_delimiter(clist_dir,';');
catch
%   error(['can not find: ',start_path]) 
error([' can not find -->  "strwrite_all_delimiter.m," or ',start_path])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(slist_dir);

clist_dir_wo_attic=strread(slist_dir,'%s','delimiter',';');
disp_with_border(['the previous ',num2str(length(clist_dir_wo_attic)),' subfolders have been added to path !!!']);
disp_with_border(['set to path (include subfolders): ',start_path]);
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
