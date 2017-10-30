dataDir = './NN2006/';
load(strcat(dataDir, 'weibullFit1.mat'));
load(strcat(dataDir, 'weibullFit2.mat'));

c0 = 0.6162; c1 = 9.7967; c2 = 0.0651;
noiseLevel = [0.8375, 0.6613, 0.6107, 0.3948, 0.3907, 0.3278, 0.2865];
plotResults(c0, c1, c2, noiseLevel, weibullFit1, 'Subject1: ');

c0 = 0.87; c1 = 1.27; c2 = 0.4187;
noiseLevel = [1.4137; 1.0337; 0.9751; 0.6615; 0.5028; 0.3940; 0.0747];
plotResults(c0, c1, c2, noiseLevel, weibullFit1, 'Subject2: ');

function plotResults(c0, c1, c2, noiseLevel, weibullPara, titleText)

refCrst    = [0.075, 0.5];
crstLevel  = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
vProb      = [0.5, 1, 2, 4, 8, 12];

domain    = -100 : 0.01 : 100; 
priorUnm  = 1.0 ./ (c1 * (abs(domain) .^ c0) + c2);
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1 ./ (c1 * (abs(support) .^ c0) + c2)) * nrmConst; 

% Shape of Prior 
figure; priorSupport = (0 : 0.01 : 15);
plot(log(priorSupport), log(prior(priorSupport)), 'LineWidth', 2);
title(strcat(titleText, 'Prior'));

% Matching Speed, C = 0.075 or 0.5 & Threshold 
plotMatchSpeed(0.075); plotMatchSpeed(0.5); 
figure; hold on; plotThreshold(0.5); % plotThreshold(0.075);
title(strcat(titleText, 'Relative Threshold'));

    function plotMatchSpeed(refCrstLevel)
        vRef = 0.5 : 0.1 : 12; baseNoise = noiseLevel(crstLevel == refCrstLevel);
        estVRef = @(vRef) efficientEstimator(prior, baseNoise, vRef);
        estiVRef = arrayfun(estVRef, vRef);

        figure; hold on;
        testCrst = [0.05, 0.1, 0.2, 0.4, 0.8];
        
        for i = 1 : length(testCrst)

            vTest = 0.05 : 0.01 : 18; baseNoise = noiseLevel(crstLevel == testCrst(i));
            estVTest = @(vTest) efficientEstimator(prior, baseNoise, vTest);
            estiVTest = arrayfun(estVTest, vTest);

            sigma = 0.01; vTestMatch = zeros(1, length(vRef));            
            for j = 1 : length(vRef)
                targetEst = estiVRef(j);
                vTestMatch(j) = mean(vTest(estiVTest > targetEst - sigma & estiVTest < targetEst + sigma));
            end
            plot(log(vRef), vTestMatch ./ vRef, 'LineWidth', 2); 
        end
        
        % Plot matching speed computed from Weibull fit
        vRef = [0.5, 1, 2, 4, 8, 12]; 
        for i = 1 : length(testCrst)
            vMatch = zeros(1, length(vRef)); 
            for j = 1 : length(vRef)
                para = weibullPara(refCrst == refCrstLevel, vProb == vRef(j), crstLevel == testCrst(i), :);
                
                candV = 0 : 0.01 : vRef(j) + 10;  
                targetProb = 0.5; delta = 0.01;
                probCorrect = wblcdf(candV, para(1), para(2));
                
                vMatch(j) = mean(candV(probCorrect > targetProb - delta & probCorrect < targetProb + delta));
            end
            plot(log(vRef), vMatch ./ vRef, '--o');
        end
        
        title(strcat(titleText, 'Matching Speed'));
    end

    function plotThreshold(refCrstLevel)
        targetDPrime = 0.95; sigma = 0.01;
        vRef = 0.5 : 0.1 : 12; baseNoise = noiseLevel(crstLevel == refCrstLevel);
        thresholdV = zeros(1, length(vRef));
        
        for i = 1 : length(vRef)
            [meanRef, stdRef] = efficientEstimator(prior, baseNoise, vRef(i));                      
            deltaV = 0 : 0.001 : 20; testV = vRef(i) + deltaV;            
            for j = 1 : length(testV)
                [meanTest, stdTest] = efficientEstimator(prior, baseNoise, testV(j));
                dPrime = (meanTest - meanRef) / sqrt((stdTest ^ 2 + stdRef ^ 2) / 2);
                if (dPrime > targetDPrime - sigma) && (dPrime < targetDPrime + sigma)
                    thresholdV(i) = deltaV(j);
                    break;
                end
            end            
        end        
        plot(log(vRef), thresholdV ./ vRef, 'LineWidth', 2);
        
        thresholdV = zeros(1, length(vProb));
        targetC = 0.75; sigma = 0.01;
        
        for x = 1 : length(vProb)
            para = weibullPara(refCrst == refCrstLevel, vProb == vProb(x), crstLevel == refCrstLevel, :);
            deltaV = 0 : 0.001 : 10; testV = vProb(x) + deltaV; 
            probC = wblcdf(testV, para(1), para(2));
            
            thresholdV(x) = mean(deltaV(probC > targetC - sigma & probC < targetC + sigma));
        end
        plot(log(vProb), thresholdV ./ vProb, '--o');        
    end
end



