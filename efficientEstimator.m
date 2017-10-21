function [mean, std] = efficientEstimator(prior, baseNoise, vProb)

% EFFICIENTESTIMATOR Compute p(v'|v) with efficient 
%            coding constrain and Gaussian likelihood
%            function baseline noise defined at v = 1

% Noise distributed according to efficient coding principle 
% J(theta) in prop to prior probability 
vBaseNoise = 1; baseStd = prior(vBaseNoise) * baseNoise;
probStd = baseStd / prior(vProb); std = probStd;

% Consider measurements in the three sigma range
measurementL = vProb - 3 * probStd;
measurementH = vProb + 3 * probStd;

% encoding
measurements = measurementL : 0.01 : measurementH;
msmtProb     = normpdf(measurements, vProb, probStd);

% decoding for each measurement
% change of variable to p(v'|v)
estimates = arrayfun(@decoder, measurements);
esmtProb  = abs(gradient(measurements, estimates)) .* msmtProb;

% mean value of the estimation distribution p(v'|v)
mean = trapz(estimates, estimates .* esmtProb);

% Special implementation for power law prior 
% and positive reference and test speed
    function [esti] = decoder(msmt)        
        estSpc   = (msmt - baseStd / prior(msmt)) : 0.01 : msmt;                
        estPrior = prior(estSpc);
        estStd   = baseStd ./ estPrior;
        estLlhd  = zeros(1, length(estSpc));
        
        for i = 1 : length(estSpc)            
            estLlhd(i) = normpdf(msmt, estSpc(i), estStd(i));
        end
        
        % Max posterior, L0 loss
        estScore = estPrior .* estLlhd; [~, maxIdx] = max(estScore);
        esti = estSpc(maxIdx);      
    end

end

