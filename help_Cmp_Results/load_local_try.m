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

%% ---------------------------------------------------------------
%% Split out of Cmp_Results.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
