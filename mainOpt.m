% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
% load(strcat(dataDir, 'SUB2.mat'));

noiseLB = 1e-4;
noiseUB = 1.2;

crstLevel = 7;
vlb = ones(1, crstLevel) * noiseLB;
vub = ones(1, crstLevel) * noiseUB;

noiseInit = 0.1 : 0.1 : 0.7;
objFunc1 = @(noisePara)costfuncWrapperFixedPrior(subject1, noisePara);
objFunc2 = @(noisePara)costfuncWrapperFixedPrior(subject2, noisePara);

% Optimization 
options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','interior-point','MaxIter',100);
[noiseSub1, fval1, exitflag1, output1] = fmincon(objFunc1, noiseInit, [], [], [], [], vlb, vub, [], options);

options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','interior-point','MaxIter',100);
[noiseSub2, fval2, exitflag2, output2] = fmincon(objFunc2, noiseInit, [], [], [], [], vlb, vub, [], options);

save FitResults;