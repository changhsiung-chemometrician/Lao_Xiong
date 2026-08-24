function handles = Cmp_Results(hObject, eventdata, handles)
% CMP_RESULTS  Standalone extraction of Cmp_Results_Callback from AQP_gui.m
%
%   handles = Cmp_Results(hObject, eventdata, handles)
%
%   Source control : pushbutton - Compare Results
%   What it does   : Replays the comparison report over the final results subfolder
% recorded by the last AQP run.
%
%   This callback adds no plain struct fields; handles is returned
%   anyway so the calling convention matches Run_AQP.m and so a
%   future edit that does add a field cannot silently lose it.
%
%   The callback body below is followed by the helpers it needs as
%   file-private local functions. Every function - primary and local alike -
%   is closed with its own matching end.
%
%   NOTE (22 Aug 2026): the header used to claim a "complete 25-function
%   reachable closure". It is not one - only find_keyword_merge_dual_curly_-
%   bracket, ismember_wMatchLoc and strwrite_all_space were ever folded in.
%   fdir_wildcard_ext_wPath, find_keyword_between_markers, fileparts_name_ext,
%   find_lastfolder, set_XTickLabel, row_always and done_with_this_function
%   still resolve through the MATLAB path, so those .m files must stay on it.
%   The CmpR_~ block added at the bottom is genuinely self-contained (base
%   MATLAB plus warndlg/questdlg only).
%
%   Extracted 20 August 2026 by the same dependency-closure procedure used for
%   Run_AQP.m on 19 Aug 2026. Edits to the moved body are tagged [EXTRACTED].

    handles = Cmp_Results_Callback(hObject, eventdata, handles);
end



% =========================================================================
% [EXTRACTED] The moved callback body. Verbatim from AQP_gui.m lines 779-789
% except for the tagged edits below.
% =========================================================================
function handles = Cmp_Results_Callback(hObject, eventdata, handles)   % [EXTRACTED] signature now returns handles
% hObject    handle to close_figs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles;

%  path_Results_AQP='C:\work\JDSU\Test_AQP_PowerUser\Result4OUT_cln_AQP\S1_RS_T375_P376[Caffeine](woCabXfer)_AQPpu_7schemes'
% path_Results_AQP='C:\work\JDSU\Test_AQP_PowerUser\Result4OUT_cln_AQP\Brix_34Conc_wNaN4Pol[Brix](MDC)_AQPpu_7schemes'
Cmp_Results_AQP(handles.OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder);
end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% ----- from AQP_gui.m: Cmp_Results_AQP (lines 8108-8240)
function out_CR = Cmp_Results_AQP(path_Results_AQP,inp)
% Compare RMSE(P) across EVERY "Results_AQP~.mat" found in one folder.
%
% Match cPP_ifile's RMSE to Q_cLegendLoop_jLine, Aug 2, 2020
% see also: BatchRun_AutoQuant_DA_pipeline(InpBR)
%
% =========================================================================
% [REWRITTEN 22 Aug 2026]  What changed vs the Aug-2020 / Aug-2023 version
% -------------------------------------------------------------------------
%  1. N FILES, NOT EXACTLY TWO.  The old body hard-errored with
%     'Not exactly two "Results_AQP~.mat" files in this folder'.  Any number
%     >= 2 is now drawn, each with its own colour/marker.
%
%  2. DIFFERENT CabXfer_scheme IS NOW A FIRST-CLASS COMPARISON.  The old
%     legend was built ONLY from the 'Spectra_Avg_~' token in the file name,
%     so two runs that differed only by calibration-transfer scheme
%     (woCabXfer vs MDC vs ...) produced two IDENTICAL legend entries and an
%     unreadable plot.  A "series" is now a (file x CabXfer_scheme) pair -
%     which also covers the case of ONE file that itself holds more than one
%     scheme (cCabXfer_scheme with >1 entry inside one run), where the old
%     ismember() silently kept only the first of the duplicated x labels.
%
%  3. THE LEGEND IS BUILT FROM WHATEVER ACTUALLY VARIES across the series -
%     Spectra_Avg method, CabXfer scheme, PP anchor ({~-PP1}/{~-PP2}), and
%     as a last resort the distinct part of the file name.  When only the
%     Spectra_Avg method varies the legend is exactly the old
%     'Spectra -->All' / 'Spectra -->Mean' pair, so the original
%     Spectra_Avg_All vs Spectra_Avg_Mean plot is preserved unchanged.
%     Whatever is COMMON to all series moves into the title.
%
%  4. MISMATCHED x-AXIS IS REPORTED, NOT SWALLOWED.  If the files do not
%     carry the same PP1+PP2 scheme list, the union is drawn and every gap
%     is listed in the command window (or raises an error when
%     inp.strict_XTick=1).  See also CmpR_check_XTick_before_store, which
%     stops such a file from landing in the comparison folder in the first
%     place.
%
%  5. Interpreter 'none' for legend/title (the tokens contain '_' and '{}',
%     which the default tex interpreter mangles), real newline instead of
%     the literal '\newline' in the x tick labels (set_XTickLabel sets
%     TickLabelInterpreter to 'none' since Apr 2024, so '\newline' had been
%     printing verbatim).
% -------------------------------------------------------------------------
% inp - all fields optional
%   .XTick_order      'as-run' (default) | 'sorted'
%   .strict_XTick     0 (default) | 1   -> error instead of warn on mismatch
%   .split_by_CabXfer 1 (default)       -> one series per CabXfer scheme
%   .markersize       12 (default)
%   .connect_lines    0 (default) | 1   -> join the markers with a line
%   .wrap_XTickLabel  1 (default)       -> break 'PP1+PP2' onto two lines
%   .grid_yes         1 (default)
%
% out_CR - .clistfilename_out .Q_cLegendLoop_jLine .S .clegend .cMissing .hf
%
% see also: BatchRun_AutoQuant_DA_pipeline  CmpR_check_XTick_before_store
% =========================================================================
if false

    cc
%     path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Brix_34Conc_wNaN4Pol_wVAL[Brix](MDC)_CM-SA_3schemes'
%     path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Ed_ds1018_4_Ref4XS_woXRS[Property1](woCabXfer)_CM-SA_6schemes'

  %   path_Results_AQP='C:\work\JDSU\Test_AQP\Results_AQP\test_PowerUser_AQP\pp1_pp2_CM-SA_6schemes';
%     path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Brix_34Conc_wNaN4Pol_wVAL[Brix](MDC)_CM-SA_6schemes'
 path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\S1_RS_T375_P376[Caffeine](woCabXfer)_AQPpu_7schemes'
    Cmp_Results_AQP(path_Results_AQP)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cc
%     path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\S1_RS_T375_P376[Caffeine]()_AQPpu_3_vs_7schemes_Spectra-All'
    path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\S1_RS_T375_P376[Caffeine]()_AQPpu_3_vs_7schemes_Spectra-Mean'
    Cmp_Results_AQP(path_Results_AQP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demo AQPlite power user ( Aug 13, 2020)
cc
 path_Results_AQP='C:\work\JDSU\Test_AQP_PowerUser\Result4OUT_cln_AQP\S1_RS_T375_P376[Caffeine](woCabXfer)_AQPpu_7schemes'
% path_Results_AQP='C:\work\JDSU\Test_AQP_PowerUser\Result4OUT_cln_AQP\Brix_34Conc_wNaN4Pol[Brix](MDC)_AQPpu_7schemes'
Cmp_Results_AQP(path_Results_AQP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cc
% path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Cmp_Ricotta[Humidity](MDC)_42schemes'
% path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Cmp_Ricotta[Fat](MDC)_42schemes'
% path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Cmp_Ricotta[Salt](MDC)_42schemes'
    path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Cmp_Ricotta[pH](MDC)_42schemes'
% path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Cmp_Ricotta[Fat](MDC)_42schemes_MSC_vs_SNV'

Cmp_Results_AQP(path_Results_AQP)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % [NEW, Aug 22, 2026] mixed CabXfer schemes, three or more files
    cc
    path_Results_AQP='C:\work\JDSU\Test_AQP\Result4OUT_cln_AQP\Cmp_woCabXfer_vs_MDC_vs_PDS[Brix]_7schemes'
    inp.strict_XTick=0;
    out_CR=Cmp_Results_AQP(path_Results_AQP,inp)
    disp_cstr(out_CR.clegend);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<2
    inp=struct;
end
inp=CmpR_defaults(inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(groot,'defaultLineLineWidth',2);
[clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(path_Results_AQP,'Results_AQP' ,'mat');

if nfile_out<2
    set(groot,'defaultLineLineWidth',0.5);
    error('Cmp_Results_AQP:need_two_files','%s',['Need at least two "Results_AQP~.mat" files in this folder --> ',path_Results_AQP]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% one SERIES per (file x CabXfer_scheme); a file with a single scheme
% (the usual case) stays one series, exactly as before
S=CmpR_build_series(clistfilename_out,inp);
nS=numel(S);
if nS<2
    set(groot,'defaultLineLineWidth',0.5);
    error('Cmp_Results_AQP:need_two_series','%s',['Could not read two usable series out of --> ',path_Results_AQP]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the x axis (typically the PP1+PP2 scheme list) shared by all series
cAll=cell(nS,1);
for iS=1:nS
    cAll{iS}=S(iS).cXT;
end
XT_same_yes=true;
for iS=2:nS
    if ~isequal(cAll{iS},cAll{1})
        XT_same_yes=false;
        break
    end
end
if XT_same_yes
    Q_cLegendLoop_jLine=cAll{1};                       % keep the as-run order
else
    if strcmpi(inp.XTick_order,'sorted')
        Q_cLegendLoop_jLine=unique(cat(1,cAll{:}));
    else
        Q_cLegendLoop_jLine=CmpR_unique_stable(cat(1,cAll{:}));
    end
end
Q_cLegendLoop_jLine=Q_cLegendLoop_jLine(:);
nQ=numel(Q_cLegendLoop_jLine);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% report (or refuse) any x-axis gap
cMissing=cell(nS,1);
for iS=1:nS
    cMissing{iS}=Q_cLegendLoop_jLine(~ismember(Q_cLegendLoop_jLine,S(iS).cXT));
end
if ~XT_same_yes
    smsg=CmpR_report_XTick_gaps(S,Q_cLegendLoop_jLine,cMissing);
    if inp.strict_XTick
        set(groot,'defaultLineLineWidth',0.5);
        error('Cmp_Results_AQP:XTick_mismatch','%s',smsg);
    else
        warning('Cmp_Results_AQP:XTick_mismatch','%s',smsg);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% legend from whatever actually differs between the series
clegend=CmpR_build_legend(S);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hf=figure;
hold on;
if inp.grid_yes
    grid on;
end
hp=[];
for iS=1:nS
    [scol,smkr]=CmpR_style(iS);
    [tf,loc]=ismember(Q_cLegendLoop_jLine,S(iS).cXT);
    xpos=find(tf);
    yval=S(iS).RMSE(loc(tf));
    if inp.connect_lines
        sls='-';
    else
        sls='none';
    end
    hpi=plot(xpos,yval,'LineStyle',sls,'Marker',smkr,'Color',scol, ...
        'MarkerSize',inp.markersize);
    hp=[hp,hpi];   % concat, NOT hp(iS)= : hp starts as [] (double) and a Line
                   % object can not be written into a double array element
end
legend(hp,clegend,'Interpreter','none','Location','best');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [XTICKLABEL, 22 Aug 2026] NOT set_XTickLabel: it forces
% TickLabelInterpreter 'none', under which neither '\newline' nor a real
% newline char wraps - the first prints verbatim, the second truncates the
% label.  CmpR_set_XTickLabel_wrap escapes the tex-special characters and
% then uses tex + \newline, which wraps and still shows '_' and '{}' as
% themselves.
inp4XTL.wrap_yes=inp.wrap_XTickLabel;
CmpR_set_XTickLabel_wrap(gca,Q_cLegendLoop_jLine,-45,8,inp4XTL);
xlim([0.5 nQ+0.5]);

% xlabel('scan thru 9 combinations of derivatives')
ylabel('RMSEP');
%%%%%%%%%%%%%
try
    stit1=find_keyword_merge_dual_curly_bracket(clistfilename_out{1});
catch
    stit1='';
end
stit3=find_lastfolder(path_Results_AQP);
%%%%%%%%%%%%%
% what is COMMON to every series belongs in the title (what DIFFERS is already in the legend)
stit2=CmpR_common_title(S);
%%%%%%%%%%%%%%%%%
ctitle={stit1;stit3;stit2};
if ~XT_same_yes
    ctitle=[ctitle;{['NOTE: x-axis entries differ between files -> union of ', ...
        num2str(nQ),' schemes shown (see command window)']}];
end
ctitle=ctitle(~cellfun(@isempty,ctitle));
title(ctitle,'Interpreter','none');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(groot,'defaultLineLineWidth',0.5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out_CR.clistfilename_out=clistfilename_out;
out_CR.nfile_out=nfile_out;
out_CR.Q_cLegendLoop_jLine=Q_cLegendLoop_jLine;
out_CR.XT_same_yes=XT_same_yes;
out_CR.S=S;
out_CR.clegend=clegend;
out_CR.cMissing=cMissing;
out_CR.hf=hf;

done_with_this_function;
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% ----- from AQP_gui.m: find_keyword_merge_dual_curly_bracket (lines 22472-22565)
function [skeyword ]=find_keyword_merge_dual_curly_bracket(targetstring,inp)
% if need to also output "targetstring_remain" --> find_keyword_merge_dual_curly_bracket_w_targetstring_remain
% can only deal with two set of curly brackets
% when only one set of curly bracket exist, output based on that one set of curly bracket
% inp.keep_curly_yes -->default to 1
%
% see also: find_keyword_merge_dual_curly_bracket_w_targetstring_remain  merge_dual_curly_bracket, RUN_XGB_CmpClsfr
if false
    
    % inp.keep_curly_yes -->default to 1
    cc
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{P-3_T-2-FQ}_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
   [skeyword ]= find_keyword_merge_dual_curly_bracket(targetstring)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % do NOT keep curly brackets on either side
    clear
    inp.keep_curly_yes=0;
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{P-3_T-2-FQ}_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
    [skeyword ]=  find_keyword_merge_dual_curly_bracket(targetstring,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % when only one set of curly bracket
    cc
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
     [skeyword ]=find_keyword_merge_dual_curly_bracket(targetstring)
    %%%%%%%%%%%%%%%%%%%%%
    % when only one set of curly bracket
    clear
    inp.keep_curly_yes=0;
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
     [skeyword ]=find_keyword_merge_dual_curly_bracket(targetstring,inp)
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fname_ifcb=targetstring;

if nargin==1
    keep_curly_yes=1;   %--> default to 1
elseif nargin==2
    try
        keep_curly_yes=   inp.keep_curly_yes;
    catch
        keep_curly_yes=1;   %--> default to 1
    end
else
    error('number of input arguments can only be 1 or 2')
end
cb2= find_keyword_between_markers_lastMarker2(fname_ifcb,'{','}');
fname_ifcb_tmp1=strrep(fname_ifcb,['{',cb2,'}'],'');
cb1=find_keyword_between_markers( fname_ifcb_tmp1,'{','}') ;
if ~isempty(cb1)
    fname_ifcb_tmp1=strrep_recursive(fname_ifcb_tmp1,'__','_');
    fname_ifcb_new=strrep(fname_ifcb_tmp1,'}',['__',cb2,'}']);
    if keep_curly_yes
        skeyword=['{',find_keyword_between_markers(fname_ifcb_new,'{','}'),'}'];
    else
        skeyword=[find_keyword_between_markers(fname_ifcb_new,'{','}')];
    end
else
    if keep_curly_yes
        skeyword=['{',find_keyword_between_markers(fname_ifcb,'{','}'),'}'];
    else
        skeyword=[find_keyword_between_markers(fname_ifcb,'{','}')];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(strfind(skeyword,'__'))
     if keep_curly_yes
    skeyword_1=[find_keyword_between_markers(skeyword,'','__'),'}'];
    skeyword_2=['{',find_keyword_between_markers(skeyword,'__','')];
     else
    skeyword_1=['{',find_keyword_between_markers(skeyword,'','__'),'}'];
    skeyword_2=['{',find_keyword_between_markers(skeyword,'__',''),'}'];  
         
     end
else
    skeyword_1=skeyword;
    skeyword_2='';
end
targetstring_remain=strrep(strrep(targetstring,skeyword_1,''),'__','_');
targetstring_remain=strrep(strrep(targetstring_remain,skeyword_2,''),'__','_');
 if keep_curly_yes 
  targetstring_remain=strrep(strrep( targetstring_remain,'{_}',''),'__','_');
 else 
  targetstring_remain=strrep(strrep( targetstring_remain,'{}',''),'__','_');
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
done_with_this_function;
end


% ----- from AQP_gui.m: ismember_wMatchLoc (lines 24794-24826)
function [lia , locb , LocMatch] =ismember_wMatchLoc(A,B)
% this should generate output "LocMatch" that --> A(LocMatch.A2B) should be the same as B(LocMatch.B2A)
% see also Cmp_Results_AQP  ismember_by_rows_wMatchLoc  ismember_by_rows  ismembertol_ByRows  ismember
if false
    
    A={'ab';'bc';'def';'ABC';'x';'CH'};
    B={'CH';'def';'ABC'};
    [lia , locb , LocMatch] =ismember_wMatchLoc(A,B);
    A(LocMatch.A2B)
    B(LocMatch.B2A)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    A={'CH';'def';'ABC'};
    B={'ab';'bc';'def';'ABC';'x';'CH'};
    [lia , locb , LocMatch] =ismember_wMatchLoc(A,B);
    A(LocMatch.A2B)
    B(LocMatch.B2A)
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[lia,locb] =ismember(A,B);


LocMatch.A2B=find(lia==1);
LocMatch.B2A=locb(LocMatch.A2B);

% check LocMatch
if ~isequal(A(LocMatch.A2B),B(LocMatch.B2A))
error('something wrong with LocMatch')
end
end


% ----- from AQP_gui.m: strwrite_all_space (lines 36347-36372)
function combined_str=strwrite_all_space(cstr)
% convert all elements of cstr into a single row of string
% separate each indv str by space
% for preparation in comparing multiple strings (stored in a cell)  to see if they all match in two sets
% where cstr MUST be in {1xn cell} format
% use unique to sort the individual strings in the cell before combine them into the combined_unique_str
% for example in comparing the TICname output from LCD when multiple TICnames were detected
% e.g. cstr1={[{'TIC-B'},{'TIC-M'},{'TIC-AA'}]};combined_unique_cs1=strwrite_unique(cstr1);
if iscell(cstr)==0
  cstr={cstr};  
end


% unique_cstr=unique(cstr{1});
% ns=length(cstr{1});
ns=length(cstr);


combined_str=[];

for is=1:ns
 combined_str=[combined_str,' ',cstr{is} ];  
    
end
combined_str(1)=[];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%  CmpR_~ helper suite - added 22 Aug 2026
%  Support for the rewritten Cmp_Results_AQP (N files, mixed CabXfer
%  schemes) and for the x-axis guard that runs BEFORE a new
%  Results_AQP_~.mat is stored into Path4OUT_cln_AQP_FinalSubfolder.
%
%  This whole block is IDENTICAL in AQP_gui.m, Run_AQP.m and Cmp_Results.m.
%  Local functions are file-private, so each file keeps its own copy; when
%  you edit one, paste the same edit into the other two.
%  Nothing here calls outside base MATLAB except warndlg/questdlg.
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% ----- defaults for Cmp_Results_AQP ---------------------------------------
function inp=CmpR_defaults(inp)
if ~isstruct(inp)
    inp=struct;
end
cdef={ 'XTick_order'      , 'as-run' ; ...
       'strict_XTick'     , 0        ; ...
       'split_by_CabXfer' , 1        ; ...
       'markersize'       , 12       ; ...
       'connect_lines'    , 0        ; ...
       'wrap_XTickLabel'  , 1        ; ...
       'grid_yes'         , 1        };
for k=1:size(cdef,1)
    if ~isfield(inp,cdef{k,1}) || isempty(inp.(cdef{k,1}))
        inp.(cdef{k,1})=cdef{k,2};
    end
end
end


% ----- one series per (file x CabXfer_scheme) -----------------------------
function S=CmpR_build_series(clistfilename_out,inp)
S=[];
for ifile=1:numel(clistfilename_out)
    pfn=clistfilename_out{ifile};
    try
        Li=load(pfn);
    catch
        warning('CmpR:load_failed','could not load --> %s',pfn);
        continue
    end
    if ~isfield(Li,'OUT_cln')
        warning('CmpR:no_OUT_cln','no OUT_cln inside --> %s',pfn);
        continue
    end
    O=Li.OUT_cln(:);
    cXT  =CmpR_field_cell(O,'cLegendLoop_jLine');
    vRMSE=CmpR_field_num (O,'Results4sRMSE_Val');
    cXfer=CmpR_field_cell(O,'CabXfer_scheme');

    [pp,nn,ee]=fileparts(pfn);   %#ok<ASGLU>
    fname=[nn,ee];

    % Spectra_Avg_Method and AnaName are stamped into OUT_cln from 22 Aug 2026
    % on; for older .mat files fall back to the file name (Spectra_Avg only).
    sSA=CmpR_join_unique(CmpR_field_cell(O,'Spectra_Avg_Method'));
    sSA=strrep(sSA,'Spectra_Avg_','');
    if isempty(sSA)
        sSA=CmpR_token_SpectraAvg(fname);
    end
    sAna=CmpR_join_unique(CmpR_field_cell(O,'AnaName'));

    uXfer=CmpR_unique_stable(cXfer);
    if inp.split_by_CabXfer && numel(uXfer)>1
        cgrp=uXfer;                      % one series per scheme inside this file
    else
        cgrp={''};                       % the usual case - a single series
    end

    for g=1:numel(cgrp)
        if isempty(cgrp{g})
            idx=(1:numel(cXT))';
        else
            idx=find(strcmp(cXfer,cgrp{g}));
        end
        [cXT_g,vRMSE_g,ndup]=CmpR_dedup(cXT(idx),vRMSE(idx));
        if ndup>0
            warning('CmpR:duplicate_XTick', ...
                '%d duplicated x-axis entries in %s (kept the first of each)',ndup,fname);
        end
        s=struct( ...
            'pathfname',pfn, ...
            'fname'    ,fname, ...
            'ifile'    ,ifile, ...
            'cXT'      ,{cXT_g}, ...
            'RMSE'     ,vRMSE_g, ...
            'sXfer'    ,CmpR_join_unique(cXfer(idx)), ...
            'sSA'      ,sSA, ...
            'sAna'     ,sAna, ...
            'sPP'      ,CmpR_token_PPanchor(fname), ...
            'sCore'    ,CmpR_token_core(fname), ...
            'ndup'     ,ndup);
        S=[S;s];
    end
end
end


% ----- pull a char field out of an OUT_cln struct array -------------------
function c=CmpR_field_cell(O,sfield)
n=numel(O);
c=cell(n,1);
for i=1:n
    v='';
    try
        v=O(i).(sfield);
    end
    if ischar(v)
        c{i}=v;
    elseif iscell(v) && ~isempty(v) && ischar(v{1})
        c{i}=v{1};
    else
        try
            c{i}=char(string(v));
        catch
            c{i}='';
        end
    end
    if isempty(c{i})
        c{i}='';
    end
end
end


% ----- pull a numeric-in-a-string field out of an OUT_cln struct array ----
function v=CmpR_field_num(O,sfield)
n=numel(O);
v=nan(n,1);
for i=1:n
    try
        x=O(i).(sfield);
        if ischar(x)
            xd=str2double(x);
            if isnan(xd)
                xd=CmpR_str2num_safe(x);
            end
            x=xd;
        end
        if isempty(x)
            x=NaN;
        end
        v(i)=x(1);
    catch
        v(i)=NaN;
    end
end
end


function x=CmpR_str2num_safe(s)
x=NaN;
try
    y=str2num(s);   %#ok<ST2NM>
    if ~isempty(y)
        x=y(1);
    end
end
end


% ----- unique, first-appearance order (unique() sorts, which reorders the
%       PP1+PP2 scan and makes two runs look shuffled) ---------------------
function c=CmpR_unique_stable(c0)
c0=c0(:);
c={};
for i=1:numel(c0)
    if ~any(strcmp(c0{i},c))
        c{end+1,1}=c0{i};   %#ok<AGROW>
    end
end
end


function s=CmpR_join_unique(c)
cu=CmpR_unique_stable(c);
cu=cu(~cellfun(@isempty,cu));
s=CmpR_strjoin(cu,' ');
end


function s=CmpR_strjoin(c,ssep)
s='';
for i=1:numel(c)
    if i==1
        s=c{i};
    else
        s=[s,ssep,c{i}];   %#ok<AGROW>
    end
end
end


function tf=CmpR_allsame(c)
tf=true;
for i=2:numel(c)
    if ~isequal(c{i},c{1})
        tf=false;
        return
    end
end
end


% ----- keep the first of any repeated x label ----------------------------
function [c,v,ndup]=CmpR_dedup(c0,v0)
c0=c0(:);
v0=v0(:);
keep=true(numel(c0),1);
for i=2:numel(c0)
    if any(strcmp(c0{i},c0(1:i-1)))
        keep(i)=false;
    end
end
ndup=sum(~keep);
c=c0(keep);
v=v0(keep);
end


% ----- 'Results_AQP_{ds_Ana}_..._Spectra_Avg_All_{SNV-PP1}.mat' -> 'All' --
function s=CmpR_token_SpectraAvg(fname)
s='';
smark='Spectra_Avg_';
k=strfind(fname,smark);
if isempty(k)
    return
end
s=fname(k(end)+length(smark):end);
p=strfind(s,'_{');
if ~isempty(p)
    s=s(1:p(1)-1);
end
s=strrep(s,'.mat','');
end


% ----- last '{~-PP1}' / '{~-PP2}' token ----------------------------------
function s=CmpR_token_PPanchor(fname)
s='';
try
    t=regexp(fname,'\{[^{}]*-PP[12]\}','match');
    if ~isempty(t)
        s=t{end};
    end
end
end


% ----- file name without the 'Results_AQP_' prefix and the '.mat' --------
function s=CmpR_token_core(fname)
s=fname;
s=strrep(s,'.mat','');
smark='Results_AQP_';
k=strfind(s,smark);
if ~isempty(k)
    s=s(k(1)+length(smark):end);
end
end


% ----- strip the common head and tail so only what differs is left -------
function c=CmpR_distinct_tails(c0)
c=c0(:);
if numel(c)<2 || CmpR_allsame(c)
    return
end
nmin=min(cellfun(@numel,c));
% common head
nh=0;
for k=1:nmin
    ch=c{1}(k);
    ok=true;
    for i=2:numel(c)
        if c{i}(k)~=ch
            ok=false;
            break
        end
    end
    if ok
        nh=k;
    else
        break
    end
end
% common tail
nt=0;
for k=1:(nmin-nh)
    ch=c{1}(end-k+1);
    ok=true;
    for i=2:numel(c)
        if c{i}(end-k+1)~=ch
            ok=false;
            break
        end
    end
    if ok
        nt=k;
    else
        break
    end
end
for i=1:numel(c)
    s=c{i}(nh+1:end-nt);
    s=regexprep(s,'^[_\-\+ ]+','');
    s=regexprep(s,'[_\-\+ ]+$','');
    if isempty(s)
        s=c0{i};
    end
    c{i}=s;
end
end


% ----- legend from whatever actually varies across the series ------------
function clegend=CmpR_build_legend(S)
nS=numel(S);
cAn=cell(nS,1);
cSA=cell(nS,1);
cXf=cell(nS,1);
cPP=cell(nS,1);
cCo=cell(nS,1);
for i=1:nS
    cAn{i}=S(i).sAna;
    cSA{i}=S(i).sSA;
    cXf{i}=S(i).sXfer;
    cPP{i}=S(i).sPP;
    cCo{i}=S(i).sCore;
end
varAn=~CmpR_allsame(cAn) && ~all(cellfun(@isempty,cAn));
varSA=~CmpR_allsame(cSA) && ~all(cellfun(@isempty,cSA));
varXf=~CmpR_allsame(cXf) && ~all(cellfun(@isempty,cXf));
varPP=~CmpR_allsame(cPP) && ~all(cellfun(@isempty,cPP));
cCoS =CmpR_distinct_tails(cCo);

clegend=cell(nS,1);
for i=1:nS
    cpart={};
    if varAn && ~isempty(cAn{i})
        cpart{end+1}=['Analyte -->',cAn{i}];   %#ok<AGROW>
    end
    if varSA && ~isempty(cSA{i})
        cpart{end+1}=['Spectra -->',cSA{i}];   %#ok<AGROW>
    end
    if varXf && ~isempty(cXf{i})
        cpart{end+1}=['CabXfer -->',cXf{i}];   %#ok<AGROW>
    end
    if varPP && ~isempty(cPP{i})
        cpart{end+1}=['PP -->',cPP{i}];        %#ok<AGROW>
    end
    if isempty(cpart)
        cpart={cCoS{i}};
    end
    clegend{i}=CmpR_strjoin(cpart,'  |  ');
end
% still ambiguous ? then bolt the distinct part of the file name on
if numel(unique(clegend))<nS
    for i=1:nS
        clegend{i}=[clegend{i},'  |  ',cCoS{i}];
    end
end
end


% ----- colour/marker cycle; 1 -> 'b*' and 2 -> 'r*' as in the original ---
function [scol,smkr]=CmpR_style(k)
ccol={'b','r','k','m',[0 0.6 0],'c',[0.85 0.33 0.10],[0.49 0.18 0.56]};
cmkr={'*','o','s','d','^','v','p','h'};
ic=mod(k-1,numel(ccol))+1;
im=mod(floor((k-1)/numel(ccol)),numel(cmkr))+1;
scol=ccol{ic};
smkr=cmkr{im};
end


% ----- title line for what every series has in common -------------------
function s=CmpR_common_title(S)
nS=numel(S);
cXf=cell(nS,1);
cSA=cell(nS,1);
cAn=cell(nS,1);
for i=1:nS
    cXf{i}=S(i).sXfer;
    cSA{i}=S(i).sSA;
    cAn{i}=S(i).sAna;
end
cpart={};
uAn=CmpR_unique_stable(cAn(~cellfun(@isempty,cAn)));
if numel(uAn)==1
    cpart{end+1}=['[',uAn{1},']'];
elseif numel(uAn)>1
    cpart{end+1}=['Analyte --> ',CmpR_strjoin(uAn,' vs '),'  (RMSEP scales differ !)'];
end
uXf=CmpR_unique_stable(cXf(~cellfun(@isempty,cXf)));
if numel(uXf)==1
    cpart{end+1}=uXf{1};                                   % as before: the shared CabXfer scheme
elseif numel(uXf)>1
    cpart{end+1}=['CabXfer --> ',CmpR_strjoin(uXf,' vs '),'  (see legend)'];
end
uSA=CmpR_unique_stable(cSA(~cellfun(@isempty,cSA)));
if numel(uSA)==1
    cpart{end+1}=['Spectra_Avg_',uSA{1}];
end
s=CmpR_strjoin(cpart,'    ');
end


% ----- readable report of the x-axis gaps -------------------------------
function smsg=CmpR_report_XTick_gaps(S,Q,cMissing)
smsg=sprintf('x-axis (cLegendLoop_jLine) entries are NOT identical across the compared files.\n');
smsg=[smsg,sprintf('Union used for the x axis has %d entries.\n',numel(Q))];
for i=1:numel(S)
    if isempty(cMissing{i})
        smsg=[smsg,sprintf('  [%d] %s  -->  complete\n',i,S(i).fname)];   %#ok<AGROW>
    else
        smsg=[smsg,sprintf('  [%d] %s  -->  MISSING %d : %s\n', ...
            i,S(i).fname,numel(cMissing{i}),CmpR_strjoin(cMissing{i}(:)',', '))];   %#ok<AGROW>
    end
end
end


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%  x-axis guard - runs BEFORE a new Results_AQP_~.mat is stored into
%  Path4OUT_cln_AQP_FinalSubfolder (see BatchRun_AutoQuant_DA_pipeline)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% ----- x-axis list straight out of the in-memory OUT_cln -----------------
function cXT=CmpR_xtick_from_OUT_cln(OUT_cln)
cXT={};
try
    cXT=CmpR_field_cell(OUT_cln(:),'cLegendLoop_jLine');
    cXT=cXT(~cellfun(@isempty,cXT));
end
end


% ----- x-axis list out of a stored Results_AQP_~.mat --------------------
function cXT=CmpR_xtick_from_matfile(pfn)
cXT={};
try
    L=load(pfn,'OUT_cln');
    if isfield(L,'OUT_cln')
        cXT=CmpR_xtick_from_OUT_cln(L.OUT_cln);
    end
end
end


% ----- same SET of x entries (order is allowed to differ) ---------------
function tf=CmpR_same_XTick_set(cA,cB)
uA=sort(CmpR_unique_stable(cA));
uB=sort(CmpR_unique_stable(cB));
tf=isequal(uA(:),uB(:));
end


% ----- is this folder compatible with the new run's x axis ? ------------
function [tf,cbad,nchecked]=CmpR_folder_XTick_compatible(sfolder,cXT_new)
tf=true;
cbad={};
nchecked=0;
if exist(sfolder,'dir')~=7
    return
end
d=dir(fullfile(sfolder,'*Results_AQP*.mat'));
for i=1:numel(d)
    if d(i).isdir
        continue
    end
    cXT_old=CmpR_xtick_from_matfile(fullfile(sfolder,d(i).name));
    if isempty(cXT_old)
        continue
    end
    nchecked=nchecked+1;
    if ~CmpR_same_XTick_set(cXT_old,cXT_new)
        tf=false;
        cbad{end+1,1}=d(i).name;   %#ok<AGROW>
    end
end
end


% =========================================================================
% CmpR_check_XTick_before_store
%   Called just before the new Results_AQP_~.mat is copied into
%   Path4OUT_cln_AQP_FinalSubfolder.  Every file already sitting in that
%   folder is compared, entry by entry, against the new run's
%   cLegendLoop_jLine list (typically the PP1+PP2 preprocessing schemes).
%   A folder that mixes two different scheme lists produces a meaningless
%   Compare Results plot, so the mismatch is caught here rather than there.
%
%   inp.policy
%       'divert'      (default) - keep the new file, but put it in a sibling
%                                 folder  <FinalSubfolder>_XTickSet2, _XTickSet3...
%                                 (the first one that is empty or compatible)
%       'ask'                   - questdlg, one of the three below
%       'save-anyway'           - warn only, store it in the same folder
%       'skip'                  - warn and do not store it at all
%
%   out_XTck.dest_folder  folder that should actually be used
%   out_XTck.save_yes     copy the file or not
%   out_XTck.match_yes    x axis agreed with what was already there
%   out_XTck.msg          human readable reason
% =========================================================================
function out_XTck=CmpR_check_XTick_before_store(sfolder,cXT_new,inp)
out_XTck.dest_folder=sfolder;
out_XTck.save_yes=true;
out_XTck.match_yes=true;
out_XTck.nchecked=0;
out_XTck.cbad={};
out_XTck.msg='';

if nargin<3 || ~isstruct(inp)
    inp=struct;
end
if ~isfield(inp,'policy') || isempty(inp.policy)
    inp.policy='divert';
end
if nargin<2 || isempty(cXT_new)
    out_XTck.msg='new run carries no cLegendLoop_jLine --> x-axis check skipped';
    disp(['[XTick guard] ',out_XTck.msg]);
    return
end

[tf,cbad,nchecked]=CmpR_folder_XTick_compatible(sfolder,cXT_new);
out_XTck.match_yes=tf;
out_XTck.cbad=cbad;
out_XTck.nchecked=nchecked;

if tf
    if nchecked==0
        out_XTck.msg=sprintf('[XTick guard] first Results_AQP_~.mat in this folder (%d x-axis entries)',numel(CmpR_unique_stable(cXT_new)));
    else
        out_XTck.msg=sprintf('[XTick guard] x axis matches the %d file(s) already in this folder',nchecked);
    end
    disp(out_XTck.msg);
    return
end

smsg=sprintf(['[XTick guard] the new run does NOT share the x-axis (PP1+PP2 scheme) list\n', ...
    'of %d file(s) already in\n   %s\n   --> %s\n'], ...
    numel(cbad),sfolder,CmpR_strjoin(cbad(:)',', '));

spolicy=lower(inp.policy);
if strcmp(spolicy,'ask')
    sans='';
    try
        cq={'The new run does NOT share the x-axis (PP1+PP2 scheme) list'; ...
            'of the Results_AQP_~.mat file(s) already in'; ...
            sfolder;''; ...
            'How should this run be stored ?'};
        sans=questdlg(cq,'Compare Results - x-axis mismatch', ...
            'Separate folder','Save anyway','Do not save','Separate folder');
    end
    switch sans
        case 'Save anyway'
            spolicy='save-anyway';
        case 'Do not save'
            spolicy='skip';
        otherwise
            spolicy='divert';
    end
end

switch spolicy
    case 'save-anyway'
        out_XTck.save_yes=true;
        out_XTck.msg=[smsg,'stored in the same folder anyway (policy save-anyway) - Compare Results will draw the union and flag the gaps'];
    case 'skip'
        out_XTck.save_yes=false;
        out_XTck.msg=[smsg,'NOT stored (policy skip) - the .mat stays in the run folder only'];
    otherwise    % 'divert'
        snew=CmpR_next_XTickSet_folder(sfolder,cXT_new);
        if isempty(snew)
            out_XTck.save_yes=true;
            out_XTck.msg=[smsg,'could not create a sibling folder - stored in the same folder'];
        else
            out_XTck.dest_folder=snew;
            out_XTck.save_yes=true;
            out_XTck.msg=[smsg,'stored in a separate folder instead --> ',snew];
        end
end
disp(out_XTck.msg);
try
    warndlg(out_XTck.msg,'Compare Results - x-axis mismatch');
end
end


% ----- first  <folder>_XTickSet<k>  that is empty or compatible ---------
function snew=CmpR_next_XTickSet_folder(sfolder,cXT_new)
snew='';
for k=2:99
    scand=[sfolder,'_XTickSet',num2str(k)];
    if exist(scand,'dir')~=7
        [ok,msg]=mkdir(scand);   %#ok<ASGLU>
        if ok
            snew=scand;
        end
        return
    end
    [tf,cbad,nchecked]=CmpR_folder_XTick_compatible(scand,cXT_new);   %#ok<ASGLU>
    if tf
        snew=scand;
        return
    end
end
end


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%  "Compare Results" button - layout and enable/colour state
%  added 22 Aug 2026
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% =========================================================================
% CmpR_layout_Cmp_Results_controls
%   Moves the Compare Results pushbutton up, parks the "# results = n" text
%   directly UNDERNEATH it, and doubles that text's font (the .fig carried no
%   explicit FontSize, i.e. the 8 pt default -> 16 pt bold).
%
%   These are the same numbers AQP_gui_fig_patch.m bakes into AQP_gui.fig.
%   Applying them here too means the layout is right even on a .fig that was
%   never patched, and the call is IDEMPOTENT (absolute positions, not
%   relative nudges) so running it twice changes nothing.
%
%   Character units, against the 112 x 32.3 AQP_gui figure:
%       old  Cmp_Results [64.25 4.81 31.38 2.43]   sNumResults [96.00 5.10 14.88 2.14]
%       new  Cmp_Results [78.00 7.55 31.38 2.60]   sNumResults [78.00 4.90 31.38 2.40]
%   x=78 clears Lines_Xticks (which ends at x=75) at the button's new height.
%   Edit the four vectors below if a different AQP_gui.fig variant (PU / CM /
%   PC / EG / lite) needs another arrangement.
% =========================================================================
function CmpR_layout_Cmp_Results_controls(handles)
pos_Cmp_Results=[78.00 7.55 31.38 2.60];
pos_sNumResults=[78.00 4.90 31.38 2.40];
FontSize_sNumResults=16;
try
    hB=handles.Cmp_Results;
    hN=handles.sNumResults;
catch
    return
end
try
    set(hB,'Units','characters');
    set(hB,'Position',pos_Cmp_Results);
end
try
    set(hN,'Units','characters');
    set(hN,'Position',pos_sNumResults);
    set(hN,'FontUnits','points','FontSize',FontSize_sNumResults, ...
        'FontWeight','bold','HorizontalAlignment','center');
end
end


% =========================================================================
% CmpR_update_Cmp_Results_button
%   n  = 0 or 1  -> visible, grey, INACTIVE  (there is nothing to compare)
%   n >= 2       -> visible, GREEN, active
%   Also rewrites the "# results = n" label so the number and the button
%   state can never disagree.
%
%   n is taken from nOpt when the caller already counted (Run AQP does), and
%   otherwise recounted from
%   handles.OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder - which matters
%   after the x-axis guard diverts a run into a _XTickSet~ folder, since the
%   count then belongs to the folder actually used.
% =========================================================================
function n=CmpR_update_Cmp_Results_button(handles,nOpt)
n=[];
if nargin>=2 && ~isempty(nOpt) && isnumeric(nOpt)
    n=nOpt(1);
end
if isempty(n)
    n=0;
    try
        sfolder=handles.OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder;
        if ~isempty(sfolder) && exist(sfolder,'dir')==7
            d=dir(fullfile(sfolder,'*Results_AQP*.mat'));
            if ~isempty(d)
                n=sum(~[d.isdir]);
            end
        end
    end
end
% ---- keep the label in step with the state ----------------------------
sNCR='';
try
    sNCR=get(handles.sNumResults,'String');   % get/set, not dot-indexing: works on a plain handle too
end
if iscell(sNCR)
    if isempty(sNCR)
        sNCR='';
    else
        sNCR=sNCR{1};
    end
end
k=strfind(sNCR,'=');
if ~isempty(k)
    sHead=strtrim(sNCR(1:k(1)-1));
else
    sHead=strtrim(sNCR);
end
if isempty(sHead)
    sHead='# results';
end
try
    set(handles.sNumResults,'String',[sHead,' = ',num2str(n)]);
end
% ---- the button ------------------------------------------------------
try
    hB=handles.Cmp_Results;
    set(hB,'Visible','on');
    if n>=2
        set(hB,'Enable','on', ...
            'BackgroundColor',[0.40 0.80 0.40], ...
            'ForegroundColor',[0 0 0], ...
            'TooltipString',sprintf('Compare the %d Results_AQP_~.mat files in the results folder',n));
    else
        set(hB,'Enable','off', ...
            'BackgroundColor',[0.83 0.83 0.83], ...
            'ForegroundColor',[0.45 0.45 0.45], ...
            'TooltipString','Needs at least two Results_AQP_~.mat files in one folder');
    end
end
% ---- the two companion buttons: nothing to show or clear at n=0 -------
if n>=1
    sEn='on';
else
    sEn='off';
end
try
    set(handles.ShowResults,'Enable',sEn);
end
try
    set(handles.ClearResults,'Enable',sEn);
end
end


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%  multi-line x tick labels that actually render
%  added 22 Aug 2026
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% =========================================================================
% CmpR_set_XTickLabel_wrap
%   Rotated x tick labels with 'PP1+PP2' broken onto two lines.
%
%   WHY THIS EXISTS.  set_XTickLabel has forced
%   TickLabelInterpreter='none' since Apr 2024.  Every caller that had been
%   preparing labels the tex way - strrep('_','\_') and strrep('+','\newline')
%   - has been printing those escapes VERBATIM ever since, e.g.
%       1stDerSGFL7[PO2]\newlineSNV
%   And the obvious repair, a real newline char with interpreter 'none',
%   does not work either: the label is truncated at the newline, so only
%   '1stDerSGFL7[PO2]' survives.
%
%   So this helper goes back to what demonstrably worked - the tex
%   interpreter and a literal \newline - and makes it safe by escaping the
%   tex-special characters in each piece FIRST ( _ ^ { } ), which is what
%   made interpreter 'none' attractive in the first place.  Underscores and
%   {PRO} therefore print as themselves AND the labels wrap.
%
%   inp.wrap_yes  1 (default) split on '+' | 0 one line per label
%
%   NOTE: a label containing a literal backslash is left alone (tex would
%   need \backslash); no PP scheme name has one.
% =========================================================================
function CmpR_set_XTickLabel_wrap(hax,cLab,deg,fs,inp)
if nargin<5 || ~isstruct(inp)
    inp=struct;
end
if ~isfield(inp,'wrap_yes') || isempty(inp.wrap_yes)
    inp.wrap_yes=1;
end
if ~iscell(cLab)
    cLab={cLab};
end
cLab=cLab(:);
n=numel(cLab);
sNL=char(1);     % private placeholder for "break the line here"
c=cell(n,1);
for i=1:n
    s=cLab{i};
    if ~ischar(s)
        try
            s=char(string(s));
        catch
            s='';
        end
    end
    if inp.wrap_yes
        s=strrep(s,'{PRO}',[sNL,'               MN-PRO']);   % kept from the original summary plot
        s=strrep(s,'+',sNL);
    end
    cpart=CmpR_split_char(s,sNL);
    for k=1:numel(cpart)
        cpart{k}=CmpR_tex_escape(cpart{k});
    end
    c{i}=CmpR_strjoin(cpart,'\newline');
end
try
    set(hax,'TickLabelInterpreter','tex');   % NOT 'none' - see the note above
end
set(hax,'XTick',1:n,'XTickLabel',c,'XTickLabelRotation',deg,'fontsize',fs);
end


function s=CmpR_tex_escape(s)
s=strrep(s,'_','\_');
s=strrep(s,'^','\^');
s=strrep(s,'{','\{');
s=strrep(s,'}','\}');
end


function c=CmpR_split_char(s,ch)
c={};
k=strfind(s,ch);
i0=1;
for i=1:numel(k)
    c{end+1,1}=s(i0:k(i)-1);   %#ok<AGROW>
    i0=k(i)+1;
end
c{end+1,1}=s(i0:end);
end


%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%  "show" and "clear" companions to the Compare Results button
%  added 22 Aug 2026
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% =========================================================================
% CmpR_create_Results_buttons
%   Adds two pushbuttons next to Compare Results:
%     Show Results   -> list the Results_AQP_~.mat files in the results
%                       folder to the COMMAND WINDOW
%     Clear Results  -> delete them all (with a confirmation), then refresh
%                       "# results = n" and the Compare Results button
%
%   Created in code rather than in the .fig so their callbacks can be plain
%   function handles to local functions - no GUIDE callback strings, no .fig
%   surgery.  Idempotent: an existing pair is reused, so a second AQP_gui
%   session or a second call adds nothing.
%
%   handles must be committed by the caller (AQP_gui_OpeningFcn does the
%   guidata right after).
% =========================================================================
function handles=CmpR_create_Results_buttons(handles)
pos_ShowResults =[63.00 6.30 14.50 1.70];
pos_ClearResults=[63.00 4.40 14.50 1.70];
FontSize_buttons=9;
try
    hfig=ancestor(handles.Cmp_Results,'figure');
catch
    return
end
if isempty(hfig) || ~ishandle(hfig)
    return
end
% ---- Show Results ----------------------------------------------------
if ~isfield(handles,'ShowResults') || ~ishandle(handles.ShowResults)
    handles.ShowResults=uicontrol(hfig,'Style','pushbutton', ...
        'Tag','ShowResults','String','Show Results', ...
        'Units','characters','Position',pos_ShowResults, ...
        'FontUnits','points','FontSize',FontSize_buttons, ...
        'TooltipString','List the Results_AQP_~.mat files of the results folder in the command window', ...
        'Callback',@CmpR_ShowResults_Callback);
else
    set(handles.ShowResults,'Units','characters','Position',pos_ShowResults);
end
% ---- Clear Results ---------------------------------------------------
if ~isfield(handles,'ClearResults') || ~ishandle(handles.ClearResults)
    handles.ClearResults=uicontrol(hfig,'Style','pushbutton', ...
        'Tag','ClearResults','String','Clear Results', ...
        'Units','characters','Position',pos_ClearResults, ...
        'FontUnits','points','FontSize',FontSize_buttons, ...
        'ForegroundColor',[0.60 0 0], ...
        'TooltipString','DELETE every Results_AQP_~.mat in the results folder', ...
        'Callback',@CmpR_ClearResults_Callback);
else
    set(handles.ClearResults,'Units','characters','Position',pos_ClearResults);
end
end


function CmpR_ShowResults_Callback(hObject,eventdata)   %#ok<INUSD>
handles=guidata(hObject);
CmpR_list_Results_files(handles);
end


function CmpR_ClearResults_Callback(hObject,eventdata)   %#ok<INUSD>
handles=guidata(hObject);
CmpR_clear_Results_files(handles);
end


% ----- the results folder of the last run, '' when there is none --------
function sfolder=CmpR_results_folder(handles)
sfolder='';
try
    sfolder=handles.OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder;
end
if ~ischar(sfolder)
    sfolder='';
end
end


% =========================================================================
% CmpR_list_Results_files  -  what is in the comparison folder right now
% =========================================================================
function [clistfilename_out,n]=CmpR_list_Results_files(handles)
clistfilename_out={};
n=0;
sfolder=CmpR_results_folder(handles);
disp('=======================================================================');
if isempty(sfolder)
    disp('Results_AQP_~.mat  -->  no results folder yet (press Run AQP first)');
    disp('=======================================================================');
    return
end
disp(['Results_AQP_~.mat  -->  ',sfolder]);
disp('-----------------------------------------------------------------------');
if exist(sfolder,'dir')~=7
    disp('   ( that folder does not exist any more )');
    disp('=======================================================================');
    return
end
d=dir(fullfile(sfolder,'*Results_AQP*.mat'));
for i=1:numel(d)
    if d(i).isdir
        continue
    end
    n=n+1;
    clistfilename_out{n,1}=fullfile(sfolder,d(i).name);   %#ok<AGROW>
    cXT=CmpR_xtick_from_matfile(clistfilename_out{n,1});
    disp(['  [',num2str(n),'] ',d(i).name]);
    disp(['        ',num2str(round(d(i).bytes/1024)),' kB   ',d(i).date, ...
        '   x-axis entries: ',num2str(numel(CmpR_unique_stable(cXT)))]);
end
if n==0
    disp('  ( none )');
end
disp('-----------------------------------------------------------------------');
disp(['  # results = ',num2str(n)]);
disp('=======================================================================');
CmpR_update_Cmp_Results_button(handles,n);
end


% =========================================================================
% CmpR_clear_Results_files  -  empty the comparison folder
%   Deletes only *Results_AQP*.mat, and only in the folder of the last run -
%   never in the _XTickSet~ siblings, and never the copy that stays in the
%   run folder itself.  Always asks first - and if the dialog cannot be
%   raised at all it CANCELS rather than deletes.  inp.ask_yes=0 skips the
%   question, for scripted use only.
% =========================================================================
function n=CmpR_clear_Results_files(handles,inp)
if nargin<2 || ~isstruct(inp)
    inp=struct;
end
if ~isfield(inp,'ask_yes') || isempty(inp.ask_yes)
    inp.ask_yes=1;      % the pushbutton always asks; pass 0 to script it
end
n=0;
sfolder=CmpR_results_folder(handles);
if isempty(sfolder) || exist(sfolder,'dir')~=7
    disp('[clear results] no results folder yet (press Run AQP first)');
    try
        warndlg('There is no results folder yet - press Run AQP first.','Clear Results');
    end
    CmpR_update_Cmp_Results_button(handles,0);
    return
end
d=dir(fullfile(sfolder,'*Results_AQP*.mat'));
d=d(~[d.isdir]);
nfound=numel(d);
if nfound==0
    disp(['[clear results] nothing to delete in --> ',sfolder]);
    CmpR_update_Cmp_Results_button(handles,0);
    return
end
if inp.ask_yes
    sans='Cancel';      % if questdlg cannot be raised, do NOT delete
    try
        sans=questdlg({sprintf('Delete all %d Results_AQP_~.mat file(s) in',nfound); ...
            sfolder;'';'This cannot be undone.'}, ...
            'Clear Results','Delete','Cancel','Cancel');
    end
else
    sans='Delete';
end
if ~strcmp(sans,'Delete')
    disp('[clear results] cancelled');
    CmpR_update_Cmp_Results_button(handles);
    return
end
disp('=======================================================================');
disp(['[clear results] deleting from --> ',sfolder]);
for i=1:nfound
    pfn=fullfile(sfolder,d(i).name);
    try
        delete(pfn);
        disp(['   deleted  ',d(i).name]);
    catch ME_del
        warning('CmpR:delete_failed','could not delete %s (%s)',d(i).name,ME_del.message);
    end
end
n=CmpR_update_Cmp_Results_button(handles);   % rewrites "# results = n" and greys the button
disp(['[clear results] # results = ',num2str(n)]);
disp('=======================================================================');
end
