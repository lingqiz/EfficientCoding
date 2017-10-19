function negLikelihood = costfuncWrapperFixedPrior(subjectData, parameters)

%COSTFUNCWRAPPER Interface function for running the optimization 
%                for fixed prior 1 / (c1 v + c2), 
%                and seven different contrast level 

cstLevel   = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
noiseLevel = parameters(1 : length(cstLevel));

% Fixed prior in this particular case 
prior = @(support) pwrPriorFixed(support);

% Two ref contrast level and six speed level
refCsts  = [0.075, 0.5];
refSpeed = [0.5, 1, 2, 4, 8, 12];

% Row index: 1 ref speed; 2 ref contrast;
% 3 test speed; 4 test contrast;
% 9 test stimulus seen faster

sumLikelihood = 0;
for i = 1 : length(refCsts)
    % Noise level at reference stimulus contrast level
    refCorst = refCsts(i);
    refNoise = noiseLevel(cstLevel == refCorst);
    for j = 1 : length(refSpeed)
        
        refV  = refSpeed(j);
        
        % Test stimulus for one reference stimulus
        testData = subjectData([3, 4, 9], subjectData(1, :) == refV ...
            & subjectData(2, :) == refCorst);
        
        % Re-organize data for function call
        testV = testData(1, :);
        [~, idx] = ismember(testData(2, :),  cstLevel);
        testNoise = noiseLevel(idx);
        testResponse = testData(3, :);
        
        % Add log likelihood for different reference stimulus
        sumLikelihood = ...
            sumLikelihood + afcCostfunc(prior, refV, refNoise, testV, testNoise, testResponse);
    end
end

negLikelihood = -sumLikelihood;

end

