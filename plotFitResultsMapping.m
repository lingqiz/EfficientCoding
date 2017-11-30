dataDir = './NN2006/';
load(strcat(dataDir, 'weibullFit1.mat'));
load(strcat(dataDir, 'weibullFit2.mat'));

c0 = 0.66; c1 = 3.29; c2 = 0.0048;
noiseLevel = [0.0521, 0.0358, 0.0352, 0.0239, 0.0243, 0.0217, 0.0141];
plotResults(c0, c1, c2, noiseLevel, weibullFit1, 'Subject1: ');

% c0 = 0.7340; c1 = 3.7791; c2 = 0.0011;
% noiseLevel = [1.9129, 1.4875, 1.2727, 0.8150, 0.5942, 0.4427, 0.2551];
% plotResults(c0, c1, c2, noiseLevel, weibullFit2, 'Subject2: ');

function plotResults(c0, c1, c2, noiseLevel, weibullPara, titleText)

refCrst    = [0.075, 0.5];
crstLevel  = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
vProb      = [0.5, 1, 2, 4, 8, 12];

domain    = 0 : 0.01 : 100; 
priorUnm  = 1.0 ./ (c1 * (abs(domain) .^ c0) + c2);
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1 ./ (c1 * (abs(support) .^ c0) + c2)) * nrmConst;

% Shape of Prior 
figure; priorSupport = (0 : 0.01 : 15);
plot(log(priorSupport), log(prior(priorSupport)), 'LineWidth', 2);
title(strcat(titleText, 'Prior'));
xlabel('log V'); ylabel('log P(V)');

% Matching Speed
plotMatchSpeed(0.075); 
plotMatchSpeed(0.5);

% Threshold
figure; hold on; grid on;
plotThreshold(0.5); 
plotThreshold(0.075);
title(strcat(titleText, 'Relative Threshold'));

    function plotMatchSpeed(refCrstLevel)        
        figure; hold on; grid on;
        colors = get(gca,'colororder');
        
        testCrst = [0.05, 0.1, 0.2, 0.4, 0.8];        
        
        % Plot matching speed computed from Bayesian fit
        vRef = 0.5 : 0.1 : 12;
        for i = 1 : length(testCrst)
            noiseConst = noiseLevel(crstLevel == testCrst(i));
            vMatch = zeros(1, length(vRef));
            for j = 1 : length(vRef)
                [estiRef, probRef] = mappingEstimator(prior, noiseConst, vRef(j));

                target = 0.5; tolerance = 0.01;
                matchL = 0.2; matchH = vRef(j) * 10;
                matchEst = (matchL + matchH) / 2;

                [estiEst, probEst] = mappingEstimator(prior, noiseConst, matchEst);
                pC = probFasterGrid(estiRef, probRef, estiEst, probEst);

                while((pC < target - tolerance) || (pC > target + tolerance))
                    if pC > target
                        matchH = matchEst;
                    else
                        matchL = matchEst;
                    end

                    matchEst = (matchL + matchH) / 2;
                    [estiEst, probEst] = mappingEstimator(prior, noiseConst, matchEst);
                    pC = probFasterGrid(estiRef, probRef, estiEst, probEst);
                end
                vMatch(j) = matchEst;
            end
            plot(log(vRef), vMatch ./ vRef, 'LineWidth', 2); 
        end    
        
        % Plot matching speed computed from Weibull fit
        vRef = [0.5, 1, 2, 4, 8, 12]; 
        for i = 1 : length(testCrst)
            vMatch = zeros(1, length(vRef)); 
            for j = 1 : length(vRef)
                para = weibullPara(refCrst == refCrstLevel, vProb == vRef(j), crstLevel == testCrst(i), :);
                
                candV = 0 : 0.01 : vRef(j) + 10;  
                targetProb = 0.5; delta = 0.1;
                probCorrect = wblcdf(candV, para(1), para(2));
                
                vMatch(j) = mean(candV(probCorrect > targetProb - delta & probCorrect < targetProb + delta));
            end
            plot(log(vRef), vMatch ./ vRef, '--o', 'Color', colors(i, :));
        end
        
        title(strcat(titleText, 'Matching Speed'));
        xlabel('log V'); ylabel('Matching Speed: $\frac{V_{1}}{V_{0}}$', 'Interpreter', 'latex');
        xticks(log(vRef)); xticklabels(arrayfun(@num2str, vRef, 'UniformOutput', false));
        
    end

    function plotThreshold(refCrstLevel)
        targetC = 0.75; tolerance = 0.005;
        vRef = 0.5 : 0.2 : 12; baseNoise = noiseLevel(crstLevel == refCrstLevel);
        thresholdV = zeros(1, length(vRef));
                
        for i = 1 : length(vRef)
            [estiRef, probRef] = mappingEstimator(prior, baseNoise, vRef(i));
            
            deltaL = 0; deltaH = 20;
            deltaEst = (deltaL + deltaH) / 2;
            [estiTest, probTest] = mappingEstimator(prior, baseNoise, vRef(i) + deltaEst);
            pC = probFasterGrid(estiRef, probRef, estiTest, probTest);
            
            while(pC < targetC - tolerance || pC > targetC + tolerance)
                if pC > targetC
                   deltaH = deltaEst; 
                else
                   deltaL = deltaEst;
                end
                
                deltaEst = (deltaL + deltaH) / 2;
                [estiTest, probTest] = mappingEstimator(prior, baseNoise, vRef(i) + deltaEst);
                pC = probFasterGrid(estiRef, probRef, estiTest, probTest);                       
            end
            thresholdV(i) = deltaEst;
        end
        
        plot(log(vRef), log(thresholdV), 'LineWidth', 2);
        
        thresholdV = zeros(1, length(vProb));
        targetC = 0.75; sigma = 0.001;
        
        for x = 1 : length(vProb)
            para = weibullPara(refCrst == refCrstLevel, vProb == vProb(x), crstLevel == refCrstLevel, :);
            deltaV = 0 : 0.0001 : 10; testV = vProb(x) + deltaV; 
            probC = wblcdf(testV, para(1), para(2));
            
            thresholdV(x) = mean(deltaV(probC > targetC - sigma & probC < targetC + sigma));
        end
        plot(log(vProb), log(thresholdV), '--o');
        
        xlabel('log V'); ylabel('Relative Threshold');
        xticks(log(vProb)); xticklabels(arrayfun(@num2str, vProb, 'UniformOutput', false));
    end
end



