function [ negLikelihood ] = costfuncWrapperGauss(subjectData, parameters)
%COSTFUNCWRAPPERGAUSS Interface function for running the optimization
    
% Prior prob function handler
prior = @(support) 0.9 * normpdf(abs(support), 0, parameters(1)) + 0.002 ;
    
% Compute negative log likelihood
negLikelihood = afcCostfunc(prior, subjectData, parameters(2 : end));
    
end