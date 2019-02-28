function plotWeibullLine(allBias, nBootstrap, colors)
    testCrst = [0.05, 0.1, 0.2, 0.4, 0.8];
    vRef = [0.5, 1, 2, 4, 8, 12];
    weibullLine = zeros(1, length(testCrst));    
    for idx = 1 : length(testCrst)
        estBias = reshape(allBias(:, idx, :), [nBootstrap, 6]);
    
        meanEst = mean(estBias, 'omitnan');
        stdEst  = std(estBias, 'omitnan');
        
        shiftOffset = rand(1)*0.1-0.05;
        weibullLine(idx) = errorbar(log(vRef)+shiftOffset, meanEst, stdEst*2, '--o', 'Color', colors(idx, :));
    end        
    legend(weibullLine, arrayfun(@num2str, testCrst, 'UniformOutput', false));
end