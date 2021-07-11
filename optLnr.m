%% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));
load('./CombinedFit/combinedGauss.mat');

%% Log linear prior, setup
c0 = paraSub(1); c1 = paraSub(2); c2 = paraSub(3);

domain    = -100 : 0.01 : 100;
priorUnm  = 1.0 ./ ((abs(domain) .^ c0) + c1) + c2;
nrmConst  = 1.0 ./ (trapz(domain, priorUnm));
priorPwrlaw = @(support) (1.0 ./ ((abs(support) .^ c0) + c1) + c2) * nrmConst;

nPoints = 20;
noiseLB = 1e-4; noiseUB = 10;
probLB  = -10;  probUB = 1; 

crstLevel = 7;
vlb = [ones(1, nPoints) * probLB, ones(1, crstLevel) * noiseLB];
vub = [ones(1, nPoints) * probUB, ones(1, crstLevel) * noiseUB];

refLB  = log(0.1);
refUB  = log(100);
delta  = (refUB - refLB) / (nPoints - 1);
refPoint = refLB : delta : refUB;
refValue = log(priorPwrlaw(exp(refPoint)));

%% Log linear prior, combined subject, fminsearch
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-3;
opts.TolFun = 1.e-3;
opts.MaxFunEvals = 5000;

paraInit = [refValue, paraSub(4:end)];

objFunc1 = @(para)costfuncWrapperLinear(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

objFunc2 = @(para)costfuncWrapperLinear(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);

objFunc4 = @(para)costfuncWrapperLinear(subject4, para);
[paraSub4, fval4, ~, ~] = fminsearchbnd(objFunc4, paraInit, vlb, vub, opts);

objFunc5 = @(para)costfuncWrapperLinear(subject5, para);
[paraSub5, fval5, ~, ~] = fminsearchbnd(objFunc5, paraInit, vlb, vub, opts);
