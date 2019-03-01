% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));

noiseLB = 1e-8; noiseUB = 10;
c0LB = 0.1;   c0UB = 10;   c0Init = 1;
c1LB = 1e-8;  c1UB = 100;  c1Init = 0.33;
c2LB = 1e-8;  c2UB = 0.01; c2Init = 1e-8;

crstLevel = 7;
vlb = [c0LB c1LB c2LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB c2UB ones(1, crstLevel) * noiseUB];

% Optimization 
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.MaxFunEvals = 2000;

noiseInit = rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc1 = @(para)costfuncWrapperPwr(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

noiseInit = rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc2 = @(para)costfuncWrapperPwr(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);

noiseInit = rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc3 = @(para)costfuncWrapperPwr(subject3, para);
[paraSub3, fval3, ~, ~] = fminsearchbnd(objFunc3, paraInit, vlb, vub, opts);

noiseInit = rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc4 = @(para)costfuncWrapperPwr(subject4, para);
[paraSub4, fval4, ~, ~] = fminsearchbnd(objFunc4, paraInit, vlb, vub, opts);

noiseInit = rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc5 = @(para)costfuncWrapperPwr(subject5, para);
[paraSub5, fval5, ~, ~] = fminsearchbnd(objFunc5, paraInit, vlb, vub, opts);
