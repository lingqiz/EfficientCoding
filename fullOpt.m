% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));

noiseLB = 1e-4; noiseUB = 1.2;
c0LB = 0.4;   c0UB = 3;   c0Init = 0.93;
c1LB = 0.01;  c1UB = 100; c1Init = 1;
c2LB = 0.001; c2UB = 100; c2Init = 0.1;

crstLevel = 7;
vlb = [c0LB c1LB c2LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB c2UB ones(1, crstLevel) * noiseUB];

noiseInit = 0.1 : 0.1 : 0.7; paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc1 = @(para)costfuncWrapperPwr(subject1, para);
objFunc2 = @(para)costfuncWrapperPwr(subject2, para);

% Optimization 
options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','interior-point','MaxIter',100);
[noiseSub1, fval1, exitflag1, output1] = fmincon(objFunc1, paraInit, [], [], [], [], vlb, vub, [], options);

options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','interior-point','MaxIter',100);
[noiseSub2, fval2, exitflag2, output2] = fmincon(objFunc2, paraInit, [], [], [], [], vlb, vub, [], options);

save FitResults;