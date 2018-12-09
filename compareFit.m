load('./GaussFitFinal/gauss_final.mat');
load('./AllFitRes/weibullFitAll.mat');

figure; hold on; grid on;
colors = get(gca,'colororder');

nSub = 5;
allPara = [paraSub1; paraSub2; paraSub3; paraSub4; paraSub5];

for i = 1 : nSub
    para = allPara(i, :);
    plotPrior(para, true, false, '-');
end

plotPrior([1, 0.3, 0], true, false, '--');
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

function plotPrior(para, logSpace, transform, style)
c0 = para(1); c1 = para(2); c2 = para(3);

domain    = -20 : 0.01 : 20;

priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 / (trapz(domain, priorUnm));
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

UB = 20; priorSupport = (0.25 : 0.001 : UB);
if logSpace
    plot(log(priorSupport), log(prior(priorSupport)), style, 'LineWidth', 2);
    
    labelPos = [0.25, 0.5, 1, 2.1 : 2 : 12.1, 20];
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
    plot((priorSupport), (priorProb), style, 'LineWidth', 2);
    xlim([0.01, UB]);
end

ylim([-7, -1]);
title('Prior Across All Subjects');
xlabel('V'); ylabel('P(V)');
end