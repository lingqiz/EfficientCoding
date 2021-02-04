%% Figure format
try 
    plotlabOBJ = plotlab();
    plotlabOBJ.applyRecipe(...
        'figureWidthInches', 15, ...
        'figureHeightInches', 15);
catch EXP
    fprintf('plotlab not available, use default MATLAB style \n');
end

%% Compare fit for individual subject
load('./AllFitRes/BayesianFitAll1.mat');
load('./AllFitRes/weibullFitAll.mat');

figure; hold on; grid on;
colors = get(gca,'colororder');

nSub = 5;
allPara = [paraSub1; paraSub2; paraSub3; paraSub4; paraSub5];

for i = 1 : nSub
    para = allPara(i, :);
    plotPriorWrapper(para, true, false, '-');
end

plotPriorWrapper([1, 1, 0.3], true, false, '--');
legend('Sub1', 'Sub2', 'Sub3', 'Sub4', 'Sub5', 'Reference');

nTrial = [5760, 5760, 960, 5760, 6240];
llLB = -log(0.5) * nTrial;

BayesianLL = [fval1, fval2, fval3, fval4, fval5];
WeibullLL  = [LL1, LL2, LL3, LL4, LL5];

figure; grid on;
normalizedLL = (llLB - BayesianLL) ./ (llLB - WeibullLL);

original  = [0.85, 0.82, 0.92, 0.82, 0.9];
competing = [0.55, 0.5, 0.65, 0.4, 0.6];

barPlot = bar([competing; normalizedLL; original]');
legend('Hurliman et al.', 'Efficient Coding', 'NN2006');

barPlot(1).FaceColor = colors(1, :);
barPlot(2).FaceColor = colors(2, :);
barPlot(3).FaceColor = colors(5, :);

yticks(0 : 0.2 : 1); grid on;
yticklabels(arrayfun(@num2str, 0 : 0.2 : 1, 'UniformOutput', false));

title('Normalized Log Likelihood');
xlabel('Subject'); ylabel('Normalized Log Probability');

%% Compare fit for combined subject
figure('DefaultAxesFontSize', 15); hold on;
colors = get(gca,'colororder');

load('./CombinedFit/combinedWeibull.mat');
WeibullLL = LL;
nTrial = [5760, 5760, 960, 5760, 6240];
llLB = sum(nTrial) * -log(0.5);

% load('./CombinedFit/combinedGauss.mat');
load('./CombinedFit/combinedMapping.mat');
normalizedPwr = (llLB - fval) / (llLB - WeibullLL);

load('./CombinedFit/combinedGamma.mat');
normalizedGamma = (llLB - fval) / (llLB - WeibullLL);

load('./CombinedFit/combinedLogLinear.mat');
normalizedLoglinear = (llLB - fval) / (llLB - WeibullLL);

load('./CombinedFit/combinedGaussUni.mat');
normalizedGauss = (llLB - fval) / (llLB - WeibullLL);

labels = categorical({'1 Power Law','2 Gamma','4 Gaussian', '3 Piecewise Log Linear'});
barPlot = bar(labels, [normalizedPwr; normalizedGamma; normalizedGauss; normalizedLoglinear], 0.25);
xlabel('Combined Subject'); ylim([0, 1]);
ylabel('Normalized Log Likelihood');

title('Effect of the Parametric Family of Prior')
grid on; barPlot.FaceColor = 'flat';
barPlot.CData(1,:) = ones(1, 3) * 0.0;
barPlot.CData(2,:) = ones(1, 3) * 0.3;
barPlot.CData(3,:) = ones(1, 3) * 0.6;
barPlot.CData(4,:) = ones(1, 3) * 0.9;

%% Compare different prior 
figure('DefaultAxesFontSize', 14); hold on;

load('./CombinedFit/combinedMapping.mat');
c0 = paraSub(1); c1 = paraSub(2); c2 = paraSub(3);
domain    = -100 : 0.01 : 100;
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 ./ (trapz(domain, priorUnm));
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;
plotPrior(prior, true, false, '-', ones(1, 3) * 0.0);

load('./CombinedFit/combinedGamma.mat');
noiseLevel = paraSub(3:end);
prior = @(support) gampdf(abs(support), paraSub(1), paraSub(2)) * 0.5;
plotPrior(prior, true, false, '-', ones(1, 3) * 0.5);

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
plotPrior(prior, true, false, '-', ones(1, 3) * 0.75);

load('./CombinedFit/combinedGaussUni.mat');
prior = @(support) (0.9 * normpdf(abs(support), 0, paraSub(1)) + 0.002);
plotPrior(prior, true, false, '-', ones(1, 3) * 0.9);

plotPriorWrapper([1, 1, 0.3], true, false, '--');
legend({'Power Law', 'Gamma', 'Log Linear', 'Gaussian', 'Neural Prior'});
title('Prior Across Parameterization')

%% Helper functions
function plotPriorWrapper(para, logSpace, transform, style)
c0 = para(1); c1 = para(2); c2 = para(3);

domain    = -100 : 0.01 : 100;
priorUnm  = 1.0 ./ (c1 * (abs(domain) .^ c0) + c2);
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1 ./ (c1 * (abs(support) .^ c0) + c2)) * nrmConst;

plotPrior(prior, logSpace, transform, style, ones(1, 3) * 0.0)
end


function plotPrior(prior, logSpace, transform, style, lineColor)
% Shape of Prior
UB = 40; priorSupport = (0.1 : 0.001 : UB);
if logSpace
    plot(log(priorSupport), log(prior(priorSupport)), style, 'LineWidth', 2, 'Color', lineColor);
    
    labelPos = [0.1, 0.25, 0.5, 1, 2, 4, 8, 20, 40];
    xticks(log(labelPos));
    xticklabels(arrayfun(@num2str, labelPos, 'UniformOutput', false));
    
    probPos = 0.01 : 0.05 : 0.3;
    yticks(log(probPos));
    yticklabels(arrayfun(@num2str, probPos, 'UniformOutput', false));
else
    priorProb = prior(priorSupport);
    if transform
        priorProb = cumtrapz(priorSupport, priorProb);
    end
    plot((priorSupport), (priorProb), style, 'LineWidth', 2, 'Color', lineColor);
    xlim([0.01, UB]);
end

ylim([-7, -0.5]);
title('Prior Distribution');
xlabel('V'); ylabel('P(V)');

end