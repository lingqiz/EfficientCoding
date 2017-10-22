function [ priorProb ] = pwrPrior(support, nrmConst, c0, c1, c2)

% PWRPRIOR   Power law prior of the form 
%            p(v) = 1 / (c1 v ^ c0 + c2)

probUnm = 1 ./ (c1 * (abs(support) .^ c0) + c2); priorProb = nrmConst * probUnm;

end