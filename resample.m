function resampleData = resample(subjectData)

crtRef  = [0.075, 0.5];
vRef    = [0.5, 1, 2, 4, 8, 12];
crtTest = [0.05, 0.075, 0.1, 0.2, 0.4, 0.5, 0.8];
dataIdx = 1:size(subjectData, 2);

resampleData = zeros(size(subjectData));

for i = 1 : length(crtRef)
    refCrst = crtRef(i);
    for j = 1 : length(vRef)
        refV = vRef(j);
        for k = 1 : length(crtTest)
            testCrst = crtTest(k);
                        
            sampleIdx = dataIdx(subjectData(1, :) == refV ...
            & subjectData(2, :) == refCrst & subjectData(4, :) == testCrst);
            
            resampleIdx = datasample(sampleIdx, length(sampleIdx));
            resampleData(:, sampleIdx) = subjectData(:, resampleIdx);                        
        end
    end
end


end

