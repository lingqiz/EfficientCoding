%% individual fit
dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));
load(strcat(dataDir, 'SUB3.mat'));
load(strcat(dataDir, 'SUB4.mat'));
load(strcat(dataDir, 'SUB5.mat'));

[LL1, weibullFit1] = weibullFit(subject1);
[LL2, weibullFit2] = weibullFit(subject2);
[LL3, weibullFit3] = weibullFit(subject3);
[LL4, weibullFit4] = weibullFit(subject4);
[LL5, weibullFit5] = weibullFit(subject5);

%% combined fit
combined = [subject1, subject2, subject3, subject4, subject5];
[LL, weibullFitCombined] = weibullFit(combined);

%% loss function, optimization
function [sumLL, fitResults] = weibullFit(subjectData)
sumLL = 0; 

vlb = [0 0]; vub = [Inf, Inf];
crtRef  = [0.075, 0.5];
vRef    = [0.5, 1, 2, 4, 8, 12];
crtTest = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];

fitResults = zeros(length(crtRef), length(vRef), length(crtTest), 2);

for i = 1 : length(crtRef)
    refCrst = crtRef(i);
    for j = 1 : length(vRef)
        refV = vRef(j);
        for k = 1 : length(crtTest)
            testCrst = crtTest(k);
            
            data = subjectData([3, 9], subjectData(1, :) == refV ...
            & subjectData(2, :) == refCrst & subjectData(4, :) == testCrst);
                                
            objFunc = @(para) weibullCstfunc(data(1, :), data(2, :), para);
            options = optimoptions('fmincon','Diagnostics','off','Display',...
            'iter','Algorithm','interior-point','MaxIter',200);
            [fitPara, fval, ~, ~] = fmincon(objFunc, [1, 1], [], [], [], [], vlb, vub, [], options);            
            
            fitResults(i, j, k, :) = fitPara;
            sumLL = sumLL + fval; 
        end
    end
end
   
end