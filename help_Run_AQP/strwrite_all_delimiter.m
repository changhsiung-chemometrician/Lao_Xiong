function combined_str=strwrite_all_delimiter(cstr,delimiter)
% convert ALL elements of cstr into a single row of string
% separate each indv str by delimiter specified
% for preparation in comparing multiple strings (stored in a cell)  to see if they all match in two sets
% where cstr MUST be in {1xn cell} format
% use unique to sort the individual strings in the cell before combine them into the combined_unique_str
% for example in comparing the TICname output from LCD when multiple TICnames were detected
% e.g. cstr1={[{'TIC-B'},{'TIC-M'},{'TIC-AA'}]};combined_unique_cs1=strwrite_unique(cstr1);
%%%%%%%%%
% for converting string of text into cell, use strread
% e.g.
% cstr=strread('COCL2_NH3_30RH_75RH_VALID1_U5_111306A.csv','%s','delimiter','_');
% cstr = 
% 
%     'COCL2'
%     'NH3'
%     '30RH'
%     '75RH'
%     'VALID1'
%     'U5'
%     '111306A.csv'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
    strwrite_all_delimiter({'abc','defgg','124'},' & ')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(cstr)==0
  cstr={cstr};  
end


% unique_cstr=unique(cstr{1});
% ns=length(cstr{1});
ns=length(cstr);


combined_str=[];

for is=1:ns
 combined_str=[combined_str,delimiter,cstr{is} ];  
    
end
if ~isempty(delimiter)
combined_str(1:length(delimiter))=[];
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
