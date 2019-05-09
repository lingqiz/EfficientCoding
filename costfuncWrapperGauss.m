function [ negLikelihood ] = costfuncWrapperGauss(subjectData, parameters)
%COSTFUNCWRAPPERGAUSS Interface function for running the optimization
    
% Prior prob function handler
prior = @(support) normpdf(abs(support), parameters(1), parameters(2));
    
% Compute negative log likelihood
negLikelihood = afcCostfunc(prior, subjectData, parameters(3 : end));
    
end