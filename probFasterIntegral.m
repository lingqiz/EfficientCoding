function [ pC ] = probFasterIntegral(estimateRef, probRef, estimateTest, probTest)
%PROBFASTER Probability of test stimuli seen faster

intLB = 0; intUB = max(estimateRef(end), estimateTest(end));
    
targetFunc = ...
    @(vTest, vRef)integrand(estimateRef, probRef, estimateTest, probTest, vTest, vRef);

% Double integral for area under ROC curve
pC = quad2d(targetFunc, intLB, intUB, intLB, @(x) x);
    
    function values = integrand(estimateRef, probRef, estimateTest, probTest, vTest, vRef)
        origDim = size(vRef);
        vRef = reshape(vRef, 1, []); vTest = reshape(vTest, 1, []);
        
        values = zeros(1, length(vRef));
        nonZeroIdx = (vRef > estimateRef(1) & vRef < estimateRef(end) ...
            & vTest > estimateTest(1) & vTest < estimateTest(end));
        
        [estimateRef, index] = unique(estimateRef);
        probRef = probRef(index);
        
        [estimateTest, index] = unique(estimateTest);
        probTest = probTest(index);
        
        values(nonZeroIdx) = interp1(estimateRef, probRef, vRef(nonZeroIdx)) ...
            .* interp1(estimateTest, probTest, vTest(nonZeroIdx));
        
        values = reshape(values, origDim);
    end

end

