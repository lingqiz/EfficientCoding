function line = plotWeibullThres(thData, threshold, color, relative, sd)

vProb = [0.5, 1, 2, 4, 8, 12];
if sd
    percentil   = [0.5, 0.841, 0.159];
else
    percentil   = [0.5, 0.975, 0.025];
end


allEstimate = zeros(3, length(vProb));

for i = 1:length(vProb)
    estimate = threshold(:, i);
    estimate = sort(estimate(~isnan(estimate)));
    for j = 1:3
        allEstimate(j, i) = estimate(floor(length(estimate)*percentil(j)));
    end
    allEstimate(1, i) = thData(i);
end

if relative
    line = errorbar(log(vProb), exp(allEstimate(1, :)) ./ vProb, ...
        (exp(allEstimate(1, :))-exp(allEstimate(3, :))) ./ vProb, (exp(allEstimate(2, :))-exp(allEstimate(1, :))) ./ vProb, ...
        '--o', 'Color', color, 'LineWidth', 1.5);
else
    line = errorbar(log(vProb), allEstimate(1, :), ...
        allEstimate(1, :)-allEstimate(3, :), allEstimate(2, :)-allEstimate(1, :), '--o', 'Color', color, 'LineWidth', 1.5);
end

end

