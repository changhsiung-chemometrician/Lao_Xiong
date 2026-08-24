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

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
