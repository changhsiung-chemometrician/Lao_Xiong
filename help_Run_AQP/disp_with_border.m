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

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 4 of the four AQP action mains: Cmp_Results, Load_DS, Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
