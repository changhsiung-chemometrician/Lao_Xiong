function set_XTickLabel(h_axes,clistxticklabel,deg,fontsize)
 % ask Perperity and fix this Apr 9, 2024
% this version is better than --> rotate_xticklabel_anydeg(clistxticklabel,deg,fontsize)
%
% use \newline to parse each XTickLabel into two lines 
% see for example -->cmp_HFA_ILCQ_RMSEP_etc
% --------------------------------------------------------
% revisit this Aug 25, 2023
% see also: example_XTickLabel_multiple_lines_or_newline , diagnose_misP_iACPmp_MID_Only
%-------------------------------------------------------
% see also: set_XTickLabel_newline ( updated Aug 25, 2023 )
%----------------------------------------------
% see also: set_YTick_clistclslabel
%---------------------------------------------------------
if false
    
    cc
    figure;
    plot([1:10],'b-*');
    clistxticklabel=cellstr([1:10]+"_"+'Test_underscore');
    set_XTickLabel(gca,clistxticklabel,-45,12);
    
end

%========================================================================================
%--------------------------------------------------------------
set(h_axes, 'TickLabelInterpreter', 'none');  % ask Perperity and fix this Apr 9, 2024   % see also: set_YTick_clistclslabel

set(h_axes,'XTick',[1:length(clistxticklabel)], 'XTickLabel', clistxticklabel,'XTickLabelRotation',deg,'fontsize',fontsize);
end

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
