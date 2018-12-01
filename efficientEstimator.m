function [mean, std] = efficientEstimator(prior, baseNoise, vProb)
% EFFICIENTESTIMATOR Compute p(v'|v) with efficient 
%            coding constrain and Gaussian likelihood
%            function baseline noise defined at v = 1

% Noise distributed according to efficient coding principle 
% J(theta) in prop to prior probability 

vBaseNoise = 1; 
baseStd = prior(vBaseNoise) * baseNoise;
probStd = baseStd / prior(vProb); 

if prior(vProb) > 1e-4
    measurement = vProb;
    mean = decoder(measurement);
    std  = abs(decoder(vProb + probStd) - decoder(vProb - probStd)) / 2;
else
    mean = vProb;
    std  = Inf;
end

if(isempty(mean) || isempty(std))
    mean = vProb;
    std  = Inf;
end

    function [esti] = decoder(msmt)
        sampleSize = 2000; 
        baseStdMsmt = baseStd / prior(msmt);        
                
        estSpaceLB = msmt - 1 * baseStdMsmt;
        estSpaceUB = msmt + 1 * baseStdMsmt;
            
        stepSize = (estSpaceUB - estSpaceLB) / sampleSize;
        estSpc = estSpaceLB : stepSize : estSpaceUB;                    
        
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

