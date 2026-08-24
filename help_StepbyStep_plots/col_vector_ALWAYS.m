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

%% ---------------------------------------------------------------
%% Split out of StepbyStep_plots.m on 21 Aug 2026 as a standalone help m-file.
%% Shared by 2 of the four AQP action mains: Run_AQP, StepbyStep_plots.
%% Canonical copy taken from Run_AQP.m.
%% ---------------------------------------------------------------
