load('./AllFitRes/weibullFitAll.mat');
plotPsycurve(paraSub1, weibullFit1, 'Subject 1');

function plotPsycurve(modelPara, weibullPara, titleText)

cRef  = 0.075;
cTest = [0.05, 0.075, 0.1, 0.2, 0.4, 0.8];
plotPsycurveCrst(modelPara, weibullPara, cRef, cTest, strcat(titleText, 'Crst = 0.075'))

cRef = 0.5;
cTest = [0.05, 0.1, 0.2, 0.4, 0.5, 0.8];
plotPsycurveCrst(modelPara, weibullPara, cRef, cTest, strcat(titleText, 'Crst = 0.5'))

end

function plotPsycurveCrst(modelPara, weibullPara, cRef, cTest, titleText)

refCrst    = [0.075, 0.5];
testCrst   = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
refV       = [0.5, 1, 2, 4, 8, 12];

supports = [0, 1; 0, 2; 0, 4; 0, 10; 0, 25; 0, 30];

c0 = modelPara(1); c1 = modelPara(2); c2 = modelPara(3);
noiseLevel = modelPara(4:end); 
    
domain    = 0 : 0.01 : 100;
priorUnm  = 1.0 ./ (c1 * (abs(domain) .^ c0) + c2);
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1 ./ (c1 * (abs(support) .^ c0) + c2)) * nrmConst; 

index = reshape(1 : 36, 6, 6)';
figure; 

for i = 1 : length(cTest)
    for j = 1 : length(refV)                
        crst1 = cRef; v1 = refV(j); crst2 = cTest(i); 
        noise1 = noiseLevel(testCrst == crst1);
        noise2 = noiseLevel(testCrst == crst2);
        
        rangeV = supports(refV == v1, :);
        v2 = rangeV(1) : 0.05 : rangeV(2);
        
        para = weibullPara(refCrst == crst1, refV == v1, testCrst == crst2, :);
        pLgrWeibull = wblcdf(v2, para(1), para(2));
        pLgrBayes = zeros(1, length(v2));
        
        [estsRef, probRef] = mappingEstimator(prior, noise1, v1);
        for k = 1 : length(pLgrBayes)
            [estsTest, probTest] = mappingEstimator(prior, noise2, v2(k));            
            pLgrBayes(k) = probFasterGrid(estsRef, probRef, estsTest, probTest);
        end
        pLgrBayes(pLgrBayes > 1) = 1;
        
        subplot(6, 6, index((i-1) * 6 + j));
        plot(v2, pLgrWeibull, 'r', 'LineWidth', 1.5); hold on;
        plot(v2, pLgrBayes,   'b', 'LineWidth', 1.5);
        xlim([rangeV(1) rangeV(2)]); ylim([0, 1]);
    end
end
suptitle(titleText);
end

