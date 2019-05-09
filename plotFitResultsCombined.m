%% Power law prior
load('./CombinedFit/combinedWeibull.mat');
load('./CombinedFit/combinedGauss.mat');

c0 = paraSub(1); c1 = paraSub(2); c2 = paraSub(3);
noiseLevel = paraSub(4:end);

domain    = -100 : 0.01 : 100;
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 ./ (trapz(domain, priorUnm));
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

plotResults(prior, noiseLevel, weibullFitCombined, 'Combined Subject: ');

%% Gamma Prior
load('./CombinedFit/combinedWeibull.mat');
load('./CombinedFit/combinedGamma.mat');

noiseLevel = paraSub(3:end);
prior = @(support) gampdf(abs(support), paraSub(1), paraSub(2)) * 0.5;

plotResults(prior, noiseLevel, weibullFitCombined, 'Combined Subject: ');

%% Gaussian Prior
load('./CombinedFit/combinedWeibull.mat');
load('./CombinedFit/combinedGaussPrior.mat');

noiseLevel = paraSub(3:end);
prior = @(support) normpdf(abs(support), paraSub(1), paraSub(2)) * 0.5;

plotResults(prior, noiseLevel, weibullFitCombined, 'Combined Subject: ');

%% Log Linear Prior
load('./CombinedFit/combinedWeibull.mat');
load('./CombinedFit/combinedLinear.mat');

nPoint = 10;
refLB  = log(0.1);
refUB  = log(100);
delta  = (refUB - refLB) / (nPoint - 1);
refPoint = refLB : delta : refUB;
refValue = paraSub(1: length(refPoint));

logLinearPrior = ...
    @(support) exp(interp1(refPoint, refValue, log(abs(support)), 'spline', 'extrap'));

domain = -100 : 0.01 : 100;
nrmConst = 1.0 / trapz(domain, logLinearPrior(domain));

prior = @(support)  logLinearPrior(support) * nrmConst;
plotResults(prior, paraSub(length(refPoint) + 1 : end), weibullFitCombined, 'Combined Subject: ');

%% Helper function
function plotResults(prior, noiseLevel, weibullPara, titleText)

refCrst    = [0.075, 0.5];
crstLevel  = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
vProb      = [0.5, 1, 2, 4, 8, 12];

% Shape of Prior
figure; priorSupport = (0 : 0.01 : 15);
plot(log(priorSupport), log(prior(priorSupport)), 'LineWidth', 2);

grid on;
title(strcat(titleText, 'Prior'));
xlabel('log V'); ylabel('log P(V)');

% Matching Speed
plotMatchSpeed(0.075);
plotMatchSpeed(0.5);

% Threshold
% true = relative threshold
figure; hold on; grid on;
l1 = plotThreshold(0.075, false, 1);
l2 = plotThreshold(0.5, false, 2);

legend([l1, l2], {'0.075', '0.5'});
title(strcat(titleText, 'Absolute Threshold'));

    function plotMatchSpeed(refCrstLevel)
        vRef = 0.5 : 0.1 : 12; baseNoise = noiseLevel(crstLevel == refCrstLevel);
        estVRef = @(vRef) efficientEstimator(prior, baseNoise, vRef);
        estiVRef = arrayfun(estVRef, vRef);
        
        figure; hold on; grid on;
        colors = get(gca,'colororder');
        testCrst = [0.05, 0.1, 0.2, 0.4, 0.8];
        
        % Plot matching speed computed from Bayesian fit
        for i = 1 : length(testCrst)
            vTest = 0.05 : 0.005 : 24; baseNoise = noiseLevel(crstLevel == testCrst(i));
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
        weibullLine = zeros(1, length(testCrst));
        for i = 1 : length(testCrst)
            vMatch = zeros(1, length(vRef));
            for j = 1 : length(vRef)
                para = weibullPara(refCrst == refCrstLevel, vProb == vRef(j), crstLevel == testCrst(i), :);
                
                candV = 0 : 0.001 : vRef(j) + 15;
                targetProb = 0.5; delta = 0.01;
                probCorrect = wblcdf(candV, para(1), para(2));
                
                vMatch(j) = mean(candV(probCorrect > targetProb - delta & probCorrect < targetProb + delta));
            end
            weibullLine(i) = ...
                plot(log(vRef), vMatch ./ vRef, '--o', 'Color', colors(i, :));
        end
        
        title(strcat(titleText, 'Matching Speed'));
        xlabel('log V'); ylabel('Matching Speed: $\frac{V_{1}}{V_{0}}$', 'Interpreter', 'latex');
        xticks(log(vRef)); xticklabels(arrayfun(@num2str, vRef, 'UniformOutput', false));
        
        legend(weibullLine, arrayfun(@num2str, testCrst, 'UniformOutput', false));
    end

    function dataLine = plotThreshold(refCrstLevel, relative, colorIdx)
        colors = get(gca,'colororder');
        
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
            plot(log(vRef), thresholdV ./ vRef, 'LineWidth', 2, 'Color', colors(colorIdx, :));
        else
            plot(log(vRef), log(thresholdV), 'LineWidth', 2, 'Color', colors(colorIdx, :));
        end
        
        thresholdV = zeros(1, length(vProb));
        targetC = 0.75; sigma = 0.001;
        
        for x = 1 : length(vProb)
            para = weibullPara(refCrst == refCrstLevel, vProb == vProb(x), crstLevel == refCrstLevel, :);
            deltaV = 0 : 0.0001 : 10; testV = vProb(x) + deltaV;
            probC = wblcdf(testV, para(1), para(2));
            
            thresholdV(x) = mean(deltaV(probC > targetC - sigma & probC < targetC + sigma));
        end
        
        if relative
            dataLine = plot(log(vProb), thresholdV ./ vProb, '--o', 'Color', colors(colorIdx, :));
            ylabel('Relative Threshold');
        else
            dataLine = plot(log(vProb), log(thresholdV), '--o', 'Color', colors(colorIdx, :));
            ylabel('Log Absolute Threshold');
        end
        
        xlabel('log V');
        xticks(log(vProb));
        xticklabels(arrayfun(@num2str, vProb, 'UniformOutput', false));
    end
end