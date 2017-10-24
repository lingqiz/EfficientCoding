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
msmtSampleSize = 100; msmtStepSize = (measurementH - measurementL) / msmtSampleSize;
measurements = measurementL : msmtStepSize : measurementH;
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
        sampleSize = 100; 
        baseStdMsmt = baseStd / prior(msmt);        
        
        if msmt >= 0
            estSpaceLB = msmt - baseStdMsmt;
            stepSize = (msmt - estSpaceLB) / sampleSize;
            estSpc = estSpaceLB : stepSize : msmt;
            
        else % msmt < 0
            estSpaceUB = msmt + baseStdMsmt;
            stepSize = (estSpaceUB - msmt) / sampleSize;
            estSpc = msmt : stepSize : estSpaceUB;                        
        end
        
        estPrior = prior(estSpc);
        estStd   = baseStd ./ estPrior;
        
        % Compute the likelihood function for varying mu and sigma 
        vecMsmt = msmt * ones(1, length(estSpc));
        estLlhd  = exp(-0.5 * ((vecMsmt - estSpc)./ estStd).^2) ./ (sqrt(2*pi) .* estStd);
        
        % Max posterior, L0 loss
        estScore = estPrior .* estLlhd; [~, maxIdx] = max(estScore);
        esti = estSpc(maxIdx);
    end

end

