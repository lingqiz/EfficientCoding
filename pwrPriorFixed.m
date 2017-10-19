function priorProb = pwrPriorFixed(support)
%PWRPRIORFIXED Power law (first order) prior with fixed const = 0.3
%              p(v) = 1 / (v + v0) with v0 = 0.3
v0 = 0.3; 

% Normalization const, computed offline 
normalizationConst = 1 / 10.2440; % Support: x [-50 50]
probUnm = 1 ./ (abs(support) + v0);

priorProb = probUnm * normalizationConst;

end

