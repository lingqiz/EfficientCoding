function plotWeibullLine(biasData, allBias, nBootstrap, colors)
    testCrst = [0.05, 0.1, 0.2, 0.4, 0.8];
    vRef = [0.5, 1, 2, 4, 8, 12];
    weibullLine = zeros(1, length(testCrst));
    shiftOffset = -0.025:0.0125:0.025;
            
    percentil = [0.5, 0.975, 0.025];
    for i = 1 : length(testCrst)
        allEstimate = zeros(3, 6);        
        estBias = reshape(allBias(:, i, :), [nBootstrap, 6]);
        for j = 1:6
            estimate = estBias(:, j);
            estimate = sort(estimate(~isnan(estimate)));                      
            for k = 1:3
                allEstimate(k, j) = estimate(floor(length(estimate)*percentil(k)));                
            end
            allEstimate(1, j) = biasData(i, j);
        end                           
        weibullLine(i) = errorbar(log(vRef)+shiftOffset(i), ...
            allEstimate(1, :), allEstimate(1, :)-allEstimate(3, :), allEstimate(2, :)-allEstimate(1, :),...
            '--o', 'Color', colors(i, :));
    end        
    legend(weibullLine, arrayfun(@num2str, testCrst, 'UniformOutput', false));    
    xlim([-1, 2.6]);
    
end