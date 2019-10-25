%% Figure 1 - Piror

load('./MappingFit/new_para_map_fit/new_para_Feb9.mat');
load('./weibullFitAll.mat');

figure; hold on;
set(gca, 'FontSize', 14);
colors = get(gca,'colororder');

nSub = 5;
allPara = [paraSub1; paraSub2; paraSub3; paraSub4; paraSub5];

for i = 1 : nSub
    para = allPara(i, :);
    l1 = plotPrior(para, true, false, '-', ones(1, 3) * 0.8);
end

load('CombinedFit/combinedMapping.mat');
load('CombinedFit/combinedWeibull.mat');
l2 = plotPrior(paraSub, true, false, '-', ones(1, 3) * 0.1);

l3 = plotPrior([1, 0.33, 0], true, false, '--', ones(1, 3) * 0.1);
legend([l1, l2, l3], {'Individual Subject', 'Combined', 'Neural Prior'});

priorXlim = xlim();
set(gcf,'Position',[0, 0, 600, 500]);

%% Distribution of Data
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat')); load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat')); load(strcat(dataDir, 'SUB4.mat')); load(strcat(dataDir, 'SUB5.mat'));

figure();
combined = [subject1, subject2, subject3, subject4, subject5];
hist = histogram(log(abs(combined(3, :))), 50, 'Normalization', 'probability');
hist.FaceColor = [0.5, 0.5, 0.5];
box off;

xlim(priorXlim);
labelPos = [0.1, 0.25, 0.5, 1, 2.0, 4.0, 8.0, 20, 40];
xticks(log(labelPos));
xticklabels(arrayfun(@num2str, labelPos, 'UniformOutput', false));

figure();
hist = histogram(abs(combined(3, :)), 50, 'Normalization', 'probability');
hist.FaceColor = [0.5, 0.5, 0.5];
box off;

%% Figure 2 - likelihood
nTrial = [5760, 5760, 960, 5760, 6240];
nTrial = [nTrial, sum(nTrial)];
llLB = -log(0.5) * nTrial;

BayesianLL = [fval1, fval2, fval3, fval4, fval5, fval];
WeibullLL  = [LL1, LL2, LL3, LL4, LL5, LL];
original  = [0.9, 0.85, 0.92, 0.82, 0.9, Inf];

figure; grid on;
normalizedLL = (llLB - BayesianLL) ./ (llLB - WeibullLL);

load('./MappingFit/new_para_map_fit/fixed_prior_01.mat');
fixedPriorLL = [fval1, fval2, fval3, fval4, fval5, Inf];
nrmFixedPriorLL = (llLB - fixedPriorLL) ./ (llLB - WeibullLL);

barPlot = bar([nrmFixedPriorLL; normalizedLL; original]');
legend('Neural Prior', 'Efficient Coding', 'NN2006');

barPlot(1).FaceColor = ones(1, 3) * 0.4;
barPlot(2).FaceColor = ones(1, 3) * 0.0;
barPlot(3).FaceColor = ones(1, 3) * 0.8;

yticks(0 : 0.2 : 1); grid on;
yticklabels(arrayfun(@num2str, 0 : 0.2 : 1, 'UniformOutput', false));

title('Normalized Log Likelihood');
xlabel('Subject'); ylabel('Normalized Log Likelihood');
name = {'1';'2';'3';'4';'5'; 'Combined'};
set(gca,'xticklabel',name);
set(gca, 'FontSize', 14)

function line = plotPrior(para, logSpace, transform, style, lineColor)
c0 = para(1); c1 = para(2); c2 = para(3);

domain    = -100 : 0.01 : 100;

priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

UB = 40; priorSupport = (0.1 : 0.001 : UB);
if logSpace
    line = plot(log(priorSupport), log(prior(priorSupport)), style, 'LineWidth', 2, 'Color', lineColor);
    
    labelPos = [0.1, 0.25, 0.5, 1, 2.0, 4.0, 8.0, 20, 40];
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
    line = plot((priorSupport), (priorProb), style, 'LineWidth', 2, 'Color', lineColor);
    xlim([0.01, UB]);
end

ylim([-7, -0.5]);
title('Prior Across All Subjects');
xlabel('V'); ylabel('P(V)');
end