%% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));
load('./GaussFit/gauss_final_2.mat');

%% Log linear prior, combined subject, fminsearch
opts = optimset('fminsearch');
opts.Display = 'iter';
opts.TolX = 1.e-5;
opts.TolFun = 1.e-5;
opts.MaxFunEvals = 2500;

%% Log linear prior 1
c0 = paraSub1(1); c1 = paraSub1(2); c2 = paraSub1(3);

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

paraInit = [refValue, paraSub1(4:end)];

objFunc1 = @(para)costfuncWrapperLinear(subject1, para);
[paraSub1, fval1, ~, ~] = fminsearchbnd(objFunc1, paraInit, vlb, vub, opts);

%% Log linear prior 1
c0 = paraSub2(1); c1 = paraSub2(2); c2 = paraSub2(3);

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

paraInit = [refValue, paraSub2(4:end)];

objFunc2 = @(para)costfuncWrapperLinear(subject2, para);
[paraSub2, fval2, ~, ~] = fminsearchbnd(objFunc2, paraInit, vlb, vub, opts);

%% Log linear prior 1
c0 = paraSub4(1); c1 = paraSub4(2); c2 = paraSub4(3);

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

paraInit = [refValue, paraSub4(4:end)];

objFunc4 = @(para)costfuncWrapperLinear(subject4, para);
[paraSub4, fval4, ~, ~] = fminsearchbnd(objFunc4, paraInit, vlb, vub, opts);

%% Log linear prior 1
c0 = paraSub5(1); c1 = paraSub5(2); c2 = paraSub5(3);

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

paraInit = [refValue, paraSub5(4:end)];

objFunc5 = @(para)costfuncWrapperLinear(subject5, para);
[paraSub5, fval5, ~, ~] = fminsearchbnd(objFunc5, paraInit, vlb, vub, opts);
