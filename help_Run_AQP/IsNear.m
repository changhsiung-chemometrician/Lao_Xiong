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

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
