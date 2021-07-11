%% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));
load('./CombinedFit/combinedGauss.mat');

%% Gaussian prior, setup
noiseLB = 1e-4; noiseUB = 10;
c0LB = 0.1; c0UB = 30; c0Init = 5;

crstLevel = 7;
vlb = [c0LB  ones(1, crstLevel) * noiseLB];
vub = [c0UB  ones(1, crstLevel) * noiseUB];
paraInit = [c0Init, paraSub(4:end)];

% Optimization
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-3;
opts.TolFun = 1.e-3;
opts.MaxFunEvals = 5000;

%% Gaussian prior, individual subject
objFunc1 = @(para)costfuncWrapperGauss(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

objFunc2 = @(para)costfuncWrapperGauss(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);

objFunc4 = @(para)costfuncWrapperGauss(subject4, para);
[paraSub4, fval4, ~, ~] = fminsearchbnd(objFunc4, paraInit, vlb, vub, opts);

objFunc5 = @(para)costfuncWrapperGauss(subject5, para);
[paraSub5, fval5, ~, ~] = fminsearchbnd(objFunc5, paraInit, vlb, vub, opts);
