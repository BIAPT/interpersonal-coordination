function results = plot_corr_blockwise(data, pair, path)

% Get relevant fields from main data struct
hands   = strsplit(pair, "_");
A_hand  = hands{1};
B_hand  = hands{2};

% Get relevant fields from main data struct
A_speed = getfield(data, A_hand);
B_speed = getfield(data, B_hand);
corr    = getfield(data, pair);

% Variables
datalength  = length(corr);
blocklength = datalength/5;

% Normalize speed vectors from A_hand and B_hand for plotting
norm      = normalize([A_speed; B_speed], 'range', [0 1]); % normalizing between 0 and 1
normsplit = reshape(norm,[datalength,2]);
A_norm    = normsplit(:,1);
B_norm    = normsplit(:,2);

% Plot rolling window Spearman correlations per block
for blocki = 1:5

    start = ((blocki-1)*blocklength)+1;
    stop  = blocki*blocklength;

    f = figure;
    plot(data.time(start:stop), corr(start:stop),...
        data.time(start:stop), A_norm(start:stop), ...
        data.time(start:stop), B_norm(start:stop));
    xlabel('Time (minutes)')
    xtickformat('m:ss')
    xsecondarylabel('Visible','off')
    [t,s] = title(['Session ' data.session], ['Block ' num2str(blocki)]);
    set(gca,'ylim',[-0.9 1.3])
    legend({[num2str(data.window) '-second rolling window Spearman correlations'];['Normalized ' A_hand ' speed'];['Normalized ' B_hand ' speed']},'Location','northwest')
    f.Position = [100 100 2000 500];
    saveas(gcf, [path 'session' data.session '_speed_scorz_' A_hand '-' B_hand '_' num2str(data.window) 's-window_block' num2str(blocki) '.tiff'])

end

end
