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
opts.TolX = 1.e-5;
opts.TolFun = 1.e-5;
opts.MaxFunEvals = 2500;

%% Gamma prior, individual subject
paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc1 = @(para)costfuncWrapperGamma(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc2 = @(para)costfuncWrapperGamma(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);

paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc4 = @(para)costfuncWrapperGamma(subject4, para);
[paraSub4, fval4, ~, ~] = fminsearchbnd(objFunc4, paraInit, vlb, vub, opts);

paraInit = [c0Init, c1Init, rand(1, crstLevel)+0.1];
objFunc5 = @(para)costfuncWrapperGamma(subject5, para);
[paraSub5, fval5, ~, ~] = fminsearchbnd(objFunc5, paraInit, vlb, vub, opts);
