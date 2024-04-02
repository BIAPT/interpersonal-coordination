% Paige Whitehead March 26, 2024

function result = compute_corr(A_data, B_data, window)

% Rank speed time series from A_data and B_data for Spearman correlations
s1 = tiedrank(A_data);
s2 = tiedrank(B_data);

% Initialize Spearman correlation matrix
scorz = zeros(length(s1)-(window-1),1);

% Calculate rolling window spearman correlations
for cori = 1:length(scorz)

    scorz(cori,1) = corr(s1((cori:(cori+(window-1))),1),s2((cori:(cori+(window-1))),1),'type','Spearman');

end

% Pad scorz
scorz_padded = [zeros(floor((length(s1)-length(scorz))/2),1); scorz; zeros(ceil((length(s1)-length(scorz))/2),1)];

% Save correlation data as output
result = scorz_padded;

end
