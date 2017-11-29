function pC = probFasterGrid(estimateRef, probRef, estimateTest, probTest)

    intLB = 0; intUB = max(estimateRef(end), estimateTest(end));
    
    vRef  = intLB : 0.05 : intUB;
    vTest = intLB : 0.05 : intUB;
    
    [V1, V2] = meshgrid(vRef,vTest);
    
    valRef  = zeros(1, length(vRef));
    valTest = zeros(1, length(vTest));
    
    nonZeroIdx = vRef >= estimateRef(1) & vRef <= estimateRef(end);
    valRef(nonZeroIdx)  = interp1(estimateRef, probRef, vRef(nonZeroIdx));
    
    nonZeroIdx = vTest >= estimateTest(1) & vTest <= estimateTest(end);
    valTest(nonZeroIdx) = interp1(estimateTest, probTest, vTest(nonZeroIdx));

    jointVal = valTest' * valRef;
    jointVal(V1 > V2) = 0;
    
    pC = trapz(vTest, trapz(vRef, jointVal, 2));
    
end