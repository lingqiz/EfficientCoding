function [estimates, probDnst] = stimulusEstimator(stmSpc, prior, stimulus, intNoise, loss)

% stimulusEstimator  Compute p(v'|v) 
%                    expressed in stimulus space

% Extended sensory space 
snsSpc = 0 : 0.001 : 1;

% Mapping from measurement to (homogeneous) sensory space
F = cumtrapz(stmSpc, prior);
snsMeasurement = interp1(stmSpc, F, stimulus);

ivsStmSpc = interp1(F, stmSpc, snsSpc);
ivsPrior  = interp1(stmSpc, prior, ivsStmSpc);

% P(m | theta), expressed in sensory space; Compute an estimate for each measurement
measurementDist = normpdf(snsSpc, snsMeasurement, intNoise); 
estimates = arrayfun(@(measurements) measurementEstimator(ivsStmSpc, ivsPrior, snsSpc, measurements, intNoise, loss), snsSpc);

% Change of Variable 
probDnst = abs(gradient(snsSpc, estimates)) .* measurementDist;

    % Estimator given measurement m (theta_hat function)
    function [estimate] = measurementEstimator(ivsStmSpc, ivsPrior, snsSpc, snsMeasurement, intNoise, loss)
        likelihoodDist = normpdf(snsSpc, snsMeasurement, intNoise);
        score = likelihoodDist .* ivsPrior;

        % Assume L2 loss or L0 loss
        if loss == 2
        posteriorDist = score / trapz(ivsStmSpc, score);
        estimate = trapz(ivsStmSpc, posteriorDist .* ivsStmSpc);
        
        else % if loss == 0        
        [~, idx] = max(score);  estimate = ivsStmSpc(idx);        
        end
    end
end

