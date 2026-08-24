function [handles, OUT_Cmp_Results] = Run_AQP(varargin)
%RUN_AQP  Standalone, self-contained extraction of the AQP GUI "Run AQP" action.
%
%   Extracted from the merged AQP_gui.m by dependency-closure analysis.
%   The primary function is a thin calling-convention adapter; the original
%   Run_AQP_Callback body follows verbatim as the first local function, and
%   every function reachable from it is folded in below as a local function.
%
%   USAGE
%     handles = Run_AQP(handles)                        % standalone
%     handles = Run_AQP(hObject, eventdata, handles)    % GUIDE-compatible
%     [handles, OUT_Cmp_Results] = Run_AQP(...)
%
%   HANDLES may be a real GUIDE handles struct or any struct exposing the
%   fields the pipeline reads: path_XLSX, path_DSn_ParentFolder, path_DS,
%   suserInitials, AQP_class, cPP1, cPP2, cDataFlow, CabXfer_scheme,
%   UDMas_scheme, TcvModelParaOpmScheme, Spectra_Avg_Method, Lines_Xticks,
%   Val_Exist, CurStatus, sNumResults, Loaded_DS_folder.
%
%   CLOSURE
%     256 functions total  (255 helpers + the extracted callback body)
%     175 functions from AQP_gui.m were NOT reachable and are omitted.
%
%   EXTERNAL DEPENDENCIES (must remain on the MATLAB path)
%     ssds.m          classdef, called by 6 closure functions. A class must
%                     live in its own file and local functions are file-
%                     private, so ssds cannot be folded in here.
%     svmtrain_MEX    LIBSVM MEX binaries, called by 4 closure functions
%     svmpredict_MEX  (the SVR branches only).
%     plsregress      Statistics and Machine Learning Toolbox, 6 call sites.
%     xlsread, readtable    MATLAB built-ins for the XLSX loaders.
%
%   SVMnose.m is NOT required - no function in this closure calls it.
%
%   MODIFICATIONS TO THE ORIGINAL BODY  (2 lines, both marked [EXTRACTED])
%     1. Run_AQP_Callback signature now returns HANDLES.
%     2. guidata(gcbo,handles) is guarded so it is a no-op outside a callback.
%
%   Every function in this file is closed with its own matching END.

    switch nargin
        case 1
            hObject = []; eventdata = []; handles = varargin{1};
        case 3
            hObject = varargin{1}; eventdata = varargin{2}; handles = varargin{3};
        otherwise
            error('Run_AQP:nargin', ...
                  'Call Run_AQP(handles) or Run_AQP(hObject,eventdata,handles).');
    end

    if ~isstruct(handles) && ~isobject(handles)
        error('Run_AQP:handles', 'HANDLES must be a struct or handle object.');
    end

    handles = Run_AQP_Callback(hObject, eventdata, handles);

    if nargout > 1
        if isfield(handles, 'OUT_Cmp_Results')
            OUT_Cmp_Results = handles.OUT_Cmp_Results;
        else
            OUT_Cmp_Results = [];
        end
    end
end



%% ==========================================================================================
%% EXTRACTED CALLBACK BODY  (verbatim from AQP_gui.m, apart from the 2 marked lines)
%% ==========================================================================================

function handles = Run_AQP_Callback(hObject, eventdata, handles)   %#ok<INUSL>  % [EXTRACTED] returns handles
% hObject    handle to Run_AQP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%     InpBR.path_XLSX= 'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21';
    out_rootPath=find_last_nonTMP_path();
    cd(out_rootPath);
    folder_name_work_dir_AQP='TMP_AQP';
    path_work_dir_AQP=tmp_folder_rm_mk(folder_name_work_dir_AQP,out_rootPath)
    cd( path_work_dir_AQP);
    %%%%%%%%%%%%%%%%%%%%%%
    if ~strcmp( get_curAQP_class(handles),'lite')
    handles.cPP1.Visible=1;
    end
    %%%%%%%%%%%%%%%%%%%%
    try
     suserInitials=   lower(handles.suserInitials.String);
    catch
     suserInitials='';    
    end

    InpBR.path_XLSX= handles.path_XLSX;
    InpBR.path_DSn_ParentFolder=handles.path_DSn_ParentFolder;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % update cPP1 in  InpBR.handles_AQP_gui.cPP1
    
    
    
    if ~strcmp( get_curAQP_class(handles),'lite')
        
        % --> AQP_class='pro'
        if   strcmp(handles.cPP1.String(handles.cPP1.Value),'PP1_PP2_xlsx') || strcmp(handles.cPP2.String(handles.cPP2.Value),'PP1_PP2_xlsx')
       
            if ~exist('T_PPn','var')
                out_PPn=load_AQP_PP1_PP2_xlsx;    % load PP1_PP2*.xlsx file
                T_PPn=out_PPn.T_PPn;
            end
            
            InpBR.handles_AQP_gui.cPP1=T_PPn.PP1;
            try
                InpBR.pathfname_PPn_xlsx=out_PPn.pathfname_PPn_xlsx;
            end
            handles.cPP2.Value=find(strcmp(handles.cPP2.String,'PP1_PP2_xlsx'))  ;   % make sure PP2 also set to 'PP1_PP2_xlsx'
        else
            InpBR=Set_cPP1_fromGUI_AQP(handles,InpBR);
        end
    
    else
        % --> AQP_class='lite'
     InpBR.handles_AQP_gui.cPP1=handles.cPP1.String(handles.cPP1.Value);
    %%%%%%%%%%%%%%%%%%%%%
             % deal with sPP1 set to UI control's title i.e. 'PP1'
             if iscell(InpBR.handles_AQP_gui.cPP1) && length(InpBR.handles_AQP_gui.cPP1)==1
                 sPP1=InpBR.handles_AQP_gui.cPP1{1};
                 if strcmp(sPP1,'PP1')   % deal with sPP1 set to UI control's title i.e. 'PP1'
                     loc_default_PP1= find( cellfun(@(x) ~isempty(strfind(lower(x),'default')),   handles.cPP1.String) );
                     
                     if length(loc_default_PP1)==1
                         sPP1=handles.cPP1.String{loc_default_PP1 }
                     elseif isempty(loc_default_PP1)
                    sPP1= handles.cPP1.String{handles.cPP1.Value+1};  % assuming 1st entry is the title for cPP1 i.e. 'PP1' then set it to next entry after 'PP1'
                        
                     else
                         error('can not handle case that multiple default found')
                     end
                 end
                 
                 if ~isempty(strfind(lower(sPP1),'default'))
                     sPP1=strtrim(find_keyword_between_markers(sPP1,'','('));
                 end
                 
                InpBR.handles_AQP_gui.cPP1={sPP1}; 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%
    % show Current Chosen cPP1 on GUI
    if  length(InpBR.handles_AQP_gui.cPP1)>1
       handles.Cur_PP1.String=['Scan Thru  -->  ', num2str(length(InpBR.handles_AQP_gui.cPP1)),'  PP1 schemes'];
    else
    handles.Cur_PP1.String= InpBR.handles_AQP_gui.cPP1;
    end
     if  length(InpBR.handles_AQP_gui.cPP1)>1
    handles.cPP1.Visible=1;    % changed by CH, Apr 3, 2020
     else
      handles.cPP1.Visible=1;   %  changed to 1 for all single cPP1 case, March 24, 2020    
     end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % update cPP2 in  InpBR.handles_AQP_gui.cPP2 and  show Current Chosen cPP2 on GUI
 if   strcmp(handles.cPP2.String(handles.cPP2.Value),'PP1_PP2_xlsx') ||  strcmp(handles.cPP1.String(handles.cPP1.Value),'PP1_PP2_xlsx')
     %      T_PPn = readtable('C:\work\JDSU\Test_AQP\Tmp4AQPliteEXE\PP1_PP2_PC.xlsx');
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if ~exist('T_PPn','var')
         out_PPn=load_AQP_PP1_PP2_xlsx;    % load PP1_PP2*.xlsx file
         T_PPn=out_PPn.T_PPn;
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     InpBR.handles_AQP_gui.cPP2=T_PPn.PP2;
     handles.cPP1.Value=find(strcmp(handles.cPP1.String,'PP1_PP2_xlsx'))  ;   % make sure PP1 also set to 'PP1_PP2_xlsx'
     
 else
     InpBR=Set_cPP2_fromGUI_AQP(handles,InpBR);    % set InpBR.handles_AQP_gui.cPP2
 end
 
 
 if false
 InpBR.handles_AQP_gui.cPP2
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% show Current Chosen cPP2 on GUI
% InpBR.handles_AQP_gui.cPP2=handles_cPP2;
if length(InpBR.handles_AQP_gui.cPP2)>1
    handles.Cur_PP2.String=      ['Scan Thru  -->  ', num2str(length(InpBR.handles_AQP_gui.cPP2)),'  PP2 schemes'];
else
    % show Current Chosen cPP2 on GUI
    handles.Cur_PP2.String=['PP2 --> ',InpBR.handles_AQP_gui.cPP2{1}];
end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if iscell(handles.cDataFlow.String)
    InpBR.handles_AQP_gui.cDataFlow=handles.cDataFlow.String(handles.cDataFlow.Value);
    elseif  ischar(handles.cDataFlow.String)
    InpBR.handles_AQP_gui.cDataFlow={handles.cDataFlow.String};     
    end
    InpBR.hf_AQP=gcf;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % cUDMas_scheme % this should be in cell datatype
    if  handles.UDMas_scheme.Value==1 &&  strcmp(handles.UDMas_scheme.String{1},'UDMas_scheme')
        
        out_default_para_UDMas_scheme=Set_GUI_PopUpMenu_parameter_Default(handles.UDMas_scheme,'UDMas_scheme','(default)');
        if ischar(out_default_para_UDMas_scheme)
        InpBR.handles_AQP_gui.cUDMas_scheme={out_default_para_UDMas_scheme};% % this should be in cell datatype
        else
         InpBR.handles_AQP_gui.cUDMas_scheme=out_default_para_UDMas_scheme;   % this should be in cell datatype
        end
    elseif handles.UDMas_scheme.Value==1 &&  ~strcmp(handles.UDMas_scheme.String{1},'UDMas_scheme')
        % AQPlite (for Sales) version
        InpBR.handles_AQP_gui.cUDMas_scheme=handles.UDMas_scheme.String(1);
        
    elseif strcmp(handles.UDMas_scheme.String{handles.UDMas_scheme.Value},'ALL_UDM_schemes')
        
        Value4DashLine=find(cellfun(@(x) isDashLine(x), handles.UDMas_scheme.String));
        if length(Value4DashLine)==1
            InpBR.handles_AQP_gui.cUDMas_scheme=handles.UDMas_scheme.String(Value4DashLine+1:end-1);
        else
            error('can not hanlde this case for "ALL_UDM_schemes"')
        end
    elseif strcmp(handles.UDMas_scheme.String{handles.UDMas_scheme.Value},'ALL_Above_UDM_schemes')
        InpBR.handles_AQP_gui.cUDMas_scheme=handles.UDMas_scheme.String(2:handles.UDMas_scheme.Value-1);
        
    else
        cUDMas_scheme=strtrim( textual_eraseAfter_wo_kw1(handles.UDMas_scheme.String(handles.UDMas_scheme.Value),'(') );
        if ischar(cUDMas_scheme)
            cUDMas_scheme={cUDMas_scheme};
        end
        InpBR.handles_AQP_gui.cUDMas_scheme=cUDMas_scheme;
        % strtrim( textual_eraseAfter(handles.UDMas_scheme.String(handles.UDMas_scheme.Value),'(') ); % remove "(default)";
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    InpBR.handles_AQP_gui.CurStatus=handles.CurStatus;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % cCabXfer_scheme --> this should be in cell datatype
    if  handles.CabXfer_scheme.Value==1
        disp('pls pick a calibration transfer scheme');
        Speak_mk('please pick a calibration transfer scheme');
        return
    elseif strcmp(handles.CabXfer_scheme.String{handles.CabXfer_scheme.Value},'ALL_CabXfer_schemes')
        InpBR.handles_AQP_gui.cCabXfer_scheme=handles.CabXfer_scheme.String(2:handles.CabXfer_scheme.Value-1);
    else
        InpBR.handles_AQP_gui.cCabXfer_scheme=handles.CabXfer_scheme.String(handles.CabXfer_scheme.Value);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % block following and move this to --> XLSX2MAT_AQP.m
    % because
    % handling cCabXfer_scheme After check --> isempty(pathfname_XRS_xlsx) July 24, 2020
    %
%      InpBR.cCabXfer_scheme=InpBR.handles_AQP_gui.cCabXfer_scheme;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Spectra_Avg_Method -->   'Spectra_Avg_Mean'    'Spectra_Avg_Median'  'Spectra_Avg_All'
    InpBR.Spectra_Avg_Method=handles.Spectra_Avg_Method.String{handles.Spectra_Avg_Method.Value};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Option for Output SAM files -->   handles.Option_Output :    'Output_SAM_yes=0'  or  'Output_SAM_yes=1'
    try
    InpBR.Option_Output_SAM=find_keynumber_numeric_AFTER_marker(   handles.Option_Output.String{handles.Option_Output.Value}  ,'=');
    catch
    InpBR.Option_Output_SAM=1;    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % handling tag --> .Lines_Xticks  % use char datatype
    if  handles.Lines_Xticks.Value==1 && strcmp(handles.Lines_Xticks.String{1},'Lines--Xticks')
        out_default_para_Lines_Xticks_picked=Set_GUI_PopUpMenu_parameter_Default(handles.Lines_Xticks,'Lines--Xticks','(default)');
         InpBR.handles_AQP_gui.Lines_Xticks_picked=out_default_para_Lines_Xticks_picked; % this should be in char datatype   
    elseif  handles.Lines_Xticks.Value==1  && ~strcmp(handles.Lines_Xticks.String{1},'Lines--Xticks')
        % special handling for AQPlite (for Sales) version
        InpBR.handles_AQP_gui.Lines_Xticks_picked=handles.Lines_Xticks.String{1};% use char datatype
    else
       Lines_Xticks_picked =handles.Lines_Xticks.String{handles.Lines_Xticks.Value};% use char datatype
       Lines_Xticks_picked= strtrim( textual_eraseAfter_wo_kw1(Lines_Xticks_picked,'(') );
       InpBR.handles_AQP_gui.Lines_Xticks_picked=Lines_Xticks_picked;           % use char datatype
      
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % "CurTcvModelParaOpmScheme" (e.g. 'KneePt+1_RMSECV' ) this one should be a char
    % % get from GUI parameter "CurTcvModelParaOpmScheme" (e.g. 'KneePt+1_RMSECV' ) later inside BatchRun_AutoQuant_DA_pipeline(InpBR) will be inserted into inp4AQP.ModelOpt
    % set parameter "inp4AQP.ModelOpt.CurTcvModelParaOpmScheme"
    % % " out_para_TcvModelParaOpmScheme " should be a char, Not a cell
     out_para_TcvModelParaOpmScheme=Set_GUI_PopUpMenu_parameter_Default(handles.TcvModelParaOpmScheme,'TcvModelParaOpmScheme','(default)');% this one should be a char, Not a cell
    InpBR.out_para_TcvModelParaOpmScheme=out_para_TcvModelParaOpmScheme;          % this one should be a char, Not a cell
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    InpBR.handles_gui=handles; % main handles from gui
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        Lip=load_local_try('C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\inp4PLS.mat');
    catch
        Lip=load([find_last_nonTMP_folder,'\Tmp4AQPliteEXE\inp4PLS.mat']);
    end
        PlsfactorScan_default=Lip.inp4PLS.PlsfactorScan; % see AQPlite.m and PLS_inside_PLS_predict_ONLY_MLtool.m
        %%%%%%%%%%%%%%%%%%%%%%
        % follwing only for testing other set of PlsfactorScan_default
        if false
            PlsfactorScan_default=[1:2:20];
        end
        %%%%%%%%%%%%%%%%%%%%%%
        InpBR.PlsfactorScan_default=PlsfactorScan_default;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  if strcmp(InpBR.out_para_TcvModelParaOpmScheme,'User-Pick') &&  iscell( InpBR.handles_gui.AQP_class.String) && strcmp( InpBR.handles_gui.AQP_class.String{ InpBR.handles_gui.AQP_class.Value},'pro')
      InpBR.handles_gui.sPLSfactor_Opm_User_Pick.Visible=1;
      %         InpBR.handles_gui.sPLSfactor_Opm_User_Pick
      theCell = cellfun(@sprintf,repmat({'PLSfactor %d'},length(PlsfactorScan_default),1), num2cell((PlsfactorScan_default)'),'Unif',false);
      if length(theCell)==length(PlsfactorScan_default)
          [theChosen, theChosenIDX] = uicellect(theCell);
          if length(theChosen)>1
              error('you can only pick one PLSfactor !!!')
          end
      else
          error('not ready for this case of PlsfactorScan_default yes')
      end
      PLSfactor_Opm_User_Pick=find_keynumber_numeric_AFTER_marker(    theChosen{1},'PLSfactor');
      %    PLSfactor_Opm_User_Pick= str2num(find_keyword_between_markers( InpBR.handles_gui.sPLSfactor_Opm_User_Pick.String,'=',''));
      InpBR.handles_gui.sPLSfactor_Opm_User_Pick.String=['PLSfactor_Opm_User_Pick = ',num2str(PLSfactor_Opm_User_Pick)];
  else
      InpBR.handles_gui.sPLSfactor_Opm_User_Pick.Visible=0;
      PLSfactor_Opm_User_Pick=NaN;
  end
    InpBR.PLSfactor_Opm_User_Pick= PLSfactor_Opm_User_Pick;
    %------------------------------------------------------------------------------------------------------------
    % revisit TcvModelParaOpmScheme  ( or  out_para_TcvModelParaOpmScheme ), Jan 5, 2023
    
%        InpBR.out_para_TcvModelParaOpmScheme='LSUX_RMSECV' ;   % hard-coded for now, Jan 5, 2023
%  InpBR.handles_gui.sPLSfactor_Opm_User_Pick.Visible=1

    %------------------------------------------------------------------------------------------------------------
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     [OUT   OUT_Cmp_Results ] =BatchRun_AutoQuant_DA_pipeline(InpBR) ;% 
     handles.OUT_Cmp_Results=OUT_Cmp_Results;
     
      [clistfilename_CR, nfile_CR]=fdir_wildcard_wPath(handles.OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder,'Results_AQP_');
      try
      sNCR=handles.sNumResults.String;
      catch
      sNCR='';    
      end
      try
      handles.sNumResults.String= [ find_keyword_between_markers(sNCR,'','='),' = ',num2str(nfile_CR)]  ;
      end
      % [CMP BUTTON STATE, 22 Aug 2026] grey+inactive while nfile_CR<2,
      % green+pushable at 2 or more.  Recounts from
      % OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder when nfile_CR is
      % stale - which it is whenever the x-axis guard diverted this run into
      % a _XTickSet~ folder.  see also: CmpR_update_Cmp_Results_button
      try
      CmpR_update_Cmp_Results_button(handles);
      end
     %%%%%%%%%%%%%%%%%%%%%%%%%  
     % move contents of 'TMP_AQP_StepByStep' to inside 'TMP_AQP', updated Nov 15, 2020
%      if strcmp(handles.authorized_user,'CH')    % allow all  users to create 'StepByStep' folder
         out_SbS=tmp_folder_rm_mk('StepByStep',pwd);                                    % allow all  users to create 'StepByStep' folder, Apr 17, 2021
         path_prev_SbS=[find_last_nonTMP_path,'\','TMP_AQP_StepByStep'];
         try
             movefile( [path_prev_SbS,'\Atrainpk*.mat'],out_SbS);
             rmdir( path_prev_SbS);
             % prepare for generating plots based on files inside out_SbS, Apr 14, 2021
             disp('copy path for StepbyStep folder to handles');
             handles.out_SbS=out_SbS;
         end
%      else          % allow all  users to create 'StepByStep' folder
%          path_prev_SbS=[find_last_nonTMP_path,'\','TMP_AQP_StepByStep'];
%          rmdir( path_prev_SbS,'s');
%      end          % allow all  users to create 'StepByStep' folder
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         cd(out_rootPath);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %%%%%%%%%%%%%%%%%%%%%%%%%
     handles.hf_AQP=InpBR.hf_AQP;
     if ~isempty(gcbo) && isgraphics(gcbo)   % [EXTRACTED] GUIDE context only; no-op standalone
         guidata(gcbo,handles);
     end
end


%% ==========================================================================================
%% DEPENDENCY CLOSURE - 255 local functions, in original AQP_gui.m order
%% ==========================================================================================

%% ----- isDashLine   [AQP_gui.m lines 746-752] ------------------------------------------------
function out=isDashLine(x)
if length(unique(x))==1 && strcmp(unique(x),'-')
    out=true;
else
    out=false;
end
end


%% ----- AQP_App_Emulator   [AQP_gui.m lines 812-897] ------------------------------------------
function out=AQP_App_Emulator(path_FinalModels,inp)
% see also: PLS_inside_PLS_predict_ONLY_MLtool --> create and save -->   fname_FinalModel=['Beta_etc_FinalModel_cnt-', num2str(inp4PLS.cnt),'_' ,inp4PLS.cList_Ana_to_Run{1},sFinal_PLSfactor,'_{',corename4FinalModel,'}.mat'];
%----------------------------------------------------------------------------------
% added pp2 Apr 3, 2020
% % fix bug related to running PP1_PP2_xlsx together with woXRS situation, May 4, 2020
% updated Aug 21, 2020 to deal with "{PRO} ONLY" scanning of PPn schemes
% see also: BatchRun_AutoQuant_DA_pipeline
% see also: PLS_inside_PLS_predict_ONLY_MLtool --> create and save -->   fname_FinalModel=['Beta_etc_FinalModel_cnt-', num2str(inp4PLS.cnt),'_' ,inp4PLS.cList_Ana_to_Run{1},sFinal_PLSfactor,'_{',corename4FinalModel,'}.mat'];
%------------------------------------------------------------------------------------
if false
    
    cc
    path_FinalModels='C:\work\JDSU\Test_AQP\Result4FinalModels'
   out= AQP_App_Emulator(path_FinalModels)
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(path_FinalModels,'Beta_etc_FinalModel_','mat');
inp.fullpath_yes=1;

 [clistfilename_out_Opm, nfile_out_Opm]=fdir_wPrefix_wPath(path_FinalModels,'mat',0,'OpmModel_Beta_etc_FinalModel_',inp);

if isempty(clistfilename_out_Opm)
 [clistfilename_out, nfile_out]=fdir_wPrefix_wPath(path_FinalModels,'mat',0,'Beta_etc_FinalModel_',inp);
% saFM=SAinsert_createNew_w_seqnum(nfile_out);

clistfilename_out=sort_nat( clistfilename_out );

saFM=[];
for iFM=1:nfile_out
    sai=load(clistfilename_out{iFM});
saFM=[saFM;sai];    
end
allRMSEP=cat(1,saFM.RMSEP);
[minRP locminRP]=min(allRMSEP);
out.RMSEP_Opm=minRP;

out.seq.PP1=saFM(locminRP).pp1;
out.seq.PP2=saFM(locminRP).pp2;       % added pp2 Apr 3, 2020

% out.seq.CabXfer=strrep(           find_keyword_between_markers(     strrep( fileparts_name_ext (   clistfilename_out{ locminRP}  )  ,'{{','{')      ,'{','_pp1')          ,'_Val','');   % fixed Apr 29, 2020
if length(inp.cCabXfer_scheme)==1
out.seq.CabXfer=inp.cCabXfer_scheme{1};
else
 out.seq.CabXfer='woCabXfer';    
end
if strcmp(out.seq.CabXfer,'T-CS_P-Val')
    out.seq.CabXfer='woCabXfer';                              % fix bug related to running PP1_PP2_xlsx together with woXRS situation, May 4, 2020
end                    


display_structure(out.seq);
try
tbSeq=struct2table(out.seq);   % struct2table, neither   out.seq.CabXfer=[] nor out.seq.CabXfer=''  works !!!
catch
  tbSeq=struct2table(out.seq,'AsArray',true);  % updated Aug 21, 2020 to deal with "{PRO} ONLY" scanning of PPn schemes
end

writetable(tbSeq,[path_FinalModels,'\Seq_Opm_PLS_Models.xlsx']);
Opm_FM=saFM(locminRP);
Opm_FM.seq=out.seq;  % based on "struct" not "table"
fname_OpmFM=['OpmModel_',fileparts_name_ext( clistfilename_out{locminRP})];
fname_OpmFM=strrep(fname_OpmFM,'{{','{');
fname_OpmFM=strrep(fname_OpmFM,'}.','.');
fname_OpmFM=strrep(fname_OpmFM,'_Val','');

save([path_FinalModels,'\',fname_OpmFM] ,'-struct','Opm_FM');
disp_with_border([[path_FinalModels,'\',fname_OpmFM],' has been saved']);
else
    disp('Opm_Model~.mat already exist');
    disp('work on testing App Emulator or Sequence Processor')
    if nfile_out_Opm==1
       Lopm=load(clistfilename_out_Opm{1});
        
       
       disp('done with testing of Seq Processor')
    else
        error('non-unique Opm_Model_~.mat file exist !!!')
    end
    out='';
end
% disp(tbSeq)
% open('Opm_PLS_Models.xlsx');
disp('done with AQP_App_Emulator(pfn)')
end


%% ----- AQP_Apply_Spectra_Avg   [AQP_gui.m lines 901-1023] -------------------------------------
function out=AQP_Apply_Spectra_Avg(SAT,inp)
% see also: avg_Spectra_ACP_CARE_LAf (June 4, 2024)
% add  inp.Spectra_Avg_Method= 'one_scan_each_cls' , June 5, 2024
%       inp.Spectra_Avg_Method= 'one_scan_each_cls';              % may get similar results to SMV
%       inp.Spectra_Avg_Method= 'Spectra_Avg_Mean';            % most popular method 
%    inp.Spectra_Avg_Method= 'Mean_PDS';            %  same as    'Spectra_Avg_Mean'   
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%-------------------------------------------------------------------
% called by clistfilename2AT_AQP.m in AQP_gui.m
% revisit this Apr 17, 2023
% see also: clistfilename2AT_AQP
% save this for fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
%==========================================================
disp('work on AQP_Apply_Spectra_Avg');
%-------------------------------------------------
% since Tcv is based on saConc4SAT_T(isamp).SampleName
% check to make sure these two match
% AclabelT_from_saConc=arrayfun(@(x) x.SampleName{1},SAT.saConc,'un',0);
% if ~isSAME_two_cstr(AclabelT_from_saConc,SAT.AclabelT  )
% error('Mismatch between AclabelT_from_saConc vs SAT.AclabelT'  );% revisit this Apr 17, 2023
% end
% check AclabelT vs saConc.SampleName
try
    if ~isSame_AclabelT_SampleName(SAT)
        Speak_mk('Mismatch between AclabelT_from_saConc vs SAT.AclabelT');
        error('Mismatch between AclabelT_from_saConc vs SAT.AclabelT'  );% revisit this Apr 17, 2023
    end
end

%----------------------------------------------------------------------------
% add  inp.Spectra_Avg_Method= 'one_scan_each_cls' , June 5, 2024
if  strcmp(inp.Spectra_Avg_Method, 'one_scan_each_cls' )
       SAT.AclabelT=cellstr("cls-"+string(SAT.AclassinfoT));% one sample in each resinkit and each class, i.e. 3 samples per class in Tset
end
%--------------------------------------------------------------------------
QAclabelT=unique_appear_order_cstr(SAT.AclabelT);
try
Conc_All=cat(1,SAT.saConc.Conc);
end
Atrainpk=[];
RawSpectra=[];
AclabelT=[];
Conc_T=[];
AclassinfoT=[];

for ipds=1:length(QAclabelT)
    loc_i=strmatch(QAclabelT{ipds},SAT.AclabelT,'exact');  % based on SAT.AclabelT
    switch inp.Spectra_Avg_Method
        case {'Spectra_Avg_Mean' , 'Spectra_Avg_T-Mean_P-All', 'one_scan_each_cls' ,  'Mean_PDS'}
            SAT_orig_Avg_All=SAT;   % save this for fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
%             disp(['Apply ',inp.Spectra_Avg_Method]);
            eaAT=mean(SAT.Atrainpk(loc_i,:),1);                        % modified by more general usage of mean --> ",1"
            try
            eaRS=mean(SAT.RawSpectra(loc_i,:),1);              % modified by more general usage of mean --> ",1"
            end
            eaL={[QAclabelT{ipds},'_Mean']};
            eaCiT=mode(SAT.AclassinfoT(loc_i,:));
            
            try
            Conc_T=[Conc_T;mean(Conc_All(loc_i))];
            end
        case 'Spectra_Avg_Median'
            
        case 'Spectra_Avg_All'
            disp('Continue without doing any "Spectra_Avg" method')
        otherwise
            error('Spectra_Avg_Method Not supported')
    end
    
    Atrainpk=[Atrainpk;eaAT ];
    try
    RawSpectra=[RawSpectra;eaRS];
    end
    AclabelT=[AclabelT;eaL];
    AclassinfoT=[AclassinfoT;eaCiT];

end

try
    saConc4SAT_T=SAinsert_createNew_w_seqnum(length(Conc_T));
    
    for isamp=1:length(Conc_T)
        saConc4SAT_T(isamp).clsname=inp.AnaName;
        
        if exist('Conc_T_all','var') && isnumeric(Conc_T_all) && all(~isnan(Conc_T_all))
            %  disp('this is the case that XSmst with Ref values will be included into CS that will be based on "Conc_T_all"')
            saConc4SAT_T(isamp).Conc=Conc_T_all(isamp);
        else
            saConc4SAT_T(isamp).Conc=Conc_T(isamp);
        end
        
        saConc4SAT_T(isamp).SampleName=AclabelT(isamp);
        saConc4SAT_T(isamp).Atrainpk=Atrainpk(isamp,:);
    end
end
% LTP.PLS.Tset.saConc=saConc4SAT_T;

SATnew=SAT;
try
SATnew.saConc=saConc4SAT_T;
end

SATnew.Atrainpk=Atrainpk;
SATnew.AclabelT=AclabelT;
SATnew.RawSpectra=RawSpectra;
SATnew.AclassinfoT=AclassinfoT;
%--------------------------------------------------------
switch inp.Spectra_Avg_Method   % see also: AutoQuant_DA_pipeline
    case {'Spectra_Avg_T-Mean_P-All'}
        SATnew.SAT_orig_Avg_All=SAT_orig_Avg_All;   % save this for fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
    case 'Spectra_Avg_All'
%         SATnew.SAT_orig_Avg_All=SAT_orig_Avg_All;   % save this for fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
    case {'Spectra_Avg_Mean' ,'Spectra_Avg_T-Mean_P-Mean'}
%         SATnew.SAT_orig_Avg_All=SATnew;  % fake it with Avg_Mean

end
%-----------------------------------------------------------

disp('done Avg');

out=SATnew;
disp('done with AQP_Apply_Spectra_Avg');
end


%% ----- AQP_rm_replicate_seq_sam   [AQP_gui.m lines 1027-1217] ----------------------------------
function out=AQP_rm_replicate_seq_sam(str0)
% typically called by clistfilename2AT_AQP ( sub-sub...function of AQP_gui.m  )
% created Apr 15, 2023
% see also: examples_regexp_CH_Apr_2023  examples_regexp_CH_June12_2014.m
% see also: AQP_Apply_Spectra_Avg clistfilename2AT_AQP (where we need to make sure AclabelT stored in SAT matched with that stored in SAT.saConc.SampleName )
% --------------------------------------------------------------------------------
% 
%===============================================================================
if false
    %------------------------------------------------------------------
    % visit Apr 15, 2023
    % fix/remove replicates number in PRO
    %
    % only one match with "-#.sam"
    cc
    disp('-----------------------------------------------');
    str0='abs_U35_cd-Unknow-12.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % only one match with "_#.sam"
    str0='abs_U35_cd-Unknow_132.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % two unique matches
    str0='abs_Unknow-12.sam_U35_cd-Unknow_132.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % 2 total matches, one unqie match, only change the last occured match
    str0='Unknow_13.sam_U35_cd-Unknow_13.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % three unique matches
    str0='Unknow-13.samabs_Unknow_12.sam_U35_cd-Unknow-132.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % 3 total matches, two unqie match, only change the last match
    str0='Unknow_132.samabs_Unknow-12.sam_U35_cd-Unknow_132.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % 3 total matches, two unqie match, only change the last match
    str0='Unknow-132.samabs_Unknow_13.sam_U35_cd-Unknow_13.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % 3 total matches, two unqie match, only change the last match
    str0='Unknow_13.samabs_Unknow-13.sam_U35_cd-Unknow-13.sam';
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    
    %-------------------------------------------------------------------
    %-------------------------------------------------------------------
    %-------------------------------------------------------------------
    
    % no match
    cc
    str0='abs_Unknow-12sam_U35_cd-Unknow_132sam';
    out=AQP_rm_replicate_seq_sam(str0);
     disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % no match
    str0='abs_Unknow-12s_U35_cd-Unknow_132.sm';
    out=AQP_rm_replicate_seq_sam(str0);
     disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % no match
    str0='abs_Unknow-12s_U35_cd-Unknow-132_sam';
    out=AQP_rm_replicate_seq_sam(str0);
     disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------
    % one match but not at end
    str0='abs_Unk-132.sam_now-12s_U35_cd-Unknow-132_sam';
    out=AQP_rm_replicate_seq_sam(str0);
     disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    
    %------------------------------------
    % more matches but none of them at end
    % 3 total matches, two unqie match, only change the last match
    str0='Unknow-1.samabs_Unknow_13.sam_U35_cd-Unknow_13.sam_sam';
    out=AQP_rm_replicate_seq_sam(str0);
     disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %------------------------------------------------------------------
    % three unique matches but none of them at end
    str0='Unknow-13.sam_abs_Unknow_12.sam_U35_cd-Unknow-132.samp';
    out=AQP_rm_replicate_seq_sam(str0);
     disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    %===========================================================================
    %===========================================================================
    % test real world datasets
    
    cc
%       str0='D:\OneDrive\OneDrive - Viavi Solutions Inc\My Documents\Customers and partners\Emiliano\Polymers\Data\Big_Five_Recycling\PE\HDPE_01\HDPE_01_1_12032019T152102.sam';
     %--------------------------------
    % following will not match pat_TS
%         str0='D:\OneDrive\OneDrive - Viavi Solutions Inc\My Documents\Customers and partners\Emiliano\Polymers\Data\Big_Five_Recycling\PE\HDPE_01\HDPE_01_1_1203201T152102.sam'
     %--------------------------------
      str0='D:\OneDrive\OneDrive - Viavi Solutions Inc\My Documents\Customers and partners\Emiliano\Polymers\Data\Big_Five_Recycling\PE\HDPE_01\HDPE_01_2_12032019T152127.sam';
    %--------------------------------
%      str0='D:\OneDrive\OneDrive - Viavi Solutions Inc\My Documents\Customers and partners\Emiliano\Polymers\Data\Big_Five_Recycling\PE\HDPE_11\HDPE_11_5_14032019T151047.sam';
    
    out=AQP_rm_replicate_seq_sam(str0);
    disp(str0);
    disp(out);
    disp('-----------------------------------------------');
    
     %===========================================================================
    %===========================================================================
   
end  % end of if false examples
%===========================================================================================
% check TimeStamp

% pat_TS_example='_12032019T152102.sam';
% pat_TS='[_]\d{8,8}[T]\d{6,6}[.]sam';   % very important to Only put "." in a [] --> [.]
pat_TS='[_]\d{8}[T]\d{6}[.]sam';   % {8} same as  {8,8} , very important to Only put "." in a [] --> [.]

m_TS = regexp(str0, pat_TS, 'match');
if length(m_TS)==1 && strfind(str0,m_TS{1})==(length(str0)-length(m_TS{1})+1)
    str0=strrep(str0,m_TS{1},'.sam');
end
%**************************************************************************
%#########################################################################
 pat='[-_]\d+[.]sam';   % very important to Only put "." in a [] --> [.]
%#########################################################################
% pat='([-_]\d+).sam';   % this will fail for some of No-Match cases
% "(_\d*|_\d*_\d*T\d*).sam"   % by VS
% pat='(_\d*|_\d*_\d*T\d*).sam'  % by VS --> only handle underscore "_"
%**************************************************************************

%=============================================================
m = regexp(str0, pat, 'match');

if ~isempty(m)
    Qm=m(end);
    [loc_last_match_start_last  loc_last_match_end ]=range_last_match(str0,Qm );
    
    if  length(Qm)==length(m)
        
         [loc_last_match_start_last  loc_last_match_end ]=range_last_match(str0,Qm );
         if loc_last_match_end~=length(str0 )
          out=str0;   
         else
         out=strrep(str0,m{end},'.sam');
         end
    else
        [loc_last_match_start_last  loc_last_match_end ]=range_last_match(str0,Qm );
        if loc_last_match_end~=length(str0 )
            out=str0;
        else
            out1=str0(1:loc_last_match_start_last-1);
            out2='.sam';
            out=[out1,out2];
        end
    end
else
    out=str0;
end
end


%% ----- range_last_match   [AQP_gui.m lines 1219-1223] ------------------------------------------
function [loc_last_match_start_last  loc_last_match_end ]=range_last_match(str0,Qm )
loc_last_match_start= strfind(str0,Qm{1});
loc_last_match_start_last=loc_last_match_start(end);
loc_last_match_end=loc_last_match_start_last+length( Qm{1})-1 ;
end


%% ----- ATsaConc_add_clistclslabel_AclassinfoT   [AQP_gui.m lines 1755-1763] --------------------
function SAT=ATsaConc_add_clistclslabel_AclassinfoT(SAT)
% add clistclslabel and/or AclassinfoT to ATsaConc 
if ~isfield(SAT,'clistclslabel') 
SAT.clistclslabel=row_always( unique(SAT.AclabelT));
end
if ~isfield(SAT,'AclassinfoT') 
SAT.AclassinfoT=cellfun(@(x) strmatch(x,SAT.clistclslabel,'exact'),SAT.AclabelT);
end
end


%% ----- ATsaConc_extract_selective_samples   [AQP_gui.m lines 1767-1791] ------------------------
function Lnew=ATsaConc_extract_selective_samples(Lorig,loc_extract)

if false
    
%     pathfname_AT='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\mC_Test\Atrainpketc_saConc_IDRC_(ManufacturerC_Test)_pp1-1stDerSGw13_pp2-SampMncn_nvar88_nsamp248.mat'
%  loc_OLs=[19 20 106 107];
%     ATsaConc_extract_selective_samples(pathfname_AT,loc_OLs)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Lorig=load(pathfname_AT);
loc_OLs=setdiff([1:length(Lorig.saConc)],loc_extract);
Lnew=Lorig;
Lnew.saConc(loc_OLs)=[];
Lnew.Atrainpk(loc_OLs,:)=[];
Lnew.AclassinfoT(loc_OLs)=[];
Lnew.AclabelT(loc_OLs)=[];
Lnew.RawSpectra(loc_OLs,:)=[];
try
Lnew.clistclslabel(loc_OLs)=[];
end
try
   Lnew.AInfo_1(loc_OLs)=[]; 
end
end


%% ----- Atrainpk_Split_Odd_Even   [AQP_gui.m lines 2039-2267] -----------------------------------
function out=Atrainpk_Split_Odd_Even(pathfname_AT)
% this can handle -->  SCSVM case that all AclassinfoT are zeros
% split Atrainpketc file into Odd seq vs Even seq sets
% will generate four files:
% T-odd_P-even,  T-even_P-odd, T-odd ONLY, and T-even ONLY 
% see also  Split_Odd_Even(obj) method in ssds
% see also  ATop, Atrainpk_merge_Apred
if false
    
   pathfname_AT= 'C:\work\JDSU\TestSite\Dataset_popular\NAVEOD\MK2200\SC_Oct30\ATetc\Atrainpketc_wRawSpectra_MK2200_SCulfogienis_Data_Oct30_pp1-1stDerSGDiederick_pp2-SNV_ncls58_nsamp1309.mat'
    Atrainpk_Split_Odd_Even(pathfname_AT);
    
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isa(pathfname_AT,'struct')
    LAT=pathfname_AT;
    pathfname_AT=['Atrainpketc_','nsamp',num2str(length(LAT.AclassinfoT)),'.mat'];
else
    
LAT=load(pathfname_AT);

end

SAT=LAT;
corename=find_keyword_between_markers(fileparts_name_ext(    pathfname_AT),'Atrainpketc_','.mat');
newPath=tmp_folder_rm_mk('AT_Odd-Even',pwd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % parsing T vs P based on Todd vs Peven
if ~any(SAT.AclassinfoT) % deal with SCSVM case that all AclassinfoT are zeros
    locT=col_always([1:2:length(SAT.AclassinfoT)]);
        locP=col_always([2:2:length(SAT.AclassinfoT)]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
else
    if length(SAT.clistclslabel)==length(SAT.AclassinfoT)
        locT=[1:2:length(SAT.AclassinfoT)];
        locP=[2:2:length(SAT.AclassinfoT)];
    else
        locT=[];
        locP=[];
        for icls=1:length(SAT.clistclslabel)
            loc_icls=find(SAT.AclassinfoT==icls);
            
            %     figure;hold on;plot(alldatenum_clean(loc_icls));
            ealocT=loc_icls(1:2:end);
            locT=[locT;ealocT];
            locP=[locP;setdiff(loc_icls,ealocT)];
            
        end
        
    end
end



try SATP.wvl_standardize  =SAT.wvl_standardize;end

SATP.clistclslabel=SAT.clistclslabel;
SATP.Atrainpk=SAT.Atrainpk(locT,:);
SATP.AclassinfoT=SAT.AclassinfoT(locT,:);
try SATP.AclabelT=SAT.AclabelT(locT,:);end
try SATP.RawSpectra.Tset=SAT.RawSpectra(locT,:);end
SATP.Apred=SAT.Atrainpk(locP,:);
SATP.AclassinfoP=SAT.AclassinfoT(locP,:);
try SATP.AclabelP=SAT.AclabelT(locP,:);end
try SATP.RawSpectra.Pset=SAT.RawSpectra(locP,:);end
SATP.locTodd=locT;
SATP.locPeven=locP;
try
SATP.PLS.Tset.saConc=LAT.saConc(locT); 
catch
    try
SATP.PLS.Tset.saConc=LAT.PLS.Tset.saConc(locT); 
    end
end


try
SATP.PLS.Pset.saConc=LAT.saConc(locP); 
catch
    try
SATP.PLS.Pset.saConc=LAT.PLS.Tset.saConc(locP); 
    end
end




% 
% updates ncls, nsampT, nsampP
corename=remove_keyword_between_markers_wlistRHS(corename,'nsamp',{'_',''});
corename=remove_keyword_between_markers_wlistRHS(corename,'nsampT',{'_',''});
corename=remove_keyword_between_markers_wlistRHS(corename,'nsampP',{'_',''});

fname_TP=[newPath,'\','Atrainpketc_wRawSpectra_{T-odd_P-even}_',corename,'_nsampT',num2str(length(SATP.AclassinfoT)),'__nsampP',num2str(length(SATP.AclassinfoP)),'_TP.mat'];
save(fname_TP,'-struct','SATP');
disp([fname_TP,' has been saved']);
SATP=rmfield(SATP,{'locTodd','locPeven'});

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save odd and even samples separately for UX
SAT_odd=rmfield(SATP,{'Apred','AclassinfoP'});
try SAT_odd=rmfield(SAT_odd,{'AclabelP'});end

try 
    SAT_odd=rmfield(SAT_odd,{'PLS'});
    SAT_odd.saConc=SATP.PLS.Tset.saConc;
end

try 
    SAT_odd=rmfield(SAT_odd,{'RawSpectra'});
    SAT_odd.RawSpectra=SATP.RawSpectra.Tset;
end





try SAT_odd.RawSpectra=SATP.RawSpectra.Tset;end
fname_odd=[newPath,'\','Atrainpketc_wRawSpectra-Direct_T-odd_',corename,'_nsampT',num2str(length(SAT_odd.AclassinfoT)),'.mat'];
save(fname_odd,'-struct','SAT_odd');
disp([fname_odd,' has been saved']);
%%%%%%%%%%
SAT_even=rmfield(SATP,{'Atrainpk','AclassinfoT'});
try SAT_even=rmfield(SAT_even,{'AclabelT'});end

SAT_even= RenameField(SAT_even, {'Apred','AclassinfoP','AclabelP'}, {'Atrainpk','AclassinfoT','AclabelT'});

try SAT_even.RawSpectra=SATP.RawSpectra.Pset;end

try 
    SAT_even=rmfield(SAT_even,{'PLS'});
    SAT_even.saConc=SATP.PLS.Pset.saConc;
end




fname_even=[newPath,'\','Atrainpketc_wRawSpectra-Direct_T-even_',corename,'_nsampT',num2str(length(SAT_even.AclassinfoT)),'.mat'];
save(fname_even,'-struct','SAT_even');
disp([fname_even,' has been saved']);





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % parsing T vs P based on Teven vs Podd
if ~any(SAT.AclassinfoT) % deal with SCSVM case that all AclassinfoT are zeros
    locT=col_always([2:2:length(SAT.AclassinfoT)]);
    locP=col_always([1:2:length(SAT.AclassinfoT)]);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
else   
    if length(SAT.clistclslabel)==length(SAT.AclassinfoT)
        locT=[2:2:length(SAT.AclassinfoT)];
        locP=[1:2:length(SAT.AclassinfoT)];
    else
        locT=[];
        locP=[];
        for icls=1:length(SAT.clistclslabel)
            loc_icls=find(SAT.AclassinfoT==icls);
            
            %     figure;hold on;plot(alldatenum_clean(loc_icls));
            ealocT=loc_icls(2:2:end);
            locT=[locT;ealocT];
            locP=[locP;setdiff(loc_icls,ealocT)];
            
        end
        
    end
    
end





try SATP1.wvl_standardize  =SAT.wvl_standardize;end

SATP1.clistclslabel=SAT.clistclslabel;
SATP1.Atrainpk=SAT.Atrainpk(locT,:);
SATP1.AclassinfoT=SAT.AclassinfoT(locT,:);
try SATP1.AclabelT=SAT.AclabelT(locT,:);end
try SATP1.RawSpectra.Tset=SAT.RawSpectra(locT,:);end

SATP1.Apred=SAT.Atrainpk(locP,:);
SATP1.AclassinfoP=SAT.AclassinfoT(locP,:);
try SATP1.AclabelP=SAT.AclabelT(locP,:);end
try SATP1.RawSpectra.Pset=SAT.RawSpectra(locP,:);end
SATP1.locTeven=locT;
SATP1.locPodd=locP;
try
SATP1.PLS.Tset.saConc=LAT.saConc(locT); 
catch
    try
SATP1.PLS.Tset.saConc=LAT.PLS.Tset.saConc(locT); 
    end
end

try
SATP1.PLS.Pset.saConc=LAT.saConc(locP); 
catch
    try
SATP1.PLS.Pset.saConc=LAT.PLS.Tset.saConc(locP); 
    end
end
% 
fname_TP1=[newPath,'\','Atrainpketc_wRawSpectra_{T-even_P-odd}_',corename,'_nsampT',num2str(length(SATP1.AclassinfoT)),'__nsampP',num2str(length(SATP1.AclassinfoP)),'_TP.mat'];
save(fname_TP1,'-struct','SATP1');
disp([fname_TP1,' has been saved']);
SATP1=rmfield(SATP1,{'locTeven','locPodd'});


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
out.SATP_Todd_Peven=SATP;
out.pathfname_Todd_Peven=fname_TP;

out.SATP_Teven_Podd=SATP1;
out.pathfname_Teven_Podd=fname_TP1;

out.SAT_odd=SAT_odd;
out.SAT_even=SAT_even;
catch
out=[];
end
disp('finish Atrainpk_Split_Odd_Even')
end


%% ----- Atrainpk_TP2TvsP   [AQP_gui.m lines 2271-2309] ------------------------------------------
function [LT LP ]=Atrainpk_TP2TvsP(pathfname_TP)
% parse Atrainpketc_~TP.mat into Tset and Pset as seperate AT files
% can deal with PLS type AT with saConc
if false
    
    clear
    pathfname_TP= 'C:\work\JDSU\Quant_2200ES\cross-SM_1700\Atrainpketc_saConc_Pertula_Samples+NC-PFN_Tset_ONLY_T-SM(S1-375)_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT75_ncls15_P-SM(S1-376)_pp1-1stDerSGDiederick_nsampP75.mat'
  [LT LP ]=Atrainpk_TP2TvsP(pathfname_TP)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    LTP=load(pathfname_TP);
    %%%%%%%%%%%%%%%%%%%
    LP.Atrainpk=LTP.Apred;
    try
    LP.AclassinfoT=LTP.AclassinfoP;
    end
    try
    LP.clistclslabel=LTP.clistclslabel;
    end
    
    try LP.AclabelT=LTP.AclabelP;end
    try LP.saConc=LTP.PLS.Pset.saConc;  end
    try LP.RawSpectra=LTP.RawSpectra.Pset;end
    try LP.wvl_standardize=LTP.wvl_standardize;end
    %%%%%%%%%%%%%%%%%%%%%%%%
    LT=LTP;
    LT=rmfield(LT,{'Apred'});
    try
        LT=rmfield(LT,{'AclassinfoP'});
    end
    
    
    try    LT=rmfield(LT,{'AclabelP'});end
    try LT.saConc=LTP.PLS.Tset.saConc;  end
    try LT.RawSpectra=LTP.RawSpectra.Tset;end
    try    LT=rmfield(LT,{'PLS'});end
end


%% ----- AutoQuant_DA_pipeline   [AQP_gui.m lines 3859-4301] -------------------------------------
function OUT_Regressor=AutoQuant_DA_pipeline(cCabXfer_scheme,inp4AQP)
% typically called by --> BatchRun_AutoQuant_DA_pipeline
% this function will call --> PLS_on_Xfer_PP_or_PP_Xfer
% this function will also call subfunction --> PP_on_Xferd_RawSpectra
%------------------------------------------------------------------------------------------------------------------
% automatic quantitative data analytic pipeline
% typically called by BatchRun_AutoQuant_DA_pipeline()
% this function will call --> BatchRun_CabXfer_Siesler48_MLtool
% will  call --> Xfer_on_RawSpectra_AQP and others ...
% % deal with UDM (if exist)
% % prepare for PLS_Scv
% Note --> % settings for running PLS for historical reason !!!
% disp('apply GLSw etc first then apply PP on UDM')
% see also CabXferLite 
%  inp4PLS_2DF.ModelPara_Opm_Scheme=inp4PLS_2DF.CurTcvModelParaOpmScheme;  % updated by CH, Nov 22, 2019
%   output Transferred CS before PP in L_X_AT2RS.Atrainpk or pathfname_AT_AT2RS (CH Dec 4, 2019)
%
%   % copy Transferred CS before PP  ( _AT2RS file) in L_X_AT2RS to "TMP_AQP" 
%   (this file can be validated with independent run of --> pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)  )
%  modified by CH to deal with missing Val set, Jan 28, 2020
% % for App Emulator, added Feb 17, 2020
% % copy of "inp4AQP" into BatchRun_CabXfer_Siesler48_MLtool inside subfunction --> Xfer_on_RawSpectra
% % make Xfer_on_RawSpectra an independent function called Xfer_on_RawSpectra_AQP
%
% % added pp2 Apr 3, 2020
% following two pp1 and pp2 will Not be needed anymore for running scan thru and summarize their results
% instead they are replaced by -->  this line is used to carry pp1 and pp2 from inp4AQP to inp4PLS_2DF
% inp4AQP.ModelOpt.pp1=inp4AQP.PP_methods.pp1;
% inp4AQP.ModelOpt.pp2=inp4AQP.PP_methods.pp2;     % added pp2 Apr 3, 2020if false
% % this line is used to carry pp1 and pp2 from inp4AQP to inp4PLS_2DF
% inp4PLS_2DF.PP_methods=inp4AQP.PP_methods;    % this line is for alt route of above line for carrying whole PP_methods into each subfunctions
%===============================================
% add following Nov 7, 2020
% % this is the case that there in Only CS exist
% % updated to handle CS-ONLY case to apply PP, Nov 7, 2020
%================================================
% % prepare and save Tset-Only or CS&Val  AT-file for AAQP to serve as PPd CabXferd RawSpectra of Master to Target, updated Nov 12, 2020
% inside subfunction --> function out_XferdRS_PP=PP_on_Xferd_RawSpectra(INP,inpPP)
% % very important to delete this file for the case woVal, otherwise it will cause problem in running PLS later
% % very important --> do NOT delete this file for the case wVal, otherwise it will cause problem in running PLS later
%================================================
% %copy CabXferd + PPd  AT-file to "TMP_AQP_StepByStep" updated Nov 15, 2020
% %deal with case that woXRS to copy CabXferd + PPd  AT-file to "TMP_AQP_StepByStep" updated Nov 16, 2020
%================================================
% % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
%================================================================================
% within subfunction : PP_on_Xferd_RawSpectra
% below will fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
% see also: XLSX2MAT_AQP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    clear; close all;
   OUT_Regressor = AutoQuant_DA_pipeline(cCabXfer_scheme,inp4AQP)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in current version of AQP, only single cCabXfer_scheme can be run at a
% time for AutoQuant_DA_pipeline, 
% for looping of multiple cCabXfer_scheme, pls use BatchRun_AutoQuant_DA_pipeline to loop
% 
if iscell(cCabXfer_scheme) && length(cCabXfer_scheme)==1
    disp('OK to run AutoQuant_DA_pipeline')
else
    error('current version of AQP, AutoQuant_DA_pipeline only support single cCabXfer_scheme be run at a time')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use saSettings to preallocate a structure array for running single iteration
% loop
% INP.cCabXfer_scheme={'MDC-GLSw[a1e-3]'};  % very important do NOT use without "[a1e-3]"
% cCabXfer_scheme={'MDC'};  % very important do NOT use without "[a1e-3]"
% cCabXfer_scheme={'STDgenize[w1]'};  % very important do NOT use without "[a1e-3]"
% cCabXfer_scheme={'woCabXfer'};  % very important do NOT use without "[a1e-3]"
 DataFlow=inp4AQP.DataFlow ;        % 'PP-Xfer'  %  'PP-Xfer' 'Xfer-PP'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step_1
switch DataFlow
    case 'Xfer-PP'
        
        
       inp4XferRS.path_CS_XRS= inp4AQP.path_CS_XRS;
       inp4XferRS.path_CS_Val= inp4AQP.path_CS_Val;
       try
       inp4XferRS.pathfname_MGs_PP_XSmst= inp4AQP.pathfname_MGs_PP_XSmst;
       catch
       inp4XferRS.pathfname_MGs_PP_XSmst='';    
       end
        
%         inp4XferRS.path_CS_XRS='C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\woCabXfer_Tmst_Ptrg_XRS';
%         inp4XferRS.path_CS_Val='C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\woCabXfer_Tmst_Ptrg_Val';

        
%         inp4XferRS.path_CS_XRS='C:\work\JDSU\CabXfer_Results_Review\AT\IDRC_AQP\CS-XRS';
%         inp4XferRS.path_CS_Val='C:\work\JDSU\CabXfer_Results_Review\AT\IDRC_AQP\CS-Val';

        inp4XferRS.inp4AQP=inp4AQP;
        out_XRS=Xfer_on_RawSpectra_AQP(cCabXfer_scheme,inp4XferRS);   % make Xfer_on_RawSpectra an independent function called Xfer_on_RawSpectra_AQP
%         out_XRS.OUT_Xfer --> this carry "Model_GLS"
        
        INP=out_XRS.INP;
        
    case 'PP-Xfer'
        PP_methods=inp4AQP.PP_methods;
        
        
       inp4PP_on_RS.path_Tmst_Ptrg_XRS= inp4AQP.path_CS_XRS;
       inp4PP_on_RS.path_Tmst_Ptrg_Val= inp4AQP.path_CS_Val;
       
       inp4PP_on_RS.pathfname_MGs_PP_XSmst= inp4AQP.pathfname_MGs_PP_XSmst;
        
        
%         inp4PP_on_RS.path_Tmst_Ptrg_XRS='C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\woCabXfer_Tmst_Ptrg_XRS';
%         inp4PP_on_RS.path_Tmst_Ptrg_Val='C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\woCabXfer_Tmst_Ptrg_Val'

%         inp4PP_on_RS.path_Tmst_Ptrg_XRS='C:\work\JDSU\CabXfer_Results_Review\AT\IDRC_AQP\CS-XRS';
%         inp4PP_on_RS.path_Tmst_Ptrg_Val='C:\work\JDSU\CabXfer_Results_Review\AT\IDRC_AQP\CS-Val'
        
        
        
        out_PP_RS=PP_on_RawSpectra(PP_methods,inp4PP_on_RS);
        
%         INP=out_PP_RS.INP;
        disp('done PP on RS')
        
        
        
        
        
    otherwise
        error('DataFlow not supported')
end
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step_2
switch DataFlow
    case 'Xfer-PP'
        inpPP.PP_methods=inp4AQP.PP_methods;
        
        out_XferdRS_PP=PP_on_Xferd_RawSpectra(INP,inpPP);
        
        path_X_P=out_XferdRS_PP.path_X_P;
        path_X_P_XRS=out_XferdRS_PP.path_X_P_XRS;
    case 'PP-Xfer'
        
        %    fileparts(out_PP_RS.pathfname_PP_XRS)
        %    out_PP_RS.pathfname_PP_Val
        inp4XferPP.path_PP_XRS=fileparts(out_PP_RS.pathfname_PP_XRS);
        inp4XferPP.pathfname_PP_Val=out_PP_RS.pathfname_PP_Val;
        
       % inp4XferPP.pathfname_MGs_PP_XSmst=inp4AQP.pathfname_MGs_PP_XSmst;
        inp4XferPP.pathfname_MGs_PP_XSmst=out_PP_RS.pathfname_MGs_PP_XSmst;
        inp4XferPP.inp4AQP=inp4AQP;
        out_XferPP=Xfer_on_PP(cCabXfer_scheme,inp4XferPP);
        %         out_XferPP.Model_GLS --> this carry "Model_GLS"
        
        if false
            Lx=load(out_XferPP.pathfname_XRS);
            Lv=load(out_XferPP.pathfname_Val);
        end
        
        disp('work on step 2 of PP-Xfer')
        
    otherwise
        error('DataFlow not supported')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%step_3
 % run PLS
 %%%%%%%%%%%%%%%%%%%%%%%%%
 % deal with UDM (if exist)
%  inp4AQP.pathfname_UDM
%  inp4AQP.PP_methods
 % check if inp4AQP.pathfname_UDM has not been PPd yet
 try
     Ludm=load(inp4AQP.pathfname_UDM);
 catch
     Ludm='';
 end
 
 if ~isempty(Ludm) && isSAME_2Matrix(Ludm.Atrainpk,Ludm.RawSpectra)
     % RawSpectra of UDM get DFd ( i.e. either Xfer-PP or PP-Xfer )
     % then result put inside --> path_DFd_UDM
     path_DFd_UDM= tmp_folder_rm_mk('TMP_DFd_UDM',pwd); % DFd --> DataFlow ed, i.e. either Xfer-PP or PP-Xfer
     prev_path=pwd;
     cd(path_DFd_UDM);
     
     % the following results should work for both data flow and GLSw 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     if ( isGLSw(cCabXfer_scheme{1}) || isGLSstd(cCabXfer_scheme{1})  ) &&  isempty(strfind(cCabXfer_scheme{1},'MDC-GLSw'))  && ~strcmp(inp4AQP.ModelOpt.CurUDMas,'woUDM')
         
         disp(' work on  GLSw when UDM exist but NOT "MDC-GLSw" yet !!!')
         
         switch DataFlow
             case 'Xfer-PP'
                 disp('apply GLSw etc first then apply PP on UDM')
                 % this will be output to outXfer and run --> UDM_GLSw  = glsw(UDM_prep,modl_GLSw,a);
                 %                  Model_GLS.modl_GLSw=modl_GLSw;
                 %                  Model_GLS.a=a;
                 %         out_XRS.OUT_Xfer --> this carry "Model_GLS"
                 if isGLSw(cCabXfer_scheme{1})
                     UDM_GLS  = glsw(Ludm.Atrainpk,out_XRS.OUT_Xfer.Model_GLS.modl_GLSw,out_XRS.OUT_Xfer.Model_GLS.a);
                 elseif isGLSstd(cCabXfer_scheme{1})
                     %UDM_GLSstd  = GLSstd_ApplyOn_UDM(UDM_prep,modl_GLSstd,opt4GLSstd);
                     UDM_GLS  = GLSstd_ApplyOn_UDM(Ludm.Atrainpk,out_XRS.OUT_Xfer.Model_GLS.modl_GLSstd);
                     
                 else
                     error('GLS type not supported')
                 end
                 
                 %Ludm.Atrainpk=UDM_GLS;
                % [Ludm.saConc.Atrainpk]=mat2cell_CH_4SAinsert(Ludm.Atrainpk,'row');% old approach not using newly created function Atrainpk2saConc
                % Ludm.saConc=Atrainpk2saConc(Ludm.Atrainpk,Ludm.saConc);
                 % try ssds method approach Atrainpk_replace to replace Ludm.Atrainpk
                 
                 %Ludm.RawSpectra=UDM_GLS;
                  % try ssds method approach RawSpectra_replace to replace Ludm.RawSpectra
                 %%%%%%%%%%%%%%%%%%%%%%%
                 sd_Ludm=ssds(Ludm);
                 % do not forget to reassign sd_Ludm to LHS of "=" !!!
                sd_Ludm= sd_Ludm.RawSpectra_replace(UDM_GLS);% since it is pp-none, Atrainpk and RawSpectra should be the same
                % do not forget to reassign sd_Ludm to LHS of "=" !!!
                sd_Ludm=  sd_Ludm.Atrainpk_replace(UDM_GLS);% since it is pp-none, Atrainpk and RawSpectra should be the same
                 
                 Ludm=sd_Ludm.LAT;  % newly updated Ludm
                 %%%%%%%%%%%%%%%%%%%%%%
                 
                 inp4sd.corename=['{',cCabXfer_scheme{1},'_pp1-none','_pp2-none','}'];
                 sd_Ludm.saveAT(inp4sd);
                 inp4PP.pathfname_AT=get_OnlyOne_AT(pwd);
                 inp4PP.PP_methods=inp4AQP.PP_methods;
                 out_PPd_UDM=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(Ludm,inp4PP);
                 delete(inp4PP.pathfname_AT);
                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 
                 
             case 'PP-Xfer'
                 disp('apply PP first then apply GLSw etc on UDM');
                 %                  inp4PP.pathfname_AT=get_OnlyOne_AT(pwd);
                 inp4PP.PP_methods=inp4AQP.PP_methods;
                 out_PPd_UDM=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(inp4AQP.pathfname_UDM,inp4PP);
                 pathfname_PPd_UDM=get_OnlyOne_AT(pwd);
                 Ludm_PPd=load(pathfname_PPd_UDM);
                 
                 %         out_XferPP --> this carry "Model_GLS"
                % UDM_GLS  = glsw(Ludm_PPd.Atrainpk,out_XferPP.Model_GLS.modl_GLSw,out_XferPP.Model_GLS.a);
                 
                 if isGLSw(cCabXfer_scheme{1})
                     UDM_GLS  = glsw(Ludm_PPd.Atrainpk,out_XferPP.Model_GLS.modl_GLSw,out_XferPP.Model_GLS.a);
                 elseif isGLSstd(cCabXfer_scheme{1})
                     %UDM_GLSstd  = GLSstd_ApplyOn_UDM(UDM_prep,modl_GLSstd,opt4GLSstd);
                     UDM_GLS  = GLSstd_ApplyOn_UDM(Ludm_PPd.Atrainpk,out_XferPP.Model_GLS.modl_GLSstd);
                     
                 else
                     error('GLS type not supported')
                 end
                 
                 
                 
                 
                 
                 delete(pathfname_PPd_UDM);
                 Ludm_PPd_Xfer=Ludm_PPd;
                 
%                  Ludm_PPd_Xfer.Atrainpk=UDM_GLS;
%                  [Ludm_PPd_Xfer.saConc.Atrainpk]=mat2cell_CH_4SAinsert(Ludm_PPd_Xfer.Atrainpk,'row');
                 
                 sd_Ludm_PPd_Xfer=ssds(Ludm_PPd_Xfer);
                 sd_Ludm_PPd_Xfer=sd_Ludm_PPd_Xfer.Atrainpk_replace(UDM_GLS);
                 
                 inp4sd.corename=['{','pp1-',inp4AQP.PP_methods.pp1,'_Xfer-',cCabXfer_scheme{1},'}'];
                 sd_Ludm_PPd_Xfer.saveAT(inp4sd);
                 
                 
                 
             otherwise
                 error('DataFlow not supported')
         end
     elseif strcmp(cCabXfer_scheme{1},'woCabXfer') || strcmp(cCabXfer_scheme{1},'MDC') || (   ( ~isempty(strfind(cCabXfer_scheme{1},'GLSw'))|| isGLSstd(cCabXfer_scheme{1}) )   && strcmp(inp4AQP.ModelOpt.CurUDMas,'woUDM') )
         out_PPd_UDM=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(inp4AQP.pathfname_UDM,inp4AQP);
         
     elseif strfind(cCabXfer_scheme{1},'STDgenize')
         
         out_PPd_UDM=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(inp4AQP.pathfname_UDM,inp4AQP);
         
     else
         
         error('for runing wUDM, so far the codes have only be tested with MDC or woCabXfer and GLSw and NOT for "MDC-GLSw" or any other Xfer  ')
         
     end
     
     cd(prev_path);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%% updating CS set %%%%
     switch DataFlow
         case 'Xfer-PP'
             path_CS_Val=path_X_P;
             path_CS_XRS=path_X_P_XRS;
             
         case 'PP-Xfer'
             path_CS_Val=fileparts(out_XferPP.pathfname_Val);
             path_CS_XRS=fileparts(out_XferPP.pathfname_XRS);
             
         otherwise
             error('DataFlow not supported')
     end
     %%%make it works for any Xfer below %%%%%
     if strcmp(cCabXfer_scheme{1},'woCabXfer')|| strcmp(cCabXfer_scheme{1},'MDC') || isGLSw(cCabXfer_scheme{1}) || isGLSstd(cCabXfer_scheme{1})  || strfind(cCabXfer_scheme{1},'STDgenize')  % eventually this if should be removed
         pathfname_CS_Val_orig=get_OnlyOne_AT(path_CS_Val);
         pathfname_CS_XRS_orig=get_OnlyOne_AT(path_CS_XRS);
         pathfname_DFd_UDM=get_OnlyOne_AT(path_DFd_UDM);
         
         
         sd_CS_Val_orig=ssds( pathfname_CS_Val_orig);
         %          sd_CS_Val_orig.LAT.PLS.Tset
         %          sd_CS_Val_orig.LAT.PLS.Pset
         
         sd_UDM=ssds( pathfname_DFd_UDM);
         %       sd_UDM.LAT
         sd_CS_Val_wUDM=sd_CS_Val_orig+sd_UDM;  % append DFd UDM to orig CS here !!!
         %   sd_CS_Val_wUDM.LAT.PLS.Tset
         % sd_CS_Val_wUDM.LAT.PLS.Pset
         %check
         if length(sd_CS_Val_wUDM.LAT.PLS.Tset.saConc)==length(sd_CS_Val_wUDM.LAT.AclabelT)
             inp4sd.corename=['{',find_keyword_between_markers(pathfname_CS_Val_orig,'{','}'),'}'];
             cd(path_CS_Val);
             sd_CS_Val_wUDM.saveAT(inp4sd);
             cd(prev_path);
             delete(pathfname_CS_Val_orig);
         else
             error('mismatch in PLS.Tset.saConc vs AclabelT in sd_CS_Val_wUDM')
         end
         %%%%%%%%%%%%
         
         sd_CS_XRS_orig=ssds( pathfname_CS_XRS_orig);
         sd_CS_XRS_wUDM=sd_CS_XRS_orig+sd_UDM;
         
         if length(sd_CS_XRS_wUDM.LAT.PLS.Tset.saConc)==length(sd_CS_XRS_wUDM.LAT.AclabelT)
             %inp4sd.corename=['{',find_keyword_between_markers(pathfname_CS_Val_orig,'{','}'),'}'];
             cd(path_CS_XRS);
             sd_CS_XRS_wUDM.saveAT(inp4sd);
             cd(prev_path);
             delete(pathfname_CS_XRS_orig);
         else
             error('mismatch in PLS.Tset.saConc vs AclabelT in sd_CS_XRS_wUDM')
         end
         %      else
         %          disp('working on GLSw etc')
     end
     %%%%%%
     
 elseif ~isempty(Ludm)
     error('pathfname_UDM should contain RawSpectra not PPd spectra')
     
 else % deal with woUDM case
     %%%%% updating CS set %%%%
     switch DataFlow
         case 'Xfer-PP'
             path_CS_Val=path_X_P;
             path_CS_XRS=path_X_P_XRS;
             
         case 'PP-Xfer'
             path_CS_Val=fileparts(out_XferPP.pathfname_Val);
             path_CS_XRS=fileparts(out_XferPP.pathfname_XRS);
             
         otherwise
             error('DataFlow not supported')
     end
     % deal with woUDM case
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
 end
 %%%% done with UDM %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% step3 contd
% after dealing with UDM, now it is ready to run PLS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
inp4PLS_2DF.path_DFd_UDM=path_DFd_UDM;
catch
inp4PLS_2DF.path_DFd_UDM='';    
end

try
    inp4PLS_2DF.sd_CS_Val_orig=sd_CS_Val_orig;
catch
   inp4PLS_2DF.sd_CS_Val_orig=''; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% provide detailed info for fig4
inp4AQP.ModelOpt.CabXfer_scheme=cCabXfer_scheme;
inp4AQP.ModelOpt.cDataFlow=inp4AQP.cDataFlow;
%
% following two pp1 and pp2 will be needed for running scan thru and summarize their results
if false
    % following two lines are replaced by --> inp4PLS_2DF=catstruct(inp4PLS_2DF,inp4AQP.PP_methods);
inp4AQP.ModelOpt.pp1=inp4AQP.PP_methods.pp1;
inp4AQP.ModelOpt.pp2=inp4AQP.PP_methods.pp2;     % added pp2 Apr 3, 2020
end
inp4PLS_2DF=catstruct(inp4PLS_2DF,inp4AQP.ModelOpt);
inp4PLS_2DF=catstruct(inp4PLS_2DF,inp4AQP.PP_methods);    % this line is used to carry pp1 and pp2 from inp4AQP to inp4PLS_2DF
inp4PLS_2DF.PP_methods=inp4AQP.PP_methods;    % this line is for alt route of above line for carrying whole PP_methods into each subfunctions

inp4PLS_2DF.tmpfolder4AllFinalModels=inp4AQP.tmpfolder4AllFinalModels; % for App Emulator, added Feb 17, 2020

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% inp4PLS_2DF.PlsfactorScan=inp4AQP.PlsfactorScan;

inp4PLS_2DF.cnt=inp4AQP.cnt ;            % add this for locating Beta_etc_FinalModel_~.mat files inside PLS_inside_PLS_predict_ONLY_MLtool

 switch DataFlow
    case 'Xfer-PP'
        inp4PLS_2DF.handles_gui=inp4AQP.handles_gui;
                inp4PLS_2DF.PlsfactorScan_default=inp4AQP.PlsfactorScan_default;
                inp4PLS_2DF.Spectra_Avg_Method = inp4AQP.Spectra_Avg_Method ;  % add this Apr 24, 2023 when dealing with Pset in Avg_Mean

     OUT_Regressor=PLS_on_Xfer_PP_or_PP_Xfer(path_CS_XRS,path_CS_Val,inp4PLS_2DF);
   
    case 'PP-Xfer'
%        path_XRS_PLS= fileparts(out_XferPP.pathfname_XRS);
%        path_Val_PLS=fileparts(out_XferPP.pathfname_Val);
 inp4PLS_2DF.handles_gui=inp4AQP.handles_gui;
                 inp4PLS_2DF.PlsfactorScan_default=inp4AQP.PlsfactorScan_default;

 OUT_Regressor=PLS_on_Xfer_PP_or_PP_Xfer(path_CS_XRS,path_CS_Val,inp4PLS_2DF);
    otherwise
        error('DataFlow not supported')
end
end


%% ----- PP_on_RawSpectra   [AQP_gui.m lines 4308-4361] ------------------------------------------
function out_PP_RS=PP_on_RawSpectra(PP_methods,inp4PP_on_RS)
path_P=tmp_folder_rm_mk('TMP_PP_AQP',pwd);
path_prev=pwd;
cd(path_P);

inpPP.PP_methods=PP_methods;

pathfname_XRS=get_OnlyOne_AT(inp4PP_on_RS.path_Tmst_Ptrg_XRS);
out_PP_XRS=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_XRS,inpPP);
out_PP_RS.pathfname_PP_XRS=[pwd,'\',out_PP_XRS.fname_new];
%%%%%%%%%%%%%
path_P_Val=tmp_folder_rm_mk('Val',pwd);
pathfname_Val=get_OnlyOne_AT(inp4PP_on_RS.path_Tmst_Ptrg_Val);
cd(path_P_Val);
out_PP_Val=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_Val,inpPP);
out_PP_RS.pathfname_PP_Val=[pwd,'\',out_PP_Val.fname_new];

%%%%%%%%%%%%%%
% deal with "pathfname_MGs_PP_XSmst"
cd(path_P);

path_PP_XSmst=tmp_folder_rm_mk('PP_XSmst',pwd);

pathfname_XSmst=inp4PP_on_RS.pathfname_MGs_PP_XSmst;

cd(path_PP_XSmst);

out_PP_XSmst=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_XSmst,inpPP);
out_PP_RS.pathfname_MGs_PP_XSmst=[pwd,'\',out_PP_XSmst.fname_new];



%%%%%%%%%%%%%%%
cd(path_prev);

if false
    
    figure;hold on;
    LRS=load(pathfname_Val);
    plot(LRS.RawSpectra.Tset','b-O');
    plot(LRS.RawSpectra.Pset','r-*');
    title('RawSpectra')
    
    figure;hold on;
    LPP=load(outPP.fname_new);
    plot(LPP.Atrainpk','c->');
    plot(LPP.Apred','m-+');
    title(PP_methods.pp1)
    
end


disp('done PP on RS')
end


%% ----- PP_on_Xferd_RawSpectra   [AQP_gui.m lines 4588-4741] ------------------------------------
function out_XferdRS_PP=PP_on_Xferd_RawSpectra(INP,inpPP)
% important locations:
% %copy CabXferd + PPd  AT-file to "TMP_AQP_StepByStep" updated Nov 15, 2020
% %deal with case that woXRS to copy CabXferd + PPd  AT-file to "TMP_AQP_StepByStep" updated Nov 16, 2020
%-------------------------------------------------------------------------------------------------------
% below will fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
%=======================================================================================
[clistfile_X nfile_X]=fdir_wildcard_ext_wPath([pwd,'\',INP.newpath_TMP_Cabxfer],'Atrainpketc_','mat');
if nfile_X==1
    pathfname_AT=clistfile_X{1};
elseif nfile_X==2
    pathfname_AT= clistfile_X(cellfun(@(x)  ~isempty(strfind(fileparts_name_ext(x),'Val')),clistfile_X));
    pathfname_AT=pathfname_AT{1};
    %%%%%%%%%%%%%%
    pathfname_AT_XRS= clistfile_X(cellfun(@(x)  isempty(strfind(fileparts_name_ext(x),'Val')),clistfile_X));
    if ~isempty(pathfname_AT_XRS)                                                                                                                   % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
        pathfname_AT_XRS=pathfname_AT_XRS{1};
    else
        pathfname_AT=INP.pathfnameTP4Val;                                                                                                      % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
        pathfname_AT_XRS='';                                                                                                                               % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
    end
else
    %     error('something wrong with INP.newpath_TMP_Cabxfer')
    pathfname_AT=INP.pathfnameTP4Val;
    pathfname_AT_XRS='';
    
end
%  pathfname_AT= 'C:\work\JDSU\CabXfer_Results_Review\TMP_Cabxfer_AQP\Atrainpketc_saConc_TPwTrn_TestCabXfer_{MDC-GLSw[a1e-3_Val]_KSall_pp1-none}_[T-XLS_P-XLS_Val]_nsampT153_nsampP153_nsampXS30.mat'
% pathfname_AT='C:\work\JDSU\CabXfer_Results_Review\TMP_CabXfer_TOOL\Atrainpketc_saConc_TPwTrn_TestCabXfer_{MDC-GLSw[a1e-3_Val]_KSall_pp1-none}_[T-XLS_P-XLS_Val]_nsampT153_nsampP153_nsampXS30.mat'
path_X_P=tmp_folder_rm_mk('TMP_CabXfer_PP_AQP',pwd);
path_prev=pwd;
cd(path_X_P);
try
L_X=load(pathfname_AT);
catch
    
    %=====================================================================================================================================
    % this is the case that there in Only CS exist % this is the case that there in Only CS exist % this is the case that there in Only CS exist % this is the case that there in Only CS exist 
    if isempty(pathfname_AT) && isempty(pathfname_AT_XRS)   % this is the case that there in Only CS exist
        %   C:\work\JDSU\Test_AQP\test_Narrow_WVL_Mst\TMP_AQP\TMP_AQP-LoadXLSX\Mst
        [clistfile_X_CS nfile_X_CS]=fdir_wildcard_ext_wPath( [find_last_nonTMP_folder,'\','TMP_AQP\TMP_AQP-LoadXLSX\Mst'],'Atrainpketc_','mat');
        if nfile_X_CS==1
            L_X_CS=load(clistfile_X_CS{1});
            %======================================================================================================================
            % below will fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
            if isfield(L_X_CS,'SAT_orig_Avg_All')    % this only happen for --> inp.Spectra_Avg_Method = 'Spectra_Avg_T-Mean_P-All'
                L_X_CS_orig_Avg_All=L_X_CS.SAT_orig_Avg_All;
                L_X=ssds(L_X_CS)>ssds(L_X_CS_orig_Avg_All);% this will fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
            else
                L_X=ssds(L_X_CS)>ssds(L_X_CS);% this is the case that there in Only CS exist
            end
            
            %=======================================================================================================================
            inp_CSonly.corename='{CS-ONLY}';
            L_X=L_X.saveAT(inp_CSonly);
            pathfname_AT=L_X.pathfname_AT;
        end
    end
     %=====================================================================================================================================

end
try
L_X_XRS=load(pathfname_AT_XRS);
catch
L_X_XRS='';    
end
% figure;hold on;plot(L_X.Atrainpk','r-*');

%very important to move Atrainpk to RawSpectra before running PP
% apply "AT2RS" operation
try
    L_X_AT2RS=L_X;
    L_X_AT2RS.RawSpectra_Tset_orig_woCabXfer=L_X_AT2RS.RawSpectra.Tset;
    L_X_AT2RS.RawSpectra.Tset=L_X.Atrainpk;
    L_X_AT2RS.RawSpectra.Pset=L_X.Apred;
    
    pathfname_AT=strrep(pathfname_AT,'saConc_TPwTrn_TestCabXfer_','');
    pathfname_AT=strrep(pathfname_AT,'_[T-CS_P-XRS}_Val]','');
    pathfname_AT=strrep(pathfname_AT,'KSall_','');
    pathfname_AT=strrep(pathfname_AT,'_wo_AT2RS','');
    pathfname_AT_AT2RS=strrep(pathfname_AT,'.mat',['_wAT2RS_For_PRO_testing.mat']);  % this can be tested for applying PP independently by pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
    save(pathfname_AT_AT2RS,'-struct','L_X_AT2RS');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % copy Transferred CS before PP  ( _AT2RS file) in L_X_AT2RS to "TMP_AQP"
    %  (this file can be validated with independent run of --> pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)  )
    copyfile(pathfname_AT_AT2RS,  [find_last_nonTMP_path,'\TMP_AQP']);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    out_PPd_Xferd_Mst_RS=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT_AT2RS,inpPP);
    %==================================================================
    % % prepare and save Tset-Only or CS&Val  AT-file for AAQP to serve as PPd CabXferd RawSpectra of Master to Target, updated Nov 12, 2020
    sd_PPd_XMR=ssds( out_PPd_Xferd_Mst_RS.fname_new);
    sPP12= ['_pp1-', inpPP.PP_methods.pp1,'_pp2-', inpPP.PP_methods.pp2] ;
    
%     sCabXfer=find_keyword_between_markers(out_PPd_Xferd_Mst_RS.fname_new,'{','_pp1-');
%         if isempty(sCabXfer)
%             sCabXfer=find_keyword_between_markers(out_PPd_Xferd_Mst_RS.fname_new,'{','_nsamp');
%         end
       sCabXfer=  INP.cCabXfer_scheme{1}; % updated Nov 16, 2020
        
        
    if isempty(INP.pathfnameTP4Val)
        % dealing with case woVal
        sd_PPd_XMR_Tonly=sd_PPd_XMR.rm_Pset;
        inp4PXMR.corename=['(',sCabXfer,sPP12,'_Tset-Only_for-AAQP',')'];
        sd_PPd_XMR_Tonly=sd_PPd_XMR_Tonly.saveAT( inp4PXMR);
       % copyfile(sd_PPd_XMR_Tonly.pathfname_AT,  [find_last_nonTMP_path,'\TMP_AQP']);
        copyfile(sd_PPd_XMR_Tonly.pathfname_AT,  [find_last_nonTMP_path,'\TMP_AQP_StepByStep']);        %copy CabXferd + PPd  AT-file to "TMP_AQP_StepByStep" updated Nov 15, 2020
        delete(sd_PPd_XMR_Tonly.pathfname_AT);           % very important to delete this file for the case woVal, otherwise it will cause problem in running PLS later
    else
        %dealing with case wVal
        inp4PXMR.corename=['(',sCabXfer,sPP12,'_CS&Val_for-AAQP',')'];
        sd_PPd_XMR=sd_PPd_XMR.saveAT(inp4PXMR);
        %copyfile(sd_PPd_XMR.pathfname_AT,  [find_last_nonTMP_path,'\TMP_AQP']);
        path_SbS_outsideTMP= [find_last_nonTMP_path,'\TMP_AQP_StepByStep'] ;
        if exist(path_SbS_outsideTMP,'dir')
            copyfile(sd_PPd_XMR.pathfname_AT,  [find_last_nonTMP_path,'\TMP_AQP_StepByStep'] );                    %copy CabXferd + PPd  AT-file to "TMP_AQP_StepByStep" updated Nov 15, 2020
        else
            path_SbS_outsideTMP=tmp_folder_rm_mk('TMP_AQP_StepByStep',find_last_nonTMP_path);
            copyfile(sd_PPd_XMR.pathfname_AT,  path_SbS_outsideTMP);                                                                  %deal with case that woXRS to copy CabXferd + PPd  AT-file to "TMP_AQP_StepByStep" updated Nov 16, 2020
        end
%         delete(sd_PPd_XMR.pathfname_AT);           % very important --> do NOT delete this file for the case wVal, otherwise it will cause problem in running PLS later
    end
   
   
   
    %%%%%% PP on XRS and also move Atrainpk to RawSpectra before running PP
    if ~isempty(L_X_XRS)
        L_X_AT2RS_XRS=L_X_XRS;
        L_X_AT2RS_XRS.RawSpectra.Tset=L_X_XRS.Atrainpk;
        L_X_AT2RS_XRS.RawSpectra.Pset=L_X_XRS.Apred;
        pathfname_AT_AT2RS_XRS=strrep(pathfname_AT_XRS,'.mat',['_AT2RS_XRS.mat']);
        
        path_X_P_XRS=tmp_folder_rm_mk('XRS',pwd);
        cd(path_X_P_XRS);
        save(pathfname_AT_AT2RS_XRS,'-struct','L_X_AT2RS_XRS');
        
        pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT_AT2RS_XRS,inpPP);
    else
        path_X_P_XRS='';
    end
    %%%%%%%%%%%%%%%
catch
       pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inpPP);           % updated to handle CS-ONLY case to apply PP, Nov 7, 2020
       delete(pathfname_AT);                                                                                         % updated to handle CS-ONLY case to apply PP, Nov 7, 2020
    path_X_P_XRS='';
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(path_prev);
%%%%%%%%%%%%%%%
out_XferdRS_PP.path_X_P=path_X_P;
out_XferdRS_PP.path_X_P_XRS=path_X_P_XRS;
end


%% ----- Xfer_on_PP   [AQP_gui.m lines 4797-4849] ------------------------------------------------
function      out_XferPP=Xfer_on_PP(cCabXfer_scheme,inp4XferPP)

path_prev=pwd;

LINP=load_local_try('C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\INP_wo_handles.mat');
INP=LINP.INP;
INP=rmfield(INP,'cCabXfer_scheme');
INP=rmfield(INP,'cXM_Slct_scheme');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
INP.pathfnameTP4Val=inp4XferPP.pathfname_PP_Val;
INP.TP_includeTrn_Yes=1; % default setting copied from CabXferLite
INP.cXM_Slct_scheme={'KSall'};

INP.cCabXfer_scheme=cCabXfer_scheme;  % very important do NOT use without "[a1e-3]"

INP.newpath_TMP_Cabxfer='TMP_Cabxfer_AQP';

path_CabX=inp4XferPP.path_PP_XRS;

INP.pathfname_MGs_PP_XSmst=inp4XferPP.pathfname_MGs_PP_XSmst;

INP.inp4AQP= inp4XferPP.inp4AQP;
OUT_Xfer=BatchRun_CabXfer_Siesler48_MLtool(path_CabX,INP);

out_XferPP.INP=INP;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% carry "Model_GLS" to outside of internal functions CabXfer_Siesler48_MLtool
out_XferPP.Model_GLS=OUT_Xfer.Model_GLS;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% move XRS and Val to their own folder
cd([pwd,'\',INP.newpath_TMP_Cabxfer]);

 [clistfile nfile]=fdir_wildcard_ext_wPath(pwd,'Atrainpketc_','mat');
 loc_Val=find(cellfun(@(x) ~isempty(strfind(fileparts_name_ext(x),'Val')),clistfile));
 loc_XRS=find(cellfun(@(x) isempty(strfind(fileparts_name_ext(x),'Val')),clistfile));
 
path_XRS=tmp_folder_rm_mk('XRS',pwd);
copyfile(clistfile{loc_XRS},path_XRS);
delete(clistfile{loc_XRS});
 
path_Val=tmp_folder_rm_mk('Val',pwd);
copyfile(clistfile{loc_Val},path_Val);
delete(clistfile{loc_Val});


cd(path_prev);

out_XferPP.pathfname_XRS=get_OnlyOne_AT(path_XRS)
out_XferPP.pathfname_Val=get_OnlyOne_AT(path_Val)


disp('done Xfer_on_PP')
end


%% ----- Scv4all_RMSE_PLS_Scv   [AQP_gui.m lines 4854-4873] --------------------------------------
function [all_RMSE_PLS_Scv]=Scv4all_RMSE_PLS_Scv(OrigCS,ScoutCS,inp4Scv)
% run Scv to generate all_RMSE_PLS_Scv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%if false  % extracted and modified from PLS_inside_PLS_predict_ONLY_MLtool()
OUT_Scv=[];
tstart = tic;
hwb = waitbar(0,'running cross validation...');  %  waitbar
% inp4Scv.PlsfactorScan= inp.PlsfactorScan;
for iPf=1:length(inp4Scv.PlsfactorScan)
    inp4Scv.PLSfactor=inp4Scv.PlsfactorScan(iPf);
    outPLS_Scv_iPf=PLS_Scv(OrigCS,ScoutCS,inp4Scv);  % new and fixed
    OUT_Scv=[OUT_Scv;outPLS_Scv_iPf];
    
    waitbar(iPf/length(inp4Scv.PlsfactorScan),hwb);   %  waitbar
end
close(hwb);% waitbar
telapsed = toc(tstart);
elapeTime_HumanRead=seconds2human_CH(telapsed);
all_RMSE_PLS_Scv=arrayfun(@(x) x.RMSE,OUT_Scv);
end


%% ----- isGLSstd   [AQP_gui.m lines 4876-4883] --------------------------------------------------
function out=isGLSstd(Xfer_scheme)
loc=strfind(Xfer_scheme,'GLSstd');
if ~isempty(loc)
    out=true;
else
    out=false;
end
end


%% ----- isGLSw   [AQP_gui.m lines 4885-4892] ----------------------------------------------------
function out=isGLSw(Xfer_scheme)
loc=strfind(Xfer_scheme,'GLSw');
if ~isempty(loc)
    out=true;
else
    out=false;
end
end


%% ----- BatchRun_AutoQuant_DA_pipeline   [AQP_gui.m lines 4896-5950] ----------------------------
function [OUT   OUT_Cmp_Results ]=BatchRun_AutoQuant_DA_pipeline(InpBR)
% typically called by --> AQP_gui (AQPlite pu)
% this function will call --> AutoQuant_DA_pipeline
%-------------------------------------------------------------------------------
% this function typically called by --> AQP_gui
% this function will call --> XLSX2MAT_AQP
% see also AQP_gui BatchRun_PLS_wTcv_StandAlone  AutoQuant_DA_pipeline
% see also: SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool (main function generate PLS results and figures)
% see also: AQP_App_Emulator
%
% important spots in this function
%   call_XLabel_Grids=InpBR.handles_AQP_gui.call_UDMas_scheme  ;
% for adjusting PlsfactorScan for small sized UDM
% turn off UDM etc, July 11, 2019
% TcvModelParaOpmScheme
% Set_GUI_PopUpMenu_parameter_Default
% inp4AQP.ModelOpt.CurTcvModelParaOpmScheme=out_para_TcvModelParaOpmScheme; % this one should be a char, Not a cell
%
%     following added Oct 2019
%      cd(path_prev);  error('No XSmst found in CS ?  typically XSmst (and XStrg) should use Ref of NaN for all of them');
%     following added Oct 21, 2019
%     get ID of XRS only and return and use to find matching ID samples in CS to serve as XSmst
%     inp4AQP.ModelOpt.PLSfactor_Opm_User_Pick=InpBP.PLSfactor_Opm_User_Pick;  % added by CH Nov 22, 2019
%
% %create tmp folder to store all fname_FinalModel for App Emulator
% % find OpmModel_Beta_etc_FinalModel by running AQP_App_Emulator.m
% plot RMSEP summary for scan thru CabXfer_scheme or PP methods or Datasets etc
% Seq in OpmFM
% % plot Opm FinalModel on RMSEP Summary figure
% % based on "Results4RMSEP" generated inside --> SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool(pathfnameTP,inp)
%  % run json_AQP_OpmModel_Sequence to prepare beta etc in json format
%-----------------------------------------------
% inp4AQP=InpBR;
%  OUT_Regressor = AutoQuant_DA_pipeline(call_XLabel_Grids(iXLG),inp4AQP);         %    Main Function 
%
% following locations are dealt with PP2
%  cPP2=InpBR.handles_AQP_gui.cPP2;         % multiple entries of cPP2 and will be used to Scan Thru
%  cLegendLoop=cPP2;     
%  inp4AQP.PP_methods.pp2=cPP2{ jLine};    %  for Scan Thru with cPP2
% % if can not find in PP1 then scan thru should be based on PP2
%
% inside the following main subfunction --> AutoQuant_DA_pipeline
% following two pp1 and pp2 will be needed for running scan thru and summarize their results
% inp4AQP.ModelOpt.pp1=inp4AQP.PP_methods.pp1;
% inp4AQP.ModelOpt.pp2=inp4AQP.PP_methods.pp2;     % added pp2 Apr 3, 2020if false
%                OUT_Regressor.cLegendLoop_jLine=cLegendLoop{jLine};
%                 idx_PPj=arrayfun(@(x) strcmp(x.cLegendLoop_jLine,cLegendLoop{jLine}),all_OUT_PLS);
%
%   % plot Opm FinalModel on RMSEP Summary figure only when more than one "OUT=ALL_OUT_PLS" were generated
%
% % deal with PP1 and PP2 come from PP1_PP2_xlsx
% % AQPlite version for N_jLine
% cLegendLoop=cellstr(string(cPP1)+"+"+string(cPP2));
%
% OUT_cln=rmfield(OUT,'inp4AQP'); %updated July 22, 2020
% save (['Results_AQP_',corename4ResultsFile,'.mat'], 'OUT_cln');
% % collect multiple runs' Results_AQP_~.mat files and use  Cmp_Results_AQP.m to show comparison plot (added July 23, 2020)
% % save OpmModel's all fig files
%  show_OpmModel_figs
%updated Aug 24, 2020 to deal with struct2cell handling of {PRO}
%-------------------------------------------------------------------------------------
% following was updated Oct 13, 2020
% % capture BCseq into fname_Results_AQP_OUT_cln
%-----------------------------------------------
% % updated Nov 14, 2020 to output CS after MatchGrids
%  % search for --> 'TMP_AQP_StepByStep'
%-----------------------------------------------
% % sometime the combined path+fname --> Path4OUT_cln_AQP_FinalSubfolder + fname_Results_AQP_OUT_cln  --> can be too long, Nov 22, 2020
%---------------------------------------------------
% % updated Dec 3, 2020 to output CS and Val after MatchGrids ( to StepByStep folder )
% ---------------------------------------------------
% % copy Mst RawSpectra Before MatchGrids (or MGs), Apr 4, 2021
% % copy Mst XRS Before MatchGrids (or MGs), Apr 4, 2021
%  % copy Mst RawSpectra Before MatchGrids (or MGs), Apr 5, 2021,  there is no Mst XRS in this case
% % rename to "CS-Before-MatchGrids", Apr 15, 2021
% % rename to "XSmst-Before-MatchGrids", Apr 15, 2021
%-----------------------------------------------------
% revisit TcvModelParaOpmScheme , Jan 5, 2023
%--------------------------------------------------------------------------------
% Opm_PP_scheme by OMfig_tit1 i.e. Opm Model's 45deg plot's 1st line in its title, Feb 25, 2023
% warning('Opm Model''s PP scheme based on sia_ContentOFM is different from OMfig_tit1 ?');
%   inp4AQP.cnt=cnt;  % add this for locating Beta_etc_FinalModel_~.mat files inside PLS_inside_PLS_predict_ONLY_MLtool
%-------------------------------------------------
% modify Mar 8, 2023 that will get OMfig_tit3_RMSE from outOpmFM.RMSEP_Opm
% modified Mar 9, 2023 that will get OMfig_tit1 (later used for sOpmSeq ) from outOpmFM
%-------------------------------------------------------------
% revisit this Mar 15, 2023 when bugs wrt Cmp_Results_AQP.m in AQPlite happened
% see also: find_keyword_merge_dual_curly_bracket_w_targetstring_remain
%----------------------------------------------------------------------------
% add this to fix error associated with SNV{PRO},  Apr 3, 2023
%------------------------------------------------------------
if false
    
    close all; clear;

    InpBR.path_CS_XRS='C:\work\JDSU\CabXfer_Results_Review\AT\Astra34-Brix\CS-XRS';
    InpBR.path_CS_Val='C:\work\JDSU\CabXfer_Results_Review\AT\Astra34-Brix\CS-Val';
    InpBR.pathfname_MGs_PP_XSmst='';
   OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       close all; clear;

    InpBR.path_CS_XRS='C:\work\JDSU\CabXfer_Results_Review\AT\IDRC-Protein\CS-XRS';
    InpBR.path_CS_Val='C:\work\JDSU\CabXfer_Results_Review\AT\IDRC-Protein\CS-Val';
   OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Brix CS123 XS30(NaN-Ref) Val153 (woUDM)
  
   close all; clear;
       InpBR.path_CS_XRS=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B123\Tmst_Ptrg_XRS';  %(NaN-Ref)
    InpBR.path_CS_Val=           'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B123\Tmst_Ptrg_Val';  %(NaN-Ref)
    InpBR.pathfname_MGs_PP_XSmst='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B123\MGs_PP_XSmst\Atrainpketc_saConc_pp1-none_pp2-none_nvar125_nsamp30_pp-After-MatchGrids.mat'
     % the above file will be PPd and put into ~\TMP_PP_AQP\PP_XSmst in "PP-Xfer" dataflow
     % 
    OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Brix CS102 XS30(NaN-Ref) Val102 (woUDM yet)
  
   close all; clear;
       InpBR.path_CS_XRS=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_woUDM\Tmst_Ptrg_XRS';  %(NaN-Ref)
    InpBR.path_CS_Val=           'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_woUDM\Tmst_Ptrg_Val';  %(NaN-Ref)
    InpBR.pathfname_MGs_PP_XSmst='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_woUDM\MGs_PP_XSmst\Atrainpketc_saConc_(Brix_XSmst_wRefNaN)_pp1-none_pp2-none_nvar125_nsamp30.mat'
     % the above file will be PPd and put into ~\TMP_PP_AQP\PP_XSmst in "PP-Xfer" dataflow
     % 
    OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Pol CS1712 XS30(NaN-Ref) Val430 (woUDM yet)
  
   close all; clear;
       InpBR.path_CS_XRS='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_woUDM\Tmst_Ptrg_XRS';  %(NaN-Ref)
    InpBR.path_CS_Val=   'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_woUDM\Tmst_Ptrg_Val';  %(NaN-Ref)
    InpBR.pathfname_MGs_PP_XSmst='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_woUDM\MGs_PP_XSmst\Atrainpketc_saConc_(Pol_CS1742_Val-Even430_XSmst_wRefNaN)_pp1-none_pp2-none_nvar125_nsamp30.mat'
     % the above file will be PPd and put into ~\TMP_PP_AQP\PP_XSmst in "PP-Xfer" dataflow
     % 
    OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Pol CS1712 XS30(NaN-Ref) Val430 with UDM431
  
%    close all; clear;
%        InpBR.path_CS_XRS=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431\Tmst_Ptrg_XRS';  %(NaN-Ref)
%     InpBR.path_CS_Val=           'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431\Tmst_Ptrg_Val';  %(NaN-Ref)
%     InpBR.pathfname_MGs_PP_XSmst='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431\MGs_PP_XSmst\Atrainpketc_saConc_(Pol_CS1742_Val-Even430_XSmst_wRefNaN)_pp1-none_pp2-none_nvar125_nsamp30.mat'
%      % the above file will be PPd and put into ~\TMP_PP_AQP\PP_XSmst in "PP-Xfer" dataflow
%      % 
%      InpBR.pathfname_UDM=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431\UDM\Atrainpketc_saConc_(Pol_CS1742_wUDM431_Val-Even430_UDM)_pp1-none_pp2-none_nvar125_nsamp431.mat'
    
% Pol CS1712 XS30(NaN-Ref) Val430 with UDM431

     close all; clear;
     InpBR.path_XLSX= 'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Pol_CS1742_wUDM431_Val-Even430'
     OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Brix CS102 XS30(NaN-Ref) Val102 with UDM21
  
   close all; clear;
%        InpBR.path_CS_XRS=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\Tmst_Ptrg_XRS';  
%     InpBR.path_CS_Val=           'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\Tmst_Ptrg_Val';  
%     InpBR.pathfname_MGs_PP_XSmst='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\MGs_PP_XSmst\Atrainpketc_saConc_(Brix_CS102_UDM21)_pp1-none_nvar125_nsamp30.mat'
%      % the above file will be PPd and put into ~\TMP_PP_AQP\PP_XSmst in "PP-Xfer" dataflow
%      % 
%      InpBR.pathfname_UDM=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\UDM\Atrainpketc_saConc_(Brix_CS102_UDM21_UDM)_pp1-none_pp2-none_nvar125_nsamp21.mat'
       
     close all; clear;
    InpBR.path_XLSX= 'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21'
     OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Pol CS1712 XS30(NaN-Ref) Val430 with UDM431 but only keep 1/Nth
  
   close all; clear;
       InpBR.path_CS_XRS=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431_OneNth\Tmst_Ptrg_XRS';  %(NaN-Ref)
    InpBR.path_CS_Val=           'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431_OneNth\Tmst_Ptrg_Val';  %(NaN-Ref)
    InpBR.pathfname_MGs_PP_XSmst='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431_OneNth\MGs_PP_XSmst\Atrainpketc_saConc_(Pol_CS1742_Val-Even430_XSmst_wRefNaN)_pp1-none_pp2-none_nvar125_nsamp30.mat'
     % the above file will be PPd and put into ~\TMP_PP_AQP\PP_XSmst in "PP-Xfer" dataflow
     % 
     InpBR.pathfname_UDM=        'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431_One40th\UDM\Atrainpketc_(Pol-Val861Odd_keep_one_40th)_pp1-none_pp2-none_nvar125_nsamp11.mat'
%     InpBR.pathfname_UDM=           'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\P1712_wUDM431_One10th\UDM\Atrainpketc_(Pol-Val861Odd_keep_one_10th)_pp1-none_pp2-none_nvar125_nsamp44.mat'
     
     OUT=BatchRun_AutoQuant_DA_pipeline(InpBR) ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

show_wb_yes=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  inp4AQP.Spectra_Avg_Method=InpBR.Spectra_Avg_Method; % copy Spectra_Avg_Method
% inp4AQP=catstruct(inp4AQP,InpBR);
inp4AQP=InpBR;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 inp4AQP.cUDMas_scheme=InpBR.handles_AQP_gui.cUDMas_scheme; % use cell datatype
 if iscell(inp4AQP.cUDMas_scheme) && length(inp4AQP.cUDMas_scheme) && strcmp(inp4AQP.cUDMas_scheme{1},'woUDM')
     disp('this supported "cUDMas_scheme" for running AQP now')
 else
     disp_with_border('current AQP only support "cUDMas_scheme" as "{woUDM}" !!!');
     Speak_mk('current AQP only support "cUDMas_scheme" as "{woUDM}" !!!');
     error('this is Not supported "cUDMas_scheme" for running AQP now')
 end
  
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% block the following on Jan 26, 2020 and load PlsfactorScan in AQP_gui.m
% Lip=load_local_try('C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\inp4PLS.mat');
% PlsfactorScan_default=Lip.inp4PLS.PlsfactorScan;
% inp4AQP.ModelOpt.PlsfactorScan=PlsfactorScan_default;

inp4AQP.ModelOpt.ModelPara_Opm_Scheme= 'ModelParaOpmBy-XS_KSall';  %       'ModelParaOpmBy-XS_KSall'          'ModelParaOpmBy-Tcv'

% inp4AQP.ModelOpt.ModelPara_Opm_Scheme= 'ModelParaOpmBy-Tcv';  %       'ModelParaOpmBy-XS_KSall'          'ModelParaOpmBy-Tcv'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% insert parameter "CurTcvModelParaOpmScheme" (e.g. 'KneePt+1_RMSECV' ) into inp4AQP.ModelOpt
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% revisit TcvModelParaOpmScheme , Jan 5, 2023
inp4AQP.ModelOpt.CurTcvModelParaOpmScheme=InpBR.out_para_TcvModelParaOpmScheme; % this one should be a char, Not a cell
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
try
inp4AQP.ModelOpt.PLSfactor_Opm_User_Pick=InpBR.PLSfactor_Opm_User_Pick;  % added by CH Nov 22, 2019
catch
inp4AQP.ModelOpt.PLSfactor_Opm_User_Pick=NaN;    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp4AQP.ModelOpt.CrossValidationType='sqrtNSfolds-Conc';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% see Run_AQP_Callback inside AQP_gui for setting up InpBR.handles_AQP_gui.cDataFlow
try
    inp4AQP.cDataFlow=InpBR.handles_AQP_gui.cDataFlow ;
catch
    inp4AQP.cDataFlow={'Xfer-PP'};  %  default DataFlow
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% try
% %     cCabXfer_scheme=InpBR.handles_AQP_gui.cCabXfer_scheme ;  % block this, since cCabXfer_scheme may have been changed inside XLSX2MAT_AQP and that only been updated to inp4AQP
%     cCabXfer_scheme=inp4AQP.cCabXfer_scheme ;  % updated July 24, 2020
% catch
%     cCabXfer_scheme={'woCabXfer','MDC','GLSw[a1e-3]','STDgenize[w7]'};  %  scan three CabXfer schemes
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%   cPP1={'SGw5','1stDerSGFL7[PO2]', '2ndDerSGFL9[PO3]'}; % this seems more consistent
%     cPP1={'1stDerSGFL7[PO2]'}; % this seems more consistent
%     cPP1={'SGw5'}; % 0rd Der
try
    cPP1=InpBR.handles_AQP_gui.cPP1 ;
catch
    cPP1={'SGw5','1stDerSGFL7[PO2]', '2ndDerSGFL9[PO3]'};  %  scan three CabXfer schemes
end
    
    smarker_DF='Ox';  % for cDataFlow
% scolor_PP='kgr';
% scolor_PP='kgrymcv';
% smarker_PP='O*+.d*p';
% for 32 unique combinations of color/marker
% scolor_PP='krgbymcpolasvhkrgbymcpolasvhkrgb';
% smarker_PP='>+<pxodh>+<pxodh>+<pxodh>+<pxodh';
scolor_PP='krgbymcpolasvhkrgbymcpolasvhkrgb';
scolor_PP=[scolor_PP,scolor_PP];
smarker_PP='>+<pxodh>+<pxodh>+<pxodh>+<pxodh';
smarker_PP=[smarker_PP,smarker_PP(2:end),smarker_PP(1)];
% 
% allcomb=arrayfun(@(x,y) [x,y],scolor_PP,smarker_PP,'uniformoutput',false);
% length(unique(allcomb))



%%%%%%%%%%%%%%%%%%%%%%
if iscell(InpBR.handles_AQP_gui.cPP2) && length(InpBR.handles_AQP_gui.cPP2)==1
 inp4AQP.PP_methods.pp2=InpBR.handles_AQP_gui.cPP2{1};   % 'SampMncn'  'none' '1stDer'   '2ndDer'  'SNV'
      cPP2=InpBR.handles_AQP_gui.cPP2;         % single entry cPP2

elseif iscell(InpBR.handles_AQP_gui.cPP2) && length(InpBR.handles_AQP_gui.cPP2)>1
     inp4AQP.PP_methods.pp2='NotSetYet';      % this should be set to one of cPP2
     cPP2=InpBR.handles_AQP_gui.cPP2;         % multiple entries of cPP2 and will be used to Scan Thru
else
  inp4AQP.PP_methods.pp2='SNV';   % 'SampMncn'  'none' '1stDer'   '2ndDer'  'SNV'
        cPP2={ inp4AQP.PP_methods.pp2};

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rmdir_DSn_AQP;% remove all DSn folders under pwd
if isempty(InpBR.path_DSn_ParentFolder)&& ~isempty(InpBR.path_XLSX)
    seqDS=1;
    inp4XLSX2MAT.DS_type='single_XLSX_folder';
%         inp4XLSX2MAT.DS_type='multiple_DSn_MAT_folders';

% pull out subfunction --> XLSX2MAT to become an independent function called XLSX2MAT_AQP
    [inp4AQP]=XLSX2MAT_AQP(inp4AQP,InpBR,seqDS,inp4XLSX2MAT);% pull out subfunction --> XLSX2MAT to become an independent function called XLSX2MAT_AQP
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % updated Nov 14, 2020 to output CS after MatchGrids
    try
        if ~isempty( inp4AQP.path_CS_XRS)
        [clistfilename_CS_XRS, nfile_CS_XRS]= fdir_wildcard_wPath( inp4AQP.path_CS_XRS,'Atrainpketc');
        elseif ~isempty( inp4AQP.path_CS_Val)                                                                                                            % updated Dec 3, 2020 to output CS and Val after MatchGrids
          nfile_CS_XRS=0;  clistfilename_CS_XRS=[];
         [clistfilename_CS_Val, nfile_CS_Val]= fdir_wildcard_wPath( inp4AQP.path_CS_Val,'Atrainpketc');                % updated Dec 3, 2020 to output CS and Val after MatchGrids
        end
        
        if    nfile_CS_XRS==1 && ~isempty(clistfilename_CS_XRS{1})
            %      copyfile( inp4AQP.pathfname_MGs_PP_XSmst ,pwd);
            path_prev=pwd;
            cd(find_last_nonTMP_path);
            pathSbS=tmp_folder_rm_mk('TMP_AQP_StepByStep',pwd);            % updated Nov 14, 2020 to output CS after MatchGrids
            cd(pathSbS);
            
            copyfile(clistfilename_CS_XRS{1},pathSbS);
            sdMGs=ssds(fileparts_name_ext(    clistfilename_CS_XRS{1}) );
            inpMGs.corename='After-MatchGrids_T-CS_P-MstXRS';
            sdMGs=sdMGs.saveAT(inpMGs);
            %============================
            % copy Mst RawSpectra Before MatchGrids (or MGs), Apr 4, 2021
            path_Mst_RS_BefMGs=[find_last_nonTMP_folder,'\TMP_AQP\TMP_AQP-LoadXLSX\Mst'];
            [clistfilename_Mst_RS_BefMGs, nfile_Mst_RS_BefMGs]= fdir_wildcard_wPath( path_Mst_RS_BefMGs,'Atrainpketc');
           if nfile_Mst_RS_BefMGs==1
             copyfile(clistfilename_Mst_RS_BefMGs{1},pathSbS);
             
            filename_Mst_RS_BefMGs_new=  strrep(strrep( fileparts_name_ext(clistfilename_Mst_RS_BefMGs{1} ),'saConc','CS-Before-MatchGrids'),'_CS)',')')   ;              % rename to "CS-Before-MatchGrids", Apr 15, 2021
             movefile( fullfile(pathSbS, fileparts_name_ext(clistfilename_Mst_RS_BefMGs{1} )) ,  fullfile( pathSbS, filename_Mst_RS_BefMGs_new )  );     % rename to "CS-Before-MatchGrids", Apr 15, 2021
           end
           %--------------------------------------------------------
           % copy Mst XRS Before MatchGrids (or MGs), Apr 4, 2021
           path_Mst_XRS_BefMGs=[find_last_nonTMP_folder,'\TMP_AQP\TMP_AQP-LoadXLSX\Mst\XSmst'];
            [clistfilename_Mst_XRS_BefMGs, nfile_Mst_XRS_BefMGs]= fdir_wildcard_wPath( path_Mst_XRS_BefMGs,'Atrainpketc');
           if nfile_Mst_XRS_BefMGs==1
               copyfile(clistfilename_Mst_XRS_BefMGs{1},pathSbS);
               % rename to "XRSmst-Before-MatchGrids", Apr 15, 2021
             filename_Mst_XRS_BefMGs_new=  strrep(strrep( fileparts_name_ext(clistfilename_Mst_XRS_BefMGs{1} ),'saConc','XSmst-Before-MatchGrids'),'_XSmst_wRefNaN','')   ;              % rename to "XSmst-Before-MatchGrids", Apr 15, 2021
             movefile( fullfile(pathSbS, fileparts_name_ext(clistfilename_Mst_XRS_BefMGs{1} )) ,  fullfile( pathSbS, filename_Mst_XRS_BefMGs_new )  );     % rename to "XSmst-Before-MatchGrids", Apr 15, 2021

           end
            %============================
            
            cd(path_prev);
            
        elseif   nfile_CS_Val==1 && ~isempty(clistfilename_CS_Val{1})                                                                      % updated Dec 3, 2020 to output CS and Val after MatchGrids
             path_prev=pwd;
            cd(find_last_nonTMP_path);
            pathSbS=tmp_folder_rm_mk('TMP_AQP_StepByStep',pwd);                                                                      % updated Dec 3, 2020 to output CS and Val after MatchGrids
            cd(pathSbS);
            
             copyfile(clistfilename_CS_Val{1},pathSbS);                                                                                                 % updated Dec 3, 2020 to output CS and Val after MatchGrids ( to StepByStep folder )
            sdMGs=ssds(fileparts_name_ext(    clistfilename_CS_Val{1}) );
            inpMGs.corename='After-MatchGrids_T-CS_P-MstVal';
            sdMGs=sdMGs.saveAT(inpMGs);
            %============================
            % copy Mst RawSpectra Before MatchGrids (or MGs), Apr 5, 2021,  there is no Mst XRS in this case
            path_Mst_RS_BefMGs=[find_last_nonTMP_folder,'\TMP_AQP\TMP_AQP-LoadXLSX\Mst'];
            [clistfilename_Mst_RS_BefMGs, nfile_Mst_RS_BefMGs]= fdir_wildcard_wPath( path_Mst_RS_BefMGs,'Atrainpketc');
           if nfile_Mst_RS_BefMGs==1
               copyfile(clistfilename_Mst_RS_BefMGs{1},pathSbS);
           end
           % there is no Mst XRS in this case
           %===============================
           % update following Apr 19, 2021
             filename_Mst_RS_BefMGs_new=  strrep(strrep( fileparts_name_ext(clistfilename_Mst_RS_BefMGs{1} ),'saConc','CS-Before-MatchGrids'),'_CS)',')')   ;              % rename to "CS-Before-MatchGrids", Apr 15, 2021
             movefile( fullfile(pathSbS, fileparts_name_ext(clistfilename_Mst_RS_BefMGs{1} )) ,  fullfile( pathSbS, filename_Mst_RS_BefMGs_new )  );     % rename to "CS-Before-MatchGrids", Apr 15, 2021
            %============================
            
            cd(path_prev);
            
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saDSn='';
    cDSn_tag={inp4XLSX2MAT.DS_type};
elseif isempty(InpBR.path_XLSX)&& ~isempty(InpBR.path_DSn_ParentFolder)
    disp('work on scanning thru multiple datasets');
     inp4XLSX2MAT.DS_type='multiple_DSn_MAT_folders';
    path_prev=pwd;
    cd(InpBR.path_DSn_ParentFolder);
    [clistsubfolder]=get_DSn_AQP;
    clistsubfolder_sortnat=sortnat(clistsubfolder);
    cd(path_prev);
    saDSn=[];
    for isf=1:length(clistsubfolder_sortnat)
        eaDSn.path_CS_Val=[clistsubfolder_sortnat{isf},'\CS_Val'];
        eaDSn.path_CS_XRS=[clistsubfolder_sortnat{isf},'\CS_XRS'];
        eaDSn.pathfname_MGs_PP_XSmst=get_OnlyOne_MAT_wPrefix(clistsubfolder_sortnat{isf},'_XSmst_');
        
        
        eaDSn.pathfname_UDM=get_OnlyOne_MAT_wPrefix(clistsubfolder_sortnat{isf},'_UDM)');
        Ludm=load(eaDSn.pathfname_UDM);
        eaDSn.nsamp_UDM=length(Ludm.saConc);
        saDSn=[saDSn;eaDSn];
    end
    clear Ludm;
    
    cDSn_tag=arrayfun(@(x) ['UDM-',num2str(x.nsamp_UDM)],saDSn,'un',0);

else
    error('not supporting this situation of input data format and type yet')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% move assignment of cCabXfer_scheme to After XLSX2MAT_AQP.m !!! July 24, 2020
try
%     cCabXfer_scheme=InpBR.handles_AQP_gui.cCabXfer_scheme ;  % block this, since cCabXfer_scheme may have been changed inside XLSX2MAT_AQP and that only been updated to inp4AQP
    cCabXfer_scheme=inp4AQP.cCabXfer_scheme ;  % updated July 24, 2020
catch
    cCabXfer_scheme={'woCabXfer','MDC','GLSw[a1e-3]','STDgenize[w7]'};  %  scan three CabXfer schemes
end
% check to make sure cCabXfer_scheme is a cell Not char
if ischar(cCabXfer_scheme)
    error('cCabXfer_scheme can Not be a char')
end
%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% setup items for iXLG -->  % Loop thru XLabel Grids or "iXLG"
try
    
    cUDMas_scheme=InpBR.handles_AQP_gui.cUDMas_scheme ;
%     call_XLabel_Grids=cUDMas_scheme;
catch
    cUDMas_scheme={'woUDM','OpmPLS-ONLY','UDM-ONLY','Split_OddUDM_EvenXRS','Scv','Both_UDM_Opm','UDMasCS'};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch InpBR.handles_AQP_gui.Lines_Xticks_picked
    case 'Lines_DSn--Xticks_UDM'
        %%%%===============%%%%%%%
        cLegendLoop=cDSn_tag;
        call_XLabel_Grids=cUDMas_scheme;
    case 'Lines_PP1--Xticks_UDM'
        cLegendLoop=cPP1;
        call_XLabel_Grids=cUDMas_scheme;
        
     case 'Lines_PP1--Xticks_CabXfer'
         if length(cPP1)>1 && length(cPP2)==1
        cLegendLoop=cPP1;
         elseif length(cPP1)==1 && length(cPP2)>1
          cLegendLoop=cPP2;     
         elseif  length(cPP1)==1 && length(cPP2)==1
           cLegendLoop=cPP1;
         else
             cLegendLoop=cellstr(string(cPP1)+"+"+string(cPP2));
%              error('can not handle this case of cPP1 and cPP2')
         end
         
         if iscell(cCabXfer_scheme)
          call_XLabel_Grids=cCabXfer_scheme;
         else
             error('cCabXfer_scheme Must be a cell !!!')
         end
        
        
    case 'Lines_UDM--Xticks_DSn'
        %%%%===============%%%%%%%
        cLegendLoop=cUDMas_scheme;
        call_XLabel_Grids=cDSn_tag;
        %%%%===============%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if show_wb_yes
    str_hwb= ['running --> ',strrep('AutoQuant_DA_pipeline()','_','\_'),' ... '];
    hwb = waitbar(0,str_hwb );
end

Total_cnt=(length(cLegendLoop)*length(call_XLabel_Grids));
cnt=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% InpBR.handles_gui.AQP_class.String
if iscell( InpBR.handles_gui.AQP_class.String) && strcmp( InpBR.handles_gui.AQP_class.String{ InpBR.handles_gui.AQP_class.Value},'pro')
    N_jLine=length(cLegendLoop);   % AQP(full) version for N_jLine
else
     N_jLine=length(InpBR.handles_gui.cPP1.String);  % AQPlite version for N_jLine
     try
     cLegendLoop=cLegendLoop(1:N_jLine);
     catch
       N_jLine=length(cLegendLoop);  
     end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if iscell(inp4AQP.cDataFlow)
corename4ResultsFile=[cPP1{1},'_',inp4AQP.cDataFlow{1},'_',cCabXfer_scheme{1},'_nLine',num2str(length(cLegendLoop)),'_nXtick',num2str(length(call_XLabel_Grids))];
corename4ResultsFile=strrep(corename4ResultsFile,'{PRO}','(PRO)');   % add this Mar 22, 2023 to avoid using wrapper {} for "PRO" that confused with wrapper for dataset name

% elseif ischar(inp4AQP.cDataFlow)
%  corename4ResultsFile=[cPP1{1},'_',inp4AQP.cDataFlow,'_',cCabXfer_scheme{1},'_nLine',num2str(length(cLegendLoop)),'_nXtick',num2str(length(call_XLabel_Grids))];
%    
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%create tmp folder to store all fname_FinalModel for App Emulator
% if length(call_XLabel_Grids)>1 |  length(cLegendLoop)>1
tmpfolder4AllFinalModels=tmp_folder_rm_mk('Result4FinalModels',find_last_nonTMP_folder);
 inp4AQP.tmpfolder4AllFinalModels=  tmpfolder4AllFinalModels; 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   ALL_OUT_PLS=[];
    
   for kDF=1:length(inp4AQP.cDataFlow)
       
       all_OUT_PLS=[];
       
       inp4AQP.DataFlow= inp4AQP.cDataFlow{kDF};
       
       for jLine=1:N_jLine
           %%%%%%%%%%%%%%%%%%%%%%%
           if length(cPP1)==1 && length(cPP2) > 1
               inp4AQP.PP_methods.pp1=cPP1{1};
               inp4AQP.PP_methods.pp2=cPP2{ jLine};    %  for Scan Thru with cPP2
               
               switch InpBR.handles_AQP_gui.Lines_Xticks_picked
                   
                   case 'Lines_PP1--Xticks_UDM'
                       disp('continue without doing anything for now')
                       
                   case 'Lines_PP1--Xticks_CabXfer'        % Default for AQP        %cCabXfer_scheme
                       disp('continue without doing anything for now')
                       
                   case 'Lines_DSn--Xticks_UDM'
                       %%%%===============%%%%%%%
                       if strcmp(inp4XLSX2MAT.DS_type,'multiple_DSn_MAT_folders')
                           ScanInfoType='saDSn';
                           ScanInfo.data=saDSn;
                           ScanInfo.seq=jLine;
                           ScanInfo.cDataTag=cLegendLoop;
                           inp4AQP=Update_inp4AQP_CurLoop(inp4AQP,ScanInfo,ScanInfoType);
                       else
                           disp('continue wo doing anything')
                       end
                       
                   case 'Lines_UDM--Xticks_DSn'
                       %%%%===============%%%%%%%
                       ScanInfoType='cUDMas_scheme';
                       ScanInfo.data=cUDMas_scheme;
                       ScanInfo.seq=jLine;
                       ScanInfo.cDataTag=cLegendLoop;
                       inp4AQP=Update_inp4AQP_CurLoop(inp4AQP,ScanInfo,ScanInfoType);
                       %%%%===============%%%%%%%
               end
           elseif length(cPP2)==1 && length(cPP1) > 1
               inp4AQP.PP_methods.pp1=cPP1{ jLine};
               inp4AQP.PP_methods.pp2=cPP2{1};
           elseif length(cPP2)==1 && length(cPP1) == 1
               inp4AQP.PP_methods.pp1=cPP1{1};
               inp4AQP.PP_methods.pp2=cPP2{1};
           elseif length(cPP2)>1 && length(cPP1)> 1
%                error('can Not handle this case with cPP1 and cPP2 yes')
                 inp4AQP.PP_methods.pp1=cPP1{ jLine};
               inp4AQP.PP_methods.pp2=cPP2{ jLine};
               
               
           else
               
               error('it should not come to this case ? can Not handle this case with cPP1 and cPP2 yes')
               inp4AQP.PP_methods.pp1=cPP1{jLine}; % this is based on single DS case from xlsx folder
           end
           
           
           %%%%%%%%%%%%%%%%%%%%%%
           
           for iXLG=1:length(call_XLabel_Grids)  % Loop thru Xlabel grids
               cnt=cnt+1;
               %%%%%%%%%%%%%%%%%%%%%%%%%
               if show_wb_yes
                   waitbar(cnt/Total_cnt,hwb,[str_hwb,num2str(cnt),'/',num2str(Total_cnt)]);
               end
               InpBR.handles_AQP_gui.CurStatus.String=['iter-',num2str(cnt),'/',num2str(Total_cnt)];
               %%%%%%%%%%%%%%%%%%%%%%%%
%                inp4savefig.cnt=cnt;
%                copy_all_open_fig_AQP(inp4savefig);
               try
                   cab(InpBR.hf_AQP);
               catch
                   close all;
               end
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %             inp4AQP.ModelOpt.CurUDMas=call_XLabel_Grids(iXLG) ;  % 'woUDM'  'Scv'  'UDM-ONLY'  'OpmPLS-ONLY' 'UDMasCS'        'Split_OddUDM_EvenXRS'  'OpmPLS_AND_Add2CS'
               
               switch InpBR.handles_AQP_gui.Lines_Xticks_picked
                   
                   case {'Lines_DSn--Xticks_UDM','Lines_PP1--Xticks_UDM'}
                       %%%%===============%%%%%%%
                       ScanInfoType='cUDMas_scheme';
                       ScanInfo.data=cUDMas_scheme;
                       ScanInfo.seq=iXLG;
                       ScanInfo.cDataTag=call_XLabel_Grids;
                       inp4AQP=Update_inp4AQP_CurLoop(inp4AQP,ScanInfo,ScanInfoType);
                       
                       %%%%===============%%%%%%%
                   case   'Lines_PP1--Xticks_CabXfer' %cCabXfer_scheme
                       ScanInfoType='cCabXfer_scheme';
                       ScanInfo.data=cCabXfer_scheme;
                       ScanInfo.seq=iXLG;
                       ScanInfo.cDataTag=call_XLabel_Grids;
                       inp4AQP=Update_inp4AQP_CurLoop(inp4AQP,ScanInfo,ScanInfoType);
                       
                   case 'Lines_UDM--Xticks_DSn'
                       
                       if strcmp(inp4XLSX2MAT.DS_type,'multiple_DSn_MAT_folders')
                           %%%%===============%%%%%%%
                           ScanInfoType='saDSn';
                           ScanInfo.data=saDSn;
                           ScanInfo.seq=iXLG;
                           ScanInfo.cDataTag=call_XLabel_Grids;
                           inp4AQP=Update_inp4AQP_CurLoop(inp4AQP,ScanInfo,ScanInfoType);
                       else
                           disp('continue wo doing anything')
                           %                     inp4AQP.DataFlow
                           
                       end
                       %%%%===============%%%%%%%
               end
               
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               if length(cCabXfer_scheme)>=1
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   % for adjusting PlsfactorScan for small sized UDM
                   %                 if ~isempty(saDSn)
                   %                      % for "Load_DSn_ParentFolder" case, Ludm stored inside "inp4AQP"
                   %                     inp4AQP=adjust_PlsfactorScan_AQP('',inp4AQP,PlsfactorScan_default);
                   %                 else
                   %                     % for "Load_XLSX_Folder" case, Ludm stored inside "InpBR"
                   %                     inp4AQP=adjust_PlsfactorScan_AQP(InpBR,'',PlsfactorScan_default);
                   %                 end
                   
                   inp4AQP=adjust_PlsfactorScan_AQP(inp4AQP,InpBR.PlsfactorScan_default);
                   
                   
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %            Main Function                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %
                   if strcmp(InpBR.handles_AQP_gui.Lines_Xticks_picked,'Lines_PP1--Xticks_CabXfer') || strcmp(InpBR.handles_AQP_gui.Lines_Xticks_picked,'Lines_PP1--Xticks_UDM')
                       
                       if isequal(call_XLabel_Grids,cCabXfer_scheme)
                           inp4AQP.handles_gui=InpBR.handles_gui;
                           inp4AQP.PlsfactorScan_default=InpBR.PlsfactorScan_default;
                           
                           inp4AQP.cnt=cnt;  % add this for locating Beta_etc_FinalModel_~.mat files inside PLS_inside_PLS_predict_ONLY_MLtool
                           
                           OUT_Regressor = AutoQuant_DA_pipeline(call_XLabel_Grids(iXLG),inp4AQP);         %    Main Function
                       else
                           error('can not handle this case of call_XLabel_Grids yet')
                       end
                   else
                       inp4AQP.handles_gui=InpBR.handles_gui;
                       inp4AQP.PlsfactorScan_default=InpBR.PlsfactorScan_default;
                       OUT_Regressor = AutoQuant_DA_pipeline(cCabXfer_scheme,inp4AQP);                        %    Main Function
                   end
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               else
                   error('at current setting, it only deal with one cCabXfer_scheme')
               end
               
               warning off
               
               OUT_Regressor.cLegendLoop_jLine=cLegendLoop{jLine};
               OUT_Regressor.CabXfer_scheme=cCabXfer_scheme{iXLG};
               OUT_Regressor.inp4AQP=inp4AQP;
               all_OUT_PLS=[all_OUT_PLS;OUT_Regressor];
               %%%%%%%%%%%%%%%%%
               % save OpmModel's all fig files
               if  Total_cnt>1
                   if cnt==1
                       inp4savefig.cnt=cnt;
                       outsavefig=copy_all_open_fig_AQP(inp4savefig);
                   else
                       all_cnt_RMSEP=cat(1,all_OUT_PLS.Results4RMSEP);
                       [minRMSEP loc_minRP]=min(all_cnt_RMSEP);
                       if loc_minRP==cnt
                           inp4savefig.cnt=cnt;
                           outsavefig=copy_all_open_fig_AQP(inp4savefig);
                       end
                   end
               end
               %%%%%%%%%%%%%%%%%%
               
           end  % end of loop iXLG=1:length(call_XLabel_Grids)  % Loop thru Xlabel grids
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
       end % end of loop jLine
       ALL_OUT_PLS=[ALL_OUT_PLS,all_OUT_PLS];
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  % end of loop kDF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all_OUT_PLS;

rmdir_TMP; % remove all TMP~ folders under pwd

try
close(hwb);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect multiple runs' Results_AQP_~.mat files and use  Cmp_Results_AQP.m to show comparison plot (added July 23, 2020)
OUT=ALL_OUT_PLS;
OUT_cln=rmfield(OUT,'inp4AQP'); %updated July 22, 2020
% =========================================================================
% [ANALYTE STAMP, 22 Aug 2026]  rmfield above drops inp4AQP, which used to
% be the ONLY carrier of the analyte name and the Spectra_Avg method.  That
% was tolerable while the comparison folder name held [AnaName] and
% (CabXfer); now that the folder name is generic (dataset + PP schemes only)
% several analytes can share one folder, so Cmp_Results_AQP needs these two
% straight out of OUT_cln to label the series.  Older .mat files simply do
% not have the fields and fall back to the file name.
% =========================================================================
try
    for iOc=1:numel(OUT_cln)
        OUT_cln(iOc).AnaName=inp4AQP.AnaName{1};
        OUT_cln(iOc).Spectra_Avg_Method=OUT(1).inp4AQP.Spectra_Avg_Method;
    end
end
if length(cPP1)>1
    corename4ResultsFile=find_keyword_between_markers(corename4ResultsFile,'Xfer-PP_','');
end
corename4ResultsFile=strrep(corename4ResultsFile,'woCabXfer','()');
%-------------------------------------------------------------------------------
 corename4ResultsFile=['{',find_lastfolder(InpBR.path_XLSX),'}_',corename4ResultsFile,'_',OUT(1).inp4AQP.Spectra_Avg_Method];
%-------------------------------------------------------------------------------
 corename4ResultsFile=strrep(corename4ResultsFile,'}',['_',inp4AQP.AnaName{1},'}']);
%-------------------------------------------------------------------------------
if ~isempty(strfind(inp4AQP.PP_methods.pp1,'DerSGFL'))
    sBCseq=['_{',inp4AQP.PP_methods.pp2,'-PP2}'];   % capture BCseq into fname_Results_AQP_OUT_cln
else
     sBCseq=['_{',inp4AQP.PP_methods.pp1,'-PP1}'];  % capture BCseq into fname_Results_AQP_OUT_cln
end
corename4ResultsFile=[corename4ResultsFile,sBCseq];
fname_Results_AQP_OUT_cln=['Results_AQP_',corename4ResultsFile,'.mat'];
    fname_Results_AQP_OUT_cln=strrep(fname_Results_AQP_OUT_cln,'(PRO)','');    % updated Apr 3, 2023
    fname_Results_AQP_OUT_cln=strrep(fname_Results_AQP_OUT_cln,'{PRO}','');% updated Apr 3, 2023

save (fname_Results_AQP_OUT_cln, 'OUT_cln');   % collect multiple runs' Results_AQP_~.mat files and use  Cmp_Results_AQP.m to show comparison plot (added July 23, 2020)

Path4OUT_cln_AQP=tmp_folder_rm_mk('Result4OUT_cln_AQP',find_last_nonTMP_folder);
%------------------------------------------------------------------------------------
% revisit this Mar 15, 2023 when bugs wrt Cmp_Results_AQP.m in AQPlite happened
%---------------------
% orig codes
% dsname=find_keyword_between_markers(corename4ResultsFile,'{','}');
% if isempty(dsname)
%    dsname=find_keyword_between_markers(corename4ResultsFile,'','}');
%    if ~isempty(dsname) && strfind(dsname,'{')==1 && isempty(strfind(dsname,'}'))
%        dsname=[dsname,'}'];
%    end
% end
%---------------------
% revisit this Mar 15, 2023 when bugs wrt Cmp_Results_AQP.m in AQPlite happened
%-----------------------------------------------------------------------------
inp4mdcb.keep_curly_yes=0;
corename4ResultsFile=strrep(corename4ResultsFile,'SNV{PRO}','SNV(PRO)');   % add this to fix error associated with SNV{PRO},  Apr 3, 2023
[dsname targetstring_remain out_mdcb]= find_keyword_merge_dual_curly_bracket_w_targetstring_remain(corename4ResultsFile,inp4mdcb);
if exist('out_mdcb','var')&& isfield(out_mdcb,'cb1')&& ~isempty(out_mdcb.cb1)
    dsname=out_mdcb.cb1;
end

dsname=strrep(dsname,['_',inp4AQP.AnaName{1} ],'');  % add this Mar 16, 2023
%-------------
if isempty(dsname)
    dsname=find_keyword_between_markers(corename4ResultsFile,'','}');
    if ~isempty(dsname) && strfind(dsname,'{')==1 && isempty(strfind(dsname,'}'))
        dsname=[dsname,'}'];
    end
end
%---------------------------------------------------------------------------------------
try
PPn_xlsx_name=strrep(strrep(fileparts_name_wo_ext(inp4AQP.pathfname_PPn_xlsx),'pp1_pp2',''),'PP1_PP2','');
catch
 PPn_xlsx_name   =['_',cPP1{1},'+',cPP2{1}];
end
if length(inp4AQP.cCabXfer_scheme)==1
    name_CabXfer_scheme=['(',inp4AQP.cCabXfer_scheme{1},')'];
else
    name_CabXfer_scheme='';
end

name_AnaName=['[',inp4AQP.AnaName{1},']'];

name_CabXfer_scheme_cln=strrep(name_CabXfer_scheme,'woCabXfer','');
PPn_xlsx_name_cln=strrep(PPn_xlsx_name,'{PRO}+SNV{PRO}','+SNV_PRO');
% =========================================================================
% [GENERIC FOLDER NAME, 22 Aug 2026]
% The comparison folder now carries ONLY the dataset name and the PP1_PP2
% scheme name.  It used to carry [AnaName] and (CabXfer_scheme) too, which
% sent a woCabXfer run and an MDC run of the same dataset into two DIFFERENT
% folders - so Compare Results could never see them together:
%     Brix_wVal_&_XRS[Brix]()_4schemes_AQP_1st_2ndDer
%     Brix_wVal_&_XRS[Brix](MDC)_4schemes_AQP_1st_2ndDer
% both now land in
%     Brix_wVal_&_XRS_4schemes_AQP_1st_2ndDer
% Nothing is lost: the analyte and the CabXfer scheme are still in the
% Results_AQP_~.mat FILE name and inside OUT_cln, which is what
% Cmp_Results_AQP builds its legend from - so the two runs keep distinct
% file names and neither overwrites the other.
% Set either flag back to 1 to restore the old, more segregated folders.
% =========================================================================
NEWDIR_include_AnaName_yes=0;      % [GENERIC FOLDER NAME]
NEWDIR_include_CabXfer_yes=0;      % [GENERIC FOLDER NAME]
if NEWDIR_include_AnaName_yes
    sNDir_Ana=name_AnaName;
else
    sNDir_Ana='';
end
if NEWDIR_include_CabXfer_yes
    sNDir_Xfer=name_CabXfer_scheme_cln;
else
    sNDir_Xfer='';
end
 NEWDIR4OUT_cln_AQP=[dsname,sNDir_Ana,sNDir_Xfer,PPn_xlsx_name_cln];
% NEWDIR4OUT_cln_AQP=[dsname,name_AnaName,name_CabXfer_scheme_cln,PPn_xlsx_name_cln];   % [GENERIC FOLDER NAME] pre-22-Aug-2026
% NEWDIR4OUT_cln_AQP=[dsname,name_CabXfer_scheme,PPn_xlsx_name];
%----------------------------

%------------------------------
[SUCCESS,MESSAGE,MESSAGEID] = mkdir(Path4OUT_cln_AQP,NEWDIR4OUT_cln_AQP);
if SUCCESS
    Path4OUT_cln_AQP_FinalSubfolder=[Path4OUT_cln_AQP,'\',NEWDIR4OUT_cln_AQP];

    % =====================================================================
    % [XTICK GUARD, 22 Aug 2026]
    % Before this run's Results_AQP_~.mat is dropped into the comparison
    % folder, check that it carries the SAME x-axis entries (the
    % cLegendLoop_jLine list - typically the PP1+PP2 preprocessing schemes)
    % as whatever is already sitting there.  A folder that mixes two
    % different scheme lists makes the Compare Results plot meaningless, so
    % the mismatch is caught here instead of showing up as a half-empty
    % scatter later on.
    %   policy 'divert'      (default) keep the file, but store it in
    %                        <FinalSubfolder>_XTickSet2 / _XTickSet3 / ...
    %          'ask'         put the choice to the user (questdlg)
    %          'save-anyway' old behaviour - store it regardless
    %          'skip'        do not store it at all
    % see also: CmpR_check_XTick_before_store  Cmp_Results_AQP
    % =====================================================================
    inp4XTck.policy='divert';
    out_XTck=CmpR_check_XTick_before_store(Path4OUT_cln_AQP_FinalSubfolder, ...
        CmpR_xtick_from_OUT_cln(OUT_cln),inp4XTck);
    Path4OUT_cln_AQP_FinalSubfolder=out_XTck.dest_folder;   % may have been diverted
    % =====================================================================

  if out_XTck.save_yes                                      % [XTICK GUARD]
%     fname_Results_AQP_OUT_cln=strrep(fname_Results_AQP_OUT_cln,'(PRO)','');    % updated Apr 3, 2023
%     fname_Results_AQP_OUT_cln=strrep(fname_Results_AQP_OUT_cln,'{PRO}','');% updated Apr 3, 2023

    pfn_RAOc=fullfile(Path4OUT_cln_AQP_FinalSubfolder,fname_Results_AQP_OUT_cln);
    
    out_long_yes=is_too_long_pfn(pfn_RAOc);
    
   % sometime the combined path+fname --> Path4OUT_cln_AQP_FinalSubfolder + fname_Results_AQP_OUT_cln  --> can be too long, Nov 22, 2020
    
    if ~out_long_yes
        copyfile(fname_Results_AQP_OUT_cln,Path4OUT_cln_AQP_FinalSubfolder);  % collect multiple runs' Results_AQP_~.mat files and use  Cmp_Results_AQP.m to show comparison plot (added July 23, 2020)
    else
        warndlg(['Results_AQP_OUT_cln has too long pathfname -->'  num2str(length(fullfile(Path4OUT_cln_AQP_FinalSubfolder,fname_Results_AQP_OUT_cln)))]);
        [ fname_Results_AQP_OUT_cln_CB  fname_Results_AQP_OUT_cln_remain]=find_keyword_merge_dual_curly_bracket_w_targetstring_remain(fname_Results_AQP_OUT_cln);
        pfn_RAOc_1=fullfile(Path4OUT_cln_AQP_FinalSubfolder,fname_Results_AQP_OUT_cln_remain);
        out_long_yes_1=is_too_long_pfn(pfn_RAOc_1);
        if ~out_long_yes_1
            movefile(fname_Results_AQP_OUT_cln,fname_Results_AQP_OUT_cln_remain);
            copyfile(fname_Results_AQP_OUT_cln_remain,Path4OUT_cln_AQP_FinalSubfolder);  % collect multiple runs' Results_AQP_~.mat files and use  Cmp_Results_AQP.m to show comparison plot (added July 23, 2020)
            warndlg([ fname_Results_AQP_OUT_cln_remain,' saved' ]);
            
        else
            warndlg(['Results_AQP_OUT_cln STILL has too long pathfname -->'  num2str(length(fullfile(Path4OUT_cln_AQP_FinalSubfolder,fname_Results_AQP_OUT_cln_remain)))]);
            fname_Results_AQP_OUT_cln_shortest=['Results_',find_keyword_between_markers(get_snow_short,'','-'),'.mat'];
            pfn_RAOc_2=fullfile(Path4OUT_cln_AQP_FinalSubfolder,fname_Results_AQP_OUT_cln_shortest);
            out_long_yes_2=is_too_long_pfn(pfn_RAOc_2);
            if  ~out_long_yes_2
                movefile(fname_Results_AQP_OUT_cln, fname_Results_AQP_OUT_cln_shortest);
                copyfile(fname_Results_AQP_OUT_cln_shortest,Path4OUT_cln_AQP_FinalSubfolder);
                warndlg(['Results_AQP_OUT_cln saved as --> ' , fname_Results_AQP_OUT_cln_shortest ]);
            else
                warndlg(['Results_AQP_OUT_cln NOT saved' ]);
            end
        end
    end
  else                                                      % [XTICK GUARD]
    disp('[XTick guard] Results_AQP_OUT_cln was NOT copied into the comparison folder');
  end                                                       % [XTICK GUARD]
    %%%%%%%%%%%%%%
    OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder=Path4OUT_cln_AQP_FinalSubfolder;
    OUT_Cmp_Results.fname_Results_AQP_OUT_cln=fname_Results_AQP_OUT_cln;
else
    OUT_Cmp_Results.Path4OUT_cln_AQP_FinalSubfolder=[];
    OUT_Cmp_Results.fname_Results_AQP_OUT_cln=[];
    
end        % end of if SUCCESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% path_FinalModels='C:\work\JDSU\Test_AQP\Result4FinalModels'
% find OpmModel_Beta_etc_FinalModel by running AQP_App_Emulator.m
try
    inpAE.cCabXfer_scheme=cCabXfer_scheme;
    outOpmFM= AQP_App_Emulator(tmpfolder4AllFinalModels,inpAE);
    if isempty(outOpmFM.seq.CabXfer)
        try
            outOpmFM.seq.CabXfer=cCabXfer_scheme{1};%updated Aug 24, 2020
        end
    end
catch
    outOpmFM='';
end
 %%%%%%%%%%%%%%%%
 % run json_AQP_OpmModel_Sequence to prepare beta etc in json format
 if ~isempty(outOpmFM)
     inp4OFM.fullpath_yes=1;
     [clistfilename_out_Opm, nfile_out_Opm]=fdir_wPrefix_wPath([find_last_nonTMP_path,'\Result4FinalModels'],'mat',0,'OpmModel_Beta_etc_FinalModel_', inp4OFM);
     if nfile_out_Opm==1
         pathfname_OpmModel=clistfilename_out_Opm{1};
         try
         out_json=json_AQP_OpmModel_Sequence(pathfname_OpmModel);
         end
%           if  Total_cnt>1
%          Speak_mk('Optimal Model created in json format');
%           end
         %%%%%%%%%%%%%%%%%%%
         if  Total_cnt>1
             inp4showOFMfig=outsavefig;
             out_SOMfig=show_OpmModel_figs(inp4showOFMfig);
             hOMfig=get(out_SOMfig.fignum_OpmModel_45deg);
         end
         %%%%%%%%%%%%%%%%%%
     end
     
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot RMSEP summary for scan thru CabXfer_scheme or PP methods or Datasets etc
Cur_AQP_class=get_curAQP_class(InpBR.handles_gui);
if strcmp(Cur_AQP_class,'pro') && ~isempty(outOpmFM) && Total_cnt > 1
    %%%%%%%%%%%%%%%%%%%%%%%%%
    set(groot,'defaultLineLineWidth',2);

    figure;hold on;
    for kDF=1:length(inp4AQP.cDataFlow)
        
        all_OUT_PLS=ALL_OUT_PLS(:,kDF);
        for jLine=1:length(cLegendLoop)
            %idx_PPj=arrayfun(@(x) strcmp(x.PP1,cLegendLoop{jLine}),all_OUT_PLS);
            idx_PPj=arrayfun(@(x) strcmp(x.cLegendLoop_jLine,cLegendLoop{jLine}),all_OUT_PLS);
            
            %  allRMSE_PPj=arrayfun(@(x) str2num(x.Results4sRMSE_Val),all_OUT_PLS(idx_PPj));
            allRMSE_PPj=arrayfun(@(x) x.Results4RMSEP,all_OUT_PLS(idx_PPj));  % based on "Results4RMSEP" generated inside --> SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool(pathfnameTP,inp)
            
            if length(call_XLabel_Grids)==1 && length(cLegendLoop)>1
                plot(jLine,allRMSE_PPj,'color',color_CH(scolor_PP(jLine)),'marker',marker_CH(smarker_PP(jLine)),'linewidth',2,'markersize',12);
            else
                %         plot(allRMSE_PPj,'color',color_CH(scolor_PP(jLine)),'marker',smarker_DF(kDF),'linewidth',2,'markersize',12);
                plot(allRMSE_PPj,'color',color_CH(scolor_PP(jLine)),'marker',marker_CH(smarker_PP(jLine)),'linewidth',2,'markersize',12);
            end
        end
        
    end
    clegend=[];
    for kDF=1:length(inp4AQP.cDataFlow)
        inp4AQP.DataFlow= inp4AQP.cDataFlow{kDF};
        if ischar(inp4AQP.DataFlow)
            clegend_kDF=cellstr(string(cLegendLoop)+'  '+inp4AQP.DataFlow);
            %         legend(clegend);
            clegend=[clegend,clegend_kDF];
        else
            legend(cLegendLoop); %inp4AQP.DataFlow
        end
        
    end
    legend(strrep(clegend,'_','\_'));
    
    % =====================================================================
    % [XTICKLABEL, 22 Aug 2026]  set_XTickLabel has forced
    % TickLabelInterpreter='none' since Apr 2024, so the tex escapes prepared
    % here were being printed VERBATIM - that is where
    %     1stDerSGFL7[PO2]\newlineSNV
    % on the RMSEP summary plot came from.  CmpR_set_XTickLabel_wrap escapes
    % the tex-special characters itself and then uses tex + \newline, so the
    % labels wrap onto two lines again AND '_' / '{PRO}' print as themselves.
    % Pass the RAW labels - no strrep here any more.
    % =====================================================================
    if length(call_XLabel_Grids)==1 && length(cLegendLoop)>1
%         rotate_xticklabel_anydeg(strrep(cLegendLoop,'_','\_'),-45,8);
        inp4XTL.wrap_yes=1;
        CmpR_set_XTickLabel_wrap(gca,cLegendLoop,-45,8,inp4XTL);
        stit_call_XLabel_Grids=call_XLabel_Grids{1};
    else
%         rotate_xticklabel_anydeg(strrep(call_XLabel_Grids,'_','\_'),-45,10);
        inp4XTL.wrap_yes=0;
        CmpR_set_XTickLabel_wrap(gca,call_XLabel_Grids,-45,10,inp4XTL);
        stit_call_XLabel_Grids='';
    end
    
    ylabel('RMSEP')
    
    % stit=strrep(find_keyword_between_markers( find_lastNfolder(  InpBR.path_CS_Val,2),'','\'),'_','\_');
    try
        stit=strrep(find_keyword_between_markers( find_lastNfolder(  InpBR.pathfname_UDM,3),'','\'),'_','\_');
    catch
        try
            stit=strrep(find_keyword_between_markers( find_lastNfolder(  InpBR.path_CS_Val,2),'','\'),'_','\_');
        catch
            stit=strrep( find_lastNfolder(  InpBR.path_XLSX,1),'_','\_');
        end
    end
    
    if length(cPP1)==1
        sPP1=['PP1-',cPP1{1}];
    else
        sPP1=['PP1-',cPP1{end}];
    end
    %%%%%%%%%%%%%%%%%%%%%%
    % plot Opm FinalModel on RMSEP Summary figure only when more than one "OUT=ALL_OUT_PLS" were generated
    %
    if length(OUT)>1
        sia_fdnOFM=string(row_always(fieldnames(outOpmFM.seq)));
        if isempty(outOpmFM.seq.CabXfer)
            outOpmFM.seq.CabXfer='';            % very tricky, it only works for ''  not for []     !!!
        end
        try
            sia_ContentOFM=string(row_always(struct2cell(outOpmFM.seq)));%updated Aug 24, 2020 to deal with struct2cell handling of {PRO}
        catch
            
            error('if bugs related to dealing with outOpmFM.seq.CabXfer=[] wrt struct2cell fixed, then supposedly should Not come to here')
            %updated Aug 24, 2020 to deal with struct2cell handling of {PRO}
            outOpmFM.seq.PP1=strrep(strrep(outOpmFM.seq.PP1,'{','_'),'}','');
            outOpmFM.seq.PP2=strrep(strrep(outOpmFM.seq.PP2,'{','_'),'}','');
            if isempty(outOpmFM.seq.CabXfer)
%                 outOpmFM.seq.CabXfer='Empty';
%             else
%                 outOpmFM.seq.CabXfer='Unknown';
            outOpmFM.seq.CabXfer='';            % very tricky, it only works for ''  not for []     !!!
            end
            sia_ContentOFM=string(  row_always(struct2cell(outOpmFM.seq))  );%updated Aug 24, 2020 to deal with struct2cell handling of {PRO}
        
        
        end
        sOpmSeq=['Opm Seq : ',strwrite_all_delimiter(cellstr(sia_fdnOFM+"-"+sia_ContentOFM),'\_')];  % Seq in OpmFM
        if length(call_XLabel_Grids)==1
            loc_x_axis_OFM=find(strcmp(cLegendLoop,outOpmFM.seq.PP1));
            if isempty(loc_x_axis_OFM)
                loc_x_axis_OFM=find(strcmp(cLegendLoop,outOpmFM.seq.PP2));  % if can not find in PP1 then scan thru should be based on PP2
            end
        else
            loc_x_axis_OFM=find(strcmp(call_XLabel_Grids,outOpmFM.seq.CabXfer));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % deal with PP1 and PP2 come from PP1_PP2_xlsx
        if isempty( loc_x_axis_OFM)
%             OMfig_tit1 =   strrep( strrep( hOMfig.CurrentAxes.Title.String{1}, name_AnaName(2:end-1) ,'') ,' ','') ;
%             if isempty( OMfig_tit1)
%                   OMfig_tit1 =   strrep( strrep( hOMfig.CurrentAxes.Title.String{3}, name_AnaName(2:end-1) ,'') ,' ','') ;
%             end
%--------------------------------------------------------------------------------------------------------
           % modified Mar 9, 2023 that will get OMfig_tit1 (later used for sOpmSeq ) from outOpmFM
           %
           OMfig_tit1 = [outOpmFM.seq.PP1,'+',outOpmFM.seq.PP2] ;
%--------------------------------------------------------------------------------------------------------
            
            %             loc_x_axis_OFM=find(   strcmp(    cellstr(sia_ContentOFM(1)+"+"+sia_ContentOFM(2))  ,  cLegendLoop)   );
           %----------------------------------------------------------------------------------------------------------------- 
           % modify Mar 8, 2023 that will get OMfig_tit3_RMSE from outOpmFM.RMSEP_Opm
           
%           if ~strcmp(  cellstr(sia_ContentOFM(1)+"+"+sia_ContentOFM(2)) , {OMfig_tit1} )
%               warning('Opm Model''s PP scheme based on sia_ContentOFM is different from OMfig_tit1 ?');
%               Speak_mk('Opm Model''s PP scheme based on sia_ContentOFM is different from OMfig_tit1 ?');
%               disp_with_border('will use results from OMfig_tit1 and continue');
%                 OMfig_tit3_RMSE = str2num( find_keyword_between_markers(  hOMfig.CurrentAxes.Title.String{3},'RMSE =' ,'STD') ) ;
%           else
%               
%               OMfig_tit3_RMSE=outOpmFM.RMSEP_Opm;
%           end
            
          OMfig_tit3_RMSE=outOpmFM.RMSEP_Opm;   % modify Mar 8, 2023 that will get OMfig_tit3_RMSE from outOpmFM.RMSEP_Opm
           %----------------------------------------------------------------------------------------------------------------- 
          
          
          
            loc_x_axis_OFM=find(   strcmp(OMfig_tit1 ,  cLegendLoop) )  ;
          
            
            sOpmSeq=['Opm Seq : ',OMfig_tit1];  % Opm_PP_scheme by OMfig_tit1 i.e. Opm Model's 45deg plot's 1st line in its title, Feb 25, 2023
            
        end
        %updated Aug 24, 2020
         if isempty( loc_x_axis_OFM)
        cLegendLoop_alt=strrep(cLegendLoop,'{PRO}','_PRO');%updated Aug 24, 2020
         loc_x_axis_OFM=find(   strcmp(cellstr(sia_ContentOFM(1)+"+"+sia_ContentOFM(2)),cLegendLoop_alt));
         end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         plot(loc_x_axis_OFM,outOpmFM.RMSEP_Opm,'color',color_CH('o'),'marker',marker_CH('h'),'markersize',15);
                plot(loc_x_axis_OFM,OMfig_tit3_RMSE,'color',color_CH('o'),'marker',marker_CH('h'),'markersize',15);
%         legend(strrep([clegend;['Opm Final Model',' RMSEP=',roundns(outOpmFM.RMSEP_Opm,3)]],'_','\_'));
                legend(strrep([clegend;['Opm Final Model',' RMSEP=',roundns(OMfig_tit3_RMSE,3)]],'_','\_'));

    else
        sOpmSeq='';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % sOpmSeq
    if length(cPP2)==1
        if ~strcmp(inp4AQP.PP_methods.pp2,'SNV')
            sPP2_alt=['   PP2-', inp4AQP.PP_methods.pp2];
            sOpmSeq   = strrep( sOpmSeq,'\_CabXfer',['\_PP2-', inp4AQP.PP_methods.pp2,'\_CabXfer']);
        else
            sPP2_alt='';
        end
    else
        sPP2_alt='';
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    if length(cCabXfer_scheme)==1
        stit2=[strrep(OUT(1).inp4AQP.Spectra_Avg_Method,'_','\_'),sPP2_alt];
        stit2=strrep( stit2,'Spectra\_Avg\_','Spectra-');    % updated July 24, 2020
        title({[sPP1,'  ',stit,'    Xfer scheme -->',strrep(cCabXfer_scheme{1},'_','\_'),'  ', stit_call_XLabel_Grids ];stit2;sOpmSeq})
    else
        try
            title({[sPP1,'  ',stit,'    UDM as -->',strrep(inp4AQP.ModelOpt.CurUDMas{1},'_','\_'),'   ',strrep(inp4AQP.ModelOpt.CurTcvModelParaOpmScheme,'_','\_')];[strrep(OUT(1).inp4AQP.Spectra_Avg_Method,'_','\_'),sPP2_alt];sOpmSeq})
        catch
            title({[sPP1,'  ',stit,'    UDM as -->',strrep(inp4AQP.ModelOpt.CurUDMas,'_','\_'),'   ',strrep(inp4AQP.ModelOpt.CurTcvModelParaOpmScheme,'_','\_')];[strrep(OUT(1).inp4AQP.Spectra_Avg_Method,'_','\_'),sPP2_alt];sOpmSeq})
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    set(groot,'defaultLineLineWidth',0.5);
    
warning off

end  % end of if strcmp(Cur_AQP_class,'pro')
end


%% ----- Update_inp4AQP_CurLoop   [AQP_gui.m lines 5957-6003] ------------------------------------
function inp4AQP=Update_inp4AQP_CurLoop(inp4AQP,ScanInfo,ScanInfoType)

%         if length(cPP1)==1 && length(cLegendLoop)==length(cDSn_tag)


switch ScanInfoType
    
    case 'saDSn'
%         ScanInfo.data=saDSn;
%         ScanInfo.seq=jLine;
%         ScanInfo.cLoop=cLegendLoop;
        
        if  length(ScanInfo.data)==length(ScanInfo.cDataTag)
            
            %             inp4AQP.PP_methods.pp1=cPP1{1};
            inp4AQP.path_CS_Val=ScanInfo.data(ScanInfo.seq).path_CS_Val;
            inp4AQP.path_CS_XRS=ScanInfo.data(ScanInfo.seq).path_CS_XRS;
            inp4AQP.pathfname_MGs_PP_XSmst=ScanInfo.data(ScanInfo.seq).pathfname_MGs_PP_XSmst;
            inp4AQP.pathfname_UDM=ScanInfo.data(ScanInfo.seq).pathfname_UDM;
        else
            % inp4AQP.PP_methods.pp1=cPP1{jLine}; % this is based on single DS case from xlsx folder
            error('mismatch between size of cLegendLoop vs cDSn_tag')
        end
    case 'cUDMas_scheme'
        if  length(ScanInfo.data)==length(ScanInfo.cDataTag)
            inp4AQP.ModelOpt.CurUDMas=ScanInfo.data(ScanInfo.seq) ;
        else
            error(['mismatch between size of ScanInfo.data vs ScanInfo.cDataTag in ',ScanInfoType])
        end
    
    case   'cCabXfer_scheme'   
        disp('work on Update_inp4AQP_CurLoop with "cCabXfer_scheme"')
        if  length(ScanInfo.data)==length(ScanInfo.cDataTag)
            %inp4AQP.ModelOpt.CurUDMas={'woUDM'} ; % hard-coded to 'woUDM' July 16, 2019
            inp4AQP.ModelOpt.CurUDMas=inp4AQP.cUDMas_scheme;
        else
            error(['mismatch between size of ScanInfo.data vs ScanInfo.cDataTag in ',ScanInfoType])
        end
        
        
        
        
    otherwise
        error(['ScanInfoType --> ',ScanInfoType,' Not supported yet'])
        
end
end


%% ----- BatchRun_CabXfer_Siesler48_MLtool   [AQP_gui.m lines 6447-6558] -------------------------
function OUT_Xfer=BatchRun_CabXfer_Siesler48_MLtool(path_CabX,INP)
% modified from BatchRun_CabXfer_Siesler48 to be used in CabXferLite()
% this function has been called by AutoQuant_DA_pipeline
% this function will call CabXfer_Siesler48_MLtool(pfT,inp,INP)
% % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
%---------------------------------------------------------------------------------
% block following, Mar 9, 2023
%---------------------------------------------------------------------------------

if false
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run --> mA or mB to mC Protein in IDRC shootout
   % for Caffeine
   close all; clear;
   %              path_CabX='C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mA_mB_P-mC_Test'
   
%    path_CabX='C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mA_P-mC_Test'
%    INP.pathfnameTP4Val='C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mA_P-mC_Val\Atrainpketc_saConc_IDRC_{T-ManufacturerA_Cal_CalSetA123_P-mC_Val_pp1-1stDerSGw13}_nvar88_nsampTT744_nsampP150.mat'
      path_CabX='C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mB_P-mC_Test'
      
   INP.pathfnameTP4Val='C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mB_P-mC_Val\Atrainpketc_saConc_IDRC_{T-ManufacturerB_Cal_CalSetB123_P-mC_Val_pp1-1stDerSGw13}_nvar88_nsampTT744_nsampP150.mat'

   
   %   INP.cCabXfer_scheme={'GLSstd2[alpha1e-3]','GLSstd2[alpha1e-6]','STDgenize[win5]','woCabXfer'};
%    INP.cCabXfer_scheme={'STDgenize[win5]','LS-PDS','LS-GLSw[a1e-3]','GLSstd2[alpha1e-6]','woCabXfer'}; % Note that GLSstd2 is based on LS already !!!
     INP.cCabXfer_scheme={'LS-GLSw[a1e-3]','GLSstd2[alpha1e-6]','woCabXfer'}; % Note that GLSstd2 is based on LS already !!!

   
   INP.cXM_Slct_scheme={'KS101'};INP.TP_includeTrn_Yes=1; % only for testing
   BatchRun_CabXfer_Siesler48_MLtool(path_CabX,INP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% use IDRC with Benoit Ref values of Val set for CabXfer Matlab Tool
   close all; clear;
      path_CabX='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\T-mA_P-mC_Test_Clean'
   INP.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\T-mA_P-mC_Val_CleanBI\Atrainpketc_saConc_IDRC_{T-mA_P-mC_Val_CleanBI_pp1-1stDerSGw13}_pp2-SampMncn_nvar88_nsampTT744_nsampP134.mat'
   
%    INP.cCabXfer_scheme={'STDgenize[win5]','LS-PDS','LS-GLSw[a1e-3]','GLSstd2[alpha1e-6]','woCabXfer'}; % Note that GLSstd2 is based on LS already !!!
      % INP.cCabXfer_scheme={'PDS','woCabXfer'}; % Note that GLSstd2 is based on LS already !!!
      INP.cCabXfer_scheme={'LS','LS-PDS','LS-GLSw[a1e-3]','woCabXfer'}; % Note that GLSstd2 is based on LS already !!!
 
%       INP.cCabXfer_scheme={'LS-OSC','OSC','woCabXfer'}; % Note that GLSstd2 is based on LS already !!!

   INP.cXM_Slct_scheme={'KS101'};INP.TP_includeTrn_Yes=1; % only for testing
   BatchRun_CabXfer_Siesler48_MLtool(path_CabX,INP)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add to path to access GLSw etc
% addpath_wo_attic('C:\work\PLS_toolbox_2014\PLS_Toolbox_792');
% addpath('C:\work\Mfiles\all_Mfile_xLAN\matlab_toolbox\attic_PLS_Toolbox')
%%%%%%%%%%%%%%%%%%
pwd_orig=pwd;

if isfield(INP,'newpath_TMP_Cabxfer')
    sTMPpath=tmp_folder_rm_mk(INP.newpath_TMP_Cabxfer,pwd);
else
    sTMPpath=tmp_folder_rm_mk('TMP_Cabxfer',pwd);
end


% cd(sTMPpath);
if ~isempty(path_CabX)
    [clistfilename_out, nfile]=fdir_wildcard_ext_wPath(path_CabX,'Atrainpketc_','mat');
else
    clistfilename_out='';
    nfile  =0;
%============================================================================================================    
% block following, Mar 9, 2023
%     try
%         if ~isempty(INP.clistfilename_CS_Val_MatchGrids)
%             clistfilename_out={INP.clistfilename_CS_Val_MatchGrids};         % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
%             nfile=1;
%             %--------------------------------------------
%             %hard-code following, Mar 8, 2023
%             nfile=0;
%             %----------------------------------------------
%         end
%     end
%============================================================================================================    

end
for  iKS=1:length(INP.cXM_Slct_scheme)
    
    for ifile=1:nfile
%         close all
        pfTP= clistfilename_out{ifile};
        %     inp.cCabXfer_scheme=INP.cCabXfer_scheme;
        %         inp.cCabXfer_scheme=INP.cCabXfer_scheme;
        inp=INP;
        inp.XM_Slct_scheme=INP.cXM_Slct_scheme{iKS};
        inp.sTMPpath=sTMPpath;
       outXfer= CabXfer_Siesler48_MLtool(pfTP,inp,INP);
        
    end
end
cd(pwd_orig);

try
OUT_Xfer=outXfer;
catch
OUT_Xfer='';    
end


disp('finish BatchRun_CabXfer_Siesler48_MLtool')
end


%% ----- BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix   [AQP_gui.m lines 6562-6825] -------
function [allh,allp,out] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp )
% main function to call --> test_Mahal_Rolling_PCA_Random_covariance_matrix
% see also: test_Mahal_Rolling_PCA_Random_covariance_matrix
%======================================================================================
if false
    
    
       cc
    inp.fig_yes=1;
    dev_X1=0;
    inp.Nrun=10;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    
    %-----------------------------------------------------------------------------------------
    
      cc
    inp.fig_yes=1;
    dev_X1=0.5;
    inp.Nrun=10;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    
    %-----------------------------------------------------------------------------------------
    cc
    inp.fig_yes=0;
    dev_X1=1;
    inp.Nrun=100000;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      %-----------------------------------------------------------------------------------------
    cc
    inp.fig_yes=0;
    dev_X1=1.5;
    inp.Nrun=10000;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
        %-----------------------------------------------------------------------------------------
    cc
    inp.fig_yes=0;
    dev_X1=1.46;
    inp.Nrun=200000;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    %-----------------------------------------------------------------------------------------
    % this will show p_value ~ 0.05 for bz=30
    cc
     inp.nD=3;    % test 3D !!!
    inp.fig_yes=0;
    dev_X1=1.33;           % this will show p_value ~ 0.05 for bz=30
    inp.Nrun=100000;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      %-----------------------------------------------------------------------------------------
    % this will show p_value ~ 0.05 for bz=10
    cc
    inp.nD=3;    % test 3D !!!
    inp.fig_yes=0;
    dev_X1=1.74;            % this will show p_value ~ 0.05 for bz=10
    inp.Nrun=100000;
    bz=10;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
       %-----------------------------------------------------------------------------------------
     % this will show p_value ~ 0.05 for bz=20
    cc
     inp.nD=3;    % test 3D !!!
    inp.fig_yes=0;
    dev_X1=1.44;            % this will show p_value ~ 0.05 for bz=20
    inp.Nrun=100000;
    bz=20;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    %-----------------------------------------------------------------------------------------
    cc
    inp.fig_yes=0;
    dev_X1=2;
    inp.Nrun=100000;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    
    %---------------------------------------------------------------------------------
    
    cc
    inp.fig_yes=1;
    dev_X1=3;
    inp.Nrun=10;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    %---------------------------------------------------------------------------------
    
    cc
    inp.fig_yes=1;
    dev_X1=6;
    inp.Nrun=10;
    bz=300;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    
    %-----------------------------------------------------------------------------------------
    %-----------------------------------------------------------------------------------------
    % move X1 to left
     cc
    inp.fig_yes=1;
    dev_X1=-0.5;
    inp.Nrun=10;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    
    %-----------------------------------------------------------------------------------------
    %-----------------------------------------------------------------------------------------
     % test running ttest2 on MD2 directly
      cc
    inp.fig_yes=0;
    dev_X1=1.33;           % this will show p_value ~ 0.05 for bz=30
    inp.Nrun=100000;
    bz=30;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      %-----------------------------------------------------------------------------------------
      %-----------------------------------------------------------------------------------------
     % test running ttest2 on MD2 directly
      cc
    inp.fig_yes=0;
    dev_X1=1.74;           % this will show p_value ~ 0.05 for bz=10
    inp.Nrun=100000;
    bz=10;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      %----------------------------------------------------------------------------------------- 
      %-----------------------------------------------------------------------------------------
     % test running ttest2 on MD2 directly
      cc
    inp.fig_yes=0;
    dev_X1=1.44;           % this will show p_value ~ 0.05 for bz=10
    inp.Nrun=100000;
    bz=20;
    [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      %-----------------------------------------------------------------------------------------  
      %===================================================================
      % study effects of size of samples or bz on MD and related
      cc
      inp.fig_yes=1;
      dev_X1=1;           % this will show p_value ~ 0.05 for bz=10
      inp.Nrun=10;
      bz=10;
      [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      %===================================================================
      % study current settings in rPCA with ttest approach
      cc
      inp.fig_yes=0;
      dev_X1=1.33;           % this will show p_value ~ 0.05 for bz=30
      inp.Nrun=10000;
      bz=30;
      [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      
      %-----------------------------------------------------------------------------------------
      % study current settings in rPCA with ttest approach
       cc
      inp.fig_yes=0;
      %dev_X1=0.975;        % study current settings in rPCA with ttest approach   % this will show p_value ~ 0.05 for bz=30
            dev_X1=1;        % study current settings in rPCA with ttest approach   % this will show p_value ~ 0.05 for bz=30
      inp.Nrun=100000;
      bz=30;
      inp.rand_cov_yes=0;
      [allh,allp] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
      %===================================================================
end

%===================================

%----------------------------------------------------
try
    nD=inp.nD;
catch
    nD=2;
end
try
 rand_cov_yes  = inp.rand_cov_yes;
catch
  rand_cov_yes=1;  
end


%====================================================

allh=[];
allp=[];
allh_alt=[];
allp_alt=[];

all_mean_sqrt_MD2_X1=[];
all_mean_sqrt_MD2_X=[];
all_mean_sqrt_MD2_XP_in_range=[];
for irun=1:inp.Nrun
    close all
    [h,p , mean_sqrt_MD2_X1 , mean_sqrt_MD2_X ,h_alt,p_alt,out_irun ] = test_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    allh=[allh;h  ];
    allp=[allp;p];
    all_mean_sqrt_MD2_X1=[all_mean_sqrt_MD2_X1; mean_sqrt_MD2_X1];
    all_mean_sqrt_MD2_X=[all_mean_sqrt_MD2_X; mean_sqrt_MD2_X];
    allh_alt=[allh_alt;h_alt  ];
    allp_alt=[allp_alt;p_alt];
    %----------------------------------------------
   all_mean_sqrt_MD2_XP_in_range=[all_mean_sqrt_MD2_XP_in_range; out_irun.mean_sqrt_MD2_XP ]; % study current settings in rPCA with ttest approach
end
%----------------------------------------------------
avg_sqrt_MD2_X1=mean(all_mean_sqrt_MD2_X1);
avg_sqrt_MD2_X=mean(all_mean_sqrt_MD2_X);
%------------------------------------------------------
% study current settings in rPCA with ttest approach
MD_XP_in_range=all_mean_sqrt_MD2_XP_in_range(~isnan(all_mean_sqrt_MD2_XP_in_range));
figure;hold on;set(gcf,'position',1000*[ 0.1937    0.1787    1.5940    0.5731  ]);
plot(all_mean_sqrt_MD2_X1,'k-*');
plot_hline(mean(all_mean_sqrt_MD2_X1),'c');
plot(find(~isnan(all_mean_sqrt_MD2_XP_in_range)),MD_XP_in_range,'bO','linewidth',2);
title_usF(['number of in range MD_XP = ',num2str(length(MD_XP_in_range ))]);
title_add(gca,['Mean of all sqrt_MD2_X1 = ',roundns(avg_sqrt_MD2_X1,2)]);

%--------------------------------------------------------------
figure;hold on;set(gcf,'position',1000*[  0.3886    0.2689    1.2817    0.5266  ]);
log_allp=log(allp);
hpp=plot(log_allp,'k-*');
ylabel('all p value');
set(gca,'YLim',[min(log(allp))  0]);
% yyaxis right
% hph=plot(allh,'r-diamond');
% ylabel('H');
loc_H_0=find(~allh);
loc_H_1=find(allh);
%----------------------------------
loc_H_0_alt=find(~allh_alt);
loc_H_1_alt=find(allh_alt);


%----------------------------------
plot(loc_H_0,log_allp( loc_H_0),'gO','linewidth',2);
plot(loc_H_1,log_allp( loc_H_1),'rO','linewidth',2);
p_value_calc=length(loc_H_0)/inp.Nrun;
sPSS=['Percentage of Blocks Reach Steady State = ',roundns(p_value_calc*100,2),'%'];
% legend([hpp hph],{'all p value','H'});
title_usF( sPSS);
%------------------------------------------------------
p_value_calc_alt=length(loc_H_0_alt)/inp.Nrun;
sPSS_alt=['Percentage of Blocks Reach Steady State ( ttest2 on MD2 Directly) = ',roundns(p_value_calc_alt*100,2),'%'];
title_add(gca,sPSS_alt);

%-------------------------------------------------------

% dev_X1
title_add(gca,['dev_X1 = ',roundns(dev_X1,3)]);
title_add(gca,['Block Size (bz) = ',roundns(bz,0)]);

title_add(gca,['Mean of all sqrt_MD2_X = ',roundns(avg_sqrt_MD2_X,2)]);
title_add(gca,['Mean of all sqrt_MD2_X1 = ',roundns(avg_sqrt_MD2_X1,2)]);
title_add(gca,['dev of Mean of all sqrt_MD2_X1 vs X = ',roundns(avg_sqrt_MD2_X1-avg_sqrt_MD2_X,2)]);
title_add(gca,['nD = ',roundns(nD,0)]);
if ~rand_cov_yes
    title_add(gca,['rand_cov_yes = ',roundns(rand_cov_yes,0),' (Uniform Covariance)']);
else
     title_add(gca,['rand_cov_yes = ',roundns(rand_cov_yes,0),' (Random Hetero Covariance)']);
end
%----------------------------------------------
out.p_value_calc=p_value_calc;


%----------------------------------------------
done_with_this_function;
end


%% ----- CabXfer_Siesler48_MLtool   [AQP_gui.m lines 6829-7775] ----------------------------------
function outXfer=CabXfer_Siesler48_MLtool(pfT,inp,INP)
% this function usually called by BatchRun_CabXfer_Siesler48_MLtool()
% this function will call --> run_each_CabXfer_AQP
% it is inside run_each_CabXfer_AQP that will do the following !!!
%======================================================================================================================================
% % prepare and save related files for PRO and AAQP dealing with CS-only case that use these files to serve as  CabXferd RawSpectra of Master to Target, updated Nov 12, 2020
%======================================================================================================================================
%
% go to --> this part is latest way that actual run in CXL
% % this is the location where CS with NaN XS can cause problems
% pfT:Mst  pfP:Trg
% "MDCextr_GLSw" (after fixing/bypassing applymean issues), Chang Hsiung, Sept 22, 2017
% see  "Incorporation of GLSstd and GLSw into AQP and coupling them with all 7 UDM schemes.pptx"  
% 'GLSstd2','MDC_GLSstd3', and 'MDCextr_GLSw' should give same results
% 'GLSw' typically show slightly different results than the above three
% "alpha" in GLSstd should be set to a^2 for "a" in GLSw
%
% add by CH, Dec 4, 2019 for output Transferred CS (but not PPd) spectra for PRO to use
% % also output as 'csv' file
%
% also output as .sam files for PRO
% internal settings below
% inp.ParentFolder4Results4PRO='Results4PRO';
% inp.prefix4tmpfolder4SAMfiles='tmp';
% path_sam=create_next_subfolder([find_last_nonTMP_folder,'\',inp.ParentFolder4Results4PRO],inp.prefix4tmpfolder4SAMfiles);
% % run VS ML2Sam
% % run VS ML2Sam wo Val set
% create_next_subfolder
% % add this by CH, Feb 18, 2020 when dealing with disable saving of SAM files
% ~isfield(inp.inp4AQP,'Option_Output_SAM') | inp.inp4AQP.Option_Output_SAM 
%
% % this line call --> load_SamLibrary
% % this line call --> ML2Sam
%==============================================================
% for calc of CT and CP
% % it is based on median !!! Nov 18, 2020
%=======================
% modify following Mar 8, 2023
% =====================================
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
            addpath_wo_attic('C:\work\PLS_toolbox_2014\PLS_Toolbox_792')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear;close all;
%     pfT='C:\work\JDSU\SieslerPharma_Quant\ATsaConc\E1\1stDer\Atrainpketc_saConc__Absorbance_E1-00198xls_PharmaLib(E1-00198)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar121_nsamp960_ncls48.mat'
%     pfP='C:\work\JDSU\SieslerPharma_Quant\ATsaConc\E1\1stDer\Atrainpketc_saConc__Absorbance_E1-00200xls_PharmaLib(E1-00200)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar121_nsamp960_ncls48.mat'
%        CabXfer_Siesler48_MLtool(pfT,pfP)
% T and P same nsamp
 % pfTP='C:\work\JDSU\SieslerPharma_Quant\XP_w6AT_E1_SGw5\Atrainpketc_saConc__Absorbance_E1-00198xls_PharmaLib{T-E1-00198__P-E1-00200_pp-SGw5}_pp1-SGw5_pp2-SampMncn_nvar125_nsampT960_ncls48_nsampP960.mat'
  pfTP='C:\work\JDSU\SieslerPharma_Quant\XP_w6AT_E1_1stDer\Atrainpketc_saConc__Absorbance_E1-00198xls_PharmaLib{T-E1-00198__P-E1-00200_pp-1stDer}_pp1-1stDerSGDiederick_pp2-SampMncn_nvar121_nsampT960_ncls48_nsampP960.mat'
 %  pfTP=   'C:\work\JDSU\SieslerPharma_Quant\XP_w6AT_AK_1stDer\Atrainpketc_saConc__Absorbance_S1-PAT002AKxls_PharmaLib{T-S1-PAT002AK__P-S1-PAT003AK_pp-1stDer}_pp1-1stDerSGDiederick_pp2-SampMncn_nvar124_nsampT960_ncls48_nsampP960.mat'
    CabXfer_Siesler48_MLtool(pfTP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;close all;
% T and P NOT same nsamp
 pfTP= 'C:\work\JDSU\SieslerPharma_Quant\XP_w6AT_AK_1stDer\Atrainpketc_saConc__Absorbance_S1-PAT001AKxls_PharmaLib{T-S1-PAT001AK__P-S1-PAT002AK_pp-1stDer}_pp1-1stDerSGDiederick_pp2-SampMncn_nvar124_nsampT956_ncls48_nsampP960.mat'
% pfTP= 'C:\work\JDSU\SieslerPharma_Quant\XP_w6AT_AK_1stDer\Atrainpketc_saConc__Absorbance_S1-PAT002AKxls_PharmaLib{T-S1-PAT002AK__P-S1-PAT001AK_pp-1stDer}_pp1-1stDerSGDiederick_pp2-SampMncn_nvar124_nsampT960_ncls48_nsampP956.mat'
clear;close all;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     clear
%         pfT='C:\work\JDSU\SieslerPharma_Quant\ATsaConc\AK\1stDer\Atrainpketc_saConc__Absorbance_S1-PAT001AKxls_PharmaLib(S1-PAT001AK)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar124_nsamp956_ncls48.mat'
%     pfP='C:\work\JDSU\SieslerPharma_Quant\ATsaConc\AK\1stDer\Atrainpketc_saConc__Absorbance_S1-PAT002AKxls_PharmaLib(S1-PAT002AK)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar124_nsamp960_ncls48.mat'
%     CabXfer_Siesler48_MLtool(pfT,pfP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% legacy study
clear;close all;
 %  pfTP=  'C:\work\JDSU\SieslerPharma_Quant\XF_9_TP_ES17-S1_1stDer\Atrainpketc_saConc__Absorbance_S1-00552xls_PharmaLib{T-S1-00552_P-S1-00375_pp1-1stDer}_pp1-1stDerSGDiederick_pp2-SampMncn_nvar121_nsampT960_ncls48_nsampP960.mat'
    pfTP=   'C:\work\JDSU\SieslerPharma_Quant\XF_9_TP_ES17-S1_SGw5\Atrainpketc_saConc__Absorbance_S1-00550xls_PharmaLib{T-S1-00550_P-S1-00375_pp1-SGw5}_pp1-SGw5_pp2-SampMncn_nvar125_nsampT959_ncls48_nsampP960.mat'
 inp.XM_Slct_scheme='KS2';
    inp.TP_includeTrn_Yes=1;
  inp.cCabXfer_scheme={'GLSstd2','GLSw','OSC','STDgenize','woCabXfer'};  
%     inp.cCabXfer_scheme={'GLSstd2','STDgenize','woCabXfer'};  
 %   inp.cCabXfer_scheme={'GLSstd2','STDgenize','woCabXfer'};  

  
  CabXfer_Siesler48_MLtool(pfTP,inp)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % compare LS-PDS vs PDS vs LS vs LS-GLS vs GLSw
 clear;close all;
    pfTP=   'C:\work\JDSU\SieslerPharma_Quant\XF_9_TP_ES17-S1_SGw5\Atrainpketc_saConc__Absorbance_S1-00550xls_PharmaLib{T-S1-00550_P-S1-00375_pp1-SGw5}_pp1-SGw5_pp2-SampMncn_nvar125_nsampT959_ncls48_nsampP960.mat'
  inp.XM_Slct_scheme='KS24';
    inp.TP_includeTrn_Yes=1;
  inp.cCabXfer_scheme={'LS','GLSstd2','LS-GLSw','GLSw','woCabXfer'};  
  CabXfer_Siesler48_MLtool(pfTP,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % investigate LS-OSC problems with KS2
 clear;close all;
    pfTP=   'C:\work\JDSU\SieslerPharma_Quant\XF_9_TP_ES17-S1_SGw5\Atrainpketc_saConc__Absorbance_S1-00550xls_PharmaLib{T-S1-00550_P-S1-00375_pp1-SGw5}_pp1-SGw5_pp2-SampMncn_nvar125_nsampT959_ncls48_nsampP960.mat'
  inp.XM_Slct_scheme='KS2';
    inp.TP_includeTrn_Yes=1;
  inp.cCabXfer_scheme={'LS-OSC','woCabXfer'};  
  CabXfer_Siesler48_MLtool(pfTP,inp)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TP_includeTrn_Yes=inp.TP_includeTrn_Yes;
fig_yes=0   ;
% internal settings below
inp.ParentFolder4Results4PRO='Results4PRO';
inp.prefix4tmpfolder4SAMfiles='tmp';

% XM_Slct_scheme='KS24';   % 'Even-Conc-mean' 'Odd-Conc-mean' 'Odd-Conc' 'Even-Conc'  sample selection scheme for Transfer Matrix see also "distslct"  "KennardStone"
  %   inp.cCabXfer_scheme={'OSC','GLSstd2','GLSw','STDgenize'};   %    'GLSw'  'GLSstd2'  'STDgenize'
   %  inp.cCabXfer_scheme={'OSC','GLSstd2'};   %    'GLSw'  'GLSstd2'  'STDgenize'

 XM_Slct_scheme=inp.XM_Slct_scheme;
 
   cCabXfer_scheme=inp.cCabXfer_scheme;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% narginchk(2);
%------------------------------------------------
% modify following Mar 8, 2023
%  defaultValue('pfP',pfT);
pfP=pfT;
%------------------------------------------------- 
% if nargin==1
   LTP=load(pfT); 
   
  LT=LTP;
  LT=rmfield(LT,{'Apred','AclassinfoP','AclabelP','PLS'});
  LT.RawSpectra=LTP.RawSpectra.Tset; 
  LT.saConc=LTP.PLS.Tset.saConc; 
  
  LP.clistclslabel=LTP.clistclslabel;
  LP.wvl_standardize=LTP.wvl_standardize;
 try LP.RawSpectra=LTP.RawSpectra.Pset; end;
  LP.saConc=LTP.PLS.Pset.saConc; 
  LP.Atrainpk=LTP.Apred;
  LP.AclassinfoT=LTP.AclassinfoP;
  LP.AclabelT=LTP.AclabelP;
try 
    LP.AInfo_1=LTP.AInfo_1_P;
catch
    LP.AInfo_1='';
end
  
%    pfP=pfT;  % tmp set this
  
  
  
% else
%   LT=load(pfT);
%   LP=load(pfP);
% end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(find_keyword_between_markers( XM_Slct_scheme,'[',']'))
XM_Slct_scheme_add_setting=find_keyword_between_markers( XM_Slct_scheme,'[',']');
XM_Slct_scheme_orig=XM_Slct_scheme;
XM_Slct_scheme=strrep_keyword_between_markers_wlistRHS(XM_Slct_scheme,'[',{']'},'');


else
 XM_Slct_scheme_add_setting=''; 
 XM_Slct_scheme_orig=XM_Slct_scheme;
end
if strcmp(XM_Slct_scheme,'KSall')
    nQPlabel=unique(LP.AclabelT);
    nQTlabel=unique(LT.AclabelT);
    N_common_label_TP=length(intersect(nQPlabel,nQTlabel));
    nKS= N_common_label_TP;
else
    nKS=find_keynumber_numeric_AFTER_marker (XM_Slct_scheme,'KS');
end
                if isnumeric(nKS)
                    KS_yes=1;
                    if nKS==1
                    XM_Slct_scheme_alt=XM_Slct_scheme;     
                    else
                    XM_Slct_scheme_alt='KSn';
                    end
                else
                    KS_yes=0;
            XM_Slct_scheme_alt=XM_Slct_scheme;
        
                end

switch XM_Slct_scheme_alt
    case {'Odd-Conc','Even-Conc','Odd-Conc-mean','Even-Conc-mean','KS1','KSn'}
        [qT nT]=unique_count(LT.AclabelT);
        
        switch XM_Slct_scheme_alt
            case {'Odd-Conc','Odd-Conc-mean'}
                clist_OddEvenConc_T=qT(1:2:end);
            case {'Even-Conc','Even-Conc-mean'}
                clist_OddEvenConc_T=qT(2:2:end);
            case {'KS1','KSn'}
%                 nKS=find_keynumber_numeric_AFTER_marker (XM_Slct_scheme,'KS');
%                 if isnumeric(nKS)
%                     KS_yes=1;
%                 else
%                     KS_yes=0;
%                 end

                allSampleName_T=arrayfun(@(x) x.SampleName{1},LT.saConc,'un',0);
                [qSN_T nSN_T]=unique_count(allSampleName_T);
                allC_T=arrayfun(@(x) x.Conc,LT.saConc);
                try
               qC_T_by_SN= cellfun(@(x) unique(allC_T(strmatch(x,allSampleName_T,'exact'))),qSN_T);
                catch
                 qC_T_by_SN= qSN_T;  
                end
%                qC_T_by_SN= cellfun(@(x) unique(allC_T(strmatch(x,allSampleName_T,'exact'))),qSN_T,'un',0);

               
               
                qC_T=sort(qC_T_by_SN);
                %[qC_T nC_T]=unique_count(allC_T);%old approach that cannot handle cases with same Conc for different SampleName
                %
 
                
                
                allSampleName_P=arrayfun(@(x) x.SampleName{1},LP.saConc,'un',0);
                [qSN_P nSN_P]=unique_count(allSampleName_P);
                allC_P=arrayfun(@(x) x.Conc,LP.saConc);
                try
                qC_P_by_SN= cellfun(@(x) unique(allC_P(strmatch(x,allSampleName_P,'exact'))),qSN_P);
                catch
                 qC_P_by_SN= qSN_P;  
                end
                qC_P=sort(qC_P_by_SN);
                %[qC_P nC_P]=unique_count(allC_P);%old approach that cannot handle cases with same Conc for different SampleName
                
%                 if ~isSAME_2Matrix(qC,qC_P)
%                     error('Tset and Pset have different Conc')
%                 else
                     if nKS==1 && isempty(XM_Slct_scheme_add_setting)
                         % based on Ymat
                        [idxTrn_T_tmp, idxRef_T_tmp] = KennardStone( qC_T, 3); 
                       % [idxTrn_T_tmp] = find(kennardstone( qC_T, 3)); 
                        
                        idxTrn_T=idxTrn_T_tmp(2);
                        %idxRef_T=unique([idxRef_T_tmp;idxTrn_T_tmp([1 3])]);
                     else
                         if ~isempty(XM_Slct_scheme_add_setting)
                             switch XM_Slct_scheme_add_setting
                                 
                                 case  'Xmat'
                                     [qLabel_T nLabel_T]=unique_count(  LT.AclabelT);
                                     Xmat_T_mean=[];
                                     for i_qLabel_T=1:length(qLabel_T)
                                         loc_i_qLabel_T=strmatch(qLabel_T{i_qLabel_T},LT.AclabelT,'exact');
                                         Xmat_T_mean=[Xmat_T_mean;mean(LT.Atrainpk(loc_i_qLabel_T,:))];
                                     end
                                     % [idxTrn_T_Xmat, idxRef_T_Xmat] = KennardStone( Xmat_T_mean, nKS); 
                                      
                                     if nKS>1
                                     [idxTrn_T_Xmat] = find(kennardstone( Xmat_T_mean, nKS)); 
                                     else
                                       [idxTrn_T_tmp] = find(kennardstone( Xmat_T_mean, 3)); 
                                       idxTrn_T_Xmat=idxTrn_T_tmp(2);
                                      % idxRef_T=unique([idxRef_T_tmp;idxTrn_T_tmp([1 3])]);  
                                     end
                                     
                                    % idxTrn_T=idxTrn_T_Xmat;
                                     %idxRef_T=idxRef_T_Xmat;
%                                      qLabel_T(idxTrn_T_Xmat)
                                     
                                     if false
                                     figure;hold on;
                                     plot(LT.Atrainpk','b-O');
                                      % plot(Xmat_T_mean','r-*');
                                      plot(Xmat_T_mean(idxTrn_T_Xmat,:)','c->');  
                                     end
                                 case 'XYmat'  
                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                    % based on Xmat 
                                      [qLabel_T nLabel_T]=unique_count(  LT.AclabelT);
                                     Xmat_T_mean=[];
                                     for i_qLabel_T=1:length(qLabel_T)
                                         loc_i_qLabel_T=strmatch(qLabel_T{i_qLabel_T},LT.AclabelT,'exact');
                                         Xmat_T_mean=[Xmat_T_mean;mean(LT.Atrainpk(loc_i_qLabel_T,:))];
                                     end
                                     % [idxTrn_T_Xmat, idxRef_T_Xmat] = KennardStone( Xmat_T_mean, nKS); 
                                      
                                     if nKS>1
                                     [idxTrn_T_Xmat] = find(kennardstone( Xmat_T_mean, nKS)); 
                                     else
                                       [idxTrn_T_tmp] = find(kennardstone( Xmat_T_mean, 3)); 
                                       idxTrn_T_Xmat=idxTrn_T_tmp(2);
                                      % idxRef_T=unique([idxRef_T_tmp;idxTrn_T_tmp([1 3])]);  
                                     end
                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                     % based on Ymat
                                     if nKS==1
                                     [idxTrn_T_tmp_Ymat] = find(kennardstone( qC_T, 3)); 
                                     idxTrn_T_Ymat=idxTrn_T_tmp_Ymat(2);
                                     else
                                      [idxTrn_T_Ymat] = find(kennardstone( qC_T, nKS));   
                                     end
                                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                     % combine Xmat and Ymat
                                     idxTrn_T_XYmat=unique([idxTrn_T_Xmat;idxTrn_T_Ymat]);
                                     
                                     
                                     
                                     
                                 otherwise
                                     error('XM_Slct_scheme_add_setting Not supported')
                             end
                             
                             
                             
                         else
                             if strcmp(XM_Slct_scheme,'KSall')% in this case, idxTrn Not determined by KennardStone
%                               idxTrn_T=   find(cellfun(@(x) ~isempty(find(qC_P==x)),  qC_T ));
try
    idxTrn_T=   find_belong2subgrp(qC_T,qC_P);
catch
    idxTrn_T='';
end
                              % try to check and make sure all Conc in T and P are unique
                              % 
                              
                                        idxTrn_T_basedon_SampleName=   find(cellfun(@(x) ~isempty(strmatch(x,allSampleName_P,'exact')),  LT.AclabelT ));
                              if length(idxTrn_T_basedon_SampleName)~=length(idxTrn_T)
                                 % error('you need to deal with case that not all Conc are unique')
                                  warning('in this case not all Conc are unique')
 
                              end
                              
                                 
                             else
                             [idxTrn_T, idxRef_T] = KennardStone( qC_T, nKS);
                             end
%                                 [idxTrn_T] = find(kennardstone( qC_T, nKS));
                         end
                     end
%                 end

              % assuming   LT.AclabelT or LT.saConc.SampleName match with allC_T
              if ~isempty(XM_Slct_scheme_add_setting) && strcmp(XM_Slct_scheme_add_setting,'Xmat')
                  
                 clist_OddEvenConc_T=  qLabel_T(idxTrn_T_Xmat);
              elseif  ~isempty(XM_Slct_scheme_add_setting) && strcmp(XM_Slct_scheme_add_setting,'XYmat')
                  clist_OddEvenConc_T=  qLabel_T(idxTrn_T_XYmat);
              else
                  if length(LT.saConc)==length(LT.AclabelT) && length(LT.saConc)==length(allC_T)
                      Conc_KSpick= qC_T(idxTrn_T);
                      %idx_saConcSampleName_KS= arrayfun(@(x) isKSpick(x,Conc_KSpick),LT.saConc);
                      %clist_OddEvenConc_T_old=unique(LT.AclabelT(idx_saConcSampleName_KS));
                      clistSN_match_Conc_KSpick=arrayfun(@(x) find_MatchConc_1stUniqueSampleNameOnly(x,allC_T,allSampleName_T),Conc_KSpick,'un',0);
                      clist_OddEvenConc_T_tmp=clistSN_match_Conc_KSpick;
%                       intersect(clist_OddEvenConc_T,clist_OddEvenConc_T_old)
                  end
              end
               
            otherwise
                error([XM_Slct_scheme, ' as XM_Slct_scheme NOT supported !!!'])
                
        end
        
        
        
        locXT_tmp=find(cellfun(@(x) ~isempty(strmatch(x,clist_OddEvenConc_T_tmp,'exact')),LT.AclabelT));
   %  % include XSmst wRefNaN if exist
% INP.pathfname_HiRes_XSmst=handles.DS.pathfname_HiRes_XSmst;
% INP.Lmst_orig_XSmst=handles.DS.Lmst_orig_XSmst;
     
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % XS for P should be determined solely by XS of T and assuming T and P use same sample ID system
        % i.e. same sample ID in T and P means they are physically same sample and with same Conc
        % however it maybe that not all clist_OddEvenConc_T_tmp can be
        % found in LP.AclabelT, hence we can only use the common ones
        
%         clist_OddEvenConc_T
%         locXT  will be determined by clist_OddEvenConc_T
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false  % force old way to turn off
        clist_OddEvenConc_P_tmp=clist_OddEvenConc_T_tmp;
        clist_sampleID_P=cat(1,LP.AclabelT);
        
        clist_OddEvenConc_P=intersect(clist_OddEvenConc_P_tmp,clist_sampleID_P);
        
        clist_OddEvenConc_T=clist_OddEvenConc_P;
       locXT= find(cellfun(@(x) ~isempty(strmatch(x,clist_OddEvenConc_T,'exact')),LT.AclabelT));
       locXP=find(cellfun(@(x) ~isempty(strmatch(x,clist_OddEvenConc_P,'exact')),LP.AclabelT));
else   % for to run in new way
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this part is latest way that actual run in CXL
    % this part is latest way that actual run in CXL
    % this part is latest way that actual run in CXL
    disp('this part is latest way that actual run in CXL');
    clist_sampleID_P=cat(1,LP.AclabelT);
    locXP=find(cellfun(@(x) ~isempty(strmatch(x,clist_sampleID_P,'exact')),LP.AclabelT));
    locXT=find(cellfun(@(x) ~isempty(strmatch(x,clist_sampleID_P,'exact')),LT.AclabelT));
    %locXT=find(cellfun(@(x) ~isempty(strmatch(x,clist_sampleID_P,'exact')),LT.AclabelT(1:248)));
    
    clist_OddEvenConc_T=clist_sampleID_P;
    clist_OddEvenConc_P=clist_sampleID_P;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %clist_sampleID_P
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% if isempty(locXT)&& length(locXP)==length(LP.saConc) 
% %------------------------------------------------
% % include XSmst wRefNaN if exist
% INP.pathfname_HiRes_XSmst=handles.DS.pathfname_HiRes_XSmst;
% INP.Lmst_orig_XSmst=handles.DS.Lmst_orig_XSmst;
% 
% else     
%     
%     
%     
% end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
       XT_Ainfo_1=LT.AInfo_1_T(locXT);
        catch
       XT_Ainfo_1='';     
        end
       try
       XP_Ainfo_1=LP.AInfo_1(locXP);
       catch
        XP_Ainfo_1='';   
       end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         % checking
%         if ~isSAME_two_cstr(clist_OddEvenConc_T,clist_OddEvenConc_P)
%             error('mismatched Conc were used to construct XM')
% %             
% %             clist_OddEvenConc_P
%             % strcmp_CI_two_cstr_deblank
%             [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(clist_OddEvenConc_T,clist_OddEvenConc_P);
%             
%             clist_OddEvenConc_T=clist_OddEvenConc_T(LOC.str1_match_str2);% added to fix cases with OLs in Trg 
%             clist_OddEvenConc_P=clist_OddEvenConc_P(LOC.str2_match_str1);% added to fix cases with OLs in Trg 
% 
%         locXT=find(cellfun(@(x) ~isempty(strmatch(x,clist_OddEvenConc_T,'exact')),LT.AclabelT));% added to fix cases with OLs in Trg 
%         locXP=find(cellfun(@(x) ~isempty(strmatch(x,clist_OddEvenConc_P,'exact')),LP.AclabelT));% added to fix cases with OLs in Trg 
%         end
        
if isempty(locXT)&& length(locXP)==length(LP.saConc)
    % this is the case that NO ref available for XS
    % this is the case that NO ref available for XS
    % this is the case that NO ref available for XS,
    % XS for mst (or XSmst) were using NaN and they were separated from CS in earlier stage of the data flow
    % the location of that XS for mst (or XSmst) --> INP.pathfname_MGs_PP_XSmst
    if ~isempty(INP.pathfname_MGs_PP_XSmst)  %  'this is the case that NO ref available for XS'
        disp('this is the case that NO ref available for XS');
        %------------------------------------------------
        % deal with include XSmst wRefNaN if exist
        % INP.pathfname_HiRes_XSmst;
        Lmst_MGs_PP_XSmst=load(INP.pathfname_MGs_PP_XSmst);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        saCTCP=[];
        % check to see if ID seq matched
        
        
%         if isSAME_two_cstr(Lmst_MGs_PP_XSmst.AclabelT,LP.AclabelT)%  'this is the case that NO ref available for XS'
            
            qLabelXT=unique(Lmst_MGs_PP_XSmst.AclabelT);
            qLabelXP=unique(LP.AclabelT);
            
            if length(qLabelXT)~=length(qLabelXP)
                error('mismatch in lengths between qLabelXT qLabelXP ');
            else
                disp('all CT and CP seems to match');
                snXS=['_nsampXS',num2str(length(qLabelXT))];
                inp.snXS=snXS;
            end
            
            
            % old approach that use all spectra (not based on median)
            %             CT_prep=Lmst_MGs_PP_XSmst.Atrainpk;
            %             CP_prep=LP.Atrainpk;
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % new and consistent approach that always use median to
            % "average" spectra with same physical sample
            % 
            CT_prep=[];
            CP_prep=[];
            for iConc=1:length(qLabelXT)
                locXT_iConc=strmatch(qLabelXT{iConc},Lmst_MGs_PP_XSmst.AclabelT,'exact');
                locXP_iConc=strmatch(qLabelXP{iConc},LP.AclabelT,'exact');
                
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % this is the location where CS with NaN XS can cause problems
                % 
                if  length(locXT_iConc)>1
                    %CT_prep_iConc=median(LT.Atrainpk(locXT_iConc,:));  % based on median not mean !!! orig approach
                    %CT_prep_iConc=mean(LT.Atrainpk(locXT_iConc,:));  % based on mean !!!
                    
                     CT_prep_iConc=median(Lmst_MGs_PP_XSmst.Atrainpk(locXT_iConc,:));  % newly fixed approach   % it is based on median !!! Nov 18, 2020
                else
                   % CT_prep_iConc=LT.Atrainpk(locXT_iConc,:);%  orig approach
                    CT_prep_iConc=Lmst_MGs_PP_XSmst.Atrainpk(locXT_iConc,:);%  newly fixed approach
                    
                end
                 % this is the location where CS with NaN XS can cause problems
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
                
                
                CT_prep=[CT_prep;CT_prep_iConc];
                
                if  length(locXP_iConc)>1
                    CP_prep_iConc=median(LP.Atrainpk(locXP_iConc,:));  % based on median not mean !!!                            % it is based on median !!! Nov 18, 2020
                    % CP_prep_iConc=mean(LP.Atrainpk(locXP_iConc,:));  % based on  mean !!!
                else
                    CP_prep_iConc=LP.Atrainpk(locXP_iConc,:);
                end
                CP_prep=[CP_prep;CP_prep_iConc];
                
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %             snXS=['_nsampXS',num2str(length(LP.saConc))];
            
%         else
%             [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(Lmst_MGs_PP_XSmst.AclabelT,LP.AclabelT);
%             if  isempty(LOC.str1_mismatch) && isempty(LOC.str2_mismatch)
%                 CT_prep_tmp=Lmst_MGs_PP_XSmst.Atrainpk;
%                 CP_prep_tmp=LP.Atrainpk;
%                 %             CT_prep=repmat(NaN,size(CT_prep_tmp));
%                 CT_prep=CT_prep_tmp(LOC.str1_match_str2,:);
%                 %             CP_prep=repmat(NaN,size(CP_prep_tmp));
%                 CP_prep=CP_prep_tmp(LOC.str2_match_str1,:);
%                 AclabelT_CT=Lmst_MGs_PP_XSmst.AclabelT(LOC.str1_match_str2);
%                 AclabelT_CP=LP.AclabelT(LOC.str2_match_str1);
%                 % further check to see if ID seq matched now
%                 if isSAME_two_cstr(AclabelT_CT,AclabelT_CP)
%                     AclabelT_CTCP= AclabelT_CT; % this is the final ID seq in matched CT and CP
%                     snXS=['_nsampXS',num2str(length(AclabelT_CTCP))];
%                 else
%                     error('somehow ID seq still not matched ??')
%                 end
%                 
%             else
%                 error('can not handle this case yet: where ID in XSmst only partially matched with that in XStrg')
%                 
%             end
%             
%         end
%         inp.snXS=snXS;
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        locRT=col_always([1:length(LT.AclabelT)]);
        locRP=col_always([1:length(LP.AclabelT)]);
        T_prep=LT.Atrainpk(locRT,:);
        P_prep=LP.Atrainpk(locRP,:);
        sCTP_meanConc=['_'];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else % this is the case that INP.pathfname_MGs_PP_XSmst Not exist and can not proceed with any Xfer
        % force to switch to 'woCabXfer'
        
        locRT=col_always([1:length(LT.AclabelT)]);
        locRP=col_always([1:length(LP.AclabelT)]);
        T_prep=LT.Atrainpk(locRT,:);
        P_prep=LP.Atrainpk(locRP,:);
        sCTP_meanConc=['_'];
        
        if ~strcmp(cCabXfer_scheme{1},'woCabXfer')
            
            cCabXfer_scheme={'woCabXfer'};  % force to switch to 'woCabXfer'
            INP.handles.XferScheme.Value=find(strcmp('woCabXfer',INP.handles.XferScheme.String));
            disp_with_border('XferScheme has been forced to swith to "woCabXfer"');
            if INP.handles.audio.Value
                Speak_mk('No matching spectra between scouting set and calibration set was found, switch to without using any transfer scheme')
            end
        end
        
        saCTCP='';
        CT_prep=[];
        CP_prep=[];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this the case that ref values available for XS
    % this the case that ref values available for XS
    % this the case that ref values available for XS

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if  (strcmp(XM_Slct_scheme,'Odd-Conc-mean') | strcmp(XM_Slct_scheme,'Even-Conc-mean') | KS_yes==1) && (  ~isempty(locXT) | ~isempty(locXP)     )
%         [qLabelXT nLabelXT]=unique_count(  LT.AclabelT(locXT));
%         [qLabelXP nLabelXP]=unique_count(  LP.AclabelT(locXP));

    % this part is latest way that actual run in CXL
    % this part is latest way that actual run in CXL
    % this part is latest way that actual run in CXL
    disp('this part is latest way that actual run in CXL');

        % treat all replicates as different samples
        qLabelXT=unique(LT.AclabelT(locXT));
        nLabelXT=length(locXT);
         qLabelXP=unique(LP.AclabelT(locXP));
        nLabelXP=length(locXP);
        
        %             qLabelXT=intersect(qLabelXT,clist_OddEvenConc_T);   % added to fix cases with OLs in Trg
        %             qLabelXP=intersect(qLabelXP,clist_OddEvenConc_P);   % added to fix cases with OLs in Trg
%         if length(qLabelXT)~=length(clist_OddEvenConc_T) | length(qLabelXP)~=length(clist_OddEvenConc_P)
%             error('mismatch in lengths between qLabelXT clist_OddEvenConc_T or qLabelXP clist_OddEvenConc_P')
        if length(qLabelXT)~=length(qLabelXP)
            error('mismatch in lengths between qLabelXT qLabelXP ');
        else
            disp('all CT and CP seems to match');
            snXS=['_nsampXS',num2str(length(qLabelXT))];
            inp.snXS=snXS;
        end
        
        %             if isSAME_two_cstr(qLabelXT,qLabelXP)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        CT_AInfo_1=[];
        CP_AInfo_1=[];
        saCTCP=[];
        CT_prep=[];
        CP_prep=[];
        for iConc=1:length(qLabelXT)
            locXT_iConc=strmatch(qLabelXT{iConc},LT.AclabelT,'exact');
            locXP_iConc=strmatch(qLabelXP{iConc},LP.AclabelT,'exact');
            
            
            if strcmp( XM_Slct_scheme_alt,'KS1') && length(locXT_iConc)==length(locXP_iConc) % since GLS can Not run with only one sample, in this case use all replicates
                CT_prep=[CT_prep;LT.Atrainpk(locXT_iConc,:)];
                CP_prep=[CP_prep;LP.Atrainpk(locXP_iConc,:)];
                
            elseif  strcmp( XM_Slct_scheme_alt,'KS1') %deal with KS1 but CT and CP different in their size
                if length(locXT_iConc)<length(locXP_iConc)
                    locXP_iConc_orig=locXP_iConc;
                    if length(locXT_iConc)==1
                        locKS_locXP_iConc=ceil(median([1:length(locXP_iConc_orig)]));
                    else
                        locKS_locXP_iConc=KennardStone(locXP_iConc_orig,length(locXT_iConc));
                    end
                    locXP_iConc=locXP_iConc_orig(locKS_locXP_iConc);
                    CT_prep=[CT_prep;LT.Atrainpk(locXT_iConc,:)];
                    CP_prep=[CP_prep;LP.Atrainpk(locXP_iConc,:)];
                else
                    locXT_iConc_orig=locXT_iConc;
                    locKS_locXT_iConc=KennardStone(locXT_iConc_orig,length(locXP_iConc));
                    locXT_iConc=locXT_iConc_orig(locKS_locXT_iConc);
                    CT_prep=[CT_prep;LT.Atrainpk(locXT_iConc,:)];
                    CP_prep=[CP_prep;LP.Atrainpk(locXP_iConc,:)];
                    
                end
                % elseif strcmp( XM_Slct_scheme_alt,'KSn') && nKS==2  % use all samples even when KSn==2
            elseif strcmp( XM_Slct_scheme_alt,'KSn') && nKS>=2  % use all samples even when KSn>=2
                % this part is latest way that actual run in CXL
                % this part is latest way that actual run in CXL
                % this part is latest way that actual run in CXL
%                   disp('this part is latest way that actual run in CXL');

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % new and consistent approach that always use median to
              % "average" spectra with same physical sample

                if  length(locXT_iConc)>1
                    CT_prep_iConc=median(LT.Atrainpk(locXT_iConc,:));  % based on median not mean !!!
                    %CT_prep_iConc=mean(LT.Atrainpk(locXT_iConc,:));  % based on mean !!!
                else
                    CT_prep_iConc=LT.Atrainpk(locXT_iConc,:);
                end
                CT_prep=[CT_prep;CT_prep_iConc];
                
                if  length(locXP_iConc)>1
                    CP_prep_iConc=median(LP.Atrainpk(locXP_iConc,:));  % based on median not mean !!!
                    % CP_prep_iConc=mean(LP.Atrainpk(locXP_iConc,:));  % based on  mean !!!
                else
                    CP_prep_iConc=LP.Atrainpk(locXP_iConc,:);
                end
                CP_prep=[CP_prep;CP_prep_iConc];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % collect AInfo_1
                % still under construction !!!
                try
                    if isempty(LT.AInfo_1_T)
                        CT_AInfo_1=[CT_AInfo_1;LT.AclabelT(locXT_iConc)];
                    else
                        CT_AInfo_1=[CT_AInfo_1;LT.AInfo_1_T(locXT_iConc)];
                    end
                catch
                    CT_AInfo_1=[CT_AInfo_1;LT.AclabelT(locXT_iConc)];
                end
                
                if isempty(LP.AInfo_1)
                    CP_AInfo_1=[CP_AInfo_1;LP.AclabelT(locXP_iConc)];
                else
                    CP_AInfo_1=[CP_AInfo_1;LP.AInfo_1(locXP_iConc)];
                end
                easaCTCP.CTi=LT.Atrainpk(locXT_iConc,:);
                easaCTCP.CPi=LP.Atrainpk(locXP_iConc,:);
                
                easaCTCP.CT=CT_prep_iConc;
                easaCTCP.CP=CP_prep_iConc;
                
                easaCTCP.CT_RS=LT.RawSpectra(locXT_iConc,:);
                easaCTCP.CP_RS=LP.RawSpectra(locXP_iConc,:);
                
                easaCTCP.AclabelT=qLabelXT{iConc};
                easaCTCP.Conc =Conc_KSpick(strcmp(easaCTCP.AclabelT,clistSN_match_Conc_KSpick));
                easaCTCP.CT_AInfo_1=LT.AclabelT(locXT_iConc);
                easaCTCP.CP_AInfo_1=LP.AclabelT(locXP_iConc);
                saCTCP=[saCTCP;easaCTCP];
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else
                error('not prepared to handle this case')
                CT_prep=[CT_prep;mean(LT.Atrainpk(locXT_iConc,:))];
                CP_prep=[CP_prep;mean(LP.Atrainpk(locXP_iConc,:))];
            end
            
            
            
            
        end  % end of "for iConc"
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Ref set used for TP validation
        if ~TP_includeTrn_Yes
            locRT=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_T,'exact')),LT.AclabelT));
            locRP=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_P,'exact')),LP.AclabelT));
        else
            locRT=col_always([1:length(LT.AclabelT)]);
            locRP=col_always([1:length(LP.AclabelT)]);
            
        end
        
        
        
        
        T_prep=LT.Atrainpk(locRT,:);
        P_prep=LP.Atrainpk(locRP,:);
        sCTP_meanConc=['_'];
        %             else
        %                warning('mismatched unique Conc in locXT vs locXP and  can NOT be used to construct XM')
        %
        %             end
        
        
        
    elseif isSAME_2Matrix(locXT,locXP)
        error('not prepared to handle this case')
        CT_prep=LT.Atrainpk(locXT,:);
        CP_prep=LP.Atrainpk(locXP,:);
        
        % Ref set used for TP validation
        locRT=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_T,'exact')),LT.AclabelT));
        locRP=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_P,'exact')),LP.AclabelT));
        
        T_prep=LT.Atrainpk(locRT,:);
        P_prep=LP.Atrainpk(locRP,:);
        
        
        
        
    elseif (length(locXT)==length(locXP)) && (  ~isempty(locXT) | ~isempty(locXP)     )
        error('not prepared to handle this case')
        % check whether XT and XP cover same Conc Seq
        if isSAME_two_cstr( LT.AclabelT(locXT),  LP.AclabelT(locXP) )
            CT_prep=LT.Atrainpk(locXT,:);
            CP_prep=LP.Atrainpk(locXP,:);
            
            % Ref set used for TP validation
            locRT=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_T,'exact')),LT.AclabelT));
            locRP=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_P,'exact')),LP.AclabelT));
            
            T_prep=LT.Atrainpk(locRT,:);
            P_prep=LP.Atrainpk(locRP,:);
        else
            error('Conc Seq in XT and XP not same and still need more elaborate methods to parse data')
        end
        
        
        
    elseif isempty(locXT) && isempty(locXP)
        CT_prep='';
        CP_prep='';
        saCTCP='';
        locRT=[1:length(LT.Atrainpk(:,1))];
        locRP=[1:length(LP.Atrainpk(:,1))];
        T_prep=LT.Atrainpk;
        P_prep=LP.Atrainpk;
    else
        error('not prepared to handle this case')
        
        [qLabelXT nLabelXT]=unique_count(  LT.AclabelT(locXT));
        [qLabelXP nLabelXP]=unique_count(  LP.AclabelT(locXP));
        if isSAME_two_cstr(qLabelXT,qLabelXP)
            
            CT_prep=[];
            CP_prep=[];
            for iConc=1:length(qLabelXT)
                locXT_iConc=strmatch(qLabelXT{iConc},LT.AclabelT,'exact');
                locXP_iConc=strmatch(qLabelXP{iConc},LP.AclabelT,'exact');
                CT_prep=[CT_prep;mean(LT.Atrainpk(locXT_iConc,:))];
                CP_prep=[CP_prep;mean(LP.Atrainpk(locXP_iConc,:))];
            end
            % Ref set used for TP validation
            locRT=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_T,'exact')),LT.AclabelT));
            locRP=find(cellfun(@(x) isempty(strmatch(x,clist_OddEvenConc_P,'exact')),LP.AclabelT));
            
            T_prep=LT.Atrainpk(locRT,:);
            P_prep=LP.Atrainpk(locRP,:);
            sCTP_meanConc=['_CTPmeanConc'];
            
            
        else
            
            error('this will NOT work, since locXT and locXP are having different unique Conc lists')
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end   % end of "if  strcmp(XM_Slct_scheme,'Odd-Conc-mean') | strcmp(XM_Slct_scheme,'Even-Conc-mean') | KS_yes==1"
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end  % end of "if isempty(locXT)&& length(locXP)==length(LP.saConc)"

       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
        
        
        
        
        
        
        
        if ~TP_includeTrn_Yes  
        clistclslabel_RT=setdiff(LT.clistclslabel,clist_OddEvenConc_T);
        clistclslabel_RP=setdiff(LP.clistclslabel,clist_OddEvenConc_P);
        else
         clistclslabel_RT=LT.clistclslabel;
          clistclslabel_RP=LP.clistclslabel;
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
    otherwise
        error([XM_Slct_scheme, ' as XM_Slct_scheme NOT supported !!!'])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check CT_AInfo_1 CP_AInfo_1 vs CT_prep CP_prep
try
    if ~isempty(locXT) | ~isempty(locXP)
        if length(CT_AInfo_1)==length(CT_prep(:,1)) && length(CP_AInfo_1)==length(CP_prep(:,1))
            disp('AInfo_1 for CT and CP are consistent');
            %     saCTCP(5).CP_AInfo_1
        else
            warning('mismatch in AInfo_1 for CT and CP')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp.fig_yes=fig_yes;
inp.XM_Slct_scheme=XM_Slct_scheme;
inp.XM_Slct_scheme_orig=XM_Slct_scheme_orig;
inp.saCTCP=saCTCP;
for iCab=1:length(cCabXfer_scheme)
%     close all
    CabXfer_scheme=cCabXfer_scheme{iCab};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check whether need to run this iteration, e.g. woCabXfer with different KSn
    %
    try
        if exist('INP','var') && strcmp(CabXfer_scheme,'woCabXfer') && find(strcmp(XM_Slct_scheme_orig,INP.cXM_Slct_scheme))>1
            %  if exist('INP','var') && strcmp(CabXfer_scheme,'woCabXfer')
            
            disp('skip this because woCabXfer only need to run KSn once')
            
        else
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if strcmp(CabXfer_scheme,'LS-OSC') && strcmp( XM_Slct_scheme,'KS2')
                CT_prep=CT_prep4LSOSC;
                CP_prep=CP_prep4LSOSC;
                inp.inp4AQP=INP.inp4AQP;
                [T_cab P_cab  SAT_cab fname_cab outXfer]=run_each_CabXfer_AQP(CabXfer_scheme,CT_prep,CP_prep,T_prep,P_prep,pfT,pfP,LT,LP,clistclslabel_RT,locRT,locRP,inp);
            else
                inp.Test_or_Val='Test';
                %inp.inp4AQP=INP.inp4AQP; % try block this, July 11, 2019
                inp.inp4AQP='';% try empty this, July 11, 2019
                [T_cab P_cab  SAT_cab fname_cab outXfer]=run_each_CabXfer_AQP(CabXfer_scheme,CT_prep,CP_prep,T_prep,P_prep,pfT,pfP,LT,LP,clistclslabel_RT,locRT,locRP,inp);
                try
                    pathfnameTP4Val= inp.pathfnameTP4Val;
                    inp4Val=inp;
                    inp4Val.pathfnameTP4Val=pathfnameTP4Val;
                    LV_TP4Val=load(pathfnameTP4Val);
                    LV.clistclslabel=LV_TP4Val.clistclslabel;
                    LV.wvl_standardize=LV_TP4Val.wvl_standardize;
                    try LV.RawSpectra=LV_TP4Val.RawSpectra.Pset; end;
                    LV.saConc=LV_TP4Val.PLS.Pset.saConc;
                    LV.Atrainpk=LV_TP4Val.Apred;
                    LV.AclassinfoT=LV_TP4Val.AclassinfoP;
                    LV.AclabelT=LV_TP4Val.AclabelP;
                    V_prep =LV_TP4Val.Apred;
                    pfV=pathfnameTP4Val;
                    clistclslabel_V=LV_TP4Val.clistclslabel;
                    locRV=[1:length(V_prep(:,1))]';
                    inp4Val.Test_or_Val='Val';
                    %                inp.inp4AQP=INP.inp4AQP;
                    inp.inp4AQP='';% try empty this, July 11, 2019
                    inp4Val.inp4AQP=INP.inp4AQP;                             % add this by CH, Feb 18, 2020 when dealing with disable saving of SAM files
                    [T_cab_V V_cab  SAT_cab_V fname_cab_V outXfer]=run_each_CabXfer_AQP(CabXfer_scheme,CT_prep,CP_prep,T_prep,V_prep,pfT,pfV,LT,LV,clistclslabel_V,locRT,locRV,inp4Val);
                end
            end
        end
    catch
        error('something wrong in running run_each_CabXfer_AQP')
        
    end
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('finish CabXfer_Siesler48_MLtool()')
end


%% ----- find_MatchConc_1stUniqueSampleNameOnly   [AQP_gui.m lines 7781-7789] --------------------
function out=find_MatchConc_1stUniqueSampleNameOnly(x,allC_T,allSampleName_T)
allSN=allSampleName_T(allC_T==x);
qSN=unique(allSN);
if ~isempty(qSN)
out=qSN{1};
else
   error('no match found in find_MatchConc_1stUniqueSampleNameOnly') 
end
end


%% ----- strmatch_empty2NaN   [AQP_gui.m lines 7803-7808] ----------------------------------------
function out=strmatch_empty2NaN(x,clistclslabel)
out=strmatch(x,clistclslabel,'exact');
if isempty(out)
    out=NaN;
end
end


%% ----- GLSstd2   [AQP_gui.m lines 8152-8214] ---------------------------------------------------
function [BadWgtMatrX,meandif,dif] = GLSstd2(mx,sx,alpha);
%GLSstd2 Develops standardization based on Generalized Least Squares
% The inputs are the transfer samples from the standard instrument (mx), 
% the transfer samples from the instrument to be standardized (sx), and
% the tolerance for matrix inversion (alpha), generally ~1e-6.
% The outputs are the weight matrix (BadWgtMatrX) and the mean difference
% between samples (meandif).
% 
% I/O: [BadWgtMatrX,meandif] = GLSstd2(mx,sx,alpha);
% see also  GLS_T_to_T_LSGLS  GLS_P_to_P_LSGLS   GLSstd2_wCTCP example_LSGLS_BW_MicroNIR  example_GLS_BW   GLS_BW_PR GLSstd3
%
%Copyright Eigenvector Research, Inc. 2001
%BMW  8/12/01
% find BadWgtMatrX based on minimize "dif" 
% which is equivalent to meancenter CT and meancenter CP then calculate the difference between meancentered CT vs meancentered CP
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[m,n] = size(mx);
if m==1
   error('you can not run GLS with only one transfer sample')
end

[m1 n1]=size(sx);
if m1~=m
   error('mx and sx should have same number of samples')
end

% Calculate the mean differences between instruments based on transfer samples

meandif = mean(mx-sx);  

% Adjust the transfer samples to be of the same mean
dif = mx-(scale(sx,-meandif));      %equivalent to meancenter CT and meancenter CP then calculate the difference between meancentered CT vs meancentered CP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check to see how was dif generated
if false
CT=mx;
CP=sx;
[mncn_CT mean_CT]=mncn(CT);
[mncn_CP mean_CP]=mncn(CP);
 %equivalent to meancenter CT and meancenter CP then calculate the difference between meancentered CT vs meancentered CP
dif_new=mncn_CT-mncn_CP; %equivalent to meancenter CT and meancenter CP then calculate the difference between meancentered CT vs meancentered CP

figure;hold on;
plot(dif','b-O');
plot(dif_new','m-*');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate downweight matrix
BadCovX = cov(dif);
BadCovX = BadCovX + eye(n)*alpha;
[v,s,v2]=svd(BadCovX);
BadEigenVals=diag(s);
BadEigenVals=BadEigenVals/mean(BadEigenVals);
BadSingVals=sqrt(BadEigenVals);
inds = find(BadSingVals > n*max(BadSingVals)*eps);
invBadSingVals = zeros(size(BadSingVals));
invBadSingVals(inds) = 1./BadSingVals(inds);
BadWgtMatrX=2*v*diag(invBadSingVals)*v';
end


%% ----- GLSstd3   [AQP_gui.m lines 8218-8263] ---------------------------------------------------
function [BadWgtMatrX,meandif,dif] = GLSstd3(mx,sx,alpha);
%based on GLSstd2 but without adjusting transfer samples to same mean
%GLSstd2 Develops standardization based on Generalized Least Squares
% The inputs are the transfer samples from the standard instrument (mx), 
% the transfer samples from the instrument to be standardized (sx), and
% the tolerance for matrix inversion (alpha), generally ~1e-6.
% The outputs are the weight matrix (BadWgtMatrX) and the mean difference
% between samples (meandif).
% 
% I/O: [BadWgtMatrX,meandif] = GLSstd2(mx,sx,alpha);

%Copyright Eigenvector Research, Inc. 2001
%BMW  8/12/01
[m,n] = size(mx);
if m==1
   error('you can not run GLS with only one transfer sample')
end

[m1 n1]=size(sx);
if m1~=m
   error('mx and sx should have same number of samples')
end

% Calculate the mean differences between instruments based on transfer samples

meandif = mean(mx-sx);  

% Adjust the transfer samples to be of the same mean
%dif = mx-(scale(sx,-meandif));

% withoutAdjust the transfer samples to be of the same mean, typically mx and sx (or CT and CP) have been meancenterd before fed into the program
dif = mx-sx;


% Generate downweight matrix
BadCovX = cov(dif);
BadCovX = BadCovX + eye(n)*alpha;
[v,s,v2]=svd(BadCovX);
BadEigenVals=diag(s);
BadEigenVals=BadEigenVals/mean(BadEigenVals);
BadSingVals=sqrt(BadEigenVals);
inds = find(BadSingVals > n*max(BadSingVals)*eps);
invBadSingVals = zeros(size(BadSingVals));
invBadSingVals(inds) = 1./BadSingVals(inds);
BadWgtMatrX=2*v*diag(invBadSingVals)*v';
end


%% ----- GLSstd_ApplyOn_UDM   [AQP_gui.m lines 8267-8296] ----------------------------------------
function  UDM_GLSstd  = GLSstd_ApplyOn_UDM(UDM_prep,modl_GLSstd)
% apply GLSstd2 or GLSstd3 on UDM dataset
% assuming UDM is used as Pset and MDC applied on Tset to match with Pset
% 'GLSstd2' and 'MDC_GLSstd3' are supposed to give same results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CabXfer_scheme=modl_GLSstd.opt4GLSstd.GLSstd_mode;

switch CabXfer_scheme
    case 'GLSstd2'
        %                 [BadWgtMatrX,meandif] = GLSstd2(CP_prep,CT_prep,alpha);
        %         %Apply the transform to all the samples in both sets
        %         T_prep_BWscale=scale(T_prep,-meandif);
        %         T_GLSstd = T_prep_BWscale*BadWgtMatrX;
        
        %         P_GLSstd = P_prep*BadWgtMatrX;
        
         % because assuming UDM is used as Pset and MDC applied on Tset to match with Pset
        % MDC_UDM is same as UDM
        UDM_GLSstd =   UDM_prep*modl_GLSstd.BadWgtMatrX;
    case 'MDC_GLSstd3'
        
        % because assuming UDM is used as Pset and MDC applied on Tset to match with Pset
        % MDC_UDM is same as UDM
        UDM_GLSstd =   UDM_prep*modl_GLSstd.BadWgtMatrX;
        
    otherwise
        error('opt4GLSstd.GLSstd_mode Not supported')
        
end
end


%% ----- KennardStone   [AQP_gui.m lines 8399-8452] ----------------------------------------------
function [idxTrn, idxRef] = KennardStone( mdY, nTrn)

% INPUT:
% mdY:          Spectra matrix
% Trn:          Number of Transfer Spectra to select
% 
% OUTPUT:
% idxTrn:       Indices for transfer spectra selected from spectra matrix mdY
% idxRef:       Indices for reference spectra selected from the spectra matrix mdY
%
% DESCRIPTION:
%       Calculates the index vectors to splits the spectra matrix 
%       mdY into transfer and reference set
if nTrn==1 | nTrn==2
    
    if nTrn==1
        error('nTrn must be at least 2')
    else
        sel = kennardstone(mdY, nTrn);
        idxTrn=find(sel==1);
        idxRef=find(sel~=1);
    end
    
    
else
    
    [mY, nY] = size( mdY );
    idxTrn = zeros( nTrn, 1 );
    mdYorg = mdY;
    
    [ dummy, idxTrn1 ] = min( SpcDistance( mean( mdY),  mdY ) );
    idxTrn(1) = idxTrn1;
    mdY( idxTrn1, : ) = NaN;
    
    [dummy, idxTrn2]= max( SpcDistance( mdY(idxTrn(1),:), mdY) );
    idxTrn(2) = idxTrn2;
    mdY( idxTrn2, : ) = NaN;
    
    for iTrn = 3:nTrn
        mdDist  = SpcDistance( mdY, mdYorg(idxTrn(1:iTrn-1),:) );
        vdMinNN = min( mdDist );
        [dummy idxMaxNN] = max( vdMinNN );
        idxTrn( iTrn ) = idxMaxNN;
        mdY( idxMaxNN, : ) = NaN;
    end
    
    idxRef = [1:mY]';
    idxRef( idxTrn ) = [];
    
    idxTrn = sort( idxTrn );
    idxRef = sort( idxRef );
    q = 0;
end
end


%% ----- LoadXlsx4AQP   [AQP_gui.m lines 8456-8666] ----------------------------------------------
function OutLX=LoadXlsx4AQP(pathfname_Orig_CS_xlsx,AnaName,inp4LoadXLSX)
% this can be used to load CS, XRS, Val, and UDM
% modified from CabXferLite.m  LoadMst_Callback(hObject, eventdata, handles)
%     following added Oct 21, 2019
%     get ID of XRS only and return and use to find matching ID samples in CS to serve as XSmst
%
%  this function within AQP_gui.m is called by --> XLSX2MAT_AQP
%  will call --> prep_IDRC_shootout_MLtool
%------------------------------------------------------------------
% see also: prep_Cannabis_repmat_property_replicates (for calling uicellect)
%=============================================================================================
 % fix input xlsx file with additional data to right of wvl block by new approach --> [idx_wvl loc_wvl]= find_wvl_range_cheading(cheading)
    % added this Nov 9, 2020
%=============================================================================================
    
if false
    
    clear
    AnaName='Brix';
    pathfname_Orig_CS_xlsx='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21\CS_sugarcane_FOSS_4Cmp_nsamp102_exclude21UDM_XS30wNaN.xlsx';
    LoadXlsx4AQP(pathfname_Orig_CS_xlsx,AnaName,inp4LoadXLSX)
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     [NUM,TXT,RAW]=xlsread(fullfile(INPpathname, INPfilename_orig));
try
[NUM,TXT,RAW]=xlsread(pathfname_Orig_CS_xlsx);
catch
    disp('halt for dealing with CS-Only for non-MN master')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % fix input xlsx file with additional data to right of wvl block by new approach --> [idx_wvl loc_wvl]= find_wvl_range_cheading(cheading)
    % added this Nov 9, 2020
  cheading=RAW(1,:);
     [idx_wvl   loc_wvl  ]= find_wvl_range_cheading(cheading);
    locNOT_NaN_NUM=find(~isnan(NUM(1,:)));
     
     loc_wvl_NUM= loc_wvl - (  loc_wvl(1) - locNOT_NaN_NUM(1) );
     
    RAW(:,loc_wvl(end)+1:end)=[];
    TXT(:,loc_wvl(end)+1:end)=[];
    TXT=TXT(1,:);
     TXT=remove_empty_cell(TXT);                        % added Nov 6, 2020
     NUM(:, loc_wvl_NUM(end)+1:end)=[];



%=================================================================
if false  % block old method that is less clean
    loc_Instrument=find(strfind_cstr('Instrument',TXT(1,:)));% added Nov 6, 2020
    if ~isempty(loc_Instrument)
        RAW(:,loc_Instrument:end)=[];
        locNaN_NUM= find(isnan(NUM(1,:)));
        if ~isempty( locNaN_NUM)
            NUM(:, locNaN_NUM(1):end)=[];
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% trim all NaN col or row
% trim all NaN rows
loc_allNaN_row=[];
for ir=1:length(RAW(:,1))
    eaRAW=RAW(ir,:);
    idx_num=all(cellfun(@(x) isnumeric(x),eaRAW));
    if idx_num
        allNaN= all(cellfun(@(x) isnan(x),eaRAW));
        if  allNaN
            loc_allNaN_row=[loc_allNaN_row;ir];
        end
    end
end
% trim all NaN cols
loc_allNaN_col=[];
for ic=1:length(RAW(1,:))
    eaRAW1=RAW(:,ic);
    idx_num=all(cellfun(@(x) isnumeric(x),eaRAW1));
    if idx_num
        allNaN= all(cellfun(@(x) isnan(x),eaRAW1));
        if  allNaN
            loc_allNaN_col=[loc_allNaN_col;ic];
        end
    end
end

RAW(loc_allNaN_row,:)=[];
RAW(:,loc_allNaN_col)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TXT=TXT(1,:);
%=================================================================
if false  % block old method that is less clean
    if ~isempty(loc_Instrument)                  % added Nov 6, 2020
        TXT(loc_Instrument:end)=[];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get ID of XRS only and return and use to find matching ID samples in CS to serve as XSmst
% 
try
    if inp4LoadXLSX.XRS_ID_only_yes && strcmp(inp4LoadXLSX.CS_XRS_Val,'XRS')
        ID_XRS=RAW(2:end,find(strcmp(TXT,'ID')));
        OutLX.ID_XRS=ID_XRS;
        return
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if there were NaN in RS, this will make all column headings (TXT) became
% empty till the last column that still contain NaN
%
if ~isempty(find(cellfun(@(x) isempty(x),TXT)))
    loc_empty_TXT=find(cellfun(@(x) isempty(x),TXT));
    loc_Real_RS_start=loc_empty_TXT(1);
    nvar_real=length(RAW(1,:))-loc_Real_RS_start+1;
    RawSpectra_ifile_checking=NUM(2:end,end-nvar_real+1:end);
    
    if ~isempty( find(isnan(RawSpectra_ifile_checking(:))) )
        N_NaN=length( find(isnan(RawSpectra_ifile_checking(:))));
        error([num2str(N_NaN),' spectra readings were NaN inside RawSpectra'])
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find AnaName in CS only
% use regexp to find loc for info* column

if strcmp(inp4LoadXLSX.CS_XRS_Val,'CS')
    loc_info_etc=detect_info_etc_CXL(TXT);
    
    ncol4info= length( find(loc_info_etc));
    clistAna_in_CS=TXT(1+ncol4info+1:end);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(clistAna_in_CS)>1
        Speak_mk('please pick the analyte you want to analyze');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % input thru a GUI dlg box style by calling "uicellect"
        %   % - Create a length nAna cell array of Items
        %         theCell = cellfun(@sprintf,repmat({'Item %d'},25,1), num2cell((1:25)'),'Unif',false);
        theCell=col_always(clistAna_in_CS);
        %   % - Present in GUI and disable Multi-Selection
        [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 0);
        %clistAna_in_CS=theChosenAna;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % input thru command window
        %                 sialistAna_in_CS=string(clistAna_in_CS)+'('+[1:length(clistAna_in_CS)]+')';
        %         clistAna_in_CS=sialistAna_in_CS.cellstr;
        %         disp(['List of Analyte : ', strwrite_all_space( row_always(clistAna_in_CS) ) ]);
        %         AnaSeq= input('analyte seq number= ');
        %         clistAna_in_CS=clistAna_in_CS(AnaSeq);
        %         clistAna_in_CS={find_keyword_between_markers(clistAna_in_CS{1},'','(')};
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        disp('since there is only one analyte, it will be picked automatically')
        theChosenAna=clistAna_in_CS;  % use cell data type
    end
 OutLX.AnaName=theChosenAna;
 AnaName=theChosenAna;
else
 OutLX.AnaName=AnaName;   
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
INPpathname=fileparts(pathfname_Orig_CS_xlsx);
%%%%%
inp.CS_XRS_Val=inp4LoadXLSX.CS_XRS_Val; % 'CS' 'XRS'  'Val' 'UDM'


pathIDRC=INPpathname;  % mA123
inp.PP_methods.pp1='none' ;inp.PP_methods.pp2='none';   %  '1stDerSGw41'  '1stDerSGw21'  'SampMncn' 'SGw5'   '1stDerSGDiederick'  'none' '1stDer'   '2ndDer'

inp.AnaName='';
inp.CSn='123';  % for A1, A2, and A3, and B1, B2, and B3
%inp.Col4Ref=find_keynumber_numeric_AFTER_marker( handles.Col4Ref.String{handles.Col4Ref.Value},'Col4Ref=');
inp.Col4Ref='';  % this will be decided inside prep_IDRC_shootout_MLtool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hard-coded Col4Info_1 to 2
% pls see also: prep_IDRC_shootout_MLtool()
if inp.Col4Ref>=4
    try
        inp.Col4Info_1=2;
    catch
        inp.Col4Info_1='';
    end
else
    inp.Col4Info_1='';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% in the following AnaName will be inserted into inp.handles.sAnalyte that goes into prep_IDRC_shootout_MLtool(pathIDRC,inp)
handles.sAnalyte.String={AnaName};  
handles.sAnalyte.Value=1;
%              handles=''; % modified later for LoadMst_xlsx4AQP
inp.handles=handles;
try
inp.ID_XRS=inp4LoadXLSX.ID_XRS;
end
inp.Spectra_Avg_Method=inp4LoadXLSX.Spectra_Avg_Method;
out= prep_IDRC_shootout_MLtool(pathIDRC,inp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add the following Oct 20, 2019
try
OutLX.pathfname_CalSet_MAT=out.pathfname_CalSet_MAT;
end
try
OutLX.fname_XSwoRef=out.fname_XSwoRef;
end
end


%% ----- MD_TO_p_value   [AQP_gui.m lines 8677-8749] ---------------------------------------------
function p_value=MD_TO_p_value(MD,df)
% see also:  p_value_TO_MD   z_score_TO_p_value
% see also:  p_value_TO_MD
%==============================================================
if false
    
      MD=1.91887;df=2;    % z=1 in normcdf
    p=MD_TO_p_value(MD,df)
    %-----------------------------------------
    MD=2.7507;df=2;       % z=2 in normcdf
    p=MD_TO_p_value(MD,df)
    %-----------------------------------------
      MD=3.63531;df=2;    % z=3 in normcdf
    p=MD_TO_p_value(MD,df)
    %=============================================
    MD=1;df=2;              % 
    p=MD_TO_p_value(MD,df)
    %------------------------------------------
      MD=2;df=2;            %
    p=MD_TO_p_value(MD,df)
    %------------------------------------------
      MD=3;df=2;            %
    p=MD_TO_p_value(MD,df)
    %------------------------------------------
    %===============================================
    % one of current settings in rPCA
    % Feb 2, 2024
        MD=2.8;df=3;            %
    p=MD_TO_p_value(MD,df)
    %--------------------------------------------
      % 2nd one of current settings in rPCA
      % Feb 2, 2024
        MD=2.5;df=3;            %
    p=MD_TO_p_value(MD,df)
     %===============================================
     % revisit with test_two_normpdf_ttest2
        MD=2.38;df=2;       % z=2 in normcdf
    p=MD_TO_p_value(MD,df)
    %---------------------------------------
        % revisit with test_two_normpdf_ttest2
        MD=1.63;df=2;       % z=2 in normcdf
    p=MD_TO_p_value(MD,df)
     
     
end
%--------------------------------------------------
%===============================================================
% if false
%     % by ChatGPT
%     % Calculate p-value using chi2cdf
%     mahalanobis_dist=MD^2;
%     p_value = 1 - chi2cdf(mahalanobis_dist, df);
% end
% %---------------------------------------------
% if false
%     % by CMH
%     mahal_X=MD^2;
%     p_chi = chi2cdf( mahal_X , df ) ;
%     
%     chi2_p=1-p_chi;
% end
%--------------------------------------
% Use MATLAB's mahal function to calculate Mahalanobis distance
% mahalanobis_dist = mahal(data, mu, inv(Sigma));

% Degrees of freedom (number of dimensions in your data)
% df = size(data, 2);

%=========================================================================
% Calculate p-value using chi2cdf
mahalanobis_dist=MD.^2; % this should be "square of MD"   % this should be "square of MD" % this should be "square of MD"
p_value = 1 - chi2cdf(mahalanobis_dist, df);    % this is "square of MD"
end


%% ----- ML2Sam   [AQP_gui.m lines 8759-8861] ----------------------------------------------------
function errorStr = ML2Sam(ID,absorbance,refVals,inp)
% called by --> CabXfer_Siesler48_MLtool
% This function generates .sam files for the dataset given in the input
% arguments (1 file/scan). It also copys the reference Y values onto the
% clipboard to copy into MicroNIR Pro for convenience. The output is an
% error string which will display the return status, indicating where the
% error occurred. If there is no error, then it will be empty.

%Inputs
%   ID:         cell array containing the scan names
%   absorbance: 2D double array containing the aborbance values of the
%               dataset
%   refVals:    1D double array containing the reference Y values


%% Initialize output
errorStr = [];

%% Select folder and create new directory
%User to select a folder 
try
mainPath=    inp.path4Sam;
catch
mainPath = uigetdir(pwd,'Select the Folder to save the .sam Files');
end
%If the selection was cancelled, ask the user to either quit the program or
%reselect the folder.
while isnumeric(mainPath)
    YN = questdlg('Folder Selection Cancelled. Retry?','Cancelled','Yes','No','Yes');
    if strcmp(YN,'No')
        msgbox('Process Cancelled. Closing Program.','Closing');
        errorStr = [errorStr,'User cancelled folder selection.'];
        return;
    else
        mainPath = uigetdir(pwd,'Select the Folder to save the .sam Files');
    end
end

%% Create new subfolder in mainPath
%start with folder 001
% startIdx = 1;
 newFolder = fullfile(mainPath,'Sam');
% 
% %if this folder exists, try 002, etc.
% while exist(newFolder,'dir')
%     startIdx = startIdx + 1;
%     newFolder = fullfile(mainPath,num2str(startIdx,'%03.f'));
% end

%once a new folder has been determined, create it.
mkdir(newFolder);


%% Ensure that the sample names are unique. If not, append a number to them
[uID,~,idxUniqueName] = unique(ID);
for iName = 1:length(uID)
    idx = find(idxUniqueName==iName);
    ID{idx(1)} = [ID{idx(1)},'-1'];
    for iDup = 2:length(idx)
        ID{idx(iDup)} = [ID{idx(iDup)},'-',num2str(iDup)];
    end
end

%% Loop through dataset to create array of classes to pass
%Get the total number of scans
numScans = length(ID);

%create array
dataSetArray = NET.createArray('VIAVI.SamLib.AqpLiteRow',numScans);

%start with the end to initialize the size of the structure
allScans(numScans).class = VIAVI.SamLib.AqpLiteRow();
allScans(numScans).class.SampleName = ID{numScans};
allScans(numScans).class.SamFileName = fullfile(newFolder,[ID{numScans},'.sam']);
allScans(numScans).class.Absorbance = absorbance(numScans,:);
allScans(numScans).class.Y = refVals(numScans,1);
dataSetArray.Set(numScans-1,allScans(numScans).class);

%Loop through and all the rest of the scans to the structure array
for iScan = 1:length(ID)-1
    allScans(iScan).class = VIAVI.SamLib.AqpLiteRow();
    allScans(iScan).class.SampleName = ID{iScan};
    allScans(iScan).class.SamFileName = fullfile(newFolder,[ID{iScan},'.sam']);
    allScans(iScan).class.Absorbance = absorbance(iScan,:);
    allScans(iScan).class.Y = refVals(iScan,1);
    dataSetArray.Set(iScan-1,allScans(iScan).class);  %adjust for 0-based indexing
end

%% Create .sam files and copy the Y values to the clipboard
% The return value is an AqpLiteResult instance. The AqpLiteResult has 
% properties of Success and Message. Where Success is a boolean indicating 
% success or failure of the task. The Message will be an empty string if 
% everthing succeeded. Otherwise it will contain an error message. (Which 
% could be quite long).

result = VIAVI.SamLib.AqpLiteExport.ToSamFiles(dataSetArray);
if ~result.Success
    errorStr = [errorStr,char(result.Message)];
    return;
end
copy(char(result.StringForClipboard));

end


%% ----- Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool   [AQP_gui.m lines 9160-9454] --------------
function out=Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool(pathfname_HiRes,pathfname_LoRes,pathfname_LoRes_Val,inp)
% Match spectra from two different Manufacturer with different wvl ranges
% this function has been called by --> XLSX2MAT_AQP
% and different resolutions
% % deal with non-MN CS woXRS but with MN-Val, Nov 20, 2020
% see also   prep_IDRC_shootout()   match_wavelength_Desktop2MicroNIR()  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if false


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1stDer  ManuA
      clear;close all;
inp.seq_pp_vs_matchgrids='pp-After-MatchGrids';   %  'pp-Before-MatchGrids'  'pp-After-MatchGrids'
inp.force_pp.pp1='1stDerSGw13';inp.force_pp.pp2='SampMncn';

%pathfname_HiRes='C:\work\JDSU\IDRC_ShootOut\ATsaConc_ManuA\1stDer\Atrainpketc_saConc_IDRC_(ManufacturerA_Cal_CalSetA1)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar737_nsamp248.mat';
% pathfname_HiRes='C:\work\JDSU\IDRC_ShootOut\ATsaConc_ManuA\1stDer\A2\Atrainpketc_saConc_IDRC_(ManufacturerA_Cal_CalSetA2)_pp1-1stDerSGw5_pp2-SampMncn_nvar737_nsamp248.mat'
% pathfname_HiRes='C:\work\JDSU\IDRC_ShootOut\ATsaConc_ManuA\1stDer\Test\Atrainpketc_saConc_IDRC_(ManufacturerA_Test)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar737_nsamp248.mat'
pathfname_HiRes='C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\A_B_Val_1stDerSGw5\Atrainpketc_saConc_IDRC_(ManufacturerA_Val)_pp1-1stDerSGw5_pp2-SampMncn_nvar737_nsamp150.mat'
pathfname_LoRes='C:\work\JDSU\IDRC_ShootOut\ATsaConc_ManuC\1stDer\Atrainpketc_saConc_IDRC_(ManufacturerC_Test)_pp1-1stDerSGw5_pp2-SampMncn_nvar96_nsamp248.mat';
 pathfname_LoRes_Val='';

out= Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool(pathfname_HiRes,pathfname_LoRes,pathfname_LoRes_Val,inp);
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

       clear;close all;
inp.seq_pp_vs_matchgrids='pp-After-MatchGrids';   %  'pp-Before-MatchGrids'  'pp-After-MatchGrids'
inp.force_pp.pp1='SGw5';inp.force_pp.pp2='SampMncn';
     pathfname_HiRes='C:\work\JDSU\SieslerPharma_Quant\Bruker\ATsaConc\orig_WL\SGw5\Lbu_1\Atrainpketc_saConc_Bruker_DX_Siesler48_pp1-SGw5_pp2-SampMncn_nvar747_nsamp336_ncls48_Lbu_1.mat'
      pathfname_LoRes='C:\work\JDSU\SieslerPharma_Quant\ATsaConc\ES17\SGw5\Atrainpketc_saConc__Absorbance_S1-00553xls_PharmaLib(S1-00553)_pp1-SGw5_pp2-SampMncn_nvar125_nsamp955_ncls48.mat'
  pathfname_LoRes_Val='C:\work\JDSU\SieslerPharma_Quant\ATsaConc\ES17\SGw5\Atrainpketc_saConc__Absorbance_S1-00552xls_PharmaLib(S1-00552)_pp1-SGw5_pp2-SampMncn_nvar125_nsamp960_ncls48.mat';
out= Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool(pathfname_HiRes,pathfname_LoRes,pathfname_LoRes_Val,inp);

 
 

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fig_yes=0;
if isa(pathfname_HiRes,'struct') && isa(pathfname_LoRes,'struct')
    Lhr=pathfname_HiRes;
    Llr=pathfname_LoRes;
    pathfname_HiRes=inp.pathfname_HiRes;
    pathfname_LoRes=inp.pathfname_LoRes;
    
    
elseif    ischar(pathfname_HiRes) && isempty(pathfname_LoRes) &&  ischar(pathfname_LoRes_Val ) && ~isempty(pathfname_LoRes_Val)  % deal with woXRS but with MN-Val, Nov 20, 2020
    % deal with woXRS but with MN-Val, Nov 20, 2020
      Lhr=load(pathfname_HiRes);
      [lia_hr,locb_hr]=ismembertol(Lhr.wvl_standardize,get_MN_wvl,1e-3);    % tol of 1e-3 should be enough
     Llr=load(pathfname_LoRes_Val);                                                                                                                                                                            % deal with non-MN CS woXRS but with MN-Val, Nov 20, 2020
    [lia_lr,locb_lr]=ismembertol(Llr.wvl_standardize,get_MN_wvl,1e-3);    % tol of 1e-3 should be enough
    if all(lia_hr) & all(lia_lr)                                                                                                                                                           % woXRS and wVal and both CS and Val based on MN grids
            out='';     % woXRS and wVal and both CS and Val based on MN grids    % woXRS and wVal and both CS and Val based on MN grids  % woXRS and wVal and both CS and Val based on MN grids    % woXRS and wVal and both CS and Val based on MN grids
            return;
    else
        % woXRS and wVal and CS-nonMN but Val based on MN grids% woXRS and wVal and CS-nonMN but Val based on MN grids% woXRS and wVal and CS-nonMN but Val based on MN grids% woXRS and wVal and CS-nonMN but Val based on MN grids
        Lhr=load(pathfname_HiRes);
        Llr=load(pathfname_LoRes_Val);
        pathfname_LoRes=pathfname_LoRes_Val;
    end
    
else
    % this is can be the case that all 3 datasets exist, CS+XRS+Val  or CS-only
    %
    if ~isempty(pathfname_LoRes)
        % this is can either be the case that all 3 datasets exist, CS+XRS+Val   OR    only CS+XRS but woVal
        Lhr=load(pathfname_HiRes);
        Llr=load(pathfname_LoRes);
    else
        % CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only% CS only
        out='';                                                 % CS only
        return;
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try  % add this to handle AQP cases without "inp.seq_pp_vs_matchgrids"
if strcmp(inp.seq_pp_vs_matchgrids,'pp-Before-MatchGrids')
    disp('doing preprocessing BEFORE MatchGrids !!!')  ;
    pp1=inp.force_pp.pp1;
    pp2=inp.force_pp.pp2;
    
    Lhr=pp_Li(Lhr,pp1,pp2);
    Nwvl_trim_eachside=(length(Lhr.RawSpectra(1,:))-length(Lhr.Atrainpk(1,:)))/2;
    
    %     Nwvl_RS=length(Lhr.RawSpectra(1,:));
    %
    %     Nwvl_AT=length(Lhr.Atrainpk(1,:));
    %     Nwvl_EachSide=(Nwvl_RS-Nwvl_AT)/2;
    try
        Lhr.wvl_AT=Lhr.wvl(Nwvl_trim_eachside+1:end-Nwvl_trim_eachside);
    catch
        Lhr.wvl_AT=Lhr.wvl_standardize(Nwvl_trim_eachside+1:end-Nwvl_trim_eachside);
    end
    Llr=pp_Li(Llr,pp1,pp2);
end
end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure;hold on;
% plot(Lhr.wvl_standardize,Lhr.RawSpectra,'b-*');
% plot(Llr.wvl_standardize,Llr.RawSpectra,'g-*');
if fig_yes
figure;hold on;
plot(Lhr.wvl_standardize,Lhr.Atrainpk,'b-*');
plot(Llr.wvl_standardize,Llr.Atrainpk,'g-O');
end
%%%%%%%%%%%%%%%%%%%%%%%
try
wvl_HR=Lhr.wvl_standardize;
catch
wvl_HR=Lhr.wvl;
Lhr.wvl_standardize=wvl_HR;
end
wvl_LR=Llr.wvl_standardize;

if fig_yes
figure;hold on;
inp4HR.str_plot='b-*';
plot_wvl_grids(wvl_HR,inp4HR);
inp4LR.str_plot='g-O';
inp4LR.MarkerSize=12;
plot_wvl_grids(wvl_LR,inp4LR);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  wvl_common=intersect(wvl_HR,wvl_LR);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% new and more general way to find "wvl_standardize_common"
% common_to_MN=intersect(wvl_standardize_common,Lmn.wvl_standardize);
if isSAME_2Matrix(wvl_LR,wvl_HR)
  wvl_common=wvl_LR;  
else
lowEnd_MN=min(wvl_LR);
lowEnd_DT=min(wvl_HR);
lowEnd_LHS=max([lowEnd_MN lowEnd_DT]);

hiEnd_MN=max(wvl_LR);
hiEnd_DT=max(wvl_HR);
hiEnd_RHS=min([hiEnd_MN hiEnd_DT]);

loc_wvl_standardize_common_NewApproach_LHS=find(wvl_LR>=lowEnd_LHS,1,'first');
loc_wvl_standardize_common_NewApproach_RHS=find(wvl_LR<=hiEnd_RHS,1,'last');

wvl_standardize_common_NewApproach=wvl_LR(loc_wvl_standardize_common_NewApproach_LHS:loc_wvl_standardize_common_NewApproach_RHS);

%checking
% if ~isSAME_2Matrix(wvl_standardize_common_NewApproach,wvl_common)
%     error('mismatch between new vs old approach');
% else
    wvl_common=wvl_standardize_common_NewApproach;
% end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inp4common.seq_pp_vs_matchgrids=inp.seq_pp_vs_matchgrids;
inp4common.PP_methods.pp1=inp.force_pp.pp1;
inp4common.PP_methods.pp2=inp.force_pp.pp2;

inp4common_Lo=inp4common;
inp4common_Lo.Path_tmpfolder=tmp_folder_rm_mk('TMP\MGs_PP_Trg',pwd);
[Llr_Matched pathfname_Matched_Llr ]=ATsaConc2wvlcommon(Llr,wvl_common,pathfname_LoRes,inp4common_Lo);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Nwvl_trim_eachside_Llr_Matched=(length(Llr_Matched.RawSpectra(1,:))-length(Llr_Matched.Atrainpk(1,:)))/2;
%     Lhr.wvl_AT=Lhr.wvl(Nwvl_trim_eachside+1:end-Nwvl_trim_eachside);

wvl_common_AT_Llr=wvl_common(Nwvl_trim_eachside_Llr_Matched+1:end-Nwvl_trim_eachside_Llr_Matched);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if length(wvl_common)==length(wvl_LR)
%     disp('grids of Lo-Res are subset of Hi-Res')
% else
    disp('this case is based on new more general approach');
    
    %     Atrainpk_NEW_dt_match_mn= interp1_CH(Ldt.wvl_AT,Ldt.Atrainpk,wvl_standardize_common_AT);
    
    RawSpectra_NEW_hr_match2common= interp1_CH(Lhr.wvl_standardize,Lhr.RawSpectra,wvl_common);
    Lhr.RawSpectra= RawSpectra_NEW_hr_match2common;
    
    wvl_common_AT=wvl_common_AT_Llr;
    
    try
        if isSAME_2Matrix(wvl_LR,wvl_HR)
             AT_NEW_hr_match2common= Lhr.Atrainpk;
        else
        AT_NEW_hr_match2common= interp1_CH(Lhr.wvl_AT,Lhr.Atrainpk,wvl_common_AT);
        end
        
    catch
        %       Lhr.wvl_AT
%         try
%             AT_NEW_hr_match2common= interp1_CH(Lhr.wvl_standardize,Lhr.Atrainpk,wvl_common_AT);
%             
%         catch
            Nwvl_trim_eachside=(length(Lhr.RawSpectra(1,:))-length(Lhr.Atrainpk(1,:)))/2;
            if Nwvl_trim_eachside<0 % deal with IDRC data 
                
%             Lhr.wvl_AT=Lhr.wvl_standardize(Nwvl_trim_eachside+1:end-Nwvl_trim_eachside);
%             AT_NEW_hr_match2common= interp1_CH(Lhr.wvl_AT,Lhr.Atrainpk,wvl_common_AT);
            AT_NEW_hr_match2common='';% deal with IDRC data 
            end
%         end
        
        
        
    end
    
    
    
    
    Lhr.Atrainpk= AT_NEW_hr_match2common;
    
    
    %     Lhr.Atrainpk='';
    Lhr.wvl_standardize=wvl_common;
    try Lhr.wvl='';end
    try Lhr.wvl_AT=wvl_common_AT;end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inp4common_Hi=inp4common;
inp4common_Hi.Path_tmpfolder=tmp_folder_rm_mk('TMP\MGs_PP_Mst',pwd);

[Lhr_Matched pathfname_Matched_Lhr ]=ATsaConc2wvlcommon(Lhr,wvl_common,pathfname_HiRes,inp4common_Hi);


DS.pathfname_MGs_PP_Mst=pathfname_Matched_Lhr;
DS.pathfname_MGs_PP_Trg_XS=pathfname_Matched_Llr;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following section added to deal with CS contain XSmst with RefNaN
try
Lhr_XSmst=inp.DS.Lmst_orig_XSmst;
pathfname_HiRes_XSmst=inp.DS.pathfname_HiRes_XSmst;

inp4common_HiXS=inp4common;
inp4common_HiXS.Path_tmpfolder=tmp_folder_rm_mk('TMP\MGs_PP_XSmst',pwd);

    RawSpectra_NEW_hr_match2common_XSmst= interp1_CH(Lhr_XSmst.wvl_standardize,Lhr_XSmst.RawSpectra,wvl_common);
    Lhr_XSmst.RawSpectra= RawSpectra_NEW_hr_match2common_XSmst;
    Lhr_XSmst.Atrainpk='';
    Lhr_XSmst.wvl_standardize=wvl_common;

[Lhr_Matched_XSmst pathfname_Matched_Lhr_XSmst ]=ATsaConc2wvlcommon(Lhr_XSmst,wvl_common,pathfname_HiRes_XSmst,inp4common_HiXS);


DS.pathfname_MGs_PP_XSmst=pathfname_Matched_Lhr_XSmst;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(pathfname_LoRes_Val)
    if isa(pathfname_LoRes_Val,'struct')
        Llr_Val=pathfname_LoRes_Val;
        pathfname_LoRes_Val=inp.pathfname_LoRes_Val;
    else
        Llr_Val=load(pathfname_LoRes_Val);
    end
    
if strcmp(inp.seq_pp_vs_matchgrids,'pp-Before-MatchGrids')
  disp('doing preprocessing BEFORE MatchGrids for Val set!!!')  
       Llr_Val=pp_Li(Llr_Val,pp1,pp2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inp4common_Lo_Val=inp4common;
    inp4common_Lo_Val.Path_tmpfolder=tmp_folder_rm_mk('TMP\MGs_PP_Trg_Val',pwd);
        [Llr_Matched_Val pathfname_Matched_Llr_Val ]=ATsaConc2wvlcommon(Llr_Val,wvl_common,pathfname_LoRes_Val,inp4common_Lo_Val);
        
        DS.pathfname_MGs_PP_Trg_Val=pathfname_Matched_Llr_Val;

end

% [Llr_Matched pathfname_Matched_Llr ]=ATsaConc2wvlcommon(Llr,wvl_common,pathfname_LoRes);




out.DS=DS;
disp('finish Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool()');
end


%% ----- pp_Li   [AQP_gui.m lines 9457-9468] -----------------------------------------------------
function Lnew=pp_Li(Li,pp1,pp2)
  Lnew=Li;
%   pp1=inp.force_pp.pp1;
        [rawSpectra_aftPP1 spp1]=preprocess_NIR_spectra(Li.RawSpectra,pp1);
%   pp2=inp.force_pp.pp2;

        [rawSpectra_aftPP2 spp2]=preprocess_NIR_spectra(rawSpectra_aftPP1,pp2);
        Lnew.Atrainpk=rawSpectra_aftPP2;
        for isamp=1:length(Lnew.saConc)
        Lnew.saConc(isamp).Atrainpk=Lnew.Atrainpk(isamp,:);
        end
end


%% ----- ATsaConc2wvlcommon   [AQP_gui.m lines 9484-9567] ----------------------------------------
function [L_Matched pathfname_Matched ]=ATsaConc2wvlcommon(L,wvl_common,pathfname,inp)
Lnew=L;


loc_wvl_common=find_belong2subgrp(L.wvl_standardize,wvl_common);
loc_rm=setdiff([1:length(L.wvl_standardize)],loc_wvl_common);


if ~isempty(L.Atrainpk)
    
    if  length(L.Atrainpk(1,:))==length(L.RawSpectra(1,:))
        loc_rm_AT=loc_rm;
    else
        Nwvl_rm4AT_eachside=(   length(L.RawSpectra(1,:))- length(L.Atrainpk(1,:)) )/2;
        loc_wvl_common_AT= loc_wvl_common(Nwvl_rm4AT_eachside+1:end-Nwvl_rm4AT_eachside );
        wvl_common_AT=L.wvl_standardize(loc_wvl_common_AT);
        wvl_L_AT=L.wvl_standardize(Nwvl_rm4AT_eachside+1:end-Nwvl_rm4AT_eachside );
        loc_wvl_common_AT_in_L_AT= find_belong2subgrp(wvl_L_AT,wvl_common_AT);
        
        loc_rm_AT_in_L_AT=setdiff([1:length(L.Atrainpk(1,:))],loc_wvl_common_AT_in_L_AT);
        %   tmp_wvl_common_AT=delsamps( wvl_L_AT',loc_rm_AT_in_L_AT);
        loc_rm_AT= loc_rm_AT_in_L_AT;
        
        %  L.wvl_standardize(loc_wvl_common_AT)
        
    end
    
else
    disp('skip above only for IDRC dataset')
    
end

Lnew.wvl_standardize(loc_rm)=[];
Lnew.RawSpectra(:,loc_rm)=[];

switch inp.seq_pp_vs_matchgrids
    case  'pp-Before-MatchGrids'
        Lnew.Atrainpk(:,loc_rm_AT)=[];
        [Lnew.saConc.Atrainpk]=SAinsert_cell2cell( arrayfun(@(x) delsamps(x.Atrainpk',loc_rm_AT)',Lnew.saConc,'un',0))
    case  'pp-After-MatchGrids'
        disp('this will apply preprocssing AFTER match grids !!!')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pp1=inp.PP_methods.pp1;pp2=inp.PP_methods.pp2;
        
        % if all(isnan(Lnew.RawSpectra(:))) && strcmp(pp1,'none') && strcmp(pp2,'none')
                 if all(isnan(Lnew.RawSpectra(:))) 
   
            disp('this is supposed to be "PPd" AT file and will NOT copy RawSpectra to Atrainpk')
            disp('instead Atrainpk will stay and do not need to do anything');
            
        else
            
            [rawSpectra_aftPP1 spp1]=preprocess_NIR_spectra(Lnew.RawSpectra,pp1);
            
            [rawSpectra_aftPP2 spp2]=preprocess_NIR_spectra(rawSpectra_aftPP1,pp2);
            Lnew.Atrainpk=rawSpectra_aftPP2;
            for isamp=1:length(Lnew.saConc)
                Lnew.saConc(isamp).Atrainpk=Lnew.Atrainpk(isamp,:);
            end
            
        end
        
end
%L.wvl_standardize(loc_wvl_common)

% isSAME_2Matrix( Lnew.saConc(10).Atrainpk,Lnew.Atrainpk(10,:))
pathfname_Matched=strrep(fileparts_name_ext(pathfname),'.mat',['_',inp.seq_pp_vs_matchgrids,'_Matched2ManuC.mat']);  % hard-coded for IDRC
pathfname_Matched=strrep(pathfname_Matched,'1stDerSGDiederick','1stDerSGw5');
pathfname_Matched=strrep_keyword_between_markers(pathfname_Matched,'_nvar','_',num2str(length(Lnew.Atrainpk(1,:))));


pathfname_Matched=strrep_keyword_between_markers(pathfname_Matched,'_pp1-','_',inp.PP_methods.pp1);
pathfname_Matched=strrep_keyword_between_markers(pathfname_Matched,'_pp2-','_',inp.PP_methods.pp2);

pathfname_Matched=[inp.Path_tmpfolder,'\',pathfname_Matched];
save(pathfname_Matched,'-struct','Lnew');
disp([pathfname_Matched,' has been saved']);

L_Matched=Lnew;


disp('finish converting ATsaConc to new wvl_common')
end


%% ----- PLS_Scv   [AQP_gui.m lines 9571-9924] ---------------------------------------------------
function out=PLS_Scv(OrigCS,ScoutCS,inp)
% modified from PLS_Tcv() called by 
% see also PLS_Tcv split_vector_into_equal_sized_bins
if false
    
    inp.Tcv_scheme='Leave-OneSample-Out';
         inp.stitle=CurAna;
    out=PLS_Scv(X,Y,cSampleName,inp);
    
end
% plsregress(X,Y,ncomp,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unwrap and prepare X,Y,cSampleName that are used in PLS_Tcv() but now
% based on ScoutCS
X=ScoutCS.X;
Y=ScoutCS.Y;
cSampleName=ScoutCS.cSampleName;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try cSampleName=cell2mat_ccstr2cstr(cSampleName);end

PLSfactor= inp.PLSfactor;
% KPplus=inp.KPplus;
Tcv_scheme=inp.Tcv_scheme;
   % case 'Leave-OneReplicate-Out'
        
        
        
        
   switch Tcv_scheme
       case {'X-Residual-Variance-Increase-Limit','Y-Residual-Variance-Increase-Limit'}
           default_X_var_increase_limit=6;
           % default_X_var_increase_limit=3;
           all_X_explain=[];
           for iPLSfactor=[1:max(inp.PlsfactorScan)]
               [xl,yl,xs,ys,beta,pctvar,mse]...
                   = plsregress(X,Y,iPLSfactor);
               
               XorY=find_keyword_between_markers(Tcv_scheme,'','-');
               switch XorY
                   case 'X'
                       all_X_explain=[all_X_explain;[iPLSfactor pctvar(1,end)]];%based on Xvar
                   case 'Y'
                       all_X_explain=[all_X_explain;[iPLSfactor pctvar(2,end)]];  % based on Yvar
                   otherwise
                       error('XorY variance not supported')
               end
           end
           
           Xvar_explain_cumsum=cumsum(all_X_explain(:,2));
           Xvar_explain_residual=1-Xvar_explain_cumsum;
           
           figure(101);set(gcf,'position',[260          70        1459         898])
           subplot(3,1,1);
           hold on;
           plot(all_X_explain(:,1),Xvar_explain_cumsum,'r-*','linewidth',2);
           ylabel(['Cumu ',XorY,'-var']);
           
           subplot(3,1,2);
           hold on;
           plot(all_X_explain(:,1),all_X_explain(:,2),'r->','linewidth',2);
           ylabel(['Incre ',XorY,'-var']);
           subplot(3,1,3);
           hold on;
           
           perc_Xvar_increase= all_X_explain(2:end,2)./Xvar_explain_cumsum(1:end-1)*100 ;
           PLSfactor_tbd=all_X_explain(2:end,1);
           
           hp3= plot(PLSfactor_tbd,perc_Xvar_increase   ,'r-+','linewidth',2);
           ylabel(['Ratio Incre ',XorY,'-var']);
           xlabel(['PLS factor']);
           set(gca,'xlim',[0 max(all_X_explain(:,1))])
           loc_lower_than_limit=find(perc_Xvar_increase<default_X_var_increase_limit);
           loc_1st_lower=min(loc_lower_than_limit);
           loc_OpmPLS=loc_1st_lower-1;
           try
               OpmPLSfactor=PLSfactor_tbd(loc_OpmPLS);% loc in PLSfactor_tbd vs PLSfactor_all are shifted by one
           catch
               if loc_OpmPLS==0
                   PLSfactor_all=    all_X_explain(:,1);
                   OpmPLSfactor=PLSfactor_all(loc_OpmPLS+1);   % loc in PLSfactor_tbd vs PLSfactor_all are shifted by one
                   
                   %             hp3= plot(PLSfactor_tbd,perc_Xvar_increase   ,'r-+','linewidth',2);
                   
               else
                   error('something wrong with loc_OpmPLS')
               end
           end
           plot_vline(OpmPLSfactor,'b');
           plot_hline(default_X_var_increase_limit,'k');
           subplot(3,1,1);
           plot_vline(OpmPLSfactor,'b');
           
           OpmPLSfactor_RVIL=OpmPLSfactor;
           title([{[inp.stitle,'  ',remove_underscore(inp.inp.pp)]};...
               %  {['Tcv:',find_keyword_between_markers(fileparts_name_wo_ext(pathfname_ATwsaConc_T),'(',')') ]};...
               {['Tcv: ',inp.inp.sSM_T,'  ',inp.Tcv_scheme]};...
               {['OpmPLSfactor by RVIL=',num2str(OpmPLSfactor_RVIL),'  ( threshold = ',num2str(default_X_var_increase_limit),'%)' ]};...
               ])
           
           subplot(3,1,3);
           title(remove_underscore(inp.inp.filename_woExt));
           
           
           
           
       case 'Leave-OneReplicate-Out'
           
           QSample=unique(cSampleName);
           QSample_sortnat=sortnat(QSample);
           AclassinfoT= cellfun(@(x) strmatch(x,QSample_sortnat,'exact'),cSampleName);
           
           
           expseq=zeros(length(AclassinfoT),1);
           for icls=unique(AclassinfoT)'
               loc_icls=find(AclassinfoT==icls);
               
               expseq(loc_icls)=[1:length(loc_icls)];
           end
           [Qx Nx]=unique_count(expseq);
           
           loc_all=col_always([1:length(Y)]);
           Yest_all=repmat(NaN,size(loc_all));
           
           List_OpmPLSfactor_iQ=[];
           for iQx=row_always(Qx)
               
               loc_P_iQx=find(expseq==iQx);
               loc_T_iQx=setdiff(loc_all,loc_P_iQx);
               
               X_T_iQx=X(loc_T_iQx,:);
               Y_T_iQx=Y(loc_T_iQx,:);
               %                %old approach with "CV"
               %                [xl_iQx,yl_iQx,xs_iQx,ys_iQx,beta_iQx,pctvar_iQx,mse_iQx]...
               %                    = plsregress(X_T_iQx,Y_T_iQx,PLSfactor,'CV',PLSfactor);
               
               %  new approach without "CV", with this approach PLSfactor
               %  can take 1 as input
               [xl_iQx,yl_iQx,xs_iQx,ys_iQx,beta_iQx,pctvar_iQx,mse_iQx]...
                   = plsregress(X_T_iQx,Y_T_iQx,PLSfactor);
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               X_P_iQx=X(loc_P_iQx,:);
               Y_P_iQx=Y(loc_P_iQx,:);
               Yest_iQx = [ones(size(X_P_iQx,1),1) X_P_iQx]*beta_iQx;
               Yest_all(loc_P_iQx,:)=Yest_iQx;
           end
           
           
       case {'Leave-OneConc-Out','10folds-Conc','5folds-Conc','2folds-Conc','sqrtNSfolds-Conc','Split_KSnX','Split_KSnY'}
           QSample=unique(cSampleName);
           QSample_sortnat=sortnat(QSample);
           QSample_appear_order= unique_appear_order_cstr(cSampleName);
           %%%%%%%%%%%%%%%%%%%%%%%%
           switch Tcv_scheme
               case {'10folds-Conc','5folds-Conc','2folds-Conc','sqrtNSfolds-Conc'}
                   nSample=length(QSample);
                   if strcmp(Tcv_scheme,'sqrtNSfolds-Conc')
                       nFolds=floor(sqrt(nSample));
                   else
                       nFolds=min(str2num(find_keyword_between_markers(Tcv_scheme,'','fold')),nSample);
                   end
                   
                   seq_pad=[1:ceil(nSample/nFolds)*nFolds];
                   seq_pad(seq_pad>nSample)=NaN;
                   idx_table=reshape(seq_pad,[nFolds ceil(nSample/nFolds) ]);
               case {'Split_KSnX','Split_KSnY'}
                  % error('under construction')
                   nSample=length(QSample);
                   nFolds=2;
                   
               case 'Leave-OneConc-Out'
                   nSample=length(QSample);
                   nFolds=nSample;
           end
           %%%%%%%%%%%%%%%%%%%%%%%%
           
           loc_all=col_always([1:length(Y)]);
           Yest_all=repmat(NaN,size(loc_all));
           
           List_OpmPLSfactor_iQ=[];
           for iQS=1:nFolds
               
               %%%%%%%%%%%%%%%%%%%%%%%%
               switch Tcv_scheme
                   case {'10folds-Conc','5folds-Conc','2folds-Conc','sqrtNSfolds-Conc'}
                       loc4P_in_QSample_appear_order=idx_table(iQS,:);
                       loc4P_in_QSample_appear_order(isnan(loc4P_in_QSample_appear_order))='';
                       loc_P_iQS=find(ismember(cSampleName,QSample_appear_order(loc4P_in_QSample_appear_order)));
                       loc_T_iQS=setdiff(loc_all,loc_P_iQS);
                       
                   case {'Split_KSnX','Split_KSnY'}
                       %error('under construction')
                       
                       switch Tcv_scheme
                           case 'Split_KSnX'
                           disp('split UDM by KS pick on X matrix')
                           [idxTrn, idxRef] = KennardStone( X, ceil(nSample/2));
                           if iQS==1
                               loc_P_iQS=idxRef;
                           else
                               loc_P_iQS=idxTrn;
                           end
                           loc_T_iQS=setdiff(loc_all,loc_P_iQS);
                           
                           
                           case 'Split_KSnY'
                               error('under construction')
                       end
                       
                       
                   case 'Leave-OneConc-Out'
                       loc_P_iQS=strmatch(QSample_sortnat{iQS},cSampleName,'exact');
                       loc_T_iQS=setdiff(loc_all,loc_P_iQS);
               end
               %%%%%%%%%%%%%%%%%%%%%%%%
               % the following is for Tcv
               %                X_T_iQS=X(loc_T_iQS,:);
               %                Y_T_iQS=Y(loc_T_iQS,:);
               
               % the following is for Scv
               X_T_iQS=[OrigCS.X;X(loc_T_iQS,:)];
               Y_T_iQS=[OrigCS.Y;Y(loc_T_iQS,:)];
               
               
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %checking
               ID4Pi=cSampleName(loc_P_iQS);
               ID4Ti=cSampleName(loc_T_iQS);
               qID4Pi=unique(ID4Pi);
               qID4Ti=unique(ID4Ti);
               TotalNum_qID=length(qID4Pi)+length(qID4Ti);
               if length(unique(cSampleName))~=TotalNum_qID
                   error('not all spectra parsed into training vs prediction set in cross validation')
               end
               %old approach with "CV"
               
               %                [xl_iQS,yl_iQS,xs_iQS,ys_iQS,beta_iQS,pctvar_iQS,mse_iQS]...
               %                    = plsregress(X_T_iQS,Y_T_iQS,PLSfactor,'CV',PLSfactor);
               
               %  new approach without "CV", with this approach PLSfactor
               %  can take 1 as input
               [xl_iQS,yl_iQS,xs_iQS,ys_iQS,beta_iQS,pctvar_iQS,mse_iQS]...
                   = plsregress(X_T_iQS,Y_T_iQS,PLSfactor);
               
               
               
               %             all_PLSfactor=[0:PLSfactor];
               %             [PLSfactor_KP_iQS, idx_of_result_KP_iQS] = knee_pt(mse_iQS(2,:),all_PLSfactor);
               %             if ~isnan(KPplus) && ~isempty(KPplus)
               %             OpmPLSfactor_iQS=    PLSfactor_KP_iQS+KPplus;    % visually adjusted to set it to knee point + KPplus
               %             else
               %              OpmPLSfactor_iQS=inp.PLSfactor_fixed;
               %             end
               %             List_OpmPLSfactor_iQ=[List_OpmPLSfactor_iQ;[iQS OpmPLSfactor_iQS]];
               if false
                   
                   figure;hold on
                   plot(all_PLSfactor,mse_iQS(2,:),'-o');
                   plot(OpmPLSfactor_iQS,mse_iQS(2,OpmPLSfactor_iQS+1),'r*');
                   title({[inp.stitle,'  T-iCV=',num2str(iQS),'/',num2str(nSample)];['    Opm PLS factor=',num2str(OpmPLSfactor_iQS)]});
                   
                   
               end
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               X_P_iQS=X(loc_P_iQS,:);
               Y_P_iQS=Y(loc_P_iQS,:);
               
               % [xl_opm,yl_opm,xs_opm,ys_opm,beta_opm,pctvar_opm,mse_opm] = plsregress(X_T_iQS,Y_T_iQS,PLSfactor);
               
               % Yest_iQS = [ones(size(X_P_iQS,1),1) X_P_iQS]*beta_opm;
               
               Yest_iQS = [ones(size(X_P_iQS,1),1) X_P_iQS]*beta_iQS;
               
               Yest_all(loc_P_iQS,:)=Yest_iQS;
           end
           
           
       otherwise
           error('Tcv scheme NOT supported')
   end

   
   if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
    RMSE=RMS_error_woNaN(Yest_all,Y);
    CV=100*RMS_error_woNaN(Yest_all,Y)/mean(Y);
   end

if false
                figure;hold on
                plot(Y,Yest_all,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE=roundns(RMS_error_woNaN(Yest_all,Y),2);
                sCV=roundns(100*RMS_error_woNaN(Yest_all,Y)/mean(Y),2);
                title({inp.stitle;['mean Opm PLS factor(KP+',num2str(KPplus),') =',num2str(mean(List_OpmPLSfactor_iQ(:,2))),'   RMSE=',sRMSE,'    CV=',sCV,'%']});
%                 'Opm PLS factor(KP+',num2str(KPplus),') =',num2str(OpmPLSfactor)
                xlabel('Y True Value')
                ylabel('Y Estimated');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-Validation 
           if false
               [xl_Self,yl_Self,xs_Self,ys_Self,beta_Self,pctvar_Self,mse_Self]...
                   = plsregress(X,Y,PLSfactor,'CV',PLSfactor);

                YFitted = [ones(size(X,1),1) X]*beta_Self;
                
                figure;hold on
                plot(Y,YFitted,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE_Self=roundns(RMS_error_woNaN(YFitted,Y),2);
                sCV_Self=roundns(100*RMS_error_woNaN(YFitted,Y)/mean(Y),2);
                title({inp.stitle;['PLS factor =',num2str(PLSfactor),'   RMSE Self=',sRMSE_Self,'    CV Self=',sCV_Self,'%']});
                
                xlabel('Y True Value')
                ylabel('Y Estimated');
             end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    out.OpmPLSfactor_RVIL=OpmPLSfactor_RVIL;
end
 if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
out.List_OpmPLSfactor=List_OpmPLSfactor_iQ;
out.Yest_all=Yest_all;
out.RMSE=RMSE;
out.CV=CV;
% out.KPplus=KPplus;
% out.meanOpmPLSfactor  = roundns(mean(List_OpmPLSfactor_iQ(:,2)),2);
% out.sCV_Self=sCV_Self;
out.PLSfactor=PLSfactor;
 end
 try
     out.nFolds=nFolds;
 end
 try
     out.Tcv_scheme=Tcv_scheme;
 end
end


%% ----- PLS_Tcv   [AQP_gui.m lines 9931-10313] ---------------------------------------------------
function out=PLS_Tcv(X,Y,cSampleName,inp)
% typically called by PLS_inside_PLS_predict_ONLY_MLtool (esp when running AQPlite)
%
% running training set cross validation for PLS
% see also PLS_Scv split_vector_into_equal_sized_bins
% % add following for revisit T2 vs Qres, Apr 21, 2021
% % activate EVRI_pls for revisit T2 vs Qres, Apr 21, 2021
%------------------------------------------------------------
% borrow codes section from this function to be used in parse_T_vs_P_in_Tcv_nFolds, Apr 19, 2023
% see also: parse_T_vs_P_in_Tcv_nFolds
%============================================================
if false
    
    inp.Tcv_scheme='Leave-OneSample-Out';
         inp.stitle=CurAna;
    out=PLS_Tcv(X,Y,cSampleName,inp);
    
end
% plsregress(X,Y,ncomp,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try cSampleName=cell2mat_ccstr2cstr(cSampleName);end

PLSfactor= inp.PLSfactor;
KPplus=inp.KPplus;
Tcv_scheme=inp.Tcv_scheme;
   % case 'Leave-OneReplicate-Out'
        
        
        
        
   switch Tcv_scheme
       case {'RMSEC','Self-Pred'}
           
            [xl,yl,xs,ysx,beta,pctvar,mse]...
                   = plsregress(X,Y,PLSfactor);
           Yest_all = [ones(size(X,1),1) X]*beta;
           
           
           
       case {'X-Residual-Variance-Increase-Limit','Y-Residual-Variance-Increase-Limit'}
           default_X_var_increase_limit=6;
            % default_X_var_increase_limit=3;
           all_X_explain=[];
           for iPLSfactor=[1:max(inp.PlsfactorScan)]
            [xl,yl,xs,ys,beta,pctvar,mse]...
                   = plsregress(X,Y,iPLSfactor);
               
               XorY=find_keyword_between_markers(Tcv_scheme,'','-');
               switch XorY
                   case 'X'
                       all_X_explain=[all_X_explain;[iPLSfactor pctvar(1,end)]];%based on Xvar
                   case 'Y'
                       all_X_explain=[all_X_explain;[iPLSfactor pctvar(2,end)]];  % based on Yvar
                   otherwise
                       error('XorY variance not supported')
               end
           end
           
           Xvar_explain_cumsum=cumsum(all_X_explain(:,2));
           Xvar_explain_residual=1-Xvar_explain_cumsum;
           
           figure(101);set(gcf,'position',[260          70        1459         898])
           subplot(3,1,1);
           hold on;
           plot(all_X_explain(:,1),Xvar_explain_cumsum,'r-*','linewidth',2);
           ylabel(['Cumu ',XorY,'-var']);
           
           subplot(3,1,2);
           hold on;
           plot(all_X_explain(:,1),all_X_explain(:,2),'r->','linewidth',2);
           ylabel(['Incre ',XorY,'-var']);
            subplot(3,1,3);
           hold on;
           
          perc_Xvar_increase= all_X_explain(2:end,2)./Xvar_explain_cumsum(1:end-1)*100 ;
          PLSfactor_tbd=all_X_explain(2:end,1);
          
          hp3= plot(PLSfactor_tbd,perc_Xvar_increase   ,'r-+','linewidth',2);
            ylabel(['Ratio Incre ',XorY,'-var']);
            xlabel(['PLS factor']);
           set(gca,'xlim',[0 max(all_X_explain(:,1))])
           loc_lower_than_limit=find(perc_Xvar_increase<default_X_var_increase_limit);
           loc_1st_lower=min(loc_lower_than_limit);
           loc_OpmPLS=loc_1st_lower-1;
           try
           OpmPLSfactor=PLSfactor_tbd(loc_OpmPLS);% loc in PLSfactor_tbd vs PLSfactor_all are shifted by one
           catch
               if loc_OpmPLS==0
               PLSfactor_all=    all_X_explain(:,1);
            OpmPLSfactor=PLSfactor_all(loc_OpmPLS+1);   % loc in PLSfactor_tbd vs PLSfactor_all are shifted by one
            
%             hp3= plot(PLSfactor_tbd,perc_Xvar_increase   ,'r-+','linewidth',2);
            
               else
              error('something wrong with loc_OpmPLS')     
               end
           end
           plot_vline(OpmPLSfactor,'b');
           plot_hline(default_X_var_increase_limit,'k');
           subplot(3,1,1);
           plot_vline(OpmPLSfactor,'b');
            
           OpmPLSfactor_RVIL=OpmPLSfactor;
            title([{[inp.stitle,'  ',remove_underscore(inp.inp.pp)]};...
                %  {['Tcv:',find_keyword_between_markers(fileparts_name_wo_ext(pathfname_ATwsaConc_T),'(',')') ]};...
                {['Tcv: ',inp.inp.sSM_T,'  ',inp.Tcv_scheme]};...
                {['OpmPLSfactor by RVIL=',num2str(OpmPLSfactor_RVIL),'  ( threshold = ',num2str(default_X_var_increase_limit),'%)' ]};...
                ])
           
           subplot(3,1,3);
           title(remove_underscore(inp.inp.filename_woExt));
           
           
           
           
       case 'Leave-OneReplicate-Out'
           
           QSample=unique(cSampleName);
           QSample_sortnat=sortnat(QSample);
           AclassinfoT= cellfun(@(x) strmatch(x,QSample_sortnat,'exact'),cSampleName);
           
           
           expseq=zeros(length(AclassinfoT),1);
           for icls=unique(AclassinfoT)'
               loc_icls=find(AclassinfoT==icls);
               
               expseq(loc_icls)=[1:length(loc_icls)];
           end
           [Qx Nx]=unique_count(expseq);
           
           loc_all=col_always([1:length(Y)]);
           Yest_all=repmat(NaN,size(loc_all));
           
           List_OpmPLSfactor_iQ=[];
           for iQx=row_always(Qx)

               loc_P_iQx=find(expseq==iQx);
               loc_T_iQx=setdiff(loc_all,loc_P_iQx);
               
               X_T_iQx=X(loc_T_iQx,:);
               Y_T_iQx=Y(loc_T_iQx,:);
%                %old approach with "CV"
%                [xl_iQx,yl_iQx,xs_iQx,ys_iQx,beta_iQx,pctvar_iQx,mse_iQx]...
%                    = plsregress(X_T_iQx,Y_T_iQx,PLSfactor,'CV',PLSfactor);

               %  new approach without "CV", with this approach PLSfactor
               %  can take 1 as input
                [xl_iQx,yl_iQx,xs_iQx,ys_iQx,beta_iQx,pctvar_iQx,mse_iQx]...
                   = plsregress(X_T_iQx,Y_T_iQx,PLSfactor);

                              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               X_P_iQx=X(loc_P_iQx,:);
               Y_P_iQx=Y(loc_P_iQx,:);
               Yest_iQx = [ones(size(X_P_iQx,1),1) X_P_iQx]*beta_iQx;
               Yest_all(loc_P_iQx,:)=Yest_iQx;
           end
           
           
       case {'Leave-OneConc-Out','10folds-Conc','5folds-Conc','sqrtNSfolds-Conc'}
           % revisit this Apr 18, 2023
           QSample=unique(cSampleName);
           QSample_sortnat=sortnat(QSample);
          QSample_appear_order= unique_appear_order_cstr(cSampleName);
           %%%%%%%%%%%%%%%%%%%%%%%%
           switch Tcv_scheme
               case {'10folds-Conc','5folds-Conc','sqrtNSfolds-Conc'}
                   nSample=length(QSample);
                   if strcmp(Tcv_scheme,'sqrtNSfolds-Conc')
                       nFolds=floor(sqrt(nSample));
                   else
                       nFolds=min(str2num(find_keyword_between_markers(Tcv_scheme,'','fold')),nSample);
                   end
                   
                   seq_pad=[1:ceil(nSample/nFolds)*nFolds];
                   seq_pad(seq_pad>nSample)=NaN;
                   idx_table=reshape(seq_pad,[nFolds ceil(nSample/nFolds) ]);
                      
               case 'Leave-OneConc-Out'
                   nSample=length(QSample);
                   nFolds=nSample;
           end
           %%%%%%%%%%%%%%%%%%%%%%%%
           
           loc_all=col_always([1:length(Y)]);
           Yest_all=repmat(NaN,size(loc_all));
           
           List_OpmPLSfactor_iQ=[];
           Pest4LSUX=repmat(NaN, [length(loc_all)  2] );
           
           for iQS=1:nFolds
               
               %%%%%%%%%%%%%%%%%%%%%%%%
               switch Tcv_scheme
                   case {'10folds-Conc','5folds-Conc','sqrtNSfolds-Conc'}
                       loc4P_in_QSample_appear_order=idx_table(iQS,:);
                       loc4P_in_QSample_appear_order(isnan(loc4P_in_QSample_appear_order))='';
                       loc_P_iQS=find(ismember(cSampleName,QSample_appear_order(loc4P_in_QSample_appear_order)));
                       loc_T_iQS=setdiff(loc_all,loc_P_iQS);
                   case 'Leave-OneConc-Out'
                       loc_P_iQS=strmatch(QSample_sortnat{iQS},cSampleName,'exact');
                       loc_T_iQS=setdiff(loc_all,loc_P_iQS);
               end
               %%%%%%%%%%%%%%%%%%%%%%%%
               X_T_iQS=X(loc_T_iQS,:);
               Y_T_iQS=Y(loc_T_iQS,:);
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %checking
               ID4Pi=cSampleName(loc_P_iQS);
               ID4Ti=cSampleName(loc_T_iQS);
               qID4Pi=unique(ID4Pi);
               qID4Ti=unique(ID4Ti);
               TotalNum_qID=length(qID4Pi)+length(qID4Ti);
               if length(unique(cSampleName))~=TotalNum_qID
                   error('not all spectra parsed into training vs prediction set in cross validation')
               end
               %old approach with "CV"

%                [xl_iQS,yl_iQS,xs_iQS,ys_iQS,beta_iQS,pctvar_iQS,mse_iQS]...
%                    = plsregress(X_T_iQS,Y_T_iQS,PLSfactor,'CV',PLSfactor);

               %  new approach without "CV", with this approach PLSfactor
               %  can take 1 as input
                              [xl_iQS,yl_iQS,xs_iQS,ys_iQS,beta_iQS,pctvar_iQS,mse_iQS]...
                   = plsregress(X_T_iQS,Y_T_iQS,PLSfactor);

               
               
               %             all_PLSfactor=[0:PLSfactor];
               %             [PLSfactor_KP_iQS, idx_of_result_KP_iQS] = knee_pt(mse_iQS(2,:),all_PLSfactor);
               %             if ~isnan(KPplus) && ~isempty(KPplus)
               %             OpmPLSfactor_iQS=    PLSfactor_KP_iQS+KPplus;    % visually adjusted to set it to knee point + KPplus
               %             else
               %              OpmPLSfactor_iQS=inp.PLSfactor_fixed;
               %             end
               %             List_OpmPLSfactor_iQ=[List_OpmPLSfactor_iQ;[iQS OpmPLSfactor_iQS]];
               if false
                   
                   figure;hold on
                   plot(all_PLSfactor,mse_iQS(2,:),'-o');
                   plot(OpmPLSfactor_iQS,mse_iQS(2,OpmPLSfactor_iQS+1),'r*');
                   title({[inp.stitle,'  T-iCV=',num2str(iQS),'/',num2str(nSample)];['    Opm PLS factor=',num2str(OpmPLSfactor_iQS)]});
                   
                   
               end
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               X_P_iQS=X(loc_P_iQS,:);
               Y_P_iQS=Y(loc_P_iQS,:);
               
               % [xl_opm,yl_opm,xs_opm,ys_opm,beta_opm,pctvar_opm,mse_opm] = plsregress(X_T_iQS,Y_T_iQS,PLSfactor);
               
               % Yest_iQS = [ones(size(X_P_iQS,1),1) X_P_iQS]*beta_opm;
               
               Yest_iQS = [ones(size(X_P_iQS,1),1) X_P_iQS]*beta_iQS;
               
               Yest_all (loc_P_iQS,:)=Yest_iQS;
               
               Pest4LSUX(loc_P_iQS,1)=iQS;
               Pest4LSUX(loc_P_iQS,2)=Yest_iQS;
               %=============================================
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %==============================================
               %==============================================
               % add following for revisit T2 vs Qres, Apr 21, 2021
               run_EVRI_pls_yes=0;     % activate EVRI_pls for revisit T2 vs Qres, Apr 21, 2021
               if run_EVRI_pls_yes
               % run with EVRI's pls()
               options.display='off';
               options.plots='none';
               
              % X_T_iQS,Y_T_iQS,PLSfactor
               
               
               [X_iAna_T_mncn mean_T]=mncn(X_T_iQS);% apply mncn to XT XP and YT before send them to pls()
               X_iAna_P_mncn=scale(X_P_iQS,mean_T);% apply mncn to XT XP and YT before send them to pls()
               [Y_iAna_T_mncn mean_Y_T]=mncn(Y_T_iQS);% apply mncn to XT XP and YT before send them to pls()
               
               warning('off');  % to turn off warning about "NARGCHK"
               model_PLS_EVRI_mncn = pls(X_iAna_T_mncn,Y_iAna_T_mncn,PLSfactor,options);  %identifies model (calibration step)
               pred_PLS_EVRI_mncn  = pls(X_iAna_P_mncn, model_PLS_EVRI_mncn,options);    %makes predictions with a new X-block
               warning('on');
               
             Yest_iQS_EVRI_pls=  pred_PLS_EVRI_mncn.pred{2}+mean_Y_T;
               tol=1e-8;
              if all(IsNear(Yest_iQS,Yest_iQS_EVRI_pls,tol))
                  disp('same results by plsregress vs EVRI_pls')
              else
                  error('results by plsregress vs EVRI_pls are different ?')
              end
             
               eaQResidual_Pset=pred_PLS_EVRI_mncn.ssqresiduals{1};
               eaT2_Pset=pred_PLS_EVRI_mncn.tsqs{1};
               
               outQR_mncn.QResidual=eaQResidual_Pset;
               outQR_mncn.T2=eaT2_Pset;
               
               end  % end of  run_EVRI_pls_yes
               
               %==============================================
               %==============================================
               
               
           end
           
           
       otherwise
           error('Tcv scheme NOT supported')
   end

   
   if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
%     RMSE=RMS_error_woNaN(Yest_all,Y);
    RMSE=RMS_error_woNaN_N(Yest_all,Y);     % modified by CH, Jan 24, 2020
    CV=100*RMS_error_woNaN(Yest_all,Y)/mean(Y);
   end

if false
                figure;hold on
                plot(Y,Yest_all,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE=roundns(RMS_error_woNaN(Yest_all,Y),2);
                sCV=roundns(100*RMS_error_woNaN(Yest_all,Y)/mean(Y),2);
                title({inp.stitle;['mean Opm PLS factor(KP+',num2str(KPplus),') =',num2str(mean(List_OpmPLSfactor_iQ(:,2))),'   RMSE=',sRMSE,'    CV=',sCV,'%']});
%                 'Opm PLS factor(KP+',num2str(KPplus),') =',num2str(OpmPLSfactor)
                xlabel('Y True Value')
                ylabel('Y Estimated');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-Validation 
           if false
               [xl_Self,yl_Self,xs_Self,ys_Self,beta_Self,pctvar_Self,mse_Self]...
                   = plsregress(X,Y,PLSfactor,'CV',PLSfactor);

                YFitted = [ones(size(X,1),1) X]*beta_Self;
                
                figure;hold on
                plot(Y,YFitted,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE_Self=roundns(RMS_error_woNaN(YFitted,Y),2);
                sCV_Self=roundns(100*RMS_error_woNaN(YFitted,Y)/mean(Y),2);
                title({inp.stitle;['PLS factor =',num2str(PLSfactor),'   RMSE Self=',sRMSE_Self,'    CV Self=',sCV_Self,'%']});
                
                xlabel('Y True Value')
                ylabel('Y Estimated');
             end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    out.OpmPLSfactor_RVIL=OpmPLSfactor_RVIL;
end
 if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
     try
out.List_OpmPLSfactor=List_OpmPLSfactor_iQ;
     end
out.Yest_all=Yest_all;
out.RMSE=RMSE;
out.CV=CV;
out.KPplus=KPplus;
% out.meanOpmPLSfactor  = roundns(mean(List_OpmPLSfactor_iQ(:,2)),2);
% out.sCV_Self=sCV_Self;
out.PLSfactor=PLSfactor;
try
out.Pest4LSUX=Pest4LSUX;
end
 end
 try
     out.nFolds=nFolds;
 end
 try
     out.Tcv_scheme=Tcv_scheme;
 end
end


%% ----- PLS_Tcv_P_Avg_All   [AQP_gui.m lines 10320-10718] -----------------------------------------
function out=PLS_Tcv_P_Avg_All(X,Y,cSampleName,inp , X_iAna_P_Tcv, Y_iAna_P_Tcv , cSampleName_P_Tcv)
% typically called by PLS_inside_PLS_predict_ONLY_MLtool (esp when running AQPlite)
%
% running training set cross validation for PLS
% see also PLS_Scv split_vector_into_equal_sized_bins
% % add following for revisit T2 vs Qres, Apr 21, 2021
% % activate EVRI_pls for revisit T2 vs Qres, Apr 21, 2021
%------------------------------------------------------------
% borrow codes section from this function to be used in parse_T_vs_P_in_Tcv_nFolds, Apr 19, 2023
% see also: parse_T_vs_P_in_Tcv_nFolds
%============================================================
if false
    
    inp.Tcv_scheme='Leave-OneSample-Out';
         inp.stitle=CurAna;
    out=PLS_Tcv(X,Y,cSampleName,inp);
    
end
% plsregress(X,Y,ncomp,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try cSampleName=cell2mat_ccstr2cstr(cSampleName);end

try cSampleName_P_Tcv=cell2mat_ccstr2cstr(cSampleName_P_Tcv);end  % add this Apr 24, 2023
cSampleName_P_Tcv=cellstr(cSampleName_P_Tcv+"_Mean");% add this Apr 24, 2023

PLSfactor= inp.PLSfactor;
KPplus=inp.KPplus;
Tcv_scheme=inp.Tcv_scheme;
   % case 'Leave-OneReplicate-Out'
        
        
        
        
   switch Tcv_scheme
       case {'RMSEC','Self-Pred'}
           
            [xl,yl,xs,ysx,beta,pctvar,mse]...
                   = plsregress(X,Y,PLSfactor);
           Yest_all = [ones(size(X,1),1) X]*beta;
           
           
           
       case {'X-Residual-Variance-Increase-Limit','Y-Residual-Variance-Increase-Limit'}
           default_X_var_increase_limit=6;
            % default_X_var_increase_limit=3;
           all_X_explain=[];
           for iPLSfactor=[1:max(inp.PlsfactorScan)]
            [xl,yl,xs,ys,beta,pctvar,mse]...
                   = plsregress(X,Y,iPLSfactor);
               
               XorY=find_keyword_between_markers(Tcv_scheme,'','-');
               switch XorY
                   case 'X'
                       all_X_explain=[all_X_explain;[iPLSfactor pctvar(1,end)]];%based on Xvar
                   case 'Y'
                       all_X_explain=[all_X_explain;[iPLSfactor pctvar(2,end)]];  % based on Yvar
                   otherwise
                       error('XorY variance not supported')
               end
           end
           
           Xvar_explain_cumsum=cumsum(all_X_explain(:,2));
           Xvar_explain_residual=1-Xvar_explain_cumsum;
           
           figure(101);set(gcf,'position',[260          70        1459         898])
           subplot(3,1,1);
           hold on;
           plot(all_X_explain(:,1),Xvar_explain_cumsum,'r-*','linewidth',2);
           ylabel(['Cumu ',XorY,'-var']);
           
           subplot(3,1,2);
           hold on;
           plot(all_X_explain(:,1),all_X_explain(:,2),'r->','linewidth',2);
           ylabel(['Incre ',XorY,'-var']);
            subplot(3,1,3);
           hold on;
           
          perc_Xvar_increase= all_X_explain(2:end,2)./Xvar_explain_cumsum(1:end-1)*100 ;
          PLSfactor_tbd=all_X_explain(2:end,1);
          
          hp3= plot(PLSfactor_tbd,perc_Xvar_increase   ,'r-+','linewidth',2);
            ylabel(['Ratio Incre ',XorY,'-var']);
            xlabel(['PLS factor']);
           set(gca,'xlim',[0 max(all_X_explain(:,1))])
           loc_lower_than_limit=find(perc_Xvar_increase<default_X_var_increase_limit);
           loc_1st_lower=min(loc_lower_than_limit);
           loc_OpmPLS=loc_1st_lower-1;
           try
           OpmPLSfactor=PLSfactor_tbd(loc_OpmPLS);% loc in PLSfactor_tbd vs PLSfactor_all are shifted by one
           catch
               if loc_OpmPLS==0
               PLSfactor_all=    all_X_explain(:,1);
            OpmPLSfactor=PLSfactor_all(loc_OpmPLS+1);   % loc in PLSfactor_tbd vs PLSfactor_all are shifted by one
            
%             hp3= plot(PLSfactor_tbd,perc_Xvar_increase   ,'r-+','linewidth',2);
            
               else
              error('something wrong with loc_OpmPLS')     
               end
           end
           plot_vline(OpmPLSfactor,'b');
           plot_hline(default_X_var_increase_limit,'k');
           subplot(3,1,1);
           plot_vline(OpmPLSfactor,'b');
            
           OpmPLSfactor_RVIL=OpmPLSfactor;
            title([{[inp.stitle,'  ',remove_underscore(inp.inp.pp)]};...
                %  {['Tcv:',find_keyword_between_markers(fileparts_name_wo_ext(pathfname_ATwsaConc_T),'(',')') ]};...
                {['Tcv: ',inp.inp.sSM_T,'  ',inp.Tcv_scheme]};...
                {['OpmPLSfactor by RVIL=',num2str(OpmPLSfactor_RVIL),'  ( threshold = ',num2str(default_X_var_increase_limit),'%)' ]};...
                ])
           
           subplot(3,1,3);
           title(remove_underscore(inp.inp.filename_woExt));
           
           
           
           
       case 'Leave-OneReplicate-Out'
           
           QSample=unique(cSampleName);
           QSample_sortnat=sortnat(QSample);
           AclassinfoT= cellfun(@(x) strmatch(x,QSample_sortnat,'exact'),cSampleName);
           
           
           expseq=zeros(length(AclassinfoT),1);
           for icls=unique(AclassinfoT)'
               loc_icls=find(AclassinfoT==icls);
               
               expseq(loc_icls)=[1:length(loc_icls)];
           end
           [Qx Nx]=unique_count(expseq);
           
           loc_all=col_always([1:length(Y)]);
           Yest_all=repmat(NaN,size(loc_all));
           
           List_OpmPLSfactor_iQ=[];
           for iQx=row_always(Qx)

               loc_P_iQx=find(expseq==iQx);
               loc_T_iQx=setdiff(loc_all,loc_P_iQx);
               
               X_T_iQx=X(loc_T_iQx,:);
               Y_T_iQx=Y(loc_T_iQx,:);
%                %old approach with "CV"
%                [xl_iQx,yl_iQx,xs_iQx,ys_iQx,beta_iQx,pctvar_iQx,mse_iQx]...
%                    = plsregress(X_T_iQx,Y_T_iQx,PLSfactor,'CV',PLSfactor);

               %  new approach without "CV", with this approach PLSfactor
               %  can take 1 as input
                [xl_iQx,yl_iQx,xs_iQx,ys_iQx,beta_iQx,pctvar_iQx,mse_iQx]...
                   = plsregress(X_T_iQx,Y_T_iQx,PLSfactor);

                              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               X_P_iQx=X(loc_P_iQx,:);
               Y_P_iQx=Y(loc_P_iQx,:);
               Yest_iQx = [ones(size(X_P_iQx,1),1) X_P_iQx]*beta_iQx;
               Yest_all(loc_P_iQx,:)=Yest_iQx;
           end
           
           
       case {'Leave-OneConc-Out','10folds-Conc','5folds-Conc','sqrtNSfolds-Conc'}
           % revisit this Apr 18, 2023
           QSample=unique(cSampleName);
           QSample_sortnat=sortnat(QSample);
          QSample_appear_order= unique_appear_order_cstr(cSampleName);
           %%%%%%%%%%%%%%%%%%%%%%%%
           switch Tcv_scheme
               case {'10folds-Conc','5folds-Conc','sqrtNSfolds-Conc'}
                   nSample=length(QSample);
                   if strcmp(Tcv_scheme,'sqrtNSfolds-Conc')
                       nFolds=floor(sqrt(nSample));
                   else
                       nFolds=min(str2num(find_keyword_between_markers(Tcv_scheme,'','fold')),nSample);
                   end
                   
                   seq_pad=[1:ceil(nSample/nFolds)*nFolds];
                   seq_pad(seq_pad>nSample)=NaN;
                   idx_table=reshape(seq_pad,[nFolds ceil(nSample/nFolds) ]);
                      
               case 'Leave-OneConc-Out'
                   nSample=length(QSample);
                   nFolds=nSample;
           end
           %%%%%%%%%%%%%%%%%%%%%%%%
           
           loc_all=col_always([1:length(Y)]);
           Yest_all=repmat(NaN,size(loc_all));
           
           List_OpmPLSfactor_iQ=[];
           Pest4LSUX=repmat(NaN, [length(loc_all)  2] );
           
           for iQS=1:nFolds
               
               %%%%%%%%%%%%%%%%%%%%%%%%
               switch Tcv_scheme
                   case {'10folds-Conc','5folds-Conc','sqrtNSfolds-Conc'}
                       loc4P_in_QSample_appear_order=idx_table(iQS,:);
                       loc4P_in_QSample_appear_order(isnan(loc4P_in_QSample_appear_order))='';
                       
                      % loc_P_iQS=find(ismember(cSampleName,QSample_appear_order(loc4P_in_QSample_appear_order)));
                       loc_P_iQS=find(ismember(cSampleName_P_Tcv,QSample_appear_order(loc4P_in_QSample_appear_order)));% add this Apr 24, 2023
                      % loc_T_iQS=setdiff(loc_all,loc_P_iQS);
                       loc_T_iQS=setdiff(loc_all,loc4P_in_QSample_appear_order);% add this Apr 24, 2023
                       
                   case 'Leave-OneConc-Out'
                       loc_P_iQS=strmatch(QSample_sortnat{iQS},cSampleName,'exact');
                       loc_T_iQS=setdiff(loc_all,loc_P_iQS);
               end
               %%%%%%%%%%%%%%%%%%%%%%%%
               X_T_iQS=X(loc_T_iQS,:);
               Y_T_iQS=Y(loc_T_iQS,:);
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %checking
               if false
                   ID4Pi=cSampleName(loc_P_iQS);
                   ID4Ti=cSampleName(loc_T_iQS);
                   qID4Pi=unique(ID4Pi);
                   qID4Ti=unique(ID4Ti);
                   TotalNum_qID=length(qID4Pi)+length(qID4Ti);
                   if length(unique(cSampleName))~=TotalNum_qID
                       error('not all spectra parsed into training vs prediction set in cross validation')
                   end
               end
               %old approach with "CV"

%                [xl_iQS,yl_iQS,xs_iQS,ys_iQS,beta_iQS,pctvar_iQS,mse_iQS]...
%                    = plsregress(X_T_iQS,Y_T_iQS,PLSfactor,'CV',PLSfactor);

               %  new approach without "CV", with this approach PLSfactor
               %  can take 1 as input
                              [xl_iQS,yl_iQS,xs_iQS,ys_iQS,beta_iQS,pctvar_iQS,mse_iQS]...
                   = plsregress(X_T_iQS,Y_T_iQS,PLSfactor);

               
               
               %             all_PLSfactor=[0:PLSfactor];
               %             [PLSfactor_KP_iQS, idx_of_result_KP_iQS] = knee_pt(mse_iQS(2,:),all_PLSfactor);
               %             if ~isnan(KPplus) && ~isempty(KPplus)
               %             OpmPLSfactor_iQS=    PLSfactor_KP_iQS+KPplus;    % visually adjusted to set it to knee point + KPplus
               %             else
               %              OpmPLSfactor_iQS=inp.PLSfactor_fixed;
               %             end
               %             List_OpmPLSfactor_iQ=[List_OpmPLSfactor_iQ;[iQS OpmPLSfactor_iQS]];
               if false
                   
                   figure;hold on
                   plot(all_PLSfactor,mse_iQS(2,:),'-o');
                   plot(OpmPLSfactor_iQS,mse_iQS(2,OpmPLSfactor_iQS+1),'r*');
                   title({[inp.stitle,'  T-iCV=',num2str(iQS),'/',num2str(nSample)];['    Opm PLS factor=',num2str(OpmPLSfactor_iQS)]});
                   
                   
               end
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                X_P_iQS=X(loc_P_iQS,:);
%                Y_P_iQS=Y(loc_P_iQS,:);
                 X_P_iQS=X_iAna_P_Tcv(loc_P_iQS,:);
                 Y_P_iQS=Y_iAna_P_Tcv(loc_P_iQS,:);
              
               
               % [xl_opm,yl_opm,xs_opm,ys_opm,beta_opm,pctvar_opm,mse_opm] = plsregress(X_T_iQS,Y_T_iQS,PLSfactor);
               
               % Yest_iQS = [ones(size(X_P_iQS,1),1) X_P_iQS]*beta_opm;
               
               Yest_iQS = [ones(size(X_P_iQS,1),1) X_P_iQS]*beta_iQS;
               
               Yest_all (loc_P_iQS,:)=Yest_iQS;
               
               Pest4LSUX(loc_P_iQS,1)=iQS;
               Pest4LSUX(loc_P_iQS,2)=Yest_iQS;
               %=============================================
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %==============================================
               %==============================================
               % add following for revisit T2 vs Qres, Apr 21, 2021
               run_EVRI_pls_yes=0;     % activate EVRI_pls for revisit T2 vs Qres, Apr 21, 2021
               if run_EVRI_pls_yes
               % run with EVRI's pls()
               options.display='off';
               options.plots='none';
               
              % X_T_iQS,Y_T_iQS,PLSfactor
               
               
               [X_iAna_T_mncn mean_T]=mncn(X_T_iQS);% apply mncn to XT XP and YT before send them to pls()
               X_iAna_P_mncn=scale(X_P_iQS,mean_T);% apply mncn to XT XP and YT before send them to pls()
               [Y_iAna_T_mncn mean_Y_T]=mncn(Y_T_iQS);% apply mncn to XT XP and YT before send them to pls()
               
               warning('off');  % to turn off warning about "NARGCHK"
               model_PLS_EVRI_mncn = pls(X_iAna_T_mncn,Y_iAna_T_mncn,PLSfactor,options);  %identifies model (calibration step)
               pred_PLS_EVRI_mncn  = pls(X_iAna_P_mncn, model_PLS_EVRI_mncn,options);    %makes predictions with a new X-block
               warning('on');
               
             Yest_iQS_EVRI_pls=  pred_PLS_EVRI_mncn.pred{2}+mean_Y_T;
               tol=1e-8;
              if all(IsNear(Yest_iQS,Yest_iQS_EVRI_pls,tol))
                  disp('same results by plsregress vs EVRI_pls')
              else
                  error('results by plsregress vs EVRI_pls are different ?')
              end
             
               eaQResidual_Pset=pred_PLS_EVRI_mncn.ssqresiduals{1};
               eaT2_Pset=pred_PLS_EVRI_mncn.tsqs{1};
               
               outQR_mncn.QResidual=eaQResidual_Pset;
               outQR_mncn.T2=eaT2_Pset;
               
               end  % end of  run_EVRI_pls_yes
               
               %==============================================
               %==============================================
               
               
           end
           
           
       otherwise
           error('Tcv scheme NOT supported')
   end

   
   if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
       %     RMSE=RMS_error_woNaN(Yest_all,Y);
       % RMSE=RMS_error_woNaN_N(Yest_all,Y);     % modified by CH, Jan 24, 2020
       RMSE=RMS_error_woNaN_N(Yest_all,Y_iAna_P_Tcv);                             % add this Apr 24, 2023
       
       %     CV=100*RMS_error_woNaN(Yest_all,Y)/mean(Y);
       CV=100*RMS_error_woNaN(Yest_all,Y_iAna_P_Tcv)/mean(Y_iAna_P_Tcv);           % add this Apr 24, 2023
       
   end

if false
                figure;hold on
                plot(Y,Yest_all,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE=roundns(RMS_error_woNaN(Yest_all,Y),2);
                sCV=roundns(100*RMS_error_woNaN(Yest_all,Y)/mean(Y),2);
                title({inp.stitle;['mean Opm PLS factor(KP+',num2str(KPplus),') =',num2str(mean(List_OpmPLSfactor_iQ(:,2))),'   RMSE=',sRMSE,'    CV=',sCV,'%']});
%                 'Opm PLS factor(KP+',num2str(KPplus),') =',num2str(OpmPLSfactor)
                xlabel('Y True Value')
                ylabel('Y Estimated');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-Validation 
           if false
               [xl_Self,yl_Self,xs_Self,ys_Self,beta_Self,pctvar_Self,mse_Self]...
                   = plsregress(X,Y,PLSfactor,'CV',PLSfactor);

                YFitted = [ones(size(X,1),1) X]*beta_Self;
                
                figure;hold on
                plot(Y,YFitted,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE_Self=roundns(RMS_error_woNaN(YFitted,Y),2);
                sCV_Self=roundns(100*RMS_error_woNaN(YFitted,Y)/mean(Y),2);
                title({inp.stitle;['PLS factor =',num2str(PLSfactor),'   RMSE Self=',sRMSE_Self,'    CV Self=',sCV_Self,'%']});
                
                xlabel('Y True Value')
                ylabel('Y Estimated');
             end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    out.OpmPLSfactor_RVIL=OpmPLSfactor_RVIL;
end
 if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
     try
out.List_OpmPLSfactor=List_OpmPLSfactor_iQ;
     end
out.Yest_all=Yest_all;
out.RMSE=RMSE;
out.CV=CV;
out.KPplus=KPplus;
% out.meanOpmPLSfactor  = roundns(mean(List_OpmPLSfactor_iQ(:,2)),2);
% out.sCV_Self=sCV_Self;
out.PLSfactor=PLSfactor;
try
out.Pest4LSUX=Pest4LSUX;
end
 end
 try
     out.nFolds=nFolds;
 end
 try
     out.Tcv_scheme=Tcv_scheme;
 end
end


%% ----- PLS_indv   [AQP_gui.m lines 10725-10817] --------------------------------------------------
function saPLS_Results=PLS_indv(X_iAna_T,X_iAna_P,Y_iAna_T,Y_iAna_P,inp)


% run_SVR_yes=1;
% para_norm=inp.para_norm;
% para_asmc=inp.para_asmc;
 PlsfactorScan=inp.PlsfactorScan;

% if run_SVR_yes
% ktype=inp.ktype;   %  'SVRbyLS'  'linear'
% % ktype='rbf';
% 
% switch  ktype
%     case 'linear'
%         sKtype=' -t 0 ';
%         
%     case  'rbf'
%         sKtype=' -t 2 ';
%         
%     case 'SVRbyLS'
%         
%         sKtype=' -t 0 ';
%         
%         
% end

% para_norm=0;
% para_asmc=1;
% switch para_asmc
%     case 1
%         sasmc_SVR='_autoscale';
%     case 2
%         sasmc_SVR='_meancenter';
%         
%     otherwise
%         error('para_asmc Not supported !!!')
% end

% [X_iAna_T_normasmc,X_iAna_P_normasmc,asmc_mean_std]=normasmc_trainpk_pred(X_iAna_T,X_iAna_P,para_norm,para_asmc);

% X_iAna_T_normasmc=sparse(X_iAna_T_normasmc);
% X_iAna_P_normasmc=sparse(X_iAna_P_normasmc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from libsvm website:
% options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC
% 	1 -- nu-SVC
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR
% 	4 -- nu-SVR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list_C=[0.01 0.1 1 10 100];
saPLS_Results=[];
all_Yest_SVR=[];
for iC=1:length(PlsfactorScan)
%     if strcmp(ktype,'SVRbyLS')
%         % epsilon-SVR
%         model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 3 ', sKtype,' -p ' num2str(0.1) ' -c ' num2str(list_C(iC))]);
%         
%     else
%         % nu-SVR
%         model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 4 ', sKtype,' -n ' num2str(1/2) ' -c ' num2str(1)]);
%     end
%     Yest_SVR=svmpredict_MEX(Y_iAna_P,X_iAna_P_normasmc,model_SVR);
 PLSfactor_i= PlsfactorScan(iC);  
[xl,yl,xs,ys,beta,pctvar,mse]...
    = plsregress(X_iAna_T,Y_iAna_T,PLSfactor_i);
Y_iAna_est = [ones(size(X_iAna_P,1),1) X_iAna_P]*beta;
% RMSE= RMS_error_woNaN_N(Y_iAna_est,Y_iAna_P); % based on N (not N-1)

    
    
    all_Yest_SVR=[all_Yest_SVR,Y_iAna_est];
    
    
    
%     RMSE_SVR= RMS_error_woNaN(Y_iAna_est,Y_iAna_P);
        RMSE_SVR= RMS_error_woNaN_N(Y_iAna_est,Y_iAna_P);

    eaSVR_Results.PLSfactor=PlsfactorScan(iC);
    eaSVR_Results.RMSE=RMSE_SVR;
    eaSVR_Results.Yest_PLS=Y_iAna_est;
    eaSVR_Results.Y_iAna_P=Y_iAna_P;
    
    eaSVR_Results.beta=beta;
    
    saPLS_Results=[saPLS_Results;eaSVR_Results];
    
end

disp('finish PLS_indv')
end


%% ----- PLS_inside_PLS_predict_ONLY_MLtool   [AQP_gui.m lines 10821-11863] ------------------------
function out=PLS_inside_PLS_predict_ONLY_MLtool(pathfnameTP,inp4PLS)
% typically called by --> SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool
% see also: AQP_App_Emulator --> fname_OpmFM=['OpmModel_',fileparts_name_ext( clistfilename_out{locminRP})];
% will call --> PLS_Tcv (when running AQPlite pu)
%-----------------------------------------------------------------------------------------------
% will call --> PLS_Tcv_P_Avg_All ( when strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_Mean')  )
% add this Apr 24, 2023
%--------------------------------------------------------------------------------------------------------------------
% an AAQP version of this function has been created --> PLS_wTcv_StandAlone_AQPpu
% modified from SVR_inside_PLS_predict_ONLY()
% this was extracted from PLS_predict_ONLY() 
% PLS_predict_ONLY() has typically been called by BatchRun_CrossUnits_PLS_predict_ONLY_v2(pathXU,Inp)
 %       PLSfactor_Opm=inp4PLS.PLSfactor_Opm_User_Pick;  % added by CH Nov 22, 2019
% ---------------------------------------------------------
 %  locations for output meta data as xlsx
 %   final TP file to be used for output as xlsx file
 %   prepare for output Beta as xlsx file use --> PLSmodel4Val
% Self_Pred or RMSEC
%   iscell( inp4PLS.handles_gui.AQP_class.String) && strcmp( inp4PLS.handles_gui.AQP_class.String{ inp4PLS.handles_gui.AQP_class.Value},'pro')
% deal with missing Val set case
%   % save beta applied on external Pset X_iAna_V also served as input for App Emulator
%  % store RS of Val and this when apply pp1+SNV should get Apred
% include inp4PLS.cList_Ana_to_Run into fname_FinalModel
%  % FinalModel.meanXT based on --> FinalModel.Atrainpk_CS_aft_CabXfer_aft_PPs or L.Atrainpk;
% Trim_Down_Results_fig for AQPlite for RMSECV
% Trim_Down_Results_fig for AQPlite for RMSEP 45deg plot
% Trim_Down_Results_fig for AQPlite RMSEP vs PLS factor plot
% % store pp2 into FinalModel (added Apr 3, 2020)
% % insert pp2 Apr 3, 2020
% % insert pp2 Apr 3, 2020  % deal with woCabXfer case
% save beta applied on external Pset X_iAna_V also served as input for App Emulator
% fix bug related to running PP1_PP2_xlsx together with woXRS situation, May 4, 2020
% % determine whether to create FinalModel below
% --------------------------------------------------------
% deal with woVal case by insert Tcv results into saPLS_Results_Val
%   ~isempty(inp4PLS.pathfnameTP4Val)
% % will generate Tcv results for both with or without Val set
%-----------------------------------------------------------------------------------------
% in orde to handle LSUX_RMSECV within AQPlite, this will call AAQP's PLS_wTcv_StandAlone_AQPpu Jan 5, 2023
%--------------------------------------------------------------------------------------------
% include cnt from  BatchRun_AutoQuant_DA_pipeline , Feb 25, 2023
% see also: AQP_App_Emulator --> fname_OpmFM=['OpmModel_',fileparts_name_ext( clistfilename_out{locminRP})];
%---------------------------------------------
% reset PlsfactorScan to scan to maxPlsfactorScan to avoid regression error, Apr 19, 2023
% --> maxPlsfactorScan
%-----------------------------------------------------------------------------------
% add this Apr 24, 2023 when dealing with Pset in Avg_Mean
%-----------------------------------------------------------------------------------------
if false
    
    
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%     clear;close all
%  %---- Run PLS (and generate results to be added to SVR below)  
%     pathfnameTP= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\SGw5\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-SGw5_pp2-SampMncn_nsampT183_nsampP15.mat'
%    %pathfnameTP= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\1stDer\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT183_nsampP15.mat'
% pathfname_ATwsaConc_P= ''
%     inp.run_SVR_yes=0;
%         PlsfactorScan=[1:10 12:2:30 ];
%     inp.cList_Ana_to_Run_PLS={'Pigment'}
%     
% inp.Tcv_scheme='Leave-OneConc-Out';
%     [Yest_bo_Tcv RMSE_bo_Tcv CV_bo_Tcv out]=PLS_predict_ONLY(pathfnameTP,pathfname_ATwsaConc_P,PlsfactorScan,inp);
% %------ Run SVR (with results of PLS added to same figure)
%     inp4SVR.RMSE_bo_Tcv=RMSE_bo_Tcv;
%    % pathfnameTP='C:\work\JDSU\SVR_opm\TP_XU_Pigment\SGw5\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-SGw5_pp2-SampMncn_nsampT183_nsampP15.mat'
% %    pathfnameTP='C:\work\JDSU\SVR_opm\TP_XU_Pigment\1stDer\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT183_nsampP15.mat'
%     out=SVR_inside_PLS_predict_ONLY(pathfnameTP,inp4SVR)
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  clear;close all;
  %pathfnameTP ='C:\work\JDSU\CUSTOMERS_OSP\BMS_BP\TestSite_PLS-BP\ATetc_BP\ATsaConc\Brix\Atrainpketc_saConc_{T-Brix_CS102}_pp-none_nvar125_nsampT102_nsampP102.mat'
   pathfnameTP = 'C:\work\JDSU\CUSTOMERS_OSP\BMS_BP\TestSite_PLS-BP\ATetc_BP\ATsaConc\Atrainpketc_saConc__Absorbance_S1-00550xls_PharmaLib{T-S1-00550__P-S1-00552_pp-1stDer}_pp2-SampMncn_nvar121_nsampT959_ncls48_nsampP960.mat'
   inp4PLS.pathfnameTP4Val=pathfnameTP;%very important to use same for Pset and Vset
  
   inp4PLS.handles_gui.AQP_class.String={'pro';'lite'};inp4PLS.handles_gui.AQP_class.Value=1; % for running with AQP --> 'pro'
   inp4PLS.PlsfactorScan_default=[2:10];% for running with AQP
   
   inp4PLS.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv';
    inp4PLS.cList_Ana_to_Run={'Caffeine'};
    inp4PLS.PlsfactorScan=[2:12];
    
        inp4PLS.CurTcvModelParaOpmScheme='KneePt-RMSECV'; % 'KneePt-RMSECV'   'Min-RMSECV'  'KneePt+1_RMSECV'
 %             inp4PLS.CurTcvModelParaOpmScheme='KneePt+1_RMSECV'; % 'KneePt-RMSECV'   'Min-RMSECV'  'KneePt+1_RMSECV'
%       inp4PLS.CurTcvModelParaOpmScheme='Min-RMSECV'; %  'KneePt+1_RMSECV'  'KneePt-RMSECV' 'Min-RMSECV'

    inp4PLS.TP_scheme='Tall_Pall'; % hard-coded to this for historical reason
    inp4PLS.list_C=[2:12];%this is dummy but need to put something in
    inp4PLS.Tcv_SameTset_yes=0;  % very important to set this to zero for historical reason
    
      
   inp4PLS.run_OL_analysis_Val_yes=1;inp4PLS.RMSE_thres4OLs=100;% use this to show 45 degree line plot
   PLS_inside_PLS_predict_ONLY_MLtool(pathfnameTP,inp4PLS)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning off

if iscell( inp4PLS.handles_gui.AQP_class.String) && strcmp( inp4PLS.handles_gui.AQP_class.String{ inp4PLS.handles_gui.AQP_class.Value},'pro')
sAQP_class='pro';
else
sAQP_class='lite';
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% following is important otherwise RMSEP vs PLSfactor for external Validation will not be shown
% 
% C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\inp4PLS.mat changed to [2:12] on July 29, 2020
% see AQPlite.m --> copied from --> C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\inp4PLS.mat --> a local folder called 'Tmp4AQPliteEXE'
% also see: AQP_gui.m --> Lip=load_local_try('C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\inp4PLS.mat');


%%%%%%%%%%%%%%%%%%%%%
L=load(pathfnameTP);
% check AclabelT vs saConc.SampleName
if ~isSame_AclabelT_SampleName(L)
Speak_mk('Mismatch between AclabelT_from_saConc vs SAT.AclabelT');
end
%=======================================================================
inp4PLS.PlsfactorScan=inp4PLS.PlsfactorScan_default; % copied from --> C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\inp4PLS.mat
nQ_AclabelT=length(unique(L.AclabelT)) ;
nFolds=floor(sqrt(nQ_AclabelT));
maxPlsfactorScan= nQ_AclabelT - ceil(nQ_AclabelT/nFolds)-1 ;   % reset PlsfactorScan to scan to maxPlsfactorScan to avoid regression error, Apr 19, 2023
inp4PLS.PlsfactorScan( inp4PLS.PlsfactorScan>maxPlsfactorScan)=[];
 %-------------------------------------------------
% collect list of ID for XS set
try
clistAclabelT_XS=arrayfun(@(x) x.AclabelT,L.saCTCP,'un',0);
catch
clistAclabelT_XS='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch inp4PLS.TP_scheme
    case 'Tall_P_1_4'
            X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[1:4:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);
    case 'Tall_P_1_100'
            X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[1:100:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);

    
    
    case 'Tall_Podd'
        X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[1:2:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);
    case 'Tall_Peven'
        X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[2:2:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);
        
    case 'Tall_Pall'
        X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        
        X_iAna_P=L.Apred;
        Y_iAna_P=cat(1,L.PLS.Pset.saConc.Conc);
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
   inp4Tcv.Tcv_scheme= find_keyword_between_markers( inp4PLS.handles.pm_Tcv_scheme.String{inp4PLS.handles.pm_Tcv_scheme.Value},'=','');
catch
%     inp4Tcv.Tcv_scheme='Leave-OneConc-Out';  % default (for now)
    
   inp4Tcv.Tcv_scheme= 'sqrtNSfolds-Conc'; % now this the new default
end
    inp4Tcv.para_norm=0;
    inp4Tcv.para_asmc=1;
    inp4Tcv.list_C=inp4PLS.list_C;
    inp4Tcv.PlsfactorScan=inp4PLS.PlsfactorScan;
    %%%%%%%%%%
    inp4Tcv.ktype='SVRbyLS';   %  'SVRbyLS'  'linear'
    CurAnaName=inp4PLS.cList_Ana_to_Run{1};

    switch inp4PLS.ModelPara_Opm_Scheme
        %============================================================================================================================
        case {'ModelParaOpmBy-Tcv','User-Pick'}
            if strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_T-Mean_P-All') % add this Apr 24, 2023 when dealing with Pset in Avg_Mean
                
                [X_iAna_P_Tcv, Y_iAna_P_Tcv , cSampleName_P_Tcv]=PLS_inside_PLS_predict_ONLY_MLtool__saConc2XY(L.PLS.Pset.saConc,CurAnaName); % add this Apr 24, 2023 when dealing with Pset in Avg_Mean
                
                [X_iAna_T_Tcv ,Y_iAna_T_Tcv , cSampleName_T_Tcv]=PLS_inside_PLS_predict_ONLY_MLtool__saConc2XY(L.PLS.Tset.saConc,CurAnaName);
                
            else
                [X_iAna_T_Tcv Y_iAna_T_Tcv , cSampleName_T_Tcv]=PLS_inside_PLS_predict_ONLY_MLtool__saConc2XY(L.PLS.Tset.saConc,CurAnaName);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Self_Pred or RMSEC
            if        iscell( inp4PLS.handles_gui.AQP_class.String) && strcmp( inp4PLS.handles_gui.AQP_class.String{ inp4PLS.handles_gui.AQP_class.Value},'pro')
                inp4TselfP=inp4Tcv;
                inp4TselfP.Tcv_scheme='Self-Pred';
                inp4TselfP.KPplus=1; % need this for historical reason
                OUT_TselfP=[];
                for iPf=1:length(inp4Tcv.PlsfactorScan)
                    inp4TselfP.PLSfactor=inp4TselfP.PlsfactorScan(iPf);
                    %*********************************************************
%                     if strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_Mean')
%                     outPLS_TselfP_iPf=PLS_Tcv_P_Avg_All(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4TselfP , X_iAna_P_Tcv, Y_iAna_P_Tcv , cSampleName_P_Tcv ); 
%                     else
                    outPLS_TselfP_iPf=PLS_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4TselfP);  % new and fixed
%                     end
                    %*********************************************************
                    OUT_TselfP=[OUT_TselfP;outPLS_TselfP_iPf];
                end
                disp('done with Self-Pred')
                figure;hold on;
                plot(inp4TselfP.PlsfactorScan,cat(1,OUT_TselfP.RMSE),'b-*');
                ylabel('RMSEC');xlabel('PLS factor');
                ctit11_SelfP={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
                title([inp4PLS.cList_Ana_to_Run{1},'    ','Tset Self Prediction';ctit11_SelfP]);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~inp4PLS.Tcv_SameTset_yes
                inp4Tcv.KPplus=1; % need this for historical reason
                OUT_Tcv=[];
                
                tstart = tic;
                hwb = waitbar(0,'running cross validation...');  %  waitbar
                for iPf=1:length(inp4Tcv.PlsfactorScan)
                    inp4Tcv.PLSfactor=inp4Tcv.PlsfactorScan(iPf);

                    %*********************************************************
                    if strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_T-Mean_P-All')
                        outPLS_Tcv_iPf=PLS_Tcv_P_Avg_All(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv, X_iAna_P_Tcv, Y_iAna_P_Tcv , cSampleName_P_Tcv);
                    else
                        outPLS_Tcv_iPf=PLS_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv);  % new and fixed
                    end
                    %*********************************************************

                    OUT_Tcv=[OUT_Tcv;outPLS_Tcv_iPf];
                    
                    waitbar(iPf/length(inp4Tcv.PlsfactorScan),hwb);   %  waitbar
                end
                close(hwb);% waitbar
                
                telapsed = toc(tstart);
                elapeTime_HumanRead=seconds2human_CH(telapsed);
                
                all_RMSE_PLS_Tcv=arrayfun(@(x) x.RMSE,OUT_Tcv);
                try
                    %this supposed to be based on CabXferTOOL
                    CurTcvModelParaOpmScheme= inp4PLS.handles.Tcv_ModelParaOpmScheme.String{inp4PLS.handles.Tcv_ModelParaOpmScheme.Value};
                catch
                    % this will be based on AQP
                    try
                    CurTcvModelParaOpmScheme= inp4PLS.CurTcvModelParaOpmScheme;
                    catch
                     CurTcvModelParaOpmScheme='KneePt-RMSECV';  
                    %CurTcvModelParaOpmScheme= 'Min-RMSECV';
                     
                    end
                end
                
                switch CurTcvModelParaOpmScheme
                    case 'Min-RMSECV'
                        [minRMSE_PLS_Tcv loc_Opm_PLS_Tcv]=min( all_RMSE_PLS_Tcv);
                        RMSE_PLS_Opm_Tcv=minRMSE_PLS_Tcv;
                        PLSfactor_Opm_Tcv=inp4Tcv.PlsfactorScan(loc_Opm_PLS_Tcv);
                    case {'KneePt-RMSECV','KneePt+1_RMSECV','User-Pick',  'LSUX_RMSECV' }
                        
                        just_return=0;
                        try
                            if max(inp4Tcv.PlsfactorScan)>2
                                [res_x, idx_of_result] = knee_pt(all_RMSE_PLS_Tcv,inp4Tcv.PlsfactorScan,just_return);
                            else
                                [minRMSE_PLS_Tcv loc_Opm_PLS_Tcv]=min( all_RMSE_PLS_Tcv);
                                res_x=loc_Opm_PLS_Tcv;  % set knee_pt by 'Min-RMSECV' for only two points PlsfactorScan
                            end
                        catch
                            res_x=loc_Opm_PLS_Tcv;  % set knee_pt by 'Min-RMSECV' for only two points PlsfactorScan
                        end
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        if strcmp(CurTcvModelParaOpmScheme,'KneePt+1_RMSECV')
                            if max(inp4Tcv.PlsfactorScan)>res_x
                            PLSfactor_Opm_Tcv=res_x+1;
                            else
                            PLSfactor_Opm_Tcv=res_x;    
                            end
                        elseif strcmp(CurTcvModelParaOpmScheme,'LSUX_RMSECV' )
                            inp4PLS.PlsfactorScan=[1:20];
                         out_LSUX=PLS_wTcv_StandAlone_AQPpu(pathfnameTP,inp4PLS);        % in orde to handle LSUX_RMSECV within AQPlite, this will call AAQP's PLS_wTcv_StandAlone_AQPpu Jan 5, 2023
                          PLSfactor_Opm_Tcv=out_LSUX.PLSfactor_Opm_Tcv;                             % Jan 5, 2023

                        elseif strcmp(CurTcvModelParaOpmScheme,'User-Pick')
                            res_x=NaN;
                            PLSfactor_Opm_Tcv=inp4PLS.PLSfactor_Opm_User_Pick;  % added by CH Nov 22, 2019
                        else
                            PLSfactor_Opm_Tcv=res_x;
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        RMSE_PLS_Opm_Tcv=all_RMSE_PLS_Tcv(inp4Tcv.PlsfactorScan==PLSfactor_Opm_Tcv);
                end
                outPLS_Tcv.PLSfactor_Opm=PLSfactor_Opm_Tcv;
                
                figure;hold on;set(gcf,'position',[ 889.6667  229.0000  936.6667  531.3333 ]);
                plot(inp4Tcv.PlsfactorScan,all_RMSE_PLS_Tcv,'k-*','linewidth',2);
                plot(PLSfactor_Opm_Tcv,RMSE_PLS_Opm_Tcv,'gO','markersize',10,'markerfacecolor','g');
                
                try
                    [hpvl htvl ]=plot_vline(res_x,'o');  %show results by 'KneePt-RMSECV'
                end
                
                ctit11={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
                ctit33={[inp4PLS.cList_Ana_to_Run{1},'  ',strrep(inp4PLS.ModelPara_Opm_Scheme,'_','\_'),'   PLSfactor\_opm =',num2str(PLSfactor_Opm_Tcv),'  RMSE=',roundns(RMSE_PLS_Opm_Tcv,3)]};
                
                ctit44=['Tcv\_scheme = ',OUT_Tcv(1).Tcv_scheme,'   nFolds=',num2str(OUT_Tcv(1).nFolds),'   Time Spent: ',elapeTime_HumanRead,'     Opm-LV by: ',strrep(CurTcvModelParaOpmScheme,'_','\_')];
                
                
                if strcmp(sAQP_class,'pro')
                    title([ctit11;ctit33;ctit44]);
                    ylabel('RMSECV');
                    xlabel('PLS factor')
                    
                elseif  strcmp(sAQP_class,'lite')
                    % Trim_Down_Results_fig for AQPlite for RMSECV
                    stit33lite=  strrep(['PLSfactor', find_keyword_between_markers( ctit33{1},'PLSfactor','')  ],'RMSE','RMSECV');
                    title([stit33lite]);
                    ylabel('RMSECV');
                    xlabel('PLS factor')
                end
            else
                outPLS_Tcv.PLSfactor_Opm= inp4PLS.outPLS_Tcv_prev.PLSfactor_Opm; % new and fixed
            end
            %============================================================================================================================
        case {'ModelParaOpmBy-XS_KSall','ModelParaOpmBy-XS_KS1','ModelParaOpmBy-XS_KS2','ModelParaOpmBy-XS_KS3','ModelParaOpmBy-XS_KS4','ModelParaOpmBy-XS_KS5','ModelParaOpmBy-XS_KS6', 'ModelParaOpmBy-XS_KS8','ModelParaOpmBy-XS_KS10', 'ModelParaOpmBy-XS_KS12', 'ModelParaOpmBy-XS_KS24', 'ModelParaOpmBy-XS_KS25', 'ModelParaOpmBy-XS_KS30', 'ModelParaOpmBy-XS_KS36', 'ModelParaOpmBy-XS_KS40', 'ModelParaOpmBy-XS_KS48', 'ModelParaOpmBy-XS_KS101'  }
            
            [X_iAna_P Y_iAna_P  cSampleName_P]=PLS_inside_PLS_predict_ONLY_MLtool__saConc2XY(L.PLS.Pset.saConc,CurAnaName);
            
            
            
            nKS=find_keynumber_numeric_AFTER_marker (inp4PLS.ModelPara_Opm_Scheme,'KS');
            
            %         allC_T=arrayfun(@(x) x.Conc,LT.saConc);
            %         [qC_T nC_T]=unique_count(allC_T);
            %         [idxTrn_T] = find(kennardstone( qC_T, nKS));
            
            allC_P=arrayfun(@(x) x.Conc,L.PLS.Pset.saConc);
            [qC_P nC_P]=unique_count(allC_P);
            try
                [idxTrn_P] = find(kennardstone( qC_P, nKS));% XS for Trg is based on KSn selection Solely based on Pset (Test in the case of IDRR) and should not be used for CabXfer !!!
            catch
                try
                    
                    % when not using PLS toolbox (e.g. not allowed to compile their codes)
                    % run with functions in 'C:\work\Mfiles\all_Mfile_xLAN\matlab_toolbox\attic_PLS_Toolbox'
                    % and mimic kennardstone's response to nKS=NaN situation
                    if isnan(nKS)
                        idxTrn_P=[1:length(qC_P)];   % this is the reponse of PLStoolbox's  kennardstone() for nKS=NaN
                    else
                        [idxTrn_P] = KennardStone( qC_P, nKS);
                    end
                    
                    
                catch
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % deal with KSn=1 or KSn=2
                    if nKS==1 || nKS==2
                        switch nKS
                            case 1
                                %                             Conc_KSpick_P= median(qC_P);
                                %                             idxTrn_P=find(qC_P==Conc_KSpick_P);
                                
                                if is_odd(length(qC_P))
                                    Conc_KSpick_P= median(qC_P);
                                    idxTrn_P=find(qC_P==Conc_KSpick_P);
                                else
                                    Conc_KSpick_P= median(qC_P);
                                    idxTrn_P=find(qC_P==Conc_KSpick_P);
                                    if isempty(idxTrn_P)
                                        [minDif locminDif]=     min(abs(qC_P-Conc_KSpick_P));
                                        idxTrn_P= locminDif;
                                    end
                                end
                                
                            case 2
                                Conc_KSpick_P= [min(qC_P);max(qC_P)];
                                idxTrn_P=find_belong2subgrp(qC_P,Conc_KSpick_P);
                        end
                    else
                        error('can not handle this case, KSn is not 1 or 2 and still can not run KennardStone ?')
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
            
            
            Conc_KSpick_P= qC_P(idxTrn_P);% XS for Trg is based on KSn selection Solely based on Pset (Test in the case of IDRR) and should not be used for CabXfer !!!
            %%%%%%%%%%%%%%%%
            % work on fixing bug ???
            %         [X_iAna_T Y_iAna_T  cSampleName_T]=saConc2XY(L.PLS.Tset.saConc,CurAnaName);
            %         allC_T=arrayfun(@(x) x.Conc,L.PLS.Tset.saConc);
            %         [qC_T nC_T]=unique_count(allC_T);
            %                 [idxTrn_T] = find(kennardstone( qC_T, nKS));% XS for Trg is based on KSn selection Solely based on Pset (Test in the case of IDRR) and should not be used for CabXfer !!!
            %
            %          Conc_KSpick_T= qC_T(idxTrn_T);% XS for Trg is based on KSn selection Solely based on Pset (Test in the case of IDRR) and should not be used for CabXfer !!!
            %%%%%%%%%%%%%%%%%
            
            
            idx_saConcSampleName_KS_P= arrayfun(@(x) PLS_inside_PLS_predict_ONLY_MLtool__isKSpick(x,Conc_KSpick_P),L.PLS.Pset.saConc);
            clist_OddEvenConc_P=unique(L.AclabelP(idx_saConcSampleName_KS_P));
            
            if ~isempty(clistAclabelT_XS)
                clist_OddEvenConc_P=clistAclabelT_XS;  % overwrite by clistAclabelT_XS !!!!!!!!!!
            else
                disp('clistAclabelT_XS NOT provided somehow ???')
            end
            
            locXP=find(cellfun(@(x) ~isempty(strmatch(x,clist_OddEvenConc_P,'exact')),L.AclabelP));% XS for Trg is based on KSn selection Solely based on Pset (Test in the case of IDRR) and should not be used for CabXfer !!!
            if isempty(X_iAna_P)
                error('Analyte Name may NOT found in this dataset ?')
            end
            
            X_iAna_P_XS= X_iAna_P(locXP,:);   % XS for Trg is based on KSn selection Solely based on Pset (Test in the case of IDRR) and should not be used for CabXfer !!!
            Y_iAna_P_XS = Y_iAna_P(locXP,:);% XS for Trg is based on KSn selection Solely based on Pset (Test in the case of IDRR) and should not be used for CabXfer !!!
            % cSampleName_P_XS=cSampleName_P(locXP,:);
            %         unique(cellfun(@(x) x{1},cSampleName_P_XS,'un',0))
            % saSVR_Results_XS=SVR_indv(X_iAna_T,X_iAna_P_XS,Y_iAna_T,Y_iAna_P_XS,inp4Tcv);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % check to see if Pset is a subset of Tset, if that happen, overfit will
            % happen in finding Opm PLS factor
            
            [LIA,LOCB] = ismember(X_iAna_P_XS,X_iAna_T,'rows');
            if all(LIA)&& ( ~strcmp(inp4PLS.CurUDMas,'Scv') && ~strcmp(inp4PLS.CurUDMas,'Split_KSnX') &&  ~strcmp(inp4PLS.CurUDMas,'Split_KSnY')  )
                Speak_mk('Scouting set is a subset of training set, overfit may happen in finding Optimal PLS factor');
                warning('XS is a subset of CS, overfit may happen in finding OpmPLSfactor')
            end
            % nMatch=0;
            % for iXS=1:length(X_iAna_P_XS(:,1))
            %     if length(find(sum( X_iAna_T-X_iAna_P_XS(iXS,:),2 )==0))>0
            %         nMatch=nMatch+1;
            %     end
            % end
            % if nMatch==length(X_iAna_P_XS(:,1))
            %     Speak_mk('Scouting set is a subset of training set, overfit may happen in finding Optimal PLS factor');
            %     error('XS is a subset of CS, overfit may happen in finding OpmPLSfactor')
            % end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if (strcmp(inp4PLS.CurUDMas,'Scv')| strcmp(inp4PLS.CurUDMas,'Split_KSnX')| strcmp(inp4PLS.CurUDMas,'Split_KSnY') ) && ~isempty( inp4PLS.all_RMSE_PLS_Scv)
                %            saSVR_Results_XS
                
                % following results done by PLS_Scv()  inside Regressor_Callback() inside CabXferLite.m
                % and stored in inp4PLS and passed into this function
                figure;hold on;
                all_C_XS=inp4PLS.PlsfactorScan;
                all_RMSE_SVR_XS=inp4PLS.all_RMSE_PLS_Scv;
                
            else
                saSVR_Results_XS=PLS_indv(X_iAna_T,X_iAna_P_XS,Y_iAna_T,Y_iAna_P_XS,inp4Tcv);
                
                figure;hold on;
                all_C_XS=arrayfun(@(x) x.PLSfactor,saSVR_Results_XS);
                all_RMSE_SVR_XS=arrayfun(@(x) x.RMSE,saSVR_Results_XS);
                
                
            end
            
            
            
            
            [RMSE_SVR_min_XS loc_minRMSE_SVR_XS]=min(all_RMSE_SVR_XS);
            % RMSE_SVR_min=minRMSE_SVR;
            
            C_SVR_min_XS=all_C_XS(loc_minRMSE_SVR_XS);   % this is actually based on PLS and should be OpmPLSfactor
            
            % plot(log10(all_C_XS),all_RMSE_SVR_XS,'k-*','linewidth',2);
            % plot(log10(C_SVR_min_XS),RMSE_SVR_min_XS,'gO','markersize',10,'markerfacecolor','g');
            plot(all_C_XS,all_RMSE_SVR_XS,'k-*','linewidth',2);
            plot(C_SVR_min_XS,RMSE_SVR_min_XS,'gO','markersize',10,'markerfacecolor','g');
            xlabel('PLS factor');
            ylabel('RMSE by PLS');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                if ~isempty(inp4PLS.elapeTime_HumanRead)
                    str_time=[ ' ( time : ',strrep(inp4PLS.elapeTime_HumanRead,'sec.','sec'),' )'];
                else
                    str_time=[];
                end
            catch
                str_time=[];
            end
            %%%%%%%%%%
            
            try
                if ~isempty(inp4PLS.CrossValidationType)
                    str_CVtype=[ ' CVtype:',strrep(inp4PLS.CrossValidationType,'_','\_')];
                else
                    str_CVtype=[];
                end
            catch
                str_CVtype=[];
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ctit11={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
            try
                ctit22={['UDMas: ',strrep(inp4PLS.CurUDMas,'_','\_'),'   ',str_CVtype,'   ',str_time]};
            catch
                ctit22='';
            end
            ctit33={[strrep(inp4PLS.ModelPara_Opm_Scheme,'_','\_'),'   C\_opm =',num2str(C_SVR_min_XS),'  RMSE=',roundns(RMSE_SVR_min_XS,3)]};
            title([ctit11;ctit22;ctit33]);
            
            %============================================================================================================================
            
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch inp4PLS.ModelPara_Opm_Scheme
    case 'User-Pick'
        PLSfactor_Opm=outPLS_Tcv.PLSfactor_Opm;
    case 'ModelParaOpmBy-Tcv'
        PLSfactor_Opm=outPLS_Tcv.PLSfactor_Opm;
    case {'ModelParaOpmBy-XS_KSall','ModelParaOpmBy-XS_KS1','ModelParaOpmBy-XS_KS2','ModelParaOpmBy-XS_KS3','ModelParaOpmBy-XS_KS4','ModelParaOpmBy-XS_KS5','ModelParaOpmBy-XS_KS6', 'ModelParaOpmBy-XS_KS8', 'ModelParaOpmBy-XS_KS10', 'ModelParaOpmBy-XS_KS12', 'ModelParaOpmBy-XS_KS24', 'ModelParaOpmBy-XS_KS25', 'ModelParaOpmBy-XS_KS30', 'ModelParaOpmBy-XS_KS36', 'ModelParaOpmBy-XS_KS40', 'ModelParaOpmBy-XS_KS48', 'ModelParaOpmBy-XS_KS101'   } 
        PLSfactor_Opm=C_SVR_min_XS;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run PLS on whole Pset
        X_iAna_P_whole=L.Apred;
        Y_iAna_P_whole=cat(1,L.PLS.Pset.saConc.Conc);


 saSVR_Results_Pwhole=PLS_indv(X_iAna_T,X_iAna_P_whole,Y_iAna_T,Y_iAna_P_whole,inp4Tcv);
  
try
 PLSfactor_Pest=   inp4PLS.PLSfactor_Pest;
 loc_saResults=find(arrayfun(@(x) x.PLSfactor==PLSfactor_Pest,saSVR_Results_Pwhole));
 sa_Results_out=saSVR_Results_Pwhole(loc_saResults);
 fname_outPest=strrep(fileparts_name_ext(pathfnameTP),'Atrainpk',['Pest_PLSfactor',num2str(PLSfactor_Pest),'_Atrainpk']);
 save(fname_outPest,'-struct','sa_Results_out');
 disp([fname_outPest,' has been saved']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_PLSfactor=arrayfun(@(x) x.PLSfactor,saSVR_Results_Pwhole);
all_RMSE_PLS=arrayfun(@(x) x.RMSE,saSVR_Results_Pwhole);
[RMSE_PLS_min loc_minRMSE_PLS]=min(all_RMSE_PLS);
% RMSE_SVR_min=minRMSE_SVR;

PLSfactor_PLS_min=all_PLSfactor(loc_minRMSE_PLS);
RMSE_PLS_Opm=all_RMSE_PLS(all_PLSfactor==PLSfactor_Opm);

% following figure only for non-Tcv AND non-User-Pick case
if ~strcmp(inp4PLS.ModelPara_Opm_Scheme,'ModelParaOpmBy-Tcv' ) && ~strcmp(inp4PLS.ModelPara_Opm_Scheme,'User-Pick' )
    
    figure;hold on;                
    plot(all_PLSfactor,all_RMSE_PLS,'k-*','linewidth',2);
    % C_SVR_Opm
    plot(PLSfactor_Opm,RMSE_PLS_Opm,'gO','markersize',15,'markerfacecolor','g');
    plot(PLSfactor_PLS_min,RMSE_PLS_min,'bO','markersize',12,'markerfacecolor','b');
    xlabel('PLS factor');
    ylabel('RMSE by PLS');
    % inp_plot_hline.label='PLS';
    % % [hphl hthl ]=plot_hline(out.RMSE_bo_Tcv,'b',inp_plot_hline );
    %  [hphl hthl ]=plot_hline(inp4PLS.RMSE_bo_Tcv,'b',inp_plot_hline );
    ctit1={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
    ctit2={['PLSfactor@min =',num2str(PLSfactor_PLS_min),'  min RMSE=',roundns(RMSE_PLS_min,3)]};
    ctit3={[strrep(inp4PLS.ModelPara_Opm_Scheme,'_','\_'),'   PLSfactor\_opm =',num2str(PLSfactor_Opm),'  RMSE=',roundns(RMSE_PLS_Opm,3)]};
    title([ctit1;ctit2;ctit3]);
end
%================================================================= 
% work on Val set wConc by PLS
try  % if causing error will go to --> error('something wrong with work on Val set wConc by PLS')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inp4V=inp4Tcv;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pick OpmPLSfactor by user input
    PLSfactor_PickByUser_yes=1;
    if PLSfactor_PickByUser_yes  && strcmp(inp4PLS.ModelPara_Opm_Scheme,'ModelParaOpmBy-Tcv' )
        try
            PLSfactor_Opm=str2num(find_keyword_numeric_AFTER_marker(inp4PLS.handles.sOpmPLS_Pick.String,'='));
        catch
            PLSfactor_Opm='';
        end
        if isempty(PLSfactor_Opm)
            PLSfactor_Opm= PLSfactor_Opm_Tcv;
            sAltOpmPLS='';
        else
            sAltOpmPLS=' (PickByUser)';
        end
        
    else
        sAltOpmPLS='';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(inp4PLS.pathfnameTP4Val)
        
        inp4V.PlsfactorScan=PLSfactor_Opm;
        
        pathfnameTP4Val=inp4PLS.pathfnameTP4Val;
        %         L_Val= load('C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mA_mB_P-mC_Val\Atrainpketc_saConc_IDRC_{T-ManufacturerA_Cal_CalSetA123_P-mC_Val_pp1-1stDerSGw13}_nvar88_nsampTT744_nsampP150.mat')
        
        % final TP file to be used for output as xlsx file
        L_Val= load(pathfnameTP4Val);% final TP file to be used for output as xlsx file
        
        X_iAna_V=L_Val.Apred;   % for Val set
        Y_iAna_V=cat(1,L_Val.PLS.Pset.saConc.Conc);   % for Val set
        %         saSVR_Results_Val=SVR_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V);
        
        if length(L_Val.Atrainpk(:,1))>length(X_iAna_T(:,1))% the case of add UDM
            X_iAna_T=L_Val.Atrainpk;
            Y_iAna_T=cat(1,L_Val.PLS.Tset.saConc.Conc);
        end
        
        saPLS_Results_Val=PLS_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V);
    else
        % deal with missing Val set case
        % % deal with woVal case by insert Tcv results into saPLS_Results_Val
        %%%%%%%%%%%%%%%%
        %---------------------------------------------------------------------------------------
        % New approach After 1008, 2020--> use Tcv results
       %  RMSE_PLS_Opm_Tcv=all_RMSE_PLS_Tcv(inp4Tcv.PlsfactorScan==PLSfactor_Opm_Tcv);
        saPLS_Results_Val.PLSfactor=PLSfactor_Opm_Tcv;% deal with woVal case by insert Tcv results into saPLS_Results_Val
        saPLS_Results_Val.RMSE=RMSE_PLS_Opm_Tcv;% deal with woVal case by insert Tcv results into saPLS_Results_Val
        % % checking
        inp4Tcv_Opm=inp4Tcv;
        inp4Tcv_Opm.PLSfactor=PLSfactor_Opm_Tcv;
        
        %*********************************************************
        if strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_T-Mean_P-All')
              outPLS_Tcv_Opm=PLS_Tcv_P_Avg_All(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv_Opm, X_iAna_P_Tcv, Y_iAna_P_Tcv , cSampleName_P_Tcv); 
        else
            outPLS_Tcv_Opm=PLS_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv_Opm);  % new and fixed
        end
        %*********************************************************
        if  outPLS_Tcv_Opm.RMSE==RMSE_PLS_Opm_Tcv      % checking
            saPLS_Results_Val.Yest_PLS=outPLS_Tcv_Opm.Yest_all;              % deal with woVal case by insert Tcv results into saPLS_Results_Val
            saPLS_Results_Val.Y_iAna_P=Y_iAna_T_Tcv;                                 % deal with woVal case by insert Tcv results into saPLS_Results_Val
            saPLS_Results_Val.beta=NaN;                                                        % deal with woVal case by insert Tcv results into saPLS_Results_Val
        else
            error('mismatch between outPLS_Tcv_Opm.RMSE vs RMSE_PLS_Opm_Tcv')
        end
        %------------------------------------------------------------------------------------------------
    end  % end of ~isempty(inp4PLS.pathfnameTP4Val)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save beta applied on external Pset X_iAna_V also served as input for App Emulator
    % determine whether to create FinalModel below
%     if  iscell( inp4PLS.handles_gui.AQP_class.String) && strcmp( inp4PLS.handles_gui.AQP_class.String{ inp4PLS.handles_gui.AQP_class.Value},'pro')  % save beta applied on external Pset X_iAna_V also served as input for App Emulator
        if  ( iscell( inp4PLS.handles_gui.AQP_class.String) && strcmp( inp4PLS.handles_gui.AQP_class.String{ inp4PLS.handles_gui.AQP_class.Value},'pro')) || (  ischar( inp4PLS.handles_gui.AQP_class.String) && strcmp(inp4PLS.handles_gui.AQP_class.String,'pro'  )  )  % save beta applied on external Pset X_iAna_V also served as input for App Emulator
   
            if isempty(inp4PLS.pathfnameTP4Val)   % deal with woVal case by insert Tcv results into FinalModel
                
                FinalModel.RMSEP=outPLS_Tcv_Opm.RMSE;                                       % deal with woVal case by insert Tcv results into FinalModel
                FinalModel.pp1=inp4PLS.pp1;                   % store pp1 into FinalModel  % deal with woVal case by insert Tcv results into FinalModel
                FinalModel.pp2=inp4PLS.pp2;                   % store pp2 into FinalModel (added Apr 3, 2020) % deal with woVal case by insert Tcv results into FinalModel
                
                sFinal_PLSfactor= ['_PLSfactor',num2str(saPLS_Results_Val.PLSfactor)];
                
            else
                beta_final_model=saPLS_Results_Val.beta;
                Yest_V_final_model = [ones(size(X_iAna_V,1),1) X_iAna_V]* beta_final_model;
                RMSE_final_model=RMS_error_woNaN_N(Yest_V_final_model,saPLS_Results_Val.Y_iAna_P);     % modified by CH, Jan 24, 2020
                FinalModel.beta=beta_final_model;
                FinalModel.Apred=X_iAna_V;
                FinalModel.Pest=Yest_V_final_model;
                FinalModel.Pref=saPLS_Results_Val.Y_iAna_P;
                FinalModel.RMSEP=RMSE_final_model;
                FinalModel.pp1=inp4PLS.pp1;                   % store pp1 into FinalModel
                FinalModel.pp2=inp4PLS.pp2;                   % store pp2 into FinalModel (added Apr 3, 2020)
                FinalModel.RawSpectra_Val= L_Val.RawSpectra.Pset;   % store RS of Val and this when apply pp1+SNV should get Apred
                FinalModel.RawSpectra_CS_aft_CabXfer_bef_PPs=L.RawSpectra.Tset;
                FinalModel.Atrainpk_CS_aft_CabXfer_aft_PPs=L.Atrainpk;
                FinalModel.meanXT=mean(L.Atrainpk);    % FinalModel.meanXT based on --> FinalModel.Atrainpk_CS_aft_CabXfer_aft_PPs or L.Atrainpk;
                
                
                allYT=cat(1,L.PLS.Tset.saConc.Conc);
                if length(allYT)~=length(L.Atrainpk(:,1))
                    error('something wrong with size of allYT or L.Atrainpk')
                else
                    FinalModel.meanYT =mean(allYT);
                end
                sFinal_PLSfactor= ['_PLSfactor',num2str(saPLS_Results_Val.PLSfactor)];
                
            end
        % pathfnameTP4Val
        if ~isempty(inp4PLS.pathfnameTP4Val)
            corename4FinalModel=  find_keyword_between_markers(fileparts_name_ext( pathfnameTP4Val),'Atrainpketc_','_nsampXS');
            if isempty(corename4FinalModel)
                corename4FinalModel=  find_keyword_between_markers(fileparts_name_ext( pathfnameTP4Val),'{','}');
            end
            % include inp4PLS.cList_Ana_to_Run into fname_FinalModel
             %=================================================================
           % include cnt from  BatchRun_AutoQuant_DA_pipeline , Feb 25, 2023 
            fname_FinalModel=['Beta_etc_FinalModel_cnt-', num2str(inp4PLS.cnt),'_' ,inp4PLS.cList_Ana_to_Run{1},sFinal_PLSfactor,'_{',corename4FinalModel,'}.mat'];
        else
            % include inp4PLS.cList_Ana_to_Run into fname_FinalModel
           % fname_FinalModel=['Beta_etc_FinalModel_',inp4PLS.cList_Ana_to_Run{1},sFinal_PLSfactor,'_',find_keyword_between_markers(fileparts_name_ext( pathfnameTP4Val),'Atrainpketc_',']_nsampT'),'.mat'];
            %=================================================================
           % include cnt from  BatchRun_AutoQuant_DA_pipeline , Feb 25, 2023 
           fname_FinalModel=['Beta_etc_FinalModel_cnt-', num2str(inp4PLS.cnt),'_',inp4PLS.cList_Ana_to_Run{1},sFinal_PLSfactor,'_',find_keyword_between_markers(fileparts_name_ext( pathfnameTP),'Atrainpketc_','_nsampP'),'.mat'];
              fname_FinalModel=strrep(fname_FinalModel,'}]','}');
          %  fname_FinalModel=strrep(fname_FinalModel,'.mat','_missing_Val.mat');
            
        end
        find_keyword_between_markers(fname_FinalModel,'_','.mat')
        try
            if ~isempty(inp4PLS.tmpfolder4AllFinalModels)
                fname_FinalModel= [inp4PLS.tmpfolder4AllFinalModels,'\',fname_FinalModel];
            end
        end
        if  ~isempty(strfind(fname_FinalModel,'}_nsampT'))
            fname_FinalModel=strrep( fname_FinalModel,'}_nsampT',['_pp2-',inp4PLS.pp2,'}_nsampT']);   % insert pp2 Apr 3, 2020
        else
            fname_FinalModel=strrep( fname_FinalModel,'}.mat',['_pp2-',inp4PLS.pp2,'}.mat']);   % insert pp2 Apr 3, 2020  % deal with woCabXfer case
        end
        
         if  ~isempty(strfind(fname_FinalModel,'_pp2')) && isempty(strfind(fname_FinalModel,'pp1'))      % fix bug related to running PP1_PP2_xlsx together with woXRS situation, May 4, 2020
                    fname_FinalModel=strrep( fname_FinalModel,'_pp2',['_pp1-',inp4PLS.pp1,'_pp2']);   % insert pp1 May 4, 2020  % fix bug related to running PP1_PP2_xlsx together with woXRS situation, May 4, 2020
         end
         
         
        save( fname_FinalModel,'-struct','FinalModel');
        disp('save beta applied on "Pset X_iAna_V"')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if false
        figure;hold on;
        plot(X_iAna_V','k-*')
        plot(X_iAna_T','r-O')
        
        %             title('Old')
        %             save('TV_old.mat','X_iAna_T','X_iAna_V','Y_iAna_T','Y_iAna_V')
        title('New')
        save('TV_new.mat','X_iAna_T','X_iAna_V','Y_iAna_T','Y_iAna_V')
        
        
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %          figure;hold on;
    %          plot(saPLS_Results_Val.Y_iAna_P,saPLS_Results_Val.Yest_PLS,'r*');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %          inp4V_scan=inp4V;
    %          inp4V_scan.PlsfactorScan=[1:20];
    %          saPLS_Results_Val_scan=PLS_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V_scan);
    %          RMSE_V_scan=cat(1,saPLS_Results_Val_scan.RMSE);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Clean up Outliers
    % for historical reason, the following section need to run,
    % in order to disable its effect, inp4PLS.RMSE_thres4OLs was set
    % to inf
%     if  inp4PLS.run_OL_analysis_Val_yes==1 && ~isempty(inp4PLS.pathfnameTP4Val)
        if  inp4PLS.run_OL_analysis_Val_yes==1 % will generate Tcv results for both with or without Val set
            warning off
         % will generate Tcv results for both with or without Val set
          if strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_T-Mean_P-All')
            dd=abs(Y_iAna_P_Tcv-saPLS_Results_Val.Yest_PLS);   
          else
        dd=abs(saPLS_Results_Val.Y_iAna_P-saPLS_Results_Val.Yest_PLS);
          end
        
        %          figure;hold on;plot(dd,'b-*');
        %          RMSE_thres4OLs=100;                  % make this so big that should basically rule out the possibility of any OLs
        RMSE_thres4OLs= inp4PLS.RMSE_thres4OLs;
        
        %          locOL=find(dd>1);
        locOL=find(dd>RMSE_thres4OLs);% hard-coded
        
        loc_Clean=find(dd<=RMSE_thres4OLs);
        figure;hold on;set(gcf,'position',1000*[ 1.0383    0.1410    0.9373    0.5313 ]);  % updated 1009, 2020
        
        if strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_T-Mean_P-All')
         plot(Y_iAna_P_Tcv,saPLS_Results_Val.Yest_PLS,'b*');
        plot(Y_iAna_P_Tcv(locOL),saPLS_Results_Val.Yest_PLS(locOL),'rO');   
        else
        plot(saPLS_Results_Val.Y_iAna_P,saPLS_Results_Val.Yest_PLS,'b*');
        plot(saPLS_Results_Val.Y_iAna_P(locOL),saPLS_Results_Val.Yest_PLS(locOL),'rO');
        end
        
        plot_45degree_line('y');
        xlabel('True Conc');
        ylabel('Est Conc');
        
         warning off
        %RMSE_clean=RMS_error_woNaN(saPLS_Results_Val.Y_iAna_P(loc_Clean),saPLS_Results_Val.Yest_PLS(loc_Clean));
        if strcmp(inp4PLS.Spectra_Avg_Method,'Spectra_Avg_T-Mean_P-All')
            RMSE_clean=RMS_error_woNaN_N(Y_iAna_P_Tcv(loc_Clean),saPLS_Results_Val.Yest_PLS(loc_Clean));
        STD_clean=std(Y_iAna_P_Tcv(loc_Clean)-saPLS_Results_Val.Yest_PLS(loc_Clean));
        Bias_clean=mean(Y_iAna_P_Tcv(loc_Clean)-saPLS_Results_Val.Yest_PLS(loc_Clean));  
            
        else
        RMSE_clean=RMS_error_woNaN_N(saPLS_Results_Val.Y_iAna_P(loc_Clean),saPLS_Results_Val.Yest_PLS(loc_Clean));
        STD_clean=std(saPLS_Results_Val.Y_iAna_P(loc_Clean)-saPLS_Results_Val.Yest_PLS(loc_Clean));
        Bias_clean=mean(saPLS_Results_Val.Y_iAna_P(loc_Clean)-saPLS_Results_Val.Yest_PLS(loc_Clean));
        end
        
        
        pathfnameTP_alt=strrep(pathfnameTP,'_{MDC','_MDC');  % fixed this Aug 25, 2020
        
        stit_TP=['TP: ',strrep(fileparts_name_ext( pathfnameTP_alt ),'_','\_')];
        stit_TP=strrep(stit_TP,'}}','}');% fixed this Aug 25, 2020
%         warning on
        
        if ~strcmp(inp4PLS.pathfnameTP4Val,pathfnameTP)
            warning off
            try
                 pathfnameTP4Val_alt=strrep(pathfnameTP4Val,'_{MDC','_MDC');  % fixed this Aug 25, 2020
            stit_Val=['Val: ',strrep(fileparts_name_ext( pathfnameTP4Val_alt ),'_','\_')];
              stit_Val=strrep(stit_Val,'}}','}');% fixed this Aug 25, 2020
            catch
                stit_Val='';
            end
%             warning on
        else
            stit_Val='';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            Cur_Analyte=inp4PLS.handles.sAnalyte.String{inp4PLS.handles.sAnalyte.Value};
        catch
            if length(inp4PLS.cList_Ana_to_Run)==1
                Cur_Analyte=  inp4PLS.cList_Ana_to_Run{1};
            else
                Cur_Analyte='Unknown';
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%
        try
            PP_Bef=inp4PLS.handles.PreprocessingMethods.String{inp4PLS.handles.PreprocessingMethods.Value};
            PP_Aft=inp4PLS.handles.AftCX_PP.String{inp4PLS.handles.AftCX_PP.Value};
            if strcmp(PP_Aft,'none+none')||strcmp(PP_Aft,'AftCX_PreprocessingMethods')
                stit_PP=['PP Bef CabXfer: ',PP_Bef];
            elseif  strcmp(PP_Bef,'none+none')
                stit_PP=['PP Aft CabXfer: ',PP_Aft];
            else
                stit_PP='Error';
                disp('can not have both PP active')
                warning('can not have both PP active')
                
            end
        catch
            stit_PP='';
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        % inp4PLS.CurTcvModelParaOpmScheme
        if isempty(locOL)
            % updated 1009, 2020
             warning off
            stit_TP=strrep(stit_TP,'}]','');% updated 1009, 2020
            if isempty(stit_Val) && isempty(stit_PP)
               
                stit_PP=[ inp4PLS.pp1 ,' + ',  inp4PLS.pp2];% updated 1009, 2020
                if isempty(inp4PLS.pathfnameTP4Val)   % deal with woVal case by insert Tcv results into saPLS_Results_Val and FinalModel
                    stit_TP=strrep(stit_TP,'TP:','Tset Alone:');% updated 1009, 2020  % deal with woVal case by insert Tcv results into saPLS_Results_Val and FinalModel
                    stit_TP=find_keyword_between_markers(stit_TP,'','\_nsampP');% updated 1009, 2020  % deal with woVal case by insert Tcv results into saPLS_Results_Val and FinalModel
                end
                stit_TP=strrep(stit_TP,'{','');
                stit_TP=strrep(stit_TP,'}','');
                title(remove_empty_cell(   {[Cur_Analyte,'    ',stit_PP];stit_TP;...
                    [strrep(inp4PLS.CurTcvModelParaOpmScheme,'_','\_'),'-->','OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),sAltOpmPLS,'   RMSE =',roundns(RMSE_clean,3),'      STD =',roundns(STD_clean,3), '      Bias =',roundns(Bias_clean,3)  ] }    )  );
%                 warning on
           
            else
                if strcmp(sAQP_class,'pro')

                    stit_TP=strrep(stit_TP,'}','');  % tricky bug caused by unbalanced curly bracket ?
                    stit_TP=strrep(stit_TP,'{','');  % tricky bug caused by unbalanced curly bracket ?
                    stit_wVal=remove_empty_cell({[Cur_Analyte,'    Pest by PLS '];stit_TP;stit_Val;stit_PP;[strrep(inp4PLS.CurTcvModelParaOpmScheme,'_','\_'),'-->','OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),sAltOpmPLS,'   RMSE =',roundns(RMSE_clean,3),'      STD =',roundns(STD_clean,3), '      Bias =',roundns(Bias_clean,3)  ] });
                    title(stit_wVal);
                elseif  strcmp(sAQP_class,'lite')
                    % Trim_Down_Results_fig for AQPlite for RMSEP 45deg plot
                    title( ['OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),sAltOpmPLS,'   RMSEP =',roundns(RMSE_clean,3),'      STD =',roundns(STD_clean,3), '      Bias =',roundns(Bias_clean,3)  ])
                end
                
            end
        else
%             warning off
            title(  remove_empty_cell(   {[Cur_Analyte,'   Pest by PLS   Val set that has been Cleaned by removing: ',num2str(row_always(locOL))];...
                [strrep(inp4PLS.CurTcvModelParaOpmScheme,'_','\_'),'-->','OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),'  RMSE =',roundns(RMSE_clean,3),'      STD =',roundns(STD_clean,3), '      Bias =',roundns(Bias_clean,3)  ] }    )     );
%             warning on
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        title_add(gca,fileparts_name_ext( pathfnameTP));
        title_add(gca,inp4PLS.Spectra_Avg_Method);
        %---------------------------------------
        % output beta (PLS model) for running prediction on Val -->"saPLS_Results_Val.beta"
        try
            PLSmodel4Val.beta=saPLS_Results_Val.beta;
            PLSmodel4Val.OpmPLSfactor=inp4V.PlsfactorScan;
            %checking
            Y_iAna_est_V = [ones(size(X_iAna_V,1),1) X_iAna_V]*PLSmodel4Val.beta;
            RMSE_V=RMS_error_woNaN_N(saPLS_Results_Val.Y_iAna_P,Y_iAna_est_V);
            if RMSE_clean~=RMSE_V
                error('something wrong with beta in PLSmodel4Val');
            else
                warning off
                corename4Val= strrep( strrep(find_keyword_between_markers(fileparts_name_wo_ext(inp4PLS.pathfnameTP4Val),'{','}'),'_Val',''),'_pp1-','_');
%                 warning on
                PPvsCab= find_keyword_between_markers(stit_PP,'',':');
                spp2=find_keyword_between_markers(stit_PP,'+','');
                corename4Val=[corename4Val,'+',spp2];
                corename4Val=[corename4Val,'_',PPvsCab];
                % remove the following because similar results have been saved
                %             fname4PLSmodel4Val=['Beta4Val_',Cur_Analyte,'_',corename4Val,'.mat'];
                %             save(fname4PLSmodel4Val,'-struct','PLSmodel4Val');
                %             disp([fname4PLSmodel4Val,'has been saved']);
                %%% prepare for output Beta as xlsx file use --> PLSmodel4Val
                
                %===================================================
                % also output --> saPLS_Results_Val
                fname4saPLS_Results_Val=['saPLS_Results_Val_',Cur_Analyte,'_',corename4Val,'.mat'];
                S_saPLS_Results_Val.saPLS_Results_Val=saPLS_Results_Val;
                save(fname4saPLS_Results_Val,'-struct','S_saPLS_Results_Val');
                disp([fname4saPLS_Results_Val,'has been saved']);
                %===================================================
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         warning on
    end
    %%%%%%%%%%%%%%%%%%%%%%
    % Pest by GLS+SVR
    %          Lest_GLS_SVR=load('C:\work\JDSU\ModelsTransferMLtool\Results\Pest\mC_Val_est_GLS_SVR.mat');
    %          figure;hold on;plot(Lest_GLS_SVR.Val_Conc,Lest_GLS_SVR.Yest_SVR,'c*');
    %                   plot(Lest_GLS_SVR.Val_Conc(locOL),Lest_GLS_SVR.Yest_SVR(locOL),'mO');
    %                            plot_45degree_line('y');
    %
    %                  RMSE_clean_GLS_SVR=RMS_error_woNaN(Lest_GLS_SVR.Val_Conc(loc_Clean),Lest_GLS_SVR.Yest_SVR(loc_Clean));
    %                  STD_clean_GLS_SVR=std(Lest_GLS_SVR.Val_Conc(loc_Clean)-Lest_GLS_SVR.Yest_SVR(loc_Clean));
    %                  Bias_clean_GLS_SVR=mean(Lest_GLS_SVR.Val_Conc(loc_Clean)-Lest_GLS_SVR.Yest_SVR(loc_Clean));
    %          title({['Pest by GLS+SVR   Val set that has been Cleaned by removing: ',num2str(row_always(locOL))];...
    %             ['RMSE by GLS+SVR clean =',roundns(RMSE_clean_GLS_SVR,2),'      STD =',roundns(STD_clean_GLS_SVR,2),'      Bias =',roundns(Bias_clean_GLS_SVR,2)    ] })
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    warning off
    
    if ~isempty(inp4PLS.pathfnameTP4Val)
        inp4V_scan=inp4V;
        inp4V_scan.PlsfactorScan=inp4PLS.PlsfactorScan;
        saPLS_Results_Val_scan=PLS_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V_scan);
        RMSE_V_scan=cat(1,saPLS_Results_Val_scan.RMSE);
        %         if ~strcmp(inp4PLS.pathfnameTP4Val,pathfnameTP) % block this checking after fixing for dealing wo XRS case
        %
        figure;hold on;
        plot(saPLS_Results_Val.PLSfactor,saPLS_Results_Val.RMSE,'yO','markersize',12,'markerfacecolor','y');
        
        plot(inp4V_scan.PlsfactorScan,RMSE_V_scan,'b-*','linewidth',2);
        xlabel('PLS factor');
        ylabel('RMSEP');
        warning off
        stit_ModOpt=strrep([inp4PLS.cDataFlow{1},'  ',inp4PLS.pp1,'  ',inp4PLS.CabXfer_scheme{1},'  ',inp4PLS.CurUDMas],'_','\_');
%         warning on
        warning off
        if strcmp(sAQP_class,'pro')
            pathfnameTP4Val_alt=strrep(pathfnameTP4Val,'_{MDC','_MDC');  % fixed this Aug 25, 2020
            
            title({[Cur_Analyte,'    ',stit_PP];[  strrep(fileparts_name_ext(pathfnameTP4Val_alt),'_','\_')  ];[stit_ModOpt];['Val set ',strrep(inp4PLS.CurTcvModelParaOpmScheme,'_','\_'),'-->','OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),sAltOpmPLS,'  RMSE=',roundns(saPLS_Results_Val.RMSE,3)]})
           
        elseif  strcmp(sAQP_class,'lite')
            % Trim_Down_Results_fig for AQPlite RMSEP vs PLS factor plot
            title(['OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),sAltOpmPLS,'  RMSEP=',roundns(saPLS_Results_Val.RMSE,3)])
            % close this RMSEP vs PLS factor plot for AQPlite
            % close(gcf)
            
        end
%          warning on
        
        
        %         end % % block this checking after fixing for dealing wo XRS case
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % following seems not needed, results from SVR, and were blocked by CH, Apr 4, 2020
        %
%         fname_outPest4V=strrep(fileparts_name_ext(pathfnameTP4Val),'Atrainpk',['Val_Pest_PLSfactor',num2str(PLSfactor_Opm),'_Atrainpk']);
%         fname_outPest4V=strrep_keyword_between_markers(fname_outPest4V,'nsampP','.mat',[num2str(length(Y_iAna_V))]);
%         save(fname_outPest4V,'-struct','saSVR_Results_Val');
%         disp([fname_outPest4V,' has been saved']);
        
        
    end
%     warning on
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
catch
    warndlg('missing Val set or something wrong with work on Val set wConc by PLS')
    
end
%================================================================= 
try
    %inp4PLS.outPLS_Tcv_prev.PLSfactor_Opm;
    out.outPLS_Tcv=outPLS_Tcv;
catch
    
    out.outPLS_Tcv='';
end
if ~isempty(inp4PLS.pathfnameTP4Val)
    out.PLSfactor_Opm=PLSfactor_Opm;
    try
        out.RMSE_PLS_Opm=RMSE_PLS_Opm;
    end
else  % deal with woVal case by insert Tcv results into saPLS_Results_Val
    out.PLSfactor_Opm=     saPLS_Results_Val.PLSfactor;     % deal with woVal case by insert Tcv results into saPLS_Results_Val
    out.RMSE_PLS_Opm=  saPLS_Results_Val.RMSE;          % deal with woVal case by insert Tcv results into saPLS_Results_Val
end

out.PLSfactor_PLS_min=PLSfactor_PLS_min;
out.RMSE_PLS_min=RMSE_PLS_min;

out.ModelPara_Opm_Scheme=inp4PLS.ModelPara_Opm_Scheme;
 warning off
sSM_P=strrep(find_keyword_between_markers( fileparts_name_ext(pathfnameTP),'_P-S1-','_'),'00','');
out.sSM_P=sSM_P;
try
   out.saPLS_Results_Val=saPLS_Results_Val; 
    
end
% warning on

  return  
end


%% ----- PLS_inside_PLS_predict_ONLY_MLtool__saConc2XY   [AQP_gui.m lines 11872-11877] -------------
function [X_iAna Y_iAna  cSampleName]=PLS_inside_PLS_predict_ONLY_MLtool__saConc2XY(saConc,AnaName)
idx_CurAna= arrayfun(@(x) strcmp(x.clsname,AnaName),saConc);
X_iAna=cell2mat(arrayfun(@(x) x.Atrainpk, saConc(idx_CurAna),'un',0));
Y_iAna=cell2mat(arrayfun(@(x) repmat(x.Conc,[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
cSampleName=cell_unwrap(arrayfun(@(x) repmat({x.SampleName},[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
end


%% ----- PLS_inside_PLS_predict_ONLY_MLtool__isKSpick   [AQP_gui.m lines 11879-11888] --------------
function out=PLS_inside_PLS_predict_ONLY_MLtool__isKSpick(x,Conc_KSpick)
if length(find(Conc_KSpick==x.Conc))==0
out=false;
elseif length(find(Conc_KSpick==x.Conc))==1
    
    out=true;
else
    error('more than one match found ')
end
end


%% ----- PLS_on_Xfer_PP_or_PP_Xfer   [AQP_gui.m lines 11900-12183] ---------------------------------
function OUT_Regressor=PLS_on_Xfer_PP_or_PP_Xfer(path_X_P_XRS,path_X_P,inp4PLS_2DF)
% typically called by --> AutoQuant_DA_pipeline
% this function will call SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool
%--------------------------------------------------------------------------------------------------------
% fix some kind of bug that cause no TP dataset will be found even though Val set does exist, Jan 3, 2023
% originally inside AutoQuant_DA_pipeline, now is an independent function
% this function will call SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool
%======================================
% add following Nov 7, 2020
% % this is the case that there in Only CS exist
% however when Only CS exist and there is no Val, there should be
% two files inside this folder but only one of them have '{CS-ONLY}'
%------------------------------------------------------------------------------------------
% fix some kind of bug that cause no TP dataset will be found even though Val set does exist, Jan 3, 2023
% use char not cell here for  inp4PLS.pathfnameTP4Val  !!! Jan 4, 2023
%------------------------------------------------------------------------------------------
% this is the case that there is Only CS exist and use "cell" not "char" in this situation, Jan 4, 2023 !!!
% tested by --> C:\work\JDSU\Test_AQP_PowerUser\Siesler48_S1_T375_only-CS
%------------------------------------------------------------------------------------------
% deal with only CS+XRS exist but woVal, Jan 4, 2023
%------------------------------------------------------
%------------------------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pathTP=path_X_P_XRS;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Lip=load('C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\inp4PLS.mat');
%     inp4PLS=Lip.inp4PLS;
try
    L4Ana=load(get_OnlyOne_AT(path_X_P_XRS));
    inp4PLS.cList_Ana_to_Run_PLS={L4Ana.PLS.Tset.saConc(1).clsname};
catch
    try
        L4Ana=load(get_OnlyOne_AT(path_X_P));                 % when both CS and Val exist, there should be only one file inside this folder
    catch
        % however when Only CS exist and there is no Val, there should be
        % two files inside this folder but only one of them have '{CS-ONLY}'
        [clistfilename_out_CSonly, nfile_out_CS_only]=    fdir_wildcard_ext_wPath(path_X_P ,'{CS-ONLY}','mat');
        if  nfile_out_CS_only==1
            L4Ana=load(clistfilename_out_CSonly{1});
        end
        %-----------------------------------------------------------------------------------------------------------
        % deal with only CS+XRS exist but woVal, Jan 4, 2023
        if nfile_out_CS_only==0
            [clistfilename_out_CS_XRS_only, nfile_out_CS_XRS_only]=    fdir_wildcard_ext_wPath(path_X_P ,'wAT2RS_For_PRO','mat');% deal with only CS+XRS exist but woVal, Jan 4, 2023
            if nfile_out_CS_XRS_only==1
            L4Ana=load(clistfilename_out_CS_XRS_only{1});
            end
        end
        %-----------------------------------------------------------------------------------------------------------
    end
    inp4PLS.cList_Ana_to_Run_PLS={L4Ana.PLS.Tset.saConc(1).clsname};

end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [clistfile_X_P_Val nfile_X_P_Val]=fdir_wildcard_ext_wPath([path_X_P],'Atrainpketc_','mat');
    if length(clistfile_X_P_Val)==1
        inp4PLS.pathfnameTP4Val=clistfile_X_P_Val{1};                                                                                                               % use char not cell here for  inp4PLS.pathfnameTP4Val  !!! Jan 4, 2023
    elseif nfile_X_P_Val>=2                                                                                                                                                          % fix this to deal with CS-ONLY case, Jan 4, 2023
        %--------------------------------------------------------------------------------------------------------------------------------------------------------
        % this is the case that there is Only CS exist and use "cell" not "char" in this situation, Jan 4, 2023 !!!
        % tested by --> C:\work\JDSU\Test_AQP_PowerUser\Siesler48_S1_T375_only-CS
        %
        %
        inp4PLS.pathfnameTP4Val= clistfile_X_P_Val(  strfind_cstr('{CS-ONLY}', clistfile_X_P_Val));                                            % this is the case that there is Only CS exist and use "cell" not "char" in this situation, Jan 4, 2023 !!!
        %----------------------------------------------------------------------------------------------------------------------------------------------------------
        % fix some kind of bug that cause no TP dataset will be found even though Val set does exist, Jan 3, 2023
        % if isempty(inp4PLS.pathfnameTP4Val) && ~isempty(strfind(  clistfile_X_P_Val{1} ,'for-AAQP'   ))                                          % fix some kind of bug that cause no TP dataset will be found even though Val set does exist, Jan 3, 2023
        if isempty(inp4PLS.pathfnameTP4Val) && ~isempty(clistfile_X_P_Val(  strfind_cstr('for-AAQP', clistfile_X_P_Val)))
            inp4PLS.pathfnameTP4Val=clistfile_X_P_Val{ strfind_cstr('for-AAQP', clistfile_X_P_Val)};                                                     % use char not cell here for  inp4PLS.pathfnameTP4Val  !!! Jan 4, 2023
        end
        %-----------------------------------------------------------------------------------------------------------------------------------------------------------
    else
        error('something wrong with clistfile_X_P_Val')
    end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
     if iscell(inp4PLS_2DF.CurUDMas)&& length(inp4PLS_2DF.CurUDMas)==1
     inp4PLS_2DF.CurUDMas=inp4PLS_2DF.CurUDMas{1};
     elseif ischar(inp4PLS_2DF.CurUDMas)
         disp('continue')
     else
         error('not ready to handle the datatype of inp4PLS_2DF.CurUDMas')
     end
     
     switch inp4PLS_2DF.CurUDMas
         
         case 'woUDM' 
             
             if strcmp( inp4PLS_2DF.CurTcvModelParaOpmScheme,'User-Pick')
                 inp4PLS_2DF.ModelPara_Opm_Scheme=inp4PLS_2DF.CurTcvModelParaOpmScheme;  % updated by CH, Nov 22, 2019
             else
                 inp4PLS_2DF.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv'; % 'woUDM' can only run with Tcv
             end
         %%% updating XRS  
         if ~isempty(inp4PLS_2DF.sd_CS_Val_orig)
             sd_XRS_folder_Cur=ssds(get_OnlyOne_AT(pathTP));
             
             sd_CS_XRS4woUDM=inp4PLS_2DF.sd_CS_Val_orig>P2T(sd_XRS_folder_Cur);
             
             
             path_prev=pwd;
             delete(get_OnlyOne_AT(pathTP));
             cd(pathTP);
             sd_CS_XRS4woUDM.saveAT;
             cd(path_prev);
             %%% updating Val
             sd_CS_Val4woUDM=inp4PLS_2DF.sd_CS_Val_orig>P2T(ssds(inp4PLS.pathfnameTP4Val));
             delete(inp4PLS.pathfnameTP4Val);
             cd(fileparts(inp4PLS.pathfnameTP4Val));
             sd_CS_Val4woUDM.saveAT;
             inp4PLS.pathfnameTP4Val=get_OnlyOne_AT(pwd);% do not forget to update filename for inp4PLS.pathfnameTP4Val
             cd(path_prev);
         else % deal with Ludm is empty
             disp('continue wo doing anything for now')
             
         end
         
         case 'UDM-ONLY'
             
%              get_OnlyOne_AT(pathTP)
%              inp4PLS.pathfnameTP4Val
          % 'UDM-ONLY' can only run with Tcv
          inp4PLS_2DF.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv'; % 'UDM-ONLY' can only run with Tcv
%              CurTcvModelParaOpmScheme
             
         case 'OpmPLS-ONLY'
             
             % prepare for  pathTP
             sd_UDM4XRS=ssds(get_OnlyOne_AT(inp4PLS_2DF.path_DFd_UDM));
             sd_CS_XRS4OpmPLS_ONLY=inp4PLS_2DF.sd_CS_Val_orig>sd_UDM4XRS;
              delete(get_OnlyOne_AT(pathTP)); % clean out the orig file there which will be wrong for Scv
             path_prev=pwd;
             cd(pathTP);
             sd_CS_XRS4OpmPLS_ONLY.saveAT;
             cd(path_prev);
             % prepare for inp4PLS.pathfnameTP4Val
             sd_CS_Val_Cur=ssds(inp4PLS.pathfnameTP4Val);
             sd_Val_alone=P2T(sd_CS_Val_Cur);
             sd_CS_Val4OpmPLS_ONLY=inp4PLS_2DF.sd_CS_Val_orig>sd_Val_alone;
             cd(fileparts(inp4PLS.pathfnameTP4Val));
             delete(inp4PLS.pathfnameTP4Val);
             sd_CS_Val4OpmPLS_ONLY.saveAT;
             inp4PLS.pathfnameTP4Val=get_OnlyOne_AT(pwd);% do not forget to update filename for inp4PLS.pathfnameTP4Val
             cd(path_prev);
         case  'Split_OddUDM_EvenXRS'  
             disp('work on Split_UDM')
             sd_UDM4XRS=ssds(get_OnlyOne_AT(inp4PLS_2DF.path_DFd_UDM));
             
             out_Sp=Atrainpk_Split_Odd_Even(sd_UDM4XRS.LAT);
%              out_Sp.SAT_odd
%              out_Sp.SAT_even
             %%%%%%
             LAT_CS_Val_orig= inp4PLS_2DF.sd_CS_Val_orig.LAT;
             %%%%%%
             sd_CS_Split=inp4PLS_2DF.sd_CS_Val_orig+ssds(out_Sp.SAT_odd);
             %%%%%
             sd_CS_XRS4Split=sd_CS_Split>ssds(out_Sp.SAT_even);
             path_prev=pwd;
             cd(pathTP);
             
             delete(get_OnlyOne_AT(pathTP)); % clean out the orig file there
             sd_CS_XRS4Split.saveAT;
             cd(path_prev);
             %%%%%
             sd_CS_Val4Split=sd_CS_Split>P2T(ssds(inp4PLS.pathfnameTP4Val));
             
             cd(fileparts(inp4PLS.pathfnameTP4Val));
             delete(inp4PLS.pathfnameTP4Val);
             sd_CS_Val4Split.saveAT;
             
             % do not forget to update filename for inp4PLS.pathfnameTP4Val
             inp4PLS.pathfnameTP4Val=get_OnlyOne_AT(pwd);% do not forget to update filename for inp4PLS.pathfnameTP4Val
             % do not forget to update filename for inp4PLS.pathfnameTP4Val
             cd(path_prev);

             
         case 'Scv'
             % prepare for PLS_Scv
             %      if isSAME_2Matrix( L_UDM4XRS_Scv.Apred,X_iAna_Scout_CS)
             LAT_CS_Val_orig= inp4PLS_2DF.sd_CS_Val_orig.LAT;
             
             OrigCS.X=          LAT_CS_Val_orig.Atrainpk;
             OrigCS.Y=          cat(1,LAT_CS_Val_orig.PLS.Tset.saConc.Conc);
             OrigCS.cSampleName=LAT_CS_Val_orig.AclabelT;
             
             sd_UDM4XRS=ssds(get_OnlyOne_AT(inp4PLS_2DF.path_DFd_UDM));
             
             ScoutCS.X=          sd_UDM4XRS.LAT.Atrainpk;
             ScoutCS.Y=          cat(1,sd_UDM4XRS.LAT.saConc.Conc);
             ScoutCS.cSampleName=sd_UDM4XRS.LAT.AclabelT;
             %%%%%%%%%%%%%%%%%%%%
             % run Scv to generate all_RMSE_PLS_Scv
             inp4Scv.PlsfactorScan=inp4PLS_2DF.PlsfactorScan;
             inp4Scv.Tcv_scheme=inp4PLS_2DF.CrossValidationType;
             
             [all_RMSE_PLS_Scv]=Scv4all_RMSE_PLS_Scv(OrigCS,ScoutCS,inp4Scv);% run Scv to generate all_RMSE_PLS_Scv
             inp4PLS.all_RMSE_PLS_Scv=all_RMSE_PLS_Scv;% input all_RMSE_PLS_Scv into SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool
             
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             sd_CS_XRS4Scv=inp4PLS_2DF.sd_CS_Val_orig>sd_UDM4XRS;
             delete(get_OnlyOne_AT(pathTP)); % clean out the orig file there which will be wrong for Scv
             path_prev=pwd;
             cd(pathTP);
             sd_CS_XRS4Scv.saveAT;
             cd(path_prev);
             
         case {'OpmPLS_AND_Add2CS','Both_UDM_Opm'}   
%              disp('work on Both_UDM_Opm')
             
             
             sd_UDM4XRS=ssds(get_OnlyOne_AT(inp4PLS_2DF.path_DFd_UDM));
             sd_CS_XRS4Both=ssds(get_OnlyOne_AT(pathTP))>sd_UDM4XRS;
             path_prev=pwd;
             cd(pathTP);
             
             delete(get_OnlyOne_AT(pathTP)); % clean out the orig file there
             sd_CS_XRS4Both.saveAT;
             cd(path_prev);
             
         case 'UDMasCS'
             
             inp4PLS_2DF.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv'; % 'UDMasCS' can only run with Tcv
             
             sd_UDM4CS=ssds(get_OnlyOne_AT(inp4PLS_2DF.path_DFd_UDM));
             sd_CS_Val_Cur=ssds(inp4PLS.pathfnameTP4Val);
             sd_Val_alone=P2T(sd_CS_Val_Cur);
             
             sd_CS_UDM_Val=sd_UDM4CS>sd_Val_alone;
             
             path_prev=pwd;
             cd(fileparts(inp4PLS.pathfnameTP4Val));
             delete(inp4PLS.pathfnameTP4Val);
             sd_CS_UDM_Val.saveAT;
             inp4PLS.pathfnameTP4Val=get_OnlyOne_AT(pwd);% do not forget to update filename for inp4PLS.pathfnameTP4Val
             cd(path_prev);
             % updating XRS folder
             sd_XRS_folder_Cur=ssds(get_OnlyOne_AT(pathTP));
             sd_XRS_alone=P2T(sd_XRS_folder_Cur);
             sd_CS_XRS4UDMasCS=sd_UDM4CS>sd_XRS_alone;
             delete(get_OnlyOne_AT(pathTP));
             cd(pathTP);
             sd_CS_XRS4UDMasCS.saveAT;
             cd(path_prev);
             
             
         otherwise
             error('CurUDMas not supported')
     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inp4PLS=catstruct(inp4PLS,inp4PLS_2DF);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % settings for running PLS for historical reason !!!
    inp4PLS.run_PLS_yes=1;inp4PLS.run_SVR_yes=0;
    inp4PLS.TP_scheme='Tall_Pall';
    inp4PLS.list_C=[1.0000e-06 1.0000e-05 1.0000e-04 1.0000e-03 0.0100 0.1000 1 10 100];
    inp4PLS.RMSE_thres4OLs=Inf;  % this must be set because historical reason !!!
    inp4PLS.run_OL_analysis_Val_yes=1;% this must be set because historical reason !!!
    inp4PLS.handles='';
    inp4PLS.PP_methods=''; % PP_methods not used inside SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool()

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(pathTP)
        pathTP=inp4PLS.pathfnameTP4Val;  % to deal with case that there was no XRS set
    end
    inp4PLS.handles_gui=inp4PLS_2DF.handles_gui;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~inp4PLS.handles_gui.Val_Exist.Value
    inp4PLS.pathfnameTP4Val='';  % modified by CH to deal with missing Val set, Jan 28, 2020
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
if isempty(pathTP) && isempty(inp4PLS.pathfnameTP4Val)
pathTP=clistfile_X_P_Val(  strfind_cstr('wAT2RS_For_PRO', clistfile_X_P_Val))  ;   % deal with only CS+XRS exist but woVal, Jan 4, 2023
end

%=====================================================================
  inp4PLS.cnt= inp4PLS_2DF.cnt;          % add this for locating Beta_etc_FinalModel_~.mat files inside PLS_inside_PLS_predict_ONLY_MLtool

%================================================================================
     OUT_Regressor=SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool(pathTP,inp4PLS);
end


%% ----- PLS_predict_ONLY   [AQP_gui.m lines 12188-12742] ------------------------------------------
function [Yest_bo_Tcv RMSE_bo_Tcv CV_bo_Tcv out]=PLS_predict_ONLY(pathfname_ATwsaConc_T,pathfname_ATwsaConc_P,PlsfactorScan,inp)
if false
    
    clear;close all
    %%%%%%%%%%%%%%%%%%%%%%
%     pathfname_ATwsaConc_P='C:\work\JDSU\Quant_2200ES\ATetc\w_saConc\Atrainpketc_saConc_Pertula_Samples+NC-PFN_Tset_ONLY_(S1-375)_pp1-1stDerSGDiederick_pp2-SampMncn_nsamp75_ncls15.mat'
%     pathfname_ATwsaConc_T='C:\work\JDSU\Quant_2200ES\ATetc\w_saConc\Atrainpketc_saConc_Pertula_Samples+NC-PFN_Tset_ONLY_(S1-376)_pp1-1stDerSGDiederick_pp2-SampMncn_nsamp75_ncls15.mat';
   % pathfname_ATwsaConc_P='C:\work\JDSU\Quant_2200ES\ATetc\w_saConc\Atrainpketc_saConc_Pertula_Samples+NC-PFN_Tset_ONLY_(S1-419)_pp1-1stDerSGDiederick_pp2-SampMncn_nsamp75_ncls15.mat'
    %%%%%%%%%%%%%%%%%%%%%%%%%
   pathfname_ATwsaConc_T= 'C:\work\JDSU\Quant_2200ES\cross-SM_1700\Atrainpketc_saConc_Pertula_Samples+NC-PFN_Tset_ONLY_T-SM(S1-375)_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT75_ncls15_P-SM(S1-376)_pp1-1stDerSGDiederick_nsampP75.mat'
    pathfname_ATwsaConc_P= ''
   %%%%%%%%%%%%%%%%%%%%%%%%%
    PlsfactorScan=[2:20 25 30 40 50];
    inp.cList_Ana_to_Run_PLS={'Microcrystalline_Cellulose'}

    [Yest RMSE CV ]=PLS_predict_ONLY(pathfname_ATwsaConc_T,pathfname_ATwsaConc_P,PlsfactorScan,inp);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     clear;close all
   
     pathfname_ATwsaConc_T= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\SGw5\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-SGw5_pp2-SampMncn_nsampT183_nsampP15.mat'
   %pathfname_ATwsaConc_T= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\1stDer\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT183_nsampP15.mat'
pathfname_ATwsaConc_P= ''
    inp.run_SVR_yes=0;
        PlsfactorScan=[1:10 12:2:30 ];
    inp.cList_Ana_to_Run_PLS={'Pigment'}
    
inp.Tcv_scheme='Leave-OneConc-Out';
    [Yest_bo_Tcv RMSE_bo_Tcv CV_bo_Tcv out]=PLS_predict_ONLY(pathfname_ATwsaConc_T,pathfname_ATwsaConc_P,PlsfactorScan,inp);

    
    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
run_EVRI_pls_yes=0;


% collect RMSE at PLSfactor==1
run_PLSfactor1_yes=1;
% set to run SVR or not
run_SVR_yes=inp.run_SVR_yes;
% run_SVR_yes=0;
    listMarker4cList_Tcv_scheme='O*+>';
    listColor4cList_Tcv_scheme='kmcg';


if isempty(pathfname_ATwsaConc_P)
      [LT LP ]=Atrainpk_TP2TvsP(pathfname_ATwsaConc_T);
      pathfname_ATwsaConc_TP=pathfname_ATwsaConc_T;
pathfname_ATwsaConc_T=['Atrainpketc_(',find_keyword_between_markers(fileparts_name_wo_ext(pathfname_ATwsaConc_TP),'T-SM(',')'),').mat'];
pathfname_ATwsaConc_P=['Atrainpketc_(',find_keyword_between_markers(fileparts_name_wo_ext(pathfname_ATwsaConc_TP),'P-SM(',')'),').mat'];
      
%     LTP=load(pathfname_ATwsaConc_T);
%     %%%%%%%%%%%%%%%%%%%
%     LP.Atrainpk=LTP.Apred;
%     LP.AclassinfoT=LTP.AclassinfoP;
%     LP.clistclslabel=LTP.clistclslabel;
%     try LP.AclabelT=LTP.AclabelP;end
%     try LP.saConc=LTP.PLS.Pset.saConc;  end
%     try LP.RawSpectra=LTP.RawSpectra.Pset;end
%     %%%%%%%%%%%%%%%%%%%%%%%%
%     LT=LTP;
%     LT=rmfield(LT,{'Apred','AclassinfoP'});
%     try    LT=rmfield(LT,{'AclabelP'});end
%     try LT.saConc=LTP.PLS.Tset.saConc;  end
%     try LT.RawSpectra=LTP.RawSpectra.Tset;end
%     try    LT=rmfield(LT,{'PLS'});end

else
    LT=load(pathfname_ATwsaConc_T);
    LP=load(pathfname_ATwsaConc_P);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clistAna=arrayfun(@(x) x.clsname,LT.saConc,'un',0);
[Qana Nana]=unique_count(clistAna);

% cList_Ana_to_Run_PLS =row_always(Qana);
cList_Ana_to_Run_PLS=inp.cList_Ana_to_Run_PLS;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% all_size_Y_iAna_P=[];
for iAna=1:length(cList_Ana_to_Run_PLS)
    CurAnaName=cList_Ana_to_Run_PLS{iAna};
    [X_iAna_T Y_iAna_T  cSampleName_T]=PLS_predict_ONLY__saConc2XY(LT.saConc,CurAnaName);
    [X_iAna_P Y_iAna_P  cSampleName_P]=PLS_predict_ONLY__saConc2XY(LP.saConc,CurAnaName);
    
%     all_size_Y_iAna_P=[all_size_Y_iAna_P;length(Y_iAna_P)];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tcv to find OpmPLSfactor_Tcv
    
   % inpTcv.Tcv_scheme='Leave-OneSample-Out';    %  'Leave-OneReplicate-Out'  'Leave-OneSample-Out'
        inpTcv.Tcv_scheme=inp.Tcv_scheme;    %  'Leave-OneReplicate-Out'  'Leave-OneSample-Out'

        if strcmp(inpTcv.Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
            inpTcv.PLSfactor=[];inpTcv.KPplus=1;inpTcv.stitle=CurAnaName;
            inpTcv.PlsfactorScan=PlsfactorScan;
            inpTcv.inp=inp;
            out_Tcv=PLS_Tcv(X_iAna_T, Y_iAna_T,cSampleName_T,inpTcv);
            OpmPLSfactor_Tcv=out_Tcv.OpmPLSfactor_RVIL;
        else
            
%             save ('Mat4testing_SVR_Tcv.mat', 'X_iAna_T', 'Y_iAna_T','cSampleName_T')
            inpTcv.KPplus=1;
            inpTcv.stitle=CurAnaName;
            %     inpTcv.nPLSfactor_scan=PlsfactorScan;
            OUT_Tcv=[];
            for irun=1:length(PlsfactorScan)
                
                inpTcv.PLSfactor=PlsfactorScan(irun);
                %inpTcv.PlsfactorScan=PlsfactorScan;
                % out=prep_Spertula_Quant( pathfname_Conc_Tab,pathfname_UXmat,inp);
                out_Tcv=PLS_Tcv(X_iAna_T, Y_iAna_T,cSampleName_T,inpTcv);
                OUT_Tcv=[OUT_Tcv;out_Tcv];
                
            end
            hf_PLS_1=figure(101);hold on;
            all_CV_Tcv=arrayfun(@(x) x.CV,OUT_Tcv);
            all_RMSE_Tcv=arrayfun(@(x) x.RMSE,OUT_Tcv);
           % plot(PlsfactorScan,all_CV_Tcv,'r-*','linewidth',2)
             plot(PlsfactorScan,all_RMSE_Tcv,'r-*','linewidth',2)
            ylabel('RMSE based on Tcv')
            xlabel('PLS factor')
            [minCV_Tcv loc_minCV_Tcv]=min(all_CV_Tcv);
            OpmPLSfactor_Tcv=PlsfactorScan(loc_minCV_Tcv);
            plot(OpmPLSfactor_Tcv,minCV_Tcv,'cO','markersize',10)
            [hpvl_Tcv htvl_Tcv ]=plot_vline(OpmPLSfactor_Tcv,'b');
            
            try
                spp=inp.pp;
            catch
                spp='';
            end
            
            try
             sSM_T=   inp.sSM_T;
            catch
               sSM_T= ''; 
            end
            
            
            title([{[CurAnaName,'  ',remove_underscore(spp)]};...
                %  {['Tcv:',find_keyword_between_markers(fileparts_name_wo_ext(pathfname_ATwsaConc_T),'(',')') ]};...
                {['Tcv: ',sSM_T,'  ',inpTcv.Tcv_scheme]};...
                {['OpmPLSfactor Tcv=',num2str(OpmPLSfactor_Tcv),'  min CV Tcv=',roundns(minCV_Tcv,2),'%'  ]};...
                ])
            
        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use XS (transfer set) to find Opm PLS factor
    switch inp.ModelPara_Opm_Scheme
         case 'ModelParaOpmBy-XS_KS4'   
             disp('starting to use XS (transfer set) to find Opm PLS factor')
        
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    call_Y_iAna_est=[];
    call_Y_iAna_P=[];
    all_RMSE=[];
    
    all_BIAS_meandif=[];
    all_STD_std=[];

    all_CV=[];
    all_Yest=[];
%     PlsfactorScan_Validation=unique([1,PlsfactorScan]);
for PLSfactor_i=row_always(PlsfactorScan)  % % scan of PLSfactor_i for Pset
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % old approach that use "CV" and repeat PLSfactor
    %         [xl,yl,xs,ys,beta,pctvar,mse]...
    %             = plsregress(X_iAna_T,Y_iAna_T,PLSfactor_i,'CV',PLSfactor_i);
    % new approach that do NOT use "CV" and only single entry of PLSfactor
    %
    [xl,yl,xs,ys,beta,pctvar,mse]...
        = plsregress(X_iAna_T,Y_iAna_T,PLSfactor_i);
    Y_iAna_est = [ones(size(X_iAna_P,1),1) X_iAna_P]*beta;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if run_EVRI_pls_yes
    % run with EVRI's pls()
    options.display='off';
    options.plots='none';
    [X_iAna_T_mncn mean_T]=mncn(X_iAna_T);
    X_iAna_P_mncn=scale(X_iAna_P,mean_T);
    [Y_iAna_T_mncn mean_Y_T]=mncn(Y_iAna_T);
    model_PLS_EVRI_mncn = pls(X_iAna_T_mncn,Y_iAna_T_mncn,PLSfactor_i,options);  %identifies model (calibration step)
    pred_PLS_EVRI_mncn  = pls(X_iAna_P_mncn, model_PLS_EVRI_mncn,options);    %makes predictions with a new X-block
    Y_iAna_est_PLS_EVRI_mncn=pred_PLS_EVRI_mncn.pred{2};
    
    Y_iAna_est_PLS_EVRI=scale(Y_iAna_est_PLS_EVRI_mncn,-mean_Y_T);
    % ssqresiduals: cell array with sum of squares residuals for each mode,
    loc_pick2show= find_belong2subgrp(  [1 3 5 30 OpmPLSfactor_Tcv],PLSfactor_i) ;
    if ~isempty( loc_pick2show )
        scolor='krbcg';
        figure(2000);hold on;
        %plot(Y_iAna_est,'b-O');
        plot(pred_PLS_EVRI_mncn.ssqresiduals{1},'color',scolor(loc_pick2show));
        % legend({'plsgress','pls'})
        title(['Q-Residuals   ','PLSfactor=',num2str(PLSfactor_i)]);
    end
    try
        close(1000);
    end
    figure(1000);hold on;
    plot(Y_iAna_est,'b-O');
    plot(Y_iAna_est_PLS_EVRI,'k-*');
    legend({'plsgress','pls'})
    title(['PLSfactor=',num2str(PLSfactor_i)])
    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % RMSE= RMS_error_woNaN(Y_iAna_est,Y_iAna_P); % based on N-1
    RMSE= RMS_error_woNaN_N(Y_iAna_est,Y_iAna_P); % based on N (not N-1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % STD_std=std(Y_iAna_est-Y_iAna_P); % based on N-1
    STD_std=sqrt(std(Y_iAna_est-Y_iAna_P)^2*(length(X_iAna_P)-1)/length(X_iAna_P)); % based on N (not N-1)
    
    BIAS_meandif=mean(Y_iAna_est-Y_iAna_P);
    % checking
    RMSE_cald=sqrt(STD_std^2+BIAS_meandif^2);
    if abs(RMSE-RMSE_cald)/mean([RMSE RMSE_cald])>5E-2
        error('something wrong with calculation of STD_std or BIAS_meandif');
    else
        all_BIAS_meandif=[all_BIAS_meandif;BIAS_meandif];
        all_STD_std=[all_STD_std;STD_std];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % handling Parse_One_Physical_Conc case
    %         if length(Y_iAna_P)==1
    call_Y_iAna_est=[call_Y_iAna_est,{Y_iAna_est}];
    call_Y_iAna_P=[call_Y_iAna_P,{Y_iAna_P}];
    
    %         end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    all_RMSE=[all_RMSE;RMSE];
    CV= 100*RMS_error_woNaN(Y_iAna_est,Y_iAna_P)/mean(Y_iAna_T);
    all_CV=[all_CV;CV];
    Yest=Y_iAna_est;
    all_Yest=[all_Yest,Yest];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  % end of scan of PLSfactor_i for Pset
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if run_PLSfactor1_yes==1
    % test PLSfactor==1
    [xl_PLS1,yl_PLS1,xs_PLS1,ys_PLS1,beta_PLS1,pctvar_PLS1,mse_PLS1]...
            = plsregress(X_iAna_T,Y_iAna_T,1);
     Y_iAna_est_PLS1 = [ones(size(X_iAna_P,1),1) X_iAna_P]*beta_PLS1;
     if length(Y_iAna_P)==1
         RMSE_PLS1=abs(Y_iAna_est_PLS1-Y_iAna_P);
     else
        RMSE_PLS1= RMS_error_woNaN(Y_iAna_est_PLS1,Y_iAna_P);
     end
    else
      RMSE_PLS1=NaN;  
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if false
    % testing plsregress with or without "CV"
    PLSfactor_i=10;
    [xl,yl,xs,ys,beta,pctvar,mse]...
            = plsregress(X_iAna_T,Y_iAna_T,PLSfactor_i,'CV',PLSfactor_i);
    
      [xl_woCV,yl_woCV,xs_woCV,ys_woCV,beta_woCV,pctvar_woCV,mse_woCV]...
            = plsregress(X_iAna_T,Y_iAna_T,PLSfactor_i);
        
      if  isSAME_2Matrix(beta,beta_woCV)
        disp('beta same as beta_woCV')
      else
          disp('beta different from beta_woCV')
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [min_RMSE loc_minRMSE]=min(all_RMSE);
    [min_CV loc_minCV]=min(all_CV);
    if loc_minRMSE==loc_minCV
        Opm_PLSfactor_minRMSE=PlsfactorScan(loc_minCV);
    else
        error('mismatch between loc_minRMSE vs loc_minCV ')
    end
    hf_PLS_2=figure(102);hold on;
    plot(PlsfactorScan,all_RMSE,'r-*','linewidth',2);
    %plot(PlsfactorScan,all_CV,'r-*','linewidth',2);
        legend({'RMSE'})

    if ~isnan(RMSE_PLS1)
         plot(1,RMSE_PLS1,'k*','markersize',10);
    end
    
    plot(Opm_PLSfactor_minRMSE,min_RMSE,'bO','markersize',8,'markerfacecolor','y');
    %plot(Opm_PLSfactor,min_CV,'bO','markersize',8,'markerfacecolor','y');
    
    [hpvl_0 htvl_0 ]=plot_vline(Opm_PLSfactor_minRMSE,'b');
    
    
    CV_basedon_Tcv=all_CV(PlsfactorScan==OpmPLSfactor_Tcv);
    RMSE_basedon_Tcv=all_RMSE(PlsfactorScan==OpmPLSfactor_Tcv);
    

        BIAS_basedon_Tcv=all_BIAS_meandif(PlsfactorScan==OpmPLSfactor_Tcv);
        STD_basedon_Tcv=all_STD_std(PlsfactorScan==OpmPLSfactor_Tcv);
       % checking 
       RMSEopmcald=sqrt(BIAS_basedon_Tcv^2+STD_basedon_Tcv^2);
       if abs(RMSEopmcald-RMSE_basedon_Tcv)/mean([RMSEopmcald RMSE_basedon_Tcv])>5E-2
            error('something wrong with calculation of STD_std or BIAS_meandif at Opm PLS factor');
       end
    
     % handling Parse_One_Physical_Conc case
        if length(call_Y_iAna_P)==length(all_RMSE)
            Y_iAna_est_basedon_Tcv=call_Y_iAna_est{PlsfactorScan==OpmPLSfactor_Tcv};
            Y_iAna_P_basedon_Tcv=call_Y_iAna_P{PlsfactorScan==OpmPLSfactor_Tcv};
        end
    
    
    
   % plot(OpmPLSfactor_Tcv,CV_basedon_Tcv,'yO','markersize',8,'markerfacecolor','b');
   
   try
     color_OpmPLS_scheme=  inp.color_OpmPLS_scheme;
   catch
       
    if ischar( inp.Tcv_scheme  )
        iTcv_scheme=1;
    else
        error('can not handle this yet')
    end
    color_OpmPLS_scheme=listColor4cList_Tcv_scheme(iTcv_scheme);
   end
    plot(OpmPLSfactor_Tcv,RMSE_basedon_Tcv,'yO','markersize',8,'markerfacecolor',color_OpmPLS_scheme);
    
    
    
    [hpvl htvl ]=plot_vline(OpmPLSfactor_Tcv,color_OpmPLS_scheme);
    
    
%             inp.sSM_T;
%          inp.sSM_P;

try
  sSM_P=inp.sSM_P;  
catch
    sSM_P='';
end

try
  sSM_TP=inp.sSM_TP;  
catch
    sSM_TP='';
end



   stitle= [{[CurAnaName,'  ',remove_underscore(spp),['  T: ',sSM_T ],['  P: ',sSM_P],'   ',inpTcv.Tcv_scheme]};...
        {['min PLSfactor=',num2str(Opm_PLSfactor_minRMSE),'  min RMSE=',roundns(min_RMSE,2) ]};...
        {['OpmPLSfactor Tcv=',num2str(OpmPLSfactor_Tcv),'  RMSE=',roundns(RMSE_basedon_Tcv,3),'  BIAS=',roundns(BIAS_basedon_Tcv,3),'  STD=',roundns(STD_basedon_Tcv,3)  ]};...
        {[remove_underscore(sSM_TP)]};...
        ] ;
    title(stitle); 
    set(gcf,'position',[534   342   835   583])
    xlabel('PLS factor')
    ylabel('extr Prediction RMSE or CV');
   % set(gcf,'position',[617   320   945   621]);
    set(gcf,'position',1000*[0.1810    0.0623    1.0187    0.5493]);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % plot 45deg plot
   Yest_OpmTcv= all_Yest(:,PlsfactorScan==OpmPLSfactor_Tcv);
   % checking
   %RMSE= RMS_error_woNaN(Yest_OpmTcv,Y_iAna_P);
   
   inp45.stitle=stitle;
   inp45.fignum=103;
    plot_Regress_45_degree_line(Y_iAna_P,Yest_OpmTcv,inp45);
        set(gcf,'position',[366.3333  109.6667  889.3333  506.6667]);
    hf_PLS_3=gcf;
    
    
    
    
end

Yest_bo_Tcv =[];% not provided yet
RMSE_bo_Tcv =RMSE_basedon_Tcv;
CV_bo_Tcv=CV_basedon_Tcv;



out.OpmPLSfactor_final=OpmPLSfactor_Tcv;

out.RMSE_bo_Tcv=RMSE_bo_Tcv;
out.BIAS_bo_Tcv=BIAS_basedon_Tcv;
out.STD_bo_Tcv=STD_basedon_Tcv;


try
out.Y_iAna_est_bo_Tcv=Y_iAna_est_basedon_Tcv;
out.Y_iAna_P_bo_Tcv=Y_iAna_P_basedon_Tcv;
end




out.CV_bo_Tcv=CV_bo_Tcv;
out.fname_T=pathfname_ATwsaConc_T;
out.fname_P=pathfname_ATwsaConc_P;
out.cList_Ana_to_Run_PLS=cList_Ana_to_Run_PLS;
try
out.PLSfactorScan_RMSE_Tcv=all_RMSE_Tcv;
catch
 out.PLSfactorScan_RMSE_Tcv=[];   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run SVR with linear kernel and autoscale
% For the SVR model, I used Linear Kernel, C value of 1, 
% Epsilon value of 0.1, Scale data to [-1,1] (recommended setting), 
% X-weights of 1.00/(SDev+0.00).

if run_SVR_yes
    ktype='SVRbyLS';   %  'SVRbyLS'  'linear'
    % ktype='rbf';
    
    switch  ktype
        case 'linear'
            sKtype=' -t 0 ';
            
        case  'rbf'
            sKtype=' -t 2 ';
            
        case 'SVRbyLS'
            
            sKtype=' -t 0 ';
            
            
    end
    
    para_norm=0;
    para_asmc=1;
    switch para_asmc
        case 1
            sasmc_SVR='_autoscale';
        case 2
            sasmc_SVR='_meancenter';
            
        otherwise
            error('para_asmc Not supported !!!')
    end
    
    [X_iAna_T_normasmc,X_iAna_P_normasmc,asmc_mean_std]=normasmc_trainpk_pred(X_iAna_T,X_iAna_P,para_norm,para_asmc);
    
    % X_iAna_T_normasmc=sparse(X_iAna_T_normasmc);
    % X_iAna_P_normasmc=sparse(X_iAna_P_normasmc);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % from libsvm website:
    % options:
    % -s svm_type : set type of SVM (default 0)
    % 	0 -- C-SVC
    % 	1 -- nu-SVC
    % 	2 -- one-class SVM
    % 	3 -- epsilon-SVR
    % 	4 -- nu-SVR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    list_C=[0.01 0.1 1 10 100];
    saSVR_Results=[];
    all_Yest_SVR=[];
    for iC=1:length(list_C)
        if strcmp(ktype,'SVRbyLS')
            % epsilon-SVR
            model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 3 ', sKtype,' -p ' num2str(0.1) ' -c ' num2str(list_C(iC))]);
            
        else
            % nu-SVR
            model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 4 ', sKtype,' -n ' num2str(1/2) ' -c ' num2str(1)]);
        end
        
        
        Yest_SVR=svmpredict_MEX(Y_iAna_P,X_iAna_P_normasmc,model_SVR);
        all_Yest_SVR=[all_Yest_SVR,Yest_SVR];
        
        
        
        RMSE_SVR= RMS_error_woNaN(Yest_SVR,Y_iAna_P);
        eaSVR_Results.C=list_C(iC);
        eaSVR_Results.RMSE=RMSE_SVR;
        eaSVR_Results.Yest_SVR=Yest_SVR;
        eaSVR_Results.Y_iAna_P=Y_iAna_P;
        
        saSVR_Results=[saSVR_Results;eaSVR_Results];
        
    end
    CV_SVR= 100*RMSE_SVR/mean(Y_iAna_T);
    
    % if false
    % for SVR
    hf_PLS_6=figure(106);hold on;  % for SVR
    all_C=arrayfun(@(x) x.C,saSVR_Results);
    all_RMSE_SVR=arrayfun(@(x) x.RMSE,saSVR_Results);
    [minRMSE_SVR loc_Opm_SVR]=min(all_RMSE_SVR);
    RMSE_SVR_Opm=minRMSE_SVR;
    C_SVR_Opm=all_C(loc_Opm_SVR);
    
    plot(log10(all_C),all_RMSE_SVR,'k-*')
    plot(log10(C_SVR_Opm),RMSE_SVR_Opm,'gO','markersize',10);
    xlabel('log10 C');
    ylabel('RMSE by SVR');
    inp_plot_hline.label='PLS';
    [hphl hthl ]=plot_hline(out.RMSE_bo_Tcv,'b',inp_plot_hline );
    title([stitle(1);{remove_underscore(sasmc_SVR)}]);
    % end
    out.CV_SVR=CV_SVR;
    try
        out.RMSE_SVR_Opm=RMSE_SVR_Opm;
        out.C_SVR_Opm=C_SVR_Opm;
        out.saSVR_Results=saSVR_Results;
        out.asmc_SVR=sasmc_SVR;
    end
    % try
    % out.Y_iAna_est_bo_Tcv=Y_iAna_est_basedon_Tcv;
    % out.Y_iAna_P_bo_Tcv=Y_iAna_P_basedon_Tcv;
    % end
    
    out.Yest_SVR=all_Yest_SVR(:,loc_Opm_SVR);  % based on C at Opm
    out.Y_iAna_P=Y_iAna_P;
    
    
    
else
    out.RMSE_SVR=NaN;
    out.CV_SVR=NaN;
    
    
end % end of SVR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
   out.hf_PLS=[hf_PLS_1;hf_PLS_2;hf_PLS_3]; 
end
try
   out.hf_SVR=[hf_PLS_6]; 
end

disp('finish PLS_predict_ONLY');

return
end


%% ----- PLS_predict_ONLY__saConc2XY   [AQP_gui.m lines 12775-12780] -------------------------------
function [X_iAna Y_iAna  cSampleName]=PLS_predict_ONLY__saConc2XY(saConc,AnaName)
idx_CurAna= arrayfun(@(x) strcmp(x.clsname,AnaName),saConc);
X_iAna=cell2mat(arrayfun(@(x) x.Atrainpk, saConc(idx_CurAna),'un',0));
Y_iAna=cell2mat(arrayfun(@(x) repmat(x.Conc,[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
cSampleName=cell_unwrap(arrayfun(@(x) repmat({x.SampleName},[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
end


%% ----- PLS_wTcv_StandAlone_AQPpu   [AQP_gui.m lines 12784-13287] ---------------------------------
function out=PLS_wTcv_StandAlone_AQPpu(pathfnameTP,inp4PLS)
% this function is mainly used for running AAQP, see --> examples_BatchRun_PLS_wTcv_StandAlone_AQPpu
% however in order to handle LSUX_RMSECV within AQPlite, this function will be called by "PLS_inside_PLS_predict_ONLY_MLtool.m" , Jan 5, 2023
% will call --> PLS_Tcv
%----------------------------------------------------------------------------------------------------
% modified from PLS_inside_PLS_predict_ONLY_MLtool()
% modified from SVR_inside_PLS_predict_ONLY()
% this was extracted from PLS_predict_ONLY() 
% PLS_wTcv_StandAlone_AQPpu() has typically been called by BatchRun_PLS_wTcv_StandAlone_AQPpu(path_ATfiles)
%========================================================
% major updates: add --> 'KneePt+1_RMSECV'
% see--> PLS_inside_PLS_predict_ONLY_MLtool.m
% ------------------------------------------------------------------------------------------------
% % deal with woVal case by insert Tcv results into saPLS_Results_Val, updated Oct 15, 2020
% see also: PLS_inside_PLS_predict_ONLY_MLtool
% % prepare for 45deg plot based on Tcv and store info inside --> saPLS_Results_Val
% --------------------------------------------------------------------------------------------------------
% % updated Oct 17, 2020 for providing Tcv_scheme of 'Leave-OneConc-Out'
% % use Tset as Pset so that it will run Tcv only, updated Nov 11, 2020
%-----------------------------------------------------------------------------------------------
% % add following output for Bias and StdErr, Mar 8, 2022
%-------------------------------------------------------------------------
% % add --> check_Atrainpk_inside_saConc_vs_root, Mar 15, 2022
%------------------------------------------------------------------------
% % add info AUC_thres for mU2U project, Mar 18, 2022
%  see this too --> Cmp_BatchRun_PLS_multiple_subfolders
%---------------------------------------------------------------------------------
% % revisit this 'LSUX_RMSECV'  Sept 13, 2022
%---------------------------------------------------------------------
% in order to handle LSUX_RMSECV within AQPlite, this function will be called by "PLS_inside_PLS_predict_ONLY_MLtool.m" , Jan 5, 2023
 % add following to calculate 'LSUX_RMSECV' from AQPlite pu , Jan 5, 2023
 %--------------------------------------------------------------------------------------------
 % this function may be used in upcoming AQPmp_gui ? , Jan 25, 2023
%=======================================================
% see also: BatchRun_PLS_wTcv_StandAlone_AQPpu
if false
    % examples for running this ...
    
 out=PLS_wTcv_StandAlone_AQPpu(pathfnameTP,inp4PLS)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   inp4PLS.pathfnameTP4Val=pathfnameTP;%hard-coded this for historical reason 
inp4PLS.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv';%hard-coded this for historical reason 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L=load(pathfnameTP);
%=====================================================
% check Atrainpk vs that inside saConc for TP pair only
out_check_AT_saConc=check_Atrainpk_inside_saConc_vs_root(L);    % add --> check_Atrainpk_inside_saConc_vs_root, Mar 15, 2022
if ~out_check_AT_saConc
    error('Mismatch between Atrainpk or Apred vs that inside saConc for Tset or Pset');
end
%===================================================
% collect list of ID for XS set
try
clistAclabelT_XS=arrayfun(@(x) x.AclabelT,L.saCTCP,'un',0);
catch
clistAclabelT_XS='';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inp4PLS.TP_scheme='Tall_Pall'

        X_iAna_T=L.Atrainpk;
        if ~isfield(L,'Apred')    % use Tset as Pset so that it will run Tcv only
         Y_iAna_T=cat(1,L.saConc.Conc);    % use Tset as Pset so that it will run Tcv only, updated Nov 11, 2020
         X_iAna_P=L.Atrainpk;                      % use Tset as Pset so that it will run Tcv only
         Y_iAna_P=cat(1,L.saConc.Conc);   % use Tset as Pset so that it will run Tcv only
         
         L.PLS.Tset.saConc=L.saConc;
         L.PLS.Pset.saConc=L.saConc;
         
         L.Apred=L.Atrainpk;
         L.AclabelP=L.AclabelT;
         L.AclassinfoP=L.AclassinfoT;
         L= rmfield(L,'saConc');
         
        else
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        X_iAna_P=L.Apred;
        Y_iAna_P=cat(1,L.PLS.Pset.saConc.Conc);
        end
        

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    inp4Tcv.Tcv_scheme= find_keyword_between_markers( inp4PLS.handles.pm_Tcv_scheme.String{inp4PLS.handles.pm_Tcv_scheme.Value},'=','');
catch
    if isfield(inp4PLS,'inp4Tcv') && isfield(inp4PLS.inp4Tcv,'Tcv_scheme')              % updated Oct 17, 2020 for providing Tcv_scheme of 'Leave-OneConc-Out'
        %     inp4Tcv.Tcv_scheme='Leave-OneConc-Out';  % default (for now)
        inp4Tcv=inp4PLS.inp4Tcv;
    else
        inp4Tcv.Tcv_scheme= 'sqrtNSfolds-Conc'; % now this the new default
    end
end
    inp4Tcv.para_norm=0;
    inp4Tcv.para_asmc=1;
%    inp4Tcv.list_C=inp4PLS.list_C;
    inp4Tcv.PlsfactorScan=inp4PLS.PlsfactorScan;
    %%%%%%%%%%
    inp4Tcv.ktype='SVRbyLS';   %  'SVRbyLS'  'linear'
    CurAnaName=inp4PLS.cList_Ana_to_Run{1};

    switch inp4PLS.ModelPara_Opm_Scheme
        %============================================================================================================================
        case 'ModelParaOpmBy-Tcv'
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % get --> CurTcvModelParaOpmScheme
                try
                    %this supposed to be based on CabXferTOOL
                    CurTcvModelParaOpmScheme= inp4PLS.handles.Tcv_ModelParaOpmScheme.String{inp4PLS.handles.Tcv_ModelParaOpmScheme.Value};
                catch
                    % this will be based on AQP
                    CurTcvModelParaOpmScheme= inp4PLS.CurTcvModelParaOpmScheme;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(CurTcvModelParaOpmScheme,'LSUX_RMSECV') && ~isequal(inp4Tcv.PlsfactorScan,[1:20])
                error('Pls set PlsfactorScan to [1:20] for "LSUX_RMSECV" ')
            end   
                
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [X_iAna_T_Tcv Y_iAna_T_Tcv  cSampleName_T_Tcv]=PLS_wTcv_StandAlone_AQPpu__saConc2XY(L.PLS.Tset.saConc,CurAnaName);
                inp4Tcv.KPplus=1; % need this for historical reason
                OUT_Tcv=[];
                all_Pest_ifold_Pest=[];
                tstart = tic;
                hwb = waitbar(0,'running cross validation...');  %  waitbar
                for iPf=1:length(inp4Tcv.PlsfactorScan)
                    inp4Tcv.PLSfactor=inp4Tcv.PlsfactorScan(iPf);
                    outPLS_Tcv_iPf=PLS_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv);  % new and fixed
                    OUT_Tcv=[OUT_Tcv;outPLS_Tcv_iPf];
                    
                    if iPf==1
                    all_Pest_ifold_Pest=[all_Pest_ifold_Pest, outPLS_Tcv_iPf.Pest4LSUX ];   
                    else
                   all_Pest_ifold_Pest=[all_Pest_ifold_Pest, outPLS_Tcv_iPf.Pest4LSUX(:,2) ]; 
                    end
                    
                    waitbar(iPf/length(inp4Tcv.PlsfactorScan),hwb);   %  waitbar
                end
                %%%%%%%%%%%%%%%%%
                all_Pest_Ptrue_ifold_Pest=[Y_iAna_T_Tcv,all_Pest_ifold_Pest];
                Pest_LSUX=all_Pest_Ptrue_ifold_Pest;
               
%                 optimalF=optPLS_Unscrambler_CH(pfn,inp);
%                  Pest= Pest_LSUX;
%                 save(  strrep(fileparts_name_ext(pathfnameTP),'Atrainpketc_','Pest4LSUX-OpmPLSfactor_BasedOn_Tset_in_'),'Pest');
%                 clear Pest
                %%%%%%%%%%%%%%%%%%%
                
                close(hwb);% waitbar
                
                telapsed = toc(tstart);
                elapeTime_HumanRead=seconds2human_CH(telapsed);
                try
                all_RMSE_PLS_Tcv=arrayfun(@(x) x.RMSE,OUT_Tcv);
                catch
               all_RMSE_PLS_Tcv=NaN;     % dealing with  'LSUX-RMSECV'
                end
                
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 % get --> CurTcvModelParaOpmScheme
%                 try
%                     %this supposed to be based on CabXferTOOL
%                     CurTcvModelParaOpmScheme= inp4PLS.handles.Tcv_ModelParaOpmScheme.String{inp4PLS.handles.Tcv_ModelParaOpmScheme.Value};
%                 catch
%                     % this will be based on AQP
%                     CurTcvModelParaOpmScheme= inp4PLS.CurTcvModelParaOpmScheme;
%                 end
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
%==============================================================================================================================                
%==============================================================================================================================                
switch CurTcvModelParaOpmScheme
    case 'Min-RMSECV'
        [minRMSE_PLS_Tcv loc_Opm_PLS_Tcv]=min( all_RMSE_PLS_Tcv);
        RMSE_PLS_Opm_Tcv=minRMSE_PLS_Tcv;
        PLSfactor_Opm_Tcv=inp4Tcv.PlsfactorScan(loc_Opm_PLS_Tcv);
        %case 'KneePt-RMSECV'
    case 'LSUX_RMSECV'                               % revisit this 'LSUX_RMSECV'  Sept 13, 2022
        [PLSfactor_Opm_Tcv   PlsfactorScan_LSUX  all_RMSE_PLS_Tcv_OR_resVar]=optPLS_Unscrambler_CH(Pest_LSUX);
        % all_RMSE_PLS_Tcv=NaN;
        %   RMSE_PLS_Opm_Tcv=all_RMSE_PLS_Tcv(PlsfactorScan_LSUX==PLSfactor_Opm_Tcv);
        RMSE_PLS_Opm_Tcv=NaN;    %  "all_RMSE_PLS_Tcv" in this situation is not based on RMSE, "RMSE_PLS_Opm_Tcv" will be assigned later in the code
        resVar_PLS_Opm_Tcv=all_RMSE_PLS_Tcv_OR_resVar(PlsfactorScan_LSUX==PLSfactor_Opm_Tcv);
        disp('running "LSUX_RMSECV" ')
        %  all_RMSE_PLS_Tcv
    case   {'KneePt-RMSECV','KneePt+1_RMSECV','User-Pick'}
        just_return=0;
        try
            if max(inp4Tcv.PlsfactorScan)>2
                [res_x, idx_of_result] = knee_pt(all_RMSE_PLS_Tcv,inp4Tcv.PlsfactorScan,just_return);
            else
                [minRMSE_PLS_Tcv loc_Opm_PLS_Tcv]=min( all_RMSE_PLS_Tcv);
                res_x=loc_Opm_PLS_Tcv;  % set knee_pt by 'Min-RMSECV' for only two points PlsfactorScan
            end
        catch
            res_x=loc_Opm_PLS_Tcv;  % set knee_pt by 'Min-RMSECV' for only two points PlsfactorScan
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(CurTcvModelParaOpmScheme,'KneePt+1_RMSECV')
            if max(inp4Tcv.PlsfactorScan)>res_x
                PLSfactor_Opm_Tcv=res_x+1;
            else
                PLSfactor_Opm_Tcv=res_x;
            end
        elseif strcmp(CurTcvModelParaOpmScheme,'User-Pick')
            res_x=NaN;
            PLSfactor_Opm_Tcv=inp4PLS.PLSfactor_Opm_User_Pick;  % added by CH Nov 22, 2019
        else
            PLSfactor_Opm_Tcv=res_x;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        RMSE_PLS_Opm_Tcv=all_RMSE_PLS_Tcv(inp4Tcv.PlsfactorScan==PLSfactor_Opm_Tcv);
        %--------------------------------------------------------------------------------------------------------------------
    otherwise
error(' CurTcvModelParaOpmScheme  Not supported !!! ');
end
%==============================================================================================================================
%==============================================================================================================================
                outPLS_Tcv.PLSfactor_Opm=PLSfactor_Opm_Tcv;
                %----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                %----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                % in order to handle LSUX_RMSECV within AQPlite, this function will be called by "PLS_inside_PLS_predict_ONLY_MLtool.m" , Jan 5, 2023
                % add following to calculate 'LSUX_RMSECV' from AQPlite pu , Jan 5, 2023
                %
                aStack = dbstack;
                if strcmp(aStack(2).name,'PLS_inside_PLS_predict_ONLY_MLtool')             % in order to handle LSUX_RMSECV within AQPlite, this function will be called by "PLS_inside_PLS_predict_ONLY_MLtool.m" , Jan 5, 2023
                    out.PLSfactor_Opm_Tcv=PLSfactor_Opm_Tcv;
                    return;
                end
                %----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                %----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                figure;hold on;set(gcf,'position',1000*[0.1263    0.0657    1.1887    0.5733]);
                if strcmp(CurTcvModelParaOpmScheme, 'LSUX_RMSECV')
                    plot(PlsfactorScan_LSUX,all_RMSE_PLS_Tcv_OR_resVar,'k-*','linewidth',2);
                     plot(PLSfactor_Opm_Tcv,resVar_PLS_Opm_Tcv,'gO','markersize',10,'markerfacecolor','g');
                else
                    plot(inp4Tcv.PlsfactorScan,all_RMSE_PLS_Tcv,'k-*','linewidth',2);
                    plot(PLSfactor_Opm_Tcv,RMSE_PLS_Opm_Tcv,'gO','markersize',10,'markerfacecolor','g');
                end
                
                
                try
                    [hpvl htvl ]=plot_vline(res_x,'o');  %show results by 'KneePt-RMSECV'
                end
                
                ctit11={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
                if strcmp(CurTcvModelParaOpmScheme, 'LSUX_RMSECV')
                ctit33={[inp4PLS.ModelPara_Opm_Scheme,'   ',CurTcvModelParaOpmScheme,'   PLSfactor_opm =',num2str(PLSfactor_Opm_Tcv),'  resVar=',roundns(resVar_PLS_Opm_Tcv,3)]};
                else
                ctit33={[inp4PLS.ModelPara_Opm_Scheme,'   ',CurTcvModelParaOpmScheme,'   PLSfactor_opm =',num2str(PLSfactor_Opm_Tcv),'  RMSECV=',roundns(RMSE_PLS_Opm_Tcv,3)]};
                end
                 ctit33=strrep(ctit33,'_','\_');
                ctit44=['Tcv_scheme = ',OUT_Tcv(1).Tcv_scheme,'   nFolds=',num2str(OUT_Tcv(1).nFolds),'   Time Spent: ',elapeTime_HumanRead,'     Opm-LV by: ',CurTcvModelParaOpmScheme];
                ctit44=strrep(ctit44,'_','\_');
                title([ctit11;ctit33;ctit44]);
                 if strcmp(CurTcvModelParaOpmScheme, 'LSUX_RMSECV')
                     ylabel('resVar');
                 else
                     ylabel('RMSECV');
                 end
                
            %============================================================================================================================

            
            %============================================================================================================================
        otherwise
            error('this version only support " ModelParaOpmBy-Tcv " ');
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 PLSfactor_Opm=outPLS_Tcv.PLSfactor_Opm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if isequal(L.Atrainpk,L.Apred)
         Tset_alone_yes=1;
     else
         Tset_alone_yes=0;
     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~Tset_alone_yes
% run PLS on whole Pset
X_iAna_P_whole=L.Apred;
Y_iAna_P_whole=cat(1,L.PLS.Pset.saConc.Conc);
saSVR_Results_Pwhole=PLS_indv(X_iAna_T,X_iAna_P_whole,Y_iAna_T,Y_iAna_P_whole,inp4Tcv);
figure;hold on;set(gcf,'position',1000*[0.0666    0.0417    1.1764    0.5480]);
all_PLSfactor=arrayfun(@(x) x.PLSfactor,saSVR_Results_Pwhole);
all_RMSE_PLS=arrayfun(@(x) x.RMSE,saSVR_Results_Pwhole);
[RMSE_PLS_min loc_minRMSE_PLS]=min(all_RMSE_PLS);
PLSfactor_PLS_min=all_PLSfactor(loc_minRMSE_PLS);
plot(all_PLSfactor,all_RMSE_PLS,'k-*','linewidth',2);
RMSE_PLS_Opm=all_RMSE_PLS(all_PLSfactor==PLSfactor_Opm);
plot(PLSfactor_Opm,RMSE_PLS_Opm,'gO','markersize',15,'markerfacecolor','g');
plot(PLSfactor_PLS_min,RMSE_PLS_min,'bO','markersize',12,'markerfacecolor','b');
xlabel('PLS factor');
ylabel('RMSE by PLS');
ctit1={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
ctit2={['PLSfactor@min =',num2str(PLSfactor_PLS_min),'  min RMSE=',roundns(RMSE_PLS_min,3)]};
ctit3={[inp4PLS.ModelPara_Opm_Scheme,'   ',strrep(CurTcvModelParaOpmScheme,'_','\_'),'   PLSfactor\_opm =',num2str(PLSfactor_Opm),'  RMSE=',roundns(RMSE_PLS_Opm,3)]};

% strrep(inp4PLS.ModelPara_Opm_Scheme,'_','\_')

%  ctit3=strrep(ctit3,'_','\_');
title([ctit1;ctit2;ctit3]);
end
%=================================================================
if ~Tset_alone_yes
    % work on Val set and in this code Val set is always equal to Pset
    inp4V=inp4Tcv;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pick OpmPLSfactor by user input
    PLSfactor_PickByUser_yes=1;
    if PLSfactor_PickByUser_yes  && strcmp(inp4PLS.ModelPara_Opm_Scheme,'ModelParaOpmBy-Tcv' )
        try
            PLSfactor_Opm=str2num(find_keyword_numeric_AFTER_marker(inp4PLS.handles.sOpmPLS_Pick.String,'='));
        catch
            PLSfactor_Opm='';
        end
        if isempty(PLSfactor_Opm)
            PLSfactor_Opm= PLSfactor_Opm_Tcv;
            sAltOpmPLS='';
        else
            sAltOpmPLS=' (PickByUser)';
        end
        
    else
        sAltOpmPLS='';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inp4V.PlsfactorScan=PLSfactor_Opm;
    
    pathfnameTP4Val=inp4PLS.pathfnameTP4Val;
    %         L_Val= load('C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mA_mB_P-mC_Val\Atrainpketc_saConc_IDRC_{T-ManufacturerA_Cal_CalSetA123_P-mC_Val_pp1-1stDerSGw13}_nvar88_nsampTT744_nsampP150.mat')
    L_Val= load(pathfnameTP4Val);
    
    X_iAna_V=L_Val.Apred;   % for Val set
    Y_iAna_V=cat(1,L_Val.PLS.Pset.saConc.Conc);   % for Val set
    %         saSVR_Results_Val=SVR_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V);
    
    if length(L_Val.Atrainpk(:,1))>length(X_iAna_T(:,1))% the case of add UDM
        X_iAna_T=L_Val.Atrainpk;
        Y_iAna_T=cat(1,L_Val.PLS.Tset.saConc.Conc);
    end
    saPLS_Results_Val=PLS_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V);  % based on RMS_error_woNaN_N
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hf_indv_45deg=figure;hold on;set(gcf,'position',1000*[0.0163    0.0470    1.1980    0.4913])
    plot(saPLS_Results_Val.Y_iAna_P,saPLS_Results_Val.Yest_PLS,'b*');
    plot_45degree_line('y');
    xlabel('True Conc');
    ylabel('Est Conc');
    
    %RMSE_clean=RMS_error_woNaN(saPLS_Results_Val.Y_iAna_P,saPLS_Results_Val.Yest_PLS);
    
    RMSE_clean=RMS_error_woNaN_N(saPLS_Results_Val.Y_iAna_P,saPLS_Results_Val.Yest_PLS);  % based on RMS_error_woNaN_N
    
    
    STD_clean=std(saPLS_Results_Val.Y_iAna_P-saPLS_Results_Val.Yest_PLS);
    Bias_clean=mean(saPLS_Results_Val.Y_iAna_P-saPLS_Results_Val.Yest_PLS);
    stit_TP=['TP: ',strrep(fileparts_name_ext( pathfnameTP ),'_','\_')];
    if ~strcmp(inp4PLS.pathfnameTP4Val,pathfnameTP)
        stit_Val=['Val: ',strrep(fileparts_name_ext( pathfnameTP4Val ),'_','\_')];
    else
        stit_Val='';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        Cur_Analyte=inp4PLS.handles.sAnalyte.String{inp4PLS.handles.sAnalyte.Value};
    catch
        if length(inp4PLS.cList_Ana_to_Run)==1
            Cur_Analyte=  inp4PLS.cList_Ana_to_Run{1};
        else
            Cur_Analyte='Unknown';
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    ctit_45deg={[Cur_Analyte,'    Pest by PLS '];stit_TP;...
        [strrep(CurTcvModelParaOpmScheme,'_','\_'),'   OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),sAltOpmPLS,'   RMSE =',roundns(RMSE_clean,3),'      STD =',roundns(STD_clean,3), '      Bias =',roundns(Bias_clean,3)  ] };
    title(ctit_45deg);
    saPLS_Results_Val.ctit_45deg=ctit_45deg;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
 % deal with woVal case by insert Tcv results into saPLS_Results_Val, updated Oct 15, 2020
 %
 %===================================
  inp4Tcv_Opm=inp4Tcv;
 inp4Tcv_Opm.PLSfactor=PLSfactor_Opm_Tcv;
 outPLS_Tcv_Opm=PLS_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv_Opm);  % new and fixed
 RMSE_PLS_Opm_Tcv=outPLS_Tcv_Opm.RMSE;  % for Tset_alone_yes==1 case, "RMSE_PLS_Opm_Tcv" assigned correct value here
 
 %===================================
 RMSE_PLS_Opm=RMSE_PLS_Opm_Tcv;
 %         RMSE_clean=NaN;
 %---------------------------------------------------------------------------------------
 % following see --> PLS_inside_PLS_predict_ONLY_MLtool
 % New approach After 1008, 2020--> use Tcv results
 %  RMSE_PLS_Opm_Tcv=all_RMSE_PLS_Tcv(inp4Tcv.PlsfactorScan==PLSfactor_Opm_Tcv);
 saPLS_Results_Val.PLSfactor=PLSfactor_Opm_Tcv;% deal with woVal case by insert Tcv results into saPLS_Results_Val
 saPLS_Results_Val.RMSE=RMSE_PLS_Opm_Tcv;% deal with woVal case by insert Tcv results into saPLS_Results_Val
 % % checking
%  inp4Tcv_Opm=inp4Tcv;
%  inp4Tcv_Opm.PLSfactor=PLSfactor_Opm_Tcv;
%  outPLS_Tcv_Opm=PLS_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv_Opm);  % new and fixed
 if  outPLS_Tcv_Opm.RMSE==RMSE_PLS_Opm_Tcv      % checking
     saPLS_Results_Val.Yest_PLS=outPLS_Tcv_Opm.Yest_all;              % deal with woVal case by insert Tcv results into saPLS_Results_Val
     saPLS_Results_Val.Y_iAna_P=Y_iAna_T_Tcv;                                 % deal with woVal case by insert Tcv results into saPLS_Results_Val
     saPLS_Results_Val.beta=NaN;                                                        % deal with woVal case by insert Tcv results into saPLS_Results_Val
 else
     error('mismatch between outPLS_Tcv_Opm.RMSE vs RMSE_PLS_Opm_Tcv')
 end
 % prepare for 45deg plot based on Tcv and store info inside --> saPLS_Results_Val
 Cur_Analyte=  inp4PLS.cList_Ana_to_Run{1};
 RMSE_clean=RMS_error_woNaN_N(saPLS_Results_Val.Y_iAna_P,saPLS_Results_Val.Yest_PLS);  % based on RMS_error_woNaN_N
 STD_clean=std(saPLS_Results_Val.Y_iAna_P-saPLS_Results_Val.Yest_PLS);
 Bias_clean=mean(saPLS_Results_Val.Y_iAna_P-saPLS_Results_Val.Yest_PLS);
 stit_TP=['TP: ',strrep(fileparts_name_ext( pathfnameTP ),'_','\_')];
 
 hf_indv_45deg=figure;hold on;set(gcf,'position',1000*[0.0163    0.0470    1.1980    0.4913])
 plot(saPLS_Results_Val.Y_iAna_P,saPLS_Results_Val.Yest_PLS,'b*');
 plot_45degree_line('y');
 xlabel('True Conc');
 ylabel('Est Conc');
 
 ctit_45deg={[Cur_Analyte,'  Val based on Tcv  '];stit_TP;...
     [inp4Tcv.Tcv_scheme,'  ',strrep(CurTcvModelParaOpmScheme,'_','\_'),'   OpmPLSfactor=',num2str(saPLS_Results_Val.PLSfactor),'   RMSE =',roundns(RMSE_clean,3),'      STD =',roundns(STD_clean,3), '      Bias =',roundns(Bias_clean,3)  ] };
 
 title(ctit_45deg);
 
 saPLS_Results_Val.ctit_45deg=ctit_45deg;
 %------------------------------------------------------------------------------------------------
 
    
    
end
%================================================================================================================================== 
%==================================================================================================================================  

try
    %inp4PLS.outPLS_Tcv_prev.PLSfactor_Opm;
    out.outPLS_Tcv=outPLS_Tcv;
catch
    out.outPLS_Tcv='';
end
out.PLSfactor_Opm=PLSfactor_Opm;
out.RMSE_PLS_Opm=RMSE_PLS_Opm;
%=============
% add following output for Bias and StdErr, Mar 8, 2022
out.Bias=Bias_clean;
out.StdErr=STD_clean;
%=============
try
out.PLSfactor_PLS_min=PLSfactor_PLS_min;
out.RMSE_PLS_min=RMSE_PLS_min;
catch
 out.PLSfactor_PLS_min=NaN;
out.RMSE_PLS_min=NaN;   
end
out.ModelPara_Opm_Scheme=inp4PLS.ModelPara_Opm_Scheme;
warning off
sSM_P=strrep(find_keyword_between_markers_wlistRHS( fileparts_name_ext(pathfnameTP),'_P-',{'}','_'}),'00','');
sSM_T=strrep(find_keyword_between_markers_wlistRHS( fileparts_name_ext(pathfnameTP),'T-',{'}','_P-'}),'00','');
%============================================================================
% % add info AUC_thres for mU2U project, Mar 18, 2022
sSM_TP_alt=find_keyword_between_markers( fileparts_name_ext(pathfnameTP),'{','}')  ;
sSM_TP_alt=strrep(sSM_TP_alt,'00','');
sSM_TP_pure= ['T-',sSM_T,'_','P-',sSM_P] ;
if ~isempty(sSM_TP_alt)  &&   ~strcmp(sSM_TP_alt, sSM_TP_pure ) && strfind(sSM_TP_alt,sSM_TP_pure)==1
sSM_TP_add=sSM_TP_alt(length(sSM_TP_pure)+2:end);
out.sSM_TP_add=sSM_TP_add;
else
out.sSM_TP_add=[];    
end
%=============================================================================
if isempty(sSM_T)
    % deal with PAT cases
    sSM_T=strrep(  find_keyword_between_markers_wlistRHS( fileparts_name_ext(pathfnameTP),'{T-',{'}','_P-'})  ,'00','');
end
warning on
out.sSM_P=sSM_P;
out.sSM_T=sSM_T;

try
    saPLS_Results_Val.AclabelP=L.AclabelP;
end
try
   out.saPLS_Results_Val=saPLS_Results_Val; 
end
try
out.hf_indv_45deg=hf_indv_45deg;
catch
out.hf_indv_45deg=[];    
end
try
   out.inp4Tcv=inp4Tcv;
end
end


%% ----- PLS_wTcv_StandAlone_AQPpu__saConc2XY   [AQP_gui.m lines 13298-13303] ----------------------
function [X_iAna Y_iAna  cSampleName]=PLS_wTcv_StandAlone_AQPpu__saConc2XY(saConc,AnaName)
idx_CurAna= arrayfun(@(x) strcmp(x.clsname,AnaName),saConc);
X_iAna=cell2mat(arrayfun(@(x) x.Atrainpk, saConc(idx_CurAna),'un',0));
Y_iAna=cell2mat(arrayfun(@(x) repmat(x.Conc,[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
cSampleName=cell_unwrap(arrayfun(@(x) repmat({x.SampleName},[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
end


%% ----- RMS_error_woNaN   [AQP_gui.m lines 13326-13386] -------------------------------------------
function RMSE=RMS_error_woNaN(Xhat,Xmeasure)
% calculate root mean square of error between calculated vs measured
% output [] if either Xhat or Xmeasure is empty
% Chang Hsiung, July 17, 08
% modified by Chang Hsiung, Nov. 11,08 by divided by (N-1) instead of N
% e.g. Xhat=[1 3 2];Xmeasure=[.5 3.5 2.5];RMSE=RMS_error(Xhat,Xmeasure)
% e.g. diff=[1 NaN 3 2];RMSE=RMS_error_woNaN(diff)
% e.g. diff=[1  3 2];RMSE=RMS_error(diff)
% e.g. Xhat=[1 NaN 3 2];Xmeasure=[.5  20 3.5 2.5];RMSE=RMS_error_woNaN(Xhat,Xmeasure)
% e.g. Xhat=[1 3 2];Xmeasure=[.5  3.5 2.5];RMSE=RMS_error(Xhat,Xmeasure)
% e.g. RMS_error_woNaN(  [[1 3 2]',[-2 0 3 ]'  ] )
%checking 


if nargin==2
    if length(Xhat)~=length(Xmeasure)
        error('mismatch in length between Xhat and Xmeasure');
    else
        Xhat=row_vector_ALWAYS(Xhat);
        Xmeasure=row_vector_ALWAYS(Xmeasure);

    end

    %RMSE formula
    if length(Xhat)==0 || length(Xmeasure)==0
        RMSE=[];
    else

        diff=Xhat-Xmeasure;
        N=sum(~isnan(diff));

        RMSE=sqrt(nansum((diff).^2)./(N-1));
        if N==1
            RMSE=NaN;   %output NaN ( instead of Inf ) for the case of N==1 
        end

    end
elseif nargin==1   % where Xhat is treated as diff
    
    if length(Xhat)==0 
        RMSE=[];
    else


    N=sum(~isnan(Xhat));
    RMSE=sqrt(nansum(Xhat.^2)./(N-1));
    
    RMSE= replace_CH(RMSE,Inf,NaN);  %output NaN (instead of Inf) in case of only one sample
    
    end

else
    error('wrong number of input variables');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% when N: number of non-NaN samples is zero, output NaN
    loc_zeroN=find(N==0);
    RMSE(loc_zeroN)=NaN;
end


%% ----- RMS_error_woNaN_N   [AQP_gui.m lines 13390-13482] -----------------------------------------
function [RMSE  out]=RMS_error_woNaN_N(Xhat,Xmeasure)
% calculation of RMSE based on  N (not N-1)
%   this RMSE when use following STD and BIAS can match with 
%   RMSE_cald=sqrt(STD_std^2+BIAS_meandif^2)  to less than 1E-10
%
%   Matlab's build-in "std" is based on N-1 !!!
%   in order to match with RMSE_N, we need to convert "std" --> "STD_std_N"
%   STD_std_N=sqrt(std(Y_iAna_est-Y_iAna_P)^2*(length(X_iAna_P)-1)/length(X_iAna_P)); % based on N (not N-1)
% 
%  BIAS_meandif=mean(Y_iAna_est-Y_iAna_P);   % this bias is based on N of cause
% 
%
% see also :  calc_RMSE_Bias_StdErr   StdErr_N   RMS_error_woNaN 
%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if false
    
    cc
    Xhat=[0;2;3];Xmeasure=[2;3;2];
%     RMSE_N=RMS_error_woNaN_N(Xhat,Xmeasure)
    STD_std_N=sqrt(std(Xhat-Xmeasure)^2*(length(Xmeasure)-1)/length(Xmeasure)) % based on N (not N-1)
    BIAS_meandif_N=mean(Xhat-Xmeasure)
    RMSE_cald=sqrt(STD_std_N^2+BIAS_meandif_N^2) % this match  RMSE_N
  [RMSE  out]=  RMS_error_woNaN_N(Xhat,Xmeasure)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
   cc
    Xhat=[1;2;3];Xmeasure=[2;3;2];
    STD_std_N=sqrt(std(Xhat-Xmeasure)^2*(length(Xmeasure)-1)/length(Xmeasure)) % based on N (not N-1)
    BIAS_meandif_N=mean(Xhat-Xmeasure)
    RMSE_cald=sqrt(STD_std_N^2+BIAS_meandif_N^2) % this match  RMSE_N
  [RMSE  out]=  RMS_error_woNaN_N(Xhat,Xmeasure)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
   cc
    Xhat=[2;2;3];Xmeasure=[2;3;2];
    STD_std_N=sqrt(std(Xhat-Xmeasure)^2*(length(Xmeasure)-1)/length(Xmeasure)) % based on N (not N-1)
    BIAS_meandif_N=mean(Xhat-Xmeasure)
    RMSE_cald=sqrt(STD_std_N^2+BIAS_meandif_N^2) % this match  RMSE_N
  [RMSE  out]=  RMS_error_woNaN_N(Xhat,Xmeasure)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cc
  Xhat=[1:10]';Xmeasure=5*ones(10,1);
   [RMSE  out]=  RMS_error_woNaN_N(Xhat,Xmeasure)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % mean  of single sample's RMSE will be equal to MAE
  cc
  Xhat=[1:10]';Xmeasure=5*ones(10,1);
  mean(arrayfun(@(x,y) RMS_error_woNaN_N(x,y),Xhat,Xmeasure))
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % however repeated distribution's RMSE_N is same as indv distribution
  % but repeated distribution's RMSE_Nm1 is slightly lower than indv distribution
  %
   cc
  Xhat=[1:10]';Xmeasure=5*ones(10,1);
  Xhat=repmat(Xhat,[100 1]);
   Xmeasure=repmat(Xmeasure,[100 1]);
   [RMSE  out]=  RMS_error_woNaN_N(Xhat,Xmeasure)
   %%%%%%%%%%%%%%%%%%%%%%%%%
   Xhat=[1:10]';Xmeasure=5*ones(10,1);
  Xhat=repmat(Xhat,[2 1]);
   Xmeasure=repmat(Xmeasure,[2 1]);
   [RMSE  out]=  RMS_error_woNaN_N(Xhat,Xmeasure)
   
   
   
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%  
end
%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if length(Xhat)==1
    RMSE=abs(Xhat-Xmeasure);
    RMSE_Nm1=RMSE;
else
    RMSE_Nm1=RMS_error_woNaN(Xhat,Xmeasure);
    RMSE=sqrt(RMSE_Nm1^2*(length(Xhat)-1)/length(Xhat));
end

diff=Xhat-Xmeasure;
N=sum(~isnan(diff));
MAE=sum(abs(diff(:)))/N;

out.RMSE=RMSE;
try
    out.RMSE_Nm1=RMSE_Nm1;
end
out.MAE=MAE;
end


%% ----- RenameField   [AQP_gui.m lines 14753-14832] -----------------------------------------------
function S = RenameField(S, Old, New)
% RenameField - Rename a field of a struct
% T = RenameField(S, Old, New)
% INPUT:
%  INPUT:
%    S:    Struct or struct array.
%    Old:  String or cell string, name of the fields to be renamed. If Old is
%          not existing in S, the output T equals the input S.
%    New:  String or cell string, new field name, which must be a valid Matlab
%          symbol: up to 63 characters, first character is a letter, the others
%          are alpha-numeric or the underscore.
%  OUTPUT:
%    T:    Struct S with renamed fields.
%
% EXAMPLES:
%   S.A = 1; S.B = 2;
%   T = RenameField(S, 'B', 'C');  %  >>  T.A = 1, T.C = 2
%
% NOTE: Hardcore programmers can omit the validity checks of the new name.
%   Then all names with up to 63 characters are allowed. Although this does
%   not crash Matlab, the effects can be rather strange: you can rename a
%   field to '*', ' ' and even ''. Such fields can be accessed by dynamic field
%   names: S.('') works!
%   If the checking is disabled, the field names are not necessarily unqiue
%   Then the dynamic field name access picks the first occurence of a name. But
%   e.g. RMFIELD will stop with an error. But other functions might crash.
%
% NOTE: This function was created after some discussions in Loren's blog:
%   http://blogs.mathworks.com/
%          loren/2010/05/13/rename-a-field-in-a-structure-array
%
% COMPILATION: See RenameField.c
% Run uTest_RenameField to check validity and speed of the Mex function.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2006-2011 matlab.THISYEAR(a)nMINUSsimon.de
%
% See also keepfield RMFIELD CELL2STRUCT, STRUCT, GENVARNAME

% $JRev: R-f V:005 Sum:rsC5ZfSTA7dM Date:11-Feb-2011 00:17:01 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Tools\GLStruct\RenameField.m $
% History:
% 001: 19-Aug-2010 00:11, Created after discussion in Loren's blog.

% Initialize: ==================================================================
% Do the work: =================================================================

% This is an implementation as M-code. Prefer the mex file, which is 50% (S has
% 1 field only) to 95% (S has 1000 fields) faster.

% Comment this out, if you want to use the M-version:
% error(['JSimon:', mfilename, ':NoMex'], 'Cannot find compiled Mex file!');

% Under Matlab 6.5 CELL2STRUCT accpets names with more than 63 characters. But
% the later recognition fails!



if isempty(S) && isa(S, 'double')  % Accept [] as empty struct without fields
   return;
end

Data  = struct2cell(S);
Field = fieldnames(S);
if ischar(Old)
   Field(strcmp(Field, Old)) = {New};
elseif iscellstr(Old)
   for iField = 1:numel(Old)
      Field(strcmp(Field, Old{iField})) = New(iField);
   end
else
   error(['JSimon:', mfilename, ':BadInputType'], ...
      'Fields must be a string or cell string!');
end

S = cell2struct(Data, Field);

return;
end


%% ----- SAinsert_cell2cell   [AQP_gui.m lines 14836-14847] ----------------------------------------
function varargout=SAinsert_cell2cell(X)
% alias of cell2cell_4SAinsert
% for one line insert of one field with or without modification from one structure array into another field
% this function typically can be used to copy/rename one structure array
% from one parent to another parent
% sa=struct('f1',{[1 2 3],[1 2 3],[1 2 3]})
% [sa.f2]=SAinsert_cell2cell( arrayfun(@(x) x.f1(1:2),sa,'uniformoutput',false))
% pls see also: cell2cell_4SAinsert  num2cell_4SAinsert  and mat2cell_4SAinsert
for i=1:length(X(:))
varargout(i)=X(i);
end
end


%% ----- SAinsert_createNew_w_seqnum   [AQP_gui.m lines 14851-14883] -------------------------------
function saNew= SAinsert_createNew_w_seqnum(N)
% create a new column Structure Array (SA) with field 'seqnum' and N elements
% e.g. saNew= SAinsert_createNew_w_seqnum(5)
% see also: SAinsert_createNew_w_seqnum_2D SAinsert_cstr_or_double  SAinsert_related
%  see also: spectra_dispenser , Nov 15, 2022
if false
    
    test1=[11:15]
    
    saNew= SAinsert_createNew_w_seqnum(5);
    
    [saNew.t1]=SAinsert_cstr_or_double(  test1 );
    
    saNew(4)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        test1=cellstr('Result-'+string([11:20]'));
    
    saNew= SAinsert_createNew_w_seqnum(10);
    
    [saNew.t1]=SAinsert_cstr_or_double(  test1 );
    
    saNew(7)

    
    
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[saNew(1:N,1).seqnum]=SAinsert_repmat(NaN,N);%create new SA and insert a dummy NaN first
[saNew.seqnum]=SAinsert_num2cell([1:N]);% insert the really needed array into it
end


%% ----- SAinsert_createNew_w_seqnum_2D   [AQP_gui.m lines 14887-14942] ----------------------------
function saNew= SAinsert_createNew_w_seqnum_2D(M,N)
% create a new column Structure Array (SA) with field 'seqnum' and N elements
% e.g. saNew= SAinsert_createNew_w_seqnum(5)
% see also: SAinsert_cstr_or_double  SAinsert_num2cell SAinsert_createNew_w_seqnum SAinsert_related
if false
    saNew= SAinsert_createNew_w_seqnum_2D(2,3);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create new and insert cstr
    test1=[{'pas','fail','pas'};{'fail','pas','fail'}]
    test2=[{'fail','fail','pas'};{'fail','pas','fail'}]
    
    saNew= SAinsert_createNew_w_seqnum_2D(2,3);
    
    [saNew.t1]=SAinsert_num2cell(  test1 );% insert the really needed array into it
    [saNew.t2]=SAinsert_num2cell(  test2 );% insert the really needed array into it
    
    saNew(1,3)
    saNew(2,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create new and insert double array
    
    test1=magic(5);
    test1(5,:)=[]
    test2=magic(5);
    test2(1,:)=[]
    
    
    saNew= SAinsert_createNew_w_seqnum_2D(4,5);
    
    [saNew.t1]=SAinsert_num2cell(  test1 );% insert the really needed array into it
    [saNew.t2]=SAinsert_num2cell(  test2 );% insert the really needed array into it
    
    saNew(1,3)
    saNew(2,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    test3={'fail','fail','pas','fail'}'
    saNew= SAinsert_createNew_w_seqnum_2D(4,1);
    [saNew.t3]=SAinsert_num2cell(  test3 );% insert the really needed array into it
    
    saNew(3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    test3={'fail','fail','pas','fail'}
    saNew= SAinsert_createNew_w_seqnum_2D(1,4);
    [saNew.t3]=SAinsert_num2cell(  test3 );% insert the really needed array into it
    
    saNew(4)
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[saNew(1:M,1:N).y_seq]=SAinsert_repmat_2D(NaN,M,N);%create new SA and insert a dummy NaN first
[saNew.y_seq]=SAinsert_num2cell(  repmat(col_always([1:M]),[1 N])  );% insert the really needed array into it
[saNew.x_seq]=SAinsert_num2cell(  repmat([1:N],[M 1])  );% insert the really needed array into it
end


%% ----- SAinsert_cstr_or_double   [AQP_gui.m lines 14946-14997] -----------------------------------
function varargout=SAinsert_cstr_or_double(X)
% alias of SAinsert_num2cell num2cell_4SAinsert
% mainly used for insert X into a structure array ( SA ) with a single line code
% X can be cstr or double array
% if X is 2D matrix, it will output cX{:},i.e. column-wise first
% e.g X=[1 2 3;4 5 6];[a b c d e f]=SAinsert_cstr_or_double(X)
% example for insert X into a structure array:
% sa=struct('f1',{0,0,0,0,0,0});X=[1 2 3;4 5 6];[sa.f1]=SAinsert_cstr_or_double(X);
% pls see also SAinsert_createNew_w_seqnum_2D num2cell_4SAinsert mat2cell_4SAinsert and cell2cell_4SAinsert

if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create new and insert cstr
    test1=[{'pas','fail','pas'};{'fail','pas','fail'}]
    test2=[{'fail','fail','pas'};{'fail','pas','fail'}]
    
    saNew= SAinsert_createNew_w_seqnum_2D(2,3);
    
    [saNew.t1]=SAinsert_cstr_or_double(  test1 );% insert the really needed array into it
    [saNew.t2]=SAinsert_cstr_or_double(  test2 );% insert the really needed array into it
    
    saNew(1,3)
    saNew(2,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create new and insert double array
    
    test1=magic(5);
    test1(5,:)=[]
    test2=magic(5);
    test2(1,:)=[]
    
    
    saNew= SAinsert_createNew_w_seqnum_2D(4,5);
    
    [saNew.t1]=SAinsert_cstr_or_double(  test1 );% insert the really needed array into it
    [saNew.t2]=SAinsert_cstr_or_double(  test2 );% insert the really needed array into it
    
    saNew(1,3)
    saNew(2,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cX=num2cell(X);
for i=1:length(cX(:))
varargout(i)=cX(i);
end
end


%% ----- SAinsert_mat2cell_CH   [AQP_gui.m lines 15001-15020] --------------------------------------
function varargout=SAinsert_mat2cell_CH(X,insert_type)
% alias of mat2cell_CH_4SAinsert
% insert_type should be either 'row' or 'col'
% mainly used for insert X into a structure array ( SA ) with a single line code
% if X is 2D matrix, it will output cX{:},i.e. column-wise first
% pls see also mat2cell_CH  mat2cell_CH_4SAinsert  num2cell_4SAinsert and cell2cell_4SAinsert 
%
% example for insert X into a structure array:
%
%insert each col
% sa=struct('f1',{0,0,0});X=[1 2 3;4 5 6];[sa.f1]=SAinsert_mat2cell_CH(X,'col')
%
% insert each row
%  sa=struct('f1',{0,0});X=[1 2 3;4 5 6];[sa.f1]=SAinsert_mat2cell_CH(X,'row')

cX=mat2cell_CH(X,insert_type);
for i=1:length(cX(:))
varargout(i)=cX(i);
end
end


%% ----- SAinsert_num2cell   [AQP_gui.m lines 15024-15074] -----------------------------------------
function varargout=SAinsert_num2cell(X)
% alias of num2cell_4SAinsert
% mainly used for insert X into a structure array ( SA ) with a single line code
% if X is 2D matrix, it will output cX{:},i.e. column-wise first
% e.g X=[1 2 3;4 5 6];[a b c d e f]=SAinsert_num2cell(X)
% example for insert X into a structure array:
% sa=struct('f1',{0,0,0,0,0,0});X=[1 2 3;4 5 6];[sa.f1]=SAinsert_num2cell(X);
% pls see also SAinsert_createNew_w_seqnum_2D num2cell_4SAinsert mat2cell_4SAinsert and cell2cell_4SAinsert

if false
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create new and insert cstr
    test1=[{'pas','fail','pas'};{'fail','pas','fail'}]
    test2=[{'fail','fail','pas'};{'fail','pas','fail'}]
    
    saNew= SAinsert_createNew_w_seqnum_2D(2,3);
    
    [saNew.t1]=SAinsert_num2cell(  test1 );% insert the really needed array into it
    [saNew.t2]=SAinsert_num2cell(  test2 );% insert the really needed array into it
    
    saNew(1,3)
    saNew(2,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create new and insert double array
    
    test1=magic(5);
    test1(5,:)=[]
    test2=magic(5);
    test2(1,:)=[]
    
    
    saNew= SAinsert_createNew_w_seqnum_2D(4,5);
    
    [saNew.t1]=SAinsert_num2cell(  test1 );% insert the really needed array into it
    [saNew.t2]=SAinsert_num2cell(  test2 );% insert the really needed array into it
    
    saNew(1,3)
    saNew(2,1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cX=num2cell(X);
for i=1:length(cX(:))
varargout(i)=cX(i);
end
end


%% ----- SAinsert_repmat   [AQP_gui.m lines 15078-15104] -------------------------------------------
function varargout= SAinsert_repmat(A,N)
% alias or same as SA_insert_repmat
% see also SA_insert_repmat (supposed to be the same)
% see also SA_insert_repmat  num2cell_4SAinsert, mat2cell_4SAinsert, cell2cell_4SAinsert 
% e.g.  [sa(1:5).f1]=SAinsert_repmat(NaN,5)
% e.g.  [sa1(1:5,1).f1]=SAinsert_repmat('aBc',5)
% e.g.  [sa2(1:10,1).f1]=SAinsert_repmat({'BaDe'},10)

% disp('pls see the following functions:');
% disp('num2cell_4SAinsert, mat2cell_4SAinsert, cell2cell_4SAinsert ');
if isnumeric(A)
%     cX=num2cell(repmat(A,[N 1]));
    
     cX=repmat({A},[N 1]);
   
elseif ischar(A)
    cX=repmat({A},[N 1]);
elseif iscell(A) && length(A)==1
    cX=repmat(A,[N 1]);
else
    error('can only handle numeric, char, or single element cell')
end
%cX=num2cell(X);
for i=1:length(cX(:))
    varargout(i)=cX(i);
end
end


%% ----- SAinsert_repmat_2D   [AQP_gui.m lines 15108-15135] ----------------------------------------
function varargout= SAinsert_repmat_2D(A,M,N)
% alias or same as SA_insert_repmat
% see also SA_insert_repmat (supposed to be the same)
% see also SA_insert_repmat  num2cell_4SAinsert, mat2cell_4SAinsert, cell2cell_4SAinsert 
% e.g.  [sa(1:5).f1]=SAinsert_repmat(NaN,5)
% e.g.  [sa1(1:5,1).f1]=SAinsert_repmat('aBc',5)
% e.g.  [sa2(1:10,1).f1]=SAinsert_repmat({'BaDe'},10)

% disp('pls see the following functions:');
% disp('num2cell_4SAinsert, mat2cell_4SAinsert, cell2cell_4SAinsert ');
if isnumeric(A)
%     cX=num2cell(repmat(A,[N 1]));
    
    % cX=repmat({A},[N 1]);
      cX=repmat({A},[M N]);
   
elseif ischar(A)
    cX=repmat({A},[M N]);
elseif iscell(A) && length(A)==1
    cX=repmat(A,[M N]);
else
    error('can only handle numeric, char, or single element cell')
end
%cX=num2cell(X);
for i=1:length(cX(:))
    varargout(i)=cX(i);
end
end


%% ----- SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool   [AQP_gui.m lines 15158-15582] ----------
function OUT=SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool(pathfnameTP,inp)
% typically called by --> PLS_on_Xfer_PP_or_PP_Xfer
% this function will call --> PLS_inside_PLS_predict_ONLY_MLtool
%-------------------------------------------------------------------------------------------
% use "testset" to optimize models parameters then those parameters applied
% on final Pset (or Validation) set
% "Results4RMSEP" generated here
if false
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IDRC
%-------------
  clear;close all
%   pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\T-mA_P-mC_Test'
%   pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\T-mA_P-mC_Test_Clean'
%   inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\T-mA_P-mC_Val_CleanBI\Atrainpketc_saConc_IDRC_{T-mA_P-mC_Val_CleanBI_pp1-1stDerSGw13}_pp2-SampMncn_nvar88_nsampTT744_nsampP134.mat'

%   pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Test\woCab'
%  inp.pathfnameTP4Val= 'C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{woCabXfer_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'

%           pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Test\GLSstd2'
%  inp.pathfnameTP4Val= 'C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{GLSstd2[alpha1e-6_Val]_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'
 
%           pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Test\LS-GLSw'
%  inp.pathfnameTP4Val= 'C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{LS-GLSw[a1e-3_Val]_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'
   
clear;close all
         
% pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Test\STDgenize'
%  inp.pathfnameTP4Val= 'C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{STDgenize[win5_Val]_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'
% pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Test\LS-PDS'
%  inp.pathfnameTP4Val= 'C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\10TP_Cabxfer_mA_mC\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{LS-PDS_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'

%  pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\4TP_Cabxfer_PDS_mA_mC\Test_PDS'
%  inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\4TP_Cabxfer_PDS_mA_mC\Val_PDS\Atrainpketc_saConc_TPwTrn_TestCabXfer_{PDS_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'
clear;close all
 
%  pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\6TP_Cabxfer_OSC_LS-OSC_mA_mC\Test_LS-OSC'
%  inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\6TP_Cabxfer_OSC_LS-OSC_mA_mC\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{LS-OSC_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'
 
  pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\6TP_Cabxfer_OSC_LS-OSC_mA_mC\Test_OSC'
 inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\MatchGrids_pp-1stDer\1stDerSGw13\6TP_Cabxfer_OSC_LS-OSC_mA_mC\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{OSC_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'

 
 inp.PLSfactor_Pest=''; 
%     inp.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv';
          inp.ModelPara_Opm_Scheme='ModelParaOpmBy-XS_KS101';  % support 3, 4, 5, 8, 12,and 24
    inp.run_SVR_yes=0;
     inp.list_C=[1e-6 1e-5 1e-4  1e-3 1e-2  0.1  1  10 1e2 ];
    %inp.list_C=[1e-6 1e-5 1e-4  1e-3 1e-2  0.1  1  10 1e2 1e3  1e4];

    inp.para_asmc=1;;inp.para_norm=0;inp.run_OL_analysis_Val_yes=0;
    %inp.run_PLS_yes=1;inp.PlsfactorScan=[1:10 12:2:30 ];
        inp.run_PLS_yes=1;inp.PlsfactorScan=[1:20 ];

    inp.TP_scheme='Tall_Pall';   % 'Tall_Peven'
    inp.cList_Ana_to_Run_PLS={'Protein'}
    SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool(pathfnameTP,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;close all

%   pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\T-mA1_P-mC_Test_Clean'
% inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\T-mA1_P-mC_Test_Clean\Atrainpketc_saConc_IDRC_{T-ManufacturerA_Cal_CalSetA1_P-mC_Clean_BI_CH_Test_pp1-1stDerSGw13}pp2-SampMncn_nvar88_nsampT248_nsampP244.mat'
  
pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\T-mA123_P-mC_Test_Clean'
inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\T-mA123_P-mC_Test_Clean\Atrainpketc_saConc_IDRC_{T-ManufacturerA_Cal_CalSetA123_P-mC_Clean_BI_CH_Test_pp1-1stDerSGw13}_nvar88_nsampT744_nsampP244.mat'


inp.PLSfactor_Pest=''; 
%     inp.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv';
          inp.ModelPara_Opm_Scheme='ModelParaOpmBy-XS_KS101';  % support 3, 4, 5, 8, 12,and 24
    inp.run_SVR_yes=0;
     inp.list_C=[1e-6 1e-5 1e-4  1e-3 1e-2  0.1  1  10 1e2 ];
    %inp.list_C=[1e-6 1e-5 1e-4  1e-3 1e-2  0.1  1  10 1e2 1e3  1e4];

    inp.para_asmc=1;;inp.para_norm=0;inp.run_OL_analysis_Val_yes=1;
    %inp.run_PLS_yes=1;inp.PlsfactorScan=[1:10 12:2:30 ];
        inp.run_PLS_yes=1;inp.PlsfactorScan=[1:20 ];

    inp.TP_scheme='Tall_Pall';   % 'Tall_Peven'
    inp.cList_Ana_to_Run_PLS={'Protein'}
    SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool(pathfnameTP,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run with various CabXfer
% 

clear;close all
% pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\LSPDS'
% inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\LSPDS\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{LS-PDS_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134_nsampXS98.mat'

pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\LSGLSw'
inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\LSGLSw\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{LS-GLSw[a1e-3_Val]_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134_nsampXS98.mat'

% pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\LS'
% inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{LS_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134_nsampXS82.mat'
% 
% % pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\woCab'
% % inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\8TP_Cabxfer_fixMismatchXS\Val\Atrainpketc_saConc_TPwTrn_TestCabXfer_{woCabXfer_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134.mat'
% 
% clear;close all
% 
% pathfnameTP='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\LS-PDS_Cabxfer\TP'
% inp.pathfnameTP4Val='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\LS-PDS_Cabxfer\Atrainpketc_saConc_TPwTrn_TestCabXfer_{LS-PDS_KS101_pp1-1stDerSGw13}_[T-mA_P-mC_Val]_nsampT744_nsampP134_nsampXS82.mat'

inp.RMSE_thres4OLs=100;% make this so big that should basically rule out the possibility of any OLs
inp.PLSfactor_Pest=''; 
%     inp.ModelPara_Opm_Scheme='ModelParaOpmBy-Tcv';
          inp.ModelPara_Opm_Scheme='ModelParaOpmBy-XS_KS101';  % support 3, 4, 5, 8, 12,and 24
    inp.run_SVR_yes=0;
     inp.list_C=[1e-6 1e-5 1e-4  1e-3 1e-2  0.1  1  10 1e2 ];
    %inp.list_C=[1e-6 1e-5 1e-4  1e-3 1e-2  0.1  1  10 1e2 1e3  1e4];

    inp.para_asmc=1;;inp.para_norm=0;inp.run_OL_analysis_Val_yes=1;
    %inp.run_PLS_yes=1;inp.PlsfactorScan=[1:10 12:2:30 ];
        inp.run_PLS_yes=1;inp.PlsfactorScan=[1:20 ];

    inp.TP_scheme='Tall_Pall';   % 'Tall_Peven'
    inp.cList_Ana_to_Run_PLS={'Protein'}
    SVR_PLS_Opm_by_Testset_then_AppliedToPset_MLtool(pathfnameTP,inp)


 
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
summary_fig_yes=0;
keep_all_fig_yes=1;
fig_scan_SGw_yes=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp(sprintf('My first input is "%s".' ,inputname(1)))
% disp(sprintf('My second input is "%s".',inputname(2)))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    save ('Begin_SVR_PLS_Opm_by_Testset_then_AppliedToPset.mat', 'inp')
  
    run_PLS_yes=inp.run_PLS_yes;
    run_SVR_yes=inp.run_SVR_yes;
    
    if  run_PLS_yes & run_SVR_yes
        error('PLS and SVR can NOT be run at same time')
    elseif ~run_PLS_yes & ~run_SVR_yes
        error('pls activate to run one of PLS or SVR ')
    elseif run_PLS_yes
        disp_with_border(' running PLS ...');
        regressor='PLS';
    elseif run_SVR_yes
        disp_with_border(' running SVR ...');
        regressor='SVR';
        
    end
    
    
%     inp.run_SVR_yes=0;  % this for running PLS_predict_ONLY(), typically set to 0


if ~isempty(strfind(pathfnameTP,'Atrainpketc_'))
    nfile=1;
    clistfilename={pathfnameTP};
    
else
    try
    [clistfilename, nfile]=fdir_wildcard_wPath(pathfnameTP,'Atrainpketc_');
    catch
      clistfilename='';
      nfile=0;
    end
    
end


   pathfname_ATwsaConc_P= ''
        PlsfactorScan=[1:10 12:2:30 ];
%     inp.cList_Ana_to_Run_PLS={'Pigment'}
    
inp.Tcv_scheme='Leave-OneConc-Out';


inp4SVR=inp;
inp4SVR.cList_Ana_to_Run= inp.cList_Ana_to_Run_PLS;
% inp4SVR.TP_scheme='Tall_Pall';   % 'Tall_Peven'
inp4PLS=inp;
inp4PLS.cList_Ana_to_Run= inp.cList_Ana_to_Run_PLS;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if it is doing Tcv and all Tset in clistfilename are same, 
% then only do hat once
if strcmp(inp.ModelPara_Opm_Scheme,'ModelParaOpmBy-Tcv')
    Tcv_SameTset_yes=0;
    for ifile=1:nfile
        try
        L_ii=load(clistfilename{ifile});
        catch
            clistfilename=clistfilename{ifile};
            L_ii=load(clistfilename{ifile});
        end
        AT_i=L_ii.Atrainpk;
        
        if ifile>1
            if isSAME_2Matrix(AT_i,AT_prev)
                Tcv_SameTset_yes=1;
            else
                Tcv_SameTset_yes=0;
                break
            end
        end
        
        AT_prev=AT_i;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ALL_out_PLS_or_SVR=[];
for ifile=1:nfile
    if ~keep_all_fig_yes
        close all
    end
    if ifile>1
        try
            if run_SVR_yes
                inp4SVR.Tcv_SameTset_yes=Tcv_SameTset_yes;
                inp4SVR.outSVR_Tcv_prev=out_SVR.outSVR_Tcv;
            end
            
            if run_PLS_yes
                inp4PLS.Tcv_SameTset_yes=Tcv_SameTset_yes;
                inp4PLS.outPLS_Tcv_prev=out_PLS.outPLS_Tcv;
            end
            
        catch
            if run_SVR_yes
                inp4SVR.Tcv_SameTset_yes=0;
                inp4SVR.outSVR_Tcv_prev='';
            end
            
            if run_PLS_yes
                inp4PLS.Tcv_SameTset_yes=0;
                inp4PLS.outPLS_Tcv_prev='';
            end
        end
    else
        if run_SVR_yes
            inp4SVR.Tcv_SameTset_yes=0;
        end
        if run_PLS_yes
            inp4PLS.Tcv_SameTset_yes=0;
        end
    end
    
    
    try
        close( out_PLS.hf_PLS );
    end
    %---- Run PLS (and generate results to be added to SVR below)
    %     pathfnameTP= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\SGw5\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-SGw5_pp2-SampMncn_nsampT183_nsampP15.mat'
    %pathfnameTP= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\1stDer\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT183_nsampP15.mat'
    pathfnameTP_ifile=clistfilename{ifile};
    %    pathfname_ATwsaConc_P= ''
    %     inp.run_SVR_yes=0;
    %         PlsfactorScan=[1:10 12:2:30 ];
    % %     inp.cList_Ana_to_Run_PLS={'Pigment'}
    %
    % inp.Tcv_scheme='Leave-OneConc-Out';
    %     if run_PLS_yes
    %         PlsfactorScan= inp.PlsfactorScan;
    %         [Yest_bo_Tcv RMSE_bo_Tcv CV_bo_Tcv out_PLS]=PLS_predict_ONLY(pathfnameTP_ifile,pathfname_ATwsaConc_P,PlsfactorScan,inp);
    %     else
    %         RMSE_bo_Tcv=NaN;
    %         out_PLS='';
    %     end
    
    %------ Run PLS (with results of PLS added to same figure)
    % this resemble the following section on SVR, i.e.SVR_inside_PLS_predict_ONLY()
    %
    
    if run_PLS_yes
        %inp4PLS.RMSE_bo_Tcv=RMSE_bo_Tcv;
        inp4PLS.handles=inp.handles;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % temporary hard-coded this for "CS_sugarcane_MicroNIR_4Cmp_wo30XS_1st21_nsamp21.xlsx"
        %     inp4PLS.PlsfactorScan=inp4PLS.PlsfactorScan(find( inp4PLS.PlsfactorScan<=14));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        out_PLS=PLS_inside_PLS_predict_ONLY_MLtool(pathfnameTP_ifile,inp4PLS);
    end
    
    %--------------------------------------------------------------------------------------------
    if run_SVR_yes
        %------ Run SVR (with results of PLS added to same figure)
        %inp4SVR.RMSE_bo_Tcv=RMSE_bo_Tcv;
        inp4SVR.RMSE_bo_Tcv=NaN;
        inp4SVR.para_norm=inp.para_norm;
        inp4SVR.para_asmc=inp.para_asmc;;
        
        % pathfnameTP='C:\work\JDSU\SVR_opm\TP_XU_Pigment\SGw5\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-SGw5_pp2-SampMncn_nsampT183_nsampP15.mat'
        %    pathfnameTP='C:\work\JDSU\SVR_opm\TP_XU_Pigment\1stDer\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT183_nsampP15.mat'
        out_SVR=SVR_inside_PLS_predict_ONLY(pathfnameTP_ifile,inp4SVR)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    warning off
    sSM_P=strrep(find_keyword_between_markers( fileparts_name_ext(pathfnameTP_ifile),'_P-S1-','_'),'00','');
    warning on
    
    if run_PLS_yes
        fname_ifile=['PLS__results_P-Val_',sSM_P,'_',inp4PLS.ModelPara_Opm_Scheme,'.mat'];
        try
            out_PLS_or_SVR=out_PLS.saPLS_Results_Val;
        catch
            out_PLS_or_SVR=out_PLS;
        end
    elseif run_SVR_yes
        fname_ifile=['SVR__results_P-',sSM_P,'_',inp4PLS.ModelPara_Opm_Scheme,'.mat'];
        out_PLS_or_SVR=out_SVR;
    end
    
    try
        save(fname_ifile,'-struct','out_PLS_or_SVR');
        disp([fname_ifile,' has been saved !']);
    end
    
    % show P-Val RMSE and OpmPLSfactor on GUI
    try
       
        OUT.Results4sRMSE_Val=roundns(out_PLS_or_SVR.RMSE,4);
        OUT.Results4sOpmPLSfactor=roundns(out_PLS_or_SVR.PLSfactor,0);
         OUT.Results4RMSEP=out_PLS_or_SVR.RMSE;  % "Results4RMSEP" generated here
    catch
        OUT.Results4sRMSE_Val=roundns(out_PLS_or_SVR.RMSE_PLS_Opm,4);
        OUT.Results4sOpmPLSfactor=roundns(out_PLS_or_SVR.PLSfactor_Opm,0);;
         OUT.Results4RMSEP=out_PLS_or_SVR.RMSE; % "Results4RMSEP" generated here
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    out_PLS_or_SVR.pathfnameTP_ifile=pathfnameTP_ifile;
    ALL_out_PLS_or_SVR=[ALL_out_PLS_or_SVR;out_PLS_or_SVR];
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
if nfile>0
fname_ALL_file=['PLS_or_SVR__results_Nfile',num2str(nfile),'_',inp4PLS.ModelPara_Opm_Scheme,'.mat'];
saResults_ALL.ALL_out_PLS_or_SVR=ALL_out_PLS_or_SVR;
save(fname_ALL_file,'-struct','saResults_ALL');
disp([fname_ALL_file,' has been saved']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list_curly=arrayfun(@(x) find_keyword_between_markers( x.pathfnameTP_ifile,'{','}'),ALL_out_PLS_or_SVR,'un',0);
% list_RMSE=arrayfun(@(x) x.RMSE_PLS_Opm,ALL_out_PLS_or_SVR);

try
list_RMSE=arrayfun(@(x) x.RMSE_PLS_Opm,ALL_out_PLS_or_SVR);
catch
    try
list_RMSE=arrayfun(@(x) x.RMSE_SVR_Opm,ALL_out_PLS_or_SVR);
    catch
     list_RMSE='';   
    end
    
end


% figure;hold on;
% plot(list_RMSE,'k-*','linewidth',2);
% hXL = rotateXLabels_CH( gca,-45,strrep(list_curly,'_','\_'));
% ylabel('RMSE');
% stit1=strrep(find_lastfolder(pathfnameTP),'_','\_');
% stit_perf=[regressor];
% title({[stit1,'  ',strrep(inp4PLS.ModelPara_Opm_Scheme,'_','\_')];[stit_perf]});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% show RMSE vs SGw (in 1stDer)
if fig_scan_SGw_yes
list_SGw=arrayfun(@(x) find_keynumber_numeric_AFTER_marker( x.pathfnameTP_ifile,'pp1-1stDerSGw'),ALL_out_PLS_or_SVR);
[list_SGw_sort idx_sort_SGw]=sort(list_SGw);
ALL_out_PLS_or_SVR_sortbySGw=ALL_out_PLS_or_SVR(idx_sort_SGw);
try
list_RMSE_sort=arrayfun(@(x) x.RMSE_PLS_Opm,ALL_out_PLS_or_SVR_sortbySGw);
catch
    try
list_RMSE_sort=arrayfun(@(x) x.RMSE_SVR_Opm,ALL_out_PLS_or_SVR_sortbySGw);
    catch
  list_RMSE_sort='';      
    end
    
end

% show summary of more than one TP sets
if summary_fig_yes
figure;hold on;
set(gcf,'position',[ 643.4000  354.6000  852.8000  420.0000]);
plot(list_SGw_sort,list_RMSE_sort,'k-*','linewidth',2);
[RMSE_OpmSGw loc_Opm_SGw]=min(list_RMSE_sort);
SGw_Opm=list_SGw_sort(loc_Opm_SGw);
plot(SGw_Opm,RMSE_OpmSGw,'gO','markersize',12,'markerfacecolor','g')
ylabel('RMSE');xlabel('SGw');

stit1=strrep(find_lastfolder(pathfnameTP),'_','\_');
stit_perf=[regressor,'   ','RMSE\_Opm = ',roundns(RMSE_OpmSGw,3),'   Opm SGw = ',num2str(SGw_Opm)];
title({[stit1,'  ',strrep(inp4PLS.ModelPara_Opm_Scheme,'_','\_')];[stit_perf]});
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
 save ('finish_SVR_PLS_Opm_by_Testset_then_AppliedToPset.mat', 'out_SVR')
catch
   
 save ('finish_SVR_PLS_Opm_by_Testset_then_AppliedToPset.mat', 'out_PLS')
    
end














disp('finish SVR_PLS_Opm_by_Testset_then_AppliedToPset');
end


%% ----- SVR_Tcv   [AQP_gui.m lines 15586-15643] ---------------------------------------------------
function out=SVR_Tcv(X,Y,cSampleName,inp)
if false
    
    L=load('Testing_SVR_Tcv_T-Bruker-SingleScanHiRes_P-ES17_SGw5_DX_1_2_S1-550.mat')
    inp.Tcv_scheme='Leave-OneConc-Out';
    inp.para_norm=0;
    inp.para_asmc=1;
    inp.list_C=[1e-6 1e-5 1e-4 1e-3 0.01 0.1 1 10 100];
    
    % if run_SVR_yes
    inp.ktype='SVRbyLS';   %  'SVRbyLS'  'linear'
    
    out=SVR_Tcv(L.X_iAna_T,L.Y_iAna_T,L.cSampleName_T,inp)
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ModelParaScan=inp.list_C;

inpTcvIndv=inp;
OUT_Tcv=[];
for irun=1:length(ModelParaScan)
    
    inpTcvIndv.ModelPara=ModelParaScan(irun);
    %inpTcv.PlsfactorScan=PlsfactorScan;
    % out=prep_Spertula_Quant( pathfname_Conc_Tab,pathfname_UXmat,inp);
    out_Tcv=SVR_Tcv_indvRun(X, Y,cSampleName,inpTcvIndv);
    OUT_Tcv=[OUT_Tcv;out_Tcv];
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
all_C=ModelParaScan;
all_RMSE_SVR=arrayfun(@(x) x.RMSE,OUT_Tcv);
[minRMSE_SVR loc_Opm_SVR]=min(all_RMSE_SVR);
RMSE_SVR_Opm=minRMSE_SVR;
C_SVR_Opm=all_C(loc_Opm_SVR);

plot(log10(all_C),all_RMSE_SVR,'k-*','linewidth',2)
plot(log10(C_SVR_Opm),RMSE_SVR_Opm,'gO','markersize',10);
xlabel('log10 C');
ylabel('RMSE by SVR');

ctit1={['SVR Tcv by ',inp.Tcv_scheme]};
ctit2={['Opm C =',num2str(C_SVR_Opm),'  RMSE=',roundns(RMSE_SVR_Opm,3)]};
title([ctit1;ctit2]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.OUT_Tcv=OUT_Tcv;
out.C_SVR_Opm=C_SVR_Opm;
out.RMSE_SVR_Opm=RMSE_SVR_Opm;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('finish SVR_Tcv')
end


%% ----- SVR_Tcv_indvRun   [AQP_gui.m lines 15647-15826] -------------------------------------------
function out=SVR_Tcv_indvRun(X,Y,cSampleName,inp)
% modified from PLS_Tcv()
if false
    
    inp.Tcv_scheme='Leave-OneConc-Out';
         inp.stitle=CurAna;
    out=SVR_Tcv_indvRun(X,Y,cSampleName,inp);
    
end
% plsregress(X,Y,ncomp,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try cSampleName=cell2mat_ccstr2cstr(cSampleName);end

CurModelPara= inp.ModelPara	;   % this will be based on "C" or "gamma" etc
% KPplus=inp.KPplus;
Tcv_scheme=inp.Tcv_scheme;
   % case 'Leave-OneReplicate-Out'
        
        
        
        
   switch Tcv_scheme

           
       case 'Leave-OneConc-Out'
           QSample=unique(cSampleName);
           QSample_sortnat=sortnat(QSample);
           nSample=length(QSample);
           loc_all=col_always([1:length(Y)]);
           Yest_all=repmat(NaN,size(loc_all));
           
           List_OpmPLSfactor_iQ=[];
           for iQS=1:nSample
               loc_P_iQS=strmatch(QSample_sortnat{iQS},cSampleName,'exact');
               loc_T_iQS=setdiff(loc_all,loc_P_iQS);
               
               X_T_iQS=X(loc_T_iQS,:);
               Y_T_iQS=Y(loc_T_iQS,:);
               
               X_P_iQS=X(loc_P_iQS,:);
               Y_P_iQS=Y(loc_P_iQS,:);

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % based on PLS
%                               [xl_iQS,yl_iQS,xs_iQS,ys_iQS,beta_iQS,pctvar_iQS,mse_iQS]...
%                    = plsregress(X_T_iQS,Y_T_iQS,PLSfactor);
%                               Yest_iQS = [ones(size(X_P_iQS,1),1) X_P_iQS]*beta_iQS;

               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % based on SVR
               ktype=inp.ktype;
               para_norm=inp.para_norm;
               para_asmc=inp.para_asmc;
               
               switch  ktype
                   case 'linear'
                       sKtype=' -t 0 ';
                   case  'rbf'
                       sKtype=' -t 2 ';
                   case 'SVRbyLS'
                       sKtype=' -t 0 ';
               end
               
               % para_norm=0;
               % para_asmc=1;
               switch para_asmc
                   case 1
                       sasmc_SVR='_autoscale';
                   case 2
                       sasmc_SVR='_meancenter';
                       
                   otherwise
                       error('para_asmc Not supported !!!')
               end
               
               [X_iAna_T_normasmc,X_iAna_P_normasmc,asmc_mean_std]=normasmc_trainpk_pred(X_T_iQS,X_P_iQS,para_norm,para_asmc);
               
               % X_iAna_T_normasmc=sparse(X_iAna_T_normasmc);
               % X_iAna_P_normasmc=sparse(X_iAna_P_normasmc);
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % from libsvm website:
               % options:
               % -s svm_type : set type of SVM (default 0)
               % 	0 -- C-SVC
               % 	1 -- nu-SVC
               % 	2 -- one-class SVM
               % 	3 -- epsilon-SVR
               % 	4 -- nu-SVR
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % list_C=[0.01 0.1 1 10 100];
%                saSVR_Results=[];
%                all_Yest_SVR=[];
%                for iC=1:length(list_C)
                   if strcmp(ktype,'SVRbyLS')
                       % epsilon-SVR
                       %model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 3 ', sKtype,' -p ' num2str(0.1) ' -c ' num2str(CurModelPara)]);
                       model_SVR = svmtrain_MEX(Y_T_iQS,X_iAna_T_normasmc,['-s 3 ', sKtype,' -p ' num2str(0.1) ' -c ' num2str(CurModelPara)]);

                   else
                       % nu-SVR
                       model_SVR = svmtrain_MEX(Y_T_iQS,X_iAna_T_normasmc,['-s 4 ', sKtype,' -n ' num2str(1/2) ' -c ' num2str(1)]);
                   end
                   
                   
                   %Yest_SVR=svmpredict_MEX(Y_iAna_P,X_iAna_P_normasmc,model_SVR);
                   Yest_SVR=svmpredict_MEX(Y_P_iQS,X_iAna_P_normasmc,model_SVR);

                   
                   Yest_iQS=Yest_SVR;
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   Yest_all(loc_P_iQS,:)=Yest_iQS;
%                end
           end
           
       otherwise
           error('Tcv scheme NOT supported')
   end
   
   
   if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
    RMSE=RMS_error_woNaN(Yest_all,Y);
    CV=100*RMS_error_woNaN(Yest_all,Y)/mean(Y);
   end

if false
                figure;hold on
                plot(Y,Yest_all,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE=roundns(RMS_error_woNaN(Yest_all,Y),2);
                sCV=roundns(100*RMS_error_woNaN(Yest_all,Y)/mean(Y),2);
                title({inp.stitle;['mean Opm PLS factor(KP+',num2str(KPplus),') =',num2str(mean(List_OpmPLSfactor_iQ(:,2))),'   RMSE=',sRMSE,'    CV=',sCV,'%']});
%                 'Opm PLS factor(KP+',num2str(KPplus),') =',num2str(OpmPLSfactor)
                xlabel('Y True Value')
                ylabel('Y Estimated');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Self-Validation 
           if false
               [xl_Self,yl_Self,xs_Self,ys_Self,beta_Self,pctvar_Self,mse_Self]...
                   = plsregress(X,Y,PLSfactor,'CV',PLSfactor);

                YFitted = [ones(size(X,1),1) X]*beta_Self;
                
                figure;hold on
                plot(Y,YFitted,'o');
                ax_now=axis;
                min_45deg=min(ax_now([1 3]));
                max_45deg=min(ax_now([2 4]));
                
                plot([min_45deg max_45deg],[min_45deg max_45deg],'b:')                  % Theoretical 45� regression line
                sRMSE_Self=roundns(RMS_error_woNaN(YFitted,Y),2);
                sCV_Self=roundns(100*RMS_error_woNaN(YFitted,Y)/mean(Y),2);
                title({inp.stitle;['PLS factor =',num2str(PLSfactor),'   RMSE Self=',sRMSE_Self,'    CV Self=',sCV_Self,'%']});
                
                xlabel('Y True Value')
                ylabel('Y Estimated');
             end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    out.OpmPLSfactor_RVIL=OpmPLSfactor_RVIL;
end
 if ~strcmp(Tcv_scheme(3:end),'Residual-Variance-Increase-Limit')
out.List_OpmPLSfactor=List_OpmPLSfactor_iQ;
out.Yest_all=Yest_all;
out.RMSE=RMSE;
out.CV=CV;
% out.KPplus=KPplus;
% out.meanOpmPLSfactor  = roundns(mean(List_OpmPLSfactor_iQ(:,2)),2);
% out.sCV_Self=sCV_Self;
% out.PLSfactor=PLSfactor;
 end
end


%% ----- SVR_indv   [AQP_gui.m lines 15830-15910] --------------------------------------------------
function saSVR_Results=SVR_indv(X_iAna_T,X_iAna_P,Y_iAna_T,Y_iAna_P,inp)


% run_SVR_yes=1;
para_norm=inp.para_norm;
para_asmc=inp.para_asmc;
 list_C=inp.list_C;

% if run_SVR_yes
ktype=inp.ktype;   %  'SVRbyLS'  'linear'
% ktype='rbf';

switch  ktype
    case 'linear'
        sKtype=' -t 0 ';
        
    case  'rbf'
        sKtype=' -t 2 ';
        
    case 'SVRbyLS'
        
        sKtype=' -t 0 ';
        
        
end

% para_norm=0;
% para_asmc=1;
switch para_asmc
    case 1
        sasmc_SVR='_autoscale';
    case 2
        sasmc_SVR='_meancenter';
        
    otherwise
        error('para_asmc Not supported !!!')
end

[X_iAna_T_normasmc,X_iAna_P_normasmc,asmc_mean_std]=normasmc_trainpk_pred(X_iAna_T,X_iAna_P,para_norm,para_asmc);

% X_iAna_T_normasmc=sparse(X_iAna_T_normasmc);
% X_iAna_P_normasmc=sparse(X_iAna_P_normasmc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from libsvm website:
% options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC
% 	1 -- nu-SVC
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR
% 	4 -- nu-SVR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list_C=[0.01 0.1 1 10 100];
saSVR_Results=[];
all_Yest_SVR=[];
for iC=1:length(list_C)
    if strcmp(ktype,'SVRbyLS')
        % epsilon-SVR
        model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 3 ', sKtype,' -p ' num2str(0.1) ' -c ' num2str(list_C(iC))]);
        
    else
        % nu-SVR
        model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 4 ', sKtype,' -n ' num2str(1/2) ' -c ' num2str(1)]);
    end
    
    
    Yest_SVR=svmpredict_MEX(Y_iAna_P,X_iAna_P_normasmc,model_SVR);
    all_Yest_SVR=[all_Yest_SVR,Yest_SVR];
    
    
    
    RMSE_SVR= RMS_error_woNaN(Yest_SVR,Y_iAna_P);
    eaSVR_Results.C=list_C(iC);
    eaSVR_Results.RMSE=RMSE_SVR;
    eaSVR_Results.Yest_SVR=Yest_SVR;
    eaSVR_Results.Y_iAna_P=Y_iAna_P;
    
    saSVR_Results=[saSVR_Results;eaSVR_Results];
    
end
end


%% ----- SVR_inside_PLS_predict_ONLY   [AQP_gui.m lines 15914-16350] -------------------------------
function out=SVR_inside_PLS_predict_ONLY(pathfnameTP,inp4SVR)
% this was extracted from PLS_predict_ONLY() 
% PLS_predict_ONLY() has typically been called by BatchRun_CrossUnits_PLS_predict_ONLY_v2(pathXU,Inp)
if false
    
    
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    clear;close all
 %---- Run PLS (and generate results to be added to SVR below)  
    pathfnameTP= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\SGw5\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-SGw5_pp2-SampMncn_nsampT183_nsampP15.mat'
   %pathfnameTP= 'C:\work\JDSU\SVR_opm\TP_XU_Pigment\1stDer\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT183_nsampP15.mat'
pathfname_ATwsaConc_P= ''
    inp.run_SVR_yes=0;
        PlsfactorScan=[1:10 12:2:30 ];
    inp.cList_Ana_to_Run_PLS={'Pigment'}
    
inp.Tcv_scheme='Leave-OneConc-Out';
    [Yest_bo_Tcv RMSE_bo_Tcv CV_bo_Tcv out]=PLS_predict_ONLY(pathfnameTP,pathfname_ATwsaConc_P,PlsfactorScan,inp);
%------ Run SVR (with results of PLS added to same figure)
    inp4SVR.RMSE_bo_Tcv=RMSE_bo_Tcv;
   % pathfnameTP='C:\work\JDSU\SVR_opm\TP_XU_Pigment\SGw5\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-SGw5_pp2-SampMncn_nsampT183_nsampP15.mat'
%    pathfnameTP='C:\work\JDSU\SVR_opm\TP_XU_Pigment\1stDer\Atrainpketc_saConc_Cargill_T-(S1-194)_P-(S1-471)_Pigment_pp1-1stDerSGDiederick_pp2-SampMncn_nsampT183_nsampP15.mat'
    out=SVR_inside_PLS_predict_ONLY(pathfnameTP,inp4SVR)
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


L=load(pathfnameTP);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch inp4SVR.TP_scheme
    case 'Tall_P_1_4'
            X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[1:4:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);
    case 'Tall_P_1_100'
            X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[1:100:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);

    
    
    case 'Tall_Podd'
        X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[1:2:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);
    case 'Tall_Peven'
        X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        loc4P=[2:2:length(L.Apred(:,1))];
        X_iAna_P=L.Apred(loc4P,:);
        Y_iAna_P_all=cat(1,L.PLS.Pset.saConc.Conc);
        Y_iAna_P= Y_iAna_P_all(loc4P);
        
    case 'Tall_Pall'
        X_iAna_T=L.Atrainpk;
        Y_iAna_T=cat(1,L.PLS.Tset.saConc.Conc);
        
        X_iAna_P=L.Apred;
        Y_iAna_P=cat(1,L.PLS.Pset.saConc.Conc);
        
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inp4Tcv.Tcv_scheme='Leave-OneConc-Out';
    
    inp4Tcv.para_norm=inp4SVR.para_norm;
    inp4Tcv.para_asmc=inp4SVR.para_asmc;;
    
    
    inp4Tcv.list_C=inp4SVR.list_C;
    %%%%%%%%%%
    inp4Tcv.ktype='SVRbyLS';   %  'SVRbyLS'  'linear'
    CurAnaName=inp4SVR.cList_Ana_to_Run{1};

switch inp4SVR.ModelPara_Opm_Scheme
    case 'ModelParaOpmBy-Tcv'
     % Optimization of SVR parameters by Tcv (Leave-One-Conc-Out')
%     inp4Tcv.Tcv_scheme='Leave-OneConc-Out';
%     inp4Tcv.para_norm=0;
%     inp4Tcv.para_asmc=1;
%     inp4Tcv.list_C=inp4SVR.list_C;
%     %%%%%%%%%%
%     inp4Tcv.ktype='SVRbyLS';   %  'SVRbyLS'  'linear'
%     CurAnaName=inp4SVR.cList_Ana_to_Run{1};
    [X_iAna_T_Tcv Y_iAna_T_Tcv  cSampleName_T_Tcv]=SVR_inside_PLS_predict_ONLY__saConc2XY(L.PLS.Tset.saConc,CurAnaName);
    if ~inp4SVR.Tcv_SameTset_yes
        outSVR_Tcv=SVR_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv);
%         outSVR_Tcv.OUT_Tcv;
%         outSVR_Tcv.C_SVR_Opm;
%         outSVR_Tcv.RMSE_SVR_Opm;
    else
%         outSVR_Tcv.C_SVR_Opm=NaN;
%         outSVR_Tcv.RMSE_SVR_Opm=NaN;
       outSVR_Tcv.C_SVR_Opm= inp4SVR.outSVR_Tcv_prev.C_SVR_Opm;
        
        
    end
    case {'ModelParaOpmBy-XS_KS1','ModelParaOpmBy-XS_KS2','ModelParaOpmBy-XS_KS3','ModelParaOpmBy-XS_KS4','ModelParaOpmBy-XS_KS5','ModelParaOpmBy-XS_KS6', 'ModelParaOpmBy-XS_KS8', 'ModelParaOpmBy-XS_KS12', 'ModelParaOpmBy-XS_KS24', 'ModelParaOpmBy-XS_KS25', 'ModelParaOpmBy-XS_KS36', 'ModelParaOpmBy-XS_KS40', 'ModelParaOpmBy-XS_KS48', 'ModelParaOpmBy-XS_KS101'   }  
        
            [X_iAna_P Y_iAna_P  cSampleName_P]=SVR_inside_PLS_predict_ONLY__saConc2XY(L.PLS.Pset.saConc,CurAnaName);

        
        
        nKS=find_keynumber_numeric_AFTER_marker (inp4SVR.ModelPara_Opm_Scheme,'KS');
        
%         allC_T=arrayfun(@(x) x.Conc,LT.saConc);
%         [qC_T nC_T]=unique_count(allC_T);
%         [idxTrn_T] = find(kennardstone( qC_T, nKS));
        
        allC_P=arrayfun(@(x) x.Conc,L.PLS.Pset.saConc);
        [qC_P nC_P]=unique_count(allC_P);
        try
            [idxTrn_P] = find(kennardstone( qC_P, nKS));
        catch
            try
                [idxTrn_P] = KennardStone( qC_P, nKS);
            catch
                
                
%                 if is_odd(length(qC_P))
%                     Conc_KSpick_P= median(qC_P);
%                     idxTrn_P=find(qC_P==Conc_KSpick_P);
%                 else
%                     Conc_KSpick_P= median(qC_P);
%                     idxTrn_P=find(qC_P==Conc_KSpick_P);
%                     if isempty(idxTrn_P)
%                         [minDif locminDif]=     min(abs(qC_P-Conc_KSpick_P));
%                         idxTrn_P= locminDif;
%                     end
%                 end
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % deal with KSn=1 or KSn=2
                if nKS==1 || nKS==2
                    switch nKS
                        case 1
%                             Conc_KSpick_P= median(qC_P);
%                             idxTrn_P=find(qC_P==Conc_KSpick_P);
%                             
                            if is_odd(length(qC_P))
                                Conc_KSpick_P= median(qC_P);
                                idxTrn_P=find(qC_P==Conc_KSpick_P);
                            else
                                Conc_KSpick_P= median(qC_P);
                                idxTrn_P=find(qC_P==Conc_KSpick_P);
                                if isempty(idxTrn_P)
                                    [minDif locminDif]=     min(abs(qC_P-Conc_KSpick_P));
                                    idxTrn_P= locminDif;
                                end
                            end
                            
                        case 2
                            Conc_KSpick_P= [min(qC_P);max(qC_P)];
                             idxTrn_P=find_belong2subgrp(qC_P,Conc_KSpick_P);
                    end
                else
                    error('can not handle this case, KSn is not 1 or 2 and still can not run KennardStone ?')
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

                
                
                
            end
        end
        Conc_KSpick_P= qC_P(idxTrn_P);
        idx_saConcSampleName_KS_P= arrayfun(@(x) SVR_inside_PLS_predict_ONLY__isKSpick(x,Conc_KSpick_P),L.PLS.Pset.saConc);
        clist_OddEvenConc_P=unique(L.AclabelP(idx_saConcSampleName_KS_P));
        locXP=find(cellfun(@(x) ~isempty(strmatch(x,clist_OddEvenConc_P,'exact')),L.AclabelP));
        
        X_iAna_P_XS= X_iAna_P(locXP,:);
        Y_iAna_P_XS = Y_iAna_P(locXP,:);
        % cSampleName_P_XS=cSampleName_P(locXP,:);
%         unique(cellfun(@(x) x{1},cSampleName_P_XS,'un',0))
saSVR_Results_XS=SVR_indv(X_iAna_T,X_iAna_P_XS,Y_iAna_T,Y_iAna_P_XS,inp4Tcv);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;hold on;
all_C_XS=arrayfun(@(x) x.C,saSVR_Results_XS);
all_RMSE_SVR_XS=arrayfun(@(x) x.RMSE,saSVR_Results_XS);
[RMSE_SVR_min_XS loc_minRMSE_SVR_XS]=min(all_RMSE_SVR_XS);
% RMSE_SVR_min=minRMSE_SVR;

C_SVR_min_XS=all_C_XS(loc_minRMSE_SVR_XS);

plot(log10(all_C_XS),all_RMSE_SVR_XS,'k-*','linewidth',2);
plot(log10(C_SVR_min_XS),RMSE_SVR_min_XS,'gO','markersize',10,'markerfacecolor','g');

ctit11={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
ctit33={[strrep(inp4SVR.ModelPara_Opm_Scheme,'_','\_'),'   C\_opm =',num2str(C_SVR_min_XS),'  RMSE=',roundns(RMSE_SVR_min_XS,3)]};
title([ctit11;ctit33]);


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch inp4SVR.ModelPara_Opm_Scheme
    case 'ModelParaOpmBy-Tcv'
        C_SVR_Opm=outSVR_Tcv.C_SVR_Opm;
    case {'ModelParaOpmBy-XS_KS1','ModelParaOpmBy-XS_KS2','ModelParaOpmBy-XS_KS3','ModelParaOpmBy-XS_KS4','ModelParaOpmBy-XS_KS5','ModelParaOpmBy-XS_KS6', 'ModelParaOpmBy-XS_KS8', 'ModelParaOpmBy-XS_KS12', 'ModelParaOpmBy-XS_KS24', 'ModelParaOpmBy-XS_KS25', 'ModelParaOpmBy-XS_KS36', 'ModelParaOpmBy-XS_KS40', 'ModelParaOpmBy-XS_KS48' , 'ModelParaOpmBy-XS_KS101'  } 
        C_SVR_Opm=C_SVR_min_XS;
end
    
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run_SVR_yes=1;
para_norm=inp4Tcv.para_norm;
para_asmc=inp4Tcv.para_asmc;
 list_C=inp4SVR.list_C;

% if run_SVR_yes
ktype=inp4Tcv.ktype;   %  'SVRbyLS'  'linear'
% ktype='rbf';

switch  ktype
    case 'linear'
        sKtype=' -t 0 ';
        
    case  'rbf'
        sKtype=' -t 2 ';
        
    case 'SVRbyLS'
        
        sKtype=' -t 0 ';
        
        
end

% para_norm=0;
% para_asmc=1;
switch para_asmc
    case 1
        sasmc_SVR='_autoscale';
    case 2
        sasmc_SVR='_meancenter';
        
    otherwise
        error('para_asmc Not supported !!!')
end

[X_iAna_T_normasmc,X_iAna_P_normasmc,asmc_mean_std]=normasmc_trainpk_pred(X_iAna_T,X_iAna_P,para_norm,para_asmc);

% X_iAna_T_normasmc=sparse(X_iAna_T_normasmc);
% X_iAna_P_normasmc=sparse(X_iAna_P_normasmc);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from libsvm website:
% options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC
% 	1 -- nu-SVC
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR
% 	4 -- nu-SVR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list_C=[0.01 0.1 1 10 100];
saSVR_Results=[];
all_Yest_SVR=[];
for iC=1:length(list_C)
    if strcmp(ktype,'SVRbyLS')
        % epsilon-SVR
        model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 3 ', sKtype,' -p ' num2str(0.1) ' -c ' num2str(list_C(iC))]);
        
    else
        % nu-SVR
        model_SVR = svmtrain_MEX(Y_iAna_T,X_iAna_T_normasmc,['-s 4 ', sKtype,' -n ' num2str(1/2) ' -c ' num2str(1)]);
    end
    
    
    Yest_SVR=svmpredict_MEX(Y_iAna_P,X_iAna_P_normasmc,model_SVR);
    all_Yest_SVR=[all_Yest_SVR,Yest_SVR];
    
    
    
    RMSE_SVR= RMS_error_woNaN(Yest_SVR,Y_iAna_P);
    eaSVR_Results.C=list_C(iC);
    eaSVR_Results.RMSE=RMSE_SVR;
    eaSVR_Results.Yest_SVR=Yest_SVR;
    eaSVR_Results.Y_iAna_P=Y_iAna_P;
    
    saSVR_Results=[saSVR_Results;eaSVR_Results];
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    C_Pest=   inp4SVR.C_Pest;
    loc_saResults=find(arrayfun(@(x) x.C==C_Pest,saSVR_Results));
    sa_Results_out=saSVR_Results(loc_saResults);
    fname_outPest=strrep(fileparts_name_ext(pathfnameTP),'Atrainpk',['Test_Pest_C',num2str(C_Pest),'_Atrainpk']);
    save(fname_outPest,'-struct','sa_Results_out');
    disp([fname_outPest,' has been saved']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inp4V=inp4Tcv;
    inp4V.list_C=C_Pest;
    if false
        X_iAna_V=X_iAna_P;   % tmp testing only
        Y_iAna_V=Y_iAna_P;   % tmp testing only
        saSVR_Results_Val=SVR_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V);% tmp testing only
    end
    
    %     if false
    %         pathfnameTP4Val=inp4SVR.pathfnameTP4Val;
    % %         L_Val= load('C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mA_mB_P-mC_Val\Atrainpketc_saConc_IDRC_{T-ManufacturerA_Cal_CalSetA123_P-mC_Val_pp1-1stDerSGw13}_nvar88_nsampTT744_nsampP150.mat')
    %        L_Val= load(pathfnameTP4Val);
    %
    %         X_iAna_V=L_Val.Apred;   % for Val set
    %         Y_iAna_V=cat(1,L_Val.PLS.Pset.saConc.Conc);   % for Val set
    %         saSVR_Results_Val=SVR_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V);
    %
    %
    %         fname_outPest4V=strrep(fileparts_name_ext(pathfnameTP4Val),'Atrainpk',['Val_Pest_C',num2str(C_Pest),'_Atrainpk']);
    %
    %         fname_outPest4V=strrep_keyword_between_markers(fname_outPest4V,'nsampP','.mat',[num2str(length(Y_iAna_V))]);
    %
    %         save(fname_outPest4V,'-struct','saSVR_Results_Val');
    %         disp([fname_outPest4V,' has been saved']);
    %
    %     end
    
    try
        pathfnameTP4Val=inp4SVR.pathfnameTP4Val;
        %         L_Val= load('C:\work\JDSU\IDRC_ShootOut\ATsaConc_Match_wvl\AB123ALL_1stDerSGw13\TP_T-mA_mB_P-mC_Val\Atrainpketc_saConc_IDRC_{T-ManufacturerA_Cal_CalSetA123_P-mC_Val_pp1-1stDerSGw13}_nvar88_nsampTT744_nsampP150.mat')
        L_Val= load(pathfnameTP4Val);
        
        X_iAna_V=L_Val.Apred;   % for Val set
        Y_iAna_V=cat(1,L_Val.PLS.Pset.saConc.Conc);   % for Val set
        saSVR_Results_Val=SVR_indv(X_iAna_T,X_iAna_V,Y_iAna_T,Y_iAna_V,inp4V);
        
        
        fname_outPest4V=strrep(fileparts_name_ext(pathfnameTP4Val),'Atrainpk',['Val_Pest_C',num2str(C_Pest),'_Atrainpk']);
        
        fname_outPest4V=strrep_keyword_between_markers(fname_outPest4V,'nsampP','.mat',[num2str(length(Y_iAna_V))]);
        
        save(fname_outPest4V,'-struct','saSVR_Results_Val');
        disp([fname_outPest4V,' has been saved']);
        
        
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CV_SVR= 100*RMSE_SVR/mean(Y_iAna_T);

% if false
figure;hold on;
all_C=arrayfun(@(x) x.C,saSVR_Results);
all_RMSE_SVR=arrayfun(@(x) x.RMSE,saSVR_Results);
[RMSE_SVR_min loc_minRMSE_SVR]=min(all_RMSE_SVR);
% RMSE_SVR_min=minRMSE_SVR;

C_SVR_min=all_C(loc_minRMSE_SVR);

plot(log10(all_C),all_RMSE_SVR,'k-*','linewidth',2);


% C_SVR_Opm
RMSE_SVR_Opm=all_RMSE_SVR(all_C==C_SVR_Opm);
plot(log10(C_SVR_Opm),RMSE_SVR_Opm,'gO','markersize',15,'markerfacecolor','g');

plot(log10(C_SVR_min),RMSE_SVR_min,'bO','markersize',12,'markerfacecolor','b');

xlabel('log10 C');
ylabel('RMSE by SVR');
inp_plot_hline.label='PLS';
% [hphl hthl ]=plot_hline(out.RMSE_bo_Tcv,'b',inp_plot_hline );
 [hphl hthl ]=plot_hline(inp4SVR.RMSE_bo_Tcv,'b',inp_plot_hline );

ctit1={[strrep(fileparts_name_ext(pathfnameTP),'_','\_')]};
ctit3={[strrep(inp4SVR.ModelPara_Opm_Scheme,'_','\_'),'   C\_opm =',num2str(C_SVR_Opm),'  RMSE=',roundns(RMSE_SVR_Opm,3)]};
title([ctit1;{remove_underscore(sasmc_SVR)};ctit3]);
% end






%=====================================================================================
out.CV_SVR=CV_SVR;
try
    out.RMSE_SVR_Opm=RMSE_SVR_Opm;
    out.C_SVR_Opm=C_SVR_Opm;
    out.saSVR_Results=saSVR_Results;
    out.asmc_SVR=sasmc_SVR;
end
% try
% out.Y_iAna_est_bo_Tcv=Y_iAna_est_basedon_Tcv;
% out.Y_iAna_P_bo_Tcv=kY_iAna_P_basedon_Tcv;
% end
try
out.Yest_SVR=all_Yest_SVR(:,loc_Opm_SVR);  % based on C at Opm
end
out.Y_iAna_P=Y_iAna_P;
try
out.outSVR_Tcv=outSVR_Tcv;
end

% out.PLSfactor_Opm=PLSfactor_Opm;
% out.RMSE_PLS_Opm=RMSE_PLS_Opm;

% out.PLSfactor_PLS_min=PLSfactor_PLS_min;
% out.RMSE_PLS_min=RMSE_PLS_min;

out.C_SVR_min=C_SVR_min;
out.RMSE_SVR_min=RMSE_SVR_min;


out.ModelPara_Opm_Scheme=inp4SVR.ModelPara_Opm_Scheme;

sSM_P=strrep(find_keyword_between_markers( fileparts_name_ext(pathfnameTP),'_P-S1-','_'),'00','');
out.sSM_P=sSM_P;
end


%% ----- SVR_inside_PLS_predict_ONLY__saConc2XY   [AQP_gui.m lines 16357-16362] --------------------
function [X_iAna Y_iAna  cSampleName]=SVR_inside_PLS_predict_ONLY__saConc2XY(saConc,AnaName)
idx_CurAna= arrayfun(@(x) strcmp(x.clsname,AnaName),saConc);
X_iAna=cell2mat(arrayfun(@(x) x.Atrainpk, saConc(idx_CurAna),'un',0));
Y_iAna=cell2mat(arrayfun(@(x) repmat(x.Conc,[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
cSampleName=cell_unwrap(arrayfun(@(x) repmat({x.SampleName},[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
end


%% ----- SVR_inside_PLS_predict_ONLY__isKSpick   [AQP_gui.m lines 16364-16373] ---------------------
function out=SVR_inside_PLS_predict_ONLY__isKSpick(x,Conc_KSpick)
if length(find(Conc_KSpick==x.Conc))==0
out=false;
elseif length(find(Conc_KSpick==x.Conc))==1
    
    out=true;
else
    error('more than one match found ')
end
end


%% ----- Set_GUI_PopUpMenu_parameter_Default   [AQP_gui.m lines 16385-16420] -----------------------
function out=Set_GUI_PopUpMenu_parameter_Default(Handles_AQP_Tag,TitPara,strDefault)
% set parameter to default when user did not pick any option (i.e. TitPara: typically at 1st entry)
if false
    
    out_default_para=Set_GUI_PopUpMenu_parameter_Default(InpBR.handles_AQP_gui.TcvModelParaOpmScheme,'TcvModelParaOpmScheme','(default)',InpBR.handles_gui.TcvModelParaOpmScheme)
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameter "inp4AQP.ModelOpt.CurTcvModelParaOpmScheme"
CurTcvModelParaOpmScheme=Handles_AQP_Tag.String{Handles_AQP_Tag.Value};
if strcmp(CurTcvModelParaOpmScheme,TitPara) % 'TcvModelParaOpmScheme' --> title in drop down menu
    % TcvModelParaOpmScheme_default='KneePt-RMSECV'; % set default value for TcvModelParaOpmScheme
    Value4Default=find(strmatch_strfind_idx(strDefault, strrep(lower(Handles_AQP_Tag.String),' ',''))); % can handle extra spaces and case insensitive
    TcvModelParaOpmScheme_default=Handles_AQP_Tag.String{Value4Default}; % set default value for TcvModelParaOpmScheme
    TcvModelParaOpmScheme_default=strtrim(find_keyword_between_markers(TcvModelParaOpmScheme_default,'','(')); % remove "(default)"
    if ~isempty(strfind(TcvModelParaOpmScheme_default,'RMSECV'))
%     Speak_mk(['Run with Default ',find_keyword_between_markers_wlistRHS(TcvModelParaOpmScheme_default,'',{'_','-'}),' R M S E C V']);
disp_with_border(['Run with Default ',find_keyword_between_markers_wlistRHS(TcvModelParaOpmScheme_default,'',{'_','-'}),' R M S E C V']);
    else
%     Speak_mk(['Run with Default ',TcvModelParaOpmScheme_default]);
disp_with_border(['Run with Default ',TcvModelParaOpmScheme_default]);
    end
%     handles_gui_tag.Value=Value4Default;
    Handles_AQP_Tag.Value=Value4Default;
    
    %inp4AQP.ModelOpt.CurTcvModelParaOpmScheme=TcvModelParaOpmScheme_default;
    out=TcvModelParaOpmScheme_default;
else
    %inp4AQP.ModelOpt.CurTcvModelParaOpmScheme=CurTcvModelParaOpmScheme; % 'KneePt-RMSECV' 'Min-RMSECV'  % see PLS_inside_PLS_predict_ONLY_MLtool()
    %out=TcvModelParaOpmScheme_default;
    
   out= strtrim( textual_eraseAfter_wo_kw1(CurTcvModelParaOpmScheme,'(') ); % remove "(default)";
    
end
end


%% ----- Set_cPP1_fromGUI_AQP   [AQP_gui.m lines 16424-16458] --------------------------------------
function  InpBR_updated=Set_cPP1_fromGUI_AQP(handles,InpBR)
%  typically called by AQP_gui.m
% will call --> 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cPP1 % this should be in cell datatype
    if strcmp( get_curAQP_class(handles),'lite')
        theChosenPP1= cPP1_AQPlite_MN_PRO;
        InpBR.handles_AQP_gui.cPP1=theChosenPP1;
    else
        if strcmp(handles.cPP1.String(handles.cPP1.Value),'ChooseFromPRO')
            % this will go to menu provided in cPP1_AQPlite_MN_PRO (cover all MN PRO-style pretreatments)
            theChosenPP1= cPP1_AQPlite_MN_PRO;                            % 'Multi', 0  --> can only pick one            % 'Multi', 0  --> can only pick one
            InpBR.handles_AQP_gui.cPP1=theChosenPP1;
        elseif strcmp(handles.cPP1.String(handles.cPP1.Value),'ChooseFromCH')
%              Speak_mk('Choose From CH Not supported yet');
%             error('ChooseFromCH Not supported yet');
            theChosenPP1= cPP1_AQPpro_CH;                               % 'Multi', 1 --> can pick more than one      % 'Multi', 1 --> can pick more than one
            InpBR.handles_AQP_gui.cPP1=theChosenPP1;


        elseif strcmp(handles.cPP1.String(handles.cPP1.Value),'ALL_PP1_schemes')
            ScanThru_cPP1 = handles.cPP1.String(1:handles.cPP1.Value-1);
            %%%%%%%%%%%%%%%
            % following 3 lines are the same
            % ScanThru_cPP1( strmatch_strfind_idx(  'ChooseFrom' ,ScanThru_cPP1) )=[];  %remove all   "*ChooseFrom*"
              ScanThru_cPP1( strmatch_strfind_idx( ScanThru_cPP1 ,  'ChooseFrom' ) )=[];  %remove all   "*ChooseFrom*"
            %  ScanThru_cPP1( strmatch_findstr_idx( ScanThru_cPP1 ,  'ChooseFrom' ) )=[];  %remove all   "*ChooseFrom*"
            %%%%%%%%%%%%%%%%
            InpBR.handles_AQP_gui.cPP1=ScanThru_cPP1;
        else
            InpBR.handles_AQP_gui.cPP1=handles.cPP1.String(handles.cPP1.Value);
        end
    end
    InpBR_updated=InpBR;
end


%% ----- Set_cPP2_fromGUI_AQP   [AQP_gui.m lines 16462-16517] --------------------------------------
function  InpBR_updated=Set_cPP2_fromGUI_AQP(handles,InpBR)
 % update cPP2 in  InpBR.handles_AQP_gui.cPP2 
 %
 try
     if iscell(handles.cPP2.String)
         handles_cPP2=handles.cPP2.String(handles.cPP2.Value);
         if length(handles_cPP2)==1
             sPP2= handles_cPP2{1};
             %%%%%%%%%%%%%%%%%%%%%
             % deal with sPPn set to UI control's title
             if strcmp(sPP2,'PP2')
               loc_default= find( cellfun(@(x) ~isempty(strfind(lower(x),'default')),   handles.cPP2.String) );
               
               if length(loc_default)==1
                   sPP2=handles.cPP2.String{loc_default }
               elseif isempty(loc_default)
                   try
                   sPP2= handles.cPP2.String{handles.cPP2.Value+1};  % assuming 1st entry is the title for cPP2 i.e. 'PP2' then set it to next entry after 'PP2'
                   catch
                   sPP2='SNV';  % default for cPP2 (if not able to be set in GUI and can not set to next entry after title 'PP2' either)
                   end
               else
                   error('can not handle case that multiple default found')
               end
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%
             if ~isempty(strfind(lower(sPP2),'default'))
                 sPP2=find_keyword_between_markers(sPP2,'','(');  % assuming "default" enclosed in "(" and ")"
             end
             
             handles_cPP2={strtrim(sPP2)};    % clean up redundant white spaces and make sure that cPP2 shoud be a cell !!!
             
         else
             error('can not handle cPP2 with multiple entries yet')
         end
         
     elseif ischar(handles.cPP2.String)
         handles_cPP2={strtrim(handles.cPP2.String)};
     else
         error('unexpected data type for handles.cPP2.String ??')
     end
 catch
     handles_cPP2={'SNV'};  % default for cPP2 (if not set in GUI)
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if iscell(handles_cPP2) && length(handles_cPP2)==1 && strcmp(handles_cPP2{1},'ChooseFromCH')
%              Speak_mk('Choose From CH Not supported yet');
%             error('ChooseFromCH Not supported yet');
            theChosenPP1= cPP1_AQPpro_CH;                               % 'Multi', 1 --> can pick more than one      % 'Multi', 1 --> can pick more than one
            handles_cPP2=theChosenPP1;
  end
 
% update final cPP2 (must be a cell ) into InpBR.handles_AQP_gui
InpBR.handles_AQP_gui.cPP2= handles_cPP2;
InpBR_updated=InpBR;
end


%% ----- SpcDistance   [AQP_gui.m lines 16522-16544] -----------------------------------------------
function mdDist = SpcDistance(mdSpcA, mdSpcB)

% INPUT:
% mdSpcA:       Spectra matrix A
% mdSpcB:       Spectra matrix B 
% 
% OUTPUT:
% mdY:          Distance between all Spectra of sets A and B
%
% DESCRIPTION:
%       Calculates distances between spectra 

mSpcA = size( mdSpcA, 1 );
mSpcB  = size( mdSpcB, 1 );

vdSumA = sum(mdSpcA.^2, 2);
vdSumB = sum(mdSpcB.^2, 2);

mdSumA = repmat( vdSumA, 1, mSpcB )';
mdSumB = repmat( vdSumB, 1, mSpcA );

mdDist = sqrt( mdSumA + mdSumB - 2*(mdSpcB * mdSpcA') );
end


%% ----- XLSX2MAT_AQP   [AQP_gui.m lines 16992-17408] ----------------------------------------------
function [inp4AQP]=XLSX2MAT_AQP(inp4AQP,InpBR,seqDS,inp)
% this function has been called by --> BatchRun_AutoQuant_DA_pipeline
% this function will call (multiple times)--> LoadXlsx4AQP
% this function will call  (only once) --> Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool
%----------------------------------------------------------------------------------------------------------------------------
% pull out subfunction from BatchRun_AutoQuant_DA_pipeline --> XLSX2MAT to become an independent function called XLSX2MAT_AQP
% convert xlsx files into mat files for input into AutoQuant_DA_pipeline(cCabXfer_scheme,inp4AQP)
% see -->       curAQP_class=cAQP_class{ InpBR.handles_gui.AQP_class.Value};
% % assign curAQP_class (May 9, 2020)
% % handling cCabXfer_scheme After check --> isempty(pathfname_XRS_xlsx) July 24, 2020
% --------------------------------
% % added this Nov 4, 2020 to fix problem caused by Mst has (at least one side) narrower wvl than Trg 
% % added this Nov 5, 2020 to fix problem with Val and caused by Mst has (at least one side) narrower wvl than Trg
% % changed from above to this,  Nov 20, 2020
%-------------------------------------------------------------
% below will fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023
% see also: AutoQuant_DA_pipeline
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get ID of XRS only and return and use to find matching ID samples in CS to serve as XSmst
try
    pathfname_XRS_xlsx=get_OnlyOne_XLSX_wPrefix(InpBR.path_XLSX,'XRS_');
catch
    pathfname_XRS_xlsx=''; % this is the case there was no XRS set exist
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % block following two lines when finished dealing with this situation
%     Speak_mk('there is NO "XRS" or transfer set  exist');
%     error('there is NO "XRS" or transfer set  exist');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% assign curAQP_class (May 9, 2020)
try
    
    if iscell(InpBR.handles_gui.AQP_class.String)
        cAQP_class= InpBR.handles_gui.AQP_class.String;
        curAQP_class=cAQP_class{ InpBR.handles_gui.AQP_class.Value};  % assign curAQP_class (May 9, 2020)
    elseif ischar(InpBR.handles_gui.AQP_class.String)
        curAQP_class=InpBR.handles_gui.AQP_class.String;  % assign curAQP_class (May 9, 2020)
    else
        curAQP_class='lite';
    end
    
catch
    curAQP_class='lite';
end
% if ~strcmp(InpBR.handles_AQP_gui.cCabXfer_scheme,'woCabXfer')  && ~isempty(pathfname_XRS_xlsx)
%  if ~strcmp(InpBR.handles_AQP_gui.cCabXfer_scheme,'woCabXfer')  || ~isempty(pathfname_XRS_xlsx) % changed to this Dec 23, 2019
if   ~isempty(pathfname_XRS_xlsx) % changed to this Dec 23a, 2019, this is the CORRECT coding !!!
    AnaName='Unknown_yet';
    inp4LoadXLSX_XRS_ID_only.CS_XRS_Val='XRS'; % 'CS' 'XRS'  'Val' 'UDM'
    inp4LoadXLSX_XRS_ID_only.XRS_ID_only_yes=1;% activate this function before calling LoadXlsx4AQP  !!!!
    OutLX_ID_XRS_ONLY=LoadXlsx4AQP(pathfname_XRS_xlsx,AnaName,inp4LoadXLSX_XRS_ID_only);
    ID_XRS=OutLX_ID_XRS_ONLY.ID_XRS;   % this "ID_XRS" will be needed inside --> clistfilename2AT_AQP.m which is 3 levels down in called functions
else
    switch curAQP_class
        case {'pro'}
          %  if  ~strcmp(InpBR.handles_AQP_gui.cCabXfer_scheme,'woCabXfer')
          if  ~strcmp(InpBR.handles_AQP_gui.cCabXfer_scheme{1},'woCabXfer')   % changed from above to this,  Nov 20, 2020
     
                InpBR.handles_AQP_gui.cCabXfer_scheme={'woCabXfer'};  % very important, this should be a cell not char !!!
                InpBR.handles_gui.CabXfer_scheme.Value=strmatch('woCabXfer',InpBR.handles_gui.CabXfer_scheme.String,'exact');
                Speak_mk('Running without calibration transfer');
          else
               Speak_mk('Running without calibration transfer');                      % updated,  Nov 20, 2020
            end
            ID_XRS='';
        otherwise  % 'lite' 
            Speak_mk('can not find XRS set and stop running AQP');
            error('can not find XRS set and stop running AQP');
    end
end
%     inp4LoadXLSX.XRS_ID_only_yes=0; % disable this function after it already completed its job above !!!!
%=========================================================
% handling cCabXfer_scheme After check --> isempty(pathfname_XRS_xlsx) July 24, 2020
%
inp4AQP.cCabXfer_scheme=InpBR.handles_AQP_gui.cCabXfer_scheme;
%=========================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    s_Mst_sf='TMP_AQP-LoadXLSX\Mst';% below will fix issues when CS-ONLY and Avg_Mean happen that Pset should be based on without Avg-Mean, Apr 24, 2023

    try
        rmdir([pwd,'\',s_Mst_sf],'s'); % add this to prevent getting subfolder 'XSmst' as file in following line -->[clistfilename_XSmst, nfile_XSmst]=fdir_wildcard_wPath(pwd,'XSmst');
    end
    path_LX_CS=tmp_folder_rm_mk(s_Mst_sf,pwd);
    path_prev=pwd;
    cd(path_LX_CS);
    inp4LoadXLSX.CS_XRS_Val='CS'; % 'CS' 'XRS'  'Val' 'UDM'
    inp4LoadXLSX.ID_XRS=ID_XRS;  % added  to find matching ID samples in CS to serve as XSmst
     inp4LoadXLSX.Spectra_Avg_Method=InpBR.Spectra_Avg_Method;
    % pathfname_Orig_CS_xlsx='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21\CS_sugarcane_FOSS_4Cmp_nsamp102_exclude21UDM_XS30wNaN.xlsx';
    pathfname_Orig_CS_xlsx=get_OnlyOne_XLSX_wPrefix(InpBR.path_XLSX,'CS_');
    AnaName='Unknown_yet';% AnaName will be decided inside LoadXlsx4AQP below when running for "CS"
    OutLX_CS=LoadXlsx4AQP(pathfname_Orig_CS_xlsx,AnaName,inp4LoadXLSX);
    % % AnaName='Brix';
    AnaName=OutLX_CS.AnaName;  % AnaName decided inside LoadXlsx4AQP when running for "CS"
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add following July 23, 2020
    inp4AQP.AnaName=AnaName;  % add following July 23, 2020
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [clistfilename_XSmst, nfile_XSmst]=fdir_wildcard_wPath(pwd,'XSmst');
    if nfile_XSmst==1
        pathfname_XSmst=clistfilename_XSmst{1};
    elseif nfile_XSmst==0
        
%         Speak_mk( 'No XSmst found in CS ?  typically XSmst and XStrg should use Ref of NaN for all of them' )
       cd(path_prev);
        warning('No XSmst found in CS ?  typically XSmst (and XStrg) should use Ref of NaN for all of them');
        
    else
        error('non-unique XSmst file exist ?')
    end
    
    path_LX_XSmst=tmp_folder_rm_mk('XSmst',pwd);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for debugging Lan Sun
    try
    disp_with_border(['try to copyfile this --> ',pathfname_XSmst]);
    end
    try
    disp_with_border(['try to copyfile to this folder --> ',path_LX_XSmst]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
    copyfile(pathfname_XSmst,path_LX_XSmst);
    end
    try
    delete(pathfname_XSmst);
    end
    cd(path_prev);
    %%%%%%%%%%%%
    try
         
        path_LX_XRS=tmp_folder_rm_mk('TMP_AQP-LoadXLSX\Trg-XRS',pwd);
        cd(path_LX_XRS);
        inp4LoadXLSX.CS_XRS_Val='XRS'; % 'CS' 'XRS'  'Val' 'UDM'
        % pathfname_XRS_xlsx='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21\XRS_sugarcane_MicroNIR_4Cmp_nsamp30_RefNaN.xlsx';
        pathfname_XRS_xlsx=get_OnlyOne_XLSX_wPrefix(InpBR.path_XLSX,'XRS_');
        
    catch
        path_LX_XRS='';
        pathfname_XRS_xlsx='';
    end
%     if ~strcmp(InpBR.handles_AQP_gui.cCabXfer_scheme,'woCabXfer')
%         
%         path_LX_XRS=tmp_folder_rm_mk('TMP_AQP-LoadXLSX\Trg-XRS',pwd);
%         cd(path_LX_XRS);
%         inp4LoadXLSX.CS_XRS_Val='XRS'; % 'CS' 'XRS'  'Val' 'UDM'
%         % pathfname_XRS_xlsx='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21\XRS_sugarcane_MicroNIR_4Cmp_nsamp30_RefNaN.xlsx';
%         pathfname_XRS_xlsx=get_OnlyOne_XLSX_wPrefix(InpBR.path_XLSX,'XRS_');
%     else
%         path_LX_XRS='';
%         pathfname_XRS_xlsx='';
%     end
    %%%%%%%%%%%%%%
    
    try
      fname_XSwoRef= OutLX_CS.fname_XSwoRef;
      
    catch
      fname_XSwoRef='';  
    end
    %%%%%%%%%%%%%%
    if ~isempty(fname_XSwoRef)
        LoadXlsx4AQP(pathfname_XRS_xlsx,AnaName,inp4LoadXLSX);
    else
       % Speak_mk('XSmst not abe to be extracted ??? Unless you are NOT going to run CabXfer ??? This is not done yet though');
%                 Speak_mk('XSmst not abe to be extracted ??? Assume you are NOT going to run CabXfer');

        %          cd(path_prev); % when only warning use this, otherwise use --> find_last_nonTMP_path ( see below)
        
        % when the codes will error exit, use the following instead of " cd(path_prev) "
%         out_rootPath=find_last_nonTMP_path();
%         cd(out_rootPath);
        %%%%%
        warning('XSmst not abe to be extracted ??? Assume you are NOT going to run CabXfer');
        
        
    end
    cd(path_prev);
    %%%%%%%%%%%%
    % check if Val set exist or not first
    try
        pathfname_Val_xlsx=get_OnlyOne_XLSX_wPrefix(InpBR.path_XLSX,'Val_');%  'Val' or 'VAL'  % case insensitive
        nfile_Val=1;
    catch
        [~, nfile_Val]=fdir_wildcard_ext_wPath(InpBR.path_XLSX,'Val_','xlsx');

    end
    %%%%%%%%%%%
    if nfile_Val==1
        path_LX_Val=tmp_folder_rm_mk('TMP_AQP-LoadXLSX\Val',pwd);
        cd(path_LX_Val);
        
       % find_keyword_between_markers(fileparts_name_ext(pathfname_Val_xlsx),'','_');
        inp4LoadXLSX.CS_XRS_Val=find_keyword_between_markers(fileparts_name_ext(pathfname_Val_xlsx),'','_'); %  'Val' or 'VAL'  % case insensitive
        
        % pathfname_Val_xlsx='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21\Val_sugarcane_MicroNIR_4Cmp_wo30XS_last102_nsamp102.xlsx';
        %     pathfname_Val_xlsx=get_OnlyOne_XLSX_wPrefix(InpBR.path_XLSX,'Val_');
        LoadXlsx4AQP(pathfname_Val_xlsx,AnaName,inp4LoadXLSX);
       InpBR.handles_gui.Val_Exist.Value = 1;
       Val_Exist=1;
    else
        msgbox('NO Validation set exist  !!!');
        InpBR.handles_gui.Val_Exist.Value = 0;
        Val_Exist=0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%
    cd(path_prev);
    %%%%%%%%%%%%
    % turn off UDM etc, July 11, 2019
    if false
        path_LX_UDM=tmp_folder_rm_mk('TMP_AQP-LoadXLSX\UDM',pwd);
        cd(path_LX_UDM);
        inp4LoadXLSX.CS_XRS_Val='UDM'; % 'CS' 'XRS'  'Val' 'UDM'
        % pathfname_UDM_xlsx='C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21\UDM_sugarcane_MicroNIR_4Cmp_wo30XS_1st21_nsamp21.xlsx';
        pathfname_UDM_xlsx=get_OnlyOne_XLSX_wPrefix(InpBR.path_XLSX,'UDM_');
        LoadXlsx4AQP(pathfname_UDM_xlsx,AnaName,inp4LoadXLSX);
        cd(path_prev);
    end
    %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % inp4MG_1=load('C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\inp4MatchGrids\inp4MG.mat');
    % inp4MG_1=inp4MG_1.inp4MG;
    %%%%%%%%%%
    % for AQP cases --> inp4MG.seq_pp_vs_matchgrids --> always set to --> 'pp-After-MatchGrids'
    % for AQP cases --> inp4MG.force_pp --> always set to --> pp1: 'none' and pp2: 'none'
    inp4MG.seq_pp_vs_matchgrids='pp-After-MatchGrids';
    inp4MG.force_pp.pp1='none';inp4MG.force_pp.pp2='none';
    %%%%%%%%%%%
    % inp4MG.pathfname_HiRes --> CS_orig
    % inp4MG.pathfname_LoRes --> XRS
    % inp4MG.pathfname_LoRes_Val --> Val
    % inp4MG.DS.pathfname_HiRes_XSmst --> XSmst
    pathfname_HiRes=get_OnlyOne_AT(path_LX_CS);
    if ~isempty(path_LX_XRS)
        try
            pathfname_LoRes=get_OnlyOne_AT(path_LX_XRS);
        catch
            pathfname_LoRes='';
        end
    else
        pathfname_LoRes='';
    end
    
    if Val_Exist
    pathfname_LoRes_Val=get_OnlyOne_AT(path_LX_Val);
    else
    pathfname_LoRes_Val='';    
    end
    
    if ~isempty(path_LX_XRS)
        try
            inp4MG.DS.pathfname_HiRes_XSmst=get_OnlyOne_AT(path_LX_XSmst);
        catch
            inp4MG.DS.pathfname_HiRes_XSmst='';
        end
    else
        inp4MG.DS.pathfname_HiRes_XSmst='';
    end
    if ~isempty(inp4MG.DS.pathfname_HiRes_XSmst)
    inp4MG.DS.Lmst_orig_XSmst=load(inp4MG.DS.pathfname_HiRes_XSmst);
    else
     inp4MG.DS.Lmst_orig_XSmst='';    
    end
    % out_MGs=Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool(handles.DS.Lmst_orig,handles.DS.Ltrg_orig,handles.DS.Ltrg_orig_Val,inp4MG);
    
    out_MGs=Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool(pathfname_HiRes,pathfname_LoRes,pathfname_LoRes_Val,inp4MG);
    
    path_LX_CS_MatchGrids=   [pwd,'\TMP\MGs_PP_Mst']; % results from above "Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool" saved in this path
   if ~isempty(out_MGs)
    path_LX_XSmst_MatchGrids=[pwd,'\TMP\MGs_PP_XSmst']; % results from above "Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool" saved in this path
   else
   path_LX_XSmst_MatchGrids='';    
   end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % replace the following by results from out_MGs=Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool
    % inp4AQP.path_CS_XRS=InpBR.path_CS_XRS;
    % get_OnlyOne_AT(InpBR.path_CS_XRS)
    try
    OOA_path_LX_CS_MatchGrids=get_OnlyOne_AT(path_LX_CS_MatchGrids);
    catch
      OOA_path_LX_CS_MatchGrids=pathfname_HiRes;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(path_LX_XRS)
        try
            try
    OOA_path_LX_XRS= out_MGs.DS.pathfname_MGs_PP_Trg_XS;         % added this Nov 4, 2020 to fix problem caused by Mst has (at least one side) narrower wvl than Trg 
            catch
    OOA_path_LX_XRS= get_OnlyOne_AT(path_LX_XRS);
            end
    
        catch
      OOA_path_LX_XRS='';          
        end
    else
     OOA_path_LX_XRS='';   
    end
    
    sd_LX_CS_MatchGrids=ssds(OOA_path_LX_CS_MatchGrids);
    try
        sd_LX_XRS=ssds(OOA_path_LX_XRS);
        sd_CS_XRS=sd_LX_CS_MatchGrids>sd_LX_XRS;
        path_CS_XRS_AQP=tmp_folder_rm_mk('TMP_AQP-MGs\Tmst_Ptrg_XRS',pwd);
        cd(path_CS_XRS_AQP);
        inp4SA.corename='{T-CS_P-XRS}';
        saveAT(sd_CS_XRS,inp4SA);
    catch
        path_CS_XRS_AQP='';
    end
    cd(path_prev);
    inp4AQP.path_CS_XRS=path_CS_XRS_AQP;
    %%%%%%%
    % inp4AQP.path_CS_Val=InpBR.path_CS_Val;
    % get_OnlyOne_AT(InpBR.path_CS_Val)
    if Val_Exist
        try
            try
                % added this Nov 5, 2020 to fix problem with Val and caused by Mst has (at least one side) narrower wvl than Trg
                % see  BatchRun_AutoQuant_DA_pipeline --> % updated Dec 3, 2020 to output CS and Val after MatchGrids ( to StepByStep folder )
                sd_CS_Val=ssds(get_OnlyOne_AT(path_LX_CS_MatchGrids))  >  ssds(out_MGs.DS.pathfname_MGs_PP_Trg_Val) ;   % added this Nov 5, 2020 to fix problem with Val and caused by Mst has (at least one side) narrower wvl than Trg
            catch
                % see  BatchRun_AutoQuant_DA_pipeline --> % updated Dec 3, 2020 to output CS and Val after MatchGrids ( to StepByStep folder )
                sd_CS_Val=ssds(get_OnlyOne_AT(path_LX_CS_MatchGrids))>  ssds(get_OnlyOne_AT(path_LX_Val));
            end
        catch
            sd_CS_Val=  sd_LX_CS_MatchGrids>ssds(get_OnlyOne_AT(path_LX_Val));
        end
        path_CS_Val_AQP=tmp_folder_rm_mk('TMP_AQP-MGs\Tmst_Ptrg_Val',pwd);    % see  BatchRun_AutoQuant_DA_pipeline --> % updated Dec 3, 2020 to output CS and Val after MatchGrids ( to StepByStep folder )
        cd(path_CS_Val_AQP);
        inp4SA.corename='{T-CS_P-Val}';
        saveAT(sd_CS_Val,inp4SA);
        inp4AQP.path_CS_Val=path_CS_Val_AQP;                                                          % see  BatchRun_AutoQuant_DA_pipeline --> % updated Dec 3, 2020 to output CS and Val after MatchGrids ( to StepByStep folder )
        
    else
        inp4AQP.path_CS_Val='';
    end
    cd(path_prev);
    %%%%%%
    % inp4AQP.pathfname_MGs_PP_XSmst=InpBR.pathfname_MGs_PP_XSmst;
    if ~isempty(path_LX_XSmst_MatchGrids)
        try
    inp4AQP.pathfname_MGs_PP_XSmst=get_OnlyOne_AT(path_LX_XSmst_MatchGrids);
        catch
       inp4AQP.pathfname_MGs_PP_XSmst='';           % deal with non-MN CS woXRS but with MN-Val, Nov 20, 2020
        end
    else
  
    end
    % path_LX_XSmst_MatchGrids=[pwd,'\TMP\MGs_PP_XSmst']; % results from above "Match_wvl_HiRes2LoRes_and_Diff_Ranges_MLtool" saved in this path
    %%%%%%%%%%%%%%%%%
    try
        %inp4AQP.pathfname_UDM=InpBR.pathfname_UDM;
        pathfname_UDM_by_LoadXlsx4AQP=get_OnlyOne_AT(path_LX_UDM);% deal with UDM created by LoadXlsx4AQP
        inp4AQP.pathfname_UDM=pathfname_UDM_by_LoadXlsx4AQP;
        if ~isempty(inp4AQP.pathfname_UDM)
            try
                Ludm=load(inp4AQP.pathfname_UDM);
            catch
                errror('can not load UDM file');
            end
        end
    catch
        inp4AQP.pathfname_UDM='';
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inp.DS_type='single_XLSX_folder';
% inp.DS_type='multiple_DSn_MAT_folders';
switch inp.DS_type
    case 'multiple_DSn_MAT_folders'
        %%% copy MAT files to separate folder and clear others TMP etc
        sDSn=['DS',num2str(seqDS),'\'];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % clear previous DSn
        try
            rmdir([pwd,'\',sDSn],'s');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        sMAT4CS_Val=[sDSn,'CS_Val'];
        path_MAT4CS_Val=tmp_folder_rm_mk(sMAT4CS_Val,pwd);
        copyfile( get_OnlyOne_AT(inp4AQP.path_CS_Val),path_MAT4CS_Val);
        
        sMAT4CS_XRS=[sDSn,'CS_XRS'];
        path_MAT4CS_XRS=tmp_folder_rm_mk(sMAT4CS_XRS,pwd);
        copyfile( get_OnlyOne_AT(inp4AQP.path_CS_XRS),path_MAT4CS_XRS);
        
        copyfile( inp4AQP.pathfname_MGs_PP_XSmst,[pwd,'\',sDSn]);
        copyfile( inp4AQP.pathfname_UDM,[pwd,'\',sDSn]);
        % replace path4MAT in inp4AQP
        inp4AQP.path_CS_Val=path_MAT4CS_Val;
        inp4AQP.path_CS_XRS=path_MAT4CS_XRS;
        inp4AQP.pathfname_MGs_PP_XSmst=get_OnlyOne_MAT_wPrefix([pwd,'\',sDSn],'_XSmst_');
        inp4AQP.pathfname_UDM=get_OnlyOne_MAT_wPrefix([pwd,'\',sDSn],'_UDM');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % remove directories used by XLSX approach
        try
            rmdir([pwd,'\TMP'],'s');
        end
        try
            rmdir([pwd,'\TMP_AQP-MGs'],'s');
        end
        try
            rmdir([pwd,'\TMP_AQP-LoadXLSX'],'s');
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 'single_XLSX_folder'
       disp('this is the single XLSX folder case') 
        
        
end
end


%% ----- Xfer_on_RawSpectra_AQP   [AQP_gui.m lines 17412-17468] ------------------------------------
function out_XRS=Xfer_on_RawSpectra_AQP(cCabXfer_scheme,inp4XferRS)
% this function is typically called by --> AutoQuant_DA_pipeline
% this function will call --> BatchRun_CabXfer_Siesler48_MLtool
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INP.handles=handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
LINP=load_local_try('C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\INP_wo_handles.mat');
catch
  LINP=load([find_last_nonTMP_folder,'\Tmp4AQPliteEXE\INP_wo_handles.mat']);  
end
INP=LINP.INP;
INP=rmfield(INP,'cCabXfer_scheme');
INP=rmfield(INP,'cXM_Slct_scheme');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following from ~\CXtmp\TMP\woCabXfer\Tmst_Ptrg_Val when run CabXferLite
% INP.pathfnameTP4Val='C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\woCabXfer_Tmst_Ptrg_Val\Atrainpketc_saConc_{T-XLS_Astra34_CS_P-XLS_Astra34_Val_pp1-none}_pp1-none_pp2-none_nvar125_nsampT153_pp-After-MatchGrids_Matched2ManuC_nsampP153.mat'
try
INP.pathfnameTP4Val=get_OnlyOne_AT(inp4XferRS.path_CS_Val);
catch
INP.pathfnameTP4Val='';    
end

INP.pathfname_MGs_PP_XSmst=inp4XferRS.pathfname_MGs_PP_XSmst;
% INP.pathfnameTP4XRS='C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\woCabXfer_Tmst_Ptrg_XRS\Atrainpketc_saConc_{T-XLS_Astra34_CS_P-XLS_Astra34_XRS_pp1-none}_pp1-none_pp2-none_nvar125_nsampT153_pp-After-MatchGrids_Matched2ManuC_nsampP30.mat'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
INP.TP_includeTrn_Yes=1; % default setting copied from CabXferLite
INP.cXM_Slct_scheme={'KSall'};
%INP.cCabXfer_scheme={'MDC'};
INP.cCabXfer_scheme=cCabXfer_scheme;  % very important do NOT use without "[a1e-3]"

INP.newpath_TMP_Cabxfer='TMP_Cabxfer_AQP';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following from ~\CXtmp\TMP\woCabXfer\Tmst_Ptrg_XRS when run CabXferLite
      %path_CabX='C:\work\JDSU\CabXfer_Results_Review\meta_AQDAP\woCabXfer_Tmst_Ptrg_XRS'
       path_CabX=inp4XferRS.path_CS_XRS;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
% inp.pathfnameTP4Val
% path_prev=pwd;

% cd(INP.newpath_TMP_Cabxfer);
INP.inp4AQP=inp4XferRS.inp4AQP;   % copy of "inp4AQP" into BatchRun_CabXfer_Siesler48_MLtool inside subfunction --> Xfer_on_RawSpectra
if ~isempty(inp4XferRS.path_CS_Val)
    
    [clistfilename_CS_Val, nfile_CS_Val]=fdir_wildcard_ext_wPath(inp4XferRS.path_CS_Val,'Atrainpketc_','mat');

    if nfile_CS_Val==1
        INP.clistfilename_CS_Val_MatchGrids=clistfilename_CS_Val{1};
    end
end

OUT_Xfer=BatchRun_CabXfer_Siesler48_MLtool(path_CabX,INP);
out_XRS.INP=INP;
out_XRS.OUT_Xfer=OUT_Xfer;
end


%% ----- adjust_PlsfactorScan_AQP   [AQP_gui.m lines 17517-17550] ----------------------------------
function inp4AQP=adjust_PlsfactorScan_AQP(inp4AQP,PlsfactorScan_default)

% for adjusting PlsfactorScan for small sized UDM
% need Ludm to run
try
    
    try
        Ludm=load(inp4AQP.pathfname_UDM);
    catch
        error('can not load "Ludm"')
    end
    
    
    if length(Ludm.AclabelT)==11 & strcmp(inp4AQP.ModelOpt.CurUDMas{1},'UDMasCS')
        inp4AQP.ModelOpt.PlsfactorScan=[1:6];
        
    elseif length(Ludm.AclabelT)==14 & strcmp(inp4AQP.ModelOpt.CurUDMas{1},'UDMasCS')
        inp4AQP.ModelOpt.PlsfactorScan=[1:8];
        
    elseif length(Ludm.AclabelT)==21 & strcmp(inp4AQP.ModelOpt.CurUDMas{1},'UDMasCS')
        inp4AQP.ModelOpt.PlsfactorScan=[1:14];
         
    elseif length(Ludm.AclabelT)==7 & strcmp(inp4AQP.ModelOpt.CurUDMas{1},'UDMasCS')
        inp4AQP.ModelOpt.PlsfactorScan=[1:2];
   
    else  %default
        inp4AQP.ModelOpt.PlsfactorScan= PlsfactorScan_default;
        
    end
    
    
    
end
end


%% ----- apply_1stDer   [AQP_gui.m lines 17554-17658] ----------------------------------------------
function [rawSpectra_1stDer ppn]=apply_1stDer(rawSpectra,inp)
% add inp to set detailed settings with Salvitzky-Golay filtering
if false
    
    L=load('C:\work\JDSU\ExplosiveDetectEquipment\EDE_lib\effects_SGolay\ATetc\Atrainpketc_wWVL_wRawSpectra-Direct_Absorbance_1700_xls_pp1-1stDer_pp2-SNV_nvar121_EDE-all_ncls16_nsampT818_addNMs_w10samples_Add2NMs-Baseline_CP.mat');
    clsnumMeOH=strmatch('MeOH',L.clistclslabel,'exact');
    loc_MeOH=find(L.AclassinfoT==clsnumMeOH);
    
    rawSpectra=L.RawSpectra(loc_MeOH,:);
     inp.SG_scheme='1stDerSGDiederick';   % '1stDerSGDiederick'  by Diederick  %  'SG1st_AH' by Andy Hulse
%     inp.SG_scheme='SG1st_AH';
    %inp.SG_weight=[0.1 0.3 0.5 0.3 0.1];
%         inp.SG_weight=[1 1 1 1 1];
%               inp.SG_weight=[];

    inp.DN=1;inp.poly_order=3;inp.width=5; 
%     inp.SG_weight=[1 1 1 1 1];
    inp.fig_yes=1;
    [rawSpectra_1stDer ppn]=apply_1stDer(rawSpectra,inp);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% apply 1st Der 
%         pp2.type='SG_1st';   
%         pp2.poly_order=3;
%         pp2.width=5;         % Note: CP suggest to use 5 instead of 7 for 1stDer
ppn.poly_order=inp.poly_order;
ppn.width=inp.width;
try
ppn.DN=inp.DN;
catch
ppn.DN=1;     % this is a function called "apply_1stDer"
end


switch inp.SG_scheme
    case 'SG1st_AH'
ppn.type='SG_1st';
rawSpectra_1stDer=[];
% rawSpectra_SNV_sgolayfilt=[];

for irow=1:length(rawSpectra(:,1))
    % you must use Column Vector !!!
    ea_rawSpectra_1stDer = loc_preprocess(rawSpectra(irow,:),ppn);

    rawSpectra_1stDer=[rawSpectra_1stDer;row_always( ea_rawSpectra_1stDer)];
    
%    ea_rawSpectra_SNV_sgolayfilt= sgolayfilt(rawSpectra_SNV(irow,:),pp2.poly_order,pp2.width);
%     rawSpectra_SNV_sgolayfilt=[rawSpectra_SNV_sgolayfilt;ea_rawSpectra_SNV_sgolayfilt];

end
    case '1stDerSGDiederick'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   savitzkyGolayFilt(X,N,DN,F) filters the signal X using a Savitzky-Golay 
%   (polynomial) filter.  The polynomial order, N, must be less than the
%   frame size, F, and F must be odd.  DN specifies the differentiation
%   order (DN=0 is smoothing). For a DN higher than zero, you'll have to
%   scale the output by 1/T^DN to acquire the DNth smoothed derivative of
%   input X, where T is the sampling interval. The length of the input X
%   must be >= F.  If X is a matrix, the filtering is done on the columns
%   of X.

% savitzkyGolayFilt(X,N,DN,F,W) specifies a weighting vector W with 
%     length F containing real, positive valued weights employed during the 
%     least-squares minimization. If not specified, or if specified as 
%     empty, W defaults to an identity matrix. 
ppn.type=inp.SG_scheme;
try
ppn.SG_weight=inp.SG_weight;
catch
ppn.SG_weight=[];  % use default of identity matrix ( all ones )  
end

rawSpectra_1stDer=[];

for irow=1:length(rawSpectra(:,1))
    % Note that the original output need to be multiplied by "-1"
ea_rawSpectra_1stDer_orig=-1*savitzkyGolayFilt(rawSpectra(irow,:),ppn.poly_order,ppn.DN,ppn.width,ppn.SG_weight);
WL_range_kept=[(ppn.width-1)/2+1:length(ea_rawSpectra_1stDer_orig)-(ppn.width-1)/2];
ea_rawSpectra_1stDer=ea_rawSpectra_1stDer_orig(:,WL_range_kept);

% [b,g] = sgolay(...) returns the matrix g of differentiation filters. 
% Each column of g is a differentiation filter for derivatives of order p-1 
% where p is the column index. 
% Given a signal x of length f, you can find an estimate of the pth order derivative, xp, of its middle value from:
% xp((f+1)/2) = (factorial(p)) * g(:,p+1)' * x



    rawSpectra_1stDer=[rawSpectra_1stDer;row_always( ea_rawSpectra_1stDer)];

end


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try 
    if inp.fig_yes
    figure;hold on;
       plot(rawSpectra_1stDer'); 
       title(strrep(inp.SG_scheme,'_','\_'))
    end
end
end


%% ----- apply_2ndDer   [AQP_gui.m lines 17662-17686] ----------------------------------------------
function [rawSpectra_2ndDer ppn]=apply_2ndDer(rawSpectra)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% apply 2nd Der 

%           type: 'SG_2nd'
%     poly_order: 3
%          width: 7
         
ppn.type='SG_2nd';
ppn.poly_order=3;
ppn.width=7;
rawSpectra_2ndDer=[];
% rawSpectra_SNV_sgolayfilt=[];

for irow=1:length(rawSpectra(:,1))
    % you must use Column Vector !!!
    ea_rawSpectra_2ndDer = loc_preprocess(rawSpectra(irow,:),ppn);

    rawSpectra_2ndDer=[rawSpectra_2ndDer;row_always( ea_rawSpectra_2ndDer)];
    
%    ea_rawSpectra_SNV_sgolayfilt= sgolayfilt(rawSpectra_SNV(irow,:),pp2.poly_order,pp2.width);
%     rawSpectra_SNV_sgolayfilt=[rawSpectra_SNV_sgolayfilt;ea_rawSpectra_SNV_sgolayfilt];

end
end


%% ----- apply_NstDer   [AQP_gui.m lines 17690-17769] ----------------------------------------------
function [rawSpectra_NstDer ppn]=apply_NstDer(rawSpectra,inp)
% similar to apply_1stDer but generalize to Nst derivatives
%  [B,G] = sgolay(...) returns the matrix G of differentiation filters. % sgolay operate in dir transpose to our convention
%     Each column of G is a differentiation filter for derivatives of order % sgolay operate in dir transpose to our convention
%     P-1 where P is the column index.  Given a length FRAMELEN signal X, an
%     estimate of the P-th order derivative of its middle value can be found
%     from:
%  
%                       ^(P)
%                       X((FRAMELEN+1)/2) = P!*G(:,P+1)'*X
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if false
     
     Li=load('C:\work\JDSU\ModelsTransferMLtool\Test_NstDer\ATsaConc\Atrainpketc_saConc_Orig_CS_pp1-none_pp2-none_nsamp153_wRawSpectra_nvar84_wvl_1162-end.mat');
     pp1='4thDerSGFL11[PO4]';
     inp.SG_scheme= 'NstDerSGFL'   ;
     inp.DN=4;
     inp.poly_order=4;
     inp.width=11;
     [rawSpectra_NstDer ppn]=apply_NstDer(Li.RawSpectra,inp);
     figure;hold on;
     plot(rawSpectra_NstDer','m-*');
     title(pp1);
     %===========================================
     % by using PLS toolbox's savgol
     
     %Example: if (y) is a 5 by 100 matrix then savgol(y,11,3,1) gives a
     %  5 by 100 matrix of first-derivative row vectors resulting from an
     %  11-point cubic Savitzky-Golay smooth of each row of (y).
     %
     %I/O: [y_hat,D] = savgol(y,width,order,deriv,options);
     %I/O: savgol demo
     width=11;
     order=4;
     deriv=4;
     Li=load('C:\work\JDSU\ModelsTransferMLtool\Test_NstDer\ATsaConc\Atrainpketc_saConc_Orig_CS_pp1-none_pp2-none_nsamp153_wRawSpectra_nvar84_wvl_1162-end.mat');
     [y_hat,D] = savgol(Li.RawSpectra,width,order,deriv);
     % plot(y_hat','c-O');
      plot(y_hat(:,6:79)','b-O');
     
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check if inp.poly_order is at least equal or larger than DN
if inp.poly_order<inp.DN
    error('poly_order should be at least equal or larger than DN i.e. DNthDer')
    
else
    [~,g] = sgolay(inp.poly_order,inp.width);% sgolay operate in dir transpose to our convention
    x=rawSpectra';  % sgolay operate in dir transpose to our convention
    DN=inp.DN;
    dt=1;
    
    %     dx = zeros(length(x),DN+1);
    %     for p=0:DN
    %         dx(:,p+1) = conv(x, factorial(p)/(-dt)^p * g(:,p+1), 'same');
    %     end
    %         rawSpectra_NstDer=dx(ceil(inp.width/2): end-(floor(inp.width/2)), end  )';
    
    nsamp=length(rawSpectra(:,1));
    
    dx = zeros(length(x(:,1)),nsamp);
    p=DN;
    for isamp=1:nsamp
        dx(:,isamp)= conv(x(:,isamp), factorial(p)/(-dt)^p * g(:,p+1), 'same');
    end
    rawSpectra_NstDer=dx(ceil(inp.width/2): end-(floor(inp.width/2)),:)';% sgolay operate in dir transpose to our convention
    ppn=inp.SG_scheme;
    
    
end








disp('done with apply_NstDer()')
end


%% ----- apply_PP_on_RawSpectra   [AQP_gui.m lines 17773-17817] ------------------------------------
function [ out   out_alt] =apply_PP_on_RawSpectra(allWL_rawSpectra_orig,inp)
% see also: pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP
% see also: prep_allData_WCR_wvl_calib_fVS
% see also: test_ssds_method_apply_PP
% see also : preprocess_NIR_spectra (old version of this function)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false

    cc;
    inp.PP_methods.pp1='SNV';inp.PP_methods.pp2='1stDerSGFL5[PO2]';

    pfn='C:\work\JDSU\Test_ACP\various_Classifications\CARE\Data_fVS\allScans_Chang_CARE_fVS_Nov22.mat';
    L=load(pfn);
    all_RS=cat(1,L.allScans.absorbanceStd );   % new capability from new version Matlab
    
    Atrainpk_PPd=apply_PP_on_RawSpectra(all_RS,inp);

    figure;plot(all_RS','b');
    figure;plot(Atrainpk_PPd','r');
    %------------------------------------------------------------------------------------
    % following is a popular PP scheme used by CMH
    inp.PP_methods.pp1='1stDerSGFL7[PO2]';inp.PP_methods.pp2='SNV';

    
    
    


end
  %========================================================================
    pp1=inp.PP_methods.pp1;
    % for Tset, do not provide "inp" but need to output "out_MSC"
    [rawSpectra_aftPP1 spp1 out_MSC_PP1]=preprocess_NIR_spectra(allWL_rawSpectra_orig,pp1);     % to deal with MSC, updated Sept 22, 2020
    spp1=inp.PP_methods.pp1;
    
    pp2=inp.PP_methods.pp2;
   % for Tset, do not provide "inp" but need to output "out_MSC" 
    [rawSpectra_aftPP2 spp2 out_MSC_PP2]=preprocess_NIR_spectra(rawSpectra_aftPP1,pp2);           % to deal with MSC, updated Sept 22, 2020
    spp2=inp.PP_methods.pp2;
    
    rawSpectra_aftPP=rawSpectra_aftPP2;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=rawSpectra_aftPP;
out_alt.rawSpectra_aftPP1=rawSpectra_aftPP1;   % after pp1 but before pp2
end


%% ----- apply_SNV   [AQP_gui.m lines 17821-17854] -------------------------------------------------
function [rawSpectra_SNV ppn]=apply_SNV(rawSpectra)
% see also: test_ssds_method_apply_PP  bsxfun_example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vectorized_yes=1;

% apply 'SNV' preprocess scheme
ppn.type='SNV';
ppn.poly_order=[];
ppn.width=[];

if vectorized_yes
    RS_SNV=transpose(auto(transpose(rawSpectra))) ;
    rawSpectra_SNV=RS_SNV;
    %
    % std_RS=col_always(std(transpose(rawSpectra)));
    % mean_RS=col_always(mean(transpose(rawSpectra)));
    % RS_mncn=rawSpectra-mean_RS;
    % RS_SNV=RS_mncn/std_RS;
    %
    % figure;plot(rawSpectra','b');
    % figure;plot(RS_mncn','c');
    % figure;plot(RS_SNV','r');
    %
else
    rawSpectra_SNV=[];
    for irow=1:length(rawSpectra(:,1))
        ea_rawSpectra_SNV = loc_preprocess(rawSpectra(irow,:),ppn);
        rawSpectra_SNV=[rawSpectra_SNV;ea_rawSpectra_SNV];

    end

end
end


%% ----- auto   [AQP_gui.m lines 17970-17989] ------------------------------------------------------
function [ax,mx,stdx] = auto(x)
%AUTO Autoscales matrix to mean zero unit variance
%  Autoscales a matrix (x) and returns the resulting matrix (ax)
%  with mean-zero unit variance columns, a vector of means (mx) 
%  and a vector of standard deviations (stdx) used in the scaling.
%
%I/O:  [ax,mx,stdx] = auto(x);
%
%See also: MDAUTO, MDMNCN, MDRESCAL, MDSCALE, MNCN, SCALE, RESCALE
% see also: bsxfun_example
%================================================================
%Copyright Eigenvector Research, Inc. 1991-98
%Modified 11/93
%Checked on MATLAB 5 by BMW  1/4/97

[m,n] = size(x);
mx    = mean(x);
stdx  = std(x);
ax    = (x-mx(ones(m,1),:))./stdx(ones(m,1),:);
end


%% ----- cPP1_AQPlite_MN_PRO   [AQP_gui.m lines 17993-18009] ---------------------------------------
function out=cPP1_AQPlite_MN_PRO()
% used in AQP_gui and cover all pretreatments in MN PRO
% 'Multi', 0  --> can only pick one
% for AQP and AQPlite, Feb2, 2020
theCell_1P=cellstr("1stDerSGFL"+[5:2:13]'+"[PO2]"+"{PRO}")  ;
theCell_2P=cellstr("2ndDerSGFL"+[5:2:13]'+"[PO2]"+"{PRO}")  ;

theCell_1=cellstr("1stDerSGFL"+[5:2:13]'+"[PO2]")  ;
theCell_2=cellstr("2ndDerSGFL"+[5:2:13]'+"[PO2]")  ;

theCell_CH={'SNV';'SGw5';'2ndDerSGFL9[PO3]'};   % added SNV for Cristina, Chang 0324, 2020

theCell=[theCell_1P;theCell_2P;theCell_1;theCell_2;theCell_CH];
 
   [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 0,'MaxPerColumn',5); % 'Multi', 0  --> can only pick one
   out=theChosenAna;
end


%% ----- cPP1_AQPpro_CH   [AQP_gui.m lines 18013-18034] --------------------------------------------
function out=cPP1_AQPpro_CH()
% used in AQP_gui and cover all pretreatments in AQP(pro) suggested by CH
% % 'Multi', 1 --> can pick more than one
% for AQP(pro), Feb3, 2020
%
% theCell_1P=cellstr("1stDerSGFL"+[5:2:13]'+"[PO2]"+"{PRO}")  ;
% theCell_2P=cellstr("2ndDerSGFL"+[5:2:13]'+"[PO2]"+"{PRO}")  ;
theCell_0=cellstr("0thDerSGFL"+[5:2:9]'+"[PO2]")  ;
theCell_1=cellstr("1stDerSGFL"+[7:2:11]'+"[PO2]")  ;
theCell_2=cellstr("2ndDerSGFL"+[9:2:13]'+"[PO2]")  ;
% theCell_CH={'SGw5';'0thDerSGFL5[PO3]'};
theCell_CH={'SNV';'SGw5';'0thDerSGFL5[PO3]'};  % add 'SNV for Cristina

% theCell_CH={'SGw5';'2ndDerSGFL9[PO3]'};

theCell=[theCell_0;theCell_1;theCell_2;theCell_CH];
 
%    [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 0,'MaxPerColumn',3); 
      [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 1,'MaxPerColumn',3); % 'Multi', 1 --> can pick more than one

   out=theChosenAna;
end


%% ----- cab   [AQP_gui.m lines 18038-18079] -------------------------------------------------------
function cab(varargin)

% This function closes all figures currently open EXCEPT for
% those listed as arguments.  'cab' stands for 'close all but'.
% 
% Usage:
%       cab figure_handle1 figure_handle2 ...
%       cab(figure_handle1, figure_handle2, ...)
%       cab('last') % or also:  cab last
%
%   - The 'last' option closes all figures except the last one opened.
%   - Calling 'cab' with no arguments is a convenient
%     alternative to 'close all'
%
% Example:
%   figure(5)
%   figure(7)
%   figure(9)
%   figure(11)
%   cab(7, 11)  % or also:  cab 7 11
%  cab([7 3])   % this also work !!!

% all_figs = findall(0, 'type', 'figure');  % Uncomment this to include ALL windows, including those with hidden handles (e.g. GUIs)
all_figs = findobj(0, 'type', 'figure');
figs2keep = [];
for i = 1:nargin
    if ischar(varargin{i})
        if strcmp(varargin{i}, 'last')
            figs2keep = all_figs(1);
            %figs2keep = gcf;
        else
            % In this case, function was called as follows:  cab 1 2 3
            figs2keep = [figs2keep, str2num(varargin{i})];
        end
    else
        % In this case, function was called as follows:  cab(1, 2, 3)
        figs2keep = [figs2keep, varargin{i}];
    end
end

delete(setdiff(all_figs, figs2keep))
end


%% ----- catstruct   [AQP_gui.m lines 18211-18357] -------------------------------------------------
function A = catstruct(varargin)
% CATSTRUCT - concatenate structures
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%   If a fieldname occurs more than once in the argument list, 
%   only the FIRST (Not the last !!) occurence is used, and the fields are alphabetically sorted.
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
%   X = CATSTRUCT(S1,S2,S3,...) concates the structures S1, S2, ... into one
%   structure X. 
%
%   Example:
%     A.name = 'Me' ; 
%     B.income = 99999 ; 
%     X = catstruct(A,B) 
%     % -> X.name = 'Me' ;
%     %    X.income = 99999 ;
%
%   CATSTRUCT(S1,S2,'sorted') will sort the fieldnames alphabetically.
%
% ??????????????????????????????????????????????????????????????????????????
% ===============================================================================
%   only the FIRST (Not the last !!) occurence is used, and the fields are alphabetically sorted.
%   following statement from author seems wrong ???
%   If a fieldname occurs more than once in the argument list, only the last
%   occurence is used, and the fields are alphabetically sorted.
% ===============================================================================
%   To sort the fieldnames of a structure A use:
%     A = CATSTRUCT(A,'sorted') ;
%
%   To concatenate two similar array of structs use simple concatenation:
%     A = dir('*.mat') ; B = dir('*.m') ; C = [A ; B] ;
%
%   When there is nothing to concatenate, the result will be an empty
%   struct (0x0 struct array with no fields). 
%
%   See also CAT, STRUCT, FIELDNAMES, STRUCT2CELL

% for Matlab R13 and up
% version 2.2 (oct 2008)
% (c) Jos van der Geest
% email: jos@jasen.nl

% History
% Created:  2005
% Revisions
%   2.0 (sep 2007) removed bug when dealing with fields containing cell
%                  arrays (Thanks to Rene Willemink) 
%   2.1 (sep 2008) added warning and error identifiers
%   2.2 (oct 2008) fixed error when dealing with empty structs (Thanks to
%                  Lars Barring)
%e.g. 
if false
    
cc    
s1.f1=1;s1.f2=2; s2.f3=3;s2.f4=4;
s=catstruct(s1,s2)
%-----------------------------------
%   only the FIRST (Not the last !!) occurence is used, and the fields are alphabetically sorted.

cc    
s1.f1=1;s1.f2=2; s2.f1=3;s2.f4=4;
s=catstruct(s1,s2)
%-----------------------------------
%   only the FIRST (Not the last !!) occurence is used, and the fields are alphabetically sorted.

cc    
s1.f1=1;s1.f2=2; s2.f3=3;s2.f2=4;
s=catstruct(s1,s2)
%-----------------------------------
%   only the FIRST (Not the last !!) occurence is used, and the fields are alphabetically sorted.

cc    
s1.f1=1;s1.f2=2; s2.f1=3;s2.f2=4;
s=catstruct(s1,s2)

%-----------------------------------
%   only the FIRST (Not the last !!) occurence is used, and the fields are alphabetically sorted.

cc    
s1.f1=1;s1.f2=2; s2.f1=3;s2.f2=4;
s=catstruct(s2,s1)




end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = nargin ;

% error(nargchk(1,Inf,N)) ;
narginchk(1,N);



if ~isstruct(varargin{end}),
    if isequal(varargin{end},'sorted'),
        sorted = 1 ;
        N = N-1 ;
        if N < 1,
            A = struct([]) ;
            return
        end
    else
        error('catstruct:InvalidArgument','Last argument should be a structure, or the string "sorted".') ;
    end
else
    sorted = 0 ;
end

FN = cell(N,1) ;
VAL = cell(N,1) ;

for ii=1:N,
    X = varargin{ii} ;
    if ~isstruct(X),
        error('catstruct:InvalidArgument',['Argument #' num2str(ii) ' is not a structure.']) ;
    end
    if ~isempty(X),
        % empty structs are ignored
        FN{ii} = fieldnames(X) ;
        VAL{ii} = struct2cell(X) ; 
    end
end

FN = cat(1,FN{:}) ;
VAL = cat(1,VAL{:}) ;
[UFN,ind] = unique(FN) ;

if numel(UFN) ~= numel(FN),
    % warning('catstruct:DuplicatesFound','Duplicate fieldnames found. Last value is used and fields are sorted') ;
     warning('catstruct:DuplicatesFound','Duplicate fieldnames found. FIRST value ( Not Last !!! ) is used and fields are sorted') ;

    sorted = 1 ;
end

if sorted,
    VAL = VAL(ind) ;
    FN = FN(ind) ;
end

if ~isempty(FN),
    % This deals correctly with cell arrays
    A = cell2struct(VAL, FN);
else
    A = struct([]) ;
end
end


%% ----- cell2csv   [AQP_gui.m lines 18371-18410] --------------------------------------------------
function cell2csv(filename,cellArray,delimiter)
% Writes cell array content into a *.csv file.
% 
% CELL2CSV(filename,cellArray,delimiter)
%
% filename      = Name of the file to save. [ i.e. 'text.csv' ]
% cellarray    = Name of the Cell Array where the data is in
% delimiter = seperating sign, normally:',' (it's default)
%
% by Sylvain Fiedler, KA, 2004
% modified by Rob Kohr, Rutgers, 2005 - changed to english and fixed delimiter
% see also  xlswrite ATsaConc2XLSX_CXL impcell2csv  
if nargin<3
    delimiter = ',';
end

datei = fopen(filename,'w');
for z=1:size(cellArray,1)
    for s=1:size(cellArray,2)
        
        var = eval(['cellArray{z,s}']);
        
        if size(var,1) == 0
            var = '';
        end
        
        if isnumeric(var) == 1
            var = num2str(var);
        end
        
        fprintf(datei,var);
        
        if s ~= size(cellArray,2)
            fprintf(datei,[delimiter]);
        end
    end
    fprintf(datei,'\n');
end
fclose(datei);
end


%% ----- cell2mat_ccstr2cstr   [AQP_gui.m lines 18414-18432] ---------------------------------------
function cstr=cell2mat_ccstr2cstr(ccstr)
% this only work for column cell of cstr
% see also: diagnose_misP_iACPmp
if false
    
    ccstr={{'abc';'cd'};{'cdcdad';'fdsafdas';'tyrr'}};
    cstr=cell2mat_ccstr2cstr(ccstr)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(ccstr{1})
    
    cstr= cat(1,ccstr{:});
elseif ischar(ccstr{1})
    cstr=ccstr;
else
    error('can not handle the data type of ccstr')
end
end


%% ----- check_Atrainpk_inside_saConc_vs_root   [AQP_gui.m lines 18476-18493] ----------------------
function out=check_Atrainpk_inside_saConc_vs_root(L)
% see also: PLS_wTcv_StandAlone_AQPpu
if isfield(L,'PLS')
    Atrainpk_from_saConc_Tset= cat(1, L.PLS.Tset.saConc.Atrainpk);
    Atrainpk_root=L.Atrainpk;
    Atrainpk_from_saConc_Pset= cat(1, L.PLS.Pset.saConc.Atrainpk);
    Apred_root=L.Apred;
    if ~isSAME_2Matrix(Atrainpk_root,Atrainpk_from_saConc_Tset) ||  ~isSAME_2Matrix(Apred_root,Atrainpk_from_saConc_Pset)
        warning('Mismatch between Atrainpk or Apred vs that inside saConc for Tset or Pset');
        out=0;
        return
    else
        out=1;
        return
    end
    error('should Not reach this point ? for check_Atrainpk_inside_saConc_vs_root');
end
end


%% ----- clistfilename2AT_AQP   [AQP_gui.m lines 18498-19020] --------------------------------------
function [SAT pathfname_SAT inp out_clistfilename2AT]=clistfilename2AT_AQP(clistfilename,keyword4TP,wksheet,inp)
% this function inside AQP_gui.m  is called by --> prep_IDRC_shootout_MLtool
%
% fix for CS set with NaN and XSmst also with NaN, after 1007, 2020
% pulled out from subfunction of prep_IDRC_shootout_MLtool and become an independent function
% implement Spectra_Avg_Method ['mean' (default for AQPlite), 'median', 'all' (default for AQP) ]
% parsing of orig CS to CS with Ref vs XSmst, this is the location that ID_XRS can be used to extract XSmst
% 
% this function will call --> AQP_Apply_Spectra_Avg
% SATnew= AQP_Apply_Spectra_Avg(SATnew,inp4ASA);
% 
% activate_Spectra_Mean_woXRS_yes
% % fix for CS set with NaN and XSmst also with NaN, after 1007, 2020
% % inp.ID_XRS was collected inside --> XLSX2MAT_AQP.m (this is 3 levels up in calling-from functions)
%  error('locations of XSmst not a subset of all rows with NaN ? this code is not ready to handle XSmst with ref values yet')
%====================================================================
    % fix input xlsx file with additional data to right of wvl block by new approach --> [idx_wvl loc_wvl]= find_wvl_range_cheading(cheading)
    % added this Nov 9, 2020
%====================================================================
% revisit this Apr 14, 2023
% to fix PRO (MNP) replicates scans' filename issues with ending like
% "~-#.sam" that cause them to be treated as physically different samples
% with different concentrations 
% --> pls search for AclabelT or "~-#.sam"
%-------------------------------------------------
% add following Apr 17, 2023 or calling AQP_rm_replicate_seq_sam
% fix "~_#.sam" or "~-#.sam" style bugs that cause replicates treated as physically different samples
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% very important !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% run AQP_rm_replicate_seq_sam BEFORE creating saConc
% see also: AQP_Apply_Spectra_Avg
% fix AclabelT Before creating saConc4SAT_T(isamp).SampleName
%============================================================================
try
Spectra_Avg_Method=inp.Spectra_Avg_Method;
catch
%  Spectra_Avg_Method='Spectra_Avg_Mean';   %  'Spectra_Avg_Mean'    'Spectra_Avg_Median'  'Spectra_Avg_All'
Spectra_Avg_Method='Spectra_Avg_All';   %  'Spectra_Avg_Mean'    'Spectra_Avg_Median'  'Spectra_Avg_All'

end

   filename_wo_ext= fileparts_name_wo_ext(clistfilename);
     locfile4Cal=setdiff(strmatch(keyword4TP,filename_wo_ext), strmatch('XRSmst',filename_wo_ext)) ;
     if ~isempty(wksheet)
         try
             [NUM,TXT,RAW]=xlsread(clistfilename{locfile4Cal},wksheet);
         catch
             [NUM,TXT,RAW]=xlsread(clistfilename{locfile4Cal});
            
             
         end
     else
         [NUM,TXT,RAW]=xlsread(clistfilename{locfile4Cal});
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % trim all NaN col or row
     % trim all NaN rows
     loc_allNaN_row=[];
     for ir=1:length(RAW(:,1))
         eaRAW=RAW(ir,:);
         idx_num=all(cellfun(@(x) isnumeric(x),eaRAW));
         if idx_num
             allNaN= all(cellfun(@(x) isnan(x),eaRAW));
             if  allNaN
                 loc_allNaN_row=[loc_allNaN_row;ir];
             end
         end
     end
     % trim all NaN cols
     loc_allNaN_col=[];
     for ic=1:length(RAW(1,:))
         eaRAW1=RAW(:,ic);
         idx_num=all(cellfun(@(x) isnumeric(x),eaRAW1));
         if idx_num
             allNaN= all(cellfun(@(x) isnan(x),eaRAW1));
             if  allNaN
                 loc_allNaN_col=[loc_allNaN_col;ic];
             end
         end
     end
     
     RAW(loc_allNaN_row,:)=[];
     RAW(:,loc_allNaN_col)=[];
     
     
    % fix input xlsx file with additional data to right of wvl block by new approach --> [idx_wvl loc_wvl]= find_wvl_range_cheading(cheading)
    % added this Nov 9, 2020
    cheading=RAW(1,:);
     [idx_wvl   loc_wvl  ]= find_wvl_range_cheading(cheading);
    locNOT_NaN_NUM=find(~isnan(NUM(1,:)));
     
     loc_wvl_NUM= loc_wvl - (  loc_wvl(1) - locNOT_NaN_NUM(1) );
     
    RAW(:,loc_wvl(end)+1:end)=[];
    TXT(:,loc_wvl(end)+1:end)=[];
    TXT=TXT(1,:);
     TXT=remove_empty_cell(TXT);                        % added Nov 6, 2020
     NUM(:, loc_wvl_NUM(end)+1:end)=[];

     if false  % block old method that is less clean
         %========================================================
         loc_Instrument=find(strfind_cstr('Instrument',TXT(1,:)));% added Nov 6, 2020
         if ~isempty(loc_Instrument)
             RAW(:,loc_Instrument:end)=[];
             locNaN_NUM= find(isnan(NUM(1,:)));
             if ~isempty( locNaN_NUM)
                 NUM(:, locNaN_NUM(1):end)=[];
             end
         end
         %=================================================
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         TXT=TXT(1,:);
         if ~isempty(loc_Instrument)                                     % added Nov 6, 2020
             TXT(loc_Instrument:end)=[];
             TXT=remove_empty_cell(TXT);                        % added Nov 6, 2020
         end
     end
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % if there were NaN in RS, this will make all column headings (TXT) became
     % empty till the last column that still contain NaN
     % 
     if ~isempty(find(cellfun(@(x) isempty(x),TXT)))
         loc_empty_TXT=find(cellfun(@(x) isempty(x),TXT));
         loc_Real_RS_start=loc_empty_TXT(1);
         nvar_real=length(RAW(1,:))-loc_Real_RS_start+1;
         RawSpectra_ifile_checking=NUM(2:end,end-nvar_real+1:end);
         
         if ~isempty( find(isnan(RawSpectra_ifile_checking(:))) )
             N_NaN=length( find(isnan(RawSpectra_ifile_checking(:))));
             error([num2str(N_NaN),' spectra readings were NaN inside RawSpectra'])
         end
     end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     nvar=length(RAW(1,:))-length(TXT);
     
%      nCol_Str_Heading=length(TXT(1,:));
%      nCol_All=length(RAW(1,:));
%      nCol_NUM_actual=nCol_All-nCol_Str_Heading;
%      nCol_NUM_rm=length(NUM(1,:))-nCol_NUM_actual;
%     NUM(:,1:nCol_NUM_rm)=[];
     
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    wvl_orig_ifile=NUM(1,end-nvar+1:end);
    RawSpectra_ifile=NUM(2:end,end-nvar+1:end);
    % check whether there is still NaN in RawSpectra
    if ~isempty(find(isnan(RawSpectra_ifile(:))))
        error('there are still NaN in RawSpectra')
    end
    
    try
    nsamp=length(RawSpectra_ifile(:,1));
    catch
        disp('halt here')
    end
    %loc_AnaName_xls=strmatch(inp.AnaName,TXT,'exact');
%     inp.handles.sAnalyte
try
    if  inp.StandAlone_Run_yes
        loc_AnaName_xls=setdiff([1:length(TXT)],[strmatch_CI('ID',TXT) ,strmatch_CI('info',TXT)]);
        if length(loc_AnaName_xls)==1
        inp.AnaName=TXT{1,loc_AnaName_xls};
        else
        error('Non-unique "loc_AnaName_xls" found ???')  
        end
    else
        CurAna=inp.handles.sAnalyte.String{inp.handles.sAnalyte.Value};
        loc_AnaName_xls=find(strcmp(CurAna,TXT));
        inp.AnaName=TXT{1,loc_AnaName_xls};
    end
catch
    CurAna=inp.handles.sAnalyte.String{inp.handles.sAnalyte.Value};
    loc_AnaName_xls=find(strcmp(CurAna,TXT));
    inp.AnaName=TXT{1,loc_AnaName_xls};
end
%     loc_AnaName_xls=inp.Col4Ref;  % hard-coded to 2nd column


%     loc_AnaName_xls=find(strcmp(CurAna,TXT));
%      inp.AnaName=TXT{1,loc_AnaName_xls};
     
     
     
%     siaCol4Ref= string(inp.handles.Col4Ref.String);
%     loc_handles_Col4Ref= find(endsWith(siaCol4Ref,num2str(loc_AnaName_xls)));
%     inp.handles.Col4Ref.Value=loc_handles_Col4Ref;% change "Col4Ref=' in GUI to matching entry
    
    try  % added this try because of running LoadMst_xlsx4AQP
    inp.handles.Col4Ref.String(2:end)='';
    firstEntry=inp.handles.Col4Ref.String{1};
    firstEntry=[find_keyword_between_markers(firstEntry,'','='),'=',num2str(loc_AnaName_xls)];
    inp.handles.Col4Ref.String{1}=firstEntry;
    inp.handles.Col4Ref.Value=1;% this should always be "1"
    end  % added this try because of running LoadMst_xlsx4AQP
    
    
     inp.Col4Ref=loc_AnaName_xls;
     
    if isempty(loc_AnaName_xls) && strcmp(keyword4TP,'Val')
        error('can not handle this case yet')
%         Conc_T=repmat(NaN,size(NUM(2:end,1)));
    else
        try
            Conc_T=cell2mat(RAW(2:nsamp+1,loc_AnaName_xls));
            
            if ischar(Conc_T) && strcmp_CI(Conc_T(1,:),'NaN')
                Conc_T=repmat(NaN,[length(Conc_T(:,1)) 1]);
                loc_NaN=[1:length(Conc_T)]';
            elseif  isnumeric(Conc_T) && ~isempty(inp.ID_XRS)
                % this is the case that ID_XRS were used to find loc_NaN when XSmst were filled with Ref values
                loc_AclabelT_all=strmatch('ID',TXT,'exact'); % hard-coded for heading for AclabelT
                cRaw4ID_all=RAW(2:end,loc_AclabelT_all);  % this is cell of "double" not str !!!
                AclabelT_all=cellfun(@(x) num2str(x),cRaw4ID_all,'un',0);% convert cRaw4ID to cell of char vectors
                loc_NaN_or_XRS=find(is_belong2subgrp_cstr(AclabelT_all,inp.ID_XRS));
                loc_NaN= loc_NaN_or_XRS; % this is for old codes to be able to still go thru
                %checking to make sure order in both are the same
                if isequal(AclabelT_all(loc_NaN_or_XRS),inp.ID_XRS)
                    loc_numericRef=find(~is_belong2subgrp_cstr(AclabelT_all,inp.ID_XRS));
                    %                    Conc_T(loc_NaN)=[];
                    %                    AclabelT_tmp(loc_NaN)=[];
                    clear Conc_T;
                    Conc_T_all=   cell2mat(RAW(2:nsamp+1,loc_AnaName_xls));  % this will be used to build CS with XSmst included
                    Conc_T_tmp=zeros(size(Conc_T_all));
                    Conc_T_tmp( loc_numericRef)=Conc_T_all( loc_numericRef);
                    Conc_T_tmp( loc_NaN_or_XRS)=repmat(NaN,size(loc_NaN_or_XRS));
                    Conc_T=Conc_T_tmp;    % Conc_T is the one that locations of XSmst filled with NaN
                    
                   %check to see if any of Conc_T has not been updated
                   if length(find(Conc_T==0))>0
                       error('some values in Conc_T not updated ?')
                   end
                   
                   
                 else
                     error('order in inp.ID_XRS  vs XSmst not same')
                 end
                   
            else
                loc_NaN='';
            end
            
        catch
            % deal with transfer set without Ref and filled with NaN ( char 'NaN' )
            % 
            Conc_T_tmp=   RAW(2:nsamp+1,loc_AnaName_xls);
            idx_char= cellfun(@(x) ischar(x), Conc_T_tmp);
            
            Conc_T_char=cellfun(@(x) str2num(x),Conc_T_tmp(idx_char));
            if all(isnan(Conc_T_char))
               loc_NaN=find(idx_char);                         % location of CS with NaN as Ref values (potentially these will be used for XSmst)
               
            else
                error('something other than NaN found')
            end
            idx_num= cellfun(@(x) isnumeric(x), Conc_T_tmp);
            Conc_T_num=cell2mat(Conc_T_tmp(idx_num));
            loc_numericRef=find(idx_num);
            
            
            Conc_T=zeros(size(Conc_T_tmp));
            Conc_T(idx_num)=Conc_T_num;
            Conc_T(idx_char)=Conc_T_char;
        end
    end

    %check Ref values
    if exist('Conc_T_all','var') && isnumeric(Conc_T_all) && all(~isnan(Conc_T_all))
        disp('this is the case that XSmst with Ref values will be included into CS that will be based on "Conc_T_all"')
    else
        if isnumeric(Conc_T) && all(~isnan(Conc_T)) && all(Conc_T>=0)
            disp('Conc are all valid numbers')
        else
            disp('NOT all Conc are valid numbers and assume this is the case XSwoRef and filled by NaN !!!')
        end
    end
    
    loc_AclabelT=strmatch('ID',TXT,'exact'); % hard-coded for heading for AclabelT
    if isempty(loc_AclabelT)
        loc_AclabelT=strmatch('samplename',strrep(strrep(strrep(lower(TXT),'_',''),' ',''),'-',''),'exact'); % hard-coded for heading for AclabelT
        if isempty(loc_AclabelT)
            error('1st Column should be either "ID" or "SampleName" (case insensitive and can have "_" or "-" or space)');
        end
    end
    
    
    cRaw4ID=RAW(2:end,loc_AclabelT);  % this is cell of "double" not str !!!
    AclabelT=cellfun(@(x) num2str(x),cRaw4ID,'un',0);% convert cRaw4ID to cell of char vectors
    
    try
        % this is the case that ID_XRS were used to find loc_NaN when XSmst were filled with Ref values
        AclabelT=AclabelT_tmp;
        
    catch
        
        if length(AclabelT)~=length(Conc_T)
            loc_NaN= strmatch('NaN',AclabelT);
            AclabelT(loc_NaN)=[];
        end
        
    end
    
    %check again
    if length(AclabelT)~=length(Conc_T)
    error('length of AclabelT not matched with Conc')
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % try to collect Info_1 etc and create string array "AInfo_1"
    % see also: Atrainpk_assemble_CrossPredict_TP_pairs_TvsPfolders_MLtool()
    %
    if ~isempty(inp.Col4Info_1) && ~isnan(inp.Col4Info_1)
        loc_Info_1=strmatch_CI('info_1',lower(TXT),'exact'); % hard-coded for heading for Info_1
        if loc_Info_1==inp.Col4Info_1
            cInfo_1=RAW(2:end,loc_Info_1);  % this is cell of "double" not str !!!
            cAInfo_1=cellfun(@(x) num2str(x),cInfo_1,'un',0);% convert cRaw4ID to cell of str
            AInfo_1=string(cAInfo_1);      % based on string array (new since Matlab 2016b)
        else
            error('mismatch between inp.Col4Info_1 and its heading')
        end
    else
        AInfo_1='';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    pp1=inp.PP_methods.pp1;
    pp2=inp.PP_methods.pp2;
    
    loc_wl_allzeros=find_allzero_col(RawSpectra_ifile);
    if length(loc_wl_allzeros)>0  
        
        Atrainpk= RawSpectra_ifile;
        Atrainpk(:,loc_wl_allzeros)=[];
        RawSpectra_ifile=repmat(NaN,size(RawSpectra_ifile));
        
    else
        if strcmp(pp1,'none') && strcmp(pp2,'none')
            Atrainpk= RawSpectra_ifile;
        else
            [rawSpectra_aftPP1_T spp1]=preprocess_NIR_spectra(RawSpectra_ifile,pp1);
            [rawSpectra_aftPP2_T spp2]=preprocess_NIR_spectra(rawSpectra_aftPP1_T,pp2);
            Atrainpk=rawSpectra_aftPP2_T;
            
        end
    end
% figure;hold on;
% plot(Atrainpk');
% figure;hold on;
% plot(RawSpectra_ifile');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% very important !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% run AQP_rm_replicate_seq_sam BEFORE creating saConc
AclabelT=cellfun(@(x) AQP_rm_replicate_seq_sam(x),AclabelT,'un',0) ; % fix AclabelT Before creating saConc4SAT_T(isamp).SampleName

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saConc4SAT_T=SAinsert_createNew_w_seqnum(length(Conc_T));

for isamp=1:length(Conc_T)
    saConc4SAT_T(isamp).clsname=inp.AnaName;
    
    if exist('Conc_T_all','var') && isnumeric(Conc_T_all) && all(~isnan(Conc_T_all))
       %  disp('this is the case that XSmst with Ref values will be included into CS that will be based on "Conc_T_all"')
         saConc4SAT_T(isamp).Conc=Conc_T_all(isamp);
    else
        saConc4SAT_T(isamp).Conc=Conc_T(isamp);
    end
    
    saConc4SAT_T(isamp).SampleName=AclabelT(isamp);   % fix AclabelT Before creating saConc4SAT_T(isamp).SampleName
    saConc4SAT_T(isamp).Atrainpk=Atrainpk(isamp,:);
end

% LTP.PLS.Tset.saConc=saConc4SAT_T;
SAT.saConc=saConc4SAT_T;
SAT.Atrainpk=Atrainpk;
%----------------------------------------------------------------
%====================================================================
% revisit this Apr 14, 2023
% to fix PRO (MNP) replicates scans' filename issues with ending like
% "~-#.sam" that cause them to be treated as physically different samples
% with different concentrations 
% or ending like "~_#.sam" (for VS datasets)
%============================================================================
% fix "~_#.sam" or "~-#.sam" style bugs that cause replicates treated as physically different samples
%
% AclabelT=AQP_rm_replicate_seq_sam(AclabelT);
%=================================================================
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% very important !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% run AQP_rm_replicate_seq_sam BEFORE creating saConc
% AclabelT=cellfun(@(x) AQP_rm_replicate_seq_sam(x),AclabelT,'un',0) ; % run AQP_rm_replicate_seq_sam before creating saConc

%=============================================================================
SAT.AclabelT=AclabelT;
%----------------------------------------------------------------
SAT=ATsaConc_add_clistclslabel_AclassinfoT(SAT);
SAT.RawSpectra=RawSpectra_ifile;
SAT.wvl_standardize=wvl_orig_ifile;
try
SAT.AInfo_1=AInfo_1;
catch
SAT.AInfo_1='';    
end

snvar=['_nvar',num2str(length(SAT.Atrainpk(1,:)))];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(unique(cellfun(@(x) find_lastfolder(fileparts(x)),strrep(clistfilename,'\\','\'),'un',0)))==1
    ccorename=unique(cellfun(@(x) find_lastfolder(fileparts(x)),strrep(clistfilename,'\\','\'),'un',0));
    scorename=[ccorename{1}];
end
if ~isempty(wksheet)
swksheet=['_',wksheet];
else
swksheet='';    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    if isempty(loc_NaN) && length(loc_NaN) < length(Conc_T)
        
        activate_Spectra_Mean_woXRS_yes=1;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % deal  with CS without XRS_mst inside
        % implement Spectra_Avg_Method ['mean' (default for AQPlite), 'median', 'all' (default for AQP) ]
        if activate_Spectra_Mean_woXRS_yes
            if ~strcmp(Spectra_Avg_Method,'Spectra_Avg_All') && strcmp_CI(keyword4TP,'cs')
                inp4ASA.Spectra_Avg_Method=Spectra_Avg_Method;
                inp4ASA.AnaName=inp.AnaName;
                SATnew= AQP_Apply_Spectra_Avg(SAT,inp4ASA);
            else
                SATnew=SAT;
            end
        else
         SATnew=SAT;   
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
%         fname=['Atrainpketc_saConc_','(',scorename,'_',keyword4TP,')_pp1-',pp1,'_pp2-',pp2,snvar,'_nsamp',num2str(length(saConc4SAT_T)),'.mat'];
%         save(fname,'-struct','SAT');

        fname=['Atrainpketc_saConc_','(',scorename,'_',keyword4TP,')_pp1-',pp1,'_pp2-',pp2,snvar,'_nsamp',num2str(length(SATnew.saConc)),'.mat'];
        save(fname,'-struct','SATnew');

        
        disp([fname,' has been saved']);
        
        
    elseif ~isempty(loc_NaN) && length(loc_NaN) ==length(Conc_T)   % this is the case of XStrg woRef or Ref are all NaN
        if strcmp(keyword4TP,'XRS')
            sDS='XStrg_wRefNaN';
        else
            sDS='UnknownDS_wRefNaN';
        end
          fname=['Atrainpketc_saConc_','(',scorename,'_',sDS,')_pp1-',pp1,'_pp2-',pp2,snvar,'_nsamp',num2str(length(saConc4SAT_T)),'.mat'];
        save(fname,'-struct','SAT');
        disp([fname,' has been saved']);   
    else
        % parsing of orig CS to CS with Ref vs XSmst, this is the location that ID_XRS can be used to extract XSmst
        if exist('Conc_T_all','var') && isnumeric(Conc_T_all) && all(~isnan(Conc_T_all))
            SATnew=SAT;
        else

            SATnew=ATsaConc_extract_selective_samples(SAT, loc_numericRef );
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % implement Spectra_Avg_Method ['mean' (default for AQPlite), 'median', 'all' (default for AQP) ]
        if ~strcmp(Spectra_Avg_Method,'Spectra_Avg_All') && strcmp_CI(keyword4TP,'cs')
            inp4ASA.Spectra_Avg_Method=Spectra_Avg_Method;
            inp4ASA.AnaName=inp.AnaName;
            SATnew= AQP_Apply_Spectra_Avg(SATnew,inp4ASA);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fname=['Atrainpketc_saConc_','(',scorename,'_',keyword4TP,')_pp1-',pp1,'_pp2-',pp2,snvar,'_nsamp',num2str(length(SATnew.saConc)),'.mat'];
        save(fname,'-struct','SATnew');
        disp([fname,' has been saved']);
        
        %%%%%%%%%%%%%%%%%
        
       % SAT_XSwoRef=ATsaConc_extract_selective_samples(SAT,loc_NaN); % before 1007, 2020
       
       % fix for CS set with NaN and XSmst also with NaN, after 1007, 2020
       % inp.ID_XRS was collected inside --> XLSX2MAT_AQP.m (this is 3 levels up in calling-from functions)
       %  
       loc_XSmst_1=  find(is_belong2subgrp_cstr(SAT.AclabelT,inp.ID_XRS));% fix for CS set with NaN and XSmst also with NaN, after 1007, 2020
        loc_XSmst=intersect(loc_NaN,loc_XSmst_1);                                        % fix for CS set with NaN and XSmst also with NaN, after 1007, 2020
        if ~isempty(loc_XSmst)
            if isequal(loc_XSmst_1,loc_XSmst)
                SAT_XSwoRef=ATsaConc_extract_selective_samples(SAT,loc_XSmst);% fix for CS set with NaN and XSmst also with NaN, after 1007, 2020
            else
                error('locations of XSmst not a subset of all rows with NaN ? this code is not ready to handle XSmst with ref values yet')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%
            if strcmp(keyword4TP,'CS')
                sXSmst='XSmst_wRefNaN';  % transfer set from Master Instrument
            else
                sXSmst='DSwRefNaN';  % unknow Dataset with NaN as Ref values
            end
            
            if length(SAT_XSwoRef.saConc)>0
                fname_XSwoRef=['Atrainpketc_saConc_','(',scorename,'_',sXSmst,')_pp1-',pp1,'_pp2-',pp2,snvar,'_nsamp',num2str(length(SAT_XSwoRef.saConc)),'.mat'];
                save(fname_XSwoRef,'-struct','SAT_XSwoRef');
                disp([fname_XSwoRef,' has been saved']);
            else
                disp_with_border('No  XSwoRef exist');
                
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    pathfname_SAT=fname;
    try
    SAT=SATnew;  % deal with the case that CS contain RefNaN XSmst
    end
    try
    out_clistfilename2AT.fname_XSwoRef=fname_XSwoRef;
    out_clistfilename2AT.SAT_XSwoRef=SAT_XSwoRef;
    catch
     out_clistfilename2AT='';   
    end
catch
    error(['somehow ',fname,' can not be created ?']);
end
end


%% ----- copy   [AQP_gui.m lines 19762-19829] ------------------------------------------------------
function copy(x,dec,sep,lf)
    % *** handle vert separator ******************************************
    if nargin < 4
        lf = char(10);  % default is line feed (char 10)
    end
    if nargin < 3
        sep = char(9);  % default is tabulator (char 9)
    end
    if nargin < 2
        dec = '.';      % default is a period '.'
    end
    % *** string argument ************************************************
    if isa(x,'char')
        [r,c] = size(x);
        if r == 1                   % not a multi-line character array ...
            clipboard('copy',x);    % ... so just push the string into the
                                    %     clipboard
        else
            x = [x, repmat(lf,r,1)];        % append linefeed to each line
            x = reshape(x',1,r*(c+1));      % make it a single line
            clipboard('copy',x);            % push this to the clipboard
        end
    % *** numeric argument ***********************************************
    elseif isa(x,'numeric') || isa(x,'logical')
%       user can force numeric content with 'copy(double(x))'
%        if isa(x,'logical')
%            x = double(x);
%        end
        s = mat2str(x);                 % write as [.. .. ..;.. .. ..]
        s = strrep(s,'.',dec);          % replace decimal separators
        if s(1)=='['                    % it's a proper array
            s = s(2:end-1);             % remove '[' and ']'
        end
        s = strrep(s,' ',sep);          % replace spaces with tabs
        s = strrep(s,';',lf);           % replace semicolons with linefeeds
        s(end+1) = lf;                  % append a linefeed
        clipboard('copy',s);            % place resulting string in clipboard
    % *** cell argument **************************************************
    elseif isa(x,'cell')
        [nrow, ncol] = size(x);
        str = '';
        for r = 1:nrow
            for c = 1:ncol-1
                str = onecell(str, x{r,c}, sep, dec);  % treat cell, append a tab
            end
            str = onecell(str, x{r,end}, lf, dec);     % treat cell, append a linefeed
        end
        clipboard('copy',str);          % copy to clipboard
    % *** table (This is Greg's contribution. Thank you, Greg!) **********
    elseif isa(x,'table')   % table is a feature of R2013b
        xheaders = x.Properties.VariableNames;
        xrownames = x.Properties.RowNames;
        xdescr = {x.Properties.Description};
        xt = table2cell(x);
        if isempty(xrownames)
            xrownames = repmat({''},height(x),1);
        end
        xt = [xdescr,xheaders;xrownames,xt];
        if isempty(cat(2,xt{:,1}))
            xt(:,1) = [];
        end
        copy(xt);
    % *** anything else **************************************************
    else
        warning('COPY:unsupported_content', ...
            'cannot copy this kind of object.');
    end
end


%% ----- onecell   [AQP_gui.m lines 19833-19847] ---------------------------------------------------
function str = onecell(str,e,ch,dec)
    if isempty(e)
        str = [str, ch];            % copy nothing if cell is empty
    elseif isa(e,'char')
        if size(e,1) == 1           % not a multi-line char array?
            str = [str, e, ch];
        else
            str = [str, mat2str(e), ch];
        end
    elseif isa(e,'numeric') || isa(x,'logical')
        str = [str, strrep(mat2str(e),'.',dec), ch];
    else
        str = [str, '(cannot copy component)', ch];
    end
end


%% ----- copy_all_open_fig_AQP   [AQP_gui.m lines 19889-19904] -------------------------------------
function out=copy_all_open_fig_AQP(inp)

aof=find_all_open_fig;
loc_NonAQPfig=find(~arrayfun(@(x) ~isempty(x.Number),aof));
aof(loc_NonAQPfig)=[];


Path4AQPfig=tmp_folder_rm_mk('Figs4OpmModel_AQP',find_last_nonTMP_folder);
for ifig=1:length(aof)
    
savefig(aof(ifig).Number,fullfile(Path4AQPfig,['Cnt',num2str(inp.cnt),'_AQP_',num2str(aof(ifig).Number)]));

end

out.Path4AQPfig=Path4AQPfig;
end


%% ----- create_next_subfolder   [AQP_gui.m lines 19908-19940] -------------------------------------
function out=create_next_subfolder(parent_path,prefixkeyword)
% find max cnt_seq_num in parent_path and add 1 to it to create next subfolder
% updated with cap on total number of 'tmp' subfolders kept, Dec 9, 2020
% see also nextname  test_nextname
if false
    
   cc
    create_next_subfolder('C:\work\JDSU\Test_AQP\Results4PRO','tmp')
    
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ntmp_keep=2;   % internal setting % updated with cap on total number of 'tmp' subfolders kept, Dec 9, 2020

clist_sf=get_subfolder_wFullPath_wKeyword(parent_path,prefixkeyword);

if ~isempty(clist_sf)
    
    if length(clist_sf)>=Ntmp_keep  % updated with cap on total number of 'tmp' subfolders kept, Dec 9, 2020
        clist_sf_sortnat=sortnat(clist_sf);
            clist_sf_rm=clist_sf_sortnat(1:length(clist_sf)-Ntmp_keep+1);
        for irm=1:length(clist_sf_rm)
            rmdir(clist_sf_rm{irm},'s');
        end
    end
    
list_cnt_num=cellfun(@(x) find_keyword_numeric_AFTER_marker(x,prefixkeyword),clist_sf);
next_cnt_num=max(list_cnt_num)+1;
next_sf=[prefixkeyword,num2str(next_cnt_num)];
out=tmp_folder_rm_mk(next_sf,parent_path);
else
out=tmp_folder_rm_mk([prefixkeyword,'1'],parent_path);
end
end


%% ----- delsamps   [AQP_gui.m lines 20321-20362] --------------------------------------------------
function eddata = delsamps(data,samps)
%DELSAMPS Deletes samples (rows) from data matrices.
%  The inputs are the original data matrix (data) and
%  the row numbers of the samples to delete (samps).
%  The output is the edited data matrix (eddata).
%  modified by Chang Hsiung, Sept. 29, 08
%  now it also works for both column and row vector in case data is <1 x n>  or <n x 1>
%I/O: eddata = delsamps(data,samps); 
%
%  This function can also be used to delete variables
%  (columns) by operating on the matrix transpose, i.e.
%
%I/O: eddata = delsamps(data',vars)';
%
%See also: keepsamps shuffle, specedit

%Copyright Eigenvector Research, Inc. 1996-98
%Modified 11/93, 1/96

%e.g eddata=delsamps([1 2 3 4 5],[2 4])
%e.g eddata=delsamps([1 2 3 4 5]',[2 4])


[m,n]    = size(data);

if m==1 | n==1
eddata=data;
eddata(samps)=[];
    
else   
[ms,ns]  = size(samps);
if ms>ns
  samps  = samps';
  ns     = ms;
end
samps    = sort(samps);
savsamps = 1:m;
savsamps(samps) = zeros(1,ns);
savsamps = find(savsamps ~= 0);
eddata   = data(savsamps,:);
end
end


%% ----- detect_info_etc_CXL   [AQP_gui.m lines 20366-20401] ---------------------------------------
function idxOut=detect_info_etc_CXL(TXT)
% see also CabXferLite
if false
    
    TXT={'Brix_Info'  , 'info', 'info_1', 'info-2', 'info 3'  , 'info5' ,  'Info_-12'  , 'infomation', 'info_*'};
    idxOut=detect_info_etc_CXL(TXT)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TXT=strrep(TXT,' ','');  % such that it can also handle cases that there were spaces
loc_info_exact=strcmp(lower(TXT),'info');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
loc_info_etc_3= cellfun(@(x) ~isempty(x), regexp(lower(TXT), ['^info$'],'start'));  % this is same as loc_info_exact

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   
% this will only allow numeric char after info[_-]*

% the following can not handle --> 'Brix_Info_2' 
%     loc_info_etc= cellfun(@(x) ~isempty(x), regexp(lower(TXT), ['info[_-]?\d'], 'start'));  % this should work for 'info_1', 'info-1', 'info1','info'
  
  %  very important to add "^" before "info"  
    loc_info_etc= cellfun(@(x) ~isempty(x), regexp(lower(TXT), ['^info[_-]?\d'], 'start'));  % this should work for 'info_1', 'info-1', 'info1','info'

  
  
  
 % the following will allow any non-alphabetic char after info[_-]*
% loc_info_etc= cellfun(@(x) ~isempty(x), regexp(lower(TXT), ['info[_-]*[^a-z]'], 'start'));  % this should work for 'info_1', 'info-1', 'info1','info'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
idxOut=loc_info_exact|loc_info_etc;
end


%% ----- display_structure   [AQP_gui.m lines 20449-20628] -----------------------------------------
function display_structure(structure, max_array_size, start_indent_size, step_size)
%This function displays the fields
%in a structure. This is done using
%the disp function.
%Fields in structures within the structure
%are shown indented.
%Arrays will be shown if the length of the array
%is smaller than a preset value (default: 10).
%Also column vectors will be shown: they are marked
%by the ' (transpose) sign.
%Input:     -Structure
%           -Integer, the maximum length of an array that still will be displayed
%           -Integer, the size of the first indent
%           -Integer, the size of the indent
%Mark Jobse 23-07-2002
%14-08-2002 Added class and size info
%19-08-2002 Added append and split_array, removed bug: error when matrix > 2D
%15-11-2002 Added functionality to display arrays; names are now aligned as in Matlab
%18-11-2002 Removed bug when 'displaying' cells.
%27-11-2002 Removed bug when displaying int or uint arrays.
%08-01-2003 Can now also display character arrays (they were previously converted to doubles)
%11-02-2003 Can now display cell ARRAYS. Only array will be displayed. Cell is converted to 
%           a structure with each cell having a name like: 'cell1', 'cell2'...
%
% SEE ALSO: toString
if (nargin < 4)
    step_size = 3;
end

if (nargin < 3)
    start_indent_size = 1;
end

if (nargin < 2)
    max_array_size = 10;
end

if (start_indent_size < step_size) %First put the name of the structure
    name_string = inputname(1);
    disp(name_string);
    start_indent_size = start_indent_size + step_size;
end

start_indent(1:start_indent_size) = ' ';
new_start_indent_size = start_indent_size + step_size;
indent = start_indent;

%Declarations
structure_out = [];
struct_cell = [];
non_struct_cell = [];
arCellCell = [];

%Get all fields out of the structure
cell = fieldnames(structure);

%Now split those fields into structures and other fields
counter = 1;
counter2 = 1;
cellcounter = 1;
for i = 1:length(cell)
    Field = getfield(structure, cell{i});
    boolean = isstruct(Field);
    blCell = iscell(Field);
    if (boolean)
        struct_cell{counter} = cell{i};
        counter = counter + 1;
    else
        if blCell
            [new_structure, blFailed] = myCell2Struct(getfield(structure, cell{i}));
            if ~blFailed
                arCellCell{cellcounter} = cell{i};
                cellcounter = cellcounter + 1;
            else
                non_struct_cell{counter2} = cell{i};
                counter2 = counter2 + 1;
            end
        else
            non_struct_cell{counter2} = cell{i};
            counter2 = counter2 + 1;
        end
    end
end

%First display the structure fields
for i = 1:length(struct_cell)
    new_structure = getfield(structure, struct_cell{i});
    string = (struct_cell{i});
    string = append(indent, string);
    disp(string);
    display_structure(new_structure, max_array_size, new_start_indent_size, step_size);
end

%Now the cellfields, which will be converted to structures
for i = 1:length(arCellCell)
    [new_structure, blFailed] = myCell2Struct(getfield(structure, arCellCell{i}));
    if ~blFailed
        string = arCellCell{i};
        string = append(indent, string);
        disp(string);
        display_structure(new_structure, max_array_size, new_start_indent_size, step_size);
    else
        non_struct_cell{counter2} = getfield(structure, arCellCell{i});
        counter2 = counter2 + 1;
    end
end

%Now display the names of the non-structure fields
%First determine the maximum length of the variable name, so they can be aligned
max_length = 0;
for i = 1:length(non_struct_cell);
    length_name = length(non_struct_cell{i});
    if (length_name > max_length)
        max_length = length_name;
    end
end
    
for i = 1:length(non_struct_cell);
    length_name = length(non_struct_cell{i});
    string = repmat(' ', 1, max_length - length_name);
    string = append(string, non_struct_cell{i});
    string = append(indent, string);
    variable_string = '';
    class_string = '';
    size_string = '';
    size_variable = size(getfield(structure, non_struct_cell{i}));
    if (length(size(getfield(structure, non_struct_cell{i}))) < 3 & ~isequal(class(getfield(structure, non_struct_cell{i})), 'cell'))
        %size_variable = sort(size_variable);
        if (size_variable(1) == 1 & size_variable(2) <= max_array_size) %Variable is an array (row)
            if (size_variable(2) == 1) %Variable is a scalar
                temp = getfield(structure, non_struct_cell{i});
                if isequal(class(temp), 'char')
                    variable_string = append(variable_string, temp);
                else
                    variable_string = append(variable_string, num2str(double(temp)));
                end
            else
                temp = getfield(structure, non_struct_cell{i});
                if isequal(class(temp), 'char')
                    variable_string = append(variable_string, temp);
                else
                    variable_string = '[';
                    variable_string = append(variable_string, num2str(double(temp)));
                    variable_string = append(variable_string, ']');
                end
            end
        else
            if (size_variable(2) == 1 & size_variable(1) <= max_array_size) %Variable is an array (column)
                %Scalar case is handled by previous if construction
                temp = getfield(structure, non_struct_cell{i});
                if isequal(class(temp), 'char')
                    variable_string = append(variable_string, temp);
                else
                    variable_string = '[';
                    variable_string = append(variable_string, num2str(double(temp)'));
                    variable_string = append(variable_string, ']');
                end
                %Now we append a ' to show this is a column vector
                variable_string = append(variable_string, '''');
            else
                class_string = class(getfield(structure, non_struct_cell{i}));
                size_string = create_size_string(size(getfield(structure, non_struct_cell{i})));
            end
        end
    else
        class_string = class(getfield(structure, non_struct_cell{i}));
        size_string = create_size_string(size(getfield(structure, non_struct_cell{i})));
    end
    string = append(string, ': ');
    string = append(string, variable_string);
    if ~isempty(class_string) %If the variable was displayed, there is no need to display class and size info
        string = append(string, '[');
        string = append(string, size_string);
        string = append(string, ' ');
        string = append(string, class_string);
        string = append(string, ']');
    end
    disp(string);
end
end


%% ----- create_size_string   [AQP_gui.m lines 20633-20643] ----------------------------------------
function size_string = create_size_string(array)
size_string = num2str(array);
%Replace the spaces in the string with x-es
pos = find(size_string == ' ');
pos = split_array(pos);
size_string(pos(:,1)) = 'x';
pos(:,1) = [];
zeropos = find(pos == 0); %Detect zeros in the matrix created by split_array
pos(zeropos) = []; %Remove them
size_string(pos) = [];
end


%% ----- split_array   [AQP_gui.m lines 20645-20669] -----------------------------------------------
function matrix = split_array(array)
%This function splits an array into a number of colums. 
%This by creating a new row every time there is a large step in
%the values in the array. This function assumes the values to be sorted!
%Input:     -Array containing SORTED (intensity) values
%Output:    -Matrix created from the original array
array = double(array);
lengte = length(array);
previous_value = array(1);
teller2 = 1;
teller3 = 1;
for teller = 1:lengte
    if ((array(teller) == previous_value) | (array(teller) == (previous_value + 1)))
        matrix(teller3, teller2)=array(teller);
        teller = teller + 1;
        teller2 = teller2 + 1;
    else
        matrix(teller3 + 1, 1)=array(teller);
        teller = teller + 1;
        teller2 = 2;
        teller3 = teller3 + 1;
    end
    previous_value = array(teller - 1);
end
end


%% ----- append   [AQP_gui.m lines 20672-20682] ----------------------------------------------------
function array_out = append(array_in, array_to_append)
%This function appends an array to the tail of another array.
%Input:     -Array, the original array
%           -Array, the array that will be attached to array_in
%Output:    -Array

length_array_in = length(array_in);
length_array_to_append = length(array_to_append);
array_out = array_in;
array_out((length_array_in + 1):(length_array_in + length_array_to_append)) = array_to_append;
end


%% ----- myCell2Struct   [AQP_gui.m lines 20685-20720] ---------------------------------------------
function [strOut, blFailed] = myCell2Struct(clIn)
%This function converts a cell ARRAY(!)
%into a structure. The original
%cell2struct will convert a cell 
%array into a structure ARRAY. 
%This function creates structure
%fieldnames 'cell1', 'cell2', etc.
%If the cell is not an array, the 
%flag Failed will be set. And no structure
%will be created.
%Input:     -Cell
%Output:    -Structure

arSize = size(clIn);

strOut = [];
blFailed = 1;
if length(arSize) > 2
    %3D matrix
%     break
return
end

if min(arSize) > 1
    %Not an array
%     break
return
end

strName = 'Cell';
for i = 1:max(arSize) %Length(clIn)
    strNameNew = [strName, num2str(i)];
    strOut = setfield(strOut, strNameNew, clIn{i});
end
blFailed = 0;
end


%% ----- fdir_wPrefix_wPath   [AQP_gui.m lines 21328-21434] ----------------------------------------
function [clist_file_OR_subfolder_name,n]=fdir_wPrefix_wPath(pathName,sext,dispyes,filenamePrefix,inp)
%list and collect files with specified extension and pathName in cell format
% for list all files (non-directory) use sext='*'
% for list ONLY subfolders (directory) use sext='' or []
% can use wildcard(s) in filenamePrefix
% see also fdir_wildcard , genpath , findfiles , listfiles
% e.g. [clist_file_OR_subfolder_name,n]=fdir(pwd,'m',0,'fake*CH')
% e.g. [clist_file_OR_subfolder_name,n]=fdir(pwd,'m',0,'test*run*1217')
% can also use wildcard in sext
% e.g.  [clist_file_OR_subfolder_name,n]=fdir(pwd,'m*',0,'*')
%
% if pathName -> '' or [] -> get from current dir  (pwd)
% for all file without any restriction on Prefix, filenamePrefix can either '' or [] or '*'
%
% for list ONLY subfolders (directory) use sext='' or []
% e.g. [clist_file_OR_subfolder_name,n]=fdir(pwd,'',0,'*')
% or [clist_file_OR_subfolder_name,n]=fdir(pwd,'',0,'')
%
% list only 1st level down subfolder with wildcard
% [clist_file_OR_subfolder_name,n]=fdir(pwd,'',0,'a*')
% or the same:  [clist_file_OR_subfolder_name,n]=fdir(pwd,'',0,'a')
%
% for list all files (non-directory) use sext='*'
% e.g. [clist_file_OR_subfolder_name,n]=fdir(pwd,'*',0,'*')
%
% e.g.  [clist_file_OR_subfolder_name,n]=fdir('','mat',0,'SVMmodels');  
% e.g.  [clist_file_OR_subfolder_name,n]=fdir('G:\work\ardpr_LN\Atrainpketc_all_R_NCA_3TICs','mat',0,'Atrainpketc_U53-R7b');  
%
% add the following to output with fullpath
% inp.fullpath_yes=1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fdir_wildcard_ext_wPath is the most useful one !!!
% see also: fdir_wildcard_ext_wPath (most popular one)
%========================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normally sext should not include "." at begining, however if user include
% it, it will be removed !!!
% e.g. '.mat'  become 'mat'
if ~isempty(strfind(sext,'.')) && strfind(sext,'.')==1
    sext(1)=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%example: clear;pathName='D:\work\ARFCAM_TICs\PhaseI\rawdata_basecase\';sext='csv';[clist_file_OR_subfolder_name,n]=fdir(pathName,sext,1);
if exist('filenamePrefix')~=1
    filenamePrefix='';
end
fullpath_filename=[pathName,'\',filenamePrefix,'*.',sext]; 
fullpath_filename(findstr(fullpath_filename,'**.'))=[];; %can handle either with '*' or wo '*' at filenamePrefix

if fullpath_filename(1)=='\' & fullpath_filename(2)~='\'
    fullpath_filename(1)=[];
end


loc_2bs=findstr(fullpath_filename,'\\');
if ~isempty(loc_2bs) && loc_2bs>1
fullpath_filename(loc_2bs)=[];; %can handle either with '/' or wo '/' at the end of pathName
end


extFiles = dir(fullpath_filename);

% for list all files (non-directory) use sext='*'
if strcmp(sext,'*')
 extFiles= extFiles(find(arrayfun(@(x) x.isdir,extFiles)==0));  
end
% for list ONLY 1st layer of subfolders (directory) use sext='' or []
if length(sext)==0
   if length(findstr(fullpath_filename,'\'))==1
  extFiles= extFiles(find(arrayfun(@(x) x.isdir,extFiles)==1));  %root directory
  disp_with_border('this is ROOT DIR case, list of 1st layer subfolder may not be all correct (list out all isdir==1) !!!')
   else
  extFiles= extFiles(find(arrayfun(@(x) x.isdir,extFiles)==1 &  arrayfun(@(x) fdir_wPrefix_wPath__NOT_single_NOR_double_dot(x.name),extFiles)==1 ));  %non-root directory

 
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clist_file_OR_subfolder_name=[];
for i=1:length(extFiles)
%  fullfile(pathName,extFiles(i).name) ;
clist_file_OR_subfolder_name=[clist_file_OR_subfolder_name;{ fullfile(pathName,extFiles(i).name) }       ]; 
 
end
 switch dispyes
 case 1
         for n=1:length(clist_file_OR_subfolder_name)
         disp(clist_file_OR_subfolder_name{n})
                 % do what you want with "file"
         end
         
     case 0
        n=length(clist_file_OR_subfolder_name) ;
         
 end   
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if    ~isempty(clist_file_OR_subfolder_name) && isequal( fileparts_name_ext( clist_file_OR_subfolder_name),clist_file_OR_subfolder_name)
     
     if exist('inp','var') && isfield(inp,'fullpath_yes') && inp.fullpath_yes==1 && ~isempty(clist_file_OR_subfolder_name)
         clist_file_OR_subfolder_name=cellfun(@(x) [pathName,'\',x],clist_file_OR_subfolder_name,'uniformoutput',false);
     elseif isempty(clist_file_OR_subfolder_name)
         disp('continue with empty clist_file_OR_subfolder_name')
     end
     
 end
end

%% ----- fdir_wPrefix_wPath__NOT_single_NOR_double_dot   [AQP_gui.m lines 21436-21442] -------------
    function out=fdir_wPrefix_wPath__NOT_single_NOR_double_dot(x)
        if ~strcmp(x,'.') & ~strcmp(x,'..')
            out=1;
        else
            out=0;
        end
end


%% ----- fdir_wildcard_wPath   [AQP_gui.m lines 21515-21549] ---------------------------------------
function [clistfilename, nfile]=fdir_wildcard_wPath(targetPathname,keyword_inside_wildcards)
% similar to fdir but use wildcard to find all file with certain keywords
% IF keyword_inside_wildcards is EMPTY, find all files in the folder and exclude parents folder/files;

% see also fdir_wildcard_wPath_sortnat wfdir_wPath (alias) ,  fdir, fdir_wildcard, fdir_wPath

% e.g. fdir_wildcard_wPath('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','svm')
% see also: recursiveDir  example_recursiveDir
% see also: fdir_wildcard_ext_wPath (most popular one)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false

 [clistfilename, nfile]=fdir_wildcard_wPath('C:\work\Bidgely\dkPublic\Public\ML\datawithTemp','');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(keyword_inside_wildcards)
    [clistfilename, nfile]=fdir_wildcard(targetPathname,keyword_inside_wildcards);
        clistfilename=cellfun(@(x) [targetPathname,'\',x],clistfilename,'uniformoutput',false);

    loc_NOTParents=cellfun(@(x) fdir_wildcard_wPath__isNOTParentFolders(x),clistfilename);
    
    clistfilename=clistfilename(loc_NOTParents);
    nfile=length(clistfilename);
    disp('since keyword_inside_wildcards is EMPTY, find all files in the folder and exclude parents folder/files');
    
    
else
    [clistfilename, nfile]=fdir_wildcard(targetPathname,keyword_inside_wildcards);
    
    
    clistfilename=cellfun(@(x) [targetPathname,'\',x],clistfilename,'uniformoutput',false);
    
end
end


%% ----- fdir_wildcard_wPath__isNOTParentFolders   [AQP_gui.m lines 21553-21561] -------------------
function out=fdir_wildcard_wPath__isNOTParentFolders(x)

if ~strcmp(fileparts_name_ext(x),'.') && ~strcmp(fileparts_name_ext(x),'..')
    out=true;
else
    out=false;
    
end
end


%% ----- fileparts_name_wo_ext   [AQP_gui.m lines 21587-21604] -------------------------------------
function filename= fileparts_name_wo_ext(file)
% modified by Chang to handle the case when file is cell of str
% June 24, 2016
if iscell(file)
    cfilename=[];
    for ifile=1:length(file)
        [PATHSTR,NAME,EXT]=fileparts(file{ifile});
        cfilename=[cfilename;{NAME}];
    end
    filename=cfilename;
    
elseif ischar(file)
    [PATHSTR,NAME,EXT]=fileparts(file);
    filename=[NAME];
else
    error('input file should be cell of str or str')
end
end


%% ----- find_all_open_fig   [AQP_gui.m lines 21608-21613] -----------------------------------------
function out=find_all_open_fig()
% find all open Matlab figures
% see also HFA_MCH_BatchRun_PPG_assemble_ILCQ

out=findall(0,'type','figure');
end


%% ----- find_all_zeros_col_idx   [AQP_gui.m lines 21617-21627] ------------------------------------
function out=find_all_zeros_col_idx(A)
if false
    
    cc
    L=load('C:\work\JDSU\Test_AQP_PowerUser\AT_diagnose_PP1-{PRO}_NarrowMstWVL\wSNV{PRO}\Atrainpketc_(woCabXfer_pp1-1stDerSGFL7[PO2]{PRO}_pp2-SNV{PRO}_CS&Val_for-AAQP)_nvar112_ncls44_nsampT102_nsampP102.mat');
    out=find_all_zeros_col_idx(L.Atrainpk)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=sum(abs(A))==0;
end


%% ----- find_allzero_col   [AQP_gui.m lines 21631-21634] ------------------------------------------
function loc_allzero_col=find_allzero_col(Atrainpk);

loc_allzero_col=find(sum(abs(Atrainpk))==0);
end


%% ----- find_belong2subgrp   [AQP_gui.m lines 21638-21692] ----------------------------------------
function [all_loc_subgrp idx_match]=find_belong2subgrp(listall,subgrp)
%find the locations of all numbers in listall belong to subgrp
% export sorted result
%e.g. all_loc_subgrp=find_belong2subgrp([1 2 3 1 2 3],[1 2])
%by Chang Hsiung, May 30, 07
% see also find_belong2subgrp_cstr  is_belong2subgrp is_belong2subgrp_cstr
if false
    
    find_belong2subgrp(2,5)
    %%%%%%%%%%%%%%%%%
    find_belong2subgrp(2,[5 2])
    %%%%%%%%%%%%%%%%%
    find_belong2subgrp([2 5],5)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(subgrp)

[rn cn]=size(listall);
all_loc_subgrp=[];
idx_match=[];
for sgi=row_vector_ALWAYS(unique(subgrp))
    loc_sgi=find(listall==sgi);
    
  if rn>=cn
    all_loc_subgrp=[all_loc_subgrp;loc_sgi ];  
    
    if ~isempty(loc_sgi)
    TF=logical(1);
    else
    TF=logical(0);    
    end
    idx_match=[idx_match;TF];

  else
    all_loc_subgrp=[all_loc_subgrp,loc_sgi ];  
    
     if ~isempty(loc_sgi)
    TF=logical(1);
    else
    TF=logical(0);    
    end
    idx_match=[idx_match,TF];
    
    
  end

end
all_loc_subgrp=sort(all_loc_subgrp);

else
 all_loc_subgrp=[];   
    
end
idx_match=logical(idx_match);
end


%% ----- find_keynumber_numeric_AFTER_marker   [AQP_gui.m lines 21739-21771] -----------------------
function keynumber=find_keynumber_numeric_AFTER_marker(targetstring,marker)
% pls use "find_keyword_numeric_AFTER_marker_cstr" instead !!!
%
% not correct anymore -->this is the main function to call, 
% and this will call "find_keyword_numeric_AFTER_marker" inside
% find keynumber that is numeric AFTER mark (use regexp)
  % output is in double datatype !!!  output NaN if no match found
% See also : find_keyword_numeric_AFTER_marker_cstr find_keyword_between_markers strtok allwords find_keyword_between_markers_wWildCards
  
if false
    
    keynumber=find_keynumber_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','T-')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     keynumber=find_keynumber_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','T')
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    keynumber=find_keynumber_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','P')
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     keynumber=find_keynumber_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','X')

    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% switch to "find_keyword_numeric_AFTER_marker_cstr" instead !!!
keynumber=find_keyword_numeric_AFTER_marker_cstr(targetstring,marker);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
skeyword=find_keyword_numeric_AFTER_marker(targetstring,marker);

keynumber=str2num(skeyword);
if isempty(keynumber)
    keynumber=NaN;
end
end


%% ----- find_keyword_between_markers_wlistRHS   [AQP_gui.m lines 22201-22270] ---------------------
function skeyword_final=find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2 )
% the flow of algo changed to find whichever skyword that is shortest !!!
% the flow of algo changed to find whichever skyword that is shortest !!!
% the flow of algo changed to find whichever skyword that is shortest !!!
% modified by Chang Hsiung, May 14, 2015
% run find_keyword_between_markers with cell list of possible RHS marker2
% if all clistmarker2 give empty results, still output empty result
% modified from skeyword=find_keyword_between_markers(targetstring,marker1,marker2)
% 
% use 'end' to represent search till the end
% e.g. find_keyword_between_markers_wlistRHS('ewma',[],{'-','end'} )
%
% Note that the sequence in clistmarker2 is important
% the program will try in that sequence, whenever it find first hit, it will stop !!!
%
% the flow of algo changed to find whichever skyword that is shortest !!!
% the flow of algo changed to find whichever skyword that is shortest !!!
% the flow of algo changed to find whichever skyword that is shortest !!!
% modified by Chang Hsiung, May 14, 2015
% see for example in SFV_depfun2TargetFolder
% see also textual_extractBetween  textual_replaceBetween strrep_keyword_between_markers_wlistRHS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
    find_keyword_between_markers_wlistRHS('afdaf_E1-00176 000_abd.mat','_E1-',{'_',' '} )
    
    find_keyword_between_markers_wlistRHS('afdaf_E1-00176 000_abd.mat','_E1-',{' ','_'} )
    
    find_keyword_between_markers_wlistRHS('afdaf_E1-00176.mat','_E1-',{' ','_'} )
    
    find_keyword_between_markers_wlistRHS('afdaf_E1-00176.mat','_E1-',{' ','','_'} )
    
    find_keyword_between_markers_wlistRHS('afdaf_E1-00176.mat','_E1-',{' ',''} )
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ischar(clistmarker2)
    clistmarker2{1}=clistmarker2;
elseif ~iscell(clistmarker2)
    error('clistmarker2 should be either a cell or a str')
    
    
end
skeyword_found=targetstring;
for istr=1:length(clistmarker2)
    if strcmp_CI(clistmarker2{istr},'end')% use 'end' to represent search till the end

        % skeyword=find_keyword_between_markers(targetstring,marker1,[]);
                skeyword=regexp_extract_mk1_mk2(targetstring,marker1,[]);

    else
        % skeyword=find_keyword_between_markers(targetstring,marker1,clistmarker2{istr});
        skeyword=        regexp_extract_mk1_mk2(targetstring,marker1,clistmarker2{istr});

    end
    if ~isempty(skeyword) && length(skeyword)<=length(skeyword_found)
        skeyword_found=skeyword;
    elseif isempty(skeyword)
        continue
    end
    
end

skeyword_final=skeyword_found;
if strcmp(skeyword_final,targetstring)
    skeyword_final='';
end
end


%% ----- find_keyword_merge_dual_curly_bracket_w_targetstring_remain   [AQP_gui.m lines 22425-22536] ---
function [skeyword targetstring_remain out]=find_keyword_merge_dual_curly_bracket_w_targetstring_remain(targetstring,inp)
% can also output "targetstring_remain"
% can only deal with two set of curly brackets
% when only one set of curly bracket exist, output based on that one set of curly bracket
% inp.keep_curly_yes -->default to 1
%
% see also: BatchRun_PLS_wTcv_StandAlone_AQPpu
% see also: find_keyword_merge_dual_curly_bracket merge_dual_curly_bracket, RUN_XGB_CmpClsfr
%-----------------------------------------------------
% revisit this Mar 15, 2023 when bugs wrt Cmp_Results_AQP.m in AQPlite happened
% see also: BatchRun_AutoQuant_DA_pipeline
% add following, Mar 16, 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
    % inp.keep_curly_yes -->default to 1
    cc
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{P-3_T-2-FQ}_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
   [skeyword targetstring_remain]= find_keyword_merge_dual_curly_bracket_w_targetstring_remain(targetstring)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % do NOT keep curly brackets on either side
    clear
    inp.keep_curly_yes=0;
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{P-3_T-2-FQ}_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
    [skeyword targetstring_remain]= find_keyword_merge_dual_curly_bracket_w_targetstring_remain(targetstring,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % when only one set of curly bracket
    cc
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
     [skeyword targetstring_remain]=find_keyword_merge_dual_curly_bracket_w_targetstring_remain(targetstring)
    %%%%%%%%%%%%%%%%%%%%%
    % when only one set of curly bracket
    clear
    inp.keep_curly_yes=0;
    targetstring=fileparts_name_ext('C:\work\JDSU\Test_ML_UCP\Aft-MTch_Ycdc_nFeat199_ParseTP_Ncomb3\Atrainpketc_icomb3_{Aft-MTch_Ycdc_nFeat199}_nvar199_ncls2_nsampT206_nsampP102.mat');
     [skeyword targetstring_remain]=find_keyword_merge_dual_curly_bracket_w_targetstring_remain(targetstring,inp)
    
    
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
 %----------------------------------------------------------
 % add following, Mar 16, 2023
 try
     out.cb1=cb1;
 catch
     out.cb1='';
 end
 try
     out.cb2=cb2;
 catch
     out.cb2='';
 end
 %----------------------------------------------------------------
done_with_this_function;
end


%% ----- find_keyword_numeric_AFTER_marker   [AQP_gui.m lines 22541-22586] -------------------------
function skeyword=find_keyword_numeric_AFTER_marker(targetstring,marker)
% pls use "find_keyword_numeric_AFTER_marker_cstr" instead !!!
%
% updated to be able to handle cstr as input
% this should not be called directly, pls call its main function: "find_keynumber_numeric_AFTER_marker"
%
% find keyword that is numeric AFTER mark (use regexp)
  % output is in string datatype !!!
% See also : find_keyword_numeric_AFTER_marker_cstr find_keyword_between_markers strtok allwords find_keyword_between_markers_wWildCards
  
if false
    
    skeyword=find_keyword_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','T-')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     skeyword=find_keyword_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','T')
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     skeyword=find_keyword_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','P')
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     skeyword=find_keyword_numeric_AFTER_marker('T-214_Lib1_P-215_Lib1','X')

    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% switch to "find_keyword_numeric_AFTER_marker_cstr" instead !!!

skeyword=find_keyword_numeric_AFTER_marker_cstr(targetstring,marker);
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pat1=[marker,'\D*\d{1}'];
locT1=regexp(targetstring,pat1,'end');


pat2=[marker,'\D*\d+'];
locT2=regexp(targetstring,pat2,'end');

if ischar(targetstring)
    skeyword=targetstring(locT1:locT2);
elseif iscell(targetstring)
    sia=string(targetstring);
   skeyword= double(sia.extractAfter(marker));
else
    error('data type of targetstring Not supported')
end
end


%% ----- find_keyword_numeric_AFTER_marker_cstr   [AQP_gui.m lines 22590-22641] --------------------
function skeyword=find_keyword_numeric_AFTER_marker_cstr(targetstring,marker)
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% updated to be able to handle cstr as input
% this version is more general because it can handle both char or cell as input
% updated Aug 8, 2019
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% change output to double datatype !!! Aug 8, 2019
% change output to double datatype !!! Aug 8, 2019
% find keyword that is numeric AFTER mark (use regexp)
%
%
% See also : find_keyword_between_markers strtok allwords find_keyword_between_markers_wWildCards
  
if false
    
    skeyword=find_keyword_numeric_AFTER_marker_cstr('T-214_Lib1_P-215_Lib1','T-')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     skeyword=find_keyword_numeric_AFTER_marker_cstr('T-214_Lib1_P-215_Lib1','T')
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     skeyword=find_keyword_numeric_AFTER_marker_cstr('T-214_Lib1_P-215_Lib1','P')
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     skeyword=find_keyword_numeric_AFTER_marker_cstr({'T-214_Lib1_P-215_Lib1';'T-214_Lib1_P-215_Lib1'},'P')
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     skeyword=find_keyword_numeric_AFTER_marker_cstr({'T-214_Lib1_P-215_Lib1';'T-214_Lib1_X-215_Lib1'},'P')
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pat1=[marker,'\D*\d{1}'];
locT1=regexp(targetstring,pat1,'end');


pat2=[marker,'\D*\d+'];
locT2=regexp(targetstring,pat2,'end');

if ischar(targetstring)
    skeyword=str2num(targetstring(locT1:locT2));% change output to double datatype !!! Aug 8, 2019
    if isempty(skeyword)
        skeyword=NaN;
    end
elseif iscell(targetstring)
    
    % old approach that was wrong
    %     sia=string(targetstring);
    %    skeyword= double(sia.extractAfter(marker));
    
    % newly fixed approach
    skeyword= cellfun(@(x,T1,T2) str2num_empty2NaN(x,T1,T2),targetstring,locT1,locT2);% change output to double datatype !!! Aug 8, 2019
    
else
    error('data type of targetstring Not supported')
end
end


%% ----- str2num_empty2NaN   [AQP_gui.m lines 22644-22649] -----------------------------------------
function out=str2num_empty2NaN(x,T1,T2)
out=str2num(x(T1:T2));
if isempty(out)
    out=NaN;
end
end


%% ----- find_lastNfolder   [AQP_gui.m lines 22728-22740] ------------------------------------------
function lastfolder=find_lastNfolder(pathname,N)
% e.g.
% pathname='G:\work\LACIS-III\G3_allr\allr_U3tset\Load-T-Dir_U3_LACIS-IIIa-G3';lastfolder=find_lastNfolder(pathname,2)
% pathname='G:\work\LACIS-III\G3_allr\allr_U3tset\Load-T-Dir_U3_LACIS-IIIa-G3';lastfolder=find_lastNfolder(pathname,10)

% e.g. replace(lastfolder,'-','_');
all_bs=find(pathname=='\');
if length(all_bs)>0
    lastfolder=pathname(all_bs( max(1, end-N+1)   )+1:end);      % if end-N+1 less than 1, use 1
else
    lastfolder=pathname;
end
end


%% ----- find_last_nonTMP_folder   [AQP_gui.m lines 22744-22769] -----------------------------------
function out=find_last_nonTMP_folder()
% alias of find_last_nonTMP_path
% find last "nonTMP directory"
% "TMP directory": case sensitive for "TMP" and must start with "TMP" !!!
% see also find_last_nonTMP_path rmdir_TMP  ILCQ
if false
    
    out=find_last_nonTMP_folder()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % cd to first "TMP"
    path_orig=pwd;
    tmp4ILCQ=tmp_folder_rm_mk('TMP-ILCQ',pwd);
    cd(tmp4ILCQ);
    
    % cd to 2nd layer of "TMP"
    path_orig=pwd;
    tmp4ILCQ=tmp_folder_rm_mk('TMP-ILCQ',pwd);
    cd(tmp4ILCQ);
    
    % cd back to last nonTMP directory
    cd(find_last_nonTMP_folder);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=find_last_nonTMP_path;
end


%% ----- find_last_nonTMP_path   [AQP_gui.m lines 22773-22807] -------------------------------------
function out=find_last_nonTMP_path()
% find last "nonTMP directory" (the main function not alias)
% "TMP directory": case sensitive for "TMP" and must start with "TMP" !!!
% see also find_last_nonTMP_folder rmdir_TMP ILCQ
%-----------------------------------
if false
    
    out=find_last_nonTMP_path()
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % cd to first "TMP"
    path_orig=pwd;
    tmp4ILCQ=tmp_folder_rm_mk('TMP-ILCQ',pwd);
    cd(tmp4ILCQ);
    
    % cd to 2nd layer of "TMP"
    path_orig=pwd;
    tmp4ILCQ=tmp_folder_rm_mk('TMP-ILCQ',pwd);
    cd(tmp4ILCQ);
    
    % cd back to last nonTMP directory
    cd(find_last_nonTMP_path);
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
curPath=pwd;
curPath=strrep(curPath,'\','/');
ceaDir=strread_delimiter(curPath,'/');
locTMP=strmatch('TMP',ceaDir);
if ~isempty(locTMP)
   out= strwrite_all_delimiter(ceaDir(1:locTMP(1)-1),'\');
else
  out= curPath; 
    
end
end


%% ----- find_wvl_range_cheading   [AQP_gui.m lines 22850-22861] -----------------------------------
function [idx_wvl loc_wvl]= find_wvl_range_cheading(cheading)
% see also: get_wvl_AQP_ACP_Input_XLS
%====================================================================
% idx_wvl_numeric=cellfun(@(x) is_numeric_NOT_NaN(x),cheading,'un',0);    %
idx_wvl_numeric=cellfun(@(x) is_numeric_NOT_NaN(x),cheading);    %

idx_wvl=idx_wvl_numeric;
loc_wvl=find(idx_wvl);


done_with_this_function;
end


%% ----- is_numeric_NOT_NaN   [AQP_gui.m lines 22864-22894] ----------------------------------------
function out=is_numeric_NOT_NaN(x)

% if isnan(x) || all(isnan(x)) || isnat(x) || isempty(x)||ismissing(x)
try
    if isnat(x)
        out=0;
        return;
    end
end

try
    if isnan(x)
        out=0;
        return;
    end
end

try
    if ischar(x)
        out=0;
%     elseif  isnan(x)
%         out=0;
    elseif isnumeric(x)
        out=1;
%     else
%         out='';
    end
catch
    error(['data type in ',x,' not expected'])
end
end


%% ----- generate_random_orthogonal_vectors   [AQP_gui.m lines 23246-23296] ------------------------
function [v1, v2, v3] = generate_random_orthogonal_vectors()
% see also: test_Mahal_Rolling_PCA_Random_covariance_matrix
% see also: generate_random_orthogonal_vectors
% see also: creat_3D_Random_covariance_matrix
%---------------------------------------------------------------
% ask ChatGPT : how to create a randomly oriented 3D orthogonal unit vectors in Matlab
% -----------------------------------------------------------------------------------
% see also: test_Mahal_Rolling_PCA_Random_covariance_matrix
%=======================================================================
if false
    
    cc
    % Example usage:
    [v1, v2, v3] = generate_random_orthogonal_vectors();
    disp('Vector 1:');
    disp(v1');
    disp('Vector 2:');
    disp(v2');
    disp('Vector 3:');
    disp(v3');
    %  test
    v1'*v2
    v2'*v3
    v1'*v3
    norm(v1)
    norm(v2)
    norm(v3)
    
    
    
end
%---------------------------------------------------------------
%============================================================================
    % Step 1: Generate three random vectors
    v1 = rand(3, 1);
    v2 = rand(3, 1);
    v3 = rand(3, 1);

    % Step 2: Normalize the vectors
    v1 = v1 / norm(v1);
    v2 = v2 / norm(v2);
    v3 = v3 / norm(v3);

    % Step 3: Ensure orthogonality using Gram-Schmidt process
    v2 = v2 - dot(v2, v1) * v1;
    v2 = v2 / norm(v2);

    v3 = v3 - dot(v3, v1) * v1;
    v3 = v3 - dot(v3, v2) * v2;
    v3 = v3 / norm(v3);
end


%% ----- get_DSn_AQP   [AQP_gui.m lines 23303-23313] -----------------------------------------------
function [clistsubfolder]=get_DSn_AQP()
% get list of all DSn folders under pwd
if false
    [clistsubfolder]=get_DSn_AQP()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clistsubfolder= cellstr(get_subfolder_wFullPath_wKeyword(pwd,'DS'));
idx_find=cellfun(@(x) get_DSn_AQP__isDSn(x,'DS'),find_lastfolder(clistsubfolder));
% clistsubf=
clistsubfolder=clistsubfolder(idx_find);
end


%% ----- get_DSn_AQP__isDSn   [AQP_gui.m lines 23320-23332] ----------------------------------------
function out=get_DSn_AQP__isDSn(x,sDS)
loc=strfind(x,sDS);
if loc==1
    sn=find_keyword_numeric_AFTER_marker(x,sDS);
    if strcmp(x,[sDS,sn])
        out=true;
    else
        out=false;
    end
else
    out=false;
end
end


%% ----- get_OnlyOne_AT   [AQP_gui.m lines 23361-23380] --------------------------------------------
function  out=get_OnlyOne_AT(pathAT)
% see also get_OnlyOne_XLSX_wPrefix
    [clistfile nfile]=fdir_wildcard_ext_wPath([pathAT],'Atrainpketc_','mat');
    if length(clistfile)==1
        out=clistfile{1};
    else
        
        if nfile>=2
            L1=load(clistfile{1});
            L2=load(clistfile{2});
            if     isequal(L1.Atrainpk,L2.Atrainpk) &&  isequal(L1.Apred,L2.Apred)  &&  isequal(L1.RawSpectra.Tset,L2.RawSpectra.Tset) &&   isequal(L1.RawSpectra.Pset,L2.RawSpectra.Pset)
                out=clistfile{1};
            else
                error(['something wrong with --> ',pathAT])
            end
        else
            error(['should Not come to here ??  something wrong with --> ',pathAT])
        end
    end
end


%% ----- get_OnlyOne_MAT_wPrefix   [AQP_gui.m lines 23384-23431] -----------------------------------
function  out=get_OnlyOne_MAT_wPrefix(path_XLSX,skeyword,opt)
% see also get_OnlyOne_XLSX_wPrefix --> better use this for AQP etc

if false
    
    path_XLSX= 'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21'
    opt.prefix_yes=1;
    out=get_OnlyOne_XLSX(path_XLSX,'UDM_',opt)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  out=get_OnlyOne_MAT_wPrefix('\\ds.jdsu.net\TFilms\IRSE\Development\DataReview_MicroNIR\AQP_Users','sa_VN_User')
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    Prefix_yes=opt.prefix_yes;
catch
    Prefix_yes=0;
end

[clistfile nfile]=fdir_wildcard_ext_wPath([path_XLSX],skeyword,'mat');
% [clist_file_OR_subfolder_name_wPath,n]=fdir_wPath(Path,sext,dispyes,filenamePrefix)

if Prefix_yes
    try
    loc_match=cellfun(@(x) strfind(fileparts_name_ext(x),skeyword),clistfile);
        loc_file_match_at_begin=find(loc_match==1);
    catch
    loc_match=cellfun(@(x) strfind(x,['\',skeyword]),clistfile);
    loc_file_match_at_begin=find(~isempty(loc_match));
    end
    
    if length(loc_file_match_at_begin)==1
        clistfile=clistfile(loc_file_match_at_begin);
        nfile=1;
    else
        error('non-unique find in the case Prefix_yes==1')
    end
end

if length(clistfile)==1
    out=clistfile{1};
else
    error(['something wrong with --> ',path_XLSX])
end
end


%% ----- get_OnlyOne_XLSX   [AQP_gui.m lines 23435-23478] ------------------------------------------
function  out=get_OnlyOne_XLSX(path_XLSX,skeyword,opt)
% see also get_OnlyOne_XLSX_wPrefix --> better use this for AQP etc

if false
    
    path_XLSX= 'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21'
    opt.prefix_yes=1;
    out=get_OnlyOne_XLSX(path_XLSX,'UDM_',opt)
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    Prefix_yes=opt.prefix_yes;
catch
    Prefix_yes=0;
end

[clistfile nfile]=fdir_wildcard_ext_wPath([path_XLSX],skeyword,'xlsx');
% [clist_file_OR_subfolder_name_wPath,n]=fdir_wPath(Path,sext,dispyes,filenamePrefix)

if Prefix_yes
    try
    loc_match=cellfun(@(x) strfind(fileparts_name_ext(x),skeyword),clistfile);
        loc_file_match_at_begin=find(loc_match==1);
    catch
    loc_match=cellfun(@(x) strfind(x,['\',skeyword]),clistfile);
    loc_file_match_at_begin=find(~isempty(loc_match));
    end
    
    if length(loc_file_match_at_begin)==1
        clistfile=clistfile(loc_file_match_at_begin);
        nfile=1;
    else
        error('non-unique find in the case Prefix_yes==1')
    end
end

if length(clistfile)==1
    out=clistfile{1};
else
    error(['something wrong with --> ',path_XLSX])
end
end


%% ----- get_OnlyOne_XLSX_wPrefix   [AQP_gui.m lines 23482-23526] ----------------------------------
function  out=get_OnlyOne_XLSX_wPrefix(path_XLSX,skeyword,opt)
% case insensitive
% see also get_OnlyOne_XLSX_wPrefix --> better use this for AQP etc

if false
    
    path_XLSX= 'C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\Brix_CS102_UDM21'
    opt.prefix_yes=1;
    out=get_OnlyOne_XLSX(path_XLSX,'UDM_',opt)
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    Prefix_yes=opt.prefix_yes;
catch
    Prefix_yes=1; % since this is "get_OnlyOne_XLSX_wPrefix"
end

[clistfile nfile]=fdir_wildcard_ext_wPath([path_XLSX],skeyword,'xlsx');
% [clist_file_OR_subfolder_name_wPath,n]=fdir_wPath(Path,sext,dispyes,filenamePrefix)

if Prefix_yes
    try
    loc_match=cellfun(@(x) strfind(lower(fileparts_name_ext(x)),lower(skeyword)),clistfile);  % case insensitive
        loc_file_match_at_begin=find(loc_match==1);
    catch
    loc_match=cellfun(@(x) strfind(lower(x),['\',lower(skeyword)]),clistfile);% case insensitive
    loc_file_match_at_begin=find(~isempty(loc_match));
    end
    
    if length(loc_file_match_at_begin)==1
        clistfile=clistfile(loc_file_match_at_begin);
        nfile=1;
    else
        error('non-unique find in the case Prefix_yes==1')
    end
end

if length(clistfile)==1
    out=clistfile{1};
else
    error(['something wrong with --> ',path_XLSX])
end
end


%% ----- get_snow   [AQP_gui.m lines 23609-23614] --------------------------------------------------
function snow=get_snow();
% e.g. snow=get_snow;
    Tnow=now;
    snow=datestr(Tnow,31);
    snow(find(snow==':' | snow==' '))='_';
end


%% ----- get_snow_short   [AQP_gui.m lines 23618-23628] --------------------------------------------
function snow_short=get_snow_short();
% e.g. get_snow_short;
%results:  11 characters string:    040916-1014
    Tnow=now;
    snow=datestr(Tnow,31);
    snow(find(snow==':' | snow==' '|snow=='-'))='';
    snow_short=snow(3:end-2);
    %snow_short=[snow_short(1:6),'-',snow_short(7:end)]; %old format
        
    snow_short=[snow_short(7:end),'-',snow_short(3:6),snow_short(1:2)]; %new format: time-mmddyr
end


%% ----- get_subfolder_wFullPath_wKeyword   [AQP_gui.m lines 23632-23656] --------------------------
function clistsubfolder= get_subfolder_wFullPath_wKeyword(parentPath,strKW)
% clistsubfolder= get_subfolder('C:\SFV')
% see also find_subfolder
% revisit Mar 16, 2024
%------------------------------------------------------------------------
if false
    
    cc
    clistsubfolder= get_subfolder_wFullPath_wKeyword('C:\work\JDSU\Test_ACP\Carpet_Lib_24\CARE_fLMVD_wCorr','M1-')
    
end
%-------------------------------------------------------------------------
%=========================================================================
if exist('parentPath','var')
 sa_dir=dir(parentPath);
else
sa_dir=dir;
end
sa_dir_isdirONLY=sa_dir(arrayfun(@(x) getsubfolderONLY(x),sa_dir));
clistsubfolder_tmp=string(arrayfun(@(x) x.name,sa_dir_isdirONLY,'uniformoutput',false));

clistsubfolder_tmp2=[parentPath,'\']+clistsubfolder_tmp;% this is based on string array
clistsubfolder_tmp3=clistsubfolder_tmp2(clistsubfolder_tmp2.contains(strKW));% this is based on string array
clistsubfolder=clistsubfolder_tmp3.cellstr; % this now based on cstr (cell of strings)
end


%% ----- getsubfolderONLY   [AQP_gui.m lines 23658-23664] ------------------------------------------
function out=getsubfolderONLY(x)
if x.isdir==1 && ~strcmp(x.name,'.')&& ~strcmp(x.name,'..')
    out=true;
else
    out=false;
end
end


%% ----- interp1_CH   [AQP_gui.m lines 23668-23747] ------------------------------------------------
function DMest = interp1_CH(varargin)
% revised version of interp1 to make data matrix follow convention that
% each row represent one sample and each column represent one variable
% varargin{1} --> master unit's grids (can be either row or col)
%
% varargin{2} --> master unit's spectra (follow chemometric convention that each row represents one sample scan and each col represent one variable
% however in single scan dataset, as long as length of varargin{2} matched with length of varargin{1} it can be run
%
% varargin{3} --> target unit's grids (can be either row or col)
% very important: nvar or length in varargin{1} Must eqaul to nvar (Ncol) in varargin{2}
% see also interp1 example_interp1
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
    clear;close all;
mst_ds0=magic(10);
mst_ds=[mst_ds0(1:5,:),mst_ds0(6:10,:)];    
mg=[1:20];
tg=[1.5:1:19.5];
DMest = interp1_CH(mg,mst_ds,tg);
figure;hold on;plot(mg,mst_ds,'b-O');plot(tg,DMest,'r-*');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this will cause error
 clear;close all;
mst_ds0=magic(10);
mst_ds=[mst_ds0(1:5,:),mst_ds0(6:10,:)];  
mst_ds=mst_ds';% this will cause error
mg=[1:20];
tg=[1.5:1:19.5];
DMest = interp1_CH(mg,mst_ds,tg);
figure;hold on;plot(mg,mst_ds,'b-O');plot(tg,DMest,'r-*');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% single scan case
% however in single scan dataset, as long as length of varargin{2} matched with length of varargin{1} it can be run

    clear;close all;
mst_ds0=magic(10);
mst_ds=[mst_ds0(1:5,:),mst_ds0(6:10,:)];
mst_ds(2:end,:)=[];

% mst_ds=mst_ds; % row vector
 mst_ds=mst_ds'; % col vector
mg=[1:20];
tg=[1.5:1:19.5]';
DMest = interp1_CH(mg,mst_ds,tg);
figure;hold on;plot(mg,mst_ds,'b-O');plot(tg,DMest,'r-*');
%-----------------------------------------------------------------------------
% revisit Jan 31, 2024
cc
inp.fig_yes=0;
range_dev_X1=[1:0.1:1.5];
inp.Nrun=10000;
inp.bz=30;
p_value_target=0.05;
out=search_devX1_p_value_Mahal_rPCA(range_dev_X1 , p_value_target, inp );


end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nx ny]=size(varargin{2});

% % very important: nvar or length in varargin{1} Must eqaul to nvar (Ncol) in varargin{2}
% however in single scan dataset, as long as length of varargin{2} matched with length of varargin{1} it can be run

if nargin>=3  && (    ( ny==1 & length(varargin{1})==length(varargin{2})   ) |  (  length(varargin{1})==length(varargin{2}(1,:))  )      ) % very important: nvar or length in varargin{1} Must eqaul to nvar (Ncol) in varargin{2}

    varargin{1}=row_always(varargin{1});
    varargin{2}=transpose(varargin{2}); % follow interp1 very strange convention that opposite of chemometric format
    
Vout = interp1(varargin{:});  % this is better approach, very important to use {:} with varargin

DMest=transpose(Vout); % transpose back to chemometric convention

else
    error('mismatch in data matrix format, length in varargin{1} may not eqaul to nvar (Ncol) in varargin{2}');
end
end


%% ----- isSAME_2Matrix   [AQP_gui.m lines 23751-23789] --------------------------------------------
function out=isSAME_2Matrix(A,B)
% check to see if the contents of two matrix or vector are the same
% can handle the case A and B both are vectors but one is row vector
% while the other one is column vector
% see also isequaln structeq strcmp_CI_two_cstr_PLOT findsubmat_FV_Atrainpk
% see also comparedata ( this can be used to compare two struct !!!)
% see also ismember (esp ismember(A,B,'rows')

% e.g. A=[1 2 3]; B=[1;2 ;3];isSAME_2Matrix(A,B)
% e.g. A=[1 2 3]; B=[10;20 ;30];isSAME_2Matrix(A,B)
% e.g. A=[1 2 3]; B=[1;2 ;3;4];isSAME_2Matrix(A,B)
% e.g. A=[]; B=[1;2 ;3;4];isSAME_2Matrix(A,B)
% e.g. A=[]; B=[];isSAME_2Matrix(A,B)


if nargin==1
    out=~any(any(A));
    
elseif nargin==2
    if ~isempty(A) & ~isempty(B)

    
    if all(size(A)==size(B))
        
        out=~any(any(A-B));
    elseif  all(size(A)==size(B'))  %handle the case A and B both are vectors but one is row vector one is column vector
        out=~any(any(A-B'));
        
    else
        out=false;%because dimension mismatch between A and B
    end
    
    else
        out=false; % at least one of A or B is empty
    end
else
    error('can only take one or two inp arguments')
end
end


%% ----- isSAME_two_cstr   [AQP_gui.m lines 24084-24109] -------------------------------------------
function [out loc_mismatch]=isSAME_two_cstr(cstr1,cstr2)
% see also isequaln strcmp_CI_two_cstr_PLOT
% see also comparedata ( this can be used to compare two struct !!!)
% updated Apr 27, 2023
% see also: Cmp_AclabelT_Apr14_Apr27_BigFive
%--------------------------------------------------------
% updated Feb 21, 2024
% use following to check whether "content" of the two cstr are same or not
%  [lia,locb] =ismember(inp.cls_pick_specified_seq,sd1.LAT.clistclslabel);
% see also: AT_reseq_clistclslabel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(cstr1) && iscell(cstr2) && length(cstr1)==length(cstr2)
    
    out=  all(cellfun(@(x,y) strcmp(x,y),cstr1,cstr2));
    if out
        loc_mismatch='';
    else
        s=cellfun(@(a,b) strcmp(a,b),cstr1,cstr2);
        loc_mismatch=find(~s);
    end
else
    out=false;
    loc_mismatch=NaN;
    
end
end


%% ----- isSame_AclabelT_SampleName   [AQP_gui.m lines 24113-24130] --------------------------------
function out=isSame_AclabelT_SampleName(L)
% see also: PLS_inside_PLS_predict_ONLY_MLtool  AQP_Apply_Spectra_Avg  clistfilename2AT_AQP 
%-------------------------------------------------
% since Tcv is based on saConc4SAT_T(isamp).SampleName
% check to make sure these two match
try
AclabelT_from_saConc=arrayfun(@(x) x.SampleName{1},L.saConc,'un',0);
catch
AclabelT_from_saConc=arrayfun(@(x) x.SampleName{1},L.PLS.Tset.saConc,'un',0);
end
%-----------------------------------------------------------------------
if ~isSAME_two_cstr(AclabelT_from_saConc,L.AclabelT  )
    warning('Mismatch between AclabelT_from_saConc vs SAT.AclabelT'  );% revisit this Apr 17, 2023
    out=false;
else
    out=true;
end
end


%% ----- is_belong2subgrp_cstr   [AQP_gui.m lines 24164-24180] -------------------------------------
function all_loc_subgrp=is_belong2subgrp_cstr(listall,subgrp)
%find the indices of locations of all char vector  in listall belong to subgrp
% reverse out by ~out to get the other half of results

% see also find_belong2subgrp_cstr find_belong2subgrp is_belong2subgrp

if false
    
    listall={'ab','bc','cd','de','efg','gh'};
    subgrp={'cd','efg'};
    out=is_belong2subgrp_cstr(listall,subgrp)
    ~out
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_loc_subgrp=cellfun(@(x) ~isempty(find(strcmp(x,subgrp))),  listall);
end


%% ----- is_odd   [AQP_gui.m lines 24207-24218] ----------------------------------------------------
function out=is_odd(x)
% see also is_even
if false
    is_odd(23)
    is_odd(24)
    is_odd(24.3)
    is_odd([2 3 4])
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out=logical(mod(x,2));
end


%% ----- is_too_long_pfn   [AQP_gui.m lines 24227-24247] -------------------------------------------
function out=is_too_long_pfn(pfn)
% see also:  BatchRun_AutoQuant_DA_pipeline         xlswrite_ChkLn
if false
    
    pfn='C:\work\JDSU\Test_AQP_PowerUser\Result4OUT_cln_AQP\{Brix_Narrow-WVL_woXRS_LOOOOOOOOOOOOOOOOOOOOOOOOOOOONG_PATHFNAME_Brix}[Brix](woCabXfer)_1stDerSGFL7[PO2]+SNV\Results_AQP_1stDerSGFL7[PO2]_Xfer-PP_()_nLine1_nXtick1_Spectra_Avg_All_.mat'
is_too_long_pfn(pfn)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 fname=[repmat('a',[1 250]),'.mat'];
pfn=fullfile('C:\work\JDSU\Test_AQP_PowerUser',fname);
length(pfn)
t=123;
save(pfn,'t');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(pfn)>259         % this '259' is very important , took a while to find out this limit !!!
    out=1;
else
    out=0;
end
end


%% ----- json_AQP_OpmModel_Sequence   [AQP_gui.m lines 24757-24870] --------------------------------
function out=json_AQP_OpmModel_Sequence(pathfname_OpmModel)
%updated Aug 24, 2020 to deal with struct2cell handling of {PRO}
%------------------------------------------------------------------------------------------------------------------------------
% add following Feb 25, 2023
% disp_with_border('there is no beta in the case of Tcv operation, e.g. CS only usage case');
%------------------------------------------------------------------------------------------------------------------------------

if false
    
    inp.fullpath_yes=1;
     [clistfilename_out_Opm, nfile_out_Opm]=fdir_wPrefix_wPath('C:\work\JDSU\Test_AQP\Result4FinalModels','mat',0,'OpmModel_Beta_etc_FinalModel_',inp);
    if nfile_out_Opm==1
    pathfname_OpmModel=clistfilename_out_Opm{1};
    out=json_AQP_OpmModel_Sequence(pathfname_OpmModel)
    end
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outOpmFM=load(pathfname_OpmModel);
%%%%%%%%%%%%%%%%%%%%%%%%
%check beta 
% FinalModel.Apred=X_iAna_V;
% Y_iAna_est = [ones(size(X_iAna_P,1),1) X_iAna_P]*beta;
if ~isfield(outOpmFM,'Apred')
    Y_iAna_est_ReCalc='';
end
if ~isempty(Y_iAna_est_ReCalc )
    Y_iAna_est_ReCalc = [ones(size(outOpmFM.Apred,1),1) outOpmFM.Apred]*outOpmFM.beta;
    if ~isequal(Y_iAna_est_ReCalc,outOpmFM.Pest)
        error('mismatch among beta, Apred, and Pest')
    else
        disp_with_border('Matched among beta, Apred, and Pest  !!!  and OK to Proceed  !!! ')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%
sia_fdnOFM=string(row_always(fieldnames(outOpmFM.seq)));

if isempty(outOpmFM.seq.CabXfer)
    outOpmFM.seq.CabXfer='';            % very tricky, it only works for ''  not for []     !!!
end

try
    sia_ContentOFM=string(row_always(struct2cell(outOpmFM.seq)));%updated Aug 24, 2020 to deal with struct2cell handling of {PRO}
catch
    
     error('if bugs related to dealing with outOpmFM.seq.CabXfer=[] wrt struct2cell fixed, then supposedly should Not come to here')
     
    %updated Aug 24, 2020
    outOpmFM.seq.PP1=strrep(strrep(outOpmFM.seq.PP1,'{','_'),'}','');
    outOpmFM.seq.PP2=strrep(strrep(outOpmFM.seq.PP2,'{','_'),'}','');
    if isempty(outOpmFM.seq.CabXfer)
        %     outOpmFM.seq.CabXfer='Empty';
        %     else
        %     outOpmFM.seq.CabXfer='Unknown';
        outOpmFM.seq.CabXfer='';            % very tricky, it only works for ''  not for []     !!!
        
    end
    sia_ContentOFM=string(  row_always(struct2cell(outOpmFM.seq))  );%updated Aug 24, 2020 to deal with struct2cell handling of {PRO}
    
end
sOpmSeq=['Opm Seq : ',strwrite_all_delimiter(cellstr(sia_fdnOFM+"-"+sia_ContentOFM),'\_')];  % Seq in OpmFM
out=sOpmSeq;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% x = 0:.1:1;
% A = [x; exp(x)];
sget_snow=get_snow;

Path_tmpfolder_4json=tmp_folder_rm_mk('4json',fileparts(pathfname_OpmModel));

fname=[Path_tmpfolder_4json,'\Prepare4json_',find_keyword_between_markers( fileparts_name_wo_ext(pathfname_OpmModel),'','}'),'}','_',sget_snow,'.txt'];
ana=find_keyword_between_markers(fileparts_name_wo_ext(pathfname_OpmModel),'FinalModel_','_PLSfactor');
% delete(fname);
fid=fopen(fname,'w');
% fprintf(fid,'%6s %12s\n','x','exp(x)');
% fprintf(fid,'%6.2f %12.8f\n',A);
% url = 'https://www.mathworks.com';
% sitename = 'The MathWorks Web Site';
% 
% fprintf('<a href = "%s">%s</a>\n',url,sitename)


fprintf(fid,['%s \r\n'],['% ',ana]);

fprintf(fid,['%s \r\n'],['% ',sget_snow]);
fprintf(fid,['%s \r\n'],['% ','----------------------------------------------------------']);
fprintf(fid,['\r\n']);

fprintf(fid,['%s \r\n'],['SavitskyGolayStep']);
sOrder=outOpmFM.seq.PP1(1);
fprintf(fid,['%s \r\n'],['"Order": ','"',sOrder,'",']);

sPO=find_keyword_between_markers(outOpmFM.seq.PP1,'[PO',']');
fprintf(fid,['%s \r\n'],['"Polynomial": ','"',sPO,'",']);
sFL=find_keyword_between_markers(outOpmFM.seq.PP1,'FL','[');
fprintf(fid,['%s \r\n'],['"Points": ','"',sFL,'",']);
fprintf(fid,['\r\n']);

fprintf(fid,['%s \r\n'],['SnvStep']);
fprintf(fid,['\r\n']);

fprintf(fid,['%s \r\n'],['PlsStep']);
% fprintf(fid,['%s \r\n'],['"Coefficients": ','"',base64encode_MLcentral(outOpmFM.beta),'",']);
% matlab.net.base64encode(typecast(swapbytes(outOpmFM.beta),'uint8'))
try
fprintf(fid,['%s \r\n'],['"Coefficients": ','"',     matlab.net.base64encode(typecast(swapbytes(outOpmFM.beta),'uint8'))   ,'",']);
catch
    disp_with_border('there is no beta in the case of Tcv operation, e.g. CS only usage case');
end

fclose(fid);

disp('done with json_AQP_OpmModel_Sequence')
end


%% ----- knee_pt   [AQP_gui.m lines 24923-25110] ---------------------------------------------------
function [res_x, idx_of_result] = knee_pt(y,x,just_return)
%function [res_x, idx_of_result] = knee_pt(y,x,just_return)
%Returns the x-location of a (single) knee of curve y=f(x)
%  (this is useful for e.g. figuring out where the eigenvalues peter out)
%
%Also returns the index of the x-coordinate at the knee
%
%Parameters:
% y (required) vector (>=3 elements)
% x (optional) vector of the same size as y
% just_return (optional) boolean
%
%If just_return is True, the function will not error out and simply return a Nan on
%detected error conditions
%
%Important:  The x and y  don't need to be sorted, they just have to
%correspond: knee_pt([1,2,3],[3,4,5]) = knee_pt([3,1,2],[5,3,4])
%
%Important: Because of the way the function operates y must be at least 3
%elements long and the function will never return either the first or the
%last point as the answer.
%
%Defaults:
%If x is not specified or is empty, it's assumed to be 1:length(y) -- in
%this case both returned values are the same.
%If just_return is not specified or is empty, it's assumed to be false (ie the
%function will error out)
%
%
%The function operates by walking along the curve one bisection point at a time and
%fitting two lines, one to all the points to left of the bisection point and one
%to all the points to the right of of the bisection point.
%The knee is judged to be at a bisection point which minimizes the
%sum of errors for the two fits.
%
%the errors being used are sum(abs(del_y)) or RMS depending on the
%(very obvious) internal switch.  Experiment with it if the point returned
%is not to your liking -- it gets pretty subjective...
%
%
%Example: drawing the curve for the submission
if false
cc
x=.1:.1:3; y = exp(-x)./sqrt(x); [i,ix]=knee_pt(y,x); 
figure;plot(x,y,'b-*');
rectangle('curvature',[1,1],'position',[x(ix)-.1,y(ix)-.1,.2,.2])
axis('square');

end
%

%Food for thought: In the best of possible worlds, per-point errors should
%be corrected with the confidence interval (i.e. a best-line fit to 2
%points has a zero per-point fit error which is kind-a wrong).
%Practially, I found that it doesn't make much difference.
% 
%dk /2012



%{

% test vectors:

[i,ix]=knee_pt([30:-3:12,10:-2:0])  %should be 7 and 7
knee_pt([30:-3:12,10:-2:0]')  %should be 7
knee_pt(rand(3,3))  %should error out
knee_pt(rand(3,3),[],false)  %should error out
knee_pt(rand(3,3),[],true)  %should return Nan
knee_pt([30:-3:12,10:-2:0],[1:13])  %should be 7
knee_pt([30:-3:12,10:-2:0],[1:13]*20)  %should be 140
knee_pt([30:-3:12,10:-2:0]+rand(1,13)/10,[1:13]*20)  %should be 140
knee_pt([30:-3:12,10:-2:0]+rand(1,13)/10,[1:13]*20+rand(1,13)) %should be close to 140
x = 0:.01:pi/2; y = sin(x); [i,ix]=knee_pt(y,x)  %should be around .9 andaround 90
[~,reorder]=sort(rand(size(x)));xr = x(reorder); yr=y(reorder);[i,ix]=knee_pt(yr,xr)  %i should be the same as above and xr(ix) should be .91
knee_pt([10:-1:1])  %degenerate condition -- returns location of the first "knee" error minimum: 2

%}


%set internal operation flags
use_absolute_dev_p = true;  %ow quadratic

%deal with issuing or not not issuing errors
issue_errors_p = true;
if (nargin > 2 && ~isempty(just_return) && just_return)
    issue_errors_p = false;
end

%default answers
res_x = nan;
idx_of_result = nan;

%check...
if (isempty(y))
    if (issue_errors_p)
        error('knee_pt: y can not be an empty vector');
    end
    return;
end

%another check
if (sum(size(y)==1)~=1)
    if (issue_errors_p)
        error('knee_pt: y must be a vector');
    end
    
    return;
end

%make a vector
y = y(:);

%make or read x
if (nargin < 2 || isempty(x))
    x = (1:length(y))';
else
    x = x(:);
end

%more checking
if (ndims(x)~= ndims(y) || ~all(size(x) == size(y)))
    if (issue_errors_p)
        error('knee_pt: y and x must have the same dimensions');
    end
    
    return;
end

%and more checking
if (length(y) < 3)
    if (issue_errors_p)
        error('knee_pt: y must be at least 3 elements long');
    end
    return;
end

%make sure the x and y are sorted in increasing X-order
if (nargin > 1 && any(diff(x)<0))
    [~,idx]=sort(x);
    y = y(idx);
    x = x(idx);
else
    idx = 1:length(x);
end

%the code below "unwraps" the repeated regress(y,x) calls.  It's
%significantly faster than the former for longer y's
%
%figure out the m and b (in the y=mx+b sense) for the "left-of-knee"
sigma_xy = cumsum(x.*y);
sigma_x  = cumsum(x);
sigma_y  = cumsum(y);
sigma_xx = cumsum(x.*x);
n        = (1:length(y))';
det = n.*sigma_xx-sigma_x.*sigma_x;
mfwd = (n.*sigma_xy-sigma_x.*sigma_y)./det;
bfwd = -(sigma_x.*sigma_xy-sigma_xx.*sigma_y) ./det;

%figure out the m and b (in the y=mx+b sense) for the "right-of-knee"
sigma_xy = cumsum(x(end:-1:1).*y(end:-1:1));
sigma_x  = cumsum(x(end:-1:1));
sigma_y  = cumsum(y(end:-1:1));
sigma_xx = cumsum(x(end:-1:1).*x(end:-1:1));
n        = (1:length(y))';
det = n.*sigma_xx-sigma_x.*sigma_x;
mbck = flipud((n.*sigma_xy-sigma_x.*sigma_y)./det);
bbck = flipud(-(sigma_x.*sigma_xy-sigma_xx.*sigma_y) ./det);

%figure out the sum of per-point errors for left- and right- of-knee fits
error_curve = nan(size(y));
for breakpt = 2:length(y-1)
    delsfwd = (mfwd(breakpt).*x(1:breakpt)+bfwd(breakpt))-y(1:breakpt);
    delsbck = (mbck(breakpt).*x(breakpt:end)+bbck(breakpt))-y(breakpt:end);
    %disp([sum(abs(delsfwd))/length(delsfwd), sum(abs(delsbck))/length(delsbck)])
    if (use_absolute_dev_p)
        % error_curve(breakpt) = sum(abs(delsfwd))/sqrt(length(delsfwd)) + sum(abs(delsbck))/sqrt(length(delsbck));
        error_curve(breakpt) = sum(abs(delsfwd))+ sum(abs(delsbck));
    else
        error_curve(breakpt) = sqrt(sum(delsfwd.*delsfwd)) + sqrt(sum(delsbck.*delsbck));
    end
end

%find location of the min of the error curve
[~,loc] = min(error_curve);
res_x = x(loc);
idx_of_result = idx(loc);
end


%% ----- load_AQP_PP1_PP2_xlsx   [AQP_gui.m lines 26198-26213] -------------------------------------
function out=load_AQP_PP1_PP2_xlsx()
% typically called by AQP_gui.m
dir_orig=pwd;
cd(find_last_nonTMP_path);
%%%%%%%%%%%%%%%%%%%%%%
[filename_PPn, pathname_PPn] = uigetfile( ...
    {'PP1_PP2*.xlsx';'pp1_pp2*.xlsx';'*.*'}, ...
    'Pick a PP1_PP2 xlsx file');
out.pathfname_PPn_xlsx=[pathname_PPn,filename_PPn];
T_PPn=readtable(out.pathfname_PPn_xlsx);
out.T_PPn=T_PPn;
%%%%%%%%%%%%%%%%%%%
cd(dir_orig);

disp('done with load_AQP_PP1_PP2_xlsx')
end


%% ----- load_SamLibrary   [AQP_gui.m lines 26217-26298] -------------------------------------------
function errorStr = load_SamLibrary
%% called by --> CabXfer_Siesler48_MLtool
% Description
%   This function finds and assembles SamLibrary.dll and TextCopy.dll. The
%   location of the files will depend on whether this function is run in an
%   executable or through MATLAB directly. The output is an error string 
%   which will display the return status, indicating where the error 
%   occurred. If there is no error, then it will be empty.

%% Initialize the output
errorStr = [];

%% Locate the path containing the dlls
mainPath = [];

%Check if the program is deployed (i.e. running as an exe or from code)
if isdeployed
    if false
        %Obtain a list of all subfolders where this exe resides in the temporary app folder
        startPath = ctfroot;
        errorStr = [errorStr,' Location: ',ctfroot];
        allFoldersSt = genpath(startPath);
        allFoldersCl = textscan(allFoldersSt,'%s','delimiter',';');
        allFolders = allFoldersCl{1};
        
        %Loop through the temporary app folders in search of the dll
        trgtFile = 'SamLibrary.dll';
        for iFolder = 1:length(allFolders)
            D = dir(allFolders{iFolder,1}); D(1:2) = [];
            if any(contains({D(:).name},trgtFile))
                mainPath = allFolders{iFolder,1};
                break;
            end
        end
        if isempty(mainPath)
            errorStr = [errorStr, 'load_SamLibrary: The SamLibrary File cannot be found.'];
            return;
        end
    end % end if false
    
    mainPath = 'C:\work\JDSU\Test_AQP\Tmp4AQPliteEXE';
    
    
else
    
    
    %     mainPath = 'C:\Viavi\MATLAB Sam Files';
    mainPath = 'C:\work\JDSU\Test_AQP\Tmp4AQPliteEXE';
end
samLibPath = fullfile(mainPath,'SamLibrary.dll');

% %Check to ensure TextCopy.dll also exists in the mainPath
% textCopyPath = fullfile(mainPath,'TextCopy.dll');
% if exist(textCopyPath,'file') == 0
%     errorStr = [errorStr,'load_SamLibrary: TextCopy.dll cannot be found.'];
%     return
% end

%% Create net assembly
try
%     try
%         samLib = NET.addAssembly(samLibPath);
%         msgbox(['load from hard-coded ',samLibPath] );
%     catch
        samLibPath=which('SamLibrary.dll');
%         msgbox(samLibPath);
        samLib = NET.addAssembly(samLibPath);
%     end
    
catch ex
    errorStr = [errorStr, ' load_SamLibrary: Error during Net.addAssembly of SamLibrary.dll.'];
    return;
end

% try 
%     textCopy = NET.addAssembly(textCopyPath);
% catch ex
%     errorStr = [errorStr, ' load_SamLibrary: Error during Net.addAssembly of TextCopy.dll.'];
%     return;
% end

end


%% ----- loc_preprocess   [AQP_gui.m lines 26350-26429] --------------------------------------------
function new_x = loc_preprocess(old_x,recipe)
% extracted from function [result,method] = uNIR_calc_method(spectrum,method)
if false
    
    % c_model --> "HX_1700_AS_SVM_SG2nd.xml"
    % L0.spectrum --> "3% H2O2_1_2013Sep03_1245.xls"
    
    figure;hold on;
    L0=load_local_try('Mat_before_preproc_test_uNIR.mat');
    tmp_y = L0.spectrum(:);
    c_model = L0.method.model(1);
    plot(tmp_y,'k')
    
    n_pre=1;
    tmp_y = loc_preprocess(tmp_y,c_model.preprocess(n_pre));
    L1=load_local_try('Mat_after_1st_preproc_test_uNIR.mat');
    if isSAME_2Matrix( L1.tmp_y,tmp_y)
        disp('match 1st preprocess');
        plot(tmp_y,'r')
    else
        error('MIS-match 1st preprocess')
    end
    
    
    n_pre=2;
    tmp_y = loc_preprocess(tmp_y,c_model.preprocess(n_pre));
    L2=load_local_try('Mat_after_2nd_preproc_test_uNIR.mat');
    
    if isSAME_2Matrix( L2.tmp_y,tmp_y)
        disp('match 2nd preprocess');
        plot(tmp_y,'g')
    else
        error('MIS-match 2nd preprocess')
    end
    
    legend({'before preprocess','after 1st preprocess','after 2nd preprocess'})
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isfield(recipe,'type')
    disp('Unable to preprocess.  No type')
    new_x = old_x;
    return
end

switch lower(recipe.type)
    case 'rtoa',
        new_x = -log10(old_x);
    case {'mean_center','mean center','zero mean'}
        new_x = old_x - mean(old_x);
    case {'normalize_mean'},
        % make the average of x equal one
        new_x = old_x/mean(old_x);
    case 'snv',
        new_x = (old_x - mean(old_x))/std(old_x);
    case {'sg_smooth','sg_0',}
        % ignore poly_order for now -- assume 3
        new_x = lsq_smooth(old_x,recipe.width);
    case {'sg_1st','sg_1',}
        % ignore poly_order for now -- assume 3
        new_x = lsq_deriv(old_x,recipe.width);
    case {'sg_2nd','sg_2',}
        % ignore poly_order for now -- assume 3
        new_x = lsq_dderiv(old_x,recipe.width);
    case {'chop'}
        % subset of wavelengths
        new_x = old_x;
        if isfield(recipe,'start')
            new_x = new_x(recipe.start+1:end);
        end
        if isfield(recipe,'end')
            new_x = new_x(1:end-recipe.end);
        end
    otherwise,
        disp(sprintf('Preprocess %s not yet supported',recipe.type));
        new_x = old_x;
end

return
end


%% ----- lsq_dderiv   [AQP_gui.m lines 26693-26782] ------------------------------------------------
function [ydata,x] = lsq_dderiv(data,npts,x)
% lsq_deriv: smoothed 2nd derivative of equally-spaced noisy data using least squares fitting
% 
% Usage: [ydata,xdata] = lsq_dderiv(data, npts [, xdata] ) performs npts smoothing of data
%   npts can be any odd number from 5 to 25 (default is 5)
%   ydata contains (npts-1) fewer points
%   xdata is also shortened so you don't have to think
%    (if xdata is included, I also divide by delta x)
%
% Implements quadratic algorithm from "Smoothing and Differentiation of Data by 
%  Simplified Least Squares Procedures," A. Savitzky and M. Golay, Analytical Chemistry 36:8,
%  July 1964, pp. 1627-1639.  
%
% Implemented by CAH 000803 on recommendation from K. Cearns
% Transferred by MKT 010824 to common directory

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% you must use Column Vector !!!
data=col_vector_ALWAYS(data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
   npts = 5;
end

% assign convolution template (filter) for smoothing
switch npts
case 5,
   tplt = [2,-1,-2,-1,2];
case 7,
   tplt = [5,0,-3,-4,-3,0,5];
case 9,
   tplt = [28,7,-8,-17,-20,-17,-8,7,28];
case 11,
   tplt = [15,6,-1,-6,-9,-10,-9,-6,-1,6,15];
case 13,
   tplt = [22,11,2,-5,-10,-13,-14,-13,-10,-5,2,11,22];
case 15,
   tplt = [91,52,19,-8,-29,-44,-53,-56,-53,-44,-29,-8,19,52,91];
case 17,
   tplt = [40,25,12,1,-8,-15,-20,-23,-24,-23,-20,-15,-8,1,12,25,40];
case 19,
   tplt = [51,34,19,6,-5,-14,-21,-26,-29,-30,-29,-26,-21,-14,-5,6,19,34,51];
case 21,
   tplt = [190,133,82,37,-2,-35,-62,-83,-98,-107,-110,-107,-98,-83,-62,-35,-2,37,82,133,190];
case 23,
   tplt = [77,56,37,20,5,-8,-19,-28,-35,-40,-43,-44,-43,-40,-35,-28,-19,-8,5,20,37,56,77];
case 25,
   tplt = [92,69,48,29,12,-3,-16,-27,-36,-43,-48,-51,-52,-51,-48,-43,-36,-27,-16,-3,12,29,48,69,92];
otherwise,
   error(sprintf('%d-point smoothing not supported.  Try an odd integer from 5 to 25.',npts));
end

% debug
if any(tplt ~= fliplr(tplt))
    error(sprintf('bad template for %d-point 2nd derivative -- call support',npts));
end

% I don't completely understand, but I think with derivatives the weights are squared into the norm
%  (and second derivative would cube the weights, and...)
%disp(sprintf('%d-point norm is %d',npts,sum(abs(tplt.^2))));

% negative sign added by CAH 001016
%ydata = -conv(data,tplt)*2/sum((tplt.^2));
% negative sign removed by CAH 130408
% CAH 130620: switched to "same" syntax on convolution, so I could put it
% in a for loop and operate on multiple columns of data
%ydata = conv(data,tplt)*2/sum((tplt.^2));
ydata = data;
for n = 1:size(ydata,2);
    ydata(:,n) = conv(ydata(:,n),tplt,'same')*2/sum((tplt.^2));
end




chops = npts-1;

%ydata = ydata( (chops+1):(end-chops));
ydata = ydata( (chops/2+1):(end-chops/2),: ); %orig approach by CAH
% ydata = ydata((chops/2+1):(end-chops/2) ); % modified by CH, Oct.1, 2013




if nargin > 2
   ydata = ydata / (x(2)-x(1)).^2;
   x = x( (chops/2+1):(end-chops/2) );
end
end


%% ----- lsq_deriv   [AQP_gui.m lines 26786-26850] -------------------------------------------------
function [ydata,x] = lsq_deriv(data,npts,x)
% lsq_deriv: smoothed derivative of equally-spaced noisy data using least squares fitting
% 
% Usage: [ydata,xdata] = lsq_deriv(data, npts [, xdata] ) performs npts smoothing of data
%   npts can be any odd number from 5 to 25 (default is 5)
%   ydata contains (npts-1) fewer points
%   xdata is also shortened so you don't have to think
%    (if xdata is included, I also divide by delta x)
%
% Implements quadratic algorithm from "Smoothing and Differentiation of Data by 
%  Simplified Least Squares Procedures," A. Savitzky and M. Golay, Analytical Chemistry 36:8,
%  July 1964, pp. 1627-1639.  
%
% Implemented by CAH 000803 on recommendation from K. Cearns
% Transferred by MKT 010824 to common directory

if nargin < 2
   npts = 5;
end

% assign convolution template (filter) for smoothing
switch npts
case 5,
   tplt = [-2:2];
case 7,
   tplt = [-3:3];
case 9,
   tplt = [-4:4];
case 11,
   tplt = [-5:5];
case 13,
   tplt = [-6:6];
case 15,
   tplt = [-7:7];
case 17,
   tplt = [-8:8];
case 19,
   tplt = [-9:9];
case 21,
   tplt = [-10:10];
case 23,
   tplt = [-11:11];
case 25,
   tplt = [-12:12];
otherwise,
   error(sprintf('%d-point smoothing not supported.  Try an odd integer from 5 to 25.',npts));
end

% debug
% I don't completely understand, but I think with derivatives the weights are squared into the norm
%  (and second derivative would cube the weights, and...)
%disp(sprintf('%d-point norm is %d',npts,sum(abs(tplt.^2))));

% negative sign added by CAH 001016
ydata = -conv(data,tplt)/sum(abs(tplt.^2));

chops = npts-1;

ydata = ydata( (chops+1):(end-chops));

if nargin > 2
   ydata = ydata / (x(2)-x(1));
   x = x( (chops/2+1):(end-chops/2) );
end
end


%% ----- lsq_smooth   [AQP_gui.m lines 26854-26913] ------------------------------------------------
function [ydata,x] = lsq_smooth(data,npts,x)
% lqs_smooth: smooth equally-spaced noisy data using least squares fitting
% 
% Usage: [ydata,xdata] = lsq_smooth(data, npts [, xdata] ) performs npts smoothing of data
%   npts can be any odd number from 5 to 25 (default is 5)
%   ydata contains (npts-1) fewer points
%   xdata is also shortened so you don't have to think
%
% Implements cubic/quadratic algorithm from "Smoothing and Differentiation of Data by 
%  Simplified Least Squares Procedures," A. Savitzky and M. Golay, Analytical Chemistry 36:8,
%  July 1964, pp. 1627-1639.  
%
%
% Implemented by CAH 000803 on recommendation from K. Cearns

if nargin < 2
   npts = 5;
end

% assign convolution template (filter) for smoothing
switch npts
case 5,
   tplt = [-3,12,17,12,-3];
case 7,
   tplt = [-2,3,6,7,6,3,-2];
case 9,
   tplt = [-21,14,39,54,59,54,39,14,-21];
case 11,
   tplt = [-36,9,44,69,84,89,84,69,44,9,-36];
case 13,
   tplt = [-11,0,9,16,21,24,25,24,21,16,9,0,-11];
case 15,
   tplt = [-78,-13,42,87,122,147,162,167,162,147,122,87,42,-13,-78];
case 17,
   tplt = [-21,-6,7,18,27,34,39,42,43,42,39,34,27,18,7,-6,-21];
case 19,
   tplt = [-136,-51,24,89,144,189,224,249,264,269,264,249,224,189,144,89,24,-51,-136];
case 21,
   tplt = [-171,-76,9,84,149,204,249,284,309,324,329,324,309,284,249,204,149,84,9,-76,-171];
case 23,
   tplt = [-42,-21,-2,15,30,43,54,63,70,75,78,79,78,75,70,63,54,43,30,15,-2,-21,-42];
case 25,
   tplt = [-253,-138,-33,62,147,222,287,322,387,422,447,462,467,462,447,422,387,322,287,222,147,62,-33,-138,-253];
otherwise,
   error(sprintf('%d-point smoothing not supported.  Try an odd integer from 5 to 25.',npts));
end

% debug
%disp(sprintf('%d-point norm is %d',npts,sum(tplt)));

ydata = conv(data,tplt)/sum(tplt);

chops = npts-1;

ydata = ydata( (chops+1):(end-chops));

if nargin > 2
   x = x( (chops/2+1):(end-chops/2) );
end
end


%% ----- marker_CH   [AQP_gui.m lines 26917-26971] -------------------------------------------------
function marker_out=marker_CH(marker_SingleLetter)
% convert single letter marker into appropriate marker
% listing of possible marker for a plot
% [ + | o | * | . | x | square | diamond | v | ^ | > | < | pentagram | hexagram | none ]
%  list_all_SL_marker='+o*.xv^><sdph'
% e.g  'd'  --> 'diamond'
% e.g. test_marker_CH
%e.g marker_out=marker_CH('d')
%e.g marker_out=marker_CH('*')

% e.g marker_out=marker_CH('fda')
% e.g marker_out=marker_CH({'d'})
% e.g marker_out=marker_CH(3)
% e.g marker_out=marker_CH('a')


% for 32 unique combinations of color/marker
% listcolor='krgbymcpolasvhkrgbymcpolasvhkrgb'
% listmarker='>+<pxodh>+<pxodh>+<pxodh>+<pxodh';
% allcomb=arrayfun(@(x,y) [x,y],listcolor,listmarker,'uniformoutput',false)
% unique(allcomb)


if ischar(marker_SingleLetter) && length(marker_SingleLetter)==1

    switch lower(marker_SingleLetter)
        case 's'
            marker_out='square';
        case 'd'
            marker_out='diamond';

        case 'p'
            marker_out='pentagram';

        case 'h'
            marker_out='hexagram';


        case 'n'   %without marker
            marker_out='none';


        otherwise  %if marker_SingleLetter is already one of '+o*.xv^><' then simply repeat itself
            if strfind('+o*.xv^><',lower(marker_SingleLetter))
            marker_out= marker_SingleLetter;
            else
             marker_out='none';   % if not match anything return 'none'
            end

    end
else
error('only single letter input allowed');

end
end


%% ----- mat2cell_CH   [AQP_gui.m lines 26975-27012] -----------------------------------------------
function out=mat2cell_CH(A,insert_type)
% see also mat2tiles, mat2cell, SAinsert_mat2cell
% insert_type should be either 'row' or 'col'
% e.g. A=[2 3 4;1 3 2];mat2cell_CH(A,'row')
% A=[2 3 4;1 3 2];mat2cell_CH(A,'col')
% e.g. A=[2 3 4;1 3 2];mat2cell_CH(A,'row')
% A=[2 3 4;1 3 2];mat2cell_CH(A,'Column')
% A=[2 3 4;1 3 2];mat2cell_CH(A,'OtherType')
%-------------------------------------------------------
% see also: mat2cell_CH_by_row
%=============================================================
if false
    cc
     A=[2 3 4;1 3 2];mat2cell_CH(A,'row')
     %--------------------------------------------------
     cc
     A=[2 3 4;1 3 2];mat2cell_CH(A,'col')
end
%---------------------------------------------------------------------
if strfind(lower(insert_type),'row')
    casetype='row';
elseif strfind(lower(insert_type),'col')
        casetype='col';
else
    warning('insert_type not supported, pls use either ''row'' or ''col''  ' );
    return;
    
end


switch casetype
    case 'row'
        out=mat2cell(A,ones(1,length(A(:,1))),length(A(1,:))  );
        
    case 'col'
         out=mat2cell(A,length(A(:,1)),ones(1,length(A(1,:))) );
end
end


%% ----- mncn   [AQP_gui.m lines 27779-27796] ------------------------------------------------------
function [mcx,mx] = mncn(x)
%MNCN Mean center scales matrix to mean zero.
%  Mean centers matrix (x), returning a matrix with
%  mean zero columns (mcx) and the vector of means
%  (mx) used in the scaling.
%
%I/O: [mcx,mx] = mncn(x);
%
%See also: AUTO, MDAUTO, MDMNCN, MDRESCAL, MDSCALE, SCALE, RESCALE

%Copyright Eigenvector Research 1991-98
%Modified 11/93
%Checked on MATLAB 5 by BMW  1/4/97

[m,n] = size(x);
mx    = mean(x);
mcx   = (x-mx(ones(m,1),:));
end


%% ----- mscorr   [AQP_gui.m lines 27800-27841] ----------------------------------------------------
function [sx,alpha,beta] = mscorr(x,xref,mc);

%MSCORR Multiplicative scatter correction (MSC)
%  MSCORR performs multiplicative scatter correction
%  (aka multiplicative signal correction) on an input
%  matrix of spectra (x) regressed against a reference
%  spectra (xref).  If the optional input (mc) is 
%  1 {default} each spectra is mean centered, if (mc) 
%  is set to 0 no mean centering is performed.
%  The outputs are the corrected spectra (sx), the 
%  intercepts/offsets (alpha) and the multiplicative 
%  scatter factor/slope (beta).
%
%I/O: [sx,alpha,beta] = mscorr(x,xref,mc);
%
%See also: STDFIR, STDGEN, STDGENNS, STDGENDW
 
%Copyright Eigenvector Research, Inc. 1997-99
%nbg 3/99
 
[m,n]       = size(xref);
if m>1&n>1, error('Input xref must be a vector'), end
if n>m
  xref      = xref'; %make xref a column vector
  m         = n;
end
if m~=size(x,2)
  error('Input xref length not compatible with x')
end
if nargin<3, mc = 1; end
if mc==0
  alpha       = zeros(size(x,1),1);
  beta        = (xref\x')';
  sx          = x./beta(:,ones(1,size(x,2)));
else
  [sx,alpha]  = mncn(x');
  [xref,mx]   = mncn(xref);
  beta        = (xref\sx)';
  alpha       = (alpha-mx*beta')';
  sx          = (x-alpha(:,ones(m,1)))./beta(:,ones(1,m));
end
end


%% ----- normaliz1   [AQP_gui.m lines 27847-27876] -------------------------------------------------
function [ndat,norms] = normaliz1(dat);
%NORMALIZ1 Normalizes rows of matrix to unit vectors
%  This function can be used for pattern normalization, which
%  is useful for preprocessing in some pattern recognition 
%  applications. The input is the data matrix (dat). The
%  output is the matrix of normalized data (ndat) and the
%  vector of norms used in the normalization (norms).
%  Warnings are given for any zero vectors found.
%
%I/O: [ndat,norms] = normaliz1(dat);
%
%See also: AUTO, BASELINE, MNCN

%Copyright Eigenvector Research, Inc. 1997-98
%bmw May 30, 1997

[m,n] = size(dat);
ndat = dat;
norms = zeros(m,1);
for i = 1:m
  if norm(ndat(i,:)) ~= 0
    norms(i) = norm(ndat(i,:),1);
    ndat(i,:) = ndat(i,:)/norms(i);
  else
   %disp(sprintf('The norm of sample %g is 0, sample not normalized!',i))
      error ('The norm of sample = 0, sample not normalized!')
   ndat
  end
end
end


%% ----- normasmc_trainpk_pred   [AQP_gui.m lines 27882-27938] -------------------------------------
function [trainpk_normasmc,pred_normasmc,asmc_mean_std]=normasmc_trainpk_pred(trainpk,pred,para_norm,para_asmc)
% add new option para_asmc=3 --> apply UX's WtSDev or divide by Tset's std (or autoscale without meancentering)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch para_norm
    case 1
        trainpk_norm=normaliz1(trainpk);
        pred_norm=normaliz1(pred);
    case 0
        trainpk_norm=trainpk;
        pred_norm=pred;
end
switch para_asmc
    case 1
        [trainpk_normasmc,meanT,stdT]=auto(trainpk_norm);
        pred_normasmc=scale(pred_norm,meanT,stdT);
        asmc_mean_std.meanT=meanT;
        asmc_mean_std.stdT=stdT;
    case 2
        [trainpk_normasmc,meanT]=mncn(trainpk_norm);
        pred_normasmc=scale(pred_norm,meanT);
        asmc_mean_std.meanT=meanT;
    case 0
        trainpk_normasmc=trainpk_norm;
        pred_normasmc=pred_norm;
        asmc_mean_std=[];
    case 3   % UX's WtSDev
        stdT=std(trainpk_norm);
        trainpk_normasmc=trainpk_norm./repmat(stdT,[length(trainpk_norm(:,1)) 1]);
        pred_normasmc=pred_norm./repmat(stdT,[length(pred_norm(:,1)) 1]);
        asmc_mean_std.meanT=[];
        asmc_mean_std.stdT=stdT;

case 4
    % libsvm scaled to [0 - 1]
        [trainpk_normasmc,meanT,stdT]=auto(trainpk_norm);
        
          min_trainpk_norm  =    min(trainpk_norm)  ;
          max_trainpk_norm  =    max(trainpk_norm)  ;
          range_trainpk_norm = max_trainpk_norm- min_trainpk_norm ;

          trainpk_normasmc= bsxfun(@rdivide, trainpk_norm-min_trainpk_norm ,range_trainpk_norm);                                  % example #1a usage of bsxfun
          
%         pred_normasmc=scale(pred_norm,meanT,stdT);
          pred_normasmc= bsxfun(@rdivide, pred_norm-min_trainpk_norm ,range_trainpk_norm);                                  % example #1a usage of bsxfun

          if false
              figure;hold on;
              plot(trainpk_normasmc','b-O') ;
                plot(pred_normasmc','r-*') ;
          end

        asmc_mean_std.meanT=NaN;
        asmc_mean_std.stdT=NaN;
        
end
end


%% ----- optPLS_Unscrambler_CH   [AQP_gui.m lines 28175-28310] -------------------------------------
function [optimalF PlsfactorScan all_RMSE_PLS_Tcv_OR_resVar]=optPLS_Unscrambler_CH(pfn,inp)
% This function is used to determine the optimal PLS factors following the rules by Unscrambler. 
% Note: Since not all details of Unscrambler rules were shared, this
% function will not generate idential results to Unscrambler for some cases.
% Input: Pest 
%   1st column: index for cross validation
%   2nd column: reference values
%   3rd to end columns: predicted values at PLS factors from 1 to the maxim
%                       number of PLS factors tested
% Output: optimalF is the determined optimal PLS factor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if false
    
    cc
    pfn='C:\work\JDSU\AAQP\Test_AAQP\Test_Input4LSUX_OPf\sent2LS\Test_Input4LSUX_OPf_sent2LS_0929_5pm\Pest4LSUX-OpmPLSfactor_BasedOn_Tset_in_{T-M1-105_P-M1-109}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls48_nsampT288_nsampP288.mat';
    inp.fig_yes=0;
    optimalF=optPLS_Unscrambler_CH(pfn,inp)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     cc
    pfn='C:\work\JDSU\AAQP\Test_AAQP\Test_Input4LSUX_OPf\sent2LS\Test_Input4LSUX_OPf_sent2LS_0929_5pm\Pest4LSUX-OpmPLSfactor_BasedOn_Tset_in_{T-M1-105_P-M1-109}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls48_nsampT288_nsampP288.mat';
    inp.fig_yes=1;
    optimalF=optPLS_Unscrambler_CH(pfn,inp)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cc
    pfn='C:\work\JDSU\AAQP\Test_AAQP\Test_Input4LSUX_OPf\sent2LS\sent2LS_0929_4pm\Pest4LSUX-OpmPLSfactor_BasedOn_Tset_in_{T-S1-550_P-S1-552}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls48_nsampT959_nsampP960.mat';
    optimalF=optPLS_Unscrambler_CH(pfn)

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
fig_yes=inp.fig_yes;
catch
 fig_yes=0;   
end
%%%%%%%%%%%%%%%%%%%
if ischar(pfn)
L=load(pfn);
Pest=L.Pest;
else
 Pest=   pfn;
end


tstart = tic;
calY=Pest(:,1);
cv=Pest(:,2);
% Calculate the total residual variance for Y.
resVar(1)=0;
for i=1:length(unique(cv))
    index1=find(cv==i);
    index2=find(cv~=i);
    meanSeg(i,1)=mean(calY(index2));
    res0(index1,1)=calY(index1)-meanSeg(i,1);
    resVar(1)=resVar(1)+sum(res0(index1).^2)...
        /length(index1)/length(unique(cv));
end
lv=size(Pest,2)-2;
for i=1:lv
    res{i}=Pest(:,i+2)-calY;
    resVar(i+1)=0;
    for j=1:length(unique(cv))
        index1=find(cv==j);
        resVar(i+1)=resVar(i+1)+sum(res{i}(index1).^2)...
            /length(index1)/length(unique(cv));
    end
end

%%% Plot the total residual variance for Y vs the number of PLS factors
if fig_yes
figure
plot([0:lv],resVar,'-o');
xlabel('Latent Variables');
ylabel('Residual Variance');
end
%%% General rule to determine the optimal PLS factor
for i=1:lv+1
    expression(i)=resVar(i)+(i-1)*0.01*resVar(1);
end
for i=1:lv
    dif=expression(i)-expression(i+1);
    if dif>0
        label{i,1}='One more factor';
    else
        label{i,1}='Stop';
    end
end
idx=strcmp(label,'Stop');
factors=[1:lv];
index=factors(idx);
if isempty(index)
    optimalF=1;
else
    optimalF=index(1)-1;
end
%%% For irregular resVar profiles
for i=1:length(index)-1
    dif=expression(index(i))-expression(index(i+1));
    if dif>0 
        optimalF=index(i+1)-1;
    elseif optimalF~=0;
        break;
    else
        [~,optimalF]=min(resVar);
        optimalF=optimalF-1;
    end
end
% Special case: when PLS factor for the minimum resVar is more reasonable
% if min(resVar)*1.2<resVar(optimalF+1)
%    [~,m]=min(resVar);
%    optimalF=m-1;
% end
if optimalF<=0
    optimalF=1;
end
% plot([0:lv],resVar,'-o');
if fig_yes
loc_OpmF=find([0:lv]==optimalF);
hold on;
plot(optimalF,resVar(loc_OpmF),'r*');
title({ [ strrep(fileparts_name_ext(pfn),'_','\_') ];['Opm PLS factor = ',num2str(optimalF)]  });
set(gcf,'position',[ 0.7297    0.2463    1.2193    0.5433]*1000);
end

% output the following
PlsfactorScan=[0:lv];
all_RMSE_PLS_Tcv_OR_resVar=resVar;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

telapsed = toc(tstart);
disp_with_border(['time elapsed = ',num2str(telapsed),'sec']);
done_with_this_function;
end


%% ----- p_value_TO_z_value   [AQP_gui.m lines 28348-28372] ----------------------------------------
function z=p_value_TO_z_value( p )
% pls use p_value_TO_z_score 
% because z_score is a better statistics term than z_value
%-----------------------------------------------
% see also: p_value_TO_z_score norminv  p_value_vs_sigma_dist_etc
%==================================================
if false
    
    
    z=p_value_TO_z_value( 0.025 )
    %----------------------------------
    z=p_value_TO_z_value( 0.1587 )
    %----------------------------------
    z=p_value_TO_z_value( 0.0015 )
    
    
    
    
end
%=======================================================
z = norminv(1-p);
%--------------------------------------------------------

done_with_this_function;
end


%% ----- plot_45degree_line   [AQP_gui.m lines 28865-28890] ----------------------------------------
function out=plot_45degree_line(sColor)
% draw a 45 degree line (always thru [0 0] though)
% see also plot_Regress_45_degree_line
if false
    
    figure;hold on;
    plot(rand(10),'r*');
    
    out=plot_45degree_line('b');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure;hold on;
    plot(rand(5),'r*');
    
    out=plot_45degree_line;
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('sColor','var')
    sColor='b'; % default sColor
end
hold on;
ax=axis;
h45=  line([0 max(ax([2 4])')  ],[0 max(ax([2 4])')],'color',sColor,'linewidth',2);
out=h45;
end


%% ----- plot_Regress_45_degree_line   [AQP_gui.m lines 28985-29058] -------------------------------
function plot_Regress_45_degree_line(Y,Yest,inp)
% plot regress points (true values and estimated values) and 45 degree line
% see also plot_45degree_line
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
    cc
    fignum=figure;
    pfn='C:\work\4GL\Test_Glucose_PLS\Pest_etc_Feb20\Pest_Pav_GL_Split_Tset_of_R1_Feb20_nsamp131.mat';
   L=load(pfn );
   inp.fignum=fignum;
   plot_Regress_45_degree_line(L.Pav,L.Pest,inp);
  [RMSE out]= RMS_error_woNaN_N(L.Pav,L.Pest);
  title({   strrep( fileparts_name_ext(pfn),'_','\_') ;   ['RMSE=',num2str(RMSE),'   MAE=',num2str(out.MAE)]});
  ylabel('P est');xlabel('P actual');
   
end
%=========================================================
try
line_prop_samples=inp.line_prop_samples;
catch
line_prop_samples='r*';    
end

try
line_prop_45degree=inp.line_prop_45degree;
catch
line_prop_45degree='b:';    
end

try
    plot_45degree_yes=inp.plot_45degree_yes
catch
    plot_45degree_yes=1;
end



try 
    stitle=inp.stitle;
catch
   stitle=''; 
end


if isfield(inp,'fignum')
   hfig=figure(inp.fignum);
  
else
 hfig=figure;
end
 hold on
             % hp_samples=  plot(Y,Yest,line_prop_samples);
             hp_samples=  plot(Y,Yest,'color',color_CH(line_prop_samples(1)),'marker',marker_CH(line_prop_samples(2)),'linestyle','none');
                ax_now=axis;
                
                %min_45deg=min(ax_now([1 3]));
                min_45deg=0;
                
                
                max_45deg=min(ax_now([2 4]));
                if plot_45degree_yes
              hp_45degree=  plot([min_45deg max_45deg],[min_45deg max_45deg],line_prop_45degree,'linewidth',2);                  % Theoretical 45� regression line
                else
               hp_45degree='';     
                end
              
              xlabel('Actual Y values');
              ylabel('Predicted Y values')
              title(stitle);
                out.hfig=hfig;
                out.hp_samples=hp_samples;
                out.hp_45degree=hp_45degree;
end


%% ----- plot_wvl_grids   [AQP_gui.m lines 29383-29406] --------------------------------------------
function hw=plot_wvl_grids(wvl,inp)
if false
inp4LR.str_plot='g-O';
inp4LR.MarkerSize=12;

plot_wvl_grids(wvl_LR,inp4LR);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp4LR.str_plot='b-*';
plot_wvl_grids(wvl_LR,inp4LR);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isa(inp,'struct')
    hw=plot(wvl,ones(size(wvl)),inp);
    
else
    if isfield(inp,'MarkerSize')
        hw=plot(wvl,ones(size(wvl)),inp.str_plot,'MarkerSize',inp.MarkerSize);
        
    else
        hw=plot(wvl,ones(size(wvl)),inp.str_plot);
    end
end
end


%% ----- prep_IDRC_shootout_MLtool   [AQP_gui.m lines 29429-29506] ---------------------------------
function out=prep_IDRC_shootout_MLtool(pathIDRC,inp)
% this function within AQP_gui.m is called by --> LoadXlsx4AQP()
% this function  will call --> clistfilename2AT_AQP
%  location of CS with NaN as Ref values (potentially these will be used for XSmst)
%         % parsing of orig CS to CS with Ref vs XSmst, this is the location that ID_XRS can be used to extract XSmst
% implement Spectra_Avg_Method ['mean' (default for AQPlite), 'median', 'all' (default for AQP) ]
%
if false
    
    clear;close all;
%      pathIDRC='C:\work\JDSU\IDRC_ShootOut\ManufacturerA'
  % pathIDRC='C:\work\JDSU\IDRC_ShootOut\ManufacturerB'
%          pathIDRC='C:\work\JDSU\IDRC_ShootOut\ManufacturerC'
% pathIDRC='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\RawXLS\ManufacturerC_wConc_clean'
% pathIDRC='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\RawXLS\ManufacturerC_wConc_orig'
% pathIDRC='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\RawXLS\ManufacturerC_wConc_orig_fixed'
%  pathIDRC='C:\work\JDSU\ModelsTransferMLtool\TestSite\mock\RawXLS\mC_Clean_BI_CH'
 
     clear;close all;

  pathIDRC='C:\work\JDSU\ModelsTransferMLtool\IDRC_raw_xls\CS_ManufacturerA'  % mA123

%       inp.PP_methods.pp1='1stDerSGw13' ;inp.PP_methods.pp2='SampMncn';   %  '1stDerSGw41'  '1stDerSGw21'  'SampMncn' 'SGw5'   '1stDerSGDiederick'  'none' '1stDer'   '2ndDer'
%         inp.PP_methods.pp1='1stDerSGw5' ;inp.PP_methods.pp2='SampMncn';   %  '1stDerSGw41'  '1stDerSGw21'  'SampMncn' 'SGw5'   '1stDerSGDiederick'  'none' '1stDer'   '2ndDer'
          inp.PP_methods.pp1='none' ;inp.PP_methods.pp2='none';   %  '1stDerSGw41'  '1stDerSGw21'  'SampMncn' 'SGw5'   '1stDerSGDiederick'  'none' '1stDer'   '2ndDer'

    inp.AnaName='Protein';
    inp.CSn='123';  % for A1, A2, and A3, and B1, B2, and B3
   out= prep_IDRC_shootout_MLtool(pathIDRC,inp)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Inp.Spectra_Avg_Method=inp.handles.Spectra_Avg_Method.String{handles.Spectra_Avg_Method.Value};

[clistfilename, nfile]=fdir_wildcard_wPath(pathIDRC,'.xls');

% ManuCom=find_keyword_between_markers(pathIDRC,'Manufacturer','');
ManuCom='';



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch inp.CS_XRS_Val
        case 'CS'
            

                [SAT_CalSet pathfname_CalSet_MAT inp out_clistfilename2AT]=clistfilename2AT_AQP(clistfilename,'CS',['CalSet',ManuCom,inp.CSn],inp);
                out.SAT_CS=SAT_CalSet;
                out.pathfname_CalSet_MAT=pathfname_CalSet_MAT;
                try
                 out.fname_XSwoRef=out_clistfilename2AT.fname_XSwoRef;
                 out.SAT_XSwoRef=out_clistfilename2AT.SAT_XSwoRef;
                end
            
        case 'XRS'
            
                [SAT_XRS pathfname_XRS_MAT inp out_clistfilename2AT ]=clistfilename2AT_AQP(clistfilename,'XRS','',inp);
                
                out.SAT_XRS=SAT_XRS;
                out.pathfname_XRS_MAT=pathfname_XRS_MAT;
                
           
        case {'Val','UDM','VAL'}   %  'Val' or 'VAL'  % case insensitive

                [SAT_Val pathfname_Val_MAT inp out_clistfilename2AT]=clistfilename2AT_AQP(clistfilename,inp.CS_XRS_Val,'',inp);
                out.SAT_Val=SAT_Val;
                out.pathfname_Val_MAT=pathfname_Val_MAT;
            
    end
% out.SAT_CS=SAT_CalSet;
% out.pathfname_CalSet_MAT=pathfname_CalSet_MAT;



out.AnaName=  inp.AnaName;
disp('finish prep_IDRC_shootout()')
end


%% ----- preprocess_NIR_spectra   [AQP_gui.m lines 29513-29842] ------------------------------------
function [rawSpectra_aftPP1 spp1 out]=preprocess_NIR_spectra(allWL_rawSpectra_orig,pp1,inp)
%------------------------------------------------------------------------
% this one is used by AQP etc
% function preprocess_NIR_spectra()
% one of the commonly calling parent functions for this --> preprocess_ATsaConc
% % if ~isempty(strfind(pp1,'DerSGw'))
%         % this will be calling --> apply_1stDer()
%         
%     elseif  ~isempty(strfind(pp1,'DerSGFL'))
%          % this will be calling --> apply_NstDer()
%
% preprocessing or pretreatment engine function
% see also preprocess_ATsaConc, apply_NstDer , apply_1stDer,  RS2AT   pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP
%==============================================================================
if false

    cc
%     pfn='RawSpectra_allScans_Chang_CARE_fVS_Nov22.mat';
    pfn= 'C:\work\JDSU\mfiles\OOP\ssds\dataset_test_PP1_w_2files\RawSpectra_allScans_Chang_CARE_fVS_Nov22.mat'
    L=load_local_try(pfn);
    pp1='1stDerSGFL5[PO2]';
    [rawSpectra_aftPP1 ]=preprocess_NIR_spectra(L.all_RS,pp1);
    figure;plot(L.all_RS','b');
    figure;plot(rawSpectra_aftPP1','r');




end
%==============================================================================
% important locations
% added to cope with PRO style pretreatment
% % fixed this to deal with non-MicroNIR grids, Nov 24, 2020
% % updated to deal with correct way of running {PRO} with SNV, Nov 30, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
show_MSC_TP_yes=0;
if nargin==2
    inp='';
elseif nargin==3
    disp('deal with MSC case');
else
    error('can not handle this nargin')
end
%%%%%%%%%%%%%%%%%%%%
disp(['apply ',pp1])
% pp1_alt=remove_keyword_between_markers(pp1,'1stDerSGw','','keepLHS');
% if strcmp(pp1_alt,pp1)
% pp1_alt=remove_keyword_between_markers(pp1,'DerSGw','','keepLHS');
% 
% end


% 'SGw*'  '~DerSGw*' '~DerSGFL*'


if ~isempty(strfind(pp1,'DerSG'))
    
    if ~isempty(strfind(pp1,'DerSGw'))
        % this will be calling --> apply_1stDer()
        pp1_alt=remove_keyword_between_markers(pp1,'DerSGw','','keepLHS');
        
    elseif  ~isempty(strfind(pp1,'DerSGFL'))
         % this will be calling --> apply_NstDer()
        pp1_alt=remove_keyword_between_markers(pp1,'DerSGFL','','keepLHS');  % in this step, pp1 such as '1stDerSGFL7[PO2]  (default)' will be taken care of by ignoring "(default)"
        
    else
        error('unexpected case ???')
        
    end
    
else
    pp1_alt=pp1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% added to cope with PRO style pretreatment
if strcmp(find_keyword_between_markers(pp1,'{','}'),'PRO')
isPRO=1;
else
isPRO=0;    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% if strcmp(pp1_alt,pp1) && length(pp1)>=3 && ( strcmp(pp1(1:3),'SGw') | strcmp(pp1(1:3),'SGF'))
%     pp1_alt=remove_keyword_between_markers(pp1,'SGFL','','keepLHS');
%     
% elseif strcmp(pp1_alt,pp1) && strcmp(pp1(1:3),'SGw')
%     
%     pp1_alt=remove_keyword_between_markers(pp1,'SGw','','keepLHS');
%     
% elseif strcmp(pp1_alt,pp1) && strcmp(pp1(1:2),'SG')
%     pp1_alt=remove_keyword_between_markers(pp1,'SG','','keepLHS');
%     
% end


if  strcmp(pp1_alt(1:3),'SGw') && isnumeric(str2num(pp1_alt(4:end)))
    pp1_alt=pp1_alt(1:3);
end


switch pp1_alt
    
    case {'SGw','SG'}
        % only apply smoothing by sgolayfilt(X,K,F)
        % K: polynomial order
        % F: the frame size and F must be odd
        K=3; % default
        sF=find_keyword_between_markers(pp1,'SGw','');
        if ~isempty(sF)
            F=str2num(sF);
            if isempty(F)
                F=5; % default
            end
        else
            F=5; % default
        end
        
        
        
        % -------------------------------------------------------------------
        % old and problematic approach ???
        %  rawSpectra_aftPP1=sgolayfilt(allWL_rawSpectra_orig,K,F);
        % -------------------------------------------------------------------
        %======================================================================
        % new and fixed approach
        % sgolayfilt work on data matrix that sample directions are in column-dir
        % each spectra should be one column vector (instead of row vector in our typical convention)
        % i.e.  DM(1:nvar,1:nsamp)
        rawSpectra_aftPP1a=sgolayfilt(allWL_rawSpectra_orig',K,F);% new and fixed approach
        rawSpectra_aftPP1=rawSpectra_aftPP1a';% new and fixed approach
        %======================================================================
        
        spp1=pp1;
        
    case '1stDer'
        warning('this will be running problematic Andy version')
        warning('this will be running problematic Andy version')
        warning('this will be running problematic Andy version')
        warning('this will be running problematic Andy version')
        
        inp.SG_scheme='SG1st_AH';
        inp.poly_order=3;inp.width=5;
        [rawSpectra_aftPP1 struct_spp1]=apply_1stDer(allWL_rawSpectra_orig,inp);
        spp1=pp1;
        
    case   '1stDerSGDiederick'
        inp.SG_scheme='1stDerSGDiederick';   % '1stDerSGDiederick'  by Diederick  %  'SG1st_AH' by Andy Hulse
        inp.DN=1;inp.poly_order=3;inp.width=5;
        
        [rawSpectra_aftPP1 struct_spp1]=apply_1stDer(allWL_rawSpectra_orig,inp);
        spp1=pp1;
        
    case   {'0thDerSGFL','1stDerSGw','1stDerSGFL','2ndDerSGFL','3rdDerSGFL','4thDerSGFL'} % this will be most general case that can change width and poly_order
        
        switch pp1_alt
            case '1stDerSGw'
                inp.SG_scheme='1stDerSGDiederick';   % '1stDerSGDiederick'  by Diederick  %  'SG1st_AH' by Andy Hulse
             case '0thDerSGFL'
                inp.SG_scheme= 'NstDerSGFL'   ;
            case '1stDerSGFL'
                inp.SG_scheme= 'NstDerSGFL'   ;
                
            case '2ndDerSGFL'
                inp.SG_scheme= 'NstDerSGFL'   ;
            case '3rdDerSGFL'
                inp.SG_scheme= 'NstDerSGFL'   ;
            case '4thDerSGFL'
                inp.SG_scheme= 'NstDerSGFL'   ;
        end
        
        %          inp.DN=1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            try
                PO=str2num(find_keyword_between_markers(pp1,'_PO',''));
            catch
                PO=str2num(find_keyword_between_markers(pp1,'[PO',']'));
            end
        catch
            PO=3;     % default setting to 3
        end
        
        if isnumeric(PO)
            inp.poly_order=PO;  % set to non-default
        else
            inp.poly_order=3;  % default setting to 3
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        inp.width=find_keynumber_numeric_AFTER_marker(pp1,pp1_alt);
        
        
        
        if is_odd(inp.width)
            
            if strcmp(pp1_alt,'1stDerSGw')
                inp.DN=1;
                
                [rawSpectra_aftPP1 struct_spp1]=apply_1stDer(allWL_rawSpectra_orig,inp);
            elseif ~isempty(strfind(pp1_alt,'DerSGFL'))
                switch pp1_alt
                     case '0thDerSGFL'
                        inp.DN=0;
                    case '1stDerSGFL'
                        inp.DN=1;
                    case '2ndDerSGFL'
                        inp.DN=2;
                    case '3rdDerSGFL'
                        inp.DN=3;
                    case '4thDerSGFL'
                        inp.DN=4;
                    otherwise
                        error('DN not supported')
                end
                [rawSpectra_aftPP1 struct_spp1]=apply_NstDer(allWL_rawSpectra_orig,inp);
                
                % added to cope with PRO style pretreatment
               if isPRO
                   
                  % NcolZeachSide=(125-length(rawSpectra_aftPP1(1,:)))/2;
                   
                   Nwvl_orig=length(allWL_rawSpectra_orig(1,:));                                  % fixed this to deal with non-MicroNIR grids, Nov 24, 2020
                   NcolZeachSide=(Nwvl_orig-length(rawSpectra_aftPP1(1,:)))/2;           % fixed this to deal with non-MicroNIR grids, Nov 24, 2020
                   
                  padZ= zeros(length(rawSpectra_aftPP1(:,1)), NcolZeachSide) ;
                   rawSpectra_aftPP1=[padZ ,rawSpectra_aftPP1,padZ];
               end
               %%%%%%%%%%%%%%%%%%%%%
               
            else
                error('did not expect this to happen ???')
            end
            
            
            spp1=pp1;
        else
            error('width for SG filter must be odd number')
        end
        
        
        
    case '2ndDer'
        
        [rawSpectra_aftPP1 struct_spp1]=apply_2ndDer(allWL_rawSpectra_orig);
        spp1=pp1;
        
        
    case {'SNV','SNV{PRO}'}   % updated to deal with correct way of running {PRO} with SNV, Nov 30, 2020
        
        if isPRO
            % updated to deal with correct way of running {PRO} with SNV, Dec 8, 2020
             rawSpectra_aftPP1=allWL_rawSpectra_orig;  %  rawSpectra_aftPP1 later will be filled with SNV results
            [rawSpectra_aftPP1_woZeros struct_spp1]=apply_SNV(allWL_rawSpectra_orig(:, ~find_all_zeros_col_idx(allWL_rawSpectra_orig)));
            rawSpectra_aftPP1(:, ~find_all_zeros_col_idx(allWL_rawSpectra_orig))=rawSpectra_aftPP1_woZeros;  %  rawSpectra_aftPP1 now filled with SNV results
            spp1=pp1;
            
        else
            [rawSpectra_aftPP1 struct_spp1]=apply_SNV(allWL_rawSpectra_orig);
            spp1=pp1;
        end
      
        
        
    case {'SampMncn','SMC'}
        rawSpectra_aftPP1=mncn(allWL_rawSpectra_orig')';
        spp1=pp1;
    case 'MSC'
        disp('work on MSC')
        if isempty(inp)
            % for Tset, do not provide "inp" but need to output "out_MSC"
            xref=mean(allWL_rawSpectra_orig);
            out.xref_MSC=xref;
        else
            % for Pset, need to provide "inp" but do Not need to output "out_MSC"
            xref=inp.xref_MSC;
        end
        [ rawSpectra_aftPP1,alpha,beta] = mscorr(allWL_rawSpectra_orig,xref);
        
        try
            if show_MSC_TP_yes
                set(groot,'defaultLineLineWidth',0.5);
                if isempty(inp)
                    figure;hold  on;plot(allWL_rawSpectra_orig','b-O');ylabel('Tset before MSC');
                    figure;hold  on;plot(rawSpectra_aftPP1','r-O'); ;ylabel('Tset after MSC');
                    figure;hold  on;plot(allWL_rawSpectra_orig','b-O');   plot(rawSpectra_aftPP1','r-O'); ylabel('Tset before & after MSC ');
                else
                    figure;hold  on;plot(allWL_rawSpectra_orig','c-*');ylabel('Pset before MSC');
                    figure;hold  on;plot(rawSpectra_aftPP1','m-*'); ;ylabel('Pset after MSC');
                    figure;hold  on;plot(allWL_rawSpectra_orig','c-*');plot(rawSpectra_aftPP1','m-*'); ylabel('Pset before & after MSC');
                end
                 set(groot,'defaultLineLineWidth',2);
            end
        end %end of try show_MSC_TP_yes
        
        spp1=pp1;
        
    case 'none'
        rawSpectra_aftPP1=allWL_rawSpectra_orig;
        spp1=pp1;
        
    otherwise
        error([pp1,' not supported !!!'])
        
end

if ~exist('out','var')
    out='';
end

%==========================================================
% % run with stand alone apply_SNV that vectorized, Nov 7, 2022
% function [rawSpectra_SNV_out ppn]=apply_SNV(rawSpectra_SNV_in)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % apply 'SNV' preprocess scheme
% ppn.type='SNV';
% ppn.poly_order=[];
% ppn.width=[];
% rawSpectra_SNV_out=[];
% for irow=1:length(rawSpectra_SNV_in(:,1))
%     ea_rawSpectra_SNV = loc_preprocess(rawSpectra_SNV_in(irow,:),ppn);
%     rawSpectra_SNV_out=[rawSpectra_SNV_out;ea_rawSpectra_SNV];
% end







disp('finish preprocess_NIR_spectra()')
end


%% ----- pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP   [AQP_gui.m lines 29846-30283] --------------
function out=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%----------------------------------------------------------
% % this one is used by AQP etc
% main engine function is --> preprocess_NIR_spectra
% function pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP()
% also handle SG with variable window width and poly_order
% see also preprocess_NIR_spectra()    RS2AT()
% also handle PLS dataset (those with saConc)
% can handle AT file with both Atrainpk and Apred 
% (or RawSpectra.Tset and RawSpectra.Pset)
% only handle pp1 and pp2, NOT pp3 !!!
% modified from  pretreat_RawSpectra_pp1_pp2_pp3
%
% last updated by Chang Hsiung, Oct 16, 2015
% fix some renaming of filename issues
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% updated by CH, Dec 4, 2019
% for testing Xfer-PP data flow in AQP make sure do the "AT2RS" (see test_AT2RS) before running this function
% %very important to move Atrainpk to RawSpectra before running PP
% updated by CH, Dec 4, 2019
% see --> AQPlite output transferred spectra in xlsx.pptx
% to deal with MSC, updated Sept 22, 2020
%================================================
%--------------------------------------------------------------------------------------------------
% update following Nov 9, 2022
% for directlly apply PP without calling ssds etc ( on RawSpectra )
% see --> apply_PP_on_RawSpectra
% see also: test_ssds_method_apply_PP
%-----------------------------------------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if false

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp.Chemo_Method='PLS'% this is NOT used anymore !!!
inp.PP_methods.pp1='1stDerSGw17' ;  % '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'

inp.PP_methods.pp2='SNV';   %   'none' '1stDer'   '2ndDer'  'SNV'

%pathfname_AT= 'C:\work\JDSU\TestStation\PharmaLib\ATetc\AK\TP\Atrainpketc_Absorbance_AK_PharmaLib(S1-PAT00)Lib1_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsampT95_nsampP95_ncls19_(T-1AK_P-2AK)_TP.mat'
% pathfname_AT= 'C:\work\JDSU\TestStation\PharmaLib\ATetc\AK\TP\Atrainpketc_Absorbance_AK_PharmaLib(S1-PAT00)Lib1_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsampT95_nsampP95_ncls19_(T-2AK_P-3AK)_TP.mat'
% pathfname_AT='C:\work\JDSU\AppliedSpectroscopy_paper\data\Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19_wRawSpectra_pp1-1stDer_pp2-SNV.mat'
% pathfname_AT='C:\work\JDSU\AppliedSpectroscopy_paper\data\Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19_wRawSpectra__pp1-1stDerSGDiederick_pp2-SNV.mat'

% pathfname_AT='C:\work\JDSU\TESTST~1\ENERGY~1\XP1788~1\Atrainpketc_saConc_nAna1_Brix_AppnStation-EnergyDrink-V_Sept28_ALL_Brands_c_f_woSKEnergyBerry_f_Parse-cf-f_{T-S1-PAT002AK__P-S1-PAT003AK}_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsampT170_ncls17_nsampP179.mat'
 pathfname_AT='C:\work\JDSU\TESTST~1\ENERGY~1\XP1788~1\Atrainpketc_saConc_nAna1_Brix_AppnStation-EnergyDrink-V_Sept28_ALL_Brands_c_f_woSKEnergyBerry_f_Parse-cf-f_{T-S1-PAT003AK__P-S1-PAT002AK}_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsampT179_ncls18_nsampP170.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp.PP_methods.pp1='1stDerSGw17' ;  % '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   %   'none' '1stDer'   '2ndDer'  'SNV'
 pathfname_AT='C:\work\JDSU\TestStation\OTC\XP_w2AT_AK4\Atrainpketc__Absorbance_AppnStation-OTC-data_{T-S1-PAT004AK_RUN-r1__P-S1-PAT004AK_RUN-0}_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsampT327_ncls11_nsampP327.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp.PP_methods.pp1='1stDerSGw5' ;  % '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   %   'none' '1stDer'   '2ndDer'  'SNV'
%  pathfname_AT='C:\work\JDSU\WL_shift\fixWL\OTC_AT_etc_1000\Atrainpketc__Absorbance_AppnStation-OTC-1000_(S1-PAT001AK)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp330_ncls11.mat'
% pathfname_AT='C:\work\JDSU\WL_shift\fixWL\OTC_AT_etc_1000\Atrainpketc__Absorbance_AppnStation-OTC-1000_(S1-PAT002AK)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp327_ncls11.mat'
% pathfname_AT='C:\work\JDSU\WL_shift\fixWL\OTC_AT_etc_1000\Atrainpketc__Absorbance_AppnStation-OTC-1000_(S1-PAT003AK)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp330_ncls11.mat'

% pathfname_AT='C:\work\JDSU\WL_shift\VfixWL_crossDetector\Atrainpketc__Absorbance_AppnStation-OTC-data_(S1-PAT005AK_RUN-0)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp331_ncls11.mat'
%  pathfname_AT='C:\work\JDSU\WL_shift\VfixWL_crossDetector\Atrainpketc__Absorbance_AppnStation-OTC-data_(S1-SI0001AK_RUN-0)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp330_ncls11.mat'
%    pathfname_AT='C:\work\JDSU\WL_shift\ATetc_XD\after_WLfix\Atrainpketc__Absorbance_AppnStation-OTC-data_(S1-PAT005AK_RUN-0)__nvar121_nsamp331_ncls11_pp1-1stDerSGw5_pp2-SNV_FlipByLog10.mat'
  pathfname_AT='C:\work\JDSU\WL_shift\ATetc_XD\Atrainpketc__Absorbance_AppnStation-OTC-data_(S1-PAT005AK_RUN-0)__nvar121_nsamp331_ncls11_pp1-1stDerSGw5_pp2-SNV_divideby100_then_neglog10.mat'
   pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp.PP_methods.pp1='1stDerSGw5' ;  % '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   %   'none' '1stDer'   '2ndDer'  'SNV'
% pathfname_AT='C:\work\JDSU\WL_shift\fixWL\sub-c\Atrainpketc_saConc_nAna1_Brix_AppnStation-EnergyDrink-V_Sept28_ALL_Brands_c_f_woSKEnergyBerry_f_Parse-cf-c_(S1-PAT002AK)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp140_ncls14.mat'
% pathfname_AT='C:\work\JDSU\WL_shift\fixWL\sub-c\Atrainpketc_saConc_nAna1_Brix_AppnStation-EnergyDrink-V_Sept28_ALL_Brands_c_f_woSKEnergyBerry_f_Parse-cf-c_(S1-PAT003AK)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp140_ncls14.mat'
% pathfname_AT='C:\work\JDSU\WL_shift\fixWL\sub-f\Atrainpketc_saConc_nAna1_Brix_AppnStation-EnergyDrink-V_Sept28_ALL_Brands_c_f_woSKEnergyBerry_f_Parse-cf-f_(S1-PAT002AK)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp170_ncls17.mat'
  pathfname_AT='C:\work\JDSU\WL_shift\fixWL\sub-f\Atrainpketc_saConc_nAna1_Brix_AppnStation-EnergyDrink-V_Sept28_ALL_Brands_c_f_woSKEnergyBerry_f_Parse-cf-f_(S1-PAT003AK)_pp1-1stDerSGDiederick_pp2-SNV_nvar124_nsamp179_ncls18.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
%  inp.Chemo_Method='PLS' % this is NOT used anymore !!!

inp.PP_methods.pp1='SG' ;  %   'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SampMncn';   % 'SampMncn'  'none' '1stDer'   '2ndDer'  'SNV'

pathfname_AT='C:\work\JDSU\PDS_Cheese\test_intr_extr_CV\ATsaConc\Atrainpketc__saConc_nAna1_Fat_CollectDirectMicroNIR_ncls11_nsamp54_nvar121_rm-6-outliers.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inp.PP_methods.pp1='1stDerSGw5' ;  %   'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   % 'SampMncn'  'none' '1stDer'   '2ndDer'  'SNV'

%pathfname_AT='C:\work\JDSU\DI_OSP\counter-false-alarms\Implement_CFP_DM\ATnew\Atrainpketc_YellowCls_nsamp21.mat'
% pathfname_AT='C:\work\JDSU\DI_OSP\counter-false-alarms\Implement_CFP_DM\AT_Kolon\Atrainpketc_wRawSpectra_T-odd_P-even_Kolon Library_pp1-1stDerSGDiederick_pp2-SNV_ncls254_nsampT2645__nsampP2568.mat'
% pathfname_AT='C:\work\JDSU\Implement_ILM+CFP\ATetc\DMflour\Atrainpketc_DM5powders_ncls5_nsamp110.mat'
pathfname_AT='C:\work\JDSU\Implement_ILM+CFP\ATetc\DMflour\Atrainpketc_DM5powders_ncls5_nsampT110_P-salt_nsampP1.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inp.PP_methods.pp1= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   % 'SampMncn'  'none' '1stDer'   '2ndDer'  'SNV'

% pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\S1-550\Siesler48\Atrainpketc_saConc_Siesler48_T-S1-00550__P-S1-00552_pp1-1stDer_pp2-SampMncn_nvar121_nsampT959_ncls48_nsampP960.mat'
% pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\S1-550\RMID\Atrainpketc_RMID_T-S1-00550__P-S1-00552_pp1-1stDerSGDiederick_pp2-SNV_nvar121_nsampT599_ncls19__nsampP600.mat'
pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\ATsaConc_ES17_S1_AK_E1_etc\S1\1stDer\Atrainpketc_saConc__Absorbance_S1-00375xls_PharmaLib(S1-00375)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar121_nsamp960_ncls48.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inp.PP_methods.pp1= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   % 'SampMncn'  'none' '1stDer'   '2ndDer'  'SNV'
%problematic --> pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\ES17_S1\Atrainpketc_saConc__Siesler48_(S1-00419)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar121_nsamp961_ncls48.mat'
% pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\ES17_S1\Atrainpketc_saConc__Siesler48_(S1-00553)_pp1-1stDerSGDiederick_pp2-SampMncn_nvar121_nsamp959_ncls48.mat'
% pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\ES17_S1\T-SCSVM_P-Kolon\Atrainpketc_wRawSpectra_T-odd_P-even_Kolon Library_pp1-1stDerSGDiederick_pp2-SNV_ncls240_nsampT2644__nsampP2569_TP.mat'
% pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\ES17_S1\AT_wNLcor\Atrainpketc_saConc__Siesler48_(S1-00550)__nvar119_nsamp959_ncls48_clsP-zeors_wNLcor.mat'
% pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\ES17_S1\AT_wNLcor\Atrainpketc_saConc__Siesler48_(S1-00552)__nvar119_nsamp960_ncls48_clsP-zeors_wNLcor.mat'
pathfname_AT='C:\work\JDSU\SC-SVM_OLs\AT_Siesler48\ES17_S1\AT_wNLcor\4PLS\wNL_PP-none\Atrainpketc_saConc__Siesler48_(S1-00552)__nvar119_nsamp960_ncls48_wNLcor.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test output AQP to xlsx file for PRO
inp.PP_methods.pp1= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   %
pathfname_AT='C:\work\JDSU\Test_AQP\Test_Output4PRO\Atrainpketc_{T-MDC-CS-woPPd_P-Val}_nvar125_ncls44_nsampT102_nsampP99.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test output AQP to xlsx file for PRO
inp.PP_methods.pp1= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   %
% pathfname_AT='C:\work\JDSU\Test_AQP\Test_Output4PRO\from_AQP\Atrainpketc_(T-woMDC-woPPd_P-Val)_nvar125_nsampT102_nsampP99_TP.mat'
pathfname_AT='C:\work\JDSU\Test_AQP\from_AQP_aft5pm\aft_AQP_complete_directlyInside_TMP_AQP\Atrainpketc_{T-MDC-CS-woPPd_P-Val}_nvar125_ncls44_nsampT102_nsampP99.mat'
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updated by CH, Dec 4, 2019
% for testing Xfer-PP data flow in AQP make sure do the "AT2RS" (see test_AT2RS) before running this function
% %very important to move Atrainpk to RawSpectra before running PP
% updated by CH, Dec 4, 2019
% test output AQP to xlsx file for PRO with AT2RS !!!
pathfname_AT='C:\work\JDSU\Test_AQP\from_AQP_aft5pm\aft_AQP_complete_directlyInside_TMP_AQP\Atrainpketc_{T-MDC-CS-woPPd_P-Val}_nvar125_ncls44_nsampT102_nsampP99.mat'
%very important to move Atrainpk to RawSpectra before running PP
L_X=load(pathfname_AT);
L_X_AT2RS=L_X;
L_X_AT2RS.RawSpectra.Tset=L_X.Atrainpk;
L_X_AT2RS.RawSpectra.Pset=L_X.Apred;
pathfname_AT_new=strrep(pathfname_AT,'.mat','_AT2RS.mat');
save(pathfname_AT_new,'-struct','L_X_AT2RS');

inp.PP_methods.pp1= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   %


pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT_new,inp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% after fixing AT2RS in AQP
cc
% pathfname_AT='C:\work\JDSU\Test_AQP\Test_Output4PRO\after_fixing_AT2RS\Atrainpketc_saConc_TPwTrn_TestCabXfer_{MDC_KSall_pp1-}_[T-CS_P-XRS}_Val]_nsampT102_nsampP99_nsampXS10_AT2RS.mat'
pathfname_AT='C:\work\JDSU\Test_AQP\Test_Output4PRO\after_fixing_AT2RS\Atrainpketc_{MDC_pp1-}_nsampT102_nsampP99_nsampXS10_wAT2RS_For_PRO_testing.mat'
inp.PP_methods.pp1= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp2='SNV';   %
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test for AQPlite power user with Siesler48 dataset

cc
pathfname_AT='C:\work\JDSU\Test_AQP\Siesler_Data\ATsaConc2XLS\T375_P376\Atrainpketc_saConc_{Siesler48_T-S1-00375__P-S1-00376}_pp-1stDer_pp2-SampMncn_nvar121_nsampT960_ncls48_nsampP960.mat'
 inp.PP_methods.pp1= '1stDer';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
% inp.PP_methods.pp1= '1stDerSGFL5[PO3]';
inp.PP_methods.pp2='SampMncn';   %
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test for U2U based on ResinKits (add OnSite-W unit)

cc
 pathfname_AT='C:\work\JDSU\Test_ACP_U2U\ATetc_U2U\Start_AT\ES\Atrainpketc_{T-ES-552-rk1552}_pp1-1stDerSGDiederick_pp2-SNV_nvar121_ncls46_nsampT1401.mat'
%     pathfname_AT='C:\work\JDSU\Test_ACP_U2U\ATetc_U2U\Start_AT\ES\Atrainpketc_{T-ES-553-rk1553}_pp1-1stDerSGDiederick_pp2-SNV_nvar121_ncls46_nsampT1410.mat'
%   inp.PP_methods.pp1='1stDerSGDiederick' ;  %    '1stDerSGDiederick'       '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
  inp.PP_methods.pp1='1stDerSGw5';  %     '1stDerSGw5' -->  inp.poly_order=3;  % default setting to 3            '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'

 inp.PP_methods.pp2='SNV';   %
pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Manyne2020 effect of SNV as PP1 vs PP2

cc
 pathfname_AT='C:\work\JDSU\Test_ACP\Mayne2020\IFPAC\AT_etc\fix_Inliers\xU-1_ncls67\Atrainpketc_{T-N1-00136_RmCls-222304_P-S1-00589_RmCls-222304}_nvar119_nsampT1063_nsampP1070_ncls67.mat'
 
%     inp.PP_methods.pp1= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
% inp.PP_methods.pp2='SNV'; 
   
inp.PP_methods.pp2= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
inp.PP_methods.pp1='SNV'; 


pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BU biogen

cc
 pathfname_AT='C:\work\JDSU\Test_ACP\Mayne2020\IFPAC\AT_etc\fix_Inliers\xU-1_ncls67\Atrainpketc_{T-N1-00136_RmCls-222304_P-S1-00589_RmCls-222304}_nvar119_nsampT1063_nsampP1070_ncls67.mat'
inp.PP_methods.pp1='SNV'; 
inp.PP_methods.pp2= '1stDerSGFL7[PO2]';  %  '1stDerSGw7[PO2]' same as '1stDerSGFL7[PO2]'     'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'


pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(pathfname_AT,inp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end  % end of examples (if false)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isa(pathfname_AT,'struct')
 LAT=pathfname_AT;   
 try
 pathfname_AT=inp.pathfname_AT;
 catch
 pathfname_AT='';    
 end
else
LAT=load(pathfname_AT);
end

% checking if "RawSpectra" exist ?
if isfield(LAT,'RawSpectra') && ~isempty(LAT.RawSpectra)
    if isa(LAT.RawSpectra,'struct') && isfield(LAT.RawSpectra,'Tset')
        allWL_rawSpectra_orig=LAT.RawSpectra.Tset;
    else
        allWL_rawSpectra_orig=LAT.RawSpectra;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % create a new function --> apply_PP_on_RawSpectra , Nov 9, 2022
    if false
        pp1=inp.PP_methods.pp1;
        % for Tset, do not provide "inp" but need to output "out_MSC"
        [rawSpectra_aftPP1 spp1 out_MSC_PP1]=preprocess_NIR_spectra(allWL_rawSpectra_orig,pp1);     % to deal with MSC, updated Sept 22, 2020
        spp1=inp.PP_methods.pp1;

        pp2=inp.PP_methods.pp2;
        % for Tset, do not provide "inp" but need to output "out_MSC"
        [rawSpectra_aftPP2 spp2 out_MSC_PP2]=preprocess_NIR_spectra(rawSpectra_aftPP1,pp2);           % to deal with MSC, updated Sept 22, 2020
        spp2=inp.PP_methods.pp2;

        rawSpectra_aftPP=rawSpectra_aftPP2;
    else   % create a new function --> apply_PP_on_RawSpectra , Nov 9, 2022
        [rawSpectra_aftPP   out_alt]=apply_PP_on_RawSpectra(allWL_rawSpectra_orig,inp);
        rawSpectra_aftPP1=out_alt.rawSpectra_aftPP1;
        pp1=inp.PP_methods.pp1;
        pp2=inp.PP_methods.pp2;
        spp1=inp.PP_methods.pp1;
        spp2=inp.PP_methods.pp2;

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if isa(LAT.RawSpectra,'struct')&& isfield(LAT.RawSpectra,'Pset')
        allWL_rawSpectra_orig_Pset=LAT.RawSpectra.Pset;
        if all(isnan(allWL_rawSpectra_orig_Pset(:)))
            disp('Pset''s RawSpectra are all NaN, hence will NOT apply PP, instead just use Apred')
          rawSpectra_aftPP_Pset=LAT.Apred;  
        else
            inp4NIR_PP1.Tset=allWL_rawSpectra_orig;                                                                                                      % to deal with MSC, updated Sept 22, 2020
           try
            inp4NIR_PP1.xref_MSC= out_MSC_PP1.xref_MSC;
           catch
             inp4NIR_PP1.xref_MSC='';  
           end
           % for Pset, need to provide "inp" but do Not need to output "out_MSC"
        [rawSpectra_aftPP1_Pset spp1]=preprocess_NIR_spectra(allWL_rawSpectra_orig_Pset,pp1,inp4NIR_PP1);         % to deal with MSC, updated Sept 22, 2020
        
            inp4NIR_PP2.Tset=rawSpectra_aftPP1;                                                                                                            % to deal with MSC, updated Sept 22, 2020
            try
            inp4NIR_PP2.xref_MSC= out_MSC_PP2.xref_MSC;   
            catch
             inp4NIR_PP2.xref_MSC='';    
            end
          % for Pset, need to provide "inp" but do Not need to output "out_MSC"
        [rawSpectra_aftPP2_Pset spp2]=preprocess_NIR_spectra(rawSpectra_aftPP1_Pset,pp2,inp4NIR_PP2);               % to deal with MSC, updated Sept 22, 2020
        rawSpectra_aftPP_Pset=rawSpectra_aftPP2_Pset;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % only handle pp1 and pp2, NOT pp3 !!!
    spp3='';
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(spp3)
        fname4pretreatment=['_pp1-',spp1,'_pp2-',spp2,'_pp3-',spp3];
    else
        fname4pretreatment=['_pp1-',spp1,'_pp2-',spp2];
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % checking
    if isSAME_2Matrix(rawSpectra_aftPP,LAT.Atrainpk)
        if  isempty(strfind(fileparts_name_wo_ext(pathfname_AT),'_pp1-'))&& isempty(strfind(fileparts_name_wo_ext(pathfname_AT),'_pp2-'))
            fname_new=strrep(fileparts_name_ext(pathfname_AT),'.mat',[fname4pretreatment,'.mat']);
        else
         fname_new=fileparts_name_ext(pathfname_AT);
        end
        SAT=LAT;
       
    else
        disp_with_border('Atrainpk different from RawSpectra after applying current pretreatments');
        
        
        if  ~isempty(strfind(fileparts_name_ext(pathfname_AT),'{')) && ~isempty(strfind(fileparts_name_ext(pathfname_AT),'}')) && ~isempty( find_keyword_between_markers(fileparts_name_ext(pathfname_AT),'_pp1-','}') ) 
            % handle the not so common case that spp1 within a curly bracket !!!
            % 
            cur_spp1=find_keyword_between_markers(fileparts_name_ext(pathfname_AT),'_pp1-','}');
            new_spp1=find_keyword_between_markers(fname4pretreatment,'_pp1-','_');
             fname_new=strrep(fileparts_name_ext(pathfname_AT),['_pp1-',cur_spp1],['_pp1-',new_spp1]);
            
        else
            
            if  isempty(strfind(fileparts_name_wo_ext(pathfname_AT),'_pp1-'))&& isempty(strfind(fileparts_name_wo_ext(pathfname_AT),'_pp2-'))
                fname_new=strrep(fileparts_name_ext(pathfname_AT),'.mat',[fname4pretreatment,'.mat']);
            else
                fname_new=remove_keyword_between_markers(fileparts_name_ext(pathfname_AT),'pp1-','_');
                %fname_new=remove_keyword_between_markers_wlistRHS(fname_new,'pp2-',{'_','.mat'});
                fname_new=remove_keyword_between_markers_wlistRHS(fname_new,'pp2-',{'_','.mat'},'keepRHS');
                
                fname_new=strrep(fname_new,'__',[fname4pretreatment,'_']);
                
                
            end
        end
        
        
        
        SAT=LAT;
        SAT.Atrainpk=rawSpectra_aftPP;
        try
            SAT.Apred=rawSpectra_aftPP_Pset;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
else
    error('RawSpetra Not available')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handle the case of PLS, insert rawSpectra_aftPP into saConc
% try
% if (isfield(inp,'Chemo_Method') && strcmp(inp.Chemo_Method,'PLS')) 
% if strcmp(inp.Chemo_Method,'PLS')
    
    if isfield(SAT,'PLS') && length(SAT.Atrainpk(:,1))==length(SAT.PLS.Tset.saConc)
         disp(' this case with SAT.PLS.Tset.saConc or SAT.PLS.Pset.saConc and NOT SAT.saConc will be handled below')
        for isaConc=1:length(SAT.PLS.Tset.saConc)
            SAT.PLS.Tset.saConc(isaConc).Atrainpk=SAT.Atrainpk(isaConc,:);
        end
        %checking
        AT_sa=cell2mat(arrayfun(@(x) x.Atrainpk,SAT.PLS.Tset.saConc,'un',0));
        if ~isSAME_2Matrix(AT_sa,SAT.Atrainpk)
            error('mismatch between AT_sa vs SAT.Atrainpk')
        end
        
        
        for isaConcP=1:length(SAT.PLS.Pset.saConc)
            SAT.PLS.Pset.saConc(isaConcP).Atrainpk=SAT.Apred(isaConcP,:);
        end
        
        %checking
        AT_saP=cell2mat(arrayfun(@(x) x.Atrainpk,SAT.PLS.Pset.saConc,'un',0));
        if ~isSAME_2Matrix(AT_saP,SAT.Apred)
            error('mismatch between AT_saP vs SAT.Apred')
        end
        
        
        
        
        
    elseif isfield(SAT,'saConc')
        disp(' this case with SAT.saConc and NOT SAT.PLS.Tset.saConc or SAT.PLS.Pset.saConc  will be handled below')
       % disp('this case with SAT.saConc will be handled here')
    if isfield(SAT,'saConc')
        for isaConc=1:length(SAT.saConc)
            SAT.saConc(isaConc).Atrainpk=SAT.Atrainpk(isaConc,:);
        end
        %checking
        AT_sa=cell2mat(arrayfun(@(x) x.Atrainpk,SAT.saConc,'un',0));
        if ~isSAME_2Matrix(AT_sa,SAT.Atrainpk)
            error('mismatch between AT_sa vs SAT.Atrainpk')
        end
        
    end
        
        
    elseif isfield(SAT,'PLS')
%         warning('no appropriate field for PLS inside SAT or more than one entry of Atrainpk in each element of saConc');
                warning('can not handle the case that regression dataset with PLS inside SAT or more than one entry of Atrainpk in each element of saConc'); % updated July 1, 2022

    else
        disp('this seems to be a Classification application'); % updated July 1, 2022
    end
    
    
% end
%%%%%%%%%%%%%%%%%%%%
if false
    % catch
    disp('this case with SAT.saConc will be handled here')
    if isfield(SAT,'saConc')
        for isaConc=1:length(SAT.saConc)
            SAT.saConc(isaConc).Atrainpk=SAT.Atrainpk(isaConc,:);
        end
        %checking
        AT_sa=cell2mat(arrayfun(@(x) x.Atrainpk,SAT.saConc,'un',0));
        if ~isSAME_2Matrix(AT_sa,SAT.Atrainpk)
            error('mismatch between AT_sa vs SAT.Atrainpk')
        end
        
    end
    
    % end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fname_new=strrep(fname_new,'(S1-PAT00)',['{',pp1,'}']);
%fname_new=strrep(fname_new,'(S1-00)',['{',pp1,'}']);
% fname_new=strrep(fname_new,'.mat',['_{',pp1,'}','.mat']);
nvar_new=length(SAT.Atrainpk(1,:));
fname_new=strrep_keyword_between_markers_wlistRHS(fname_new,'_nvar',{'_','.mat'},num2str(nvar_new),'keepBoth');

if isempty(strfind(fname_new,'nvar'))
    fname_new=strrep(fname_new,'.mat',['_nvar',num2str(nvar_new),'.mat']);
end


save(fname_new,'-struct','SAT');
disp([fname_new,' has been saved'])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updated Aug 28, 2020
if exist([find_last_nonTMP_path,'\TMP_AQP'],'dir')
copyfile(fname_new,[find_last_nonTMP_path,'\TMP_AQP']);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out.fname_new=fname_new;

disp('finish pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP()')
end


%% ----- regexp_extract_mk1_mk2   [AQP_gui.m lines 30288-30516] ------------------------------------
function out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
% renamed from regexp_extract_mk1_mk2_alt2 (June 10, 2025)
% extract an alphanumeric or special characters string between two marker strings; mk1 and mk2
% only extract one string
% can deal with mk2 is a cell, for this case Only extract numerical digits (Note: code actually extracts any chars based on (.*?))
% also deal with "empty end" case (see --> example #8c) , for this case Only extract numerical digits (Note: code actually extracts any chars based on (.*?))
% MODIFIED: Handles mk2='' ( ischar Not cell ) to extract from mk1 to end of targetstring, see --> example # 10
% MODIFIED: Handles mk1='' (ischar Not cell ) to extract from beginning of targetstring to mk2 , see --> example # 11
% see --> example # 12 : deal with  extraction of string between begin of targetstring to mk2 by setting mk1='' and mk2 is a cell !!! in this case program should return the shortest extraction
%-----------------------------------------------------
% by Gemini
% expression = [marker1 '(.*?)' marker2];
% Note that to leave a blank space between marker1 and '(.*?)' also between '(.*?)'  and marker2
% (This comment might be about general regex construction; the code concatenates directly)
% .: Matches any character (except newline).
% *: Matches the preceding character zero or more times.
% ?: Makes the * quantifier "lazy" (non-greedy). This is important to ensure it matches the shortest possible string between marker1 and marker2. Without ?, it would match all the way to the last marker2 in the string.
%  do NOT use '(.+?)'  this will cause code to crash when nothing to be extracted (e.g. in example #5 ) !!!
%---------------------------------------------------------
% Final fix by Google AI Studio wrt examples 9 - 11
%----------------------------------------------------------
% see also: regexp_PP_scheme_SGFL
%=========================================================
if false
        %---------------------------------------------------------------------
    % example #1
    cc
    targetstring='SMV[pwCos]' ;  mk1='[' ;  mk2=']' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %---------------------------------------------------------------------
    % example #2
    cc
    targetstring='SMV[Corr]' ;  mk1='[' ;  mk2=']' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #3
    cc
    targetstring='Atrainpketc_(5){ApdCls-N6_S3_T-103_P-600}_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='Atrainpketc_' ;  mk2='_nvar' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #4

    cc
    targetstring='Atrainpketc_(5){ApdCls-N6_S3_T-103_P-600}_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='ncls' ;  mk2='_' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)

 %---------------------------------------------------------------------

    % example #5
    % when there is nothing in between
    cc
    targetstring='Atrainpketc_(){ApdCls-N6_S3_T-103_P-600}_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2=')' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #6
    % when there are more than one matched patterns only extract the first one
    %
    cc
    targetstring='Atrainpketc_(abc){ApdCls-N6_S3_T-103_P-600}_(345)_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2=')' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #7
    % when there are more than one matched patterns only extract the first one
    %
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2=')' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %---------------------------------------------------------------------

    % example #7a
    % when there are more than one matched patterns only extract the first one
    %
    cc
    targetstring='Atrainpketc_(345abc){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2={ ')' };
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %------------------------------------------------------------------------------------------------------------------------------------------
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % example #8a
    % when there are more than one ending matched patterns i.e. mk2 is a cell
    %  % Captures one or more digits (like '123')
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT355.mat' ;  
    mk1='nsampT' ;  mk2={'_','.mat' };
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %+++++++++++++++++++++++++++++++++++++
    % example #8b  % Captures one or more digits (like '123')
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT3556_others.mat' ;  
    mk1='nsampT' ;  mk2={'_','.mat' };
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %+++++++++++++++++++++++++++++++++++++
    % example #8c    % Captures one or more digits (like '123')
    % deal with "empty end" case
    % when none of cmk2 can be found it will extract to the very end of  targetstring
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT1234567890' ;  % deal with "empty end" case
    mk1='nsampT' ;  mk2={'_','.mat'};
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
 %+++++++++++++++++++++++++++++++++++++
    % example #9a : deal with extracted string is alphanumeric + special characters
    %
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234567890.mat' ;  % deal with "empty end" case
    mk1='_T-' ;  mk2={'_','.mat'};
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    % hope the program to return '103-4a' 

 %+++++++++++++++++++++++++++++++++++++
    % example #9b : deal with extracted string is alphanumeric + special characters
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600-v3.mat' ;  
    mk1='_P-' ;  mk2={'_','.mat'};
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
% hope the program to return '600-v3' 
 %+++++++++++++++++++++++++++++++++++++
    % example #9c : deal with extracted string is alphanumeric + special characters
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-A12-v3' ;  
    mk1='_P-' ;  mk2={'_','.mat'};
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
% hope the program to return 'A12-v3' 
 %+++++++++++++++++++++++++++++++++++++
    % example #9d  : deal with extracted string is alphanumeric + special characters
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234567890.mat' ;  % deal with "empty end" case
    mk1='Atrainpketc_';  mk2={'_','.mat'};
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    
    % hope the program to return '(345){ApdCls-N6' 
   %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % ... (examples 1-9d remain the same) ...

    % example # 10   
    % deal with  extraction of string between mk1 to end of targetstring by setting mk2='' 
    % hope the program to return 'nvar119_ncls8_nsampT1234'
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234' ;  % deal with  mk1 to end of string by setting mk2='' ;
    mk1='(abc)_';  mk2='' ;
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2) % This should now work with the modification
   %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % example # 11   
    % deal with  extraction of string between begin of targetstring to mk2 by setting mk1='' 
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234' ;  
    mk1='';  mk2='_(abc)'; % MODIFIED mk1 to be '' as per feature description
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2) % This should now work with the modification
    % hope the program to return 'Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}'

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % example # 12  
    % deal with  extraction of string between begin of targetstring to mk2 by setting mk1='' 
    % and mk2 is a cell !!! in this case program should return the shortest extraction
    %
    cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234' ;  
    mk1='';  mk2={'_(abc)','_(345)'}; % MODIFIED mk1 to be '' as per feature description
    out=regexp_extract_mk1_mk2(targetstring,mk1,mk2) % This should now work with the modification
    % hope the program to return 'Atrainpketc'

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end   % end of examples

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Determine the pattern for the start marker (mk1)
if isempty(mk1)
    processed_mk1_pattern = '^'; % Anchor to the beginning of the string if mk1 is empty
else
    processed_mk1_pattern = regexptranslate("escape", mk1);
end

if ischar(mk2) | isempty(mk2)
    % str_tag1 was here, now using processed_mk1_pattern
    if isempty(mk2)
        % If mk2 is an empty string, extract from mk1 (or beginning) to the end of targetstring.
        % Use (.*) for greedy matching to the end.
        expression = [processed_mk1_pattern '(.*)'];
    else
        % Original behavior for non-empty mk2.
        str_tag2 = regexptranslate("escape", mk2);
        expression = [processed_mk1_pattern '(.*?)' str_tag2];
    end
    cout = regexp(targetstring, expression, 'tokens', 'once');
    % Original assignment: will error if cout is empty (no match for pattern).
    % This is kept for "minimal change" if that implies preserving original error modes.
    % If cout is {''}, out becomes '', which is correct for cases like ex #5.
    if isempty(cout)
        out='';
    else
        out = cout{1};
    end
elseif iscell(mk2)
    % cmarker2=mk2; % This variable is not used in the Google AI Studio fix part.
    % Final fix by Google AI Studio wrt examples 9a - 9d
    % Uses processed_mk1_pattern instead of direct regexptranslate('escape', mk1)
    extracted_content = regexp(targetstring, ...
                               [processed_mk1_pattern ...    % Escaped start marker or '^'
                                '(.*?)' ...                          % Capture any characters, non-greedy
                                '(?:' ...                            % Start of non-capturing group for terminators
                                  strjoin([ ...
                                      cellfun(@(m) regexptranslate('escape', m), mk2(~cellfun('isempty', mk2)), 'UniformOutput', false), ... % Valid, escaped mk2 alternatives
                                      {'$'} ...                      % Add end-of-string as a mandatory alternative terminator
                                  ], '|') ...                        % Join all terminator patterns with OR
                                ')' ...                              % End of non-capturing group (required - Change 2)
                               ], 'tokens', 'once');
    % Original assignment: will error if extracted_content is empty (no match).
    out = extracted_content{1};
else
    error('mk2 should be either char or cell');
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
end % end of function --> regexp_extract_mk1_mk2_alt


%% ----- remove_empty_cell   [AQP_gui.m lines 30523-30535] -----------------------------------------
function cstr = remove_empty_cell(cstr)
% updated Aug 2026: by Claude
%   ismissing() is ELEMENT-WISE -- ismissing('ID') returns [0 0], which is an
%   illegal operand for ||.  Scalar-safe test moved into a subfunction below.
% output string if cstr become single cell !!!

loc = cellfun(@local_is_empty_or_missing, cstr);
cstr(loc) = [];

if iscell(cstr) && length(cstr)==1
    cstr = cstr{1};        % output the content if cstr become single cell !!!
end
end % end of function --> remove_empty_cell


%% ----- local_is_empty_or_missing   [AQP_gui.m lines 30538-30562] ---------------------------------
function tf = local_is_empty_or_missing(x)
% returns a SCALAR logical for any cell content

if isempty(x)
    tf = true;                          % '' , [] , "" of size 0, {}
    return
end

if ischar(x)
    tf = all(isspace(x));               % '   ' is missing, 'ID' / 'info 1' are not
    return
end

if isstring(x)
    tf = all(ismissing(x) | strlength(x)==0);   % <missing> and ""
    return
end

try
    m  = ismissing(x);                  % numeric NaN, datetime NaT, categorical <undefined>
    tf = ~isempty(m) && all(m(:));
catch
    tf = false;                         % type ismissing can't handle -> keep it
end
end    % end of function -->local_is_empty_or_missing


%% ----- remove_keyword_between_markers   [AQP_gui.m lines 30567-30592] ----------------------------
function skeyword=remove_keyword_between_markers(targetstring,marker1,marker2,opt)


if isempty(find_keyword_between_markers(targetstring,marker1,marker2))
skeyword=targetstring;

else
if ~exist('opt','var')
    % if opt not provided, both marker1 and marker2 will be removed
skeyword=strrep(targetstring, [marker1,find_keyword_between_markers(targetstring,marker1,marker2),marker2]  ,'');

elseif strcmp(opt,'keepLHS')
skeyword=strrep(targetstring, [find_keyword_between_markers(targetstring,marker1,marker2),marker2]  ,'');
    
    
elseif strcmp(opt,'keepRHS')
 skeyword=strrep(targetstring, [marker1,find_keyword_between_markers(targetstring,marker1,marker2)]  ,'');
   
else
    error('not supported opt');
    
    
    
end
end
end


%% ----- remove_keyword_between_markers_wlistRHS   [AQP_gui.m lines 30596-30626] -------------------
function skeyword=remove_keyword_between_markers_wlistRHS(targetstring,marker1,marker2,opt)
% see also strrep_keyword_between_markers_wlistRHS

if isempty(find_keyword_between_markers_wlistRHS(targetstring,marker1,marker2))
    skeyword=targetstring;
    
else
    
   kwfound= find_keyword_between_markers_wlistRHS(targetstring,marker1,marker2);
  marker2_used= marker2{ cellfun(@(x) ~isempty(strfind(targetstring,[kwfound,x])),marker2)};
    
    
    if ~exist('opt','var')
        % if opt not provided, both marker1 and marker2 will be removed
        skeyword=strrep(targetstring, [marker1,find_keyword_between_markers_wlistRHS(targetstring,marker1,marker2),marker2_used]  ,'');
        
    elseif strcmp(opt,'keepLHS')
        skeyword=strrep(targetstring, [find_keyword_between_markers_wlistRHS(targetstring,marker1,marker2),marker2_used]  ,'');
        
        
    elseif strcmp(opt,'keepRHS')
        skeyword=strrep(targetstring, [marker1,find_keyword_between_markers_wlistRHS(targetstring,marker1,marker2)]  ,'');
        
    else
        error('not supported opt');
        
        
        
    end
end
end


%% ----- remove_underscore   [AQP_gui.m lines 30630-30648] -----------------------------------------
function [str_new]=remove_underscore(str_orig);
if iscell( str_orig)

    for ic=1:length(str_orig)
    eastr_orig=str_orig{ic};
    eastr_new=eastr_orig;
    eastr_new(find(eastr_orig=='_'))=' ';
    str_new{ic}=eastr_new;
    end
if size(str_new)~=size(str_orig)
    str_new=str_new';
end
 
else
    str_new=str_orig;
    str_new(find(str_orig=='_'))=' ';

end
end


%% ----- replace_CH   [AQP_gui.m lines 30652-30780] ------------------------------------------------
function A = replace_CH(A, S1, S2) 
% see also: strrep_cstr (deal with matching whole char vector of each element of cstr instead of partial match of each cstr in strrep)
% % see also: ApdCls_eaSn (May 20, 2024)
% this function can NOT handle the case when both S1 or S2 ischar !!! use strrep_cstr that CAN !!!
%-----------------------------------------------------------------
% REPLACE_CH - Replace Elements
%
% this works for double array too, 
% while replace only works for char vector, cstr, and string array
% 
% if only two nargin e.g. A = replace_CH(A, S12) --> assuming S12=[S1,S2];
% 
% mainly for dealing with doubles array
% see also replace_sia_cstr_exact
%   B = REPLACE(A,S1,S2) returns a matrix B in which the elements in A that 
%   are in S1 are replaced by those in S2. In general, S1 and S2 should have
%   an equal number of elements. If S2 has one element, it is expanded to
%   match the size of S1. Examples:
%      replace([1 1 2 3 4 4],[1 3],[0 99]) % ->  [ 0 0 2 99 4 4]
%      replace(1:10,[3 5 6 8],NaN) % ->  [ 1 2 NaN 4 NaN NaN 7 NaN 9 10]
%      replace([1 NaN Inf 8 99],[NaN Inf 99],[12 13 14]) % -> [1 12 13 8 14]
%
%   A and S1 can be cell arrays of strings. In that case S2 should be a
%   cell array as well but can contain mixed types. Example:
%      replace({'aa' 'b' 'c' 'a'},{'a' 'b'}, {'xx' 2}) %-> {'aa' [2] 'c' 'xx'}
%
%   If S2 is empty, the elements of A that are in S1
%   are removed. Examples:
%      replace(1:5,[2 4],[]) % -> [1 3 5]
%      replace({'aa' 'a' 'b' 'aa' 'c'},{'aa','c'},{}) % -> {'a', 'b'}
%   see also: replace_sia_cstr_exact
%   See also FIND, STRREP, REGEXPREP, ISMEMBER
%   same as replace.m in \Mfiles\ALL_Utility_mfiles
%   Also See:   STRREP (alias: replace_str_unequal_size.m)
%   Also See: fix_underscore, bs4us
% for Matlab R13
% version 1.2 (feb 2006)
% (c) Jos van der Geest
% email: jos@jasen.nl
% REPLACE_CH - Replace Elements
% mainly for dealing with doubles array
% see also:  strrep_cstr  replace_sia_cstr_exact
%---------------------------------------------------
if false
    
    replace_CH([1 1 2 3 4 4],[1 3],[0 99]) % ->  [ 0 0 2 99 4 4]
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    replace_CH([1 1 2 3 4 4],[[1; 3],[0;99]]) % ->  [ 0 0 2 99 4 4]
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    replace_CH([1 1 2 3 4 4]',[[1; 3],[0;99]]) % ->  [ 0 0 2 99 4 4]'
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    L=load( 'C:\work\JDSU\Manuf_U2U\Test-mU2U\ATetc_production_MN_wcrStd\SVM\Atrainpketc_mU2U_fVS_0328_aftRm4OutliersUnits(OSW)_w_lvfID_nvar125_ncls3_nsampT1752_nsampP1752.mat')
    L.AclabelT_lvfID=replace_CH(L.AclabelT_lvfID,{'1025-10070Z'},{'1025-10070z'});  % better approach
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %================================================================
    % this will work  (May 20, 2024)
    replace_CH({'aa' 'a' 'b' 'aa' 'c'},{'aa'},{'ddd'})
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % following will Not work (May 20, 2024)
    replace_CH({'aa' 'a' 'b' 'aa' 'c'},'aa','ddd')
    %     [qz nz]=unique_count(L.AclabelT_lvfID)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
narginchk(2,3);

if nargin==2
    if length(S1(1,:))==2
        S12=S1;
        S1=S12(:,1);
        S2=S12(:,2);
    else
        error('not able to handle this')
    end
end
% all three inputs should be cell arrays or numerical arrays
if ~isequal(iscell(A), iscell(S1)) || ~isequal(iscell(A), iscell(S2))
   disp_with_border('this function can NOT handle the case when both S1 or S2 ischar !!! use strrep_cstr that CAN !!!');
    error('The arguments should be all cell arrays or not.') ;
end

if iscell(A),
    % if they are cell, they should be character arrays
    if ~all(cellfun('isclass',A(:),'char')),
        error('A should be a cell array of strings.') ;
    end
    if ~all(cellfun('isclass',S1(:),'char')),
        error('S1 should be a cell array of strings.') ;
    end
end

if ~isempty(S2),
    if numel(S2)==1,
        % single element expansion
        S2 = repmat(S2,size(S1)) ;
    elseif numel(S1) ~= numel(S2),
        error('The number of elements in S1 and S2 do not match ') ;
    end
end

% the engine
[tf,loc] = ismember(A,S1) ;
if any(tf),
    if isempty(S2),
        A(tf) = [] ;
    else
        A(tf) = S2(loc(tf)) ;
    end
end

% special treatment for nans if necessary
if ~iscell(S1),
    % only for non-cell arrays
    qsn = isnan(S1(:)) ;
    if any(qsn),
        qa = isnan(A(:)) ;
        if any(qa),            
            if isempty(S2),
                A(qa) = [] ;
            else
                i = min(find(qsn)) ;            
                A(qa) = S2(i) ;
            end
        end
    end
end
end


%% ----- rmdir_DSn_AQP   [AQP_gui.m lines 30893-30908] ---------------------------------------------
function rmdir_DSn_AQP()
% remove all DSn folders under pwd
if false
    rmdir_DSn_AQP()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clistsubfolder= cellstr(get_subfolder_wFullPath_wKeyword(pwd,'DS'));
idx_find=cellfun(@(x) rmdir_DSn_AQP__isDSn(x,'DS'),find_lastfolder(clistsubfolder));
% clistsubf=
clistsubfolder=clistsubfolder(idx_find);
for ipath=1:length(clistsubfolder)
    try
    rmdir(clistsubfolder{ipath},'s');
    end
end
end


%% ----- rmdir_DSn_AQP__isDSn   [AQP_gui.m lines 30910-30922] --------------------------------------
function out=rmdir_DSn_AQP__isDSn(x,sDS)
loc=strfind(x,sDS);
if loc==1
    sn=find_keyword_numeric_AFTER_marker(x,sDS);
    if strcmp(x,[sDS,sn])
        out=true;
    else
        out=false;
    end
else
    out=false;
end
end


%% ----- rmdir_TMP   [AQP_gui.m lines 30926-30938] -------------------------------------------------
function rmdir_TMP()
% remove all TMP~ folders under pwd
if false
    rmdir_TMP()
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clistsubfolder= get_subfolder_wFullPath_wKeyword(pwd,'TMP');
for ipath=1:length(clistsubfolder)
    try
    rmdir(clistsubfolder{ipath},'s');
    end
end
end


%% ----- row_vector_ALWAYS   [AQP_gui.m lines 31024-31037] -----------------------------------------
function output_row_vector=row_vector_ALWAYS(input_vector);
% make sure it become row vector such that can be used in for loop

size_in=size(input_vector);

if min(size_in)>1
  error('input vector is not a vector, it is a matrix');  
end
if size_in(1)>size_in(2)
   output_row_vector=input_vector';
else
   output_row_vector=input_vector; 
end
end


%% ----- run_each_CabXfer_AQP   [AQP_gui.m lines 31041-31854] --------------------------------------
function [T_cab, P_cab , SAT_cab, fname_cab,outXfer ]=run_each_CabXfer_AQP(CabXfer_scheme,CT_prep,CP_prep,T_prep,P_prep,pfT,pfP,LT,LP,clistclslabel_RT,locRT,locRP,inp)
% this is called by CabXfer_Siesler48_MLtool
% important locations
%
% deal with output XLSX for PRO with Narrow Master WVL and wVal set, Nov 5, 2020
%
% deal with output csv for PRO with Narrow Master WVL and woVal set, Nov 5, 2020
%
% % added this  "get_MN_wvl"  Nov 6, 2020
%======================================================================================================================================
%  % prepare and save Tset-Only AT-file for AAQP to serve as  CabXferd RawSpectra of Master to Target, updated Nov 12, 2020
%======================================================================================================================================
%   %copy CabXferd RawSpectra AT-file (wo-PPd) to "TMP_AQP_StepByStep" updated Nov 15, 2020
%======================================================================================================================================
%  % this location used for Cmp LS vs CH, Nov 17, 2020
%======================================================================================================================================
% %  updated Dec 8, 2020, tol of 1e-3 should be enough
%======================================================================================================================================
% % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
%======================================================================================================================================
% % modify following Mar 8, 2023
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CabXfer_scheme_orig=CabXfer_scheme;
addSetting_CabXfer_scheme=find_keyword_between_markers(CabXfer_scheme_orig,'[',']');
CabXfer_scheme=remove_keyword_between_markers(CabXfer_scheme,'[',']');


switch  CabXfer_scheme
    case 'woCabXfer'
        T_cab=T_prep;
        P_cab=P_prep;
        
    %--------------------------------------------------------------------------------------------------------------
    % "MDCextr_GLSw" (after fixing/bypassing applymean issues), Chang Hsiung, Sept 22, 2017     
    case {'GLSw','MDCextr_GLSw','GLSw_default'}  % "MDCextr_GLSw" (after fixing/bypassing applymean issues), Chang Hsiung, Sept 22, 2017
        %   a : [{0.02}] scalar parameter limiting downweighting {default = 1e-2},
        if ~isempty(addSetting_CabXfer_scheme)
            try
                a=str2num(strrep(find_keyword_between_markers	(addSetting_CabXfer_scheme,'a',''),'p','.'));
            catch
                error('something wrong with "a" parameter')
            end
        else
            a=0.02;
        end
        % a=0.02;
        %   a : [{0.02}] scalar parameter limiting downweighting {default = 1e-2},
        if strcmp(CabXfer_scheme,'GLSw')
            % see  "Incorporation of GLSstd and GLSw into AQP and coupling them with all 7 UDM schemes.pptx"  
            %%%%%%%%%%%%%%%%%%%%%%%%
            % old approach before fixing/bypassing applymean issue
            % before fixing applymean issue, it was running with --> applymean_method = 'YES_on_T&P'
            % applymean_method='YES_on_T&P'; % before fixing applymean issue, it was running with --> applymean_method = 'YES_on_T&P'
             applymean_method='yesT_noP'; % according to PLS toolbox documentation, this is what should be running
             
        elseif strcmp(CabXfer_scheme,'GLSw_default')     
             applymean_method='YES_on_T&P';
             
        elseif strcmp(CabXfer_scheme,'MDCextr_GLSw')
            % see  "Incorporation of GLSstd and GLSw into AQP and coupling them with all 7 UDM schemes.pptx"  
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % "MDCextr_GLSw" (after fixing/bypassing applymean issues), Chang Hsiung, Sept 22, 2017
            applymean_method='MDCextr';  % 'MDCextr' 'YES_on_T&P'   'yesT_noP'   'noT_yesP'   'NO_on_T&P' % before fixing applymean issue, it was running with --> 'YES_on_T&P'
            %%%%%%%%%%%%%%%%%%%%%%%%
        else
            
            error('this GLS scheme subtype not supported')
        end
        
        if strcmp(applymean_method,'MDCextr')
            % apply MDC to CT and CP and T and P from out side glsw
            CT_MDC=  mncn(CT_prep)+mean(CP_prep);
            
            %check whether input x1 and x2 have same mean
            dif_x1_x2=abs( mean(CT_MDC)-mean(CP_prep));
            if max(dif_x1_x2) < 10* max(eps(mean(CT_MDC)))
                modl_GLSw = glsw( CP_prep,CT_MDC,a); % per Lan suggestion and will be our default seq: "CP-CT" or  CP --> x1 and  CT--> x2
            else
                error('x1 and x2 for glsw not MDC''d properly')
            end
            
        else
            % old approach before fixing/bypassing applymean issue
            % before fixing applymean issue, it was running with --> applymean_method = 'YES_on_T&P' (set above)
            % routine way of running glsw
            %modl_GLSw = glsw( CT_prep,CP_prep,a); % orig approach
            modl_GLSw = glsw( CP_prep,CT_prep,a); % per Lan suggestion and will be our default seq: "CP-CT" or  CP --> x1 and  CT--> x2
            
        end
        
%           modl_GLSw = glsw( CP_prep,CT_prep,a);% same result as above
if false
    modl_GLSw.detail.options.applymean
         figure;hold on;
         plot(CT_prep','k->');
         plot(CP_prep','r-*');
end      


       switch applymean_method
           case  'MDCextr' 
                % apply MDC to T (or P ) from out side glsw
            T_MDC=  T_prep-mean(CT_prep)+mean(CP_prep);
            % modl_GLSw.detail.options.applymean='no';% since meaddif is all zeros, this step is not needed
            % 
            T_GLSw  = glsw(T_MDC,modl_GLSw,a);         %apply correction
            % modl_GLSw.detail.options.applymean='no';% since meaddif is all zeros, this step is not needed
            P_GLSw  = glsw(P_prep,modl_GLSw,a);         %apply correction
               
           case 'YES_on_T&P'
        % stay the same, after using Lan's suggestion
        % modl_GLSw.detail.options.applymean by default set to "yes"
        T_GLSw  = glsw(T_prep,modl_GLSw,a);         %apply correction
        P_GLSw  = glsw(P_prep,modl_GLSw,a);         %apply correction
           case 'yesT_noP'
             modl_GLSw.detail.options.applymean='yes';
              T_GLSw  = glsw(T_prep,modl_GLSw,a);         %apply correction
             modl_GLSw.detail.options.applymean='no' ; 
              P_GLSw  = glsw(P_prep,modl_GLSw,a);         %apply correction 
            case 'noT_yesP'
             modl_GLSw.detail.options.applymean='no';
              T_GLSw  = glsw(T_prep,modl_GLSw,a);         %apply correction
             modl_GLSw.detail.options.applymean='yes' ; 
              P_GLSw  = glsw(P_prep,modl_GLSw,a);         %apply correction    
           case 'NO_on_T&P'     
             modl_GLSw.detail.options.applymean='no';
              T_GLSw  = glsw(T_prep,modl_GLSw,a);         %apply correction
            % modl_GLSw.detail.options.applymean='no' ; % already set above
              P_GLSw  = glsw(P_prep,modl_GLSw,a);         %apply correction  
              
              
              
           otherwise
               error(['applymean_method=',applymean_method,' Not supported'])
       end
        
        
        T_cab=T_GLSw;
        P_cab=P_GLSw;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % this will be output to outXfer and run --> UDM_GLSw  = glsw(UDM_prep,modl_GLSw,a);
        Model_GLS.modl_GLSw=modl_GLSw;
        Model_GLS.a=a;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    case 'MDC'  % pls see : "asymmetric_Local_Scaling__PDS in Unscrambler X 10.4.pptx"
        %  Mean Difference Correction
        % this location used for Cmp LS vs CH, Nov 17, 2020
        [mncn_CT mean_CT]=mncn(CT_prep);             % this location used for Cmp LS vs CH, Nov 17, 2020
        [mncn_CP mean_CP]=mncn(CP_prep);
        T_MDC=scale(T_prep,mean_CT)+mean_CP;
        P_MDC=P_prep;
        T_cab=T_MDC;
        P_cab=P_MDC;
        %========================================================
%         disp('halt to save CT_CP etc');   % this location used for Cmp LS vs CH, Nov 17, 2020
        
        if false
            
           save Brix_CT_CP_30PDS.mat CT_prep CP_prep mncn_CT mean_CT mncn_CP mean_CP T_MDC P_MDC 
           % or 
            save Brix_CT_CP_10PDS.mat CT_prep CP_prep mncn_CT mean_CT mncn_CP mean_CP T_MDC P_MDC 

        end
        %====================================================
    case 'LS'
        %  meandif = mean(CT_prep-CP_prep);
        [mncn_CT mean_CT]=mncn(CT_prep);
        [mncn_CP mean_CP]=mncn(CP_prep);
        T_LS=scale(T_prep,mean_CT);
        P_LS=scale(P_prep,mean_CP);
        T_cab=T_LS;
        P_cab=P_LS;
        
    case {'LS-GLSw','MDC-GLSw'}
        if ~isempty(addSetting_CabXfer_scheme)
            try
                a=str2num(strrep(find_keyword_between_markers	(addSetting_CabXfer_scheme,'a',''),'p','.'));
            catch
                error('something wrong with "a" parameter')
            end
        else
            a=0.02;
        end
        
        
        [mncn_CT mean_CT]=mncn(CT_prep);
        [mncn_CP mean_CP]=mncn(CP_prep);
        %=================================
        switch CabXfer_scheme
            
            case 'LS-GLSw'
%         T_LS=scale(T_prep,mean_CT);
%         P_LS=scale(P_prep,mean_CP);
        CT_prep=mncn_CT;
        CP_prep=mncn_CP;
        T_prep=scale(T_prep,mean_CT);
        P_prep=scale(P_prep,mean_CP);
        
            case  'MDC-GLSw'
        T_MDC=scale(T_prep,mean_CT)+mean_CP;
        P_MDC=P_prep; % this may redundant, but the purpose is to make it more systematic
        
        T_prep=T_MDC; % this may redundant, but the purpose is to make it more systematic
        P_prep=P_MDC; % this may redundant, but the purpose is to make it more systematic 
        
        
        CT_MDC=mncn_CT +mean_CP ;        
        CP_MDC=mncn_CP +mean_CP ;% this may redundant, but the purpose is to make it more systematic 
        
        CT_prep=CT_MDC;% this may redundant, but the purpose is to make it more systematic 
        CP_prep=CP_MDC;% this may redundant, but the purpose is to make it more systematic 
        
        
        
        end
        %=================================
        %   a : [{0.02}] scalar parameter limiting downweighting {default = 1e-2},
        %a=0.02;
        modl_GLSw = glsw( CT_prep,CP_prep,a);
        %   a : [{0.02}] scalar parameter limiting downweighting {default = 1e-2},
        T_GLSw  = glsw(T_prep,modl_GLSw,a);         %apply correction
        P_GLSw  = glsw(P_prep,modl_GLSw,a);         %apply correction
        T_cab=T_GLSw;
        P_cab=P_GLSw;
        
        if false
        figure;hold on;plot(T_cab','r-*')
        figure;hold on;plot(T_prep','b-O')
        end
%         disp('halt for MDC-GLSw')
        
        
    case 'LS-OSC'
        [mncn_CT mean_CT]=mncn(CT_prep);
        [mncn_CP mean_CP]=mncn(CP_prep);
        T_LS=scale(T_prep,mean_CT);
        P_LS=scale(P_prep,mean_CP);
        
        CT_prep=mncn_CT;
        CP_prep=mncn_CP;
        
        T_prep=scale(T_prep,mean_CT);
        P_prep=scale(P_prep,mean_CP);
        
        Nfac_OSC=2;  % based on osccalcdemo's setting
        [nx,nw,np,nt] = osccalc(CT_prep,CP_prep,Nfac_OSC);
        T_cab = oscapp(T_prep,nw,np);
        P_cab = oscapp(P_prep,nw,np);
        
        
        
    case {'GLSstd2','LS_GLSstd3','MDC_GLSstd3'}
     % see  "Incorporation of GLSstd and GLSw into AQP and coupling them with all 7 UDM schemes.pptx"  
        % 'GLSstd2' --> Adjust the transfer samples to be of the same mean

        % 'GLSstd3'  based on GLSstd2 but --> Without adjusting transfer samples to same mean
        
        % 'GLSstd2' equivalent to MDC-GLSstd3 ?
        
        % "alpha"  the tolerance for matrix inversion (alpha), generally ~1e-6.
        %  alpha=1e-6;
        
        if ~isempty(addSetting_CabXfer_scheme)
            try
                alpha=str2num(strrep(find_keyword_between_markers	(addSetting_CabXfer_scheme,'alpha',''),'p','.'));
            catch
                error('something wrong with "alpha" parameter')
            end
        else
            alpha=1e-6;
        end
        
        switch CabXfer_scheme
            case 'GLSstd2'
                % see also "GLSstd_ApplyOn_UDM" in "AutoQuant_DA_pipeline"
                % for applying this kind of GLS on UDM
                [BadWgtMatrX,meandif] = GLSstd2(CP_prep,CT_prep,alpha);
                %         %Apply the transform to all the samples in both sets
        
        T_prep_BWscale=scale(T_prep,-meandif);
        T_GLSstd = T_prep_BWscale*BadWgtMatrX;
        
        P_GLSstd = P_prep*BadWgtMatrX;
        
            case 'LS_GLSstd3'
                try
                    if strcmp(inp.inp4AQP.DataFlow,'PP-Xfer')
                        [BadWgtMatrX,meandif] = GLSstd3(mncn(CP_prep),mncn(CT_prep),alpha);
                        %                  T_GLSstd = T_prep*BadWgtMatrX;
                        %                  P_GLSstd = P_prep*BadWgtMatrX;
                        
                        T_GLSstd = scale(T_prep,mean(CT_prep))*BadWgtMatrX;
                        P_GLSstd = scale(P_prep,mean(CP_prep))*BadWgtMatrX;
                    else
                        Speak_mk('DataFlow should be Preprocessing followd by transfer to this transfer scheme to make sense');
                        disp_with_border('DataFlow should be "PP-Xfer" to this Xfer_scheme to make sense');
                        return
                        % error('DataFlow should be "PP-Xfer" to this Xfer_scheme to make sense');
                    end
                catch
                    Speak_mk('DataFlow should be Preprocessing followd by transfer to this transfer scheme to make sense');
                    disp_with_border('DataFlow should be "PP-Xfer" to this Xfer_scheme to make sense');
                    error('DataFlow should be "PP-Xfer" to this Xfer_scheme to make sense');
                    
                end
                 
                
            case 'MDC_GLSstd3'  
             % see also "GLSstd_ApplyOn_UDM" in "AutoQuant_DA_pipeline"
             % for applying this kind of GLS on UDM   
                CT_MDC=mncn(CT_prep)+mean(CP_prep);
                
%                 mean(CT_MDC) mean(CP_prep)
               [BadWgtMatrX,meandif] = GLSstd3(CP_prep,CT_MDC,alpha); 
               
                T_MDC=T_prep-mean(CT_prep)+mean(CP_prep);
                T_GLSstd = T_MDC*BadWgtMatrX;
                
               P_GLSstd = P_prep*BadWgtMatrX;
               
               
                
        end
        % "alpha"  the tolerance for matrix inversion (alpha), generally ~1e-6.
        
%         %Apply the transform to all the samples in both sets
%         T_LSGLS = T_prep*BadWgtMatrX;
%         P_prep_BWscale=scale(P_prep,-meandif);
%         P_LSGLS = P_prep_BWscale*BadWgtMatrX;
        
        T_cab=T_GLSstd;
        P_cab=P_GLSstd;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % this will be output to outXfer and run --> UDM_GLSstd  = GLSstd_ApplyOn_UDM(UDM_prep,modl_GLSstd);
        opt4GLSstd.GLSstd_mode=CabXfer_scheme;
        modl_GLSstd.opt4GLSstd=opt4GLSstd;
        modl_GLSstd.BadWgtMatrX=BadWgtMatrX;
        modl_GLSstd.meandif=meandif;
        modl_GLSstd.alpha=alpha;
        Model_GLS.modl_GLSstd=modl_GLSstd;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
        
        
        
    case 'PDS'
      % win=5;
       %    win=9;
%            win=1;
       %    win=3;
      win=find_keynumber_numeric_AFTER_marker(addSetting_CabXfer_scheme,'w');
        options_PDS.maxpc=[];
        [stdmatpds,stdvectpds] = stdgen(CP_prep,CT_prep,win,options_PDS);
        T_prd_basedon_stdgenize   = stdize(T_prep,stdmatpds,  stdvectpds);
        T_cab=T_prd_basedon_stdgenize;
        P_cab=P_prep;
        
        
        
        
    case 'LS-PDS'
        %--------------------------------
        [mncn_CT mean_CT]=mncn(CT_prep);
        [mncn_CP mean_CP]=mncn(CP_prep);
        T_LS=scale(T_prep,mean_CT);
        P_LS=scale(P_prep,mean_CP);
        %--------------------------------
        win=5;
        T4stdgenize=T_LS;
        CT4stdgenize=mncn_CT;
        P4stdgenize=P_LS;
        CP4stdgenize=mncn_CP;
        
        [stdmatpds,stdvectpds] = stdgen(CP4stdgenize,CT4stdgenize,win);
        T_prd_basedon_stdgenize   = stdize(T4stdgenize,stdmatpds,  stdvectpds);
        T_cab=T_prd_basedon_stdgenize;
        P_cab=P4stdgenize;
        
        if false
            figure;hold on;
            plot(T_cab','b-O');
            plot(P_cab','r-O');
        end
        %--------------------------------
    case {'STDgenize','STDgenize99','PDS99'}
        
        % BMW's PDS based on stdgen and stdize
        if ~isempty(addSetting_CabXfer_scheme)
            try
                win=find_keynumber_numeric_AFTER_marker(addSetting_CabXfer_scheme,'win');
                if isnan(win)
                    win=find_keynumber_numeric_AFTER_marker(addSetting_CabXfer_scheme,'w');
                end
            catch
                error('something wrong with "win" width')
            end
        else
            win=5;
        end
        
        
        T4stdgenize=T_prep;
        CT4stdgenize=CT_prep;
        P4stdgenize=P_prep;
        CP4stdgenize=CP_prep;
        
        switch CabXfer_scheme
            
            case 'STDgenize'
        [stdmatpds,stdvectpds] = stdgen(CP4stdgenize,CT4stdgenize,win);
        T_prd_basedon_stdgenize   = stdize(T4stdgenize,stdmatpds,  stdvectpds);
            case {'STDgenize99','PDS99'}
         [stdmatpds,stdvectpds] = stdgen99(CP4stdgenize,CT4stdgenize,win);
        T_prd_basedon_stdgenize   = stdize99(T4stdgenize,stdmatpds,  stdvectpds); 
            otherwise
                error([CabXfer_scheme,' Not supported ??'])
                
        end
        
        T_cab=T_prd_basedon_stdgenize;
        P_cab=P4stdgenize;
        
        if false
            
            save('New_T_T_PDS.mat','T4stdgenize','T_prd_basedon_stdgenize');
            
            figure;hold on;
            plot(CT4stdgenize','c-*');
            plot(CP4stdgenize','m-*');
            title('New or Old stdgenize CT vs CP');
            legend({'CT','CP'});
            
            figure;hold on;
            plot(T4stdgenize','b-*');
            plot(T_prd_basedon_stdgenize','r-*');
            title('New or Old stdgenize T vs PDS-T');
            legend({'T','PDS-T'});
            
            figure;hold on;
            plot(P_cab','k-*');
            plot(T_cab','r-*');
            title('New or Old stdgenize Tcab vs Pcab');
            legend({'P-cab','T-cab'});
            
            
        end
        
        
        
        
        
    case 'OSC'
        %------------------------------------
        % based on example in "osccalcdemo"
        % % Use the OSCCALC function on the subset of spectra from the two
        % % instruments to calculate the necessary correction factors (weights, nw, and
        % % loadings, np) necessary to remove the undesired variance:
        %
        % [nx,nw,np,nt] = osccalc(x,y,2);
        %
        % % and use OSCAPP applies these correction factors to the full set of all spectra
        %
        % newx1 = oscapp(spec1.data,nw,np);
        % newx2 = oscapp(spec2.data,nw,np);
        Nfac_OSC=2;  % based on osccalcdemo's setting
        [nx,nw,np,nt] = osccalc(CT_prep,CP_prep,Nfac_OSC);
        T_cab = oscapp(T_prep,nw,np);
        P_cab = oscapp(P_prep,nw,np);
        
    otherwise
        error('CabXfer scheme not supported')
        
end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        spp1=find_keyword_between_markers_wlistRHS(   fileparts_name_wo_ext(   pfT),'_pp1-',{'_','}'});
       if isempty(spp1)
                spp1=find_keyword_between_markers_wlistRHS(   fileparts_name_wo_ext(   pfT),'_pp-',{'_','}'});
       end
                    sTSM=find_keyword_between_markers(fileparts_name_wo_ext(pfT),'{T-','_');
            sPSM=find_keyword_between_markers(fileparts_name_wo_ext(pfT),'_P-','_');

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       if inp.fig_yes==1
                figure(35);hold on;
                
          % T on top      
        hp35_P=plot(P_cab','b-O');
        hp35_T=plot(T_cab','m-*');
        legend([hp35_P(1) hp35_T(1)],{[CabXfer_scheme,' -> P '],[CabXfer_scheme,' -> T']});

         % P on top
%         hp35_T=plot(T_cab','m-*');
%         hp35_P=plot(P_cab','b-O');
%         legend([hp35_T(1) hp35_P(1)],{[CabXfer_scheme,' -> T '],[CabXfer_scheme,' -> P']});

        if strcmp(pfT,pfP)
        title({[CabXfer_scheme,' :  Mst(',sTSM,')',' ->  Trg(',sPSM,')'];['pp1-',spp1]});

        else
        title([CabXfer_scheme,' :  Mst(',find_keyword_between_markers(fileparts_name_wo_ext(pfT),'(',')'),')',' ->  Trg(',find_keyword_between_markers(fileparts_name_wo_ext(pfP),'(',')'),')']);
        end
        
        
         figure(30);hold on;
        hp30_P=plot(P_prep','c-O');
        hp30_T=plot(T_prep','r-*');
        legend([hp30_P(1) hp30_T(1)],{'Ref P','Ref T'});
       % title(['Ref sets ->  ',remove_underscore(fileparts_name_wo_ext(pfT))]);
        if strcmp(pfT,pfP) 
               title({[CabXfer_scheme,' :  Mst(',sTSM,')',' ->  Trg(',sPSM,')'];['pp1-',spp1]});

        else
       title(['Ref sets',' :  Mst(',find_keyword_between_markers(fileparts_name_wo_ext(pfT),'(',')'),')',' ->  Trg(',find_keyword_between_markers(fileparts_name_wo_ext(pfP),'(',')'),')']);
        end
       end
        
%      Atrainpk_GLSw=[Atrainpk_GLSw;T_GLSw];
%      Apred_GLSw=[Apred_GLSw;P_GLSw];
% 
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SAT_cab.wvl_standardize=LT.wvl_standardize;
SAT_cab.clistclslabel=clistclslabel_RT;
SAT_cab.Atrainpk=T_cab;
SAT_cab.Apred=P_cab;
% 
try SAT_cab.RawSpectra.Tset=LT.RawSpectra(locRT,:);end
try SAT_cab.RawSpectra.Pset=LP.RawSpectra(locRP,:);end
SAT_cab.AclabelT=LT.AclabelT(locRT,:);;
SAT_cab.AclabelP=LP.AclabelT(locRP,:);;
try
SAT_cab.AclassinfoT=cellfun(@(x) strmatch(x,SAT_cab.clistclslabel,'exact'),SAT_cab.AclabelT);
catch
    try
SAT_cab.AclassinfoT=cellfun(@(x) strmatch_empty2NaN(x,SAT_cab.clistclslabel),SAT_cab.AclabelT);
    catch
 SAT_cab.AclassinfoT=repmat(NaN,size(SAT_cab.AclabelT));       
    end
end

try
SAT_cab.AclassinfoP=cellfun(@(x) strmatch(x,SAT_cab.clistclslabel,'exact'),SAT_cab.AclabelP);
catch
SAT_cab.AclassinfoP=repmat(NaN,[size(SAT_cab.AclabelP)]);    
end
saConc_RT_cab=LT.saConc(locRT);
% for irow=1:length(saConc_RT_cab)
% saConc_RT_cab(irow).Atrainpk=T_cab(irow,:);
% end

[saConc_RT_cab.Atrainpk]=SAinsert_mat2cell_CH(T_cab,'row');


saConc_RP_cab=LP.saConc(locRP);
% for irow=1:length(saConc_RP_cab)
% saConc_RP_cab(irow).Atrainpk=P_cab(irow,:);
% end
[saConc_RP_cab.Atrainpk]=SAinsert_mat2cell_CH(P_cab,'row');


SAT_cab.PLS.Tset.saConc=saConc_RT_cab;
SAT_cab.PLS.Pset.saConc=saConc_RP_cab;
try
SAT_cab.saCTCP=inp.saCTCP; % this will be used to carry list of ID for XS set
end
snsampT=['_nsampT',num2str(length(SAT_cab.PLS.Tset.saConc))];
snsampP=['_nsampP',num2str(length(SAT_cab.PLS.Pset.saConc))];
%--------------------------------------------------------
% modify following Mar 8, 2023
% defaultValue('sCTP_meanConc','_');
sCTP_meanConc='_';
%--------------------------------------------------------

fname_cab=['Atrainpketc_saConc_TestCabXfer_{',CabXfer_scheme_orig,'_',inp.XM_Slct_scheme_orig,sCTP_meanConc,'_pp1-',spp1,'}','_[T-',sTSM,'_P-',sPSM,']',snsampT,snsampP,'.mat'];
fname_cab=strrep(fname_cab,'__','_');
fname_cab=strrep(fname_cab,'_pp1-1stDerSGDiederick','_pp-1stDer');

if ~strcmp(CabXfer_scheme,'woCabXfer')
fname_cab=strrep(fname_cab,'.mat',[inp.snXS,'.mat']);
end

if inp.TP_includeTrn_Yes 
fname_cab=strrep(fname_cab,'_saConc','_saConc_TPwTrn');
end
%===================================================================================
 % % prepare and save Tset-Only AT-file for AAQP to serve as  CabXferd RawSpectra of Master to Target, updated Nov 12, 2020
     sd4AAQP=ssds(SAT_cab);
     sd4AAQP_Tset_Only=sd4AAQP.rm_Pset;
     inp4AAQP.corename=['{',CabXfer_scheme,'-Mst_RawSpectra_Tset-Only_for-AAQP','}'];
     sd4AAQP_Tset_Only=sd4AAQP_Tset_Only.saveAT(inp4AAQP );
     copyfile(sd4AAQP_Tset_Only.pathfname_AT,  [find_last_nonTMP_path,'\TMP_AQP_StepByStep']);                    %copy CabXferd RawSpectra AT-file (wo-PPd) to "TMP_AQP_StepByStep" updated Nov 15, 2020

%===================================================================================
if strcmp(inp.Test_or_Val,'Val')
    fname_cab=strrep(fname_cab,']',['_',inp.Test_or_Val,']']);
    fname_cab=strrep(fname_cab,'.mat',['_wo_AT2RS.mat']); % for --> SAT_cab.Atrainpk will be used for output of transfered CS sent to  MicroNIR-PRO
    save(fullfile(inp.sTMPpath,fname_cab),'-struct','SAT_cab');             % SAT_cab.Atrainpk will be used for output of transfered CS sent to  MicroNIR-PRO
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add by CH, Dec 4, 2019 for output Transferred CS (but not PPd) spectra for PRO to use
    % very important --> make sure run AT2RS before manually preprocessing these AT files
    % see test_AT2RS()
    % see --> AQPlite output transferred spectra in xlsx.pptx
    sd4PRO=ssds(SAT_cab);
    inp4P.corename=['{T-',CabXfer_scheme,'-CS-woPPd_P-Val','}'];
    sd_T_CabXferd_CS_woPPd_P_Val_4PRO=sd4PRO.saveAT(inp4P);
    disp('output Transferred CS (but not PPd) spectra for PRO to use')
    cprint0=[{'ID',sd4PRO.LAT.PLS.Tset.saConc(1).clsname},num2cell(sd4PRO.LAT.wvl_standardize)];
    callConc_T=num2cell(cat(1,sd4PRO.LAT.PLS.Tset.saConc.Conc));
    callID_T=arrayfun(@(x) x.SampleName{1},sd4PRO.LAT.PLS.Tset.saConc,'un',0);
    
    cAtrainpk=num2cell(sd4PRO.LAT.Atrainpk);% come from SAT_cab.Atrainpk and will be used for output of transfered CS sent to  MicroNIR-PRO
    %===================================================================
     % deal with output XLSX for PRO with Narrow Master WVL and wVal set, Nov 5, 2020
%      Lwvl=load('C:\work\JDSU\Test_AQP\test_Narrow_WVL_Mst\WVL\wvl_ES_AK.mat');
% =====================================================
% % added this  "get_MN_wvl"  Nov 6, 2020
     wvl_MN=get_MN_wvl;   % added this  "get_MN_wvl"  Nov 6, 2020
%=====================================================     
if length(sd4PRO.LAT.wvl_standardize)<length(wvl_MN)
    Npz=length(wvl_MN)- length(sd4PRO.LAT.wvl_standardize);
    sPZ=['_Pad',num2str(Npz),'ZerosCol'];
    DM_zeros=zeros([length(callID_T) length(wvl_MN)]);
    
    %      loc_wvl_intersect=row_always(find_belong2subgrp(wvl_MN,sd4PRO.LAT.wvl_standardize));
    %------------------------------------------------------------------------------------------------------------------------
    % updated Dec 8, 2020 to handle Narrow-WVL and woXRS case (i.e. MatchGrids Only)
    [ idx_wvl_intersect,locb]=ismembertol( row_always(sd4PRO.LAT.wvl_standardize),  row_always(wvl_MN),1e-3);    %  updated Dec 8, 2020, tol of 1e-3 should be enough
    %------------------------------------------------------------------------------------------------------------------------
    loc_wvl_intersect=find(idx_wvl_intersect);
    
    Atrainpk_pz=DM_zeros;
    Atrainpk_pz(:, loc_wvl_intersect)=sd4PRO.LAT.Atrainpk;
    cAtrainpk_pz=num2cell(Atrainpk_pz);% come from SAT_cab.Atrainpk and will be used for output of transfered CS sent to  MicroNIR-PRO
    cprint0_pz=[{'ID',sd4PRO.LAT.PLS.Tset.saConc(1).clsname},num2cell(row_always(wvl_MN))];
    % cprint=[cprint0;[ callID_T, callConc_T, cAtrainpk]];
    cprint=[cprint0_pz;[ callID_T, callConc_T, cAtrainpk_pz]];
else
    sPZ='';
    cprint=[cprint0;[ callID_T, callConc_T, cAtrainpk]];
    
end
    %===================================================================

    
    xlsx_fname_T_CabXferd_CS_woPPd_4PRO=[fileparts_name_wo_ext(sd_T_CabXferd_CS_woPPd_P_Val_4PRO.pathfname_AT),'.xlsx'];
    xlsx_fname_T_CabXferd_CS_woPPd_4PRO=strrep(xlsx_fname_T_CabXferd_CS_woPPd_4PRO,'P-Val','');
    xlsx_fname_T_CabXferd_CS_woPPd_4PRO=textual_eraseBetween_rmkw1(xlsx_fname_T_CabXferd_CS_woPPd_4PRO,'_nsampP','.xls');
    xlsx_fname_T_CabXferd_CS_woPPd_4PRO=strrep(xlsx_fname_T_CabXferd_CS_woPPd_4PRO,'_}','}');
    % deal with output XLSX for PRO with Narrow Master WVL and wVal set, Nov 5, 2020
     xlsx_fname_T_CabXferd_CS_woPPd_4PRO=strrep( xlsx_fname_T_CabXferd_CS_woPPd_4PRO,'.xlsx',[sPZ,'.xlsx']);  % deal with output XLSX for PRO with Narrow Master WVL and wVal set, Nov 5, 2020
    
    xlswrite_ChkLn(xlsx_fname_T_CabXferd_CS_woPPd_4PRO,cprint);
    disp_with_border([xlsx_fname_T_CabXferd_CS_woPPd_4PRO,' has been created']);
    % also output as 'csv' file
    csv_fname_T_CabXferd_CS_woPPd_4PRO=strrep(xlsx_fname_T_CabXferd_CS_woPPd_4PRO,'.xlsx','.csv');
    cell2csv(csv_fname_T_CabXferd_CS_woPPd_4PRO,cprint);
    %%%%%%%%%%%%%%%%%%%%%%%
    % also output as .sam files for PRO
    % ParentFolder4Results4PRO='Results4PRO';
    % prefix4tmpfolder4SAMfiles='tmp';
    if  ~isfield(inp.inp4AQP,'Option_Output_SAM') | inp.inp4AQP.Option_Output_SAM 
        path_sam=create_next_subfolder([find_last_nonTMP_folder,'\',inp.ParentFolder4Results4PRO],inp.prefix4tmpfolder4SAMfiles);
        copyfile([pwd,'\',csv_fname_T_CabXferd_CS_woPPd_4PRO],path_sam);
        %%%%%%%%%%%%
        % run VS ML2Sam
        errorStr_loadSL = load_SamLibrary;
        disp(['errorStr_loadSL:', errorStr_loadSL]);
        Speak_mk(errorStr_loadSL);
        inp4ML2Sam.path4Sam=path_sam;
        errorStr_convert2Sam = ML2Sam(callID_T,cell2mat(cAtrainpk),cell2mat(callConc_T),inp4ML2Sam);
        disp(['errorStr_convert2Sam:', errorStr_convert2Sam]);
        
        disp('done with ML2Sam')
    end
    %%%%%%%%%%%%%%%%%%%%%%
    if false
        isequal(T_cab,sd4PRO.LAT.Atrainpk)
        
        figure;hold on;plot(sd4PRO.LAT.Apred','k-*');plot(T_cab','r-*');
        figure;hold on;plot(sd4PRO.LAT.Apred','k-*');plot(T_prep','b-O');
        
    end
    
    %
else
%============================================================

    save(fullfile(inp.sTMPpath,fname_cab),'-struct','SAT_cab');
    disp([fname_cab,' has been saved'])

    % SAT_cab
    if isempty(inp.pathfnameTP4Val)
     %-----------------------------------------------------------------------------------------------------   
%     % % prepare and save related files for AAQP dealing with CS-only ( or Tset-Only ) case that use these files to serve as  CabXferd RawSpectra of Master to Target, updated Nov 12, 2020
%      sd4AAQP=ssds(SAT_cab);
%      sd4AAQP_Tonly=sd4AAQP.rm_Pset;
%      inp4Tonly.corename=['{',CabXfer_scheme,'-Mst_RawSpectra_','Tset-Only_for-AAQP','}'];
%      sd4AAQP_Tonly=sd4AAQP_Tonly.saveAT;
%      
     %-----------------------------------------------------------------------------------------------------
        callConc_T=num2cell(cat(1,SAT_cab.PLS.Tset.saConc.Conc));
        callID_T=arrayfun(@(x) x.SampleName{1},SAT_cab.PLS.Tset.saConc,'un',0);
        cAtrainpk=num2cell(SAT_cab.Atrainpk);% come from SAT_cab.Atrainpk and will be used for output of transfered CS sent to  MicroNIR-PRO
        cprint0=[{'ID',SAT_cab.PLS.Tset.saConc(1).clsname},num2cell(SAT_cab.wvl_standardize)];
        cprint=[cprint0;[ callID_T, callConc_T, cAtrainpk]];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        sd4PRO=ssds(SAT_cab);
        
             wvl_MN=get_MN_wvl;   % added this  "get_MN_wvl"  Nov 6, 2020
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % deal with output csv for PRO with Narrow Master WVL and woVal set, Nov 5, 2020
%         Lwvl=load('C:\work\JDSU\Test_AQP\test_Narrow_WVL_Mst\WVL\wvl_ES_AK.mat');
        if length(sd4PRO.LAT.wvl_standardize)<length(wvl_MN)
            Npz=length(wvl_MN)- length(sd4PRO.LAT.wvl_standardize);
            sPZ=['_Pad',num2str(Npz),'ZerosCol'];
            DM_zeros=zeros([length(callID_T) length(wvl_MN)]);
            
%             loc_wvl_intersect=row_always(find_belong2subgrp(wvl_MN,sd4PRO.LAT.wvl_standardize));
%             
%            loc_wvl_intersect=row_always(find_belong2subgrp(sd4PRO.LAT.wvl_standardize,wvl_MN   ));

            % added Nov 6, 2020
           [lia,locb]=ismembertol(sd4PRO.LAT.wvl_standardize,get_MN_wvl,1e-3);    % tol of 1e-3 should be enough
           loc_wvl_intersect=locb;

            Atrainpk_pz=DM_zeros;
            Atrainpk_pz(:, loc_wvl_intersect)=sd4PRO.LAT.Atrainpk;
            cAtrainpk_pz=num2cell(Atrainpk_pz);% come from SAT_cab.Atrainpk and will be used for output of transfered CS sent to  MicroNIR-PRO
            cprint0_pz=[{'ID',sd4PRO.LAT.PLS.Tset.saConc(1).clsname},num2cell(row_always(wvl_MN))];
            % cprint=[cprint0;[ callID_T, callConc_T, cAtrainpk]];
            cprint=[cprint0_pz;[ callID_T, callConc_T, cAtrainpk_pz]];
        else
            sPZ='';
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % only output as 'csv' file (not xlsx)
        %         sd4PRO=ssds(SAT_cab);
        inp4P.corename=['{T-',CabXfer_scheme,'-CS-woPPd_P-Val','}'];
        sd_T_CabXferd_CS_woPPd_P_Val_4PRO=sd4PRO.saveAT(inp4P);
        disp('output Transferred CS (but not PPd) spectra for PRO to use')
        csv_fname_T_CabXferd_CS_woPPd_4PRO=[fileparts_name_wo_ext(sd_T_CabXferd_CS_woPPd_P_Val_4PRO.pathfname_AT),'.csv'];
        csv_fname_T_CabXferd_CS_woPPd_4PRO=strrep(csv_fname_T_CabXferd_CS_woPPd_4PRO,'P-Val','');
        csv_fname_T_CabXferd_CS_woPPd_4PRO=textual_eraseBetween_rmkw1(csv_fname_T_CabXferd_CS_woPPd_4PRO,'_nsampP','.xls');
        csv_fname_T_CabXferd_CS_woPPd_4PRO=strrep(csv_fname_T_CabXferd_CS_woPPd_4PRO,'_}','}');
        
        % deal with output csv for PRO with Narrow Master WVL and woVal set, Nov 5, 2020
        csv_fname_T_CabXferd_CS_woPPd_4PRO=strrep( csv_fname_T_CabXferd_CS_woPPd_4PRO,'.csv',[sPZ,'.csv']);  % deal with output csv for PRO with Narrow Master WVL and woVal set, Nov 5, 2020
        
        cell2csv(csv_fname_T_CabXferd_CS_woPPd_4PRO,cprint);
        %%%%%%%%%
        path_sam=create_next_subfolder([find_last_nonTMP_folder,'\',inp.ParentFolder4Results4PRO],inp.prefix4tmpfolder4SAMfiles);
        copyfile([pwd,'\',csv_fname_T_CabXferd_CS_woPPd_4PRO],path_sam);
        %%%%%%%%%%%%
        % run VS ML2Sam wo Val set
        errorStr_loadSL = load_SamLibrary;
        disp(['errorStr_loadSL:', errorStr_loadSL]);
        Speak_mk(errorStr_loadSL);
        inp4ML2Sam.path4Sam=path_sam;
        errorStr_convert2Sam = ML2Sam(callID_T,cell2mat(cAtrainpk),cell2mat(callConc_T),inp4ML2Sam);
        disp(['errorStr_convert2Sam:', errorStr_convert2Sam]);
        disp('done with ML2Sam for case with missing Val set')
    end
    %%%%%%%%%%%%%%%%%%%%%%
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(inp.Test_or_Val,'Test')
fname_CTCP=strrep(fname_cab,'Atrainpketc_saConc','saCTCP');
snConc=['_nConc',num2str(length(inp.saCTCP))];
nsampCT=sum(arrayfun(@(x) length(x.CT_AInfo_1),inp.saCTCP));
nsampCP=sum(arrayfun(@(x) length(x.CP_AInfo_1),inp.saCTCP));
if nsampCT==nsampCP
    snsampCTCP=['_nsampCTCP',num2str(nsampCP)];
  fname_CTCP=strrep(fname_CTCP,'.mat',[snConc,snsampCTCP,'.mat']);
  SCTCP.saCTCP=inp.saCTCP;
 save(fullfile(inp.sTMPpath,fname_CTCP),'-struct','SCTCP');
   
else
    
 snsampCT=['_nsampCT',num2str(nsampCT)];
 snsampCP=['_nsampCP',num2str(nsampCP)];
 
  fname_CTCP=strrep(fname_CTCP,'.mat',[snConc,snsampCT,snsampCP,'.mat']);
  SCTCP.saCTCP=inp.saCTCP;
  try
  SCTCP.CP4stdgenize=CP4stdgenize;
  SCTCP.CT4stdgenize=CT4stdgenize;
  
  SCTCP.T4stdgenize=T4stdgenize;
  SCTCP.stdmatpds= stdmatpds; 
  SCTCP.stdvectpds=stdvectpds;
  end
 save(fullfile(inp.sTMPpath,fname_CTCP),'-struct','SCTCP');    
    
end
disp([fname_CTCP,' has been saved'])
end

try
    outXfer.Model_GLS=Model_GLS;
catch
    outXfer.Model_GLS='';
end
end


%% ----- savitzkyGolay   [AQP_gui.m lines 31867-32014] ---------------------------------------------
function [fc, df] = savitzkyGolay(x,n,dn,x0,W,flag)
% Function:
%       Savitzky-Golay Smoothing and Differentiation Filter
%       The Savitzky-Golay smoothing/differentiation filter (i.e., the
%       polynomial smoothing/differentiation filter, or  the least-squares
%       smoothing/differentiation filters) optimally fit a set of data
%       points to polynomials of different degrees. 
%       See for details in Matlab Documents (help sgolay). The sgolay
%       function in Matlab can deal with only symmetrical and uniformly
%       spaced data of even number.
%       This function presented here is a general implement of the sgolay
%       function in Matlab. The Savitzky-Golay filter coefficients for even
%       number, nonsymmetrical and nonuniformly spaced data can be
%       obtained. And the filter coefficients for the initial point or the
%       end point can be obtained too. In addition, either numerical
%       results or symbolical results can be obtained. Lastly, this
%       function is faster than MATLAB's sgolay.
%
% Usage:
%       [fc,df] = savitzkyGolay(x,n,dn,x0,flag)
%   input:
%       x    = the original data point, e.g., -5:5 
%       n    = polynomial order
%       dn   = differentation order (0=smoothing),  default=0
%       x0   = estimation point, can be a vector    default=0
%       W    = weight vector, can be empty          
%              must have same length as x0          default=identity
%       flag = numerical(0) or symbolical(1),       default=0
%
%   output:
%       fc   = filter coefficients obtained (B output of sgolay).
%       df   = differentiation filters (G output of sgolay).
% Notes:
% 1.    x can be arbitrary, e.g., odd number or even number, symmetrical or
%       nonsymmetrical, uniformly spaced or nonuniformly spaced, etc.       
% 2.    x0 can be arbitrary, e.g., the initial point, the end point, etc.
% 3.    Either numerical results or symbolical results can be obtained.
% Example:
%       sgsdf([-3:3],2,0,0,[],0)
%       sgsdf([-3:3],2,0,0,[],1)
%       sgsdf([-3:3],2,0,-3,[],1)
%       sgsdf([-3:3],2,1,2,[],1)
%       sgsdf([-2:3],2,1,1/2,[],1)
%       sgsdf([-5:2:5],2,1,0,[],1)     
%       sgsdf([-1:1 2:2:8],2,0,0,[],1)
% Author:
%       Diederick C. Niehorster <dcniehorster@hku.hk> 2011-02-05
%       Department of Psychology, The University of Hong Kong
%
%       Originally based on
%       http://www.mathworks.in/matlabcentral/fileexchange/4038-savitzky-golay-smoothing-and-differentiation-filter
%       Allthough I have replaced almost all the code (partially based on
%       the comments on the FEX submission), increasing its compatibility
%       with MATLABs sgolay (now supports a weight matrix), its numerical
%       stability and it speed. Now, the help is pretty much all that
%       remains.
%       Jianwen Luo <luojw@bme.tsinghua.edu.cn, luojw@ieee.org> 2003-10-05
%       Department of Biomedical Engineering, Department of Electrical Engineering
%       Tsinghua University, Beijing 100084, P. R. China  
% Reference
%[1]A. Savitzky and M. J. E. Golay, "Smoothing and Differentiation of Data
%   by Simplified Least Squares Procedures," Analytical Chemistry, vol. 36,
%   pp. 1627-1639, 1964.
%[2]J. Steinier, Y. Termonia, and J. Deltour, "Comments on Smoothing and
%   Differentiation of Data by Simplified Least Square Procedures,"
%   Analytical Chemistry, vol. 44, pp. 1906-1909, 1972.
%[3]H. H. Madden, "Comments on Savitzky-Golay Convolution Method for
%   Least-Squares Fit Smoothing and Differentiation of Digital Data,"
%   Analytical Chemistry, vol. 50, pp. 1383-1386, 1978.
%[4]R. A. Leach, C. A. Carter, and J. M. Harris, "Least-Squares Polynomial
%   Filters for Initial Point and Slope Estimation," Analytical Chemistry,
%   vol. 56, pp. 2304-2307, 1984.
%[5]P. A. Baedecker, "Comments on Least-Square Polynomial Filters for
%   Initial Point and Slope Estimation," Analytical Chemistry, vol. 57, pp.
%   1477-1479, 1985.
%[6]P. A. Gorry, "General Least-Squares Smoothing and Differentiation by
%   the Convolution (Savitzky-Golay) Method," Analytical Chemistry, vol.
%   62, pp. 570-573, 1990.
%[7]Luo J W, Ying K, He P, Bai J. Properties of Savitzky-Golay Digital
%   Differentiators, Digital Signal Processing, 2005, 15(2): 122-136.
%
%See also:
%       sgolay, savitzkyGolayFilt

% Check if the input arguments are valid and apply defaults
% error(nargchk(2,6,nargin,'struct'));
narginchk(2,6);% fixed by CH, Oct 29, 2016


if round(n) ~= n, error(generatemsgid('MustBeInteger'),'Polynomial order (n) must be an integer.'), end
if round(dn) ~= dn, error(generatemsgid('MustBeInteger'),'Differentiation order (dn) must be an integer.'), end
if n > length(x)-1, error(generatemsgid('InvalidRange'),'The Polynomial Order must be less than the frame length.'), end
if dn > n, error(generatemsgid('InvalidRange'),'The Differentiation order must be less than or equal to the Polynomial order.'), end

% set defaults if needed
if nargin<6
    flag=false;
end
if nargin < 5 || isempty(W)
   % No weighting matrix, make W an identity
   W = eye(length(x0));
else
   % Check W is real.
   if ~isreal(W), error(generatemsgid('NotReal'),'The weight vector must be real.'),end
   % Check for right length of W
   if length(W) ~= length(x0), error(generatemsgid('InvalidDimensions'),'The weight vector must be of the same length as the frame length.'),end
   % Check to see if all elements are positive
   if min(W) <= 0, error(generatemsgid('InvalidRange'),'All the elements of the weight vector must be greater than zero.'), end
   % Diagonalize the vector to form the weighting matrix
   W = diag(W);
end
if nargin<4
    x0=0;
end
if nargin<3
    dn=0;
end

% prepare for symbolic output
if flag
    x=sym(x);
    x0=sym(x0);
end

Nx  = length(x);
x=x(:);
Nx0 = length(x0);
x0=x0(:);

if flag
    A=ones(length(x),1);
    for k=1:n
        A=[A x.^k];
    end
    df = inv(A'*A)*A';                          % backslash operator doesn't work as expected with symbolic inputs, but the "slowness and inaccuracy" of this method doesn't matter when doing the symbolic version
else
    df = cumprod([ones(Nx,1) x*ones(1,n)],2) \ eye(Nx);
end
df = df.';

hx = [(zeros(Nx0,dn)) ones(Nx0,1)*prod(1:dn)];  % order=0:dn-1,& dn,respectively
for k=1:n-dn                                    % order=dn+1:n=dn+k
    hx = [hx x0.^k*prod(dn+k:-1:k+1)];
end

% filter coeffs
fc = df*hx'*W;
end


%% ----- savitzkyGolayFilt   [AQP_gui.m lines 32018-32118] -----------------------------------------
function y=savitzkyGolayFilt(x,N,DN,F,W,DIM)
%savitzkyGolayFilt Savitzky-Golay Filtering.
%   savitzkyGolayFilt(X,N,DN,F) filters the signal X using a Savitzky-Golay 
%   (polynomial) filter.  The polynomial order, N, must be less than the
%   frame size, F, and F must be odd.  DN specifies the differentiation
%   order (DN=0 is smoothing). For a DN higher than zero, you'll have to
%   scale the output by 1/T^DN to acquire the DNth smoothed derivative of
%   input X, where T is the sampling interval. The length of the input X
%   must be >= F.  If X is a matrix, the filtering is done on the columns
%   of X.
%
%   Note that if the polynomial order N equals F-1, no smoothing
%   will occur.
%
%   savitzkyGolayFilt(X,N,DN,F,W) specifies a weighting vector W with
%   length F containing real, positive valued weights employed during the
%   least-squares minimization. If not specified, or if specified as
%   empty, W defaults to an identity matrix.
%
%   savitzkyGolayFilt(X,N,DN,F,[],DIM) or savitzkyGolayFilt(X,N,DN,F,W,DIM)
%   operates along the dimension DIM.
%
%   See also savitzkyGolay, FILTER, sgolayfilt

%   References:
%     [1] Sophocles J. Orfanidis, INTRODUCTION TO SIGNAL PROCESSING,
%              Prentice-Hall, 1995, Chapter 8.

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.4 $  $Date: 2009/08/11 15:47:54 $

% error(nargchk(4,6,nargin,'struct'));

 narginchk(4,6);% fixed by CH, Oct 29, 2016

 
 
 
% Check if the input arguments are valid
if round(F) ~= F, error(generatemsgid('MustBeInteger'),'Frame length must be an integer.'), end
if rem(F,2) ~= 1, error(generatemsgid('SignalErr'),'Frame length must be odd.'), end
if round(N) ~= N, error(generatemsgid('MustBeInteger'),'Polynomial order must be an integer.'), end
if N > F-1, error(generatemsgid('InvalidRange'),'The Polynomial order must be less than the frame length.'), end
if DN > N, error(generatemsgid('InvalidRange'),'The Differentiation order must be less than or equal to the Polynomial order.'), end

if nargin < 5 || isempty(W)
   % No weighting matrix, make W an identity
   W = ones(F,1);
else
   % Check for right length of W
   if length(W) ~= F, error(generatemsgid('InvalidDimensions'),'The weight vector must be of the same length as the frame length.'),end
   % Check to see if all elements are positive
   if min(W) <= 0, error(generatemsgid('InvalidRange'),'All the elements of the weight vector must be greater than zero.'), end
end

if nargin < 6, DIM = []; end

% Compute the projection matrix B
pp = fix(-F./2):fix(F./2);
B = savitzkyGolay(pp,N,DN,pp,W);

if ~isempty(DIM) && DIM > ndims(x)
	error(generatemsgid('InvalidDimensions'),'Dimension specified exceeds the dimensions of X.')
end

% Reshape X into the right dimension.
if isempty(DIM)
	% Work along the first non-singleton dimension
	[x, nshifts] = shiftdim(x);
else
	% Put DIM in the first dimension (this matches the order 
	% that the built-in filter function uses)
	perm = [DIM,1:DIM-1,DIM+1:ndims(x)];
	x = permute(x,perm);
end

if size(x,1) < F, error(generatemsgid('InvalidDimensions'),'The length of the input must be >= frame length.'), end

% Preallocate output
y = zeros(size(x));

% Compute the transient on (note, this is different than in sgolayfilt,
% they had an optimization leaving out some transposes that is only valid
% for DN==0)
y(1:(F+1)/2-1,:) = fliplr(B(:,(F-1)/2+2:end)).'*flipud(x(1:F,:));

% Compute the steady state output
ytemp = filter(B(:,(F-1)./2+1),1,x);
y((F+1)/2:end-(F+1)/2+1,:) = ytemp(F:end,:);

% Compute the transient off
y(end-(F+1)/2+2:end,:) = fliplr(B(:,1:(F-1)/2)).'*flipud(x(end-(F-1):end,:));

% Convert Y to the original shape of X
if isempty(DIM)
	y = shiftdim(y, -nshifts);
else
	y = ipermute(y,perm);
end
end


%% ----- search_devX1_p_value_Mahal_rPCA   [AQP_gui.m lines 32150-32225] ---------------------------
function out=search_devX1_p_value_Mahal_rPCA(range_dev_X1 , p_value_target, inp )
% search thru range_dev_X1 to find best dev_X1 that can generate p_value closest to p_value_target
%
% see also: BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix
% see also: test_Mahal_Rolling_PCA_Random_covariance_matrix
%====================================================================================

if false
    % search for p_value = 0.05
    cc
    inp.fig_yes=0;
    range_dev_X1=[1:0.1:1.5];
    inp.Nrun=10000;
    inp.bz=30;
    p_value_target=0.05;
    out=search_devX1_p_value_Mahal_rPCA(range_dev_X1 , p_value_target, inp );
%==========================================================================================
% search for p_value = 0.05
    cc
    inp.fig_yes=0;
    range_dev_X1=[1.5:0.1:2];
    inp.Nrun=10000;
    inp.bz=10;
    p_value_target=0.05;
    out=search_devX1_p_value_Mahal_rPCA(range_dev_X1 , p_value_target, inp );
%==========================================================================================
% search for p_value = 0.05
    cc
    inp.fig_yes=0;
    range_dev_X1=[1.2:0.1:1.7];
    inp.Nrun=10000;
    inp.bz=20;
    p_value_target=0.05;
    out=search_devX1_p_value_Mahal_rPCA(range_dev_X1 , p_value_target, inp );

    
end
%=======================================================================================

bz=inp.bz;
all_p_value_calc=[];
all_p_value_calc_log=[];

for idev=1:length(range_dev_X1)
    close all
    dev_X1=range_dev_X1(idev);
    [allh,allp,out_idev] = BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp );
    all_p_value_calc=[all_p_value_calc ;  out_idev.p_value_calc];
    all_p_value_calc_log=[all_p_value_calc_log ;  log(out_idev.p_value_calc)];
    disp(['idev=',num2str(dev_X1),'  ',num2str(idev),'/',num2str(length(range_dev_X1))]);
end
log_p_value_target=log(p_value_target);
% exp( log_p_value_target )
figure;hold on;
plot(range_dev_X1,all_p_value_calc_log,'b-*');
plot_hline(log_p_value_target ,'r');
%------------------------------------------
mst_ds=all_p_value_calc_log; % col vector
mg=range_dev_X1;
tg=[range_dev_X1(1):0.01:range_dev_X1(end)];
DMest = interp1_CH(mg,mst_ds,tg);
[min_diff   loc_min]=min(abs(DMest-log_p_value_target)) ;
closest_dev_X1=tg(loc_min) ;
plot_vline(closest_dev_X1 ,'g');

title_usF(['bz=',num2str(bz)]);
title_add(gca,['Est dev_X1 --> ',roundns(closest_dev_X1,2)]);
%-------------------------------------

%---------------------------------------
out.all_p_value_calc_log=all_p_value_calc_log;
out.range_dev_X1=range_dev_X1;

%-------------------------------------
done_with_this_function;
end


%% ----- seconds2human   [AQP_gui.m lines 32230-32395] ---------------------------------------------
function out = seconds2human(secs, varargin)
%SECONDS2HUMAN( seconds )   Converts the given number of seconds into a 
%                           human-readable string.
%
%   str = SECONDS2HUMAN(seconds) returns a human-readable string from a
%   given (usually large) amount of seconds. For example, 
%
%       str = seconds2human(1463456.3)
%
%       str = 
%       'About 2 weeks and 2 days.'
%
%   You may also call the function with a second input argument; either
%   'short' (the default) or 'full'. This determines the level of detail
%   returned in the string:
%
%       str = seconds2human(1463456.3, 'full')
%   
%       str =
%       '2 weeks, 2 days, 22 hours, 30 minutes, 56 seconds.'
%
%   The 'short' format returns only the two largest units of time.
%
%   [secs] may be an NxM-matrix, in which case the output is an NxM cell 
%   array of the corresponding strings. 
%
%   NOTE: SECONDS2HUMAN() defines one month as an "average" month, which 
%   means that the string 'month' indicates 30.471 days. 
%
%   See also seconds2human_CH, datestr, datenum, etime. 


% Please report bugs and inquiries to: 
%
% Name       : Rody P.S. Oldenhuis
% E-mail     : oldenhuis@gmail.com    (personal)
%              oldenhuis@luxspace.lu  (professional)
% Affiliation: LuxSpace s�rl
% Licence    : GPL + anything implied by placing it on the FEX


% If you find this work useful, please consider a donation:
% https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=6G3S5UYM7HJ3N

    % default error
%     error(nargchk(1,2,nargin));%#ok
% NARGINCHK
     narginchk(1,2);
    
    
    % define some intuitive variables
    Seconds   = round(1                 );
    Minutes   = round(60     * Seconds  ); 
    Hours     = round(60     * Minutes  );
    Days      = round(24     * Hours    ); 
    Weeks     = round(7      * Days     ); 
    Months    = round(30.471 * Days     );
    Years     = round(365.26 * Days     );
    Centuries = round(100    * Years    );
    Millennia = round(10     * Centuries);

    % put these into an array, and define associated strings
    units   = [Millennia, Centuries, Years, Months, Weeks, ...
               Days, Hours, Minutes, Seconds];
%     singles = {'millennium'; 'century'; 'year'; 'month'; ...
%                'week'; 'day'; 'hour'; 'minute'; 'second'};
%     plurals = {'millennia' ; 'centuries'; 'years'; 'months'; ...
%                'weeks'; 'days'; 'hours'; 'minutes'; 'seconds'};

           
        singles = {'millennium'; 'century'; 'year'; 'month'; ...
               'week'; 'day'; 'hr'; 'min'; 'sec'};
    plurals = {'millennia' ; 'centuries'; 'years'; 'months'; ...
               'weeks'; 'days'; 'hrs'; 'mins'; 'secs'};
       
           
           
           
           
           
    % cut off all decimals from the given number of seconds
    assert(isnumeric(secs), 'seconds2human:seconds_mustbe_numeric', ...
        'The argument ''secs'' must be a scalar or matrix.');
    secs = round(secs);   
    
    % parse second argument
    short = true; 
    if (nargin > 1)
        % extract argument
        short = varargin{1};
        % check its type
        assert(ischar(short), 'seconds2human:argument_type_incorrect', ...
            'The second argument must be either ''short'' or ''full''.');
        % check its contents
        switch lower(short)
            case 'full' , short = false;
            case 'short', short = true;
            otherwise
                error('seconds2human:short_format_incorrect',...
                    'The second argument must be either ''short'' or ''full''.');
        end
    end
    
    % pre-allocate appropriate output-type
    numstrings = numel(secs);    
    if (numstrings > 1), out = cell(size(secs)); end
    
    % build (all) output string(s)    
    for j = 1:numstrings
                
        % initialize nested loop
        secsj   = secs(j);
        counter = 0;       
        if short, string = 'About ';
        else      string = '';
        end
        
        % possibly quick exit
        if (secsj < 1), string = 'Less than one second.'; end
        
        % build string for j-th amount of seconds
        for i = 1:length(units)
            
            % amount of this unit
            amount = fix(secsj/units(i));
            
            % include this unit in the output string
            if amount > 0
                
                % increase counter
                counter = counter + 1;
                                
                % append (single or plural) unit of time to string
                if (amount > 1)
                    string = [string, num2str(amount), ' ', plurals{i}];%#ok
                else
                    string = [string, num2str(amount), ' ', singles{i}];%#ok
                end
                                
                % Finish the string after two units if short format is requested
                if (counter > 1 && short), string = [string, '.']; break, end%#ok
                
                % determine whether the ending should be a period (.) or a comma (,)
                if (rem(secsj, units(i)) > 0)
                    if short, ending = ' and ';
                    else ending = ', ';
                    end
                else ending = '.';
                end
                string = [string, ending];%#ok
                
            end
            
            % subtract this step from given amount of seconds
            secsj = secsj - amount*units(i);
        end
        
        % insert in output cell, or set output string
        if (numstrings > 1)
            out{j} = string;
        else
            out = string;
        end        
    end % for
    
end % seconds2human


%% ----- seconds2human_CH   [AQP_gui.m lines 32399-32417] ------------------------------------------
function out=seconds2human_CH(secs, varargin)
% modified from seconds2human to handle less than one second case
% and if less than one hour, always report in full
% see also seconds2human
%
if secs<1
    out=[roundns(secs,3),' sec.'];
elseif secs <= 3600
    out = seconds2human(secs, 'full');
else
    try
   out = seconds2human(secs, varargin{:}); 
    catch
     out = seconds2human(secs, varargin{:},'short'); 
      
    end
    
end
end


%% ----- show_OpmModel_figs   [AQP_gui.m lines 32937-32948] ----------------------------------------
function out=show_OpmModel_figs(inp)

aof=find_all_open_fig;
loc_NonAQPfig=find(~arrayfun(@(x) ~isempty(x.Number),aof));
aof(loc_NonAQPfig)=[];
close(aof);

 [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(inp.Path4AQPfig,'Cnt','fig');
allfig_OpmModel=cellfun(@(x) openfig(x),clistfilename_out);
 Speak_mk('all figures for Optimal Model open');
out.fignum_OpmModel_45deg=allfig_OpmModel(end);
end


%% ----- sort_nat   [AQP_gui.m lines 32982-33077] --------------------------------------------------
function [cs,index] = sort_nat(c,mode)
%sort_nat: Natural order sort of cell array of strings.
% usage:  [S,INDEX] = sort_nat(C)
%
% where,
%    C is a cell array (vector) of strings to be sorted.
%    S is C, sorted in natural order.
%    INDEX is the sort order such that S = C(INDEX);
%
% Natural order sorting sorts strings containing digits in a way such that
% the numerical value of the digits is taken into account.  It is
% especially useful for sorting file names containing index numbers with
% different numbers of digits.  Often, people will use leading zeros to get
% the right sort order, but with this function you don't have to do that.
% For example, if C = {'file1.txt','file2.txt','file10.txt'}, a normal sort
% will give you
%
%       {'file1.txt'  'file10.txt'  'file2.txt'}
%
% whereas, sort_nat will give you
%
%       {'file1.txt'  'file2.txt'  'file10.txt'}
%
% See also: sort

% Version: 1.4, 22 January 2011
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Set default value for mode if necessary.
if nargin < 2
	mode = 'ascend';
end

% Make sure mode is either 'ascend' or 'descend'.
modes = strcmpi(mode,{'ascend','descend'});
is_descend = modes(2);
if ~any(modes)
	error('sort_nat:sortDirection',...
		'sorting direction must be ''ascend'' or ''descend''.')
end

% Replace runs of digits with '0'.
c2 = regexprep(c,'\d+','0');

% Compute char version of c2 and locations of zeros.
s1 = char(c2);
z = s1 == '0';

% Extract the runs of digits and their start and end indices.
[digruns,first,last] = regexp(c,'\d+','match','start','end');

% Create matrix of numerical values of runs of digits and a matrix of the
% number of digits in each run.
num_str = length(c);
max_len = size(s1,2);
num_val = NaN(num_str,max_len);
num_dig = NaN(num_str,max_len);
for i = 1:num_str
	num_val(i,z(i,:)) = sscanf(sprintf('%s ',digruns{i}{:}),'%f');
	num_dig(i,z(i,:)) = last{i} - first{i} + 1;
end

% Find columns that have at least one non-NaN.  Make sure activecols is a
% 1-by-n vector even if n = 0.
activecols = reshape(find(~all(isnan(num_val))),1,[]);
n = length(activecols);

% Compute which columns in the composite matrix get the numbers.
numcols = activecols + (1:2:2*n);

% Compute which columns in the composite matrix get the number of digits.
ndigcols = numcols + 1;

% Compute which columns in the composite matrix get chars.
charcols = true(1,max_len + 2*n);
charcols(numcols) = false;
charcols(ndigcols) = false;

% Create and fill composite matrix, comp.
comp = zeros(num_str,max_len + 2*n);
comp(:,charcols) = double(s1);
comp(:,numcols) = num_val(:,activecols);
comp(:,ndigcols) = num_dig(:,activecols);

% Sort rows of composite matrix and use index to sort c in ascending or
% descending order, depending on mode.
[unused,index] = sortrows(comp);
if is_descend
	index = index(end:-1:1);
end
index = reshape(index,size(c));
cs = c(index);
end


%% ----- sortnat   [AQP_gui.m lines 33081-33218] ---------------------------------------------------
function [Oa,Oi,ar,nu] = sortnat(Ia,varargin)
% Customizable natural order sort (by numeric value and character order).
%
% (c) 2012 Stephen Cobeldick
%
% Sort the strings in a cell-of-strings by numeric value and character order.
%
% Syntax:
% SortedCellStr = sortnat(CellStr);
% [SortedCellStr,SortIndex] = sortnat(CellStr);
%
% By default sorts case-insensitive ascending, with integer numeric values.
% Optional inputs may be used control the format of the numeric values
% within the strings (see Tokens), case sensitivity and sort direction.
%
% See also natsort, natsortrows, natsortrows,  fdir_wildcard_wPath_sortnat SORT SORTROWS UNIQUE CELLSTR REGEXP SSCANF
%
% ### Algorithm ####
%
% This natural order sort function uses the following algorithm:
% # Use "regexp" to split strings into numeric and character tokens.
% # Parse numeric tokens using "sscanf", format is '%f' (floating point).
% # Sort tokens (from left to right along the strings) with order:
%   1. Empty tokens (i.e. shorter strings).
%   2. Numeric tokens by value.
%   3. Character tokens (i.e. ASCII order).
% # Return sorted strings and sort index.
%
% ### Tokens ###
%
% # A numeric token consists of some combination of digits, may optionally
%   include a +/- sign, decimal point, exponent, etc. The numeric tokens
%   must be able to be parsed by "sscanf" (format '%f'), and may be defined
%   by the optional input "regexp" pattern RgxN: examples are shown below:
%
%               Example RgxN  | For Numeric Tokens of Type
%   --------------------------|---------------------------------
%                       '\d+' | integer (default).
%                 '(-|+)?\d+' | integer with optional +/- sign.
%               '\d+(\.\d+)?' | integer or decimal.
%             '(-|+)\d+\.\d+' | decimal with +/- sign.
%                    '10e\d+' | exponential, base ten.
%   '[1-9]\d*|(?<=0?)0(?!\d)' | integer excluding leading zeros.
%
% # A character token is any other single character (i.e. all other
%   characters (letters) not matching regexp pattern RgxN).
%
% ### Inputs and Outputs ###
%
% # Outputs:
%   OtAr = Cell of strings, arranged in order, same size as InAr.
%   OtIx = Logical, such that OtAr = InAr(OtIx), same size as InAr.
% For debugging, where the rows are linear indexed from the input array:
%   TokS = Cell of strings, showing all numeric and character tokens.
%   NumV = Numeric, with "sscanf" parsed numeric values. NaN = non-parsed.
%
% # Inputs:
%   InAr = Cell array of strings to be sorted.
%   RgxN = String, to extract numeric tokens using "regexp", '\d+'*.
%   CsIn = Logical, true/false* -> case sensitive/insensitive (RgxN & sort).
%   AsDe = Logical, true/false* -> descending/ascending sort.
%
% An empty input [] uses the default input option value (indicated *).
%
% Outputs = [OtAr,OtIx,TokS,NumV]
% Inputs = (InAr,RgxN*,CsIn*,AsDe*)

DfAr = {'\d+',false,false}; % *{RgxN,CsIn,AsDe}
DfIx = ~cellfun('isempty',varargin);
DfAr(DfIx) = varargin(DfIx);
%
SrS = ['(',DfAr{1},')|.'];
if DfAr{2}
    [cm,ct] = regexp(reshape(Ia,1,[]),SrS,'match','tokenextents');
else
    [cm,ct] = regexpi(lower(reshape(Ia,1,[])),SrS,'match','tokenextents');
end
%
cx = cellfun('length',cm);
cy = numel(cm);
cz = max(cx);
%
nu = NaN(cy,cz);
ar = cell(cy,cz);
ei = true(cy,cz);
ni = false(cy,cz);
qo = zeros(cy,cz);
%
% Insert non-empty tokens into comparison array:
for m = find(cx>0)
    ar(m,1:cx(m)) = cm{m};
    ei(m,1:cx(m)) = false;
    ni(m,1:cx(m)) = ~cellfun('isempty',ct{m});
end
%
% Convert numeric tokens into number values:
nu(ni) = sscanf(sprintf('%s ',ar{ni}),'%f');
%
% Assign indices:
for n = 1:cz
    % Empty (shorter strings):
    qj = ei(:,n);
    if any(qj)
        qo(qj,n) = 1;
        el = sum(qj);
    else
        el = 0;
    end
    % Numeric:
    qj = ni(:,n);
    if any(qj)
        [qs,qi] = sort(nu(qj,n));
        qu = cumsum([true;qs(1:end-1)~=qs(2:end)]);
        qu(qi) = qu;
        qo(qj,n) = qu+el;
        nl = sum(qj);
    else
        nl = 0;
    end
    % Character:
    qj = ~ei(:,n) & ~ni(:,n);
    if any(qj)
        [qs,qi] = sort(ar(qj,n));
        qu = cumsum([true;~strcmp(qs(1:end-1),qs(2:end))]);
        qu(qi) = qu;
        qo(qj,n) = qu+el+nl;
    end
end
%
% Sort indices:
if DfAr{3}
    [~,Oi] = sortrows(qo,-(1:cz));
else
    [~,Oi] = sortrows(qo,+(1:cz));
end
Oi = reshape(Oi,size(Ia));
Oa = reshape(Ia(Oi),size(Ia));
end


%% ----- stdgen99   [AQP_gui.m lines 35431-35578] --------------------------------------------------
function [stdmat,stdvect] = stdgen99(spec1,spec2,window,tol,maxpc)
%STDGEN Instrument standardization transform generator
%  Generates direct or piecewise direct standardization matrix
%  with or without additive background correction based on
%  spectra from two instruments, or original calibration spectra
%  and drifted spectra from a single instrument. The inputs are
%  the original standard spectra (spec1), the spectra from the
%  instrument to be standarized (spec2) and the number of channels
%  to be used for each transform (window). If window is set to
%  0, direct standardization is used, otherwise, piecewise
%  direct standardization is used. An optional input variable,
%  (tol) adjusts the tolerance to be used in forming the local 
%  models used in piecewise direct standardization, and is equal
%  to the minimum relative size of singular values to include in
%  each model (default is 1e-2). A second optional variable (maxpc) 
%  specifies the maximum number of PCs to be retained for each
%  model. The outputs are the transform matrix (stdmat) and 
%  an optional output with the additive background correction 
%  (stdvect). If only one output argument is given, no background 
%  correction is used. See STDSSLCT for selection of
%  standardization subsets and STDIZE for standardizing new
%  spectra using an existing model.
%
%I/O: [stdmat,stdvect] = stdgen(spec1,spec2,window,tol,maxpc);
%
%See also: STDSSLCT, STDDEMO, STDFIR, STDIZE, STDGENNS, STDGENDW, MSCORR

%Copyright Eigenvector Research, Inc. 1994-98
%Modified BMW 10/95
%Modified BMW 3/98
%Modified BMW 1/99 - tolerance check

[ms,ns] = size(spec1);
[ms2,ns2] = size(spec2);
if ms ~= ms2
  error('Both spectra must have the same number of samples')
end
if ns ~= ns2
  error('Both spectra must have the same number of channels')
end
if nargin > 2
  if window ~= 0
    if floor(window/2) == window/2
      disp('  ')
      disp('The number of channels in the window should really be') 
      disp('an odd number for the channels to be properly centered')
	  disp('in the intervals.')
	  disp('  ')
	end
  end
end
if nargout == 2
  [mspec1,mns1] = mncn(spec1);
  [mspec2,mns2] = mncn(spec2);
else
  mspec1 = spec1;
  mspec2 = spec2;
end
if window == 0
  if ms <= ns
    [u,s,v] = svd(mspec2',0);
    if nargout == 2
      s = inv(s(1:ms-1,1:ms-1));
	  invs = zeros(ms,ms);
	  invs(1:ms-1,1:ms-1) = s;  
    else
      invs = inv(s);
    end
    spec2inv = u*invs*v';
  else
    spec2inv = pinv(mspec2);
  end	
  stdmat = spec2inv*mspec1;
else
  %stdmat = zeros(ns,ns);
  winm = floor(window/2)+1;
  % Diagonal index numbers
  rin = 1:ns; cin = 1:ns;
  for i = 2:winm
    % below diagonal
    rin = [rin i:ns];
    cin = [cin 1:ns-i+1];
	% above diagonal
	rin = [rin 1:ns-i+1];
	cin = [cin i:ns];
  end
  stdmat = sparse(rin,cin,zeros(size(rin)),ns,ns);
  ind1 = floor(window/2);
  ind2 = window-ind1-1;
  if (nargin < 4 | isempty(tol))
    tol = 1e-2;
	maxpc = ms;
  elseif (nargin < 5 | isempty(maxpc))
    if tol > 1
	  disp('Error in specification of tol')
	  error('Tolerance must be <= 1')
	end
    maxpc = ms;
  else	
    if maxpc > ms
	  disp('Error in specification of maxpc')
	  error('Number of PCs must be <= number of samples')
	end
  end
  for i = 1:ns
	if round(i/100) == (i/100)
      s = sprintf('Now working on channel %g out of %g.',i,ns');
      disp(s)
	end 
    if i <= ind1
      xspec2 = mspec2(:,1:i+ind2);
      wind = i+ind2;
    elseif i >= ns-ind2+1
      xspec2 = mspec2(:,i-ind1:ns);
      wind = ns-i+ind1+1;
    else
      xspec2 = mspec2(:,i-ind1:i+ind2);
      wind = window;
    end
    [u,s,v] = svd(xspec2'*xspec2);
    % For a relative tolerence use this:
    %sinds = size(find((s(1,1)*ones(wind,1))./diag(s) < (1/tol))); BMW 1/99
	sinds = size(find( diag(s)./(s(1,1)*ones(wind,1)) > tol ));
    sinds = sinds(1);
    % For an absolute tolerance use this:
    %sinds = size(find(diag(s)>tol));   
    %sinds = max([sinds(1) 1]);
	if sinds > maxpc
	  sinds = maxpc;
	end
    sinv = zeros(size(s));
    sinv(1:sinds,1:sinds) = inv(s(1:sinds,1:sinds));
    %disp(i)
    %disp([xspec2 spec1(:,i)])
    mod = u*sinv*v'*xspec2'*spec1(:,i);
    if i <= ind1
      stdmat(1:i+ind2,i) = mod;
    elseif i >= ns-ind2+1
      stdmat(i-ind1:ns,i) = mod;
    else
      stdmat(i-ind1:i+ind2,i) = mod;
    end
  end
end
if nargout == 2
  stdvect = (mns1' - stdmat'*mns2')';
end
end


%% ----- stdize99   [AQP_gui.m lines 35582-35613] --------------------------------------------------
function stdspec = stdize99(nspec,stdmat,stdvect);
%STDIZE Standardizes new spectra using previously developed transform
%  Inputs are the new spectra to be standardized (nspec),
%  the standardization matrix (stdmat) and the additive background
%  correction (stdvect). The output is the standardized spectra (stdspec).
%  The standardization matrix and background correction can be obtained
%  using the functions STDGEN, STDGENDW and STDGENNS.
%
%I/O: stdspec = stdize(nspec,stdmat,stdvect);
%
%See also: STDSSLCT, STDGEN, STDDEMO, STDGENDW, STDGENNS

%Copyright Eigenvector Research, Inc. 1997-98
%bmw 5/30/97, nbg 2/23/98,12/98

if nargin<3
  [ms,ns] = size(nspec);
  [mm,nm] = size(stdmat);
  if ns~=mm
    error('Spectrum and transfer matrix sizes not compatible')
  end
  stdspec = nspec*stdmat;
else
  [ms,ns] = size(nspec);
  [mm,nm] = size(stdmat);
  [mv,nv] = size(stdvect);
  if (ns~=mm | nm~=nv)
    error('Spectrum, transfer matrix and background vector sizes not compatible')
  end
  stdspec = nspec*stdmat + ones(ms,1)*stdvect;
end
end


%% ----- strcmp_CI   [AQP_gui.m lines 35617-35623] -------------------------------------------------
function result=strcmp_CI(str1,str2);
%Case Insensitive version of strcmp
% e.g.  strcmp_CI('good','Good')
% strcmp_CI('good','bad')

result=strcmp(lower(str1),lower(str2));
end


%% ----- strmatch_CI   [AQP_gui.m lines 35808-35812] -----------------------------------------------
function result=strmatch_CI(str,strs,varargin);
%Case Insensitive version of strmatch

result=strmatch(lower(str),lower(strs),varargin{:});
end


%% ----- strread_delimiter   [AQP_gui.m lines 35867-35885] -----------------------------------------
function cstr=strread_delimiter(str,sdelimiter)
% converting string of text into cell column, use strread and user provided delimiter
%   e.g.
%   cstr=strread_delimiter('COCL2_NH3_30RH_75RH_VALID1_U5_111306A.csv','_');
%   cstr = 
%   
%       'COCL2'
%       'NH3'
%       '30RH'
%       '75RH'
%       'VALID1'
%       'U5'
%       '111306A.csv'
%   see also   strread_delimiter_wDoubleQuote_headingCSVfile   strread_delimiter_2num

cstr=strread(str,'%s','delimiter',sdelimiter);

return;
end


%% ----- strrep_keyword_between_markers   [AQP_gui.m lines 35957-35967] ----------------------------
function out=strrep_keyword_between_markers(targetstring,marker1,marker2,str_replace)
% see also textual_replaceBetween  find_keyword_between_markers
if false
   targetstring= 'Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19_wRawSpectra_pp1-1stDer_pp2-SNV_KS-nsampT1026_wKennard-Stone_NonKS-nsampP6685.mat'
    out=strrep_keyword_between_markers(targetstring,'_ncls','_','20')
end

str_prev=find_keyword_between_markers(targetstring,marker1,marker2);

out=strrep(targetstring,[marker1,str_prev,marker2],[marker1,str_replace,marker2]);
end


%% ----- strrep_keyword_between_markers_wlistRHS   [AQP_gui.m lines 35971-36031] -------------------
function skeyword=strrep_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2,str_replace,opt)
% this is the latest and more flexible function to rename targetstring
% this can be used to remove skeyword too
% usually use 'keepBoth' to rename targetstring
% use str_replace='' and 'keepRHS' to remove skeyword
% see also textual_replaceBetween
if false
    
   targetstring= 'Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19_wRawSpectra_pp1-1stDer_pp2-SNV_KS-nsampT1026_wKennard-Stone_NonKS-nsampP6685.mat'
    out=strrep_keyword_between_markers_wlistRHS(targetstring,'_ncls',{'_'},'20','keepBoth')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      targetstring= 'Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19.mat'
    out=strrep_keyword_between_markers_wlistRHS(targetstring,'_ncls',{'_','.mat'},'20','keepBoth')
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      targetstring= 'Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19_wRawSpectra.mat'
    out=strrep_keyword_between_markers_wlistRHS(targetstring,'_ncls',{'_','.mat'},'20','keepBoth')
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use str_replace='' and 'keepRHS' to remove skeyword
      targetstring= 'Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19_wRawSpectra.mat'
    out=strrep_keyword_between_markers_wlistRHS(targetstring,'_ncls',{'_','.mat'},'','keepRHS')
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use str_replace='' and 'keepRHS' to remove skeyword
      targetstring= 'Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds__nsamp7711_ncls19.mat'
    out=strrep_keyword_between_markers_wlistRHS(targetstring,'_ncls',{'_','.mat'},'','keepRHS')

    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2))
    skeyword=targetstring;
    
else
    
   kwfound= find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2);
  marker2_used= clistmarker2{ cellfun(@(x) ~isempty(strfind(targetstring,[kwfound,x])),clistmarker2)};
    
    
    if ~exist('opt','var')
        % if opt not provided, both marker1 and marker2 will be removed
        skeyword=strrep(targetstring, [marker1,find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2),marker2_used]  ,str_replace);
        
    elseif strcmp(opt,'keepLHS')
        skeyword=strrep(targetstring, [find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2),marker2_used]  ,str_replace);
        
        
    elseif strcmp(opt,'keepRHS')
        skeyword=strrep(targetstring, [marker1,find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2)]  ,str_replace);
    
  elseif strcmp(opt,'keepBoth')
        skeyword=strrep(targetstring, [find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2)]  ,str_replace);
    
        
    else
        error('not supported opt');
        
        
        
    end
end
end


%% ----- test_Mahal_Rolling_PCA_Random_covariance_matrix   [AQP_gui.m lines 36231-36529] -----------
function [h,p,mean_sqrt_MD2_X1,mean_sqrt_MD2_X,h_alt,p_alt,out] = test_Mahal_Rolling_PCA_Random_covariance_matrix( N,dev_X1 ,inp )
% typically called by --> BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix
% create two Random_covariance_matrix: X and X1
% see also: z_score_TO_sqrt_mahal_or_MD
% see also: test_Mahal_Log_or_Not_Random_covariance_matrix
% see also: BatchRun_Mahal_Rolling_PCA_Random_covariance_matrix
% see also: generate_random_orthogonal_vectors
%===================================================================================
if false
    
   
    %-----------------------------------------------------------
     cc
    inp.fig_yes=1;
    dev_X1=0;
    [h,p] = test_Mahal_Rolling_PCA_Random_covariance_matrix( 30,dev_X1 ,inp )
     %-----------------------------------------------------------
    
     cc
    inp.fig_yes=1;
    dev_X1=2;
    [h,p] = test_Mahal_Rolling_PCA_Random_covariance_matrix( 30,dev_X1 ,inp )
      %-----------------------------------------------------------
      % test 3D !!!
       cc
       inp.nD=3;    % test 3D !!!
    inp.fig_yes=1;
    dev_X1=0;bz=30;
    [h,p] = test_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp )
      %----------------------------------------------------------- 
      % test 3D !!!
       cc
       inp.nD=3;    % test 3D !!!
    inp.fig_yes=1;
    dev_X1=3;bz=300;
    [h,p] = test_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp )
      %----------------------------------------------------------- 
     % test running ttest2 on MD2 directly
       cc
       inp.nD=2;    % 
    inp.fig_yes=1;
    dev_X1=0;bz=300;
    [h,p,~,~,h_alt,p_alt] = test_Mahal_Rolling_PCA_Random_covariance_matrix( bz,dev_X1 ,inp )
      %----------------------------------------------------------- 
      
      
      
      
      
      
      
end
%----------------------------------------------------
try
    nD=inp.nD;
catch
    nD=2;
end
try
 rand_cov_yes  = inp.rand_cov_yes;
catch
  rand_cov_yes=1;  
end
%====================================================

switch nD
    case 2
        % Random covariance matrix
        % create two Random_covariance_matrix: X and X1
        if rand_cov_yes
        t=rand(1)*pi;
        else
        t=1*pi;
        end
        U=[cos(t) -sin(t);sin(t) cos(t)];
        %============================================
        % check whether U is % orthogonal
        if false
            U(1,:)*U(2,:)'  % check whether U is % orthogonal
        end
        %============================================
         if rand_cov_yes
         Co=U*diag(rand(1,2))*U';
         else
         Co=U*diag([1 1])*U';
         end
        % Random samples
        N=round(max(N,10));
        X=mvnrnd([0 0],repmat(Co,[1 1 N]));% create two Random_covariance_matrix: X and X1
    case 3
        [v1, v2, v3] = generate_random_orthogonal_vectors();
        U=transpose([v1,v2,v3]);
         Co=U*diag(rand(1,3))*U';
        % Random samples
        N=round(max(N,10));
        X=mvnrnd([0 0 0],repmat(Co,[1 1 N]));% create two Random_covariance_matrix: X and X1
end
% Random samples
% N=round(max(N,10));
% X=mvnrnd([0 0],repmat(Co,[1 1 N]));% create two Random_covariance_matrix: X and X1
%------------------------
switch nD
    case 2
        % create two Random_covariance_matrix: X and X1
        if rand_cov_yes
            t1=rand(1)*pi;
        else
            t1=1*pi;
        end
        U1=[cos(t1) -sin(t1);sin(t1) cos(t1)];
         if rand_cov_yes
         Co1=U1*diag(rand(1,2))*U1';
         else
         Co1=U1*diag([1 1])*U1';
         end
        % X1=mvnrnd([1 0],repmat(Co1,[1 1 N]));% create two Random_covariance_matrix: X and X1
        X1=mvnrnd([dev_X1 0],repmat(Co1,[1 1 N]));% create two Random_covariance_matrix: X and X1
        %-----------------------------------------------------------------------------------
    case 3
        [v1_1, v2_1, v3_1] = generate_random_orthogonal_vectors();
        U1=transpose([v1_1,v2_1,v3_1]);
        Co1=U1*diag(rand(1,3))*U1';
        % Random samples
        X1=mvnrnd([dev_X1 0 0],repmat(Co1,[1 1 N]));% create two Random_covariance_matrix: X and X1
        %-----------------------------------------------------------------------------------
end
%------------------------

if inp.fig_yes
    
  switch nD
    case 2  
figure;hold on;set(gcf,'position',[  33.9552  415.0896  560.2388  420.5373  ]);
plot(X(:,1),X(:,2),'b*');
plot(X1(:,1),X1(:,2),'r>');
      case 3
figure;hold on;set(gcf,'position',[  33.9552  415.0896  560.2388  420.5373  ]);
plot3(X(:,1),X(:,2),X(:,3),'b*');
plot3(X1(:,1),X1(:,2),X1(:,3),'r>');
  end


end
%------------------------------------------------------
% load examgrades
% x = grades(:,1);
% y = grades(:,2);
% Test the null hypothesis that the two data vectors are from populations with equal means, without assuming that the populations also have equal variances.

% [h,p] = ttest2(x,y,'Vartype','unequal')

MD2_X=mahal(X,X);
MD2_X1=mahal(X1,X);

sqrt_MD2_X=sqrt(MD2_X);
mean_sqrt_MD2_X=mean(sqrt_MD2_X );

sqrt_MD2_X1=sqrt(MD2_X1);
mean_sqrt_MD2_X1=mean(sqrt_MD2_X1 );

if inp.fig_yes

figure;hold on;set(gcf,'position',[597.0597  414.3731  560.2388  420.5373 ]);
[hist_MD2_X  md_hist_MD2_X]=hist(MD2_X,10);
[hist_MD2_X1  md_hist_MD2_X1]=hist(MD2_X1,10);
stem(md_hist_MD2_X,hist_MD2_X,'color','b');
stem(md_hist_MD2_X1,hist_MD2_X1,'color','r');
ylabel('number of occurances of MD2');xlabel('MD2');

end
%------------------------------------------
log_MD2_X=log( MD2_X);
log_MD2_X1=log( MD2_X1);
if inp.fig_yes
    figure;hold on;set(gcf,'position',1000*[  1.1609    0.4137    0.5602    0.4205 ]);
    [hist_log_MD2_X  md_hist_log_MD2_X]=hist(log_MD2_X,10);
    [hist_log_MD2_X1 md_hist_log_MD2_X1]=hist(log_MD2_X1,10);
    
    stem(md_hist_log_MD2_X, hist_log_MD2_X,'color','b');
    stem(md_hist_log_MD2_X1,hist_log_MD2_X1,'color','r');
    ylabel('number of occurances of log(MD2)');xlabel('log(MD2)');
end
%===================================================================================================
%  H=0 indicates that the null hypothesis ("means are equal") cannot be rejected at the 5% significance level.
%  or  H=0 indicates that null hypothesis ("means are equal") Confirmed at the 5% significance level.
% [h,p] = ttest2(log_MD2_X,log_MD2_X1,'Vartype','unequal');
[h,p] = ttest2(log_MD2_X,log_MD2_X1,'Vartype','unequal', 'tail','left' );  %  'left'  "mean of X is less than mean of Y (or X1)" (left-tailed test)
%===================================================================================================
% test running ttest2 on MD2 directly, i.e. without log
[h_alt,p_alt] = ttest2(MD2_X,MD2_X1,'Vartype','unequal', 'tail','left' );  %  'left'  "mean of X is less than mean of Y (or X1)" (left-tailed test)
%===================================================================================================
 % one of current settings in rPCA
    % Feb 2, 2024
    if false
        MD=2.8;df=3;            %
        p=MD_TO_p_value(MD,df)
        %--------------------
        mean(sqrt(MD2_X1))
        
    end
    
mean_sqrt_MD2_XP = mean(sqrt(MD2_X1))  ;
if  mean_sqrt_MD2_XP>2.7 &&  mean_sqrt_MD2_XP<2.9
    out.mean_sqrt_MD2_XP=mean_sqrt_MD2_XP;
else
    out.mean_sqrt_MD2_XP=NaN;
end

%===================================================================================================

return
%===============================================================
% D2 = mahal(Y,X) returns the Mahalanobis distance (in squared units) of
%     each observation (point) in Y from the sample data in X
% Y=[1 1];
% D2 = mahal(Y,X);
% MD=sqrt(D2);

mahal_X=mahal(X,X);   % same as mahal
% MD_X=sqrt(mahal_X);   % same as sqrt_mahal
%--------------------------------------------------
% nu=2;
% p_chi = chi2cdf( 2^2 , nu ) ;
% 1-p_chi
% 
% p_chi = chi2cdf( 3^2 , nu ) ;
% 1-p_chi

nu=2;   % number of PC
p_chi = chi2cdf( mahal_X , nu ) ;
figure;hold on;
chi2_MD=sort(sqrt(mahal_X));
chi2_p=1-sort(p_chi);
plot(chi2_MD,chi2_p,'b*');
z1=1;
z2=2;
[min_chi2_MD_z1  loc_chi2_MD_z1]=min(abs(chi2_MD-z1));
p_chi2_z1=chi2_p(loc_chi2_MD_z1 );
sp_chi2_z1=['p_value_chi2_z1 = ',roundns(p_chi2_z1,3)]; 

[min_chi2_MD_z2  loc_chi2_MD_z2]=min(abs(chi2_MD-z2));
p_chi2_z2=chi2_p(loc_chi2_MD_z2 );
sp_chi2_z2=['p_value_chi2_z2 = ',roundns(p_chi2_z2,3)]; 

z3=3;
[min_chi2_MD_z3  loc_chi2_MD_z3]=min(abs(chi2_MD-z3));
p_chi2_z3=chi2_p(loc_chi2_MD_z3 );
sp_chi2_z3=['p_value_chi2_z3 = ',roundns(p_chi2_z3,3)]; 
scolor_all_z='orm';
all_z=[z1,z2,z3];
all_p_chi2=[p_chi2_z1, p_chi2_z2,p_chi2_z3];

for iz=1:length(all_z)
    z_score=all_z(iz);
    plot_vline(z_score,scolor_all_z(iz));
    plot(z_score,all_p_chi2(iz),'marker','O','color',color_CH( scolor_all_z(iz)), 'markerfacecolor',color_CH( scolor_all_z(iz)) );
end

xlabel(usF('chi2_MD'));
ylabel(usF('chi2_p'));
title('chi2cdf');
title_add(gca,sp_chi2_z1);
title_add(gca,sp_chi2_z2);title_add(gca,sp_chi2_z3);
%-------------------------
% X_chi2 = chi2inv(1-z_score_TO_p_value( 2 ),nu)
 X_chi2 = sqrt(chi2inv(1-0.607,nu))
 X_chi2 = sqrt(chi2inv(1-0.135,nu))
 X_chi2 = sqrt(chi2inv(1-0.011,nu))
%-------------------------------------
% X_chi2_norm_z2 = sqrt(chi2inv(1-z_score_TO_p_value( 2 ),nu));
X_chi2_norm_z2 = z_score_TO_sqrt_mahal_or_MD(2,nu);
plot(X_chi2_norm_z2,z_score_TO_p_value( 2 ),'marker',marker_CH('p'),'color',color_CH( 'c'), 'markerfacecolor',color_CH( 'c'),'markersize',12 );
sX_chi2_norm_z2=['MD to have p_value of z=2 in norm (i.e. ',roundns( z_score_TO_p_value( 2 ),3),') --> ',roundns(X_chi2_norm_z2,3 ) ];
title_add(gca,sX_chi2_norm_z2);

%==========================================================
sqrt_mahal_X=sqrt(mahal_X);   % same as sqrt_mahal
stit=['sqrt mahal'];
all_z=[1 2 3];
plot_hist_MD_etc(sqrt_mahal_X,stit,all_z ,N);

%===============================================================
auto_MD_X =  auto(sqrt_mahal_X);
stit=['auto sqrt mahal'];
 all_z=[1];
plot_hist_MD_etc(auto_MD_X,stit,all_z ,N);
%===============================================================
log_sqrt_MD_X=log(sqrt(mahal_X));
stit=['log sqrt mahal'];
 all_z=[1];
plot_hist_MD_etc(log_sqrt_MD_X,stit,all_z ,N);
%===============================================================
auto_log_sqrt_MD_X =  auto(log_sqrt_MD_X);
stit=['auto log sqrt mahal'];
 all_z=[1];
plot_hist_MD_etc(auto_log_sqrt_MD_X,stit,all_z ,N);
%-----------------------
done_with_this_function;
end


%% ----- plot_hist_MD_etc   [AQP_gui.m lines 36532-36555] ------------------------------------------
function plot_hist_MD_etc(MDetc,stit,all_z ,N)
scolor_all_z='orm';
figure;hold on;
hist(MDetc,100);title([stit,'  N=',num2str(N)]);
% mean_auto_log_sqrt_MD_X  =  mean(MDetc);
% std_auto_log_sqrt_MD_X  =  std(MDetc);
all_p_simu=[];
for iz=1:length(all_z)
    z_score=all_z(iz);
    % z_score_auto_log_sqrt_MD_1=mean_auto_log_sqrt_MD_X+z_score*std_auto_log_sqrt_MD_X;
    z_score_auto_log_sqrt_MD_1=z_score;
    p_simu_1=length(find(MDetc>z_score_auto_log_sqrt_MD_1))/N;
    all_p_simu=[all_p_simu, p_simu_1 ];
    plot_vline(z_score_auto_log_sqrt_MD_1,scolor_all_z(iz));
end
hp_mean_MD=plot_vline(mean(MDetc),'a');
legend(hp_mean_MD,{['mean of ',stit]});
for iz=1:length(all_z)
title_add(gca,['p_value at z=',num2str(z_score),' simulated = ',num2str(all_p_simu(iz))]);
end
title_add(gca,['mean of ',stit,' = ',roundns(mean(MDetc),2)]);
xlabel(stit);
ylabel('number of occurances');
end


%% ----- textual_eraseAfter_wo_kw1   [AQP_gui.m lines 36559-36604] ---------------------------------
function out=textual_eraseAfter_wo_kw1(cstr,kw1)
%-------------------------------------------------------------------------------
% function : textual_eraseAfter(cstr,kw1)
% if cstr is char or cell with size of 1, 
% output (or out) should have same datatype as input (or cstr)
% 
% can not handle the case that cstr is cell and some of them are empty
% while some of them are not
% see also textual_replaceBetween_multiple_kw2
if false
    
    cstr={'abc_ncls5.mat';'AABB_ncls777';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_eraseAfter_wo_kw1(cstr,'ncls')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_cls5.mat'}
    out=textual_eraseAfter_wo_kw1(cstr,'ncls')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr='abc_cls5.mat'
    out=textual_eraseAfter_wo_kw1(cstr,'ncls')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat'}
    out=textual_eraseAfter_wo_kw1(cstr,'ncls')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr='abc_ncls5.mat'
    out=textual_eraseAfter_wo_kw1(cstr,'ncls')
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


out=textual_replaceBetween_multiple_kw2(cstr,kw1,{''},'');
% can not handle the case that cstr is cell and some of them are empty
% while some of them are not
if iscell(out)&&length(out)==1
    out=out{1};
    out=strrep(out,kw1,'');
    if iscell(cstr)&&~isempty(out)
       out={out}; 
    end
else
    out=strrep(out,kw1,'');
end
if isempty(out)
    out=cstr;
end
end


%% ----- textual_eraseBetween_rmkw1   [AQP_gui.m lines 36608-36752] --------------------------------
function out=textual_eraseBetween_rmkw1(cstr,kw1,kw2)
%===================================================================
% function textual_eraseBetween_rmkw1(cstr,kw1,kw2)
% use string array to erase Between two keywords and remove kw1 too
% this will handle cell of str and str end with ".mat" etc
% if input cstr is char, out will be char too
% if nothing found, nothing will be erased
% this will handle the case that kw2='' or end of str
% see also textual_extractBetween  textual_replaceBetween  find_keyword_between_markers_wlistRHS  strrep_keyword_between_markers_wlistRHS strrep_keyword_between_markers
%===================================================================
if false
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1 (and last entry will be empty output)
    cstr={'Atrainpketc_ABC_DEF_pp1-SGw5_nsamp231_nsampP222.mat';'Atrainpketc_xhr_pp1-1stDer_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT123_nsampP22.mat';};
    out=textual_eraseBetween_rmkw1(cstr,'_pp1-','_')
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1
    cstr='Atrainpketc_ABC_DEF_pp1-SGw5_nsamp231_nsampP222.mat';
    out=textual_eraseBetween_rmkw1(cstr,'_pp1-','_')

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1
    cstr='Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';
    out=textual_eraseBetween_rmkw1(cstr,'_pp1-','_')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with pp1
    cstr='Atrainpketc_ABC_DEF_nsamp231_nsampP222_pp1-SGw5.mat';
    out=textual_eraseBetween_rmkw1(cstr,'_pp1-','_')

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nvar119.mat'};
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if input cstr is char, out will be char too
    cstr='Atrainpketc_ABC_DEF_nsamp231_nvar119.mat';
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if input cstr is char, out will be char too
    cstr='Atrainpketc_ABC_DEF_nsamp231.mat';
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','_')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nvar119.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125.mat'};
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % deal with kw2 missing (e.g. at end of str)
    cstr={'Atrainpketc_ABC_DEF_nsamp23.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_ncls3.mat';'Atrainpketc_ABC_DEF_nsamp31.csv';};
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % deal with kw2 missing (e.g. at end of str) and kw1 missing
    cstr={'Atrainpketc_ABC_DEF.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_ncls3.mat';'Atrainpketc_ABC_DEF_nsamp31.csv';};
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp111_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp122_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp123_nsampT111_nsampP22.mat';};
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT111_nsampP22.mat';};
    out=textual_eraseBetween_rmkw1(cstr,'_nsampP','_')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT121.mat';};
    out=textual_eraseBetween_rmkw1(cstr,'_nsampP','_')
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with mixed with "_nsamp","_nsampP", and "_nsampT"
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_xhr_brtc_nsamp12_nvar125_nsampT111.mat';'Atrainpketc_ABC_DEF_nsamp231_nsampT123_nsampP22.mat';};
    out=textual_eraseBetween_rmkw1(cstr,'_nsampT','_')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal kw2 --> end of filename
    cstr={'Atrainpketc_ABC_DEF_nsamp231_nsampP222.mat';'Atrainpketc_ABC_vbc_nsamp123.mat'};
    out=textual_eraseBetween_rmkw1(cstr,'_nsamp','')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 cstr={'Sample 146_1';'Sample 146_10';'Sample 147_1'};
 out=textual_eraseBetween_rmkw1(cstr,'_','')
    

    
    


    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sia_cstr=string(cstr);

siaOut=sia_cstr;
sia_Aft=extractAfter(sia_cstr,kw1);


if ~isempty(kw2)

    sia_Aft_Bef=extractBefore(sia_Aft,kw2);
    
    idx_NotFound=isnan(strlength(sia_Aft_Bef));
    idx_NotFound_wo_kw1=~contains(sia_cstr,kw1);
    idx_NotFound_w_kw1=idx_NotFound & ~idx_NotFound_wo_kw1;
    
    idx_Found=~isnan(strlength(sia_Aft_Bef));
    
    siaOut_Found=eraseBetween(sia_cstr(idx_Found),kw1,kw2);
    siaOut_Found=erase(siaOut_Found,kw1);  % erase kw1 too (this should be applied on siaOut_Found)
    
    siaOut(idx_Found)=siaOut_Found;
    
    if any(idx_NotFound)
        siaOut_NotFound_w_kw1=eraseBetween(sia_cstr(idx_NotFound_w_kw1),kw1,'.');% assume missing kw2 were because end with ".mat" etc
        siaOut_NotFound_w_kw1=erase(siaOut_NotFound_w_kw1,kw1);% erase kw1 too (this should be applied on siaOut_NotFound_w_kw1)
        siaOut(idx_NotFound_w_kw1)=siaOut_NotFound_w_kw1;
        
        
        if any(idx_NotFound_wo_kw1)   % deal with the case that no "kw1" can be found
            siaOut(idx_NotFound_wo_kw1) =sia_cstr(idx_NotFound_wo_kw1);% deal with the case that no "kw1" can be found
        end
    end
%     out=siaOut.cellstr;
%     if ischar(cstr)&& ~isempty(out)
%         out=out{1};
%     end
else
    ToBeErased=kw1+sia_Aft;
        % for some reason, the following will Not work for cstr={'Sample 146_1';'Sample 146_10';'Sample 147_1'};
       % siaOut=erase(siaOut,ToBeErased);  % erase kw1 too (this should be applied on siaOut_Found)
        siaOut=strrep(siaOut,ToBeErased,'');  % erase kw1 too (this should be applied on siaOut_Found)

    
end

out=siaOut.cellstr;
    if ischar(cstr)&& ~isempty(out)
        out=out{1};
    end
end


%% ----- textual_replaceBetween_multiple_kw2   [AQP_gui.m lines 37204-37305] -----------------------
function out=textual_replaceBetween_multiple_kw2(cstr,kw1,ckw2,str_new)
%-------------------------------------------------------------------------------
% function : textual_replaceBetween_multiple_kw2(cstr,kw1,ckw2,str_new)
%
% find shortest extraction between kw1 and each of ckw2 
% then replace by str_new
%
% can handle empty entry in ckw2 now, empty kw2 will be treated as "end of str"
%
% out is same data type as cstr, i.e. is cstr is cell, out is cell, 
% if cstr is char vector, out is char vector too
% 
% if both kw2 and str_new are empty, this work same as "eraseAfter"
% 
% see also textual_eraseAfter  strrep_vs_replace_vs_textual_replaceBetween_multiple_kw2
if false
    
    cstr={'abc_ncls5.mat';'def_ncls7_nsamp32.mat';'def_ncls9_nsamp223.mat';'fadfas_ncls_nsamp2356.mat'}
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'.','_'},'111')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cstr={'abc_ncls5.mat','def_ncls7_nsamp32.mat','def_ncls9_nsamp223.mat','fadfas_ncls_nsamp2356.mat'}
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'.','_','nsamp'},'111')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat';'def_ncls7_nsamp32.mat';'def_ncls9_nsamp223.mat';'fadfas_ncls nsamp-2356.mat'}
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'.','_','-'},'111')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat';'def_ncls7(_Unit-S1-221).mat';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'_','.','('},'111')
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abc_ncls5.mat';'def_ncls7(_Unit-S1-221).mat';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'_','.','('},'') % remove section Between kw1 and ckw2
   
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following can handle empty kw2 now
    cstr={'abc_ncls5.mat';'AABB_ncls777';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'_','.',''},'111')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% the following can handle empty kw2 and when str_new is empty, this can be
% used to work like "eraseAfter"
    cstr={'abc_ncls5.mat';'AABB_ncls777';'def_ncls9_nsamp223.mat';'fadfas_ncls231'}
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{''},'')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % test when cstr is char vector
    cstr='def_ncls7(_Unit-S1-221).mat';
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'_','.','('},'111') % remove section Between kw1 and ckw2

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % test when cstr is cell
    cstr={'def_ncls7(_Unit-S1-221).mat'};
    out=textual_replaceBetween_multiple_kw2(cstr,'_ncls',{'_','.','('},'111') % remove section Between kw1 and ckw2



end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

sia_out_NE=replaceBetween(col_always(sia(idx_NOTempty_kw2)),kw1,ckw2_match(idx_NOTempty_kw2),str_new);

sia_out_E=extractBefore(col_always(sia(~idx_NOTempty_kw2)),kw1)+kw1+str_new;
sia_out=sia;
sia_out(idx_NOTempty_kw2)=sia_out_NE;
sia_out(~idx_NOTempty_kw2)=sia_out_E;


out=cellstr(sia_out);
out=reshape(out,size(cstr));
try
if ischar(cstr_orig)
    out=out{1};
end
end
end


%% ----- title_add   [AQP_gui.m lines 37317-37406] -------------------------------------------------
function title_add(hgca,cstr)
% see also: title_add_GAIS (newer and better approach that can be convert to Python by using --> set(htit,'string',ctit  ,  'Interpreter', 'none'  )   )
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% if there is any full path exist, e.g. C:\~ , this will disable the usF operation, very tricky !!!
% if there is any full path exist, e.g. C:\~ , this will disable the usF operation, very tricky !!!
% if there is any full path exist, e.g. C:\~ , this will disable the usF operation, very tricky !!!
% you can try to use strrep(ctit_full_path,'\','-') to fix that
% or better try to fix by --> strrep(ctit_full_path,'\','/') , Apr 4, 2024
%--------------------------------------------------------------------
% add new cstr to the title of axes -> hgca
% cstr can be string or cell
% see also:  title_usF   underscoreFix   usF  underscore_related
% or better try to fix by --> strrep(ctit_full_path,'\','/') , Apr 4, 2024
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% see also: title_add_GAIS (newer and better approach that can be convert to Python by using --> set(htit,'string',ctit  ,  'Interpreter', 'none'  )   )
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-------------------------------------------------------------------------------------------
if false
    
    figure;
    title_add(gca,'this is a test');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    title_add(gca,pwd);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    title_add(gca,{'this is a test Three';'this is a test Four'}) ;
    %========================================================
    
    cc
    figure;
    title_add(gca,pwd);
    title_add('test_with_usF');
    %========================================================
    
    cc
    figure;
%     title_usF('test_with_usF');
    title_add(gca,pwd)
     %========================================================
    
    cc
    figure;
%     title_usF('test_with_usF');
     title('test_with_usF');

    title_add(gca,pwd) 
  %========================================================
    % revisit Apr 14, 2024
    cc
    figure;
    title_usF(pwd);
    title_add(gca,'test_with_usF');
    %========================================================
    % revisit Apr 14, 2024
    cc
    figure;
    title_usF('test_with_usF');
    title_add(gca,pwd);
    %========================================================  
    cc
    figure;
    title_usF('C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_U2U_AclabelT-ClsName_Un\nTU5');
     
end
%==============================================================================================
% cstr=strrep(cstr,'\','/');% or better try to fix by --> strrep(ctit_full_path,'\','/') , Apr 4, 2024
%-----------------------------------------------------
htit=get(hgca,'title');
if ischar(cstr)
    cstr={cstr};
elseif iscell(cstr)
    cstr=cstr;
else
    error('cstr must be cell or string')
end
ctit=[get(htit,'string');cstr];
%=================================================================
% since already did following at shortcut --> ML_jdsu_woPLStoolbox
% % following will avoid the issue with usF etc
% set(0, 'DefaultTextInterpreter', 'none');
% now this will just run with regular title
% see also: set_XTickLabel
%----------------------------------------------------
% if false
    ctit=underscoreFix(ctit);% see also: underscoreFix
% end
%==========================================================
% set(0, 'DefaultTextInterpreter', 'none');   % somehow need to rerun this, even though it has been setup to run during startup : ML_jdsu_woPLStoolbox ?

set(htit,'string',ctit);
end


%% ----- title_usF   [AQP_gui.m lines 37410-37482] -------------------------------------------------
function title_usF(ctit)
% since already did following at shortcut --> ML_jdsu_woPLStoolbox
% % following will avoid the issue with usF etc
% set(0, 'DefaultTextInterpreter', 'none');
% now this will just run with regular title
% see also: set_XTickLabel
%---------------------------------------------------
% if there is any full path exist, e.g. C:\~ , this will disable the usF operation, very tricky !!!
% if there is any full path exist, e.g. C:\~ , this will disable the usF operation, very tricky !!!
% if there is any full path exist, e.g. C:\~ , this will disable the usF operation, very tricky !!!
% you can try to use strrep(ctit_full_path,'\','-') to fix that
% or better try to fix by --> strrep(ctit_full_path,'\','/') , Apr 4, 2024
%--------------------------------------------------------------------
% OR title_usF(strrep(find_lastNfolder(path_Results,3),'\','_'));
% see diagnose_misP_iACPmp , May 30, 2023
%========================================================================
% add new cstr to the title of axes -> hgca
% cstr can be string or cell
% see also:  title_add  underscoreFix  usF  underscore_related
%==================================================================
% or better try to fix by --> strrep(ctit_full_path,'\','/') , Apr 4, 2024
%-------------------------------------------------------------------------------------------
if false

    cc
    figure;
    title_usF('this is a test') ;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    cc
    figure;
    title_usF('this_is_a_test') ;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cc
    figure;
    title_usF({'this_is_a_test';'afda_1232'}) ;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cc
    figure;
%     title_usF({'this_is_a_test';'afda_1232' ; 'afda\_1232'  ; 'afda\\_1232'}) ;
    title_usF({pwd;'this_is_a_test';'afda_1232' ; 'afda\_1232'  ; 'afda\\_1232'}) ;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cc
    figure;
     title_usF({'this_is_a_test';'afda_1232' ; 'afda\_1232'  ; 'afda\\_1232'}) ;
%     title({'this_is_a_test';'afda_1232' ; 'afda\_1232'  ; 'afda\\_1232'}) ;



end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if false
    % ctit=strrep(ctit,'\','/');% or better try to fix by --> strrep(ctit_full_path,'\','/') , Apr 4, 2024
    %----------------------------------------------------
    htit=get(gca,'title');
    if ischar(ctit)
        ctit={ctit};
    elseif iscell(ctit)
        ctit=ctit;
    else
        error('cstr must be cell or string')
    end
    % ctit=[get(htit,'string');cstr];
    ctit=underscoreFix(ctit);% see also: underscoreFix
    % if there is any full path exist, e.g. C:\~ , this will disable the usF operation, very tricky !!!
    %
    set(htit,'string',ctit);
end


%% ----- tmp_folder_rm_mk   [AQP_gui.m lines 37492-37583] ------------------------------------------
function Path_tmpfolder=tmp_folder_rm_mk(tmpfolder,parentfolder,inp)
% created by merge SFV of tmp_folder_rm_mk, Aug 1, 2025
%-----------------------------------------------------------------
% function Path_tmpfolder=tmp_folder_rm_mk(tmpfolder,parentfolder)
% create new tmpfolder under parentfolder, 
%
% this delete all files inside DESTINATION (but keep contents of all subfolders), if they already exist
% this delete all files inside DESTINATION (but keep contents of all subfolders), if they already exist
% this delete all files inside DESTINATION (but keep contents of all subfolders), if they already exist
%
%-----------------------------------------------------------------------------------------------------------------------------
% e.g. Path_tmpfolder=tmp_folder_rm_mk('test1',pwd)
% if inp.quiet exist and set to one, it will not disp additional info(added by Chang Hsiung, Sept 17, 2014)
% 
%============================================================================

warning off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cnt=0;
max_cnt=10;
Path_tmpfolder=[parentfolder,'\',tmpfolder];

while ~exist(Path_tmpfolder,'dir')
    cnt=cnt+1;
    try
        rmdir(Path_tmpfolder,'s');
    end
    
    if ~exist(Path_tmpfolder,'dir')
        
        
        if exist(Path_tmpfolder,'file')
            %try to delete Path_tmpfolder as a FILE (NOT directory)
            % otherwise it may cause tmpfolder NOT able to be created !!!
            try
                delete(Path_tmpfolder);  %try to delete Path_tmpfolder as a FILE (NOT directory)
            end
        end
        
        try
            mkdir(Path_tmpfolder);
        end
    end
    
    if cnt >1
        tmp_folder_rm_mk__disp_with_border(['try ',num2str(cnt),' times to create ',Path_tmpfolder]);
    else
        
        
        
        try
            if inp.quiet
                
            else
                tmp_folder_rm_mk__disp_with_border([Path_tmpfolder,' has been created']);
            end
        catch
            tmp_folder_rm_mk__disp_with_border([Path_tmpfolder,' has been created']);
            
        end
        
        
        
        
    end
    if exist(Path_tmpfolder,'dir')
        return;
    end
    if cnt>max_cnt
        disp(['try ',num2str(max_cnt),' and give up']);
        return;
    end
end

if exist(Path_tmpfolder,'dir')
    % if this folder already exist, then delete all files from it, but not subfolder(s)
    delete_cstrFile_tmpFolder(Path_tmpfolder);
    try
        if inp.quiet
            
        else
            tmp_folder_rm_mk__disp_with_border([Path_tmpfolder,' originally already exist, now delete all files (not include subfolders) from it']);
        end
    catch
        tmp_folder_rm_mk__disp_with_border([Path_tmpfolder,' originally already exist, now delete all files (not include subfolders) from it']);
        
    end
end
%===================================================
warning on
end


%% ----- tmp_folder_rm_mk__fdir_wildcard   [AQP_gui.m lines 37586-37613] ---------------------------
function [clistfilename, nfile]=tmp_folder_rm_mk__fdir_wildcard(targetPathname,keyword_inside_wildcards,inp)
% similar to fdir but use wildcard to find all file with certain keywords
% if no "*" found in keyword_inside_wildcards, it will use ['*',keyword_inside_wildcards,'*']
% see also wfdir(alias) , fdir , fdir_wPath  , fdir_wildcard_wPath

% e.g. fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','svm')
% e.g.inp.fullpath_yes=1; fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','svm',inp)
% e.g. fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','*svm*zip')
% e.g. fdir_wildcard('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','*svm*mht')
% e.g. fdir_wildcard_wPath('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','*svm*mht')

prev_dir=pwd;
cd (targetPathname);

if isempty(strfind(keyword_inside_wildcards,'*'))
SAlist=dir(['*',keyword_inside_wildcards,'*']);
else
SAlist=dir([keyword_inside_wildcards]);
end

clistfilename=arrayfun(@(x) x.name,SAlist,'uniformoutput',false);
cd (prev_dir);
nfile=length(clistfilename);

 if exist('inp','var') && isfield(inp,'fullpath_yes') && inp.fullpath_yes==1
   clistfilename=cellfun(@(x) [targetPathname,'\',x],clistfilename,'uniformoutput',false);
 end
end


%% ----- tmp_folder_rm_mk__fdir_wildcard_wPath   [AQP_gui.m lines 37616-37650] ---------------------
function [clistfilename, nfile]=tmp_folder_rm_mk__fdir_wildcard_wPath(targetPathname,keyword_inside_wildcards)
% similar to fdir but use wildcard to find all file with certain keywords
% IF keyword_inside_wildcards is EMPTY, find all files in the folder and exclude parents folder/files;

% see also fdir_wildcard_wPath_sortnat wfdir_wPath (alias) ,  fdir, fdir_wildcard, fdir_wPath

% e.g. fdir_wildcard_wPath('C:\work\Mfiles\ALL_Utility_mfiles\MatlabCentral_attic','svm')
% see also: recursiveDir  example_recursiveDir
% see also: fdir_wildcard_ext_wPath (most popular one)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false

 [clistfilename, nfile]=tmp_folder_rm_mk__fdir_wildcard_wPath('C:\work\Bidgely\dkPublic\Public\ML\datawithTemp','');

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(keyword_inside_wildcards)
    [clistfilename, nfile]=tmp_folder_rm_mk__fdir_wildcard(targetPathname,keyword_inside_wildcards);
        clistfilename=cellfun(@(x) [targetPathname,'\',x],clistfilename,'uniformoutput',false);

    loc_NOTParents=cellfun(@(x) tmp_folder_rm_mk__isNOTParentFolders(x),clistfilename);
    
    clistfilename=clistfilename(loc_NOTParents);
    nfile=length(clistfilename);
    disp('since keyword_inside_wildcards is EMPTY, find all files in the folder and exclude parents folder/files');
    
    
else
    [clistfilename, nfile]=tmp_folder_rm_mk__fdir_wildcard(targetPathname,keyword_inside_wildcards);
    
    
    clistfilename=cellfun(@(x) [targetPathname,'\',x],clistfilename,'uniformoutput',false);
    
end
end


%% ----- tmp_folder_rm_mk__isNOTParentFolders   [AQP_gui.m lines 37653-37661] ----------------------
function out=tmp_folder_rm_mk__isNOTParentFolders(x)

if ~strcmp(tmp_folder_rm_mk__fileparts_name_ext(x),'.') && ~strcmp(tmp_folder_rm_mk__fileparts_name_ext(x),'..')
    out=true;
else
    out=false;
    
end
end


%% ----- tmp_folder_rm_mk__regexp_extract_mk1_mk2   [AQP_gui.m lines 37664-37892] ------------------
function out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
% renamed from regexp_extract_mk1_mk2_alt2 (June 10, 2025)
% extract an alphanumeric or special characters string between two marker strings; mk1 and mk2
% only extract one string
% can deal with mk2 is a cell, for this case Only extract numerical digits (Note: code actually extracts any chars based on (.*?))
% also deal with "empty end" case (see --> example #8c) , for this case Only extract numerical digits (Note: code actually extracts any chars based on (.*?))
% MODIFIED: Handles mk2='' ( ischar Not cell ) to extract from mk1 to end of targetstring, see --> example # 10
% MODIFIED: Handles mk1='' (ischar Not cell ) to extract from beginning of targetstring to mk2 , see --> example # 11
% see --> example # 12 : deal with  extraction of string between begin of targetstring to mk2 by setting mk1='' and mk2 is a cell !!! in this case program should return the shortest extraction
%-----------------------------------------------------
% by Gemini
% expression = [marker1 '(.*?)' marker2];
% Note that to leave a blank space between marker1 and '(.*?)' also between '(.*?)'  and marker2
% (This comment might be about general regex construction; the code concatenates directly)
% .: Matches any character (except newline).
% *: Matches the preceding character zero or more times.
% ?: Makes the * quantifier "lazy" (non-greedy). This is important to ensure it matches the shortest possible string between marker1 and marker2. Without ?, it would match all the way to the last marker2 in the string.
%  do NOT use '(.+?)'  this will cause code to crash when nothing to be extracted (e.g. in example #5 ) !!!
%---------------------------------------------------------
% Final fix by Google AI Studio wrt examples 9 - 11
%----------------------------------------------------------
% see also: regexp_PP_scheme_SGFL
%=========================================================
if false
        %---------------------------------------------------------------------
    % example #1
    tmp_folder_rm_mk__cc
    targetstring='SMV[pwCos]' ;  mk1='[' ;  mk2=']' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %---------------------------------------------------------------------
    % example #2
    tmp_folder_rm_mk__cc
    targetstring='SMV[Corr]' ;  mk1='[' ;  mk2=']' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #3
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(5){ApdCls-N6_S3_T-103_P-600}_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='Atrainpketc_' ;  mk2='_nvar' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #4

    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(5){ApdCls-N6_S3_T-103_P-600}_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='ncls' ;  mk2='_' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)

 %---------------------------------------------------------------------

    % example #5
    % when there is nothing in between
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(){ApdCls-N6_S3_T-103_P-600}_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2=')' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #6
    % when there are more than one matched patterns only extract the first one
    %
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(abc){ApdCls-N6_S3_T-103_P-600}_(345)_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2=')' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %---------------------------------------------------------------------

    % example #7
    % when there are more than one matched patterns only extract the first one
    %
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2=')' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %---------------------------------------------------------------------

    % example #7a
    % when there are more than one matched patterns only extract the first one
    %
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345abc){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT355_nsampP373.mat' ;  
    mk1='(' ;  mk2={ ')' };
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)

    %------------------------------------------------------------------------------------------------------------------------------------------
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    % example #8a
    % when there are more than one ending matched patterns i.e. mk2 is a cell
    %  % Captures one or more digits (like '123')
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT355.mat' ;  
    mk1='nsampT' ;  mk2={'_','.mat' };
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %+++++++++++++++++++++++++++++++++++++
    % example #8b  % Captures one or more digits (like '123')
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT3556_others.mat' ;  
    mk1='nsampT' ;  mk2={'_','.mat' };
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    %+++++++++++++++++++++++++++++++++++++
    % example #8c    % Captures one or more digits (like '123')
    % deal with "empty end" case
    % when none of cmk2 can be found it will extract to the very end of  targetstring
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600}_(abc)_nvar119_ncls8_nsampT1234567890' ;  % deal with "empty end" case
    mk1='nsampT' ;  mk2={'_','.mat'};
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
 %+++++++++++++++++++++++++++++++++++++
    % example #9a : deal with extracted string is alphanumeric + special characters
    %
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234567890.mat' ;  % deal with "empty end" case
    mk1='_T-' ;  mk2={'_','.mat'};
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    % hope the program to return '103-4a' 

 %+++++++++++++++++++++++++++++++++++++
    % example #9b : deal with extracted string is alphanumeric + special characters
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-600-v3.mat' ;  
    mk1='_P-' ;  mk2={'_','.mat'};
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
% hope the program to return '600-v3' 
 %+++++++++++++++++++++++++++++++++++++
    % example #9c : deal with extracted string is alphanumeric + special characters
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103_P-A12-v3' ;  
    mk1='_P-' ;  mk2={'_','.mat'};
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
% hope the program to return 'A12-v3' 
 %+++++++++++++++++++++++++++++++++++++
    % example #9d  : deal with extracted string is alphanumeric + special characters
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234567890.mat' ;  % deal with "empty end" case
    mk1='Atrainpketc_';  mk2={'_','.mat'};
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2)
    
    % hope the program to return '(345){ApdCls-N6' 
   %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % ... (examples 1-9d remain the same) ...

    % example # 10   
    % deal with  extraction of string between mk1 to end of targetstring by setting mk2='' 
    % hope the program to return 'nvar119_ncls8_nsampT1234'
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234' ;  % deal with  mk1 to end of string by setting mk2='' ;
    mk1='(abc)_';  mk2='' ;
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2) % This should now work with the modification
   %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % example # 11   
    % deal with  extraction of string between begin of targetstring to mk2 by setting mk1='' 
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234' ;  
    mk1='';  mk2='_(abc)'; % MODIFIED mk1 to be '' as per feature description
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2) % This should now work with the modification
    % hope the program to return 'Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}'

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % example # 12  
    % deal with  extraction of string between begin of targetstring to mk2 by setting mk1='' 
    % and mk2 is a cell !!! in this case program should return the shortest extraction
    %
    tmp_folder_rm_mk__cc
    targetstring='Atrainpketc_(345){ApdCls-N6_S3_T-103-4a_P-600}_(abc)_nvar119_ncls8_nsampT1234' ;  
    mk1='';  mk2={'_(abc)','_(345)'}; % MODIFIED mk1 to be '' as per feature description
    out=tmp_folder_rm_mk__regexp_extract_mk1_mk2(targetstring,mk1,mk2) % This should now work with the modification
    % hope the program to return 'Atrainpketc'

    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

end   % end of examples

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Determine the pattern for the start marker (mk1)
if isempty(mk1)
    processed_mk1_pattern = '^'; % Anchor to the beginning of the string if mk1 is empty
else
    processed_mk1_pattern = regexptranslate("escape", mk1);
end

if ischar(mk2) || isempty(mk2)
    % str_tag1 was here, now using processed_mk1_pattern
    if isempty(mk2)
        % If mk2 is an empty string, extract from mk1 (or beginning) to the end of targetstring.
        % Use (.*) for greedy matching to the end.
        expression = [processed_mk1_pattern '(.*)'];
    else
        % Original behavior for non-empty mk2.
        str_tag2 = regexptranslate("escape", mk2);
        expression = [processed_mk1_pattern '(.*?)' str_tag2];
    end
    cout = regexp(targetstring, expression, 'tokens', 'once');
    % Original assignment: will error if cout is empty (no match for pattern).
    % This is kept for "minimal change" if that implies preserving original error modes.
    % If cout is {''}, out becomes '', which is correct for cases like ex #5.
    if isempty(cout)
        out='';
    else
        out = cout{1};
    end
elseif iscell(mk2)
    % cmarker2=mk2; % This variable is not used in the Google AI Studio fix part.
    % Final fix by Google AI Studio wrt examples 9a - 9d
    % Uses processed_mk1_pattern instead of direct regexptranslate('escape', mk1)
    extracted_content = regexp(targetstring, ...
                               [processed_mk1_pattern ...    % Escaped start marker or '^'
                                '(.*?)' ...                          % Capture any characters, non-greedy
                                '(?:' ...                            % Start of non-capturing group for terminators
                                  strjoin([ ...
                                      cellfun(@(m) regexptranslate('escape', m), mk2(~cellfun('isempty', mk2)), 'UniformOutput', false), ... % Valid, escaped mk2 alternatives
                                      {'$'} ...                      % Add end-of-string as a mandatory alternative terminator
                                  ], '|') ...                        % Join all terminator patterns with OR
                                ')' ...                              % End of non-capturing group (required - Change 2)
                               ], 'tokens', 'once');
    % Original assignment: will error if extracted_content is empty (no match).
    out = extracted_content{1};
else
    error('mk2 should be either char or cell');
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
end % end of function --> regexp_extract_mk1_mk2_alt


%% ----- delete_cstrFile_tmpFolder   [AQP_gui.m lines 37895-37900] ---------------------------------
function delete_cstrFile_tmpFolder(Path_tmpfolder)
% delete all files from Path_tmpfolder, , but not subfolder(s)
    clistfile=tmp_folder_rm_mk__fdir_wildcard_wPath(Path_tmpfolder,'*');

cellfun(@(x) delete_fileONLY(x),clistfile);
end


%% ----- delete_fileONLY   [AQP_gui.m lines 37903-37913] -------------------------------------------
function delete_fileONLY(x)
fkw=tmp_folder_rm_mk__regexp_extract_mk1_mk2(x,'\','');


if strcmp(x,'.') || strcmp(x,'..') || strcmp(fkw,'.') || strcmp(fkw,'..')
%     disp('cont wo delete');
else
    delete(x);
    
end
end


%% ----- tmp_folder_rm_mk__disp_with_border   [AQP_gui.m lines 37916-37945] ------------------------
function out=tmp_folder_rm_mk__disp_with_border(str_to_show)
% updated May 8, 2020 with "out"
% updated with padding with '+' , June 3, 2025
%=========================================================
if false
    
 tmp_folder_rm_mk__disp_with_border('this is a test');
 %%%%%%%%%%%%%%%%%%%%
 out=tmp_folder_rm_mk__disp_with_border('this is a test');
 out
 
 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nedge=10;
ns=length(str_to_show);
% ub=repmat('!',[1,ns+nedge*2]);
ub=repmat('+',[1,ns+nedge*2]);                  % updated with padding with '+' , June 3, 2025

ls=repmat(' ',[1,nedge]);

% ls(1:2)='**';
ls(1:2)='';                                                    % updated with padding with '+' , June 3, 2025

as=fliplr(ls);
disp(ub);
disp([ls,str_to_show,as]);
disp(ub);
out=str_to_show;
end


%% ----- tmp_folder_rm_mk__fileparts_name_ext   [AQP_gui.m lines 37948-37966] ----------------------
function filename= tmp_folder_rm_mk__fileparts_name_ext(file)
% modified by Chang to handle the case when file is cell of str
% June 24, 2016
if iscell(file)
    cfilename=[];
    for ifile=1:length(file)
        [~,NAME,EXT]=fileparts(file{ifile});
        cfilename=[cfilename;{[NAME,EXT]}];
    end
    filename=cfilename;
    
elseif ischar(file)
    [~,NAME,EXT]=fileparts(file);
    filename=[NAME,EXT];
    
else
    error('input file should be cell of str or str')
end
end


%% ----- tmp_folder_rm_mk__cc   [AQP_gui.m lines 37969-37975] --------------------------------------
function [] = tmp_folder_rm_mk__cc()
%CC Full Clear / Complete Clear
%   Because I'm too lazy to type clear;close all;clc every damn time
evalin('base','clear');
close all;
clc
end


%% ----- uicellect   [AQP_gui.m lines 37979-38299] -------------------------------------------------
function [theChosen, theChosenIDX] = uicellect(theCell, varargin)
%------------------------------------------------------
% see changes made --> ( for Run_Populate_PRV_gui , July 6, 2023 )
%=================================================================================
% UICELLECT Present dialogue for selecting cells from a cell array
%
%  USAGE: [theChosen, theChosenIDX] = uicellect(theCell, varargin)
%
%  OUTPUT
%	  theChosen:     cell array of chosen items (empty if none chosen)
%	  theChosenIDX:  idx to input cell array of choices
%
% ________________________________________________________________________________________
%  INPUTS
%	  theCell:  cell array of items to choose from
%
% ________________________________________________________________________________________
%  VARARGIN (partial matches OK; run without arguments to see default values)
% | NAME            | DEFAULT       
% |-----------------|---------------------------------------------------------------------
% | Prompt          | message to present to user at top of gui
% | MultiSelect     | if true (or 1), user allowed to select multiple items           
% | MaxPerColumn    | max items per column (if more than # of items, one column layout)
% | RowPixelHeight  | height of gui rows (one item per row/column), in pixels     
% | ColPixelWidth   | width of gui columns, in pixels        
% | BaseFontSize    | base font size (used for item labels)  
% | hAlign          | gui horizontal alignment, can be: middle,top,upper,bottom,lower
% | vAlign          | gui vertical alignment, can be: center, left, right
% | BackgroundColor | gui background color             
% | ForegroundColor | gui foreground color
%
% ________________________________________________________________________________________
%  EXAMPLES
%----------------------------------%
% this has been used in CabXferLite for picking analyte to analyze when
% "LoadMst" was pushed
% see inside --> function LoadMst_Callback(hObject, eventdata, handles)
%=============================================================================
if false
%   % - Create a length 25 cell array of Items
   theCell = cellfun(@sprintf,repmat({'Item %d'},25,1), num2cell((1:25)'),'Unif',false);
%   % - Present in GUI using Default Settings
   [theChosen, theChosenIDX] = uicellect(theCell); 
%   % - Present in GUI and disable Multi-Selection
   [theChosen, theChosenIDX] = uicellect(theCell, 'Multi', 0); 
%----------------------------------------------------   
% for picking anaylte in CabXferLite
theCell={'Brix';'Pol';'OtherSugarIngredient'};
   [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 0); 
theChosenAna
%===================================================
theCell={'Brix';'Pol'};
   [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 0); 
theChosenAna
%===================================================
theCell={'Brix';'Pol';'Protein';'THC'};
   [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 0); 
theChosenAna
%----------------------------------------------------
%   % - Present in GUI but Change How it Looks
%   when 'MaxPer' larger than half of # of items and less than total # of
%   items, the results are the same, compare the following two examples

   [theChosen, theChosenIDX] = uicellect(theCell,'MaxPer',13,'RowPix',35,'ColPix',150); 

   [theChosen, theChosenIDX] = uicellect(theCell,'MaxPer',12,'RowPix',35,'ColPix',150); 
%
%----------------------------------------------------
% for AQP and AQPlite, Feb2, 2020
theCell_1P=cellstr("1stDerSGFL"+[5:2:13]'+"[PO2]"+"{PRO}")  ;
theCell_2P=cellstr("2ndDerSGFL"+[5:2:13]'+"[PO2]"+"{PRO}")  ;

theCell_1=cellstr("1stDerSGFL"+[5:2:13]'+"[PO2]")  ;
theCell_2=cellstr("2ndDerSGFL"+[5:2:13]'+"[PO2]")  ;

theCell_CH={'SGw5';'2ndDerSGFL9[PO3]'};

theCell=[theCell_1P;theCell_2P;theCell_1;theCell_2;theCell_CH];
 
   [theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 0,'MaxPerColumn',5); 
theChosenAna
%-------------------------------------------------------------------------------
% for LocalAuto study, Mar 12, 2023
cc
pfn='C:\work\JDSU\Test_ACP\LocalAutoscaling_study\ATetc_ResinKits_popular_polymers\Atrainpketc_{T-ES-553_P-OS-145}_Cmp_SVM_ILM_nvar121_ncls10_nsampT300_nsampP302_wPopularNames.mat' ;
L=load(pfn);
theCell=L.clistclslabel;
[theChosenAna, theChosenIDX] = uicellect(theCell, 'Multi', 1,'MaxPerColumn',5);
theChosenAna

%=================================================================================================
end  % end of if false
% ----------------------------- Copyright (C) 2015 Bob Spunt -----------------------------
%	Created:  2015-08-23
%	Email:     spunt@caltech.edu
% 
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or (at
%   your option) any later version.
%       This program is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
%       You should have received a copy of the GNU General Public License
%   along with this program.  If not, see: http://www.gnu.org/licenses/.
% ________________________________________________________________________________________

% | Defaults for VARARGIN
%
% original def:
% def = { ... 
%       'Prompt',           'Select from the following:',	...
%       'MultiSelect',      true, ...
%       'MaxPerColumn',     10, ...
%       'RowPixelHeight',   40, ...
%       'ColPixelWidth',    300, ...
%       'BaseFontSize',     14, ...
%       'hAlign',           'center', ...
%       'vAlign',           'middle', ...
%       'BackgroundColor',  [20/255 23/255 24/255], ...
%       'ForegroundColor',  [1 1 1] ...
% 	};
% ----------------------------------------------------------------
% new def modified by CH to fit CabXferLite()
def = { ... 
      'Prompt',           'Select from the following:',	...
      'MultiSelect',      true, ...
      'MaxPerColumn',     10, ...
      'RowPixelHeight',   100, ...  %changed from 40 --> 60 --> 100 ( for Run_Populate_PRV_gui , July 6, 2023 )
      'ColPixelWidth',    500, ...  % changed from 300 --> 500      ( for Run_Populate_PRV_gui , July 6, 2023 )
      'BaseFontSize',     14, ...
      'hAlign',           'center', ...
      'vAlign',           'middle', ...
      'BackgroundColor',  [20/255 23/255 24/255], ...
      'ForegroundColor',  [1 1 1] ...
	};
% ----------------------------------------------------------------

% | Update values for VARARGIN where necessary
vals = setargs(def, varargin);

% | Check arguments
if nargin < 1, mfile_showhelp; fprintf('\t| - VARARGIN DEFAULTS - |\n'); disp(vals); return; end
nopt = length(theCell);
if nopt > MaxPerColumn
    ncol = ceil(nopt/MaxPerColumn);
    nrow = ceil(nopt/ncol); 
else
    ncol = 1; 
    nrow = nopt; 
end

% | Calculate Figure Position
uiW       = ColPixelWidth*ncol;
uiH       = RowPixelHeight*nrow;
% figpos    = align_figure(uiW, uiH, vAlign, hAlign);
%   figpos    = [10,50, uiW, uiH];% modified by CH
  figpos    = [500,300, uiW, uiH];% modified by CMH, July 6, 2023


% | Make Figure
fige      =  figure( ...
    'Name'                     ,        'UICELLECT'         ,...
    'Units'                    ,        'pix'               ,...
    'Position'                 ,        figpos              ,...
    'Resize'                   ,        'on'                ,...
    'Color'                    ,        BackgroundColor     ,...
    'NumberTitle'              ,        'off'               ,...
    'DockControls'             ,        'off'               ,...
    'MenuBar'                  ,        'none'              ,...
    'Toolbar'                  ,        'none'              ,...
    'Tag'                      ,        'uicellect dialogue',...
    'WindowStyle'              ,        'normal'            ,...
    'UserData'                 ,        1);
                    

% | Use PGRID to create UIPANEL layout
pbase = pgrid(3, 1, ...
    'margin', .01, ...
    'panelsep', .025, ...
    'parent', fige, ...
    'relheight', [1 nrow 1], ...
    'backg', BackgroundColor, ...
    'foreg', ForegroundColor); 

% | UPPER UIPANEL:  PROMPT
% 'FontSize' below has been modified by CH, originally was BaseFontSize*1.25
% 
ht  =  uicontrol( ...
               'Style'   ,     'text'                                 ,...
              'Parent'   ,     pbase(1)                               ,...
                 'Tag'   ,     'Prompt'                               ,...
              'String'   ,     Prompt                                 ,...
               'Units'   ,     'normalized'                           ,...
            'Position'   ,     [0 0 1 1]                              ,...
     'BackgroundColor'   ,     BackgroundColor                        ,...
     'ForegroundColor'   ,     ForegroundColor                        ,...
               'Value'   ,     0                                      ,...
 'HorizontalAlignment'   ,     'left'                                 ,...
              'Enable'   ,     'on'                                   ,...
           'FontAngle'   ,     'normal'                               ,...
            'FontName'   ,     'fixed-width'                          ,...
            'FontSize'   ,     BaseFontSize*1.5                      ,...   % changed from 0.8 --> 1.5    ( for Run_Populate_PRV_gui , July 6, 2023 )
           'FontUnits'   ,     'points'                               ,...
          'FontWeight'   ,     'normal'                                ...
                    );

% | MIDDLE UIPANELS:  CELL ITEMS
[popt, pidx] = pgrid(nrow, ncol, 'parent', pbase(2), 'backg', BackgroundColor, 'foreg', ForegroundColor);

% | Re-arrange so that cols are traversed first 
pidx(:,3) = 1:length(popt);
pidx      = sortrows(pidx,2); 
popt      = popt(pidx(:,3)); 
set(pbase(2), 'bordertype', 'line');

% | Create UICONTROl for each CELL
if MultiSelect
    theItemCallback = '';
else
    theItemCallback = {@cb_changeselection, pbase(2)};  
end
for i = 1:nopt
    opth(i)  =  uicontrol( ...
                   'Style'   ,     'check'                                ,...
                  'Parent'   ,     popt(i)                                ,...
                     'Tag'   ,     'opt'                                  ,...
                  'String'   ,      theCell{i}                            ,...
                   'Units'   ,     'normalized'                           ,...
                'Position'   ,     [0 0 1 1]                              ,...
         'BackgroundColor'   ,     BackgroundColor                        ,...
         'ForegroundColor'   ,     ForegroundColor                        ,...
                   'Value'   ,     0                                      ,...
     'HorizontalAlignment'   ,     'center'                               ,...
                  'Enable'   ,     'on'                                   ,...
           'TooltipString'   ,     ''                                     ,...
                'Callback'   ,     theItemCallback                        ,...
               'FontAngle'   ,     'normal'                               ,...
                'FontName'   ,     'fixed-width'                          ,...
                'FontSize'   ,     BaseFontSize*1.5                           ,...  % changed from 0.8 --> 1.5   ( for Run_Populate_PRV_gui , July 6, 2023 )
               'FontUnits'   ,     'points'                               ,...
              'FontWeight'   ,     'normal'                               ,...
                'UserData'   ,     MultiSelect                            ,...
                 'Visible'   ,     'on');
     drawnow; 
end
     
% | LOWER UIPANELS:  PUSH BUTTONS
pui = pgrid(1, ncol+1, 'parent', pbase(3), 'backg', BackgroundColor, 'foreg', ForegroundColor); 

% | Select All
if MultiSelect
    htog  =  uicontrol( ...
                   'Style'   ,     'toggle'                               ,...
                  'Parent'   ,     pui(end-1)                             ,...
                     'Tag'   ,     'toggle'                               ,...
                  'String'   ,     'Select All'                           ,...
                   'Units'   ,     'normalized'                           ,...
                'Position'   ,     [.05 0 .90 1]                          ,...
         'BackgroundColor'   ,     ForegroundColor                        ,...
         'ForegroundColor'   ,     BackgroundColor                        ,...
                   'Value'   ,     0                                      ,...
     'HorizontalAlignment'   ,     'center'                               ,...
                  'Enable'   ,     'on'                                   ,...
           'TooltipString'   ,     ''                                     ,...
                'Callback'   ,     ''                                     ,...
               'FontAngle'   ,     'normal'                               ,...
                'FontName'   ,     'fixed-width'                          ,...
                'FontSize'   ,     BaseFontSize*1.5                      ,...      % changed from 0.8 --> 1.5   ( for Run_Populate_PRV_gui , July 6, 2023 )
               'FontUnits'   ,     'points'                               ,...
              'FontWeight'   ,     'bold'                                 ,...
                'UserData'   ,     []                                     ,...
                 'Visible'   ,     'on'                                    ...
                        );
end

% | FINISH
hok  =  uicontrol( ...
               'Style'   ,     'push'                                 ,...
              'Parent'   ,     pui(end)                               ,...
                 'Tag'   ,     'okbutton'                             ,...
              'String'   ,     'FINISH'                               ,...
               'Units'   ,     'normalized'                           ,...
            'Position'   ,     [.05 0 .90 1]                          ,...
     'BackgroundColor'   ,     BackgroundColor                        ,...
     'ForegroundColor'   ,     ForegroundColor                        ,...
               'Value'   ,     0                                      ,...
 'HorizontalAlignment'   ,     'center'                               ,...
              'Enable'   ,     'on'                                   ,...
       'TooltipString'   ,     ''                                     ,...
            'Callback'   ,     ''                                     ,...
           'FontAngle'   ,     'normal'                               ,...
            'FontName'   ,     'fixed-width'                          ,...
            'FontSize'   ,     BaseFontSize*1.5                       ,...              % changed from 0.8 --> 1.5   ( for Run_Populate_PRV_gui , July 6, 2023 )
           'FontUnits'   ,     'points'                               ,...
          'FontWeight'   ,     'bold'                                 ,...
            'UserData'   ,     []                                     ,...
             'Visible'   ,     'on'                                    ...
                    );

% | FINISH UP
set(fige, 'CloseRequestFcn', {@cb_closefig, fige, 0})
if MultiSelect, set(htog, 'Callback', {@cb_selectall, opth}); end
set(hok, 'Callback', {@cb_closefig, fige, 1})
drawnow
uiwait(fige)
theChosen       = [];
theChosenIDX    = []; 
if ishandle(fige)
    if get(fige, 'UserData')
        idx = cell2mat(get(opth, 'Value'));
        if any(idx)
            str = get(opth, 'string');
            theChosen       = str(find(idx));
            theChosenIDX    = find(idx);
        end
    end
    delete(fige)
end
end


%% ----- pgrid   [AQP_gui.m lines 38305-38390] -----------------------------------------------------
function [ph, pidx] = pgrid(nrow, ncol, varargin)
% PGRID Create a grid of of UIPANELs
%
%  USAGE: [phandle, pidx] = pgrid(nrow, ncol, varargin)
%
%  OUTPUT
%   hpanel: array of handles to uipanels comprising the grid
%   hidx:   [row,col] indices for the returned uipanel handles
% ________________________________________________________________________________________
%  INPUTS
%   nrow:   number of rows in grid
%   ncol:   number of cols in grid
% ________________________________________________________________________________________
%  VARARGIN
% | NAME            | DEFAULT       | DESCRIPTION 
% |-----------------|---------------|-----------------------------------------------------
% | parent          | gcf           | parent object for grid 
% | relwidth        | ones(1, ncol) | relative width of columns (arbitrary units)            
% | relheight       | ones(1, nrow) | relative height of rows (arbitrary units)            
% | marginsep       | 0.0100        | size of margin surrounding grid (normalized units)           
% | panelsep        | 0.0100        | size of space between panels (normalized units)            
% | backgroundcolor | [.08 .09 .09] | uipanel background color             
% | foregroundColor | [.97 .97 .97] | uipanel foreground color
% | bordertype      | 'none'        | etchedin, etchedout, beveledin, beveledout, line 
% | borderwidth     | 1             | uipanel border width in pixels
% ________________________________________________________________________________________
%

% ----------------------------- Copyright (C) 2015 Bob Spunt -----------------------------
%	Created:  2015-08-23
%	Email:     spunt@caltech.edu
% ________________________________________________________________________________________

% | Defaults for VARARGIN
def = { ...
'parent',              []                                   ,...
'relwidth',            []                                   ,...
'relheight',		   []                                   ,...
'marginsep',          .01                                   ,...
'panelsep',           .01                                   ,...
'backgroundcolor',    [20/255 23/255 24/255]                ,...
'foregroundcolor',    [248/255 248/255 248/255]             ,...
'bordertype',         'none'                                ,...
'borderwidth',         1                                     ...
};

% | Update values for VARARGIN where necessary
vals = setargs(def, varargin);

% | Check arguments
if nargin < 2, mfile_showhelp; return; end
if isempty(parent), parent          = gcf; end
if isempty(relwidth), relwidth      = ones(1, ncol); end
if isempty(relheight), relheight    = ones(1, nrow); end
if length(relwidth)~=ncol, printmsg('Length of RELWIDTH must equal NCOL. Try again!'); ph = []; pidx = []; return; end
if length(relheight)~=nrow, printmsg('Length of RELHEIGHT must equal NROW. Try again!'); ph = []; pidx = []; return; end

% | Get normalized positions for each panel 
pos         = getpositions(relwidth, relheight, marginsep, panelsep);
pidx        = pos(:,1:2);
hpos        = pos(:,3:end);

% | pgrid loop
npanel      = size(hpos, 1);
ph     = gobjects(npanel, 1);
for i = 1:npanel
    ph(i)  =  uipanel( ...
                  'Parent'   ,     parent                                 ,...
                   'Units'   ,     'normalized'                           ,...
                     'Tag'   ,     sprintf('[%d] x [%d]', pidx(i,:))        ,...
                   'Title'   ,     ''                                     ,...
           'TitlePosition'   ,     'centertop'                            ,...
                'Position'   ,     hpos(i,:)                              ,...
         'BackgroundColor'   ,     backgroundcolor                        ,...
         'ForegroundColor'   ,     foregroundcolor                        ,...
              'BorderType'   ,     bordertype                             ,...
             'BorderWidth'   ,     borderwidth                            ,...
                'UserData'   ,     pidx(i,:)                              ,...
                 'Visible'   ,     'off'                                   ...
                            );
end

% | Make Visible
for i = 1:npanel, set(ph(i), 'visible', 'on'); drawnow; end

end


%% ----- getpositions   [AQP_gui.m lines 38391-38425] ----------------------------------------------
function pos        = getpositions(relwidth, relheight, marginsep, uicontrolsep, top2bottomidx)
if nargin<2, relheight = [6 7]; end
if nargin<3, marginsep = .025; end
if nargin<4, uicontrolsep = .01; end
if nargin<5, top2bottomidx = 1; end
if size(relheight,1) > 1, relheight = relheight'; end
if size(relwidth, 1) > 1, relwidth = relwidth'; end
ncol        = length(relwidth);
nrow        = length(relheight); 
if top2bottomidx, relheight = relheight(end:-1:1); end

% width
rowwidth    = 1-(marginsep*2)-(uicontrolsep*(ncol-1));  
uiwidths    = (relwidth/sum(relwidth))*rowwidth;
allsep      = [marginsep repmat(uicontrolsep, 1, ncol-1)];
uilefts     = ([0 cumsum(uiwidths(1:end-1))]) + cumsum(allsep); 

% height
colheight   = 1-(marginsep*2)-(uicontrolsep*(nrow-1));
uiheights   = (relheight/sum(relheight))*colheight;
allsep      = [marginsep repmat(uicontrolsep, 1, nrow-1)];
uibottoms   = ([0 cumsum(uiheights(1:end-1))]) + cumsum(allsep);
if top2bottomidx, uiheights = uiheights(end:-1:1); end
if top2bottomidx, uibottoms = uibottoms(end:-1:1); end

% combine
pos = zeros(ncol*nrow, 6);
pos(:,1) = reshape(repmat(nrow:-1:1, ncol, 1), size(pos,1), 1);
pos(:,2) = reshape(repmat(1:ncol, 1, nrow), size(pos,1), 1);
pos(:,3) = uilefts(pos(:,2)); 
pos(:,4) = uibottoms(pos(:,1)); 
pos(:,5) = uiwidths(pos(:,2)); 
pos(:,6) = uiheights(pos(:,1));
pos      = sortrows(pos, 1);
end


%% ----- setargs   [AQP_gui.m lines 38426-38449] ---------------------------------------------------
function argstruct  = setargs(defaults, optargs)
% SETARGS Name/value parsing and assignment of varargin with default values
if nargin < 1, mfile_showhelp; return; end
if nargin < 2, optargs = []; end
defaults = reshape(defaults, 2, length(defaults)/2)'; 
if ~isempty(optargs)
    if mod(length(optargs), 2)
        error('Optional inputs must be entered as Name, Value pairs, e.g., myfunction(''name'', value)'); 
    end
    arg = reshape(optargs, 2, length(optargs)/2)';
    for i = 1:size(arg,1)
       idx = strncmpi(defaults(:,1), arg{i,1}, length(arg{i,1}));
       if sum(idx) > 1
           error(['Input "%s" matches multiple valid inputs:' repmat('  %s', 1, sum(idx))], arg{i,1}, defaults{idx, 1});
       elseif ~any(idx)
           error('Input "%s" does not match a valid input.', arg{i,1});
       else
           defaults{idx,2} = arg{i,2};
       end  
    end
end
for i = 1:size(defaults,1), assignin('caller', defaults{i,1}, defaults{i,2}); end
if nargout>0, argstruct = cell2struct(defaults(:,2), defaults(:,1)); end
end


%% ----- cb_closefig   [AQP_gui.m lines 38476-38479] -----------------------------------------------
function cb_closefig(varargin)
  set(varargin{3}, 'UserData', varargin{4});
  uiresume(varargin{3})
end


%% ----- cb_selectall   [AQP_gui.m lines 38480-38496] ----------------------------------------------
function cb_selectall(varargin)
h = varargin{3}; 
if get(varargin{1}, 'Value')
    for i = 1:length(h)
        set(h, 'Value', 1);
        drawnow; 
    end
    set(varargin{1}, 'String', 'De-Select All'); 
else
    for i = 1:length(h)
        set(h, 'Value', 0);
        drawnow; 
    end
    set(varargin{1}, 'String', 'Select All'); 
end
drawnow
end


%% ----- cb_changeselection   [AQP_gui.m lines 38497-38503] ----------------------------------------
function cb_changeselection(varargin)
    cval    = get(varargin{1}, 'value'); 
    h       = findall(varargin{3}, 'tag', 'opt');
    set(h, 'value', 0);
    set(varargin{1}, 'value', cval); 
    drawnow; 
end


%% ----- mfile_showhelp   [AQP_gui.m lines 38504-38509] --------------------------------------------
function mfile_showhelp(varargin)
% MFILE_SHOWHELP
ST = dbstack('-completenames');
if isempty(ST), fprintf('\nYou must call this within a function\n\n'); return; end
eval(sprintf('help %s', ST(2).file));
end


%% ----- underscoreFix   [AQP_gui.m lines 38513-38543] ---------------------------------------------
function out = underscoreFix(str)
%UNDERSCOREFIX Escapes underscores and corrects backslashes for MATLAB titles.
%
%   out = underscoreFix(str)
%
%   This function prepares a string, or a cell array of strings, for use
%   in MATLAB plots (e.g., titles, labels) where the TeX interpreter is
%   active. It performs two main operations:
%   1. Escapes underscores ('_') by converting them to '\_'.
%   2. Replaces any backslashes ('\') that are NOT part of an escape
%      sequence with forward slashes ('/'). This is useful for
%      displaying Windows-style file paths correctly.
%
%   The function correctly handles character vectors and cell arrays.

%   Modern, standalone version created by Gemini.
%   This version is self-contained and uses a local helper function for
%   clarity and robustness, avoiding the errors of previous versions.

if ischar(str)
    out = clean_string(str);
elseif iscell(str)
    % Apply the cleaning function to every element of the cell array
    out = cellfun(@(c) clean_string(c), str, 'UniformOutput', false);
elseif isempty(str)
    out = str;
else
    error('Input must be a character vector, a cell array of strings, or empty.');
end

end


%% ----- clean_string   [AQP_gui.m lines 38546-38595] ----------------------------------------------
function s_out = clean_string(s_in)
% This function contains the core logic for cleaning a single string.
% It is a local function, visible only within this M-file.

% If the input isn't a string or is empty, return it immediately.
if ~ischar(s_in) || isempty(s_in)
    s_out = s_in;
    return;
end

% Step 1: Perform the primary underscore escape.
s = strrep(s_in, '_', '\_');

% Step 2: Recursively collapse any existing double backslashes ('\\')
% into single backslashes ('\'). This handles pre-escaped file paths.
s_before_collapse = s;
s_after_collapse = strrep(s_before_collapse, '\\', '\');
while ~strcmp(s_before_collapse, s_after_collapse)
    s_before_collapse = s_after_collapse;
    s_after_collapse = strrep(s_before_collapse, '\\', '\');
end
s = s_after_collapse;

% Step 3: Replace any remaining "lone" backslashes with forward slashes.
% This is the key to fixing file paths without breaking TeX escapes.

% Find the locations of all correctly escaped underscores ('\_').
loc_escaped_underscore = strfind(s, '\_');

% Create a logical mask for the entire string, initially all false.
is_part_of_escape = false(1, length(s));

% Mark the characters that are part of the '\_' sequence as 'true'.
if ~isempty(loc_escaped_underscore)
    is_part_of_escape(loc_escaped_underscore) = true;      % Mark the '\'
    is_part_of_escape(loc_escaped_underscore + 1) = true;  % Mark the '_'
end

% Find all backslashes in the string.
loc_all_backslashes = strfind(s, '\');

% Identify which of these backslashes are "lone" (i.e., not part of '\_').
loc_lone_backslashes = loc_all_backslashes(~is_part_of_escape(loc_all_backslashes));

% Replace only the lone backslashes with forward slashes.
s(loc_lone_backslashes) = '/';

s_out = s;

end % <<< FIX: This local function is now properly terminated with an 'end' statement.


%% ----- unique_appear_order_cstr   [AQP_gui.m lines 38642-38654] ----------------------------------
function cstr_unique_appear_order=unique_appear_order_cstr(cstr)
% do the 'unique' function but sorted by the order appeared in the sequence
% handle input as cell of strings (cstr)
% based on first appearance of that string
% e.g  cstr={'C','C','C','B','B','B','P5','P5','P5','P8','P8','P8','Panda','Panda','Panda','A'};cstr_unique_appear_order=unique_appear_order_cstr(cstr);
% see also: unique_count_appear_order_cstr
%-----------------------------------------------------
cstr_unique_appear_order=cstr;
for iT=1:length(unique(cstr)  )
    loc_iT=strmatch(cstr_unique_appear_order{iT},   cstr_unique_appear_order,'exact');
cstr_unique_appear_order(loc_iT(2:end)) =[];
end
end


%% ----- unique_count   [AQP_gui.m lines 38658-38712] ----------------------------------------------
function [uniques,numUnique] = unique_count(x,option)
% alias of count_unique
%COUNT_UNIQUE  Determines unique values, and counts occurrences
%   [uniques,numUnique] = count_unique(x)
%
%   This function determines unique values of an array, and also counts the
%   number of instances of those values.
%
%   This uses the MATLAB builtin function accumarray, and is faster than
%   MATLAB's unique function for intermediate to large sizes of arrays for integer values.  
%   Unlike 'unique' it cannot be used to determine if rows are unique or 
%   operate on cell arrays.
%
%   If float values are passed, it uses MATLAB's logic builtin unique function to
%   determine unique values, and then to count instances.
%
%   Descriptions of Input Variables:
%   x:  Input vector or matrix, N-D.  Must be a type acceptable to
%       accumarray, numeric, logical, char, scalar, or cell array of
%       strings.
%   option: Acceptable values currently only 'float'.  If 'float' is
%           specified, the input x vector will be treated as containing
%           decimal values, regardless of whether it is a float array type.
%
%   Descriptions of Output Variables:
%   uniques:    sorted unique values
%   numUnique:  number of instances of each unique value
%
%   Example(s):
%   >> [uniques] = count_unique(largeArray);
%   >> [uniques,numUnique] = count_unique(largeArray);
%
%   See also: force2PUREcstr, count_matrix_elems, count_unique,  unique, accumarray, howcommon
% see also: unique_count_appear_order_cstr
% --------------------------------
% Author: Anthony Kendall
% Contact: anthony [dot] kendall [at] gmail [dot] com
% Created: 2009-03-17
%=========================================================
testFloat = false;
if nargin == 2 && strcmpi(option,'float')
    testFloat = true;
end

if testFloat
    [uniques,numUnique] = float_cell_unique(x);
else
    try %this will fail if the array is float or cell
        [uniques,numUnique] = int_log_unique(x);
    catch %default to standard approach
        [uniques,numUnique] = float_cell_unique(x);
    end
end

end  % end of --> unique_count


%% ----- int_log_unique   [AQP_gui.m lines 38716-38745] --------------------------------------------
function [uniques,numUnique] = int_log_unique(x)
%First, determine the offset for negative values
minVal = min(x(:));

if minVal < 1
    %Now, offset to get the index
    index = x(:) - minVal + 1;

    %Get the number of duplicates with accumarray
    numUnique = accumarray(index,1);

    %Get the sum of those duplicate values
    sumDups = accumarray(index,x(:));
else
    %Get the number of duplicates with accumarray
    numUnique = accumarray(x(:),1);

    %Get the sum of those duplicate values
    sumDups = accumarray(x(:),x(:));
end

%Find numUnique > 0
test = (numUnique > 0);

%Determine the unique values
uniques = sumDups(test) ./ (numUnique(test));

%Trim the numUnique array
numUnique = numUnique(test);
end   % end of --> int_log_unique


%% ----- float_cell_unique   [AQP_gui.m lines 38750-38798] -----------------------------------------
function [uniques,numUnique] = float_cell_unique(x)

if ~iscell(x)
    %First, sort the input vector
    x = sort(x(:));
    numelX = numel(x);
    
    %Check to see if the array type needs to be converted to double
    currClass = class(x);
    isdouble = strcmp(currClass,'double');
    
    if ~isdouble
        x = double(x);
    end
    
    %Check to see if there are any NaNs or Infs, sort returns these either at
    %the beginning or end of an array
    if isnan(x(1)) || isinf(x(1)) || isnan(x(numelX)) || isinf(x(numelX))
        %Check to see if the array contains nans or infs
        xnan = isnan(x);
        xinf = isinf(x);
        testRep = xnan | xinf;
        
        %Remove all of these from the array
        x = x(~testRep);
    end
    
    %Determine break locations of unique values
    uniqueLocs = [1;diff(x)] ~= 0;
else
    isdouble = true; %just to avoid conversion on finish
    
    %Sort the rows of the cell array
    x = sort(x(:));
    
    %Determine unique location values
    uniqueLocs = [1;~strcmp(x(1:end-1),x(2:end))] ~= 0 ;
end

%Determine the unique values
uniques = x(uniqueLocs);

if ~isdouble
    x = feval(currClass,x);
end

%Count the number of duplicate values
numUnique = diff([find(uniqueLocs);length(x)+1]);
end  % end of --> float_cell_unique


%% ----- usF   [AQP_gui.m lines 38918-38971] -------------------------------------------------------
function out=usF(str)
% since already did following at shortcut --> ML_jdsu_woPLStoolbox
% % following will avoid the issue with usF etc
% set(0, 'DefaultTextInterpreter', 'none');
% now this will just return the input
%------------------------------------------------------------
% alias of underscoreFix
% see also: title_add_GAIS underscoreFix   title_usF  title_add  underscore_related
%--------------------------------------------------------------------
% when str is a path, potentially use following to fix it ...(see also title_usF or title_add)
% or better try to fix by --> strrep(ctit_full_path,'\','/') , Apr 4, 2024
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% see also: title_add_GAIS (newer and better approach that can be convert to Python by using --> set(htit,'string',ctit  ,  'Interpreter', 'none'  )   )
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%----------------------------------------------------------------------
if false
    cc;
% ns=usF('afeb\_234');
ns='afeb\_234';

figure;title(ns);
title_add(gca,'23243_fadfaf');
%-----------------------------------------------------

cc;
ns=usF('afeb\\\\\\\\_234');
figure;title(ns);
title_add(gca,'23243\\\\_fadfaf');;

%-----------------------------------------------------

cc;
str='fdadf_266';
str=replace(str,'_','\_');
ns=usF(str);
figure;title(ns);
title_add(gca,'23243\\\\_fadfaf');
title_add(gca,'23243_fadfaf');
title_add(gca,'\\\\_fadfaf');
title_add(gca,'\\\\_fadfaf_');




end
%----------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------
% since already did following at shortcut --> ML_jdsu_woPLStoolbox
% % following will avoid the issue with usF etc
% set(0, 'DefaultTextInterpreter', 'none');
% now this will just return the input
% if false
    out=underscoreFix(str);
end


%% ----- xlswrite_ChkLn   [AQP_gui.m lines 39075-39097] --------------------------------------------
function xlswrite_ChkLn(varargin)
% check length of fname to make sure it is not over limit of 135
% see also: is_too_long_pfn
if false
    
    fname=[repmat('a',[1 130]),'xxlsx'];
    cprint={'afdafdad','122324','faafd1234'};
    xlswrite_ChkLn(fname,cprint)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this will exceed !!!!!
     fname=[repmat('a',[1 131]),'xxlsx'];% this will exceed !!!!!
    cprint={'afdafdad','122324','faafd1234'};
    xlswrite_ChkLn(fname,cprint)% this will exceed !!!!!
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length(varargin{1})>135
    warning('xls_fname exceeds 135  xls_fname exceeds 135  xls_fname exceeds 135');
    disp_with_border('did NOT write to xlsx file due to : xls_fname exceeds 135  xls_fname exceeds 135  xls_fname exceeds 135');
else
    xlswrite(varargin{1},varargin{2});
end
end


%% ----- z_score_TO_p_value   [AQP_gui.m lines 39101-39141] ----------------------------------------
function p=z_score_TO_p_value( z )
% z_score is a better statistics term than z_value
% see also: normcdf
% see also: p_value_TO_z_score  p_value_vs_sigma_dist_etc
% see also: z_score_TO_sqrt_mahal_or_MD
% see also: MD_TO_p_value
%==============================================================
if false
    
    %---------------------------
    p=z_score_TO_p_value( 1 )
    %---------------------------
    p=z_score_TO_p_value( 2 )
    %---------------------------
    p=z_score_TO_p_value( 3 )
    %---------------------------
    %---------------------------
    z_score_TO_p_value(p_value_TO_z_value( 0.1587))
    %---------------------------------
    z_score_TO_p_value(p_value_TO_z_value(0.0228))
    %---------------------------
    z_score_TO_p_value(p_value_TO_z_value(  0.0013 ))
    %---------------------------
    p=z_score_TO_p_value( 1.73 )
    1-p
    %---------------------------
    p=z_score_TO_p_value( 2 )
    1-p
    %---------------------------
    p=z_score_TO_p_value( 1.5 )
    1-p
    %---------------------------
end
%==================================================

p=(1 - normcdf(z));  % p_oneTailed   % see also: normcdf



done_with_this_function;
end


%% ----- z_score_TO_sqrt_mahal_or_MD   [AQP_gui.m lines 39145-39179] -------------------------------
function [MD p_value]=z_score_TO_sqrt_mahal_or_MD(z,nu )
% where nu is number of variable or nPC
% see also: test_Mahal_Log_or_Not_Random_covariance_matrix
if false
    
     %======================================================
    [MD p_value] = z_score_TO_sqrt_mahal_or_MD(1,1 )
    %-----------------------------------
    [MD p_value] =  z_score_TO_sqrt_mahal_or_MD(2,1 )
    %-----------------------------------
    [MD p_value] = z_score_TO_sqrt_mahal_or_MD(3,1 )
    %======================================================
    [MD p_value] = z_score_TO_sqrt_mahal_or_MD(1,2 )
    %-----------------------------------
    [MD p_value] =  z_score_TO_sqrt_mahal_or_MD(2,2 )
    %-----------------------------------
    [MD p_value] = z_score_TO_sqrt_mahal_or_MD(3,2 )
    %======================================================
    [MD p_value] = z_score_TO_sqrt_mahal_or_MD(1,3 )
    %-----------------------------------
    [MD p_value] =  z_score_TO_sqrt_mahal_or_MD(2,3 )
    %-----------------------------------
    [MD p_value] = z_score_TO_sqrt_mahal_or_MD(3,3 )
    %======================================================
    
    
    
    
    
end
p_value = z_score_TO_p_value( z );
X_chi2_norm_z2 = sqrt(chi2inv(1-p_value,nu));

MD=X_chi2_norm_z2;   % same as sqrt_mahal or sqrt_D2 (in  D2 = mahal(Y,X)  )
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
