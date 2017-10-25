function [ negLogLL ] = weibullCstfunc(x, r, para)

pCorrect = wblcdf(x, para(1), para(2));
probRes = pCorrect .* r + (1 - pCorrect) .* (1 - r);

zeroThreshold = 1e-5;
probRes(probRes == 0) = zeroThreshold;

logll = sum(log(probRes));
negLogLL = -logll;

end

