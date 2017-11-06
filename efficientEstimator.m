function [mean, std] = efficientEstimator(prior, baseNoise, vProb)

% EFFICIENTESTIMATOR Compute p(v'|v) with efficient 
%            coding constrain and Gaussian likelihood
%            function baseline noise defined at v = 1

% Noise distributed according to efficient coding principle 
% J(theta) in prop to prior probability 
vBaseNoise = 1; baseStd = prior(vBaseNoise) * baseNoise;
probStd = baseStd / prior(vProb); std = probStd;

measurement = vProb; mean = decoder(measurement);

% Special implementation for power law prior 
% and positive reference and test speed
    function [esti] = decoder(msmt)
        sampleSize = 400; 
        baseStdMsmt = baseStd / prior(msmt);        
        
        if msmt >= 1            
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

