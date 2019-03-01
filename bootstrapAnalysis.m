%% Bootstrap
subject = subject1;
paraSub = paraSub1;
subjectIdx = 1;

resampleData = resample(subject);
[sumLL, fitResults] = weibullFit(resampleData);
[biasLC, biasHC, thLC, thHC] = extractPsychcurve(fitResults, false);

nBootstrap = 100;

allBiasLC = zeros([nBootstrap, size(biasLC)]);
allBiasHC = zeros([nBootstrap, size(biasHC)]);
allthLC   = zeros([nBootstrap, length(thLC)]);
allthHC   = zeros([nBootstrap, length(thHC)]);

parfor idx = 1:nBootstrap
    resampleData = resample(subject);
    [sumLL, fitResults] = weibullFit(resampleData);
    [biasLC, biasHC, thLC, thHC] = extractPsychcurve(fitResults, false);
    
    allBiasLC(idx, :, :) = biasLC;
    allBiasHC(idx, :, :) = biasHC;
    allthLC(idx, :)   = thLC;
    allthHC(idx, :)   = thHC;
end

%% Analysis & Plot
c0 = paraSub(1); c1 = paraSub(2); c2 = paraSub(3);
noiseLevel = paraSub(4:end);

refCrst   = [0.075, 0.5];
crstLevel = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
vProb     = [0.5, 1, 2, 4, 8, 12];
vRef      = [0.5, 1, 2, 4, 8, 12];

% Computing Prior Probability
domain    = -100 : 0.01 : 100; 
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

figure; hold on; grid on;
colors = get(gca,'colororder');

plotBiasBayes(prior, noiseLevel, 0.075);
plotWeibullLine(allBiasLC, nBootstrap, colors);
xlabel('log V'); ylabel('Matching Speed: $\frac{V_{1}}{V_{0}}$', 'Interpreter', 'latex');
xticks(log(vRef)); xticklabels(arrayfun(@num2str, vRef, 'UniformOutput', false));
title(sprintf('Subject %d Matching Speed - Low Contrast', subjectIdx));
ylim([0, 2.5]);

figure; hold on; grid on;
plotBiasBayes(prior, noiseLevel, 0.5);
plotWeibullLine(allBiasHC, nBootstrap, colors);
xlabel('log V'); ylabel('Matching Speed: $\frac{V_{1}}{V_{0}}$', 'Interpreter', 'latex');
xticks(log(vRef)); xticklabels(arrayfun(@num2str, vRef, 'UniformOutput', false));
title(sprintf('Subject %d Matching Speed - High Contrast', subjectIdx));
ylim([0, 6]);

%% Threshold
figure; hold on; grid on;
colors = get(gca,'colororder');

meanThLC = mean(allthLC, 'omitnan');
stdThLC  = std(allthLC, 'omitnan');
t1 = errorbar(log(vProb), meanThLC, stdThLC*2, '--o', 'Color', colors(1, :));
plotThresBayes(prior, noiseLevel, 0.075, colors(1, :));

meanThHC = mean(allthHC, 'omitnan');
stdThHC  = std(allthHC, 'omitnan');
t2 = errorbar(log(vProb), meanThHC, stdThHC*2, '--o', 'Color', colors(2, :));
plotThresBayes(prior, noiseLevel, 0.5, colors(2, :));

xlabel('log V'); ylabel('Threshold');
xticks(log(vProb)); 
xticklabels(arrayfun(@num2str, vProb, 'UniformOutput', false));
yticklabels(arrayfun(@(x)num2str(x, '%.2f'), exp(yticks), 'UniformOutput', false));
legend([t1, t2], {'0.075', '0.5'});
title(sprintf('Subject %d Threshold', subjectIdx));
