function [ negLikelihood ] = costfuncWrapperPwr(subjectData, parameters)
%COSTFUNCWRAPPERPWR Interface function for running the optimization

c0 = parameters(1); c1 = parameters(2); c2 = parameters(3);
fprintf('\nCost function evaluation with the following parameters: \n')
fprintf('Constant c0: %.2f, c1: %.2f, c2: %.2f \n', c0, c1, c2);
fprintf('Noise level: \n')
fprintf(num2str(parameters(4 : end))); fprintf('\n \n');

% Computing Prior Probability
domain    = -100 : 0.01 : 100; 
priorUnm  = 1.0 ./ (c1 * (abs(domain) .^ c0) + c2);
nrmConst  = 1.0 / (trapz(domain, priorUnm));

% Prior prob function handler
prior = @(support) priors.pwrPrior(support, nrmConst, c0, c1, c2);

% Compute negative log likelihood
negLikelihood = afcCostfunc(prior, subjectData, parameters(4 : end));

end