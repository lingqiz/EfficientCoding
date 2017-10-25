dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));

[LL1Sub1, LL2Sub1] = weibullFit(subject1);
[LL1Sub2, LL2Sub2] = weibullFit(subject2);


function [sumLL1, sumLL2] = weibullFit(subjectData)
sumLL1 = 0; 
sumLL2 = 0;

vlb = [0 0]; vub = [Inf, Inf];
crtRef  = [0.075, 0.5];
vRef    = [0.5, 1, 2, 4, 8, 12];
crtTest = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];

opts = optimset('fminsearch'); opts.Display = 'iter';
opts.TolX = 1.e-8; opts.MaxFunEvals = 2000;

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
            [~, fval1, ~, ~] = fmincon(objFunc, 2 + 0.5 * rand(1, 2), [], [], [], [], vlb, vub, [], options);            
            [~, fval2, ~, ~] = fminsearchbnd(objFunc, 2 + 0.5 * rand(1, 2), vlb, vub, opts);
            
            sumLL1 = sumLL1 + fval1; sumLL2 = sumLL2 + fval2;
        end
    end
end
    
end