function negLikelihood = costfuncWrapperOrdPrior(subjectData, parameters)

%COSTFUNCWRAPPERFIXEDPRIOR Interface function for running the optimization for first
%                 order pwl prior 1 / (c1 v + c2) and seven different contrast level 
%                

c1 = parameters(1); c2 = parameters(2);
prior = @(support) priors.pwrPriorOrd(support, c1, c2);
negLikelihood = afcCostfunc(prior, subjectData, parameters(3 : end));

end

