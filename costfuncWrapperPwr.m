function [ negLikelihood ] = costfuncWrapperPwr(subjectData, parameters)
%COSTFUNCWRAPPERPWR Interface function for running the optimization

c0 = parameters(1); c1 = parameters(2); c2 = parameters(3);

% Computing Prior Probability
domain    = -50 : 0.01 : 50; 
priorUnm  = 1.0 ./ (c1 * (abs(domain) .^ c0) + c2);
nrmConst  = 1.0 / (trapz(domain, priorUnm));

% Prior prob function handler
prior = @(support) priors.pwrPrior(support, nrmConst, c0, c1, c2);

% Compute negative log likelihood
negLikelihood = afcCostfunc(prior, subjectData, parameters(4 : end));

end

