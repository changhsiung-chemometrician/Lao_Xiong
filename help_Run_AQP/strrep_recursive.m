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

%% ---------------------------------------------------------------
%% Split out of Run_AQP.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Cmp_Results, Run_AQP.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
