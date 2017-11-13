% Different Loss Function 
% Reproduce Kording & Wolpert, PNAS 2004

thetaLB = -10; thetaUB = 10;
domain = thetaLB : 0.001 : thetaUB;

mean = 0;
rho  = 0.3; 
prob = (1 - rho) * normpdf(domain, mean - 1.2, 1.2 * sqrt(2)) ...
    + rho * normpdf(domain, mean - 1.2 + 1.2 / rho, 1.2 * (1 + (1 / rho - 1) ^ 2) ^ 0.5);

[~, modeIdx] = max(prob);
mode = domain(modeIdx);

figure; hold on; grid on;
colors = get(gca,'colororder');
plot(domain, prob, 'LineWidth', 2);

lossFunc = @(estimate, domain, posterior, loss) ...
    trapz(domain, posterior .* loss(estimate, domain));    
l2Loss = @(estimate, domain, posterior) lossFunc(estimate, domain, posterior, ...
    @(x, y) (x - y) .^ 2);
ivtGaussLoss = @(estimate, domain, posterior, sigma) lossFunc(estimate, domain, posterior, ...
    @(x, y) -exp(-(x - y).^2 / (2 * sigma^2)) );
ivtGauss = @(x ,y, sigma) -exp(-(x - y).^2 / (2 * sigma^2));

options = optimoptions('fmincon','Display','off');
estl2 = fmincon(@(est) l2Loss(est, domain, prob), 0, [], [], [], [], thetaLB, thetaUB, [], options);
sigma = 1;
estGauss1 = fmincon(@(est) ...
    ivtGaussLoss(est, domain, prob, sigma), 0, [], [], [], [], thetaLB, thetaUB, [], options);
plot(domain, ivtGauss(0, domain, sigma) + 1, 'LineWidth', 2);
sigma = 2;
estGauss2 = fmincon(@(est) ...
    ivtGaussLoss(est, domain, prob, sigma), 0, [], [], [], [], thetaLB, thetaUB, [], options);
plot(domain, ivtGauss(0, domain, sigma) + 1, 'LineWidth', 2);
sigma = 3;
estGauss3 = fmincon(@(est) ...
    ivtGaussLoss(est, domain, prob, sigma), 0, [], [], [], [], thetaLB, thetaUB, [], options);
plot(domain, ivtGauss(0, domain, sigma) + 1, 'LineWidth', 2);

plot([mode, mode], ylim, '--', 'LineWidth', 2); 
plot([estl2, estl2], ylim, '--', 'LineWidth', 2);

plot([estGauss1, estGauss1], ylim, '--', 'Color', colors(2, :), 'LineWidth', 2);
plot([estGauss2, estGauss2], ylim, '--', 'Color', colors(3, :), 'LineWidth', 2);
plot([estGauss3, estGauss3], ylim, '--', 'Color', colors(4, :), 'LineWidth', 2);

title('Effect of Loss Function'); hold off;