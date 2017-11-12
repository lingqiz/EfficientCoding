function [mean, std] = efficientEstimator(prior, baseNoise, vProb)

% EFFICIENTESTIMATOR Compute p(v'|v) with efficient 
%            coding constrain and Gaussian likelihood
%            function baseline noise defined at v = 1

% Noise distributed according to efficient coding principle 
% J(theta) in prop to prior probability 

vBaseNoise = 1; 
baseStd = prior(vBaseNoise) * baseNoise;
probStd = baseStd / prior(vProb); 

measurement = vProb; 
mean = decoder(measurement);
std  = abs(decoder(vProb + probStd) - decoder(vProb - probStd)) / 2;

% Special implementation for power law prior 
% and positive reference and test speed
    function [esti] = decoder(msmt)
        sampleSize = 1000; 
        baseStdMsmt = baseStd / prior(msmt);        
        
        if msmt >= 0            
            estSpaceLB = msmt - 2 * baseStdMsmt;
            stepSize = (msmt - estSpaceLB) / sampleSize;
            estSpc = estSpaceLB : stepSize : msmt;
            
        else % msmt < 0
            estSpaceUB = msmt + 2 * baseStdMsmt;
            stepSize = (estSpaceUB - msmt) / sampleSize;
            estSpc = msmt : stepSize : estSpaceUB;                        
        end
        
        estPrior = prior(estSpc);
        estStd   = baseStd ./ estPrior;
        
        % Compute the likelihood function for varying mu and sigma 
        vecMsmt = msmt * ones(1, length(estSpc));
        estLlhd = ...
            exp(-0.5 * ((vecMsmt - estSpc) ./ estStd) .^2) ./ (sqrt(2 * pi) .* estStd);
        
        % Max posterior, L0 loss
        estScore = estPrior .* estLlhd; 
        [~, maxIdx] = max(estScore);
        esti = estSpc(maxIdx);
    end

end

