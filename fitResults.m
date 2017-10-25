
c0 = 0.6252; c1 = 2.7478; c2 = 0.1483;
noiseLevel = [0.8425, 0.65, 0.5985, 0.3935, 0.3916, 0.3297, 0.2910];
plotResults(c0, c1, c2, noiseLevel);

% c0 = 0.87; c1 = 1.27; c2 = 0.4187;
% noiseLevel = [1.4137; 1.0337; 0.9751; 0.6615; 0.5028; 0.3940; 0.0747];
% plotResults(c0, c1, c2, noiseLevel);

function plotResults(c0, c1, c2, noiseLevel)
crstLevel  = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];

domain    = -100 : 0.01 : 100; 
priorUnm  = 1.0 ./ (c1 * (abs(domain) .^ c0) + c2);
nrmConst  = 1.0 / (trapz(domain, priorUnm));

prior = @(support) (1 ./ (c1 * (abs(support) .^ c0) + c2)) * nrmConst; 

% Shape of Prior 
priorSupport = (0 : 0.01 : 15);
plot(log(priorSupport), log(prior(priorSupport)));

% Matching Speed, C = 0.075 or 0.5
plotMatchSpeed(0.075); plotMatchSpeed(0.5); 

figure; hold on;
plotThreshold(0.075); plotThreshold(0.5); 

    function plotMatchSpeed(refCrstLevel)
        vRef = 0.5 : 0.1 : 12; baseNoise = noiseLevel(crstLevel == refCrstLevel);
        estVRef = @(vRef) efficientEstimator(prior, baseNoise, vRef);
        estiVRef = arrayfun(estVRef, vRef);

        figure; hold on;
        testCrst = [0.05, 0.1, 0.2, 0.4, 0.8];
        
        for i = 1 : length(testCrst)

            vTest = 0.2 : 0.01 : 14; baseNoise = noiseLevel(crstLevel == testCrst(i));
            estVTest = @(vTest) efficientEstimator(prior, baseNoise, vTest);
            estiVTest = arrayfun(estVTest, vTest);

            sigma = 0.01; vTestMatch = zeros(1, length(vRef));            
            for j = 1 : length(vRef)
                targetEst = estiVRef(j);
                vTestMatch(j) = mean(vTest(estiVTest > targetEst - sigma & estiVTest < targetEst + sigma));
            end
            plot(log(vRef), vTestMatch ./ vRef); 
        end
    end


    function plotThreshold(refCrstLevel)
        targetDPrime = 0.95; sigma = 0.01;
        vRef = 0.5 : 0.1 : 14; baseNoise = noiseLevel(crstLevel == refCrstLevel);
        thresholdV = zeros(1, length(vRef));
        
        for i = 1 : length(vRef)
            [meanRef, stdRef] = efficientEstimator(prior, baseNoise, vRef(i));
                        
            deltaV = 0:0.001:5; testV = vRef(i) + deltaV;            
            for j = 1 : length(testV)
                [meanTest, stdTest] = efficientEstimator(prior, baseNoise, testV(j));
                dPrime = (meanTest - meanRef) / sqrt((stdTest ^ 2 + stdRef ^ 2) / 2);
                if (dPrime > targetDPrime - sigma) && (dPrime < targetDPrime + sigma)
                    thresholdV(i) = deltaV(j);
                    break;
                end
            end            
        end        
        plot(log(vRef), thresholdV ./ vRef);
    end

end



