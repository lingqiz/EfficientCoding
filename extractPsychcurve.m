function [biasLC, biasHC, thLC, thHC] = extractPsychcurve(weibullPara, showPlot)

crstLevel = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];

refCrst    = [0.075, 0.5];
testCrst  = [0.05, 0.1, 0.2, 0.4, 0.8];

vProb     = [0.5, 1, 2, 4, 8, 12];
vRef      = [0.5, 1, 2, 4, 8, 12];


    function bias = findBias(refCrstLevel)
        if(showPlot)
            figure; hold on;
        end
        weibullLine = zeros(length(testCrst), length(vRef));
        
        for i = 1 : length(testCrst)
            vMatch = zeros(1, length(vRef));
            for j = 1 : length(vRef)
                para = weibullPara(refCrst == refCrstLevel, vProb == vRef(j), crstLevel == testCrst(i), :);
                
                candV = 0 : 0.0001 : vRef(j) + 20;
                targetProb = 0.5; delta = 0.01;
                probCorrect = wblcdf(candV, para(1), para(2));
                
                vMatch(j) = mean(candV(probCorrect > targetProb - delta & probCorrect < targetProb + delta));
            end
            
            weibullLine(i, :) = vMatch ./ vRef;
            if(showPlot)
                plot(log(vRef), vMatch ./ vRef, '--o');
            end
            bias = weibullLine;
        end
    end

biasLC = findBias(0.075);
biasHC = findBias(0.5);

    function threshold = findThreshold(refCrstLevel)
        thresholdV = zeros(1, length(vProb));
        pseV = zeros(1, length(vProb));
        targetC = 0.75; pseC = 0.5;
        
        for x = 1 : length(vProb)
            para = weibullPara(refCrst == refCrstLevel, vProb == vProb(x), crstLevel == refCrstLevel, :);
            rangeV = 0.1 : 0.001 : 30;
            [probC, ia] = unique(wblcdf(rangeV, para(1), para(2)), 'stable');
            rangeV = rangeV(ia);
            
            thresholdV(x) = interp1(probC, rangeV, targetC);
            pseV(x) = interp1(probC, rangeV, pseC);
        end
        thresholdV = thresholdV - pseV;
        if(showPlot)
            plot(log(vProb), log(thresholdV), '--o');
        end
        threshold = log(thresholdV);
        
    end

if(showPlot)
    figure; hold on;
end

thLC = findThreshold(0.075);
thHC = findThreshold(0.5);

end

