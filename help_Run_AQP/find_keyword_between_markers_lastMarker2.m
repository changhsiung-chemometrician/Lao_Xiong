function skeyword=find_keyword_between_markers_lastMarker2(targetstring,marker1,marker2)
% find keyword between mark1 and marker2
% instead of find keyword between marker1 and closest marker2, 
% this find that between marker1 vs LAST marker2 !!!
% if marker1 or marker2 is empty, then find keyword between begin/end and marker
% e.g. skeyword=find_keyword_between_markers('F:\test\U202\ARFCAM\all_R_test.mat','\U','\')
% this one should cause problem e.g. skeyword=find_keyword_between_markers('F:\test\test_U202\ARFCAM\all_R_U201_test.mat','_U','\') 
% e.g. skeyword=find_keyword_between_markers('F:\test\U202','\U',[])
% for case not unique marker1 found
% e.g. skeyword=find_keyword_between_markers('abs_U35_cd_Unknow_ef','_u','_')
%
% e.g. skeyword=find_keyword_between_markers('F:\work\U202\ETOX flag\Results','\',' flag\')
 % e.g. skeyword=find_keyword_between_markers('ETOX flag\Results',[],' flag\')
  % e.g. skeyword=find_keyword_between_markers('ETOX flag\Results',[],'flag*\')  %this will cause error due to wildcard exist in marker2
  % 
% See also : find_keyword_numeric_AFTER_marker find_keynumber_numeric_AFTER_marker  strtok allwords find_keyword_between_markers_wWildCards
  if false
      
 find_keyword_between_markers_lastMarker2('T-abc-de_F-g','','-')
     
find_keyword_between_markers_lastMarker2('T-abc-de_F-g','T-','-')

find_keyword_between_markers_lastMarker2('T-abc_T-de_F_gg-h_gg_HH','T-','_gg')

find_keyword_between_markers_lastMarker2('T-abc_T-de_F_gg-h','T-','_gg')

find_keyword_between_markers_lastMarker2('T-abc_T-de_F_gg-h_gg_HH','T-','')

find_keyword_between_markers_lastMarker2('T-abc-de_F-g','T-','-g')

%%%%%%%%%%%%%%%%%%%%%%%%%
L=load_local_try('AclabelT_orig_DM0617.mat')
AclabelT=cellfun(@(x) find_keyword_between_markers_lastMarker2(x,'','-'),L.AclabelT_orig,'un',false)


  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(targetstring)&& length(targetstring)==1
    targetstring=targetstring{1};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check if there is wildcard (*) inside marker1 or marker2, if YES, need to
%switch to use find_keyword_between_markers_wWildCards.m
loc_wc1=strfind(marker1,'*');
loc_wc2=strfind(marker2,'*');

if ~isempty(loc_wc1) || ~isempty(loc_wc2)
    error('this version can not handle wildcards (*) in marker1 or marker2, pls use find_keyword_between_markers_wWildCards.m')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(marker1)==0
    all_loc_match_marker2=findstr(targetstring,marker2);
    %      if length(all_loc_match_marker2)~=1
    %          warning('marker1 empty and loc of marker2 not unique');
    %          skeyword=[];
    %      else
    
    if ~isempty(marker2) && isempty(all_loc_match_marker2)
        skeyword=[];
    elseif isempty(marker2)
        skeyword = targetstring;
    else
        
        %   skeyword=targetstring(1:all_loc_match_marker2(1)-1);
        skeyword=targetstring(1:all_loc_match_marker2(end)-1);% this find that between marker1 vs LAST marker2 !!!
        
        
    end
    %      end
else
    start_loc=findstr(targetstring,marker1)+length(marker1);
    
    if length(start_loc)==1
        if length(marker2)==0
            
            skeyword=targetstring(start_loc:end);
        else
            all_loc_match_marker2=findstr(targetstring,marker2);
            all_loc_match_marker2_occurlater=all_loc_match_marker2(find(all_loc_match_marker2>start_loc  ));
            if isempty(all_loc_match_marker2_occurlater)
                skeyword=[];
            else
                %end_loc=all_loc_match_marker2_occurlater(1)-1;
                end_loc=all_loc_match_marker2_occurlater(end)-1;% this find that between marker1 vs LAST marker2 !!!
                skeyword=targetstring(start_loc:end_loc);
            end
        end
        
    elseif length(start_loc)>1
        
        all_loc_match_marker2=findstr(targetstring,marker2);
        
        if length(all_loc_match_marker2)~=1
            
            
            if  length(marker2)==0
                skeyword=targetstring(start_loc(end):end);
                
            elseif length(all_loc_match_marker2)==0
                skeyword=[];
                
            else
                %warning('more than one mark1 AND not unique mark2');
                %skeyword=[];
                skeyword=targetstring(start_loc(end):all_loc_match_marker2(end)-1);% will find keyword between last marker1 and last marker2
                
                
            end
            
            
            
            
        else
            all_loc_match_marker1_occurearly=start_loc(find(start_loc<all_loc_match_marker2 ));
            
            %            closest_start_loc=  all_loc_match_marker1_occurearly(end)+length(marker1);
            closest_start_loc=  all_loc_match_marker1_occurearly(end); %new approach March 19, 2014
            
            
            %              skeyword=targetstring(closest_start_loc-1:all_loc_match_marker2-1);
            skeyword=targetstring(closest_start_loc:all_loc_match_marker2-1);%new approach March 19, 2014
            
            
            
        end
        
    else
        
        % warning('can not find marker1');
        skeyword=[];
    end
    
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
