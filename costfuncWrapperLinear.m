function [ negLikelihood ] = costfuncWrapperLinear(subjectData, parameters)
%COSTFUNCWRAPPERLINEAR Interface function for running the optimization

% Prior prob function handler
nPoint = 20;
refLB  = log(0.1);
refUB  = log(100);
delta  = (refUB - refLB) / (nPoint - 1);
refPoint = refLB : delta : refUB;
refValue = parameters(1: length(refPoint));

logLinearPrior = ...
    @(support) exp(interp1(refPoint, refValue, log(abs(support)), 'spline', 'extrap'));

domain = 0.1 : 0.01 : 100;
nrmConst = 1.0 / trapz(domain, logLinearPrior(domain));

prior = @(support)  logLinearPrior(support) * nrmConst;
% Compute negative log likelihood
negLikelihood = afcCostfunc(prior, subjectData, parameters((length(refPoint) + 1) : end));

end