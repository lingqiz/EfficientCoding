function plotBiasBayes(prior, noiseLevel, refCrstLevel, plotColor)
crstLevel  = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];

vRef = 0.5 : 0.1 : 12; baseNoise = noiseLevel(crstLevel == refCrstLevel);
estVRef = @(vRef) efficientEstimator(prior, baseNoise, vRef);
estiVRef = arrayfun(estVRef, vRef);

testCrst = [0.05, 0.1, 0.2, 0.4, 0.8];
shiftOffset = -0.025:0.0125:0.025;

for i = 1 : length(testCrst)
    vTest = 0.05 : 0.005 : 24; baseNoise = noiseLevel(crstLevel == testCrst(i));
    estVTest = @(vTest) efficientEstimator(prior, baseNoise, vTest);
    estiVTest = arrayfun(estVTest, vTest);
    
    sigma = 0.01; vTestMatch = zeros(1, length(vRef));
    for j = 1 : length(vRef)
        targetEst = estiVRef(j);
        vTestMatch(j) = mean(vTest(estiVTest > targetEst - sigma & estiVTest < targetEst + sigma));
    end
    plot(log(vRef)+shiftOffset(i), vTestMatch ./ vRef, 'LineWidth', 1.5, 'Color', plotColor(i, :));
end
end