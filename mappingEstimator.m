function [estimates, probDnst] = mappingEstimator(priorProb, intNoise, vProb)
% MAPPINGESTIMATOR Compute p(v'|v) with efficient 
%            coding constrain and transformation to 
%            the internal space

% Noise distributed according to efficient coding principle 
% J(theta) in prop to prior probability
% Extended sensory space

stepSize = 1e-2;
stmSpc = -100 : stepSize : 100;
prior  = priorProb(stmSpc);

% Mapping from measurement to (homogeneous) sensory space
F = cumtrapz(stmSpc, prior);
snsMeasurement = interp1(stmSpc, F, vProb);

% P(m | theta), expressed in sensory space
estLB = max(0, snsMeasurement - 4 * intNoise);
estUB = min(1, snsMeasurement + 4 * intNoise);

sampleSize = 800; sampleStepSize  = (estUB - estLB) / sampleSize;
estDomain = estLB : sampleStepSize : estUB;

measurementDist = normpdf(estDomain, snsMeasurement, intNoise);

% Inverse prior
ivsStmSpc = interp1(F, stmSpc, estDomain);
ivsPrior  = interp1(stmSpc, prior, ivsStmSpc);

% Compute an estimate for each measurement
likelihoodDist = ... 
    exp(-0.5 * ((estDomain - estDomain')./ intNoise).^2) ./ (sqrt(2*pi) .* intNoise);
score = likelihoodDist .* ivsPrior;

% L0 loss, posterior Mode
[~, idx]  = max(score, [], 2); 
estimates = ivsStmSpc(idx);

[estimates, idx] = uniquetol(estimates, 1e-4, 'OutputAllIndices', true);

idx = cellfun(@(x) x(end), idx);
estDomain = estDomain(idx);

% Smooth with polynomial 
nOrder   = 4;
plnm     = polyfit(estDomain, estimates, nOrder);

% Change of Variable
probDnst = abs(gradient(estDomain, polyval(plnm, estDomain))) .* measurementDist(idx);

% Git rid of NaNs & Infs
estimates = estimates(~isnan(probDnst) & ~isinf(probDnst)); 
probDnst  = probDnst(~isnan(probDnst)  & ~isinf(probDnst));

end

