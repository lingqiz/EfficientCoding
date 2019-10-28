function plotThresBayes(prior, noiseLevel, refCrstLevel, color, relative, logSpace)

crstLevel  = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
targetDPrime = 0.955; sigma = 0.005;
vRef = 0.5 : 0.2 : 12; baseNoise = noiseLevel(crstLevel == refCrstLevel);
thresholdV = zeros(1, length(vRef));

for i = 1 : length(vRef)
    [meanRef, stdRef] = efficientEstimator(prior, baseNoise, vRef(i));
    
    deltaL = 0; deltaH = 20;
    deltaEst = (deltaL + deltaH) / 2;
    [meanTest, stdTest] = efficientEstimator(prior, baseNoise, vRef(i) + deltaEst);
    dPrime = (meanTest - meanRef) / sqrt((stdTest ^ 2 + stdRef ^ 2) / 2);
    
    while(dPrime < targetDPrime - sigma || dPrime > targetDPrime + sigma)
        if dPrime > targetDPrime
            deltaH = deltaEst;
        else
            deltaL = deltaEst;
        end
        
        deltaEst = (deltaL + deltaH) / 2;
        [meanTest, stdTest] = efficientEstimator(prior, baseNoise, vRef(i) + deltaEst);
        dPrime = (meanTest - meanRef) / sqrt((stdTest ^ 2 + stdRef ^ 2) / 2);
    end
    thresholdV(i) = deltaEst;
end

if relative
    plot(log(vRef), thresholdV ./ vRef, 'LineWidth', 2, 'Color', color);
elseif logSpace
    plot(log(vRef), log(thresholdV), 'LineWidth', 2, 'Color', color);
else
    plot(vRef, thresholdV, 'LineWidth', 2, 'Color', color);
end

end

