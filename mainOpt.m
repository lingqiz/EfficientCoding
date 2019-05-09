%% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));
load('./CombinedFit/combinedGauss.mat');

%% Gamma prior, setup
noiseLB = 1e-4; noiseUB = 10;
c0LB = 1e-8; c0UB = 10; c0Init = 2;
c1LB = 1e-8; c1UB = 1e3; c1Init = 3;

crstLevel = 7;
vlb = [c0LB c1LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB ones(1, crstLevel) * noiseUB];

% Optimization
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-3;
opts.TolFun = 1.e-3;
opts.MaxFunEvals = 5000;

%% Gamma prior, combined subject
combinedData = [subject1, subject2, subject3, subject4, subject5];
paraInit = [c0Init, c1Init, paraSub(4:end)];
objFunc = @(para)costfuncWrapperGamma(combinedData, para);
[paraSub, fval, ~, ~] = fminsearchbnd(objFunc, paraInit, vlb, vub, opts);

%% Gamma prior, individual subject
paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc1 = @(para)costfuncWrapperGamma(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc2 = @(para)costfuncWrapperGamma(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);

paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc3 = @(para)costfuncWrapperGamma(subject3, para);
[paraSub3, fval3, ~, ~] = fminsearchbnd(objFunc3, paraInit, vlb, vub, opts);

paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc4 = @(para)costfuncWrapperGamma(subject4, para);
[paraSub4, fval4, ~, ~] = fminsearchbnd(objFunc4, paraInit, vlb, vub, opts);

paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc5 = @(para)costfuncWrapperGamma(subject5, para);
[paraSub5, fval5, ~, ~] = fminsearchbnd(objFunc5, paraInit, vlb, vub, opts);

%% Gaussian prior, setup
noiseLB = 1e-4; noiseUB = 10;
c0LB = 0.1; c0UB = 30; c0Init = 5;

crstLevel = 7;
vlb = [c0LB  ones(1, crstLevel) * noiseLB];
vub = [c0UB  ones(1, crstLevel) * noiseUB];

% Optimization
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-3;
opts.TolFun = 1.e-3;
opts.MaxFunEvals = 5000;

%% Gaussian Prior, combined subject
combinedData = [subject1, subject2, subject3, subject4, subject5];
paraInit = [c0Init, paraSub(4:end)];
objFunc = @(para)costfuncWrapperGauss(combinedData, para);
[paraSub, fval, ~, ~] = fminsearchbnd(objFunc, paraInit, vlb, vub, opts);

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

combinedData = [subject1, subject2, subject3, subject4, subject5];
paraInit = [refValue, paraSub(4:end)];
objFunc = @(para)costfuncWrapperLinear(combinedData, para);
[paraSub, fval, ~, ~] = fminsearchbnd(objFunc, paraInit, vlb, vub, opts);
