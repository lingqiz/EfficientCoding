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
        targetC = 0.75; sigma = 0.01;
        
        for x = 1 : length(vProb)
            para = weibullPara(refCrst == refCrstLevel, vProb == vProb(x), crstLevel == refCrstLevel, :);
            deltaV = 0 : 0.0001 : 20; testV = vProb(x) + deltaV; 
            probC = wblcdf(testV, para(1), para(2));
            
            thresholdV(x) = mean(deltaV(probC > targetC - sigma & probC < targetC + sigma));
            if(showPlot)
                plot(log(vProb), log(thresholdV), '--o');
            end
                        
            threshold = log(thresholdV);
        end
    end

if(showPlot)
    figure; hold on;
end

thLC = findThreshold(0.075);
thHC = findThreshold(0.5);

end

