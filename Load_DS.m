function handles = Load_DS(hObject, eventdata, handles)
% LOAD_DS  Standalone extraction of Load_DS_Callback from AQP_gui.m
%
%   handles = Load_DS(hObject, eventdata, handles)
%
%   Source control : popupmenu (used imperatively) - Load_DS / Browse
%   What it does   : Opens uigetdir, records the chosen dataset folder on the handles
% struct, echoes it into the Loaded_DS_folder label, and reveals cPP1
% when the AQP class is not "lite".
%
%   Plain struct fields this sets (these are why handles must be
%   returned - MATLAB passes structs BY VALUE):
%       handles.path_DS                  consumed by Run_AQP and StepbyStep_plots_AQP
%       handles.path_XLSX                consumed by Run_AQP (InpBR.path_XLSX)
%       handles.path_DSn_ParentFolder    consumed by Run_AQP (multi-DS mode)
%
%   This file is self-contained: the callback body below is followed by its
%   complete 2-function reachable closure, lifted verbatim from AQP_gui.m
%   and folded in as file-private local functions. Every function - primary
%   and local alike - is closed with its own matching end.
%
%   Extracted 20 August 2026 by the same dependency-closure procedure used for
%   Run_AQP.m on 19 Aug 2026. Edits to the moved body are tagged [EXTRACTED].

    handles = Load_DS_Callback(hObject, eventdata, handles);
end



% =========================================================================
% [EXTRACTED] The moved callback body. Verbatim from AQP_gui.m lines 273-302
% except for the tagged edits below.
% =========================================================================
function handles = Load_DS_Callback(hObject, eventdata, handles)   % [EXTRACTED] signature now returns handles
% hObject    handle to Load_DS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Load_DS contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Load_DS
%================================================================
%      handles.suserInitials.String=handles.authorized_user;  % add this handles.suserInitials.String=handles.authorized_user at function Load_DS_Callback, Apr 25, 2023
% new approach below:
% add this handles.suserInitials.String=handles.authorized_user at gui_mainfcn --> local_openfig , Apr 25, 2023

disp_with_border(['Loading Dataset by --> ',handles.suserInitials.String]);
%===============================================================
path_DS = uigetdir(pwd, 'Pls Pick XLSX Dataset folder');

% ---- [IMPROVEMENT, 20 August 2026] uigetdir returns the DOUBLE 0 when the user
% cancels. Unguarded, handles.path_DS becomes 0, the folder label reads
% "0", and the failure only shows up much later inside the run. Delete
% these four lines to restore byte-exact legacy behaviour.
if isequal(path_DS,0)
    disp('Load_DS: cancelled by user - dataset folder left unchanged.');
    return
end


if strcmp(handles.Load_DS.String{handles.Load_DS.Value},'Load_DSn_ParentFolder')
handles.path_DSn_ParentFolder=path_DS;
handles.path_XLSX='';
else
handles.path_XLSX=path_DS;
handles.path_DSn_ParentFolder='';
end
handles.path_DS=path_DS;
handles.Loaded_DS_folder.String=path_DS;
% [EXTRACTED] guarded: outside a callback gcbo is empty and this throws.
if ~isempty(gcbo) && isgraphics(gcbo)
    guidata(gcbo,handles);
end
 if ~strcmp( get_curAQP_class(handles),'lite')
handles.cPP1.Visible=1;
 end
end
