function out=textual_extractBetween(cstr,kw1,kw2)
%===================================================================
% function textual_extractBetween(cstr,kw1,kw2)
% textual_extractBetween_multiple_kw2() is supposed to be able to handle all works for textual_extractBetween()
% inside this function it will call textual_extractBetween_multiple_kw2() first
% only when ~_multiple_kw2() fail, then run its orig version
%
% however, this version has advantage of shorter name, 
% hence you can always call it too
%
% compared to find_keyword_between_markers_cstr, this version will not be
% able to handle cases that contained multiple kw1 or kw2 paired with ''
% while find_keyword_between_markers_cstr will output shortest results
% this version will Not
%
% use string array to extract Between two keywords
% this will handle cell of str and str end with ".mat" etc
% if input cstr is char, out will be char too
% if nothing found, empty will be output
% see also find_keyword_between_markers_cstr textual_extractBetween_multiple_kw2 textual_eraseBetween_rmkw1 textual_replaceBetween  find_keyword_between_markers_wlistRHS  strrep_keyword_between_markers_wlistRHS strrep_keyword_between_markers
%===================================================================
if false
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1 (and last entry will be empty output)
    cstr={'Atrainpketc_ABC_DEF_pp1-SGw5_nsamp231_nsampP222.mat';'Atrainpketc_xhr_pp1-1stDer_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT123_nsampP22.mat';};
    out=textual_extractBetween(cstr,'_pp1-','_')
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1
    cstr='Atrainpketc_ABC_DEF_pp1-SGw5_nsamp231_nsampP222.mat';
    out=textual_extractBetween(cstr,'_pp1-','_')

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1
    cstr='Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';
    out=textual_extractBetween(cstr,'_pp1-','_')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1
    cstr='Atrainpketc_ABC_DEF_nsamp231_nsampP222_pp1-SGw5.mat';% assume missing kw2 were because end with ".mat" etc
    out=textual_extractBetween(cstr,'_pp1-','_')

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nvar119.mat'};
    out=textual_extractBetween(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if input cstr is char, out will be char too
    cstr='Atrainpketc_ABC_DEF_nsamp231_nvar119.mat';
    out=textual_extractBetween(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if input cstr is char, out will be char too
    cstr='Atrainpketc_ABC_DEF_nsamp231.mat';
    out=textual_extractBetween(cstr,'_nsamp','_')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nvar119.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125.mat'};
    out=textual_extractBetween(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % deal with kw2 missing (e.g. at end of str)
    cstr={'Atrainpketc_ABC_DEF_nsamp23.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_ncls3.mat';'Atrainpketc_ABC_DEF_nsamp31.csv';};
    out=textual_extractBetween(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp111_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp122_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp123_nsampT111_nsampP22.mat';};
    out=textual_extractBetween(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT111_nsampP22.mat';};
    out=textual_extractBetween(cstr,'_nsampP','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT121.mat';};
    out=textual_extractBetween(cstr,'_nsampP','_')
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT123_nsampP22.mat';};
    out=textual_extractBetween(cstr,'_nsampT','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % when dealing with extractBetween kw1 to "end of str"
        cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222';'Atrainpketc_ABC_DEF_nsamp231_nsampP123'};
    out=textual_extractBetween(cstr,'_nsampP','')

    
    
    
    
end  % end of examples



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% textual_extractBetween_multiple_kw2() is supposed to be able to handle all works for textual_extractBetween()
% hence, this function will call textual_extractBetween_multiple_kw2() first
% only when ~_multiple_kw2() fail, then run its orig version


try
    % the following is a more flexible and powerful version, 
    % hence try it first
    % 
    out=textual_extractBetween_multiple_kw2(cstr,kw1,kw2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
catch
  % only when ~_multiple_kw2() fail, then run its orig version
  
    
    % this older version can still handle some special cases that above version can not handle
    % 
    %     warning('pls use the more flexible --> textual_extractBetween_multiple_kw2()')
    %     disp_with_border('textual_extractBetween_multiple_kw2() can handle extracting till end of str by using empty as kw2')
    %     disp_with_border('textual_extractBetween_multiple_kw2() can also handle extracting from begin of str to kw2 by using empty kw1')
    %     warning('pls use the more flexible --> textual_extractBetween_multiple_kw2()')
    %     disp_with_border('textual_extractBetween_multiple_kw2() can handle extracting till end of str by using empty as kw2')
    %     disp_with_border('textual_extractBetween_multiple_kw2() can also handle extracting from begin of str to kw2 by using empty kw1')
    % Speak_mk('please use the more flexible --> textual_extractBetween_multiple_kw2()')
    % Speak_mk('Because it can handle empty keyword 1 or keyword 2 cases')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Speak_mk('surprise to see it comes to here ???')
    Speak_mk('textual_extractBetween_multiple_kw2 supposed to able to handle all works for textual_extractBetween')

    if isempty(kw2)
        out= textual_extractBetween_multiple_kw2(cstr,kw1,kw2);
    else
        sia_cstr=string(cstr);
        
        siaOut=sia_cstr;
        
        sia_Aft=extractAfter(sia_cstr,kw1);
        sia_Aft_Bef=extractBefore(sia_Aft,kw2);
        
        idx_NotFound=isnan(strlength(sia_Aft_Bef));
        idx_NotFound_wo_kw1=~contains(sia_cstr,kw1);
        idx_NotFound_w_kw1=idx_NotFound & ~idx_NotFound_wo_kw1;
        
        idx_Found=~isnan(strlength(sia_Aft_Bef));
        
        siaOut_Found=extractBetween(sia_cstr(idx_Found),kw1,kw2);
        siaOut(idx_Found)=siaOut_Found;
        
        if any(idx_NotFound)
            siaOut_NotFound_w_kw1=extractBetween(sia_cstr(idx_NotFound_w_kw1),kw1,'.');% assume missing kw2 were because end with ".mat" etc
            siaOut(idx_NotFound_w_kw1)=siaOut_NotFound_w_kw1;
            if any(idx_NotFound_wo_kw1)
                siaOut(idx_NotFound_wo_kw1) ='';
            end
        end
        out=siaOut.cellstr;
        if ischar(cstr)&& ~isempty(out)
            out=out{1};
        end
    end
    
    
end
end

%% ---------------------------------------------------------------
%% Split out of Cmp_Results.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
