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

paraSub3(4:end) = paraSub3(4:end)*0.5;
costfuncWrapperPwr(subject3, paraSub3)

timeit(@() costfuncWrapperPwr(subject4, paraSub4))
