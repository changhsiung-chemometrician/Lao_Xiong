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
    out=color_CH__remove_empty_cell(arrayfun(@(x) matchedinfdn2outfdn(x,'SL',inp,'rgb'),SAcolor,'UniformOutput',false)); % output the content if cstr become single cell !!!
elseif isnumeric(inp) && length(inp)==3
   out=color_CH__remove_empty_cell(arrayfun(@(x) sameNumeric_infdn2outfdn(x,'rgb',inp,'SL'),SAcolor,'UniformOutput',false)); % output the content if cstr become single cell !!!
else
    error('inp format can not be recognized !!!');
end
end

%% ---------------------------------------------------------------
%% Split out of StepbyStep_plots.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
