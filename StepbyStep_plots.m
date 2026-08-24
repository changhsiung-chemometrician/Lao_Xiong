function handles = StepbyStep_plots(hObject, eventdata, handles)
% STEPBYSTEP_PLOTS  Standalone extraction of StepbyStep_plots_Callback from AQP_gui.m
%
%   handles = StepbyStep_plots(hObject, eventdata, handles)
%
%   Source control : popupmenu (menu-as-command) - StepbyStep / CS_XRSmst_Bef_MGs / CS_Val_CabXfer_PP
%   What it does   : Item 1 prints the available choices; items 2-3 dispatch
% StepbyStep_plots_AQP over the StepByStep folder, then self-reset to 1.
%
%   This callback adds no plain struct fields; handles is returned
%   anyway so the calling convention matches Run_AQP.m and so a
%   future edit that does add a field cannot silently lose it.
%
%   This file is self-contained: the callback body below is followed by its
%   complete 32-function reachable closure, lifted verbatim from AQP_gui.m
%   and folded in as file-private local functions. Every function - primary
%   and local alike - is closed with its own matching end.
%
%   Extracted 20 August 2026 by the same dependency-closure procedure used for
%   Run_AQP.m on 19 Aug 2026. Edits to the moved body are tagged [EXTRACTED].

    handles = StepbyStep_plots_Callback(hObject, eventdata, handles);
end



% =========================================================================
% [EXTRACTED] The moved callback body. Verbatim from AQP_gui.m lines 792-808
% except for the tagged edits below.
% =========================================================================
function handles = StepbyStep_plots_Callback(hObject, eventdata, handles)   % [EXTRACTED] signature now returns handles
% hObject    handle to close_figs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if hObject.Value==1
    %
    disp('===============================');
    disp('pls pick one of the following : ');
     disp('------------------------------');
   disp_cstr(  hObject.String(2:end)  );
    disp('===============================');
else
StepbyStep_plots_AQP(handles,hObject);              % updated for diagnose of AQPlite, Apr 14, 2021
end
% disp('Reset StepbyStep');
hObject.Value=1;
end



% ----- from AQP_gui.m: Calc_Qres_T2_AQPlite (lines 7958-8044)
function out_Qres_T2=Calc_Qres_T2_AQPlite(LAT,opmPLSfactor )
% typically called by "StepbyStep" inside  AQPlite pu or Qres_T2_AQPlite_StepbyStep
% see also: Qres_T2_AQPlite_StepbyStep (created Sept 22, 2023)
% see also: prep_CFP_Quant_FalsePos_SCSVM_Mahal_Qres_T2
%------------------------------------------------------------------
if false
    
    
end
%======================================================
try
AnaName=LAT.PLS.Tset.saConc(1).clsname;
[X_iAna_T Y_iAna_T  cSampleName]=saConc2XY(LAT.PLS.Tset.saConc,AnaName);
catch
X_iAna_T= LAT.Atrainpk;   
end
%------------------------------------------------------------------------------------------------------
[Xloadings,Yloadings,Xscores,Yscores, ...
    beta,pctVar,mse,stats] = plsregress(X_iAna_T,Y_iAna_T,opmPLSfactor);
XL=Xloadings;
meanXT = mean(X_iAna_T,1);

try
    [X_iAna_P Y_iAna_P  cSampleName]=saConc2XY(LAT.PLS.Pset.saConc,AnaName);
     FalsePos_yes=0;
catch
    FalsePos_yes=1;
    X_iAna_P=LAT.Apred;   % deal with FalsePos case
end

%------------------------------------------------------------------------------------------------------

XP=X_iAna_P;

XP_scores=transpose(inv(XL'*XL)*XL'*scale(XP,meanXT)');% this approach is the latest correct one implemented by Chang Hsiung, around 2009-2010
XP_reconstructed= scale(XP_scores*XL',-meanXT);
XP_Residual=XP-XP_reconstructed;
ss_XP_Residual=sum(XP_Residual.^2,2);
if false
figure;hold on;plot(ss_XP_Residual,'g-*');
ylabel('Q Residuals for XP');
end
%--------------------------------------------------------------------------------------
XT=X_iAna_T;
XT_scores=Xscores;
XT_reconstructed= scale(XT_scores*XL',-meanXT);
XT_Residual=XT-XT_reconstructed;
ss_XT_Residual=sum(XT_Residual.^2,2);
if false
figure;hold on;plot(ss_XT_Residual,'k-*');
ylabel('Q Residuals for XT');
end

if false
    
    figure;hold on;
    hp1= plot(XP','r-','linewidth',0.5);
    hp2= plot(XP_reconstructed','color',color_CH('a'),'linewidth',0.5);
    legend([hp1(1)  hp2(1)],{'Val','ReConstruct-Val'});
    
end
%--------------------------------------------------------------------------------------

out_Qres_T2.ss_XT_Residual=ss_XT_Residual;
out_Qres_T2.ss_XP_Residual=ss_XP_Residual;
%--------------------------------------------------------------------------------------

 ss_XT_scores=sum(XT_scores.^2,2);       
 ss_XP_scores=sum(XP_scores.^2,2);                 % pure "CH" approach to calculate T2

%--------------------------------------------------------------------------------------

out_Qres_T2.ss_XT_scores=ss_XT_scores;
out_Qres_T2.ss_XP_scores=ss_XP_scores;
%--------------------------------------------------------------------------------------
out_Qres_T2.FalsePos_yes=FalsePos_yes;









done_with_this_function;
end


% ----- from AQP_gui.m: StepbyStep_plots_AQP (lines 16850-16983)
function StepbyStep_plots_AQP(handles,hObject)
% % updated Apr 30, 2021 --> plot_vline_stem
% % check  if  wvl in target is based on MicroNIR, May 1, 2021
disp('work on plotting spectra in StepbyStep folder');
try
 out_SbS=   handles.out_SbS;
catch
out_SbS='';    
end
if ~isempty(out_SbS)
    [clistfilename_SbS, nfile_SbS]=fdir_wildcard_ext_wPath(out_SbS,'Atrainpketc_','mat');
    SbS_Spectra_type=hObject.String{hObject.Value};
    switch SbS_Spectra_type
        case 'CS_XRSmst_Bef_MGs'
            keyword4SbS_SpectraType_CS='CS-Before-MatchGrids';
            keyword4SbS_SpectraType_XSmst='XSmst-Before-MatchGrids';
            if ~isempty(keyword4SbS_SpectraType_CS)
                loc_SbS_plot_ATfile_CS=find(strfind_cstr(keyword4SbS_SpectraType_CS,fileparts_name_ext(clistfilename_SbS)));
                if length( loc_SbS_plot_ATfile_CS)==1
                    LAT_SbS_CS=load(clistfilename_SbS{loc_SbS_plot_ATfile_CS});
                    
                    wvl_MN=get_MN_wvl;
                    wvl_CS_Bef_MGs=LAT_SbS_CS.wvl_standardize;
                    %=================================================
                    % % check  if  wvl in target is based on MicroNIR, May 1, 2021
                     loc_SbS_plot_ATfile_Aft_MGs=find(strfind_cstr('_After-MatchGrids_',fileparts_name_ext(clistfilename_SbS)));
                    if ~isempty(loc_SbS_plot_ATfile_Aft_MGs)
                        LAT_amg=load(clistfilename_SbS{loc_SbS_plot_ATfile_Aft_MGs});
                        wvl_MGs_trg=LAT_amg.wvl_standardize;
                        % if    length(wvl_MGs_trg) ~=length( wvl_MN )   ||  any(~IsNear(wvl_MGs_trg,wvl_MN,1e-3))     % check  if  wvl in target is based on MicroNIR, May 1, 2021
                          if   ~is_MN_wvl( wvl_MGs_trg )               % check  if  wvl in target is based on MicroNIR, May 1, 2021
                            wvl_MN=wvl_MGs_trg;
                            trg_wvl_type='non-MN grids';
                        else
                             trg_wvl_type='MN grids';
                        end
                    else
                         trg_wvl_type='MN grids';
                    end
                    
                    %=================================================
                    figure; hold on;set(gcf,'position',[121.0000   77.6667  839.3333  626.6667]);
                    hpCS= plot(wvl_CS_Bef_MGs,LAT_SbS_CS.Atrainpk,'b-','linewidth',0.5);
                    loc_SbS_plot_ATfile_XSmst=find(strfind_cstr(keyword4SbS_SpectraType_XSmst,fileparts_name_ext(clistfilename_SbS)));
                    if length( loc_SbS_plot_ATfile_XSmst)==1
                        LAT_SbS_XSmst=load(clistfilename_SbS{loc_SbS_plot_ATfile_XSmst});
                        hpXSmst= plot(wvl_CS_Bef_MGs,LAT_SbS_XSmst.Atrainpk,'c-','linewidth',0.5);
                        out_MN_grids=plot_vline_stem(wvl_MN);                                                                       % updated Apr 30, 2021 --> plot_vline_stem
                        legend([hpCS(1)   hpXSmst(1)  out_MN_grids.hp_grids],{'CS','XRSmst',trg_wvl_type});
                    else
                        out_MN_grids=plot_vline_stem(wvl_MN);                                                                       % updated Apr 30, 2021 --> plot_vline_stem
                        legend([hpCS(1)  out_MN_grids.hp_grids ],{'CS' , trg_wvl_type });
                    end
                    title({[   strrep(find_lastfolder(handles.path_DS),'_','\_') ];[strrep(SbS_Spectra_type,'_','\_')]});
                    ylabel('Spectra');xlabel('wvl');
                end
            end
            
        case 'CS_Val_CabXfer_PP'
            keyword4SbS_SpectraType='CS&Val_for-AAQP';
            if ~isempty(keyword4SbS_SpectraType)
                loc_SbS_plot_ATfile=find(strfind_cstr(keyword4SbS_SpectraType,fileparts_name_ext(clistfilename_SbS)));
                if length(loc_SbS_plot_ATfile)==1
                    LAT_SbS=load(clistfilename_SbS{loc_SbS_plot_ATfile});
                    figure; hold on;set(gcf,'position',[621.0000   77.6667  839.3333  626.6667]);
                    hpCS= plot(LAT_SbS.Atrainpk','b-','linewidth',0.5);
                    hpVal=  plot(LAT_SbS.Apred','r-','linewidth',0.5);
                    legend([hpCS(1)   hpVal(1) ],{'CS','Val'});
                   sCur_CabXfer_scheme= handles.CabXfer_scheme.String{handles.CabXfer_scheme.Value};
                     title({[   strrep(find_lastfolder(handles.path_DS),'_','\_') ,'  ',sCur_CabXfer_scheme];[strrep(SbS_Spectra_type,'_','\_')]});
                    ylabel('Spectra');xlabel('wvl');
                    %===========================================
                    try
                    LR=load(fullfile(handles.OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder,handles.OUT_Cmp_Results.fname_Results_AQP_OUT_cln));
                    catch
                        disp('try to load a shortname Results_~.mat');
                        
                        [clistfilename_out_Results, nfile_out_Results]=fdir_wildcard_ext_wPath(handles.OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder,'Results_','mat');
                        if nfile_out_Results==1
                            LR=load(clistfilename_out_Results{1});
                        else
                            warning('can  Not uniquely find Results_~.mat file,  hence can Not show Qres and T2 for CS_Val_CabXfer_PP ');
                            return;
                        end
                        
                    end
                  opmPLSfactor = str2num( LR.OUT_cln.Results4sOpmPLSfactor);
                    out_Qres_T2=Calc_Qres_T2_AQPlite(LAT_SbS,opmPLSfactor );
                    disp('work on plot LogStdScale Qres and T2');
                    inp4LogStdScale.opmPLSfactor=opmPLSfactor;
                    inp4LogStdScale.sfname=strrep(fileparts_name_ext(clistfilename_SbS{loc_SbS_plot_ATfile}),'_','\_');
                     inp4LogStdScale.sDSname= strrep(find_lastfolder(handles.path_DS),'_','\_') ;
                     
                    inp4LogStdScale.plot_Qres_OR_T2='Qres';
                    out_Qres_LogStdScale=plot_LogStdScale_Qres_T2 (out_Qres_T2,inp4LogStdScale);
                    
                     inp4LogStdScale.plot_Qres_OR_T2='T2';
                    out_T2_LogStdScale=plot_LogStdScale_Qres_T2 (out_Qres_T2,inp4LogStdScale);
                    %--------------------------------------------------------------
                    out_Qres_LogStdScale.X_QR_T2_T_scaled ;
                    out_Qres_LogStdScale.X_QR_T2_P_scaled ;
                    
                    out_T2_LogStdScale.X_QR_T2_T_scaled ;
                    out_T2_LogStdScale.X_QR_T2_P_scaled ;
                    figure;hold on;set(gcf,'position',1000*[0.3937    0.0423    1.0613    0.6853]);
                    hpT= plot(out_T2_LogStdScale.X_QR_T2_T_scaled,out_Qres_LogStdScale.X_QR_T2_T_scaled,'bO','linewidth',0.5);
                    hpP= plot(out_T2_LogStdScale.X_QR_T2_P_scaled,out_Qres_LogStdScale.X_QR_T2_P_scaled,'g*','linewidth',0.5);
                    plot_vline(3,'r');plot_hline(3,'r');
                    legend([hpT hpP],{'CS or Tset','Val or Pset'});
                    xlabel('Hotelling T-square (scaled by StdLog)'); ylabel('Q Residuals (scaled by StdLog)');
                    title([inp4LogStdScale.sfname;{[inp4LogStdScale.sDSname,'   OpmPLSfactor = ',num2str(inp4LogStdScale.opmPLSfactor )]};]);

                    %--------------------------------------------------------------
                    disp('done with plot LogStdScale Qres and T2');
                    %===========================================
                else
                    disp_with_border('NO appropriate spectra of CS vs Val were found, hence NO plot will be generated');
                end
            end
            
        otherwise
            keyword4SbS_SpectraType='';
            warning on
            warning('SbS_Spectra_type Not supported');
            warning off
    end
    
    
   
    
    
end
    disp('done on plotting spectra in StepbyStep folder');
end


% ----- from AQP_gui.m: is_MN_wvl (lines 24280-24294)
function out = is_MN_wvl(wvl_new)
% see also: get_MN_wvl , IsNear  , StepbyStep_plots_AQP  , get_wvl_AQP_ACP_Input_XLS
if false
    
    
end
%================================================
wvl_MN=get_MN_wvl;

if length(wvl_new) ==length( wvl_MN )   &&   all(IsNear(wvl_new,wvl_MN,1e-3))
    out=true;
else
    out=false;
end
end


% ----- from AQP_gui.m: plot_LogStdScale_Qres_T2 (lines 29039-29126)
function out=plot_LogStdScale_Qres_T2 (out_Qres_T2,inp)
if false
    
end
%=================================================
Nsigma=3;
%=================================================
 switch inp.plot_Qres_OR_T2
 case 'Qres'
ss_XT_Residual=out_Qres_T2.ss_XT_Residual;
ss_XP_Residual=out_Qres_T2.ss_XP_Residual;
     case 'T2'
ss_XT_Residual=out_Qres_T2.ss_XT_scores;
ss_XP_Residual=out_Qres_T2.ss_XP_scores;
 end



%-------------------------------------------------------------------------
% hist of QR of Tset_selfP at OpmPLSfactor
QResidual_Tself_OpmPLSfactor= ss_XT_Residual;
log_QResidual_Tself_OpmPLSfactor=log(QResidual_Tself_OpmPLSfactor);
med_log_QResidual_Tself_OpmPLSfactor=median(log_QResidual_Tself_OpmPLSfactor);
std_log_QResidual_Tself_OpmPLSfactor=std(log_QResidual_Tself_OpmPLSfactor);
thres_QR=med_log_QResidual_Tself_OpmPLSfactor+std_log_QResidual_Tself_OpmPLSfactor*Nsigma;
sthres_QR=['Thres\_QR = ',roundns(thres_QR,3)];
%----------------------------------------
QResidual_Pset_OpmPLSfactor=ss_XP_Residual;
log_QResidual_Pset_OpmPLSfactor=log(QResidual_Pset_OpmPLSfactor);
%----------------------------------------
QResidual_Pset_ScaledByTcvSigma=(log_QResidual_Pset_OpmPLSfactor-med_log_QResidual_Tself_OpmPLSfactor)/std_log_QResidual_Tself_OpmPLSfactor;
thres_QR_scaled=(thres_QR-med_log_QResidual_Tself_OpmPLSfactor)/std_log_QResidual_Tself_OpmPLSfactor;

QResidual_Tset_ScaledByTcvSigma=(log_QResidual_Tself_OpmPLSfactor-med_log_QResidual_Tself_OpmPLSfactor)/std_log_QResidual_Tself_OpmPLSfactor;

[N_QR_T X_QR_T_scaled]=hist(QResidual_Tset_ScaledByTcvSigma,20);
N_QR_T=N_QR_T/length(QResidual_Tset_ScaledByTcvSigma)*100;

[N_QR_P X_QR_P_scaled]=hist(QResidual_Pset_ScaledByTcvSigma,20);
N_QR_P=N_QR_P/length(QResidual_Pset_ScaledByTcvSigma)*100;

figure;
switch inp.plot_Qres_OR_T2
 case 'Qres'
     set(gcf,'position',1000*[1.1    0.0277    1.0580    0.5347]);
     case 'T2'
     set(gcf,'position',1000*[0.1    0.0277    1.0580    0.5347]);
      
 end
% set(gcf,'position',[621.0000   77.6667  839.3333  626.6667]);

hold on;
hsQR_T=stem(X_QR_T_scaled,N_QR_T,'b') ;
hsQR_T.Marker='.';
hsQR_P=stem(X_QR_P_scaled,N_QR_P,'g') ;

if out_Qres_T2.FalsePos_yes
 loc_X_QR_P_misP=find(X_QR_P_scaled<=thres_QR_scaled);  % decide which are misP
else
loc_X_QR_P_misP=find(X_QR_P_scaled>thres_QR_scaled);  % decide which are misP
end


if ~isempty(loc_X_QR_P_misP)
 plot(X_QR_P_scaled(loc_X_QR_P_misP),N_QR_P(loc_X_QR_P_misP),'mO','linestyle','none','markerfacecolor','m');   
end
hsQR_P.Marker='*';
plot_vline(thres_QR_scaled,'r');
legend({'CS or Tset','Val or Pset','Over Threshold','Threshold'})

xlabel([inp.plot_Qres_OR_T2,' of Pset scaled by Tset Sigma']);
ylabel('percent of samples')
if out_Qres_T2.FalsePos_yes
 loc_QRP_OverThres=find(log_QResidual_Pset_OpmPLSfactor<=thres_QR);
else
    loc_QRP_OverThres=find(log_QResidual_Pset_OpmPLSfactor>thres_QR);
end    
    sperc_OT=[roundns(length(loc_QRP_OverThres)/length( ss_XP_Residual )*100,2),'%'];
title([inp.sfname;{inp.sDSname};{[inp.plot_Qres_OR_T2,'    Val Over Thredhold = ',sperc_OT,'  (',num2str(length(loc_QRP_OverThres)),'/',  num2str(length(ss_XP_Residual ))   ,')']}]);

% title([sfname;{['QResidual for Pset','   Thres set by Tset-->',PLS_Tset_scheme,'   ','OpmPLSfactor=',num2str(inp.opmPLSfactor),'  numFalsePredict=',num2str(length(loc_QRP_OverThres))]}])
%----------------------------------------
out.X_QR_T2_T_scaled=QResidual_Tset_ScaledByTcvSigma;
out.X_QR_T2_P_scaled=QResidual_Pset_ScaledByTcvSigma;

%----------------------------------------
done_with_this_function;
end


% ----- from AQP_gui.m: plot_vline_stem (lines 29410-29431)
function out=plot_vline_stem(wvl_MN,inp)
% see also: StepbyStep_plots_AQP  plot_vline
if false
    
end
%======================================================================
try
    scolor=inp.scolor;
catch
    scolor='y';
end

ax0=axis;
hp_MN_grids=stem(wvl_MN,ax0(4)*ones([1  length(wvl_MN)]),scolor,'marker','none');    % note that here use 'none' to plot stem without heads
set(gca,'ylim',ax0([3 4]));   % since sometimes stem plot above may change 'ylim', hence need to reset ymax to before stem plot

if ax0(3)<0
    hp_MN_grids1=stem(wvl_MN,ax0(3)*ones([1  length(wvl_MN)]),'y','marker','none');
end

out.hp_grids=hp_MN_grids;
end


% ----- from AQP_gui.m: saConc2XY (lines 32003-32008)
function [X_iAna Y_iAna  cSampleName]=saConc2XY(saConc,AnaName)
idx_CurAna= arrayfun(@(x) strcmp(x.clsname,AnaName),saConc);
X_iAna=cell2mat(arrayfun(@(x) x.Atrainpk, saConc(idx_CurAna),'un',0));
Y_iAna=cell2mat(arrayfun(@(x) repmat(x.Conc,[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
cSampleName=cell_unwrap(arrayfun(@(x) repmat({x.SampleName},[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
end
