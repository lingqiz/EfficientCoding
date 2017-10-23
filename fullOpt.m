% Load Dataset, Initialization, Start Fitting Procedure
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));

noiseLB = 1e-4; noiseUB = 2.0;
c0LB = 0.4;   c0UB = 2;  c0Init = 1.6;
c1LB = 0.01;  c1UB = 10; c1Init = 0.87;
c2LB = 0.001; c2UB = 100; c2Init = 9.22;

crstLevel = 7;
vlb = [c0LB c1LB c2LB ones(1, crstLevel) * noiseLB];
vub = [c0UB c1UB c2UB ones(1, crstLevel) * noiseUB];

noiseInit = [1.2 1.0 0.6 0.5 0.4 0.3 0.2]; 
paraInit = [c0Init, c1Init, c2Init, noiseInit];
objFunc1 = @(para)costfuncWrapperPwr(subject1, para);
objFunc2 = @(para)costfuncWrapperPwr(subject2, para);

testPara = [1.8, 0.1673, 9.43, 1.42, 1.0584, 0.8704, 0.60452, 0.54482, 0.42878, 0.48189];
cost = objFunc1(testPara);

% % Optimization 
% options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','interior-point','MaxIter',100);
% [paraSub1, fval1, exitflag1, output1] = fmincon(objFunc1, paraInit, [], [], [], [], vlb, vub, [], options);
% 
% options = optimoptions('fmincon','Diagnostics','on','Display','iter','Algorithm','interior-point','MaxIter',100);
% [paraSub2, fval2, exitflag2, output2] = fmincon(objFunc2, paraInit, [], [], [], [], vlb, vub, [], options);
% 
% save FitResults;

