classdef ssds
    % Spectral Sensing DataSet class
    % modified from BasicClass
    % Chang Hsiung, June 2, 2017
    %
    % important locations
    %
    % then also deal with case that o1 and o2 are TP pair
    % and Pset are with NaN as AclassinfoP (typically happen in ILCQ's XBPL cases)
    %
    % List of Some Popular Methods
    %  r = plus(o1,o2)
    % create minus(o1,o2) , Sept 3, 2023
    %  oTP=gt(o1,o2) same as oTP=TP_pair(o1,o2)
    %  oTP=TP_pair(o1,o2)
    %  out_obj=P2T(obj)
    %  out_obj=saveAT(obj,inp)
    %-------------------------------------------------------
    % [out_obj]=merge_rm_extract_class(obj,inp) % see also: rm_cls_AT (NOT ssds method)
    %  with capability of inp.action='merge_repeat'  % run 'merge' for more than  one set of classes to be merged , see for  example --> assemble_AT_HFA_BP
    %  in this action,  inp.cls_pick should be "cell of cell" data type  ,% see also: convert_clistclslabel_merged_TO_inp_cls_pick, see also:  create_Mayne_merged_pairs_in_cMPSS
    %------------------------------------------------------
    % [out_obj]=rm_Pset(obj)
    % [out_obj]=rm_samps_Tset(obj,inp)
    %
    % [out_obj]=rm_samps_Pset_in_TPpair(obj,inp) % latest version (July,2019)
    % [out_obj]=rm_samps_Pset_or_Tset_in_TPpair(obj,inp) % July 15, 2020 % rm certain samples in Pset or Tset of TP pairs and may only work for Clsfr type datasets
    % [out_obj]=rm_samps_Pset(obj,inp) % seems quite similar to rm_samps_Pset_in_TPpair() above, this is an earlier version though
    % [out_obj]=extract_Pset(obj,inp) % this extract_Pset and rm_samps_Pset are alias to each other
    % method --> parse_Consecutive_Block
    % main function is  ssds_method_parse_Consecutive_Block 
    % % deal with oTP=TP_pair(o1,o2)   modified Apr 15, 2020 during HFA BP project   
    %
    % out_obj=Multi_Labels_Classificatoin(obj,inp) % added Apr 24, 2020
    % handles4Clsfr.L.ILC_atrb_1.Conversion_Table_clsinfo_or_predcls
    %
    %  following added June 22, 2020
    %  [out_obj]=T_plus_P(obj,inp)
    % -----------------------------------------------
    % ssds method --> parse_Tset_Nfolds_Extr_Tcv(obj,inp) % for PLS applications to split Atrainpk into Nfolds for cross validation etc operations
    % added Sept 24, 2020
    % ----------------------------------------------
    % may undergo some updates in following method, Oct, 2020
    % [out_obj]=show_rm_samps_OLs(obj,inp)
    % see --> test_ssds_show_rm_samps_OLs_method
    %-------------------------------------------------
    % updated Jan 31, 2021
    % % for method rm_samps_Tset(obj,inp) must provide inp.loc_rm or inp.label_rm (see Rm_select_samps_AclabelT_wRepSeq)   % updated Jan 31, 2021
    % see also: Rm_select_samps_AclabelT_wRepSeq( pfn ,inp ) , ssds method--> [out_obj]=rm_samps_Tset(obj,inp) ,  and its main function --> rm_samps_AT.m
    % see also: tag_AclabelT_ReplicateSeq(pfn)
    %------------------------------------------------
    % revisit method --> diagnose_Clsname_PushButton, Dec 8, 2021 for BH/ABU visualization tools
    %------------------------------------------------
    % revisit a non-ssds function for mU2U project, Mar 31, 2022: Atrainpk_Split_Odd_Even_physical_diff_samp , located in --> C:\work\Mfiles\AtrainpkOperations
    %-----------------------------------------------
    % function --> r = add_append_classes(o1,o2) 
    % see --> append M classes of FalsePos materials to form N+M classes model then use this to counter FalsePos.pptx
    % % main function to call --> ssds_method_add_append_classes
    %     this method add or append two Clsfr Tset with ncls1 and ncls2 into ncls1+ncls2 classes, Sept 29, 2022
    %---------------------------------------------
    % ssds method --> apply_PP
    % use both inp.corename and inp.PP_methods at the SAME time !!!
    % remind this again, Sept 30, 2022
    % see for example: pretreat_RK_1stDerSGFL7_PO2(path_AT,inp)
    %---------------------------------------
    % revisit --> TP_pair_FalsePos  method for revisit implementation of CFP-SVM for MN Pro project, Oct 2, 2022
    % add example for running ssds method --> merge_rm_extract_class : test_ssds_method_merge_rm_extract_class , Oct 27, 2022
    %---------------------------------------
    % % see --> Atrainpk_SplitCls , Oct 30, 2022
    %---------------------------------------
    % add ssds method -->  [out_obj]=Split_class(obj,inp) , Oct 31, 2022
    %------------------------------------
    % update ssds method --> apply_PP when running SNV with vectorized codes, Nov 7, 2022
    % see --> test_ssds_method_apply_PP
    %------------------------------------
    % add this fname_AT_barebone_tail,  Dec 22, 2022
    % see for example --> RUN_SVM_linear_wDecVal_CmpClsfr
    %-------------------------------------------------------------------------------------------------------
    %     Feb 13, 2023
    %     update extract_Pset to be able to run with inp.cls_pick ( in addtion to inp.loc)
    %     see for example (#2) --> prep_ResinKit_for_Cloud_Csharp_in_Cmp_SVM_vs_ILM
    %     see for (better) example (esp  independent example ) --> test_ssds_method_extract_Pset
    %     see ssds method --> extract_Pset
    %         extract or trim down to subset of Pset in AT files with _TP etc
    %         reduce number of samples in Pset but keep Tset the same
    %         and still have _TP pairs format
    %==========================================================
    % check AclabelT vs saConc.SampleName, Apr 18, 2023
    % see also: isSame_AclabelT_SampleName
    %-------------------------------------------------------------------
    % create a new ssds method --> parse_Clsfr_Tcv_nFolds
    %   function out=parse_Clsfr_Tcv_nFolds(obj,inp)
    % parse in venetian blinds style by CMH, Apr 21, 2023  
    % will parse PDS (physically different samples) into different side of T_vs_P and PDS determined by AclabelT or saConc.SamepleName
    % see also: test_ssds_method_parse_Clsfr_Tcv_nFolds
    %------------------------------------------------------------------
    % check if all classes filled in Tset, May 10, 2023
    %---------------------------------------------------------------------------
    % create minus(o1,o2) , Sept 3, 2023
    % see also: ssds_method_minus
    %--------------------------------------------------------------------------
    % inp.merge_clsname ; % with size matched with Nrow in inp.cls_pick, Sept 26, 2023
    %---------------------------------------------------------------
    % revisit merge_rm_extract_class(obj,inp) , Jan 15, 2024
    %=========================================================
    % P2T(obj,inp) updated Jan 23, 2024 to deal with usage cases when Pset converted into Tset, it will Not be used as independent Tset
    % instead, it will only be used to expand another Tset (typically by calling ssds_method_plus)
    % or it will be used as a Pset for another independent Tset (typically by calling ">" or TP_pair(o1,o2))
    % add new inp option: inp.keep_clistclslabel_yes
    % only keep clistclslabel_P when keep_clistclslabel_yes==0 & keep_clistclslabel_P_yes==1
    %-------------------------------------------------------------
    % plus_wDup(o1,o2)
    % add this Feb 15, 2024
    % main function to call --> ssds_method_plus_wDup --> ssds_plus_wDup_reAssemble
    % see also: ssds_method_plus_wDup   ssds_plus_wDup_reAssemble
    %--------------------------------------------------------------------
    % add following Feb 15, 2024
    % plus_wExtractCls(o1,o2,inp)  % This appends extracted classes of Tset or Pset of obj2 to end of obj1's Tset or Pset
    % main function to call --> ssds_method_plus_wExtractCls
    % need to provide --> inp.cls_pick (e.g. {'[Carpet]-N6','[Carpet]-N66'} ) 
    % inp.plus_method : 
            %     'T2T' (default), 'P2P'  , 'T2P' , 'P2T'
    %===========================================================================
    % add following Feb 17, 2024
    % function [out_obj]=extract_class(obj,inp)
            % to deal with extract only, but can output clistclslabel to follow user specified seq ( i.e. inp.cls_pick_specified_seq )
            % ssds method --> extract_class (Feb 17, 2024)
            % main function to call --> Atrainpk_merge_classes_ATop
    %===========================================================================
    % add following Feb 19, 2024
    % function [out_obj]=extract_plus_apd_class(o1,o2,inp)     
    % extract from o2, plus those fit o1's clistclslabel into o1, then the rest adp to o1
    %----------------------------------------------------------------------
    %======================================================================
    % % make sure that LAT in obj.LAT matches that in obj.pathfname_AT, May 5, 2024
    %---------------------------------------------------------------------------
    % add this checking of clistclslabel_P in --> oTP=TP_pair(o1,o2), June 17, 2024
    %------------------------------------------------------------------------------
    % add ssds method --> clistclslabel_sort
    % add ssds method --> clistclslabel_sort_rm_source
    %-----------------------------------------------------------------
    % updated Aug 1, 2024
     %   merge_clsname   or  merged_clsname   --> '1st_occur' --> use the first class's name as new merged class's name
     % see also: kt_summary_reAssemble_CarpetLib_CARE_LAfiber_etc
     %-------------------------------------------------------------------
     % add --> run_CFP_GM_kt(obj,inp) %  Aug 2024
     %---------------------------------------------
     % create an operator overloading for "&" (i.e.  sd1 & sd2 --> and(o1,o2)  ) to represent plus_wDup_TP (July 12, 2025)
     % main function to call --> ssds_method_plus_wDup_4Py_combined
     % make some changes here to get rid of that annoying obj_saveAT.pathfname_AT (July 12, 2025)
    %========================================================================
    properties
        %Value
        nsamp
        nsampT
        nsampP
        nvar
        ncls
        nclsT
        nclsP
        LAT
        pathfname_AT
        fname_AT_barebone_tail   % add this property -->" fname_AT_barebone_tail", Dec 22, 2022
        type_Model   %  'Clsfr' or 'PLS'
        %------------------------------------------------
        % add following proptertie to handle MLbClsfr (Multi_Labels Clsfr), Apr 11, 2023
        % where "LC" refers to Super Classes
        AclassinfoMap2LC
        clistclslabel_LC
        AclassinfoT_LC
        AclassinfoP_LC
        Clsfr_Model_subtype  % MLbClsfr for above case
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = ssds(varargin) % By adding this constructor to the class definition, you can create an object in one step:
            
            if nargin == 1 
                if ischar(varargin{1})
                LAT=load_local_try(varargin{1});
                obj.pathfname_AT=varargin{1};
                elseif isa(varargin{1},'struct')
                LAT= varargin{1};  
                obj.pathfname_AT='';
                else
                    error('datatype for input not supported')
                end
                obj.nsamp=length(LAT.Atrainpk(:,1));
                obj.nsampT=length(LAT.Atrainpk(:,1));
                
                try
                obj.nsampP=length(LAT.Apred(:,1));
                catch
                obj.nsampP=NaN;    
                end
                %%%%%%
                try
                    try
                        saConc_T=LAT.PLS.Tset.saConc;
                    catch
                        saConc_T=LAT.saConc;
                    end
                catch
                    saConc_T='';
                end
                
                try
                    saConc_P=LAT.PLS.Pset.saConc;
                catch
                    saConc_P='';
                end
                %%%checking size of T and P and assign 
               % if length(saConc_T)>0 & length(saConc_T)==obj.nsampT
               if length(saConc_T)>0 & ~isempty(saConc_T)  % updated July 28, 2020
                   obj.type_Model='PLS';
                   %------------------------------------------------------
                   % check AclabelT vs saConc.SampleName, Apr 18, 2023
                   if ~isSame_AclabelT_SampleName(LAT)
                   Speak_mk('Mismatch between AclabelT_from_saConc vs SAT.AclabelT');
                   end
                   %-----------------------------------------------------
                   % check whether Atrainpk matched with that inside saConc
                   
                   %                 LAT.Atrainpk(1,:)
                   %                 LAT.saConc(1).Atrainpk(1,:)
                   
                   %====================================
                   % add this July 28, 2020
                   % see also:   check_and_try_fix_nsamp_inconsistency_ATsaConc ,  nsamp_ATsaConc_wChecking  ,  nsamp_ATsaConc
                   [nsamp_T  nsamp_P out_nsamp]=nsamp_ATsaConc_wChecking(LAT);
                   if ~out_nsamp.nsamp_match
                       if ~isempty(obj.pathfname_AT)
                           error(['misMatch in nsamp in  -->',fileparts_name_ext( obj.pathfname_AT )])
                       else
                           error(['misMatch in nsamp !!!'])
                       end
                   else
                       disp('nsamp are consistent within this ATsaConc')
                   end
                   try
                       Atrainpk_from_saConc= cat(1,LAT.saConc.Atrainpk);
                       disp('check Atrainpk')
                       if length(LAT.saConc)~=length(LAT.Atrainpk(:,1))
                           error('mismatch in size of LAT.saConc vs LAT.Atrainpk')
                       end
                       if ~isSAME_2Matrix(Atrainpk_from_saConc,LAT.Atrainpk)
                           Speak_mk('mismatch between "A" train peak vs that in structure array');
                           [lia_T,locb_T] = ismember_by_rows(LAT.Atrainpk,Atrainpk_from_saConc);
                           loc_rm=find(lia_T==0);
                           error('can not create ssds instance due to mismatch between Atrainpk from LAT vs that from saConc')
                           %Speak_mk('"A" train peak inside structure array will be replaced by external "A" train peak');
                           %                             [LAT.saConc.Atrainpk]=mat2cell_CH_4SAinsert(LAT.Atrainpk,'row');
                           %LAT.saConc=Atrainpk2saConc(LAT.Atrainpk,LAT.saConc);
                       end
                   catch
                       Atrainpk_from_saConc= cat(1,LAT.PLS.Tset.saConc.Atrainpk);
                       disp('check Atrainpk')
                       if ~isSAME_2Matrix(Atrainpk_from_saConc,LAT.Atrainpk)
                           Speak_mk('mismatch between "A" train peak vs that in structure array')
                           [lia_T,locb_T] = ismember_by_rows(LAT.Atrainpk,Atrainpk_from_saConc);
                           loc_rm=find(lia_T==0);
                           
                           error('can not create ssds instance due to mismatch between Atrainpk from LAT vs that from saConc')
                           
                           %Speak_mk('"A" train peak inside structure array will be replaced by external "A" train peak');
                           %[LAT.PLS.Tset.saConc.Atrainpk]=mat2cell_CH_4SAinsert(LAT.Atrainpk,'row');
                       end
                   end
                   
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   try
                       Apred_from_saConc= cat(1,LAT.PLS.Pset.saConc.Atrainpk);
                   catch
                       Apred_from_saConc='';
                   end
                   disp('check Apred')
                   if ~isempty(Apred_from_saConc)
                       if ~isSAME_2Matrix(Apred_from_saConc,LAT.Apred)
                           Speak_mk('mismatch between "A" pred vs that in structure array');
                           [lia_P,locb_P] = ismember_by_rows(LAT.Apred,Apred_from_saConc);
                           loc_rm=find(lia_P==0);
                           error('can not create ssds instance due to mismatch between Apred from LAT vs that from saConc')
                           %Speak_mk('"A" train peak inside structure array will be replaced by external "A" pred');
                           %[LAT.PLS.Pset.saConc.Atrainpk]=mat2cell_CH_4SAinsert(LAT.Apred,'row');
                       end
                   end
                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               else
                   obj.type_Model='Clsfr';
               end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 if length(saConc_P)>0 & length(saConc_P)~=obj.nsampP
                     error('mismatch between size of PLS.Pset.saConc vs nsampP')
                 end
                %%%%%%
                obj.nvar=length(LAT.Atrainpk(1,:));
                % deal with Label Combination data structure in multi-label SVM
                if  isfield(LAT,'AclassinfoMap2LC') && isfield(LAT,'clistclslabel_LC') && isfield(LAT,'AclassinfoP')
                    % deal with Label Combination data structure in multi-label SVM
                    obj.ncls=length(LAT.clistclslabel);
                    obj.nclsT=length(LAT.clistclslabel);
                    obj.nclsP=length(LAT.clistclslabel_LC);
                    %------------------------------------------
                    obj.AclassinfoMap2LC=LAT.AclassinfoMap2LC;  % add this July 11, 2023
                    %--------------------------------------
                    if ~isempty(obj.AclassinfoMap2LC) && max(obj.AclassinfoMap2LC(:,2))==obj.nclsP && max(obj.AclassinfoMap2LC(:,1))==obj.nclsT
                       
                        obj.Clsfr_Model_subtype= 'MLbClsfr';
                        obj.AclassinfoMap2LC=LAT.AclassinfoMap2LC;
                    else
                        obj.Clsfr_Model_subtype='NotValid_MLbClsfr';
                        obj.AclassinfoMap2LC=[];
                        warning(obj.Clsfr_Model_subtype);
                        
                    end
                    %                     AclassinfoMap2LC
                    %                     clistclslabel_LC
                    %                     AclassinfoT_LC
                    %                     AclassinfoP_LC
                    %                     Clsfr_Model_subtype  % MLbClsfr for above case
                else
                    obj.ncls=length(LAT.clistclslabel);
                    obj.nclsT=length(LAT.clistclslabel);
                    obj.nclsP=NaN;
                end
                
                %%%%%%%%%%%%
                % final output of ssds constructor
                obj.LAT=LAT;
                %##############################
                % check if all classes filled in Tset, May 10, 2023
                if strcmp(obj.type_Model,'Clsfr')&& isfield(obj.LAT,'AclassinfoT' )   % add this checking for "AclassinfoT", Sept 8, 2023
                    try
                        [QclsinfoT NclsinforT]= unique_count(obj.LAT.AclassinfoT) ;
                        if ~isequal(row_always(QclsinfoT),[1: length(obj.LAT.clistclslabel)] )
                            % warning(['Misssing class(es) in Tset in L_iQS when ith-Fold = ',num2str(iQS)]);
                            % EB
%                             warning(['mismatch in size of QclsinfoT or QclsinfoP vs  clistclslabel , if it is converting Pset to Tset, maybe it is fine ?']);
                         disp(['mismatch in size of QclsinfoT or QclsinfoP vs  clistclslabel , if it is converting Pset to Tset, maybe it is fine ']);
                        end
                    catch
                         warning(['mismatch in size of QclsinfoT or QclsinfoP vs  clistclslabel , if it is converting Pset to Tset, maybe it is fine ?']);
                    end
                else     
                    warning('misssing AclassinfoT for "Clsfr" ??');  % add this checking for "AclassinfoT", Sept 8, 2023
                end
                %%%%%%%%%%%%
             %====================
            % add this fname_AT_barebone_tail,  Dec 22, 2022 
            % see for example --> RUN_SVM_linear_wDecVal_CmpClsfr
            %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            inp4sA.corename='';
            obj_saveAT=saveAT(obj,inp4sA);
%           fname_AT_barebone_tail=[svar,sncls,snsamp,snsampT,snsampP,'.mat'];
            delete(obj_saveAT.pathfname_AT) ;                       % make some changes here to get rid of that annoying obj_saveAT.pathfname_AT (July 12, 2025)
            obj.fname_AT_barebone_tail=obj_saveAT.fname_AT_barebone_tail;
            %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            %====================
                
            else
                error('not ready to handle this case yet')
                
            end
        end   % end of ssds constructor
        %%%%%%%%%%%%%%%%
        
        function r = roundOff(obj)
            r = round([obj.Value],2);
        end
        
        %%%%%%%%%%%%%%%%
        function r = multiplyBy(obj,n)
            r = [obj.Value] * n;
        end
        %%%%%%%%%%%%%%%%
        %Here is an operator overloading of the MATLAB plus function. It append Tset of obj2 to end of obj1
        function r = plus(o1,o2)  %Here is an overload of the MATLAB plus function. It defines addition for this class as adding the property values:
            %             r = o1.nsamp + o2.nsamp;
            % main function to call --> ssds_method_plus
            % see also: ssds_method_plus
            r=ssds_method_plus(o1,o2);
            
        end  % end of "plus" method
        %%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%
        %Here is an operator overloading of the MATLAB and (&) function. It append (after remove Duplicates) Tset and Pset of obj2 to end of obj1
        function r = and(o1,o2)  %Here is an overload of the MATLAB and function. It defines addition for this class as adding the property values:
            % main function to call --> ssds_method_plus_wDup_4Py_combined
            % see also: ssds_method_plus
            pfn1=o1.pathfname_AT;
            pfn2=o2.pathfname_AT;
            r = ssds_method_plus_wDup_4Py_combined(pfn1, pfn2);
            
        end  % end of "and" method
        %%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%
        %Here is an overload of the MATLAB plus function. It append Tset of obj2 to end of obj1
        function r = plus_wDup(o1,o2)  %Here is an overload of the MATLAB plus function. It defines addition for this class as adding the property values:
            % main function to call --> ssds_method_plus_wDup --> ssds_plus_wDup_reAssemble
            % see also: ssds_method_plus
            r=ssds_method_plus_wDup(o1,o2);   % main function to call --> ssds_plus_wDup_reAssemble
            
        end  % end of "plus" method
        %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%
        %Here is an overload of the MATLAB plus function. This appends extracted classes of Tset or Pset of obj2 to end of obj1's Tset or Pset
        %
        function r = plus_wExtractCls(o1,o2,inp)  % This appends extracted classes of Tset or Pset of obj2 to end of obj1's Tset or Pset
            % main function to call --> ssds_method_plus_wExtractCls
            % see also: ssds_method_plus_wExtractCls
            % added Feb 15, 2024
            %------------------------------------------
            % need to provide --> inp.cls_pick (e.g. {'[Carpet]-N6','[Carpet]-N66'} ) 
            % inp.plus_method : 
            %     'T2T' (default), 'P2P'  , 'T2P' , 'P2T'
            %-------------------------------------------
            % will call ssds_method : merge_rm_extract_class(sd2,inp)
            % inp.action='extract';
            % need to provide --> inp.cls_pick (e.g. {'[Carpet]-N6','[Carpet]-N66'} ); 
            %------------------------------------------
            r=ssds_method_plus_wExtractCls(o1,o2,inp);   % main function to call --> 
            
        end  % end of "plus_wExtractCls" method
        %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Here is an overload of the MATLAB plus function. It append Tset of obj2 to end of obj1
        function r = minus(o1,o2)  %Here is an overload of the MATLAB minus function. It defines minus for this class as minus the property values:
            % create minus(o1,o2) , Sept 3, 2023
            %             r = o1.nsamp - o2.nsamp;
            % main function to call --> ssds_method_minus
            % see also: ssds_method_minus , plus, ssds_method_plus
            r=ssds_method_minus(o1,o2);
            
        end  % end of "minus" method
        %%%%%%%%%%%%%%%%
        function out_obj=saveAT(obj,inp)
            %         disp('calculate nsamp, ncls, and nvar, then save as Atrainpketc_~.mat');
            %%%%%%%
            obj_orig=obj;
            %%%%%%%%%%%%%
            try
                corename=['_',inp.corename];
            catch
                corename='';
            end
            %%%%%%%
            snsamp=['_nsamp',num2str(obj.nsamp)];
            if ~isnan(obj.nsampP)
                snsampP=['_nsampP',num2str(obj.nsampP)];
                snsampT=['_nsampT',num2str(obj.nsamp)];
                snsamp='';
                
            else
                snsampP='';
                snsampT='';
            end
            
            if strcmp(obj.type_Model,'Clsfr')
                % deal with Label Combination data structure in multi-label SVM
                if ~isnan(obj.nclsP)
                 % deal with Label Combination data structure in multi-label SVM   
                 sncls=['_nclsT',num2str(obj.ncls),'_nclsP',num2str(obj.nclsP)];   % deal with Label Combination data structure in multi-label SVM
                else
                sncls=['_ncls',num2str(obj.ncls)];
                end
                
                
            else
                %sncls='';
                try
                sncls=['_ncls',num2str(obj.ncls)];
                catch
                 sncls='';   
                end
            end
            
            svar=['_nvar',num2str(obj.nvar)];
            %%%%
            if isempty(corename)&& ~isempty(inp.pathfname_AT)
                corename_tmp=fileparts_name_ext(inp.pathfname_AT);
                corename_tmp=find_keyword_between_markers(corename_tmp,'Atrainpketc_','.mat');
                  fname_AT=['Atrainpketc_',corename_tmp,'.mat']; 
            else
                fname_AT=['Atrainpketc_',corename,svar,sncls,snsamp,snsampT,snsampP,'.mat'];
                fname_AT=strrep(fname_AT,'__','_');
            end
            %%%%
            %====================
            % add this fname_AT_barebone_tail,  Dec 22, 2022 
            fname_AT_barebone_tail=[svar,sncls,snsamp,snsampT,snsampP,'.mat'];% see for example --> RUN_SVM_linear_wDecVal_CmpClsfr
            %====================
            SAT=obj.LAT;
            save(fname_AT,'-struct','SAT');
            disp([pwd,'\',fname_AT,' has been saved !']);
            obj.pathfname_AT=[pwd,'\',fname_AT];  % update property --> pathfname_AT
            obj.fname_AT_barebone_tail=fname_AT_barebone_tail;% add this fname_AT_barebone_tail,  Dec 22, 2022 
            out_obj=obj;
            %%%%%%%%%%%%%
            % try  to delete previously saved pathfname_AT that user did not provide corename
            % added by CH, June 22, 2020
            % updated Mar 7, 2024 by adding --> && strcmp(pwd,fileparts(obj_orig.pathfname_AT))
            if ~isempty(inp.corename) && ~isempty(obj_orig.pathfname_AT) && ~isequal(obj.pathfname_AT,obj_orig.pathfname_AT)  && strcmp(pwd,fileparts(obj_orig.pathfname_AT))
                try
                    delete(obj_orig.pathfname_AT);
                end
            end
            %%%%%%%%%%%%%
        end %end of "saveAT" method
        %%%%%%%%%%%%%%%%%%
        % this is equivalent to the method of "gt" or ">" below
        function oTP=TP_pair(o1,o2)
            % form TP pair by using first obj as Tset and 2nd as Pset
            % see for example: test_ssds_TP_pair_method()
            % main function is Atrainpk_merge_Apred()
            %
            % following is modified by CH, May 15, 2019
            % if clistclslabel in o2 is different from that of o1,
            % it will be added to oTP as "clistclslabel_P", see --> Atrainpk_merge_Apred
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % find skeyP from fnLP in Atrainpk_merge_Apred()
            % in current setting, try two possibilities: 
            % "(T-" vs ")"   and   "T-" vs "_"
            inp.cmk1={'(T-','T-'};% this for extracting Pset info from "o2"
            inp.cmk2={')',  '_'};% this for extracting Pset info from "o2"
            % find skeyP from fnLP in Atrainpk_merge_Apred()
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             if ~isempty(o1.pathfname_AT)&&~isempty(o2.pathfname_AT)
%               fnLT= o1.pathfname_AT;
%               fnLP= o2.pathfname_AT;
%             else
            fnLT=o1.LAT;  % always use struct (because sometimes o1.pathfname_AT may already been deleted)
            fnLP=o2.LAT;  % always use struct (because sometimes o2.pathfname_AT may already been deleted)
%             end
            
            [fnLTLP SfnLTLP]=Atrainpk_merge_Apred(fnLT,fnLP,inp);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % avoid using the following that needs to save pathfname which
            % can create problems in compiled version
            % instead passing by structure
            %pathfnameLTLP=which(fnLTLP);%use this such that pathfname_AT can be filled with actual value
            %oTP=ssds(pathfnameLTLP);
            oTP=ssds(SfnLTLP);% instead passing by structure
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % deal with ILCQ with multiple XBPLs case, 
                % see for example --> build_ext_TPpairs_ILCQ_multiple_XBPLs()
                if all(isnan(o2.LAT.AclassinfoT)) &&   ~isSAME_two_cstr(o1.LAT.clistclslabel,o2.LAT.clistclslabel) && strcmp(o1.type_Model,'PLS') && strcmp(o2.type_Model,'PLS')
                    oTP.LAT.AclassinfoP_alt=oTP.LAT.AclassinfoP;
                    %checking
                    if length(oTP.LAT.clistclslabel_P)>1
                        try
                        oTP.LAT.AclassinfoP_alt=o2.LAT.AclassinfoT_alt;  
                        catch
                            error('need to provide Aclassinfo for oTP.LAT.AclassinfoP_alt')
                        end
%                         if ~isequal(row_always(unique(oTP.LAT.AclassinfoP_alt)),[1:length(oTP.LAT.clistclslabel_P)])
%                             error('mismatch between AclassinfoP_alt vs clistclslabel_P, this is mainly for ILCQ with multiple XBPLs case, see -->  build_ext_TPpairs_ILCQ_multiple_XBPLs() or ssds.plus method or ssds.TP_pair or Atrainpk_merge_Apred')
%                         end
                    elseif length(oTP.LAT.clistclslabel_P)==1
                        oTP.LAT.AclassinfoP_alt=ones(size(oTP.LAT.AclassinfoP));
                    else
                        error('can not handle this case wrt length(oTP.LAT.clistclslabel_P)')
                    end
                end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
           % deal with oTP=TP_pair(o1,o2)   modified Apr 15, 2020 during HFA BP project    
           %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
           % add this checking of clistclslabel_P in --> oTP=TP_pair(o1,o2), June 17, 2024 (see ssds)
           % add checking to see if ~isempty(fnLP.clistclslabel_P) , July 8, 2024
           %
           if ~isfield(oTP.LAT,'clistclslabel_P')  && isfield(fnLP,'clistclslabel_P') &&  ~isempty(fnLP.clistclslabel_P)   && ~isequal(fnLP.clistclslabel_P,fnLP.clistclslabel )   % add checking to see if ~isempty(fnLP.clistclslabel_P) , July 8, 2024
               oTP.LAT.clistclslabel_P= fnLP.clistclslabel_P;  % clistclslabel_P has been forced to be added to fnLP in method "P2T", this was added on Apr 16, 2020
           end
           %%%%%%%%%%
           %==================================================================================================
           % add checking to see if ~isempty(fnLP.clistclslabel_P) , July 8, 2024
           if  isfield(fnLP,'clistclslabel_P') &&  ~isempty(fnLP.clistclslabel_P) 
               qclsinfoP= unique(oTP.LAT.AclassinfoP);
               try
                   %                if  length(oTP.LAT.clistclslabel_P)==length( oTP.LAT.clistclslabel)                                                   % add this checking of clistclslabel_P in --> oTP=TP_pair(o1,o2), June 17, 2024
                   %try
                   for i_qP=1:length(qclsinfoP)
                       new_clsinfoP_i_qP=find(strcmp(oTP.LAT.clistclslabel,oTP.LAT.clistclslabel_P(qclsinfoP(i_qP))));
                       if ~isempty(new_clsinfoP_i_qP)
                           oTP.LAT.AclassinfoP=replace_CH(oTP.LAT.AclassinfoP    ,qclsinfoP(i_qP),new_clsinfoP_i_qP);  % semi column added at this stupid place, July 1, 2022
                       end
                   end
                   %end
                   %                end
               end
           end   % end of if -->  isfield(fnLP,'clistclslabel_P') &&  ~isempty(fnLP.clistclslabel_P) 
           %======================================================================================================
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end % end of "TP_pair" method
        %================================================================================================================================
        %================================================================================================================================
        
        %%%%%%%%%%%%%%%%%%
        %Here is an overload of the MATLAB gt (or ">" )function. It pairs Tset of obj2 as Pset to obj1
        % this is equivalent to the method of TP_pair
        function oTP=gt(o1,o2)
            % form TP pair by using first obj as Tset and 2nd as Pset
            % see for example: test_ssds_TP_pair_method()
            % main function is Atrainpk_merge_Apred()
            %
            % following is modified by CH, May 15, 2019
            % if clistclslabel in o2 is different from that of o1,
            % it will be added to oTP as "clistclslabel_P"
            oTP=TP_pair(o1,o2);
        end % end of "gt" or ">" method
        
         %%%%%%%%%%%%%%%%%%
         function oTP=TP_pair_FalsePos(o1,o2,inp)
            % form TP pair by using first obj as Tset and 2nd as Pset
            % where 2nd AT or o2 will be converted to all NaN cls_P
            % see for example: test_ssds_TP_pair_FalsePos_method()
            % see also: '2AT->TP_FalsePos' in ATop
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            % very important: o1 and o2 should be ssds obj
            % see for example: test_ssds_TP_pair_FalsePos_method()
            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if nargin==3
             corename=inp.corename;
            else
                corename='';
            end
            if isa(o1,'ssds') & isa(o2,'ssds')
                try
                    fnLT=o1.pathfname_AT;
                    fnLP=o2.pathfname_AT;
                    sT=ssds(fnLT);
                    sP=ssds(fnLP);
                catch
                    sT=o1;sP=o2;
                end
            else
                error('inputs to TP_pair_FalsePos MUST be ssds obj')
            end
                
                sP.LAT.AclassinfoT=repmat(NaN,size(sP.LAT.AclassinfoT));
                sTP=sT>sP;

                if ~isempty(sTP.pathfname_AT)
                    delete(sTP.pathfname_AT);
                end
                
                try
                strT=find_keyword_between_markers_wlistRHS( find_keyword_between_markers(fileparts_name_ext(fnLT),'{','}'),'T-',{'_',''});;
                catch
                strT='';    
                end
                try
                strP=find_keyword_between_markers_wlistRHS( find_keyword_between_markers(fileparts_name_ext(fnLP),'{','}'),'T-',{'_',''});;
                catch
                strP='';    
                end
                if ~isempty(corename)
                    inp.corename=corename;
                else
                    inp.corename=['{','T-',strT,'_','P-',strP,'}'];
                end
                new_sd =sTP.saveAT(inp);
                
                pathfname_AT_new= strrep(new_sd.pathfname_AT,'.mat','_clsP-NaN.mat');
                copyfile( new_sd.pathfname_AT,pathfname_AT_new);
                disp(['only this --> ',pathfname_AT_new,' has been created'])
                delete(new_sd.pathfname_AT);
            %%%%%%%%%%%%%%%
            oTP=ssds(pathfname_AT_new);
        end % end of "TP_pair_FalsePos" method
        %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%
        % remove Tset and replace it by Pset
        function out_obj=P2T(obj,inp)
            % add new inp option: inp.keep_clistclslabel_yes
            % remove Tset and replace it by Pset
            %------------------------------
            % see for example: ...
            %=========================================================
            % P2T(obj,inp) updated Jan 23, 2024 to deal with usage cases when Pset converted into Tset, it will Not be used as independent Tset
            % instead, it will only be used to expand another Tset (typically by calling ssds_method_plus)
            % or it will be used as a Pset for another independent Tset (typically by calling ">" or TP_pair(o1,o2))
            % add new inp option: inp.keep_clistclslabel_yes
            % only keep clistclslabel_P when keep_clistclslabel_yes==0 & keep_clistclslabel_P_yes==1
            %---------------------------------------------------------
            if nargin==2
                keep_clistclslabel_yes=inp.keep_clistclslabel_yes;
            else
                keep_clistclslabel_yes=1;  %default set to 1
            end
            
            if keep_clistclslabel_yes
                keep_clistclslabel_P_yes=0;
            else
                keep_clistclslabel_P_yes=1;
            end
            %===================================
            
           LATnew.Atrainpk=obj.LAT.Apred;
           LATnew.AclassinfoT=obj.LAT.AclassinfoP;
           
           try
            LATnew.AclassinfoT_alt=obj.LAT.AclassinfoP_alt;   %deal with ILCQ XBPL case
           end
           
           LATnew.AclabelT=obj.LAT.AclabelP;
           %========================================================
           if ~keep_clistclslabel_yes && keep_clistclslabel_P_yes
               try
                   LATnew.clistclslabel=obj.LAT.clistclslabel_P;  % only keep clistclslabel_P when keep_clistclslabel_yes==0 & keep_clistclslabel_P_yes==1
               catch
                   LATnew.clistclslabel=obj.LAT.clistclslabel;
               end
           else
                LATnew.clistclslabel=obj.LAT.clistclslabel;
           end
           %=======================================================
           
            try
             LATnew.wvl_standardize=obj.LAT.wvl_standardize;   
            end
            try
             LATnew.RawSpectra=obj.LAT.RawSpectra.Pset;   
            end
            try
             LATnew.saConc=obj.LAT.PLS.Pset.saConc; 
%             catch
%                 error('saConc not available for Pset')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~isfield(LATnew,'clistclslabel_P')
                LATnew.clistclslabel_P=LATnew.clistclslabel;  % this will be needed in TP_pair(o1,o2) and this was added on Apr 16, 2020
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            out_obj=ssds(LATnew);
            %------------------------------------------------------------------------
            if isempty(out_obj.pathfname_AT)
                inp.corename='{P2T}';
            out_obj=    out_obj.saveAT(inp);
            end
            %------------------------------------------------------------------------
            
        end % end of P2T method
        %%%%%%%%%%%%%%%%%%
        % replace Atrainpk into saConc and replace external Atrainpk too
        function out_obj=Atrainpk_replace(obj,Atrainpk_new)
            % replace Atrainpk into saConc and replace external Atrainpk too
             % % do not forget to reassign obj to LHS of "=" when calling this method from outside !!!
            % see for example: Atrainpk2saConc()
            LATnew=obj.LAT;
            LATnew.Atrainpk=Atrainpk_new;
            try
                LATnew.saConc=Atrainpk2saConc(Atrainpk_new,LATnew.saConc);
            catch
                LATnew.PLS.Tset.saConc=Atrainpk2saConc(Atrainpk_new,LATnew.PLS.Tset.saConc);
            end
            out_obj=ssds(LATnew);
        end % end of Atrainpk_replace method
        %%%%%%%%%%%%%%%%%%
        % replace RawSpectra into AT objects
        function out_obj=RawSpectra_replace(obj,RawSpectra_new)
            % replace RawSpectra into AT objects
            % % do not forget to reassign obj to LHS of "=" when calling this method from outside !!!
            
            LATnew=obj.LAT;
            try
            LATnew.RawSpectra.Tset=RawSpectra_new;
            catch
            LATnew.RawSpectra=RawSpectra_new;   
            end
            out_obj=ssds(LATnew);
        end % end of Atrainpk_replace method
        %%%%%%%%%%%%%%%%%%
        % show RawSpectra and Atrainpk and allow interactively pickCurve etc
        function diagnose_AT(obj,inp)
            
            if exist('inp','var')
                
                if ischar(inp) && ( strcmp(lower(inp),'atrainpk')| strcmp(lower(inp),'rawspectra'))
                    inptmp=inp;clear inp;
                    inp.Spectra_Type=inptmp;
                    
                    % set to activate --> activate_PickSpectra_GUI_yes or activate_Clsname_CmpSpectra_gui_yes
                    setup_ShowLabel_findclosestCurve_RS_AT_gui(obj.pathfname_AT,inp);
                elseif isa(inp,'struct') && isfield(inp,'Spectra_Type') && ~isempty(inp.Spectra_Type)
                    
                    % set to activate --> activate_PickSpectra_GUI_yes or activate_Clsname_CmpSpectra_gui_yes
                    setup_ShowLabel_findclosestCurve_RS_AT_gui(obj.pathfname_AT,inp);
                    
                else
                    error('data type for "inp" not supported')
                end
                %             pathfname_AT='C:\work\JDSU\CUSTOMERS\GreenWall\ATetc\Atrainpketc_GreenWall_nvar121_ncls6_nsamp252_pp1-1stDerSGw5_pp2-SNV.mat';
                
            else
                %default
                inp.Spectra_Type='Atrainpk';
                % set to activate --> activate_PickSpectra_GUI_yes or activate_Clsname_CmpSpectra_gui_yes
               setup_ShowLabel_findclosestCurve_RS_AT_gui(obj.pathfname_AT,inp); 
                
                
            end


        end %% end of diagnose_AT() method
        %%%%%%%%%%%%%%%%%%
        function diagnose_Clsname_PushButton(obj,inp)
            % % revisit method --> diagnose_Clsname_PushButton, Dec 8, 2021 for BH/ABU visualization tools
            % To set color and width of inner line for Pset when picked see below:
            % function Clsname_CmpSpectra_gui_4ssds() line --> set(hp_spectra_pushed_P_alt,'linewidth',0.8,'color',[0.8 0.8 0.8]);
            %
            % see also setup_ShowLabel_findclosestCurve_RS_AT_gui
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if false
                % with Apred, test with ssds
                inp.Spectra_Type='Atrainpk';
                pathfname_AT='C:\work\JDSU\CUSTOMERS\GreenWall\AT_Odd-Even_bef_rm2OLs\Atrainpketc_wRawSpectra_T-odd_P-even_GreenWall_nvar121_ncls6_pp1-1stDerSGw5_pp2-SNV_nsampT126__nsampP126_TP.mat';
                sd=ssds(pathfname_AT);
                sd.diagnose_Clsname_PushButton(inp);
                %%%%%%%%%%%%%%%%%%%%
                %inp.Spectra_Type='Atrainpk';
                inp.Spectra_Type='RawSpectra';
                pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\BMS_5P\Atrainpketc__T1130_P1201_nvar58_ncls5__pp1-1stDerSGFL7[PO2]_pp2-SNV_nsampT51_nsampP49.mat';
                sd=ssds(pathfname_AT);
                sd.diagnose_Clsname_PushButton(inp);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            inp.pick_method='Clsname_PushButton';% this setting should stay the same
            setup_ShowLabel_findclosestCurve_RS_AT_gui(obj.pathfname_AT,inp);
            
        end  %end of diagnose_Clsname_PushButton
        %%%%%%%%%%%%%%%%%%
        % apply preprocessing or pretreatment                                            % use both inp.corename and inp.PP_methods at the SAME time !!!
        % % use both inp.corename and inp.PP_methods at the SAME time !!!            % use both inp.corename and inp.PP_methods at the SAME time !!!
        % for example
        % inp.PP_methods.pp1='1stDerSGw15' ;  %   'SG' 'SGw5'   '1stDerSGw17' '1stDerSGDiederick' '1stDerSGw5' 'none' '1stDer'   '2ndDer'  'SNV'
        % inp.PP_methods.pp2='SNV';   % 'SampMncn'  'none' '1stDer'   '2ndDer'  'SNV'
        % inp.corename=corename;                                                                                  % use both inp.corename and inp.PP_methods at the SAME time !!!
        % sd0=ssds(LAT);
        % out_obj=apply_PP(sd0,inp);
        
        function out_obj=apply_PP(obj,inp)
             % use both inp.corename and inp.PP_methods at the SAME time !!!
            try
                inp.pathfname_AT=['Atrainpketc_',inp.corename,'.mat'];
            catch
                inp.pathfname_AT=['Atrainpketc_','some_corename','.mat'];
            end
            outPP=pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP(obj.LAT,inp);
            
            LAT_PPd=load(outPP.fname_new);
            delete(outPP.fname_new);
            inp.corename=find_keyword_between_markers(outPP.fname_new,'Atrainpketc_','.mat');
           corename_new=strrep(inp.corename,['_nvar', textual_extractBetween_multiple_kw2(inp.corename,'_nvar',{'_',''})],'');
           inp.corename=corename_new;                                                                                      % use both inp.corename and inp.PP_methods at the SAME time !!!
            sd1=ssds(LAT_PPd);
            out_obj_saveAT= saveAT(sd1,inp);
            out_obj=sd1;
            out_obj.pathfname_AT=out_obj_saveAT.pathfname_AT;
            
        end % end of apply_PP() method
        %%%%%%%%%%%%%%%%%%
        %==============================================================================================================
        % parse_T_vs_P_in_Clsfr_Tcv_nFolds
        function [out_objs cpfn_iTcv ]=parse_Clsfr_Tcv_nFolds(obj,inp)
        % parse in venetian blinds style by CMH, Apr 21, 2023   
        % main function --> parse_T_vs_P_in_Clsfr_Tcv_nFolds
        % will parse PDS (physically different samples) into different side of T_vs_P and PDS determined by AclabelT or saConc.SamepleName
        %
        % see also: parse_T_vs_P_in_Clsfr_Tcv_nFolds
        % see also: test_ssds_method_parse_Clsfr_Tcv_nFolds
        if isa(obj,'ssds') && ~isempty(obj.pathfname_AT)
            pfn_AT=obj.pathfname_AT;
        elseif ischar(obj)
            pfn_AT=obj;
        else
            error('datatype for obj Not supported yet');
        end
           [out_objs cpfn_iTcv ]=parse_T_vs_P_in_Clsfr_Tcv_nFolds(pfn_AT,inp.nFolds) ;
        end
        
        %=============================================================================================================
        % parse Atrainpk based on sub-class info in AclabelT
         function [out]=parse_AclabelT_subcls(obj,inp)
        % after parsing, all Atrainpk samples used exactly same number of times as Pset in all TP pairs
        % need to provide the following:
        %  inp.smk1='_P';inp.smk2='';inp.Nsubcls4T=2;
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % very important --> every class Must have same number of "_P",
        %  see prep_Muscle.m
        % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        % modified from Atrainpk_Split_Odd_Even_physical_diff_samp(pathfname_AT)
        % see also Atrainpk_parse_AclabelT_subcls(), test_ssds_parse_AclabelT_subcls_method(), ATop.m
        % see also prep_ResinKits_Molecules_J_rk_4_5_6_3N1 parse_AclabelT_subcls_PDS prep_Muscle and parse_physically_different_samples
        % see doc_Hsiung_jdsu() and prep_Muscle()
        disp('work on parsing by AclabelT_subcls for classification apps')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            switch inp.parse_method
                case 'OnePDS_EachCls'
                    out=Atrainpk_parse_AclabelT_subcls(obj.LAT,inp); % see also prep_ResinKits_Molecules_J_rk_4_5_6_3N1
                case 'OnePDS_AllCls'
                    out=Atrainpk_parse_AclabelT_subcls_OnePDS_AllCls(obj.LAT,inp);
            end
        catch
            %%% for original non-PDS parsing applications, e.g. ResinKits, see for example: prep_RK_1_3_VS1120_50Polymers_wRK5_RK6
            % prep_RK_1_3_VS1120_50Polymers_wRK5_RK6() generate 3 sets of parsed results for rk1-4, rk5-6, and rk1-6
            out=Atrainpk_parse_AclabelT_subcls(obj.LAT,inp);% for original non-PDS parsing applications, e.g. ResinKits, see for example: prep_RK_1_3_VS1120_50Polymers_wRK5_RK6
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % where out.oaTP --> object array for TP pairs
        %  and  out.tmpfolder4Save  --> folder to store all TP pairs
        
        end % end of parse_AclabelT_subcls()
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [out]=parse_Consecutive_Block(obj,inp)
            % main function is  ssds_method_parse_Consecutive_Block
            % see example inside --> ssds_method_parse_Consecutive_Block
            %
            % modified from parse_HBpro_consecutive_sequence()
            % key function to run is --> Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp)
            % inp.parse_method set to 'OnePDS_EachCls' inside ssds's method --> parse_AclabelT_subcls_OnePDS_EachCls
            % inp.parse_method_sub can be
            % (1) 'AllPerm' (default) --> default setting that will generate Nfold^ncls pairs of TP files
            % or
            % (2) 'SameFQallCls' --> all Pset have Same FQ for all Cls and only generate Nfold TP pairs
            % see also parse_HBpro_consecutive_sequence_standalone Atrainpk_parse_AclabelT_subcls
            % see also prep_Muscle
            % see also permn
            % see also Atrainpk_parse_AclabelT_subcls  parse_consecutive_sequence_Nfold
            % see also parse_Consecutive_Block MLOCM_QX_or_PX_pickFeat2AT
            disp('work on ssds method --> parse_Consecutive_Block');
            if isempty(obj.pathfname_AT)
                error('pls provide obj.pathfname_AT')
            else
                out=ssds_method_parse_Consecutive_Block(obj.pathfname_AT,inp);
            end
        end
        %%%%%%%%%%%%%%%%%%
        % parse Atrainpk based on sub-class info in AclabelT and leave one PDS (Physically Different Sample) out each time from each class
        % PDS: Physically Different Sample
         function [out]=parse_AclabelT_subcls_OnePDS_EachCls(obj,inp)
        % will parse PDS as one PDS in Pset for each class : inp.parse_method='OnePDS_EachCls';
        % main fuction called by this method is : parse_physically_different_samples()     
        % after parsing, all Atrainpk samples used exactly same number of times as Pset in all TP pairs
        % need to provide the following:
        %   inp.smk1='_PDS'; % this can be any length, e.g."_P" or "_PDS"
        %   inp.smk2=''; % this should not be changed to others
        %
        % try to follow these procedures in the following (see prep_Muscle):
        % sd=ssds(LAT);
        %
        % inp.corename=[fileparts_name_wo_ext(pathfname_rawdata)];;
        % sd_PPd=apply_PP(sd,inp);
        %
        %  inp.smk1='_PDS';inp.smk2=''; % inp.smk1 will be used as smk4PDS in parse_physically_different_samples
        %  sd_PPd.parse_AclabelT_subcls_PDS(inp);
        % see also prep_ResinKits_Molecules_J_rk_4_5_6_3N1(pathfname)
        % see also prep_Muscle and parse_physically_different_samples
        % see also parse_AclabelT_subcls, Atrainpk_parse_AclabelT_subcls(), test_ssds_parse_AclabelT_subcls_method(), ATop.m
        % see doc_Hsiung_jdsu() and prep_Muscle()
        disp('work on parsing by AclabelT_subcls based on leave one PDS out as Pset each time')
        inp.parse_method='OnePDS_EachCls';
        
        if ~exist('inp','var') || ~isfield(inp,'parse_method_sub')
        inp.parse_method_sub='AllPerm'; % or 'SameFQallCls' and 'AllPerm' --> default setting that will generate Nfold^ncls pairs of TP files
        end
         
        out= parse_physically_different_samples(obj.pathfname_AT,inp);% see also prep_ResinKits_Molecules_J_rk_4_5_6_3N1(pathfname)
       % out=Atrainpk_parse_AclabelT_subcls(obj.LAT,inp);
        % where out.oaTP --> object array for TP pairs
        %  and  out.tmpfolder4Save  --> folder to store all TP pairs
        end % end of parse_AclabelT_subcls_PDS()
        %%%%%%%%%%%%%%%%%%
        % parse Atrainpk based on sub-class info in AclabelT
         function [out]=parse_AclabelT_subcls_OnePDS_AllCls(obj,inp)
        % will parse PDS as one PDS in Pset for All classes : inp.parse_method='OnePDS_AllCls';     
        % after parsing, all Atrainpk samples used exactly same number of times as Pset in all TP pairs
        % need to provide the following:
        %  inp.smk1='_PDS';inp.smk2='';
        % modified from Atrainpk_Split_Odd_Even_physical_diff_samp(pathfname_AT)
        % see also Atrainpk_parse_AclabelT_subcls(), test_ssds_parse_AclabelT_subcls_method(), ATop.m
        % see also parse_AclabelT_subcls_PDS prep_Muscle and parse_physically_different_samples
        % see doc_Hsiung_jdsu() and prep_Muscle()
        disp('based on "_OnePDS_AllCls" to work on parsing by AclabelT_subcls for classification apps');
        inp.parse_method='OnePDS_AllCls';
        out=parse_physically_different_samples(obj.pathfname_AT,inp);
        % where out.oaTP --> object array for TP pairs
        %  and  out.tmpfolder4Save  --> folder to store all TP pairs
        
        end % end of parse_AclabelT_subcls()
        %%%%%%%%%%%%%%%%%%
        % merge or remove or extract certain classes in Atrainpk etc 
        function [out_obj]=merge_rm_extract_class(obj,inp)
            % see also rm_cls_AT (NOT ssds method)
            % see --> Atrainpk_SplitCls , Oct 30, 2022
            % after merge/removal/extract, all AclassinfoT should not have any skipping in cls seq number
            % need to provide the following:
            %  inp.cls_pick={};
            %---------------------------------------------------------------------
            %  inp.action:
            %                    'merge_repeat'  % run 'merge' for more than  one set of classes to be merged , see for  example --> assemble_AT_HFA_BP
            %                                             % in this action,  inp.cls_pick should be "cell of cell" data type , % see also: convert_clistclslabel_merged_TO_inp_cls_pick ,see also:  create_Mayne_merged_pairs_in_cMPSS
            %                    inp.merge_clsname ; % with size matched with Nrow in inp.cls_pick, Sept 26, 2023
            %--------------------------------------------------------------------------------------------------------------
            %                    'merge'              % run 'merge' for only one set of classes to be merged
            %                         merge_clsname or  merged_clsname --> 'all' --> %default
            %                         merge_clsname   or  merged_clsname   --> '1st_occur' --> use the first class's name as new merged class's name
            %                    '' or 'rm' or 'remove' --> remove these classes
            %                    'extract' --> extract these classes
            % modified from Atrainpk_merge_classes_ATop()
            % see also Run_ssds_merge_rm_extract_class --> example for running this method
            % see also Atrainpk_merge_classes_ATop asmc_Global_extract_Local,  Atrainpk_merge_classes_ATop(), Atrainpk_merge_classes_Nclusters_ATop() , ATop.m
            % see examples: test_ssds_method_merge_rm_extract_class    prep_PA6_PA66_for_WVL_calibration_in_Clsfr
            % see also rm_cls_AT (NOT ssds method)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % for running two actions see for example: prep_RK_1_3_VS1120_50Polymers(pathfname_VS,pathfname_prev_AT)
            % for running 4 consecutive actions of "merge" see for example:  assemble_AT_HFA_BP(pfn1,pfn2,pfn4,pfn8,inp)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % with updates in Oct 28, 2022 now you can provide inp.corename while calliong merge_rm_extract_class
            % see for example --> prep_PA6_PA66_for_WVL_calibration_in_Clsfr
            % see also:  add_append_classes  and  ssds_method_add_append_classes
            % % see also --> Split_class(obj,inp) and  Atrainpk_SplitCls , Oct 31, 2022
            %=====================================================================================
            disp('work on merge/removal/extract certain classes in Atrainpk etc for classification apps')
            clistcls_tobe_merged=inp.cls_pick;
            if isempty(obj.pathfname_AT)
                obj.pathfname_AT=obj.LAT;
            end

            if strcmp(inp.action,'merge_repeat')
                if iscell(inp.cls_pick{1})

                    inpr.action='merge';
                    for irp=1:length(inp.cls_pick)
                        inpr.cls_pick= inp.cls_pick{irp};
                        try
                        inpr.merge_clsname= inp.merge_clsname{irp};
                        catch
                            try
                        inpr.merge_clsname=  inp.merged_clsname;
                            catch
                          inpr.merge_clsname='';          
                            end
                        end
                        clistcls_tobe_merged=inpr.cls_pick;
                        if irp==1
                            obj_pathfname_AT=     obj.pathfname_AT;
                        else
                            obj_pathfname_AT=   out_irp.pathfname;
                        end
                        out_irp=Atrainpk_merge_classes_ATop(obj_pathfname_AT,clistcls_tobe_merged,inpr);
                    end
                    out=out_irp;

                elseif ischar(inp.cls_pick{1})
                    inp.action='merge';
                    out=Atrainpk_merge_classes_ATop(obj.pathfname_AT,clistcls_tobe_merged,inp);
                else
                    error('can not handle data types in inp.cls_pick for action "merge_repeat''')
                end
            else
                try
                    Ltest=load(obj.pathfname_AT);
                    out=Atrainpk_merge_classes_ATop(obj.pathfname_AT,clistcls_tobe_merged,inp);
                catch
                    out=Atrainpk_merge_classes_ATop(obj.LAT,clistcls_tobe_merged,inp);
                end
              
            end

            sd1=ssds(out.LAT);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %check if Atrainpk_from_saConc match with Atrainpk
            if isfield(out.LAT,'saConc')
                Atrainpk_from_saConc= cat(1,out.LAT.saConc.Atrainpk);
                if ~isequal(out.LAT.Atrainpk,Atrainpk_from_saConc)
                    error('mismatch between  Atrainpk_from_saConc vs Atrainpk')
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            out_obj=sd1;
            out_obj.pathfname_AT=out.pathfname;
            %---------------------------------------------------
            try
                out_obj_aft_saveAT=out_obj.saveAT( inp )  ;   % add inp.corename if it exist, Oct 28, 2022 % updated Oct 30, 2022
            end
            try
                % try to remove newMergeCls subfolder if it is empty, Oct 28, 2022
                [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(fileparts( out.pathfname) ,'','mat')  ;
                if nfile_out==0
                    rmdir( fileparts( out.pathfname)  )  ;
                end
            end
            %================================================
            % will Not remove pathfname_Orig, updated Dec 1, 2022
%             try
% %                 delete(out.pathfname_Orig )  ;     % try to remove pathfname_Orig
%             end
            %================================================
            try
                out_obj.pathfname_AT=out_obj_aft_saveAT.pathfname_AT;       % updated Oct 30, 2022
            catch
                out_obj.pathfname_AT='';
            end
            %-------------------------------------------------
        end % end of merge_rm_extract_class()
        %%%%%%%%%%%%%%%%%%
        %=======================================================================================
        function [out_obj]=extract_class(obj,inp)
            % to deal with extract only, but can output clistclslabel to follow user specified seq ( i.e. inp.cls_pick_specified_seq )
            % ssds method --> extract_class (Feb 17, 2024)
            % main function to call --> Atrainpk_merge_classes_ATop
            % see also: ssds_method_add_append_classes (Feb 17, 2024)
            %---------------------------------------------------
            % modified from merge_rm_extract_class()
            % to deal with extract only, but can output clistclslabel to follow user specified seq
            %
            % created Feb 17, 2024
            %------------------------------------------
            % deal with inp.cls_pick_specified_seq
            
            if isfield(inp,'cls_pick_specified_seq') && ~isempty(  inp.cls_pick_specified_seq )
                str_pss= strwrite_all_delimiter ( row_always(inp.cls_pick_specified_seq ),'   ') ;
                disp(['cls_pick_specified_seq --> ',str_pss  ]  );
                if ~isfield(inp,'cls_pick') || isempty( inp.cls_pick )
                    inp.cls_pick = inp.cls_pick_specified_seq;
                end
            end
            
            % need to provide--> inp.cls_pick
            if isfield(inp,'cls_pick') && ~isempty( inp.cls_pick )   % need to provide--> inp.cls_pick
                
                [out_obj]=ssds_method_extract_class(obj,inp);
                %********************************************************************************************
%                 if false
%                     clistcls_tobe_merged=inp.cls_pick;
%                     if isempty(obj.pathfname_AT)
%                         obj.pathfname_AT=obj.LAT;
%                     end
%                     %-----------------------
%                     inp.action='extract';
%                     %-----------------------
%                     out=Atrainpk_merge_classes_ATop(obj.pathfname_AT,clistcls_tobe_merged,inp);
%                     
%                     sd1=ssds(out.LAT);
%                     out_obj=sd1;
%                     out_obj.pathfname_AT=out.pathfname;
%                 end
                %*************************************************************************************************
            else
                error('pls provide--> inp.cls_pick');
            end
        end  % end of extract_class
        %=======================================================================================
        function [out_obj]=extract_plus_apd_class(o1,o2,inp)
            % extract from o2, plus those fit o1's clistclslabel into o1, then the rest adp to o1
            
            [out_obj]=ssds_method_extract_plus_apd_class(o1,o2,inp);
            
            
            
        end
         %=======================================================================================
        % Split classes in Atrainpk etc
        function [out_obj]=Split_class(obj,inp)
            % main function --> Atrainpk_SplitCls(L1,inp)
            %  provide following two inputs:
            %    e.g.  inp.smk1='_p5'; % in ResinKits dataset where "p5" is at injection molding gate
            %     inp.pathfname_AT=pfn;
            %-----------------------------------
            % % seq of clistlabel_icls based on their appearance order
            %----------------------------------------------------------------
            % see example --> test_ssds_method_Split_class(L1,inp)
            % see also: merge_rm_extract_class(obj,inp)  and  add_append_classes(o1,o2)

            out=Atrainpk_SplitCls(obj.LAT,inp);

            out_obj =out.out_obj;

        end
        %========================================================================================
        % extract or trim down to subset of Pset in AT files with _TP etc 
        % reduce number of samples in Pset but keep Tset the same 
        % and still have _TP pairs format
        % revisit this Feb 13, 2023 --> see --> prep_ResinKit_for_Cloud_Csharp_in_Cmp_SVM_vs_ILM
         function [out_obj]=extract_Pset(obj,inp)
             %  inp.loc --> locations of Pset to be extracted
             %------------------------------------------------------------
             %  inp.cls_pick --> cell of cls name (in clistclslabel format)  to be extracted,   updated Feb 13, 2023
             %  %     see for example (#2) --> prep_ResinKit_for_Cloud_Csharp_in_Cmp_SVM_vs_ILM
             %     see for (better) example (esp  independent example ) --> test_ssds_method_extract_Pset
             %-------------------------------------------------------------
             % see also test_ssds_extract_Pset_method  strrep_keyword_between_markers_wlistRHS
             % see also method: show_rm_samps_OLs
             disp('extract certain samples or classes out of Pset');
             %---------------------------------------------------------------------------------
             if isfield(inp,'cls_pick') && ~isempty( inp.cls_pick )
                 %  use  inp.cls_pick  to find inp.loc in extract_Pset
                 loc_clsnum_Pset=find(ismember(obj.LAT.clistclslabel, inp.cls_pick) );
                 inp.loc=find(ismember(obj.LAT.AclassinfoP,loc_clsnum_Pset));
                 
                 locTrim=setdiff([1:length(obj.LAT.AclassinfoP)],inp.loc);
             elseif isfield(inp,'loc') && ~isempty( inp.loc )
                 locTrim=setdiff([1:length(obj.LAT.AclassinfoP)],inp.loc);
             end
             %----------------------------------------------------------------------------------
             
             LATnew=obj.LAT;
             try
             LATnew.AclabelP(locTrim)=[];
             end
             LATnew.AclassinfoP(locTrim)=[];
             LATnew.Apred(locTrim,:)=[];
             try
              LATnew.RawSpectra.Pset(locTrim,:)=[];   
             end
             try
                 LATnew.PLS.Pset.saConc(locTrim,:)=[];
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             % deal with multiple XBPLs
             if isfield(LATnew,'AclassinfoP_alt') && isfield(LATnew,'clistclslabel_P')
                 LATnew.AclassinfoP_alt(locTrim)=[];
                Q_AclassinfoP_alt= unique(LATnew.AclassinfoP_alt);
                 if length(Q_AclassinfoP_alt)==1 && Q_AclassinfoP_alt<=length(LATnew.clistclslabel_P)
                     LATnew.clistclslabel_P=LATnew.clistclslabel_P(Q_AclassinfoP_alt);
                 else
                     error('mismatch between AclassinfoP_alt and clistclslabel_P')
                 end
                 
             end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             
             out_obj=ssds(LATnew);
             
%              inp.pathfname_AT=textual_replaceBetween(obj.pathfname_AT,'_nsampP','_',num2str(length(inp.loc)));
             inp.pathfname_AT=strrep_keyword_between_markers_wlistRHS(obj.pathfname_AT,'_nsampP',{'_','.mat'},num2str(length(inp.loc)),'keepBoth');
             out_obj.saveAT(inp);
             
             
             
         end % end of extract_Pset method
        %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%
        % this is same as extract_Pset 
        % but naming convention of this function becomes more consistent with other methods
         function [out_obj]=rm_samps_Pset(obj,inp)
        % alias of extract_Pset(obj,inp)
        % which will extract or trim down to subset of Pset in AT files with _TP etc 
        % reduce number of samples in Pset but keep Tset the same 
        % and still have _TP pairs format
        % see also method: show_rm_samps_OLs
        [out_obj]=extract_Pset(obj,inp);
        
         end % end of rm_samps_Pset method
        %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%
        % use show_line_in_figure() to show line seq number within a plot (or Atrainpk etc)
        % or rm certain samples from AT file, only handle Tset alone AT files
         function [out_obj]=show_rm_samps_OLs(obj,inp)
        % 1) inp.action: 'ManualPick' (default) user use mouse to pick and
        % choose which OLs can be removed and use action: 'rm_samps' to
        % remove them
        % 2) inp.action: 'rm_samps' this setting combined with
        % inp.list_samps_seq_rm will remove those OLs and create new AT
        %
        % see also: test_ssds_show_rm_samps_OLs_method
        %  see also: methods in ssds --> rm_samps_Tset
        %
        % see also : show_line_in_figure
        % see also method: rm_samps_Pset or extract_Pset
        % error('still under construction')
        try
        action= inp.action;   
        catch
        action='ManualPick';
        end
        
        figure;hold on;
        LineList=plot(obj.LAT.Atrainpk','linewidth',0.5);
        
        switch action
            case 'ManualPick'
                
                [out_OLs]=show_line_in_figure(LineList);
            case 'rm_samps'
                try
              list_samps_seq_rm=  inp.list_samps_seq_rm; % [4 98 105];
              hp_OLs=plot(obj.LAT.Atrainpk(list_samps_seq_rm,:)','color',color_CH('o'),'marker',marker_CH('p'),'linewidth',2);
              out_OLs=hp_OLs;
              
                catch
                    disp_with_border('pls provide : inp.list_samps_seq_rm !!!');
                    disp_with_border('No OLs removed');
                    out_OLs='';
                    %error()
                end
                
            otherwise
                error('action not supported')
        end
        out_obj.OLs=out_OLs;
        
         end % end of show_rm_samps_OLs method
        %%%%%%%%%%%%%%%%
        % generate new subtype of LAT by providing AclabelT_LC
        % create clistclslabel_LC and calculate AclassinfoMap2LC
        function out_obj=Label_Combination(obj,inp)
        % see also Label_Combination_Mapping and LC    
          disp('generate new subtype of LAT with "AclassinfoMap2LC"')    
            
        out_obj='';    
        end
        %%%%%%%%%%%%%%%%%%
        % generate new subtype of LAT by providing AclabelT_LC
        % create clistclslabel_LC and calculate AclassinfoMap2LC
        function out_obj=LC(obj,inp)
        % alias for Label_Combination
        % see also Label_Combination_Mapping and Label_Combination    
         error('still under construction')   
           out_obj=Label_Combination(obj,inp); 
            
        end
        %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%
        % generate multi-labels classification LAT by comparing LAT.clistclslabel  vs  ILC.(['clistclslabel_',mk1_jA])
        % convert AclassinfoT and AclassinfoP to ILC.AclassinfoT_mk1 and ILC.AclassinfoP_mk1
        function out_obj=Multi_Labels_Classificatoin(obj,inp)
         %    % added Apr 24, 2020
         % % see ppt --> ILC-4cls_vs_ILC-8cls_Split-TP_1stBlock_2ndBlock.pptx
        % see also Atrainpk_add_ILC_ClassinfoTP, test_ssds_method_Multi_Labels_Classification,   and   BatchRun_AutoClsfr_DA_pipeline_HFA
        %    inside  BatchRun_AutoClsfr_DA_pipeline_HFA() see --> handles4Clsfr.L.ILC_atrb_1.Conversion_Table_clsinfo_or_predcls
          disp('generate multi-labels classification LAT');    
           out_obj= Atrainpk_add_ILC_ClassinfoTP(obj.pathfname_AT,inp);
           % out.cfname_wILC --> cell of fname_wILC
           
        end
        %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out_obj=asmc_Global_extract_Local(obj,inp)
            % apply auto based on Global (orig) classes
            % then extract local classes
            % see ppt: "SCiO OTC API ncls2 vs ILM vs ncls10_wPCA_SVM_autoGlobal_vs_autoLocal.pptx"
            % 
        %  need inp: e.g   inp.cls_pick={'C01','C03'};
        % see also: asmc_Orig_Tset_extract_subset() merge_rm_extract_class()
        % 
        inp.action='extract';
          out_obj=  asmc_Orig_Tset_extract_subset(obj.pathfname_AT,inp);
        
        end % end of asmc_Global_extract_Local()
        %%%%%%%%%%%%%%%%%%
        % split Atrainpk into odd vs even for cross validation etc operations
        function [out_obj_Todd_Peven out_obj_Teven_Podd]=Split_Odd_Even(obj)
        % after split, all Atrainpk samples used exactly once in all folds
        % modified from Atrainpk_Split_Odd_Even(pathfname_AT)
        % see also: test_ssds_Split_Odd_Even_method()
        pathfname_AT=obj.pathfname_AT;
        out=Atrainpk_Split_Odd_Even(pathfname_AT);
        
        out_obj_Todd_Peven=ssds(out.pathfname_Todd_Peven);
        out_obj_Teven_Podd=ssds(out.pathfname_Teven_Podd);

        
        end % end of Split_Odd_Even() method
        %%%%%%%%%%%%%%%%%%
        % for PLS applications to split Atrainpk into Nfolds for cross validation etc operations
        function [array_obj_TP_pairs]=parse_Tset_Nfolds_Extr_Tcv(obj,inp)
        % after split, all Atrainpk samples used exactly once in all folds
        % modified from Atrainpk_Split_Odd_Even() and PLS_Tcv()
        % see also:   TP_parsing_Extr_Tcv   test_ssds_split_Nfolds_method()
        disp('work on parse_Tset_Nfolds_Extr_Tcv');
        pfn=obj.pathfname_AT;
%         pfn='C:\work\JDSU\Test_Quant_U2U\Siesler_Data\VS0909\OSW\Atrainpketc_saConc_Caffeine_(M1-105)_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls48_nsamp288.mat';
%         inp.CurAnaName='Caffeine';
%         inp.Tcv_scheme='Odd-Even-Scans' ;                            %  'Odd-Even-Scans'   '1PSSout'   'sqrtNSfolds-Conc'    'Leave-OneConc-Out'
        array_obj_TP_pairs=TP_parsing_Extr_Tcv(pfn,inp);
        
        end % end of split_Nfolds() method
        %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%
        % rm whole Pset, typically used after merge_rm_extract_class etc
        function [out_obj]=rm_Pset(obj)
        % rm whole Pset, typically used after merge_rm_extract_class etc
        % see also: IL2Q ssds.merge_rm_extract_class() 
        %%%%%%%%%%%%%%%%%%%%%
        out_obj = ssds_method_rm_Pset(obj);   % created May 21, 2024
%                 LAT= obj.LAT;
%                 LAT= rmfield(LAT,{'Apred','AclassinfoP','AclabelP'});
%                 try
%                  LAT= rmfield(LAT,{'AclassinfoP_alt'});   
%                 end
%                 
%                 
%                 
%                 try
%                 LAT.RawSpectra=LAT.RawSpectra.Tset;
%                 end
%                 try
%                 LAT.saConc=LAT.PLS.Tset.saConc;
%                 end
%                 try
%                 LAT= rmfield(LAT,'PLS');
%                 end
%                 %%%%%%%%%%%%%%%%%%%%%%%%%
%                 out_obj_tmp=ssds(LAT);
%                 corename=find_keyword_between_markers(fileparts_name_ext( obj.pathfname_AT),'(',')');
%                 if isempty(corename)
%                     corename=find_keyword_between_markers(fileparts_name_ext( obj.pathfname_AT),'{','}');
%                     if ~isempty(corename)
%                        corename=['{',corename,'}']; 
%                     else
%                         corename='';
%                     end
%                 else
%                    corename=['(',corename,')']; 
%                 end
%                 inp.corename=corename;
%                 out_obj_tmp2=out_obj_tmp.saveAT(inp);
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 out_obj=out_obj_tmp2;
        end % end of rm_Pset method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % rm certain samples in Tset only
        function [out_obj]=rm_samps_Tset(obj,inp)
        % rm certain samples in Tset only
        % only handle AT with Tset alone
        % can Not handle AT with TP_pair or both Tset and Pset exist !!!
        %-------------------------------------------------------------------------------------
        % must provide --> inp.loc_rm 
        % otherwise should provide inp.label_rm
        % for method rm_samps_Tset(obj,inp) must provide inp.loc_rm otherwise should provide inp.label_rm (see Rm_select_samps_AclabelT_wRepSeq)   % updated Jan 31, 2021
        % see Rm_select_samps_AclabelT_wRepSeq, and "AclabelT_wRepSeq" is a reserved word created by tag_AclabelT_ReplicateSeq
        %  updated Jan 31, 2021
        % --------------------------------------------------------------------------------------
        % see also: IL2Q   rm_samps_AT (Not ssds method)
        %%%%%%%%%%%%%%%%%%%%%
               % checking: can Not handle AT with TP_pair or both Tset and Pset exist !!!
               if isfield(obj.LAT,'PLS')
                   error('can Not handle AT with TP_pair i.e. both Tset and Pset exist !!!')
               end
%                pathfname_AT=obj.pathfname_AT;
%                if isempty(pathfname_AT)
%                    inp4sa.corename='';
%                    obj_with_pathfname=obj.saveAT(inp4sa);
%                    pathfname_AT=obj_with_pathfname.pathfname_AT;
%                else
% %                    sd_pfn=ssds(obj.pathfname_AT);
% %                    sd_pfn.LAT=obj.LAT;  % make sure that LAT in obj.LAT matches that in obj.pathfname_AT, May 5, 2024
%                     inp4sa.corename='';
%                    obj_with_pathfname=obj.saveAT(inp4sa);
%                    pathfname_AT=obj_with_pathfname.pathfname_AT;
%                end
%                %=========================================================
               inp4sa.corename='';
               obj_with_pathfname=obj.saveAT(inp4sa);
               pathfname_AT=obj_with_pathfname.pathfname_AT;
               %=========================================================
               % old approach
               %out=rm_samps_AT(pathfname_AT,inp);
               %out_obj=ssds(out.pathfname_new); % very important to add this step
               %==========================================================================================
               if ~isfield(inp,'loc_rm') && isfield(inp,'label_rm')        % for method rm_samps_Tset(obj,inp) must provide inp.loc_rm otherwise should provide inp.label_rm (see Rm_select_samps_AclabelT_wRepSeq)   % updated Jan 31, 2021
                   L=load(pathfname_AT);
                   if isfield(L,'AclabelT_wRepSeq') && length(L.AclabelT_wRepSeq)==length(L.AclassinfoT)
                       [lia,locb] = ismember(L.AclabelT_wRepSeq,inp.label_rm);
                       inp.loc_rm=find(lia);
                       % check
                       if length(inp.loc_rm)~=length(inp.label_rm)
                           error('not all inp.label_rm were found ?')
                       end
                   elseif  isfield(L,'AclabelT') && length(L.AclabelT)==length(L.AclassinfoT)          % updated Nov 29, 2022
                       [lia,locb] = ismember(L.AclabelT,inp.label_rm);
                       inp.loc_rm=find(lia);
                       % check
                       if length(inp.loc_rm)~=length(inp.label_rm)
                           error('not all inp.label_rm were found ?')
                       end
                   else
                       error('need to provide "AclabelT_wRepSeq" with same size as AclassinfoT, see tag_AclabelT_ReplicateSeq.m for creating it')
                   end
               end
               %==========================================================================================
               out_obj=rm_samps_AT(pathfname_AT,inp); %new approach % see Rm_select_samps_AclabelT_wRepSeq, and "AclabelT_wRepSeq" is a reserved word created by tag_AclabelT_ReplicateSeq
               
               
        end % end of rm_samps_Tset method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % rm certain samples in Pset of TP pairs and only work for PLS type datasets
        function [out_obj]=rm_samps_Pset_in_TPpair(obj,inp)
        % rm certain samples in Tset only
        % only handle AT with Tset alone
        % can Not handle AT with TP_pair or both Tset and Pset exist !!!
        % must provide --> inp.loc_rm
        % see also: IL2Q   rm_samps_AT (Not ssds method)
        %%%%%%%%%%%%%%%%%%%%%
               % checking: can Not handle AT with TP_pair or both Tset and Pset exist !!!
               if strcmp(obj.type_Model,'PLS')
                   if ~isfield(obj.LAT,'PLS')
                       error('there is no Pset, if you need to rm_samps from Tset, pls use ssds method --> rm_samps_Tset !!!')
                   end
               end
               Pset=obj.P2T;
               
              % pathfname_AT=obj.pathfname_AT;
 %------------------------------------------------------------------------------------------------------------------------------------             
               pathfname_AT_Pset=Pset.pathfname_AT;                 
               
               if isempty(pathfname_AT_Pset)
               inp4sa.corename='';
               Pset_with_pathfname=Pset.saveAT(inp4sa);
               pathfname_AT_Pset=Pset_with_pathfname.pathfname_AT;
               end
%-------------------------------------------------------------------------------------------------------------------------               
               % old approach
               %out=rm_samps_AT(pathfname_AT,inp);
               %out_obj=ssds(out.pathfname_new); % very important to add this step
               
               out_obj_Pset=rm_samps_AT(pathfname_AT_Pset,inp); %new approach
               
               Tset=obj.rm_Pset;
               
               out_obj=Tset>out_obj_Pset;
               if isfield(inp,'corename') && ~isempty(inp.corename)
                   out_obj=out_obj.saveAT(inp);
               end
               
        end % end of rm_samps_Pset_in_TPpair method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % rm certain samples in Pset or Tset of TP pairs and may only work for Clsfr type datasets
        function [out_obj]=rm_samps_Pset_or_Tset_in_TPpair(obj,inp)
        % rm certain samples in Pset or Tset and only work for Clsfr type datasets
        % must provide --> both inp.loc_rm_Pset and inp.loc_rm_Tset !!! if loc_rm_Tset missing, it will be filled by [];
        %
        % July 15, 2020
        % see also: prepare_ResinKits_close_classes
        % see for example --> KT_CFP_GM_SVM_Rm_S70 (July 5, 2024)
        %%%%%%%%%%%%%%%%%%%%%
               % checking: can Not handle AT with TP_pair or both Tset and Pset exist !!!
               if ~strcmp(obj.type_Model,'Clsfr')
                       warning('this may only work for Clsfr type datasets ? !!!')
                       Speak_mk('this may only work for Clsfr type datasets ? !!!')
               end
               Pset=obj.P2T;
               
              % pathfname_AT=obj.pathfname_AT;
               pathfname_AT_Pset=Pset.pathfname_AT;
               
               if isempty(pathfname_AT_Pset)
               inp4sa.corename='';
               Pset_with_pathfname=Pset.saveAT(inp4sa);
               pathfname_AT_Pset=Pset_with_pathfname.pathfname_AT;
               end
               
               % old approach
               %out=rm_samps_AT(pathfname_AT,inp);
               %out_obj=ssds(out.pathfname_new); % very important to add this step
               
               inp_P.loc_rm=inp.loc_rm_Pset;
               try
                   inp_P.corename=inp.corename;
               catch
                   inp_P.corename='';
               end
               out_obj_Pset=rm_samps_AT(pathfname_AT_Pset,inp_P); %new approach
               %%%%%%%%%%%%%%%%%%%
               Tset=obj.rm_Pset;
               pathfname_AT_Tset=Tset.pathfname_AT;
               try
                inp_T.loc_rm=inp.loc_rm_Tset;
               catch
                 inp_T.loc_rm=[];  % if loc_rm_Tset missing, it will be filled by [];
               end
                out_obj_Tset=rm_samps_AT(pathfname_AT_Tset,inp_T); %new approach
                
               if isfield(inp,'loc_rm_Pset') && ~isempty(inp.loc_rm_Pset)
                inp.corename =  get_corename_pfn(out_obj_Pset.pathfname_AT);
                inp.corename=strrep(inp.corename,'}','_Pset}');
               end
               
               out_obj=out_obj_Tset>out_obj_Pset;
               if isfield(inp,'corename') && ~isempty(inp.corename)
                   out_obj=out_obj.saveAT(inp);
               end
               
        end % end of rm_samps_Pset_in_TPpair method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [out_obj]=T_plus_P(obj,inp)
            % see examples in --> ssds_method_T_plus_P
            % very important, must provide output, i.e. out_obj in this case !!!
            % very important, must provide output, i.e. out_obj in this case !!!
            % very important, must provide output, i.e. out_obj in this case !!!
            %%%%%%%%%%%%%%%%%%%
            if nargin==1
                inp='';
            end
            if isa(obj,'ssds')
                pfn=obj.pathfname_AT;
            end
            out_obj=  ssds_method_T_plus_P(pfn,inp);
        end% end of ssds_method --> T_plus_P
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%
        % this method add or append two Clsfr Tset with ncls1 and ncls2 into ncls1+ncls2 classes, Sept 29, 2022
        function out_obj= add_append_classes(o1,o2,inp)  %Here is an overload of the MATLAB plus function. It defines addition for this class as adding the property values:
            % see examples in --> ssds_method_add_append_classes
            % main function to call --> ssds_method_add_append_classes
            % see also: ssds_method_plus and Atrainpk_SplitCls
            if nargin==3
             out_obj=ssds_method_add_append_classes(o1,o2,inp);   
            else
            out_obj=ssds_method_add_append_classes(o1,o2);
            end
        end  % end of "add_append_classes" method
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  function [out_obj]=clistclslabel_sort(obj)
      % see example in --> BuildBlock_summary_CmbLib_B5_RK
      %%%%%%%%%%%%%%%%%%%
      if isa(obj,'ssds')
          try
              pfn=obj.pathfname_AT;
          end
          L=obj.LAT;
      elseif isstruct(obj)
          L=obj;
      end
      %+++++++++++++++++++++++++++++++++
      clistclslabel_orig=L.clistclslabel;
      clistclslabel_sort=sort( clistclslabel_orig );
      [lia,locb] =  ismember(clistclslabel_orig, clistclslabel_sort) ;
      L_sort=L;
      L_sort.clistclslabel=clistclslabel_sort;
      L_sort.AclassinfoT=replace_CH(L.AclassinfoT,[1:length(locb)],locb );
      try
          L_sort.AclassinfoP=replace_CH(L.AclassinfoP,[1:length(locb)],locb );
      end
      out_obj =ssds(L_sort) ;
  end% end of ssds_method --> clistclslabel_sort
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %========================================================================
  function [out_obj]=clistclslabel_sort_rm_source(obj,inp)
      % see example in --> KT_combine_B5_RK_DS_source
      % need to provide --> inp.DS_source (e.g. 'RK' or 'LAf')
      if all(cellfun(@(x) ~isempty(strfind(x,['_', inp.DS_source] )),obj.LAT.clistclslabel))
          %           sd_rk=ssds(Lrk);
          %++++++++++++++++++++++++++++
          sd_rk=obj.clistclslabel_sort;
          sd_rk.LAT.clistclslabel=strrep(sd_rk.LAT.clistclslabel,['_',inp.DS_source],'');   % rm_source
          %     %--------------------------
          out_obj=ssds( sd_rk.LAT);  % sort & rm_source
          %++++++++++++++++++++++++++++
      else
          error(['can not find DS_source --> ', inp.DS_source]);
      end
  end  % end of ssds_method --> clistclslabel_sort_rm_source
    %========================================================================
    % following methods will be Rm for KT
    %========================================================================%========================================================================
     %========================================================================%========================================================================
 %=============================================================================================
  function [out_obj]=clistclslabel_sortnat(obj)
      % see example in --> BuildBlock_summary_CmbLib_B5_RK
      
      %%%%%%%%%%%%%%%%%%%
      if isa(obj,'ssds')
          try
              pfn=obj.pathfname_AT;
          end
          L=obj.LAT;
      elseif isstruct(obj)
          L=obj;
      end
      %+++++++++++++++++++++++++++++++++
      clistclslabel_orig=L.clistclslabel;
      clistclslabel_sort=sortnat( clistclslabel_orig );
      [lia,locb] =  ismember(clistclslabel_orig, clistclslabel_sort) ;
      L_sort=L;
      L_sort.clistclslabel=clistclslabel_sort;
      L_sort.AclassinfoT=replace_CH(L.AclassinfoT,[1:length(locb)],locb );
      try
          L_sort.AclassinfoP=replace_CH(L.AclassinfoP,[1:length(locb)],locb );
      end
      out_obj =ssds(L_sort) ;
  end% end of ssds_method --> clistclslabel_sortnat
  %=================================================================
  % EB sort etc
  function [out_obj]=clistclslabel_rm_source_sort(obj,inp)
      % see example in --> KT_combine_B5_RK_DS_source
      % need to provide --> inp.DS_source (e.g. 'RK' or 'LAf')
      if all(cellfun(@(x) ~isempty(strfind(x,['_', inp.DS_source] )),obj.LAT.clistclslabel))
          %           sd_rk=ssds(Lrk);
          %++++++++++++++++++++++++++++
%           sd_rk=obj.clistclslabel_sort;
          sd_rk=obj;
          sd_rk.LAT.clistclslabel=strrep(sd_rk.LAT.clistclslabel,['_',inp.DS_source],'');   % rm_source
          sd_rk=sd_rk.clistclslabel_sort;
          %     %--------------------------
          out_obj=ssds( sd_rk.LAT);  % sort & rm_source
          %++++++++++++++++++++++++++++
      else
          error(['can not find DS_source --> ', inp.DS_source]);
      end
  end  % end of ssds_method --> clistclslabel_rm_source_sort
  
    %========================================================================  
     %========================================================================
  % EB sort etc
  function [out_obj]=clistclslabel_sortnat_rm_source(obj,inp)
      % see example in --> KT_combine_B5_RK_DS_source
      % need to provide --> inp.DS_source (e.g. 'RK' or 'LAf')
      if all(cellfun(@(x) ~isempty(strfind(x,['_', inp.DS_source] )),obj.LAT.clistclslabel))
          %           sd_rk=ssds(Lrk);
          %++++++++++++++++++++++++++++
          sd_rk=obj.clistclslabel_sortnat;
          sd_rk.LAT.clistclslabel=strrep(sd_rk.LAT.clistclslabel,['_',inp.DS_source],'');   % rm_source
          %     %--------------------------
          out_obj=ssds( sd_rk.LAT);  % sort & rm_source
          %++++++++++++++++++++++++++++
      else
          error(['can not find DS_source --> ', inp.DS_source]);
      end
  end  % end of ssds_method --> clistclslabel_sortnat_rm_source
    %========================================================================
    function [out_obj]=run_CFP_GM_sortTcls(obj,inp)
        % see example in --> BatchRun_CFP_SVM_maxDV_FOM , two_stages_CFP_forcePredict , ScanThru_two_stages_CFP_forcePredict
        %
        %======================================================%========================================================================
        cd(find_last_nonTMP_path);
        pathTMP=tmp_folder_rm_mk('TMP_2SCFP',pwd);
        cd(pathTMP );
        %----------------------------------------------------
        inp.dvABC_by_kt_yes=1;
        inp.Clsfr_Global='SVM_linear_wDecVal_APs';
        inp.Clsfr_force_Predict='SVM_linear_wDecVal_APs';
        inp.dvB_PDS_yes=0;
        inp.InsituThres_scheme= 'IV' ;
        inp.CFP_dvABC_SVM_kernel= 'rbf' ;
        inp.iGM= 1;
        inp.nGM=1;
        Out=BatchRun_CFP_SVM_maxDV_FOM( obj.pathfname_AT, inp );
        out_obj=Out;
        %--------------------------------------------------------------------------
        cd(find_last_nonTMP_path);
        %----------------------------------------------------
    end  % end of ssds_method --> run_CFP_GM_sortTcls
    %==========================================================================
     function [out_obj]=run_CFP_GM_kt(obj,inp)
        % see example in --> kt_BatchRun_CFP_SVM_maxDV_FOM
        %
        %======================================================%========================================================================
        cd(find_last_nonTMP_path);
        pathTMP=tmp_folder_rm_mk('TMP_2SCFP',pwd);
        cd(pathTMP );
        %----------------------------------------------------
        inp.dvABC_by_kt_yes=1;
        inp.Clsfr_Global='SVM_linear_wDecVal_APs';
        inp.Clsfr_force_Predict='SVM_linear_wDecVal_APs';
        inp.dvB_PDS_yes=0;
        inp.InsituThres_scheme= 'IV' ;
        inp.CFP_dvABC_SVM_kernel= 'rbf' ;
        inp.iGM= 1;
        inp.nGM=1;
        Out=ssds_method_run_CFP_GM_kt( obj.pathfname_AT, inp );
        out_obj=Out;
        %--------------------------------------------------------------------------
        cd(find_last_nonTMP_path);
        %----------------------------------------------------
    end  % end of ssds_method --> run_CFP_GM_sortTcls
    
    
    
    
    
    
    
  
  %========================================================================================================================================================
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end  % end for methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
end  % end for classdef


%% ==========================================================================================
%% LOCAL FUNCTIONS FOR ssds  (closure of ssds; every function end-terminated)
%% Appended so the ssds class is self-contained: MATLAB local functions are
%% file-private, so ssds's helpers must live in THIS file to be reachable by
%% the class methods. (Same helpers also live as locals inside AQP_gui.m.)
%% ==========================================================================================


%% ----- from AT_replace_clistclslabel.m ------------------------------------
function out=AT_replace_clistclslabel(pfn_AT,inp)
% typically called by --> AT2XLS_ACP
% see also: AT2XLS_ACP
% see also: AT_match_clistclslabel  AT_sortBy_clistclslabel
%======================================================================
if false
    
    cc
    pfn_AT='C:\work\JDSU\Test_ACP\RK4NSEdemo\ATetc_Carpet_fVS_wNoMatch\Carpet_fVS_Only\Atrainpketc_{T-(T2_20230803_VS_TrainSet)_P-(T2_20230803_VS_PredSet_Correct-Pset)}_nvar119_ncls6_nsampT225_nsampP75.mat';
    inp.clistclslabel_replace={...
        '[Carpet]-N6','Nylon-6';...
        '[Carpet]-PET','PET';...
        '[Carpet]-WOOL','WOOL';...
        };
    out=AT_replace_clistclslabel(pfn_AT,inp)
    %---------------------------------------------------------------------------------------------
    % prepare RK_Big7 to match with orig Big7, Jan 6, 2024
    
    cc
    pfn_AT='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_RK_Big7\Atrainpketc_{T-109-105_P-EdEmLS_rm4OLs_chgID3_fixAclabelT_(RK_Big7)}_LocalAutoStudy_nvar119_ncls7_nsampT294_nsampP135.mat'
    %     pfn_AT_orig_Big7='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_Big7\Atrainpketc_{Big5+PC}_nvar119_ncls7_nsampT610_nsampP585.mat'
    
    inp.clistclslabel_replace={...
        'PolyStyrene - General Purpose','PS';...
        'Thermoplastic Polyester (PETG)','PET';...
        'Polycarbonate','PC';...
        'Polyethylene - Low Density' ,'LDPE';...
        'Polyethylene - High Density' ,'HDPE';...
        'Polypropylene - Homopolymer' ,'PP';...
        'Polyvinyl Chloride - Flexible' ,'PVC';...
        };
 
    out=AT_replace_clistclslabel(pfn_AT,inp)
     %---------------------------------------------------------------------------------------------
    % prepare RK_Big7 to match with orig Big7, Jan 6, 2024
    
    cc
    %     pfn_AT='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_RK_Big7\Atrainpketc_{T-109-105_P-EdEmLS_rm4OLs_chgID3_fixAclabelT_(RK_Big7)}_LocalAutoStudy_nvar119_ncls7_nsampT294_nsampP135.mat'
    pfn_AT='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_Big7\Atrainpketc_{Big5+PC}_nvar119_ncls7_nsampT610_nsampP585.mat'
    
    inp.clistclslabel_replace={...
        'Polycarbonate','PC';...
        };
    
    out=AT_replace_clistclslabel(pfn_AT,inp)
    %-------------------------------------------------------------------------
    % replace RK Sn in AclabelT or AclabelP by real polymer names from clistclslabel , Apr 7, 2024
    
    %
   
     %-------------------------------------------------------------------------
    
end

%--------------------------------------------------
if ischar(pfn_AT)
    L=load(pfn_AT);
elseif isstruct(pfn_AT)
    L=   pfn_AT;
else
    error('pfn_AT should be either ischar or isstruct');
end
% deal with inp.clistclslabel_replace
if exist('inp','var')&& isfield(inp,'clistclslabel_replace')&& ~isempty(inp.clistclslabel_replace )
    %     clistclslabel_new=L.clistclslabel;
    disp('deal with inp.clistclslabel_replace');
    clistclslabel_old=L.clistclslabel;
%     clistclslabel_new = textual_replace_exact(L.clistclslabel,inp.clistclslabel_replace(:,1),inp.clistclslabel_replace(:,2));
        clistclslabel_new =row_always( inp.clistclslabel_replace(:,2));
    loc_replace=find(~ismember(clistclslabel_old,clistclslabel_new));
    if length(loc_replace )~=length(inp.clistclslabel_replace(:,1) )
        error('some items in clistclslabel Not replaced ?');
    else
         L.clistclslabel=clistclslabel_new;
%          sloc_replace=strwrite_all_delimiter( cellstr(  string(row_always(loc_replace))),'_');
         sloc_replace= strwrite_all_delimiter_numeric_input( loc_replace,'_' );
         try
             fname_new=strrep(fileparts_name_ext( pfn_AT),'.mat',['_ClsRep',sloc_replace  ,'.mat']);
             save(fname_new,'-struct','L');
             disp_with_border([fname_new,' has been created']);
             out.pfn_AT_new=fname_new;
         end
         out.Lnew=L;
    end
end
end


%% ----- from AT_reseq_clistclslabel.m --------------------------------------
function out=AT_reseq_clistclslabel(pfn_AT,inp)
% must provide same size as clistclslabel --> inp.cls_pick_specified_seq
% check size and "content" of clistclslabel vs inp.cls_pick_specified_seq
% see also: ssds method --> extract_class
% see also: ssds_method_extract_class
% see also: ismember
%=====================================================================
if false
     %===============================================================================
     
    % Feb 21, 2024
    % test to use this to reseq clistclslabel
    cc
    %-----------
    pfn_AT='C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat';% seq Not important, they depend on their orig seq in L2
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    L1=load( pfn_AT);
    inp.cls_pick_specified_seq=flipud(L1.clistclslabel); % seq now is important, they follow cls_pick_specified_seq
    %-------------
    out=AT_reseq_clistclslabel(pfn_AT,inp)
    %+++++++++++++++++++++++++++++++++++++++++++++++++++
    % July 6, 2024 KT
    % July 7, 2024 --> RK_EdEmLS_P2T
    % see also: KT_RK_EdEmLS_P2T_PET_PP_PS_PVC
    cc
%     pfn_AT='C:\work\JDSU\KT\ATetc_PlasticsRecycle\ATetc_T-RK_B5_P-SKZ\RK\Atrainpketc_{T-109-105_P-EdEmLS_shortname}_(Cls-1_18_27_29)_nvar119_ncls4_nsamp168.mat'
    pfn_AT='C:\work\JDSU\KT\ATetc_PlasticsRecycle\ATetc_cmb_RK_B5\Atrainpketc_{RK_EdEmLS_P2T_PET_PP_PS_PVC}_nvar119_ncls4_nsamp78.mat'
    
     L1=load( pfn_AT);
    inp.cls_pick_specified_seq=sort(L1.clistclslabel); % seq now is important, they follow cls_pick_specified_seq
    %-------------
    out=AT_reseq_clistclslabel(pfn_AT,inp)

    
    
    
    %===============================================================================
    
end
%============================================================================================
%---------------------------------------------------
 sd1=ssds(pfn_AT);

% check size and "content" of clistclslabel vs inp.cls_pick_specified_seq
if length(inp.cls_pick_specified_seq)~=length(sd1.LAT.clistclslabel)
    error('mismatch in size of inp.cls_pick_specified_seq vs sd1.LAT.clistclslabel');
else
   [lia,locb] =ismember(inp.cls_pick_specified_seq,sd1.LAT.clistclslabel);
    if ~all(lia)
         error('mismatch in "content" of inp.cls_pick_specified_seq vs sd1.LAT.clistclslabel');
    end
end
%-----------------------------------------------------------
inp.action='extract';
% o2x=merge_rm_extract_class(sd2,inp);
o1x=extract_class(sd1,inp);  % modified from merge_rm_extract_class() % to deal with extract only, but can output clistclslabel to follow user specified seq

o1x.LAT.clistclslabel ;
% inp.corename=['{',strwrite_all_delimiter(inp.cls_pick_specified_seq,' '),'}'];
inp.corename=strrep(get_corename_pfn(pfn_AT),'}',['_clistclslabel_Reseq}']);

o1x=o1x.saveAT(inp);
%-------------------------------------------
out.pfn_AT_new=o1x.pathfname_AT;
 out.Lnew=o1x.LAT;
 %---------------------------------------
done_with_this_function;
end


%% ----- from AT_sortBy_WinCls1st_sortTcls.m --------------------------------
function out=AT_sortBy_WinCls1st_sortTcls(pfn_AT, inp)
% need inp.winner_clsnum & inp.winner_clistclslabel
% will be labelled as 'WinCls1st'                                     or                             'WinCls1st[inp.winner_clistclslabel]'
% modified from AT_sortBy_clistclslabel_sortTcls to deal with sign of DecVal in binary libsvm
% see also: BatchRun_CFP_SVM_maxDV_FOM   ,   maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone
% ---------------------------------------------------------------------------------------------------------------------------
% see also: AT_sortBy_clistclslabel_sortTcls_sortPcls (end of July, 2024)
% modified from AT_sortBy_clistclslabel, end of July, 2024
% only deal with Atrainpk etc (Tset) part
% see also: libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto, typically called by --> iACP_switch_Clsfr_ACP (inside family of iACPmp_gui )
% see also: AT_match_clistclslabel AT_replace_clistclslabel
%==========================================================================
if false
    

   
    %---------------------------------------------------------
    % revisit end of July, 2024
    % during kt for CFP GM
    cc
    pfn_AT='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\Atrainpketc_{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)_nvar119_ncls4_nsampT224_nsampP240.mat';
    inp.winner_clsnum=2;  inp.winner_clistclslabel='PP'; 
    out=AT_sortBy_WinCls1st_sortTcls(pfn_AT,inp)
    
    %---------------------------------------------------------
     % revisit end of July, 2024
    % during kt for CFP GM
    cc
    pfn_AT='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\Atrainpketc_{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)_nvar119_ncls4_nsampT224_nsampP240.mat';
%     inp.winner_clsnum=1;  inp.winner_clistclslabel='PET'; 
%       inp.winner_clsnum=3;  inp.winner_clistclslabel='PTT'; 
            inp.winner_clsnum=4;  inp.winner_clistclslabel='TP'; 

    out=AT_sortBy_WinCls1st_sortTcls(pfn_AT,inp)
    
    
end
%===================================================

L=load(pfn_AT);

% checking 
if ~strcmp(L.clistclslabel{ inp.winner_clsnum }, inp.winner_clistclslabel )
error('Mismatch between  inp.winner_clsnum & inp.winner_clistclslabel ?');
end
Atrainpk_new=[];
AclassinfoT_new=[];
AclabelT_new=[];
AclabelT_new_alt=[];
AclabelT_new_MID=[];
AclabelT_new_SupCls=[];
RawSpectra_new=[];

for icls=1:2
    if icls==1
        loc_icls=find(L.AclassinfoT==inp.winner_clsnum);
    elseif icls==2
        loc_icls=find(L.AclassinfoT~=inp.winner_clsnum);
    end
    Atrainpk_new=[Atrainpk_new ; L.Atrainpk(loc_icls,:)  ];
    AclassinfoT_new=[AclassinfoT_new ; L.AclassinfoT(loc_icls,:)  ];
    try
    RawSpectra_new=[RawSpectra_new ; L.RawSpectra(loc_icls,:)  ];
    end
     AclabelT_new=[AclabelT_new ; L.AclabelT(loc_icls,:)  ];
     try
     AclabelT_new_alt=[AclabelT_new_alt ; L.AclabelT_alt(loc_icls,:)  ];
     AclabelT_new_MID=[AclabelT_new_MID ; L.AclabelT_MID(loc_icls,:)  ];
     AclabelT_new_SupCls=[AclabelT_new_SupCls ; L.AclabelT_SupCls(loc_icls,:)  ];
     end
end



Lnew=L;
Lnew.Atrainpk=Atrainpk_new;
Lnew.AclassinfoT=AclassinfoT_new;
Lnew.AclabelT=AclabelT_new;
if ~isempty(RawSpectra_new)
Lnew.RawSpectra=RawSpectra_new;
end
%-------------------------------------------
try
Lnew.AclabelT_alt=AclabelT_new_alt;
Lnew.AclabelT_MID=AclabelT_new_MID;
Lnew.AclabelT_SupCls=AclabelT_new_SupCls;
end
%-----------------------------------------
sd1=ssds(Lnew);
% inp.corename=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar'),'sortByclistclslabel'];
inp.corename_0=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar')];

sWinCls1st=['_WinCls1st','[',inp.winner_clistclslabel,']'];

inp.corename=strrep(inp.corename_0,'}',[sWinCls1st,'}']) ;
if strcmp(inp.corename,inp.corename_0)
 inp.corename=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar'),sWinCls1st(2:end)];   
end

sd2=sd1.saveAT(inp);
% out=sd2.pathfname_AT;
out.obj=sd2;
out.pathfname_AT=sd2.pathfname_AT;

done_with_this_function;
end


%% ----- from AT_sortBy_clistclslabel_sortCls.m -----------------------------
function out=AT_sortBy_clistclslabel_sortCls(pfn_AT)
% typically called by maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone
%==========================================================================
if false
    %---------------------------------------------------------
    % revisit end of July, 2024
    % 
    cc
    pfn_AT='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\Atrainpketc_{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)_nvar119_ncls4_nsampT224_nsampP240.mat'
    out=AT_sortBy_clistclslabel_sortCls(pfn_AT)
    
    %---------------------------------------------------------

    %---------------------------------------------------------
    cc
    pfn_AT='C:\SFV\PREV\Extract_iACPmp_gui_012123\CARE_alone_ncls4\sortTcls_fix_RS_indvT_vs_P\Atrainpketc_{Pset_in_ApdCls-N6_S3_T-103_P-105_sortTcls_CARE_alone_nTU1_1_PET_PP_PTT_TP_T-103_P-105_sortTcls}_nvar119_ncls4_nsamp240.mat'
    out=AT_sortBy_clistclslabel_sortCls(pfn_AT)
    
    %---------------------------------------------------------
    % revisit Aug
    cc
   pfn_AT= 'C:\work\JDSU\KTaug\ATetc_Tset_Seq\LAf_alone_Bef_Aft_Rm-PP_S70\Rm_S70_PP_LAf\Atrainpketc_{ATetc_LAf_Only_ncls4--xU_nTU1_[1]_rm5OLs_Pset}_nvar119_ncls4_nsampT1010_nsampP1015.mat'
    out=AT_sortBy_clistclslabel_sortCls(pfn_AT)
    
    
end
%===================================================

L=load(pfn_AT);

Atrainpk_new=[];
AclassinfoT_new=[];
AclabelT_new=[];
AclabelT_new_alt=[];
AclabelT_new_MID=[];
AclabelT_new_SupCls=[];

RawSpectra_new=[];
for icls=1:length(L.clistclslabel)
    loc_icls=find(L.AclassinfoT==icls);
    Atrainpk_new=[Atrainpk_new ; L.Atrainpk(loc_icls,:)  ];
    AclassinfoT_new=[AclassinfoT_new ; L.AclassinfoT(loc_icls,:)  ];
    %----------------------------------------------------------------------
    try
    RawSpectra_new=[RawSpectra_new ; L.RawSpectra(loc_icls,:)  ];
    end
    %-------------------------------------------------------------------------
     AclabelT_new=[AclabelT_new ; L.AclabelT(loc_icls,:)  ];
     try
     AclabelT_new_alt=[AclabelT_new_alt ; L.AclabelT_alt(loc_icls,:)  ];
     AclabelT_new_MID=[AclabelT_new_MID ; L.AclabelT_MID(loc_icls,:)  ];
     AclabelT_new_SupCls=[AclabelT_new_SupCls ; L.AclabelT_SupCls(loc_icls,:)  ];
     end
end
Lnew=L;
Lnew.Atrainpk=Atrainpk_new;
Lnew.AclassinfoT=AclassinfoT_new;
Lnew.AclabelT=AclabelT_new;
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if ~isempty(RawSpectra_new )
    Lnew.RawSpectra=RawSpectra_new;
end
%-------------------------------------------
try
Lnew.AclabelT_alt=AclabelT_new_alt;
Lnew.AclabelT_MID=AclabelT_new_MID;
Lnew.AclabelT_SupCls=AclabelT_new_SupCls;
end
%-----------------------------------------
sd1=ssds(Lnew);
% inp.corename=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar'),'sortByclistclslabel'];
inp.corename_0=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar')];
% inp.corename=strrep(inp.corename_0,'}',['_sortTcls}' ]) ;
inp.corename=strrep(inp.corename_0,'}',['_sortCls}' ]) ;

if strcmp(inp.corename,inp.corename_0)
 inp.corename=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar'),'sortTcls'];   
end

sd2=sd1.saveAT(inp);
% out=sd2.pathfname_AT;
out.obj=sd2;
out.pathfname_AT=sd2.pathfname_AT;

done_with_this_function;
end


%% ----- from AT_sortBy_clistclslabel_sortTcls.m ----------------------------
function out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
% note that in --> AT_sortBy_clistclslabel_sortCls , RS may Not sorted !!!
%---------------------------------------------------------------------------------------------
% see also: AT_sortBy_clistclslabel_sortTcls_sortPcls (end of July, 2024)
% see also: AT_sortBy_WinCls1st_sortTcls (end of July, 2024)
%----------------------------------------------------------------------------------
% modified from AT_sortBy_clistclslabel, end of July, 2024
% only deal with Atrainpk etc (Tset) part
% see also: libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto, typically called by --> iACP_switch_Clsfr_ACP (inside family of iACPmp_gui )
% see also: AT_match_clistclslabel AT_replace_clistclslabel
%+++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also: maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone (end of July, 2024)
%---------------------------------------------------------------
% fix_RS, July 25, 2024
%==========================================================================
if false
    
    cc
     pfn_AT='C:\work\JDSU\Test_ACP\Plastics_Recycle\ATetc_SKZ\SKZ1\ncls22\Atrainpketc_{SKZ_final_German_LS_May9_SKZ1_SuperClass}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls22_nsamp941.mat'
    out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
    %-------------------------------------------
    % include AclabelT_alt _MID _SupCls
     cc
     pfn_AT='C:\work\JDSU\Test_ACP\Plastics_Recycle\ATetc_SKZ_wAclabelT_etc\SupCls\ncls22\Atrainpketc_{SKZ_final_German_LS_May9_SKZ1_SuperClass}_pp1-1stDerSGFL7[PO2]_pp2-SNV_wGloc_MID_SupCls_nvar119_ncls22_nsamp941.mat'
    out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
    %-------------------------------------------------
    % revisit Jan 8, 2024
    cc
    pfn_AT= 'C:\work\JDSU\Test_ACP\SCSVM_LocalAuto_Clsfr\ATetc_DI\Atrainpketc_{T-DM-5Powders}_nvar119_ncls5_nsamp110.mat'
    out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
    %---------------------------------------------------
    % revisit end of July, 2024
     cc
%     pfn_AT='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\winCls_PTT\Atrainpketc_{{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)[WinCls-PTT]}_nvar119_ncls4_nsampT224_nsampP45.mat'
    pfn_AT='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\winCls_PTT\Atrainpketc_{{T-ApdCls-N6_S3_T-103_P-105_P-T-DM-5Powders_sortTcls_[citric-acid]_ClsP-NaN}[WinCls-PTT]}_nvar119_ncls4_nsampT224_nsampP20.mat'
    out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
    %---------------------------------------------------------
    % revisit end of July, 2024
    % during kt for CFP GM
    cc
    pfn_AT='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\Atrainpketc_{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)_nvar119_ncls4_nsampT224_nsampP240.mat'
    out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
    
    %---------------------------------------------------------
    % revisit during testing LocalAuto July 31, 2024
    
    cc
  %  pfn_AT= 'C:\work\JDSU\KTaug\AT_LAf_alone\LAf_ncls4_DS_source\xU_nTU1\Atrainpketc_(1){Nylons_PET_PP_LAf_T-LAf_103_P-LAf_105}_nvar119_ncls4_nsampT1015_nsampP1020.mat';
%        pfn_AT= 'C:\work\JDSU\KTaug\AT_LAf_alone\LAf_ncls4_DS_source\xU_nTU1\Atrainpketc_(2){Nylons_PET_PP_LAf_T-LAf_103_P-LAf_109}_nvar119_ncls4_nsampT1015_nsampP1020.mat'
       
       pfn_AT='C:\work\JDSU\KT\AT_LAf_alone\Atrainpketc_{T-LAf_Nylons_PET_M1-103_P-M1-105}_ncls3_nsampT765_nsampP770.mat'
    out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
%----------------------------------------------------------------------

    % revisit Aug
    cc
   pfn_AT= 'C:\work\JDSU\KTaug\ATetc_Tset_Seq\LAf_alone_Bef_Aft_Rm-PP_S70\Rm_S70_PP_LAf\Atrainpketc_{ATetc_LAf_Only_ncls4--xU_nTU1_[1]_rm5OLs_Pset}_nvar119_ncls4_nsampT1010_nsampP1015.mat'
    out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)

    %---------------------------------------------------------
% scan thru whole folder

cc
% pfn_AT='C:\work\JDSU\KTaug\AT_LAf_alone\LAf_ncls4_DS_source\xU_nTU1' ; 
pfn_AT='C:\work\JDSU\KT\ATetc_LAf_Only_ncls3_woPP\xU_nTU1' ;
out=AT_sortBy_clistclslabel_sortTcls(pfn_AT)
   
    
end   % end of if false
%===================================================
if isstruct(pfn_AT)
    L=pfn_AT;
elseif isfolder(pfn_AT)
    [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(pfn_AT,'Atrainpketc_','mat') ; 
    clistfilename_out=sortnat( clistfilename_out);
    
else
L=load(pfn_AT);
end
%-----------------------------------------------------------------------------------------------------------------------

for iat=1:nfile_out
%++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++
pfn_AT=clistfilename_out{iat};
L=load(pfn_AT);

sd0=ssds(pfn_AT);
try
inp.corename=get_corename_pfn(pfn_AT);
catch
    inp.corename='{BefSort}';
end
sd0=sd0.saveAT(inp);  % save AT Bef sort
%-------------------------------------------------
Atrainpk_new=[];
AclassinfoT_new=[];
AclabelT_new=[];
AclabelT_new_alt=[];
AclabelT_new_MID=[];
AclabelT_new_SupCls=[];

RawSpectra_new=[];
for icls=1:length(L.clistclslabel)
    loc_icls=find(L.AclassinfoT==icls);
    Atrainpk_new=[Atrainpk_new ; L.Atrainpk(loc_icls,:)  ];
    AclassinfoT_new=[AclassinfoT_new ; L.AclassinfoT(loc_icls,:)  ];
    %----------------------------------------------------------------------
    try
    RawSpectra_new=[RawSpectra_new ; L.RawSpectra(loc_icls,:)  ];
    catch
     RawSpectra_new=[RawSpectra_new ; L.RawSpectra.Tset(loc_icls,:)  ];     % fix_RS, July 25, 2024
    end
    %-------------------------------------------------------------------------
     AclabelT_new=[AclabelT_new ; L.AclabelT(loc_icls,:)  ];
     try
     AclabelT_new_alt=[AclabelT_new_alt ; L.AclabelT_alt(loc_icls,:)  ];
     AclabelT_new_MID=[AclabelT_new_MID ; L.AclabelT_MID(loc_icls,:)  ];
     AclabelT_new_SupCls=[AclabelT_new_SupCls ; L.AclabelT_SupCls(loc_icls,:)  ];
     end
end
Lnew=L;
Lnew.Atrainpk=Atrainpk_new;
Lnew.AclassinfoT=AclassinfoT_new;
Lnew.AclabelT=AclabelT_new;
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if    isfield(Lnew.RawSpectra,'Tset')   &&   ~isempty(RawSpectra_new)                   % fix_RS, July 25, 2024
    Lnew.RawSpectra.Tset=RawSpectra_new;
elseif  ~isempty(RawSpectra_new)
    Lnew.RawSpectra=RawSpectra_new;
end
%-------------------------------------------
try
Lnew.AclabelT_alt=AclabelT_new_alt;
Lnew.AclabelT_MID=AclabelT_new_MID;
Lnew.AclabelT_SupCls=AclabelT_new_SupCls;
end
%-----------------------------------------
sd1=ssds(Lnew);
% inp.corename=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar'),'sortByclistclslabel'];
% inp.corename_0=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar')];
try
inp.corename_0=get_corename_pfn(pfn_AT );
catch
    inp.corename_0='{OrigBefSort}';
end

inp.corename=strrep(inp.corename_0,'}',['_sortTcls}' ]) ;
if strcmp(inp.corename,inp.corename_0)
 inp.corename=[find_keyword_between_markers(fileparts_name_ext(pfn_AT),'Atrainpketc_','nvar'),'sortTcls'];   
end

sd2=sd1.saveAT(inp);
% out=sd2.pathfname_AT;
out.obj=sd2;
out.pathfname_AT=sd2.pathfname_AT;

%++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++
end   % end of iat

%========================================================================================================
done_with_this_function;
end


%% ----- from Atrainpk2saConc.m ---------------------------------------------
function saConc_new=Atrainpk2saConc(Atrainpk,saConc)
% see also mat2cell_CH_4SAinsert saConc2Atrainpk  ssds (constructor)
% insert Atrainpk into an existing saConc in PLS style dataset or AT files
if false
    
    % in this example, an Atrainpk with all zeros will be inserted into saConc
    % 
    clear
        LAT=load('C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\UDM\Atrainpketc_saConc_(Brix_CS102_UDM21_UDM)_pp1-none_pp2-none_nvar125_nsamp21.mat');
    Atrainpk=zeros(size(LAT.Atrainpk));
    saConc=LAT.saConc;
    saConc_new=Atrainpk2saConc(Atrainpk,saConc);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear
    LAT=load('C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\UDM\Atrainpketc_saConc_(Brix_CS102_UDM21_UDM)_pp1-none_pp2-none_nvar125_nsamp21.mat');
    Atrainpk_allzeros=zeros(size(LAT.Atrainpk));
    LAT.Atrainpk=Atrainpk_allzeros;
    sd_AT=ssds(LAT);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clear
    LAT=load('C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\UDM\Atrainpketc_saConc_(Brix_CS102_UDM21_UDM)_pp1-none_pp2-none_nvar125_nsamp21.mat');
     sd_AT=ssds(LAT);
    
    Atrainpk_allzeros=zeros(size(LAT.Atrainpk));
   
       sd_AT=sd_AT.Atrainpk_replace(Atrainpk_allzeros);

%     
%    sd_AT_new=Atrainpk_replace(sd_AT,Atrainpk_allzeros);
    
   

    
    
    
    
    
end

 [saConc.Atrainpk]=mat2cell_CH_4SAinsert(Atrainpk,'row'); 
saConc_new=saConc;
end


%% ----- from Atrainpk_SplitCls.m -------------------------------------------
function out=Atrainpk_SplitCls(L1,inp)
%split class into binary sub-classes based on smk1 and NOT smk1
% % seq of clistlabel_icls based on their appearance order
%---------------------------------------------------------------------------------------------
% see also: prep_PA6_PA66_for_WVL_calibration_in_Clsfr
% see also: ssds method --> merge_rm_extract_class and ssds_method_add_append_classes(o1,o2)
%---------------------------------------------------------------------------------------------
% deal with vacant cls in clistclslabel_new and AclassinfoT, May 30, 2024
%--------------------------------------------------------------------------------------------
% see also: parse_CARE_LAf_PCA_SVM_plot (June 2, 2024)
%======================================================================================
if false

    cc
    pfn='C:\work\JDSU\Manuf_U2U\WVL_Align\ATetc_ResinKits\OnSite_sKxU_rk5_3N1_ncls50\PA6_66\Atrainpketc_{T-rk5145_P-rk5159(T145)}_PA6_PA66_nvar121_ncls2_nsampT61_nsampP60.mat';
    L1=load(pfn);
    inp.smk1='_p5';
    inp.pathfname_AT=pfn;
    out_SplitCls=Atrainpk_SplitCls(L1,inp);

    %-----------------------------------------------------------------------------
    % run by ssds method --> [out_obj]=Split_class(obj,inp)

    cc
    pfn='C:\work\JDSU\Manuf_U2U\WVL_Align\ATetc_ResinKits\OnSite_sKxU_rk5_3N1_ncls50\PA6_66\Atrainpketc_{T-rk5145_P-rk5159(T145)}_PA6_PA66_nvar121_ncls2_nsampT61_nsampP60.mat';
    L1=load(pfn);
    sd1=ssds(L1);
    inp.smk1='_p5';
    inp.pathfname_AT=pfn;
    [out_obj]=Split_class(sd1,inp);

    %----------------------------------------------------------------------------------
    % revisit May 30, 2024 to deal with split PET-CARE vs PET-LAf
    % deal with vacant cls in clistclslabel_new and AclassinfoT, May 30, 2024
    cc
    pfn='C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_CARE_LAf_xU\wPET_CARE_nTU5_1\1st_summary\Atrainpketc_{1_T-MK_0514_M1-599_P-(MK_0522_M1-470)}_(PET_PET-LAf)(PTT)_nvar119_ncls2_nsampT915_nsampP390.mat' ;
    L1=load(pfn);
    sd1=ssds(L1);
    inp.smk1='_S1-_S6';
    inp.pathfname_AT=pfn;
    [out_obj]=Split_class(sd1,inp);
  %----------------------------------------------------------------------------------
    % revisit May 30, 2024 to deal with split all ClsName-CARE vs ClsName-LAf
    % deal with vacant cls in clistclslabel_new and AclassinfoT, May 30, 2024
    cc
    pfn='C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_CARE_LAf_xU\wPET_CARE_nTU5_1\1st_summary\Atrainpketc_{1_T-MK_0514_M1-599_P-(MK_0522_M1-470)_Pset-Combined}_nvar119_ncls6_nsampT2321_nsampP1078.mat';
    L1=load(pfn);
    sd1=ssds(L1);
    inp.smk1='_S1-_S6';
    inp.pathfname_AT=pfn;
    [out_obj]=Split_class(sd1,inp);


end
%========================================================================================

%split class into binary sub-classes based on smk1 and NOT smk1
% L1=out_sd_extract.LAT;
% smk1=  '_p5'   ;
smk1=  inp.smk1  ;
%------------------------------------------------------------------------------------
switch   inp.smk1

    case  '_S1-_S6'  % revisit May 30, 2024 to deal with split PET-CARE vs PET-LAf
        disp('revisit May 30, 2024 to deal with split PET-CARE vs PET-LAf');
        [qlT   nlT]=unique_count_sortnat_cstr  (L1.AclabelT);
        [qlP   nlP]=unique_count_sortnat_cstr (L1.AclabelP);

        AclabelT_ClsName=find_keyword_between_markers_cstr(L1.AclabelT,'','_');
        AclabelT_Sn=find_keyword_between_markers_wlistRHS_cstr(L1.AclabelT,'_S',{'_',''});
        AclabelT_ClsName_Sn=cellstr(AclabelT_ClsName+"_S"+AclabelT_Sn);

        AclabelP_ClsName=find_keyword_between_markers_cstr(L1.AclabelP,'','_');
        AclabelP_Sn=find_keyword_between_markers_wlistRHS_cstr(L1.AclabelP,'_S',{'_',''});
        AclabelP_ClsName_Sn=cellstr(AclabelP_ClsName+"_S"+AclabelP_Sn);

        [qlTcs   nlTcs]=unique_count_sortnat_cstr  (AclabelT_ClsName_Sn);
        [qlPcs   nlPcs]=unique_count_sortnat_cstr (AclabelP_ClsName_Sn);

        figure;hold on;
        stem(nlTcs);
        set_XTickLabel(gca,qlTcs,-45,8);
        title('AclabelT');

        figure;hold on;
        stem(nlPcs);
        set_XTickLabel(gca,qlPcs,-45,8);
        title('AclabelP');

end
%-------------------------------------------------------------------------------------------------------------------------
switch   inp.smk1

    case  '_S1-_S6'  % revisit May 30, 2024 to deal with split PET-CARE vs PET-LAf
    disp('revisit May 30, 2024 to deal with split PET-CARE vs PET-LAf');
   AclabelT_Sn_num=cellfun(@(x) str2num(x),AclabelT_Sn);
   AclabelP_Sn_num=cellfun(@(x) str2num(x),AclabelP_Sn);

        loc_mk1_T=find( AclabelT_Sn_num <= 6);
        loc_NOTmk1_T=find( AclabelT_Sn_num > 6);    % NOT smk1 in Tset

        loc_mk1_P=find( AclabelP_Sn_num <= 6);
        loc_NOTmk1_P=find( AclabelP_Sn_num > 6);    % NOT smk1 in Pset


    otherwise
        loc_mk1_T=find(strfind_cstr(L1.AclabelT,smk1));
        loc_NOTmk1_T=find(~strfind_cstr(L1.AclabelT,smk1));    % NOT smk1 in Tset

        loc_mk1_P=find(strfind_cstr(L1.AclabelP,smk1));
        loc_NOTmk1_P=find(~strfind_cstr(L1.AclabelP,smk1));  % NOT smk1 in Pset
end
%==================================================================


clistclslabel_new=[];
for icls=1:length(L1.clistclslabel)

clistlabel_icls_mk1={ strrep([L1.clistclslabel{icls},'_' ,smk1] ,'__','_' )}    ;

clistlabel_icls_NOTmk1={ strrep( [L1.clistclslabel{icls},'_NOT-' ,smk1] ,'-_','-' )}    ;
%======================================================================
% seq of clistlabel_icls based on their appearance order
if loc_mk1_T(1)  < loc_NOTmk1_T(1)
    clistclslabel_new=[ clistclslabel_new,  clistlabel_icls_mk1 ,  clistlabel_icls_NOTmk1 ];  % seq of clistlabel_icls based on their appearance order
else
    clistclslabel_new=[ clistclslabel_new,  clistlabel_icls_NOTmk1 ,  clistlabel_icls_mk1 ];    % seq of clistlabel_icls based on their appearance order
end
%======================================================================

end
%---------------------------------------------------------
clear clistlabel_icls_mk1 clistlabel_icls_NOTmk1 ;
AclassinfoT_new=repmat(NaN,size(L1.AclassinfoT));
AclassinfoP_new=repmat(NaN,size(L1.AclassinfoP));

for icls=1:length(L1.clistclslabel)

loc_icls_T=find(L1.AclassinfoT==icls );
loc_icls_P=find(L1.AclassinfoP==icls );

loc_icls_T_mk1=intersect(loc_mk1_T, loc_icls_T   )  ;
loc_icls_P_mk1=intersect(loc_mk1_P, loc_icls_P   )  ;

clistlabel_icls_mk1={ strrep([L1.clistclslabel{icls},'_' ,smk1] ,'__','_' )}    ;
AclassinfoT_new( loc_icls_T_mk1) = find(strcmp( clistclslabel_new,clistlabel_icls_mk1) );
AclassinfoP_new( loc_icls_P_mk1) = find(strcmp( clistclslabel_new,clistlabel_icls_mk1) );


loc_icls_T_NOTmk1=intersect(loc_NOTmk1_T, loc_icls_T   )  ;
loc_icls_P_NOTmk1=intersect(loc_NOTmk1_P, loc_icls_P   )  ;

clistlabel_icls_NOTmk1={ strrep( [L1.clistclslabel{icls},'_NOT-' ,smk1] ,'-_','-' )}    ;
AclassinfoT_new( loc_icls_T_NOTmk1) = find(strcmp( clistclslabel_new,clistlabel_icls_NOTmk1) );
AclassinfoP_new( loc_icls_P_NOTmk1) = find(strcmp( clistclslabel_new,clistlabel_icls_NOTmk1) );


end
%=================================================================================
% deal with vacant cls in clistclslabel_new and AclassinfoT, May 30, 2024
qcsnT=unique(AclassinfoT_new) ;
clistclslabel_new=clistclslabel_new( qcsnT );
AclassinfoT_new=replace_CH(AclassinfoT_new, qcsnT,[1:length(qcsnT)] )  ;
AclassinfoP_new=replace_CH(AclassinfoP_new, qcsnT,[1:length(qcsnT)] )  ;
%------------------------------------------------------------------------------------------
%checking
if any(isnan(AclassinfoT_new)) || any(isnan(AclassinfoP_new))
    error('some of AclassinfoT_new or AclassinfoP_new Not filled correctly ?');
else
    L1_new=L1;
    L1_new.AclassinfoT=AclassinfoT_new;
    L1_new.AclassinfoP=AclassinfoP_new;
    L1_new.clistclslabel=clistclslabel_new;
   sncls_new=['_ncls',num2str(length(L1_new.clistclslabel))];

end

% pathfname_new=fileparts_name_ext( out_sd_extract.pathfname_AT ) ;
pathfname_new=fileparts_name_ext( inp.pathfname_AT ) ;

sncls_old=['_ncls',find_keyword_between_markers(pathfname_new,'_ncls','_') ];
pathfname_new=strrep( pathfname_new,sncls_old,['_aftSplitCls',sncls_new]);

save( pathfname_new ,'-struct','L1_new');
disp_with_border([ pathfname_new,' has been saved !' ]);
out_obj=ssds(L1_new);
out.pathfname_AT=pathfname_new;
out.out_obj=out_obj;
out.LAT_new=L1_new;
%=========================================================
done_with_this_function;
end


%% ----- from Atrainpk_Split_Odd_Even.m -------------------------------------
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


%% ----- from Atrainpk_add_ILC_ClassinfoTP.m --------------------------------
function out=Atrainpk_add_ILC_ClassinfoTP(pathfname_TP,inp)
% see also: BatchRun_AutoClsfr_DA_pipeline_HFA
% revisit this for Plastics Recycle, Apr 7, 2023
if false
    
    cc
    pathfname_TP='C:\work\JDSU\HFA-BP\AT_etc\S1S2S4S8\S1S2S4S8_ncls8_nsamp222_OnePDS_EachCls_Ncomb2'                                             %Global Model 8 classes
    inp.cAttribute_mk1_mk2={{'S0','_'}};
    Atrainpk_add_ILC_ClassinfoTP(pathfname_TP,inp)
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % to convert predcls from 8cls to 4cls
      predcls=[1 2 7 8 3 4 5 6]
      Li=load('C:\work\JDSU\HFA-BP\AT_etc\S1S2S4S8\ILC-8cls\wILC-NewClsinfo\Atrainpketc_icomb1_{P-1_T-1-FQ}_nvar75_ncls8_nsampT109_nsampP113_w_ILC_NewClassinfoTP.mat')
      predcls_4cls=replace_CH(predcls,Li.AclassinfoT,Li.ILC_atrb_1.AclassinfoT_S0)
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    % after running --> revisit_parseTP_BMS_M3_woXBPL()
      cc
    pathfname_TP='C:\work\JDSU\HFA-BP\Test_BMS_prev_MIMIC-III_wo_XBPL\nvar75_ncls11_nsamp732_OnePDS_EachCls_Ncomb3_nsamp732_rm12OLs'                                             %Global Model 11 classes
    inp.cAttribute_mk1_mk2={{'p','_'}};
    Atrainpk_add_ILC_ClassinfoTP(pathfname_TP,inp)  
      
      
      
      
      
end
%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(strfind(pathfname_TP,'.mat'))

    [cpathfname_TP, nfile]=fdir_wildcard_wPath(pathfname_TP,'Atrainpketc_');
else
    cpathfname_TP={pathfname_TP};
    nfile=1;
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfname_wILC=[];
for ifile=1:nfile
    Li=load(cpathfname_TP{ifile});
    for jA=1:length(inp.cAttribute_mk1_mk2)
        cAttribute_mk1_mk2_jA=  inp.cAttribute_mk1_mk2{jA};
        mk1_jA=cAttribute_mk1_mk2_jA{1};
        mk2_jA=cAttribute_mk1_mk2_jA{2};
        ckeyword_jA_i= find_keyword_between_markers_cstr(Li.clistclslabel,mk1_jA, mk2_jA);
        clistclslabel_jA_i=cellstr(string(mk1_jA)+ckeyword_jA_i);
        ILC.(['clistclslabel_',mk1_jA])=unique_appear_order_cstr(clistclslabel_jA_i);
        clistclslabel_jA_i=ILC.(['clistclslabel_',mk1_jA]);
        
        AclassinfoT_jA_i=repmat(NaN,size(Li.AclassinfoT));
        AclassinfoP_jA_i=repmat(NaN,size(Li.AclassinfoP));

        for ji_cls_k=1:length(clistclslabel_jA_i)
       clsinfo_ji_cls_k= strmatch_findstr_loc([clistclslabel_jA_i{ji_cls_k},mk2_jA],Li.clistclslabel);
       
       loc_clsT_ji_cls_k=find_belong2subgrp(Li.AclassinfoT,clsinfo_ji_cls_k);
       AclassinfoT_jA_i(loc_clsT_ji_cls_k)=replace_CH(Li.AclassinfoT(loc_clsT_ji_cls_k),clsinfo_ji_cls_k,ji_cls_k);
       
              loc_clsP_ji_cls_k=find_belong2subgrp(Li.AclassinfoP,clsinfo_ji_cls_k);
       AclassinfoP_jA_i(loc_clsP_ji_cls_k)=replace_CH(Li.AclassinfoP(loc_clsP_ji_cls_k),clsinfo_ji_cls_k,ji_cls_k);
        end
        %checking
        if any(isnan(AclassinfoT_jA_i)) | any(isnan(AclassinfoP_jA_i)) 
        error('some AclassinfoT_jA_i or AclassinfoT_jA_i Not properly replaced with new clsnum')
        end
   
        
        ILC.(['AclassinfoT_',mk1_jA])=AclassinfoT_jA_i;
        ILC.(['AclassinfoP_',mk1_jA])=AclassinfoP_jA_i;
        cstr_Conversion_Table_clsinfo_or_predcls= unique_appear_order_cstr(cellstr(string(Li.AclassinfoT)+"-"+string(AclassinfoT_jA_i)));
        Conversion_Table_clsinfo_or_predcls=[find_keyword_numeric_between_markers_cstr(cstr_Conversion_Table_clsinfo_or_predcls,'','-'),find_keyword_numeric_between_markers_cstr(cstr_Conversion_Table_clsinfo_or_predcls,'-','')];
      % Conversion_Table_clsinfo_or_predcls=[Li.AclassinfoT,AclassinfoT_jA_i]; % long and redundant form of this conversion table

      ILC.Conversion_Table_clsinfo_or_predcls=Conversion_Table_clsinfo_or_predcls;
        % for example, see below
        % predcls_4cls=replace_CH(predcls_8cls,ILC.Conversion_Table_clsinfo_or_predcls(:,1),ILC.Conversion_Table_clsinfo_or_predcls(:,2);
        % predcls_4cls=replace_CH(predcls,Li.AclassinfoT,Li.ILC_atrb_1.AclassinfoT_S0);

        %%%%%%%%%%%%%%%%%%%%%%%%%
        % the following will be needed inside --> BatchRun_AutoClsfr_DA_pipeline_HFA
        Li.(['ILC_atrb_',num2str(jA)])=ILC;
        %%%%%%%%%%%%%%%%%%%%%%%%%
    end  % end of jA
    sTcls=['T-',num2str(length(unique(ILC.Conversion_Table_clsinfo_or_predcls(:,1)))),'cls'];
    sPcls=['P-',num2str(length(unique(ILC.Conversion_Table_clsinfo_or_predcls(:,2)))),'cls'];
    fname_wILC=strrep(fileparts_name_ext(cpathfname_TP{ifile}),'.mat',['_wILC_(',sTcls,'_',sPcls,').mat']);
    save(fname_wILC,'-struct','Li');
    disp([fname_wILC,' has been saved'])
    
    cfname_wILC=[cfname_wILC;{fname_wILC}];
end % end of ifile

out.cfname_wILC=cfname_wILC;

disp('done with Atrainpk_add_ILC_ClassinfoTP')
end


%% ----- from Atrainpk_merge_Apred.m ----------------------------------------
function [fnLTLP SfnLTLP]=Atrainpk_merge_Apred(fnLT,fnLP,inp)
% will handle PLS's saConc too
% updated Feb 18, 2021 to copy AclabelT_wRepSeq
% see also Atrainpk_remove_classes
%-------------------------------------------------------------------------------------------------------
% add this checking of clistclslabel_P in --> oTP=TP_pair(o1,o2), June 17, 2024 (see ssds)
%-------------------------------------------------------------------------------------------------------
if false
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   

% T-SM2 Lib1  P-SM1 Lib1  ( 19 MaID )
fnLT='C:\work\JDSU\Excipients\ATetc\SM2_Lib1\Atrainpketc_Absorbance_PharmaLib(S1-00215)Lib1_pp1-SNV_pp2-1stDer_nvar121_nsamp570_ncls19.mat';
% fnLP='C:\work\JDSU\Excipients\ATetc\SM2_Lib2\Atrainpketc_Absorbance_PharmaLib(S1-00215)Lib2_pp1-SNV_pp2-1stDer_nvar121_nsamp570_ncls19.mat';
  fnLP= 'C:\work\JDSU\Excipients\ATetc\Lib-2\Atrainpketc_Absorbance_PharmaLib(S1-00214)Lib2_pp1-SNV_pp2-1stDer_nvar121_nsamp572_ncls19.mat'

[fnLTLP]=Atrainpk_merge_Apred(fnLT,fnLP)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fnLT= 'C:\work\JDSU\ExplosiveDetectEquipment\EDE_lib\ATetc\Atrainpketc_wWVL_wRawSpectra_Absorbance_1700_xls_pp1-1stDer_pp2-SNV_nvar121_EDE-all_ncls16_nsamp808_addNMs.mat'
% fnLP='C:\work\JDSU\ExplosiveDetectEquipment\EDE_lib\ATetc\Atrainpketc_Precursor_BelongTo_EDE__ncls16_nsamp152_wNMs.mat'
  
% fnLT=  'C:\work\JDSU\ExplosiveDetectEquipment\EDE_lib\ATetc\wPhantom\TsetONLY\Atrainpketc_wWVL_wRawSpectra_Absorbance_1700_xls_pp1-1stDer_pp2-SNV_nvar121_ncls17_nsampT515_addNMs_w3samples_phantomCls.mat'
% fnLP ='C:\work\JDSU\ExplosiveDetectEquipment\EDE_lib\ATetc\wPhantom\PsetONLY\Atrainpketc_Precursor_BelongTo_EDE__ncls17_nsamp152_wNMs_wPhantomCls.mat'
 
% fnLT= 'C:\work\JDSU\ExplosiveDetectEquipment\EDE_lib\ATetc\wPhantom\Baseline\ATetc_pretreated_by_UX\Atrainpketc_pretreated_by_UX_1stDer_SNV__EDE_first10_BL_nsamp522.mat'
% fnLP= 'C:\work\JDSU\ExplosiveDetectEquipment\EDE_lib\ATetc\wPhantom\Baseline\ATetc_pretreated_by_UX\Atrainpketc_pretreated_by_UX_1stDer_SNV__EDE_last20_nsamp296.mat'
fnLT='C:\work\JDSU\ExplosiveDetectEquipment\Confidence\ATetc\SG_Diederick\Atrainpketc_wWVL_wRawSpectra-Direct_Absorbance_1700_xls_nvar121_EDE-first10_wBLasNMs_ncls16_nsampT522__ReApply_pp1-1stDerSGDiederick_pp2-SNV.mat'
fnLP='C:\work\JDSU\ExplosiveDetectEquipment\Confidence\ATetc\SG_Diederick\Atrainpketc_wRawSpectra-Direct_Absorbance_1700_xls_nvar121_EDE-last20_ncls16_nsamp296_match-BLasNMs__ReApply_pp1-1stDerSGDiederick_pp2-SNV.mat'
[fnLTLP]=Atrainpk_merge_Apred(fnLT,fnLP)
 
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isa(fnLT,'struct')
    LT= fnLT;
    fnLT=['Atrainpketc_(T-Tset)_nsamp',num2str(length(LT.Atrainpk(:,1))),'.mat'];
elseif ischar(fnLT)
    LT=load(fnLT);
else
    error('fnLT should be either a struct or char')
end


if isa(fnLP,'struct')
    LP= fnLP;
    fnLP='Atrainpketc_(P-Pset).mat';
elseif ischar(fnLP)
    LP=load(fnLP);
else
    error('fnLP should be either a struct or char')
end


SfnLTLP=LT;
SfnLTLP.Apred=LP.Atrainpk;
SfnLTLP.AclassinfoP=LP.AclassinfoT;
try
SfnLTLP.AclabelP=LP.AclabelT;
end
%============================================
try
    if length(LP.AclabelT)==length(LP.AclabelT_wRepSeq)
      SfnLTLP.AclabelP_wRepSeq=LP.AclabelT_wRepSeq;                  % updated Feb 18, 2021 to copy AclabelT_wRepSeq
    end
end
%=============================================
if isfield(LT,'RawSpectra') && isfield(LP,'RawSpectra')
    if ~isa( LT.RawSpectra,'struct') && ~isa( LP.RawSpectra,'struct')
        SfnLTLP=rmfield(SfnLTLP,'RawSpectra');
        SfnLTLP.RawSpectra.Tset=LT.RawSpectra;
        SfnLTLP.RawSpectra.Pset=LP.RawSpectra;
    else
        try SfnLTLP.RawSpectra.Tset=LT.RawSpectra;end
        try SfnLTLP.RawSpectra.Tset=LT.RawSpectra.Tset;end
        
        try SfnLTLP.RawSpectra.Pset=LP.RawSpectra;end
        try SfnLTLP.RawSpectra.Pset=LP.RawSpectra.Tset;end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handle PLS's saConc
% LT.saConc=LTP.PLS.Tset.saConc;
% LP.saConc=LTP.PLS.Pset.saConc;
try SfnLTLP.PLS.Tset.saConc=LT.saConc; 
   SfnLTLP= rmfield(SfnLTLP,'saConc');
end
try SfnLTLP.PLS.Pset.saConc=LP.saConc; end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try
% SfnLTLP.saChain=[SfnLTLP.saChain;LP.saChain];
% end
% try
% SfnLTLP.saFeat=[SfnLTLP.saFeat;LP.saFeat];
% end
snsampT=['_nsampT',num2str(length(SfnLTLP.AclassinfoT))];
snsampP=['_nsampP',num2str(length(SfnLTLP.AclassinfoP))];


snsamp_orig=['_nsamp',find_keyword_between_markers_wlistRHS( fnLT,'_nsamp',{'_','.'})];
fnLTLP=fnLT;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % find skeyP from fnLP
% inp.cmk1 and inp.cmk2 must have same length
if length(inp.cmk1)==length(inp.cmk2)
    ckeyP=[];
    for imk=1:length(inp.cmk1)
        inp.smk1=inp.cmk1{imk};inp.smk2=inp.cmk2{imk};
        try
            skeyP=strtrim(find_keyword_between_markers(fileparts_name_ext(fnLP),inp.smk1,inp.smk2));
        catch
            skeyP='';
        end
        ckeyP=[ckeyP;{skeyP}];
    end
end

first_nonempty_skeyP=find(cellfun(@(x) ~isempty(x),ckeyP),1,'first');
if length(first_nonempty_skeyP)==1
skeyP=ckeyP{first_nonempty_skeyP};
else
skeyP='';    
end

if ~isempty(skeyP)
   skeyP=['_(P-',skeyP,')']; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fnLTLP=fileparts_name_ext( strrep(strrep(fnLTLP,snsamp_orig,[snsampT,skeyP,snsampP]),'.mat','_TP.mat')); % save to current folder



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect and consolidate keywords for Tset and Pset and put them at end of fnLTLP
% remove redundant keywords
% try
% skeyT=strtrim(find_keyword_between_markers(fileparts_name_ext(fnLT),inp.smk1,inp.smk2));
% skeyP=strtrim(find_keyword_between_markers(fileparts_name_ext(fnLP),inp.smk1,inp.smk2));
% ckT=strread_delimiter(skeyT,'_');
% ckP=strread_delimiter(skeyP,'_');
% creduntTP=intersect(ckT,ckP);
% QckT=setdiff(ckT,creduntTP);
% QckP=setdiff(ckP,creduntTP);
% QskT=strwrite_all_delimiter(QckT,'_');
% QskP=strwrite_all_delimiter(QckP,'_');
% end
% try
% CommonTP=strwrite_all_delimiter(creduntTP,'_');
% catch
%  CommonTP='';   
% end
% try
%  fnLTLP=strrep(fnLTLP,CommonTP,'');
% end
% try
%  fnLTLP=strrep(fnLTLP,QskT,'');
% end
% if ~isempty(CommonTP)
% skeyTP=['(','T-[',CommonTP,']',QskT,'_P-',QskP,')'];
% else
%     try
% skeyTP=['(','T-',QskT,'_P-',QskP,')'];
%     catch
% skeyTP='';        
%     end
% end
% 
% fnLTLP=strrep(fnLTLP,'_TP.mat',['_',skeyTP,'_TP.mat']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


try
 fnLTLP=strrep(fnLTLP,'_wWVL','');
end
try
 fnLTLP=strrep(fnLTLP,'_wRawSpectra','');
end
try
 fnLTLP=strrep(fnLTLP,'__','_');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modified by CH, May 15, 2019
% if length(LP.clistclslabel)==1  && isempty(find(strcmp(SfnLTLP.clistclslabel,LP.clistclslabel{1})))
if  ~isequal(SfnLTLP.clistclslabel,LP.clistclslabel)
SfnLTLP.clistclslabel_P=LP.clistclslabel;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save(fnLTLP,'-struct','SfnLTLP');

disp([fnLTLP,' has been saved !']);
end


%% ----- from Atrainpk_merge_classes_ATop.m ---------------------------------
function out=Atrainpk_merge_classes_ATop(pathfname_AT,clistcls_tobe_merged,inp)
% modified from Atrainpk_merge_classes
% instead of using idx_Cls_ON, it will take clistcls_tobe_merged as input
% this function can be used to merge certain classes, it only merge one
% cluster of classes into one class at one time
% it depends on idx_Cls_ON to determine which classes to stay and which to be removed
% 
% see also Atrainpk_merge_classes_Nclusters_ATop Atrainpk_merge_Apred
%-----------------------------------------------------------------------
% handle the case that captured AclabelP_MID and AclabelP_SupCls for misP_Cls_pairs analysis, June 6, 2023
%---------------------------------------------------------------------
% add this to deal with AclabelP_alt etc, Dec 12 2023
%------------------------------------------------------
% add this to deal with FalsePos samples, Dec 19, 2023
%-----------------------------------------------------------
% add this to handle cases that user specify extracted clistclslabel seq, Feb 17, 2024
% isfield(inp,'cls_pick_specified_seq')
%------------------------------
% update this Feb 21, 2024 --> pathfname_AT_new
%-------------------------------------------------------------------
%   case sensitve and must be exactly matched with spelling -->   inp.merged_ClsName , June 4, 2024
% see also: test_ssds_method_merge_rm_extract_class
%-------------------------------------------------------------------
if false
    
    pathfname_AT='C:\work\JDSU\Dataset_popular\PolymerLib\Atrainpketc_allAT_OneLIB_ncls27__pp1-1stDerSGDiederick_pp2-SNV__6SM_nsampT1296_nsampP2004.mat'
  %   pathfname_AT= 'C:\work\JDSU\PolymerLib\ATetc\allU\wQuadCor-Reds\Atrainpketc_allAT_OneLIB_wQuadCor-Reds__pp1-1stDerSGDiederick_pp2-SNV_nsamp3300_ncls27_wRawSpectra.mat'

    LAT=load(pathfname_AT);
   % clistcls_tobe_merged={'PA6','PA66'};
        clistcls_tobe_merged={'PAN','TPU','ABS'};
    out=Atrainpk_merge_classes_ATop(pathfname_AT,clistcls_tobe_merged);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % revisit June 22, 2024
    cc
   pathfname_AT= 'C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_Final\CARE_nTU5_1\Atrainpketc_(1){T-(TUseq1+TUseq2+TUseq3+TUseq4+TUseq5)_P-(M1-600_ApdCls-N6_S3_wMLbl_SupCls-N6_(N6_&_N6S3))}_nvar119_nclsT8_nclsP7_nsampT1855_nsampP373.mat'
      clistcls_tobe_merged={'N6','N6S3'};
       inp.action='merge';inp.merged_ClsName='N6';
    out=Atrainpk_merge_classes_ATop(pathfname_AT,clistcls_tobe_merged,inp);
    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    action=inp.action;
catch
%     action='all';%default
error('pls provide "action" in "inp.action"')
end
if strcmp(lower(action),'remove')|| strcmp(lower(action),'rm') || isempty(action)
    action='remove';
end

if strcmp(lower(action),'merge')||  isempty(action)
    action='merge';
    if isfield(inp,'merge_clsname') && ~isempty(inp.merge_clsname)  && ~strcmp(inp.merge_clsname,  '1st_occur')   %   case sensitve and must be exactly matched with spelling -->   inp.merged_ClsName , June 4, 2024
        merged_ClsName_user_provided =  inp.merged_ClsName;                                      %   case sensitve and must be exactly matched with spelling -->   inp.merged_ClsName , June 4, 2024
      merged_ClsName_type =   'user_provided_clsname';
    elseif  isfield(inp,'merge_clsname') && ~isempty(inp.merge_clsname) && strcmp(inp.merge_clsname,  '1st_occur')
       merged_ClsName_type= '1st_occur';
    else
     merged_ClsName_type='all';  % 'all' '1st_occur' 
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ischar(pathfname_AT)&& strcmp(pathfname_AT(end-3:end),'.mat')

% LAT=load(pathfname_AT);
clistfilename{1}=pathfname_AT;
nfile=1;
File_Or_Folder='File';

elseif ischar(pathfname_AT)&& ~strcmp(pathfname_AT(end-3:end),'.mat')
[clistfilename, nfile]=fdir_wildcard_ext_wPath(pathfname_AT,'Atrainpketc_','mat');
File_Or_Folder='Folder';


elseif isstruct(pathfname_AT)
LAT=pathfname_AT;
nfile=1;
File_Or_Folder='File';
sd0=ssds(LAT);
inp4sd0.corename='Orig';
pathfname_AT=sd0.saveAT(inp4sd0);
% pathfname_AT='Atrainpketc_dummy.mat';

else
    error('datatype of pathfname_AT is WRONG')
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('inp','var')&& isfield(inp,'keepSameFolder') && ~isempty(inp.keepSameFolder)
    TMPpath=[pwd,'\',inp.keepSameFolder];
    
elseif exist('inp','var')&& isfield(inp,'folder4newClsConfig') && ~isempty(inp.folder4newClsConfig)
    TMPpath=tmp_folder_rm_mk(inp.folder4newClsConfig,fileparts(pathfname_AT));
else
    if isa(pathfname_AT,'ssds')
        pathfname_AT=pathfname_AT.pathfname_AT;
    end
    LF=find_lastfolder(fileparts(pathfname_AT));
    if ~strcmp(LF,'newMergeCls')
        % for running 1st action
        % before create/clean "newMergeCls" make sure prev results (if exist) copied to pwd
        %
        path_pwd_newMergeCls=[pwd,'\newMergeCls'];
        if exist(path_pwd_newMergeCls,'dir')
            [clist_file_OR_subfolder_name,n_nMC]=fdir_wPath(path_pwd_newMergeCls,'mat',0,'Atrainpketc');
            if n_nMC==1
                copyfile(clist_file_OR_subfolder_name{1});
            elseif n_nMC>1
                copyfile(clist_file_OR_subfolder_name{1});
                Speak_mk('More than one AT file in newMergeCls, and only first was copied');
            end
        end
        TMPpath=tmp_folder_rm_mk('newMergeCls',pwd);
    else
        % for running 2nd action ...
        copyfile(pathfname_AT);
        pathfname_AT=[pwd,'\',fileparts_name_ext(pathfname_AT)];
        clistfilename{1}=pathfname_AT;
        TMPpath=tmp_folder_rm_mk('newMergeCls',pwd);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('clistfilename','var')
    clistfilename{1}=pathfname_AT;
end

for ifile=1:nfile

LAT=load(clistfilename{ifile});
% check 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    classinfo2merged=cellfun(@(x) strmatch(x,LAT.clistclslabel,'exact'),clistcls_tobe_merged);
catch
    error('something wrong with creating classinfo2merged from clistcls_tobe_merged ');
    classinfo2merged=cellfun(@(x) strmatch(x,LAT.clistclslabel,'exact'),clistcls_tobe_merged,'un',0)
end
if isfield(inp,'cls_pick_specified_seq') && ~isempty(  inp.cls_pick_specified_seq ) % add this to handle cases that user specify extracted clistclslabel seq, Feb 17, 2024
   classinfo2merged=cellfun(@(x) strmatch(x,LAT.clistclslabel,'exact'), inp.cls_pick_specified_seq);
   loc2merged=find_belong2subgrp(LAT.AclassinfoT,classinfo2merged); % will be based on sorted clsnum
else
    loc2merged=find_belong2subgrp(LAT.AclassinfoT,sort(classinfo2merged)); % will be based on sorted clsnum
end
    
    idx_Cls_ON=ones(length(LAT.clistclslabel),1);
    idx_Cls_ON(classinfo2merged)=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(idx_Cls_ON)==length(LAT.clistclslabel)
    loc_ClsNum_RM=find(idx_Cls_ON==0);
  loc_samp_RM=find(arrayfun(@(x) ~isempty(find(loc_ClsNum_RM==x)),LAT.AclassinfoT)==1);  
  
   %if isSAME_2Matrix( unique(LAT.AclassinfoT(loc_samp_RM)),loc_ClsNum_RM)
       
   if isempty(setdiff( unique(LAT.AclassinfoT(loc_samp_RM)),loc_ClsNum_RM ))
       SAT=LAT;
       %  SAT.Atrainpk(loc_samp_RM,:)=[];
       %  SAT.AclassinfoT(loc_samp_RM,:)=[];
       % reassign AclassinfoT
       % loc_ClsNum_STAY=delsamps(col_always([1:length(LAT.clistclslabel)]),loc_ClsNum_RM);
       % loc_ClsNum_STAY_new=col_always([1:length(loc_ClsNum_STAY)]);
       
       if strcmp(action,'remove')
           AclassinfoT_new=replace_CH(SAT.AclassinfoT,loc_ClsNum_RM,'');
       elseif strcmp(action,'extract')
           
               AclassinfoT_new=SAT.AclassinfoT(loc_samp_RM);
           
           
       elseif strcmp(action,'merge')
           AclassinfoT_new=replace_CH(SAT.AclassinfoT,loc_ClsNum_RM,loc_ClsNum_RM(1));
           
       else
           error('not supported action')
       end
        Qclsinfo_new=unique(AclassinfoT_new);
       %%%%%%%%%%%%%%%%%%%%%%%%% 
       % this is very tricky, when AclassinfoT are NaN, 
       % special handling will be needed
       if all(isnan(AclassinfoT_new))
           disp('all AclassinfoT are NaN');
       else
            if isfield(inp,'cls_pick_specified_seq') && ~isempty(  inp.cls_pick_specified_seq )   % add this to handle cases that user specify extracted clistclslabel seq, Feb 17, 2024
       AclassinfoT_new=replace_CH(AclassinfoT_new,classinfo2merged,[1:length(classinfo2merged)]);
            else
       AclassinfoT_new=replace_CH(AclassinfoT_new,Qclsinfo_new,[1:length(Qclsinfo_new)]);
            end
       
       
       end
       %%%%%%%%%%%%%%%%%%%%%%%%
       Qclsinfo_final=unique(AclassinfoT_new);
       
       SAT.AclassinfoT=AclassinfoT_new;
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       if isfield(SAT,'Apred')&& isfield(SAT,'AclassinfoP')
           %         if isfield(LAT,'loc_samp_RM_P')
           %     loc_samp_RM_P=LAT.loc_samp_RM_P;
           %         else
           %             loc_samp_RM_P=find(arrayfun(@(x) ~isempty(find(loc_ClsNum_RM==x)),SAT.AclassinfoP)==1);
           %         end
           %    % SAT.Apred(loc_samp_RM_P,:)=[];
           %     SAT.AclassinfoP(loc_samp_RM_P,:)=[];
           %     % reassign AclassinfoP
           %     AclassinfoP_new=replace_CH(SAT.AclassinfoP,loc_ClsNum_STAY,loc_ClsNum_STAY_new);
           %     SAT.AclassinfoP=AclassinfoP_new;
           
           if strcmp(action,'remove')
               AclassinfoP_new=replace_CH(SAT.AclassinfoP,loc_ClsNum_RM,'');
               % added following Jan 20, 2020 to also remove classes from Pset
               loc_samp_RM_P=find(arrayfun(@(x) ~isempty(find(loc_ClsNum_RM==x)),LAT.AclassinfoP)==1);
               
           elseif strcmp(action,'extract')
               
               if all(isnan(LAT.AclassinfoP))
                   loc_samp_RM_P=[1:length(SAT.AclassinfoP)];      % add this to deal with FalsePos samples, Dec 19, 2023
               else
                   loc_samp_RM_P=find(arrayfun(@(x) ~isempty(find(loc_ClsNum_RM==x)),LAT.AclassinfoP)==1);
               end
               
             
                   AclassinfoP_new=SAT.AclassinfoP(loc_samp_RM_P);
                
               
           elseif strcmp(action,'merge')
               AclassinfoP_new=replace_CH(SAT.AclassinfoP,loc_ClsNum_RM,loc_ClsNum_RM(1));
           else
               error('not supported')
           end
           %Qclsinfo_new_P=unique(AclassinfoT_new);
            if isfield(inp,'cls_pick_specified_seq') && ~isempty(  inp.cls_pick_specified_seq )
              AclassinfoP_new=replace_CH(AclassinfoP_new ,classinfo2merged,[1:length(classinfo2merged)]);   % add this to handle cases that user specify extracted clistclslabel seq, Feb 17, 2024
            else
              AclassinfoP_new=replace_CH(AclassinfoP_new,Qclsinfo_new,[1:length(Qclsinfo_new)]);
            end
           
           Qclsinfo_final_P=unique(AclassinfoP_new);
           SAT.AclassinfoP=AclassinfoP_new;
       end
       %checking
       %     if ~isSAME_2Matrix( unique(SAT.AclassinfoT),loc_ClsNum_STAY_new)
       %     error('something wrong with SAT.AclassinfoT')
       %     end
       if strcmp(action,'remove')
           SAT.clistclslabel(loc_ClsNum_RM)=[];
       elseif strcmp(action,'extract')
           if isfield(inp,'cls_pick_specified_seq') && ~isempty(  inp.cls_pick_specified_seq )
             SAT.clistclslabel=SAT.clistclslabel(classinfo2merged);   
           else
           SAT.clistclslabel=SAT.clistclslabel(loc_ClsNum_RM);
           end
           
       elseif strcmp(action,'merge')
           
           switch merged_ClsName_type
               case 'all'
                   SAT.clistclslabel{loc_ClsNum_RM(1)}=strwrite_all_delimiter( LAT.clistclslabel(loc_ClsNum_RM),'_');
               case '1st_occur'
                   SAT.clistclslabel{loc_ClsNum_RM(1)}=LAT.clistclslabel{loc_ClsNum_RM(1)};
               case 'user_provided_clsname'
                   SAT.clistclslabel{loc_ClsNum_RM(1)}= merged_ClsName_user_provided ;
           end
                   SAT.clistclslabel(loc_ClsNum_RM(2:end))=[];
           
           
           
       else
           error('not supported')
       end
       
       
       switch action
           case 'merge'
               disp('will deal with merge action on  Atrainpk etc');
               
               
           case 'remove'
               disp('will remove all these classes from Atrainpk etc');
               SAT.Atrainpk(loc_samp_RM,:)=[];
               
               try
               SAT.RawSpectra(loc_samp_RM,:)=[];
               catch
                   %disp('working on fixing this RS issue')
                 SAT.RawSpectra.Tset(loc_samp_RM,:)=[];  
               end
               
               try
                   SAT_AclabelT_orig=SAT.AclabelT;
                   SAT.AclabelT(loc_samp_RM,:)=[];
                   if isfield(SAT,'AclabelT_wRepSeq') && length(SAT.AclabelT_wRepSeq)==length(SAT_AclabelT_orig)
                      SAT.AclabelT_wRepSeq(loc_samp_RM,:)=[]; 
                   end
               end
               %------------------------------------------------------------------------
             % add this to deal with AclabelT_alt etc, Jan 16, 2024
               try
                 SAT.AclabelT_alt(loc_samp_RM,:)=[];
               end
               try
                 SAT.AclabelT_MID(loc_samp_RM,:)=[];
               end
               try
                 SAT.AclabelT_SupCls(loc_samp_RM,:)=[];
               end
               %------------------------------------------------------------------------
               %------------------------------------------------------------------------
               % added following Jan 20, 2020 to also remove classes from Pset
               %
               if isfield(SAT,'Apred')&& isfield(SAT,'AclassinfoP')
                   SAT.Apred(loc_samp_RM_P,:)=[];
                   try
                       SAT.AclabelP(loc_samp_RM_P,:)=[];
                   end
                   try
                       SAT.RawSpectra.Pset(loc_samp_RM_P,:)=[];  ;
                   end
               end
               
               %-----------------------------------------------------------------------
               try
               SAT.saConc(loc_samp_RM,:)=[]; % updated May 3, 2019
               catch
                   try
                      SAT.PLS.Tset.saConc(loc_samp_RM,:)=[]; % updated May 3, 2019 
                   end
               end
               
               
           case 'extract'
               disp('will extract all these classes from Atrainpk etc');
               SAT.Atrainpk=SAT.Atrainpk(loc_samp_RM,:);
               
               try
               SAT.RawSpectra=SAT.RawSpectra(loc_samp_RM,:);
               catch
                SAT.RawSpectra.Tset=SAT.RawSpectra.Tset(loc_samp_RM,:);   
               end
               
               try
                   SAT_AclabelT_orig=SAT.AclabelT;
                   SAT.AclabelT=SAT.AclabelT(loc_samp_RM);
                   if isfield(SAT,'AclabelT_wRepSeq') && length(SAT.AclabelT_wRepSeq)==length(SAT_AclabelT_orig)
                       SAT.AclabelT_wRepSeq(loc_samp_RM,:)=[];
                   end
                   %------------------------------------------------------
                   % add this June 1, 2023
                   if isfield(SAT,'AclabelT_alt') && length(SAT.AclabelT_alt)==length(SAT_AclabelT_orig)
                       AclabelT_alt_orig=SAT.AclabelT_alt;
                       SAT.AclabelT_alt = AclabelT_alt_orig (loc_samp_RM ) ;
                   end
                   % handle the case that captured AclabelP_MID and AclabelP_SupCls for misP_Cls_pairs analysis, June 6, 2023
                   if isfield(SAT,'AclabelT_MID') && length(SAT.AclabelT_MID)==length(SAT_AclabelT_orig)
                       AclabelT_MID_orig=SAT.AclabelT_MID;
                       SAT.AclabelT_MID = AclabelT_MID_orig (loc_samp_RM ) ;
                   end
                   if isfield(SAT,'AclabelT_SupCls') && length(SAT.AclabelT_SupCls)==length(SAT_AclabelT_orig)
                       AclabelT_SupCls_orig=SAT.AclabelT_SupCls;
                       SAT.AclabelT_SupCls = AclabelT_SupCls_orig (loc_samp_RM ) ;
                   end
                   %--------------------------------------------------
                   
               end
               
              if isfield(SAT,'Apred')&& isfield(SAT,'AclassinfoP')
               SAT.Apred=SAT.Apred(loc_samp_RM_P,:);
               
                %------------------------------------------------------
                   % add this to deal with AclabelP_alt etc, Dec 12 2023
                   try
                       SAT_AclabelP_orig=SAT.AclabelP;
                       SAT.AclabelP=SAT.AclabelP(loc_samp_RM_P);
                       if isfield(SAT,'AclabelP_alt') && length(SAT.AclabelP_alt)==length(SAT_AclabelP_orig)
                           AclabelP_alt_orig=SAT.AclabelP_alt;
                           SAT.AclabelP_alt = AclabelP_alt_orig (loc_samp_RM_P ) ;
                       end
                       % handle the case that captured AclabelP_MID and AclabelP_SupCls for misP_Cls_pairs analysis, June 6, 2023
                       if isfield(SAT,'AclabelP_MID') && length(SAT.AclabelP_MID)==length(SAT_AclabelP_orig)
                           AclabelP_MID_orig=SAT.AclabelP_MID;
                           SAT.AclabelP_MID = AclabelP_MID_orig (loc_samp_RM_P ) ;
                       end
                       if isfield(SAT,'AclabelP_SupCls') && length(SAT.AclabelP_SupCls)==length(SAT_AclabelP_orig)
                           AclabelP_SupCls_orig=SAT.AclabelP_SupCls;
                           SAT.AclabelP_SupCls = AclabelP_SupCls_orig (loc_samp_RM_P ) ;
                       end
                   end
                   %--------------------------------------------------
                try
                SAT.RawSpectra.Tset=SAT.RawSpectra.Tset(loc_samp_RM,:);
                end
                 try
                SAT.RawSpectra.Pset=SAT.RawSpectra.Pset(loc_samp_RM_P,:);
                end 
              end
              %%%%%%%%%%%%%%%%%
              if ~isfield(SAT,'saConc')
               if isfield(SAT,'PLS') && isfield(SAT.PLS,'Tset')&& isfield(SAT.PLS.Tset,'saConc')
               SAT.PLS.Tset.saConc=SAT.PLS.Tset.saConc(loc_samp_RM);
               end
               if isfield(SAT,'PLS') && isfield(SAT.PLS,'Pset')&& isfield(SAT.PLS.Pset,'saConc')
               SAT.PLS.Pset.saConc=SAT.PLS.Pset.saConc(loc_samp_RM_P);
               end
              else
                  error('under construction')
              end
               %%%%%%%%%%%%%%%
               
               
               
           otherwise
               error(' method for action NOT supported')
               
       end
       
       %       try    SAT.AclabelT(loc_samp_RM,:)=[]; end
       %        try    SAT.saWL(loc_samp_RM,:)=[]; end
       %        try SAT=rmfield(SAT,'AclabelP');end
       
   else
       error('something wrong with loc_samp_RM')
   end
   ncls=length(SAT.clistclslabel);
   


% pathfname_AT
switch File_Or_Folder
    case 'File'
       fname_AT_new=fileparts_name_wo_ext( pathfname_AT);
    case 'Folder'
       fname_AT_new=fileparts_name_wo_ext( clistfilename{ifile});
        
        
end
       
       sncls_orig=['_ncls',num2str(length(LAT.clistclslabel))];
       
       fname_AT_new=strrep(fname_AT_new,sncls_orig,'');
       
      % remove_keyword_between_markers(fname_AT_new,'_ncls','_')
%    end
   
%     snsamp_new=num2str(length(SAT.AclassinfoT));
%     
%     snsamp_old=find_keyword_between_markers_wlistRHS(fileparts_name_wo_ext( fname_AT_new),'_nsamp',{'_',''});
%     fname_AT_new=strrep(fname_AT_new,snsamp_old,snsamp_new);
    
    pathfname_AT_new=fullfile(TMPpath,fname_AT_new);
    pathfname_AT_new=[pathfname_AT_new,['_ncls',num2str(ncls),'.mat']];
    
    if strcmp(action,'remove')|| strcmp(action,'extract')|| strcmp(action,'merge')
        
        
        if isfield(SAT,'Apred')&& isfield(SAT,'AclassinfoP')
            pathfname_AT_new=  textual_replaceBetween_multiple_kw2(pathfname_AT_new,'_nsampT',{'_','.mat'},num2str(length(SAT.AclassinfoT)));
            pathfname_AT_new=  textual_replaceBetween_multiple_kw2(pathfname_AT_new,'_nsampP',{'_','.mat'},num2str(length(SAT.AclassinfoP)));
            
        else
            pathfname_AT_new=  textual_replaceBetween_multiple_kw2(pathfname_AT_new,'_nsamp',{'_','.mat'},num2str(length(SAT.AclassinfoT)));
            
        end
    else
        error('action not supported')
    end
    
    
    
out.LAT=SAT;
out.LAT.clistclslabel=row_always( out.LAT.clistclslabel );
%--------------------------------------------------------------
% add the following, Oct 28, 2022
if ischar( pathfname_AT)
out.pathfname_Orig=pathfname_AT;
else
out.pathfname_Orig='';
end
%-----------------------------------------------------------
% update this Feb 21, 2024 --> pathfname_AT_new
pathfname_AT_new=strrep(pathfname_AT_new,'.mat',['_(',action,num2str(length(clistcls_tobe_merged)),'cls',').mat']);
try
pathfname_AT_new=strrep(pathfname_AT_new,inp4sd0.corename,'');
end
%--------------------------------------------
out.pathfname=pathfname_AT_new;
out.TMPpath4MergeCls=TMPpath;

save(out.pathfname,'-struct','SAT');
disp_with_border([pathfname_AT_new,' has been saved !']);
    
else
     error('something wrong with idx_Cls_ON')
    
end

end



disp('finish Atrainpk_merge_classes()')
end


%% ----- from Atrainpk_parse_AclabelT_subcls.m ------------------------------
function out=Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp)
% insert --> AclabelT_clsnum_sampseq Apr 23, 2019
% parse Atrainpk based on sub-class info in AclabelT
% after parsing, all Atrainpk samples used exactly same number of times as Pset in all TP pairs
% modified from Atrainpk_Split_Odd_Even_physical_diff_samp()
% important variable --> ListPermn_rownum_in_listcomb_clsi
% see also parse_AclabelT_subcls in ssds, Atrainpk_parse_AclabelT_subcls_OnePDS_AllCls, ATop, Atrainpk_merge_Apred
% see also permn
% see also prep_ResinKits_Molecules_J_rk_4_5_6_3N1(pathfname)

if false
    
    clear;close all
   pathfname_AT= 'C:\work\JDSU\CUSTOMERS_OSP\BMS_OTC\ATetc\Atrainpketc__SciO_OTC_api_brand_wPillSeq_pp1-1stDerSGw15_pp2-SNV_nvar317_ncls30_nsamp1080.mat';
    inp.smk1='_P';inp.smk2='';inp.Nsubcls4T=2;
   Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp);
  %%%%%%%%%%%%%%%%%%%%%%%%%%
      clear;close all
   pathfname_AT= 'C:\work\JDSU\CUSTOMERS_OSP\BMS_OTC\ATetc\Atrainpketc__SciO_OTC_api_brand_wPillSeq_pp1-1stDerSGw15_pp2-SNV_nvar317_ncls30_nsamp1080.mat';
    inp.smk1='_P';inp.smk2='';inp.Nsubcls4T=1;
   Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   cc
pathfname_AT='D:\DellG2\OLD\work\JDSU\CUSTOMERS_OSP\BMS_OTC\TestSite\API_T-10Cls_Syndrome_P-4Cls\Atrainpketc__SciO_OTC_API_T-10Cls_Syndrome_P-4Cls_wPillSeq_wLC_pp1-1stDerSGw15_pp2-SNV_nvar317_ncls10_nsamp1080.mat'
inp.corename='SciO_OTC_API_T-10Cls_P-4Cls';
inp.smk1='_P';inp.smk2='';inp.Nsubcls4T=2;
   Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp);

   
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
parse_method_sub=inp.parse_method_sub;
catch
parse_method_sub='';    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isa(pathfname_AT,'struct')
    LAT= pathfname_AT;
elseif ischar(pathfname_AT)
    LAT=load(pathfname_AT);
else
    error('pathfname_AT should either be a pathfname(char) or LAT(struct)')
end

SAT=LAT;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create AclabelT_clsnum_sampseq (inside each cls)
ncls=length(LAT.clistclslabel);
AclabelT_clsnum_sampseq=repmat({'NA'},size(LAT.AclassinfoT));
for icls=1:ncls
    loc_icls=find(LAT.AclassinfoT==icls);
    seq_in_icls=col_always([1:length(loc_icls)]);
  AclabelT_clsnum_sampseq_i=cellstr("cls"+icls+"_"+seq_in_icls );  
AclabelT_clsnum_sampseq(loc_icls)=AclabelT_clsnum_sampseq_i;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% newPath=tmp_folder_rm_mk('TP_parse_AclabelT_subcls',pwd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % parsing T vs P based on Todd_physical_samp vs Peven_physical_samp
% use AclabelT to parse
% check whether it is applicable
try
    if isfield(SAT,'AclabelT_SpectraName')
    AclabelT=SAT.AclabelT_SpectraName; % modified Apr 17, 2019
    else
    AclabelT=SAT.AclabelT;    
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % calculate number and clist of subcls in each class based on AclabelT and clistclslabel
    %
    % first extract (or load) AclabelT_subcls
    %     smk1='_P';smk2='';
    try
        smk1=inp.smk1;smk2=inp.smk2;
        if strcmp(smk1(1),'_')
            smk1_clean=smk1(2:end);
        else
            smk1_clean=smk1;
        end
        
        AclabelT_subcls=cellstr(string(smk1_clean)+textual_extractBetween_multiple_kw2(string(AclabelT),smk1,smk2));
    catch
        error('not ready to deal with wo smk1 or smk2 yet')
    end
    
    [qlistsubcls nsubcls]=unique_count(AclabelT_subcls);
    % check to see if all cls have at least one of qlistsubcls
    cnsubcls_eacls=[];
    for icls=1:length(SAT.clistclslabel)
        [qlistsubcls_icls nsubcls_icls]=  unique_count(AclabelT_subcls(SAT.AclassinfoT==icls));
        cnsubcls_eacls=[cnsubcls_eacls,{nsubcls_icls}];
    end
    
     min_N_subcls= min(cellfun(@(x) length(x),cnsubcls_eacls));
     cnsubcls_eacls_trim=cellfun(@(x) x(1:min_N_subcls),cnsubcls_eacls,'un',0);
      nsubcls_eacls=cell2mat(cnsubcls_eacls_trim);
      
     qlistsubcls=qlistsubcls(1:min_N_subcls);


    
    
    if all(min(nsubcls_eacls)>0) && inp.Nsubcls4T<=length(qlistsubcls)-1
        disp('ok to proceed');
        [numcomb,listcomb]=Cmn(length(qlistsubcls),inp.Nsubcls4T,'listyes');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         inp.parse_method='OnePDS_EachCls';
        if strcmp(parse_method_sub,'AllPerm')
        ListPermn_rownum_in_listcomb_clsi = permn([1:length(qlistsubcls)],length(SAT.clistclslabel));
        numcomb=length(ListPermn_rownum_in_listcomb_clsi(:,1));
        elseif strcmp(parse_method_sub,'SameFQallCls')
        ListPermn_rownum_in_listcomb_clsi='';      
        else
         ListPermn_rownum_in_listcomb_clsi='';   
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         listcomb=flipud(listcomb);% flipud this such that Tset picked will follow intuitive fashion, i.e. starts with [1 2],[1 3], etc
    else
        disp_with_border('Not all cls have at least one entry of each subcls  OR  inp.Nsubcls4T > length(qlistsubcls)-1')
        error('will return wo result')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saLoc=[];
    ALL_locP_icls_additional=[];
    call_listcomb_icls_icomb=[];
    for icomb=1:numcomb
        
        cLoc_T_icls=[];
        cLoc_P_icls=[];
        
        for icls=1:length(SAT.clistclslabel)
            loc_icls=find(SAT.AclassinfoT==icls);
%             AclabelT_icls=AclabelT(loc_icls);
            AclabelT_subcls_icls=AclabelT_subcls(loc_icls);
            if ~isempty(ListPermn_rownum_in_listcomb_clsi)
                rownum4icls=ListPermn_rownum_in_listcomb_clsi(icomb,icls);
                listcomb_icls_icomb=listcomb(rownum4icls,:);
                call_listcomb_icls_icomb=[call_listcomb_icls_icomb;{listcomb_icls_icomb}];
                
                locT_icls=loc_icls(find_belong2subgrp_cstr(AclabelT_subcls_icls, qlistsubcls(listcomb_icls_icomb)));
           locP_icls_4Trim=loc_icls(find_belong2subgrp_cstr(AclabelT_subcls_icls, qlistsubcls( setdiff( [1:length(qlistsubcls)],listcomb_icls_icomb))));

            else
           locT_icls=loc_icls(find_belong2subgrp_cstr(AclabelT_subcls_icls, qlistsubcls(listcomb(icomb,:))));
           locP_icls_4Trim=loc_icls(find_belong2subgrp_cstr(AclabelT_subcls_icls, qlistsubcls( setdiff( [1:length(qlistsubcls)],listcomb(icomb,:)))));
     
            
            end
         
           
           locP_icls=setdiff(loc_icls,locT_icls);
           locP_icls=setdiff(locP_icls,ALL_locP_icls_additional);
           
           locP_icls_additional=setdiff(locP_icls,locP_icls_4Trim);
           ALL_locP_icls_additional =[ALL_locP_icls_additional;locP_icls_additional];
           
           
            cLoc_T_icls=[cLoc_T_icls;{locT_icls}];
            cLoc_P_icls=[cLoc_P_icls;{locP_icls}];
            
        end
      ea_saLoc.Loc_T=cell2mat(cLoc_T_icls);
      ea_saLoc.Loc_P=cell2mat(cLoc_P_icls);
     saLoc=[saLoc;ea_saLoc];   
    end % end of icomb
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
catch
    disp('this dataset NOT able to do parsing based on AclabelT')
    out=[];
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check whether all scans served as Pset wo missing any
% and
% whether all scans covered same number of times
all_LocP=cell2mat(arrayfun(@(x) x.Loc_P,saLoc,'un',0));
[qLocP nLocP]=unique_count(all_LocP);

if length(qLocP)==length(SAT.AclassinfoT)&& length(unique(nLocP))==1
    %if length(qLocP)==length(SAT.AclassinfoT) % with unbalanced number of subcls, some samples will be counted more than once or more than other samples
    disp('parsing is complete and uniform and OK to proceed');
elseif length(unique(nLocP))>1
    warning('some samples will be weighted more than other samples, however this should not happen ???')
    Speak_mk('some samples will be weighted more than other samples, however this should not happen ??? ')
    
else
    error('either some scans were missing to served as Pset or Not all scans covered same number of times')
end

% visually checking
 if false
     
     figure;hold on;
     for icomb=1:length(saLoc)
         plot(saLoc(icomb).Loc_T,icomb*ones(size(saLoc(icomb).Loc_T)),'bO');
         plot(saLoc(icomb).Loc_P,icomb*ones(size(saLoc(icomb).Loc_P)),'r*');
     end
     set(gca,'ylim',[0.5 icomb+0.5])
     title(['Nsubcls4T = ',num2str(inp.Nsubcls4T)])
     xlabel('sample seq');ylabel('icomb')
     
 end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_orig=pwd;

% tmpfolder4Save=tmp_folder_rm_mk(['TMP_T-',num2str(inp.Nsubcls4T),'s'],pwd);
% tmpfolder4Save=tmp_folder_rm_mk([inp.corename],pwd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tmpfolder4Save=tmp_folder_rm_mk(['TMP_T-',num2str(inp.Nsubcls4T),'s'],pwd);
tmpcorename=find_keyword_between_markers(inp.corename,'','_pp2');
if isempty(tmpcorename)
    tmpcorename= inp.corename;
end
try
    sparse_method= ['_',inp.parse_method];
catch
    sparse_method='';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add pp1 to tmpcorename
if false
    try
        tmpcorename=strrep(tmpcorename,'{BLC',['{pp1-',inp.PP_methods.pp1,'_BLC']);
    end
    try
        tmpcorename=[inp.corename_parse_folder,'_',tmpcorename];
    end
    
    try
        tmpcorename=textual_eraseBetween_rmkw1(tmpcorename,'_nvar','_');
    end
    try
        tmpcorename=textual_eraseBetween_rmkw1(tmpcorename,'_nsamp','');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    corename_parse_folder_rmOLs=inp.corename_parse_folder_rmOLs;
    if ~isempty(corename_parse_folder_rmOLs)
        corename_parse_folder_rmOLs=['_',corename_parse_folder_rmOLs];
    end
catch
    corename_parse_folder_rmOLs='';
end
if isempty(tmpcorename) && strcmp(sparse_method(1),'_')
    sparse_method_tmp=sparse_method(2:end);
    
   sparse_method='';
 
%   tmpfolder4Save=tmp_folder_rm_mk([tmpcorename,sparse_method_tmp,'_Ncomb',num2str(numcomb),'_nsamp',num2str(length(LAT.AclassinfoT)),corename_parse_folder_rmOLs],pwd);
    tmpfolder4Save=tmp_folder_rm_mk([tmpcorename,sparse_method_tmp,'_ParseTP_Ncomb',num2str(numcomb),corename_parse_folder_rmOLs],pwd);

else
    tmpcorename=strrep(tmpcorename,'{','');
        tmpcorename=strrep(tmpcorename,'}','');
        
sparse_method='';

% tmpfolder4Save=tmp_folder_rm_mk([tmpcorename,sparse_method,'_Ncomb',num2str(numcomb),'_nsamp',num2str(length(LAT.AclassinfoT)),corename_parse_folder_rmOLs],pwd);
tmpfolder4Save=tmp_folder_rm_mk([tmpcorename,sparse_method,'_ParseTP_Ncomb',num2str(numcomb),corename_parse_folder_rmOLs],pwd);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(tmpfolder4Save);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parse into numcomb TP pairs
oaTP=[];  % object array for TP pairs
for icomb=1:length(saLoc)
    
    LocT_i=saLoc(icomb).Loc_T;
    try
        LATi.RawSpectra.Tset=LAT.RawSpectra(LocT_i,:);
    end
    LATi.Atrainpk=LAT.Atrainpk(LocT_i,:);
    LATi.AclassinfoT=LAT.AclassinfoT(LocT_i);
    try
        LATi.AclabelT=LAT.AclabelT(LocT_i);
    end
    
    try
        LATi.AclabelT_clsnum_sampseq=AclabelT_clsnum_sampseq(LocT_i);
    end
    
    try
        LATi.PLS.Tset.saConc=LAT.saConc(LocT_i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with Label Combination data structure in multi-label SVM
    try
        LATi.AclabelT_LC=LAT.AclabelT_LC(LocT_i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LocP_i=saLoc(icomb).Loc_P;
    try
        LATi.RawSpectra.Pset=LAT.RawSpectra(LocP_i,:);
    end
    LATi.Apred=LAT.Atrainpk(LocP_i,:);
    LATi.AclassinfoP=LAT.AclassinfoT(LocP_i);
    
    try
        %LATi.AclabelP=LAT.AclabelT(LocP_i);
        LATi.AclabelP=LAT.AclabelT_SpectraName(LocP_i);
    catch
        LATi.AclabelP=LAT.AclabelT(LocP_i);                                 % updated Aug 16, 2020
    end
    try
        LATi.AclabelP_clsnum_sampseq=AclabelT_clsnum_sampseq(LocP_i);
        LATi.global_samp_seq=LocP_i;
    end
    
    
    try
        LATi.PLS.Pset.saConc=LAT.saConc(LocP_i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %checking
    %     Apred_from_saConc= cat(1,LATi.PLS.Pset.saConc.Atrainpk);
    %     isSAME_2Matrix(Apred_from_saConc,LATi.Apred)
    %     save('Apred_from_saConc_&_LATi_Apred.mat','Apred_from_saConc');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with Label Combination data structure in multi-label SVM
    try
        LATi.AclabelP_LC=LAT.AclabelT_LC(LocP_i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %check whether any missing classes
    if isequal(unique(LATi.AclassinfoT),unique(LAT.AclassinfoT))
        LATi.clistclslabel=LAT.clistclslabel;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % deal with Label Combination data structure in multi-label SVM
        try
            LATi.clistclslabel_LC=LAT.clistclslabel_LC;
        end
        try
            LATi.AclassinfoMap2LC=LAT.AclassinfoMap2LC;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        error(['missing class in this icomb = ' ,num2str(icomb)])
    end
    try
        LATi.wvl_standardize=LAT.wvl_standardize;
    end
    sdi=ssds(LATi);
    
    %   sTsubcls=strwrite_all_delimiter(  qlistsubcls(listcomb(icomb,:)),'_');
    if ~isempty(call_listcomb_icls_icomb)
        % call_listcomb_icls_icomb{icomb}  ;
        sTsubcls= [num2str(length(qlistsubcls(call_listcomb_icls_icomb{icomb}))),inp.smk1]  ;
        listcomb4P_i= setdiff([1:length(qlistsubcls)],call_listcomb_icls_icomb{icomb});
        
    else
        sTsubcls= [num2str(length(qlistsubcls(listcomb(icomb,:)))),inp.smk1]  ;
        listcomb4P_i= setdiff([1:length(qlistsubcls)],listcomb(icomb,:));
    end
    
    sTsubcls=strrep(sTsubcls,'_FQ','b');% updated Jan 16, 2019
    
    %     sPsubcls=strwrite_all_delimiter(  qlistsubcls(listcomb4P_i),'_');
    %  sPsubcls=strrep(strrep(strwrite_all_delimiter( unique(LATi.AclabelP),'_'),'FQ','b'),'cls','c') ; % updated Jan 16, 2019
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with Label Combination data structure in multi-label SVM
    if isfield(sdi.LAT,'clistclslabel_LC')
        sLC='_wLC';
    else
        sLC='';
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    try
        %corename_orig=[inp.corename,'_'];
        corename_orig=[inp.corename];
    catch
        corename_orig='';
    end
    try
        corename_orig=textual_eraseBetween_rmkw1(corename_orig,'nvar','_');
    end
    try
        corename_orig=textual_eraseBetween_rmkw1(corename_orig,'_nsamp','');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   inp.corename=[corename_orig,'icomb',num2str(icomb),'_{T-',sTsubcls,'_P-',sPsubcls,sLC,'}'];
    %   inp4Save.corename=['icomb',num2str(icomb),'_{',corename_orig,'P-',sPsubcls,'_T-',sTsubcls,sLC,'}'];
    if ~isempty(strfind(corename_orig,'ncls'))
        
        inp4Save.corename=['icomb',num2str(icomb),'_{','P-',num2str(icomb),'_T-',sTsubcls,sLC,'}'];
        
    else
        inp4Save.corename=['icomb',num2str(icomb),'_{','P-',num2str(icomb),'_T-',sTsubcls,sLC,'}','_',corename_orig];
    end
    sdi=saveAT(sdi,inp4Save);  % reassign sdi to LHS of "=" to include pathfname_AT into sdi
    oaTP=[oaTP;sdi];
end    % end of icomb
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(path_orig);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.tmpfolder4Save=tmpfolder4Save;
out.oaTP=oaTP;  % object array for TP pairs
disp('finish Atrainpk_parse_AclabelT_subcls')
end


%% ----- from Atrainpk_parse_AclabelT_subcls_OnePDS_AllCls.m ----------------
function out=Atrainpk_parse_AclabelT_subcls_OnePDS_AllCls(pathfname_AT,inp)
% parse Atrainpk based on sub-class info in AclabelT
% after parsing, all Atrainpk samples used exactly same number of times as Pset in all TP pairs
% modified from Atrainpk_Split_Odd_Even_physical_diff_samp()
% see also parse_AclabelT_subcls in ssds, Atrainpk_parse_AclabelT_subcls, ATop, Atrainpk_merge_Apred
if false
    
    clear;close all
   pathfname_AT= 'C:\work\JDSU\CUSTOMERS_OSP\BMS_OTC\ATetc\Atrainpketc__SciO_OTC_api_brand_wPillSeq_pp1-1stDerSGw15_pp2-SNV_nvar317_ncls30_nsamp1080.mat';
    inp.smk1='_P';inp.smk2='';inp.Nsubcls4T=2;
   Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp);
  %%%%%%%%%%%%%%%%%%%%%%%%%%
      clear;close all
   pathfname_AT= 'C:\work\JDSU\CUSTOMERS_OSP\BMS_OTC\ATetc\Atrainpketc__SciO_OTC_api_brand_wPillSeq_pp1-1stDerSGw15_pp2-SNV_nvar317_ncls30_nsamp1080.mat';
    inp.smk1='_P';inp.smk2='';inp.Nsubcls4T=1;
   Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp);
%--------------------------------------------------------------
cc
pathfname_AT='D:\DellG2\OLD\work\JDSU\CUSTOMERS_OSP\BMS_OTC\TestSite\API_T-10Cls_Syndrome_P-4Cls\Atrainpketc__SciO_OTC_API_T-10Cls_Syndrome_P-4Cls_wPillSeq_wLC_pp1-1stDerSGw15_pp2-SNV_nvar317_ncls10_nsamp1080.mat'
inp.smk1='_P';inp.smk2='';inp.Nsubcls4T=1;
Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp);
   
   
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isa(pathfname_AT,'struct')
    LAT= pathfname_AT;
elseif ischar(pathfname_AT)
    LAT=load(pathfname_AT);
else
    error('pathfname_AT should either be a pathfname(char) or LAT(struct)')
end

SAT=LAT;

% newPath=tmp_folder_rm_mk('TP_parse_AclabelT_subcls',pwd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % parsing T vs P based on Todd_physical_samp vs Peven_physical_samp
% use AclabelT to parse
% check whether it is applicable
try
    
    AclabelT=SAT.AclabelT;
    %%%%%%%%%%%%%%%%%%%%%%%
    % calculate number and clist of subcls in each class based on AclabelT and clistclslabel
    %
    % first extract (or load) AclabelT_subcls
    %     smk1='_P';smk2='';
    try
        smk1=inp.smk1;smk2=inp.smk2;
        if strcmp(smk1(1),'_')
            smk1_clean=smk1(2:end);
        else
            smk1_clean=smk1;
        end
        
        AclabelT_subcls=cellstr(string(smk1_clean)+textual_extractBetween_multiple_kw2(string(AclabelT),smk1,smk2));
        AclabelT_subcls=cellstr(string('Cls')+string(SAT.AclassinfoT)+'_'+AclabelT_subcls);% add this for "_OnePDS_AllCls"
        
        
    catch
        error('not ready to deal with wo smk1 or smk2 yet')
    end
    
    [qlistsubcls nsubcls]=unique_count(AclabelT_subcls);
    numcomb=length(qlistsubcls);
    
    
    %if false
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % check to see if all cls have at least one of qlistsubcls
        cnsubcls_eacls=[];
        for icls=1:length(SAT.clistclslabel)
            [qlistsubcls_icls nsubcls_icls]=  unique_count(AclabelT_subcls(SAT.AclassinfoT==icls));
            cnsubcls_eacls=[cnsubcls_eacls,{nsubcls_icls}];
        end
        
        min_N_subcls= min(cellfun(@(x) length(x),cnsubcls_eacls));
        cnsubcls_eacls_trim=cellfun(@(x) x(1:min_N_subcls),cnsubcls_eacls,'un',0);
        nsubcls_eacls=cell2mat(cnsubcls_eacls_trim);
        
%         qlistsubcls=qlistsubcls(1:min_N_subcls);
        
        if all(min(nsubcls_eacls)>0) && inp.Nsubcls4T<=length(qlistsubcls)-1
            disp('ok to proceed');
%             [numcomb,listcomb]=Cmn(length(qlistsubcls),inp.Nsubcls4T,'listyes');
            %         listcomb=flipud(listcomb);% flipud this such that Tset picked will follow intuitive fashion, i.e. starts with [1 2],[1 3], etc
        else
            disp_with_border('Not all cls have at least one entry of each subcls  OR  inp.Nsubcls4T > length(qlistsubcls)-1')
            error('will return wo result')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %end
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    saLoc=[];
    ALL_locP_icls_additional=[];
    for icomb=1:numcomb
        if false
            cLoc_T_icls=[];
            cLoc_P_icls=[];
            
            for icls=1:length(SAT.clistclslabel)
                loc_icls=find(SAT.AclassinfoT==icls);
                %             AclabelT_icls=AclabelT(loc_icls);
                AclabelT_subcls_icls=AclabelT_subcls(loc_icls);
                
                locT_icls=loc_icls(find_belong2subgrp_cstr(AclabelT_subcls_icls, qlistsubcls(listcomb(icomb,:))));
                
                
                locP_icls_4Trim=loc_icls(find_belong2subgrp_cstr(AclabelT_subcls_icls, qlistsubcls( setdiff( [1:length(qlistsubcls)],listcomb(icomb,:)))));
                
                locP_icls=setdiff(loc_icls,locT_icls);
                locP_icls=setdiff(locP_icls,ALL_locP_icls_additional);
                
                locP_icls_additional=setdiff(locP_icls,locP_icls_4Trim);
                ALL_locP_icls_additional =[ALL_locP_icls_additional;locP_icls_additional];
                
                
                cLoc_T_icls=[cLoc_T_icls;{locT_icls}];
                cLoc_P_icls=[cLoc_P_icls;{locP_icls}];
                
            end
        end
        
        
%       ea_saLoc.Loc_T=cell2mat(cLoc_T_icls);
%       ea_saLoc.Loc_P=cell2mat(cLoc_P_icls);
      
%       [qlistsubcls nsubcls]=unique_count(AclabelT_subcls);

      ea_saLoc.Loc_P=find(strcmp(AclabelT_subcls,qlistsubcls{icomb}));
      ea_saLoc.Loc_T=setdiff(col_always([1:length(SAT.AclassinfoT)]),ea_saLoc.Loc_P);

      
      
     saLoc=[saLoc;ea_saLoc];   
    end % end of icomb
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   
catch
    disp('this dataset NOT able to do parsing based on AclabelT')
    out=[];
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check whether all scans served as Pset wo missing any
% and
% whether all scans covered same number of times
all_LocP=cell2mat(arrayfun(@(x) x.Loc_P,saLoc,'un',0));
[qLocP nLocP]=unique_count(all_LocP);

if length(qLocP)==length(SAT.AclassinfoT)&& length(unique(nLocP))==1
    %if length(qLocP)==length(SAT.AclassinfoT) % with unbalanced number of subcls, some samples will be counted more than once or more than other samples
    disp('parsing is complete and uniform and OK to proceed');
elseif length(unique(nLocP))>1
    warning('some samples will be weighted more than other samples, however this should not happen ???')
    Speak_mk('some samples will be weighted more than other samples, however this should not happen ??? ')
    
else
    error('either some scans were missing to served as Pset or Not all scans covered same number of times')
end

% visually checking
 if false
     
     figure;hold on;
     for icomb=1:length(saLoc)
         plot(saLoc(icomb).Loc_T,icomb*ones(size(saLoc(icomb).Loc_T)),'bO');
         plot(saLoc(icomb).Loc_P,icomb*ones(size(saLoc(icomb).Loc_P)),'r*');
     end
     set(gca,'ylim',[0.5 icomb+0.5])
     title(['Nsubcls4T = ',num2str(inp.Nsubcls4T)])
     xlabel('sample seq');ylabel('icomb')
     
 end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_orig=pwd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tmpfolder4Save=tmp_folder_rm_mk(['TMP_T-',num2str(inp.Nsubcls4T),'s'],pwd);
tmpcorename=find_keyword_between_markers(inp.corename,'','_pp2');
if isempty(tmpcorename)
    tmpcorename= inp.corename;
end
try
    sparse_method= ['_',inp.parse_method];
catch
    sparse_method='';
end
    
tmpfolder4Save=tmp_folder_rm_mk([tmpcorename,sparse_method],pwd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(tmpfolder4Save);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parse into numcomb TP pairs
oaTP=[];  % object array for TP pairs
for icomb=1:length(saLoc)
    
    LocT_i=saLoc(icomb).Loc_T;
    LATi.RawSpectra.Tset=LAT.RawSpectra(LocT_i,:);
    LATi.Atrainpk=LAT.Atrainpk(LocT_i,:);
    LATi.AclassinfoT=LAT.AclassinfoT(LocT_i);
    try
        LATi.AclabelT=LAT.AclabelT(LocT_i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with Label Combination data structure in multi-label SVM
    try
        LATi.AclabelT_LC=LAT.AclabelT_LC(LocT_i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LocP_i=saLoc(icomb).Loc_P;
    LATi.RawSpectra.Pset=LAT.RawSpectra(LocP_i,:);
    LATi.Apred=LAT.Atrainpk(LocP_i,:);
    LATi.AclassinfoP=LAT.AclassinfoT(LocP_i);
    
    try
        LATi.AclabelP=LAT.AclabelT(LocP_i);
    end
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with Label Combination data structure in multi-label SVM
    try
        LATi.AclabelP_LC=LAT.AclabelT_LC(LocP_i);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %check whether any missing classes
    if isequal(unique(LATi.AclassinfoT),unique(LAT.AclassinfoT))
        LATi.clistclslabel=LAT.clistclslabel;
         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
         % deal with Label Combination data structure in multi-label SVM
        try
         LATi.clistclslabel_LC=LAT.clistclslabel_LC;   
        end
        try
        LATi.AclassinfoMap2LC=LAT.AclassinfoMap2LC;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        error(['missing class in this icomb = ' ,num2str(icomb)])
    end
    try
        LATi.wvl_standardize=LAT.wvl_standardize;
    end
  sdi=ssds(LATi);
  
%   sTsubcls=strwrite_all_delimiter(  qlistsubcls(listcomb(icomb,:)),'_');
   % sTsubcls= [num2str(length(qlistsubcls(listcomb(icomb,:)))),inp.smk1]  ;
    sTsubcls= ['AllOtherSamp']  ;

%  listcomb4P_i= setdiff([1:length(qlistsubcls)],listcomb(icomb,:));
  %  sPsubcls=strwrite_all_delimiter(  qlistsubcls(listcomb4P_i),'_');
        sPsubcls=strrep(qlistsubcls{icomb},'_','');

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
 % deal with Label Combination data structure in multi-label SVM
if isfield(sdi.LAT,'clistclslabel_LC')
    sLC='_wLC';
else
   sLC=''; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   try
       corename_orig=[inp.corename,'_'];
   catch
       corename_orig='';
   end
%   inp.corename=[corename_orig,'icomb',num2str(icomb),'_{T-',sTsubcls,'_P-',sPsubcls,sLC,'}'];
  inp4Save.corename=['icomb',num2str(icomb),'_{',corename_orig,'P-',sPsubcls,'_T-',sTsubcls,sLC,'}'];

  sdi=saveAT(sdi,inp4Save);  % reassign sdi to LHS of "=" to include pathfname_AT into sdi
   oaTP=[oaTP;sdi]; 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(path_orig);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out.tmpfolder4Save=tmpfolder4Save;
out.oaTP=oaTP;  % object array for TP pairs
disp('finish Atrainpk_parse_AclabelT_subcls')
end


%% ----- from BatchRun_CFP_SVM_maxDV_FOM.m ----------------------------------
function Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp )
% see --> ssds built-in method : [out_obj]=run_CFP_GM_sortTcls(obj,inp)
% see also: test_ssds_run_CFP_GM_sortTcls
%---------------------------------------------------------------------------------------------------
% revisit for KT, July 17, 2024
% main function to call --> maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone
%-----------------------------------------------------------------------------
% see also: two_stages_CFP_forcePredict   ScanThru_two_stages_CFP_forcePredict
%-------------------------------------------------------------------
% typically called by --> two_stages_CFP_forcePredict
% main function to call --> maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone
% modified from and iterative BatchRun of maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone
%------------------------------------------------------
% Mar 20, 2023
% for Cmp to ILM, see --> Implement_ILM_CFP
%--------------------------------------------
% add following, Mar 25, 2024
% inp.CFP_dvABC_SVM_kernel='linear';  
%---------------------------------
% calc of dvB in --> dvABC_etc_Global_or_Local_Model will take long time when Tset size is big
% dvB=minDVLwin_rm1fT;
%-----------------------------------------------
% set dvB_PDS_yes=1 , i.e. dvB Tcv by PDS , see --> dvABC_etc_Global_or_Local_Model.m , Mar 26, 2024
%------------------------------------------------
% fix this when No misP_forcePredict happened, Apr 18, 2024
%--------------------------------------------------------------------------------------------------------------
% see also: two_stages_CFP_forcePredict   ScanThru_two_stages_CFP_forcePredict
%---------------------------------------------------------------------------------------------------------------
% apply asmc1 on AT (  end of July, 2024 )
%----------------------------------------------------------
% save sd_iqcn_kt based on kt (or WinCls1st ) approach , end of July, 2024
% see also: kt_dvABC_etc_Global_or_Local_Model
%---------------------------------------------------------------
% block following for cases this function called by ScanThru_two_stages_CFP_forcePredict (Aug 26, 2024)
%==============================================================

if false
    cc
    pfn_GM_only= 'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\TP_FP_DM-5Powders\TruePos\Atrainpketc_DM-5Powders_nvar119_ncls5_nsampT55_nsampP15.mat' ;
    inp='';
     inp.Clsfr_short_GM ='SVM_Linear_wDecVal_APs';
%     inp.Clsfr_short_GM ='SVM_Linear_wLocalAuto'; 
    Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
    %-------------------------------------------------------------------------------------------------------------------
    % CARE  
    cc
     pfn_GM_only= 'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\CARE_mobileApp\Atrainpketc_CARE_case1_pp1-1stDerSGFL5[PO3]_pp2-SNV_nvar121_ncls6_nsampT185_nsampP32.mat'
     inp.Clsfr_short_GM ='SVM_Linear_wDecVal_APs';  % 'SVM_Linear_wDecVal_APs'  'SVM_Linear_wLocalAuto'
%       inp.Clsfr_short_GM ='SVM_Linear_wLocalAuto';  % 'SVM_Linear_wDecVal_APs'  'SVM_Linear_wLocalAuto'

    Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
     %-------------------------------------------------------------------------------------------------------------------
    % ResinKits_popular_polymers
    cc
     pfn_GM_only=  'C:\work\JDSU\Test_ACP\iACPmp\ATetc_ResinKits_popular_polymers\Atrainpketc_{T-ES-553_P-OS-145}_Cmp_SVM_ILM_nvar121_ncls10_nsampT300_nsampP302_wPopularNames.mat'
%      inp.Clsfr_short_GM ='SVM_Linear_wDecVal_APs';  % 'SVM_Linear_wDecVal_APs'  'SVM_Linear_wLocalAuto'
       inp.Clsfr_short_GM ='SVM_Linear_wLocalAuto';  % 'SVM_Linear_wDecVal_APs'  'SVM_Linear_wLocalAuto'
    Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
    
    %--------------------------------------------------------------------------------------------------------------------
    
    cc
    pfn_GM_only=  'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\TP_FP_DM-5Powders\FalsePos\Atrainpketc_{T-DM-5Powders_FalsePos-RKSS-1}_nvar119_ncls5_nsampT55_nsampP30.mat'
     inp='';
    Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
    
     %--------------------------------------------------------------------------------------------------------------------
    
    cc
     pfn_GM_only=  'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\TP_FP_DM-5Powders\FalsePos\Atrainpketc_T-DM-5Powders_P-Foreign_nvar119_ncls5_nsampT55_nsampP21.mat'
     inp='';
    Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
    %------------------------------------------------------------------------------------------------
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % revisit Mar 24, 2024 to deal with CARE carpet datasets
    % calc of dvB in --> dvABC_etc_Global_or_Local_Model will take long time when Tset size is big
    % dvB=minDVLwin_rm1fT;
    
    cc
%   pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\TruePos\Atrainpketc_{{T-(ncls7_6U_ApdCls-N6_S3_rmCls-TP)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)}[WinCls-N66]}_nvar119_ncls7_nsampT1959_nsampP100.mat'
    
%       pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\RMID_ncls19\Atrainpketc_{T-(ncls7_6U_ApdCls-N6_S3_rmCls-TP)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)}_nvar119_ncls7_nsampT1959_nsampP373.mat'
     pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\RMID_ncls19\Atrainpketc_{T-T-(ncls7_6U_ApdCls-N6_S3_rmCls-TP)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)_P-RMID_T-S1-00550_P-S1-00552_ClsP-NaN}_nvar119_ncls7_nsampT1959_nsampP599.mat'
    
    inp.Clsfr_Global='SVM_linear_wDecVal_APs';
    inp.InsituThres_scheme='IV';
    inp.CFP_dvABC_SVM_kernel='rbf';  % default set to 'rbf';
    %           inp.CFP_dvABC_SVM_kernel='linear';  %
    
    %    inp.List_nLcls=2;  % this is based on Global Model only hence this is  Not needed
    Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
    %=========================================================================
    % after run all 6 units , Mar 27, 2024 to capture all M1-num
    
    cc
      pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\TruePos\fix_M1-num\Atrainpketc_{T-(6U_woTP_ApdCls-N6_S3)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)}_nvar119_ncls7_nsampT1959_nsampP373.mat'

%     pfn_GM_only= 'C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\FalsePos\fix_M1-num\Atrainpketc_{T-T-(6U_woTP_ApdCls-N6_S3)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)_P-RMID_T-S1-00550_P-S1-00552_ClsP-NaN}_nvar119_ncls7_nsampT1959_nsampP599.mat'
%      pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\FalsePos\fix_M1-num\Atrainpketc_{T-T-(6U_woTP_ApdCls-N6_S3)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)_P-P2T_ClsP-NaN}_nvar119_ncls7_nsampT1959_nsampP600.mat'
%      pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\FalsePos\fix_M1-num\Atrainpketc_{{T-T-(6U_woTP_ApdCls-N6_S3)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)_P-P2T_ClsP-NaN}[WinCls-PP]}_nvar119_ncls7_nsampT1959_nsampP80.mat'
   
     inp.Clsfr_Global='SVM_linear_wDecVal_APs';
    inp.InsituThres_scheme='IV';
    inp.CFP_dvABC_SVM_kernel='rbf';  % default set to 'rbf';
    %           inp.CFP_dvABC_SVM_kernel='linear';  %
    
    %    inp.List_nLcls=2;  % this is based on Global Model only hence this is  Not needed
    Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
    %===============================================================
    % revisit July 4, 2024 for KT
    % nTU2
    % revisit to test final work flow : CFP_GM + ILM[nLcls2] based on nTU2 ds=12
   % revisit July 4, 2024 for KT
   cc
   %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   %----- TruePos -----
%    pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\nTU2\Atrainpketc_(12){T-(TUseq1+TUseq4)_P-(M1-600_ApdCls-N6_S3)}_nvar119_ncls8_nsampT730_nsampP373.mat'
%      pfn_GM_only= 'C:\work\JDSU\KT\ATetc_CFP_GM_SVM\TruePos\Atrainpketc_AC{1_CARE_nTU5_1_LAf_T-599_P-103}_nvar119_ncls6_nsampT2646_nsampP1343.mat'
   %-----FalsePos -----
   %      pfn_GM_only='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_CFP_GlobalModel\nTU2\Atrainpketc_{T-T-(TUseq1+TUseq4)_P-(M1-600_ApdCls-N6_S3)_P-P2T_ClsP-NaN_RMID_P-S1-00552}_nvar119_ncls8_nsampT730_nsampP600.mat'
%    pfn_GM_only= 'C:\work\JDSU\KT\ATetc_CFP_GM_SVM\FalsePos\Atrainpketc_(T-Tset)_nsampT2646_nsampP110_ClsP-NaN.mat';
   pfn_GM_only='C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_CARE_LAf_xU\wPET_CARE_nTU5_1\4U\FPos_5P\Atrainpketc_{T-2_T-MK_0514_M1-599_P-(MK_0529_M1-103)_Pset-Combined_P-T-DM-5Powders_sortTcls_ClsP-NaN}_nvar119_ncls6_nsampT2321_nsampP110.mat'
   %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   inp.Clsfr_Global='SVM_linear_wDecVal_APs';
   inp.InsituThres_scheme='IV';
   inp.CFP_dvABC_SVM_kernel='rbf';  % default set to 'rbf';
   
   Out=BatchRun_CFP_SVM_maxDV_FOM( pfn_GM_only, inp );
   
     %===============================================================
   
   % test kt vs non-kt approaches
   % begin of Aug, 2024
   cc
   %+++++++++++++++
   % % save sd_iqcn_kt based on kt (or WinCls1st ) approach , end of July, 2024 --> BatchRun_CFP_SVM_maxDV_FOM
   inp.dvABC_by_kt_yes=1;  % see also: maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone
   %+++++++++++++++++++
        path_GM_only='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\sortTcls\fix_RS'  % use this as Demo example for kt !!!
%        inp.pfn_FPos='C:\work\JDSU\Test_ACP\BioD_Plastics_Bag\ATetc_DM_5Powders\Atrainpketc_{T-DM-5Powders_sortTcls}_nvar119_ncls5_nsamp110.mat';

   %+++++++++++++++++++
   inp.Clsfr_Global='SVM_linear_wDecVal_APs';           % current settings
   inp.Clsfr_force_Predict='SVM_linear_wDecVal_APs';    % current settings
   inp.dvB_PDS_yes=0;                                   % based on All scans (current setting by DM )
   %----------------------------
   inp.InsituThres_scheme='IV';
   inp.CFP_dvABC_SVM_kernel='rbf';  % default set to 'rbf';
   %----------------------------- 
   [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(path_GM_only,'Atrainpketc_','mat');

   Out=BatchRun_CFP_SVM_maxDV_FOM( clistfilename_out{1}, inp ) ;
    
end
%============================================================================================================================
% block following for cases this function called by ScanThru_two_stages_CFP_forcePredict (Aug 26, 2024)
% cd(find_last_nonTMP_path);
% pathTMP=tmp_folder_rm_mk('TMP_2SCFP',pwd);
% cd(pathTMP );
%----------------------------------------------------
L0=load( pfn_GM_only );
sd0=ssds(L0);

L0_auto=apply_autoscale_on_Atrainpketc_L_struct( L0 ) ;
%==============================================================================================================================
%==============================================================================================================================
try
    Clsfr_short_GM=inp.Clsfr_Global;
catch
    Clsfr_short_GM='SVM_Linear_wDecVal_APs';  % default set to this
end
switch Clsfr_short_GM
    case {'Linear_wDecVal_APs','SVM' , 'SVM_Linear_wDecVal_APs' , 'SVM_linear_wDecVal_APs'}
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        handles4Clsfr.L=L0_auto;
        [handles4Clsfr out4Clsfr]=RUN_SVM_linear_wDecVal_CmpClsfr(handles4Clsfr);
        all_predcls= out4Clsfr.predcls;
        loc_misP=find(all_predcls~=L0.AclassinfoP);
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     case {'SVM_OVA_RBF_wDecVal', 'ova_rbf_wDecVal'}
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        handles4Clsfr.L=L0_auto;
        
       [handles4Clsfr out4Clsfr]=RUN_LIBSVM_ova_rbf_wDecVal_CmpClsfr(handles4Clsfr);

        all_predcls= out4Clsfr.predcls;
        loc_misP=find(all_predcls~=L0.AclassinfoP);
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   
        
    case { 'SVM_Linear_wDecVal_APs_LocalAuto' ,'SVM_Linear_wLocalAuto' } 
        pathfname_AT_LA = L0_auto ;
        inp_LA.enable_LocalAuto_yes=1;   % run Local Auto version of APs libsvm wDecVal
        inp_LA.libsvm_kt='linear';inp_LA.show_fig_yes=0;
        para_norm_LA=0;para_asmc_LA=1; % for 'SVM_Linear_wLocalAuto' Must set this to One !!!
                                            
        out4Clsfr = libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto(pathfname_AT_LA,para_norm_LA,para_asmc_LA,inp_LA)  ;
        
        all_predcls= out4Clsfr.predcls;
        loc_misP=find(all_predcls~=L0.AclassinfoP);
        
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    otherwise
        error('Global Model type Not supported ??');
end
%==============================================================================================================================
%==============================================================================================================================

qclsnum_apor_predcls=unique_appear_order(all_predcls) ;
inp4eaBR.fig_yes=0;
% loc_Pset=repmat(NaN,size(L0.AclassinfoP));
all_maxDV=repmat(NaN,size(L0.AclassinfoP));
all_thres_insitu=repmat(NaN,size(L0.AclassinfoP));
all_qcn_i=repmat(NaN,size(L0.AclassinfoP));
all_FOM=repmat(NaN,size(L0.AclassinfoP));

all_dvABC_gm=[];
call_nPDS_WinCls=[];
all_out_eaBR=[];
%  winner_clsnum=find(strcmp(L0.clistclslabel,inp.winner_clistclslabel));
for iqcn=1: length(qclsnum_apor_predcls )
    qcn_i=qclsnum_apor_predcls(iqcn);
    inp4eaBR.winner_clistclslabel=L0.clistclslabel{qcn_i };
    %--------------------------------------
%     inp4eaBR.Clsfr_Global=inp.Clsfr_Global;
%      inp4eaBR.InsituThres_scheme=inp.InsituThres_scheme;
%      inp4eaBR.List_nLcls=inp.List_nLcls;
      inp4eaBR=catstruct(inp4eaBR,inp);
     
    %****************************************
    inp_iqcn.loc_rm_Pset=find(all_predcls~=qcn_i);
    sd_iqcn = sd0.rm_samps_Pset_or_Tset_in_TPpair(inp_iqcn);
    inp_iqcn.corename=['{',find_keyword_between_markers(fileparts_name_ext(pfn_GM_only),'Atrainpketc_','_nvar'),'[WinCls-',inp4eaBR.winner_clistclslabel ,']','}'];
    sd_iqcn=sd_iqcn.saveAT( inp_iqcn );
    %--------------------------------------------------------------------------------
    % apply asmc1 on AT (  end of July, 2024 )
   LAT_sd_iqcn_asmc1=apply_autoscale_on_Atrainpketc_L_struct(sd_iqcn.LAT);
     sd_iqcn_asmc1 =ssds(LAT_sd_iqcn_asmc1);
      inp_iqcn_asmc1.corename=strrep(inp_iqcn.corename,']',']_asmc1');
     sd_iqcn_asmc1= sd_iqcn_asmc1.saveAT( inp_iqcn_asmc1);
    %--------------------------------------------------------------------------------
    pfn_GM_only_Winner_Only_iqcn=sd_iqcn.pathfname_AT;
%     inp_iqcn.cls_pick= { inp4eaBR.winner_clistclslabel }  ;   %
%     inp_iqcn.corename=['{',find_keyword_between_markers(fileparts_name_ext(pfn_GM_only),'Atrainpketc_','_nvar'),'[',inp4eaBR.winner_clistclslabel ,']','}'];
%     sd0=ssds(L0);
%     sd_winP_iqcn=extract_Pset(sd0,inp_iqcn);% need  inp.cls_pick
    %***************************************
    %=============================================================================================================
    %=============================================================================================================
    % calc of dvB in --> dvABC_etc_Global_or_Local_Model will take long time when Tset size is big
    %
    out_eaBR=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone (pfn_GM_only_Winner_Only_iqcn, inp4eaBR );
    all_out_eaBR=[all_out_eaBR ;  out_eaBR ];
    %=============================================================================================================
    %=============================================================================================================
    %++++++++++++++++++++++++++++++++++++++++++++++++++++
   if ~isempty( out_eaBR.LAT_rq_sT)
           inp_iqcn_kt.corename=['{',find_keyword_between_markers(fileparts_name_ext(pfn_GM_only),'Atrainpketc_','_nvar'),'[WinCls1st-',inp4eaBR.winner_clistclslabel ,']','}'];    % save sd_iqcn_kt based on kt (or WinCls1st ) approach , end of July, 2024
           sd_iqcn_kt=ssds( out_eaBR.LAT_rq_sT);
           sd_iqcn_kt=sd_iqcn_kt.saveAT( inp_iqcn_kt);   % save sd_iqcn_kt based on kt (or WinCls1st ) approach , end of July, 2024
   end
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++
    all_dvABC_gm=[all_dvABC_gm; out_eaBR.dvABC_gm];

    call_nPDS_WinCls=[call_nPDS_WinCls;{out_eaBR.nPDS_WinCls}];

    %======================================
    loc_Pset_i=find(all_predcls==qcn_i);
    all_maxDV(loc_Pset_i)=out_eaBR.maxDV_gm;
    all_thres_insitu( loc_Pset_i ) = out_eaBR.thres_insitu_IV;
    all_qcn_i( loc_Pset_i ) =qcn_i;
    all_FOM(loc_Pset_i)=out_eaBR.FOM;
end
%------------------------------------------------
% checking
if false
    if ~isequal(all_qcn_i,all_predcls)
        error('something wrong with all_qcn_i');
    else
        if all(isnan(L0.AclassinfoP))
            tb_seq=[];
        else
            tb_seq =  findseq(all_qcn_i) ;
        end
        
    end
else
    tb_seq=[];
end
%========================================================
if ~all(isnan(L0.AclassinfoP))
    % TruePos
     loc_misP_CFP=find(all_FOM<0.5);
     loc_passP_CFP=find(all_FOM>=0.5);
     loc_misP_forcePredict=loc_misP;
     sNmisP_fP=['NmisP_forcePredict=',num2str(length(loc_misP_forcePredict))];

else
    % FalsePos
    loc_misP_CFP=find(all_FOM>=0.5);
    loc_passP_CFP=find(all_FOM<0.5);
    loc_misP_forcePredict=[];
    sNmisP_fP='';
end
%================================================
loc_misP_All=unique([loc_misP_forcePredict;loc_misP_CFP]);
sNmisP_All=['NmisP_All=',num2str(length(loc_misP_All))];
%================================================
%--------------------------------------------
call_dvABC_gm_sdvB_PDS_yes  =arrayfun(@(x) x.sdvB_PDS_yes,  all_dvABC_gm,'un',0) ;
try
    Qcall_dvABC_gm_sdvB_PDS_yes = unique(call_dvABC_gm_sdvB_PDS_yes) ;
    if length(Qcall_dvABC_gm_sdvB_PDS_yes )==1 && ~isempty(Qcall_dvABC_gm_sdvB_PDS_yes{1})
        sQcall_dvABC_gm_sdvB_PDS_yes=Qcall_dvABC_gm_sdvB_PDS_yes{1};
    elseif isempty(Qcall_dvABC_gm_sdvB_PDS_yes{1})
        sQcall_dvABC_gm_sdvB_PDS_yes='dvB Tcv based on All scans';
    else
        sQcall_dvABC_gm_sdvB_PDS_yes='';
    end
catch
 sQcall_dvABC_gm_sdvB_PDS_yes='dvB Tcv based on All scans';   
end
%----------------------------------------------------------------------
hf_maxDV=figure;hold on;set(gcf,'position',[ 0.5147    0.2317    1.2373    0.6261]*1000);
ylabel('maxDV of Pset');xlabel('Pset Sample Seq');

% plot(all_maxDV,'b-*');

if isempty( tb_seq )
    plot(all_maxDV,'b-*');
    plot( all_thres_insitu,'color',color_CH('o'),'marker',marker_CH('-'),'linewidth',2);
else
    for i_tb_seq=1:length( tb_seq (:,1))
        loc_seq_i_begin_end=tb_seq(i_tb_seq,2:3);
        loc_seq_i = [loc_seq_i_begin_end(1): loc_seq_i_begin_end(2)] ;
        plot(   loc_seq_i , all_thres_insitu(loc_seq_i),'color',color_CH('o'),'marker',marker_CH('d'),'linewidth',2);
        plot(   loc_seq_i , all_maxDV(loc_seq_i),'color',color_CH('b'),'marker',marker_CH('*'));
    end
end
%---------------------------------
if ~all(isnan(L0.AclassinfoP))
    loc_misP_CFP_PS=  setdiff(loc_misP_CFP ,loc_misP_forcePredict);                % PS-neg
    sNmisP_PS_neg=['NmisP_PS_neg=',num2str(length(loc_misP_CFP_PS))];  % PS-neg
    
    %-----------------------------
    % TruePos and show force prediction results --> loc_misP
    %     hp_misP_forcePredict =  plot(loc_misP_forcePredict, all_maxDV( loc_misP_forcePredict ),'color',color_CH('m'),'marker',marker_CH('h'),'markersize',6,'linestyle','none','markerfacecolor','m');  %  loc_misP_forcePredict=loc_misP;
    if ~isempty(loc_misP_forcePredict)
        hp_misP_forcePredict =  plot_vline(loc_misP_forcePredict,'m');  %  loc_misP_forcePredict=loc_misP;
    else
        hp_misP_forcePredict=[];
    end
    loc_misP_forcePredict_and_CFP=intersect(loc_misP_forcePredict,loc_misP_CFP);     % PF-neg
    sNmisP_PF_neg=['NmisP_PF_neg=',num2str(length(loc_misP_forcePredict_and_CFP))];  % PF-neg
    %---------------------------------
    loc_misP_forcePredict_but_Pass_CFP=setdiff(loc_misP_forcePredict,loc_misP_CFP); % PF-pos
    sNmisP_PF_pos=['NmisP_PF_pos=',num2str(length(loc_misP_forcePredict_but_Pass_CFP))];  % PF-pos
    
    
end

%---------------------------------
hp_misP_CFP=plot(loc_misP_CFP, all_maxDV( loc_misP_CFP),'color',color_CH('o'),'marker',marker_CH('x'),'markersize',15,'linewidth',2,'linestyle','none');
%==================================
if ~all(isnan(L0.AclassinfoP))
    if isempty(hp_misP_forcePredict)                % fix this when No misP_forcePredict happened, Apr 18, 2024
        legend([ hp_misP_CFP  ],{'misP by CFP'});   % fix this when No misP_forcePredict happened, Apr 18, 2024
    else
        legend([hp_misP_forcePredict(1) hp_misP_CFP  ],{'misP by force Predict','misP by CFP'});
    end
else
    legend([hp_misP_CFP  ],{'misP by CFP'});
end
%-----------------------------------
enlarge_axis;
title_usF(['Both CFP & force_Predict based on --> ', Clsfr_short_GM]);
title_add(gca,fileparts_name_ext(pfn_GM_only));
try
title_add(gca,['CFP_dvABC_SVM_kernel=',inp.CFP_dvABC_SVM_kernel]);
end
if ~all(isnan(L0.AclassinfoP))
    title_add(gca,['NmisP_CFP=',num2str(length(loc_misP_CFP)),'   ',sNmisP_fP,'   ',sNmisP_All,'   ',sQcall_dvABC_gm_sdvB_PDS_yes]  );
    title_add(gca,[sNmisP_All,' --> ',sNmisP_PS_neg,'   ',sNmisP_PF_pos,'   ',sNmisP_PF_neg]  );
else
    title_add(gca,['NmisP_CFP=',num2str(length(loc_misP_CFP)),'   ',sNmisP_fP,'   ',sNmisP_All,'   ',sQcall_dvABC_gm_sdvB_PDS_yes]  );
end
%------------------------------------------------------------
hf_FOM=figure;hold on;set(gcf,'position',1000*[ 0.7217    0.1493    1.2931    0.6261 ]);
plot(all_FOM,'c-*');
%     plot( all_thres_insitu,'color',color_CH('o'),'marker',marker_CH('d'));
% if ~all(isnan(L0.AclassinfoP))
%     % TruePos
%      loc_misP_CFP=find(all_FOM<=0.5);
% else
%     % FalsePos
%     loc_misP_CFP=find(all_FOM>0.5);
% end
plot(loc_misP_CFP, all_FOM( loc_misP_CFP),'rO');

plot_hline(0.5,'o');
ylabel('FOM');
xlabel('Pset Sample Seq');
enlarge_axis;
% title_usF(Clsfr_short_GM);
title_usF(['Both CFP & force_Predict based on --> ', Clsfr_short_GM]);

title_add(gca,fileparts_name_ext(pfn_GM_only));
try
title_add(gca,['CFP_dvABC_SVM_kernel=',inp.CFP_dvABC_SVM_kernel]);
end
% title_add(gca,['NmisP_CFP=',num2str(length(loc_misP_CFP)),'   ',sQcall_dvABC_gm_sdvB_PDS_yes]  );
title_add(gca,['NmisP_CFP=',num2str(length(loc_misP_CFP)),'   ',sNmisP_fP,'   ',sNmisP_All,'   ',sQcall_dvABC_gm_sdvB_PDS_yes]  );

%=========================================================
Out.loc_misP_CFP=loc_misP_CFP;
Out.loc_passP_CFP=loc_passP_CFP;
Out.all_maxDV=all_maxDV;
Out.all_thres_insitu=all_thres_insitu;
Out.all_predcls=all_predcls;
Out.clistclslabel=L0.clistclslabel;
Out.AclassinfoP=L0.AclassinfoP;
Out.AclabelP=L0.AclabelP;
Out.sQcall_dvABC_gm_sdvB_PDS_yes=sQcall_dvABC_gm_sdvB_PDS_yes;
Out.WinCls=all_qcn_i;
Out.FOM=all_FOM;
Out.all_nPDS_WinCls=call_nPDS_WinCls; % collect nPDS_WinCls, May 1, 2024
%-------------------------------------
if  inp.dvABC_by_kt_yes
arrayfun(@(x) copyfile(x.pfn_dvABC,find_last_nonTMP_path),all_out_eaBR) ;
arrayfun(@(x) copyfile(x.pfn_wc1_wP,find_last_nonTMP_path),all_out_eaBR) ;
end
%========================================================
 cd(find_last_nonTMP_path);
%========================================================
done_with_this_function;
end
%=======================================================


%% ----- from Cmn.m ---------------------------------------------------------
function [numcomb,listcomb]=Cmn(m,n,listyesno)
% pls use nchoosek, see examples in libsvm_LOH_allClsModel_Anton_predict or  libsvm_LOH_pred_APs
% ----------------------------------------------------------------------
 %----------------------------------------------------------------------
 % old method below
%   [numcomb,listcomb]=Cmn(ncls,2,'listyes');
%    listcomb=flipud( listcomb ) ;
%---------------------------------------------------------
 % change to following, Feb 11, 2023
% listcomb =nchoosek([1:ncls],2) ;
% numcomb=length(listcomb(:,1));
%========================================
%------------------------------------------------------------------
% find all possible combinations
% listyesno='listyes'; %default
% see also nchoosecrit
if false
    
[numcomb,listcomb]=Cmn(6,3,'listyes')

[numcomb,listcomb]=Cmn(16,8,'listno')

[numcomb,listcomb]=Cmn(5,2)  % listyesno='listyes'; %default

[numcomb,listcomb]=Cmn(20,2,'listyes')

[numcomb,listcomb]=Cmn(54,2,'listyes');   % this too big to run

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%
% run old version factdes, latest version from PLS toolbox changed to something that is not compatiable with Cmn
path_prev=pwd;
cd('C:\work\JDSU\mfiles\jdsu_Utility_mfiles');% run old version factdes, latest version from PLS toolbox changed to something that is not compatiable with Cmn
allcomb=factdes(m,2);
cd(path_prev);
%%%%%%%%%%%%


loc_Cmn=find(sum(allcomb,2)==n);
numcomb=length(loc_Cmn);
if ~exist('listyesno','var')
    listyesno='listyes'; %default
end   
 
switch listyesno
    case 'listyes'
        listcomb_binary=allcomb(loc_Cmn,:);
        for i=1:numcomb
            listcomb(i,:)=find(listcomb_binary(i,:)==1);
        end
        
    case 'listno'
        
        listcomb=[];
end
end


%% ----- from FOM_logistic_DV_Calc.m ----------------------------------------
function max_DV_Q = FOM_logistic_DV_Calc(max_DV,thres_insitu )
%  'Orig_3parameters'         % default setting % default setting % default setting % default setting % default setting % default setting 
% see also: RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr   Implement_ILM_CFP
% see also: maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone   BatchRun_CFP_SVM_maxDV_FOM
% CMH : Mar 20, 2023
%---------------------------------
% see also: logit 
%====================================================================================================================
if length( thres_insitu ) ==1
    thres_insitu_ALL=repmat(thres_insitu,size( max_DV));
elseif length( thres_insitu )== length( max_DV)
    thres_insitu_ALL= thres_insitu;
else
    error('thres_insitu must be either scalr or same length as max_DV');
end
%====================================================================================================================

thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
% logistic_DV_yes=1;%  if logistic_DV_yes
logistic_output_type='Orig_3parameters' ;                %   'InflectPtZero'  'Orig_3parameters'   '4parameters'
alpha=5;
%=========================================================================
Qinf=1;
% logistic_output_type='InflectPtZero'                 %   'InflectPtZero'  'Orig_3parameters'   '4parameters'
switch logistic_output_type                                                                                                % revisit per Brad's figure of merit that spans 0 to 1, Jan 28, 2021
    case 'InflectPtZero'
        max_DV_Q=                    logistic_output_InflectPtZero(Qinf,thalf, alpha,max_DV); % revisit per Brad's figure of merit that spans 0 to 1, Jan 28, 2021
        max_DV_Q_thres_insitu=logistic_output_InflectPtZero(Qinf,thalf(end),alpha,thalf(end));% for plotting thres orange line below
        %======================================================================================================================================
        %**************************************************************************************************************************************
    case   'Orig_3parameters'         % default setting % default setting % default setting % default setting % default setting % default setting 
        max_DV_Q=                    logistic_output(Qinf,thalf,alpha,max_DV); % revisit per DM's figure of merit request, July 13, 2020
        % for plotting thres orange line below
        %         max_DV_Q_thres_insitu=logistic_output(Qinf,thalf(end),alpha,thalf(end));% for plotting thres orange line below
        %**************************************************************************************************************************************
        %======================================================================================================================================
        
    case   '4parameters'
        Qmin=-1;
        max_DV_Q=                    logistic_output_4parameters(Qinf,thalf,Qmin, alpha,max_DV); % revisit per Brad's figure of merit that spans 0 to 1, Jan 28, 2021
        max_DV_Q_thres_insitu= logistic_output_4parameters(Qinf,thalf(end),Qmin,alpha,thalf(end));% for plotting thres orange line below
    otherwise
        error(['logistic_output_type --> ', logistic_output_type,' Not supported !!!'])
end
end

% all_maxDecVal_P_logisticDV( sa_UniqueLocalModel(iQLM).loc_in_IS)=max_DV_Q;
%=========================================================================


%% ----- from IsNear.m ------------------------------------------------------
function tf=IsNear(a,b,tol)
%ISNEAR True Where Nearly Equal.
% ISNEAR(A,B) returns a logical array the same size as A and B that is True
% where A and B are almost equal to each other and False where they are not.
% A and B must be the same size or one can be a scalar.
% ISNEAR(A,B,TOL) uses the tolerance TOL to determine nearness. In this
% case, TOL can be a scalar or an array the same size as A and B.
%
% When TOL is not provided, TOL = SQRT(eps).
%
% Use this function instead of A==B when A and B contain noninteger values.
% D.C. Hanselman, University of Maine, Orono, ME 04469
% Mastering MATLAB 7
% 2005-03-09
% see also: IsNear_2AT get_MN_wvl  RUN_SIMCA_CmpClsfr,  isequal, isequalfp
% see also: isequaltol (added Feb 18, 2023 and seems work better)
%--------------------------------------------------------------------------
if nargin==2
%    tol=sqrt(eps);       % original version
	tol=sqrt(eps(max(abs(a),abs(b))));     %  my version. sqrt seems like 'overdamping'
end
% when in need of optimization, drop the error checks
if ~isnumeric(a) || isempty(a) || ~isnumeric(b) || isempty(b) ||...
   ~isnumeric(tol) || isempty(tol)
   error('Inputs Must be Numeric.')
end
if any(size(a)~=size(b)) && numel(a)>1 && numel(b)>1
   error('A and B Must be the Same Size or Either can be a Scalar.')
end
% main line
tf=abs((a-b))<=abs(tol);
end


%% ----- from IsNear_2AT.m --------------------------------------------------
function  out=IsNear_2AT(AT1,AT2,tol)
% see also: RUN_SIMCA_CmpClsfr, IsNear
% see also: isequaltol (added Feb 18, 2023 and seems work better)
if false
    
    cc
    pathfname_AT='C:\work\JDSU\Test_ACP\Mayne2020\Results_Mayne2020\4EM\ATetc_4EM\Atrainpketc_{ResinKits_P-rk1_T-3rk_RKSS-24_25_26_27}_nvar121_ncls4_nsampT360_nsampP120.mat';
    L=load(pathfname_AT);
    AT1=L.Atrainpk;
    AT2=auto(AT1);
    tol=1e-13;
    IsNear_2AT(AT1,AT2,tol)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % AT2 created by auto AT1 twice
     cc
    pathfname_AT='C:\work\JDSU\Test_ACP\Mayne2020\Results_Mayne2020\4EM\ATetc_4EM\Atrainpketc_{ResinKits_P-rk1_T-3rk_RKSS-24_25_26_27}_nvar121_ncls4_nsampT360_nsampP120.mat';
    L=load(pathfname_AT);
    AT1=auto(L.Atrainpk);
    
    [Lasmc.Atrainpk,Lasmc.Apred,asmc_mean_std]=normasmc_trainpk_pred(L.Atrainpk,L.Apred,0,1);
    AT2=auto(Lasmc.Atrainpk);
     tol=1e-15;
    IsNear_2AT(AT1,AT2,tol)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % AT2 created by auto AT1 twice
     cc
    pathfname_AT='C:\work\JDSU\Test_ACP\Mayne2020\Results_Mayne2020\4EM\ATetc_4EM\Atrainpketc_{ResinKits_P-rk1_T-3rk_RKSS-24_25_26_27}_nvar121_ncls4_nsampT360_nsampP120.mat';
    L=load(pathfname_AT);
    AT1=auto(L.Atrainpk);
    
    [Lasmc.Atrainpk,Lasmc.Apred,asmc_mean_std]=normasmc_trainpk_pred(L.Atrainpk,L.Apred,0,1);
    AT2=auto(Lasmc.Atrainpk);
     tol=1e-13;
    IsNear_2AT(AT1,AT2,tol)
    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% out=all(all(IsNear(auto(LAT.Atrainpk),LAT.Atrainpk,1e-13)))   ;
out=all(all(IsNear(   AT1  , AT2, tol)));

%     isequal(AT1  , AT2)


done_with_this_function;
end


%% ----- from KennardStone.m ------------------------------------------------
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


%% ----- from MLOCM_QX_or_PX_pickFeat2AT.m ----------------------------------
function out=MLOCM_QX_or_PX_pickFeat2AT(pathfname_QPX_wAUC,pfn_AS,inp)
% modified from part of prep_MLOCM_Y(path_raw,pfn_AS,pfn_9f,inp)
if false
    
    cc
    pfn_AS='C:\work\JDSU\Test_ML_UCP\datasets_mixed_attrib\X4Y_MLOCM\QX_LS_Oct10\baseline.mat'
     pathfname_QPX_wAUC='C:\work\JDSU\Test_ML_UCP\QPX_wAUC\PX_fg_wAUC_MLOCM_PX_fg_PX_LS_Oct5_Nfeat78.mat'
       inp.AUC_thres=0.50;
            inp.TP_parse_method='ConsecutiveBlock';   % 'ConsecutiveBlock'  'Split_Odd_Even'

%     pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\QX_wAUC_MLOCM_QX_QX_LS_Oct10_Nfeat37.mat'
%     inp.AUC_thres=[0.6   0.8];
    
%         pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\QX_wAUC_MLOCM_QX_QX_LS_Oct10_Nfeat37.mat'
%     inp.AUC_thres=[0.6   0.75];
    
%             pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\QX_wAUC_MLOCM_QX_QX_LS_Oct10_Nfeat37.mat'
%     inp.AUC_thres=[0.5];
    MLOCM_QX_or_PX_pickFeat2AT(pathfname_QPX_wAUC,pfn_AS,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        cc
    pfn_AS='C:\work\JDSU\Test_ML_UCP\datasets_mixed_attrib\X4Y_MLOCM\QX_LS_Oct10\baseline.mat'
    pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\QX_wAUC_MLOCM_QX_QX_LS_Oct10_Nfeat37.mat'
   %   inp.AUC_thres=[0.95];
           inp.AUC_thres=[0.65];
%           inp.AUC_thres=[0.50];
%           inp.AUC_thres=[0.80];

     inp.TP_parse_method='ConsecutiveBlock';   % 'ConsecutiveBlock'  'Split_Odd_Even'
%           inp.TP_parse_method='Split_Odd_Even';   % 'ConsecutiveBlock'  'Split_Odd_Even'

    MLOCM_QX_or_PX_pickFeat2AT(pathfname_QPX_wAUC,pfn_AS,inp)
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % PX LbL features
      cc
    pfn_AS='C:\work\JDSU\Test_ML_UCP\datasets_mixed_attrib\X4Y_MLOCM\QX_LS_Oct10\baseline.mat'
%     pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\QX_wAUC_MLOCM_QX_QX_LS_Oct10_Nfeat37.mat'
%   pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\PX_fL_wAUC_MLOCM_PX_fL_LbL_Nfeat180.mat'
 %pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\PX_fL_wAUC_MLOCM_PX_fL_LbL_Nfeat540.mat'
 pathfname_QPX_wAUC=  'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\PX_fL_wAUC_MLOCM_PX_fL_LbL_Nfeat600_{ProPara-TMP2}.mat'
 
%      inp.AUC_thres=[0.5];
%        inp.AUC_thres=[0.6];
     inp.AUC_thres=[0.65];

       inp.TP_parse_method='ConsecutiveBlock';   % 'ConsecutiveBlock'  'Split_Odd_Even'
%           inp.TP_parse_method='Split_Odd_Even';   % 'ConsecutiveBlock'  'Split_Odd_Even'

    MLOCM_QX_or_PX_pickFeat2AT(pathfname_QPX_wAUC,pfn_AS,inp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   cc
    pfn_AS='C:\work\JDSU\Test_ML_UCP\datasets_mixed_attrib\X4Y_MLOCM\QX_LS_Oct10\baseline.mat'
% pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\PX_fL_wAUC_MLOCM_PX_fL_LbL_Nfeat300_{ProPara-RD}.mat'
pathfname_QPX_wAUC='C:\work\JDSU\Test_ML_UCP\QPX_wAUC\PX_fg_wAUC_MLOCM_PX_fg_{ProPara-}_Nfeat78_revisit.mat'
% pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\ScanThruALL'
%  inp.AUC_thres=[0.62];
 inp.AUC_thres=[0.60];

       inp.TP_parse_method='ConsecutiveBlock';   % 'ConsecutiveBlock'  'Split_Odd_Even'
%           inp.TP_parse_method='Split_Odd_Even';   % 'ConsecutiveBlock'  'Split_Odd_Even'

    MLOCM_QX_or_PX_pickFeat2AT(pathfname_QPX_wAUC,pfn_AS,inp)

  
  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Las=load(pfn_AS);
Lxa=load(pathfname_QPX_wAUC);

core1=find_keyword_between_markers(    fileparts_name_wo_ext( pathfname_QPX_wAUC),'','_wAUC');
core2=strrep(strrep_recursive(['AUC-thres',strrep(sprintf('%0.2f', inp.AUC_thres),'.','p')],'  ',' '),' ','-');  % very important to use --> sprintf('%0.2f',...)
%%%%%%%%%%%%%%%%
sProPara=find_keyword_between_markers(fileparts_name_wo_ext(pathfname_QPX_wAUC),'{','}');
% sProPara=['_{ProPara-',strrep(sProPara,'features_',''),'}'];


%%%%%%%%%%%%%%%%%%%%
if false
    sort(Lxa.AUC.all_AUC_final)
end

%checking 
if length(Lxa.AUC.all_AUC_final)==length(Lxa.QPX(1,:))
    
    
    if length(strfind(core2,'-'))==1
%          if inp.AUC_thres==0.5
%           ds_feat_pick=find(Lxa.AUC.all_AUC_final>=inp.AUC_thres);   
%          else
        ds_feat_pick=find(Lxa.AUC.all_AUC_final>inp.AUC_thres);
%          end
        
    elseif length(strfind(core2,'-'))==2
        thres_low=min(inp.AUC_thres);
        thres_high=max(inp.AUC_thres);
%         if thres_low==0.5
%          ds_feat_pick=find( Lxa.AUC.all_AUC_final>=thres_low & Lxa.AUC.all_AUC_final<=thres_high  );   
%         else
        ds_feat_pick=find( Lxa.AUC.all_AUC_final>thres_low & Lxa.AUC.all_AUC_final<=thres_high  );
%         end
    end
    
    
else
    error('size of Lxa.QPX vs Lxa.AUC.all_AUC_final NOT matched')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(ds_feat_pick)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    call_featureName_pick=Lxa.AUC.call_featureName(ds_feat_pick);
    call_featureName_pick_AUC=num2cell(Lxa.AUC.all_AUC_final(ds_feat_pick));
    call_featureSeqNum=num2cell(col_always(ds_feat_pick));
    cprint={'featureSeqNum','featureName','AUC'};
    cprint=[cprint;[call_featureSeqNum,call_featureName_pick, call_featureName_pick_AUC]];
    sNfP=['_NfeatPick',num2str(length(ds_feat_pick))];
    fname_featPick=['Features_Pick_',core1,'_',core2,sNfP,'_(',fileparts_name_wo_ext(pathfname_QPX_wAUC),')','.xlsx']
    xlswrite_ChkLn(fname_featPick,cprint);
    disp_with_border([fname_featPick,' has been saved']);
    out.XLSX_fname_featPick=fname_featPick;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %
    if strcmp(core1,'QX')
        fp=setdiff(ds_feat_pick,37);
    else
        fp=ds_feat_pick;
    end
    
    
    LAT.Atrainpk=Lxa.QPX(:,fp);
    LAT.AclassinfoT=replace_CH(Las.idx,0,2);
    LAT.clistclslabel={'pass','fail'};
    %  LAT.wvl_standardize=[1 2];
    LAT.wvl_standardize=row_always(ds_feat_pick);
    
    LAT.RawSpectra=LAT.Atrainpk;
    LAT.AclabelT=cellstr("SampSeq"+[1:length(LAT.AclassinfoT)]'+"_Cls-"+LAT.AclassinfoT);
    sd=ssds(LAT);
    
    
    %  inp4sd.corename='{NewQX_LS-Oct10_feat22_23}';
    inp4sd.corename=['{',core1,'_',sProPara,'_',core2,'}'];
    
    sd=sd.saveAT(inp4sd);   % very important to add this line !!!
    switch inp.TP_parse_method
        case 'ConsecutiveBlock'
            inp4parse.parse_method_sub='SameFQallCls'; % 'AllPerm' (default)
            inp4parse.Nfold=3;  % inp.Nfold=3 ; (default)
            inp4parse.corename_parse_folder=inp4sd.corename;
            inp4parse.corename=inp4sd.corename;
            
            out_CB=sd.parse_Consecutive_Block(inp4parse);
            
            %  out_CB=parse_Consecutive_Block(sd.pathfname_AT,inp4parse);
            
        case 'Split_Odd_Even'
            sd.Split_Odd_Even;
    end
    out_CB.ds_feat_pick=ds_feat_pick;
else
    out.XLSX_fname_featPick='';
    out_CB='';
    call_featureName_pick='';
    LAT='';
end
 
 out.ds_feat_pick=ds_feat_pick;
 out.N_ds_feat_pick=length(ds_feat_pick);
out.call_featureName_pick=call_featureName_pick;
out.all_featureName_pick_AUC=Lxa.AUC.all_AUC_final(ds_feat_pick);
out.LAT=LAT;
 out.out_CB=out_CB;
 
return



switch ds_feat_pick
    case 'fp_22_23'
 % AT based on feat22 feat23
 fp=[22 23];
 LAT.Atrainpk=QX(:,fp);
 LAT.AclassinfoT=replace_CH(Las.idx,0,2);
 LAT.clistclslabel={'pass','fail'};
 LAT.wvl_standardize=[1 2];
 LAT.RawSpectra=LAT.Atrainpk;
 LAT.AclabelT=cellstr("SampSeq"+[1:length(LAT.AclassinfoT)]'+"_Cls-"+LAT.AclassinfoT);
 sd=ssds(LAT);
 inp4sd.corename='{NewQX_LS-Oct10_feat22_23}';
 sd=sd.saveAT(inp4sd);
 
 sd.Split_Odd_Even;
 
 
    case  'fp_all'
  fp=[1:37];
 LAT.Atrainpk=QX(:,fp);
 LAT.AclassinfoT=replace_CH(Las.idx,0,2);
 LAT.clistclslabel={'pass','fail'};
 LAT.wvl_standardize=[1 : 37];
 LAT.RawSpectra=LAT.Atrainpk;
 LAT.AclabelT=cellstr("SampSeq"+[1:length(LAT.AclassinfoT)]'+"_Cls-"+LAT.AclassinfoT);
 sd=ssds(LAT);
 inp4sd.corename='{NewQX_LS-Oct10_feat_all}';
 sd.saveAT(inp4sd);
 
end
end


%% ----- from MLbClsfr_AclassinfoMap2LC_loc_misP.m --------------------------
function [loc_misP predcls_LC  out]=MLbClsfr_AclassinfoMap2LC_loc_misP(L,predcls_GM,PAS_GM)
% this function typically called by --> RUN_SVM_linear_wDecVal_CmpClsfr
% revisit this Mar 14, 2024
%================================================================================

predicted_label_wDecVal_APs_LinearKernel=predcls_GM;
PAS_libsvm_wDecVal_APs_LinearKernel=PAS_GM;

% deal with MLbClsfr with AclassinfoMap2LC
% loc_misP=find(predicted_label_wDecVal_APs_LinearKernel~=L.AclassinfoP);
% deal with Prediction part of Label Combination data structure in multi-label SVM, Apr 8, 2023
% need L.AclassinfoMap2LC
if isfield(L,'AclassinfoMap2LC')
    % deal with Label Combination data structure in multi-label SVM
    AclassinfoP_LC=replace_CH(L.AclassinfoP,L.AclassinfoMap2LC);
    predcls_LC=replace_CH(predicted_label_wDecVal_APs_LinearKernel,L.AclassinfoMap2LC);
    loc_misP=find(predcls_LC~=AclassinfoP_LC);
    out.AclassinfoP_LC=AclassinfoP_LC;
    
else
    loc_misP=find(predicted_label_wDecVal_APs_LinearKernel~=L.AclassinfoP);
    out.AclassinfoP_LC='';
    predcls_LC='';
end
if isfield(L,'AclassinfoMap2LC')
    out.predcls=predcls_LC;
    out.predcls_LC=predcls_LC;
else
    out.predcls= predicted_label_wDecVal_APs_LinearKernel;
    out.predcls_LC='';
end
if isfield(L,'AclassinfoMap2LC')
    out.AclassinfoP=AclassinfoP_LC;
    out.AclassinfoMap2LC=L.AclassinfoMap2LC;
    out.clistclslabel_LC=L.clistclslabel_LC;
else
    out.AclassinfoP= L.AclassinfoP;
    out.AclassinfoMap2LC=[];
    out.clistclslabel_LC='';
end
%-------------------------------------------------------------
out.NmisP=length(loc_misP);
out.loc_misP=loc_misP;
%--------------------------------------------------------
if all(isnan(L.AclassinfoP))
    out.extr_Predict_Accuracy=NaN;
else
    if isfield(L,'AclassinfoMap2LC')
        out.extr_Predict_Accuracy=(length(predcls_LC)-out.NmisP)/length(predcls_LC)*100;
    else
        out.extr_Predict_Accuracy=PAS_libsvm_wDecVal_APs_LinearKernel;
    end
end
end
%================================================================================
%================================================================================


%% ----- from RUN_LIBSVM_ova_rbf_wDecVal_CmpClsfr.m -------------------------

function [handles out]=RUN_LIBSVM_ova_rbf_wDecVal_CmpClsfr(handles)
%
% function [handles out]=RUN_SVM_rbf_CmpClsfr_wDecVal(handles)
% see also RUN_SVM_rbf_CmpClsfr_wDecVal   libsvm_DecVal   and LIBSVM_ova
waitbar_yes=0;

L=handles.L;
%%%%%%%%%%%%%%%%%%
L.Atrainpk=double(L.Atrainpk);
L.Apred=double(L.Apred);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainpk_sparse=sparse(L.Atrainpk);
pred_sparse=sparse(L.Apred);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    kw4ASSVM= handles.kw4ASSVM;
    gamma=kw4ASSVM/length(L.Atrainpk(1,:));
    
catch
    gamma=1/length(L.Atrainpk(1,:));
end
try
    C4ASSVM= handles.C4ASSVM;
    
catch
    C4ASSVM=1;
end



t0_rbfSVM=cputime;

%   model_wProb = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-b 1 -g',num2str(gamma),' -q']);  % with Prob output
%   

  % model_wDecVal = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-g ',num2str(gamma),' -q']);        % with Dec_Val output
    model_wDecVal = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-g ',num2str(gamma),' -c ',num2str(C4ASSVM),' -q']);        % with Dec_Val output

  
ET_model_build_rbfSVM=cputime-t0_rbfSVM;
disp([' model building time for rbfSVM --> ',num2str(ET_model_build_rbfSVM),' sec']);
%%%%%%%%%%%%%  
%  [predicted_label_wProb_self, accuracy_wProb_self, decision_values_prob_estimates_wProb_self]...
%     = svmpredict_MEX(L.AclassinfoT, trainpk_sparse, model_wProb,'-b 1' );                         % with Prob output

 [predicted_label_wDecVal_self, accuracy_wDecVal_self, decision_values_prob_estimates_wDecVal_self]...
    = svmpredict_MEX(L.AclassinfoT, trainpk_sparse, model_wDecVal ); % self_predict with Dec_Val output 

% [saDecVal_self]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal_self,model_wDecVal.nr_class);
% checking
% if ~isSAME_2Matrix( arrayfun(@(x) x.winner_cls,saDecVal_self),predicted_label_wDecVal_self)
% error('mismatch between saDecVal_self vs predicted_label_wDecVal_self')
% end

% [dummy_sort ind_sort_model_Label]=sort(model_wProb.Label)   ;
%             decision_values_prob_estimates_wProb_self_SORT=decision_values_prob_estimates_wProb_self(:,ind_sort_model_Label);
            

PAS_libsvm_wDecVal_default_C_gamma_self=accuracy_wDecVal_self(1);
disp_with_border(['SELF-PAS based on libsvm with Dec_Val and default C and gamma=1/nFeat --> ',roundns(PAS_libsvm_wDecVal_default_C_gamma_self,2),'%']);
disp('**********************************************************')
%  [predicted_label_wProb, accuracy_wProb, decision_values_prob_estimates_wProb]...
%     = svmpredict_MEX(L.AclassinfoP, pred_sparse, model_wProb,'-b 1' );                               % with Prob output
%             

 [predicted_label_wDecVal, accuracy_wDecVal, decision_values_prob_estimates_wDecVal]...
    = svmpredict_MEX(L.AclassinfoP, pred_sparse, model_wDecVal);                                        % extr_predict with Dec_Val output



PAS_libsvm_wDecVal_default_C_gamma=accuracy_wDecVal(1);
disp_with_border(['PAS based on libsvm with Dec_Val and default C and gamma=1/nFeat --> ',roundns(PAS_libsvm_wDecVal_default_C_gamma,2),'%']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    if length(L.clistclslabel)<=100
        
        % warning('number of class too large to be handled by current codes in libsvm_DecVal(), since it will generate huge structure and structure array')
        warning('if this take too long to run, you can try skip this section ? however, this suggestion has not been fully test ...')
        
        % end
        [saDecVal_extr]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal,model_wDecVal.nr_class);
        %
        winner_cls_allpairs=cat(1,saDecVal_extr.winner_cls);
        
        %checking
        if ~isSAME_2Matrix(winner_cls_allpairs,predicted_label_wDecVal)
            warning('mismatch between results from saDecVal_extr vs decision_values_prob_estimates_wDecVal');
            num_diff_pred=length(find(winner_cls_allpairs~=predicted_label_wDecVal));
            disp_with_border([num2str(num_diff_pred),'-->number of mismatch in pred labels based on all-pairs dec_val between direct output of svmpredict_MEX vs based on saDecVal_extr'])
            speak(['number mismatch equal ',num2str(num_diff_pred)])
        end
    end
end
% LIBSVM_ova(handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parsing TP for ova approach
if waitbar_yes
 hwb = waitbar(0,'running OVA operations...');  %  waitbar
end
all_DecVal=[];
for icls=1:length(handles.L.clistclslabel)
disp(['parse TP for icls=',num2str(icls),' in an one-vs-allothers approach'])
locOneCls_T=find(handles.L.AclassinfoT==icls);
locAllCls_T=find(handles.L.AclassinfoT~=icls);

handles_icls=handles;
handles_icls.L.AclassinfoT=repmat(NaN,size(handles_icls.L.AclassinfoT));
handles_icls.L.AclassinfoT(locOneCls_T)=1;  % cls1 is always the focus cls
handles_icls.L.AclassinfoT(locAllCls_T)=2;   % !!! do NOT use "-1" for other classes !!!
handles_icls.L.clistclslabel={'focus_cls','other_cls'};
[handles_LIB_icls out_LIB_icls]=RUN_SVM_rbf_CmpClsfr_wDecVal(handles_icls);



% all_DecVal=[all_DecVal,out_LIB_icls.pred_prob];  % this is still based on libsvm's format cls appear seq in Tset
% 

DecVal_focus_cls=cat(1,out_LIB_icls.saDecVal_extr.DecVal_Cls1);% based on cls seq number themselves and cls1 is always the focus cls

all_DecVal=[all_DecVal,DecVal_focus_cls]; % based on cls seq number themselves
if waitbar_yes
waitbar(icls/length(handles.L.clistclslabel),hwb);   %  waitbar
end
end
if waitbar_yes
 close(hwb);% waitbar
end
[max_dec_val_ova winner_cls_ova]=max(all_DecVal');
winner_cls_ova=col_always(winner_cls_ova);
PAS_libsvm_wDecVal_default_C_gamma_OVA=length(find(winner_cls_ova==handles.L.AclassinfoP))/length(handles.L.AclassinfoP)*100;
% calculate PAS considering only max_dec_val_ova > 0
loc_match=find(winner_cls_ova==handles.L.AclassinfoP);
loc_NotMatch=find(winner_cls_ova~=handles.L.AclassinfoP);

loc_MaxDecVal_positive=find(max_dec_val_ova>0);
loc_MaxDecVal_negative=find(max_dec_val_ova<=0);

loc_match_AND_positive=intersect(loc_match,loc_MaxDecVal_positive);

loc_match_AND_negative=intersect(loc_match,loc_MaxDecVal_negative);

loc_NotMatch_AND_positive=intersect(loc_NotMatch,loc_MaxDecVal_positive);

PAS_libsvm_wDecVal_OVA_thres0=length(loc_match_AND_positive)/length(handles.L.AclassinfoP)*100;

if false
    
    figure;hold on;plot(max_dec_val_ova,'b-*')
plot(loc_match_AND_negative,max_dec_val_ova(loc_match_AND_negative),'c>');
plot(loc_match_AND_positive,max_dec_val_ova(loc_match_AND_positive),'gO','markersize',10);
plot(loc_NotMatch_AND_positive,max_dec_val_ova(loc_NotMatch_AND_positive),'rdiamond');
legend({'Max DecVal','Match & Negative MaxDecVal','Match & Positive MaxDecVal','NotMatch & Positive MaxDecVal'});
title(['PAS=',roundns(PAS_libsvm_wDecVal_OVA_thres0,2),'%']);
ylabel('Max DecVal');xlabel('sample seq')

end
%%%%%%%%%%%%%%%%%%%%%%%%
% out.self_Predict_Accuracy=PAS_libsvm_wDecVal_default_C_gamma_self;
% out.extr_Predict_Accuracy=PAS_libsvm_wDecVal_default_C_gamma;
out.self_Predict_Accuracy=NaN;
out.extr_Predict_Accuracy=PAS_libsvm_wDecVal_default_C_gamma_OVA;


out.ET_model_build=ET_model_build_rbfSVM;
% out.predicted_label_wProb=predicted_label_wDecVal;
out.predicted_label_wProb=winner_cls_ova;

try 
%    out.predcls= predicted_label_wDecVal;
     out.predcls= winner_cls_ova;
 
end
try 
    % this is still based on libsvm's format of cls appear seq in Tset
%    out.pred_prob= decision_values_prob_estimates_wDecVal; % based on Tset's sample seq of their class ID and  based on libsvm's output format of half of all dec_val

out.pred_prob=all_DecVal; % based on cls seq num (first col --> cls1, 2nd col --> cls2 ...)

end

try
    out.saDecVal_extr=saDecVal_extr;  % based on Chang's format of cls seq number themselves
end
%-----------------------------------------------------
% 

done_with_this_function;
end


%% ----- from RUN_SVM_linear_CmpClsfr_wDecVal.m -----------------------------

function [handles out]=RUN_SVM_linear_CmpClsfr_wDecVal(handles,varargin)
% see also libsvm_DecVal   and LIBSVM_ova
% % add this June 29, 2022
%======================================================
if nargin>1
    inp=varargin{1};
%     inp.saDecVal_yes=0;
else
    inp.saDecVal_yes=1;
end
L=handles.L;
%%%%%%%%%%%%%%%%%%
L.Atrainpk=double(L.Atrainpk);
L.Apred=double(L.Apred);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainpk_sparse=sparse(L.Atrainpk);
pred_sparse=sparse(L.Apred);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gamma=1/length(L.Atrainpk(1,:));

t0_rbfSVM=cputime;

%   model_wProb = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-b 1 -g',num2str(gamma),' -q']);  % with Prob output
%   

%    model_wDecVal = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-g ',num2str(gamma),' -q']);        % with Dec_Val output
try
    if handles.load_exist_SVMmodel_yes && ~isempty(handles.SVMmodel_icls)
        model_wDecVal = handles.SVMmodel_icls;
    elseif ~handles.load_exist_SVMmodel_yes
        model_wDecVal = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,[' -t 0  ',' -q']);        % with Dec_Val output
    else
        error('can not handle this case');
    end
catch
 model_wDecVal = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,[' -t 0  ',' -q']);        % with Dec_Val output
end


 out.SVMmodel= model_wDecVal  ;                                                                               % add this June 29, 2022
 
ET_model_build_rbfSVM=cputime-t0_rbfSVM;
disp([' model building time for rbfSVM --> ',num2str(ET_model_build_rbfSVM),' sec']);
%%%%%%%%%%%%%  
%  [predicted_label_wProb_self, accuracy_wProb_self, decision_values_prob_estimates_wProb_self]...
%     = svmpredict_MEX(L.AclassinfoT, trainpk_sparse, model_wProb,'-b 1' );                         % with Prob output
if   ~isfield(handles,'load_exist_SVMmodel_yes')  || ~handles.load_exist_SVMmodel_yes
    [predicted_label_wDecVal_self, accuracy_wDecVal_self, decision_values_prob_estimates_wDecVal_self]...
        = svmpredict_MEX(L.AclassinfoT, trainpk_sparse, model_wDecVal ); % self_predict with Dec_Val output
    
    % [saDecVal_self]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal_self,model_wDecVal.nr_class);
    % % checking
    % if ~isSAME_2Matrix( arrayfun(@(x) x.winner_cls,saDecVal_self),predicted_label_wDecVal_self)
    % error('mismatch between saDecVal_self vs predicted_label_wDecVal_self')
    % end
    
    % [dummy_sort ind_sort_model_Label]=sort(model_wProb.Label)   ;
    %             decision_values_prob_estimates_wProb_self_SORT=decision_values_prob_estimates_wProb_self(:,ind_sort_model_Label);
    
    
    PAS_libsvm_wDecVal_default_C_gamma_self=accuracy_wDecVal_self(1);
    disp_with_border(['SELF-PAS based on libsvm with Dec_Val and default C and gamma=1/nFeat --> ',roundns(PAS_libsvm_wDecVal_default_C_gamma_self,2),'%']);
    disp('**********************************************************')
end
%  [predicted_label_wProb, accuracy_wProb, decision_values_prob_estimates_wProb]...
%     = svmpredict_MEX(L.AclassinfoP, pred_sparse, model_wProb,'-b 1' );                               % with Prob output
%             

 [predicted_label_wDecVal, accuracy_wDecVal, decision_values_prob_estimates_wDecVal]...
    = svmpredict_MEX(L.AclassinfoP, pred_sparse, model_wDecVal);                                        % extr_predict with Dec_Val output
if  inp.saDecVal_yes==1
[saDecVal_extr]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal,model_wDecVal.nr_class);
end
% [saDecVal_self]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal_self,model_wDecVal.nr_class);
% % checking
% if ~isSAME_2Matrix( arrayfun(@(x) x.winner_cls,saDecVal_self),predicted_label_wDecVal_self)
% error('mismatch between saDecVal_self vs predicted_label_wDecVal_self')
% end


if      ~isfield(handles,'load_exist_SVMmodel_yes')  ||   ~handles.load_exist_SVMmodel_yes
PAS_libsvm_wDecVal_default_C_gamma=accuracy_wDecVal(1);
disp_with_border(['PAS based on libsvm with Dec_Val and default C and gamma=1/nFeat --> ',roundns(PAS_libsvm_wDecVal_default_C_gamma,2),'%']);
end
%%%%%%%%%%%%%%%%%%%%%%%%
try
out.self_Predict_Accuracy=PAS_libsvm_wDecVal_default_C_gamma_self;
end
try
out.extr_Predict_Accuracy=PAS_libsvm_wDecVal_default_C_gamma;
end
try
out.ET_model_build=ET_model_build_rbfSVM;
end
out.predicted_label_wProb=predicted_label_wDecVal;
try 
   out.predcls= predicted_label_wDecVal;
end
try 
    % this is still based on libsvm's format of cls appear seq in Tset
   out.pred_prob= decision_values_prob_estimates_wDecVal; % based on Tset's sample seq of their class ID and  based on libsvm's output format of half of all dec_val
end

try
    out.saDecVal_extr=saDecVal_extr;  % based on Chang's format of cls seq number themselves
end

try 
    out.model_wDecVal=model_wDecVal;
end
end


%% ----- from RUN_SVM_linear_wDecVal_CmpClsfr.m -----------------------------
function [handles out]=RUN_SVM_linear_wDecVal_CmpClsfr(handles)
% typically called by iACP_switch_Clsfr_ACP or switch_Clsfr_ACP
% modified from RUN_SVM_linear_CmpClsfr but put "-b 1" off
% important locations:
% % use above to generate sv in sPCA_gui --> see  --> SVM_Anton_wP_samecolorFD_DPR_ACP
%---------------------------------------------------------------------------------------------------------
% insert PP_methods into SVMmodel, revisit Dec 20, 2022
% save SVMmodel with inserted PP_methods, revisit Dec 20, 2022
%---------------------------------------------------------------------------------------------
% test iACPmp_gui with SVMmodel as input, Dec 20, 2022
% see --> iACP_switch_Clsfr_ACP
%-----------------------------------------------------------------------------------
% update following to handle SVMmodel creation, Dec 21, 2022
%-------------------------------------------------------------------------------
 % capture mT and stdT and RawSpectra_Tset for iACP load model directly usage case, Jan 9, 2023
 %----------------------------------------------------------------------------------------
 % add following to deal with MLbClsfr case (and without MLbClsfr), Apr 11, 2023
%================================================================
%==========================================================
L=handles.L;  % Note that handles.L was created in  RefreshCmpClsfrGUI.m (subfun inside CmpClsfr.m)
%----------------------------------------------
try
    Lorig=handles.Lorig; % after PPd but before asmc, Dec 22, 2022
    if false
        figure;hold on;plot(Lorig.Atrainpk','b-o');
        figure;hold on;plot(L.Atrainpk','c-o');
        std(L.Atrainpk)
    end
end

%------------------------------------------------------------------------
% %----------------------------------------------------------------------------
% this is already autoscaled Atrainpk etc , should apply_PP before this
% %  apply PP_methods if they exist inside "handles", Dec 20-, 2022
% if isfield(handles,'PP_methods')
% inp4PP.PP_methods=handles.PP_methods;
% sd0=ssds(L);
% sd1=sd0.apply_PP(inp4PP);
% L=sd1.LAT;                         % replace "L" by "PPd L"
% end
% %------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%
try
L.Atrainpk=double(L.Atrainpk);
trainpk_sparse=sparse(L.Atrainpk);
catch
trainpk_sparse='';
end
%=======================-=
L.Apred=double(L.Apred);
pred_sparse=sparse(L.Apred);
%===========================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0_linearSVM=cputime;

try
    C=handles.SVMpara.C;
    para_C=C;str_SVM_parameters=[' -t 0  -c ',num2str(para_C),' -q'];  % Not using default C, instead use "para_C" 

catch
str_SVM_parameters=[' -t 0  ',' -q']; % default C = 1
end

%    model_wProb_LinearKernel = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-b 1 -t 0  ',' -q']);
%       model_wProb_LinearKernel = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,[' -t 0  ',' -q']);


% trainpk_sparse=[trainpk_sparse,zeros(size(L.AclassinfoT))];
% trainpk_sparse=[trainpk_sparse,ones(size(L.AclassinfoT))];
%  trainpk_sparse=[2*ones(size(L.AclassinfoT)),trainpk_sparse,ones(size(L.AclassinfoT))];

% the following is too big
%  trainpk_sparse=[10000*rand(size(L.AclassinfoT)),trainpk_sparse,100*rand(size(L.AclassinfoT))];
 
%  trainpk_sparse=[rand(size(L.AclassinfoT)),trainpk_sparse,rand(size(L.AclassinfoT))];
%       model_wProb_LinearKernel = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,str_SVM_parameters);
% use above to generate sv in sPCA_gui --> see  --> SVM_Anton_wP_samecolorFD_DPR_ACP
%====================================================================================
try
    L_Clsfr_Model =  load( handles.inp.Clsfr_Model );  % see --> iACP_switch_Clsfr_ACP
    model_wDecVal_APs_LinearKernel =L_Clsfr_Model.model_wDecVal_APs_LinearKernel;
    %     model_wProb_LinearKernel.PP_methods  = handles.inp.PP_methods;
catch
    %     model_wProb_LinearKernel = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,str_SVM_parameters);
    model_wDecVal_APs_LinearKernel = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,str_SVM_parameters);
    %      model_wProb_LinearKernel.PP_methods  = handles.inp.PP_methods;
    %--------------------------------------------------------
    % updated June 27, 2022
    SM.model_wDecVal_APs_LinearKernel =model_wDecVal_APs_LinearKernel ;
    try
        SM.PP_methods  = handles.inp.PP_methods;                                                                          % insert PP_methods into SVMmodel, revisit Dec 20, 2022
    catch
        try
            SM.PP_methods  = handles.PP_methods;                                                                            % insert PP_methods into SVMmodel, revisit Dec 20, 2022
        catch
            SM.PP_methods ='';
        end
    end
    %-------------------------------------------------------------
    try
    SM.Lorig=Lorig;% after PPd but before asmc, Dec 22, 2022
    end
    %------------------------------------------------------------
    % capture mT and stdT and RawSpectra_Tset for iACP load model directly usage case, Jan 9, 2023
    %
    try
    SM.mT=mean(Lorig.Atrainpk);  % after PPd but before asmc
    SM.stdT=std(Lorig.Atrainpk);    % after PPd but before asmc
    SM.RawSpectra_Tset=Lorig.RawSpectra.Tset; % RawSpectra collected for diagnosis purpose
    SM.AclassinfoT=Lorig.AclassinfoT ;
    SM.Atrainpk=Lorig.Atrainpk;
    catch
    SM.mT='';SM.stdT=[];SM.RawSpectra_Tset=[];  % when running AACP or BatchRun_AutoClsfr_DA_pipeline_ACP ( Jan 18, 2023)
    end
    try
        SM.AclabelT=Lorig.AclabelT;
    end
    %=============================================================================================================================================
    SVMmodelType=  'SVMmodel_Linear_wDecVal_APs_'   ;
    try
    ModelName=consolidate_PPs_in_ModelName_vs_Atrainpk(SVMmodelType,handles,SM);
    catch
   ModelName=[];                                                 % when running AACP or BatchRun_AutoClsfr_DA_pipeline_ACP ( Jan 18, 2023)
    end
    %=============================================================================================================================================
    if ~isempty(ModelName)
        save(ModelName,'-struct','SM');    % save SVMmodel with inserted PP_methods, revisit Dec 20, 2022
        disp_with_border([ModelName,' has been saved !']);
    end
    %--------------------------------------------------------
end      % end of try -->   L_Clsfr_Model =  load( handles.inp.Clsfr_Model );
%=================================================================================================================================================
%=================================================================================================================================================
%=================================================================================================================================================

 ET_model_build_linearSVM=cputime-t0_linearSVM;
 disp([' model building time for linearSVM --> ',num2str(ET_model_build_linearSVM),' sec']);
 
%       [SELF_predicted_label_wProb_LinearKernel, SELF_accuracy_wProb_LinearKernel, SELF_decision_values_prob_estimates_wProb_LinearKernel]...
%     = svmpredict_MEX(L.AclassinfoT, trainpk_sparse,  model_wProb_LinearKernel,'-b 1' );
if ~isempty(trainpk_sparse)
      [SELF_predicted_label_wProb_LinearKernel, SELF_accuracy_wProb_LinearKernel, SELF_decision_values_prob_estimates_wProb_LinearKernel]...
    = svmpredict_MEX(L.AclassinfoT, trainpk_sparse,  model_wDecVal_APs_LinearKernel );
else
SELF_accuracy_wProb_LinearKernel=NaN;
end

 SELF_PAS_libsvm_wProb_LinearKernel=SELF_accuracy_wProb_LinearKernel(1);
% disp_with_border(['SELF_LinearKernel-PAS based on libsvm with Prob --> ',roundns(SELF_PAS_libsvm_wProb_LinearKernel,2),'%']);
disp_with_border(['SELF_LinearKernel-PAS based on libsvm with DecVal --> ',roundns(SELF_PAS_libsvm_wProb_LinearKernel,2),'%']);
%-----------------------------------------------------------------------
loc_misP_SELF_predicted=find(SELF_predicted_label_wProb_LinearKernel~=L.AclassinfoT);  % updated Apr 19, 2024
NmisP_SELF_predicted=length(loc_misP_SELF_predicted );                                 % updated Apr 19, 2024
%-------------------------------------------------------------------------   
   
%    [predicted_label_wProb_LinearKernel, accuracy_wProb_LinearKernel, decision_values_prob_estimates_wProb_LinearKernel]...
%     = svmpredict_MEX(L.AclassinfoP, pred_sparse,  model_wProb_LinearKernel,'-b 1' );

% testing for insert NaN into sparse_Pset
% pred_sparse(10,1)=NaN;% use "zero" to remove entry in sparse matrix, see below
% pred_sparse(10,1)=0; % use "zero" to remove entry in sparse matrix 

% pred_sparse=[pred_sparse,zeros(size(L.AclassinfoP))];
%   pred_sparse=[zeros(size(L.AclassinfoP)),pred_sparse,zeros(size(L.AclassinfoP))];
%  pred_sparse=[10*rand(size(L.AclassinfoP)),pred_sparse,100*rand(size(L.AclassinfoP))];
 [nsp narp]=size(pred_sparse);
%  locOdd=[1:45:narp];
% locOdd=[];
% locEven=[2:2:narp];

%    locOdd=[1:4 narp-3:narp];
% 
% IZP=zeros(nsp,length(locOdd));
% pred_sparse(:,locOdd)=IZP;
%=======================================================================================================
% External Prediction !!!
   [predicted_label_wDecVal_APs_LinearKernel, accuracy_wDecVal_APs_LinearKernel, decision_values_prob_estimates_wProb_LinearKernel]...
    = svmpredict_MEX(L.AclassinfoP, pred_sparse,  model_wDecVal_APs_LinearKernel);
%=======================================================================================================
try
PAS_libsvm_wDecVal_APs_LinearKernel=accuracy_wDecVal_APs_LinearKernel(1);
catch
PAS_libsvm_wDecVal_APs_LinearKernel=NaN;    
end
% disp_with_border(['LinearKernel-PAS based on libsvm with Prob --> ',roundns(PAS_libsvm_wDecVal_APs_LinearKernel,2),'%']);
disp_with_border(['LinearKernel-PAS based on libsvm with DecVal --> ',roundns(PAS_libsvm_wDecVal_APs_LinearKernel,2),'%']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%================================================================================
%================================================================================
% add following to deal with MLbClsfr case (and without MLbClsfr), Apr 11, 2023
%
PAS_GM = PAS_libsvm_wDecVal_APs_LinearKernel;
predcls_GM=predicted_label_wDecVal_APs_LinearKernel;
[loc_misP predcls_LC  out]=MLbClsfr_AclassinfoMap2LC_loc_misP(L,predcls_GM , PAS_GM);
%================================================================================
%================================================================================

S_SVMlinear_misP.SampleSeq=loc_misP;
try
S_SVMlinear_misP.PredasLabel=arrayfun(@(x) L.clistclslabel{x},predicted_label_wDecVal_APs_LinearKernel(loc_misP),'un',0);
end
try
    S_SVMlinear_misP.TrueLabel=L.AclabelP(loc_misP);
catch
    try
        L.AclabelP=arrayfun(@(x) L.clistclslabel{x},L.AclassinfoP,'un',0);
    catch
        
        % deal with samples from non-merged classes predas merged cls
        L.AclabelP=repmat({NaN},size(L.AclassinfoP));
        try
        loc_from_NonMerged=find_belong2subgrp( L.AclassinfoP,setdiff(unique(L.AclassinfoP),[1:length(L.clistclslabel)]));
        L.AclabelP(loc_from_NonMerged)=arrayfun(@(x) handles.Lorig.clistclslabel{x},L.AclassinfoP(loc_from_NonMerged),'un',0);
         loc_from_Merged=find_belong2subgrp( L.AclassinfoP,[1:length(L.clistclslabel)]);
         L.AclabelP(loc_from_Merged)=arrayfun(@(x) L.clistclslabel{x},L.AclassinfoP(loc_from_Merged),'un',0);
        end
    end
    S_SVMlinear_misP.TrueLabel=L.AclabelP(loc_misP);
end
try
    corename=find_keyword_between_markers( handles.INPfilename,'Atrainpketc_','.mat');
catch
    try
        corename=find_keyword_between_markers( handles.pathfname_AT,'Atrainpketc_','.mat');
    catch
        corename='--';
    end
end

try
    addinfo_Hier=[handles.addinfo_Hier,'_'];;
corename=[addinfo_Hier,corename];
end
try
    if handles.xlswrite==1
        fname_misP=['MisPredicted_by_SVM-linear(',num2str(length(loc_misP)),')_',corename,'.xlsx'];
        try
            struct2xls(fname_misP,S_SVMlinear_misP);
        catch
            if isempty(loc_misP)
                %  very important to add : " 'un',false " to output to a structure
                S_SVMlinear_misP=structfun(@(x) NaN,S_SVMlinear_misP,'un',0);%  very important to add : " 'un',false " to output to a structure
                try      struct2xls(fname_misP,S_SVMlinear_misP);end
            else
                try
                    disp(['can not write to xls for ',fname_misP]) ;
                end
            end
        end
        disp([fname_misP,' has been saved ']);
    end
end
disp(['number of Mis-Predicted  = ',num2str(length(loc_misP)),'/',num2str(length(L.AclassinfoP))]);
disp('**********************************************************')
disp('**********************************************************')
%======================================================================================

out.ET_model_build=ET_model_build_linearSVM;

%%%%%%%%%%%%%%%%%%%%%%%%
out.self_Predict_Accuracy=SELF_PAS_libsvm_wProb_LinearKernel;
out.NmisP_self_Predict=NmisP_SELF_predicted;
%=========================================================================
try 
   out.pred_prob= decision_values_prob_estimates_wProb_LinearKernel;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
out.sv_indices=model_wDecVal_APs_LinearKernel.sv_indices;
catch
 out.sv_indices=[];   
end
%--------------------------------------------------------------------------------------------
try
    out.ModelName=ModelName;
catch
    out.ModelName=[];
end
%--------------------------------------------------------------------------------------------

try
   out.para_C=para_C;
end

%--------------------------------------------------------
try
    out.model_Label=model_wDecVal_APs_LinearKernel.Label;
end
end
%----------------------------------------------------------


%% ----- from RUN_SVM_rbf_CmpClsfr_wDecVal.m --------------------------------

function [handles out]=RUN_SVM_rbf_CmpClsfr_wDecVal(handles,varargin)
% see also libsvm_DecVal   and LIBSVM_ova

if nargin>1
    inp=varargin{1};
else
    inp.saDecVal_yes=1;
end

L=handles.L;
%%%%%%%%%%%%%%%%%%
L.Atrainpk=double(L.Atrainpk);
L.Apred=double(L.Apred);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainpk_sparse=sparse(L.Atrainpk);
pred_sparse=sparse(L.Apred);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gamma=1/length(L.Atrainpk(1,:));

try
    kw4ASSVM= handles.kw4ASSVM;
    gamma=kw4ASSVM/length(L.Atrainpk(1,:));
    
catch
    gamma=1/length(L.Atrainpk(1,:));
end
try
    C4ASSVM= handles.C4ASSVM;
    
catch
    C4ASSVM=1;
end




t0_rbfSVM=cputime;

%   model_wProb = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-b 1 -g',num2str(gamma),' -q']);  % with Prob output
%   

%    model_wDecVal = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-g ',num2str(gamma),' -q']);        % with Dec_Val output
     model_wDecVal = svmtrain_MEX(L.AclassinfoT, trainpk_sparse,['-g ',num2str(gamma),' -c ',num2str(C4ASSVM),' -q']);        % with Dec_Val output

  
ET_model_build_rbfSVM=cputime-t0_rbfSVM;
disp([' model building time for rbfSVM --> ',num2str(ET_model_build_rbfSVM),' sec']);
%%%%%%%%%%%%%  
%  [predicted_label_wProb_self, accuracy_wProb_self, decision_values_prob_estimates_wProb_self]...
%     = svmpredict_MEX(L.AclassinfoT, trainpk_sparse, model_wProb,'-b 1' );                         % with Prob output

 [predicted_label_wDecVal_self, accuracy_wDecVal_self, decision_values_prob_estimates_wDecVal_self]...
    = svmpredict_MEX(L.AclassinfoT, trainpk_sparse, model_wDecVal ); % self_predict with Dec_Val output 

% [saDecVal_self]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal_self,model_wDecVal.nr_class);
% % checking
% if ~isSAME_2Matrix( arrayfun(@(x) x.winner_cls,saDecVal_self),predicted_label_wDecVal_self)
% error('mismatch between saDecVal_self vs predicted_label_wDecVal_self')
% end

% [dummy_sort ind_sort_model_Label]=sort(model_wProb.Label)   ;
%             decision_values_prob_estimates_wProb_self_SORT=decision_values_prob_estimates_wProb_self(:,ind_sort_model_Label);
            

PAS_libsvm_wDecVal_default_C_gamma_self=accuracy_wDecVal_self(1);
disp_with_border(['SELF-PAS based on libsvm with Dec_Val and default C and gamma=1/nFeat --> ',roundns(PAS_libsvm_wDecVal_default_C_gamma_self,2),'%']);
disp('**********************************************************')
%  [predicted_label_wProb, accuracy_wProb, decision_values_prob_estimates_wProb]...
%     = svmpredict_MEX(L.AclassinfoP, pred_sparse, model_wProb,'-b 1' );                               % with Prob output
%             

 [predicted_label_wDecVal, accuracy_wDecVal, decision_values_prob_estimates_wDecVal]...
    = svmpredict_MEX(L.AclassinfoP, pred_sparse, model_wDecVal);  % extr_predict with Dec_Val output

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if  inp.saDecVal_yes==1

[saDecVal_extr]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal,model_wDecVal.nr_class);
end
% [saDecVal_self]=libsvm_DecVal(model_wDecVal,decision_values_prob_estimates_wDecVal_self,model_wDecVal.nr_class);
% % checking
% if ~isSAME_2Matrix( arrayfun(@(x) x.winner_cls,saDecVal_self),predicted_label_wDecVal_self)
% error('mismatch between saDecVal_self vs predicted_label_wDecVal_self')
% end



PAS_libsvm_wDecVal_default_C_gamma=accuracy_wDecVal(1);
disp_with_border(['PAS based on libsvm with Dec_Val and default C and gamma=1/nFeat --> ',roundns(PAS_libsvm_wDecVal_default_C_gamma,2),'%']);

%%%%%%%%%%%%%%%%%%%%%%%%
out.self_Predict_Accuracy=PAS_libsvm_wDecVal_default_C_gamma_self;
out.extr_Predict_Accuracy=PAS_libsvm_wDecVal_default_C_gamma;
out.ET_model_build=ET_model_build_rbfSVM;
out.predicted_label_wProb=predicted_label_wDecVal;
try 
   out.predcls= predicted_label_wDecVal;
end
try 
    % this is still based on libsvm's format of cls appear seq in Tset
   out.pred_prob= decision_values_prob_estimates_wDecVal; % based on Tset's sample seq of their class ID and  based on libsvm's output format of half of all dec_val
end

try
    out.saDecVal_extr=saDecVal_extr;  % based on Chang's format of cls seq number themselves
end
try 
    out.model_wDecVal=model_wDecVal;
end
end


%% ----- from RUN_SVM_rbf_wDecVal_CmpClsfr.m --------------------------------
function [handles out]=RUN_SVM_rbf_wDecVal_CmpClsfr(handles,inp)
% revisit this July 17, 2026 to include this into CMS_Clsfrs_Predict_Alt
% ILM+CFP's local models are based on this function
% see --> RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr.m
%
% modified from RUN_SVM_linear_CmpClsfr but put "-b 1" off
% see also: RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
%           RUN_SVM_wRBF_OpmHyParam_CmpClsfr  (source of the uigetfile /
%                                              inp.asmc_num driver pattern
%                                              used in the block below)
%----------------------------------------------------------------------------
%
% [handles,out] = RUN_SVM_rbf_wDecVal_CmpClsfr(handles,inp)
%
%   inp.sigma    : RBF kernel width MULTIPLIER        (default 1)
%   inp.C        : soft-margin cost -> libsvm  -c     (default 1)
%   inp.asmc_num : 0 none / 1 autoscale / 2 mean-center  (RECORD ONLY, see below)
%
% *** IMPORTANT NOTE TO USER ******************************************
% *  inp.sigma is NOT passed to libsvm directly. It is DIVIDED BY nvar :
% *
% *          gamma = inp.sigma / nvar        ( nvar = size(Atrainpk,2) )
% *
% *  and that gamma is what goes into libsvm's  -g  option. This keeps
% *  the original convention of this function, where gamma was always
% *  hard-wired to 1/nvar.
% *
% *  ==> inp.sigma = 1  reproduces EXACTLY the original behaviour of
% *      this function (the version in which the user could NOT specify
% *      any setting). Same for inp.C = 1. So the defaults are
% *      backward-compatible: calling with no inp at all, or with
% *      sigma=1 / C=1, gives bit-identical results to the old code.
% *
% *  sigma > 1 -> narrower kernel / tighter fit
% *  sigma < 1 -> wider kernel / smoother fit
% *
% *  inp.sigma is the same quantity as the legacy handles.SVMpara.kw .
% *  Both names are accepted and both are echoed back in `out`.
% *********************************************************************
%
% *** NOTE ON inp.asmc_num ********************************************
% *  This function does NOT apply autoscaling / mean-centering itself.
% *  Preprocessing is done UPSTREAM by normasmc_trainpk_pred (see the
% *  driver block below), exactly as in RUN_SVM_wRBF_OpmHyParam_CmpClsfr.
% *  inp.asmc_num is therefore carried through for RECORD KEEPING ONLY --
% *  it is stored in `out` so that a result can always be traced back to
% *  the preprocessing that produced it. It is deliberately NOT used to
% *  transform the data a second time (that would double-scale).
% *********************************************************************
%
%   Resolution order (first non-empty wins):
%       sigma : inp.sigma -> inp.kw -> handles.inp.sigma -> handles.sigma ->
%               handles.SVMpara.kw (legacy, same meaning) -> 1
%       C     : inp.C     -> handles.inp.C -> handles.C ->
%               handles.SVMpara.C  (legacy)              -> 1
%
%   Escape hatch: inp.gamma , if supplied, overrides everything and is
%   passed to -g as-is WITHOUT the /nvar division. When BOTH inp.gamma and
%   inp.sigma are supplied, the two are cross-checked (see out.HyPara.check)
%   and a warning is issued if they disagree; inp.gamma wins.
%
%   HYPERPARAMETER RECORD returned in `out`:
%       out.asmc_num , out.sigma_used , out.kw_used , out.nvar ,
%       out.gamma_used , out.C_used
%       out.HyPara            -- struct holding all of the above together
%       out.HyPara.check      -- sigma <-> gamma consistency verdict
%
% ==========================================================================
% GLUCOSE CASE STUDY -- why asmc=0 gave 0% and how sigma fixes it
% ==========================================================================
% Atrainpketc_{Glucose}_ncls3_nsampT1401_nsampP356.mat , nvar = 25
%
% The RBF kernel exp(-gamma*||x-y||^2) is SCALE-DEPENDENT. Two opposite
% failure modes exist, and asmc=0 with the old default hits the first:
%
%   gamma*||x-y||^2 -> 0   ==> K = all-ones matrix, every sample looks
%                              identical, model collapses to ONE class
%   gamma*||x-y||^2 -> inf ==> K = identity matrix, perfect memorization
%                              but zero generalization
%
%   RAW spectra (asmc=0): median ||x-y||^2 = 0.00255 (values ~ +/-0.09)
%        sigma = 1 -> gamma = 0.04 -> gamma*d2 = 1.0e-4
%        -> kernel entries all ~0.9999 -> ALL-ONES -> 0% accuracy
%   AUTOSCALED (asmc=1) : median ||x-y||^2 = 21.1  (8500x larger)
%        sigma = 1 -> gamma = 0.04 -> gamma*d2 = 0.87
%        -> kernel spans 0.42 .. 2e-4 -> 92% accuracy
%
%   Median-heuristic sigma  =  nvar / median(||x-y||^2) :
%        RAW        -> sigma ~ 9800   (!!)
%        AUTOSCALED -> sigma ~ 1.19
%   That last number is why the original hard-wired code always looked
%   fine on autoscaled data: sigma=1 happens to sit right next to the
%   median heuristic once the data has unit variance.
%
%   MEASURED external accuracy % (NmisP/356) on this dataset:
%     asmc=0 : sigma=1     C=1     ->  0.00 % (356)   <-- original default
%              sigma=9750  C=1000  -> 96.63 % ( 12)
%     asmc=1 : sigma=1     C=1     -> 92.13 % ( 28)   <-- original default
%              sigma=125   C=10    -> 99.44 % (  2)   <-- best found
%              sigma=1250  C=10    ->  0.00 % (356)   <-- over-narrow kernel
% ==========================================================================

if false
    %====================================================================
    % Begin key example 
    cc
    [filename, pathname] = uigetfile('*.mat', 'Pick a Atrainpketc_~.mat file');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User pressed cancel');
    else
        disp(['User selected ', fullfile(pathname, filename) ]);
        pathfname_AT=fullfile(pathname, filename) ;
    end
    Lorig=load(pathfname_AT);   inp.pathfname_TP= pathfname_AT ;
    %++++++++++++++++
    allowedNumbers = [0, 1, 2];promptMessage = sprintf('Enter an asmc_num from [%s]: ', num2str(allowedNumbers(:)'));
    inp.asmc_num= str2double(input(promptMessage, 's'));
    %++++++++++++++++
    % ---- RBF hyperparameters : sigma (kernel width multiplier) and C ------
    % NOTE: gamma = sigma/nvar  is what libsvm actually receives.
    %       sigma = 1 and C = 1 reproduce the ORIGINAL hard-wired behaviour.
    nvar_pk = size(Lorig.Atrainpk,2);
    promptSigma = sprintf(['Enter sigma  (kernel width multiplier, gamma = sigma/nvar , nvar = %d)\n' ...
                           '   [ENTER for default 1 = original behaviour]: '], nvar_pk);
    s_str = input(promptSigma,'s');
    if isempty(s_str), inp.sigma = 1; else, inp.sigma = str2double(s_str); end
    if ~isfinite(inp.sigma) || inp.sigma<=0
        warning('bad sigma entered -> falling back to 1'); inp.sigma = 1;
    end

    promptC = sprintf(['Enter C  (soft-margin cost)\n' ...
                       '   [ENTER for default 1 = original behaviour]: ']);
    c_str = input(promptC,'s');
    if isempty(c_str), inp.C = 1; else, inp.C = str2double(c_str); end
    if ~isfinite(inp.C) || inp.C<=0
        warning('bad C entered -> falling back to 1'); inp.C = 1;
    end

    disp(['   --> sigma = ',num2str(inp.sigma), ...
          '   gamma = sigma/nvar = ',num2str(inp.sigma/nvar_pk), ...
          '   C = ',num2str(inp.C), ...
          '   asmc_num = ',num2str(inp.asmc_num)]);
    %++++++++++++++++
    [Atrainpk_asmc, Apred_asmc, asmc_mean_std ]=normasmc_trainpk_pred(Lorig.Atrainpk,Lorig.Apred, 0 , inp.asmc_num);
    L_PPd_asmc=Lorig;L_PPd_asmc.Atrainpk=Atrainpk_asmc ;L_PPd_asmc.Apred=Apred_asmc ;
    handles=L_PPd_asmc;  inp.INPfilename=filename;
    [handles out]=RUN_SVM_rbf_wDecVal_CmpClsfr(handles,inp);
    % End of key example
  %=====================================================================
    % ---- hyperparameter record echoed back by the function ---------------
    disp(out.HyPara)
    disp(out.HyPara.check)
    % out.asmc_num  out.sigma_used  out.kw_used  out.nvar
    % out.gamma_used  out.C_used
    % out.HyPara.check.isconsistent == true  when gamma == sigma/nvar

    %% ---------------------------------------------------------------
    %  VARIANT A : suggested settings for the Glucose dataset
    %  ---------------------------------------------------------------
    %  answer the prompts with --
    %     asmc_num = 0 , sigma = 1     , C = 1      ->  0.00 % , NmisP 356/356
    %     asmc_num = 0 , sigma = 9750  , C = 1000   -> 96.63 % , NmisP  12/356
    %     asmc_num = 1 , sigma = 1     , C = 1      -> 92.13 % , NmisP  28/356
    %     asmc_num = 1 , sigma = 125   , C = 10     -> 99.44 % , NmisP   2/356
    %     asmc_num = 1 , sigma = 1250  , C = 10     ->  0.00 % , NmisP 356/356
    %                                                  (SELF=100%, nSV=nsampT)

    %% ---------------------------------------------------------------
    %  VARIANT B : median-heuristic auto-sigma (no prompt needed)
    %              scale-independent, works for any asmc_num
    %  ---------------------------------------------------------------
    A  = handles.Atrainpk;
    ns = min(2000,size(A,1));
    ii = randi(size(A,1),ns,1);  jj = randi(size(A,1),ns,1);
    d2 = sum((A(ii,:)-A(jj,:)).^2,2);   d2 = d2(d2>0);
    inp.sigma = size(A,2)/median(d2);      % = nvar/median(d2) -> gamma=1/median
    inp.C     = 10;
    [handles out]=RUN_SVM_rbf_wDecVal_CmpClsfr(handles,inp);

    %% ---------------------------------------------------------------
    %  VARIANT C : sigma x C sweep, NmisP tabulated alongside accuracy
    %  ---------------------------------------------------------------
    sList = [1 2.5 12.5 25 50 125 250 500];
    cList = [1 10 100 1000];
    ACC = nan(numel(sList),numel(cList));
    SELF= nan(numel(sList),numel(cList));
    NMIS= nan(numel(sList),numel(cList));
    for is = 1:numel(sList)
        for ic = 1:numel(cList)
            inp.sigma = sList(is);  inp.C = cList(ic);
            [~,o] = RUN_SVM_rbf_wDecVal_CmpClsfr(handles,inp);
            ACC(is,ic)  = o.extr_Predict_Accuracy;
            SELF(is,ic) = o.self_Predict_Accuracy;
            NMIS(is,ic) = o.NmisP;
        end
    end
    rn = compose('sigma_%g',sList);  vn = compose('C_%g',cList);
    disp('---- external accuracy % ----');
    disp(array2table(ACC ,'VariableNames',vn,'RowNames',rn));
    disp('---- NmisP ----');
    disp(array2table(NMIS,'VariableNames',vn,'RowNames',rn));
    disp('---- SELF accuracy % ----');
    disp(array2table(SELF,'VariableNames',vn,'RowNames',rn));
    [~,k] = min(NMIS(:));  [is,ic] = ind2sub(size(NMIS),k);
    disp(['best --> sigma = ',num2str(sList(is)), ...
          '  C = ',num2str(cList(ic)), ...
          '  NmisP = ',num2str(NMIS(k)), ...
          '  acc = ',num2str(ACC(k)),' %']);

    % CAVEAT for the Glucose set: all 356 prediction samples belong to
    % Subj-B, so "accuracy" here is really "fraction assigned to Subj-B".
    % Use a class-balanced prediction set before treating 99.44 % as a
    % general multiclass figure of merit.

end
%============================================================

% L=handles.L;  % Note that handles.L was created in  RefreshCmpClsfrGUI.m (subfun inside CmpClsfr.m)

try
L=handles.L;
catch
L=handles;      % revisit this July 17, 2026 to include this into CMS_Clsfrs_Predict_Alt
end

%%%%%%%%%%%%%%%%%%
L.Atrainpk=double(L.Atrainpk);
L.Apred=double(L.Apred);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trainpk_sparse=sparse(L.Atrainpk);
pred_sparse=sparse(L.Apred);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nvar = size(L.Atrainpk,2);

if nargin<2 || ~isstruct(inp),  inp = struct;  end

% ------------------- record asmc_num (RECORD ONLY) ---------------
% This function does NOT preprocess; normasmc_trainpk_pred does that
% upstream. asmc_num is carried so results stay traceable.
if isfield(inp,'asmc_num') && ~isempty(inp.asmc_num)
    asmc_num = inp.asmc_num;
elseif isstruct(handles) && isfield(handles,'asmc_num') && ~isempty(handles.asmc_num)
    asmc_num = handles.asmc_num;
elseif isstruct(handles) && isfield(handles,'asmc') && ~isempty(handles.asmc)
    asmc_num = handles.asmc;
else
    asmc_num = NaN;                      % not declared by the caller
end
if ~isnan(asmc_num) && ~ismember(asmc_num,[0 1 2])
    warning('inp.asmc_num = %g is outside [0 1 2]; recorded as-is',asmc_num);
end
switch asmc_num
    case 0,  asmc_scheme = 'none / raw';
    case 1,  asmc_scheme = 'autoscale';
    case 2,  asmc_scheme = 'mean-center';
    otherwise, asmc_scheme = 'undeclared';
end

% ------------------- resolve sigma (default 1) -------------------
% NOTE: gamma = sigma/nvar . sigma=1 reproduces the original hard-wired
%       gamma = 1/nvar behaviour.  sigma and the legacy kw are the SAME
%       quantity, so inp.kw is accepted as an alias.
sigma_src = 'default';
if isfield(inp,'sigma') && ~isempty(inp.sigma)
    sigma = inp.sigma;                    sigma_src = 'inp.sigma';
elseif isfield(inp,'kw') && ~isempty(inp.kw)
    sigma = inp.kw;                       sigma_src = 'inp.kw';
elseif isstruct(handles) && isfield(handles,'inp') && isstruct(handles.inp) ...
        && isfield(handles.inp,'sigma') && ~isempty(handles.inp.sigma)
    sigma = handles.inp.sigma;            sigma_src = 'handles.inp.sigma';
elseif isstruct(handles) && isfield(handles,'sigma') && ~isempty(handles.sigma)
    sigma = handles.sigma;                sigma_src = 'handles.sigma';
elseif isstruct(handles) && isfield(handles,'SVMpara') && isstruct(handles.SVMpara) ...
        && isfield(handles.SVMpara,'kw') && ~isempty(handles.SVMpara.kw)
    sigma = handles.SVMpara.kw;           sigma_src = 'handles.SVMpara.kw (legacy)';
else
    sigma = 1;                            sigma_src = 'default (=1)';
end

gamma       = sigma / nvar;
gamma_src   = 'derived from sigma/nvar';
sigma_asked = sigma;        % what the user asked for, before any gamma override

% escape hatch: raw gamma, bypasses the /nvar division
gamma_override = false;
if isfield(inp,'gamma') && ~isempty(inp.gamma)
    gamma          = inp.gamma;
    gamma_src      = 'inp.gamma (overrides sigma, bypasses /nvar)';
    gamma_override = true;
    sigma          = gamma*nvar;          % keep the record self-consistent
end

% ---- consistency check :  gamma  ==  sigma / nvar  ? -------------
chk = struct();
chk.nvar           = nvar;
chk.sigma_recorded = sigma;
chk.gamma_expected = sigma / nvar;
chk.gamma_actual   = gamma;
chk.abs_diff       = abs(chk.gamma_actual - chk.gamma_expected);
if chk.gamma_expected ~= 0
    chk.rel_diff = chk.abs_diff / abs(chk.gamma_expected);
else
    chk.rel_diff = chk.abs_diff;
end
chk.tol            = 1e-12;
chk.isconsistent   = (chk.rel_diff <= chk.tol);
if chk.isconsistent
    chk.msg = sprintf('OK: gamma (%g) == sigma/nvar (%g/%d)', ...
                      chk.gamma_actual, chk.sigma_recorded, nvar);
else
    chk.msg = sprintf('MISMATCH: gamma (%g) ~= sigma/nvar (%g/%d = %g)', ...
                      chk.gamma_actual, chk.sigma_recorded, nvar, chk.gamma_expected);
    warning('RUN_SVM_rbf_wDecVal_CmpClsfr:sigmaGammaMismatch','%s',chk.msg);
end
% if the caller supplied BOTH sigma and gamma, tell them which one won
if gamma_override && (isfield(inp,'sigma') || isfield(inp,'kw'))
    chk.sigma_asked_by_user = sigma_asked;
    chk.note = sprintf(['both sigma (%g) and gamma (%g) were supplied; ' ...
                        'inp.gamma WINS -> effective sigma = gamma*nvar = %g'], ...
                        sigma_asked, gamma, sigma);
    if abs(sigma_asked - sigma) > 1e-12*max(1,abs(sigma))
        warning('RUN_SVM_rbf_wDecVal_CmpClsfr:sigmaOverridden','%s',chk.note);
    end
end

% ------------------- resolve C (default 1) ----------------------
C_src = 'default';
if isfield(inp,'C') && ~isempty(inp.C)
    para_C = inp.C;                       C_src = 'inp.C';
elseif isstruct(handles) && isfield(handles,'inp') && isstruct(handles.inp) ...
        && isfield(handles.inp,'C') && ~isempty(handles.inp.C)
    para_C = handles.inp.C;               C_src = 'handles.inp.C';
elseif isstruct(handles) && isfield(handles,'C') && ~isempty(handles.C)
    para_C = handles.C;                   C_src = 'handles.C';
elseif isstruct(handles) && isfield(handles,'SVMpara') && isstruct(handles.SVMpara) ...
        && isfield(handles.SVMpara,'C') && ~isempty(handles.SVMpara.C)
    para_C = handles.SVMpara.C;           C_src = 'handles.SVMpara.C (legacy)';
else
    para_C = 1;                           C_src = 'default (=1)';
end

str_SVM_parameters = [' -g ',num2str(gamma),' -c ',num2str(para_C),' -q'];
disp([' RBF-SVM parameters --> sigma(kw) = ',num2str(sigma), ...
      '  ==> gamma = sigma/nvar = ',num2str(gamma), ...
      '   C = ',num2str(para_C), ...
      '   (nvar = ',num2str(nvar), ...
      ' , asmc_num = ',num2str(asmc_num),' [',asmc_scheme,'])']);


t0_linearSVM=cputime;

      model_wDecVal_RBFKernel = svmtrain_MEX(L.AclassinfoT, trainpk_sparse, str_SVM_parameters);

 ET_model_build_linearSVM=cputime-t0_linearSVM;
 disp([' model building time for linearSVM --> ',num2str(ET_model_build_linearSVM),' sec']);

      [SELF_predicted_label_wProb_LinearKernel, SELF_accuracy_wProb_LinearKernel, SELF_decision_values_prob_estimates_wProb_LinearKernel]...
    = svmpredict_MEX(L.AclassinfoT, trainpk_sparse,  model_wDecVal_RBFKernel );


 SELF_PAS_libsvm_wProb_LinearKernel=SELF_accuracy_wProb_LinearKernel(1);
disp_with_border(['SELF_LinearKernel-PAS based on libsvm with DecVal --> ',roundns(SELF_PAS_libsvm_wProb_LinearKernel,2),'%']);


   [predicted_label_wProb_LinearKernel, accuracy_wProb_LinearKernel, decision_values_prob_estimates_wProb_LinearKernel]...
    = svmpredict_MEX(L.AclassinfoP, pred_sparse,  model_wDecVal_RBFKernel);


PAS_libsvm_wProb_LinearKernel=accuracy_wProb_LinearKernel(1);
disp_with_border(['LinearKernel-PAS based on libsvm with DecVal --> ',roundns(PAS_libsvm_wProb_LinearKernel,2),'%']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc_misP=find(predicted_label_wProb_LinearKernel~=L.AclassinfoP);
S_SVMlinear_misP.SampleSeq=loc_misP;
try
S_SVMlinear_misP.PredasLabel=arrayfun(@(x) L.clistclslabel{x},predicted_label_wProb_LinearKernel(loc_misP),'un',0);
end
try
    S_SVMlinear_misP.TrueLabel=L.AclabelP(loc_misP);
catch
    try
        L.AclabelP=arrayfun(@(x) L.clistclslabel{x},L.AclassinfoP,'un',0);
    catch

        % deal with samples from non-merged classes predas merged cls
        L.AclabelP=repmat({NaN},size(L.AclassinfoP));
        try
        loc_from_NonMerged=find_belong2subgrp( L.AclassinfoP,setdiff(unique(L.AclassinfoP),[1:length(L.clistclslabel)]));

        L.AclabelP(loc_from_NonMerged)=arrayfun(@(x) handles.Lorig.clistclslabel{x},L.AclassinfoP(loc_from_NonMerged),'un',0);

         loc_from_Merged=find_belong2subgrp( L.AclassinfoP,[1:length(L.clistclslabel)]);
         L.AclabelP(loc_from_Merged)=arrayfun(@(x) L.clistclslabel{x},L.AclassinfoP(loc_from_Merged),'un',0);
        end

    end
    S_SVMlinear_misP.TrueLabel=L.AclabelP(loc_misP);

end

try
    corename=find_keyword_between_markers( handles.INPfilename,'Atrainpketc_','.mat');
catch
    try
        corename=find_keyword_between_markers( inp.INPfilename,'Atrainpketc_','.mat');
    catch
        try
            corename=find_keyword_between_markers( handles.pathfname_AT,'Atrainpketc_','.mat');
        catch
            try
                corename=find_keyword_between_markers( inp.pathfname_TP,'Atrainpketc_','.mat');
            catch
                corename='--';
            end
        end
    end
end

try
    addinfo_Hier=[handles.addinfo_Hier,'_'];;
corename=[addinfo_Hier,corename];
end

try
    if handles.xlswrite==1
        fname_misP=['MisPredicted_by_SVM-linear(',num2str(length(loc_misP)),')_',corename,'.xlsx'];
        try
            struct2xls(fname_misP,S_SVMlinear_misP);
        catch
            if isempty(loc_misP)

                %  very important to add : " 'un',false " to output to a structure
                S_SVMlinear_misP=structfun(@(x) NaN,S_SVMlinear_misP,'un',0);%  very important to add : " 'un',false " to output to a structure
                try      struct2xls(fname_misP,S_SVMlinear_misP);end
            else
                try
                    disp(['can not write to xls for ',fname_misP]) ;
                end
            end
        end

        disp([fname_misP,' has been saved ']);
    end
end

disp(['number of Mis-Predicted  = ',num2str(length(loc_misP)),'/',num2str(length(L.AclassinfoP))]);
disp('**********************************************************')
disp('**********************************************************')
%%%%%%%%%%%%%%%%%%%%%%%%
out.self_Predict_Accuracy=SELF_PAS_libsvm_wProb_LinearKernel;
out.extr_Predict_Accuracy=PAS_libsvm_wProb_LinearKernel;
out.ET_model_build=ET_model_build_linearSVM;
out.NmisP=length(loc_misP);
%%%%%%%%%%%%%%%%%%%%%%%%%%
% ===== HYPERPARAMETER RECORD (all user-provided settings) ================
out.asmc_num    = asmc_num;        % 0 none / 1 autoscale / 2 mean-center
out.asmc_scheme = asmc_scheme;
out.sigma_used  = sigma;           % kernel width multiplier
out.kw_used     = sigma;           % legacy alias -- SAME quantity as sigma
out.nvar        = nvar;
out.gamma_used  = gamma;           % what libsvm actually received via -g
out.C_used      = para_C;

% grouped, plus provenance of each setting
out.HyPara = struct( ...
    'asmc_num'    , asmc_num , ...
    'asmc_scheme' , asmc_scheme , ...
    'sigma'       , sigma , ...
    'kw'          , sigma , ...
    'nvar'        , nvar , ...
    'gamma'       , gamma , ...
    'C'           , para_C , ...
    'sigma_source', sigma_src , ...
    'gamma_source', gamma_src , ...
    'C_source'    , C_src , ...
    'libsvm_args' , strtrim(str_SVM_parameters) , ...
    'check'       , chk );
% ========================================================================
try, out.nSV=sum(model_wDecVal_RBFKernel.nSV); end
try, out.nSV_frac=out.nSV/numel(L.AclassinfoT); end
%%%%%%%%%%%%%%%%%%%%%%%%%%
try
   out.predcls= predicted_label_wProb_LinearKernel;
end
try
   out.pred_prob= decision_values_prob_estimates_wProb_LinearKernel;
end

try
    out.model_Label=model_wDecVal_RBFKernel.Label;
end

out.loc_misP=loc_misP;
end   % end of function --> RUN_SVM_rbf_wDecVal_CmpClsfr


%% ----- from RawSpectra_new_P_from_o1_o2.m ---------------------------------
function out=RawSpectra_new_P_from_o1_o2(o1,o2)

try
    RawSpectra1= o1.LAT.RawSpectra.Pset;
catch
    
    RawSpectra1='';
end

try
    RawSpectra2= o2.LAT.RawSpectra.Pset;
catch
    RawSpectra2='';
end

if ~isempty(RawSpectra1) && ~isempty(RawSpectra2)
    RawSpectra_new=[RawSpectra1;RawSpectra2];
else
    RawSpectra_new='';
end
        
% if ~isempty(RawSpectra_new)
%     try
%         if isa(LAT_new.RawSpectra,'struct')
%             LAT_new.RawSpectra.Pset=RawSpectra_new;
%         else
%             LAT_new.RawSpectra=RawSpectra_new;
%         end
%     end
% else
%     LAT_new.RawSpectra=LAT_new.Atrainpk; %when RawSpectra in o1 and o2 not both exist, use Atrainpk to represent it
% end

 out=RawSpectra_new;
end
        
        


%% ----- from RenameField.m -------------------------------------------------
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


%% ----- from SAinsert_cell2cell.m ------------------------------------------
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


%% ----- from SAinsert_createNew_w_seqnum.m ---------------------------------
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


%% ----- from SAinsert_createNew_w_seqnum_2D.m ------------------------------
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


%% ----- from SAinsert_cstr_or_double.m -------------------------------------
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


%% ----- from SAinsert_mat2cell_CH.m ----------------------------------------
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


%% ----- from SAinsert_num2cell.m -------------------------------------------
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


%% ----- from SAinsert_repmat.m ---------------------------------------------
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


%% ----- from SAinsert_repmat_2D.m ------------------------------------------
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


%% ----- from SpcDistance.m -------------------------------------------------
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


%% ----- from Speak_mk.m ----------------------------------------------------
function [ ret ] = Speak_mk(saytext, voice, rate, volume, pitch, language)
% Use speech output to speak a given text.
%
% Usage:
%
% [ ret ] = Speak(text [, voice][, rate][, volume][, pitch][, language]);
%
% The function returns an optional 'ret'urn code 0 on success, non-zero
% on failure to speak the requested text.
%
% 'text' must be a text to speak, either a text string or a cell array
% of text strings to speak separately, cell by cell.
%
% The optional 'voice' parameter allows to select among different system
% voices. It is supported on Linux and Mac OS/X.
%
% The names of the available voices differ across operating systems.
%
% Linux supports, e.g., male1,  male2,  male3,  female1,  female2,
% female3, child_male, child_female.
%
% OS/X: Type "!say -v ?" in Matlab to get a list of supported voices.
%
% The optional 'rate' parameter controls speed of speaking on OS/X and
% Linux. On OS/X it defines the number of words per minute, on Linux a
% value between -100 and +100 defines slower or faster speed.
%
% The optional 'volume' parameter allows control of loudness on Linux:
% Value range is -100 to + 100.
%
% The optional 'pitch' parameter allows control of pitch on Linux:
% Value range is -100 to + 100.
%
% The optional 'language' parameter allows control of the output language
% on Linux. E.g., 'de' would output in german language, 'en' english
% language. The text string must be a valid ISO language code string.
%
% Note: Speak on MS-Windows requires the .NET framework to be installed.
% Note: Speak on Linux requires the spd-say command to be installed. This
% is the case by default, e.g., at least on Ubuntu Linux 12.04 and later.
%
% Examples:
% Say "Hello darling" with standard system voice:
% Speak_mk('Hello darling');
%
% Say same text with voice named "Albert":
% Speak('Hello darling', 'Albert');
%

% History:
% 24.07.09 mk           Written for OS/X.
% 03.10.12 Vishal Shah  Added basic support for MS-Windows.
% 06.10.12 mk           Add extended support for OS/X and Linux.
% 24.07.15 mk           Use double-quotes instead of pairs of single quotes
%                       to protect strings containing apostrophes etc.
%                       Suggested by elladawu. Successfully tested on Linux.
if false
    
    Speak_mk('Hello darling')
    
    Speak_mk('can only run with cross validation')
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    error('You must provide the text string to speak!');
end

% Make saytext cell array of characters:
if ~isa(saytext,'cell')
    saytext = {saytext};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IsWin=1;
IsOSX=0;
IsLinux=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if IsOSX
    cmd = 'say ';

    if nargin >= 2 && ~isempty(voice)
        cmd = [cmd sprintf('-v "%s" ', voice)];
    end

    if nargin >= 3 && ~isempty(rate)
        cmd = [cmd sprintf('-r %i ', rate)];
    end

    for k=1:length(saytext)
        % Build command string for speech output and do a system() call:
        ret = system(sprintf('%s "%s"', cmd, saytext{k}));
    end
end

if IsLinux
    cmd = 'spd-say --wait ';

    if nargin >= 2 && ~isempty(voice)
        cmd = [cmd sprintf('--voice-type "%s" ', voice)];
    end

    if nargin >= 3 && ~isempty(rate)
        cmd = [cmd sprintf('--rate %i ', rate)];
    end

    if nargin >= 4 && ~isempty(volume)
        cmd = [cmd sprintf('--volume %i ', volume)];
    end

    if nargin >= 5 && ~isempty(pitch)
        cmd = [cmd sprintf('--pitch %i ', pitch)];
    end

    if nargin >= 6 && ~isempty(language)
        cmd = [cmd sprintf('--language "%s" ', language)];
    end

    ret = 0;
    for k=1:length(saytext)
        % Build command string for speech output and do a system() call:
        ret = system(sprintf('%s "%s"', cmd, saytext{k}));
        if ret
            break;
        end
    end

    if ret
        warning('Speak: You need to install the spd-say function (speech-dispatcher) to use this function on Linux. Skipped.'); %#ok<WNTAG>
    end
end

if IsWin
    try
        % Using
        % Microsoft's TTS Namespace
        % http://msdn.microsoft.com/en-us/library/system.speech.synthesis.ttsengine(v=vs.85).aspx
        % Microsoft's Synthesizer Class
        % http://msdn.microsoft.com/en-us/library/system.speech.synthesis.speechsynthesizer(v=vs.85).aspx

        NET.addAssembly('System.Speech');
        Speaker = System.Speech.Synthesis.SpeechSynthesizer;
        for k=1:length(saytext)
            Speaker.Speak (saytext{k});
        end
        ret=0;
    catch
        warning('Speak: You need to install the .Net framework to use this function on Windows. Skipped.'); %#ok<WNTAG>
        ret=1;
    end
end

return;
end


%% ----- from TP_parsing_Extr_Tcv.m -----------------------------------------
function out=TP_parsing_Extr_Tcv(pfn,inp)
% modified from PLS_Tcv
%  outPLS_Tcv_iPf=PLS_Tcv(X_iAna_T_Tcv,Y_iAna_T_Tcv,cSampleName_T_Tcv,inp4Tcv);  % new and fixed
% data parsing based on "appear order"  Not sortnat
% see also:   Atrainpk_parse_AclabelT_subcls    sprintf_pad_zero_prefix 
if false
    
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cc
    pfn='C:\work\JDSU\Test_Quant_U2U\Siesler_Data\VS0909\OSW\Atrainpketc_saConc_Caffeine_(M1-105)_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls48_nsamp288.mat';
      inp.CurAnaName='Caffeine';
    inp.Tcv_scheme='Odd-Even-Scans' ;                            %  'Odd-Even-Scans'   '1PSSout'   'sqrtNSfolds-Conc'    'Leave-OneConc-Out'
    out=TP_parsing_Extr_Tcv(pfn,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    L=load(pfn);


Tcv_scheme= inp.Tcv_scheme;
% [X Y  cSampleName]=saConc2XY(L.PLS.Tset.saConc,inp.CurAnaName);
[X Y  cSampleName]=saConc2XY(L.saConc,inp.CurAnaName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
QSample=unique(cSampleName);
QSample_sortnat=sortnat(QSample);
QSample_appear_order= unique_appear_order_cstr(cSampleName);

nSample=length(QSample);
if strcmp(Tcv_scheme,'sqrtNSfolds-Conc')
    nFolds=floor(sqrt(nSample));
elseif strcmp(Tcv_scheme,'Leave-OneConc-Out') | strcmp(Tcv_scheme ,'1PSSout')
    nFolds=nSample;
elseif    strcmp(Tcv_scheme,'Odd-Even-Scans')
     nFolds=2;
else
    error(' "Tcv_scheme" Not supported')
end

seq_pad=[1:ceil(nSample/nFolds)*nFolds];
seq_pad(seq_pad>nSample)=NaN;
idx_table=reshape(seq_pad,[nFolds ceil(nSample/nFolds) ]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_orig=pwd;
tmpcorename=strrep(find_keyword_between_markers(fileparts_name_ext(pfn),'Atrainpketc','_pp1'),'_saConc_','');

tmpfolder4Save=tmp_folder_rm_mk([tmpcorename,'_',Tcv_scheme,'_ParseTP_Ncomb',num2str(nFolds)],pwd);
cd(tmpfolder4Save);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loc_all=col_always([1:length(Y)]);
oaTP=[];
for iQS=1:nFolds
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    switch Tcv_scheme
        case {'10folds-Conc','5folds-Conc','sqrtNSfolds-Conc'}
            loc4P_in_QSample_appear_order=idx_table(iQS,:);
            loc4P_in_QSample_appear_order(isnan(loc4P_in_QSample_appear_order))='';
            loc_P_iQS=find(ismember(cSampleName,QSample_appear_order(loc4P_in_QSample_appear_order)));
            loc_T_iQS=setdiff(loc_all,loc_P_iQS);
        case {'Leave-OneConc-Out','1PSSout'}   % PSS: Physically Same Sample
           % loc_P_iQS=strmatch(QSample_sortnat{iQS},cSampleName,'exact');
              loc_P_iQS=strmatch(QSample_appear_order{iQS},cSampleName,'exact');
            loc_T_iQS=setdiff(loc_all,loc_P_iQS);
        case 'Odd-Even-Scans'
            loc_P_iQS=col_always([ iQS:2:length(cSampleName)]);
            loc_T_iQS=setdiff(loc_all,loc_P_iQS);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    X_T_iQS=X(loc_T_iQS,:);
    Y_T_iQS=Y(loc_T_iQS,:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %checking
    if ~strcmp(Tcv_scheme,'Odd-Even-Scans')
        ID4Pi=cSampleName(loc_P_iQS);
        ID4Ti=cSampleName(loc_T_iQS);
        qID4Pi=unique(ID4Pi);
        qID4Ti=unique(ID4Ti);
        TotalNum_qID=length(qID4Pi)+length(qID4Ti);
        if length(unique(cSampleName))~=TotalNum_qID
            error('not all spectra parsed into training vs prediction set in cross validation')
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    X_P_iQS=X(loc_P_iQS,:);
    Y_P_iQS=Y(loc_P_iQS,:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LocT_i=loc_T_iQS;
    try
        LATi.RawSpectra.Tset=L.RawSpectra(LocT_i,:);
    end
    LATi.Atrainpk=L.Atrainpk(LocT_i,:);
    LATi.AclassinfoT=L.AclassinfoT(LocT_i);
    LATi.AclabelT=L.AclabelT(LocT_i);
    LATi.PLS.Tset.saConc=L.saConc(LocT_i);
    %%%%%%%%
     LocP_i=loc_P_iQS;
    try
        LATi.RawSpectra.Pset=L.RawSpectra(LocP_i,:);
    end
    LATi.Apred=L.Atrainpk(LocP_i,:);
    LATi.AclassinfoP=L.AclassinfoT(LocP_i);
    LATi.AclabelP=L.AclabelT(LocP_i);
    LATi.PLS.Pset.saConc=L.saConc(LocP_i);
    %%%%%%%%%%
    LATi.clistclslabel=L.clistclslabel;
    try
    LATi.wvl_standardize=L.wvl_standardize;
    end
    %%%%%%%%%%%%
    sdi=ssds(LATi);
    inp_i.corename=['icomb',sprintf_pad_zero_prefix(iQS,length(num2str(nFolds))),find_keyword_between_markers(fileparts_name_ext(pfn),'Atrainpketc','_nvar')];
    sdi=sdi.saveAT(inp_i);
    %%%%%%%%%%%%%
    oaTP=[oaTP;sdi];
end
cd(path_orig);
out.oaTP=oaTP;  % object array for TP pairs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
done_with_this_function;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [X_iAna Y_iAna  cSampleName]=saConc2XY(saConc,AnaName)
% idx_CurAna= arrayfun(@(x) strcmp(x.clsname,AnaName),saConc);
% X_iAna=cell2mat(arrayfun(@(x) x.Atrainpk, saConc(idx_CurAna),'un',0));
% Y_iAna=cell2mat(arrayfun(@(x) repmat(x.Conc,[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
% cSampleName=cell_unwrap(arrayfun(@(x) repmat({x.SampleName},[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));


%% ----- from addpath_wo_attic.m --------------------------------------------
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


%% ----- from apply_1stDer.m ------------------------------------------------
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


%% ----- from apply_2ndDer.m ------------------------------------------------
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


%% ----- from apply_NstDer.m ------------------------------------------------
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


%% ----- from apply_PP_on_RawSpectra.m --------------------------------------
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


%% ----- from apply_SNV.m ---------------------------------------------------
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
% isequal(rawSpectra_SNV,RS_SNV)

% done_with_this_function;


%% ----- from apply_autoscale_on_Atrainpketc_L_struct.m ---------------------
function Lasmc=apply_autoscale_on_Atrainpketc_L_struct(L)
if false
    
    cc
    pfn_AT='C:\work\JDSU\Test_ACP\iACPmp\ATetc_ResinKits_popular_polymers\Atrainpketc_{T-ES-553_P-OS-145}_Cmp_SVM_ILM_nvar121_ncls10_nsampT300_nsampP302_wPopularNames.mat' ;
    L=load(pfn_AT);
    Lasmc=apply_autoscale_on_Atrainpketc_L_struct(L);
    
end
%---------------------------------------------------------------------------------------------------------------------------------

Lasmc=L;
para_asmc=1;
para_norm=0;
[Lasmc.Atrainpk,Lasmc.Apred,asmc_mean_std]=normasmc_trainpk_pred(L.Atrainpk,L.Apred,para_norm,para_asmc);
if ~isequaltol(std(Lasmc.Atrainpk),ones([1 length(Lasmc.Atrainpk(1,:))]))
error('autoscale seems not working properly ?');
else
  disp('autoscale OK');
end
done_with_this_function;
end
          


%% ----- from asmc_Orig_Tset_extract_subset.m -------------------------------
function out= asmc_Orig_Tset_extract_subset(pathfname_AT,inp)
% see also Run_ssds_merge_rm_extract_class
if false
    
    clear
%     inp.cls_pick={'C05','C06','C07'};inp.action='extract';
        inp.cls_pick={'C01','C03'};inp.action='extract';

    pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\BMS_OTC\TestSite\API-Brand_T-10Cls\TMP_T-2s\Atrainpketc__icomb3_{T-P02_P03_P-P01}_nvar317_ncls10_nsampT720_nsampP360.mat'
    asmc_Orig_Tset_extract_subset(pathfname_AT,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % test this in ssds method: asmc_Global_extract_Local(obj,inp)
    
    clear
        pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\BMS_OTC\TestSite\API-Brand_T-10Cls\TMP_T-2s\Atrainpketc__icomb3_{T-P02_P03_P-P01}_nvar317_ncls10_nsampT720_nsampP360.mat'
    sd1=ssds(pathfname_AT);
     inp.cls_pick={'C01','C03'};% only need this but not inp.action='extract';
     
    out_asmc=asmc_Global_extract_Local(sd1,inp)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear
       % pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\Resin_Kits_PolymerLib\TestSite\ResinKit1-2_nsamp4491_VS_Nov20\TMP_T-1s\Atrainpketc__icomb1_{T-rk-1_P-rk-2}_nvar121_ncls50_nsampT1491_nsampP1500.mat'
    pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\Resin_Kits_PolymerLib\TestSite\RmCls_SS-6_46_ResinKit1-2\TMP_T-1s\Atrainpketc__icomb1_{T-rk-1_P-rk-2}_nvar121_ncls48_nsampT1431_nsampP1440.mat'
        sd1=ssds(pathfname_AT);
     inp.cls_pick={'RKSS-15','RKSS-47'};% only need this but not inp.action='extract';
     
    out_asmc=asmc_Global_extract_Local(sd1,inp);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % only Atrainpk there is no Apred etc
        clear
    pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\Resin_Kits_PolymerLib\TestSite\RmCls_SS-6_46_ResinKit1-2\Atrainpketc__icomb1_{T-rk-1}_nvar121_ncls48_nsampT1431.mat'
        sd1=ssds(pathfname_AT);
     inp.cls_pick={'RKSS-15','RKSS-47'};% only need this but not inp.action='extract';
     
    out_asmc=asmc_Global_extract_Local(sd1,inp);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ResinKits ncls=49 xRKs P-rk4 
            clear
    pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\Resin_Kits_PolymerLib\TestSite\RmCls_SS-46_ResinKit1-4_fixed_xRKs\Atrainpketc__icomb4_{ResinKit1_2_4_VS_Jan3_fixed_RmCls_SS-46_P-rk4_T-3rk}_nvar121_ncls49_nsampT4431_nsampP1470.mat'
        sd1=ssds(pathfname_AT);
        inp.action='extract';
     inp.cls_pick={'RKSS-28','RKSS-45'};% only need this but not inp.action='extract';
    out_asmc=asmc_Global_extract_Local(sd1,inp);
    
    

    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sd=ssds(pathfname_AT);
fname_AT_orig=fileparts_name_ext(sd.pathfname_AT);

para_norm=0;
para_asmc=1;
Lorig=sd.LAT;

if isfield(Lorig,'Apred')
[Atrainpk_asmc,Apred_asmc,asmc_mean_std]=normasmc_trainpk_pred(Lorig.Atrainpk,Lorig.Apred,para_norm,para_asmc);
Lasmc=Lorig;
Lasmc.Atrainpk=Atrainpk_asmc;
Lasmc.Apred=Apred_asmc;
else
[Atrainpk_asmc,Apred_asmc,asmc_mean_std]=normasmc_trainpk_pred(Lorig.Atrainpk,Lorig.Atrainpk,para_norm,para_asmc);
Lasmc=Lorig;
Lasmc.Atrainpk=Atrainpk_asmc;
% Lasmc.Apred=Apred_asmc;
end
sd1=ssds(Lasmc);
inp.pathfname_AT=strrep(fname_AT_orig,'.mat',['_Global-ncls',num2str(length(Lorig.clistclslabel)),'-asmc',num2str(para_asmc),'.mat']);
sd1=saveAT(sd1,inp);
out_extract=sd1.merge_rm_extract_class(inp);




out=out_extract;
disp('done asmc_Orig_Tset_extract_subset')
end


%% ----- from auto.m --------------------------------------------------------
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


%% ----- from calc_max_DV_in_CFP_SVM.m --------------------------------------
function   [max_DV Gloc_maxDV]= calc_max_DV_in_CFP_SVM( L )
%  also called --> maxDecVal_P
%--------------------------------------------
% add following, Mar 25, 2024
% CFP_dvABC_SVM_kernel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate maxDV (added July 18, 2020)
%    save( fname4hLW,'LwinCls','handles_insitu_Tcv','handles_LwinAPs_b');  % add --> handles_LwinAPs_b for max_DV cal'c
%================================================================
% L.handles_LwinAPs_b
% L.handles_LwinAPs_b.Lorig
% L.handles_LwinAPs_b.L  --> most important for calc of max_DV
%==============================================
% when called by Global Model, following section will skip
if ~isempty(L.handles_LwinAPs_b.Lorig)  % the following only work for Local Classes Model
    % the following only work for Local Classes Model
    figure;hold on;
    hp1=plot(L.handles_LwinAPs_b.Lorig.Apred','b-O');
    hp2=plot(L.handles_LwinAPs_b.L.Apred','r-*');
    % legend({'Apred scaled by Global Model','Apred scaled by Local Model'})
    
    loc_insitu_T=find_belong2subgrp_cstr(L.handles_LwinAPs_b.Lorig.AclabelT,L.handles_LwinAPs_b.L.clistclslabel);
    AT_insitu.Atrainpk=L.handles_LwinAPs_b.Lorig.Atrainpk(loc_insitu_T,:);
    AT_insitu.Apred=L.handles_LwinAPs_b.Lorig.Apred;
    [AT_insitu.Atrainpk,AT_insitu.Apred,asmc_mean_std]=normasmc_trainpk_pred(AT_insitu.Atrainpk,AT_insitu.Apred,0,1);
end


%--------------------------------------------------------------------------------------------------------------------------------------------------------------------
if false
    if isequal(AT_insitu.Apred,L.handles_LwinAPs_b.L.Apred)
        disp('check Apred is based on scaled by Local Model --> OK !!!');
        hp3=plot(AT_insitu.Apred','g-O');
        legend([hp1(1) hp2(1) hp3(1)  ],{'Apred scaled by Global Model','Apred scaled by Local Model','Apred scaled by Local Model Re-Calcd'});
        stit0=strrep(find_keyword_merge_dual_curly_bracket(fileparts_name_wo_ext(fname4dvA)),'_','\_')  ;
        title([stit0  ])
    else
        error('check Apred is based on scaled by Local Model --> Failed !!!')
        %         warning('check Apred is based on scaled by Local Model --> Failed !!!')

    end
end
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% L.handles_LwinAPs_b.L.Apred
% L.handles_LwinAPs_b.Lorig.Apred
if exist('L')
    
    try
        CFP_dvABC_SVM_kernel= L.CFP_dvABC_SVM_kernel;
    catch
        CFP_dvABC_SVM_kernel='rbf';
    end
else
      CFP_dvABC_SVM_kernel='rbf';
end
switch CFP_dvABC_SVM_kernel
    case 'rbf'
        [handles_LwinAPs_b out_LwinAPs_b]=RUN_SVM_rbf_wDecVal_CmpClsfr(L.handles_LwinAPs_b);
    case 'linear'
        [handles_LwinAPs_b out_LwinAPs_b]=RUN_SVM_linear_wDecVal_CmpClsfr(L.handles_LwinAPs_b);
    otherwise
        error('pls provide CFP_dvABC_SVM_kernel ?');
end
%===================================================================================
LwinAPs_DV_iqLwin= out_LwinAPs_b.pred_prob*(-1)^(find(out_LwinAPs_b.model_Label==L.LwinCls)-1);
max_DV=LwinAPs_DV_iqLwin;
Gloc_maxDV=L.Gloc_iqLwin_in_locMax ;

% figure;hold on;
% plot(L.Gloc_iqLwin_in_locMax  , max_DV,'b-O');
% ylabel('max DecVal Pset');
% xlabel("Gloc");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

done_with_this_function;
end


%% ----- from calc_thres_insitu_IV_V.m --------------------------------------
 function thres_insitu=calc_thres_insitu_IV_V(dvA, dvB, dvC , inp)
 % modified from calc_thres_insitu_IV, Jan 12, 2024
 % revisit this Mar 19, 2023
 % see also: maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone
 % revisit this Jan 12, 2024
 %--------------------------------------------------------------------------
 if false
     
 end
 %----------------------------------------------------------------------------
 %=================================================================================
 if nargin==1  && isa(dvA,'struct')
     unwrap_struct(dvA);
 elseif nargin==2  && isa(dvA,'struct') && isa(dvB,'struct') && isfield(dvB,'InsituThres_scheme')
     inp=dvB;
     unwrap_struct(dvA);
 end
 %--------------------------------------------------------------------------------
 switch inp.InsituThres_scheme
     %==============================================================================
     case {'IV'}
         if dvA<0 & dvB<0
             thres_insitu=mean([dvB dvC]);
         elseif dvA>0 & dvB>0
             thres_insitu=mean([dvB 0]);
         elseif dvA>0 & dvB<0
             thres_insitu=dvB;
         else
             error('can not handle this case with dvA and dvB')
         end
     %==============================================================================    
     case {'V'}
         %          thres_insitu= mean([minDVLwin_rm1fT;max_DV_LocalRU1]);
         thres_insitu= mean([dvB;dvC]);
     %==============================================================================    
     otherwise
         error('InsituThres_scheme Not supported ?');
 end
 
 %-----------------------------------------------------------------------
 done_with_this_function;
end
 %-----------------------------------------------------------------------

 
 


%% ----- from catstruct.m ---------------------------------------------------
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


%% ----- from cc.m ----------------------------------------------------------
function [] = cc()
%CC Full Clear / Complete Clear
%   Because I'm too lazy to type clear;close all;clc every damn time
evalin('base','clear');
close all;
clc
end


%% ----- from cell_unwrap.m -------------------------------------------------
function out=cell_unwrap(cstr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% unwrap cells inside each cell element and output a col vector cell
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if false
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={'abd';'fasfda';'fsafda'};
    out=cell_unwrap(cstr)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={{'abd'};{'fasfda','fasfaasdsds'};{'fsafda'}};
    out=cell_unwrap(cstr)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cstr={{'abd'};{'fasfdasffss';'dsds'};{'fsafda'}};
    out=cell_unwrap(cstr)
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
   
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=[];
for i=1:length(cstr)
    if iscell(cstr(i)) && ischar(cstr{i})
        eacstr=cstr(i);
    elseif iscell(cstr(i)) && iscell(cstr{i})
        eacstr=cstr{i};
    else
        out=cstr;
        disp('can not unwrap');
        return
    end
    out=[out;col_vector_ALWAYS( eacstr)];
    
end
end


%% ----- from cmap_DPR.m ----------------------------------------------------
function list_color_DPR = cmap_DPR(numcls,inp)
% this is still the latest version as of Dec 2021
% and typically this function should reside in --> 'C:\work\JDSU\mfiles\jdsu_Utility_mfiles\cmap_etc'
% updated by CMH, Mar 11, 2023
%==========================================================================================================
% updated for BH/ABU studies to accomodate customerized color schemes provided in  "inp.scolor"
% see also: plot_Pretreated_Spectra_various_stages_configurations
%
%%--------------------------------------------------------
% this is the latest version that use KS to pick colors
% currently there are 16 colors available for default settings
% pls see them in themap2_DefaultSet
%=====================================================
% see also : cmap_DPR_customerized cmap_DPR_reset_default_path
%=====================================================================
if false
    
    list_color_DPR = cmap_DPR(16);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(12);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(14);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(5);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
     list_color_DPR = cmap_DPR(4);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(31);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(30);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(3);
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%
    list_color_DPR = cmap_DPR(200);

    
end
%=================================================================
if nargin==1  ||  ( nargin==2  && isfield(inp,'clistclslabel') )      % 1st case typically deal with called by cmap_DPR_customerized while 2nd case deal with called by SVMnose
    % nargin==1 --> 1st case typically deal with called by cmap_DPR_customerized
    % ( nargin==2  && isfield(inp,'clistclslabel') ) --> 2nd case deal with called by SVMnose
    
    %the last row reserved for the last class (the nonagent class)
    % blue (b) reserved for neural or unknown
    % based on colorSpectrum_curvspace that go from K->R->G->B1
    % for numcls 2-7, this will be set manually
    show_color_yes=0;
    if numcls==5
        themap2_DefaultSet={'k';'r';'m';'c';'h';'p';'o';'v';'l';'s';'a';'w8';'g'};
    elseif numcls==4
%         themap2_DefaultSet={'k';'c';'r';'m'};
         themap2_DefaultSet={'k';'c';'m';'g'};
    else
        themap2_DefaultSet={'k';'r';'g8';'b8';'y8';'m';'c';'h';'p';'o';'v';'l';'s';'a';'w8';'g'};
    end
    defaultSetClsnum=length(themap2_DefaultSet);
    green=[0 1 0];blue=[0 0 1];
    B1=[0 0 0.8];%sligthly darker blue
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % use new approach based on colorSpectrum.m
    %      themap1=colorSpectrum(numcls);
    if   numcls>defaultSetClsnum
        themap1=colorSpectrum_curvspace(numcls);
        % move/add green to last row
        c=bsxfun(@minus,themap1,green);
        loc_g=find(sum(abs(c),2)==0);
        themap2=themap1;
        if ~isempty(loc_g)
            themap2(loc_g,:)=[];
            themap2=[themap2;green];
        else
            themap2(end,:)=green;
        end
        d=bsxfun(@minus,themap2,blue);
        loc_b=find(sum(abs(d),2)<1e-4);  % give some tolerance to finding location for blue color
        if ~isempty(loc_b)
            if length(themap2(:,1))~=numcls  && length(themap2(:,1))==numcls+1 && ~isempty(loc_b)
                themap2(loc_b,:)=[];
            elseif length(themap2(:,1))==numcls  && loc_b-1>=1
                blue_new=(blue+themap2(loc_b-1,:))/2;
                themap2(loc_b,:)=blue_new;
            else
                error('something unexpected happened')
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %       list_color_DPR=themap([1:numcls-1 end],:);
        
        
    else  % deal with colors under defaultSetClsnum
        
        themap2_DefaultSet_rgb=cell2mat(cellfun(@(x) rgbConvert(x),themap2_DefaultSet,'un',false));
        themap2=themap2_DefaultSet_rgb([1:numcls-1 end],:);
        
        
        %
        %
        %       switch numcls
        %           case 2
        %               themap2=[0 0 0;green];
        %           case 3
        %               themap2=[0 0 0;1 0 0;green];
        %           case 4
        %               themap2=[0 0 0;1 0 0;B1;green];
        %
        %           case 5
        %               themap2=[0 0 0;1 0 0;B1;[0.9 0.9 0];green];
        %
        %           case 6
        %               themap2=[0 0 0;1 0 0;B1;[0.9 0.9 0];[1 0 1];green];
        %
        %           case 7
        %               themap2=[0 0 0;1 0 0;B1;[0.9 0.9 0];[1 0 1];[0 1 1];green];
        %
        %           otherwise
        %               error('color for this number of cls NOT provided under defaultSetClsnum')
        %
        %       end
        
        
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % check whether themap2 meet all requirements
    if isUnique_themap(themap2) && isGreenLast(green,themap2) && isBlueAbsent(blue,themap2) && length(themap2(:,1))==numcls
        
        list_color_DPR=themap2;
    elseif ~isGreenLast(green,themap2)
        %             warning('last color is NOT Green');
        list_color_DPR=themap2;
    else
        error('something wrong with themap2')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if show_color_yes==1
        figure;hold on;
        for ic=1:numcls
            plot(ic,ic,'color',list_color_DPR(ic,:),'marker','O','markersize',20,'markerfacecolor',list_color_DPR(ic,:));
        end
        
    end
elseif nargin==2  && isfield(inp,'scolor')
    % updated Dec 8, 2021 for plot_Pretreated_Spectra_various_stages_configurations
    list_color_DPR=[];
    for ic=1:length(inp.scolor)
        list_color_DPR=[ list_color_DPR;color_CH(inp.scolor(ic))];
    end
else
    
    error('input variables signature Not supported')
end
end
%=================================================================================================================
%=================================================================================================================
%=================================================================================================================
%=================================================================================================================

    function out=isBlueAbsent(blue,themap)
         d=bsxfun(@minus,themap,blue);
     loc_b=find(sum(abs(d),2)==0);
        if isempty(loc_b)
            out=true;
        else
            out=false;
        end
end
        

    function out= isGreenLast(green,themap)
        
%        green=[0 1 0];
     
     c=bsxfun(@minus,themap,green);
     loc_g=find(sum(abs(c),2)==0); 
if ~isempty(loc_g) && loc_g==length(themap(:,1))
    out=true;
else
    out=false;
end
end

            
    function out=isUnique_themap(themap)
        
        ccmap=[];
        for ic=1:length(themap(:,1))
            ccmap=[ccmap;{kw2skw(themap(ic,:))}];
            
            
        end
        
        list_unique_color=unique(ccmap);
        
        if length(list_unique_color)~=length(themap(:,1))
            warning('not all colors are unique')
            out=false;
        else
%             disp(['there are ',num2str(length(list_unique_color)),' colors and they are all unique !']);
            out=true;
        end
end
        
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        function out= rgbConvert(x)     
        
        try 
            out=color_CH(x);
        catch
            
             out1=color_CH(x(1));       
             out=out1*str2num(x(2))/10;       
        end
end
        
        
        
            
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % original themap
%        themap=[0    0    0; %black (k)
%           1    0    0; %red (r)
%         % 0    0    1; %blue (b) reserved for neural or unknown 
% %         1    1    0; %replace this yellow by the below "o" (orange)see color_CH
%           1    0.5  0; 
%           1    0    1;
%           0    1    1;
%           0.6  0.6  0.6;
%           0.5  0    0;
%           0    0.5  0;
%           0    0    0.5;
%           0.5 0.5   0;
%           1    1    0; % put yellow here
%           0.5  0    0.5;
%           0    0.5  0.5;
%           0.3  0.3  0.3;
%           0.3  0    0;
%           0    0.3  0;
%           0    0    0.3;
%           0.3  0.3  0;
%           0.3  0    0.3;
%           0    0.3  0.3;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%           0.9    0    0; %red (r)
%         % 0    0    1; %blue (b) reserved for neural or unknown 
% %         1    1    0; %replace this yellow by the below "o" (orange)see color_CH
%           0.9    0.5  0; 
%           0.9    0    0.9;
%           0    0.9    0.9;
%           0.4  0.4  0.4;
%           0.4  0    0;
%           0    0.4  0;
%           0    0    0.4;
%           0.4 0.4   0;
%           0.9   0.9    0; % put yellow here
%           0.4  0    0.4;
%           0    0.4  0.4;
%           0.2  0.2  0.2;
%           0.2  0    0;
%           0    0.2  0;
%           0    0    0.2;
%           0.2  0.2  0;
%           0.2  0    0.2;
%           0    0.2  0.2;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%           0    1    0]; %green (g) stay at the END and reserved for non-agent class (air and interferents etc)
%       
%       
%       
      


%% ----- from col_always.m --------------------------------------------------
function colvector=col_always(inputvector)
% can handle either 1D numeric array or cell array
% see also row_always
% e.g. col_always([1 2 3])
% e.g. col_always([1 ;2 ;3])
% e.g. col_always({'ab','bcd','efgg'})
% e.g. col_always([1 2 3; 4 5 6])

size_inputvector=size(inputvector);
if isempty(inputvector)
    colvector=inputvector;
elseif  size_inputvector(1)>1 & size_inputvector(2)>1
    error('inputvector is not a 1D vector');
else
    if size_inputvector(1)>1
        colvector=inputvector;
    else
        colvector=inputvector';
    end
end
end


%% ----- from col_vector_ALWAYS.m -------------------------------------------
function output_row_vector=col_vector_ALWAYS(input_vector)
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
output_row_vector=output_row_vector';
end


%% ----- from colorSpectrum_curvspace.m -------------------------------------
function ColorCodes = colorSpectrum_curvspace(N)
% colorSpectrum Creates a spectrum of colors from red to green to blue. 
%   ColorCodes = colorSpectrum(N) ColorCodes contains N three-element RPG 
%   vectors. The RPG vectors follow the transition of red to green and 
%   green to blue. All RPB vectors must add to one, this avoids colors such
%   as cyan and yellow, which are hard to see in plots. 
% 
%   Ex. The following example shows the full spectrum made.
%       N = 1000;C=colorSpectrum(N);figure,hold on,
%       for i = 1:N,plot([1:10],ones(10,1)*i,'Color',C(i,:)),end,hold off

%   Copywrite Kirk T. Smith
% modified by Chang Hsiung to have transition K-R-G-B
%   
if false
    
    ColorCodes = colorSpectrum_curvspace(4)
    %%%%%%%%%%%%%%%%%%%%
    ColorCodes = colorSpectrum_curvspace(40)
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
K=[0 0 0];
R=[1 0 0];
G=[0 1 0];
B1=[0 0 0.8];%sligthly darker blue
p=[K;R;G;B1];
ColorCodes_orig= curvspace(p,N);
nMainColor=length(p(:,1));

nSlice=floor(N/nMainColor);
nRemain=N-nMainColor*nSlice;

mdSeq=[];orig_seq=[1:N]';
for iSlice=1:nSlice
    if iSlice==1
     
        [idxTrn, idxRef] = KennardStone( ColorCodes_orig, nMainColor);
       
    else
        [idxTrn, idxRef] = KennardStone( CurColorCodes, nMainColor);
        
    end
    mdSeq=[mdSeq;orig_seq(idxTrn)];
    if iSlice==1
        CurColorCodes=ColorCodes_orig;
    end
    
    CurColorCodes(idxTrn,:)=[];
    orig_seq(idxTrn)=[];
    
    
end
mdSeq=[mdSeq;setdiff([1:N]',mdSeq)];
if length(unique(mdSeq))~=N
error('something wrong in most distinguish colors seq');
else
 ColorCodes   =ColorCodes_orig(mdSeq,:);
    
end
disp('finish in setting up most distinguish color scheme')
end



% randseq=shaker([1:N]);
% 
% ColorCodes= curvspace(p,N);




% % R = linspace(255,-255,N)';
% K = linspace(255,-255,N)';
% 
% % G = [linspace(0,255,ceil(N/2)),linspace(255,0,ceil(N/2))]';
% % if mod(N,2)
% %     G = [G(1:ceil(N/2));G(ceil(N/2)+2:end)];
% % end
% 
% 
% R = [linspace(0,255,ceil(N/3)),linspace(255,0,ceil(N/3))]';
% if mod(N,3)
%     R = [R(1:ceil(N/3));R(ceil(N/3)+3:end)];
% end
% 
% 
% 
% G = [linspace(0,255,ceil(N*2/3)),linspace(255,0,ceil(N*2/3))]';
% 
% if mod(N,3)
%     G = [G(1:ceil(N*2/3));G(ceil(N*2/3)+3:end)];
% end
% 
% 
% 
% B = linspace(-255,255,N)';
% 
% 
% 
% % ColorCodes = [R,G,B]/255;
% ColorCodes = [K,R,G,B]/255;
% 
% ColorCodes = max(0,ColorCodes);
% end
% 


%% ----- from color_CH.m ----------------------------------------------------
function out=color_CH(inp)
% merge color_rgb_singleletter etc, Aug 1, 2025
%--------------------------------------------------------
% alias of color_rgb_singleletter
%convert either single letter color to rgb or vice versa
% e.g.     out=color_CH('r')
% e.g.     out=color_CH([.5 0 1])
% SAcolor(1).SL='k';SAcolor(1).rgb=[0 0 0];  % blacK
% SAcolor(2).SL='r';SAcolor(2).rgb=[1 0 0];  % Red
% SAcolor(3).SL='g';SAcolor(3).rgb=[0 1 0];  % Green
% SAcolor(4).SL='b';SAcolor(4).rgb=[0 0 1];  % Blue
% 
% SAcolor(5).SL='y';SAcolor(5).rgb=[1 1 0];  % Yellow--> Not used, see new one below
% SAcolor(5).SL='y';SAcolor(5).rgb=[0.8 0.8 0];  % dark Yellow for visibility

% SAcolor(6).SL='m';SAcolor(6).rgb=[1 0 1];  % Magenta
% SAcolor(7).SL='c';SAcolor(7).rgb=[0 1 1];  % Cyan
% SAcolor(8).SL='w';SAcolor(8).rgb=[1 1 1];  % White
% 
% SAcolor(9).SL='p'; SAcolor(9).rgb=[1 0 .5];  % Pink
% SAcolor(10).SL='o';SAcolor(10).rgb=[1 .5 0];  % Orange
% SAcolor(11).SL='l';SAcolor(11).rgb=[.5 1 0];  % Lime green
% SAcolor(12).SL='a';SAcolor(12).rgb=[0 1 .5];  % Aquamarine
% SAcolor(13).SL='s';SAcolor(13).rgb=[0 .5 1];  % Sky blue
% SAcolor(14).SL='v';SAcolor(14).rgb=[.5 0 1];  % Violet
% 
% SAcolor(15).SL='h';SAcolor(15).rgb=[.5 .5 .5];  % Half black/white or gray

% ALSO:
% listing of possible marker for a plot
% figure;h=plot(0,0);set(h,'marker');
% [ + | o | * | . | x | square | diamond | v | ^ | > | < | pentagram | hexagram | {none} ]
%
% list of 14 unique color (exclude w)
%listcolor='krgbymcpolasvh'

% for 32 unique combinations of color/marker
% listcolor='krgbymcpolasvhkrgbymcpolasvhkrgb'
% listmarker='>+<pxodh>+<pxodh>+<pxodh>+<pxodh';

%
if false
    
% for 32 unique combinations of color/marker
list_color='krgbymcpolasvhkrgbymcpolasvhkrgb'
list_marker='>+<pxodh>+<pxodh>+<pxodh>+<pxodh';
allcomb=arrayfun(@(x,y) [x,y],list_color,list_marker,'uniformoutput',false);
length(unique(allcomb))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for 64 unique combinations of color/marker
list_color='krgbymcpolasvhkrgbymcpolasvhkrgb';
list_color=[list_color,list_color];
list_marker='>+<pxodh>+<pxodh>+<pxodh>+<pxodh';
list_marker=[list_marker,list_marker(2:end),list_marker(1)];

allcomb=arrayfun(@(x,y) [x,y],list_color,list_marker,'uniformoutput',false);
length(unique(allcomb))

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=color_rgb_singleletter(inp);
end

% --- Merged function: color_rgb_singleletter.m ---
function out=color_rgb_singleletter(inp)
%convert either single letter color to rgb or vice versa
% e.g.     out=color_rgb_singleletter('r')
% e.g.     out=color_rgb_singleletter([.5 0 1])
% alias: color_singleletter_rgb,  color_CH
SAcolor(1).SL='k';SAcolor(1).rgb=[0 0 0];  % blacK
SAcolor(2).SL='r';SAcolor(2).rgb=[1 0 0];  % Red
SAcolor(3).SL='g';SAcolor(3).rgb=[0 1 0];  % Green
SAcolor(4).SL='b';SAcolor(4).rgb=[0 0 1];  % Blue

% SAcolor(5).SL='y';SAcolor(5).rgb=[1 1 0];  % Yellow--> Not used, see new one below
SAcolor(5).SL='y';SAcolor(5).rgb=[0.8 0.8 0];  % dark Yellow for visibility

SAcolor(6).SL='m';SAcolor(6).rgb=[1 0 1];  % Magenta
SAcolor(7).SL='c';SAcolor(7).rgb=[0 1 1];  % Cyan
SAcolor(8).SL='w';SAcolor(8).rgb=[1 1 1];  % White

SAcolor(9).SL='p'; SAcolor(9).rgb=[1 0 .5];  % Pink
SAcolor(10).SL='o';SAcolor(10).rgb=[1 .5 0];  % Orange
SAcolor(11).SL='l';SAcolor(11).rgb=[.5 1 0];  % Lime green
SAcolor(12).SL='a';SAcolor(12).rgb=[0 1 .5];  % Aquamarine
SAcolor(13).SL='s';SAcolor(13).rgb=[0 .5 1];  % Sky blue
SAcolor(14).SL='v';SAcolor(14).rgb=[.5 0 1];  % Violet

SAcolor(15).SL='h';SAcolor(15).rgb=[.5 .5 .5];  % Half black/white or gray
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ischar(inp) && length(inp)==1
    out=remove_empty_cell(arrayfun(@(x) matchedinfdn2outfdn(x,'SL',inp,'rgb'),SAcolor,'UniformOutput',false)); % output the content if cstr become single cell !!!
elseif isnumeric(inp) && length(inp)==3
   out=remove_empty_cell(arrayfun(@(x) sameNumeric_infdn2outfdn(x,'rgb',inp,'SL'),SAcolor,'UniformOutput',false)); % output the content if cstr become single cell !!!
else
    error('inp format can not be recognized !!!');
end
end

function outval= matchedinfdn2outfdn(x,infdn,inval,outfdn)
% find matching string

if color_CH__strcmp_CI(x.(infdn),inval)
    outval=x.(outfdn);
else
    outval=[];
end
end

function outval= sameNumeric_infdn2outfdn(x,infdn,inval,outfdn)
% find same numeric vector

if all(x.(infdn)==inval)
    outval=x.(outfdn);
else
    outval=[];
end
end

% --- Merged function: remove_empty_cell.m ---
function cstr=remove_empty_cell(cstr)
% output string if cstr become single cell !!!
loc=cellfun(@(x) isempty(x),cstr);
cstr(loc)=[];

if iscell(cstr) && length(cstr)==1
    cstr=cstr{1};        % output the content if cstr become single cell !!!
end
end

% --- Merged function: strcmp_CI.m ---
function result=color_CH__strcmp_CI(str1,str2)
%Case Insensitive version of strcmp
% e.g.  strcmp_CI('good','Good')
% strcmp_CI('good','bad')

result=strcmp(lower(str1),lower(str2));
end


%% ----- from consolidate_PPs_in_ModelName_vs_Atrainpk.m --------------------
function ModelName=consolidate_PPs_in_ModelName_vs_Atrainpk(SVMmodelType,handles,SM)
% changed to this new format that only allow TP pair to be used for model building from handles.inp.pathfname_TP, Jan 9, 2023

%=============================================================================================================================================
    %=============================================================================================================================================
    % update following to handle SVMmodel creation, Dec 21, 2022
%     SVMmodelType=  'SVMmodel_Linear_wDecVal_APs_'   ;
if false
    try
        pathfname_Tset =   handles.inp.pathfname_Tset;                                 % handle the case called by iACPmp_gui.mlapp
        ModelName=    strrep( fileparts_name_ext(pathfname_Tset),'Atrainpketc_',        [SVMmodelType]);
    catch
        try
            %         pathfname_TP=  handles.inp.pathfname_TP;
            pathfname_TP=  handles.pathfname_TP;    % modified from above line to this, Dec 20, 2022
            ModelName=    strrep( fileparts_name_ext(pathfname_TP),'Atrainpketc_',        [SVMmodelType]);
        catch
            try
                pathfname_TP=  handles.inp.pathfname_TP;    % modified from above line to this, Dec 20, 2022
                ModelName=    strrep( fileparts_name_ext(pathfname_TP),'Atrainpketc_',        [SVMmodelType]);
            catch
                pathfname_TP='';
                ModelName='';
            end
        end
    end
else
    % changed to this new format that only allow TP pair to be used for model building from handles.inp.pathfname_TP, Jan 9, 2023
    %
    try
        pathfname_TP=  handles.inp.pathfname_TP;
        ModelName=    strrep( fileparts_name_ext(pathfname_TP),'Atrainpketc_',        [SVMmodelType]);
    catch
        error(' only allow TP pair to be used for model building from handles.inp.pathfname_TP   ');
    end

end
    %======================================================================
    % handle the case called by iACPmp_gui.mlapp
    if ~exist( 'pathfname_TP','var' )
        pathfname_TP =  handles.inp.pathfname_Tset;
        ModelName=    strrep( fileparts_name_ext(pathfname_TP),'Atrainpketc_',        [SVMmodelType]);
    end
    %======================================================================
    % check PPs in pathfname_TP vs in ModelName
    if ~isempty(ModelName ) && ~isempty(pathfname_TP) && isfield(SM,'PP_methods') && ~isempty(SM.PP_methods)
        sPP1_MN=find_keyword_between_markers(ModelName,'_pp1-'  ,'_')    ;
        sPP2_MN=find_keyword_between_markers(ModelName,'_pp2-'  ,'_')    ;
        if strcmp(SM.PP_methods.pp1 , sPP1_MN ) && strcmp(SM.PP_methods.pp1 , sPP1_MN )
            disp('PPs in ModelName matched with that in  "inp.PP_methods" !  ');
            ModelName=strrep(ModelName,'some_corename','Same-PPs');
        else
            disp('PPs in ModelName NOT matched with that in  "inp.PP_methods" !  ');
            sdx=ssds(pathfname_TP);
            pathfname_TP_barebone_tail =sdx.fname_AT_barebone_tail ;
            ModelName=[SVMmodelType,'pp1-' , SM.PP_methods.pp1,'_pp2-' , SM.PP_methods.pp2, pathfname_TP_barebone_tail  ] ;
            disp('PPs updated ModelName created !!! ');
        end
    end
end
    %=============================================================================================================================================
    %=============================================================================================================================================


%% ----- from consolidate_corename_2_pfn.m ----------------------------------
function out=consolidate_corename_2_pfn(pfn1,pfn2,inp)
% see also: get_corename_pfn

if false
    
    cc
    pfn1='C:\work\JDSU\Test_ACP\RK4NSEdemo\T109_P-105_wXLSX_0715\Atrainpketc_{T-M1-109_rk5_P-M1-105_rkN1}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls50_nsampT1500_nsampP300_wRK-SampleName.mat';
    pfn2='C:\work\JDSU\Test_ACP\RK4NSEdemo\ATetc_CARE\4NSEdemo\Atrainpketc_{CARE4NSEdemo}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls6_nsampT182_nsampP31.mat';
    inp='';
    out=consolidate_corename_2_pfn(pfn1,pfn2,inp)
    %----------------------------------------------------------------
    
    cc
    pfn1='C:\work\JDSU\Test_ACP\RK4NSEdemo\T109_P-105_wXLSX_0715\Atrainpketc_{T-M1-109_rk5_P-M1-105_rkN1}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls50_nsampT1500_nsampP300_wRK-SampleName.mat';
    pfn2='C:\work\JDSU\Test_ACP\RK4NSEdemo\ATetc_CARE\4NSEdemo\Atrainpketc_{CARE4NSEdemo}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls6_nsampT182_nsampP31.mat';
    inp.sPrefix_1='A-';
    inp.sPrefix_2='B-';
    out=consolidate_corename_2_pfn(pfn1,pfn2,inp)
    
    %--------------------------------------------------------------
    % add this Mar 9, 2024
    cc
    pfn_T='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_indv_4U\yarn\Atrainpketc_{M1-109(yarn)_M1-109}_nvar119_ncls4_nsamp80.mat';
    pfn_P='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_indv_4U\yarn\Atrainpketc_{M1-599(yarn)_M1-599}_nvar119_ncls4_nsamp80.mat';
    sdT=ssds(pfn_T);
    sdP=ssds(pfn_P);
    inp.sPrefix_1='T-';
    inp.sPrefix_2='P-';
    out_corename=consolidate_corename_2_pfn(pfn_T,pfn_P,inp);
    inp.corename=out_corename;
    sdTP=sdT>sdP;
    sdTP=sdTP.saveAT(inp);
    
    
    
    
    
    
end
%-------------------------------------------------------------------------------------------------
inp4cn.sMk_yes=0;
try
    sPrefix_1=inp.sPrefix_1;
    sPrefix_2=inp.sPrefix_2;
catch
    sPrefix_1='1-';
    sPrefix_2='2-';
end
out=['{',sPrefix_1,'(', get_corename_pfn(pfn1,'{','}',inp4cn),')_',sPrefix_2 ,'(', get_corename_pfn(pfn2,'{','}',inp4cn),')}' ];
end


%% ----- from create_spectra_plot_from_CmpSpectra_4ssds.m -------------------
function create_spectra_plot_from_CmpSpectra_4ssds(Atrainpk,Apred,fignum,FigNUserData,inp)
% this is typically called by --> setup_ShowLabel_findclosestCurve_RS_AT_gui
% this will setup for calling --> Clsname_CmpSpectra_gui_4ssds()  or 'pushbutton' --> 'Clsname_CmpSpectra_gui_4ssds'
%
% modified from create_spectra_plot_from_CmpSpectra()
% this function is used in setup_ShowLabel_findclosestCurve_RS_AT_gui()
% pls see CmpSpectra_fpred_analysis_gui()
% pls see FeatMat_Callback(hObject, eventdata, handles) inside SVM_gui.m
% see also setup_ShowLabel_findclosestCurve_RS_AT_gui create_spectra_plot_from_CmpSpectra 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  get "userdata" from fignum, typically already contained pickCurve (and pickCurve_P) from setup_ShowLabel_findclosestCurve_RS_AT_gui()
%  then set FigNUserData4pickCurve.pickCurve.hp_fig5 to very small
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% revisit following subfunction/functions for visualization tools in ABU or BH studies, Dec 7, 2021
% SVM_gui.m in SVMnose --> its own subfuntion --> FeatMat_Callback
% FeatMat_Callback   --> sd.diagnose_Clsname_PushButton(inp);
%    sd.diagnose_Clsname_PushButton(inp)  -->   setup_ShowLabel_findclosestCurve_RS_AT_gui          
%       setup_ShowLabel_findclosestCurve_RS_AT_gui  -->     create_spectra_plot_from_CmpSpectra_4ssds
%           create_spectra_plot_from_CmpSpectra_4ssds -->   pushbutton --> Clsname_CmpSpectra_gui_4ssds()
%                                                                                                      h_uicntl_clsname = uicontrol('style','pushbutton', ...
%                                                                                                        'string', FigNUserData.TPinfo_loaded.clistclslabel{icls}, 'callback', ...
%                                                                                                          'Clsname_CmpSpectra_gui_4ssds', ...
%                                                                                                            'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [0.9 loc_ui_clsname(icls) .08 ht_pb],'ForegroundColor',list_color_DPR(icls,:));
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% revisit this to copy this method to PCA-SVM plots, Sept 2, 2023
% create "ClsName" pushbutton for Tset, revisit Sept 2, 2023
% create "clsnum-P" pushbutton for Pset, revisit Sept 2, 2023
%-----------------------------------------------------------------
% add following to create DataTip for SVMnose, Apr 6, 2024
%------------------------------------------
% modify this to accommodate newly created pushbutton 'ManualPick' or "DataTips_Pick_scan" , Apr 15, 2024
% revisit June 8, 2024
%=============================================================================



FigNUserData4pickCurve=get(fignum,'userdata');
[FigNUserData4pickCurve.pickCurve.hp_fig5.LineStyle]=deal('none');%  make pickCurve.hp_fig5 to very small
[FigNUserData4pickCurve.pickCurve.hp_fig5.MarkerSize]=deal(0.3);%  make pickCurve.hp_fig5 to very small
try
    [FigNUserData4pickCurve.pickCurve_P.hp_fig5.LineStyle]=deal('none');%  make pickCurve_P.hp_fig5 to very small
    [FigNUserData4pickCurve.pickCurve_P.hp_fig5.MarkerSize]=deal(0.3);%  make pickCurve_P.hp_fig5 to very small
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xticklabel_angle=-45;
inpXLabels.xtick_increment=2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isa(Atrainpk,'struct')
Atrainpk=Atrainpk.Tset;
end
   ncls=length(FigNUserData.TPinfo_loaded.clistclslabel);
   if isfield(inp,'scolor')
       list_color_DPR = cmap_DPR(length(FigNUserData.TPinfo_loaded.clistclslabel),inp);
   else
       list_color_DPR = cmap_DPR(length(FigNUserData.TPinfo_loaded.clistclslabel));
   end
    figure(fignum);hold on;;
    chp_spectra_fig4100=[];
    for icls=1:ncls
%         loc_icls=find(FigNUserData.TPinfo_loaded.classinfoT==icls);
                loc_icls=find(FigNUserData.TPinfo_loaded.AclassinfoT==icls);
                


     %   chp_spectra_fig4100{icls,1}=plot(Atrainpk(loc_icls,:)','color',list_color_DPR(icls,:));
         chp_spectra_fig4100{icls,1}=plot(FigNUserData.TPinfo_loaded.wvl_standardize(FigNUserData.TPinfo_loaded.loc_wvl4AT),Atrainpk(loc_icls,:),'color',list_color_DPR(icls,:),'marker','O','markersize',4);
      %++++++++++++++++++++++++++++++++++++++++++++++++++++
      % add following to create DataTip for SVMnose, Apr 6, 2024
          inp_icls.sDataTip=[strrep(FigNUserData.TPinfo_loaded.AclabelT(loc_icls),'_','\_')];
          inp_icls.sDataTip_prefix='AclabelT-';
          plot_wDataTip(chp_spectra_fig4100{icls,1},inp_icls);
         %+++++++++++++++++++++++++++++++++++++++++++++++++++
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(Apred)
        chp_spectra_fig4100_P=[];
        nsamp_eaCls_P=[];
        for icls=1:ncls
            %         loc_icls=find(FigNUserData.TPinfo_loaded.classinfoT==icls);
            loc_icls_P=find(FigNUserData.TPinfo_loaded.AclassinfoP==icls);
            nsamp_eaCls_P=[nsamp_eaCls_P;length(loc_icls_P)];
            %   chp_spectra_fig4100{icls,1}=plot(Atrainpk(loc_icls,:)','color',list_color_DPR(icls,:));
            if ~isempty(loc_icls_P)
                
                chp_spectra_fig4100_P{icls,1}=plot(FigNUserData.TPinfo_loaded.wvl_standardize(FigNUserData.TPinfo_loaded.loc_wvl4AT),Apred(loc_icls_P,:),'color',list_color_DPR(icls,:),'marker','x','markersize',4);
               % chp_spectra_fig4100_P{icls,1}=plot(FigNUserData.TPinfo_loaded.wvl_standardize(FigNUserData.TPinfo_loaded.loc_wvl4AT),Apred(loc_icls_P,:),'color',[0.8 0.8 0.8],'marker','x','markersize',4);

               %++++++++++++++++++++++++++++++++++++++++++++++++++++
      % add following to create DataTip for SVMnose, Apr 6, 2024
          inp_icls_P.sDataTip=[strrep(FigNUserData.TPinfo_loaded.AclabelP(loc_icls_P),'_','\_')];
          inp_icls_P.sDataTip_prefix='AclabelP-';
          plot_wDataTip(chp_spectra_fig4100_P{icls,1},inp_icls_P);
         %+++++++++++++++++++++++++++++++++++++++++++++++++++
            else
                chp_spectra_fig4100_P{icls,1}=NaN;
            end
        end
        list_empty_clsP=find(nsamp_eaCls_P==0);
    else
        chp_spectra_fig4100_P=[];
        list_empty_clsP=NaN;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     isfield(inpp,'wvl_match_Atrainpk')

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ax_4100=axis;
    % loc_ax_clsname=linspace(ax_4100(1),ax_4100(2),ncls);
    
%     loc_ui_clsname=linspace(0.1,0.9,ncls);

%     loc_ui_clsname=linspace(0.08,1,ncls+1);
        loc_ui_clsname=linspace(0.08,0.85,ncls+1);  % modify this to accommodate newly created pushbutton 'ManualPick' or "DataTips_Pick_scan" , Apr 15, 2024

    ht_pb=(loc_ui_clsname(end)-loc_ui_clsname(1))/ncls;

    for icls=1:ncls
        % text(loc_ax_clsname(icls),ax_4100(4),FigNUserData.TPinfo_loaded.clistclslabel{icls},'color',list_color_DPR(icls,:));
        
        %         h_uicntl_clsname = uicontrol('style','pushbutton', ...
        %             'string', FigNUserData.TPinfo_loaded.clistclslabel{icls}, 'callback', ...
        %             'Clsname_CmpSpectra_gui', ...
        %             'fontsize', 8,'FontWeight','bold', 'units', 'normalized', 'position', [loc_ui_clsname(icls) 0.9 .05 .05],'ForegroundColor',list_color_DPR(icls,:));
        
        if ~isempty(Apred)
            %=================================================================================
            % create "ClsName" pushbutton for Tset, revisit Sept 2, 2023
            h_uicntl_clsname = uicontrol('style','pushbutton', ...
                'string', FigNUserData.TPinfo_loaded.clistclslabel{icls}, 'callback', ...
                'Clsname_CmpSpectra_gui_4ssds', ...
                'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [0.9 loc_ui_clsname(icls) .08 ht_pb],'ForegroundColor',list_color_DPR(icls,:));
            %%%%%%%%%%%%%%%%%%%%
            % create "clsnum-P" pushbutton for Pset, revisit Sept 2, 2023
            if isempty(find(list_empty_clsP==icls))
            h_uicntl_clsname_P = uicontrol('style','pushbutton', ...
                'string', [num2str(icls),'-P'], 'callback', ...
                'Clsname_CmpSpectra_gui_4ssds', ...
                'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [0.98 loc_ui_clsname(icls) .02 ht_pb],'ForegroundColor',list_color_DPR(icls,:));
            end
           %=================================================================================
        else
                       h_uicntl_clsname = uicontrol('style','pushbutton', ...
                'string', FigNUserData.TPinfo_loaded.clistclslabel{icls}, 'callback', ...
                'Clsname_CmpSpectra_gui_4ssds', ...
                'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [0.9 loc_ui_clsname(icls) .1 ht_pb],'ForegroundColor',list_color_DPR(icls,:));
            h_uicntl_clsname_P=[];
            
            
            
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    
    
%     h_uicntl_clsname = uicontrol('style','pushbutton', ...
%         'string', 'None', 'callback', ...
%         'Clsname_CmpSpectra_gui', ...
%         'fontsize', 8,'FontWeight','bold', 'units', 'normalized', 'position', [0.02 0.9 .05 .05],'ForegroundColor','b');
   
    
    h_uicntl_clsname = uicontrol('style','pushbutton', ...
    'string', 'None', 'callback', ...
    'Clsname_CmpSpectra_gui_4ssds', ...
    'fontsize', 8,'FontWeight','bold', 'units', 'normalized', 'position', [ 0.9 0.02 .05 .05],'ForegroundColor','b');
    %----------
    h_uicntl_clsname = uicontrol('style','pushbutton', ...
    'string', 'ManualPick', 'callback', ...
    'Clsname_CmpSpectra_gui_4ssds', ...
    'fontsize', 8,'FontWeight','bold', 'units', 'normalized', 'position', [ 0.9 0.85 .1 .05],'ForegroundColor','b');% modify this to accommodate newly created pushbutton 'ManualPick' or "DataTips_Pick_scan" , Apr 15, 2024

    %----------
    h_uicntl_clsname = uicontrol('style','pushbutton', ...
        'string', 'RmAll', 'callback', ...
        'Clsname_CmpSpectra_gui_4ssds', ...
        'fontsize', 8,'FontWeight','bold', 'units', 'normalized', 'position', [0.83 0.02 .05 .05],'ForegroundColor','b');
    
    h_uicntl_clsname = uicontrol('style','pushbutton', ...
        'string', 'ShowAll', 'callback', ...
        'Clsname_CmpSpectra_gui_4ssds', ...
        'fontsize', 8,'FontWeight','bold', 'units', 'normalized', 'position', [0.78 0.02 .05 .05],'ForegroundColor','b');
    
    
    
    
    % position_4100=get(gcf,'position');
    % if position_4100(3)<1276 && position_4100(4)<656
    set(gcf,'position',[256.3333   60.3333  944.0000  566.6667]);
    % end
    title([{FigNUserData.TPinfo_loaded.INPfilename};{''}])
    FigNUserData_4100=FigNUserData;
    FigNUserData_4100.fignum=fignum;
    FigNUserData_4100.chp_spectra_fig4100=chp_spectra_fig4100;
    try
        FigNUserData_4100.chp_spectra_fig4100_P=chp_spectra_fig4100_P;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     FigNUserData4pickCurve=get(fignum,'userdata');
    
    
    try
        FigNUserData_4100.pickCurve=FigNUserData4pickCurve.pickCurve;
    end
    
    try
        FigNUserData_4100.pickCurve_P=FigNUserData4pickCurve.pickCurve_P;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    set(fignum,'userdata',FigNUserData_4100);
end
   % disp_with_border(['First time push CmpSpectra, figure(',num2str(fignum.Number),') created but no picking of figure(400)''s prediction results will be prompted']);


%% ----- from curvspace.m ---------------------------------------------------
function q = curvspace(p,N)

% CURVSPACE Evenly spaced points along an existing curve in 2D or 3D.
%   CURVSPACE(P,N) generates N points that interpolates a curve
%   (represented by a set of points) with an equal spacing. Each
%   row of P defines a point, which means that P should be a n x 2
%   (2D) or a n x 3 (3D) matrix.
%
%   See also LINSPACE.
%

%   22 Mar 2005, Yo Fukushima

%   (Example)
if false
    
  x = -2*pi:0.5:2*pi;
  y = 10*sin(x);
  z = linspace(0,10,length(x));
  N = 50;
  p = [x',y',z'];
  q = curvspace(p,N);
  figure;
  plot3(p(:,1),p(:,2),p(:,3),'*-b',q(:,1),q(:,2),q(:,3),'.r');
  axis equal;
  legend('Original Points','Interpolated Points');
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  clear
  p=[0 0 0;1  0 0;0 1 0;0 0 1];
  N=50;
  q = curvspace(p,N);
    figure;
  plot3(p(:,1),p(:,2),p(:,3),'*-b',q(:,1),q(:,2),q(:,3),'.r');
  axis equal;
  legend('Original Points','Interpolated Points');

  
end
%








%% initial settings %%
currentpt = p(1,:); % current point
indfirst = 2; % index of the most closest point in p from curpt
len = size(p,1); % length of p
q = currentpt; % output point
k = 0;

%% distance between points in p %%
for k0 = 1:len-1
   dist_bet_pts(k0) = distance(p(k0,:),p(k0+1,:));
end
totaldist = sum(dist_bet_pts);

%% interval %%
intv = totaldist./(N-1);

%% iteration %%
for k = 1:N-1
   
   newpt = []; distsum = 0;
   ptnow = currentpt;
   kk = 0;
   pttarget = p(indfirst,:);
   remainder = intv; % remainder of distance that should be accumulated
   while isempty(newpt)
      % calculate the distance from active point to the most
      % closest point in p
      disttmp = distance(ptnow,pttarget);
      distsum = distsum + disttmp;
      % if distance is enough, generate newpt. else, accumulate
      % distance
      if distsum >= intv
         newpt = interpintv(ptnow,pttarget,remainder);
      else
         remainder = remainder - disttmp;
         ptnow = pttarget;
         kk = kk + 1;
         if indfirst+kk > len
            newpt = p(len,:);
         else
            pttarget = p(indfirst+kk,:);
         end
      end
   end
   
   % add to the output points
   q = [q; newpt];
   
   % update currentpt and indfirst
   currentpt = newpt;
   indfirst = indfirst + kk;
   
end
end



%%%%%%%%%%%%%%%%%%%%%%%%%
%%    SUBFUNCTIONS     %%
%%%%%%%%%%%%%%%%%%%%%%%%%

function l = distance(x,y)

% DISTANCE Calculate the distance.
%   DISTANCE(X,Y) calculates the distance between two
%   points X and Y. X should be a 1 x 2 (2D) or a 1 x 3 (3D)
%   vector. Y should be n x 2 matrix (for 2D), or n x 3 matrix
%   (for 3D), where n is the number of points. When n > 1,
%   distance between X and all the points in Y are returned.
%
%   (Example)
%   x = [1 1 1];
%   y = [1+sqrt(3) 2 1];
%   l = distance(x,y)
%

% 11 Mar 2005, Yo Fukushima

%% calculate distance %%
if size(x,2) == 2
   l = sqrt((x(1)-y(:,1)).^2+(x(2)-y(:,2)).^2);
elseif size(x,2) == 3
   l = sqrt((x(1)-y(:,1)).^2+(x(2)-y(:,2)).^2+(x(3)-y(:,3)).^2);
else
   error('Number of dimensions should be 2 or 3.');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newpt = interpintv(pt1,pt2,intv)

% Generate a point between pt1 and pt2 in such a way that
% the distance between pt1 and new point is intv.
% pt1 and pt2 should be 1x3 or 1x2 vector.

dirvec = pt2 - pt1;
dirvec = dirvec./norm(dirvec);
l = dirvec(1); m = dirvec(2);
newpt = [intv*l+pt1(1),intv*m+pt1(2)];
if length(pt1) == 3
   n = dirvec(3);
   newpt = [newpt,intv*n+pt1(3)];
end
end


%% ----- from delsamps.m ----------------------------------------------------
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


%% ----- from disp_cstr.m ---------------------------------------------------
function disp_cstr(cstr)
% e.g. cstr{1}='fafaffa';cstr{2}='fafdsffafaffa';disp_cstr(cstr)
% e.g. cstr{1}='C:\work\fafaffa.mat';cstr{2}='C:\work\fafdsffafaffa.mat';disp_cstr(cstr)

cellfun(@(x) disp(x),cstr);
end


%% ----- from disp_with_border.m --------------------------------------------
function out=disp_with_border(str_to_show)
% updated May 8, 2020 with "out"
% updated with padding with '+' , June 3, 2025
%=========================================================
if false
    
 disp_with_border('this is a test');
 %%%%%%%%%%%%%%%%%%%%
 out=disp_with_border('this is a test');
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


%% ----- from done_with_this_function.m -------------------------------------
function out=done_with_this_function()
% put this at end of any function to show which function is this
% see also: PLOT_MCC_ML_OCM_ScanThru_AUCthres
% see also: mfilename, me, find_parent_calling_function, PLOT_MCC_ML_OCM_ScanThru_AUCthres, test_me, predict_gnb_NaiveBayes, RUN_XGB_CmpClsfr

aStack = dbstack;
if length(aStack)>1
    aName = aStack(2).name;   % this (or "2") is the parent function that is calling this current function and in case there is "3" that will be the grandparent
  disp(['done with --> ',aName]);  
  out=aName;
end
end

    


%% ----- from dvABC_etc_Global_or_Local_Model.m -----------------------------
function out=dvABC_etc_Global_or_Local_Model(L  ,  inp  )
% revisit for KT, July 17, 2024
% deal with indv winner cls
% typically called by --> maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone   % revisit for KT, July 17, 2024
%---------------------------------------------------------------------------------------------
% typically called by --> dvABC_insituThres_FOM_GlobalModel
% modified from maxDV_Global_or_Local_Model
%------------------------------------------------
% dvB Tcv by PDS , Mar 26, 2024
% set dvB_PDS_yes=1 , i.e. dvB Tcv by PDS , see --> dvABC_etc_Global_or_Local_Model.m , Mar 26, 2024
% % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
% create/collect nPDS_WinCls , May 1, 2024 
% see also: AclabelT_format_ClsName_Sn_dvB_Tcv_PDS, May 4, 2024
% revisit for KT, July 17, 2024
%=======================================================
if false
    
    
    %==============================================================
   % wo asmc1 AT
    cc
  pfn_wc='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\winCls_PTT\Atrainpketc_{{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)[WinCls-PTT]}_nvar119_ncls4_nsampT224_nsampP45.mat';
     inp.LwinCls=3;
     %-----
    Lgmdv=load(pfn_wc);
    Lgmdv_auto=apply_autoscale_on_Atrainpketc_L_struct( Lgmdv ) ;                                                                        % this line would be needed for not asmc1 AT % this line would be needed for not asmc1 AT % this line would be needed for not asmc1 AT
    Lgmdv_auto.Apred=Lgmdv_auto.Atrainpk;   % create self_P for dvABC etc based on GlobalModel
    Lgmdv_auto.AclassinfoP=Lgmdv_auto.AclassinfoT; % create self_P for dvABC etc based on GlobalModel
    try
        Lgmdv_auto.AclabelP=Lgmdv_auto.AclabelT; % create self_P for dvABC etc based on GlobalModel
    end
    %-----
    out=dvABC_etc_Global_or_Local_Model(Lgmdv_auto  ,  inp  )
    out.dvB/2
    
    %==============================================================
    % with asmc1 AT
    % see also: BatchRun_CFP_SVM_maxDV_FOM --> apply asmc1 on AT (  end of July, 2024 )
    cc
    pfn_wc='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\winCls_PTT\Atrainpketc_{{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)[WinCls-PTT]_asmc1}_nvar119_ncls4_nsampT224_nsampP45.mat';
    inp.LwinCls=3;
    
    %-----
    Lgmdv_auto=load(pfn_wc);
    Lgmdv_auto.Apred=Lgmdv_auto.Atrainpk;   % create self_P for dvABC etc based on GlobalModel
    Lgmdv_auto.AclassinfoP=Lgmdv_auto.AclassinfoT; % create self_P for dvABC etc based on GlobalModel
    try
        Lgmdv_auto.AclabelP=Lgmdv_auto.AclabelT; % create self_P for dvABC etc based on GlobalModel
    end
    %-----
    out=dvABC_etc_Global_or_Local_Model(Lgmdv_auto  ,  inp  )
    out.dvB/2

    
    
    
    %==============================================================
end
%===================================================================================
try
dvB_PDS_yes=inp.dvB_PDS_yes;;   % set dvB_PDS_yes=1 , i.e. dvB Tcv by PDS , see --> dvABC_etc_Global_or_Local_Model.m , Mar 26, 2024
catch
dvB_PDS_yes=0;    
end

if dvB_PDS_yes
    sdvB_PDS_yes='dvB_Tcv_PDS=Yes';
else
    sdvB_PDS_yes='';
end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
LwinCls=inp.LwinCls;                                    % Local or Global Model's predicted as winner cls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "handles_insitu_Tcv" come from  RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
%------------------------------------------------------------------

if isfield(L,'handles_insitu_Tcv') && isfield(L.handles_insitu_Tcv,'L')
    disp('continue as orig process');
    handles_insitu_Tcv=L.handles_insitu_Tcv;% already based on autoscaled and self_P
elseif ~isfield(L,'handles_insitu_Tcv') && isfield(L,'Atrainpk') && isfield(L,'AclassinfoT')
    disp('new and cleaner approach --> move input variable "L" to handles_insitu_Tcv.L');
  handles_insitu_Tcv.L=L;  
end
%------------------------------------------------------------------

% handles_insitu_Tcv=L.handles_insitu_Tcv;% already based on autoscaled and self_P
%%%%%%%%%%%%%%%%%
% "handles_insitu_Tcv" converted to binary mode and call it "handles_insitu_Tcv_b"
handles_insitu_Tcv_b=handles_insitu_Tcv;                                                                                                                                % handles_insitu_Tcv_b --> this is the most important AT for calc of dvABC

%*****************************************************************************************************************************************************************************************************************
% handles_insitu_Tcv_b.L --> self-Prediction AT based on all local classes
if isequaltol(handles_insitu_Tcv_b.L.Atrainpk, handles_insitu_Tcv_b.L.Apred)
    disp_with_border('handles_insitu_Tcv_b.L --> self-Prediction AT based on all local classes');
else
    error('something wrong with "handles_insitu_Tcv_b.L"');
end
handles_insitu_Tcv_b.L.AclassinfoT(handles_insitu_Tcv_b.L.AclassinfoT~=LwinCls)=0;
handles_insitu_Tcv_b.L.AclassinfoP(handles_insitu_Tcv_b.L.AclassinfoP~=LwinCls)=0;
%%%%%%%%%%%%%%%%%%%
if exist('inp')
    try
        CFP_dvABC_SVM_kernel= inp.CFP_dvABC_SVM_kernel;
    catch
        CFP_dvABC_SVM_kernel='rbf';
    end
else
    CFP_dvABC_SVM_kernel='rbf';
end
%---------------------------
switch CFP_dvABC_SVM_kernel
    case 'rbf'
[handles_insitu_Tcv_b out_insitu_Tcv_b]=RUN_SVM_rbf_wDecVal_CmpClsfr(handles_insitu_Tcv_b);  % this is Not running OVA, but for binary classes case, it is the same as OVA
    case 'linear'
[handles_insitu_Tcv_b out_insitu_Tcv_b]=RUN_SVM_linear_wDecVal_CmpClsfr(handles_insitu_Tcv_b);
    otherwise
        error('pls provide CFP_dvABC_SVM_kernel ?');
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 DV_L_selfP_b=out_insitu_Tcv_b.pred_prob*(-1)^(find(out_insitu_Tcv_b.model_Label==LwinCls)-1);
% if false
%     DV_L_selfP_b=out_insitu_Tcv_b.pred_prob;
% end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

locLwin=find(handles_insitu_Tcv_b.L.AclassinfoT==LwinCls);
%-----------------------------------------------------------
% dvB Tcv by PDS , Mar 26, 2024
if dvB_PDS_yes
    if isfield(handles_insitu_Tcv_b.L,'AclabelT') && length(unique(handles_insitu_Tcv_b.L.AclabelT(locLwin)))~=length( handles_insitu_Tcv_b.L.AclabelT(locLwin ))
        [qAclabelT_win nAclabelT_win]=unique_count(handles_insitu_Tcv_b.L.AclabelT( locLwin ));
        
        if length( qAclabelT_win)==1
          qAclabelT_win_alt={[qAclabelT_win{1},'_1stH'];[qAclabelT_win{1},'_2ndH']};
        else
          qAclabelT_win_alt='';  
        end
        
    else
        qAclabelT_win= handles_insitu_Tcv_b.L.AclabelT(locLwin);
        nAclabelT_win=ones(size(qAclabelT_win));
    end
else
    qAclabelT_win= handles_insitu_Tcv_b.L.AclabelT(locLwin);
    nAclabelT_win=ones(size(qAclabelT_win));
     qAclabelT_win_alt=''; 
end
% +++++++++++++++++++++++++++++++++++++
if dvB_PDS_yes
    if length( qAclabelT_win)==1
        
        locLwin_1stH=locLwin(1:ceil(length(locLwin)/2));
        locLwin_2ndH=setdiff(locLwin,locLwin_1stH );
        cstr_locLwin_1stH=strwrite_all_delimiter(  cellstr(string(row_always(locLwin_1stH )))  ,'_') ;
        cstr_locLwin_2ndH=strwrite_all_delimiter(  cellstr(string(row_always(locLwin_2ndH )))  ,'_') ;
        cstr_locLwin=[{cstr_locLwin_1stH};{cstr_locLwin_2ndH}];
    else
        cstr_locLwin=[];
        for i_qT=1:length( qAclabelT_win )
            s_locLwin_i = strwrite_all_delimiter(  cellstr(string(row_always(find(strcmp(handles_insitu_Tcv_b.L.AclabelT,qAclabelT_win{ i_qT})))))  ,'_') ;
            cstr_locLwin=[cstr_locLwin ;{s_locLwin_i} ];
        end
    end
    
else
  cstr_locLwin = locLwin;                                     % orig approach that Tcv based on all indv scans in "locLwin"
end
%-------------------------------------------------------------

DV_Lwin=DV_L_selfP_b(locLwin);
minDVLwin=min(DV_Lwin);                                                                                                                                                                 % creation of dvA

dvA=minDVLwin;
%*****************************************************************************************************************************************************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%
% % find not 1st place winner or  all RunnerUp (RU1)
loc_NOT_Lwin=find(handles_insitu_Tcv_b.L.AclassinfoT~=LwinCls);

DV_LocalRU1=DV_L_selfP_b(loc_NOT_Lwin);
[max_DV_LocalRU1  loc_max_DV_LocalRU1]=max(DV_LocalRU1);
dvC=max_DV_LocalRU1;                                                                                                                                                                   % creation of dvC % the closest pt of all non-winner classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v1: find out 2nd place winner class
AclassinfoT_NOT_Lwin=handles_insitu_Tcv.L.AclassinfoT(loc_NOT_Lwin);
clsnum_RU1=AclassinfoT_NOT_Lwin(loc_max_DV_LocalRU1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles_insitu_rmWinCls=handles_insitu_Tcv;
% handles_insitu_rmWinCls=L.handles_insitu_rmWinCls;
handles_insitu_rmWinCls=handles_insitu_Tcv;
DV_Lwin_rm1fT=[];


% if length(locLwin)>1
%     for iLwincls=1:length(locLwin)
if length(cstr_locLwin)>1
    
    for iLwincls=1:length(cstr_locLwin)
        
        handles_insitu_rmWinCls_i=handles_insitu_rmWinCls;
        %++++++++++++++++++++++++++++++++++++++++++++++++++++
        if dvB_PDS_yes  % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
            %         Lwincls_i=locLwin(iLwincls);
            Lwincls_i=strread_delimiter_2num(cstr_locLwin{iLwincls},'_') ;   % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        else
            Lwincls_i=cstr_locLwin(iLwincls);                                 % orig approach that Tcv based on all indv scans in "locLwin"
        end
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        handles_insitu_rmWinCls_i.L.Apred=handles_insitu_rmWinCls_i.L.Atrainpk(Lwincls_i,:);        % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclassinfoP=handles_insitu_rmWinCls_i.L.AclassinfoT(Lwincls_i); % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclabelP=handles_insitu_rmWinCls_i.L.AclabelT(Lwincls_i);       % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        %++++++++++++++++++++++++++++++++++++++++++++++++++++
        handles_insitu_rmWinCls_i.L.Atrainpk(Lwincls_i,:)=[];                                       % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclassinfoT(Lwincls_i)=[];                                      % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclabelT(Lwincls_i)=[];                                         % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        %++++++++++++++++++++++++++++++++++++++++++++++++++++
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % run with simpler libsvm
        handles_insitu_rmWinCls_binary=handles_insitu_rmWinCls_i;
        handles_insitu_rmWinCls_binary.L.AclassinfoT(handles_insitu_rmWinCls_binary.L.AclassinfoT~=LwinCls)=0;
        switch CFP_dvABC_SVM_kernel
            case 'rbf'
                [handles_rmWinCls_i_b out_rmWinCls_i_b]=RUN_SVM_rbf_wDecVal_CmpClsfr(handles_insitu_rmWinCls_binary);
            case 'linear'
                [handles_rmWinCls_i_b out_rmWinCls_i_b]=RUN_SVM_linear_wDecVal_CmpClsfr(handles_insitu_rmWinCls_binary);
        end
        
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
         DV_Lwin_rm1fT=[DV_Lwin_rm1fT;out_rmWinCls_i_b.pred_prob*(-1)^(find(out_rmWinCls_i_b.model_Label==LwinCls)-1) ];
%         if false
%             DV_Lwin_rm1fT=[DV_Lwin_rm1fT;out_rmWinCls_i_b.pred_prob];
%         end
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
else
    DV_Lwin_rm1fT =DV_Lwin;
    
end
[minDVLwin_rm1fT  loc_minDVLwin_rm1fT]=min(DV_Lwin_rm1fT);      % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024                                                                                               % creation of dvB
dvB=minDVLwin_rm1fT;                                            % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if length(qLcls_win_RU1_etc(:,1))==1
%     clistLocalClass= Lorig.clistclslabel(qLcls_win_RU1_etc);
%     disp_with_border('list of local classes (winner RU1 etc) found after re-running Global Model inside dvA_dvB_dvC_ILM_CFP_v1()')
%     disp_with_border(strwrite_all_space(clistLocalClass));
% else
%     warning('non unique list of 5 local classes found')
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp_with_border(['dvA = ',roundns(dvA,4),'  dvB = ',roundns(dvB,4),'  dvC = ',roundns(dvC,4)]);
clsname_Lwin=handles_insitu_Tcv.L.clistclslabel{ LwinCls };
disp_with_border(['winner class --> ',clsname_Lwin]);
disp_with_border(strwrite_all_space(handles_insitu_Tcv.L.clistclslabel));
%==========================================================================================
out.dvA=dvA;  out.dvB=dvB;   out.dvC=dvC;
try
    out.ncls=length(L.clistclslabel);
    out.clistclslabel=L.clistclslabel;
catch
    out.ncls=length(handles_insitu_Tcv.L.clistclslabel);
    out.clistclslabel=handles_insitu_Tcv.L.clistclslabel;
end


out.sdvB_PDS_yes=sdvB_PDS_yes;
% out.nPDS_WinCls=['nPDS=',num2str(length(cstr_locLwin)),'_',clsname_Lwin];                        % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
if ~isempty(qAclabelT_win_alt)
out.nPDS_WinCls=['nPDS=',num2str(length(cstr_locLwin)),'[',num2str(length(qAclabelT_win)),']','(',clsname_Lwin,')'];     % create/collect nPDS_WinCls , May 1, 2024                   % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
else
out.nPDS_WinCls=['nPDS=',num2str(length(cstr_locLwin)),'(',clsname_Lwin,')'];     % create/collect nPDS_WinCls , May 1, 2024                   % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
end
return;



%==========================================================================================
%==========================================================================================
%==========================================================================================
%==========================================================================================
%==========================================================================================
%==========================================================================================
%==========================================================================================
%==========================================================================================
%==========================================================================================

if false
    plot_maxDV_yes=1;
    %------------------------------------------------------------------
    L_winP_auto=L;
    winner_clsnum=inp.winner_clsnum;
    Gloc_maxDV=inp.Gloc_maxDV;
    %============================================================================================
    L_winP__handles_LwinAPs_b=L_winP_auto;
    out_L_winP__handles_LwinAPs_b=is_autoscale(L_winP__handles_LwinAPs_b);
    if ~out_L_winP__handles_LwinAPs_b
        error(' L_winP__handles_LwinAPs_b is Not autoscaled ');
    else
        disp('next --> prepare L_winP__handles_LwinAPs_b into binary format');
        disp('calc of "max_DV_GM" --> max_DV based on Global Model');
        L_winP__handles_LwinAPs_b.AclassinfoT(L_winP__handles_LwinAPs_b.AclassinfoT~=winner_clsnum)=0;
        L_winP__handles_LwinAPs_b.AclassinfoP(L_winP__handles_LwinAPs_b.AclassinfoP~=winner_clsnum)=0;
        %     L=load(fname4dvA);
        %     [max_DV  Gloc_maxDV] = calc_max_DV_in_CFP_SVM( L ) ;        % add this calc of max_DV for Pset, Sept 26, 2022
        Lgm.handles_LwinAPs_b.L=L_winP__handles_LwinAPs_b;
        Lgm.LwinCls=winner_clsnum;                            % very important to add this !!!
        Lgm.Gloc_iqLwin_in_locMax =   Gloc_maxDV;    %  very important to add this !!!
        Lgm.handles_LwinAPs_b.Lorig=[];
        [max_DV_GM  Gloc_maxDV_GM] = calc_max_DV_in_CFP_SVM( Lgm ) ;
        if plot_maxDV_yes
            try
                hp_GM=  plot(Gloc_maxDV_GM  , max_DV_GM,'color',inp.scolor,'marker','O','markersize',8);
            catch
                hp_GM=  plot(Gloc_maxDV_GM  , max_DV_GM,'b-O','markersize',10);
            end
            %     legend([ hp_LCM  hp_GM],{'Max DV reCalc based on Local Classes Model' , 'Max DV reCalc based on Global Model' });
            try
                title_usF( inp.stit);
            end
        end
        %-----------------------------------------------------
        %     disp_with_border(['clistclslabel in local model --> ',strwrite_all_space(L_fname4dvA.handles_LwinAPs_b.L.clistclslabel)]);
        %-----------------------------------------------
        out.maxDV   = max_DV_GM;
        out.Gloc_maxDV= Gloc_maxDV_GM;
        try
            out.hp_GM_LM=hp_GM;
        catch
            out.hp_GM_LM='';
        end
    end
    %============================================================================================
end  % end of if false
end


%% ----- from enlarge_axis.m ------------------------------------------------
function ax_new=enlarge_axis(alpha1,alpha2,alpha3)
% works in both 2D/3D and in both linear and logarithmic scales    
% x-y-z axes are enlarged by magnification factors alpha1, alpha2, alpha3
% factors alpha1, alpha2, alpha3 are given in %, negative values are allowed
% see also: summary_iACP_wPP
if false
% example 1: x=1:100; y=sqrt(x); plot(x,y); enlarge_axis(0.1,0.05)
% example 2: x=1:100; y=sqrt(x); semilogy(x,y); enlarge_axis(0.1,0.05);
% example 3: x=1:100; y=sqrt(x); semilogx(x,y); enlarge_axis(0.1,0.05);
% example 4: x=1:100; y=sqrt(x); loglog(x,y); enlarge_axis(0.1,0.05);
% example 5: sphere; axis image; enlarge_axis;
end
%---------------------------------------------------------------------
if false

    cc
    figure;
    x=1:100; y=sqrt(x);
    subplot(2,2,1); semilogx(x,y); axis tight; title('original tight figure')
    subplot(2,2,2); semilogx(x,y); axis tight; title('figure enlarged by 10%');
    enlarge_axis(0.1,0.1);
    
    subplot(2,2,3); sphere; axis tight; title('original tight figure')
    subplot(2,2,4); sphere; axis tight; title('figure enlarged by 5%');
    enlarge_axis;


end
%=====================================================================
alpha=0.05;     % default increase of 5% in each axis
ax=axis;
if numel(ax)==4          % 2D case
   is_2D=1; alpha3=0;      
   ax=[ax 1 1];
   if nargin==0
      alpha1=alpha; alpha2=alpha;
   end
else                     % 3D case
    is_2D=0; 
    if nargin==0
      alpha1=alpha; alpha2=alpha; alpha3=alpha; 
    end
end
if strcmp(get(gca,'XScale'),'log')     
    ax(1)=log10(ax(1));
    ax(2)=log10(ax(2));    
end
if strcmp(get(gca,'YScale'),'log')     
    ax(3)=log10(ax(3));
    ax(4)=log10(ax(4));    
end
if strcmp(get(gca,'ZScale'),'log')     
    ax(5)=log10(ax(5));
    ax(6)=log10(ax(6));    
end
ax_new=ax*[[1+alpha1 -alpha1; -alpha1 1+alpha1], zeros(2), zeros(2); ...
           zeros(2), [1+alpha2 -alpha2; -alpha2 1+alpha2], zeros(2); ...
           zeros(2), zeros(2), [1+alpha3 -alpha3; -alpha3 1+alpha3]  ...
           ];
if strcmp(get(gca,'XScale'),'log')
    ax_new(1)=10^ax_new(1);
    ax_new(2)=10^ax_new(2);       
end
if strcmp(get(gca,'YScale'),'log')
    ax_new(3)=10^ax_new(3);
    ax_new(4)=10^ax_new(4);       
end
if strcmp(get(gca,'ZScale'),'log')
    ax_new(3)=10^ax_new(5);
    ax_new(4)=10^ax_new(6);       
end
if is_2D
   ax_new=ax_new(1:4);
end
axis(ax_new);
end


%% ----- from factdes.m -----------------------------------------------------
function desgn = factdes(fact,levl)
%FACTDES full factorial design of experiments.
%  Input (fact) is the number of factors in the design,
%  (levl) is the number of levels (default = 2). (desgn)
%  is the matrix of the experimental design. If levl=2
%  and fact=k then this gives a 2^k design. To obtain
%  a center point of zero (column means zeros) use
%  desgn = mncn(desgn);
%
%I/O: desgn = factdes(fact);
%  provides a full factorial two level design, and
%
%I/O: desgn = factdes(fact,levl);
%  provides a full factorial levl level design.
%
%See also: FFACDES1

%Copyright Eigenvector Research, Inc. 1996-98
%nbg

if nargin<2
  levl = 2;
end

nexp   = levl^fact;

desgn  = zeros(nexp,fact);
for ii = 1:nexp-1
  mexp   = ii;
  jj     = fact;
  while mexp > 0
    mnx  = mexp/levl;
	trn  = floor(mnx);
    desgn(ii+1,jj) = round((mnx-trn)*levl);
	mexp = trn;
	jj   = jj - 1;
  end 
end
end


%% ----- from fdir.m --------------------------------------------------------
function [clist_file_OR_subfolder_name,n]=fdir(path,sext,dispyes,filenamePrefix,inp)
%list and collect files with specified extension and path in cell format
% for list all files (non-directory) use sext='*'
% for list ONLY subfolders (directory) use sext='' or []
% can use wildcard(s) in filenamePrefix
% see also fdir_wildcard , genpath , findfiles , listfiles
% e.g. [clist_file_OR_subfolder_name,n]=fdir(pwd,'m',0,'fake*CH')
% e.g. [clist_file_OR_subfolder_name,n]=fdir(pwd,'m',0,'test*run*1217')
% can also use wildcard in sext
% e.g.  [clist_file_OR_subfolder_name,n]=fdir(pwd,'m*',0,'*')
%
% if path -> '' or [] -> get from current dir  (pwd)
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
% see also fdir_wildcard_ext_wPath



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normally sext should not include "." at begining, however if user include
% it, it will be removed !!!
% e.g. '.mat'  become 'mat'
if ~isempty(strfind(sext,'.')) && strfind(sext,'.')==1
    sext(1)=[];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%example: clear;path='D:\work\ARFCAM_TICs\PhaseI\rawdata_basecase\';sext='csv';[clist_file_OR_subfolder_name,n]=fdir(path,sext,1);
if exist('filenamePrefix')~=1
    filenamePrefix='';
end
fullpath_filename=[path,'\',filenamePrefix,'*.',sext]; 
fullpath_filename(findstr(fullpath_filename,'**.'))=[];; %can handle either with '*' or wo '*' at filenamePrefix

if fullpath_filename(1)=='\' & fullpath_filename(2)~='\'
    fullpath_filename(1)=[];
end


loc_2bs=findstr(fullpath_filename,'\\');
if ~isempty(loc_2bs) && loc_2bs>1
fullpath_filename(loc_2bs)=[];; %can handle either with '/' or wo '/' at the end of path
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
  extFiles= extFiles(find(arrayfun(@(x) x.isdir,extFiles)==1 &  arrayfun(@(x) NOT_single_NOR_double_dot(x.name),extFiles)==1 ));  %non-root directory

 
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clist_file_OR_subfolder_name = {extFiles.name}';
 
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
 if exist('inp','var') && isfield(inp,'fullpath_yes') && inp.fullpath_yes==1
   clist_file_OR_subfolder_name=cellfun(@(x) [path,'\',x],clist_file_OR_subfolder_name,'uniformoutput',false);
 end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function out=NOT_single_NOR_double_dot(x)
        if ~strcmp(x,'.') & ~strcmp(x,'..')
            out=1;
        else
            out=0;
        end
end
        
 
 
 


%% ----- from fdir_wPath.m --------------------------------------------------
function [clist_file_OR_subfolder_name_wPath,n]=fdir_wPath(Path,sext,dispyes,filenamePrefix)
% add Path to clist_file_OR_subfolder_name and become clist_file_OR_subfolder_name_wPath

[clist_file_OR_subfolder_name,n]=fdir(Path,sext,dispyes,filenamePrefix);
clist_file_OR_subfolder_name_wPath=cellfun(@(x) [Path,'\',x],clist_file_OR_subfolder_name,'uniformoutput',false);
end

 
 
 


%% ----- from fdir_wildcard.m -----------------------------------------------
function [clistfilename, nfile]=fdir_wildcard(targetPathname,keyword_inside_wildcards,inp)
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


%% ----- from fdir_wildcard_ext_wPath.m -------------------------------------
function [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(targetPathname,keyword_inside_wildcards,sext)
% this one should be the most useful one for finding files under a folder
% similar to fdir_wildcard_wPath, but user can specify filename ext
% similar to fdir but use wildcard to find all file with certain keywords
%-----------------------------------------------------------------------
% this one should be the most useful one for finding files under a folder
%------------------------------------------------------------------------
% see also fdir_wildcard_ext_woPath  fdir_wildcard_wPath  wfdir_wPath (alias) ,  fdir, fdir_wildcard, fdir_wPath
%  see also: example_recursiveDir
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% this one should be the most useful one to acquire files under a folder
% this one should be the most useful one to acquire files under a folder
%========================================================================

%======================================================================
if false
    
[clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath('C:\work\Ames\SVM_PLS\test_CAalgo\AmiSept9CL2','AmiSept9CL2','csv');
disp_cstr(clistfilename_out);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[clistfilename, nfile]=fdir_wildcard(targetPathname,keyword_inside_wildcards);

% clistfilename_wMatch_ext=clistfilename(cellfun(@(x) strcmp(x(end-length(sext):end),['.',sext]),clistfilename));

clistfilename_wMatch_ext=clistfilename(cellfun(@(x) ~isempty(strfind(x,['.',sext])),clistfilename));

clistfilename_out=cellfun(@(x) [targetPathname,'\',x],clistfilename_wMatch_ext,'uniformoutput',false);
nfile_out=length(clistfilename_out);
end


%% ----- from fdir_wildcard_wPath.m -----------------------------------------
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out=fdir_wildcard_wPath__isNOTParentFolders(x)

if ~strcmp(fileparts_name_ext(x),'.') && ~strcmp(fileparts_name_ext(x),'..')
    out=true;
else
    out=false;
    
end
end


%% ----- from fileparts_name_ext.m ------------------------------------------
function filename= fileparts_name_ext(file)
% modified by Chang to handle the case when file is cell of str
% June 24, 2016
if iscell(file)
    cfilename=[];
    for ifile=1:length(file)
        [PATHSTR,NAME,EXT]=fileparts(file{ifile});
        cfilename=[cfilename;{[NAME,EXT]}];
    end
    filename=cfilename;
    
elseif ischar(file)
    [PATHSTR,NAME,EXT]=fileparts(file);
    filename=[NAME,EXT];
    
else
    error('input file should be cell of str or str')
end
end


%% ----- from fileparts_name_wo_ext.m ---------------------------------------
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


%% ----- from find_all_zeros_col_idx.m --------------------------------------
function out=find_all_zeros_col_idx(A)
if false
    
    cc
    L=load('C:\work\JDSU\Test_AQP_PowerUser\AT_diagnose_PP1-{PRO}_NarrowMstWVL\wSNV{PRO}\Atrainpketc_(woCabXfer_pp1-1stDerSGFL7[PO2]{PRO}_pp2-SNV{PRO}_CS&Val_for-AAQP)_nvar112_ncls44_nsampT102_nsampP102.mat');
    out=find_all_zeros_col_idx(L.Atrainpk)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=sum(abs(A))==0;
end


%% ----- from find_belong2subgrp.m ------------------------------------------
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
% idx_match=[];


%% ----- from find_belong2subgrp_cstr.m -------------------------------------
function [all_loc_subgrp , all_idx_subgrp]=find_belong2subgrp_cstr(listall,subgrp)
%find the locations of all char vector  in listall belong to subgrp
% see also is_belong2subgrp_cstr find_belong2subgrp is_belong2subgrp

if false
    
    listall={'ab','bc','cd','de','efg','gh'};
    subgrp={'cd','efg'};
    t=find_belong2subgrp_cstr(listall,subgrp)
    t(1)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_idx_subgrp=cellfun(@(x) ~isempty(find(strcmp(x,subgrp))),  listall);
all_loc_subgrp=find(all_idx_subgrp);
end


% 
% if ~isempty(subgrp)
% 
% [rn cn]=size(listall);
% all_loc_subgrp=[];
% for sgi=row_vector_ALWAYS(unique(subgrp))
%     loc_sgi=find(listall==sgi);
%     
%   if rn>=cn
%     all_loc_subgrp=[all_loc_subgrp;loc_sgi ];  
%   else
%     all_loc_subgrp=[all_loc_subgrp,loc_sgi ];    
%   end
% 
% end
% all_loc_subgrp=sort(all_loc_subgrp);
% 
% else
%  all_loc_subgrp=[];   
%     
% end


%% ----- from find_keynumber_numeric_AFTER_marker.m -------------------------
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


%% ----- from find_keyword_between_markers.m --------------------------------
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
 
 
 
 
 
 


%% ----- from find_keyword_between_markers_cstr.m ---------------------------
function out=find_keyword_between_markers_cstr(targetstring,marker1,marker2)
% handle cases that targetstring is cstr or cell of characters vectors
% out is same datatype as input (i.e. targetstring)
% while find_keyword_between_markers can only handle single entry of input ( targetstring )
% 
% See also : find_keyword_between_markers textual_extractBetween textual_replaceBetween strrep_keyword_between_markers  find_keyword_numeric_AFTER_marker find_keynumber_numeric_AFTER_marker  strtok allwords find_keyword_between_markers_wWildCards
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
if false
    
    skeyword=find_keyword_between_markers_cstr('F:\work\U202\ETOX flag\Results','\',' flag\')
    %%%%%%%%%%%%
    skeyword=find_keyword_between_markers_cstr({'F:\work\U202\ETOX flag\Results'},'\',' flag\')
    %%%%%%%%%%%%%%
    cstr=[{'F:\work\U202\ATOX flag\Results'};{'F:\work\U202\BBTOX flag\Results'};{'F:\work\U202\CCCTOX flag\Results'}];
        out=find_keyword_between_markers_cstr(cstr,'\',' flag\')

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ischar(targetstring)
    out=find_keyword_between_markers(targetstring,marker1,marker2);
elseif iscell(targetstring)
    
    out=cellfun(@(x) find_keyword_between_markers(x,marker1,marker2),targetstring,'un',0);
    
else
    error('can not handle this kind of datatype')
end
 
 
 return;
end
 

 
 
 
 
 


%% ----- from find_keyword_between_markers_lastMarker2.m --------------------
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

 
 
 
 
 


%% ----- from find_keyword_between_markers_wlistRHS.m -----------------------
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


%% ----- from find_keyword_between_markers_wlistRHS_cstr.m ------------------
function keyword_final=find_keyword_between_markers_wlistRHS_cstr(targetstring,marker1,clistmarker2 )
% deal with when targetstring iscell, Apr 28, 2024
% see also: parse_xPDS_xU_from_U2U_folder, Apr 28, 2024
%-------------------------------------------------------
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
    
    find_keyword_between_markers_wlistRHS_cstr('afdaf_E1-00176 000_abd.mat','_E1-',{'_',' '} )
    
    find_keyword_between_markers_wlistRHS_cstr('afdaf_E1-00176 000_abd.mat','_E1-',{' ','_'} )
    
    find_keyword_between_markers_wlistRHS_cstr('afdaf_E1-00176.mat','_E1-',{' ','_'} )
    
    find_keyword_between_markers_wlistRHS_cstr('afdaf_E1-00176.mat','_E1-',{' ','','_'} )
    
    find_keyword_between_markers_wlistRHS_cstr('afdaf_E1-00176.mat','_E1-',{' ',''} )
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(targetstring)
    keyword_final=cellfun(@(x) find_keyword_between_markers_wlistRHS(x ,marker1,clistmarker2),targetstring,'un',0);
elseif ischar( targetstring)
    keyword_final=find_keyword_between_markers_wlistRHS(targetstring,marker1,clistmarker2 );
else
    error('can not support this targetstring''s datatype');
end
end
%================================================================


%% ----- from find_keyword_merge_dual_curly_bracket.m -----------------------
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ----- from find_keyword_numeric_AFTER_marker.m ---------------------------
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


%% ----- from find_keyword_numeric_AFTER_marker_cstr.m ----------------------
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out=str2num_empty2NaN(x,T1,T2)
out=str2num(x(T1:T2));
if isempty(out)
    out=NaN;
end
end


%% ----- from find_keyword_numeric_between_markers_cstr.m -------------------
function out=find_keyword_numeric_between_markers_cstr(targetstring,marker1,marker2)
% handle cases that targetstring is cstr or cell of characters vectors
% out will be array (not cell) for cell targetstring !!!
% if can not convert keyword (char) to numeric then output NaN (not empty)
% See also : find_keyword_between_markers textual_extractBetween textual_replaceBetween strrep_keyword_between_markers  find_keyword_numeric_AFTER_marker find_keynumber_numeric_AFTER_marker  strtok allwords find_keyword_between_markers_wWildCards
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
if false
    
    skeyword=find_keyword_numeric_between_markers_cstr('F:\work\U202\234flag\Results','\','flag\')
    %%%%%%%%%%%%%
    skeyword=find_keyword_numeric_between_markers_cstr('F:\work\U202\2o3flag\Results','\','flag\')
       %%%%%%%%%%%%%
    skeyword=find_keyword_numeric_between_markers_cstr('F:\work\U202\2o3flag\Results','\',' flag\')
    %%%%%%%%%%%%
    skeyword=find_keyword_numeric_between_markers_cstr({'F:\work\U202\ETOX flag\Results'},'\',' flag\')
    %%%%%%%%%%%%%%
    cstr=[{'F:\work\U202\123flag\Results'};{'F:\work\U202\23flag\Results'};{'F:\work\U202\6666flag\Results'}];
        out=find_keyword_numeric_between_markers_cstr(cstr,'\','flag\')
    %%%%%%%%%%%%%%
    cstr=[{'F:\work\U202\123Flag\Results'};{'F:\work\U202\23flag\Results'};{'F:\work\U202\66f6flag\Results'}];
        out=find_keyword_numeric_between_markers_cstr(cstr,'\','flag\')

        %%%%%%%%%%%%%%
    cstr=[{'F:\work\U202\123Flag\Results246'};{'F:\work\U202\23flag\Results34r'};{'F:\work\U202\66f6flag\Results\'}];
        out=find_keyword_numeric_between_markers_cstr(cstr,'\Results','')
    
        
        
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ischar(targetstring)
    
    out1=find_keyword_between_markers(targetstring,marker1,marker2);
    if isempty(out1)
        out=NaN;
    else
        out=str2num(out1);
        if isempty(out)
            out=NaN;
        end
    end
    
elseif iscell(targetstring)
    
    out=cellfun(@(x) fkn(x,marker1,marker2),targetstring);
    
else
    error('can not handle this kind of datatype')
end
end
 
 
%  return;
 
    function out=fkn(x,marker1,marker2)
        
        out1=find_keyword_between_markers(x,marker1,marker2);
        if isempty(out1)
            out=NaN;
        else
            out=str2num(out1);
            if isempty(out)
                out=NaN;
            end
        end
end
 
 
 


%% ----- from find_last_nonTMP_path.m ---------------------------------------
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


%% ----- from find_lastfolder.m ---------------------------------------------
function lastfolder=find_lastfolder(pathname)
% e.g.
% pathname='G:\work\LACIS-III\G3_allr\allr_U3tset\Load-T-Dir_U3_LACIS-IIIa-G3';lastfolder=find_lastfolder(pathname)
% e.g. replace(lastfolder,'-','_');
if ischar(pathname)
    
    all_bs=find(pathname=='\');
    if length(all_bs)>0
        lastfolder=pathname(all_bs(end)+1:end);
    else
        lastfolder=pathname;
    end
    
elseif iscell(pathname)
    
    lastfolder=cellfun(@(x) find_lastfolder(x),pathname,'uniformoutput',false);
    
    
    
else
    error('datatype of pathname not supported');
    
end
end


%% ----- from findseq.m -----------------------------------------------------
function varargout = findseq(A,dim)
%------------------------------------------------------
% use --> findseq_cstr_unique_count_appear_order !!!
% that can deal with single repeat cases & can handle both cstr or numeric array !!!, June 21, 2023
%---------------------------------------------------------
% FINDSEQ Find sequences of repeated (adjacent/consecutive) numeric values
%
%   FINDSEQ(A) Find sequences of repeated numeric values in A along the
%              first non-singleton dimension. A should be numeric.
%
%   FINDSEQ(...,DIM) Look for sequences along the dimension specified by the 
%                    positive integer scalar DIM.
%
%   OUT = findseq(...)
%       OUT is a "m by 4" numeric matrix where m is the number of sequences found.
%       
%       Each sequence has 4 columns where:
%           - 1st col.:  the value being repeated
%           - 2nd col.:  the position of the first value of the sequence
%           - 3rd col.:  the position of the last value of the sequence
%           - 4th col.:  the length of the sequence
%       
%   [VALUES, INPOS, FIPOS, LEN] = findseq(...)
%       Get OUT as separate outputs. 
%
%       If no sequences are found no value is returned.
%       To convert positions into subs/coordinates use IND2SUB
%
% 
% Examples:
%
%     % There are sequences of 20s, 1s and NaNs (column-wise)
%     A   =  [  20,  19,   3,   2, NaN, NaN
%               20,  23,   1,   1,   1, NaN
%               20,   7,   7, NaN,   1, NaN]
%
%     OUT = findseq(A)
%     OUT =  
%            20        1          3        3
%             1       14         15        2
%           NaN       16         18        3
%     
%     % 3D sequences: NaN, 6 and 0
%     A        = [  1, 4
%                 NaN, 5
%                   3, 6];
%     A(:,:,2) = [  0, 0
%                 NaN, 0
%                   0, 6];
%     A(:,:,3) = [  1, 0
%                   2, 5
%                   3, 6];
%     
%     OUT = findseq(A,3)
%     OUT = 
%             6     6    18     3
%             0    10    16     2
%           NaN     2     8     2
%
% Additional features:
% - <a href="matlab: web('http://www.mathworks.com/matlabcentral/fileexchange/28113','-browser')">FEX findseq page</a>
% - <a href="matlab: web('http://www.mathworks.com/matlabcentral/fileexchange/6436','-browser')">FEX rude by us page</a>
%
% See also: findseq_cstr DIFF, FIND, SUB2IND, IND2SUB
% see also: groupFcn, group1s, groupConsec
%------------------------------------------------------

% Author: Oleg Komarov (oleg.komarov@hotmail.it) 
% Tested on R14SP3 (7.1) and on R2012a. In-between compatibility is assumed.
% 02 jul 2010 - Created
% 05 jul 2010 - Reorganized code and fixed bug when concatenating results
% 12 jul 2010 - Per Xiaohu's suggestion fixed bug in output dimensions when A is row vector
% 26 aug 2010 - Cast double on logical instead of single
% 28 aug 2010 - Per Zachary Danziger's suggestion reorganized check structure to avoid bug when concatenating results
% 22 mar 2012 - Per Herbert Gsenger's suggestion fixed bug in matching initial and final positions; minor change to distribution of OUT if multiple outputs; added 3D example 
% 08 nov 2013 - Fixed major bug in the sorting of Final position that relied on regularity conditions not always verified

% NINPUTS
% error(nargchk(1,2,nargin));
narginchk(1,2);

% NOUTPUTS
error(nargoutchk(0,4,nargout));

% IN
if ~isnumeric(A)
    error('findseq:fmtA', 'A should be numeric')
elseif isempty(A) || isscalar(A)
    varargout{1} = [];
    return
elseif islogical(A)
    A = double(A);
end

% DIM
szA = size(A);
if nargin == 1 || isempty(dim)
    % First non singleton dimension
    dim = find(szA ~= 1,1,'first');
elseif ~(isnumeric(dim) && dim > 0 && rem(dim,1) == 0) || dim > numel(szA)
    error('findseq:fmtDim', 'DIM should be a scalar positive integer <= ndims(A)');
end

% Less than two elements along DIM
if szA(dim) == 1
    varargout{1} = [];
    return
end

% ISVECTOR
if nnz(szA ~= 1) == 1
    A = A(:);
    dim = 1;
    szA = size(A);
end

% Detect 0, NaN, Inf and -Inf
OtherValues    = cell(1,4);
OtherValues{1} = A ==    0;
OtherValues{2} = isnan(A) ;
OtherValues{3} = A ==  Inf;
OtherValues{4} = A == -Inf;
Values         = [0,NaN, Inf,-Inf];

% Remove zeros
A(OtherValues{1}) = NaN;                             

% Make the bread
bread = NaN([szA(1:dim-1),1,szA(dim+1:end)]);

% [1] Get chunks of "normal" values
Out = mainengine(A,bread,dim,szA);

% [2] Get chunks of 0, NaN, Inf and -Inf
for c = 1:4
    if nnz(OtherValues{c}) > 1
        % Logical to double and NaN padding
        OtherValues{c} = double(OtherValues{c});                        
        OtherValues{c}(~OtherValues{c}) = NaN;                          
        % Call mainengine and concatenate results
        tmp = mainengine(OtherValues{c}, bread,dim,szA);
        if ~isempty(tmp)
            Out = [Out; [repmat(Values(c),size(tmp,1),1) tmp(:,2:end)]];  %#ok
        end
    end
end

% Distribute output
if nargout < 2 
    varargout = {Out};
else
    varargout = num2cell(Out(:,1:nargout),1);
end

end

% MAINENGINE This functions uses run length encoding and retrieve positions 
function Out = mainengine(meat,bread,dim,szMeat)

% Make a sandwich  
sandwich    = cat(dim, bread, meat, bread);

% Find chunks (run length encoding engine)
IDX         = diff(diff(sandwich,[],dim) == 0,[],dim);

% Initial and final row/col subscripts
[rIn, cIn]  = find(IDX  ==  1);
[rFi, cFi]  = find(IDX  == -1);

% Make sure row/col subs correspond (relevant if dim > 1)
[In, idx]   = sortrows([rIn, cIn],1);
Fi          = [rFi, cFi];
Fi          = Fi(idx,:);

% Calculate length of blocks
if dim < 3
    Le = Fi(:,dim) - In(:,dim) + 1;
else
    md = prod(szMeat(2:dim-1));
    Le = (Fi(:,2) - In(:,2))/md + 1;
end

% Convert to linear index
InPos       = sub2ind(szMeat,In(:,1),In(:,2));
FiPos       = sub2ind(szMeat,Fi(:,1),Fi(:,2));

% Assign output
Out         = [meat(InPos),...    % Values
               InPos      ,...    % Initial positions 
               FiPos      ,...    % Final   positions
               Le         ];      % Length of the blocks
end


%% ----- from fix_underscore.m ----------------------------------------------
function str_new=fix_underscore(str_orig)
% fix the underscore artifact for string or cell of strings
% e.g. str=fix_underscore('test_1_2_3.mat');figure;title(str);
% e.g. str=fix_underscore({'test_1_2_3.mat';'TEST_2nd_line'});figure;title(str);
% e.g. str=fix_underscore({'test_1_2_3.mat','TEST_2nd_line'});figure;title(str);

% alias of bs4us.m
% use the following formula:  str=strrep(str,'_','\_');



if iscell( str_orig)

    for ic=1:length(str_orig)
        eastr_orig=str_orig{ic};

        eastr_new=strrep(eastr_orig,'_','\_');
        str_new{ic}=eastr_new;

    end
    
    %make sure cell of string keep same 'shape' (row or column)
    if size(str_new)~=size(str_orig)
        str_new=str_new';     
    end

else
    
    str_new=strrep(str_orig,'_','\_');
    
    

end
end


%% ----- from fix_underscore_cstr.m -----------------------------------------
function [str_new]=fix_underscore_cstr(str_orig);
% fix all underscore in a cell of strings: cstr or a single str
% e.g. cstr1={'ab_cd','101_23'};figure;text([.2 .3],[.5 .5],fix_underscore_cstr(cstr1));
% e.g. str1='ab_cd';figure;text([.2 ],[.5 ],fix_underscore_cstr(str1));


if iscell( str_orig)

    for ic=1:length(str_orig)
    eastr_orig=str_orig{ic};
    eastr_new=fix_underscore(eastr_orig);
    %eastr_new(find(eastr_orig=='_'))='-';
    str_new{ic}=eastr_new;
    end
if size(str_new)~=size(str_orig)
    str_new=str_new';
end
 
else
    str_new=str_orig;
     str_new=fix_underscore(str_orig);
    %str_new(find(str_orig=='_'))='-';

end
end


%% ----- from get_corename_pfn.m --------------------------------------------
function out=get_corename_pfn(pfn,sMk1,sMk2,inp)
% see also: consolidate_corename_2_pfn
%-------------------------------------------------------------
if false
    
    cc
    pfn= 'C:\work\JDSU\Test_ACP\DI_MLbl_23\uX-1\Atrainpketc_{T-N1-00136_RmCls-222304_P-S1-00589_RmCls-222304}_nvar119_ncls68_nsampT1063_nsampP1070.mat';
    sMk1='{';sMk2='}';
    out=get_corename_pfn(pfn,sMk1,sMk2)
    
    
end
%=============================================================================
if nargin==1
    sMk1='{';sMk2='}';
end

try
    if inp.sMk_yes
        out=[sMk1, find_keyword_between_markers(fileparts_name_ext(pfn),sMk1,sMk2),sMk2] ;
    else
        out=[find_keyword_between_markers(fileparts_name_ext(pfn),sMk1,sMk2)] ;   % set inp.sMk_yes --> 0
    end
catch
    out=[sMk1, find_keyword_between_markers(fileparts_name_ext(pfn),sMk1,sMk2),sMk2] ;
end
end

% done_with_this_function;


%% ----- from isSAME_2Matrix.m ----------------------------------------------
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


%% ----- from isSAME_2Matrix_regardless_sequence.m --------------------------
function out=isSAME_2Matrix_regardless_sequence(AT1,AT2)
% can handle with tol (by default set to 1e-10 now)
%------------------------------------------------------------------------------
%  updated to isSAME_or_PartialMatch_2Matrix_regardless_sequence, Feb 14,
%  2024
% see also isSAME_Tset, cmp_ATsaConc, merge_Pset_with_SameTset_in_XBPL,  ismember,  isequal,  isSAME_2Matrix 
% see also: isequaltol (Aug 31, 2023)
% see also: isSAME_or_PartialMatch_2Matrix_regardless_sequence
% see also:  ismembertol_ByRows
% see also: isequal_ismember_IsNear_related
%--------------------------------------------------------------------------------------
% [lia,locb]=ismembertol_ByRows(AT1,AT2,tol);            % new approach, July 25, 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    % same Tset (same Atrainpk and same clistclslabel)
    cc
    pathfname_AT1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_AT2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70.mat'
    L1=load(pathfname_AT1);
    L2=load(pathfname_AT2);
    out=isSAME_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk)
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % (same Atrainpk although different clistclslabel)
   
    cc
    pathfname_AT1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_AT2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\attic_different_in_clistclslabel\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70_SCls[1_2_3].mat'
    L1=load(pathfname_AT1);
    L2=load(pathfname_AT2);
    
    out=isSAME_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk)
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % slightly changed by Atrainpk(1,:)=Atrainpk(1,:)+0.0001;
    
    cc
    pathfname_AT1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_AT2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\attic_different_in_clistclslabel\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70_SCls[1_2_3]_slightly_changed_1stRow.mat'
    L1=load(pathfname_AT1);
    L2=load(pathfname_AT2);
    out=isSAME_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk)
 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % revisit June 17, 2025




end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [lia,locb]=ismember(AT1,AT2,'rows'); % old method
tol=1e-10;                                                                        % can handle with tol (by default set to 1e-10 now)
[lia,locb]=ismembertol_ByRows(AT1,AT2,tol);            % new approach, July 25, 2024
%+++++++++++++++++++++++++++++++++++++++++++++
if false
[mindev_1 locmin_1]=min(abs(mean(AT1-AT2(1,:),2)))

[mindev_100 locmin_100]=min(abs(mean(AT1-AT2(100,:),2)))
end


if length(lia)==length(locb) && length(AT1(:,1))==length(AT2(:,1))
    
    %     if isequal(unique(locb),col_always([1:length(AT1(:,1))])) && length(unique(lia))==1
    tol=1e-8;
    if isequaltol(unique(locb),col_always([1:length(AT1(:,1))]),tol) && length(unique(lia))==1
        
        disp('------------------------')
        disp('SAME contents in  two Atrainpk!!!')
        disp('------------------------')
        out=true;
    else
        loc_NotSAME_AT1= find(lia==0);
        if ~isempty(loc_NotSAME_AT1)
            disp('------------------------')
            disp('Location(s) in AT1 not matched:')
            loc_NotSAME_AT1;
            disp('------------------------')
        end
        loc_NotSAME_AT2= find(locb==0);
        if ~isempty(loc_NotSAME_AT2)
            disp('------------------------')
            disp('Location(s) in AT2 not matched:')
            loc_NotSAME_AT2;
            disp('------------------------')
        end
        disp('contents in  two Atrainpk are not the SAME');
        out=false;
    end
else
    disp('size of two Atrainpk are not the SAME')
    out=false;
end
end
    


%% ----- from isSAME_Tset.m -------------------------------------------------
function out=isSAME_Tset(pathfname_AT1,pathfname_AT2)
% check to see if two Atrainpk are the SAME regardless seq 
% by calling --> isSAME_2Matrix_regardless_sequence
% and also if clistclslabel are the SAME (including seq)
%-----------------------------------------------------------------------
% see also  cmp_ATsaConc,  isSAME_2Matrix_regardless_sequence,    merge_Pset_with_SameTset_in_XBPL,  ismember, isSAME_2Matrix, isequal
% see also: prep_Rm_OLs_BasedOn_misP_Plastics_Recycle (Aug 31, 2023)
% see also: isequaltol (Aug 31, 2023)
%----------------------------------------------
% see also: isSAME_or_PartialMatch_2Matrix_regardless_sequence (created Feb 14, 2024)
%
%====================================================================
if false
    
    clear
    pathfname_AT1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_AT2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70.mat'
    out=isSAME_Tset(pathfname_AT1,pathfname_AT2)
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
    clear
    pathfname_AT1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_AT2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\attic_different_in_clistclslabel\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70_SCls[1_2_3].mat'
    out=isSAME_Tset(pathfname_AT1,pathfname_AT2)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % for HFA MCH AT files
%     pathfname_AT1= 'C:\work\JDSU\HFA-BP\Test_HFA_SCH2MCH\S001\S001_SCH_MCH_AT\Atrainpketc_HBpro_HFP_Systolic_S001_MCH_RawPPG_{BLC=CL}_pp1-1stDerSGFL7[PO2]_ncls2_nsamp123.mat'
%     pathfname_AT1='C:\work\JDSU\HFA-BP\Test_HFA_SCH2MCH\S002\S002_SCH_MCH_AT\Atrainpketc_HBpro_HFP_Systolic_S002_MCH_RawPPG_{BLC=CL}_pp1-1stDerSGFL7[PO2]_ncls2_nsamp34.mat'
     pathfname_AT1='C:\work\JDSU\HFA-BP\Test_HFA_SCH2MCH\S004\S004_SCH_MCH_AT\Atrainpketc_HBpro_HFP_Systolic_S004_MCH_RawPPG_{BLC=CL}_pp1-1stDerSGFL7[PO2]_ncls2_nsamp30.mat'
 %   pathfname_AT1='C:\work\JDSU\HFA-BP\Test_HFA_SCH2MCH\S008\S008_SCH_MCH_AT\Atrainpketc_HBpro_HFP_Systolic_S008_MCH_RawPPG_{BLC=CL}_pp1-1stDerSGFL7[PO2]_ncls2_nsamp40.mat'
%%%%
%     pathfname_AT2='Atrainpketc_HBpro_HFP_Systolic_S008_MCH_RawPPG_{BLC=CL}_pp1-1stDerSGFL7[PO2]_ncls2_nsamp40_R2thresTop10_nvar7-9.mat'
   pathfname_AT2= 'Atrainpketc_HBpro_HFP_Systolic_S004_MCH_RawPPG_{BLC=CL}_pp1-1stDerSGFL7[PO2]_ncls2_nsamp30_R2thresTop10_nvar8-8.mat'
    out=isSAME_Tset(pathfname_AT1,pathfname_AT2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 cc
    pathfname_AT1= 'C:\work\JDSU\HFA-BP\Test_HFA_SCH2MCH\allS_MCH\Atrainpketc_{[S001_MCH][S002_MCH][S004_MCH][S008_MCH]}_nvar75_ncls8_nsamp227.mat'
  pathfname_AT2='C:\work\JDSU\HFA-BP\Test_HFA_SCH2MCH\allS_MCH\Atrainpketc_{[S001_MCH][S002_MCH][S004_MCH][S008_MCH]_R2thresTop10}_nvar75_ncls8_nsamp227.mat'
     out=isSAME_Tset(pathfname_AT1,pathfname_AT2)
     
     
     
end
%======================================================================================
%=======================================================================================

if ischar( pathfname_AT1)
    L1=load(pathfname_AT1);
elseif isstruct( pathfname_AT1)
    L1= pathfname_AT1;
end

if ischar( pathfname_AT2)
    L2=load(pathfname_AT2);
elseif isstruct( pathfname_AT2)
    L2= pathfname_AT2;
end

%checking
if isequal(L1.clistclslabel,L2.clistclslabel)    % and also if clistclslabel are the SAME (including seq)

    disp('------------------------')
    disp('SAME clistclslabel !!!')
    disp('------------------------')
    
    out=isSAME_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk);

    
else
    disp('clistclslabel are different');
    out=false;
end

disp('done checking isSAME_Tset')
end


%% ----- from isSAME_or_PartialMatch_2Matrix_regardless_sequence.m ----------
function out=isSAME_or_PartialMatch_2Matrix_regardless_sequence(AT1,AT2)
%  created Feb 14, 2024
% this will deal with partial Matched, Feb 14, 2024
% modified from isSAME_2Matrix_regardless_sequence
% see also: prep_add_N6_N66_TO_Big7_reAssemble
%----------------------------------------------------------------
% see also isSAME_Tset, cmp_ATsaConc, merge_Pset_with_SameTset_in_XBPL,  ismember,  isequal,  isSAME_2Matrix 
% see also: isequaltol (Aug 31, 2023)
% see also: isSAME_2Matrix_regardless_sequence
%------------------------------------------------------------------------
% this will deal with partial Matched, Feb 14, 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % created Feb 14, 2024
    % test when the two are identical
    cc
    pathfname_AT1='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat';
    pathfname_AT2='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat';
    L1=load(pathfname_AT1);
    L2=load(pathfname_AT2);
    out=isSAME_or_PartialMatch_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % created Feb 14, 2024
    % test when the two are completely different
    cc
    pathfname_AT1='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat';
    pathfname_AT2='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_DM-5Powders\Atrainpketc_{T-DM-5Powders_sortTcls}_nvar119_ncls5_nsamp110.mat';
    L1=load(pathfname_AT1);
    L2=load(pathfname_AT2);
    out=isSAME_or_PartialMatch_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % created Feb 14, 2024
    % test when the two are Partially Matched
    cc
    pathfname_AT1='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat';
    pathfname_AT2='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(RK)}_nvar119_ncls9_nsampT694_nsampP620.mat';
    L1=load(pathfname_AT1);
    L2=load(pathfname_AT2);
    out=isSAME_or_PartialMatch_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk);
    
    %==============================================================
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lia,locb]=ismember(AT1,AT2,'rows');

if length(lia)==length(locb) && length(AT1(:,1))==length(AT2(:,1))
    
    %     if isequal(unique(locb),col_always([1:length(AT1(:,1))])) && length(unique(lia))==1
    tol=1e-12;
    if isequaltol(unique(locb),col_always([1:length(AT1(:,1))]),tol) && length(unique(lia))==1
        
        disp('------------------------')
        disp('SAME contents in  two Atrainpk!!!')
        disp('------------------------')
        out=true;
    else
        loc_NotSAME_AT1= find(lia==0);
        if ~isempty(loc_NotSAME_AT1)
            disp('------------------------')
            disp('Location(s) in AT1 not matched:')
            loc_NotSAME_AT1;
            disp('------------------------')
        end
        loc_NotSAME_AT2= find(locb==0);
        if ~isempty(loc_NotSAME_AT2)
            disp('------------------------')
            disp('Location(s) in AT2 not matched:')
            loc_NotSAME_AT2;
            disp('------------------------')
        end
        disp('contents in  two Atrainpk are not the SAME');
        %         out=false;
        out.loc_NotSAME_AT1=loc_NotSAME_AT1;
        out.loc_NotSAME_AT2=loc_NotSAME_AT2;
    end
    
elseif    length(AT1(:,1))~=length(AT2(:,1))   % this will deal with partial Matched, Feb 14, 2024
    
    disp('deal with partial Matched');  % this will deal with partial Matched, Feb 14, 2024
    [lia_1,locb_1]=ismember(AT1,AT2,'rows');
    [lia_2,locb_2]=ismember(AT2,AT1,'rows');
    loc_NotSAME_AT1= find(lia_1==0);
    loc_SAME_AT1= find(lia_1==1);
    loc_NotSAME_AT2= find(lia_2==0);
    loc_SAME_AT2= find(lia_2==1);
    
    if  ~isempty( loc_SAME_AT1) || ~isempty( loc_SAME_AT2)
        if length(loc_SAME_AT1)==length(loc_SAME_AT2)
            disp_with_border(['number of overlapped row(s) = ',num2str(length(loc_SAME_AT1))]);
        else
            error('somehow number of overlapped rows between the two AT are different ?');
        end
        out.loc_SAME_AT1=loc_SAME_AT1;
        out.loc_SAME_AT2=loc_SAME_AT2;
        out.loc_NotSAME_AT1=loc_NotSAME_AT1;
        out.loc_NotSAME_AT2=loc_NotSAME_AT2;
    else
        disp('size of two Atrainpk are not the SAME and there is no overlap of the two either')
        out=false;
    end
    
end
end
    


%% ----- from isSAME_two_cstr.m ---------------------------------------------
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


%% ----- from isSame_AclabelT_SampleName.m ----------------------------------
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
%--------------------------------------------------------------------------


%% ----- from is_autoscale.m ------------------------------------------------
function out=is_autoscale(L)

if isequaltol(std(L.Atrainpk),ones([1 length(L.Atrainpk(1,:))]))
    out=true;
else
    out=false;
end
end


%% ----- from is_odd.m ------------------------------------------------------
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
% if out~=1
%     out=false;
% else
%     out=true;
% end


%% ----- from isequaltol.m --------------------------------------------------
function eqFlag = isequaltol(A, B, tol, eqNaN, onlyNum, chkInput)
%================================================
% this can also be used to compare two struct !!!
% see also --> dvABC_insituThres_FOM_GlobalModel
% Mar 17, 2023
%================================================
% this seems better than IsNear or IsNear_2AT
% add this Feb 18, 2023
%===================================================
% isequaltol(A, B, tol, eqnan, onlynum)
%
% Like the MATLAB built-in functions "isequal" and "isequaln" this function is
% used to determine if two variables A and B are equal. But here two floating
% point numbers are considered equal if the difference is less than a set
% tolerance.
%
% INPUT:
% A, B    - any type of MATLAB arrays.
% tol     - an optional tolerance used to determine if two floating point
%           numbers are considered equal. Can be scalar with the tolerance for
%           double precision numbers (default 1e-6 used for single precision) or
%           a two-element vector with tolerances for single and double precision
%           numbers. If not supplied set to [1e-6, 1e-12].
% eqnan   - an optional logical flag indicating if NaN are considered equal. If
%           not supplied set to true.
% onlynum - an optional logical flag indicating if non-numerical data, such as
%           strings, can be different. If not supplied set to false. 
%
% OUTPUT:
% Returns a logical that is set to true if A and B are equal within the given
% tolerances and false otherwise.
%
% NOTE:
% The program recursively checks cell and structure arrays and might be slow if
% they are very large.
%
% EXAMPLES:
if false
    clear
    isequal(1, 1+eps)
    isequaltol(1, 1+eps)
    %------------------------------------------
    A = rand(100, 100);
    B = log10(10.^A);
    isequal(A, B)
    isequaltol(A, B)
    %-------------------------------------------
    % note that this even works for data in a field of struct
    C.data = {sparse(A(A < 0.5) + 1i*A(A < 0.5))};
    D.data = {sparse(B(B < 0.5) + 1i*B(B < 0.5))};
    isequal(C, D)
    isequaltol(C, D)
    %--------------------------------------------------------
    % test for datasets used for DI_MLbl_23
    cc
    Lfp=load('C:\work\JDSU\Test_ACP\DI_MLbl_23\uX-1\RK_as_FalsePos_rk-145\Atrainpketc_{T-OS-145-rk5145}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls46_nsamp1416.mat')
    load('C:\work\JDSU\Test_ACP\DI_MLbl_23\uX-1\FalsePos-Prk-145\Atrainpketc_{T-N1-00136_RmCls-222304_Prk-145}_nvar119_ncls68_nsampT1063_nsampP1416.mat')
    
    isequaltol(Apred,Lfp.Atrainpk)
    isequaltol(Apred,Lfp.Atrainpk,1e-13)
    isequaltol(Apred,Lfp.Atrainpk,1e-14)
    
end
%==================================================================
% Author      : Patrik Forssén, Karlstad University
% Release     : 1.2
% Release date: Feb 2023
%
% See also isequal, isequaln, ismembertol.
% VERSION HISTORY
% 1.0.0 First release
% 1.0.1 Fixed skip non-numeric test
% 1.1.0 Fixed numeric test and added support for tables
% 1.1.1 Corrected for column and row vectors with same number of elements
% 1.2   Fixed numeric test
 
% Default input
if (nargin < 3 || isempty(tol))     , tol      = [1e-6, 1e-12]; end
if (nargin < 4 || isempty(eqNaN))   , eqNaN    = true         ; end
if (nargin < 5 || isempty(onlyNum)) , onlyNum  = false        ; end
% For internal use!
if (nargin < 6 || isempty(chkInput)), chkInput = true         ; end
 
% Check inputs (only has to be done once!)
if (chkInput)
  % tol
  if (~isvector(tol)  || ~isnumeric(tol) || ~isreal(tol) || ...
      length(tol) < 1 || length(tol) > 2 || min(tol) <= 0)
    error('isequaltol:ToleranceIncorrect', ['The input tolerance must be ', ...
      'a real scalar or a two-element vector > 0']) 
  end
  % Use default for single precision?
  if (length(tol) == 1), tol = [1e-6, tol]; end
  
  % eqNaN
  if (~isscalar(eqNaN) || (~isequal(eqNaN, false) && ~isequal(eqNaN, true)))
    error('isequaltol:EqualNaNIncorrect', ['The input equal NaN flag ', ...
      'must be a scalar logical or 0/1'])
  end
  
  % onlyNum
  if (~isscalar(onlyNum) || (~isequal(onlyNum, false) && ...
      ~isequal(onlyNum, true)))
    error('isequaltol:OnlyNumericIncorrect', ['The input only numeric ', ...
      'data flag must be a scalar logical or 0/1'])
  end
end
  
% Both numeric/logical arrays?
if ((isnumeric(A) || islogical(A)) && (isnumeric(B) || islogical(B)))
  if (isfloat(A) || isfloat(B))
    % Make sure both are floating point arrays
    if (~isfloat(A)), A = cast(A, class(B)); end
    if (~isfloat(B)), B = cast(B, class(A)); end
    % Check if they are equal with tolerance
    eqFlag = eqFloatTol(A, B, tol, eqNaN);
  else
    % Let "isequal" or "isequaln" handle it
    if (~eqNaN)
      eqFlag = isequal( A, B);
    else
      eqFlag = isequaln(A, B);
    end
  end
  return
end
% Convert tables to cell arrays
if (istable(A)), A = table2cell(A); end
if (istable(B)), B = table2cell(B); end
 
% Both cell arrays?
if (iscell(A) && iscell(B))
  % Check if dimensions match
  if (~isequal(size(A), size(B)))
    % Row and column vectors with the same number of elements should be checked
    if (~(isvector(A) && isvector(B) && numel(A) == numel(B)))
      eqFlag = false;
      return
    end
  end
  % Must check elements recursively
  eqFlag = true;
  for elemNo = 1 : numel(A)
    eqFlag = isequaltol(A{elemNo}, B{elemNo}, tol, eqNaN, onlyNum, false);
    if (~eqFlag), return, end
  end
  return
end
 
% Both struct arrays?
if (isstruct(A) && isstruct(B))
  % Check if dimensions match
  if (~isequal(size(A), size(B)))
    eqFlag = false;
    return
  end
  % Check if fieldnames match
  AFields = fieldnames(A);
  BFields = fieldnames(B);
  if (~isempty(setxor(AFields, BFields)))
    eqFlag = false;
    return
  end
  % Must check fields recursively
  eqFlag = true;
  for elemNo = 1 : numel(A)
    for fieldNo = 1 : length(AFields)
      ATmp   = A(elemNo).(AFields{fieldNo});
      BTmp   = B(elemNo).(AFields{fieldNo});
      eqFlag = isequaltol(ATmp, BTmp, tol, eqNaN, onlyNum, false);
      if (~eqFlag), return, end
    end
  end
  return
end
 
% Check also non-numeric data?
if (~onlyNum)
  % Let "isequal" or "isequaln" handle it!
  if (~eqNaN)
    eqFlag = isequal( A, B);
  else
    eqFlag = isequaln(A, B);
  end
else
  if (iscell(A) || isstruct(A) || isnumeric(A) || islogical(A) || ...
      iscell(B) || isstruct(B) || isnumeric(B) || islogical(B))
    % Not both are non-numeric data items
    eqFlag = false;
  else
    eqFlag = true;
  end
end
 
end
 
 
 
function eqFlag = eqFloatTol(A, B, tol, eqNaN)
 
% Check if dimensions match
if (~isequal(size(A), size(B)))
  % Row and column vectors with the same number of elements should be checked
  if (~(isvector(A) && isvector(B) && numel(A) == numel(B)))
    eqFlag = false;
    return
  end
end
 
% Sparse matrices?
if (issparse(A) && issparse(B))
  % Check if number of nonzero elements is the same
  if (~isequal(nnz(A), nnz(B)))
    eqFlag = false;
    return
  end
  % Check that the locations of nonzero elements are the same
  ALinInd = find(A);
  BLinInd = find(B);
  if (~isequal(ALinInd, BLinInd))
    eqFlag = false;
    return
  end
  % Convert to full vectors
  A = full(A(ALinInd));
  B = full(A(ALinInd));
elseif (issparse(A))
  A = full(A);
elseif (issparse(B))
  B = full(B);
end
 
% Convert to vectors
A = A(:);
B = B(:);
 
% NaN equal?
A(isnan(A))   = 0;
if (eqNaN)
  B(isnan(B)) = 0;
else
  B(isnan(B)) = 1;
end
 
% Single or double precision?
currTol = tol(2);
if (isa(A, 'single') || isa(B, 'single')), currTol = tol(1); end
 
% Check
if (~isreal(A) || ~isreal(B))
  % Check real and imaginary parts
  eqFlag = all(abs(real(A) - real(B)) <= currTol);
  if (~eqFlag), return, end
  eqFlag = all(abs(imag(A) - imag(B)) <= currTol);
else
  eqFlag = all(abs(A - B) <= currTol);
end
 
end


%% ----- from ismember_by_rows.m --------------------------------------------
function [lia,locb, LocMatch] = ismember_by_rows(A,B)
% special case of ismember
% see also:      ismembertol_ByRows      is_belong2subgrp
if false
    
    cc
    L=load('C:\work\JDSU\Test_ML_UCP\effects_auto_BankMarketing\AT_BankMarket\Atrainpketc_BankMarketing_nsamp45211_num_asmc1.mat');
    LTP=load('C:\work\JDSU\Test_ML_UCP\datasets_mixed_attrib\BankMarketing\AT_etc\Atrainpketc_BankMarketing_nsampT40239_nsampP4972_num_asmc1_TP.mat');
 [lia,locb] = ismember_by_rows(LTP.Apred,L.Atrainpk);
 
isequal( L.Atrainpk(locb,:),LTP.Apred)
 %%%%%%%%%%%%%%%%%%%%%%%%%%
 
 [lia,locb] = ismember_by_rows(RawSpectra,t)
 
 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lia,locb] = ismember(A,B,'rows');

LocMatch.A2B=find(lia==1);
LocMatch.B2A=locb(LocMatch.A2B);

% check LocMatch
if ~isequal(A(LocMatch.A2B),B(LocMatch.B2A))
error('something wrong with LocMatch')
end
end


%% ----- from ismember_by_rows_wMatchLoc.m ----------------------------------
function [lia,locb, LocMatch] = ismember_by_rows_wMatchLoc(A,B)
% see also:  ismembertol_ByRows --> this maybe better !!
%-------------------------------------------------
% special case of ismember
% see also: ismember_wMatchLoc  ISMEMBERTOL
% revisit for finding out RawSpectra that removed certain outliers to form Atrainpk, Mar 6, 2023
%
% see also: isequal_ismember_IsNear_related
% see also: find_removed_outliers_in_RawSpectra_to_match_Atrainpk
%----------------------------------------------------------------
if false
    
    cc
    L=load('C:\work\JDSU\Test_ML_UCP\effects_auto_BankMarketing\AT_BankMarket\Atrainpketc_BankMarketing_nsamp45211_num_asmc1.mat');
    LTP=load('C:\work\JDSU\Test_ML_UCP\datasets_mixed_attrib\BankMarketing\AT_etc\Atrainpketc_BankMarketing_nsampT40239_nsampP4972_num_asmc1_TP.mat');
 [lia,locb, LocMatch] = ismember_by_rows_wMatchLoc( LTP.Apred  ,  L.Atrainpk );
 
 % check 
isequal(  LTP.Apred(LocMatch.A2B,:)  ,  L.Atrainpk(LocMatch.B2A,:)  )

 %%%%%%%%%%%%%%%%%%%%%%%%%%
 
%  [lia,locb, LocMatch] =ismember_by_rows_wMatchLoc(RawSpectra,t)
%==========================================================================
cc
pfn='C:\work\JDSU\Test_ACP\RK4NSEdemo\ATetc_Carpet_fVS\2ndBatch\Atrainpketc_{[T2_20230803_VS_TrainSet]_[T2_20230803_VS_PredSet]_Nrep4PDS5}_nvar119_ncls6_nsampT225_nsampP75.mat';
LTP=load(pfn)
  [lia,locb, LocMatch] = ismember_by_rows_wMatchLoc( LTP.Apred  ,  LTP.Atrainpk );
isequal(  LTP.Apred(LocMatch.A2B,:)  ,  LTP.Atrainpk(LocMatch.B2A,:)  )
%---
locRM=LocMatch.B2A;
%---
LTP.Atrainpk=delsamps(LTP.Atrainpk,locRM);
LTP.AclassinfoT=delsamps(LTP.AclassinfoT,locRM);
LTP.AclabelT=delsamps(LTP.AclabelT,locRM);
LTP.RawSpectra.Tset=delsamps(LTP.RawSpectra.Tset,locRM);
  [lia,locb, LocMatch] = ismember_by_rows_wMatchLoc( LTP.Apred  ,  LTP.Atrainpk );
sd1=ssds(LTP);
inp.corename=get_corename_pfn(pfn);
sd1.saveAT(inp);

%------------------------------------------------------------------------------------------
end % end of if false examples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lia,locb] = ismember(A,B,'rows');

LocMatch.A2B=find(lia==1);
LocMatch.B2A=locb(LocMatch.A2B);

% check LocMatch
if ~isequal(A(LocMatch.A2B,:),B(LocMatch.B2A,:))
error('something wrong with LocMatch')
end
end


%% ----- from ismembertol_ByRows.m ------------------------------------------
function [LIA,LOCB]=ismembertol_ByRows(a,b,tol)
% this is most important function inside "ismember" family
% show example of running ismembertol for comparing rows of matric with tol
% note that tol should be placed before "ByRows"
% see also strcmp_CI_two_cstr_deblank
%-----------------------------------------------------------------------------------------------------
% see for example of using this function--> find_removed_outliers_in_RawSpectra_to_match_Atrainpk
% Mar 7, 2023
%---------------------------------------------------------
% see also:  isSAME_2Matrix_regardless_sequence (July 25, 2024)
%-----------------------------------------------------------------------------------------------------

if false
    
    a=[1 1 4;2 1 4; 1 2 3 ;4 5 6];b=[0 1 0; 1 2.00001 3 ;2 2 40;8 8 8];
    tol=1e-3;
[LIA,LOCB]=ismembertol_ByRows(a,b,tol)

% a(LIA,:) same as -->  b(LOCB(LIA),:)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    a=[1 1 4;2 1 4; 1 2 3 ;4 5 6];b=[0 1 0; 1 2.00001 3 ;2 2 40];
    tol=1e-10;
[LIA,LOCB]=ismembertol_ByRows(a,b,tol)

 %++++++++++++++++++++++++++++++++++++++++++++++++++++
 %++++++++++++++++++++++++++++++++++++++++++++++++++++

% revisit June 17, 2025 during creation of cmap_dpr_module.py

cc
Lp=load('C:\SFV\Extract_cmap_DPR\Results_mat\lcD_68_Py.mat');
Lm=load('C:\SFV\Extract_cmap_DPR\Results_mat\ldD_68_ML.mat');
tol=1e-3;

a=Lp.lcD_68_Py;
b=Lm.list_color_DPR;
[ LIA, LOCB]=ismembertol_ByRows(a,b,tol);    % "a" --> Python  & "b" --> Matlab
loc_orphan_p=find(~LIA)
a(loc_orphan_p,:)  % 67th color by Py is orphan
dev_op_p=b-a(loc_orphan_p,:);
figure;hold on;
plot(abs(dev_op_p)','r-*');
enlarge_axis;
%-------------
m=Lm.list_color_DPR;
p=Lp.lcD_68_Py;
[ LIm, LOCp]=ismembertol_ByRows(m,p,tol);   % "m" --> Matlab  & "p" --> Python
loc_orphan_m=find(~LIm)
m(loc_orphan_m,:)
dev_op_m=p-m(loc_orphan_m,:);

figure;hold on;
plot(abs(dev_op_m)','m->');
enlarge_axis;


 %++++++++++++++++++++++++++++++++++++++++++++++++++++
 %++++++++++++++++++++++++++++++++++++++++++++++++++++

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[LIA,LOCB]=  ismembertol(a,b,tol,'ByRows',true);
end


%% ----- from keepfield.m ---------------------------------------------------
function outstruct = keepfield(instruct,fields)
% OUTSTRUCT = KEEPFIELD(INSTRUCT,FIELDNAMES)
% Removes all fields from a structure other than those specified in 
% input variable FIELDS. 
%
% FIELDS may be a single field, or a cell array of field names
%
% ex:
% a = dir('*.m');
% b = keepfield(a,{'name','bytes'});
%
% See also: RenameField  rmfield
%
% Written by Brett Shoelson, PhD
% 3/1/05
% shoelson@helix.nih.gov

if nargin ~= 2
	error('Requires 2 input arguments.');
end
if ~isa(instruct,'struct')
	error('The first input argument must be a structure.');
end
if (~isa(fields,'char') & ~isa(fields,'cell')) | (isa(fields,'cell') & ~all(cellfun('isclass',fields,'char')))
	error('The second input argument must be a string representing the name of a field to keep or a cell array of field names to keep.');
end

outstruct = rmfield(instruct,setdiff(fieldnames(instruct),fields));
end


%% ----- from kt_calc_max_DV_in_CFP_SVM.m -----------------------------------
function   [max_DV Gloc_maxDV]= kt_calc_max_DV_in_CFP_SVM( L )
% typically called by --> kt_maxDV_Global_or_Local_Model
%------------------------------------------------------------------------------
%  also called --> maxDecVal_P
%--------------------------------------------
% add following, Mar 25, 2024
% CFP_dvABC_SVM_kernel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate maxDV (added July 18, 2020)
%    save( fname4hLW,'LwinCls','handles_insitu_Tcv','handles_LwinAPs_b');  % add --> handles_LwinAPs_b for max_DV cal'c
%================================================================
% L.handles_LwinAPs_b
% L.handles_LwinAPs_b.Lorig
% L.handles_LwinAPs_b.L  --> most important for calc of max_DV
%==============================================
if false
    
    
end
%====================================================
% when called by Global Model, following section will skip
if ~isempty(L.handles_LwinAPs_b.Lorig)  % the following only work for Local Classes Model
    % the following only work for Local Classes Model
    figure;hold on;
    hp1=plot(L.handles_LwinAPs_b.Lorig.Apred','b-O');
    hp2=plot(L.handles_LwinAPs_b.L.Apred','r-*');
    % legend({'Apred scaled by Global Model','Apred scaled by Local Model'})
    
    loc_insitu_T=find_belong2subgrp_cstr(L.handles_LwinAPs_b.Lorig.AclabelT,L.handles_LwinAPs_b.L.clistclslabel);
    AT_insitu.Atrainpk=L.handles_LwinAPs_b.Lorig.Atrainpk(loc_insitu_T,:);
    AT_insitu.Apred=L.handles_LwinAPs_b.Lorig.Apred;
    [AT_insitu.Atrainpk,AT_insitu.Apred,asmc_mean_std]=normasmc_trainpk_pred(AT_insitu.Atrainpk,AT_insitu.Apred,0,1);
end


%--------------------------------------------------------------------------------------------------------------------------------------------------------------------
if false
    if isequal(AT_insitu.Apred,L.handles_LwinAPs_b.L.Apred)
        disp('check Apred is based on scaled by Local Model --> OK !!!');
        hp3=plot(AT_insitu.Apred','g-O');
        legend([hp1(1) hp2(1) hp3(1)  ],{'Apred scaled by Global Model','Apred scaled by Local Model','Apred scaled by Local Model Re-Calcd'});
        stit0=strrep(find_keyword_merge_dual_curly_bracket(fileparts_name_wo_ext(fname4dvA)),'_','\_')  ;
        title([stit0  ])
    else
        error('check Apred is based on scaled by Local Model --> Failed !!!')
        %         warning('check Apred is based on scaled by Local Model --> Failed !!!')

    end
end
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% L.handles_LwinAPs_b.L.Apred
% L.handles_LwinAPs_b.Lorig.Apred
if exist('L')
    
    try
        CFP_dvABC_SVM_kernel= L.CFP_dvABC_SVM_kernel;
    catch
        CFP_dvABC_SVM_kernel='rbf';
    end
else
      CFP_dvABC_SVM_kernel='rbf';
end
switch CFP_dvABC_SVM_kernel
    case 'rbf'
        [handles_LwinAPs_b out_LwinAPs_b]=RUN_SVM_rbf_wDecVal_CmpClsfr(L.handles_LwinAPs_b);
    case 'linear'
        [handles_LwinAPs_b out_LwinAPs_b]=RUN_SVM_linear_wDecVal_CmpClsfr(L.handles_LwinAPs_b);
    otherwise
        error('pls provide CFP_dvABC_SVM_kernel ?');
end
%===================================================================================
% LwinAPs_DV_iqLwin= out_LwinAPs_b.pred_prob*(-1)^(find(out_LwinAPs_b.model_Label==L.LwinCls)-1);
if false
    out_LwinAPs_b.model_Label
end
LwinAPs_DV_iqLwin= out_LwinAPs_b.pred_prob  ;

max_DV=LwinAPs_DV_iqLwin;
Gloc_maxDV=L.Gloc_iqLwin_in_locMax ;

% figure;hold on;
% plot(L.Gloc_iqLwin_in_locMax  , max_DV,'b-O');
% ylabel('max DecVal Pset');
% xlabel("Gloc");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

done_with_this_function;
end


%% ----- from kt_dvABC_etc_Global_or_Local_Model.m --------------------------
function out=kt_dvABC_etc_Global_or_Local_Model  (L  ,  inp  )
% typically called by sd.run_CFP_GM_kt
%----------------------------------------------------------------------
% typically called by --> kt_maxDV_dvABC_insituThres_GlobalModel_or_Local_barebone
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also: BatchRun_CFP_SVM_maxDV_FOM for creating L or pfn_wc
% revisit for KT, July 17, 2024
% deal with indv winner cls
% typically called by --> maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone   % revisit for KT, July 17, 2024
%---------------------------------------------------------------------------------------------
% typically called by --> dvABC_insituThres_FOM_GlobalModel
% modified from maxDV_Global_or_Local_Model
%------------------------------------------------
% dvB Tcv by PDS , Mar 26, 2024
% set dvB_PDS_yes=1 , i.e. dvB Tcv by PDS , see --> dvABC_etc_Global_or_Local_Model.m , Mar 26, 2024
% % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
% create/collect nPDS_WinCls , May 1, 2024 
% see also: AclabelT_format_ClsName_Sn_dvB_Tcv_PDS, May 4, 2024
% revisit for KT, end of July , 2024
%=======================================================
if false
   %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


   %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   %  PTT  in TruePos or FalsePos                
   
   cc
      inp.pfn_wc= 'C:\work\JDSU\KT2LS\KT-Demo_CFP_GM\TruePos\dvABC\alt\Atrainpketc_{dvABC_WC1-PTT}_nvar119_ncls4_nsampT224_nsampP224.mat';   %  PTT  in TruePos
%       inp.pfn_wc= 'C:\work\JDSU\KT2LS\KT-Demo_CFP_GM\FalsePos\dvABC\alt\Atrainpketc_{dvABC_WC1-PTT}_nvar119_ncls4_nsampT224_nsampP224.mat';   %  PTT  in FalsePos
   %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   L=load(inp.pfn_wc);
%    inp.LwinCls=1;            % this will be determined inside the code     % Note that in this case, winner cls moved to cls-1 even in clistclslabel  % Note that in this case, winner cls moved to cls-1 even in clistclslabel
   %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   out=kt_dvABC_etc_Global_or_Local_Model  (L  ,  inp  )
   out.dvB/2                 %     0.1675
   
   %===========================================================================================================================
   %===========================================================================================================================
  % Aug 19, 2024 
     %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %  PET  in TruePos
   
   cc
    inp.pfn_wc=  'C:\work\JDSU\KT2LS\KT-Demo_CFP_GM\TruePos\dvABC\Atrainpketc_{dvABC_WC1-PET}_nvar119_ncls4_nsampT224_nsampP224.mat' ;   %  PET  in TruePos
   L=load(inp.pfn_wc);
%    inp.LwinCls=1;                               % this will be determined inside the code 
   out=kt_dvABC_etc_Global_or_Local_Model  (L  ,  inp  )
   out.dvB/2                 %   0.4540
   
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Demo CFP_GM FalsePos : flour --> PET
   cc
    inp.pfn_wc= 'C:\work\JDSU\KTaug\Test_KTa\ATetc_CFP_GM_Demo\dvABC_maxDVP_FalsePos-flour\Atrainpketc_{dvABC_WC1-PET}_nvar119_ncls4_nsampT224_nsampP224.mat' ;   %   FalsePos flour --> PET
   L=load(inp.pfn_wc);
%    inp.LwinCls=1;                               % this will be determined inside the code 
   out=kt_dvABC_etc_Global_or_Local_Model  (L  ,  inp  )
   out.dvB/2                 %   0.4540
   
   
   
   
   %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
end 
%===================================================================================
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
try
LwinCls=inp.LwinCls;                                    % Local or Global Model's predicted as winner cls
catch
 winner_clistclslabel =   find_keyword_between_markers(fileparts_name_ext(   inp.pfn_wc),'dvABC_WC1-','}')  ;
 LwinCls=find(strcmp(L.clistclslabel, winner_clistclslabel));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% "handles_insitu_Tcv" come from  RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
%------------------------------------------------------------------
if isfield(L,'handles_insitu_Tcv') && isfield(L.handles_insitu_Tcv,'L')
    disp('continue as orig process');
    handles_insitu_Tcv=L.handles_insitu_Tcv;% already based on autoscaled and self_P
elseif ~isfield(L,'handles_insitu_Tcv') && isfield(L,'Atrainpk') && isfield(L,'AclassinfoT')
    disp('new and cleaner approach --> move input variable "L" to handles_insitu_Tcv.L');
  handles_insitu_Tcv.L=L;  
end
%------------------------------------------------------------------
handles_insitu_Tcv_b=handles_insitu_Tcv;                                                                                                                                % handles_insitu_Tcv_b --> this is the most important AT for calc of dvABC
%*****************************************************************************************************************************************************************************************************************
% handles_insitu_Tcv_b.L --> self-Prediction AT based on all local classes
  if isequaltol(handles_insitu_Tcv_b.L.Atrainpk, handles_insitu_Tcv_b.L.Apred)
%  if   isSAME_2Matrix_regardless_sequence(handles_insitu_Tcv_b.L.Atrainpk, handles_insitu_Tcv_b.L.Apred )
    disp_with_border('handles_insitu_Tcv_b.L --> self-Prediction AT based on all local classes');
else
    error('something wrong with "handles_insitu_Tcv_b.L"');
end
handles_insitu_Tcv_b.L.AclassinfoT(handles_insitu_Tcv_b.L.AclassinfoT~=LwinCls)=0;
handles_insitu_Tcv_b.L.AclassinfoP(handles_insitu_Tcv_b.L.AclassinfoP~=LwinCls)=0;
%%%%%%%%%%%%%%%%%%%
if exist('inp')
    try
        CFP_dvABC_SVM_kernel= inp.CFP_dvABC_SVM_kernel;
    catch
        CFP_dvABC_SVM_kernel='rbf';
    end
else
    CFP_dvABC_SVM_kernel='rbf';
end
%---------------------------
switch CFP_dvABC_SVM_kernel
    case 'rbf'
[handles_insitu_Tcv_b out_insitu_Tcv_b]=RUN_SVM_rbf_wDecVal_CmpClsfr(handles_insitu_Tcv_b);  % this is Not running OVA, but for binary classes case, it is the same as OVA
    case 'linear'
[handles_insitu_Tcv_b out_insitu_Tcv_b]=RUN_SVM_linear_wDecVal_CmpClsfr(handles_insitu_Tcv_b);
    otherwise
        error('pls provide CFP_dvABC_SVM_kernel ?');
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    DV_L_selfP_b=out_insitu_Tcv_b.pred_prob;
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
locLwin=find(handles_insitu_Tcv_b.L.AclassinfoT==LwinCls);
    qAclabelT_win= handles_insitu_Tcv_b.L.AclabelT(locLwin);
    nAclabelT_win=ones(size(qAclabelT_win));
     qAclabelT_win_alt=''; 
  cstr_locLwin = locLwin;                                     % orig approach that Tcv based on all indv scans in "locLwin"
%-------------------------------------------------------------
DV_Lwin=DV_L_selfP_b(locLwin);
minDVLwin=min(DV_Lwin);                                                                                                                                                                 % creation of dvA
dvA=minDVLwin;
%*****************************************************************************************************************************************************************************************************************
%%%%%%%%%%%%%%%%%%%%%%%%%
% % find not 1st place winner or  all RunnerUp (RU1)
loc_NOT_Lwin=find(handles_insitu_Tcv_b.L.AclassinfoT~=LwinCls);
DV_LocalRU1=DV_L_selfP_b(loc_NOT_Lwin);
[max_DV_LocalRU1  loc_max_DV_LocalRU1]=max(DV_LocalRU1);
dvC=max_DV_LocalRU1;                                                                                                                                                                   % creation of dvC % the closest pt of all non-winner classes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v1: find out 2nd place winner class
AclassinfoT_NOT_Lwin=handles_insitu_Tcv.L.AclassinfoT(loc_NOT_Lwin);
clsnum_RU1=AclassinfoT_NOT_Lwin(loc_max_DV_LocalRU1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
handles_insitu_rmWinCls=handles_insitu_Tcv;
DV_Lwin_rm1fT=[];
if length(cstr_locLwin)>1
    for iLwincls=1:length(cstr_locLwin)
        handles_insitu_rmWinCls_i=handles_insitu_rmWinCls;
            Lwincls_i=cstr_locLwin(iLwincls);                                 % orig approach that Tcv based on all indv scans in "locLwin"
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        handles_insitu_rmWinCls_i.L.Apred=handles_insitu_rmWinCls_i.L.Atrainpk(Lwincls_i,:);        % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclassinfoP=handles_insitu_rmWinCls_i.L.AclassinfoT(Lwincls_i); % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclabelP=handles_insitu_rmWinCls_i.L.AclabelT(Lwincls_i);       % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        %++++++++++++++++++++++++++++++++++++++++++++++++++++
        handles_insitu_rmWinCls_i.L.Atrainpk(Lwincls_i,:)=[];                                       % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclassinfoT(Lwincls_i)=[];                                      % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        handles_insitu_rmWinCls_i.L.AclabelT(Lwincls_i)=[];                                         % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
        %++++++++++++++++++++++++++++++++++++++++++++++++++++
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % run with simpler libsvm
        handles_insitu_rmWinCls_binary=handles_insitu_rmWinCls_i;
        handles_insitu_rmWinCls_binary.L.AclassinfoT(handles_insitu_rmWinCls_binary.L.AclassinfoT~=LwinCls)=0;
        switch CFP_dvABC_SVM_kernel
            case 'rbf'
                [handles_rmWinCls_i_b out_rmWinCls_i_b]=RUN_SVM_rbf_wDecVal_CmpClsfr(handles_insitu_rmWinCls_binary);
            case 'linear'
                [handles_rmWinCls_i_b out_rmWinCls_i_b]=RUN_SVM_linear_wDecVal_CmpClsfr(handles_insitu_rmWinCls_binary);
        end
            DV_Lwin_rm1fT=[DV_Lwin_rm1fT;out_rmWinCls_i_b.pred_prob];
    end
else
    DV_Lwin_rm1fT =DV_Lwin;
end
%=============================
if false
    out_rmWinCls_i_b.model_Label
    clsname_Lwin=handles_insitu_Tcv.L.clistclslabel{ LwinCls };
end
%==========================================
[minDVLwin_rm1fT  loc_minDVLwin_rm1fT]=min(DV_Lwin_rm1fT);      % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024                                                  % creation of dvB
dvB=minDVLwin_rm1fT;                                            % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
%==============================
disp_with_border(['dvA = ',roundns(dvA,4),'  dvB = ',roundns(dvB,4),'  dvC = ',roundns(dvC,4)]);
clsname_Lwin=handles_insitu_Tcv.L.clistclslabel{ LwinCls };
disp_with_border(['winner class --> ',clsname_Lwin]);
disp_with_border(strwrite_all_space(handles_insitu_Tcv.L.clistclslabel));
%==========================================================================================
out.dvA=dvA;  out.dvB=dvB;   out.dvC=dvC;
try
    out.ncls=length(L.clistclslabel);
    out.clistclslabel=L.clistclslabel;
catch
    out.ncls=length(handles_insitu_Tcv.L.clistclslabel);
    out.clistclslabel=handles_insitu_Tcv.L.clistclslabel;
end
 out.sdvB_PDS_yes='';
if ~isempty(qAclabelT_win_alt)
out.nPDS_WinCls=['nPDS=',num2str(length(cstr_locLwin)),'[',num2str(length(qAclabelT_win)),']','(',clsname_Lwin,')'];     % create/collect nPDS_WinCls , May 1, 2024                   % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
else
out.nPDS_WinCls=['nPDS=',num2str(length(cstr_locLwin)),'(',clsname_Lwin,')'];     % create/collect nPDS_WinCls , May 1, 2024                   % revisit this --> "dvB_PDS_yes" for DM, Apr 30, 2024
end
end
%==========================================================================================
%==========================================================================================


%% ----- from kt_maxDV_Global_or_Local_Model.m ------------------------------
function out=kt_maxDV_Global_or_Local_Model(L,inp  )
% typically called by sd.run_CFP_GM_kt
% will call --> kt_calc_max_DV_in_CFP_SVM
%---------------------------------------------------------------------------
% typically called by --> kt_maxDV_dvABC_insituThres_GlobalModel_or_Local_barebone
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% will call --> kt_calc_max_DV_in_CFP_SVM
% typically called by -->  maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone      or          dvABC_insituThres_FOM_GlobalModel
% see also: kt_calc_max_DV_in_CFP_SVM
%========================================================================
if false
     %===========================================================
     % KT-Demo    PET  in  TruePos
     
      cc
        inp.pfn_maxDV='C:\work\JDSU\KT2LS\KT-Demo_CFP_GM\TruePos\maxDV_P\Atrainpketc_{ApdCls-N6_S3_T-103_P-105_sortTcls_WinCls1st[PET]}_nvar119_ncls4_nsampT224_nsampP90.mat'  % TruePos
    L=load_local_try ( inp.pfn_maxDV );
    
    inp.fig_yes=1;
    [out]= kt_maxDV_Global_or_Local_Model( L , inp );
     
     
     %----------------------------------------------------------------------------------------------------------------
     % KT-Demo CFP_GM FalsePos : flour --> PET

  cc
    inp.pfn_maxDV ='C:\work\JDSU\KTaug\Test_KTa\ATetc_CFP_GM_Demo\dvABC_maxDVP_FalsePos-flour\Atrainpketc_{T-ApdCls-N6_S3_T-103_P-105_sortTPcls_P-T-DM-5P-flour_ClsP-NaN_WinCls1st[PET]}_nvar119_ncls4_nsampT224_nsampP30.mat';
  L=load_local_try(  inp.pfn_maxDV);
  
    inp.fig_yes=1;
  out=kt_maxDV_Global_or_Local_Model(L,  inp  );  
     
    %===========================================================
end     % end of if false
%==========================================================================================
%==========================================================================================

plot_maxDV_yes=inp.fig_yes;
%------------------------------------------------------------------
%------------------------------------------------------------------
L_winP_auto=L;

try
winner_clsnum=inp.winner_clsnum;
catch
 winner_clistclslabel =   find_keyword_between_markers(fileparts_name_ext(   inp.pfn_maxDV),'WinCls1st[',']')  ;
 winner_clsnum=find(strcmp(L.clistclslabel, winner_clistclslabel));
end

try
 stit=   inp.stit;
catch
 stit=   winner_clistclslabel; 
end


try
Gloc_maxDV=inp.Gloc_maxDV;
catch
Gloc_maxDV  =[1:length(L_winP_auto.AclassinfoP )];  
end
%============================================================================================
L_winP__handles_LwinAPs_b=L_winP_auto;
out_L_winP__handles_LwinAPs_b=is_autoscale(L_winP__handles_LwinAPs_b);
if ~out_L_winP__handles_LwinAPs_b
    error(' L_winP__handles_LwinAPs_b is Not autoscaled ');
else
    disp('next --> prepare L_winP__handles_LwinAPs_b into binary format');
    disp('calc of "max_DV_GM" --> max_DV based on Global Model');
    L_winP__handles_LwinAPs_b.AclassinfoT(L_winP__handles_LwinAPs_b.AclassinfoT~=winner_clsnum)=0;
    L_winP__handles_LwinAPs_b.AclassinfoP(L_winP__handles_LwinAPs_b.AclassinfoP~=winner_clsnum)=0;
    %     L=load(fname4dvA);
    %     [max_DV  Gloc_maxDV] = calc_max_DV_in_CFP_SVM( L ) ;        % add this calc of max_DV for Pset, Sept 26, 2022
    Lgm.handles_LwinAPs_b.L=L_winP__handles_LwinAPs_b;
    Lgm.LwinCls=winner_clsnum;                            % very important to add this !!!
    Lgm.Gloc_iqLwin_in_locMax =   Gloc_maxDV;    %  very important to add this !!!
    Lgm.handles_LwinAPs_b.Lorig=[];
    Lgm=catstruct(Lgm,inp);
    [max_DV_GM  Gloc_maxDV_GM] = kt_calc_max_DV_in_CFP_SVM( Lgm ) ;
    if plot_maxDV_yes
        try
            hp_GM=  plot(Gloc_maxDV_GM  , max_DV_GM,'color',inp.scolor,'marker','O','markersize',8);
        catch
            hp_GM=  plot(Gloc_maxDV_GM  , max_DV_GM,'b-O','markersize',10);
        end
        %     legend([ hp_LCM  hp_GM],{'Max DV reCalc based on Local Classes Model' , 'Max DV reCalc based on Global Model' });
        try
            title_usF(stit);
        end
    end
    %-----------------------------------------------------
%     disp_with_border(['clistclslabel in local model --> ',strwrite_all_space(L_fname4dvA.handles_LwinAPs_b.L.clistclslabel)]);
    %-----------------------------------------------
    out.maxDV   = max_DV_GM;
    out.Gloc_maxDV= Gloc_maxDV_GM;
    try
        out.hp_GM_LM=hp_GM;
    catch
        out.hp_GM_LM='';
    end
    %-------------------------------
    out.ncls=length(L.clistclslabel);
    out.clistclslabel=L.clistclslabel;

    %-------------------------------
end
end
%============================================================================================


%% ----- from kw2skw.m ------------------------------------------------------
function skw=kw2skw(kw,symbol4period)
%convert kernel width to string of kernel width
%replacing '.' with symbol4period
% see also parameter2filename
%
% e.g.  kw2skw([.8 0.8 1.5],'p')
if ~exist('symbol4period','var')
    symbol4period='p';             %default setting
end
whole_kw=[];
for ik=1:length(kw)
    ikw=kw(ik);
    skw_tmp=num2str(ikw);
    loc_period=find(skw_tmp=='.');
    if length(loc_period)>0
        skw_tmp(loc_period)=symbol4period;
    end
    whole_kw=[whole_kw,'_', skw_tmp];
end

skw=whole_kw(2:end);
end


%% ----- from libsvm_DecVal.m -----------------------------------------------
function [saDecVal]=libsvm_DecVal(model_libsvm_wDecVal,Y1_pred_ova_libsvm,ncls)
% cope with the Decision Value output in LIBSVM
% extracted from fpred_analysis_ui
% see also RUN_LIBSVM_ova_rbf_wDecVal_CmpClsfr  and LIBSVM_ova
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if show_libsvm_wDecVal_yes==1

Label_Seq_Model_libsvm=model_libsvm_wDecVal.Label;

% if ncls==2
% disp('ncls==2 case')
% else
% disp('ncls~=2 case')
%     
% end


% allcomb=factdes(ncls,2);
% loc_Cmn=find(sum(allcomb,2)==2);
% allcomb_pick2=flipud(allcomb(loc_Cmn,:));
% all_cls_seq0=[];
% for iicls=1:length(allcomb_pick2(:,1))
% all_cls_seq0=[all_cls_seq0;row_always( Label_Seq_Model_libsvm(find(allcomb_pick2(iicls,:)==1)))];
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
all_cls_seq_alt=[];
for icls_1st=1:(ncls-1)
    for icls_2nd=icls_1st+1:ncls
        all_cls_seq_alt=[ all_cls_seq_alt;[icls_1st, icls_2nd ]];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
all_cls_seq_final=[];
for icls_1st=1:(ncls-1)
    for icls_2nd=icls_1st+1:ncls
        all_cls_seq_final=[ all_cls_seq_final;[Label_Seq_Model_libsvm(icls_1st), Label_Seq_Model_libsvm(icls_2nd) ]];
    end
end





% if isSAME_2Matrix(all_cls_seq_alt,all_cls_seq)
%     
%     all_cls_seq= all_cls_seq_alt;
% else
% %        error('somehow mismatch');
%     if ncls==2
%         all_cls_seq= fliplr(all_cls_seq_alt);
%     else
%         all_cls_seq= all_cls_seq_alt;
%         
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     all_cls_seq= all_cls_seq_alt;  % old and problematic approach

  % correct approach:  all_cls_seq_final 
         all_cls_seq= all_cls_seq_final;    % correct approach:  all_cls_seq_final 





all_Cur_Other_DecVal=[];

for icls=1:ncls
    OtherCls=setdiff([1:ncls],icls);
    for jOcls=row_always(OtherCls)
        
        loc_Col_match=  find( all_cls_seq(:,1)== icls & all_cls_seq(:,2)==jOcls);
        
        if ~isempty(loc_Col_match)
            CurDecVal=Y1_pred_ova_libsvm(:,loc_Col_match);
        else
            loc_Col_match_flip=  find( all_cls_seq(:,1)==jOcls  & all_cls_seq(:,2)==icls);
            CurDecVal=-1*Y1_pred_ova_libsvm(:,loc_Col_match_flip);
            
        end
        DecVal__CurCls_OtherCls.(['Cls_',num2str(icls),'_',num2str(jOcls)])=CurDecVal;
        ea_Cur_Other_DecVal=[icls*ones(length(Y1_pred_ova_libsvm(:,1)),1),jOcls*ones(length(Y1_pred_ova_libsvm(:,1)),1),CurDecVal    ];

        all_Cur_Other_DecVal=[all_Cur_Other_DecVal;ea_Cur_Other_DecVal];

        
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% predas_cls_libsvm_DecVal

fdname_cls_seq=fieldnames(DecVal__CurCls_OtherCls);
predas_cls_libsvm_DecVal=[];
ALL_Vote=[];
cALL_DecVal=[];
    for icls=1:ncls
            loc_icls_fd=cellfun(@(x) icls==str2num(find_keyword_between_markers(x,'Cls_','_')),fdname_cls_seq);

       DecVal__icls_OtherCls =keepfield(DecVal__CurCls_OtherCls,fdname_cls_seq(loc_icls_fd));
       matDecVal_icls_OtherCls= struct2array(DecVal__icls_OtherCls);
       
      sign_matDecVal_icls_OtherCls =sign(matDecVal_icls_OtherCls);
      
      zero4neg_matDecVal_icls_OtherCls= replace_CH(sign_matDecVal_icls_OtherCls,-1,0) ;
      
      if    isSAME_2Matrix(sign_matDecVal_icls_OtherCls,zero4neg_matDecVal_icls_OtherCls)
%           disp(['at icls = ',num2str(icls),'   somehow -1 not replaced by zero ?'])
          ALL_sign_matDecVal_icls_OtherCls= sign_matDecVal_icls_OtherCls(:);
          ALL_zero4neg_matDecVal_icls_OtherCls= replace_CH(ALL_sign_matDecVal_icls_OtherCls,-1,0) ;
          
          ReshapeBack_zero4neg_matDecVal_icls_OtherCls=reshape( ALL_zero4neg_matDecVal_icls_OtherCls,size(matDecVal_icls_OtherCls));
          Nvote_icls=sum( ReshapeBack_zero4neg_matDecVal_icls_OtherCls ,2);
      else
          Nvote_icls=sum( zero4neg_matDecVal_icls_OtherCls ,2);
          
      end
        
  
   ALL_Vote=[ALL_Vote,Nvote_icls];
   
%    callDecVal_isampP=[callDecVal_isampP,{allDecVal_isampP_icls}];
cALL_DecVal=[cALL_DecVal,{matDecVal_icls_OtherCls}];

    end
    
    saDecVal=SAinsert_createNew_w_seqnum(length(Y1_pred_ova_libsvm(:,1)));
    
    [saDecVal.Vote]=SAinsert_mat2cell_CH(ALL_Vote,'row');
    for icls=1:ncls
    [saDecVal.(['DecVal_Cls',num2str(icls)])]=SAinsert_mat2cell_CH(cALL_DecVal{icls},'row');
    end
%     ALL_Vote=[ALL_Vote;allVote_isampP];
     
all_winner_cls_libsvm_DecVal=arrayfun(@(x) findWinCls(x),saDecVal);
[saDecVal.winner_cls]=SAinsert_num2cell(all_winner_cls_libsvm_DecVal);
all_winner_DecVal=arrayfun(@(x) findWinDecVal(x),saDecVal,'un',false);
[saDecVal.winner_DecVal]=SAinsert_cell2cell(all_winner_DecVal);

all_2ndwinner_cls_libsvm_DecVal=arrayfun(@(x) find2ndWinCls(x),saDecVal);
[saDecVal.winner_cls_2nd]=SAinsert_num2cell(all_2ndwinner_cls_libsvm_DecVal);

 all_2ndwinner_DecVal=arrayfun(@(x) find2ndWinDecVal(x),saDecVal,'un',false);
 [saDecVal.winner_DecVal_2nd]=SAinsert_cell2cell(all_2ndwinner_DecVal);
  
all_DecVal_winner_1st_vs_2nd =arrayfun(@(x,x1,y,y1) getMutualDecVal(x,x1,y,y1),all_winner_cls_libsvm_DecVal,all_winner_DecVal,all_2ndwinner_cls_libsvm_DecVal,all_2ndwinner_DecVal);   
[saDecVal.DecVal_winner_1st_vs_2nd]=SAinsert_num2cell(all_DecVal_winner_1st_vs_2nd);
end



% figure(410);hold on;
% set(410,'position',[25          63        1574         392]);
% arrayfun(@(x) plot(x.seqnum,x.winner_cls_2nd,'c*','markersize',5),saDecVal);
% arrayfun(@(x) plot(x.seqnum,x.winner_cls,'g*','markersize',10),saDecVal);
% 
% 
% figure(420);hold on;
% set(420,'position',[30          68        1574         392]);
% grid_2ndwinner=0.1;
% arrayfun(@(x) plot(x.seqnum*ones(length(x.winner_DecVal_2nd),1)+grid_2ndwinner,x.winner_DecVal_2nd,'c*','markersize',5),saDecVal);
% arrayfun(@(x) plot(x.seqnum*ones(length(x.winner_DecVal),1),x.winner_DecVal,'b*','markersize',10),saDecVal);
% 
% arrayfun(@(x) plot([x.seqnum x.seqnum+grid_2ndwinner],[x.DecVal_winner_1st_vs_2nd -1*x.DecVal_winner_1st_vs_2nd],'k-'),saDecVal);
%%%%%%%%%%%%%%%%%%%%%%%%%%

% % checking of results by libsvm_DecVal
% all_loc_maxcls_Y1_pred_ova=[];
% for isampP=1:length(handles.Y1_pred_ova(:,1))
%         loc_maxcls_Y1_pred_ova=find(table_ipred_maxcls(isampP,:)==1    );
% all_loc_maxcls_Y1_pred_ova=[all_loc_maxcls_Y1_pred_ova;loc_maxcls_Y1_pred_ova];
%         
% end
% if ~isempty( find(all_winner_cls_libsvm_DecVal~=all_loc_maxcls_Y1_pred_ova   ))
%     loc_mismatch_DecVal=find(all_winner_cls_libsvm_DecVal~=all_loc_maxcls_Y1_pred_ova );
%     figure(410);
%     arrayfun(@(x) plot(x.seqnum,x.winner_cls,'rO'),saDecVal(loc_mismatch_DecVal));
%     figure(420);
%     arrayfun(@(x) plot(x.seqnum*ones(length(x.winner_DecVal),1),x.winner_DecVal,'rO'),saDecVal(loc_mismatch_DecVal));
%     warning('Mis-Match between predcls between libsvm_DecVal vs Y1_pred_ova !!!!!');
% else
%     disp_with_border('Match between predcls between libsvm_DecVal vs Y1_pred_ova !!!');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%
% end % end of showing show_libsvm_wDecVal_yes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out=findWinCls(x)
[maxV locmax]=max(x.Vote);
out=locmax;
end
function out=findWinDecVal(x)
out=x.(['DecVal_Cls',num2str(x.winner_cls)]);
end

function out=find2ndWinCls(x)
% [maxV locmax]=max(x.Vote);
[maxV,loci,locj] = minmax(x.Vote,2,'max');  % find the 2 largest vaues 
out=locj(2);
end

function out=find2ndWinDecVal(x)
out=x.(['DecVal_Cls',num2str(x.winner_cls_2nd)]);
end

function out=getMutualDecVal(x,x1,y,y1)

if x<y
   DecVal_1= x1{1}(y-1);
   DecVal_2=-1*y1{1}(x); 
else
   DecVal_1= x1{1}(y);
   DecVal_2=-1*y1{1}(x-1); 

end

if DecVal_1==DecVal_2
out=DecVal_1;
else
    error('somehow DecVal_1~=DecVal_2  ??? ')
end
end


%% ----- from libsvm_DecVal_Vote.m ------------------------------------------
function [ALL_Vote]=libsvm_DecVal_Vote(model_libsvm_wDecVal,Y1_pred_ova_libsvm,ncls)
% ALL_Vote are arranged in cls seq number, first column for cls-1, 2nd for cls-2 etc
% ALL_Vote are arranged in cls seq number, first column for cls-1, 2nd for cls-2 etc
% ALL_Vote are arranged in cls seq number, first column for cls-1, 2nd for cls-2 etc
% ALL_Vote are arranged in cls seq number, first column for cls-1, 2nd for cls-2 etc
%
% modified from libsvm_DecVal, but NOT using saDecVal to handle big number classes (e.g. Kolon Pharma) situation
% 
if false
    
    
end


Label_Seq_Model_libsvm=model_libsvm_wDecVal.Label;

all_cls_seq_final=[];
for icls_1st=1:(ncls-1)
    for icls_2nd=icls_1st+1:ncls
        try
        all_cls_seq_final=[ all_cls_seq_final;[Label_Seq_Model_libsvm(icls_1st), Label_Seq_Model_libsvm(icls_2nd) ]];
        catch
            disp('something wrong with all_cls_seq_final')
        end
    end
end


all_cls_seq= all_cls_seq_final;    % correct approach:  all_cls_seq_final 



ALL_Vote=[];
cALL_DecVal=[];
for icls=1:ncls
%     loc_icls_fd=cellfun(@(x) icls==str2num(find_keyword_between_markers(x,'Cls_','_')),fdname_cls_seq);
%     
%     DecVal__icls_OtherCls =keepfield(DecVal__CurCls_OtherCls,fdname_cls_seq(loc_icls_fd));
    %%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % matDecVal_icls_OtherCls= struct2array(DecVal__icls_OtherCls);
    loc_col_icls_1=find(all_cls_seq(:,1)==icls);
    loc_col_icls_2=find(all_cls_seq(:,2)==icls);
    matDecVal_icls_OtherCls_1=Y1_pred_ova_libsvm(:,loc_col_icls_1);
    matDecVal_icls_OtherCls_2=-1*Y1_pred_ova_libsvm(:,loc_col_icls_2);

    
    matDecVal_icls_OtherCls=[matDecVal_icls_OtherCls_1,matDecVal_icls_OtherCls_2];
    
    
    
    sign_matDecVal_icls_OtherCls =sign(matDecVal_icls_OtherCls);
    
    zero4neg_matDecVal_icls_OtherCls= replace_CH(sign_matDecVal_icls_OtherCls,-1,0) ;
    
%     if    isSAME_2Matrix(sign_matDecVal_icls_OtherCls,zero4neg_matDecVal_icls_OtherCls)
%         disp(['at icls = ',num2str(icls),'   somehow -1 not replaced by zero ?'])
        ALL_sign_matDecVal_icls_OtherCls= sign_matDecVal_icls_OtherCls(:);
        ALL_zero4neg_matDecVal_icls_OtherCls= replace_CH(ALL_sign_matDecVal_icls_OtherCls,-1,0) ;
        
        ReshapeBack_zero4neg_matDecVal_icls_OtherCls=reshape( ALL_zero4neg_matDecVal_icls_OtherCls,size(matDecVal_icls_OtherCls));
        Nvote_icls=sum( ReshapeBack_zero4neg_matDecVal_icls_OtherCls ,2);
%     else
%         Nvote_icls=sum( zero4neg_matDecVal_icls_OtherCls ,2);
%         
%     end
    
    
    ALL_Vote=[ALL_Vote,Nvote_icls];
    
    %    callDecVal_isampP=[callDecVal_isampP,{allDecVal_isampP_icls}];
    
end










disp('finish libsvm_DecVal_Vote')
end


%% ----- from libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto.m ---
function out = libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto(pathfname_AT,para_norm,para_asmc,inp)  
% typically called by --> iACP_switch_Clsfr_ACP (inside family of iACPmp_gui )
% run Local Auto version of APs libsvm wDecVal
% modified from libsvm_insitu_build_allCls_Model_for_LOH_pred_APs
% Feb 14,2023
%==========================================================
% typically called by --> libsvm_LOH_pred_APs
% modified from libsvm_LOH_pred_APs
% this will fix AclassinfoT if they are not sorted by appear order of libsvm' Label
% see --> fname_new=strrep( fileparts_name_ext(pathfname_AT),'.mat'  ,'_ClsSeqAprOrder.mat' );
% Feb 2, 2023
%--------------------------------------------------
% add new setting 'Prob', i.e. run wProb on binary clsfr of each OVO pair, Dec 12, 2023
%
%---------------------------------------------------------
% see also: AT_sortBy_clistclslabel
 %================================================================================================================
 if false
     
     cc;
     tic
                       pathfname_AT='C:\work\JDSU\Test_ACP\iACPmp\ATetc_summary_alt_P-TsetName\SVMmodel_files\Atrainpketc_some_corename_pp1-SNV_pp2-1stDerSGFL5[PO3]_nvar121_ncls6_nsampT185_nsampP32.mat';
     %               pathfname_AT='C:\work\JDSU\Test_ACP\iACPmp\ATetc_LOHpred\Atrainpketc_some_corename_pp1-SNV_pp2-1stDerSGFL5[PO3]_nvar121_ncls6_nsampT185_nsampP32_ClsSeqAprOrder.mat';
     
     %              pathfname_AT='C:\work\JDSU\Test_ACP\Biological_Samples\OSBC_GlucoseMonitoring\ncls3\Atrainpketc_ftirDots_SM0009_T-NormalsftirDotsThreeShift_C12ftirDotsNoShift_ncls3_nsamT1401_nsamP356.mat';
     %                  pathfname_AT='C:\work\JDSU\Dataset_popular\PharmaLib\TP\Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds_nsamp7711_ncls19_wRawSpectra_KS-nsampT1026_wKennard-Stone_NonKS-nsampP6685_ReApply_pp1-1stDerSGDiederick_pp2-SNV.mat' ;% libsvm-Anton based on OVA can not handle too many ncls case
     %               pathfname_AT='C:\work\4GL\API_T-10Cls_Syndrome_P-4Cls_C01Pain\demo\Atrainpketc__icomb3_{T-P02_P03_P-P01_wLC}_nvar317_nclsT10_nclsP4_nsampT720_nsampP360.mat'  ;
     %      pathfname_AT='C:\work\JDSU\Test_ACP\Plastics_Recycle\API_T-10Cls_Syndrome_P-4Cls_C01Pain\demo\Atrainpketc__icomb3_{T-P02_P03_P-P01_wLC}_nvar317_nclsT10_nclsP4_nsampT720_nsampP360.mat'
     
%         pathfname_AT= 'C:\work\JDSU\Test_ACP\particle_metrology\CNT-sensors\Atrainpketc_all_R_Condensation_T80_P120_sortP.mat'
%       pathfname_AT= 'C:\work\JDSU\Test_ACP\particle_metrology\CNT-sensors\Atrainpketc_all_R_Condensation_T80_P120_sortP_clsinfoT-Sort.mat'
     
     inp.enable_LocalAuto_yes=1;   % for running SVM_Linear_wLocalAuto
     %            inp.libsvm_kt='linear';
     inp.libsvm_kt='Prob';
     para_norm=0;para_asmc=1;
     inp.show_fig_yes=0;
     out = libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto(pathfname_AT,para_norm,para_asmc,inp)    ;
     toc
     
     %=============================================================================================
     % run Local Auto version of APs libsvm wDecVal
     cc;
     tic
                                   pathfname_AT='C:\work\JDSU\Test_ACP\Biological_Samples\OSBC_GlucoseMonitoring\ncls3\Atrainpketc_ftirDots_SM0009_T-NormalsftirDotsThreeShift_C12ftirDotsNoShift_ncls3_nsamT1401_nsamP356.mat';
     %                          pathfname_AT='C:\work\4GL\API_T-10Cls_Syndrome_P-4Cls_C01Pain\demo\Atrainpketc__icomb3_{T-P02_P03_P-P01_wLC}_nvar317_nclsT10_nclsP4_nsampT720_nsampP360.mat'  ;
     %       pathfname_AT='C:\work\JDSU\Dataset_popular\PharmaLib\TP\Atrainpketc_allAT_OneLIB_ALL_3Reds_3Blues_wRawSpectra_wQuadCor-Reds_nsamp7711_ncls19_wRawSpectra_KS-nsampT1026_wKennard-Stone_NonKS-nsampP6685_ReApply_pp1-1stDerSGDiederick_pp2-SNV.mat' ;% libsvm-Anton based on OVA can not handle too many ncls case
     
     %           pathfname_AT='C:\work\JDSU\Test_ACP\iACPmp\ATetc_LOHpred\Atrainpketc_{T-ES-553_P-OS-145}_nvar121_ncls46_nsampT1410_nsampP1416.mat'  ;
     %        pathfname_AT= 'C:\work\JDSU\Test_ACP\Cloud_Csharp\T-ES-553_P-OS-145_wRK-SampleName\TP_Cmp_SVM_ILM\ncls10\Atrainpketc_{T-ES-553_P-OS-145}_Cmp_SVM_ILM_nvar121_ncls10_nsampT300_nsampP302.mat';
     %         pathfname_AT= 'C:\work\JDSU\Test_ACP\Test_Trinamix\ATetc\Trinamix\Atrainpketc_{T-T1_rkN1_P-T1_rkN2}_nvar349_ncls50_nsampT300_nsampP300.mat'
     %     pathfname_AT= 'C:\work\JDSU\Test_ACP\Cloud_Csharp\Trinamix_ds1\Atrainpketc_some_corename_pp1-SNV_pp2-2ndDerSGFL7[PO2]_nvar347_ncls50_nsampT300_nsampP300.mat'
     %     pathfname_AT=  'C:\work\JDSU\Test_ACP\Cloud_Csharp\Trinamix_ds1\Atrainpketc_some_corename_pp1-SNV_pp2-1stDerSGFL15[PO3]_nvar339_ncls50_nsampT300_nsampP300.mat'
     % pathfname_AT='C:\work\JDSU\AB_test\Speed_DellG3_vs_DellG2\ATetc_Mayne2020\Atrainpketc_(T-N136Rm1OL_N200Rm3OLs_RmCls-222304_P-S1-00589)_ncls68_nsamp2110_nsampP1070_TP_rm3OLs.mat'
%      pathfname_AT='C:\work\JDSU\AB_test\Speed_DellG3_vs_DellG2\ATetc_Mayne2020\Atrainpketc_(T-N136Rm1OL_N200Rm3OLs_RmCls-222304_P-S1-00589)_ncls68_nsamp2110_nsampP1070_TP_rm3OLs_MatchRS2Atrainpk.mat'
     inp.enable_LocalAuto_yes=1;   % for running SVM_Linear_wLocalAuto
%      inp.libsvm_kt='linear';
      inp.libsvm_kt='Prob';
     para_norm=0;para_asmc=1;
     inp.show_fig_yes=0;
     out = libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto(pathfname_AT,para_norm,para_asmc,inp)    ;
     toc
     %------------------------------------------------------------------------------------------------------------------------
     % test with MLbClsfr datsets, Apr 11, 2023
     cc
     pathfname_AT='C:\work\JDSU\Test_ACP\test_MultiLabelClsfr\Datasets_MLb_Clsfr\BMS_OTC\ncls10\Atrainpketc__icomb3_{T-P02_P03_P-P01_wLC}_nvar317_ncls10_nsampT720_nsampP360_C01-Pain.mat'
%       pathfname_AT='C:\work\JDSU\Test_ACP\test_MultiLabelClsfr\Datasets_MLb_Clsfr\BMS_OTC\nclsT10_nclsP4\Atrainpketc__icomb3_{T-P02_P03_P-P01_wLC}_nvar317_nclsT10_nclsP4_nsampT720_nsampP360_w-AclassinfoMap2LC.mat'
      inp.enable_LocalAuto_yes=1;   % for running SVM_Linear_wLocalAuto
     inp.libsvm_kt='linear';
     para_norm=0;para_asmc=1;
     inp.show_fig_yes=0;
     out = libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto(pathfname_AT,para_norm,para_asmc,inp)   
     
     %---------------------------------------------------------%---------------------------------------------------------%---------------------------------------------------------
     %---------------------------------------------------------%---------------------------------------------------------%---------------------------------------------------------

     % test wLocalAuto , revisit July 31, 2024
     
     cc
     
     % these Not sorted yet and will go thru sortTcls inside this code
                pathfname_AT= 'C:\work\JDSU\KTaug\AT_LAf_alone\LAf_ncls4_DS_source\xU_nTU1\Atrainpketc_(1){Nylons_PET_PP_LAf_T-LAf_103_P-LAf_105}_nvar119_ncls4_nsampT1015_nsampP1020.mat'
%                 pathfname_AT='C:\work\JDSU\KT\AT_LAf_alone\Atrainpketc_{T-LAf_Nylons_PET_M1-103_P-M1-105}_ncls3_nsampT765_nsampP770.mat'
%             --------------------------------------------------------------------
%             these already sortTcls
%             pathfname_AT='C:\work\JDSU\Test_ACP\particle_metrology\Tcv_nF5_{Particle_TrainingData-11-2023}\Atrainpketc_{P-f-1_nF5_(Particle_TrainingData-11-2023)}_nvar22_ncls14_nsampT1603_nsampP407.mat'
%              pathfname_AT='C:\work\JDSU\Test_ACP\Biological_Samples\OSBC_GlucoseMonitoring\ncls3\Atrainpketc_ftirDots_SM0009_T-NormalsftirDotsThreeShift_C12ftirDotsNoShift_ncls3_nsamT1401_nsamP356.mat';
%              pathfname_AT='C:\work\JDSU\Test_ACP\Plastics_Recycle\API_T-10Cls_Syndrome_P-4Cls_C01Pain\demo\Atrainpketc__icomb3_{T-P02_P03_P-P01_wLC}_nvar317_nclsT10_nclsP4_nsampT720_nsampP360.mat'
%-------------------------------
    inp.enable_LocalAuto_yes=1;   % for running SVM_Linear_wLocalAuto
        inp.libsvm_kt='linear';   % orig wDecVal APs
%         inp.libsvm_kt='Prob';  % add new setting 'Prob', i.e. run wProb on binary clsfr of each OVO pair, Dec 12, 2023 % new wProb approach
     para_norm=0;para_asmc=1;
     inp.show_fig_yes=0;
     out = libsvm_insitu_build_allCls_Model_for_LOH_pred_APs_wLocalAuto(pathfname_AT,para_norm,para_asmc,inp)
     
      %---------------------------------------------------------%---------------------------------------------------------%---------------------------------------------------------
    
     
 end      % end of if false for running examples
 %-------------------------------------------------------------------------------------------------------------------------
 %-------------------------------------------------------------------------------------------------------------------------------------------------------
 try
     show_fig_yes=   inp.show_fig_yes;
 catch
     show_fig_yes=0;
 end
 %------------------------------------------------------------------------------------------------------------
 if isstruct(pathfname_AT)
     L=pathfname_AT;
 elseif ischar( pathfname_AT )
     L=load(pathfname_AT);
 end
 
 
 trainpk=L.Atrainpk;
 if isfield(L,'RawSpectra') && isfield(L.RawSpectra,'Tset')
       RawSpectra_Tset=L.RawSpectra.Tset;
       try
           if length(RawSpectra_Tset(:,1))~=length( trainpk(:,1) )
               RawSpectra_Tset=[];
               warning('RawSpectra_Tset does Not have same length as trainpk ??');
           end
       end
 end

 pred=L.Apred;
 classinfoT=L.AclassinfoT;
 classinfoP=L.AclassinfoP;
 clistclslabel=L.clistclslabel;
 %------------------------------------------------------------------------------------------------------------
 % allCls training and prediction
 ClsSeq_lib=row_always(unique_appear_order(  classinfoT ) );
 ncls=length(ClsSeq_lib) ;
 if ~isequal(  ClsSeq_lib,   [1: ncls] )
     out_sort=AT_sortBy_clistclslabel_sortTcls(pathfname_AT) ;
     Lnew=out_sort.obj.LAT;
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   
   if isa(pathfname_AT,'struct')
       sdn=ssds(Lnew);
       pathfname_AT=['Atrainpketc',sdn.fname_AT_barebone_tail];  % add this Mar 20, 2023
   end
  
     fname_new=strrep( fileparts_name_ext(pathfname_AT),'.mat'  ,'_clsinfoT-Sort.mat' );   % see also: AT_sortBy_clistclslabel
     save( fname_new,'-struct',"Lnew"  );
  
     ClsSeqAprOrder_yes=1;
     %----------------------------------------------------
     classinfoT=Lnew.AclassinfoT;
     trainpk=Lnew.Atrainpk;
     try
         clabelT=Lnew.AclabelT;
     end
    %-------------------------------------------------
 else
     ClsSeqAprOrder_yes=0;
 end
 %-------------------------------------------------------------------------------------------------
 YT_allCls=classinfoT;
 YP_allCls=classinfoP;
 %------------------------------------------------------------------------------------------------------------
 [trainpk_normasmc,pred_normasmc]=normasmc_trainpk_pred(trainpk,pred,para_norm,para_asmc);   %norm and asmc operations

 %-------------------------------------------------------------
 XT_allCls=trainpk_normasmc;
 XT_allCls_sparse=sparse(XT_allCls ) ;
 %  YT_allCls=classinfoT;


 XP_allCls=pred_normasmc;
 XP_allCls_sparse=sparse(  XP_allCls ) ;
 %  YP_allCls=classinfoP;

 switch inp.libsvm_kt
     case 'linear'
         model_wDecVal_allCls = svmtrain_MEX(YT_allCls, XT_allCls_sparse,[' -t 0  ',' -q']);        % linear with Dec_Val output
          [predicted_label_wDecVal_allCls, accuracy_wDecVal_allCls, decision_values_prob_estimates_wDecVal_allCls]...
             = svmpredict_MEX(YP_allCls, XP_allCls_sparse, model_wDecVal_allCls);                                        % extr_predict with Dec_Val output
         
     case 'Prob' 
         % add new setting 'Prob', i.e. run wProb on binary clsfr of each OVO pair, Dec 12, 2023
         model_wDecVal_allCls = svmtrain_MEX(YT_allCls, XT_allCls_sparse,['-b 1 -t 0  ',' -q']);        % linear with Dec_Val output
        [predicted_label_wDecVal_allCls, accuracy_wDecVal_allCls, decision_values_prob_estimates_wDecVal_allCls]...
             = svmpredict_MEX(YP_allCls, XP_allCls_sparse, model_wDecVal_allCls,'-b 1');   

         %          disp_with_border(['NmisP libsvm allCls (',  inp.libsvm_kt ,')  = ' ,num2str(NmisP_lib_allCls)]);

         % ClsSeq_lib=model_wDecVal_allCls.Label ;
         % ncls=model_wDecVal_allCls.nr_class;

 end
 
 
         
         loc_misP_lib_allCls=find(predicted_label_wDecVal_allCls~=classinfoP)  ;
         NmisP_lib_allCls=length(loc_misP_lib_allCls);
 
 
 %-------------------------------------------------------------------
  %=====================================================================================
  %=====================================================================================
  
  %----------------------------------------------------------
% change to following, Feb 11, 2023
listcomb =nchoosek([1:ncls],2) ;
numcomb=length(listcomb(:,1));
%----------------------------------------------------------
% Y1_pred_APs_libsvm_LocalAuto=[];
Y1_pred_APs_libsvm_LocalAuto=zeros([length(classinfoP)   numcomb]);
%------------------------------------------------------

  for iAP=1:numcomb
      %------------------------------------------------------------------
      listCls_iAP=  listcomb(iAP,:) ;
      loc_iAP_Tset=find_belong2subgrp(classinfoT, listCls_iAP);
      %    idx_iAP_Tset=ismember(classinfoT, listCls_iAP);
      XT=XT_allCls(loc_iAP_Tset,:) ;
      YT_orig=YT_allCls(loc_iAP_Tset,:) ;
      YT=-1*ones(length(YT_orig(:,1)),1);
      focusCls_iAP=  listCls_iAP(1) ;
      loc_iAP_Tset_focusCls=find_belong2subgrp(classinfoT, focusCls_iAP);
      loc_onecls_YT=find(YT_orig== focusCls_iAP );
      YT(loc_onecls_YT)=1;
      %     [N d] = size(XP_allCls_sparse);
      [N d] = size(XP_allCls);
      
      %========================================================
      % deal with LIBSVM
      XT_sparse=sparse(XT);
      XP=XP_allCls;
      XP_sparse=sparse(XP);
      YP=-1*ones(length(XP(:,1)),1);
      loc_onecls_YP=find(classinfoP==focusCls_iAP);
      YP(loc_onecls_YP)=1;
      %====================================================================
      
      if inp.enable_LocalAuto_yes
          [XT_sparse_LA,XP_sparse_LA]=normasmc_trainpk_pred(XT_sparse,XP_sparse,para_norm,para_asmc);   %norm and asmc operations
          
          switch inp.libsvm_kt
              case 'linear'
                  model_wDecVal_LA = svmtrain_MEX(YT, XT_sparse_LA,[' -t 0  ',' -q']);        % linear with Dec_Val output
                   exponent4neg=find(model_wDecVal_LA.Label==1)-1;
                  if exponent4neg==1
                      warning('change sign ? 1st entry in model_wDecVal_LA.Label is Not 1 ? instead is -1');
                  end
                  [predicted_label_wDecVal_LA, accuracy_wDecVal_LA, decision_values_prob_estimates_wDecVal_LA]...
                      = svmpredict_MEX(YP, XP_sparse_LA, model_wDecVal_LA);
                 
                  decision_values_adjust_LA= decision_values_prob_estimates_wDecVal_LA*(-1)^(exponent4neg);% determine sign of DV in binary SVM model
                  sign_decision_values_adjust_LA=sign(decision_values_adjust_LA);
              case 'Prob'
                  % add new setting 'Prob', i.e. run wProb on binary clsfr of each OVO pair, Dec 12, 2023
                  model_wDecVal_LA = svmtrain_MEX(YT, XT_sparse_LA,['-b 1 -t 0  ',' -q']);
%                    exponent4neg=find(model_wDecVal_LA.Label==1)-1;
%                   if exponent4neg==1
%                       warning('change sign ? 1st entry in model_wDecVal_LA.Label is Not 1 ? instead is -1');
%                   end
                  [predicted_label_wDecVal_LA, accuracy_wDecVal_LA, decision_values_prob_estimates_wDecVal_LA]...
                      = svmpredict_MEX(YP, XP_sparse_LA, model_wDecVal_LA,'-b 1');
                  locP_decision_values_adjust_LA= find(decision_values_prob_estimates_wDecVal_LA(:,1)>=decision_values_prob_estimates_wDecVal_LA(:,2));
                  locN_decision_values_adjust_LA= find(decision_values_prob_estimates_wDecVal_LA(:,1)<decision_values_prob_estimates_wDecVal_LA(:,2));
                  decision_values_adjust_LA=repmat(NaN,size(decision_values_prob_estimates_wDecVal_LA(:,1)));
                  decision_values_adjust_LA( locP_decision_values_adjust_LA)=1;
                  decision_values_adjust_LA( locN_decision_values_adjust_LA)=-1;
                  sign_decision_values_adjust_LA=sign(decision_values_adjust_LA);
                  if ClsSeqAprOrder_yes && iAP==numcomb
                      warning('this results may or may not be problematic ?');
                      warning('CNT-sensors seems find but somehow does match in this ncls6_nsampT185_nsampP32 dataset ??');
                  end
%                    if exponent4neg==1
%                       warning('above calc may be questionable ? sine 1st entry in model_wDecVal_LA.Label is Not 1 ? instead is -1');
%                   end
          end
          
      
       %   Y1_pred_APs_libsvm_LocalAuto=[ Y1_pred_APs_libsvm_LocalAuto, decision_values_adjust_LA ];
%        if ~isequal(decision_values_prob_estimates_wDecVal_LA,decision_values_adjust_LA )
%            figure;hold on;
%            plot(decision_values_prob_estimates_wDecVal_LA,'k-O');
%            plot(decision_values_adjust_LA,'r-*');
%        end
       
       Y1_pred_APs_libsvm_LocalAuto(:,iAP)=decision_values_adjust_LA ;

      end
      
  end   % end of iAP
  %----------------------------------------------------------------------------------------------------
           disp_with_border(['NmisP libsvm allCls (',  inp.libsvm_kt ,')  = ' ,num2str(NmisP_lib_allCls)]);
  %=======================================================================
  [ALL_Vote_LA]=libsvm_DecVal_Vote(model_wDecVal_allCls,Y1_pred_APs_libsvm_LocalAuto,ncls);
     [ maxVote_LA, predcls_LA]=max(ALL_Vote_LA,[],2);   %Note the end input is empty
     
     loc_misP_LA=find(classinfoP~=predcls_LA) ;
     NmisP_LA=length(loc_misP_LA);
%      disp('Great !!!');
     disp_with_border(['NmisP Local Auto = ',num2str(NmisP_LA),' (',  inp.libsvm_kt ,')']);
%=====================================================================
  %=====================================================================================
  %=====================================================================================
  try
      if ClsSeqAprOrder_yes
          disp_with_border([ ' newly created "ClsSeqAprOrder" Atrainpketc_~.mat file !!!' ]);
          disp_with_border([ fname_new,' has been saved !!!' ]);
      end
  end
 %---------------------------------------------------------------------
 try
 pfn_AT=which(fname_new);
 out.pfn_AT=pfn_AT;
 catch
  out.pfn_AT='';   
 end
 out.model_wDecVal_allCls= model_wDecVal_allCls ;
 out.DecVal_APs_allCls = decision_values_prob_estimates_wDecVal_allCls;
 
 %-----------------------------------------------------------------------------------
 out.NmisP_lib_allCls=NmisP_lib_allCls;
out.classinfoT = classinfoT; 
out.classinfoP = classinfoP; 
out.XT_allCls=XT_allCls;
out.YT_allCls=YT_allCls;
out.XP_allCls=XP_allCls;
out.ClsSeqAprOrder_yes=ClsSeqAprOrder_yes;
%-------------------------------
% out.AclassinfoP=classinfoP;
out.predcls=predcls_LA;
out.loc_misP = loc_misP_LA;
out.NmisP=  NmisP_LA ;
out.extr_Predict_Accuracy = (length(classinfoP)-NmisP_LA)/length(classinfoP)*100 ;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ----- from load_local_try.m ----------------------------------------------
function [ L ]=load_local_try(varargin)
% try to load from local drive if the specified pathfilename can not be found
% and if not available in pwd, then try to addpath_wo_attic(pwd) and see if
% that can find it
% if still not able to find it, then give up
% e.g. L=load_local_try('c:\test_load_local_try.mat');
try
L=load(varargin{:});
catch
    try
%     filenameONLY=find_keyword_between_markers(varargin{1},'\',[]);
        filenameONLY=fileparts_name_ext(varargin{1});

    
    localfilename=[pwd,'\',filenameONLY];
    L=load(localfilename);
    disp(['can not find in ',varargin{1},', hence load from: ',localfilename]);
    catch
        try
            path_try2find=  which(fileparts_name_ext( localfilename) ) ;
            if isempty(path_try2find)
                addpath_wo_attic(pwd);
                try
                L=load(fileparts_name_ext( localfilename));
                disp(['load from: ',which(fileparts_name_ext( localfilename))]);
                catch
                    error('try to add path of subfolders and still not able to load')
                end
                else
              L=load(path_try2find);  
            disp(['load from ',path_try2find]);
            end
        catch
            error('try all possible loading path and still fail')
        end
        
    end
end
end
%------------------------------------------------
% try
% out2=path_try2find;
% catch
% out2='';
% end


%% ----- from loc_preprocess.m ----------------------------------------------
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

% end


%% ----- from logistic_output.m ---------------------------------------------
function Q=logistic_output(Qinf,thalf,alpha,t,ti,inp)

if false
    
    clear;close all;
    Qinf=1;
    thalf=-0.5;
    alpha=30;
    t=[-2:0.1:1];
    ti=-0.4;
    inp.fig_yes=1;
    Q=logistic_output(Qinf,thalf,alpha,t,ti,inp);
   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    cc
    load('C:\work\JDSU\Test_ACP\Results_ACP\test_FOM\test_FOM_{P-rk1_T-3rk_RKSS-24_25_26_27}_1.mat')
    Q1=logistic_output(Qinf,thalf,alpha,t)
    load('C:\work\JDSU\Test_ACP\Results_ACP\test_FOM\test_FOM_{P-rk1_T-3rk_RKSS-24_25_26_27}_2.mat')
    Q2=logistic_output(Qinf,thalf,alpha,t)
    
    Q=[Q1;Q2];
    figure;hold on;
    plot(Q,'b-*');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    thalf=0.4;   % insitu_prediction_threshold for DV of Pset
    alpha=5;                                                                                                        % current setting for alpha
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;
    max_DV=0.6;   % DV for Pset
    max_DV_Q=logistic_output(Qinf,thalf,alpha,max_DV) % revisit per DM's figure of merit request, July 13, 2020
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    thalf=0.4 ;% insitu_prediction_threshold for DV of Pset
    alpha=30;                                                                                                   % very high setting for alpha  
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;
    max_DV=0.6;      % DV for Pset
    max_DV_Q=logistic_output(Qinf,thalf,alpha,max_DV) % revisit per DM's figure of merit request, July 13, 2020
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    thalf=0.4 ;% insitu_prediction_threshold for DV of Pset
    alpha=1;                                                                                                       % very low setting for alpha  
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;
    max_DV=0.6;      % DV for Pset
    max_DV_Q=logistic_output(Qinf,thalf,alpha,max_DV) % revisit per DM's figure of merit request, July 13, 2020

    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this section must be used for  RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
if length(t)==length(thalf)  % see RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
    Q = Qinf./(1 + exp(-alpha*(t-thalf)));   % see RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
else
    error('can not calculate Q')
end
%% 
%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this following section Not needed for running RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
if false   % block this for running with Matlab 2024a
    if exist('ti') && ~isempty(ti) && ~isnan(ti)
        Qi=Qinf./(1 + exp(-alpha*(ti-thalf)));
    else
    end
    if exist('inp')&& isfield(inp,'fig_yes') && inp.fig_yes
        figure;hold on;plot(t,Q,'b-*');
        try
            plot(ti,Qi,'r-O');
        end
        title(['alpha=',num2str(alpha),' thalf=',num2str(thalf),' Qinf=',num2str(Qinf)]);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('done with logistic_output')
end


%% ----- from logistic_output_4parameters.m ---------------------------------
function Q=logistic_output_4parameters(Qinf,thalf,Qmin,alpha,t)
% see https://www.myassays.com/four-parameter-logistic-regression.html
if false
    
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    
    thalf=[0.4 0.4 0.4];   % insitu_prediction_threshold for DV of Pset
    alpha=5;                                                                                                        % current setting for alpha
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;Qmin=-1;
%     max_DV=[  0.44  0.45  0.46];   % DV for Pset
        max_DV=[  0.59  0.6  0.61];   % DV for Pset

    max_DV_Q=logistic_output_4parameters(Qinf,thalf,Qmin,alpha  ,  max_DV) % revisit per DM's figure of merit request, July 13, 2020
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    thalf=0.4 ;% insitu_prediction_threshold for DV of Pset
    alpha=30;                                                                                                   % very high setting for alpha  
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;Qmin=-1;
    max_DV=0.6;      % DV for Pset
    max_DV_Q=logistic_output_4parameters(Qinf,thalf,Qmin,alpha  ,  max_DV  )   % revisit per DM's figure of merit request, July 13, 2020
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    thalf=0.4 ;% insitu_prediction_threshold for DV of Pset
    alpha=1;                                                                                                       % very low setting for alpha  
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;Qmin=-1;
    max_DV=0.6;      % DV for Pset
    max_DV_Q=logistic_output_4parameters(Qinf,thalf,Qmin,alpha  ,  max_DV)% revisit per DM's figure of merit request, July 13, 2020

    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this section must be used for  RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
if length(t)==length(thalf)  % see RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
%     
% %     if false
%      Q1 = Qinf./(1 + exp(-alpha*(t-thalf)));   % see RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
%      Q=(Q1-0.5)*2;
% %     end
    
%     if false
 Q=Qinf+(Qmin-Qinf)./( 1 + ( t ./ thalf  ).^alpha  )  ;                         % see https://www.myassays.com/four-parameter-logistic-regression.html
%     end
    
else
    error('can not calculate Q')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('done with logistic_output')
end


%% ----- from logistic_output_InflectPtZero.m -------------------------------
function Q=logistic_output_InflectPtZero(Qinf,thalf,alpha,t)
% this is based on rescaled output of logistic_output
if false
    
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    
    thalf=[0.6 0.6 0.6];   % insitu_prediction_threshold for DV of Pset
    alpha=5;                                                                                                        % current setting for alpha
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;Qmin=-1;
%     max_DV=[  0.44  0.45  0.46];   % DV for Pset
        max_DV=[  0.59  0.6  0.61];   % DV for Pset

    max_DV_Q=logistic_output_InflectPtZero(Qinf,thalf,alpha  ,  max_DV) % revisit per DM's figure of merit request, July 13, 2020
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    thalf=0.4 ;% insitu_prediction_threshold for DV of Pset
    alpha=30;                                                                                                   % very high setting for alpha  
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;Qmin=-1;
    max_DV=0.6;      % DV for Pset
    max_DV_Q=logistic_output_InflectPtZero(Qinf,thalf,alpha  ,  max_DV  )   % revisit per DM's figure of merit request, July 13, 2020
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extracted from RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr(handles,inp)
    %     thalf=thres_insitu_ALL;  % !!!! should be using this "thres_insitu_ALL"
    
    cc
    thalf=0.4 ;% insitu_prediction_threshold for DV of Pset
    alpha=1;                                                                                                       % very low setting for alpha  
    % !!!! should be using this "thres_insitu_ALL"
    Qinf=1;Qmin=-1;
    max_DV=0.6;      % DV for Pset
    max_DV_Q=logistic_output_InflectPtZero(Qinf,thalf,alpha  ,  max_DV)% revisit per DM's figure of merit request, July 13, 2020

    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this section must be used for  RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
if length(t)==length(thalf)  % see RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
    
    Q1 = Qinf./(1 + exp(-alpha*(t-thalf)));   % see RUN_SVM_InSituLocalScale_Hierarchical_CmpClsfr
    Q=(Q1-0.5)*2;                                     % this is based on rescaled output of logistic_output
    
    if false
        % this is based on
        % Q=logistic_output_4parameters(Qinf,thalf,Qmin,alpha,t) however there are abnormal results sometimes
        %
        Q=Qinf+(Qmin-Qinf)./( 1 + ( t ./ thalf  ).^alpha  )  ;                         % see https://www.myassays.com/four-parameter-logistic-regression.html
    end
    
else
    error('can not calculate Q')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('done with logistic_output')
end


%% ----- from lsq_dderiv.m --------------------------------------------------
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


%% ----- from lsq_deriv.m ---------------------------------------------------
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


%% ----- from lsq_smooth.m --------------------------------------------------
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


%% ----- from marker_CH.m ---------------------------------------------------
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


%% ----- from mat2cell_CH.m -------------------------------------------------
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


%% ----- from mat2cell_CH_4SAinsert.m ---------------------------------------
function varargout=mat2cell_CH_4SAinsert(X,insert_type)
% alias of SAinsert_mat2cell_CH
% insert_type should be either 'row' or 'col'
% mainly used for insert X into a structure array ( SA ) with a single line code
% if X is 2D matrix, it will output cX{:},i.e. column-wise first
% pls see also mat2cell_CH SAinsert_mat2cell  num2cell_4SAinsert and cell2cell_4SAinsert 
%
% example for insert M into a structure array:
%
%insert each col
% sa=struct('f1',{0,0,0});X=[1 2 3;4 5 6];[sa.f1]=mat2cell_CH_4SAinsert(X,'col');
%
% insert each row
% sa=struct('f1',{0,0});X=[1 2 3;4 5 6];[sa.f1]=mat2cell_CH_4SAinsert(X,'row');
%
% see also Atrainpk2saConc  ssds ( constructor )
% see also: spectra_dispenser , Nov 15, 2022
%-----------------------------------------------------------------------------------------
if false
    
    % put Atrainpk as all zeros into saConc
    LAT=load('C:\work\JDSU\ModelsTransferMLtool\GLS+UDM\ATetc\AQP\B102_UDM21\UDM\Atrainpketc_saConc_(Brix_CS102_UDM21_UDM)_pp1-none_pp2-none_nvar125_nsamp21.mat');
    LAT.Atrainpk=zeros(size(LAT.Atrainpk));
    [LAT.saConc.Atrainpk]=mat2cell_CH_4SAinsert(LAT.Atrainpk,'row'); 
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cX=mat2cell_CH(X,insert_type);
for i=1:length(cX(:))
varargout(i)=cX(i);
end
end


%% ----- from maxDV_Global_or_Local_Model.m ---------------------------------
function out=maxDV_Global_or_Local_Model(L,inp  )
% typically called by -->  maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone      or          dvABC_insituThres_FOM_GlobalModel
if false
    
end
%==========================================================================================
plot_maxDV_yes=inp.fig_yes;
%------------------------------------------------------------------
%------------------------------------------------------------------
L_winP_auto=L;
winner_clsnum=inp.winner_clsnum;
Gloc_maxDV=inp.Gloc_maxDV;
%============================================================================================
L_winP__handles_LwinAPs_b=L_winP_auto;
out_L_winP__handles_LwinAPs_b=is_autoscale(L_winP__handles_LwinAPs_b);
if ~out_L_winP__handles_LwinAPs_b
    error(' L_winP__handles_LwinAPs_b is Not autoscaled ');
else
    disp('next --> prepare L_winP__handles_LwinAPs_b into binary format');
    disp('calc of "max_DV_GM" --> max_DV based on Global Model');
    L_winP__handles_LwinAPs_b.AclassinfoT(L_winP__handles_LwinAPs_b.AclassinfoT~=winner_clsnum)=0;
    L_winP__handles_LwinAPs_b.AclassinfoP(L_winP__handles_LwinAPs_b.AclassinfoP~=winner_clsnum)=0;
    %     L=load(fname4dvA);
    %     [max_DV  Gloc_maxDV] = calc_max_DV_in_CFP_SVM( L ) ;        % add this calc of max_DV for Pset, Sept 26, 2022
    Lgm.handles_LwinAPs_b.L=L_winP__handles_LwinAPs_b;
    Lgm.LwinCls=winner_clsnum;                            % very important to add this !!!
    Lgm.Gloc_iqLwin_in_locMax =   Gloc_maxDV;    %  very important to add this !!!
    Lgm.handles_LwinAPs_b.Lorig=[];
    Lgm=catstruct(Lgm,inp);
    [max_DV_GM  Gloc_maxDV_GM] = calc_max_DV_in_CFP_SVM( Lgm ) ;
    if plot_maxDV_yes
        try
            hp_GM=  plot(Gloc_maxDV_GM  , max_DV_GM,'color',inp.scolor,'marker','O','markersize',8);
        catch
            hp_GM=  plot(Gloc_maxDV_GM  , max_DV_GM,'b-O','markersize',10);
        end
        %     legend([ hp_LCM  hp_GM],{'Max DV reCalc based on Local Classes Model' , 'Max DV reCalc based on Global Model' });
        try
            title_usF( inp.stit);
        end
    end
    %-----------------------------------------------------
%     disp_with_border(['clistclslabel in local model --> ',strwrite_all_space(L_fname4dvA.handles_LwinAPs_b.L.clistclslabel)]);
    %-----------------------------------------------
    out.maxDV   = max_DV_GM;
    out.Gloc_maxDV= Gloc_maxDV_GM;
    try
        out.hp_GM_LM=hp_GM;
    catch
        out.hp_GM_LM='';
    end
    %-------------------------------
    out.ncls=length(L.clistclslabel);
    out.clistclslabel=L.clistclslabel;

    %-------------------------------
end
end
%============================================================================================


%% ----- from maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone.m ---
function out=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp )
% revisit for KT, July 17, 2024
%---------
% typically called by --> BatchRun_CFP_SVM_maxDV_FOM
%+++++++++++++++++++++++++++++++++++++++++
% inp.dvABC_by_kt_yes
% will call -->  dvABC_etc_Global_or_Local_Model or kt_dvABC_etc_Global_or_Local_Model
%----------------------------------------------------------------------------------
% revisit this Jan 12, 2024
% will call --> dvABC_etc_Global_or_Local_Model
% will call --> maxDV_Global_or_Local_Model
% will call --> calc_thres_insitu_IV
% will call --> FOM_logistic_DV_Calc
%------------------------------------------------------
% modified from dvABC_insituThres_FOM_GlobalModel
% see also: test_ssds_method_extract_Pset
% see also: calc_max_DV_in_CFP_SVM
%-------------------------------------------------
% need to add calc of "thres_insitu_V" by extending calc_thres_insitu_IV
% revisit this Jan 12, 2024
%--------------------------------------------
% add following, Mar 25, 2024
% inp.CFP_dvABC_SVM_kernel='linear';  
%-----------------------------------------------
% set dvB_PDS_yes=1 , i.e. dvB Tcv by PDS , see --> dvABC_etc_Global_or_Local_Model.m , Mar 26, 2024
%----------------------------------------
% collect thres_insitu_IV etc, Apr 4, 2024
%--------------------------------------------------------------------
% end of July, 2024
% apply norm and asmc !!! % apply norm and asmc !!!% apply norm and asmc !!!
%++++++++++++++++++++++++++++++++++++++++++++++
%  inp.dvABC_by_kt_yes
% end of July, 2024
% will call -->  dvABC_etc_Global_or_Local_Model or kt_dvABC_etc_Global_or_Local_Model
%---------------------------------------------------------------------
% will call --> AT_sortBy_clistclslabel_sortCls
%==========================================================================================================================
if false
    %=============================================================
    % citric-acid GM only
    cc
%     pfn_GM_only= 'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\TP_FP_DM-5Powders\TruePos\Atrainpketc_DM-5Powders_nvar119_ncls5_nsampT55_nsampP15.mat' ;
    pfn_GM_only='C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\ATetc_5Powders_P-eachWinner\Atrainpketc_{DM-5Powders[citric-acid]}_nvar119_ncls5_nsampT55_nsampP3.mat'
    inp.winner_clistclslabel='citric-acid';
%      inp.InsituThres_scheme='IV';
     inp.InsituThres_scheme='V';
    inp.fig_yes=1;
    out_GM_Only=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    %=============================================================
    % flour
    cc
    pfn_GM_only= 'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\ATetc_5Powders_P-eachWinner\Atrainpketc_{DM-5Powders[flour]}_nvar119_ncls5_nsampT55_nsampP3.mat' ;
    inp.winner_clistclslabel='flour';
    %      inp.InsituThres_scheme='IV';
     inp.InsituThres_scheme='V';

    inp.fig_yes=1;
    out=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % LocalModel flour in Global-Only codes
    cc
     inp.winner_clistclslabel='flour';
    pfn_GM_only='C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\ATetc_test_LM_in_GM\Atrainpketc_{DM-5Powders_LocalModel-(citric-acid_flour_sugar)}_winner-flour_nvar119_ncls3_nsampT35_nsampP3.mat'
     %      inp.InsituThres_scheme='IV';
     inp.InsituThres_scheme='V';

    inp.fig_yes=1;
    out=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    %===============================================================
    % 'salt'
    cc
    pfn_GM_only='C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\ATetc_5Powders_P-eachWinner\Atrainpketc_{DM-5Powders[salt]}_nvar119_ncls5_nsampT55_nsampP3.mat' ;
    inp.winner_clistclslabel='salt';
    %      inp.InsituThres_scheme='IV';
     inp.InsituThres_scheme='V';

     inp.fig_yes=1;
    out=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    %=============================================================
    % cream-tartar
    cc
    pfn_GM_only= 'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\ATetc_5Powders_P-eachWinner\Atrainpketc_{DM-5Powders[cream-tartar]}_nvar119_ncls5_nsampT55_nsampP3.mat' ;
    inp.winner_clistclslabel='cream-tartar';
    %      inp.InsituThres_scheme='IV';
     inp.InsituThres_scheme='V';

      inp.fig_yes=1;
    out=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    
    %=============================================================
    % 'sugar' GM only
    cc
    pfn_GM_only= 'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\ATetc_5Powders_P-eachWinner\Atrainpketc_{DM-5Powders[sugar]}_nvar119_ncls5_nsampT55_nsampP3.mat' ;
    inp.winner_clistclslabel='sugar';
    %      inp.InsituThres_scheme='IV';
     inp.InsituThres_scheme='V';

     inp.fig_yes=1;
    out=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %  LocalModel 'sugar' in GM only codes
    cc
    pfn_GM_only= 'C:\work\JDSU\Test_ACP\CFP_Global-Cls_ILM\ATetc_test_LM_in_GM\Atrainpketc_{DM-5Powders_LocalModel-(citric-acid_flour_sugar)}_winner-sugar_nvar119_ncls3_nsampT35_nsampP3.mat'
    inp.winner_clistclslabel='sugar';
    %      inp.InsituThres_scheme='IV';
     inp.InsituThres_scheme='V';

     inp.fig_yes=1;
    out=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    %=============================================================
    %---------------------------------------------------    
    % RK_Big7 vs TruePos indv & all P-cls with GM only, Jan 13, 2024
    cc
    %     pfn_GM_only= 'C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_RK_Big7\Atrainpketc_{Orig-(T-109-105_P-EdEmLS_rm4OLs_chgID3_fixAclabelT_(RK_Big7))_clistclslabelMatch2-(Big5+PC)_indvCls-PET}_nvar119_ncls7_nsampT294_nsampP16.mat'
    %     pfn_GM_only= 'C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_RK_Big7_indvCls-PET\Atrainpketc_{Orig-(T-109-105_P-EdEmLS_rm4OLs_chgID3_fixAclabelT_(RK_Big7))_clistclslabelMatch2-(Big5+PC)_indvCls-PET}_(PET)(PC)_ncls2_nsampT84_nsampP16.mat'
    pfn_GM_only='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_RK_Big7\Atrainpketc_{Orig-(T-109-105_P-EdEmLS_rm4OLs_chgID3_fixAclabelT_(RK_Big7))_clistclslabelMatch2-(Big5+PC)}_nvar119_ncls7_nsampT294_nsampP135.mat'
    inp.Clsfr_Global='SVM_linear_wDecVal_APs';
    %     inp.winner_clistclslabel='PET';
%      inp.InsituThres_scheme='IV';
          inp.InsituThres_scheme='V';
    inp.fig_yes=0;
    out_GM_Only=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    
    %---------------------------------------------------
      %---------------------------------------------------    
    % RK_Big7 vs FalsePos 5 Powders all P-cls with GM only, Jan 14, 2024
    cc
    pfn_GM_only='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_4DM\Atrainpketc_{T-Orig-(T-109-105_P-EdEmLS_rm4OLs_chgID3_fixAclabelT_(RK_Big7))_clistclslabelMatch2-(Big5+PC)_P-T-DM-5Powders_sortTcls_ClsP-NaN}_nvar119_ncls7_nsampT294_nsampP110.mat'
    inp.Clsfr_Global='SVM_linear_wDecVal_APs';
    %     inp.winner_clistclslabel='PET';
%      inp.InsituThres_scheme='IV';
          inp.InsituThres_scheme='V';
    inp.fig_yes=0;
    out_GM_Only=maxDV_dvABC_insituThres_FOM_GlobalModel_or_Local_barebone ( pfn_GM_only, inp ) ;
    
    %---------------------------------------------------
    %=============================================================
    
    
    
end   % end of if false examples
%==========================================================================================================================
%==========================================================================================================================
%==========================================================================================================================
try
fig_yes=inp.fig_yes;
catch
fig_yes=0;    
end
%--------------------------------------
Lorig=load( pfn_GM_only );  % or L0=load( pfn_GM_only );
ncls=length(Lorig.clistclslabel);
%=========================================================%=========================================================
%=========================================================%=========================================================
% apply norm and asmc !!! % apply norm and asmc !!!% apply norm and asmc !!!
para_norm=0;para_asmc=1;
L_testOrig=Lorig;
[L_testOrig.Atrainpk,L_testOrig.Apred,asmc_mean_std]=normasmc_trainpk_pred(Lorig.Atrainpk,Lorig.Apred,para_norm,para_asmc);           % apply norm and asmc !!! % apply norm and asmc !!!% apply norm and asmc !!!
handles_testOrig.L=L_testOrig;
handles_testOrig.addinfo_Hier=['woHier'];
switch inp.Clsfr_Global
    case {'SVM_linear_wDecVal_APs','SVM_OVA_RBF_wDecVal'}
        % [handles_testOrig out_testOrig]=RUN_SVM_linear_CmpClsfr_wDecVal(handles_testOrig);
        %%%%%%%%%%%%%%%%%%%%%%
        inp4wDecVal_APs.saDecVal_yes=0; % disable generation of saDecVal_extr which for big ncls will take long long time
        if strcmp(inp.Clsfr_Global,'SVM_linear_wDecVal_APs' )
        [handles_testOrig out_testOrig]=RUN_SVM_linear_CmpClsfr_wDecVal(handles_testOrig,inp4wDecVal_APs);
        
        %%%%%%%%%%%
        % ALL_Vote_wDecVal_linear are arranged in cls seq number, first column for cls-1, 2nd for cls-2 etc
        [ALL_Vote_wDecVal_linear]=libsvm_DecVal_Vote(out_testOrig.model_wDecVal,out_testOrig.pred_prob,ncls);
        % ALL_Vote_wDecVal_linear are arranged in cls seq number, first column for cls-1, 2nd for cls-2 etc
        [maxVote locMaxVote]=max(ALL_Vote_wDecVal_linear');
        out_testOrig.pred_prob=ALL_Vote_wDecVal_linear;
        % checking
        if isSAME_2Matrix(col_always(locMaxVote),col_always(out_testOrig.predcls))
            %%%%%%%%%%%%%%%%%%%%%%%
            % since out_testOrig.pred_prob is copied from ALL_Vote_wDecVal_linear and is based on sorted clsnum seq
            % when out_testOrig and clsnumSeqT fed into win_runup() below, they should be both based on sorted clsnum seq
            %
            % but for wDecVal -->  clsnumSeqT based on sorted order
            clsnumSeqT=unique( handles_testOrig.L.AclassinfoT);% but for wDecVal -->  clsnumSeqT based on sorted order
            % but for wDecVal -->  clsnumSeqT based on sorted order
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp_with_border('clsnumSeqT as input to "win_runup()" below  will be based on "sorted" clsnum seq, NOT appearance seq !!!')
        else
            warning('mismatch between locMaxVote vs out_testOrig.predcls but will continue ...');
            Speak_mk('mismatch between locMaxVote vs predcls but will continue ...');
            clsnumSeqT=unique( handles_testOrig.L.AclassinfoT);% but for wDecVal -->  clsnumSeqT based on sorted order
            disp_with_border('clsnumSeqT as input to "win_runup()" below  will be based on "sorted" clsnum seq, NOT appearance seq !!!')
            
        end
        %%%%%%%%%%%%%
        
        
        elseif strcmp(inp.Clsfr_Global,'SVM_OVA_RBF_wDecVal' )
         [handles_testOrig out_testOrig]=RUN_LIBSVM_ova_rbf_wDecVal_CmpClsfr(handles_testOrig);  
        else
            error('inp.Clsfr_Global Not supported');
        end
        
        
    otherwise
        error('Clsfr_Global Not supported !!!')
end
if ~all(isnan(Lorig.AclassinfoP))
loc_misP_TruePos_forcePredict=find(out_testOrig.predcls~=handles_testOrig.L.AclassinfoP);
else
loc_misP_TruePos_forcePredict='';    
end
locMax=out_testOrig.predcls;
qLwinCls=unique(locMax);
%======================================================================================================================================================================
%======================================================================================================================================================================
ALL_predcls_iqLwin_in_locMax=repmat(NaN,size(locMax));
ALL_thres_insitu=repmat(NaN,size(locMax));
ALL_max_DV_GM=repmat(NaN,size(locMax));

for iqLwin=1:length(qLwinCls)
    LwinCls=qLwinCls(iqLwin);
    loc_iqLwin_in_locMax=find(locMax==LwinCls);
    ALL_predcls_iqLwin_in_locMax( loc_iqLwin_in_locMax )=iqLwin;
    %=========================================================%=========================================================
    %=========================================================%=========================================================
    
    % winner_clsnum=find(strcmp(L0.clistclslabel,inp.winner_clistclslabel));
    winner_clsnum=LwinCls;
    inp.winner_clistclslabel=Lorig.clistclslabel{ winner_clsnum };
    %=========================================================%=========================================================
    %=========================================================%=========================================================
    sd0=ssds(pfn_GM_only);
    inpRmSamp_P.loc_rm=setdiff([1:length(locMax)],loc_iqLwin_in_locMax);
   sd0_iqLwin = sd0.rm_samps_Pset_in_TPpair(inpRmSamp_P);
    
    %-------------------------------------------------------------------------
    
    L0=sd0_iqLwin.LAT;
    L_winP=L0;
    L_winP_auto=apply_autoscale_on_Atrainpketc_L_struct(L_winP);
    %=%============================================================================================
    Lgmdv=L0;    %
    %------------------------------------------------------------
    % it seems that we should apply autoscale to Lgmdv too ?
    Lgmdv_auto=apply_autoscale_on_Atrainpketc_L_struct( Lgmdv ) ;
    % clear Lgmdv ;
    %----------------------------------------------------
    Lgmdv_auto.Apred=Lgmdv_auto.Atrainpk;   % create self_P for dvABC etc based on GlobalModel
    Lgmdv_auto.AclassinfoP=Lgmdv_auto.AclassinfoT; % create self_P for dvABC etc based on GlobalModel
    try
        Lgmdv_auto.AclabelP=Lgmdv_auto.AclabelT; % create self_P for dvABC etc based on GlobalModel
    end
    inp_dvABC_gm.LwinCls= winner_clsnum;
    inp_dvABC_gm.fig_yes=fig_yes;
    inp_dvABC_gm=catstruct(inp_dvABC_gm,inp);
    %-------------------------------------
    %##########################################################################################
    % 1st main function 1st main function 1st main function 1st main function 1st main function --> dvABC_etc_Global_or_Local_Model dvABC_etc_Global_or_Local_Model dvABC_etc_Global_or_Local_Model dvABC_etc_Global_or_Local_Model 
    
    %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    % will call -->  dvABC_etc_Global_or_Local_Model or kt_dvABC_etc_Global_or_Local_Model
    try
        if inp.dvABC_by_kt_yes
            %+++++
           loc_not_wc=find( ~strcmp(Lgmdv_auto.clistclslabel,inp_dvABC_gm.winner_clistclslabel )) ;
            inp4rq.cls_pick_specified_seq=[ {inp_dvABC_gm.winner_clistclslabel} , Lgmdv_auto.clistclslabel(loc_not_wc) ] ; % seq now is important, they follow cls_pick_specified_seq
            sd_gm_auto=ssds(Lgmdv_auto);
            inp4rq.corename='{ReSeq_WC1st}';
            sd_gm_auto=sd_gm_auto.saveAT( inp4rq);
            out_rq=AT_reseq_clistclslabel(sd_gm_auto.pathfname_AT,inp4rq);
%             out_rq_sortTcls=AT_sortBy_clistclslabel_sortTcls(out_rq.pfn_AT_new);
            out_rq_sortTcls=AT_sortBy_clistclslabel_sortCls(out_rq.pfn_AT_new);

            LAT_rq_sT_orig=out_rq_sortTcls.obj.LAT ;
            LAT_rq_sT=LAT_rq_sT_orig;
            LAT_rq_sT.Apred=LAT_rq_sT_orig.Atrainpk;
            LAT_rq_sT.AclassinfoP=LAT_rq_sT_orig.AclassinfoT;
            LAT_rq_sT.AclabelP=LAT_rq_sT_orig.AclabelT;
           if  find(strcmp(LAT_rq_sT.clistclslabel,inp_dvABC_gm.winner_clistclslabel))~=1
               error('wincls Not set to 1st ?')
           else
            inp_dvABC_gm.LwinCls=1;   % very important to reset this !!!
           end
            %+++++
            sd_rq_sT = ssds(LAT_rq_sT);
            inp4rq_sT.corename=['{dvABC_WC1-',LAT_rq_sT.clistclslabel{1},'}'];
            sd_rq_sT=sd_rq_sT.saveAT(inp4rq_sT );
            % out_dvABC_gm=kt_dvABC_etc_Global_or_Local_Model(Lgmdv_auto,  inp_dvABC_gm  )  ;           % actually work on --> L_fname4dvA.handles_insitu_Tcv.L
            out_dvABC_gm=kt_dvABC_etc_Global_or_Local_Model(LAT_rq_sT,  inp_dvABC_gm  )  ;           % actually work on --> L_fname4dvA.handles_insitu_Tcv.L
            %+++++++++
        else
            out_dvABC_gm=dvABC_etc_Global_or_Local_Model(Lgmdv_auto,  inp_dvABC_gm  )  ;                % actually work on --> L_fname4dvA.handles_insitu_Tcv.L
        end
    catch
        warning('somehow can Not run --> kt_dvABC_etc_Global_or_Local_Model ?');
        out_dvABC_gm=dvABC_etc_Global_or_Local_Model(Lgmdv_auto,  inp_dvABC_gm  )  ;
    end
    % will call -->  dvABC_etc_Global_or_Local_Model or kt_dvABC_etc_Global_or_Local_Model
    %$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    
    % 1st main function 1st main function 1st main function 1st main function 1st main function
    %##########################################################################################
    
    %---------------------------------
    if fig_yes
        hf_dvABC=figure;hold on;
        hp_dv_gm=plot([1:3],[out_dvABC_gm.dvA out_dvABC_gm.dvB out_dvABC_gm.dvC],'b-O');
        enlarge_axis;
        cXT_dv={'dvA',  'dvB' , 'dvC' };
        set_XTick_etc(gca,cXT_dv,-30,12);
        title_usF(inp.winner_clistclslabel);
        title_add(gca,strwrite_all_delimiter( out_dvABC_gm.clistclslabel,' & '));
        ylabel('dvABC');
    end
    %======================================================================================================================================================================
    %======================================================================================================================================================================
    %======================================================================================================================================================================
    %  L_fname4dvA.handles_LwinAPs_b.L  --> most important for calc of max_DV
    if fig_yes
        hf_maxDV =   figure;hold on;
    end
    %----------------------------------------
    % calc of max_DV_GM --> max_DV based on Global Model
    %=%============================================================================================
    inp4gm.winner_clsnum=winner_clsnum;
    try
        inp4gm.Gloc_maxDV= Gloc_maxDV ;
    catch
        inp4gm.Gloc_maxDV = col_always([1: length(L_winP_auto.AclassinfoP)]);
    end
    inp4gm.stit=inp.winner_clistclslabel;
    %-------------------------------------
    Lgm=L_winP_auto;
    inp4gm.fig_yes=fig_yes;
    inp4gm=catstruct(inp4gm,inp);
    %##########################################################################################
    % 2nd main function 2nd main function 2nd main function 2nd main function 2nd main function
    try
        if inp.dvABC_by_kt_yes
            %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            
            
               sd_winP_auto =   ssds(L_winP_auto) ;
            inp4winP_auto.corename_1=get_corename_pfn(pfn_GM_only );
%             inp4winP_auto.corename_2 = find_keyword_between_markers(fileparts_name_ext( pfn_GM_only), inp4winP_auto.corename_1,'}') ;
%             inp4winP_auto.corename=['{',inp4winP_auto.corename_1,  inp4winP_auto.corename_2,'}'];
            inp4winP_auto.corename=inp4winP_auto.corename_1;
            
            sd_winP_auto=sd_winP_auto.saveAT( inp4winP_auto);
%                 pfn_AT='C:\work\JDSU\KT2LS\KT_mfiles\ILM_&_CFP\CARE_alone_nTU1_1\ncls4_PET_PP_PTT_TP\Atrainpketc_{ApdCls-N6_S3_T-103_P-105}_LocalAutoStudy(Cls-3_4_5_6)_nvar119_ncls4_nsampT224_nsampP240.mat';
               inp_wc1_wP.winner_clsnum=find(strcmp(sd_winP_auto.LAT.clistclslabel, inp.winner_clistclslabel))  ;  
               inp_wc1_wP.winner_clistclslabel=inp.winner_clistclslabel; 
               out_wc1_wP=AT_sortBy_WinCls1st_sortTcls(sd_winP_auto.pathfname_AT,inp_wc1_wP) ;

            
            out_maxDV_gm=kt_maxDV_Global_or_Local_Model(out_wc1_wP.obj.LAT,inp4gm  );                     % inp.dvABC_by_kt_yes
            %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        else
            out_maxDV_gm=maxDV_Global_or_Local_Model(Lgm,inp4gm  );
        end
    catch
        out_maxDV_gm=maxDV_Global_or_Local_Model(Lgm,inp4gm  );
    end
    % 2nd main function 2nd main function 2nd main function 2nd main function 2nd main function
    %##########################################################################################
    ALL_max_DV_GM( loc_iqLwin_in_locMax )= out_maxDV_gm.maxDV ;
    %----------------------------------------
    %=%============================================================================================
    %-----------------------------------
    if fig_yes
        figure(hf_maxDV);
        ylabel('maxDV of Pset');xlabel('Samples Seq of Pset');
        title_add(gca,'max_DV_P');
        title_add(gca,strwrite_all_delimiter( out_maxDV_gm.clistclslabel,' & '));
    end
    %=============================================================================================
    % Step-3 : calc of thres_insitu
    thres_insitu=calc_thres_insitu_IV_V(out_dvABC_gm,inp);
    
    ALL_thres_insitu( loc_iqLwin_in_locMax)=thres_insitu;
    
    if fig_yes
        figure(hf_dvABC);
        plot_hline(thres_insitu,'o');
        title_add(gca,['InsituThres_scheme=',inp.InsituThres_scheme]);
        
        figure(hf_maxDV);
        plot_hline(thres_insitu,'o');
        title_add(gca,['InsituThres_scheme=',inp.InsituThres_scheme]);
        
        enlarge_axis;
    end
    %===========================================================================================
    % Step-4 : Calc of FOM
    
    max_DV_Q = FOM_logistic_DV_Calc(out_maxDV_gm.maxDV,thres_insitu ) ;% Calc of FOM
    if false
        if fig_yes
            figure(hf_dvABC);
            plot_hline(thres_insitu,'o');
            figure(hf_maxDV);
            plot_hline(thres_insitu,'o');
            enlarge_axis;
        end
    end
    %======================================================================================================================================================================
    
end   % end of iqLwin
%======================================================================================================================================================================
%======================================================================================================================================================================
hf_PS_CFP_LocalThres=figure;hold on; set(gcf,'position', 1000* [ 0.4488    0.3420    1.2960    0.5094 ]);
plot(ALL_thres_insitu,'r-');
% plot(ALL_predcls_iqLwin_in_locMax,'k-*');
plot(ALL_max_DV_GM,'b-*');

ylabel('MaxDecision Values');
xlabel('sample sequence');
if all(isnan(Lorig.AclassinfoP))
    loc_PS_GM=find(ALL_max_DV_GM<ALL_thres_insitu);
    loc_PF_GM=find(ALL_max_DV_GM>=ALL_thres_insitu);
else
    loc_PS_GM=find(ALL_max_DV_GM>ALL_thres_insitu);
    loc_PF_GM=find(ALL_max_DV_GM<=ALL_thres_insitu);
    plot_vline(loc_misP_TruePos_forcePredict,'m');
end
plot(loc_PF_GM,ALL_max_DV_GM(loc_PF_GM ),'rO','linestyle','none');

PS_CFP_GM=    length( loc_PS_GM)/length(ALL_max_DV_GM)*100 ;
NmisP_CFP_GM= length( loc_PF_GM );
if ~all(isnan(Lorig.AclassinfoP))
loc_PF_GM_ALL=unique([loc_PF_GM;loc_misP_TruePos_forcePredict]);
else
loc_PF_GM_ALL= loc_PF_GM;   
end
NmisP_CFP_GM_ALL=length(loc_PF_GM_ALL );
PS_CFP_GM_ALL= (length(ALL_max_DV_GM)-NmisP_CFP_GM_ALL)/length(ALL_max_DV_GM)*100 ;
% title([{strrep(handles.pathfname_AT,'_','\_')};{[sGLm,'   ',snLcls,' ',strThresGlobal]};{['PS=',roundns(PS_CFP,2),'%','  NmisP=',num2str(NmisP_CFP)]} ]);
title_usF([{fileparts_name_ext(pfn_GM_only)};{['PS=',roundns(PS_CFP_GM,2),'%','  NmisP=',num2str(NmisP_CFP_GM)]} ]);
if ~all(isnan(Lorig.AclassinfoP))
title_add(gca,['TruePos case -->   ','PS_ALL=',roundns(PS_CFP_GM_ALL,2),'%','  NmisP ALL=',num2str(NmisP_CFP_GM_ALL)]);
end
%--------------------------------------------------------------
try
    snLcls=['nLcls = ',num2str(inp.List_nLcls)];
catch
    snLcls='';  % typically this is running with Global Model
end
%-------------------------------------------------------------
title_add(gca,['InsituThres_scheme=',inp.InsituThres_scheme,'   ',snLcls]);
title_add(gca,['Winner Cls --> ',inp.winner_clistclslabel]);
try
title_add(gca,['CFP_dvABC_SVM_kernel=',inp.CFP_dvABC_SVM_kernel,'   ',out_dvABC_gm.sdvB_PDS_yes,'   ',out_dvABC_gm.nPDS_WinCls]);
end
enlarge_axis;
%======================================================================================================================================================================
%======================================================================================================================================================================
out.dvABC_gm=out_dvABC_gm;
out.maxDV_gm= out_maxDV_gm.maxDV;
out.thres_insitu = thres_insitu ;

if strcmp(inp.InsituThres_scheme,'IV')
out.thres_insitu_IV=thres_insitu;
else
out.thres_insitu_IV=NaN;    
end
%------------------------------------------------------
% collect thres_insitu_IV etc, Apr 4, 2024
out.collect_thres_insitu_IV.thres_insitu_IV=out.thres_insitu_IV;
out.collect_thres_insitu_IV.winner_clistclslabel = inp.winner_clistclslabel;
%--------------------------------------------------------
out.FOM=max_DV_Q;                        % Calc of FOM
out.hf_PS_CFP_LocalThres=hf_PS_CFP_LocalThres;
out.PS_CFP_GM_ALL=PS_CFP_GM_ALL;
%-----------------------------------------------------------
out.nPDS_WinCls= out_dvABC_gm.nPDS_WinCls;  % collect nPDS_WinCls , May 1, 2024
%--------------------------------------------------------------
try 
    out.LAT_rq_sT=LAT_rq_sT;  %  based on inp.dvABC_by_kt_yes==1
    out.pfn_dvABC=sd_rq_sT.pathfname_AT;
    out.pfn_wc1_wP=out_wc1_wP.pathfname_AT;
catch
    out.LAT_rq_sT='';
    out.pfn_wc1_wP='';
    out.pfn_dvABC='';
end
%*****************************************************************************************************************************************************************************************************************
%*****************************************************************************************************************************************************************************************************************
%*****************************************************************************************************************************************************************************************************************

done_with_this_function;
end
%*****************************************************************************************************************************************************************************************************************


%% ----- from merge_Pset_with_SameTset_in_XBPL.m ----------------------------
function out=merge_Pset_with_SameTset_in_XBPL(pathfname_1,pathfname_2,inp)
% only work for same clistclslabel in Tset of both datasets
% results will be based on 1st dataset's Tset and merged Pset based on both
if false
    
    clear
    pathfname_1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70.mat'
    inp.corename='{T5subj_p801L134_p1004_57_89_117_Pp801L2_Pp1004_68}';
    merge_Pset_with_SameTset_in_XBPL(pathfname_1,pathfname_2,inp);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pathfname_2 from "attic_different_in_clistclslabel"
    clear
    pathfname_1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\attic_different_in_clistclslabel\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70_SCls[1_2_3].mat'
    inp.corename='{T5subj_p801L134_p1004_57_89_117_Pp801L2_Pp1004_68}';
    merge_Pset_with_SameTset_in_XBPL(pathfname_1,pathfname_2,inp);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % add RawSpectra to "pathfname_1"
    clear
    pathfname_1='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp801L2\Atrainpketc_{T5subj_p801L134_p1004_57_89_117_Pp801L2_wRS}_nvar75_ncls13_nsampT845_nsampP82.mat'
    pathfname_2='C:\work\JDSU\ILCQ\Test_ILCQ\Just_testing\TP_pair\T5subj_p801L134_p1004_57_89_117_Pp1004_68\Atrainpketc_(T5subj_p801L134_p1004_57_89_117_Pp1004_68)_nvar75_ncls13_nsampT845_nsampP70.mat'
    inp.corename='{T5subj_p801L134_p1004_57_89_117_Pp801L2_Pp1004_68}';
    merge_Pset_with_SameTset_in_XBPL(pathfname_1,pathfname_2,inp);
    
    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L1=load(pathfname_1);
L2=load(pathfname_2);

%checking
if isSAME_Tset(pathfname_1,pathfname_2)


L3=L1;
try
L3.AclabelP=[L1.AclabelP;L2.AclabelP];
end
try
L3.AclassinfoP=[L1.AclassinfoP;L2.AclassinfoP];
L3.Apred=[L1.Apred;L2.Apred];
end

try
    
    L3=rmfield(L3,'RawSpectra');
    L3.RawSpectra.Tset=[L1.RawSpectra.Tset];
    L3.RawSpectra.Pset=[L1.RawSpectra.Pset;L2.RawSpectra.Pset];

end
L3.clistclslabel_P=[L1.clistclslabel_P,L2.clistclslabel_P];
try
L3.PLS.Pset.saConc=[L1.PLS.Pset.saConc;L2.PLS.Pset.saConc];
end
try
L3.AclassinfoP_alt=[L1.AclassinfoP_alt;length(unique(L1.AclassinfoP_alt))+L2.AclassinfoP_alt];
end
sd3=ssds(L3);

sd3.saveAT(inp);

out=sd3;
else
   disp('can not merge two Pset, because they have different Tset') 
    
end
disp('done with merge_Pset_with_SameTset_in_XBPL')
end


%% ----- from minmax.m ------------------------------------------------------
function [vals,varargout] = minmax(data,varargin)
%MINMAX  find kth smallest or largest values and their indices.                        
%                                             
% USAGE:
%         vals = minmax(data) % find minimum
%         vals = minmax(data,k) % find kth smallest values
%         vals = minmax(data,k,flag)  % find kth largest values
%         [vals,loci] = minmax(:)  
%         [vals,loci,locj] = minmax(:)  % for 2 d array
%         [vals,loci,locj,...] = minmax(:)  % for multi dimensional array
%                                             
% INPUT:
%    data - two dimensional data                                   
%    k - number of smallest or largest values required
%    flag - whether min or max
%       
% OUTPUT:
%    vals - smallest or largest values                                     
%    loci -  index to the row
%    locj - index to the column
%        
% EXAMPLES:
%    data = 1:16;
%    data = reshape(data,4,4);  
%    [out,loci,locj] = minmax(data,5)  % find the 5 smallest vaues and
%                      their locations
%   [out,loci,locj] = minmax(data,5,'max')  % find the 5 largest vaues and
%                     their locations
% 
% Limitation: 
%             
% See also: minmax_extreme_filter

% Author:Durga Lal Shrestha
% CSIRO Land & Water, Highett, Australia
% eMail: durgalal.shrestha@gmail.com
% Website: www.durgalal.co.cc
% Copyright 2012 Lal Shrestha
% $First created: 27-Jul-2012
% $Revision: 1.0.0 $ $Date: 27-Jul-2012 09:58:33 $

% ***********************************************************************
% INPUT ARGUMENTS CHECK
% error(nargchk(1,3,nargin))
% change prev to the following
narginchk(1,3);

% Default values
k=1;
flag = 'min';

% Input argument check
if nargin>1
    k = varargin{1};
    if nargin>2
        flag = varargin{2};
    end
end
    
% Check if k is positive scalar interger
if ~isscalar(k) || k<=0 || ischar(k)
    error('minmax:k','Second argument "k" should be positive scalar') 
end

sizeData = size(data);
dim = numel(sizeData);
if k > numel(data)
    error('minmax:k','Second argument "k" should be less than number of elements in array')
end

if strcmpi(flag,'min')
    mode = 'ascend'; 
elseif strcmpi(flag,'max')
    mode = 'descend'; 
else
   error('minmax:flag','Does not understand the third argument, should be either "min" or "max"') 
end

if nargout > dim+1
    error('minmax:nargout','Number of output argument shuold be less than dimension of data + 1') 
end
% Calculation
[svals,idx] = sort(data(:),mode);        % sort the array
vals = svals(1:k);                       % kth smallest or largest value
% If location is requested
if nargout >1
    loc = cell(dim,1);    
    [loc{:}] = ind2sub(sizeData,idx(1:k)); 
    varargout = loc;
end 
end
 


%% ----- from mncn.m --------------------------------------------------------
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


%% ----- from mscorr.m ------------------------------------------------------
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

 


%% ----- from normaliz1.m ---------------------------------------------------
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
  


%% ----- from normasmc_trainpk_pred.m ---------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


%% ----- from nsamp_ATsaConc.m ----------------------------------------------
function [nsamp_T  nsamp_P out]=nsamp_ATsaConc(L)
% see also:   nsamp_ATsaConc_wChecking    check_and_try_fix_nsamp_inconsistency_ATsaConc
% get nsamp in PLS type AT or ATsaConc
%     nsamp_T=[nAT nfT nlT nrT ncT];  % Atrainpk % AclassinfoT % AclabelT % RawSpectra Tset % saConc Tset
%
%======================================
    % Tset
    nAT=length(L.Atrainpk(:,1));
    
    nfT=length(L.AclassinfoT(:,1));
    
    try
        nlT=length(L.AclabelT(:,1));
    catch
        nlT=NaN;
    end
    
    if isfield(L,'RawSpectra') && isfield(L.RawSpectra,'Tset')
        nrT=length(L.RawSpectra.Tset(:,1));
    else
        try
            nrT=length(L.RawSpectra(:,1));
        catch
            nrT=NaN;
        end
    end
    
    if isfield(L,'PLS')
        ncT=length(L.PLS.Tset.saConc);
    elseif isfield(L,'saConc')
        ncT=length(L.saConc);
    else
        nrT=NaN;
    end
    
    nsamp_T=[nAT nfT nlT nrT ncT];  % Atrainpk % AclassinfoT % AclabelT % RawSpectra Tset % saConc Tset
    out.VariableNames_Tset={'Atrainpk','AclassinfoT','AclabelT','RawSpectra','saConc'};
    %======================================
    %======================================
    % Pset
    if isfield(L,'Apred')
        nAP=length(L.Apred(:,1));
        
        nfP=length(L.AclassinfoP(:,1));
        
        try
            nlP=length(L.AclabelP(:,1));
        catch
            nlP=NaN;
        end
        
        if isfield(L,'RawSpectra') && isfield(L.RawSpectra,'Pset')
            nrP=length(L.RawSpectra.Pset(:,1));
        else
          nrP=NaN;
        end
        
        if isfield(L,'PLS')
            try
            ncP=length(L.PLS.Pset.saConc);
            catch
            ncP=length(L.Apred(:,1));    
            end
        else
           ncP=NaN;
           error('ATsaConc with Pset but did NOT provide saConc for Pset ?')
        end
        
        nsamp_P=[nAP nfP nlP nrP ncP];  % Apred % AclassinfoP % AclabelP % RawSpectra Pset % saConc Pset
    else
        
        nsamp_P=[NaN];  % this the case with Tset ONLY
        
    end
    
    out.VariableNames_Pset={'Apred','AclassinfoP','AclabelP','RawSpectra','saConc'};
end

    
    %======================================


%% ----- from nsamp_ATsaConc_wChecking.m ------------------------------------
function [nsamp_T  nsamp_P out]=nsamp_ATsaConc_wChecking(L)
% see also: check_and_try_fix_nsamp_inconsistency_ATsaConc  nsamp_ATsaConc
if false

[nsamp_T  nsamp_P out]=nsamp_ATsaConc_wChecking(L);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[nsamp_T_i  nsamp_P_i out_woChecking]=nsamp_ATsaConc(L);

%===============================
qn_i_P=unique(nsamp_P_i  (  ~isnan(nsamp_P_i)  )  );
if length(qn_i_P)>1
    disp_with_border(['misMatch in nsampP ']);
    out.nsamp_match_P=0;
elseif length(qn_i_P)==1
    out.nsamp_match_P=1;
elseif isempty(qn_i_P)
    out.nsamp_match_P=NaN;
else
    error('can not handle this about length(qn_i_P)')
end
%===============================
qn_i_T=unique(nsamp_T_i  (  ~isnan(nsamp_T_i)  ) );
if length(qn_i_T)>1
    if ~isnan(out.nsamp_match_P)
    disp_with_border(['misMatch in nsampT ']);
    else
    disp_with_border(['misMatch in nsamp (Tset Only case) ']);    
    end
    out.nsamp_match_T=0;
elseif length(qn_i_T)==1
    out.nsamp_match_T=1;
else
    error('can not handle this about length(qn_i_T)')
end

%===============================
nsamp_T = nsamp_T_i;
nsamp_P = nsamp_P_i;
%===============================
if ~isnan(out.nsamp_match_P)
out.nsamp_match=out.nsamp_match_T && out.nsamp_match_P ;
else
out.nsamp_match=out.nsamp_match_T;    
end
end
%=====================================

% done_with_this_function;


%% ----- from parse_T_vs_P_in_Clsfr_Tcv_nFolds.m ----------------------------
function [out_objs cpfn_iTcv ]=parse_T_vs_P_in_Clsfr_Tcv_nFolds(pfn_AT,nFolds)
% main function called by ssds method: parse_Clsfr_Tcv_nFolds
% will parse PDS (physically different samples) into different side of T_vs_P and PDS determined by AclabelT or saConc.SamepleName
% can handle both Clsfr or PLS, in the case of PLS, no Tcv_ith-Fold Atrainpketc~.mat file will be generated
% can handle both Clsfr or PLS, in the case of PLS ncls always set to One
%----------------------------------------------------------------------
%  see --> C:\work\JDSU\Test_ACP\Plastics_Recycle\Results_Plastics_Recyle\Prelim BigFive_Apr14_&_27_Self-Predict_&_new code base to deal with Tcv in Classification.pptx
%----------------------------------------------------------------------
% see also: PLS_Tcv
% see also: test_ssds_method_parse_Clsfr_Tcv_nFolds
%=================================================================================
if false
    
    %---------------------------------------------
    % Clsfr
    cc
    % pfn_AT='C:\work\JDSU\Test_ACP\Plastics_Recycle\ATetc_BigFive\Atrainpketc_{BigFive_LS_Apr14}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls6_nsamp1181.mat';
      pfn_AT='C:\work\JDSU\Test_ACP\Plastics_Recycle\ATetc_BigFive\Apr27\Atrainpketc_{BigFive_LS_Apr27}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls6_nsamp1181.mat'
    nFolds=3;
    parse_T_vs_P_in_Clsfr_Tcv_nFolds(pfn_AT,nFolds);
    %------------------------------------------------------
    % PLS
    cc
    pfn_AT='C:\work\JDSU\Test_AQP_PowerUser\datasets_test_rm_replicate_seq_sam\Atrainpketc_{CS_wTS_Caffeine__CS-ONLY_Avg-All}_nvar115_ncls20_nsampT100_nsampP100_pp1-1stDerSGFL7[PO2]_pp2-SNV.mat'
%      pfn_AT= 'C:\work\JDSU\Test_AQP_PowerUser\datasets_test_rm_replicate_seq_sam\Atrainpketc_{CS_wTS_Caffeine__CS-ONLY_Avg-Mean}_nvar115_ncls20_nsampT20_nsampP20_pp1-1stDerSGFL7[PO2]_pp2-SNV.mat'
    nFolds=4;
    parse_T_vs_P_in_Clsfr_Tcv_nFolds(pfn_AT,nFolds);
      %---------------------------------------------
    % Clsfr for SKZ
    cc
      pfn_AT='C:\work\JDSU\Test_ACP\Plastics_Recycle\ATetc_SKZ\SKZ1\Atrainpketc_{SKZ_final_German_LS_May9_SKZ1_SuperClass}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls23_nsamp941.mat'
    nFolds=3;
    parse_T_vs_P_in_Clsfr_Tcv_nFolds(pfn_AT,nFolds);
    
    %---------------------------------------------
     % Clsfr for Acetone
    cc
      pfn_AT='C:\work\JDSU\Test_ACP\Acetone_Measurements\ATetc_Acetone\Atrainpketc_{PATL_Acetone_Data_for_Chang_June15}_pp1-1stDerSGFL7[PO2]_pp2-SNV_nvar119_ncls2_nsamp41.mat'
    nFolds=2;
    parse_T_vs_P_in_Clsfr_Tcv_nFolds(pfn_AT,nFolds);
    
    
    
end
%==================================================================
fig_yes=1;  % show Tcv PDS samples in T_vs_P catergories

if ischar( pfn_AT) && ~isempty(pfn_AT)
    sd0=ssds(pfn_AT);
    if strcmp(sd0.type_Model,'PLS')
        sd0.ncls=1;% can handle both Clsfr or PLS, in the case of PLS ncls always set to One
        fig_yes=1;  % since in the case of PLS, no Tcv_ith-Fold Atrainpketc~.mat file will be generated, will force fig_yes-->1
    end
else
    error('pfn_AT must be a pathfname for Atrainpketc_~.mat file');
end
%--------------------------------------------------------------
% nFolds=floor(sqrt(nSample));
%--------------------------------------------------
if fig_yes
    figure;hold on;
    set(gcf,'position',1000*[  0.3284    0.1851    1.5181    0.5230 ]);
end
%---------------------------------------------
X=sd0.LAT.Atrainpk;
if strcmp(sd0.type_Model,'PLS')
    Y=ones(size( sd0.LAT.AclassinfoT));% can handle both Clsfr or PLS, in the case of PLS ncls always set to One
else
    Y= sd0.LAT.AclassinfoT;
    list_color = cmap_DPR(sd0.ncls);
end

Ylabel=sd0.LAT.AclabelT;
out_objs=[];
cpfn_iTcv=[];
for iQS=1:nFolds
    Atrainpk_iQS=[];
    AclassinfoT_iQS=[];
    AclabelT_iQS=[];
    Apred_iQS=[];
    AclassinfoP_iQS=[];
    AclabelP_iQS=[];
    for jCls=1:sd0.ncls
        if strcmp(sd0.type_Model,'PLS')
            loc_jCls=find(Y==jCls);% can handle both Clsfr or PLS, in the case of PLS ncls always set to One
        else
            loc_jCls=find(sd0.LAT.AclassinfoT==jCls);
        end
        %-------------------
        cSampleName=sd0.LAT.AclabelT( loc_jCls);
        QSample_appear_order= unique_appear_order_cstr(cSampleName);% will parse PDS (physically different samples) into different side of T_vs_P and PDS determined by AclabelT or saConc.SamepleName
        %--------------------
        nSample_jCls=length(QSample_appear_order);
        seq_pad=[1:ceil(nSample_jCls/nFolds)*nFolds];
        seq_pad(seq_pad>nSample_jCls)=NaN;
        idx_table=reshape(seq_pad,[nFolds ceil(nSample_jCls/nFolds) ]);
        loc4P_in_QSample_appear_order=idx_table(iQS,:);
        loc4P_in_QSample_appear_order(isnan(loc4P_in_QSample_appear_order))='';
        loc_P_iQS=loc_jCls(find(ismember(cSampleName,QSample_appear_order(loc4P_in_QSample_appear_order))));
        loc_T_iQS=setdiff(loc_jCls,loc_P_iQS);
        %======================================
         if fig_yes && strcmp(sd0.type_Model,'Clsfr')
         plot(loc_P_iQS,iQS*ones(size( loc_P_iQS)),'color',list_color(jCls,:),'marker','*','linestyle','none');
         end
        %--------------------------------------
        X_P_iQS=X(loc_P_iQS,:);
        Y_P_iQS=Y(loc_P_iQS,:);
        Ylabel_P_iQS=Ylabel(loc_P_iQS,:);
        X_T_iQS=X(loc_T_iQS,:);
        Y_T_iQS=Y(loc_T_iQS,:);
        Ylabel_T_iQS=Ylabel(loc_T_iQS,:);
        %-------------------------------------
        Atrainpk_iQS=[Atrainpk_iQS;X_T_iQS];
        AclassinfoT_iQS=[AclassinfoT_iQS;Y_T_iQS];
        AclabelT_iQS=[AclabelT_iQS ;Ylabel_T_iQS];
        Apred_iQS=[Apred_iQS;X_P_iQS];
        AclassinfoP_iQS=[AclassinfoP_iQS;Y_P_iQS];
        AclabelP_iQS=[AclabelP_iQS ;Ylabel_P_iQS];
        %-----------------------------------
    end      % end of jCls
    %=========================================
    L_iQS.Atrainpk=Atrainpk_iQS;
    L_iQS.AclassinfoT=AclassinfoT_iQS;
    L_iQS.AclabelT=AclabelT_iQS;
    L_iQS.Apred=Apred_iQS;
    L_iQS.AclassinfoP=AclassinfoP_iQS;
    L_iQS.AclabelP=AclabelP_iQS;
    L_iQS.clistclslabel=sd0.LAT.clistclslabel;
    L_iQS.wvl_standardize=sd0.LAT.wvl_standardize;
    %-----------------------------------------------
    if ~strcmp(sd0.type_Model,'PLS')% can handle both Clsfr or PLS, in the case of PLS, no Tcv_ith-Fold Atrainpketc~.mat file will be generated
        sd_iQS=ssds(L_iQS);
        inp4iQS.corename=['{','P-f-',num2str(iQS),'_nF',num2str(nFolds),'_(', find_keyword_between_markers(fileparts_name_ext(pfn_AT),'{','}'),')'  ,'}'];
        sd_iQS=sd_iQS.saveAT( inp4iQS);
        %=======================================
        out_objs=[out_objs; sd_iQS];
        cpfn_iTcv=[cpfn_iTcv ; {sd_iQS.pathfname_AT}  ];
    end
    %======================================
    %         %checking : will parse PDS (physically different samples) into different side of T_vs_P and PDS determined by AclabelT or saConc.SamepleName
    if ~isempty(find(ismember( L_iQS.AclabelT , L_iQS.AclabelP)))
        error('physically same sample(s) reside in both T_iQS and P_iQS');
    else
        if fig_yes
            %             figure;hold on;
            loc_P_iQS=find(ismember(Ylabel,L_iQS.AclabelP));
            
            %-----------------------------------------------
            if strcmp(sd0.type_Model,'PLS')
            plot(loc_P_iQS,iQS*ones(size( loc_P_iQS)),'r*');
            end
            %-----------------------------------------------
        end
    end
    %======================================
end  % end of iQS (nFolds)
if fig_yes
    xlabel('Sample Sequence Number');
    ylabel('ith-Fold');
    enlarge_axis;
    title_usF({[ 'Type of Model --> ',sd0.type_Model ,'    nFolds = ',num2str(nFolds)];[ fileparts_name_ext(pfn_AT) ];['Locations of Pset in Tcv_ith-Fold']});
end

%-----------------------------------------------------------------------------
%=====================================================================

done_with_this_function;
end


%====================================================================


%% ----- from parse_consecutive_sequence_Nfold.m ----------------------------
function out=parse_consecutive_sequence_Nfold(loc_icls,Nfold)
% see example of using this function in --> parse_HBpro_consecutive_sequence.m
% see also example of this above in BatchRun_SnapshotRun_BMS_PPG.m
% 
if false
    parse_consecutive_sequence_Nfold([5:15],3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parse_consecutive_sequence_Nfold([5:16],3)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nsamp=length(loc_icls);
remain=mod(nsamp,Nfold);
NsampEF=(nsamp-remain)/Nfold;
if remain~=0
loc_tall_all=loc_icls([1:(NsampEF+1)*remain]);
loc_short_all=loc_icls([length(loc_tall_all)+1:nsamp]);
mat_tall=reshape(loc_tall_all,[NsampEF+1 remain]);
cmat_tall=mat2cell_CH(mat_tall,'col');
mat_short=reshape(loc_short_all,[NsampEF Nfold-remain]);
cmat_short=mat2cell_CH(mat_short,'col');
cParsedNfold=[cmat_tall,cmat_short];

else
    
cParsedNfold =mat2cell_CH(reshape(loc_icls,[NsampEF Nfold]),'col');  
end
%%%%%%%%%%%%
out=cParsedNfold;

disp('done parse_consecutive_sequence_Nfold');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ----- from parse_physically_different_samples.m --------------------------
function out=parse_physically_different_samples(pathfname_AT,inp)
% this is the main function called by --> sd_PPd.parse_AclabelT_subcls_PDS(inp);
% LAT.AclabelT --> store PDS or Physically Different Samples' name
% LAT.AclabelT_SpectraName --> store each spectrum's detailed filename
% always parsed to leave one PDS out from each class
%
% try to follow these procedures in the following (see prep_Muscle ):
        % sd=ssds(LAT);
        % inp.corename=[fileparts_name_wo_ext(pathfname_rawdata)];;
        % sd_PPd=apply_PP(sd,inp);
        %  inp.smk1='_P';inp.smk2='';
        %  sd_PPd.parse_AclabelT_subcls_PDS(inp);
% see     prep_Muscle.m and ssds method parse_AclabelT_subcls_PDS for example of using this method    
% see also  sd.parse_AclabelT_subcls_PDS  prep_Muscle, ssds, and Atrainpk_parse_AclabelT_subcls
% see also prep_ResinKits_Molecules_J_rk_4_5_6_3N1(pathfname)
if false
    
    clear
    %pathfname_AT='C:\work\JDSU\CUSTOMERS\Muscle\data_LanSun\ATetc\Atrainpketc_Muscle_Triceps_LMH_Conc.mat'
    pathfname_AT='C:\work\JDSU\CUSTOMERS\Muscle\data_LanSun\ATetc\Atrainpketc_Muscle_Triceps_pp1-1stDerSGFL7[PO2]_LMH_Conc.mat'
    parse_physically_different_samples(pathfname_AT)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smk4PDS=inp.smk1;

LAT=load(pathfname_AT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAT.AclabelT_SpectraName=LAT.AclabelT;%% save orig AclabelT for Molecules J ResinKits dataset sKsU case


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 
% L.AclabelT_SpectraName
% LAT.AclabelT=textual_extractBetween( LAT.AclabelT_SpectraName,'','-');
if false
LAT.AclabelT=textual_extractBetween( LAT.AclabelT_SpectraName,'-',''); %updated Jan 16, 2019 for "Muscle" dataset
end

try
    % LAT.AclabelT=textual_extractBetween( LAT.AclabelT_SpectraName,'','_o'); %for Molecules J ResinKits dataset sKsU case
    % AclabelT_smk=textual_extractBetween( LAT.AclabelT,inp.smk1,inp.smk2);
    AclabelT_smk=textual_extractBetween( LAT.AclabelT_SpectraName,inp.smk1,inp.smk2);
catch
    AclabelT_smk=textual_extractBetween( LAT.AclabelT,inp.smk1,inp.smk2);% for prep_ResinKits_Unit2Unit_Repeatability_Performance() Aug 15, 2020
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check to make sure there are at least two PDS: Physically Different
% Samples in each class

nPDS=[];  % this is very important and will be needed below at [sd_parsed]=parse_AclabelT_subcls(sd,inp);
for icls=1:length(LAT.clistclslabel)
%  [qPDS_i nPDS_i]=unique_count(LAT.AclabelT(find(LAT.AclassinfoT==icls))); 
  [qPDS_i nPDS_i]=unique_count(AclabelT_smk(find(LAT.AclassinfoT==icls)));  
nPDS=[nPDS;length(qPDS_i)];
end


if ~all(nPDS>1)
  error('there are some classes have less than two PDS');
else
    disp('all classes have at two PDS hence it is OK to proceed')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if false  % following not needed anymore, CH March 29, 2019
%     for icls=1:length(LAT.clistclslabel)
%         loc_LC=find(LAT.AclassinfoT==icls);
%         qps_LC=unique_appear_order_cstr(LAT.AclabelT(loc_LC));
%         for iq_clsi=1:length(qps_LC)
%             loc_iq_clsi= find(strcmp(LAT.AclabelT,qps_LC{iq_clsi}))  ;
%             LAT.AclabelT(loc_iq_clsi)=cellstr(string(LAT.AclabelT(loc_iq_clsi))+[smk4PDS,num2str(iq_clsi)]);
%         end
%     end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LAT.AclabelT=LAT.AclabelT_SpectraName; % % go back to orig AclabelT for Molecules J ResinKits dataset sKsU case
%  LAT.AclabelT_SpectraName=LAT.AclabelT; % %for Molecules J ResinKits dataset sKsU case

sd=ssds(LAT);
inp.corename=find_keyword_between_markers(   fileparts_name_wo_ext(pathfname_AT),'Atrainpketc_','_nvar');
if isempty(inp.corename)
 inp.corename=find_keyword_between_markers(   fileparts_name_wo_ext(pathfname_AT),'Atrainpketc_','');
end
if strcmp(inp.corename(1),'_')
inp.corename(1)=[];
end
% inp.smk1='_P';inp.smk2='';
inp.Nsubcls4T=min(nPDS)-1; % always parsed to leave one PDS out from each class
[sd_parsed]=parse_AclabelT_subcls(sd,inp);
out=sd_parsed;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('done with parse_physically_different_samples')
end


%% ----- from permn.m -------------------------------------------------------
function [M, I] = permn(V, N, K)
% see also Atrainpk_parse_AclabelT_subcls parse_HBpro_consecutive_sequence
% see also npermutek (permutations without repetitions)
if false
    % for example for CV of 4-folds with 3 classes (i.e. 3 distinct BP in
    % MIMIC-III)
    M1 = permn([1 2 3 4],3) % returns the 64-by-3 matrix
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % for example for CV of 3-folds with 2 classes (i.e. 2 distinct BP in
    % MIMIC-III)
    M2 = permn([1 2 3 ],2) % returns the 9-by-2 matrix
end
% PERMN - permutations with repetition
%   Using two input variables V and N, M = PERMN(V,N) returns all
%   permutations of N elements taken from the vector V, with repetitions.
%   V can be any type of array (numbers, cells etc.) and M will be of the
%   same type as V.  If V is empty or N is 0, M will be empty.  M has the
%   size numel(V).^N-by-N. 
%
%   When only a subset of these permutations is needed, you can call PERMN
%   with 3 input variables: M = PERMN(V,N,K) returns only the K-ths
%   permutations.  The output is the same as M = PERMN(V,N) ; M = M(K,:),
%   but it avoids memory issues that may occur when there are too many
%   combinations.  This is particulary useful when you only need a few
%   permutations at a given time. If V or K is empty, or N is zero, M will
%   be empty. M has the size numel(K)-by-N. 
%
%   [M, I] = PERMN(...) also returns an index matrix I so that M = V(I).
%
%   Examples:
%     M = permn([1 2 3],2) % returns the 9-by-2 matrix:
%              1     1
%              1     2
%              1     3
%              2     1
%              2     2
%              2     3
%              3     1
%              3     2
%              3     3
%
%     M = permn([99 7],4) % returns the 16-by-4 matrix:
%              99     99    99    99
%              99     99    99     7
%              99     99     7    99
%              99     99     7     7
%              ...
%               7      7     7    99
%               7      7     7     7
%
%     M = permn({'hello!' 1:3},2) % returns the 4-by-2 cell array
%             'hello!'        'hello!'
%             'hello!'        [1x3 double]
%             [1x3 double]    'hello!'
%             [1x3 double]    [1x3 double]
%
%     V = 11:15, N = 3, K = [2 124 21 99]
%     M = permn(V, N, K) % returns the 4-by-3 matrix:
%     %        11  11  12
%     %        15  15  14
%     %        11  15  11
%     %        14  15  14
%     % which are the 2nd, 124th, 21st and 99th permutations
%     % Check with PERMN using two inputs
%     M2 = permn(V,N) ; isequal(M2(K,:),M)
%     % Note that M2 is a 125-by-3 matrix
%
%     % PERMN can be used generate a binary table, as in
%     B = permn([0 1],5)  
%
%   NB Matrix sizes increases exponentially at rate (n^N)*N.
%
%   See also PERMS, NCHOOSEK
%            ALLCOMB, PERMPOS on the File Exchange
% tested in Matlab 2016a
% version 6.1 (may 2016)
% (c) Jos van der Geest
% Matlab File Exchange Author ID: 10584
% email: samelinoa@gmail.com
% History
% 1.1 updated help text
% 2.0 new faster algorithm
% 3.0 (aug 2006) implemented very fast algorithm
% 3.1 (may 2007) Improved algorithm Roger Stafford pointed out that for some values, the floor
%   operation on floating points, according to the IEEE 754 standard, could return
%   erroneous values. His excellent solution was to add (1/2) to the values
%   of A.
% 3.2 (may 2007) changed help and error messages slightly
% 4.0 (may 2008) again a faster implementation, based on ALLCOMB, suggested on the
%   newsgroup comp.soft-sys.matlab on May 7th 2008 by "Helper". It was
%   pointed out that COMBN(V,N) equals ALLCOMB(V,V,V...) (V repeated N
%   times), ALLCMOB being faster. Actually version 4 is an improvement
%   over version 1 ...
% 4.1 (jan 2010) removed call to FLIPLR, using refered indexing N:-1:1
%   (is faster, suggestion of Jan Simon, jan 2010), removed REPMAT, and
%   let NDGRID handle this
% 4.2 (apr 2011) corrrectly return a column vector for N = 1 (error pointed
%    out by Wilson).
% 4.3 (apr 2013) make a reference to COMBNSUB
% 5.0 (may 2015) NAME CHANGED (COMBN -> PERMN) and updated description,
%   following comment by Stephen Obeldick that this function is misnamed
%   as it produces permutations with repetitions rather then combinations.
% 5.1 (may 2015) always calculate M via indices
% 6.0 (may 2015) merged the functionaly of permnsub (aka combnsub) and this
%   function
% 6.1 (may 2016) fixed spelling errors
narginchk(2,3) ;
if fix(N) ~= N || N < 0 || numel(N) ~= 1 ;
    error('permn:negativeN','Second argument should be a positive integer') ;
end
nV = numel(V) ;
if nargin==2, % PERMN(V,N) - return all permutations
    
    if nV==0 || N == 0,
        M = zeros(nV,N) ;
        I = zeros(nV,N) ;
        
    elseif N == 1,
        % return column vectors
        M = V(:) ;
        I = (1:nV).' ;
    else
        % this is faster than the math trick used for the call with three
        % arguments.
        [Y{N:-1:1}] = ndgrid(1:nV) ;
        I = reshape(cat(N+1,Y{:}),[],N) ;
        M = V(I) ;
    end
else % PERMN(V,N,K) - return a subset of all permutations
    nK = numel(K) ;
    if nV == 0 || N == 0 || nK == 0
        M = zeros(numel(K), N) ;
        I = zeros(numel(K), N) ;
    elseif nK < 1 || any(K<1) || any(K ~= fix(K))
        error('permn:InvalidIndex','Third argument should contain positive integers.') ;
    else
        
        V = reshape(V,1,[]) ; % v1.1 make input a row vector
        nV = numel(V) ;
        Npos = nV^N ;
        if any(K > Npos)
            warning('permn:IndexOverflow', ...
                'Values of K exceeding the total number of combinations are saturated.')
            K = min(K, Npos) ;
        end
             
        % The engine is based on version 3.2 with the correction
        % suggested by Roger Stafford. This approach uses a single matrix
        % multiplication.
        B = nV.^(1-N:0) ;
        I = ((K(:)-.5) * B) ; % matrix multiplication
        I = rem(floor(I),nV) + 1 ;
        M = V(I) ;
    end
end
end
% Algorithm using for-loops
% which can be implemented in C or VB
%
% nv = length(V) ;
% C = zeros(nv^N,N) ; % declaration
% for ii=1:N,
%     cc = 1 ;
%     for jj=1:(nv^(ii-1)),
%         for kk=1:nv,
%             for mm=1:(nv^(N-ii)),
%                 C(cc,ii) = V(kk) ;
%                 cc = cc + 1 ;
%             end
%         end
%     end
% end


%% ----- from plot_hline.m --------------------------------------------------
function [hphl hthl ]=plot_hline(locY,sColor,inp )
% plot horizontal lines based on axis(1) and axis(2) with option adding label
% see also plot_vline, gridxy, hline, vline, crossing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==1
    sColor='o';
end
%====================
if exist('inp','var') && isfield(inp,'demoONLY') && inp.demoONLY==1
    error('the following is only for "Evaluate Selection"');
 %%%%%%%%%%%%%%%%   
 figure;hold on;
 plot([1:100],[1:100],'b-*');
 loc_R00=10;
 inp_plot_hline.label='R00';
 [ hpvl_loc_R00 htvl_loc_R00 ]=plot_hline(loc_R00,'m',inp_plot_hline);

 %%%%%%%%%%%%%%%%   
end


if  exist('inp','var')&& isfield(inp,'hgca')&& ~isempty(inp.hgca)
    ax=axis(inp.hgca);
else
    ax=axis;
end

try
    lw=inp.linewidth;
catch
   lw=2; 
end


for i_hvl=1:length(locY)
    if length(sColor)==length(locY)
        sColor_i=sColor(i_hvl);
    elseif length(sColor)==1
        sColor_i=sColor;
    else
        error('length of sColor  should matched with locY or equal to one')
    end
    
    hphl(i_hvl)=plot([ax(1) ax(2)],[locY(i_hvl) locY(i_hvl)],'color',color_CH(sColor_i),'linewidth',lw);
    %%%%%%%%%%%%%%%%%%%
    if exist('inp','var') && isfield(inp,'label')&& ~isempty(inp.label)
        
        if ischar(inp.label)
            % Note that are more than one handles in following results
            hthl(i_hvl).htext=    text([ax(1) ax(2)],[locY(i_hvl) locY(i_hvl)],inp.label,'color',sColor_i);
            
        elseif iscell(inp.label)
            % checking
            if length(inp.label)~=length(locY) && length(inp.label)~=1
                error('number of entries in inp.label should matched with locY or equal to one')
            elseif  length(inp.label)==length(locY)
                 % Note that are more than one handles in following results
                hthl(i_hvl).htext=   text([ax(1) ax(2)],[locY(i_hvl) locY(i_hvl)],inp.label{i_hvl},'color',sColor_i);
                
            elseif  length(inp.label)==1
                 % Note that are more than one handles in following results
                hthl(i_hvl).htext=   text([ax(1) ax(2)],[locY(i_hvl) locY(i_hvl)],inp.label{1},'color',sColor_i);
                
            end
            
        else
            error('inp.label must be either char or cell')
        end
    else
        hthl=[];
        
    end
    %%%%%%%%%%%%%%%%%%%
    
    
end
end


%% ----- from plot_vline.m --------------------------------------------------
function [hpvl htvl ]=plot_vline(locX,sColor,inp )
%  plot vertical lines based on axis(3) and axis(4) with option adding label
% see also  plot_vline_stem,  plot_hline, gridxy,  hline, vline, crossing, vline_HW, hline_HW
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist('inp','var') && isfield(inp,'demoONLY') && inp.demoONLY==1
    error('the following is only for "Evaluate Selection"');
 %%%%%%%%%%%%%%%%   
 figure;hold on;
 plot([1:100],[1:100],'b-*');
 loc_R00=10;
 inp_plot_vline.label='R00';
  inp_plot_vline.fontsize=6;inp_plot_vline.TopLabelShiftRatio=0.03;
 [ hpvl_loc_R00 htvl_loc_R00 ]=plot_vline(loc_R00,'m',inp_plot_vline);
 %%%%%%%%%%%%%%%%%
 
 
 
 
 

 %%%%%%%%%%%%%%%%   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  inp_linewidth =inp.linewidth;
catch
 inp_linewidth=2;   % change default to 2 to match with plot_hline
end
try
  inp_linestyle =inp.linestyle;
catch
  inp_linestyle='-';   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try 
    txtFontSize=inp.fontsize;
catch
    txtFontSize=8; %default font size
end
try
TopLabelShiftRatio=inp.TopLabelShiftRatio;
catch
 TopLabelShiftRatio=0;   
end
%%%%%%%%%%%%%%
try
TopLabel_Only_yes=inp.TopLabel_Only_yes;
catch
TopLabel_Only_yes=0;    
end
%%%%%%%%%%%%%%%
if exist('inp','var')&& isfield(inp,'hgca')&& ~isempty(inp.hgca)
    ax=axis(inp.hgca);
else
    ax=axis;
end




for i_hvl=1:length(locX)
    if length(sColor)==length(locX)
        sColor_i=sColor(i_hvl);
    elseif length(sColor)==1
        sColor_i=sColor;
    else
        error('length of sColor  should matched with locX or equal to one')
    end
    
    hpvl(i_hvl)=plot([locX(i_hvl) locX(i_hvl)],[ax(3) ax(4)],'color',color_CH(sColor_i),'linewidth',inp_linewidth,'linestyle',inp_linestyle);
    %%%%%%%%%%%%%%%%%%%
    if exist('inp','var') && isfield(inp,'label')&& ~isempty(inp.label)
        
        if ischar(inp.label)
            % Note that are more than one handles in following results
             if TopLabel_Only_yes
            htvl(i_hvl).htext=    text([locX(i_hvl) ],[ax(4)-TopLabelShiftRatio*(ax(4)-ax(3))],inp.label,'color',color_CH(sColor_i),'fontsize',txtFontSize,'interpreter','none');
             else
            htvl(i_hvl).htext=    text([locX(i_hvl) locX(i_hvl)],[ax(3) ax(4)-TopLabelShiftRatio*(ax(4)-ax(3))],inp.label,'color',color_CH(sColor_i),'fontsize',txtFontSize,'interpreter','none');
             end
             
        elseif iscell(inp.label)
            % checking
            if length(inp.label)~=length(locX) && length(inp.label)~=1
                error('number of entries in inp.label should matched with locX or equal to one')
            elseif  length(inp.label)==length(locX)
                 % Note that are more than one handles in following results
%                 htvl(i_hvl).htext=   text([locX(i_hvl) locX(i_hvl)],[ax(3) ax(4)],inp.label{i_hvl},'color',color_CH(sColor_i),'fontsize',txtFontSize);
               if TopLabel_Only_yes
               htvl(i_hvl).htext=   text([locX(i_hvl)],[ax(4)-TopLabelShiftRatio*(ax(4)-ax(3))],inp.label{i_hvl},'color',color_CH(sColor_i),'fontsize',txtFontSize,'interpreter','none');
               else
               htvl(i_hvl).htext=   text([locX(i_hvl) locX(i_hvl)],[ax(3) ax(4)-TopLabelShiftRatio*(ax(4)-ax(3))],inp.label{i_hvl},'color',color_CH(sColor_i),'fontsize',txtFontSize,'interpreter','none');
               end
               
               
            elseif  length(inp.label)==1
                 % Note that are more than one handles in following results
                 
                 if TopLabel_Only_yes
                htvl(i_hvl).htext=   text([locX(i_hvl) ],[ax(4)-TopLabelShiftRatio*(ax(4)-ax(3))],inp.label{1},'color',color_CH(sColor_i),'fontsize',txtFontSize,'interpreter','none');
                 else
                htvl(i_hvl).htext=   text([locX(i_hvl) locX(i_hvl)],[ax(3) ax(4)-TopLabelShiftRatio*(ax(4)-ax(3))],inp.label{1},'color',color_CH(sColor_i),'fontsize',txtFontSize,'interpreter','none');
   
                 end
            end
            
        else
            error('inp.label must be either char or cell')
        end
    else
        htvl=[];
        
    end
    %%%%%%%%%%%%%%%%%%%
    
    
end
end


%% ----- from plot_wDataTip.m -----------------------------------------------
function plot_wDataTip(hp,inp)
% this will handle hp contains multiple "Line" and each line shows same datatip
%  only different lines show different datatips
%-----------------------------------------------
% add this to SVMnose, revisit Apr 6, 2024
%--------------------------------------------------------------------
% see one of input formats below (example #2)
% i.e. contain two fields --> sDataTip sDataTip_prefix
% inp = 
% 
%   struct with fields:
% 
%            sDataTip: {144×1 cell}
%     sDataTip_prefix: 'OSW-'
%------------------------------------------------------------------
% see also : PCA_trajectory_MBCPSS_3D_Standalone
% see also: findclosestCurve_barebone  findclosestCurve_autoscaled  findclosestCurve_autoscaled_barebone
% see also: fpred_analysis_ui  ginput
% see also: plot_wDataTip_singleLine ( this will handle hp contains just single "Line")
%------------------------------------------------------------------
% add this to SVMnose, revisit Apr 6, 2024
% see also: create_spectra_plot_from_CmpSpectra_4ssds
%==================================================================
if false
    
    %------------------------------------------
    cc
    figure;hold on;
    y=[rand(5);rand(5)*2];
    x=[1:length(y(1,:))];
    hp=plot(x,y,'g-O');
    inp.sDataTip='SampSeq';
    plot_wDataTip(hp,inp)
    %------------------------------------------
    % example #2
    cc
    %    L=load( 'C:\work\JDSU\Manuf_U2U\Test-mU2U\ATetc_production_MN_wcrStd\SVM\2nd_example_nsamp150\T-OE(ALL)\P-OL\Atrainpketc_production-MN_wcrStd_2nd_example_nsamp150_{T-OSW-OE(ALL)_P-OSW-Outlier-M1-0000109}_pp1-SNV_nsampT138_nsampP6.mat');
    L=load( 'C:\work\JDSU\Manuf_U2U\Test-mU2U\ATetc_production_MN_wcrStd\SVM\2nd_example_nsamp150\T-OE(ALL)\P-OL\Atrainpketc_production-MN_wcrStd_2nd_example_nsamp150_{T-OSW-OE(ALL)_P-OSW-Outlier-M1-1000100}_pp1-SNV_nsampT138_nsampP6.mat');
    
    y=[L.Atrainpk;L.Apred];
    x=[1:length(y(1,:))];
    figure;hold on;
    hp=plot(x,y,'b-');
    % inp.sDataTip='SampSeq';
    inp.sDataTip=[L.AclabelT;L.AclabelP];
    inp.sDataTip_prefix='OSW-';
    plot_wDataTip(hp,inp)
    %--------------------------------------------------
    % potentially revisit this for iACP_mp project diagnosis purpose, Dec 2022
    %
    %------------------------------------------------
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % example #3
    % add this to SVMnose, revisit Apr 6, 2024
    % see also: create_spectra_plot_from_CmpSpectra_4ssds
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
end
%--------------------------------------------------------------------------------
%  hp_PCA_R_PSS=plot3(PC1_R,PC2_R,PC3_R,'b-x');
%=================================================
% add TS as DataTips to PSS stage, Jan 27, 2022
% see --> https://www.mathworks.com/help/matlab/creating_plots/create-custom-data-tips.html
%-----------------------------------------------------------------
try
    sDataTip_prefix =   inp.sDataTip_prefix;
catch
    sDataTip_prefix = '';
end
%---------------------------------------------------------------------
for ihp=1:length(hp)
    hp(ihp).DataTipTemplate.DataTipRows(2:end)=[];
    
    if ischar(inp.sDataTip)
        hp(ihp).DataTipTemplate.DataTipRows(1).Label=[inp.sDataTip,'='];
        row = dataTipTextRow(inp.sDataTip,ones(size(hp(ihp).XData))*ihp);
    elseif iscell(inp.sDataTip )
        hp(ihp).DataTipTemplate.DataTipRows(1).Label=[ sDataTip_prefix,'=']   ;
        row = dataTipTextRow( sDataTip_prefix, repmat( inp.sDataTip(ihp),size( hp(ihp).XData))    );
    else
        error('format of inp.sDataTip Not supported');
    end
    % row = dataTipTextRow('TS',inp.TS);
    
    hp(ihp).DataTipTemplate.DataTipRows(1) = row;
end
end
%==================================================


%% ----- from preprocess_NIR_spectra.m --------------------------------------
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


%% ----- from pretreat_preprocess_RawSpectra_pp1_pp2_AT_TP.m ----------------
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
 


%% ----- from regexp_extract_mk1_mk2.m --------------------------------------
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

%======================================================================
%======================================================================


%% ----- from remove_keyword_between_markers.m ------------------------------
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


%% ----- from remove_keyword_between_markers_wlistRHS.m ---------------------
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


%% ----- from replace_CH.m --------------------------------------------------
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


%% ----- from rm_samps_AT.m -------------------------------------------------
function out=rm_samps_AT(pathfname_AT,inp)
% out is a ssds object
% deal with missing classes in Tset after certain samples have been removed, Aug 31, 2023
%=====================================================================================
if false
    
    clear;close all
   pathfname_AT= 'C:\work\JDSU\ILCQ\Test_ILCQ\ATsaConc\Atrainpketc_GlobalClsfrModel_nSubj4_ncls11_nvar75_nsamp744.mat';
   Lrm=load('C:\work\JDSU\ILCQ\Results_ILCQ\ALL_loc_misP_i_ip_Global_nsamp744_ILM_NmisP12.mat');
   inp.loc_rm=Lrm.ALL_loc_misP_i_ip_Global;
   out=rm_samps_AT(pathfname_AT,inp)
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
  % save('ALL_loc_misP_i_ip_Global_nsamp1007_ILM_NmisP17.mat','-struct','Out')
   clear;close all
%    pathfname_AT= 'C:\work\JDSU\ILCQ\Test_ILCQ\ATsaConc\Atrainpketc_GlobalClsfrModel_nSubj5_ncls14_nvar75_ncls14_nsamp1007.mat'
%    Lrm=load('C:\work\JDSU\ILCQ\Results_ILCQ\ALL_loc_misP_i_ip_Global_nsamp1007_ILM_NmisP17.mat')
   pathfname_AT= 'C:\work\JDSU\ILCQ\Test_ILCQ\ATsaConc\Atrainpketc_GlobalClsfrModel_nSubj5_ncls13_nvar75_ncls13_nsamp922.mat'
   Lrm=load('C:\work\JDSU\ILCQ\Test_ILCQ\ParseTP\IL2Q\Global_loc_RmOLs\ALL_loc_misP_i_ip_Global_Msubj5_ILM[nLcls2]_nsamp922_NmisP12.mat')
   inp.loc_rm=Lrm.ALL_loc_misP_i_ip_Global;
   out=rm_samps_AT(pathfname_AT,inp)
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
change_AclassinfoT_yes = inp.change_AclassinfoT_yes;% in this setting of "1" , created AT may Not be able to serve as Pset for original clistclslabel   
catch
change_AclassinfoT_yes=0;  % in this setting of "0" , created AT may only be able to serve as Pset for original clistclslabel    
end
%----------------------------------------------
L=load(pathfname_AT);
rm=inp.loc_rm;
L1=L;
L1.Atrainpk(rm,:)=[];
L1.AclassinfoT(rm,:)=[];
%----------------------------------------------------------------------
if change_AclassinfoT_yes
    % check to see if all classes exist in Tset
    % deal with missing classes in Tset after certain samples have been removed, Aug 31, 2023
    [qt nt]=unique_count(L1.AclassinfoT);
    qt_orig=col_always([1:max(L.AclassinfoT)]);
    qt_Rm=setdiff(qt_orig,qt);
    qt_new=col_always([1:length(qt)]);
    L1.clistclslabel(qt_Rm )=[];
    L1.AclassinfoT=replace_CH(L1.AclassinfoT,qt,qt_new  );
    if ~isempty(qt_Rm )% deal with missing classes in Tset after certain samples have been removed, Aug 31, 2023
        
        Speak_mk(['following class number have been removed : ',num2str(row_always(qt_Rm))]);
        disp_with_border( ['following class number have been removed : ',num2str(row_always(qt_Rm))]);
        Speak_mk(['class sequence number have been changed']);
        disp_with_border(['class sequence number (i.e. AclassinfoT) have been changed']);
    end
end
%----------------------------------------------------------------------
try
 L1.AclassinfoT_alt(rm,:)=[];   %deal with ILCQ XBPL cases
end

try
L1.AclabelT(rm,:)=[];
end
%-------------------------------------------
% add following June 5, 2023
try
L1.AclabelT_alt(rm,:)=[];
end
try
L1.AclabelT_MID(rm,:)=[];
end
try
L1.AclabelT_SupCls(rm,:)=[];
end
%--------------------------------------------

%-------------------------------------------------------------------------------------
% see Rm_select_samps_AclabelT_wRepSeq, and "AclabelT_wRepSeq" is a reserved word created by tag_AclabelT_ReplicateSeq
%  updated Jan 31, 2021
%
try
    if length(L1.AclabelT_wRepSeq)==length(L.AclassinfoT)
    L1.AclabelT_wRepSeq(rm,:)=[];
    end
end
%-----------------------------------------------------------------------------------
try
L1.saConc(rm,:)=[];
end
try
L1.RawSpectra(rm,:)=[];
end
srmOLs=['_','rm',num2str(length(rm)),'OLs'];
% srmOLs=['_','rm',num2str(length(rm)),'samps'];
if isfield(inp,'corename')&& ~isempty(inp.corename)
srmOLs =['_', strrep(inp.corename,'}',[srmOLs,'}'])];
end
fname_new=fileparts_name_ext(pathfname_AT);
fname_new=textual_replaceBetween_multiple_kw2(fname_new,'_nsamp',{'_','.mat'},num2str(length(L1.AclassinfoT)));
fname_new=strrep(fname_new,'_nvar',[srmOLs,'_nvar']);
fname_new=strrep(fname_new,'__','_');
save(fname_new,'-struct','L1');
disp([fname_new,' has been saved !'])
% out.pathfname_new=fname_new;
out=ssds(fname_new);

disp('done with rm_samps_AT()') 
end


%% ----- from rmfield_AclabelP_AclassinfoP_etc.m ----------------------------
function out=rmfield_AclabelP_AclassinfoP_etc(LAT)
% see also: ssds_method_rm_Pset
%++++++++++++++++++++++++++++++++++++++++++++++++++++
% add this May 21, 2024
cfdn=fieldnames(LAT);% add this May 21, 2024
% LAT=rmfield(LAT,cfdn(loc_AcP ));% add this May 21, 2024
loc_AclassinfoP=strmatch('AclassinfoP',cfdn);% add this May 21, 2024
loc_AclabelP=strmatch('AclabelP',cfdn);% add this May 21, 2024
LAT=rmfield(LAT,cfdn([loc_AclassinfoP;loc_AclabelP ]));% add this May 21, 2024
out=LAT;
end


%% ----- from roundns.m -----------------------------------------------------
% ------------------------------------------------------------- roundn(x,d)
% ROUNDNS(x,d) returns str of x rounded to d digits.
%
%    If d is not given, then d = 0 is assumed.
%
% See also:
%   ROUND   ROUNDN
% -------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = roundns(x,d)


if false
    %%%%%%%%%%%%%%%%
    roundns(2.3348,3)
    
   %%%%%%%%%%%%%%%%%%%%% 
     roundns(2.3343)
   %%%%%%%%%%%%%%%%%%%%%%%
   
    roundns(2.5543)
   %%%%%%%%%%%%%%%%%%%%%%%
   
   
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 1
    y = round(x);
    y=deblank(num2str(y));

else
   
    y = round(10^d*x)/10^d;
    y=deblank(num2str(y));
      
end
end


%% ----- from row_always.m --------------------------------------------------
function rowvector=row_always(inputvector)
% can handle either 1D numeric array or cell array
% see also col_always
% e.g. row_always([1 2 3])
% e.g. row_always([1 ;2 ;3])
% e.g. row_always({'ab';'bcd';'efgg'})
% e.g. row_always([1 2 3; 4 5 6])
%
%%%%%%%%%%%%%%%%%%%%%
size_inputvector=size(inputvector);
if isempty(inputvector)
    rowvector=inputvector;
elseif  size_inputvector(1)>1 & size_inputvector(2)>1
    error('inputvector is not a 1D vector');
else
    if size_inputvector(1)>1
       rowvector=inputvector';
    else
         rowvector=inputvector;
    end
end
end


%% ----- from row_vector_ALWAYS.m -------------------------------------------
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


%% ----- from saConc2XY.m ---------------------------------------------------
function [X_iAna Y_iAna  cSampleName]=saConc2XY(saConc,AnaName)
idx_CurAna= arrayfun(@(x) strcmp(x.clsname,AnaName),saConc);
X_iAna=cell2mat(arrayfun(@(x) x.Atrainpk, saConc(idx_CurAna),'un',0));
Y_iAna=cell2mat(arrayfun(@(x) repmat(x.Conc,[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
cSampleName=cell_unwrap(arrayfun(@(x) repmat({x.SampleName},[length(x.Atrainpk(:,1)) 1]), saConc(idx_CurAna),'un',0));
end


%% ----- from savitzkyGolay.m -----------------------------------------------
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


%% ----- from savitzkyGolayFilt.m -------------------------------------------
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


%% ----- from scale.m -------------------------------------------------------
function sx = scale(x,means,stds)
%SCALE Scales matrix as specified.
%  Scales a matrix (x) using means (mx) and standard 
%  deviations (stds) specified.
%
%I/O format is:  sx = scale(x,mx,stdx);
%
%  If only two input arguments are supplied then the function
%  will not do variance scaling, but only vector subtraction.
%
%I/O format is:  sx = scale(x,mx);
%
%See also: AUTO, MDAUTO, MDMNCN, MDRESCAL, MDSCALE, MNCN, RESCALE

%Copyright Eigenvector Research, Inc. 1991-98
%Modified 11/93 
%Checked on MATLAB 5 by BMW  1/4/97

[m,n] = size(x);
if nargin == 3
  sx = (x-means(ones(m,1),:))./stds(ones(m,1),:);
else
  sx = (x-means(ones(m,1),:));
end
end


%% ----- from set_XTickLabel.m ----------------------------------------------
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


%% ----- from set_XTick_etc.m -----------------------------------------------
function set_XTick_etc(h_axes,clistxticklabel,deg,fontsize)
% this version is better than --> rotate_xticklabel_anydeg(clistxticklabel,deg,fontsize)
%  typically use gca for h_axes as input to this function
%
% use \newline to parse each XTickLabel into two lines 
% see for example -->    summary_iACP_wPP     cmp_HFA_ILCQ_RMSEP_etc
% 
if false
    
    figure;plot([1:10],'r-*');
    clistxticklabel=cellstr("xtick"+[11:20]);
    set_XTick_etc(gca,clistxticklabel,-45,8) ;   % note that use "gca" as 1st input
    grid on;

end
%=============================================================================================
set(h_axes,'XTick',[1:length(clistxticklabel)], 'XTickLabel', clistxticklabel,'XTickLabelRotation',deg,'fontsize',fontsize);
end


%% ----- from setup_ShowLabel_findclosestCurve_RS_AT_gui.m ------------------
function setup_ShowLabel_findclosestCurve_RS_AT_gui(pathfname_AT,inp)
% this is typically called by ssds method --> sd.diagnose_Clsname_PushButton(inp)
% this will call  --> create_spectra_plot_from_CmpSpectra_4ssds
%
% set to activate --> activate_PickSpectra_GUI_yes or activate_Clsname_CmpSpectra_gui_yes
% see also show_line_in_figure  ShowLabel_findclosestCurve_RS_AT_gui  prep_GreenWall
% see also ssds method : diagnose_Clsname_PushButton
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% revisit following subfunction/functions for visualization tools in ABU or BH studies, Dec 7, 2021
% SVM_gui.m in SVMnose --> its own subfuntion --> FeatMat_Callback
% FeatMat_Callback   --> sd.diagnose_Clsname_PushButton(inp);
%    sd.diagnose_Clsname_PushButton(inp)  -->   setup_ShowLabel_findclosestCurve_RS_AT_gui          
%       setup_ShowLabel_findclosestCurve_RS_AT_gui  -->     create_spectra_plot_from_CmpSpectra_4ssds
%           create_spectra_plot_from_CmpSpectra_4ssds -->   pushbutton --> Clsname_CmpSpectra_gui_4ssds()
%                                                                                                      h_uicntl_clsname = uicontrol('style','pushbutton', ...
%                                                                                                        'string', FigNUserData.TPinfo_loaded.clistclslabel{icls}, 'callback', ...
%                                                                                                          'Clsname_CmpSpectra_gui_4ssds', ...
%                                                                                                            'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [0.9 loc_ui_clsname(icls) .08 ht_pb],'ForegroundColor',list_color_DPR(icls,:));
%====================================================================================================================================================
% revisit for plotting SNV-RawSpectra, Sept 12, 2023
% see also: FeatMat_Callback inside SVM_gui.m
%-----------------------------------------------------------------
% add following to create DataTip for SVMnose, Apr 6, 2024
%=============================================================================
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 try
 SNV_RS_yes=inp.SNV_RS_yes   ;    % revisit for plotting SNV-RawSpectra, Sept 12, 2023
 catch
 SNV_RS_yes=0;                   % default for SNV_RS_yes
 end
%-------------------------------------------------------------------------
if false
    
    close all;clear;
    inp.pick_method='Clsname_PushButton';
    inp.Spectra_Type='RawSpectra';
    pathfname_AT='C:\work\JDSU\CUSTOMERS\GreenWall\ATetc\Atrainpketc_GreenWall_nvar121_ncls6_nsamp252_pp1-1stDerSGw5_pp2-SNV.mat';
    setup_ShowLabel_findclosestCurve_RS_AT_gui(pathfname_AT,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    close all;clear;
    inp.pick_method='Clsname_PushButton';
    inp.Spectra_Type='Atrainpk';
    pathfname_AT='C:\work\JDSU\CUSTOMERS\GreenWall\ATetc\Atrainpketc_GreenWall_nvar121_ncls6_nsamp252_pp1-1stDerSGw5_pp2-SNV.mat';
    setup_ShowLabel_findclosestCurve_RS_AT_gui(pathfname_AT,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % with Apred
        close all;clear;
        inp.pick_method='Clsname_PushButton';
    inp.Spectra_Type='Atrainpk';
    pathfname_AT='C:\work\JDSU\CUSTOMERS\GreenWall\AT_Odd-Even_bef_rm2OLs\Atrainpketc_wRawSpectra_T-odd_P-even_GreenWall_nvar121_ncls6_pp1-1stDerSGw5_pp2-SNV_nsampT126__nsampP126_TP.mat';
    setup_ShowLabel_findclosestCurve_RS_AT_gui(pathfname_AT,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % with Apred
        close all;clear;
        inp.pick_method='Clsname_PushButton';
    inp.Spectra_Type='Atrainpk';
    pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\Resin_Kits_PolymerLib\TestSite\ResinKit1-2_nsamp4491_VS_Nov20\TMP_T-1s\Atrainpketc__icomb1_{T-rk-1_P-rk-2}_nvar121_ncls50_nsampT1491_nsampP1500.mat';
    setup_ShowLabel_findclosestCurve_RS_AT_gui(pathfname_AT,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % with Apred, test with ssds
    close all;clear;
        inp.Spectra_Type='Atrainpk';
    pathfname_AT='C:\work\JDSU\CUSTOMERS\GreenWall\AT_Odd-Even_bef_rm2OLs\Atrainpketc_wRawSpectra_T-odd_P-even_GreenWall_nvar121_ncls6_pp1-1stDerSGw5_pp2-SNV_nsampT126__nsampP126_TP.mat';
    sd=ssds(pathfname_AT);
    sd.diagnose_Clsname_PushButton(inp);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % with Apred, test with ssds
    close all;clear;
        inp.Spectra_Type='RawSpectra';
    pathfname_AT='C:\work\JDSU\CUSTOMERS\GreenWall\AT_Odd-Even_bef_rm2OLs\Atrainpketc_wRawSpectra_T-odd_P-even_GreenWall_nvar121_ncls6_pp1-1stDerSGw5_pp2-SNV_nsampT126__nsampP126_TP.mat';
    sd=ssds(pathfname_AT);
    sd.diagnose_Clsname_PushButton(inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run with ssds method --> diagnose_Clsname_PushButton()
                inp.Spectra_Type='Atrainpk';
              %  inp.Spectra_Type='RawSpectra';
                  pathfname_AT='Atrainpketc__T1130_P1201_nvar58_ncls5__pp1-1stDerSGFL7[PO2]_pp2-SNV_nsampT51_nsampP49.mat';
                %pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\BMS_5P\Atrainpketc__T1130_P1201_SGw7_nvar64_ncls5_nsampT51_nsampP49.mat'
                %pathfname_AT='C:\work\JDSU\CUSTOMERS_OSP\BMS_5P\MicroNIR_5P\Atrainpketc_DM5powders_ncls5_nsamp110_pp1-1stDerSGw5_pp2-SNV.mat'
                sd=ssds(pathfname_AT);
                sd.diagnose_Clsname_PushButton(inp);
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pick_method=inp.pick_method;
switch pick_method
    case 'Clsname_PushButton'
activate_PickSpectra_GUI_yes=0;
activate_Clsname_CmpSpectra_gui_yes=1;
    case  'Manual_PickSpectra'
 activate_PickSpectra_GUI_yes=1;
activate_Clsname_CmpSpectra_gui_yes=0;       
    otherwise
        error('pick_method not supported')
        
end
% check activation of PickSpectra vs Clsname_CmpSpectra_gui_4ssds
if ~activate_PickSpectra_GUI_yes & ~activate_Clsname_CmpSpectra_gui_yes
    error('pls active at least one of PickSpectra or Clsname_CmpSpectra')
    
elseif activate_PickSpectra_GUI_yes & activate_Clsname_CmpSpectra_gui_yes
    warning('this may not work yet')
    
else
    disp('run one of PickSpectra or Clsname_CmpSpectra')
    
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LAT=load(pathfname_AT);
%===================================================
if isfield(LAT,'inp_cmap_DPR')  % see --> plot_Pretreated_Spectra_various_stages_configurations 
list_color_cls = cmap_DPR(length(LAT.clistclslabel),LAT.inp_cmap_DPR);
    
else
list_color_cls = cmap_DPR(length(LAT.clistclslabel));
end
%=================================================
figure;hold on;
title(strrep(fileparts_name_ext(pathfname_AT),'_','\_'));
set(gcf,'position',1000*[0.0523    0.1063    1.1840    0.4927]);
switch inp.Spectra_Type
    case 'RawSpectra'
        try
        loc_wvl4AT=[1:length(LAT.wvl_standardize)];
        
        catch
       LAT.wvl_standardize=[1:length(LAT.RawSpectra.Tset(1,:))];     
        loc_wvl4AT=[1:length(LAT.wvl_standardize)];    
        end
        
        %hp_fig5=plot(LAT.wvl_standardize,LAT.RawSpectra);
        if isa(LAT.RawSpectra,'struct')
            % revisit for plotting SNV-RawSpectra, Sept 12, 2023
            if SNV_RS_yes
            hp_fig5=plot(LAT.wvl_standardize,apply_SNV(LAT.RawSpectra.Tset),'linestyle','none');% initiate an arry of blank "Line" obj
            else
            hp_fig5=plot(LAT.wvl_standardize,LAT.RawSpectra.Tset,'linestyle','none');% initiate an arry of blank "Line" obj
            end
            
            for icls=1:length(LAT.clistclslabel)
                loc_icls=find(LAT.AclassinfoT==icls);
                if SNV_RS_yes
                    hp_fig5(loc_icls) =plot(LAT.wvl_standardize,apply_SNV(LAT.RawSpectra.Tset(loc_icls,:)),'color',list_color_cls(icls,:),'marker','>','markersize',5);% filled them with real colors that matched with their respective classes
                else
                    hp_fig5(loc_icls) =plot(LAT.wvl_standardize,LAT.RawSpectra.Tset(loc_icls,:),'color',list_color_cls(icls,:),'marker','>','markersize',5);% filled them with real colors that matched with their respective classes
                end
            end
        else
            % revisit for plotting SNV-RawSpectra, Sept 12, 2023
            
            if SNV_RS_yes
                hp_fig5=plot(LAT.wvl_standardize,apply_SNV(LAT.RawSpectra),'linestyle','none');% initiate an arry of blank "Line" obj
                for icls=1:length(LAT.clistclslabel)
                    loc_icls=find(LAT.AclassinfoT==icls);
                    hp_fig5(loc_icls) =plot(LAT.wvl_standardize,apply_SNV(LAT.RawSpectra(loc_icls,:)),'color',list_color_cls(icls,:),'marker','>','markersize',5);% filled them with real colors that matched with their respective classes
                end
            else
                hp_fig5=plot(LAT.wvl_standardize,LAT.RawSpectra,'linestyle','none');% initiate an arry of blank "Line" obj
                for icls=1:length(LAT.clistclslabel)
                    loc_icls=find(LAT.AclassinfoT==icls);
                    hp_fig5(loc_icls) =plot(LAT.wvl_standardize,LAT.RawSpectra(loc_icls,:),'color',list_color_cls(icls,:),'marker','>','markersize',5);% filled them with real colors that matched with their respective classes
                end
            end
        end
        xlabel('wvl');
        if SNV_RS_yes
          ylabel('SNV of RawSpectra')   
        else
        ylabel('RawSpectra')
        end
                %%%%%%%%%%%%%%%%%%%%%%%%
        % setup RawSpectra.Pset etc of Pset
        if isfield(LAT,'Apred')&& ~isempty(LAT.Apred)&& isfield(LAT,'AclassinfoP')&& ~isempty(LAT.AclassinfoP)
            try
                if SNV_RS_yes
                    hp_fig5_P=plot(LAT.wvl_standardize,apply_SNV(LAT.RawSpectra.Pset),'linestyle','none');% initiate an arry of blank "Line" obj
                else
                    hp_fig5_P=plot(LAT.wvl_standardize,LAT.RawSpectra.Pset,'linestyle','none');% initiate an arry of blank "Line" obj
                end
            end
            
            for icls=1:length(LAT.clistclslabel)
                loc_icls=find(LAT.AclassinfoP==icls);
                if ~isempty(loc_icls)
                    if SNV_RS_yes
                        hp_fig5_P(loc_icls) =plot(LAT.wvl_standardize,apply_SNV(LAT.RawSpectra.Pset(loc_icls,:)),'color',list_color_cls(icls,:),'marker','*','markersize',5);% filled them with real colors that matched with their respective classes
                    else
                        hp_fig5_P(loc_icls) =plot(LAT.wvl_standardize,LAT.RawSpectra.Pset(loc_icls,:),'color',list_color_cls(icls,:),'marker','*','markersize',5);% filled them with real colors that matched with their respective classes
                    end
                end
            end
            if SNV_RS_yes
                ylabel('SNV of RawSpectra (Tset or Pset)') ;
            else
                ylabel('RawSpectra (Tset or Pset)') ;
            end
           Apred_yes=1;
        else
           Apred_yes=0; 
        end
        %%%%%%%%%%%%%%%%%%%%%%%%
    case 'Atrainpk'
        if isa(LAT.RawSpectra,'struct')
            gap_wvl=(length(LAT.RawSpectra.Tset(1,:))-length(LAT.Atrainpk(1,:)))/2;
        else
            gap_wvl=(length(LAT.RawSpectra(1,:))-length(LAT.Atrainpk(1,:)))/2;
        end
        
        loc_wvl4AT=[gap_wvl+1:length(LAT.wvl_standardize)-gap_wvl];
        hp_fig5=plot(LAT.wvl_standardize(loc_wvl4AT),LAT.Atrainpk,'linestyle','none');% initiate an arry of "blank" "Line" obj
%         hp_fig5=repmat(NaN,size(LAT.AclassinfoT));
        
        for icls=1:length(LAT.clistclslabel)
            loc_icls=find(LAT.AclassinfoT==icls);
          hp_fig5(loc_icls) =plot(LAT.wvl_standardize(loc_wvl4AT),LAT.Atrainpk(loc_icls,:),'color',list_color_cls(icls,:),'marker','>','markersize',5);% filled them with real colors that matched with their respective classes
         %++++++++++++++++++++++++++++++++++++++++++++++++++++
         % add following to create DataTip for SVMnose, Apr 6, 2024 (this may Not be needed ?)
          inp_icls.sDataTip=[LAT.AclabelT(loc_icls)];
          inp_icls.sDataTip_prefix='AclabelT-';
          plot_wDataTip(hp_fig5(loc_icls),inp_icls);
         %+++++++++++++++++++++++++++++++++++++++++++++++++++
        end
%         hp_fig5=plot(LAT.wvl_standardize(loc_wvl4AT),LAT.Atrainpk);
        xlabel('wvl');
        ylabel('Atrainpk');
                % the following approach is too Slow
%         arrayfun(@(x,c) setClsColor(x,c,LAT), hp_fig5,LAT.AclassinfoT);

        %%%%%%%%%%%%%%%%%%%%%%%%
        % setup Apred etc of Pset
        if isfield(LAT,'Apred')&& ~isempty(LAT.Apred)&& isfield(LAT,'AclassinfoP')&& ~isempty(LAT.AclassinfoP)
            
            hp_fig5_P=plot(LAT.wvl_standardize(loc_wvl4AT),LAT.Apred,'linestyle','none');% initiate an arry of blank "Line" obj
            
            for icls=1:length(LAT.clistclslabel)
                loc_icls=find(LAT.AclassinfoP==icls);
                if ~isempty(loc_icls)
                hp_fig5_P(loc_icls) =plot(LAT.wvl_standardize(loc_wvl4AT),LAT.Apred(loc_icls,:),'color',list_color_cls(icls,:),'marker','*','markersize',5);% filled them with real colors that matched with their respective classes
                end
            end
            
           ylabel('Atrainpk or Apred') ;
           Apred_yes=1;
        else
           Apred_yes=0; 
        end
        %%%%%%%%%%%%%%%%%%%%%%%%
    otherwise
        error('Spectra Type not supported')
        
end
% pickCurve.cX_fig5: X-coord in cell, each cell element contain one curve's X-coord
% 
% pickCurve.cY_fig5: Y-coord in cell, each cell element contain one curve's Y-coord 


switch inp.Spectra_Type
    case 'RawSpectra'
        
        if isa(LAT.RawSpectra,'struct')
            pickCurve.cX_fig5=repmat({col_always(LAT.wvl_standardize)},[length(LAT.RawSpectra.Tset(:,1)) 1]);
            if SNV_RS_yes
            cY_fig5_tmp=mat2cell_CH(apply_SNV(LAT.RawSpectra.Tset),'row');    
            else
            cY_fig5_tmp=mat2cell_CH(LAT.RawSpectra.Tset,'row');
            end
            
        else
            pickCurve.cX_fig5=repmat({col_always(LAT.wvl_standardize)},[length(LAT.RawSpectra(:,1)) 1]);
            if SNV_RS_yes
             cY_fig5_tmp=mat2cell_CH(apply_SNV(LAT.RawSpectra),'row');    
            else
            cY_fig5_tmp=mat2cell_CH(LAT.RawSpectra,'row');
            end
        end
        try
            if  Apred_yes
                pickCurve_P.cX_fig5=repmat({col_always(LAT.wvl_standardize)},[length(LAT.RawSpectra.Pset(:,1)) 1]);
                cY_fig5_tmp_P=mat2cell_CH(LAT.RawSpectra.Pset,'row');
            end
        end
        
    case 'Atrainpk'
        pickCurve.cX_fig5=repmat({col_always(LAT.wvl_standardize(loc_wvl4AT))},[length(LAT.Atrainpk(:,1)) 1]);
        cY_fig5_tmp=mat2cell_CH(LAT.Atrainpk,'row'); 
        if  Apred_yes
        pickCurve_P.cX_fig5=repmat({col_always(LAT.wvl_standardize(loc_wvl4AT))},[length(LAT.Apred(:,1)) 1]);
        cY_fig5_tmp_P=mat2cell_CH(LAT.Apred,'row'); 
        end
    otherwise
        error('Spectra Type not supported')
end

cY_fig5=cellfun(@(x) x',cY_fig5_tmp,'un',0);
pickCurve.cY_fig5=cY_fig5;
pickCurve.hp_fig5=hp_fig5;
try
    if  Apred_yes
        cY_fig5_P=cellfun(@(x) x',cY_fig5_tmp_P,'un',0);
        pickCurve_P.cY_fig5=cY_fig5_P;
        pickCurve_P.hp_fig5=hp_fig5_P;
        
    end
end
% tRS=RS';
% pickCurve.cY_fig5=tRS(:);
try
pickCurve.CurveTag_fig5=LAT.AclabelT_info1;
catch
pickCurve.CurveTag_fig5=LAT.AclabelT;
end
%%%%%%%%%%%%%%%%%%
% the following is for Pset and will be used in ShowLabel_findclosestCurve_RS_AT_gui() by
% T_or_P to determine whether to load this or the default pickCurve (Tset)
try
    if  Apred_yes
        try
            pickCurve_P.CurveTag_fig5=LAT.AclabelP_info1;
        catch
            pickCurve_P.CurveTag_fig5=LAT.AclabelP;
        end
    end
end
%%%%%%%%%%%%%%%%%%
FigNUserData.pickCurve=pickCurve;
try
    if  Apred_yes
        FigNUserData.pickCurve_P=pickCurve_P;
    end
end

% guidata(gcf,pickCurve);
% setappdata(gcf, 'UserData', pickCurve);
set(gcf,'userdata',FigNUserData);
% findclosestCurve_autoscaled(pickCurve);

%%%%%%%%%%%%%%%%%%%%%
% ShowLabel_findclosestCurve_RS_AT_gui();
%%%%%%%%%%%%
% create GUI pushbutton for "ShowLabel_findclosestCurve_RS_AT_gui()"
if activate_PickSpectra_GUI_yes
try
    if Apred_yes
        sPickSpectra='pick-T';
        sPickSpectra_P='pick-P';
        h_uicntl_pickSpectra_P = uicontrol('style','pushbutton', ...
            'string', sPickSpectra_P, 'callback', ...
            'ShowLabel_findclosestCurve_RS_AT_gui', ...
            'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [ 0.2 0.01 .1 .05],'ForegroundColor','b');
    else
        sPickSpectra='pick-Spectra';
    end
catch
    sPickSpectra='pick-Spectra';
end
h_uicntl_pickSpectra = uicontrol('style','pushbutton', ...
    'string', sPickSpectra, 'callback', ...
    'ShowLabel_findclosestCurve_RS_AT_gui', ...
    'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [ 0.1 0.01 .1 .05],'ForegroundColor','b');
end % end of activate_PickSpectra_GUI_yes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create GUI pushbutton for "uiresume" to continue picking of curve
% h_uicntl_Continue = uicontrol('style','pushbutton', ...
%     'string', 'Continue', 'callback', ...
%     'uiresume((gcbf))', ...
%     'fontsize', 6,'FontWeight','bold', 'units', 'normalized', 'position', [ 0.9 0.4 .1 .05],'ForegroundColor','b');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% replicate create_spectra_plot_from_CmpSpectra in SVMnose's FeatMat_Callback(hObject, eventdata, handles) inside SVM_gui.m
if activate_Clsname_CmpSpectra_gui_yes

inp4create_spectra.wvl=LAT.wvl_standardize;

switch inp.Spectra_Type
    case 'RawSpectra'
        %===================================================================
        if SNV_RS_yes
            if Apred_yes
                try
                    AT4create_spectra=apply_SNV(LAT.RawSpectra.Tset);
                    AT4create_spectra_P=apply_SNV(LAT.RawSpectra.Pset);
                catch
                    AT4create_spectra=apply_SNV(LAT.RawSpectra);
                    AT4create_spectra_P=[];
                end
            else
                AT4create_spectra=apply_SNV(LAT.RawSpectra);
                AT4create_spectra_P=[];
            end
        else %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            if Apred_yes
                try
                    AT4create_spectra=LAT.RawSpectra.Tset;
                    AT4create_spectra_P=LAT.RawSpectra.Pset;
                catch
                    AT4create_spectra=LAT.RawSpectra;
                    AT4create_spectra_P=[];
                end
            else
                AT4create_spectra=LAT.RawSpectra;
                AT4create_spectra_P=[];
            end
        end
        %===================================================================
        
    case  'Atrainpk'
        if Apred_yes
            AT4create_spectra=LAT.Atrainpk;
            AT4create_spectra_P=LAT.Apred;
        else
            AT4create_spectra=LAT.Atrainpk;
            AT4create_spectra_P=[];
        end
        
end


FigNUserData4create_spectra.TPinfo_loaded=LAT;

try
FigNUserData4create_spectra.TPinfo_loaded.loc_wvl4AT=loc_wvl4AT;
catch
FigNUserData4create_spectra.TPinfo_loaded.loc_wvl4AT=loc_wvl4AT;
end


FigNUserData4create_spectra.TPinfo_loaded.INPfilename=strrep(fileparts_name_ext(pathfname_AT),'_','\_');
fig_gcf=gcf;

% fignum4create_spectra=figure(fig_gcf.Number+1);
fignum4create_spectra=fig_gcf;

% this will setup for calling --> Clsname_CmpSpectra_gui()
if isfield(LAT,'inp_cmap_DPR')
    inp4create_spectra.scolor=LAT.inp_cmap_DPR.scolor;
end
% ==========================================================
% revisit for plotting SNV-RawSpectra, Sept 12, 2023
%  apply_SNV -->   AT4create_spectra, AT4create_spectra_P
%-----------------------------------------------------------
% in following function:  create_spectra_plot_from_CmpSpectra_4ssds
% add following to create DataTip for SVMnose, Apr 6, 2024
create_spectra_plot_from_CmpSpectra_4ssds(AT4create_spectra,AT4create_spectra_P,fignum4create_spectra,FigNUserData4create_spectra,inp4create_spectra);
%===========================================================

end % end of activate_Clsname_CmpSpectra_gui_yes
%%%%%%%%%%%%%%%%%%%%%%%%%
disp('done setup_ShowLabel_findclosestCurve_RS_AT_gui()')
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function setClsColor(x,c,LAT)
% list_color_DPR = cmap_DPR(length(LAT.clistclslabel));
% x.Color=list_color_DPR(c,:);


%% ----- from show_line_in_figure.m -----------------------------------------
function out=show_line_in_figure(LineList)
% by directly clicking on one of the lines in a plot, 
% this will show line seq number in title
% this function can be used to show spectra seq number in Atrainpk etc
% this is also used as main function in ssds method: show_rm_samps_OLs
% see also ssds --> method: show_rm_samps_OLs
% see also findclosestCurve~.m
% see also : test_show_line_in_figure Outliers_HBpro_MAD  ShowLabel_findclosestCurve_RS_AT_gui setup_ShowLabel_findclosestCurve_RS_AT_gui


set(LineList, 'ButtonDownFcn', {@myLineCallback, LineList});
out='';
end



function myLineCallback(LineH, EventData, LineList)
% disp(LineH);                    % The handle
% disp(get(LineH, 'YData'));      % The Y-data
disp(find(LineList == LineH));  % Index of the active line in the list
set(LineList, 'LineWidth', 0.5);
set(LineH,    'LineWidth', 2.5);
uistack(LineH, 'top');  % Set active line before all others
title(['line seq = ',num2str(find(LineList == LineH))])
end


%% ----- from sortnat.m -----------------------------------------------------
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
%-----------------------------------------------------------------------End


%% ----- from speak.m -------------------------------------------------------
function [ ret ] = speak(saytext, voice, rate, volume, pitch, language)
% Use speech output to speak a given text.
%
% Usage:
%
% [ ret ] = Speak(text [, voice][, rate][, volume][, pitch][, language]);
%
% The function returns an optional 'ret'urn code 0 on success, non-zero
% on failure to speak the requested text.
%
% 'text' must be a text to speak, either a text string or a cell array
% of text strings to speak separately, cell by cell.
%
% The optional 'voice' parameter allows to select among different system
% voices. It is supported on Linux and Mac OS/X.
%
% The names of the available voices differ across operating systems.
%
% Linux supports, e.g., male1,  male2,  male3,  female1,  female2,
% female3, child_male, child_female.
%
% OS/X: Type "!say -v ?" in Matlab to get a list of supported voices.
%
% The optional 'rate' parameter controls speed of speaking on OS/X and
% Linux. On OS/X it defines the number of words per minute, on Linux a
% value between -100 and +100 defines slower or faster speed.
%
% The optional 'volume' parameter allows control of loudness on Linux:
% Value range is -100 to + 100.
%
% The optional 'pitch' parameter allows control of pitch on Linux:
% Value range is -100 to + 100.
%
% The optional 'language' parameter allows control of the output language
% on Linux. E.g., 'de' would output in german language, 'en' english
% language. The text string must be a valid ISO language code string.
%
% Note: Speak on MS-Windows requires the .NET framework to be installed.
% Note: Speak on Linux requires the spd-say command to be installed. This
% is the case by default, e.g., at least on Ubuntu Linux 12.04 and later.
%
% Examples:
% Say "Hello darling" with standard system voice:
% Speak_mk('Hello darling');
%
% Say same text with voice named "Albert":
% Speak('Hello darling', 'Albert');
%

% History:
% 24.07.09 mk           Written for OS/X.
% 03.10.12 Vishal Shah  Added basic support for MS-Windows.
% 06.10.12 mk           Add extended support for OS/X and Linux.
% 24.07.15 mk           Use double-quotes instead of pairs of single quotes
%                       to protect strings containing apostrophes etc.
%                       Suggested by elladawu. Successfully tested on Linux.
if false
    
    Speak_mk('Hello darling')
    
    Speak_mk('can only run with cross validation')
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    error('You must provide the text string to speak!');
end

% Make saytext cell array of characters:
if ~isa(saytext,'cell')
    saytext = {saytext};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
IsWin=1;
IsOSX=0;
IsLinux=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if IsOSX
    cmd = 'say ';

    if nargin >= 2 && ~isempty(voice)
        cmd = [cmd sprintf('-v "%s" ', voice)];
    end

    if nargin >= 3 && ~isempty(rate)
        cmd = [cmd sprintf('-r %i ', rate)];
    end

    for k=1:length(saytext)
        % Build command string for speech output and do a system() call:
        ret = system(sprintf('%s "%s"', cmd, saytext{k}));
    end
end

if IsLinux
    cmd = 'spd-say --wait ';

    if nargin >= 2 && ~isempty(voice)
        cmd = [cmd sprintf('--voice-type "%s" ', voice)];
    end

    if nargin >= 3 && ~isempty(rate)
        cmd = [cmd sprintf('--rate %i ', rate)];
    end

    if nargin >= 4 && ~isempty(volume)
        cmd = [cmd sprintf('--volume %i ', volume)];
    end

    if nargin >= 5 && ~isempty(pitch)
        cmd = [cmd sprintf('--pitch %i ', pitch)];
    end

    if nargin >= 6 && ~isempty(language)
        cmd = [cmd sprintf('--language "%s" ', language)];
    end

    ret = 0;
    for k=1:length(saytext)
        % Build command string for speech output and do a system() call:
        ret = system(sprintf('%s "%s"', cmd, saytext{k}));
        if ret
            break;
        end
    end

    if ret
        warning('Speak: You need to install the spd-say function (speech-dispatcher) to use this function on Linux. Skipped.'); %#ok<WNTAG>
    end
end

if IsWin
    try
        % Using
        % Microsoft's TTS Namespace
        % http://msdn.microsoft.com/en-us/library/system.speech.synthesis.ttsengine(v=vs.85).aspx
        % Microsoft's Synthesizer Class
        % http://msdn.microsoft.com/en-us/library/system.speech.synthesis.speechsynthesizer(v=vs.85).aspx

        NET.addAssembly('System.Speech');
        Speaker = System.Speech.Synthesis.SpeechSynthesizer;
        for k=1:length(saytext)
            Speaker.Speak (saytext{k});
        end
        ret=0;
    catch
        warning('Speak: You need to install the .Net framework to use this function on Windows. Skipped.'); %#ok<WNTAG>
        ret=1;
    end
end

return;
end


%% ----- from sprintf_pad_zero_prefix.m -------------------------------------
function out= sprintf_pad_zero_prefix(n,l)
% n : numerical integer to be converted to char
% l : total length of converted number in char
% out will have l-length(num2str(n)) zeros preceding n
% see also sprintf sortnat
if false
    
    out=sprintf_pad_zero_prefix(23,5)
    %%%%%%%%%%%%%%%%%
    out=sprintf_pad_zero_prefix(2,3)
    %%%%%%%%%%%%%%%%%
    out=sprintf_pad_zero_prefix(122,3)
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%


out=strrep(sprintf(['%',num2str(l),'d'],n),' ','0');
end


%% ----- from ssds_method_T_plus_P.m ----------------------------------------
function [out_obj]= ssds_method_T_plus_P(pfn,inp)
% see also: test_ssds_method_T_plus_P
% see also: prep_comprehensive_model_CARE_fLMVD_T_plus_P
%=============================================================
%
if false
   % when there is inp, there are 4 ways of calling this kind of ssds method

cc
pfn='C:\work\JDSU\Test_ACP\AT_etc\ResinKit_Jan3_RmCls_SS-6_46_T4pos\alt\Atrainpketc__icomb5_{P-p5_T-4_p}_nvar121_ncls48_nsampT4625_nsampP1156.mat';
sd=ssds(pfn);
sd1=T_plus_P(sd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cc
pfn='C:\work\JDSU\Test_ACP\AT_etc\ResinKit_Jan3_RmCls_SS-6_46_T4pos\alt\Atrainpketc__icomb5_{P-p5_T-4_p}_nvar121_ncls48_nsampT4625_nsampP1156.mat';
sd=ssds(pfn);
sd1=sd.T_plus_P;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cc
pfn='C:\work\JDSU\Test_ACP\AT_etc\ResinKit_Jan3_RmCls_SS-6_46_T4pos\alt\Atrainpketc__icomb5_{P-p5_T-4_p}_nvar121_ncls48_nsampT4625_nsampP1156.mat';
inp.corename='{ResinKit_Jan3_RmCls_SS-6_46_ALL_p1-p5}';
sd=ssds(pfn);
sd1=T_plus_P(sd,inp);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cc
pfn='C:\work\JDSU\Test_ACP\AT_etc\ResinKit_Jan3_RmCls_SS-6_46_T4pos\alt\Atrainpketc__icomb5_{P-p5_T-4_p}_nvar121_ncls48_nsampT4625_nsampP1156.mat';
inp.corename='{ResinKit_Jan3_RmCls_SS-6_46_ALL_p1-p5}';
sd=ssds(pfn);
sd1=sd.T_plus_P(inp);
 %-----------------------------------------------------------
    % revisit Mar 20, 2024 aft extr Val M1-470 DM
    cc
    pfn='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_extr_Val_0320\TP_pair\Atrainpketc_{T-(ncls7_6U_ApdCls-N6_S3_rmCls-TP)_P-(M1-470_extr_Val_DM_0320_woTP_M1-470)}_nvar119_ncls7_nsampT1959_nsampP75.mat';
    inp.corename='{6U_ApdCls-N6_S3_rmCls-TP_PLUS_M1-470_extr_Val_DM_0320}';
    sd=ssds(pfn);
    sd1=sd.T_plus_P(inp);
 %-----------------------------------------------------------
    % revisit Mar 23, 2024 aft extr Val 5U fDM_MK
    cc
    pfn='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_extr_Val_0320\DM_MK\Atrainpketc_{T-(ncls7_6U_ApdCls-N6_S3_rmCls-TP)_P-(RawXLSX_extr_Val_fDM_MK_rm_Yarn)}_nvar119_ncls7_nsampT1959_nsampP373.mat';
    inp.corename='{6U_ApdCls-N6_S3_rmCls-TP_PLUS_M1-470_extr_Val_DM_0320}';
    sd=ssds(pfn);
    sd1=sd.T_plus_P(inp); 
    %-----------------------------------------------------------
    % revisit July 29, 2024 for kt
    cc
    pfn='C:\work\JDSU\KT2LS\AT_CARE_etc\Final_Construt_CARE\Atrainpketc_{T-(TUseq1+TUseq2+TUseq3+TUseq4+TUseq5)_P-(M1-600_ApdCls-N6_S3)}_LocalAutoStudy(Cls-Nylons_PET_PP)_nvar119_ncls4_nsampT1200_nsampP238.mat';
    inp.corename='{CARE_alone_6U_Nylons_PET_PP}';
    sd=ssds(pfn);
    sd1=sd.T_plus_P(inp); 
      %-----------------------------------------------------------
    % revisit July 29, 2024 for kt
    cc
    pfn='C:\work\JDSU\KT2LS\AT_CARE_etc\Final_Construt_CARE\Atrainpketc_{T-(TUseq1+TUseq2+TUseq3+TUseq4+TUseq5)_P-(M1-600_ApdCls-N6_S3)}_LocalAutoStudy(PTT)(WOOL)_nvar119_ncls2_nsampT431_nsampP90.mat' ;
    inp.corename='{CARE_alone_6U_PTT_WOOL}';
    sd=ssds(pfn);
    sd1=sd.T_plus_P(inp); 
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end  % end of examples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin==1
    inp='';
end
%%%%%%%%%%%%%%%
LPp5=load(pfn);

sd0=ssds(pfn);
sd1=sd0.rm_Pset;

sd2=sd0.P2T;
% inp.corename='{P-p5_alone}'
% sd2=sd2.saveAT(inp);


sda=sd1+sd2;

try
    if  ~isempty(inp.corename)
        sda=sda.saveAT(inp);
    end
end
out_obj=sda;


done_with_this_function;
end


%% ----- from ssds_method_add_append_classes.m ------------------------------
function out_obj=ssds_method_add_append_classes(o1,o2,inp)
%======================================================================================================
% check whether o1 and o2 match in "type_Model" and are both 'Clsfr'
if strcmp(o1.type_Model,o2.type_Model) && strcmp(o1.type_Model, 'Clsfr')  % only can handle 'Clsfr' type_Model

%     if isnan(o1.nsampP) && isnan(o2.nsampP)
%        if isnan(o1.nsampP) % deal with the case when sd1 or sd2 is TP pair, July 24, 2023
     
        L1=o1.LAT ;
        L2=o2.LAT ;
        clistclslabel_new=[row_always(L1.clistclslabel),row_always(L2.clistclslabel)];
        %check no overlap
        if    length(unique(clistclslabel_new))==length(L1.clistclslabel)+length(L2.clistclslabel)
            AclassinfoT2_new=  L2.AclassinfoT+length(L1.clistclslabel);
            AclassinfoT_new=[L1.AclassinfoT; AclassinfoT2_new];
            Lnew.clistclslabel=clistclslabel_new;
            Lnew.AclassinfoT=AclassinfoT_new;
            Lnew.Atrainpk=[L1.Atrainpk;L2.Atrainpk];
            %----------------------------------------------------
            % deal with the case when sd2 is TP pair, July 24, 2023
            if isfield(L1,'Apred') && ~isempty(L1.Apred)
                AclassinfoP1_new=  L1.AclassinfoP;
                Lnew.AclassinfoP=AclassinfoP1_new;
                Lnew.Apred=L1.Apred;
            else
                Lnew.AclassinfoP=[];
                Lnew.Apred=[];
            end
            %------------------------------------------------------
            if isfield(L2,'Apred') && ~isempty(L2.Apred)
                AclassinfoP2_new=  L2.AclassinfoP+length(L1.clistclslabel);
                Lnew.AclassinfoP=[Lnew.AclassinfoP;AclassinfoP2_new];
                Lnew.Apred=[Lnew.Apred ; L2.Apred];
            end
            %-----------------------------------------------------
            if ~isstruct(L1.RawSpectra) && ~isstruct(L2.RawSpectra)
                Lnew.RawSpectra=[L1.RawSpectra; L2.RawSpectra];
            elseif isstruct(L1.RawSpectra) && isstruct(L2.RawSpectra)
                Lnew.RawSpectra.Tset=[L1.RawSpectra.Tset; L2.RawSpectra.Tset];
                Lnew.RawSpectra.Pset=[L1.RawSpectra.Pset; L2.RawSpectra.Pset];
                try
                Lnew.AclabelP=[L1.AclabelP; L2.AclabelP];
                end
                
             elseif ~isstruct(L1.RawSpectra) && isstruct(L2.RawSpectra)
                Lnew.RawSpectra.Tset=[L1.RawSpectra; L2.RawSpectra.Tset];
                Lnew.RawSpectra.Pset=[ L2.RawSpectra.Pset]; 
                 try
                Lnew.AclabelP=[L2.AclabelP];
                end
                
             elseif isstruct(L1.RawSpectra) && ~isstruct(L2.RawSpectra)
                Lnew.RawSpectra.Tset=[L1.RawSpectra.Tset; L2.RawSpectra];
                Lnew.RawSpectra.Pset=[ L1.RawSpectra.Pset];     
                
                try
                Lnew.AclabelP=[L1.AclabelP];
                end
                
                
            else
                warning('somehow still can Not handle this case yet, "RawSpectra" Not converted !!!');
                
            end
            
            try
                Lnew.AclabelT=[L1.AclabelT; L2.AclabelT];
            end
            
            try
                if IsNear_2AT(L1.wvl_standardize,L2.wvl_standardize,0.1)
                    Lnew.wvl_standardize=L1.wvl_standardize;
                end
            end
            %=============================================
            % final results should come to this section !!!
            sdnew=ssds(Lnew);
            
            try
              out_obj=sdnew.saveAT(inp);   
            catch
            inp.corename='add_append_two_AT_classes';
            out_obj=sdnew.saveAT(inp);
            end
            %==============================================
        else
            error('clistclslabel in two input objects have overlapped names')
        end
%     else
%         error('this function can only deal with LAT with Tset only');
%     end

else
    error('this ssds method can only handle "Clsfr" type_Model !!! ');
end




done_with_this_function;
end


%% ----- from ssds_method_extract_class.m -----------------------------------
function [out_obj]=ssds_method_extract_class(obj,inp)
% to deal with extract only, but can output clistclslabel to follow user specified seq ( i.e. inp.cls_pick_specified_seq )
% ssds method --> extract_class
% main function to call --> Atrainpk_merge_classes_ATop
% see also: ssds_method_add_append_classes (Feb 17, 2024)
%--------------------------------------------------------
% see also: ssds_method_extract_plus_apd_class (Feb 20, 2024)
%------------------------------------------------------
% see also: AT_reseq_clistclslabel (Feb 21, 2024)
%+++++++++++++++++++++++++++++++++++++++++++++++++++
% update following July 7, 2024 during KT
%---------------------------------------------------------------
%===================================================================
if false
    

    %===============================================================================
    
     cc
    L1=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\ATetc_Orig_Big7_EmLS\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat');
    sd1=ssds(L1);
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % reverse common seq in inp.cls_pick
    inp.cls_pick_specified_seq={'[Carpet]-N66','[Carpet]-N6'}; % seq now is important, they follow cls_pick_specified_seq
    %-------------
    inp.action='extract';
    % o2x=merge_rm_extract_class(sd2,inp);
    o2x=extract_class(sd2,inp);  % modified from merge_rm_extract_class() % to deal with extract only, but can output clistclslabel to follow user specified seq
    o2x.LAT.clistclslabel
    inp.corename=['{',strwrite_all_delimiter(inp.cls_pick_specified_seq,'  '),'}'];
    o2x.saveAT(inp);
    
    
      %===============================================================================
    
     cc
    L1=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\ATetc_Orig_Big7_EmLS\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat');
    sd1=ssds(L1);
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % follow common seq in inp.cls_pick
    inp.cls_pick_specified_seq={'[Carpet]-N6','[Carpet]-N66'}; % seq now is important, they follow cls_pick_specified_seq
    %-------------
    inp.action='extract';
    % o2x=merge_rm_extract_class(sd2,inp);
    o2x=extract_class(sd2,inp);  % modified from merge_rm_extract_class() % to deal with extract only, but can output clistclslabel to follow user specified seq
    o2x.LAT.clistclslabel
      inp.corename=['{',strwrite_all_delimiter(inp.cls_pick_specified_seq,'  '),'}'];
    o2x.saveAT(inp);
     %===============================================================================
     
    % Feb 21, 2024
    % test to use this to reseq clistclslabel
     cc
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % follow common seq in inp.cls_pick
%     inp.cls_pick_specified_seq={'[Carpet]-N6','[Carpet]-N66'}; % seq now is important, they follow cls_pick_specified_seq
      inp.cls_pick_specified_seq=flipud(sd2.LAT.clistclslabel); % seq now is important, they follow cls_pick_specified_seq
    %-------------
    inp.action='extract';
    % o2x=merge_rm_extract_class(sd2,inp);
    o2x=extract_class(sd2,inp);  % modified from merge_rm_extract_class() % to deal with extract only, but can output clistclslabel to follow user specified seq
    
    o2x.LAT.clistclslabel
      inp.corename=['{',strwrite_all_delimiter(inp.cls_pick_specified_seq,' '),'}'];
    o2x.saveAT(inp);
    
    
    %===============================================================================
end   % end of if false examples
%=================================================================
%=================================================================

%********************************************************************************************
% if false
    clistcls_tobe_merged=inp.cls_pick;
    if isempty(obj.pathfname_AT)
        obj.pathfname_AT=obj.LAT;
    end
    %-----------------------
    inp.action='extract';
    %-----------------------
    try
        Ldummy=load(obj.pathfname_AT);
        out=Atrainpk_merge_classes_ATop(obj.pathfname_AT,clistcls_tobe_merged,inp);
         %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % update following July 7, 2024 during KT
        if isfield(inp,'cls_pick_specified_seq')  &&   isfield( out.LAT,'clistclslabel_P')  &&   all(ismember(inp.cls_pick_specified_seq, out.LAT.clistclslabel_P))
            out.LAT.clistclslabel_P='';
            out_LAT=out.LAT;
            save(out.pathfname,'-struct','out_LAT') ;
        end
    catch
        out=Atrainpk_merge_classes_ATop(obj.LAT,clistcls_tobe_merged,inp);
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % update following July 7, 2024 during KT
        if isfield(inp,'cls_pick_specified_seq')  &&   isfield( out.LAT,'clistclslabel_P')  &&   all(ismember(inp.cls_pick_specified_seq, out.LAT.clistclslabel_P))
            out.LAT.clistclslabel_P='';
            out_LAT=out.LAT;
            save(out.pathfname,'-struct','out_LAT') ;
        end
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    end
    %------------------------------------------
    try
     [SUCCESS,MESSAGE,MESSAGEID] =    copyfile(out.pathfname,pwd);
        sd1=ssds(out.pathfname);
    catch
         sd1=ssds(out.LAT);
    end
    %-----------------------------------------------------------
    out_obj=sd1;
    out_obj.pathfname_AT=out.pathfname;
% end
%*************************************************************************************************








done_with_this_function;
end


%% ----- from ssds_method_extract_plus_apd_class.m --------------------------
function  [out]=ssds_method_extract_plus_apd_class(o1,o2,inp)
% extract from o2, plus those fit o1's clistclslabel into o1, then the rest adp to o1
% will call -->  ssds_method_extract_class  ssds_method_plus_wExtractCls   ssds_method_add_append_classes
% or within ssds --> extract_class  plus_wExtractCls add_append_classes
% Feb 19, 2024
%==========================================================================
if false
    
    cc
    L1=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\ATetc_Orig_Big7_EmLS\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat');
    sd1=ssds(L1);
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % reverse common seq in inp.cls_pick
%     inp.cls_pick_specified_seq={'[Carpet]-N66','[Carpet]-N6'}; % seq now is important, they follow cls_pick_specified_seq
     %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % commonly used seq for BigN datasets in inp.cls_pick
    inp.cls_pick_specified_seq={'[Carpet]-N6','[Carpet]-N66'}; % seq now is important, they follow cls_pick_specified_seq
    [out]=ssds_method_extract_plus_apd_class(sd1,sd2,inp);
    
    %==============================================================================
    
     cc
    L1=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\ATetc_Orig_Big7_EmLS\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat');
    sd1=ssds(L1);
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    inp.cls_pick_specified_seq={'[Carpet]-PET','[Carpet]-PTT','[Carpet]-N6','[Carpet]-N66'}; % seq now is important, they follow cls_pick_specified_seq
    [out]=ssds_method_extract_plus_apd_class(sd1,sd2,inp);
    
     %==============================================================================
    
     cc
    L1=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\ATetc_Orig_Big7_EmLS\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat');
    sd1=ssds(L1);
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    inp.cls_pick_specified_seq={'[Carpet]-WOOL','[Carpet]-PP','[Carpet]-PET','[Carpet]-PTT','[Carpet]-N6','[Carpet]-N66'}; % seq now is important, they follow cls_pick_specified_seq
    [out]=ssds_method_extract_plus_apd_class(sd1,sd2,inp);
    %==============================================================================
    %==============================================================================
    %==============================================================================
    
    % OrigBig7 add Nylons(CARE)
     cc
    L1=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\ATetc_Orig_Big7_EmLS\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat');
    sd1=ssds(L1);
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % inp.cls_pick_specified_seq={'[Carpet]-N6','[Carpet]-N66'}; % seq now is important, they follow cls_pick_specified_seq
    %  inp.cls_pick_specified_seq={'[Carpet]-PET','[Carpet]-PP'}; % these two already part of L1
     inp.cls_pick_specified_seq={'[Carpet]-PET','[Carpet]-PP','[Carpet]-N6','[Carpet]-N66'};  % plus2cls & adp2cls
    [out]=ssds_method_extract_plus_apd_class(sd1,sd2,inp);
    
    
     %==============================================================================
     
    % OrigBig7 add Nylons(RK)
     cc
    L1=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\ATetc_Orig_Big7_EmLS\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat');
    sd1=ssds(L1);
    %-----------
    L2=load('C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{RK_T-109-105_P-EdEmLS}_nvar119_nclsT50_nclsP33_nsampT2100_nsampP607.mat');% seq Not important, they depend on their orig seq in L2
    sd2=ssds(L2);
     %--------------------------
    % rename clistclslabel to match format in pfn_orig
    inp.clistclslabel_replace={...
        'Nylon - Type 66','N66';...               %
        'Nylon - Type 6 (Homopolymer)','N6';...   %
        };
    out_rename_Nylons=AT_replace_clistclslabel(L2,inp);
    %--------------------------
    %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    inp.cls_pick_specified_seq={'N6','N66'}; % seq now is important, they follow cls_pick_specified_seq
    [out]=ssds_method_extract_plus_apd_class(sd1,ssds(out_rename_Nylons.Lnew),inp);
    %==============================================================
    % revisit July 9, 2024 for --> summary_CmbLib_B5_RK
    % see also: ssds_method_extract_class
    
    %==============================================================================
    %==============================================================================
    %==============================================================================

end
%======================================================

%-------------
inp.action='extract';
% o2x=merge_rm_extract_class(sd2,inp);
o2x=extract_class(o2,inp);
%------------------------------------------
% this hard-coded !!!
o2x.LAT.clistclslabel=strrep(o2x.LAT.clistclslabel,'[Carpet]-','');  % this hard-coded !!!
o2x.LAT.clistclslabel
inp.corename='{Rm_[Carpet]-}';
o2x.saveAT(inp);
%------------------------------------------
o1.LAT.clistclslabel
[lia,locb] = ismember(o2x.LAT.clistclslabel,o1.LAT.clistclslabel);
loc_plus_clistclslabel_o2x=find(lia);
loc_apd_clistclslabel_o2x=find(~lia);
%-------------------
if ~isempty(loc_plus_clistclslabel_o2x)
inp_plus.cls_pick=o2x.LAT.clistclslabel(loc_plus_clistclslabel_o2x); % seq Not important
 inp_plus.action='extract';
o1_aft_plus=plus_wExtractCls(o1,o2x,inp_plus);
sPlusCls=[ '_plus',num2str(length(loc_plus_clistclslabel_o2x)) ];
else
o1_aft_plus=o1;  
sPlusCls='';
end
%-------------------
if ~isempty(loc_apd_clistclslabel_o2x)
inp_apd.cls_pick=o2x.LAT.clistclslabel(loc_apd_clistclslabel_o2x); % seq Not important
inp_apd.action='extract';
o2x_apd=extract_class(o2x,inp_apd);
out_obj=add_append_classes(o1_aft_plus,o2x_apd);
sApdCls=[ '_apd',num2str(length(loc_apd_clistclslabel_o2x)) ];

else
out_obj= o1_aft_plus;   
sApdCls='';
end
%----------------------------------------
% check nsampT and nsampP
if o1.nsampT+o2x.nsampT~=out_obj.nsampT
    error('MisMatch in nsampT among o1, o2x, and out_obj ??' );
end
if o1.nsampP+o2x.nsampP~=out_obj.nsampP
    error('MisMatch in nsampP among o1, o2x, and out_obj ??' );
end

%----------------------------------------
inp4out.corename=['{',sPlusCls,  sApdCls   ,'_cls}'];
out_obj=out_obj.saveAT(inp4out);
%===========================================
out.out_obj= out_obj;
out.o2x=o2x;
%-------------

done_with_this_function;
end


%% ----- from ssds_method_minus.m -------------------------------------------
function r=ssds_method_minus(o1,o2)
% see also ssds
% see also : ssds_method_plus
if false
    
    %====================================================================
    cc
    pfn1='C:\work\JDSU\Test_ACP\CnsdLib\ATetc_BigFive_MID_Tcv\Atrainpketc_{BigFive_LS_Apr27_MaterialID}_pp1-1stDerSGFL7[PO2]_pp2-SNV_wGloc_MID_SupCls_nvar119_ncls6_nsamp1181.mat'
    pfn2='C:\work\JDSU\Test_ACP\CnsdLib\ATetc_BigFive_MID_Tcv\Atrainpketc_{BigFive_LS_Apr27_MaterialID_rm34OLs_rm3OLs_nF2}_nvar119_ncls6_nsamp1143.mat';
    o1=ssds(pfn1);o2=ssds(pfn2);
    o3=o1-o2;
%     r=ssds_method_minus(o1,o2);
   %---------
    inp.sPrefix_1='Torig-';
    inp.sPrefix_2='Minus-';
    corename_3=consolidate_corename_2_pfn(pfn1,pfn2,inp);
    inp.corename=corename_3;
    sd3=o3.saveAT(inp);
  %====================================================================
    
end
%====================================================================
% important locations
% start operation of minus or subtraction, Sept 4, 2023
% only deal with Tset only case for now, Sept 4, 2023
%====================================================================
disp('subtract obj2 from obj1')
% check whether o1 and o2 match in "type_Model"
if strcmp(o1.type_Model,o2.type_Model)
    type_Model=o1.type_Model;
    try
        try
            saConc_T_1=o1.LAT.PLS.Tset.saConc;
        catch
            saConc_T_1=o1.LAT.saConc;
        end
    catch
        saConc_T_1='';
    end
    try
        try
            saConc_T_2=o2.LAT.PLS.Tset.saConc;
        catch
            saConc_T_2=o2.LAT.saConc;
        end
    catch
        saConc_T_2='';
    end
else
    error('obj1 and obj2 have different "type_Model"');
end
%             if ~isempty(saConc_T_1) && ~isempty(saConc_T_2)
%                 type_Model='PLS';
%             elseif isempty(saConc_T_1) && isempty(saConc_T_2)
%                 type_Model='Clsfr';
%             else
%                 error('can not determine whether it is PLS or Clsfr')
%             end
%check if nvar and clistclslabel match
% add row_always and deblank, July 19, 2023
if o1.nvar==o2.nvar && ( strcmp(type_Model,'PLS') ||  ( strcmp(type_Model,'Clsfr') && isSAME_two_cstr(deblank(row_always(o1.LAT.clistclslabel)),deblank(row_always(o2.LAT.clistclslabel)))  )  )
    %                 if isequal(o1.LAT.clistclslabel,o2.LAT.clistclslabel)
    %-------------------------------------------------------
    % only try to merge Tset when they are different
    if ~isSAME_Tset(o1.pathfname_AT,o2.pathfname_AT)
        % check to see if o2 is based on XBPL Pset, i.e. o2.LAT.AclassinfoT are all NaN
        %  and o2.LAT.clistclslabel are all different from o1.LAT.clistclslabel
        % if it is true, then append o2 as new classes to o1
        if all(isnan(o2.LAT.AclassinfoT))&& isempty(intersect(o2.LAT.clistclslabel,o1.LAT.clistclslabel))
        obj2_new_cls_yes=1; % o2 is based on XBPL Pset
        clistclslabel_new=[o1.LAT.clistclslabel,o2.LAT.clistclslabel];
        AclassinfoT_o2_new=replace_CH(o2.LAT.AclassinfoT_alt,[1:length(o2.LAT.clistclslabel)],[length(o1.LAT.clistclslabel)+1:(length(o1.LAT.clistclslabel) + length(o2.LAT.clistclslabel))]);
        else
        obj2_new_cls_yes=0;    
        end
        LAT_new=o1.LAT;
        if obj2_new_cls_yes
          LAT_new.clistclslabel= clistclslabel_new; 
        end
        %===========================================================
        % start operation of minus or subtraction, Sept 4, 2023
        [lia,locb, LocMatch] = ismember_by_rows_wMatchLoc(o1.LAT.Atrainpk , o2.LAT.Atrainpk);
        % LocMatch.A2B
        loc_rm=find(lia);
        LAT_new.Atrainpk(loc_rm,:)=[];
        LAT_new.AclassinfoT(loc_rm,:)=[];
        try
        LAT_new.AclabelT(loc_rm,:)=[];    
        end
        try
        LAT_new.RawSpectra(loc_rm,:)=[];    
        end
        cfname=fieldnames(LAT_new);
        cAclabelT_etc= cfname(strmatch('AclabelT_',cfname)) ;
        for ifn=1:length(cAclabelT_etc )
            LAT_new.(cAclabelT_etc{ifn})(loc_rm,:)=[];
        end
        r=ssds(LAT_new);
        return
        % only deal with Tset only case for now, Sept 4, 2023 % only deal with Tset only case for now, Sept 4, 2023 % only deal with Tset only case for now, Sept 4, 2023
        %====================================================================================================================================================================================
        %====================================================================================================================================================================================
        %====================================================================================================================================================================================

        if obj2_new_cls_yes
            LAT_new.AclassinfoT=[o1.LAT.AclassinfoT;AclassinfoT_o2_new];
            %checking to see if any NaN left
            if any(isnan(LAT_new.AclassinfoT))
                error('still some NaN exist in AclassinfoT')
            end
        else
            LAT_new.AclassinfoT=[o1.LAT.AclassinfoT;o2.LAT.AclassinfoT];
        end
        
        LAT_new.AclabelT=[o1.LAT.AclabelT;o2.LAT.AclabelT];
        %%%%%%%%%%%%%%%%%%%%%%%
        % appending saConc (only works on Tset of o2 to Tset of o1)
        if strcmp(type_Model,'PLS')
            if isfield(LAT_new,'PLS')
                LAT_new.PLS.Tset.saConc=[LAT_new.PLS.Tset.saConc;saConc_T_2];
            elseif isfield(LAT_new,'saConc') && ( isfield(o2.LAT,'PLS') |  isfield(o1.LAT,'PLS'))
                LAT_new.PLS.Tset.saConc=[LAT_new.saConc;saConc_T_2];
            else
                LAT_new.saConc=[LAT_new.saConc;saConc_T_2];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%
        try
            RawSpectra1= o1.LAT.RawSpectra.Tset;
        catch
            try
                RawSpectra1= o1.LAT.RawSpectra;
            catch
                RawSpectra1='';
            end
            
        end
        
        try
            RawSpectra2= o2.LAT.RawSpectra.Tset;
        catch
            try
                RawSpectra2= o2.LAT.RawSpectra;
            catch
                RawSpectra2='';
            end
            
        end
        
        if ~isempty(RawSpectra1) && ~isempty(RawSpectra2)
            RawSpectra_new=[RawSpectra1;RawSpectra2];
        else
            RawSpectra_new='';
        end
        
        if ~isempty(RawSpectra_new)
            try
                if isa(LAT_new.RawSpectra,'struct')
                    LAT_new.RawSpectra.Tset=RawSpectra_new;
                else
                    LAT_new.RawSpectra=RawSpectra_new;
                end
            end
        else
            LAT_new.RawSpectra=LAT_new.Atrainpk; %when RawSpectra in o1 and o2 not both exist, use Atrainpk to represent it
        end
        %%%%%%%%%%%%%%%%%%%%%%
        RawSpectra_new_P=RawSpectra_new_P_from_o1_o2(o1,o2);
        
        Tset_SAME_yes=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        disp_with_border('two Tset are identical');
        Tset_SAME_yes=1;
        
    end % end of trying to merge two different Tset
    %------------------------------------------------------------
    
    
    %                 obj_new=ssds(LAT_new);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with ILCQ with multiple XBPLs case,
    % see for example --> build_ext_TPpairs_ILCQ_multiple_XBPLs()
    if ~isSAME_two_cstr(row_always(o1.LAT.clistclslabel),row_always(o2.LAT.clistclslabel)) && strcmp(type_Model,'PLS') && ~obj2_new_cls_yes
        
        % also make sure no overlap between o1.LAT.clistclslabel vs o2.LAT.clistclslabel
        if  isempty(intersect(o1.LAT.clistclslabel,o2.LAT.clistclslabel))
            
            %LAT_new.ncls=length(o1.LAT.clistclslabel)+length(o2.LAT.clistclslabel);
            %obj_new.nclsT=obj_new.ncls;
            LAT_new.clistclslabel=[o1.LAT.clistclslabel,o2.LAT.clistclslabel];
            loc_o1=col_always([1:length(o1.LAT.AclassinfoT)]);
            loc_o2=loc_o1(end)+col_always([1:length(o2.LAT.AclassinfoT)]);
            
            LAT_new.AclassinfoT(loc_o1)=o1.LAT.AclassinfoT;
            LAT_new.AclassinfoT(loc_o2)=length(o1.LAT.clistclslabel)+o2.LAT.AclassinfoT;
            %%%%%%%%%%%%%%%%%%%%
            % then also deal with case that o1 and o2 are TP pair
            % and Pset are with NaN as AclassinfoP (typically happen in ILCQ's XBPL cases)
            %
            try
                if all(isnan(o1.LAT.AclassinfoP))&& all(isnan(o2.LAT.AclassinfoP))
                    o1_AclassinfoP=o1.LAT.AclassinfoP;
                    o2_AclassinfoP=o2.LAT.AclassinfoP;
                end
            catch
                try
                    if all(isnan(o1.LAT.AclassinfoP))
                        o1_AclassinfoP=o1.LAT.AclassinfoP;
                    end
                catch
                    o1_AclassinfoP='';
                end
                %%%%%%%%
                try
                    if all(isnan(o2.LAT.AclassinfoP))
                        o2_AclassinfoP=o2.LAT.AclassinfoP;
                    end
                catch
                    o2_AclassinfoP='';
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp('work on merging Pset of o1 and o2')
            
            if ~isempty(o1_AclassinfoP) && ~isempty(o2_AclassinfoP)
                LAT_new.clistclslabel_P=[o1.LAT.clistclslabel_P,o2.LAT.clistclslabel_P];
                LAT_new.Apred=[o1.LAT.Apred;o2.LAT.Apred];
                LAT_new.AclassinfoP=[o1.LAT.AclassinfoP;o2.LAT.AclassinfoP];
                LAT_new.AclassinfoP_alt=[o1.LAT.AclassinfoP_alt;length(o1.LAT.clistclslabel_P)+o2.LAT.AclassinfoP_alt];
                LAT_new.AclabelP=[o1.LAT.AclabelP;o2.LAT.AclabelP];
                LAT_new.PLS.Pset.saConc=[o1.LAT.PLS.Pset.saConc;o2.LAT.PLS.Pset.saConc];
                
                if exist('RawSpectra_new_P','var')&& ~isempty(RawSpectra_new_P)&& length(RawSpectra_new_P(:,1))==length(LAT_new.Apred(:,1))
                    try
                    LAT_new.RawSpectra.Pset=RawSpectra_new_P;
                    end
                end
                
                %disp('still work on merging Pset of o1 and o2')
                %error('still need to continue work on merging Pset of o1 and o2');
            elseif isempty(o1_AclassinfoP) && ~isempty(o2_AclassinfoP)
                
                LAT_new.clistclslabel_P=[o2.LAT.clistclslabel_P];
                LAT_new.Apred=[o2.LAT.Apred];
                LAT_new.AclassinfoP=[o2.LAT.AclassinfoP];
                LAT_new.AclassinfoP_alt=[o2.LAT.AclassinfoP_alt];
                LAT_new.AclabelP=[o2.LAT.AclabelP];
                
                %LAT_new.PLS.Tset.saConc=[o1.LAT.saConc];
                LAT_new.PLS.Pset.saConc=[o2.LAT.PLS.Pset.saConc];
                LAT_new=rmfield(LAT_new,'saConc');
                
                %error('still need to continue work on merging Pset of o1 and o2 in this case');
            else
                disp('continue without doing anything')
                
            end
            
            
            %%%%%%%%%%%%%%%%%%%
        elseif length(o1.LAT.clistclslabel)==length(o2.LAT.clistclslabel)
            
            [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(o1.LAT.clistclslabel,o2.LAT.clistclslabel);
            if isempty(LOC.str1_mismatch) && isempty(LOC.str2_mismatch)
                error('size of clistclslabel matched only order are different')
            else
                error('size of clistclslabel matched but contents are different')
            end
            
        else
            error('can not handle the case that there are partial overlap between o1.LAT.clistclslabel vs o2.LAT.clistclslabel')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif Tset_SAME_yes && isnan(o1.nclsP) && isnan(o2.nclsP)
        disp('work on merging Pset of o1 and o2 (in XBPL operations) when two Tset are same') ;
        inp4MP.corename='SameTset_wPsetMerged';
        out_wMerged_Pset= merge_Pset_with_SameTset_in_XBPL(o1.pathfname_AT,o2.pathfname_AT,inp4MP);
        
        LAT_new=out_wMerged_Pset.LAT;
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%
    %some sanity checks
    if any(isnan(LAT_new.AclassinfoT))
        error('still some NaN exist in AclassinfoT at finish of ssds_method_plus')
    end
    if ~isfield(LAT_new,'AclassinfoP_alt') && isfield(LAT_new,'clistclslabel_P')
    LAT_new=rmfield(LAT_new,'clistclslabel_P');
    end
    if isfield(LAT_new,'AclassinfoP_alt') && ~isfield(LAT_new,'clistclslabel_P')
    LAT_new=rmfield(LAT_new,'AclassinfoP_alt');
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj_new=ssds(LAT_new);
    if isempty(obj_new.pathfname_AT)
        inp.corename='{plus}';
        obj_new=    obj_new.saveAT(inp);
    end
    r=obj_new;
    
    
else
    warning('mismatch in nvar or clistclslabel (only for Clsfr)');
    disp('output is still obj1')
    r=o1;
    
end
end


%% ----- from ssds_method_parse_Consecutive_Block.m -------------------------
function out=ssds_method_parse_Consecutive_Block(pathfname_AT,inp)
% main function for ssds method --> parse_Consecutive_Block
% modified from parse_HBpro_consecutive_sequence()
% key function to run is --> Atrainpk_parse_AclabelT_subcls(pathfname_AT,inp)
% inp.parse_method set to 'OnePDS_EachCls' inside ssds's method --> parse_AclabelT_subcls_OnePDS_EachCls
% inp.parse_method_sub can be 
% (1) 'AllPerm' (default) --> default setting that will generate Nfold^ncls pairs of TP files
% or
% (2) 'SameFQallCls' --> all Pset have Same FQ for all Cls and only generate Nfold TP pairs
% see also parse_HBpro_consecutive_sequence_standalone Atrainpk_parse_AclabelT_subcls
% see also prep_Muscle
% see also permn
% see also Atrainpk_parse_AclabelT_subcls  parse_consecutive_sequence_Nfold
if false
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    clear;close all;
    %      inp.parse_method_sub='SameFQallCls'; % 'AllPerm' (default)
    %      inp.Nfold=3;  % inp.Nfold=3 ; (default)
    %      inp.corename_parse_folder='ML_OCM_QX_Oct10';
    % %      pathfname_AT='C:\work\JDSU\ILCQ\Test_ILCQ\ATsaConc\p1004_mhBPL\Atrainpketc_HBpro_Systolic_p1004_{BLC=CL}_pp1-1stDerSGFL7[PO2]_nsamp178_ncls2.mat'
    %  pathfname_AT='C:\work\JDSU\Test_ML_UCP\ATetc_QX_Oct10\Atrainpketc_{QX_AUC-thres0p5}_nvar35_ncls2_nsamp308.mat'
    %  parse_Consecutive_Block(pathfname_AT,inp);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this is an indirect example
    cc
    pfn_AS='C:\work\JDSU\Test_ML_UCP\datasets_mixed_attrib\X4Y_MLOCM\QX_LS_Oct10\baseline.mat'
    pathfname_QPX_wAUC= 'C:\work\JDSU\Test_ML_UCP\QPX_wAUC\QX_wAUC_MLOCM_QX_QX_LS_Oct10_Nfeat37.mat'
    %      inp.AUC_thres=[0.95];
    inp.AUC_thres=[0.65];
    inp.TP_parse_method='ConsecutiveBlock';   % 'ConsecutiveBlock'  'Split_Odd_Even'
    %           inp.TP_parse_method='Split_Odd_Even';   % 'ConsecutiveBlock'  'Split_Odd_Even'
    MLOCM_QX_or_PX_pickFeat2AT(pathfname_QPX_wAUC,pfn_AS,inp)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this is a more direct example !!!
    cc
    pathfilename_AT= 'C:\work\JDSU\Test_ML_UCP\ATetc_QX_Oct10\Atrainpketc_{QX_AUC-thres0p5}_nvar35_ncls2_nsamp308.mat'
    sd=ssds(pathfilename_AT);
    inp.TP_parse_method='ConsecutiveBlock';   % 'ConsecutiveBlock'  'Split_Odd_Even'
    inp.parse_method_sub='SameFQallCls'; % 'AllPerm' (default)
    inp.Nfold=3;  % inp.Nfold=3 ; (default)
    inp.corename='{QX_AUC-thres0p5_demo}';
    
    out_CB=sd.parse_Consecutive_Block(inp);
    % typically use this to run results from above --> BatchRun_AutoClsfr_DA_pipeline_wMixAttrib
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s_rm_OLs=find_keyword_between_markers(pathfname_AT,'rm','OLs');
if ~isempty(s_rm_OLs) 
inp.corename_parse_folder_rmOLs=['rm',s_rm_OLs,'OLs'];
else
 inp.corename_parse_folder_rmOLs=[];   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%
L=load(pathfname_AT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  Nfold=inp.Nfold;  
catch
 Nfold=3;% number of folds for cross validation, here it is using consecutive HR as subcls
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncls=length(L.clistclslabel);
AclabelT_new=L.AclabelT;
for icls=1:ncls
    loc_icls=find(L.AclassinfoT==icls);
    cparsed_loc_icls=parse_consecutive_sequence_Nfold(loc_icls,Nfold);
    for jf=1:length(cparsed_loc_icls)
        loc_icls_jf=cparsed_loc_icls{jf};
        %AclabelT_new(loc_icls_jf)=cellstr(string(AclabelT_new(loc_icls_jf))+['_FQ',num2str(jf)]);
%         AclabelT_new(loc_icls_jf)=cellstr( string(['FQ',num2str(jf)]) + ['-cls',num2str(icls)]);
        AclabelT_new(loc_icls_jf)=cellstr( ['cls',num2str(icls)] + string(['-FQ',num2str(jf)])   ); %updated Jan 16, 2019

    end
end
L.AclabelT_SpectraName=AclabelT_new;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sd=ssds(L);
if ~isfield(inp,'corename') || isempty(inp.corename)
inp.corename=find_keyword_between_markers(fileparts_name_wo_ext(pathfname_AT),'Atrainpketc_','_pp1');
end
outsaveName=sd.saveAT(inp);
sd.pathfname_AT=outsaveName.pathfname_AT;
%inp.smk1='_FQ';inp.smk2=''; % FQ--> Fold seQuence
inp.smk1='-FQ';inp.smk2=''; % FQ--> Fold seQuence
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% main function for following method: Atrainpk_parse_AclabelT_subcls()
out_parse=sd.parse_AclabelT_subcls_OnePDS_EachCls(inp); % main function: Atrainpk_parse_AclabelT_subcls()
% main function for above: Atrainpk_parse_AclabelT_subcls()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out=out_parse;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
% collect "bN_all_cls"
[clistfile_parse nfile_parse]=fdir_wildcard_wPath(out_parse.tmpfolder4Save,'Atrainpk');
clistfile_parse_sort=sortnat(fileparts_name_ext(clistfile_parse));
% L1=load(clistfile_parse{1});
% ncls=length(L1.clistclslabel);
bN_all_cls=[];% matrix list all block numbers for cls1 to clsN (each col represent one cls)
try
    for icls=1:ncls
        %%%-----------------------%%
        %%% see --> C:\work\JDSU\CUSTOMERS_OSP\BMS_BP\TestSite_PLS-BP\HBpro_Systolic_TestSite_PLS-BP_p1004_{BLC=CL}_OnePDS_EachCls_Ncomb27_nsamp263
        bN_icls=cellfun(@(x)  str2num(find_keyword_between_markers(x,['c',num2str(icls),'-b'],'_')),clistfile_parse_sort);
        %%%%%-------------%%%%%%
        % for other folders of TP pairs, the above need to change
        %%%%%-------------%%%%%%
        bN_all_cls=[bN_all_cls,bN_icls];
    end
end
%%%%%%%%%%%%%%%%%%%%%%
try
    Out4bN_all_cls.bN_all_cls= bN_all_cls;  % matrix list all block numbers for cls1 to clsN (each col represent one cls)
end
% save "Out4bN_all_cls_~.mat" that contain "bN_all_cls" ONLY
pathfilename4Out=[out_parse.tmpfolder4Save,'\','Out4bN_all_cls_',find_lastfolder( out_parse.tmpfolder4Save),'.mat'];
save(pathfilename4Out,'-struct','Out4bN_all_cls');
disp([pathfilename4Out,' has been saved']);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('done with parse_Consecutive_Block');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ----- from ssds_method_plus.m --------------------------------------------
function r=ssds_method_plus(o1,o2)
% see also ssds
% see also : ssds_method_minus
%=====================================================
% add following to deal with case that o2.LAT.clistclslabel is subset of o1.LAT.clistclslabel, Apr 5, 2024
%  see also:cross_units_predict_CARE_fLMVD 
% disp('even not same seq, but can be fix');
%===================================================
if false
    
    % this example Not finished yet
    cc
    pfn1='C:\work\JDSU\Test_ACP\CnsdLib\ATetc_BigFive_MID_Tcv\Atrainpketc_{BigFive_LS_Apr27_MaterialID_rm34OLs_rm3OLs_nF2}_nvar119_ncls6_nsamp1143.mat';
%     pfn2='C:\work\JDSU\Test_ACP\CnsdLib\ATetc_BigFive_MID_Tcv\Atrainpketc_{BigFive_LS_Apr27_MaterialID}_pp1-1stDerSGFL7[PO2]_pp2-SNV_wGloc_MID_SupCls_nvar119_ncls6_nsamp1181.mat'
    %-----------------------------------------------------------
    % revisit Mar 20, 2024 aft extr Val M1-470 DM
    cc
    pfn1='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_extr_Val_0320\Tset_only\Atrainpketc_{ncls7_6U_ApdCls-N6_S3_rmCls-TP}_nvar119_ncls7_nsamp1959.mat';
    pfn2='C:\work\JDSU\Test_ACP\Carpet_Lib_24\ATetc_extr_Val_0320\Tset_only\Atrainpketc_{M1-470_extr_Val_DM_0320_woTP_M1-470}_nvar119_ncls6_nsamp75.mat'
    %-----------------------------------------------------
     %=============================================================
    % revisit for LA fiber carpet samples, May 11, 2024
    
    cc
    pfn_1='C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_LA_Carpet\T_Care_nTU6_P-LA_ncls2_Nylons_MK_Sort_SN_Dn1\Atrainpketc_{T-(AT_indv_ncls8_6U_N6_N66)_P-(MK_SN_Dn1_M1-599_MK_SN_Dn1_Cln)}_nvar119_ncls2_nsampT450_nsampP227.mat'
    sd0=ssds(pfn_1);
    sd0_T=sd0.rm_Pset;
    o1=sd0_T;
    pfn_2='C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\Tcv_nF3_{MK_SN_Dn1_M1-599_MK_SN_Dn1_Cln}\Atrainpketc_{P-f-1_nF3_(MK_SN_Dn1_M1-599_MK_SN_Dn1_Cln)}_nvar119_ncls1_nsampT156_nsampP71.mat';
    o2=ssds(pfn_2);
    sd_T=o1+o2;
    
    sd_TP=sd_T>o2.P2T;
    %--------------------------------------------------------------------------------------------
    % PP from LAf, June 19, 2024
    cc
    sd1=ssds('C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_VS0612_0619_PP-Only\indvU\Atrainpketc_{LAf_PP_M1-105}_nvar119_ncls1_nsamp250.mat');
    sd2=ssds('C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_VS0612_0619_PP-Only\indvU\Atrainpketc_{LAf_PP_M1-109}_nvar119_ncls1_nsamp250.mat');
    sd12=sd1+sd2;
    sd3=ssds('C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_VS0612_0619_PP-Only\indvU\Atrainpketc_{LAf_PP_M1-470}_nvar119_ncls1_nsamp250.mat');
    sd_all=sd12+sd3;   

    
    
    
    
end
%====================================================================
disp('append obj2 to obj1')
% check whether o1 and o2 match in "type_Model"
if strcmp(o1.type_Model,o2.type_Model)
    type_Model=o1.type_Model;
    try
        try
            saConc_T_1=o1.LAT.PLS.Tset.saConc;
        catch
            saConc_T_1=o1.LAT.saConc;
        end
    catch
        saConc_T_1='';
    end
    
    try
        try
            saConc_T_2=o2.LAT.PLS.Tset.saConc;
        catch
            saConc_T_2=o2.LAT.saConc;
        end
    catch
        saConc_T_2='';
    end
else
    error('obj1 and obj2 have different "type_Model"');
    
end
%             if ~isempty(saConc_T_1) && ~isempty(saConc_T_2)
%                 type_Model='PLS';
%             elseif isempty(saConc_T_1) && isempty(saConc_T_2)
%                 type_Model='Clsfr';
%             else
%                 error('can not determine whether it is PLS or Clsfr')
%             end


%check if nvar and clistclslabel match
% add row_always and deblank, July 19, 2023
%===============================================================
% add following to deal with case that o2.LAT.clistclslabel is subset of o1.LAT.clistclslabel, Apr 5, 2024
%  see also:cross_units_predict_CARE_fLMVD 
if ~isequal(deblank(row_always(o1.LAT.clistclslabel)),deblank(row_always(o2.LAT.clistclslabel)))  && all(ismember( deblank(row_always(o2.LAT.clistclslabel)) ,deblank(row_always(o1.LAT.clistclslabel))))
   [lia,locb] =  ismember( deblank(row_always(o2.LAT.clistclslabel)) ,deblank(row_always(o1.LAT.clistclslabel)));
  
   if  ~isequal(locb,[1:length(locb)])
       disp('++++++++++++++++++++++++++');
       disp('even not same seq, but can be fix');
       disp('++++++++++++++++++++++++++');
       o2.LAT.clistclslabel=strrep_cstr  (o2.LAT.clistclslabel, o2.LAT.clistclslabel, o1.LAT.clistclslabel ) ;
       o2.LAT.AclassinfoT=replace_CH(o2.LAT.AclassinfoT, locb, [1:length(locb)]) ;
       try
            o2.LAT.AclassinfoP=replace_CH(o2.LAT.AclassinfoP, locb, [1:length(locb)]) ;
       end
       
   end
    
    %     sdTi_P_sdT_kTi=sdTi>sdT_kTi;
    %     sdTi=  sdTi + sdTi_P_sdT_kTi.P2T ;
    sd_T1_P2=o1>o2;
    o2=sd_T1_P2.P2T;
    if false
        o2.LAT.clistclslabel
        unique(o2.LAT.AclassinfoT)
    end
end
%==================================================================
if o1.nvar==o2.nvar && ( strcmp(type_Model,'PLS') ||  ( strcmp(type_Model,'Clsfr') && isSAME_two_cstr(deblank(row_always(o1.LAT.clistclslabel)),deblank(row_always(o2.LAT.clistclslabel)))  )  )
    
    %                 if isequal(o1.LAT.clistclslabel,o2.LAT.clistclslabel)
    
    %-------------------------------------------------------
    % only try to merge Tset when they are different
    if ~isSAME_Tset(o1.LAT,o2.LAT)
        % check to see if o2 is based on XBPL Pset, i.e. o2.LAT.AclassinfoT are all NaN
        %  and o2.LAT.clistclslabel are all different from o1.LAT.clistclslabel
        % if it is true, then append o2 as new classes to o1
        if all(isnan(o2.LAT.AclassinfoT))&& isempty(intersect(o2.LAT.clistclslabel,o1.LAT.clistclslabel))
        obj2_new_cls_yes=1; % o2 is based on XBPL Pset
        clistclslabel_new=[o1.LAT.clistclslabel,o2.LAT.clistclslabel];
        AclassinfoT_o2_new=replace_CH(o2.LAT.AclassinfoT_alt,[1:length(o2.LAT.clistclslabel)],[length(o1.LAT.clistclslabel)+1:(length(o1.LAT.clistclslabel) + length(o2.LAT.clistclslabel))]);
        else
        obj2_new_cls_yes=0;    
        end
        
        LAT_new=o1.LAT;
        
        if obj2_new_cls_yes
          LAT_new.clistclslabel= clistclslabel_new; 
        end
        
        LAT_new.Atrainpk=[o1.LAT.Atrainpk;o2.LAT.Atrainpk];
        if obj2_new_cls_yes
            LAT_new.AclassinfoT=[o1.LAT.AclassinfoT;AclassinfoT_o2_new];
            %checking to see if any NaN left
            if any(isnan(LAT_new.AclassinfoT))
                error('still some NaN exist in AclassinfoT')
            end
        else
            LAT_new.AclassinfoT=[o1.LAT.AclassinfoT;o2.LAT.AclassinfoT];
        end
        
        LAT_new.AclabelT=[o1.LAT.AclabelT;o2.LAT.AclabelT];
        %%%%%%%%%%%%%%%%%%%%%%%
        % appending saConc (only works on Tset of o2 to Tset of o1)
        if strcmp(type_Model,'PLS')
            if isfield(LAT_new,'PLS')
                LAT_new.PLS.Tset.saConc=[LAT_new.PLS.Tset.saConc;saConc_T_2];
            elseif isfield(LAT_new,'saConc') && ( isfield(o2.LAT,'PLS') |  isfield(o1.LAT,'PLS'))
                LAT_new.PLS.Tset.saConc=[LAT_new.saConc;saConc_T_2];
            else
                LAT_new.saConc=[LAT_new.saConc;saConc_T_2];
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%
        try
            RawSpectra1= o1.LAT.RawSpectra.Tset;
        catch
            try
                RawSpectra1= o1.LAT.RawSpectra;
            catch
                RawSpectra1='';
            end
            
        end
        
        try
            RawSpectra2= o2.LAT.RawSpectra.Tset;
        catch
            try
                RawSpectra2= o2.LAT.RawSpectra;
            catch
                RawSpectra2='';
            end
            
        end
        
        if ~isempty(RawSpectra1) && ~isempty(RawSpectra2)
            RawSpectra_new=[RawSpectra1;RawSpectra2];
        else
            RawSpectra_new='';
        end
        
        if ~isempty(RawSpectra_new)
            try
                if isa(LAT_new.RawSpectra,'struct')
                    LAT_new.RawSpectra.Tset=RawSpectra_new;
                else
                    LAT_new.RawSpectra=RawSpectra_new;
                end
            end
        else
            LAT_new.RawSpectra=LAT_new.Atrainpk; %when RawSpectra in o1 and o2 not both exist, use Atrainpk to represent it
        end
        %%%%%%%%%%%%%%%%%%%%%%
        RawSpectra_new_P=RawSpectra_new_P_from_o1_o2(o1,o2);
        
        Tset_SAME_yes=0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    else
        disp_with_border('two Tset are identical');
        Tset_SAME_yes=1;
        
    end % end of trying to merge two different Tset
    %------------------------------------------------------------
    
    
    %                 obj_new=ssds(LAT_new);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % deal with ILCQ with multiple XBPLs case,
    % see for example --> build_ext_TPpairs_ILCQ_multiple_XBPLs()
    if ~isSAME_two_cstr(row_always(o1.LAT.clistclslabel),row_always(o2.LAT.clistclslabel)) && strcmp(type_Model,'PLS') && ~obj2_new_cls_yes
        
        % also make sure no overlap between o1.LAT.clistclslabel vs o2.LAT.clistclslabel
        if  isempty(intersect(o1.LAT.clistclslabel,o2.LAT.clistclslabel))
            
            %LAT_new.ncls=length(o1.LAT.clistclslabel)+length(o2.LAT.clistclslabel);
            %obj_new.nclsT=obj_new.ncls;
            LAT_new.clistclslabel=[o1.LAT.clistclslabel,o2.LAT.clistclslabel];
            loc_o1=col_always([1:length(o1.LAT.AclassinfoT)]);
            loc_o2=loc_o1(end)+col_always([1:length(o2.LAT.AclassinfoT)]);
            
            LAT_new.AclassinfoT(loc_o1)=o1.LAT.AclassinfoT;
            LAT_new.AclassinfoT(loc_o2)=length(o1.LAT.clistclslabel)+o2.LAT.AclassinfoT;
            %%%%%%%%%%%%%%%%%%%%
            % then also deal with case that o1 and o2 are TP pair
            % and Pset are with NaN as AclassinfoP (typically happen in ILCQ's XBPL cases)
            %
            try
                if all(isnan(o1.LAT.AclassinfoP))&& all(isnan(o2.LAT.AclassinfoP))
                    o1_AclassinfoP=o1.LAT.AclassinfoP;
                    o2_AclassinfoP=o2.LAT.AclassinfoP;
                end
            catch
                try
                    if all(isnan(o1.LAT.AclassinfoP))
                        o1_AclassinfoP=o1.LAT.AclassinfoP;
                    end
                catch
                    o1_AclassinfoP='';
                end
                %%%%%%%%
                try
                    if all(isnan(o2.LAT.AclassinfoP))
                        o2_AclassinfoP=o2.LAT.AclassinfoP;
                    end
                catch
                    o2_AclassinfoP='';
                end
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            disp('work on merging Pset of o1 and o2')
            
            if ~isempty(o1_AclassinfoP) && ~isempty(o2_AclassinfoP)
                LAT_new.clistclslabel_P=[o1.LAT.clistclslabel_P,o2.LAT.clistclslabel_P];
                LAT_new.Apred=[o1.LAT.Apred;o2.LAT.Apred];
                LAT_new.AclassinfoP=[o1.LAT.AclassinfoP;o2.LAT.AclassinfoP];
                LAT_new.AclassinfoP_alt=[o1.LAT.AclassinfoP_alt;length(o1.LAT.clistclslabel_P)+o2.LAT.AclassinfoP_alt];
                LAT_new.AclabelP=[o1.LAT.AclabelP;o2.LAT.AclabelP];
                LAT_new.PLS.Pset.saConc=[o1.LAT.PLS.Pset.saConc;o2.LAT.PLS.Pset.saConc];
                
                if exist('RawSpectra_new_P','var')&& ~isempty(RawSpectra_new_P)&& length(RawSpectra_new_P(:,1))==length(LAT_new.Apred(:,1))
                    try
                    LAT_new.RawSpectra.Pset=RawSpectra_new_P;
                    end
                end
                
                %disp('still work on merging Pset of o1 and o2')
                %error('still need to continue work on merging Pset of o1 and o2');
            elseif isempty(o1_AclassinfoP) && ~isempty(o2_AclassinfoP)
                
                LAT_new.clistclslabel_P=[o2.LAT.clistclslabel_P];
                LAT_new.Apred=[o2.LAT.Apred];
                LAT_new.AclassinfoP=[o2.LAT.AclassinfoP];
                LAT_new.AclassinfoP_alt=[o2.LAT.AclassinfoP_alt];
                LAT_new.AclabelP=[o2.LAT.AclabelP];
                
                %LAT_new.PLS.Tset.saConc=[o1.LAT.saConc];
                LAT_new.PLS.Pset.saConc=[o2.LAT.PLS.Pset.saConc];
                LAT_new=rmfield(LAT_new,'saConc');
                
                %error('still need to continue work on merging Pset of o1 and o2 in this case');
            else
                disp('continue without doing anything')
                
            end
            
            
            %%%%%%%%%%%%%%%%%%%
        elseif length(o1.LAT.clistclslabel)==length(o2.LAT.clistclslabel)
            
            [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(o1.LAT.clistclslabel,o2.LAT.clistclslabel);
            if isempty(LOC.str1_mismatch) && isempty(LOC.str2_mismatch)
                error('size of clistclslabel matched only order are different')
            else
                error('size of clistclslabel matched but contents are different')
            end
            
        else
            error('can not handle the case that there are partial overlap between o1.LAT.clistclslabel vs o2.LAT.clistclslabel')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif Tset_SAME_yes && isnan(o1.nclsP) && isnan(o2.nclsP)
        disp('work on merging Pset of o1 and o2 (in XBPL operations) when two Tset are same') ;
        inp4MP.corename='SameTset_wPsetMerged';
        out_wMerged_Pset= merge_Pset_with_SameTset_in_XBPL(o1.pathfname_AT,o2.pathfname_AT,inp4MP);
        
        LAT_new=out_wMerged_Pset.LAT;
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%
    %some sanity checks
    if any(isnan(LAT_new.AclassinfoT))
        error('still some NaN exist in AclassinfoT at finish of ssds_method_plus')
    end
    if ~isfield(LAT_new,'AclassinfoP_alt') && isfield(LAT_new,'clistclslabel_P')
    LAT_new=rmfield(LAT_new,'clistclslabel_P');
    end
    if isfield(LAT_new,'AclassinfoP_alt') && ~isfield(LAT_new,'clistclslabel_P')
    LAT_new=rmfield(LAT_new,'AclassinfoP_alt');
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    obj_new=ssds(LAT_new);
    if isempty(obj_new.pathfname_AT)
        inp.corename='{plus}';
        obj_new=    obj_new.saveAT(inp);
    end
    r=obj_new;
    
    
else
 % EB   
%     warndlg('mismatch in nvar or clistclslabel, output is still obj1');
%     disp('output is still obj1');
    disp_with_border('mismatch in nvar or clistclslabel (only for Clsfr)');
    disp_with_border('output is still obj1');
    r=o1;
    
end
end


%% ----- from ssds_method_plus_wDup.m ---------------------------------------
function   r=ssds_method_plus_wDup(o1,o2)
% main function to call --> ssds_plus_wDup_reAssemble
% modified from --> prep_add_N6_N66_TO_Big7_reAssemble
% see also: ssds_plus_wDup_reAssemble
% created Feb 15, 2024
%========================================================================
if false
    
    cc
    pfn_AT1='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat';
    pfn_AT2='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig-(Orig_Big7+Nylons(RK))_clistclslabelMatch2-(Orig_Big7+Nylons(CARE))}_nvar119_ncls9_nsampT694_nsampP620.mat';
    o1=ssds( pfn_AT1); o2=ssds( pfn_AT2);
    r= ssds_method_plus_wDup(o1,o2);
    
end
%---------------------------------------------------------------------------------------
cd(find_last_nonTMP_path);
Path_tmpfolder=tmp_folder_rm_mk('TMP_plus_wDup',pwd);
cd(Path_tmpfolder);
%--------------------------------------------
pfn_AT1=o1.pathfname_AT;

if ~isempty( o2.pathfname_AT)
pfn_AT2=o2.pathfname_AT;
else
pfn_AT2=o2.LAT;   
end
inp4reAssemble='';
out=ssds_plus_wDup_reAssemble( pfn_AT1 , pfn_AT2, inp4reAssemble );
r=out;
%---------------------------------------
cd(find_last_nonTMP_path);
copyfile(out.pathfname_new,pwd);
%---------------------------------------


done_with_this_function;
end


%% ----- from ssds_method_plus_wDup_4Py_combined.m --------------------------
function final_pfn = ssds_method_plus_wDup_4Py_combined(pfn_AT1_orig, pfn_AT2_orig)
% Combines two SSDS datasets, creating a single output file and cleaning up all intermediate files.
% Preserves the original source files by working in an isolated temporary directory.
%
% Inputs:
%   pfn_AT1_orig: Path (relative or absolute) to the first original .mat file.
%   pfn_AT2_orig: Path (relative or absolute) to the second original .mat file.
%
% Output:
%   final_pfn: Path to the new, combined .mat file.
%
% Created: Feb 15, 2024
% Modified: July 12, 2025
%========================================================================
if false
    
    % This `if false` block contains all valid example use cases,
    % which will now be handled correctly by the robust file management logic.
    
    % --- Example #1: Relative paths ---
    cc
    pfn_AT1 = 'plus_wDup_partOL/Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat';
    pfn_AT2 = 'plus_wDup_partOL/Atrainpketc_{Orig-(Orig_Big7+Nylons(RK))_clistclslabelMatch2-(Orig_Big7+Nylons(CARE))}_nvar119_ncls9_nsampT694_nsampP620.mat';
    final_pfn = ssds_method_plus_wDup_4Py_combined(pfn_AT1, pfn_AT2);
    %----------------------------------------------------------------------------
    
    % --- Example #2: Absolute paths ---
    cc
    pfn_AT1 = 'C:\work\JDSU\mfiles\ChemoTools_Py\ssds_in_Python\SLbl_SplitApd_nTU1\SameT\Atrainpketc_(1){ApdCls-N6_S3_T-103_P-105}_nvar119_ncls8_nsampT355_nsampP375.mat';
    pfn_AT2 = 'C:\work\JDSU\mfiles\ChemoTools_Py\ssds_in_Python\SLbl_SplitApd_nTU1\Atrainpketc_(30){ApdCls-N6_S3_T-600_P-599}_nvar119_ncls8_nsampT373_nsampP375.mat';
    final_pfn = ssds_method_plus_wDup_4Py_combined(pfn_AT1, pfn_AT2);
    %----------------------------------------------------------------------------

    % --- Example #3: Absolute paths with identical properties ---
    cc
    pfn_AT1 = 'C:\work\JDSU\mfiles\ChemoTools_Py\ssds_in_Python\SLbl_SplitApd_nTU1\SameT\Atrainpketc_(1){ApdCls-N6_S3_T-103_P-105}_nvar119_ncls8_nsampT355_nsampP375.mat';
    pfn_AT2 = 'C:\work\JDSU\mfiles\ChemoTools_Py\ssds_in_Python\SLbl_SplitApd_nTU1\SameT\Atrainpketc_(2){ApdCls-N6_S3_T-103_P-109}_nvar119_ncls8_nsampT355_nsampP375.mat';
    final_pfn = ssds_method_plus_wDup_4Py_combined(pfn_AT1, pfn_AT2);
    %----------------------------------------------------------------------------
    
    % --- Example #4: Absolute paths with identical properties ---
    cc
    pfn_AT1 = 'C:\work\JDSU\mfiles\ChemoTools_Py\ssds_in_Python\SLbl_SplitApd_nTU1\SameT\Atrainpketc_(1){ApdCls-N6_S3_T-103_P-105}_nvar119_ncls8_nsampT355_nsampP375.mat';
    pfn_AT2 = 'C:\work\JDSU\mfiles\ChemoTools_Py\ssds_in_Python\SLbl_SplitApd_nTU1\SameP\Atrainpketc_(12){ApdCls-N6_S3_T-109_P-105}_nvar119_ncls8_nsampT375_nsampP375.mat';
    final_pfn = ssds_method_plus_wDup_4Py_combined(pfn_AT1, pfn_AT2);
    %----------------------------------------------------------------------------
end
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------
    
    % --- Environment Setup ---
    original_dir = pwd;
    % Create a single, isolated temporary directory for all operations.
    tmp_folder = fullfile(original_dir, ['TMP_plus_wDup_' datestr(now,'yyyymmddTHHMMSSFFF')]);
    mkdir(tmp_folder);
    
    % Guarantees that upon function exit (due to success or error),
    % we change back to the original directory and delete the temp folder.
    cleanupHandler = onCleanup(@() {cd(original_dir); rmdir(tmp_folder, 's');});

    try
        % --- Step 1: Isolate Inputs to Prevent Collisions ---
        % Copy source files to the temp folder with safe, unique names.
        pfn_AT1_safe_copy = fullfile(tmp_folder, 'input1.mat');
        pfn_AT2_safe_copy = fullfile(tmp_folder, 'input2.mat');
        copyfile(which(pfn_AT1_orig), pfn_AT1_safe_copy);
        copyfile(which(pfn_AT2_orig), pfn_AT2_safe_copy);
        
        % ** CRITICAL STEP: Change the working directory into the sandbox **
        cd(tmp_folder);
        
        % --- Step 2: Call the worker function ---
        % It will now run entirely inside the temp folder, containing all side effects.
        r = ssds_plus_wDup_reAssemble_4Py('input1.mat', 'input2.mat');
        
        % --- Step 3: Move the final result out to the original directory ---
        [~, fname_new, ext_new] = fileparts(r.pathfname_new);
        final_filename = [fname_new, ext_new];
        final_pfn = fullfile(original_dir, final_filename);
        
        % The movefile source path must be absolute in case the filename is the same
        % as a file in the original directory.
        movefile(fullfile(pwd, r.pathfname_new), final_pfn);
        
    catch ME
        % The onCleanup handler will run automatically to clean the directory.
        % We just rethrow the error to make sure the user knows what went wrong.
        rethrow(ME);
    end
    
    % The onCleanup handler will run here upon successful completion,
    % changing back to the original directory and deleting the temp folder.

    
    % --- Nested Subfunction: ssds_plus_wDup_reAssemble_4Py ---
    function out = ssds_plus_wDup_reAssemble_4Py(pfn_AT1, pfn_AT2)
        % This function's logic remains the same. It is the computational core and
        % now runs safely inside the temporary directory.
        L1 = load(pfn_AT1);
        L2 = load(pfn_AT2);
        
        out.Tset = isSAME_or_PartialMatch_2Matrix_regardless_sequence_4Py(L1.Atrainpk, L2.Atrainpk);
        try, out.Pset = isSAME_or_PartialMatch_2Matrix_regardless_sequence_4Py(L1.Apred, L2.Apred); catch, out.Pset = struct(); end
        
        clear L1 L2;

        sd1 = ssds(pfn_AT1);
        sd1T = sd1.rm_Pset;
        if isempty(out.Tset.loc_NotSAME_AT2)
            sd_T_new = sd1T;
            corename_T = '{SameTset}';
        else
            sd2 = ssds(pfn_AT2);
            sd2T = sd2.rm_Pset;
            inp_sd2.loc_rm = out.Tset.loc_SAME_AT2;
            sd2T_NotSame = sd2T.rm_samps_Tset(inp_sd2);
            sd_T_new = sd1T + sd2T_NotSame;
            corename_T = sprintf('{NnewT=%d}', length(out.Tset.loc_NotSAME_AT2));
        end

        sd1P = sd1.P2T;
        if isempty(out.Pset.loc_NotSAME_AT2)
            sd_P_new = sd1P;
            corename_P = '{_SamePset}';
        else
            if ~exist('sd2', 'var'), sd2 = ssds(pfn_AT2); end
            sd2P = sd2.P2T;
            inp_sd2P.loc_rm = out.Pset.loc_SAME_AT2;
            sd2P_NotSame = sd2P.rm_samps_Tset(inp_sd2P);
            sd_P_new = sd1P + sd2P_NotSame;
            corename_P = sprintf('{_NnewP=%d}', length(out.Pset.loc_NotSAME_AT2));
        end
        clear sd1 sd1T sd1P sd2 sd2T sd2P sd2T_NotSame sd2P_NotSame inp_sd2 inp_sd2P;

        sd_TP_new = sd_T_new > sd_P_new;
        corename_TP = strrep([corename_T, corename_P], '}{', '');
        
        sd_TP_new.saveAT(struct('corename', corename_TP));

        search_pattern = ['*' corename_TP '*.mat'];
        file_list = dir(search_pattern);
        if isempty(file_list), error('SaveFailed: Final combined file was not created.'); end
        
        % Return just the filename, as the caller knows it's in the current (temp) directory.
        out.pathfname_new = file_list(1).name;
    end

    % --- Nested Subfunction: isSAME_or_PartialMatch_2Matrix_regardless_sequence_4Py ---
    function out = isSAME_or_PartialMatch_2Matrix_regardless_sequence_4Py(AT1, AT2)
        [lia_1, ~] = ismember(AT1, AT2, 'rows');
        [lia_2, ~] = ismember(AT2, AT1, 'rows');
        out.loc_SAME_AT1 = find(lia_1);
        out.loc_SAME_AT2 = find(lia_2);
        out.loc_NotSAME_AT1 = find(~lia_1);
        out.loc_NotSAME_AT2 = find(~lia_2);
    end

end


%% ----- from ssds_method_plus_wExtractCls.m --------------------------------
function r=ssds_method_plus_wExtractCls(o1,o2,inp)
%  main function to call --> ssds_plus_wExtractCls_reAssemble
% so far only run --> "ssds_method_plus" , Not "ssds_method_plus_wDup"
% see also: ssds_method_add_append_classes
%--------------------------------------------------------
% see also: ssds_method_extract_plus_apd_class (Feb 20, 2024)
%---------------------------------------------------------------
%-------------------------------------------------------------------------
if false
    
    %========================================================================
    cc
    pfn_orig='C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Atrainpketc_{Orig_Big7+Nylons(RK)}_nvar119_ncls9_nsampT694_nsampP620.mat'
    pfn_Nylons='C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{CARE_fVS}_nvar119_ncls6_nsampT225_nsampP75.mat'
    %--------------------------
    % rename clistclslabel to match format in pfn_orig
    inp.clistclslabel_replace={...
        '[Carpet]-N6','N6';...
        '[Carpet]-N66','N66';...
        };
    out_rename_Nylons=AT_replace_clistclslabel(pfn_Nylons,inp);
    %--------------------------
    o1=ssds(pfn_orig);
    o2=ssds(out_rename_Nylons.pfn_AT_new);
    inp.cls_pick={'N66','N6'}; % seq Not important
    inp.action='extract';
    % r=ssds_method_plus_wExtractCls(o1,o2,inp)
    r=plus_wExtractCls(o1,o2,inp)
    %------------------------
    inp.sPrefix_1='1)-';
    inp.sPrefix_2='2)-';
    out_corename=consolidate_corename_2_pfn(pfn_orig,pfn_Nylons,inp);
    inp.corename=out_corename;
    r.saveAT(inp)
    
    
    %========================================================================
    % see also: ssds_method_add_append_classes
    cc
    pfn_orig='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat'    % see also: ssds_method_add_append_classes
    pfn_Nylons = 'C:\work\JDSU\Test_ACP\Recycle_Lib_24\Nylons_CARE_RK\Nylons_source\Atrainpketc_{RK_T-109-105_P-EdEmLS}_nvar119_nclsT50_nclsP33_nsampT2100_nsampP607.mat'
    %--------------------------
    % rename clistclslabel to match format in pfn_orig
    inp.clistclslabel_replace={...
        'Nylon - Type 66','N66';...               %
        'Nylon - Type 6 (Homopolymer)','N6';...   %
        };
    out_rename_Nylons=AT_replace_clistclslabel(pfn_Nylons,inp);
    %--------------------------
    o1=ssds(pfn_orig);
    o2=ssds(out_rename_Nylons.pfn_AT_new);
    inp.cls_pick={'N66','N6'}; % seq Not important
    inp.action='extract';
    r=plus_wExtractCls(o1,o2,inp);
    %------------------------
    inp.sPrefix_1='1)-';
    inp.sPrefix_2='2)-';
    out_corename=consolidate_corename_2_pfn(pfn_orig,pfn_Nylons,inp);
    inp.corename=out_corename;
    r.saveAT(inp)
    %=============================================================
    
    
end
%-----------------------------------------------

out=ssds_plus_wExtractCls_reAssemble(o1,o2,inp);

r=out;
done_with_this_function;
end


%% ----- from ssds_method_rm_Pset.m -----------------------------------------
function out_obj = ssds_method_rm_Pset(obj)
% run ssds method --> rm_Pset
% created May 21, 2024
% see also: rmfield_AclabelP_AclassinfoP_etc
%----------------------------------
% add this May 21, 2024
%======================================================
if false
    %---------------------------------------
    
    cc
    sd1=ssds('C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_LAfiber_bF_OfficeCarpet\eaSn_MK0511\nF2\Atrainpketc_{P-f-1_nF2_(T-(AT_indv_ncls8_6U_N6_N66)_(MK_0511_aftFix)_AclabelT-ClsName_Sn_Only)}_nvar119_ncls2_nsampT309_nsampP397.mat');
    sd1T=sd1.rm_Pset;
    
    
    %---------------------------------------
    
    cc
    sd1=ssds('C:\work\JDSU\Test_ACP\Enhanced_CarpetLib\ATetc_LAfiber_bF_OfficeCarpet\eaSn_MK0511\nF2\Atrainpketc_{P-f-2_nF2_(T-(AT_indv_ncls8_6U_N6_N66)_(MK_0511_aftFix)_AclabelT-ClsName_Sn_Only)}_nvar119_ncls2_nsampT397_nsampP309.mat')
    sd1T=sd1.rm_Pset;
    
    %---------------------------------------
    
end
%--------------------------------------


LAT= obj.LAT;
%++++++++++++++++++++++++++++++++++++++++++++++++++++
% add this May 21, 2024
% cfdn=fieldnames(LAT);% add this May 21, 2024
% % LAT=rmfield(LAT,cfdn(loc_AcP ));% add this May 21, 2024
% loc_AclassinfoP=strmatch('AclassinfoP',cfdn);% add this May 21, 2024
% loc_AclabelP=strmatch('AclabelP',cfdn);% add this May 21, 2024
% LAT=rmfield(LAT,cfdn([loc_AclassinfoP;loc_AclabelP ]));% add this May 21, 2024

LAT=rmfield_AclabelP_AclassinfoP_etc(LAT);

%+++++++++++++++++++++++++++++++++++++++++++++++++++
% LAT= rmfield(LAT,{'Apred','AclassinfoP','AclabelP'});
LAT= rmfield(LAT,{'Apred'});
% try
%     LAT= rmfield(LAT,{'AclassinfoP_alt'});
% end
%----------------------------------------------
try
    LAT.RawSpectra=LAT.RawSpectra.Tset;
end
try
    LAT.saConc=LAT.PLS.Tset.saConc;
end
try
    LAT= rmfield(LAT,'PLS');
end
%%%%%%%%%%%%%%%%%%%%%%%%%
out_obj_tmp=ssds(LAT);
% corename=find_keyword_between_markers(fileparts_name_ext( obj.pathfname_AT),'(',')');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% add this May 21, 2024
corename=get_corename_pfn(obj.pathfname_AT);
corename_P=find_keyword_between_markers(corename,'_P-','}');% add this May 21, 2024
if ~isempty(corename_P)
    corename=strrep(corename,['_P-',corename_P],'');% add this May 21, 2024
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if isempty(corename)
    corename=['{','rm_Pset','}'];
end
inp.corename=corename;
out_obj_tmp2=out_obj_tmp.saveAT(inp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
out_obj=out_obj_tmp2;
%=============================================================

done_with_this_function;
end


%% ----- from ssds_method_run_CFP_GM_kt.m -----------------------------------
function Out=ssds_method_run_CFP_GM_kt( pfn_GM_only, inp )
% will call --> ssds_method_maxDV_dvABC_kt
% similar to --> kt_maxDV_dvABC_insituThres_GlobalModel_or_Local_barebone
%==============================================================

if false

   
     %===============================================================
   
   % test kt vs non-kt approaches
   % begin of Aug, 2024
   cc
   %+++++++++++++++
   % % save sd_iqcn_kt based on kt (or WinCls1st ) approach , end of July, 2024 
   inp.dvABC_by_kt_yes=1;  % see also: 
   %+++++++++++++++++++
           path_GM_only='C:\work\JDSU\KTaug\Test_KTa\ATetc_CFP_GM_Demo\CARE_TruePos'   % new dataset as Demo, Aug 2024 (both Tset and Pset sorted)
%          path_GM_only='C:\work\JDSU\KTaug\Test_KTa\ATetc_CFP_GM_Demo\5Powders'
   %+++++++++++++++++++
   inp.Clsfr_Global='SVM_linear_wDecVal_APs';           % current settings
   inp.Clsfr_force_Predict='SVM_linear_wDecVal_APs';    % current settings
   inp.dvB_PDS_yes=0;                                   % based on All scans (current setting by DM )
   %----------------------------
   inp.InsituThres_scheme='IV';
   inp.CFP_dvABC_SVM_kernel='rbf';  % default set to 'rbf';
   %----------------------------- 
   [clistfilename_out, nfile_out]=fdir_wildcard_ext_wPath(path_GM_only,'Atrainpketc_','mat');

   Out=ssds_method_run_CFP_GM_kt( clistfilename_out{1}, inp ) ;
      %===============================================================
   
end
%============================================================================================================================
cd(find_last_nonTMP_path);
pathTMP=tmp_folder_rm_mk('TMP_2SCFP',pwd);
cd(pathTMP );
%----------------------------------------------------

L0=load( pfn_GM_only );
sd0=ssds(L0);

L0_auto=apply_autoscale_on_Atrainpketc_L_struct( L0 ) ;
%==============================================================================================================================
%==============================================================================================================================
try
    Clsfr_short_GM=inp.Clsfr_Global;
catch
    Clsfr_short_GM='SVM_Linear_wDecVal_APs';  % default set to this
end
switch Clsfr_short_GM
    case { 'SVM_linear_wDecVal_APs'}
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        handles4Clsfr.L=L0_auto;
        [handles4Clsfr out4Clsfr]=RUN_SVM_linear_wDecVal_CmpClsfr(handles4Clsfr);
        all_predcls= out4Clsfr.predcls;
        loc_misP=find(all_predcls~=L0.AclassinfoP);
        %+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    otherwise
        error('Global Model type Not supported ??');
end
%==============================================================================================================================
%==============================================================================================================================

qclsnum_apor_predcls=unique_appear_order(all_predcls) ;
inp4eaBR.fig_yes=0;
% loc_Pset=repmat(NaN,size(L0.AclassinfoP));
all_maxDV=repmat(NaN,size(L0.AclassinfoP));
all_thres_insitu=repmat(NaN,size(L0.AclassinfoP));
all_qcn_i=repmat(NaN,size(L0.AclassinfoP));

all_dvABC_gm=[];
call_nPDS_WinCls=[];
all_out_eaBR=[];
loc_Pset_i_0=0;

%  winner_clsnum=find(strcmp(L0.clistclslabel,inp.winner_clistclslabel));
for iqcn=1: length(qclsnum_apor_predcls )
    qcn_i=qclsnum_apor_predcls(iqcn);
    inp4eaBR.winner_clistclslabel=L0.clistclslabel{qcn_i };
    %--------------------------------------
%     inp4eaBR.Clsfr_Global=inp.Clsfr_Global;
%      inp4eaBR.InsituThres_scheme=inp.InsituThres_scheme;
%      inp4eaBR.List_nLcls=inp.List_nLcls;
      inp4eaBR=catstruct(inp4eaBR,inp);
     
    %****************************************
    inp_iqcn.loc_rm_Pset=find(all_predcls~=qcn_i);
    sd_iqcn = sd0.rm_samps_Pset_or_Tset_in_TPpair(inp_iqcn);
    inp_iqcn.corename=['{',find_keyword_between_markers(fileparts_name_ext(pfn_GM_only),'Atrainpketc_','_nvar'),'[WinCls-',inp4eaBR.winner_clistclslabel ,']','}'];
    sd_iqcn=sd_iqcn.saveAT( inp_iqcn );
    %--------------------------------------------------------------------------------
    % apply asmc1 on AT (  end of July, 2024 )
   LAT_sd_iqcn_asmc1=apply_autoscale_on_Atrainpketc_L_struct(sd_iqcn.LAT);
     sd_iqcn_asmc1 =ssds(LAT_sd_iqcn_asmc1);
      inp_iqcn_asmc1.corename=strrep(inp_iqcn.corename,']',']_asmc1');
     sd_iqcn_asmc1= sd_iqcn_asmc1.saveAT( inp_iqcn_asmc1);
    %--------------------------------------------------------------------------------
    pfn_GM_only_Winner_Only_iqcn=sd_iqcn.pathfname_AT;
%     inp_iqcn.cls_pick= { inp4eaBR.winner_clistclslabel }  ;   %
%     inp_iqcn.corename=['{',find_keyword_between_markers(fileparts_name_ext(pfn_GM_only),'Atrainpketc_','_nvar'),'[',inp4eaBR.winner_clistclslabel ,']','}'];
%     sd0=ssds(L0);
%     sd_winP_iqcn=extract_Pset(sd0,inp_iqcn);% need  inp.cls_pick
    %***************************************
    %=============================================================================================================
    %=============================================================================================================
    % calc of dvB in --> dvABC_etc_Global_or_Local_Model will take long time when Tset size is big
    %
%     out_eaBR=kt_maxDV_dvABC_insituThres_GlobalModel_or_Local_barebone (pfn_GM_only_Winner_Only_iqcn, inp4eaBR );
        out_eaBR=ssds_method_maxDV_dvABC_kt (pfn_GM_only_Winner_Only_iqcn, inp4eaBR );

    all_out_eaBR=[all_out_eaBR ;  out_eaBR ];
    %=============================================================================================================
    %=============================================================================================================
    %++++++++++++++++++++++++++++++++++++++++++++++++++++
   if ~isempty( out_eaBR.LAT_rq_sT)
           inp_iqcn_kt.corename=['{',find_keyword_between_markers(fileparts_name_ext(pfn_GM_only),'Atrainpketc_','_nvar'),'[WinCls1st-',inp4eaBR.winner_clistclslabel ,']','}'];    % save sd_iqcn_kt based on kt (or WinCls1st ) approach , end of July, 2024
           sd_iqcn_kt=ssds( out_eaBR.LAT_rq_sT);
           sd_iqcn_kt=sd_iqcn_kt.saveAT( inp_iqcn_kt);   % save sd_iqcn_kt based on kt (or WinCls1st ) approach , end of July, 2024
   end
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++
    all_dvABC_gm=[all_dvABC_gm; out_eaBR.dvABC_gm];

    call_nPDS_WinCls=[call_nPDS_WinCls;{out_eaBR.nPDS_WinCls}];

    %======================================
loc_Pset_i =  loc_Pset_i_0 + col_always( [1:length(find(all_predcls==qcn_i))])   ;
loc_Pset_i_0=loc_Pset_i(end);

    all_maxDV(loc_Pset_i)=out_eaBR.maxDV_gm;
    all_thres_insitu( loc_Pset_i ) = out_eaBR.thres_insitu_IV;
    all_qcn_i( loc_Pset_i ) =qcn_i;
end
%------------------------------------------------
% checking
if false
    if ~isequal(all_qcn_i,all_predcls)
        error('something wrong with all_qcn_i');
    else
        if all(isnan(L0.AclassinfoP))
            tb_seq=[];
        else
            tb_seq =  findseq(all_qcn_i) ;
        end
    end
else
    tb_seq=[];
end
%========================================================
%================================================
%--------------------------------------------
call_dvABC_gm_sdvB_PDS_yes  =arrayfun(@(x) x.sdvB_PDS_yes,  all_dvABC_gm,'un',0) ;
try
    Qcall_dvABC_gm_sdvB_PDS_yes = unique(call_dvABC_gm_sdvB_PDS_yes) ;
    if length(Qcall_dvABC_gm_sdvB_PDS_yes )==1 && ~isempty(Qcall_dvABC_gm_sdvB_PDS_yes{1})
        sQcall_dvABC_gm_sdvB_PDS_yes=Qcall_dvABC_gm_sdvB_PDS_yes{1};
    elseif isempty(Qcall_dvABC_gm_sdvB_PDS_yes{1})
        sQcall_dvABC_gm_sdvB_PDS_yes='dvB Tcv based on All scans';
    else
        sQcall_dvABC_gm_sdvB_PDS_yes='';
    end
catch
 sQcall_dvABC_gm_sdvB_PDS_yes='dvB Tcv based on All scans';   
end
%----------------------------------------------------------------------
hf_maxDV=figure;hold on;set(gcf,'position',[ 0.5147    0.2317    1.2373    0.6261]*1000);
ylabel('maxDV of Pset');xlabel('Pset Sample Seq');


if isempty( tb_seq )
    plot(all_maxDV,'b-*');
    plot( all_thres_insitu,'color',color_CH('o'),'marker',marker_CH('-'),'linewidth',2);
else
    for i_tb_seq=1:length( tb_seq (:,1))
        loc_seq_i_begin_end=tb_seq(i_tb_seq,2:3);
        loc_seq_i = [loc_seq_i_begin_end(1): loc_seq_i_begin_end(2)] ;
        plot(   loc_seq_i , all_thres_insitu(loc_seq_i),'color',color_CH('o'),'marker',marker_CH('d'),'linewidth',2);
        plot(   loc_seq_i , all_maxDV(loc_seq_i),'color',color_CH('b'),'marker',marker_CH('*'));
    end
end
%---------------------------------

%-----------------------------------
enlarge_axis;
title_usF(['Both CFP & force_Predict based on --> ', Clsfr_short_GM]);
title_add(gca,fileparts_name_ext(pfn_GM_only));
try
title_add(gca,['CFP_dvABC_SVM_kernel=',inp.CFP_dvABC_SVM_kernel]);
end

%=========================================================
Out.all_maxDV=all_maxDV;
Out.all_thres_insitu=all_thres_insitu;
Out.all_predcls=all_predcls;
Out.clistclslabel=L0.clistclslabel;
Out.AclassinfoP=L0.AclassinfoP;
Out.AclabelP=L0.AclabelP;
Out.sQcall_dvABC_gm_sdvB_PDS_yes=sQcall_dvABC_gm_sdvB_PDS_yes;
Out.WinCls=all_qcn_i;
Out.all_nPDS_WinCls=call_nPDS_WinCls; % collect nPDS_WinCls, May 1, 2024
%-------------------------------------
% if  inp.dvABC_by_kt_yes
% arrayfun(@(x) copyfile(x.pfn_dvABC,find_last_nonTMP_path),all_out_eaBR) ;
% arrayfun(@(x) copyfile(x.pfn_wc1_wP,find_last_nonTMP_path),all_out_eaBR) ;
% end
%========================================================
 %--------------------------------------------------------------------------
 cd(find_last_nonTMP_path);

done_with_this_function;
end
%=======================================================


%% ----- from ssds_plus_wDup_reAssemble.m -----------------------------------
function out=ssds_plus_wDup_reAssemble( pfn_AT1 , pfn_AT2, inp )
% this function typically called by --> ssds_method_plus_wDup
%-------------------------------------------------
% this function typically used after calling --> prep_add_N6_N66_TO_Big7
% will call --> isSAME_or_PartialMatch_2Matrix_regardless_sequence
%=============================================================================
% see also: prep_add_N6_N66_TO_Big7
% see also: isSAME_2Matrix_regardless_sequence
% see also: isSAME_or_PartialMatch_2Matrix_regardless_sequence
%==========================================================================
if false
    
    % pfn_orig='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_Big7\Atrainpketc_{EmLS_Orig_Big7_T-f2_P-f1}_nvar119_ncls7_nsampT610_nsampP585.mat'
    
    cc
    pfn_AT1='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig_Big7+Nylons(CARE)}_nvar119_ncls9_nsampT700_nsampP616.mat';
    pfn_AT2='C:\work\JDSU\Test_ACP\Commercial_PlasticsRecycle_Carpet_Lib\ATetc_OrigBig7_apdNylons\Atrainpketc_{Orig-(Orig_Big7+Nylons(RK))_clistclslabelMatch2-(Orig_Big7+Nylons(CARE))}_nvar119_ncls9_nsampT694_nsampP620.mat';
    inp='';
    out=ssds_plus_wDup_reAssemble( pfn_AT1 , pfn_AT2, inp )
    
end
%================================================================

L1=load(pfn_AT1);
if ischar( pfn_AT2)&& ~isempty(pfn_AT2 )
L2=load(pfn_AT2);
elseif isstruct( pfn_AT2)
L2=pfn_AT2;    
end
%----------------------------------

out_Tset=isSAME_or_PartialMatch_2Matrix_regardless_sequence(L1.Atrainpk,L2.Atrainpk);
%----------------------------------------------------------
try
out_Pset=isSAME_or_PartialMatch_2Matrix_regardless_sequence(L1.Apred,L2.Apred);
catch
out_Pset='';    
end
%----------------------------------------------------------
if isstruct(out_Tset) && ~isempty(out_Tset.loc_SAME_AT2)
    
    sd2=ssds(pfn_AT2);
    sd2T=sd2.rm_Pset;
    inp_sd2.loc_rm=out_Tset.loc_SAME_AT2;
   sd2T_NotSame = sd2T.rm_samps_Tset(inp_sd2);
   sd1=ssds(pfn_AT1);
    sd1T=sd1.rm_Pset;
   %--------------------------------------------------------------------
    if length(out_Tset.loc_SAME_AT2)==length(out_Tset.loc_SAME_AT1)
        if ~isempty(out_Tset.loc_SAME_AT1 )
            sNdupT=['_NdupT',num2str(length(out_Tset.loc_SAME_AT2))];
        else
            sNdupT='';
        end
    else
        error('something wrong with out_Tset.loc_SAME_AT2 vs out_Tset.loc_SAME_AT1 ?');
    end
     if ~isempty(out_Tset.loc_NotSAME_AT1)
        sNnewT1=['_NnewT1=',num2str(length(out_Tset.loc_NotSAME_AT1))];
    else
       sNnewT1='';
     end
     if ~isempty(out_Tset.loc_NotSAME_AT2)
        sNnewT2=['_NnewT2=',num2str(length(out_Tset.loc_NotSAME_AT2))];
    else
       sNnewT2='';
     end
     %------------------------------------------------------------------
    sd_T_new=sd1T + sd2T_NotSame;
    inp_Tn.corename=['{',sNdupT,sNnewT1,sNnewT2,'}'];
    sd_T_new.saveAT(inp_Tn);
end
%----------------------------------------------------------
if isstruct(out_Pset) && ~isempty(out_Pset.loc_SAME_AT2)
    
    %sd2=ssds(pfn_AT2);
    sd2P=sd2.P2T;
    inp_sd2P.loc_rm=out_Pset.loc_SAME_AT2;
   sd2P_NotSame = sd2P.rm_samps_Tset(inp_sd2P);
   
%    sd1=ssds(pfn_AT1);
    sd1P=sd1.P2T;
   %+++++++++++++++++++++++++++++++++++++++++++
    %--------------------------------------------------------------------
    if length(out_Pset.loc_SAME_AT2)==length(out_Pset.loc_SAME_AT1)
        if ~isempty(out_Pset.loc_SAME_AT1 )
            sNdupP=['_NdupP',num2str(length(out_Pset.loc_SAME_AT2))];
        else
            sNdupP='';
        end
    else
        error('something wrong with out_Pset.loc_SAME_AT2 vs out_Pset.loc_SAME_AT1 ?');
    end
     if ~isempty(out_Pset.loc_NotSAME_AT1)
        sNnewP1=['_NnewP1=',num2str(length(out_Pset.loc_NotSAME_AT1))];
    else
       sNnewP1='';
     end
     if ~isempty(out_Pset.loc_NotSAME_AT2)
        sNnewP2=['_NnewP2=',num2str(length(out_Pset.loc_NotSAME_AT2))];
    else
       sNnewP2='';
     end
     %------------------------------------------------------------------
   %+++++++++++++++++++++++++++++++++++++++++++++
    sd_P_new=sd1P + sd2P_NotSame;
     inp_Pn.corename=['{',sNdupP,sNnewP1,sNnewP2,'}'];
    sd_P_new.saveAT(inp_Pn);
   %-------------------------------------- 
   sd_TP_new=sd_T_new>sd_P_new;
  inpTPn.corename = [inp_Tn.corename,inp_Pn.corename] ;
   inpTPn.corename=strrep(inpTPn.corename,'}{','');
  sd_TP_new = sd_TP_new.saveAT(inpTPn);
   
end
%------------------------------
out.Tset=out_Tset;
out.Pset=out_Pset;
out.sd_TP_new=sd_TP_new;
out.pathfname_new=sd_TP_new.pathfname_AT;
%------------------------------
done_with_this_function;
end


%% ----- from ssds_plus_wExtractCls_reAssemble.m ----------------------------
function out=ssds_plus_wExtractCls_reAssemble(o1,o2,inp)
% this function typically called by --> ssds_method_plus_wExtractCls
if false
    
    
end
%----------------------------------------------------------------------------------

o2x=merge_rm_extract_class(o2,inp);
%---------------------------------------------------------------------------------------------------------------
% Match AclassinfoT and AclassinfoP and clistclslabel from "o2x" to "o1"
[lia,locb] =   ismember(col_always( o2x.LAT.clistclslabel ), col_always(o1.LAT.clistclslabel ) ) ;
if all(lia)
    o2x.LAT.AclassinfoT=replace_CH(o2x.LAT.AclassinfoT,[1:length(o2x.LAT.clistclslabel)],row_always(locb));
    try
     o2x.LAT.AclassinfoP=replace_CH(o2x.LAT.AclassinfoP,[1:length(o2x.LAT.clistclslabel)],row_always(locb));    
    end
 o2x.LAT.clistclslabel=row_always(o1.LAT.clistclslabel);
else
    error('some classes in o2x can Not find matches in o1  ??');
end
%--------------------------------------------------------------------------------------------------------------
%   r= ssds_method_plus_wDup(o1,o2x);       % so far only run --> "ssds_method_plus" , Not "ssds_method_plus_wDup"
%-----------
r_T=o1.rm_Pset+o2x.rm_Pset;    % so far only run --> "ssds_method_plus" , Not "ssds_method_plus_wDup"
r_P=o1.P2T+o2x.P2T;            % so far only run --> "ssds_method_plus" , Not "ssds_method_plus_wDup"
r=r_T>r_P;
%----------------------------------------------------------------------------------------------------------------
out=r;
%---------------------------------------
done_with_this_function;
end


%% ----- from strcmp_CI.m ---------------------------------------------------
function result=strcmp_CI(str1,str2);
%Case Insensitive version of strcmp
% e.g.  strcmp_CI('good','Good')
% strcmp_CI('good','bad')

result=strcmp(lower(str1),lower(str2));
end


%% ----- from strcmp_CI_two_cstr.m ------------------------------------------
function match_table=strcmp_CI_two_cstr(cstr1,cstr2)
% pls see also findstr_CI_two_cstr.m
match_table=[];
for ic1=1:length(cstr1)
    for ic2=1:length(cstr2)
       if strcmp_CI(cstr1(ic1),cstr2(ic2))
           match_table(ic1,ic2)=1;
       else
           match_table(ic1,ic2)=0;
       end
    end
end
end


%% ----- from strcmp_CI_two_cstr_deblank.m ----------------------------------
function [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(cstr1,cstr2,varargin)
% modified from strcmp_CI_two_cstr_PLOT() by adding deblank
% based on match_table from strcmp_CI_two_cstr.m to plot out the two cstr
% and connect all matching pairs with lines
% e.g. cstr1={'ab','cde','gh','ijkl'};cstr2={'abc','cde','gh'}; [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_PLOT(cstr1,cstr2)
% e.g. cstr1={'ba','ab','cde','xy','gh','ijkl'};cstr2={'baa','abc','cde','gh'}; inp.figyes=1;[cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_PLOT(cstr1,cstr2,inp)
% checking: cstr1(LOC.str1_match)
% checking: cstr2(LOC.str2_match)
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%  use LOC.str1_match_str2 to map cstr1 to order of cstr2
%  use LOC.str2_match_str1 to map cstr2 to order of cstr1
% see examples below
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% see also isSAME_Tset isSAME_2Matrix
% see also ismembertol_ByRows CStrAinBP  cmp_related
if false
    
    cstr1={'a','b','c','d','e'};
    cstr2={'b','d','e','c'};
    [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(cstr1,cstr2);
    cstr1(LOC.str1_match_str2)
    cstr2(LOC.str2_match_str1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      cstr1={'b','c','d'};
    cstr2={'a','d','e','c','f','b'};
    [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(cstr1,cstr2);
    cstr1(LOC.str1_match_str2)
    cstr2(LOC.str2_match_str1)
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      cstr1={'a','b','c','d'};
    cstr2={'d','c','b','a'};
    [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(cstr1,cstr2);
    cstr1(LOC.str1_match_str2)
    cstr2(LOC.str2_match_str1)
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      cstr1={'b','a','d','c'};
    cstr2={'a','b','c','d'};
    [cstr1_strcmp_matched  cstr2_strcmp_matched  LOC]=strcmp_CI_two_cstr_deblank(cstr1,cstr2);
    cstr1(LOC.str1_match_str2)
    cstr2(LOC.str2_match_str1)

    
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isempty(varargin)
inp=varargin{1};
figyes=inp.figyes;
else
figyes=0;    %default
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% prefilter with deblank !!!
cstr1=deblank(cstr1);
cstr2=deblank(cstr2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    match_table_Glucose_CH_DH=strcmp_CI_two_cstr(cstr1,cstr2);
    
    loc_rows_match=find(sum(match_table_Glucose_CH_DH,2)>=1);
    cstr1_strcmp_matched=cstr1(loc_rows_match);
    
    loc_cols_match=find(sum(match_table_Glucose_CH_DH,1)>=1);
    cstr2_strcmp_matched=cstr2(loc_cols_match);
    
    loc_rows_mismatch=[1:length(cstr1)]';
    loc_rows_mismatch(loc_rows_match)=[];

    cstr1_strcmp_Mismatched=cstr1(loc_rows_mismatch);
    
    
    loc_cols_mismatch=[1:length(cstr2)]';
    loc_cols_mismatch(loc_cols_match)=[];

    cstr2_strcmp_Mismatched=cstr2(loc_cols_mismatch);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if figyes==1
    figure;hold on;
    maxlength_two_cstr=max([length(cstr1_strcmp_matched),length(cstr2_strcmp_matched), length(cstr1_strcmp_Mismatched),length(cstr2_strcmp_Mismatched)]);
    
    plot([0 250],[0 maxlength_two_cstr],'w.');
    try  text(90*ones(length(cstr1_strcmp_matched),1),[maxlength_two_cstr:-1:maxlength_two_cstr-length(cstr1_strcmp_matched)+1],fix_underscore_cstr(cstr1_strcmp_matched),'HorizontalAlignment','right');
    end
    
    try  text(110*ones(length(cstr2_strcmp_matched),1),[maxlength_two_cstr:-1:maxlength_two_cstr-length(cstr2_strcmp_matched)+1],fix_underscore_cstr(cstr2_strcmp_matched),'HorizontalAlignment','left');
    end

    try text(40*ones(length(cstr1_strcmp_Mismatched),1),[maxlength_two_cstr:-1:maxlength_two_cstr-length(cstr1_strcmp_Mismatched)+1],fix_underscore_cstr(cstr1_strcmp_Mismatched),'HorizontalAlignment','right');
    end
    
    try text(160*ones(length(cstr2_strcmp_Mismatched),1),[maxlength_two_cstr:-1:maxlength_two_cstr-length(cstr2_strcmp_Mismatched)+1],fix_underscore_cstr(cstr2_strcmp_Mismatched),'HorizontalAlignment','left');
    end
    
    [rows cols vals]=find(match_table_Glucose_CH_DH==1);
    for imatch=1:length(vals)
        plot([90 110],[maxlength_two_cstr-find(loc_rows_match==rows(imatch))+1,maxlength_two_cstr-find(loc_cols_match==cols(imatch))+1],'g-');
    end
 text(90,maxlength_two_cstr+2,[num2str(length(loc_rows_match)),'/',num2str(length(cstr1))],'HorizontalAlignment','right');
 text(110,maxlength_two_cstr+2,[num2str(length(loc_cols_match)),'/',num2str(length(cstr2))],'HorizontalAlignment','left');
 
 text(40,maxlength_two_cstr+2,[num2str(length(loc_rows_mismatch)),'/',num2str(length(cstr1))],'HorizontalAlignment','right');
 text(160,maxlength_two_cstr+2,[num2str(length(loc_cols_mismatch)),'/',num2str(length(cstr2))],'HorizontalAlignment','left');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LOC.match_table=match_table_Glucose_CH_DH;

% rearrange LOC.str1_match and LOC.str2_match in one-on-one match sequence
[Imatch tmp1]=find(LOC.match_table);

[Jmatch tmp2]=find(LOC.match_table');% fixed by CH, March 2, 2017

% [XX YY]=find(LOC.match_table);



% the following two are in one-on-one match sequence 
% e.g. cstr1(LOC.str1_match_str2(1))==cstr2(LOC.str2_match_str1(1))
% cstr1(LOC.str1_match_str2(end))==cstr2(LOC.str2_match_str1(end))
LOC.str1_match_str2=Imatch;
LOC.str2_match_str1=Jmatch;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checking
if length(cstr1)==length(cstr2)
    if ~isSAME_two_cstr(cstr1(Imatch),cstr2)|~isSAME_two_cstr(cstr2(Jmatch),cstr1)
        %error('something wrong with LOC.str1_match_str2 and LOC.str2_match_str1')
               warning('something wrong with LOC.str1_match_str2 and LOC.str2_match_str1')

    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LOC.str1_match=loc_rows_match;    % Very Important: NOT in same sequence as  LOC.str2_match
LOC.str1_mismatch=loc_rows_mismatch;

LOC.str2_match=loc_cols_match;   % Very Important: NOT in same sequence as  LOC.str1_match
LOC.str2_mismatch=loc_cols_mismatch;
end





    %sum(sum(match_table_Glucose_CH_DH))


%% ----- from strfind_cstr.m ------------------------------------------------
function out=strfind_cstr(PATTERN,cstr)
% Note that input variables' seq is different from strfind !!!
% see -->  IND = STRFIND(TEXT,PATTERN)
%-------------------------------------------------------------------------------
% alias as strmatch_strfind_idx or strmatch_findstr_idx
% strmatch that "index" output same size as cstr with logical true/false, similar to FIND
% can handle first input is cstr and 2nd input is str too
% strmatch_findstr_idx and strmatch_strfind_idx are the SAME
% see also strmatch_strfind_idx
% updated May 21, 2020
out=strmatch_strfind_idx(PATTERN,cstr);
end


%% ----- from strmatch_findstr_loc.m ----------------------------------------
function LOC=strmatch_findstr_loc(str,cstr)
% strmatch that use findstr scheme to output location (NOT index) of result, 
% this will have similar format like strmatch
% this is especially useful for cases that element(s) of cstr only contain
% part of  str, e.g. 'Refrigerat' is part of 'Refrigerator'
% see also  strmatch_strfind_loc   strmatch_findstr  strmatch_strfind
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if false
    
        str='Refrigerator';
    cstr=    {'Space Heater','Air Conditioner','Clothes Dryer','Refrigerat'};

     strmatch_findstr_loc(str,cstr)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strmatch_findstr(str,cstr)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strmatch(str,cstr)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    strmatch_strfind(str,cstr)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if iscell(cstr) && ischar(str)
out=cellfun(@(x) ~isempty(findstr(x,str)),cstr);
LOC=find(out==1);
else
    error('input#1 should be char and input#2 should be cell !!!')
    
end
end


%% ----- from strmatch_strfind_idx.m ----------------------------------------
function out=strmatch_strfind_idx(str,cstr)
% strmatch that "index" output same size as cstr with logical true/false, similar to FIND
% can handle first input is cstr and 2nd input is str too
% strmatch_findstr_idx and strmatch_strfind_idx are the SAME
% see also strfind_cstr  strmatch_findstr_idx  containstr  strmatch_findstr
% updated by CH, Feb 3, 2020
if ischar(cstr) && iscell(str)
out=cellfun(@(x) ~isempty(strfind(x,cstr)),str);
elseif ischar(str) && iscell(cstr)
out=cellfun(@(x) ~isempty(strfind(x,str)),cstr);
else
    error('can not handle this case of str and cstr')
end
end


%% ----- from strread_delimiter.m -------------------------------------------
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


%% ----- from strread_delimiter_2num.m --------------------------------------
function num=strread_delimiter_2num(str,sdelimiter)
% converting string of text into array of numbers, use strread and user provided delimiter
% can use either 2p5 or  2.5 in the str
%   e.g.1
%   num=strread_delimiter_2num('2_5_36','_');
%  e.g.2
%   num=strread_delimiter_2num('2_2p5_3p6','_');
%  num=[2  2.5  3.6];
%  e.g.3
%   num=strread_delimiter_2num('2_10.5_8.6','_')

% e.g. 4, it is OK with extra us at end
%   num=strread_delimiter_2num('2_10.5_8.6_','_')

cstr=strread(str,'%s','delimiter',sdelimiter);
num=cellfun(@(x) str2num(period4p(x)),cstr)';
end

function str=period4p(str)
str=replace_CH(str,'p','.');
end


%% ----- from strrep_cstr.m -------------------------------------------------
function out=strrep_cstr( A, cstr1, cstr2 )
% can handle when cstr1 or cstr2 ischar !!!
% deal with matching whole char vector of each element of cstr instead of partial match of each cstr in strrep
% May 20, 2024
%------------------------------------------------------------------------
% see also: replace_CH (deal with matching whole char vector of each element of cstr instead of partial match of each cstr in strrep)
% alias for replace_CH (Apr 7, 2022)
% see also: ApdCls_eaSn (May 20, 2024)
%-------------------------------------------------------------------------
if false
    
    cc
     strrep_cstr({'aa' 'a' 'b' 'aa' 'c'},{'aa'},{'ddd'}) 
     %----------------------------------------------------------------------
     
     cc
     L=load( 'C:\work\JDSU\Manuf_U2U\Test-mU2U\ATetc_production_MN_wcrStd\SVM\Atrainpketc_mU2U_fVS_0328_aftRm4OutliersUnits(OSW)_w_lvfID_nvar125_ncls3_nsampT1752_nsampP1752.mat')
     AclabelT_lvfID_new=strrep_cstr(L.AclabelT_lvfID,{'1025-10070Z'},{'1025-10070z'});  % better approach
     [qz nz]=unique_count(AclabelT_lvfID_new)
     [qz_orig nz_orig]=unique_count(L.AclabelT_lvfID)
     sum(nz_orig(1:2))
     
    
end
%=====================================================
if ischar(cstr1)  % can handle when cstr1 or cstr2 ischar !!!
    cstr1={cstr1};
end
if ischar(cstr2)  % can handle when cstr1 or cstr2 ischar !!!
    cstr2={cstr2};
end
%----------------------------------------------
out=replace_CH( A, cstr1, cstr2 );






done_with_this_function;
end


%% ----- from strrep_keyword_between_markers_wlistRHS.m ---------------------
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


%% ----- from strrep_recursive.m --------------------------------------------
function [ S ] = strrep_recursive( S1,S2,S3 )
% strrep_recursive repeat strrep until it is not changed anymore
%   for example:
%  t='000111333322222' when run with strrep_recursive(t,'33','3')
% will become '000111322222'
%  t='000111333322222' when run with strrep_recursive(t,'22','2')
% will become '00011133332'
%  if only want to remove all space, you can simply use strrep(S1,' ','')

length_S1=length(S1);
S=S1;
while length(S)>=length_S1
    S=strrep( S,S2,S3 );
    
    if length(S)==length_S1
        return;
    end
    
    length_S1=length(S);
end
end


%% ----- from struct2xls.m --------------------------------------------------
function struct2xls(filename,s,varargin)
%STRUC2XLS Writes the contents os a simple structure into an Excel file
% STRUC2XLS (FILE,S) writes the contents of structure S to a excel file
% named FILE. The name of the structure can be followed by parameter/value 
% pairs to specify additional properties. 
% 
% The name of the worksheet can be specified as (...,'Sheet',WSHEET) 
% where WSHEET is a character string. If it does not exist it will be added 
% to the excel file. The starting row and column can be specified as 
% (...,'Row',R) and (...,'Col',C) respectively. R must be a non-negative 
% integer, and C must be a capital letter from 'A' to 'Z'. Field names will 
% be written in column C starting at row R. The contents of the structure 
% will be written adjacent to each field name.
% 
% EXAMPLE: 
%	s= struct('one',[1,2],'two',[10,20,30],'three',[100,200,300,400]);
%	struct2xls('s2xls',s,'Row',4,'Col','D')
%
%	Jan-31-2008


%Defaults
sheet= 'Sheet1';
col= 'A';
fstrow= 1;

%Optional arguments
if ~isempty(varargin)
	for j= 1:2:length(varargin)
		switch varargin{j}
			case 'Sheet'
				sheet= varargin{j+1};
			case 'Col'
				col= varargin{j+1};
			case 'Row'
				fstrow= varargin{j+1};
			otherwise
				error ('Unrecognized argument name');
		end
	end
end

%Transform to cell
c= struct2cell(s);

%Field names
f= fieldnames(s);

%write
for j= 1:size(f,1)
	% m= cell2mat(c(j));
    S=cell2struct(c(j),'m');
    
    
	%rangeA= [col,num2str(j+fstrow-1)];
    	rangeA= [char(double(col-1+j)),'1'];

    
    
	% rangeB= [char(double(col+1)),num2str(j+fstrow-1)];
    %	rangeB= [char(double(col)),num2str(j+fstrow-1+1)];
        rangeB= [char(double(col-1+j)),'2'];

	xlswrite(filename,f(j),sheet,rangeA);
    
	%xlswrite(filename,m,sheet,rangeB);
    	xlswrite(filename,S.m,sheet,rangeB);

    
    
end
end


%% ----- from strwrite_all_delimiter.m --------------------------------------
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


%% ----- from strwrite_all_delimiter_numeric_input.m ------------------------
function out=strwrite_all_delimiter_numeric_input( loc_replace,delimiter )
% see also: AT2XLS_ACP

if false
    
    cc
    loc_replace=[3;12;23;5];
    strwrite_all_delimiter_numeric_input( loc_replace,'_' )
end
%======================================================================================
%--------------------------------------------------------------------------
sloc_replace=strwrite_all_delimiter( cellstr(  string(row_always(loc_replace))),delimiter);
out=sloc_replace;
end


%% ----- from strwrite_all_space.m ------------------------------------------
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


%% ----- from textual_eraseBetween_rmkw1.m ----------------------------------
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


% disp('finish textual_eraseBetween_rmkw1')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ----- from textual_extractBetween.m --------------------------------------
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
% disp('finish textual_extractBetween')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% ----- from textual_extractBetween_multiple_kw2.m -------------------------
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

% else
% disp('some ckw2 are empty')
% 
% 
% 
% 
% end


%% ----- from textual_replaceBetween_multiple_kw2.m -------------------------
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

% else
% disp('some ckw2 are empty')
% 
% 
% 
% 
% end


%% ----- from title_add.m ---------------------------------------------------
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


%% ----- from title_usF.m ---------------------------------------------------
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
% else
% % %------------------------------------------------
% % % following will avoid the issue with usF etc
%  set(0, 'DefaultTextInterpreter', 'none');   % somehow need to rerun this, even though it has been setup to run during startup : ML_jdsu_woPLStoolbox ?
%     title(ctit);
% end


%% ----- from tmp_folder_rm_mk.m --------------------------------------------
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

% --- Merged from file: fdir_wildcard.m ---
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

% --- Merged from file: fdir_wildcard_wPath.m ---
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

% --- Helper function from fdir_wildcard_wPath.m ---
function out=tmp_folder_rm_mk__isNOTParentFolders(x)

if ~strcmp(tmp_folder_rm_mk__fileparts_name_ext(x),'.') && ~strcmp(tmp_folder_rm_mk__fileparts_name_ext(x),'..')
    out=true;
else
    out=false;
    
end
end

% --- Merged from file: regexp_extract_mk1_mk2.m ---
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

% --- Merged from file: delete_cstrFile_tmpFolder.m ---
function delete_cstrFile_tmpFolder(Path_tmpfolder)
% delete all files from Path_tmpfolder, , but not subfolder(s)
    clistfile=tmp_folder_rm_mk__fdir_wildcard_wPath(Path_tmpfolder,'*');

cellfun(@(x) delete_fileONLY(x),clistfile);
end

% --- Helper function from delete_cstrFile_tmpFolder.m ---
function delete_fileONLY(x)
fkw=tmp_folder_rm_mk__regexp_extract_mk1_mk2(x,'\','');


if strcmp(x,'.') || strcmp(x,'..') || strcmp(fkw,'.') || strcmp(fkw,'..')
%     disp('cont wo delete');
else
    delete(x);
    
end
end

% --- Merged from file: disp_with_border.m ---
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

% --- Merged from file: fileparts_name_ext.m ---
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

% --- Merged from file: cc.m ---
function [] = tmp_folder_rm_mk__cc()
%CC Full Clear / Complete Clear
%   Because I'm too lazy to type clear;close all;clc every damn time
evalin('base','clear');
close all;
clc
end


%% ----- from underscoreFix.m -----------------------------------------------
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

% --- Local Helper Function ---
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


%% ----- from unique_appear_order.m -----------------------------------------
function list_TIC_appear_order=unique_appear_order(list_TIC_Letter)
% this can handle numeric array or single vector of char array or cstr
%
% do the 'unique' function but sorted by the order appeared in the sequence
% based on first appearance of that symbol
% e.g  list_TIC_Letter='NNNNNSSSSSKKKKK';
% for cstr pls use unique_appear_order_cstr
%=============================================================================================
if false
    
    cc 
    list_TIC_Letter={'aaa','aaa','bbbb','bbbb','bbbb','c','c','a','a','a','a'}'
    list_TIC_appear_order=unique_appear_order(list_TIC_Letter)
    
    %-----------------------------------------------------------------
   cc 
    list_TIC_Letter='NNNNNSSSSSKKKKK';
    list_TIC_appear_order=unique_appear_order(list_TIC_Letter)  
      %-----------------------------------------------------------------
   cc 
    list_TIC_Letter=[1  1  1  3  0.2 0.2 0.2  -2 -2 -2 5 5]';
    list_TIC_appear_order=unique_appear_order(list_TIC_Letter)  
    
    
    
end
%=============================================================================================
if iscell(list_TIC_Letter)
    %    error('for input of cstr, pls use unique_appear_order_cstr()');    % this can only handle numeric array or single vector of char array that is not cell
    
    list_TIC_appear_order=unique_appear_order_cstr(list_TIC_Letter);
    
else
    list_TIC_appear_order=list_TIC_Letter;
    for iT=1:length(unique(list_TIC_Letter)  )
        loc_iT=findstr(row_vector_ALWAYS(list_TIC_appear_order),list_TIC_appear_order(iT));
        list_TIC_appear_order(loc_iT(2:end)) =[];
    end
end
end


%% ----- from unique_appear_order_cstr.m ------------------------------------
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


%% ----- from unique_count.m ------------------------------------------------
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
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++

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

%+++++++++++++++++++++++++++++++++++++++++++++++++++++
%+++++++++++++++++++++++++++++++++++++++++++++++++++++

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


%+++++++++++++++++++++++++++++++++++++++++++++++++++++
%+++++++++++++++++++++++++++++++++++++++++++++++++++++


%% ----- from unique_count_appear_order_cstr.m ------------------------------
function [uniques,numUnique] = unique_count_appear_order_cstr(cstr,option)
% this can handle both numeric array or cstr
% see also : unique_count_appear_order (alias of this function)
%------------------------------------------------
% modified from unique_count and unique_appear_order_cstr
% this can handle numeric array too
% see also: diagnose_misP_iACPmp
%----------------------------------
% see also: unique_count_sortnat_cstr (May 10, 2024)
%===================================================
if false
 % test with numeric array
    cc
    cstr=[1  1  1  3  0.2 0.2 0.2  -2 -2 -2 5 5]'    % this can handle numeric array too
    [uniques,numUnique] = unique_count_appear_order_cstr(cstr)
    %-------------------------------------------------
  % test with cstr  
  cc
     cstr={'aaa','aaa','bbbb','bbbb','bbbb','c','c','a','a','a','a'}'
   [uniques,numUnique] = unique_count_appear_order_cstr(cstr)  
    
end
%===================================================
%------------------------------------------------
if isnumeric( cstr )
cstr_unique_appear_order=unique_appear_order(cstr) ;% this can handle numeric array too
elseif iscell(cstr)
cstr_unique_appear_order=unique_appear_order_cstr(cstr) ;
else
    error('cstr should be cstr or numeric');
end

[qcstr  ncstr] =unique_count(cstr) ;

[lia,locb] = ismember(cstr_unique_appear_order,qcstr);
ncstr_appear_order= ncstr ( locb ) ;

uniques=cstr_unique_appear_order;
numUnique = ncstr_appear_order ;
end

% done_with_this_function;


%% ----- from unique_count_sortnat_cstr.m -----------------------------------
function [uniques,numUnique] = unique_count_sortnat_cstr(cstr)
% modified from unique_count_appear_order_cstr
% this only handle cstr
% May 10, 2024
%-------------------------------------------------------
% see also: unique_count_appear_order_cstr
% see also : unique_count_appear_order (alias of this function)
%------------------------------------------------
% modified from unique_count and unique_appear_order_cstr
% this can handle numeric array too
% see also: diagnose_misP_iACPmp
%===================================================
if false
 % test with numeric array
%     cc
%     cstr=[5  5  5  3  0.2 0.2 0.2  -2 -2 -2 1 1]'    % this can handle numeric array too
%     [uniques,numUnique] = unique_count_sortnat_cstr(cstr)
    %-------------------------------------------------
    % test with cstr
    cc
    cstr={'aaa_13','aaa_13','aaa_2','aaa_2','aaa_2','aaa_0'}'
    [uniques,numUnique] = unique_count_sortnat_cstr(cstr)
    %-------------------------------------------------
    % test with cstr
    cc
    cstr={'aaa_13','aaa_13','aaa_2','aaa_2','aaa_2','b_0'}'
    [uniques,numUnique] = unique_count_sortnat_cstr(cstr)
    
    
end
%===================================================
%------------------------------------------------

if iscell(cstr)
    
    cstr_sortnat=sortnat(cstr) ;
    [uniques,numUnique]=unique_count_appear_order_cstr( cstr_sortnat);
else
    error('cstr should be cstr only');
end
end

% [qcstr  ncstr] =unique_count(cstr) ;
% [lia,locb] = ismember(cstr_sortnat,qcstr);
% ncstr_appear_order= ncstr ( locb ) ;
% 
% uniques=cstr_sortnat;
% numUnique = ncstr_appear_order ;
% 
%  done_with_this_function;


%% ----- from unwrap_struct.m -----------------------------------------------
function unwrap_struct(S)
% unwrap variables out of a structure ( struct ): S into the current workspace with same name as the fieldname
% e.g. clear; S.FVformula='diffFV';S.wFV=75;S.kw=.5;unwrap_struct(S);
% by Chang Hsiung, Feb. 2, 08
% see also v2struct
afn=fieldnames(S);
for i=1:length(afn)
    eval([afn{i},'=','S.',afn{i},';']); 
    assignin('caller',afn{i},getfield(S,afn{i}));
end
end


%% ----- from xlswrite_ChkLn.m ----------------------------------------------
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
