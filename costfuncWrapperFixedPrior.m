function negLikelihood = costfuncWrapperFixedPrior(subjectData, parameters)

%COSTFUNCWRAPPERFIXEDPRIOR Interface function for running the optimization for  
%                fixed prior 1 / (c1 v + c2) and seven different contrast level        

% Fixed prior in this particular case
prior = @(support) priors.pwrPriorFixed(support);
negLikelihood = afcCostfunc(prior, subjectData, parameters);

end

