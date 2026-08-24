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

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
