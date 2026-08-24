function skeyword=find_keyword_between_markers(targetstring,marker1,marker2)
% find keyword between mark1 and marker2
% modify code  to always use last start_loc (or marker1) , Dec 6, 2022
%------------------------------------------------------------------------------------------------------
% if more than one occurances found and skeyword is the same, then return that same skeyword (updated Apr 25, 2020)
%
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
  %=========================================================================
% modify code  to always use last start_loc (or marker1) , Dec 6, 2022
%--------------------------------------------------------------------------
% see also: AQP_rm_replicate_seq_sam
%=========================================================================
  if false
      
      find_keyword_between_markers('S001_mBP120_S001_mBP150','S0','_')  % if only two occurances and skeyword is the same, then return that same skeyword (updated Apr 25, 2020)
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            find_keyword_between_markers('S001_mBP120_S002_mBP150','S0','_')
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %unique found
           find_keyword_between_markers('S001_mBP120_S001_mBP130_S001_mBP140_S001_mBP150','S0','_')  % if only two occurances and skeyword is the same, then return that same skeyword (updated Apr 25, 2020)
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
      % not unique found
                    find_keyword_between_markers('S001_mBP120_S001_mBP130_S001_mBP140_S002_mBP150','S0','_')  % if only two occurances and skeyword is the same, then return that same skeyword (updated Apr 25, 2020)
   
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
           % not unique found
                    find_keyword_between_markers('S001_mBP120_S004_mBP130_S001_mBP140_S001_mBP150','S0','_')  % if only two occurances and skeyword is the same, then return that same skeyword (updated Apr 25, 2020)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %unique found
           find_keyword_between_markers('S008_mBP120_S008_mBP130_S008_mBP140_S008_mBP150_S008_mBP160','S0','_')  % if only two occurances and skeyword is the same, then return that same skeyword (updated Apr 25, 2020)
       %=============================================================
       % revisit this Dec 6, 2022
       % for case not unique marker1 found
       % modify code  to always use last start_loc (or marker1) , Dec 6, 2022
       cc
       skeyword=find_keyword_between_markers('abs_U35_cd_Unknow_ef','_U','_')
       %------------------------------------------------------------------
       % visit Apr 14, 2023
       % fix/remove replicates number in PRO
       % example #1
       % see also: AQP_rm_replicate_seq_sam

        cc
        str0='abs_U35_cd-Unknow-1.sam'
       skeyword=find_keyword_between_markers(str0,'-','.sam');
       newstr=strrep(str0,['-',skeyword,'.sam'],'.sam')
       
       %-------------------------------------------------
       % example #2
       % see also: AQP_rm_replicate_seq_sam
        cc
        str0='abs_U35-cd_Unknow-12.sam'
       skeyword=find_keyword_between_markers(str0,'-','.sam');
       newstr=strrep(str0,['-',skeyword,'.sam'],'.sam')
       %-----------------------------------------------------
       % #3
       % see also: AQP_rm_replicate_seq_sam
        cc
        str0='abs_-U35_-cd__Unk--now-12345.sam'
       skeyword=find_keyword_between_markers(str0,'-','.sam');
       newstr=strrep(str0,['-',skeyword,'.sam'],'.sam')
       
        %-----------------------------------------------------
       % #4
       % see also: AQP_rm_replicate_seq_sam
        cc
        str0='abs_-35_-cd_-23232_Unk_sam-3_sam--now-12345.sam'
       skeyword=find_keyword_between_markers(str0,'-','.sam');
       newstr=strrep(str0,['-',skeyword,'.sam'],'.sam')
          %-----------------------------------------------------
       % #4 this will fail
       % see also: AQP_rm_replicate_seq_sam
        cc
        str0='abs_-35_-cd_-23232_Unk-5.sam-3_sam--now-5.sam'
       skeyword=find_keyword_between_markers(str0,'-','.sam');
       newstr=strrep(str0,['-',skeyword,'.sam'],'.sam')
       %---------------------------------------------------------
       % #5 this still work as long as two skeyword not the same,
       %    since skeyword always capture the last "-#.sam" ?
       % see also: AQP_rm_replicate_seq_sam
       cc
        str0='abs_-35_-cd_-23232_Unk-23.sam-3_sam--now-5322.sam'
       skeyword=find_keyword_between_markers(str0,'-','.sam');
       newstr=strrep(str0,['-',skeyword,'.sam'],'.sam')
      
       
       
       
       
            
  end
  %======================================================================================================================================
% See also : textual_extractBetween textual_replaceBetween strrep_keyword_between_markers  find_keyword_numeric_AFTER_marker find_keynumber_numeric_AFTER_marker  strtok allwords find_keyword_between_markers_wWildCards
    %======================================================================================================================================
      %======================================================================================================================================
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
 skeyword=targetstring(1:all_loc_match_marker2(1)-1);
   
end
%      end
 else
  start_loc=findstr(targetstring,marker1)+length(marker1);
  %===============================================
  % modify code  to always use last start_loc (or marker1) , Dec 6, 2022
  if length(start_loc)>1
      start_loc=start_loc(end);                                                                       % modify code  to always use last start_loc (or marker1) , Dec 6, 2022
  end
  %===============================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  % if more than one occurances found and skeyword is the same, then return that same skeyword (updated Apr 25, 2020)
% block following Dec 6, 2022
if false % block following Dec 6, 2022
    if length(start_loc)>1  % only deal with two occurances case
        for ist=1:length(start_loc)-1
            targetstring_1stpart= targetstring(start_loc(ist)-length(marker1):start_loc(ist+1)-length(marker1)-1);;
            skeyword_1stpart=textual_extractBetween( targetstring_1stpart,marker1,marker2);
            if ist==length(start_loc)-1
                targetstring_2ndpart=targetstring(start_loc(ist+1)-length(marker1):end);
            else
                targetstring_2ndpart=targetstring(start_loc(ist+1)-length(marker1):start_loc(ist+2)-length(marker1)-1);
            end
            skeyword_2ndpart=textual_extractBetween( targetstring_2ndpart,marker1,marker2);
            if strcmp(skeyword_1stpart,skeyword_2ndpart)
                skeyword=skeyword_1stpart;
            else
                skeyword=[];
                return;
            end
        end  %end of ist
        return;
    end
end   % block above section, Dec 6, 2022
% block above section, Dec 6, 2022
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if length(start_loc)==1
         if length(marker2)==0

             skeyword=targetstring(start_loc:end);
         else
             all_loc_match_marker2=findstr(targetstring,marker2);
             all_loc_match_marker2_occurlater=all_loc_match_marker2(find(all_loc_match_marker2>start_loc  ));
             if isempty(all_loc_match_marker2_occurlater)
               skeyword=[];  
             else
             end_loc=all_loc_match_marker2_occurlater(1)-1;
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
             warning('more than one mark1 AND not unique mark2');
             skeyword=[];
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
%% Split out of Cmp_Results.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
