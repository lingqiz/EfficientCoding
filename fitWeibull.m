dataDir = './NN2006/';
load(strcat(dataDir, 'SUB1.mat'));
load(strcat(dataDir, 'SUB2.mat'));

sumLL1 = weibullFit(subject1);
sumLL2 = weibullFit(subject2);


function sumLL = weibullFit(subjectData)
sumLL = 0; 

vlb = [0 0]; vub = [Inf, Inf];
crtRef  = [0.075, 0.5];
vRef    = [0.5, 1, 2, 4, 8, 12];
crtTest = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];

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
            [~, fval, ~, ~] = fmincon(objFunc, 1 + rand(1, 2), [], [], [], [], vlb, vub, [], options);
            
            sumLL = sumLL + fval;
        end
    end
end
    
end