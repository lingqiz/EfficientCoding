function [estimates, esmtProb] = estimatorGauss(estSpc, prior, noiseConst, vProb)
% ESTIMATORGAUSS Compute p(v'|v) with efficient
%                coding constrain and Gaussian likelihood

% Noise distributed according to efficient coding principle
% J(theta) in prop to prior probability
probStd = noiseConst / prior(vProb);
estPrior = prior(estSpc); estStd = noiseConst ./ estPrior;

% Consider measurements in the four sigma range
measurementL = vProb - 4 * probStd;
measurementH = vProb + 4 * probStd;

% Encoding
stepSize = 0.01;
measurements = measurementL : stepSize : measurementH;
msmtProb     = normpdf(measurements, vProb, probStd);

% Decoding for each measurement
% Change of variable to p(v'|v)
estimates = arrayfun(@decoder, measurements);
esmtProb  = abs(gradient(measurements, estimates)) .* msmtProb;

% Decoder for L2 loss
    function [estimate] = decoder(msmt)        
        % Compute the likelihood function for varying mu and sigma 
        vecMsmt = msmt * ones(1, length(estSpc));
        estLlhd  = exp(-0.5 * ((vecMsmt - estSpc)./ estStd) .^2) ./ (sqrt(2 * pi) .* estStd);

        % L2 loss, Posterior mean
        estScore = estPrior .* estLlhd; postProb = estScore / trapz(estSpc, estScore);
        estimate = trapz(estSpc, estSpc .* postProb);              
    end
end