function negLikelihood = costfuncWrapperFixedPrior(subjectData, parameters)

%COSTFUNCWRAPPERFIXEDPRIOR Interface function for running the optimization for  
%                fixed prior 1 / (c1 v + c2) and seven different contrast level        

% Fixed prior in this particular case
fprintf('\nNoise level: \n')
fprintf(num2str(parameters)); fprintf('\n \n');

prior = @(support) priors.pwrPriorFixed(support);
negLikelihood = afcCostfunc(prior, subjectData, parameters);

end

