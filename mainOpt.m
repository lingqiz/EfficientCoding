% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';

load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));

noiseLB = 1e-4; 
noiseUB = 0.3;
c0LB = 0.4;   c0UB = 1.5;  
c1LB = 0.01;  c1UB = 10; 
c2LB = 0.001; c2UB = 100; 

crstLevel = 7;
vlb = [c0LB c1LB c2LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB c2UB ones(1, crstLevel) * noiseUB];

% Optimization 
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1e-3;
opts.MaxFunEvals = 2000;

objFunc1 = @(para)costfuncWrapperPwr(subject1, para);
paraInit = [ones(1, 3), rand(1, 7) * 0.1];
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

objFunc2 = @(para)costfuncWrapperPwr(subject2, para);
paraInit = [ones(1, 3), rand(1, 7) * 0.1];
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);

objFunc3 = @(para)costfuncWrapperPwr(subject3, para);
paraInit = [ones(1, 3), rand(1, 7) * 0.1];
[paraSub3, fval3, ~, ~] = fminsearchbnd(objFunc3, paraInit, vlb, vub, opts);

objFunc4 = @(para)costfuncWrapperPwr(subject4, para);
paraInit = [ones(1, 3), rand(1, 7) * 0.1];
[paraSub4, fval4, ~, ~] = fminsearchbnd(objFunc4, paraInit, vlb, vub, opts);

objFunc5 = @(para)costfuncWrapperPwr(subject5, para);
paraInit = [ones(1, 3), rand(1, 7) * 0.1];
[paraSub5, fval5, ~, ~] = fminsearchbnd(objFunc5, paraInit, vlb, vub, opts);

save('fit_res.mat');
