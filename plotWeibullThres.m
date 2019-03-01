function line = plotWeibullThres(threshold, color)

vProb = [0.5, 1, 2, 4, 8, 12];
percentil   = [0.5, 0.975, 0.025];
allEstimate = zeros(3, length(vProb));

for i = 1:length(vProb)
    estimate = threshold(:, i);
    estimate = sort(estimate(~isnan(estimate)));
    for j = 1:3
        allEstimate(j, i) = estimate(floor(length(estimate)*percentil(j)));
    end
end

line = errorbar(log(vProb), allEstimate(1, :), ...
    allEstimate(1, :)-allEstimate(3, :), allEstimate(2, :)-allEstimate(1, :), '--o', 'Color', color);

end

