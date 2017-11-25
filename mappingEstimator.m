function [estimates, probDnst] = mappingEstimator(priorProb, intNoise, vProb)
% MAPPINGESTIMATOR Compute p(v'|v) with efficient 
%            coding constrain and transformation to 
%            the internal space

% Noise distributed according to efficient coding principle 
% J(theta) in prop to prior probability
% Extended sensory space
stmSpc = -100 : 0.01 : 100;
prior  = priorProb(stmSpc);

snsSpc = 0 : 0.001 : 1; 

% Mapping from measurement to (homogeneous) sensory space
F = cumtrapz(stmSpc, prior);
snsMeasurement = interp1(stmSpc, F, vProb);

ivsStmSpc = interp1(F, stmSpc, snsSpc);
ivsPrior  = interp1(stmSpc, prior, ivsStmSpc);

% P(m | theta), expressed in sensory space
measurementDist = normpdf(snsSpc, snsMeasurement, intNoise);

% Compute an estimate for each measurement
likelihoodDist  = normpdf(snsSpc, snsSpc', intNoise);
score = likelihoodDist .* ivsPrior;

% L0 loss, posterior Mode
[~, idx]  = max(score, [], 2); 
estimates = ivsStmSpc(idx);

% Change of Variable
probDnst = abs(gradient(snsSpc, estimates)) .* measurementDist;

% Git rid of NaNs & Infs
estimates = estimates(~isnan(probDnst) & ~isinf(probDnst)); 
probDnst  = probDnst(~isnan(probDnst)  & ~isinf(probDnst));

end

