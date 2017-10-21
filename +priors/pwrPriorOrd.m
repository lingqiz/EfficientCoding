function [ priorProb ] = pwrPriorOrd(support, c1, c2)

% PWRPRIOR   Power law prior of the form 
%            p(v) = 1 / (c1 v + c2)

persistent const1; persistent const2; persistent nrmConst;
domain = -50 : 0.001 : 50; % Normalization defined over function domain

if isempty(const1) || isempty(const2) || (~ (const1 == c1)) || (~ (const2 == c2))
    const1 = c1; const2 = c2;
    nrmConst = 1.0 / (trapz(domain, 1 ./ (const1 * abs(domain) + const2)));
end

probUnm = 1 ./ (const1 * abs(support) + const2); priorProb = nrmConst * probUnm;

end