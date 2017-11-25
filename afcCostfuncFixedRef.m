function logll = afcCostfuncFixedRef(prior, refV, refNoise, testV, testNoise, response)

% AFCCOSTFUNCFIXEDREF Cost function for two-alternatice forced choice task  
%             with fixed reference stimulus and corresponding test stimulus.
%             Compute the log likelihood of the data. 

[refEstimate, refProbDnst] = mappingEstimator(prior, refNoise, refV);
probFaster = zeros(1, length(testV));

for i = 1 : length(testV)
    [testEstimate, testProbDnst] = mappingEstimator(prior, testNoise(i), testV(i));
    probFaster(i) = probFasterIntegral(refEstimate, refProbDnst, testEstimate, testProbDnst);       
end

% Probability of the response 
probRes = probFaster .* response + (1 - probFaster) .* (1 - response);

% Avoid log(0) for numerical issuses
% Should consider remove outliers 
zeroThreshold = 1e-5;
probRes(probRes == 0) = zeroThreshold;

% Sum of the log likelihood
logll = sum(log(probRes));

end