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
snsMeasurement = interp1(stmSpc, F, vProb, 'linear','extrap');

% P(m | theta), expressed in sensory space
estLB = max(0, snsMeasurement - 4 * intNoise);
estUB = min(1, snsMeasurement + 4 * intNoise);

% even grid in internal space 
% measurement distribution in internal space
sampleSize = 500; sampleStepSize  = (estUB - estLB) / sampleSize;
estDomainInt = estLB : sampleStepSize : estUB;
measurementDist = normpdf(estDomainInt, snsMeasurement, intNoise);

% even grid in external space
estLBext = interp1(F, stmSpc, estLB, 'linear','extrap');
estUBext = interp1(F, stmSpc, estUB, 'linear','extrap');
sampleStepSize  = (estUBext - estLBext) / sampleSize;

% corresponding points in internal space
estDomainExt = estLBext : sampleStepSize : estUBext;
invExtDomain = interp1(stmSpc, F, estDomainExt, 'linear','extrap');

% prior for estimation
extPrior = priorProb(estDomainExt);

% Compute an estimate for each measurement
likelihoodDist = ... 
    exp(-0.5 * ((invExtDomain - invExtDomain')./ intNoise).^2) ./ (sqrt(2*pi) .* intNoise);
score = likelihoodDist .* extPrior;

% L0 loss, posterior Mode
% estDomainExt -> estimate & invExtDomain -> estimate
[~, idx]  = max(score, [], 2); 
estimates = estDomainExt(idx);

% estDomainInt -> estimate
estimatesInt = interp1(invExtDomain, estimates, estDomainInt, 'linear','extrap');

% Smooth with polynomial
warning('off','all');
nOrder   = 5;
plnm     = polyfit(estDomainInt, estimatesInt, nOrder);

% Change of Variable
estimatesInt = polyval(plnm, estDomainInt);
probDnst = abs(gradient(estDomainInt, estimatesInt)) .* measurementDist;

estimates = estimatesInt;
assert(sum(isnan(probDnst)) == 0);

end

