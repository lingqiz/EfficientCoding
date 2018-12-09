function [ negLikelihood ] = costfuncWrapperPwr(subjectData, parameters)
%COSTFUNCWRAPPERPWR Interface function for running the optimization

c0 = parameters(1); c1 = parameters(2); c2 = parameters(3);

% Computing Prior Probability
domain    = -100 : 0.01 : 100; 
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 / (trapz(domain, priorUnm));

% Prior prob function handler
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

% Compute negative log likelihood
negLikelihood = afcCostfunc(prior, subjectData, parameters(4 : end));

end