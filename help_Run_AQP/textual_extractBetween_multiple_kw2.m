function out=textual_extractBetween_multiple_kw2(cstr,kw1,ckw2)
%-------------------------------------------------------------------------------
% function : textual_extractBetween_multiple_kw2(cstr,kw1,ckw2,str_new)
% this is the latest and most powerful version for extracting substrings
% it can handle empty kw1 now (extracting from Begin of each str element in cstr)
% can handle empty entry in ckw2 now, empty kw2 will be treated as "end of str"
% find shortest extraction between kw1 and each of ckw2 
%
% if ckw2 is empty, it will be replaced by {''}
% if ckw2 ischar, it will be replaced by {ckw2} !!!!!!
%
% can handle empty entry in ckw2 now, empty kw2 will be treated as "end of str"
% can handle empty entry in ckw2 now, empty kw2 will be treated as "end of str"
% can handle empty entry in ckw2 now, empty kw2 will be treated as "end of str"
%
% out is same data type as cstr, i.e. is cstr is cell, out is cell, 
% if cstr is char vector, out is char vector too
% 
% if both kw2 and str_new are empty, this work same as "eraseAfter"
% 
% textual_extractBetween_multiple_kw2() is supposed to be able to handle all works for textual_extractBetween()
%          
% see also textual_extractBetween()  textual_eraseAfter
if false
    
    cstr={'abc_ncls5.mat';'def_ncls7_nsamp32.mat';'def_ncls9_nsamp223.mat';'fadfas_ncls_nsamp2356.mat'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'.','_'})
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat','def_ncls7_nsamp32.mat','def_ncls9_nsamp223.mat','fadfas_ncls_nsamp2356.mat'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'.','_','nsamp'})
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat';'def_ncls7_nsamp32.mat';'def_ncls9_nsamp223.mat';'fadfas_ncls nsamp-2356.mat'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'.','_','-'})
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat';'def_ncls7(_Unit-S1-221).mat';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'_','.','('})
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat';'def_ncls7(_Unit-S1-221).mat';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'_','.','('}) %
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the following can handle empty kw2 now
    cstr={'abc_ncls5.mat';'AABB_ncls777';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'_','.',''})
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % the following can handle empty kw2
    
    cstr={'abc_ncls5.mat';'AABB_ncls777';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{''})
    
    % the following can handle empty kw2
    % if ckw2 is empty, it will be replaced by {''}
    
    cstr={'abc_ncls5.mat';'AABB_ncls777';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls','')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % test when cstr is char vector
    cstr='def_ncls7(_Unit-S1-221).mat';
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'_','.','('}) %
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % test when cstr is cell
    cstr={'def_ncls7(_Unit-S1-221).mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'_ncls',{'_','.','('}) % remove section Between kw1 and ckw2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % test when kw1 is empty and single kw2 found, this is OK
    cstr={'def_ncls7_Unit-S1-221).mat';'def_ncls8_Unit-S1-221).mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'',{')'}) % kw1 is empty and single kw2 found , this still OK
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % it can handle empty kw1 now (extracting from Begin of each str element in cstr)
    % test when kw1 is empty but multiple kw2 found
    cstr={'deA_ncls7_Unit-S1-221).mat';'deB_ncls8_Unit-S1-221).mat';'deD_ncls10_Unit-S1-221).mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'',{'_'}) % kw1 is empty but multiple kw2 found
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % test when kw1 is empty but multiple kw2 found
    cstr={'deA_ncls7_Unit-S1-221).mat','deB_ncls8_Unit-S1-221).mat','deD_ncls10_Unit-S1-221).mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'',{'_'}) % kw1 is empty but multiple kw2 found
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % test when kw1 is empty but multiple kw2 but different number of kw2 found
    %
    cstr={'deA_ncls7_Unit-S1-221).mat';'deB_ncls8_Unit-S1-221).mat';'deC_Unit-S1-221).mat';'deD_ncls10_Unit-S1-221).mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'',{'_'}) % kw1 is empty but multiple kw2 found, this is problematic
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % test when missing kw1 in cstr
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'_pp1-','_')
    % test when missing kw1 in cstr
    cstr='Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';
    out=textual_extractBetween_multiple_kw2(cstr,'_pp1-','_')
    % test when missing kw1 in cstr
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'_pp1-','_')
    
    % test when some of cstr have missing kw1
    cstr={'Atrainpketc_ABC_DEF_pp1-SGw5_nsamp231_nsampP222.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'_pp1-','_')
    % test when some of cstr have missing kw1
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_ABC_DEF_pp1-SGw5_nsamp231_nsampP222.mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'_pp1-','_')
    % test when some of cstr have missing kw1
    cstr={'Atrainpketc_ABC_DEF_pp1-1stDer_nsamp231_nsampP222.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_ABC_DEF_pp1-SGw5_nsamp231_nsampP222.mat'};
    out=textual_extractBetween_multiple_kw2(cstr,'_pp1-','_')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % when dealing with extractBetween kw1 to "end of str"
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP212';'Atrainpketc_ABC_DEF_nsamp231_nsampP1234'};
    out=textual_extractBetween_multiple_kw2(cstr,'_nsampP','')
    
    
end % end of examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% handle the case that ckw2 is empty
if isempty(ckw2)
  ckw2={''};  
end
%%%%%%%%
% if ckw2 ischar, it will be replaced by {ckw2} !!!!!!
if  ischar(ckw2)
ckw2={ckw2};
end
%%%%%%%
% check to make sure none of ckw2 is empty
% if all(strlength(string(ckw2)))

% error('still under construction')
if ischar(cstr)
cstr_orig=cstr;
cstr={cstr};
end
sia=string(cstr);
allLx=repmat(NaN,[length(cstr) length(ckw2)]);
for ikw2=1:length(ckw2)
  exAft=  extractAfter(col_always(sia),kw1) ;
  if isempty(ckw2{ikw2})
     exBefAft=exAft;  
  else
    exBefAft=  extractBefore(exAft,ckw2{ikw2}) ;
  end
 allLx(:,ikw2)=strlength(exBefAft);   
    
end

[minLx locLx]=min(allLx,[],2);
locLx=col_always(locLx);

ckw2_match=arrayfun(@(x) ckw2{x},locLx,'un',0);

idx_NOTempty_kw2=logical(strlength(string(ckw2_match)));

% sia_out_NE=replaceBetween(col_always(sia(idx_NOTempty_kw2)),kw1,ckw2_match(idx_NOTempty_kw2),str_new);
try
    
    sia_out_NE=extractBetween(col_always(sia(idx_NOTempty_kw2)),kw1,ckw2_match(idx_NOTempty_kw2));
    
%    cQckw2_match_idx_NOTempty_kw2= unique(ckw2_match(idx_NOTempty_kw2));
%    
%    sia_out_NE=extractBetween(col_always(sia(idx_NOTempty_kw2)),kw1,cQckw2_match_idx_NOTempty_kw2{1}  );

    
    
catch
    loc_NOTempty_kw2=find(idx_NOTempty_kw2);
    sia_out_NE=[];
    for i_NOTempty_kw2=row_always(loc_NOTempty_kw2)
        sia_out_NE_i=extractBetween(col_always(sia(i_NOTempty_kw2)),kw1,ckw2_match{i_NOTempty_kw2});
        if length(sia_out_NE_i)>1
            sia_out_NE_i(2:end)=[];
        end
        if isempty(sia_out_NE_i)
            % fix the following bug such that
            % textual_extractBetween_multiple_kw2 give same results as textual_extractBetween
            % sia_out_NE_i=''; % for string (or sia), change to following line
            sia_out_NE_i=string(''); %for string (or sia) use this reprsentation, otherwise sia_out_NE will not have same length as idx_NOTempty_kw2
            % 
        end
        sia_out_NE=[sia_out_NE;sia_out_NE_i];
    end
end
% 
% catch
% sia_out_NE=extractBetween(col_always(sia(idx_NOTempty_kw2)),repmat({kw1},size(idx_NOTempty_kw2)),ckw2_match(idx_NOTempty_kw2));
%     
% end



% sia_out_E=extractBefore(col_always(sia(~idx_NOTempty_kw2)),kw1)+kw1+str_new;

% sia_out_E=extractBefore(col_always(sia(~idx_NOTempty_kw2)),kw1)+kw1;
sia_out_E=extractAfter(col_always(sia(~idx_NOTempty_kw2)),kw1);



sia_out=sia;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(kw1)
    if ~isempty(sia_out_NE)
        [nRow nCol]=size(sia_out_NE);
        if iscolumn(idx_NOTempty_kw2) && nRow==length(idx_NOTempty_kw2)
            sia_out(idx_NOTempty_kw2)=sia_out_NE(:,1);
            
        elseif isrow(idx_NOTempty_kw2) && nCol==length(idx_NOTempty_kw2)
            % this part may never needed
            sia_out(idx_NOTempty_kw2)=sia_out_NE(1,:);
        else
            
            error('can not handle this yet')
        end
%     else
%        %sia_out=string(''); 
%         disp('conti wo doing anything else')
    end
else
    % sia_out(idx_NOTempty_kw2)=sia_out_NE;
    if length(sia_out_NE)<length(idx_NOTempty_kw2)
        if length(sia_out_NE)==0
        sia_out_NE=repmat(string(''),size(idx_NOTempty_kw2));
%         else
%          error('should not come to here ??? Not ready to handle this yet')   
        end
    end
    try
    sia_out(idx_NOTempty_kw2)=sia_out_NE;
    end
    
    sia_out(~idx_NOTempty_kw2)=sia_out_E;
end

% loc_missing=find(isnan(sia_out.strlength));
loc_NOT_missing=find(~isnan(sia_out.strlength));


out_NOT_missing=cellstr(sia_out(loc_NOT_missing));

out=repmat({''},size(cstr));
out(loc_NOT_missing)=out_NOT_missing;



out=reshape(out,size(cstr));
try
if ischar(cstr_orig)
    out=out{1};
end
end
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
