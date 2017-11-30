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

c0Init = 0.5779; c1Init = 2.6546; c2Init = 0.1720;
noiseInit = [0.0509, 0.0410, 0.0379, 0.0239, 0.0231, 0.0188, 0.0178];
paraInit = [c0Init, c1Init, c2Init, noiseInit];

objFunc1 = @(para)costfuncWrapperPwr(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

c0Init = 0.7340; c1Init = 3.7791; c2Init = 0.0011;
noiseInit = [0.0638, 0.0496, 0.0424, 0.0272, 0.0198, 0.0148, 0.0085];
paraInit = [c0Init, c1Init, c2Init, noiseInit];

objFunc2 = @(para)costfuncWrapperPwr(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);
