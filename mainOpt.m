% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));

noiseLB = 1e-4; noiseUB = 2.0;
c0LB = 0.4;   c0UB = 2;  c0Init = 1.2;
c1LB = 0.01;  c1UB = 10; c1Init = 0.2;
c2LB = 0.001; c2UB = 100; c2Init = 9;

crstLevel = 7;
vlb = [c0LB c1LB c2LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB c2UB ones(1, crstLevel) * noiseUB];

noiseInit = [1.1 0.9 0.8 0.6 0.5 0.4 0.3]; 
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc1 = @(para)costfuncWrapperPwr(subject1, para);

% Optimization 
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-12;
opts.MaxFunEvals = 1000;

[paraResSub1, fval1, exitflag1, output1] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

% objFunc2 = @(para)costfuncWrapperPwr(subject2, para);
% options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','interior-point','MaxIter',100);
% [paraSub2, fval2, exitflag2, output2] = fmincon(objFunc2, paraInit, [], [], [], [], vlb, vub, [], options);

save FitResults;

