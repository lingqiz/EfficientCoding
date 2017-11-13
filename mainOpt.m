% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));

noiseLB = 1e-4; noiseUB = 3;
c0LB = 0.4;   c0UB = 3;  c0Init = 1;
c1LB = 0.01;  c1UB = 10; c1Init = 1;
c2LB = 0.001; c2UB = 100; c2Init = 0.3;

crstLevel = 7;
vlb = [c0LB c1LB c2LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB c2UB ones(1, crstLevel) * noiseUB];

noiseInit = rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc1 = @(para)costfuncWrapperPwr(subject1, para);

options = optimoptions('particleswarm', 'Display', 'iter');
[paraSub1PS, fval1PS, ~] = particleswarm(objFunc1, length(paraInit), vlb, vub, options);

noiseInit = 0.5 + rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc2 = @(para)costfuncWrapperPwr(subject2, para);

options = optimoptions('particleswarm', 'Display', 'iter');
[paraSub2PS, fval2PS, ~] = particleswarm(objFunc2, length(paraInit), vlb, vub, options);

% Optimization 
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-6;
opts.MaxFunEvals = 2000;

noiseInit = rand(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc1 = @(para)costfuncWrapperPwr(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

noiseInit = 0.5 + and(1, crstLevel);
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc2 = @(para)costfuncWrapperPwr(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);
