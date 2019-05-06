%% Mapping fit
load('MappingFit/new_para_map_fit/new_para_Feb9.mat');

crst = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
sub3Idx = [2, 6, 7];

figure; hold on; grid on;
colors = get(gca,'colororder'); 
set(gca, 'FontSize', 14)

ylim([0 0.1]);
title('Homogeneous Space');

xticks(log(crst)); 
xticklabels(arrayfun(@num2str, crst, 'UniformOutput', false));
xlim(log([0.04, 0.9]));
xlabel('Contrast'); ylabel('Noise Constant')

%% Semiparametric fit
subplot(3, 2, 1);
l1 = plot(log(crst), paraSub1(4:end), 'o', 'LineWidth', 1.2, 'Color', colors(1, :)); 
hold on; grid on;
noise_sub1 = plot_fit(crst, paraSub1, colors(1, :), [1e4, 100, rand(1, 2)]);
title('Subject 1');

subplot(3, 2, 2);
l2 = plot(log(crst), paraSub2(4:end), 'o', 'LineWidth', 1.2, 'Color', colors(2, :));
hold on; grid on;
noise_sub2 = plot_fit(crst, paraSub2, colors(2, :), [1e4, 100, rand(1, 2)]);
title('Subject 2');

subplot(3, 2, 3);
l3 = plot(log(crst(sub3Idx)), paraSub3(3 + sub3Idx), 'o', 'LineWidth', 1.2, 'Color', colors(3, :));
hold on; grid on;
noise_sub3 = plot_fit(crst(sub3Idx), [ones(1, 3), paraSub3(3+sub3Idx)], colors(3, :), [2e4, 200, 1.78, 0.82]);
title('Subject 3');

subplot(3, 2, 4);
l4 = plot(log(crst), paraSub4(4:end), 'o', 'LineWidth', 1.2, 'Color', colors(4, :));
hold on; grid on;
noise_sub4 = plot_fit(crst, paraSub4, colors(4, :), [1e4, 100, rand(1, 2)]);
title('Subject 4');

subplot(3, 2, [5, 6]);
l5 = plot(log(crst), paraSub5(4:end), 'o', 'LineWidth', 1.2, 'Color', colors(5, :));
hold on; grid on;
noise_sub5 = plot_fit(crst, paraSub5, colors(5, :), [1e4, 100, rand(1, 2)]);
pbaspect([2.1 1 1]);
title('Subject 5');

suptitle('Contrast-dependent Noise');

%% Gaussian fit
% load('GaussFitFinal/gauss_final.mat');
% subplot(1, 2, 2);  hold on; grid on;
% set(gca, 'FontSize', 14)
% 
% paraSub1 = plotNoise(paraSub1);
% paraSub2 = plotNoise(paraSub2);
% paraSub4 = plotNoise(paraSub4);
% paraSub5 = plotNoise(paraSub5);
% 
% legend({'Sub1', 'Sub2', 'Sub4', 'Sub5'});
% ylim([0 0.1]);
% title('Gaussian Approximation');

function loss = combined_loss(combined_data, combined_para)
    crst = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
    rmax = combined_para(1); rbase = combined_para(2);
    paras = reshape(combined_para(3:end), [4, 2]);
    
    loss = 0;
    for idx = 1:4
        pred = hc(crst, [rmax, rbase, paras(idx, :)]);
        loss = loss + sum((pred - combined_data(idx, :)) .^ 2);        
    end
end

function fit = plot_fit(crst, paraSub, color, init)    
    fit = fit_para(crst, paraSub(4:end), init);
    crstRange = 0.04 : 0.01 : 1;
        
    plot(log(crstRange), hc(crstRange, fit), 'k', 'LineWidth', 1.2, 'Color', color);
    legend({sprintf('q: %.2f \nc50: %.2f', fit(3), fit(4))});

    xticks(log(crst)); 
    xticklabels(arrayfun(@num2str, crst, 'UniformOutput', false));
    xlim(log([0.04, 1]));
    ylim([0, 0.08]);
end


function fit = fit_para(crst, noise, init)    
    options = optimoptions('fmincon','Display','off', ...
        'OptimalityTolerance', 1e-10, 'StepTolerance', 1e-10, 'MaxFunctionEvaluations', 1e5);
    
    problem.options = options;
    problem.solver = 'fmincon';
    problem.objective = @(para) sum((hc(crst, para) - noise) .^ 2);
    problem.x0 = init;
    problem.lb = [-1e3, -1e3, 0, 0];
    problem.ub = [1e6, 1e6, 100, 1];
    
    fit = fmincon(problem);
end

% TODO: compare fisher information?
% TODO: lookup r_max, r_base, q and c_50 from neural data 
% and compare to our fits
function noise = hc(c, para)
    rmax = para(1); rbase = para(2); 
    q = para(3); c50 = para(4);
    
    rate  = rmax * (c .^ q) ./ (c .^ q + c50 .^ q) + rbase;
    noise = 1 ./ sqrt(rate); 
end

function paraSub = plotNoise(paraSub)
crst = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
c0 = paraSub(1); c1 = paraSub(2); c2 = paraSub(3);

% Computing Prior Probability
domain    = -100 : 0.01 : 100; 
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 / (trapz(domain, priorUnm));

% Prior prob function handler
prior = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

vBaseNoise = 1; 
baseStd = prior(vBaseNoise) * paraSub(4:end);
paraSub(4:end) = baseStd;

plot(crst, baseStd, '--o', 'LineWidth', 1.2)
% plot(log(crst), baseStd, '--o', 'LineWidth', 1.2)

end
