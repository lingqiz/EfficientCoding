% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));

noiseLB = 1e-4; noiseUB = 0.1;
c0LB = 0.4;   c0UB = 1.2;  
c1LB = 0.01;  c1UB = 10; 
c2LB = 0.001; c2UB = 100; 

crstLevel = 7;
vlb = [c0LB c1LB c2LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB c2UB ones(1, crstLevel) * noiseUB];

% Optimization 
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-6;
opts.MaxFunEvals = 2000;

c0Init = 0.6076; c1Init = 3.038; c2Init = 0.033;
noiseInit = [0.049, 0.0338, 0.0326, 0.0218, 0.0222, 0.0180, 0.0132];
paraInit = [c0Init, c1Init, c2Init, noiseInit];

objFunc1 = @(para)costfuncWrapperPwr(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

c0Init = 0.7340; c1Init = 3.7791; c2Init = 0.0011;
noiseInit = [0.0675, 0.0525, 0.0449, 0.0288, 0.0210, 0.0156, 0.0090];
paraInit = [c0Init, c1Init, c2Init, noiseInit];

objFunc2 = @(para)costfuncWrapperPwr(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);
