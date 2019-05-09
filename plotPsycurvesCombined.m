% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));

load('./CombinedFit/combinedWeibull.mat');
combinedSubject = [subject1, subject2, subject3, subject4, subject5];

%% Pwrlaw Prior
load('./CombinedFit/combinedGauss.mat');
c0 = paraSub(1); c1 = paraSub(2); c2 = paraSub(3);
noiseLevel = paraSub(4:end);

domain    = -100 : 0.01 : 100;
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 ./ (trapz(domain, priorUnm));
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

plotPsycurve(combinedSubject, prior, noiseLevel, weibullFitCombined, 'Combined Subject:');

%% Gamma Prior
load('./CombinedFit/combinedGamma.mat');

noiseLevel = paraSub(3:end);
prior = @(support) gampdf(abs(support), paraSub(1), paraSub(2)) * 0.5;

plotPsycurve(combinedSubject, prior, noiseLevel, weibullFitCombined, 'Combined Subject:')

%% Log Linear Prior
load('./CombinedFit/combinedWeibull.mat');
load('./CombinedFit/combinedLogLinear.mat');

nPoint = 20;
refLB  = log(0.1);
refUB  = log(100);
delta  = (refUB - refLB) / (nPoint - 1);
refPoint = refLB : delta : refUB;
refValue = paraSub(1: length(refPoint));

logLinearPrior = ...
    @(support) exp(interp1(refPoint, refValue, log(abs(support)), 'spline', 'extrap'));

domain = 0.1 : 0.01 : 100;
nrmConst = 1.0 / trapz(domain, logLinearPrior(domain));

prior = @(support)  logLinearPrior(support) * nrmConst * 0.5;
plotPsycurve(combinedSubject, prior, paraSub(length(refPoint) + 1 : end), weibullFitCombined, 'Combined Subject:')

%% Helper function
function plotPsycurve(subData, prior, noiseLevel, weibullPara, titleText)

cRef  = 0.075;
cTest = [0.05, 0.075, 0.1, 0.2, 0.4, 0.8];
plotPsycurveCrst(subData, prior, noiseLevel, weibullPara, cRef, cTest, strcat(titleText, 'Reference Contrast = 0.075'))

cRef = 0.5;
cTest = [0.05, 0.1, 0.2, 0.4, 0.5, 0.8];
plotPsycurveCrst(subData, prior, noiseLevel, weibullPara, cRef, cTest, strcat(titleText, 'Reference Contrast = 0.5'))

end

function plotPsycurveCrst(subData, prior, noiseLevel, weibullPara, cRef, cTest, titleText)

refCrst    = [0.075, 0.5];
testCrst   = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
refV       = [0.5, 1, 2, 4, 8, 12];

supports = [0.25, 1; 0.25, 2; 0.25, 4; 0.25, 10; 0.25, 25; 0.25, 30];

index = reshape(1 : 36, 6, 6)';
figure('Renderer', 'painters', 'Position', [10 10 1024 768]);

for i = 1 : length(cTest)
    for j = 1 : length(refV)
        crst1 = cRef; v1 = refV(j); crst2 = cTest(i);
        noise1 = noiseLevel(testCrst == crst1);
        noise2 = noiseLevel(testCrst == crst2);
        
        rangeV = supports(refV == v1, :);
        v2 = rangeV(1) : 0.005 : rangeV(2);
        
        testData = subData([3, 9], ...
            subData(2, :) == crst1 & subData(1, :) == v1 & subData(4, :) == crst2);
        [testSpeed, ~, idxC] = uniquetol(testData(1, :), 1e-4);
        resProb = zeros(1, length(testSpeed));
        dataCount = zeros(1, length(testSpeed));
        scale = 4;
        for idx = 1:length(testSpeed)
            resProb(idx) = mean(testData(2, idxC' == idx));
            dataCount(idx) = sum(idxC' == idx);
        end
        
        subplot(6, 6, index((i-1) * 6 + j));
        if(sum(dataCount) > 0)
            para = weibullPara(refCrst == crst1, refV == v1, testCrst == crst2, :);
            pLgrWeibull = wblcdf(v2, para(1), para(2));
            pLgrBayes = zeros(1, length(v2));
            
            [meanRef, stdRef] = efficientEstimator(prior, noise1, v1);
            for k = 1 : length(pLgrBayes)
                [meanTest, stdTest] = efficientEstimator(prior, noise2, v2(k));
                dPrime = (meanTest - meanRef) / sqrt((stdTest ^ 2 + stdRef ^ 2) / 2);
                pLgrBayes(k) = 0.5 * erfc(-0.5 * dPrime);
            end
            
            plot(v2, pLgrWeibull, 'r', 'LineWidth', 1.5); hold on;
            plot(v2, pLgrBayes,   'b', 'LineWidth', 1.5);
        end
        
        scatter(testSpeed, resProb, dataCount * scale, 'k');
        xlim([rangeV(1) rangeV(2)]); ylim([0, 1]);
        
        if(i == 1)
            ylabel(sprintf('Reference Speed:\n%.1f', v1));
        end
        if(j == 1)
            title(sprintf('Test Contrast:\n%g', crst2), 'FontWeight','Normal');
        end
        if(j == 6)
            xlabel('Test Speed [deg/sec]');
        end
        
    end
end
suptitle(titleText);
end