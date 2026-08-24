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

%% ---------------------------------------------------------------
%% Split out of StepbyStep_plots.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
