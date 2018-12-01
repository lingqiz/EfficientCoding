load('GammaPrior/gammaFit2.mat');
nSub = 5;
allPara = [paraSub1; paraSub2; paraSub3; paraSub4; paraSub5];

figure; hold on; grid on;
for idx = 1:nSub
    para = allPara(idx, :);
    plotPrior(para, true, false, '-');
end

function plotPrior(para, logSpace, transform, style)

prior = @(support) gampdf(abs(support), para(1), para(2));

domain = [-20:0.01:-0.01, 0.01:0.01:20];
priorUnm = prior(domain);
nrmConst = trapz(domain, priorUnm);

prior = @(support) gampdf(abs(support), para(1), para(2)) / nrmConst;

% Shape of Prior 
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

ylim([-5.5, -1]);
title('Prior Across All Subjects');
xlabel('V'); ylabel('P(V)');
end