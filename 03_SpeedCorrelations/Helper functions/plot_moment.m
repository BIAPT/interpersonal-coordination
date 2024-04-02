function results = plot_moment(data, moment_idx, path)

% Fixed variables
fs          = 60;
secs_to_pad = 5;
pad         = fs*secs_to_pad; % in frames

% Find start and end points
startcell = str2double(split(data.start(moment_idx), ':'));
if ((startcell(1)*60 + startcell(2))*fs - pad) < 0
    startframe = 1;
    xmin = data.time(startframe);         % Set lower x-axis boundary
    xbar1 = data.time(startframe + pad);  % Set lower moment boundary
else
    startframe = (startcell(1)*60 + startcell(2))*fs - pad;
    xmin = data.time(startframe);         % Set lower x-axis boundary
    xbar1 = data.time(startframe + pad);  % Set lower moment boundary
end

finishcell = str2double(split(data.finish(moment_idx), ':'));
if ((finishcell(1)*60 + finishcell(2))*fs + pad) > 54000
    finishframe = 54000;
    xmax = data.time(finishframe);        % Set upper x-axis boundary
    xbar2 = data.time(finishframe);       % Set upper moment boundary
else
    finishframe = (finishcell(1)*60 + finishcell(2))*fs + pad;
    xmax = data.time(finishframe);        % Set upper x-axis boundary
    xbar2 = data.time(finishframe - pad); % Set upper moment boundary
end


% Generate figure of moment
f = figure;
box on
hold on
set(gca,'ylim', [-1.1 1.1])
set(gca,'ytick', [-1 -0.5 0 0.5  1], 'LineWidth', 1,'FontSize', 12)
xlabel('Time (minutes)', 'FontSize',16)
ylabel('Maximum Correlation', 'FontSize',16)
f.Position = [200 50 1000 700]; 
patch([xbar1 xbar1, xbar2 xbar2], [-1.096 max(ylim) max(ylim) -1.096], [0 0.4470 0.7410], 'EdgeColor', 'none')
alpha(0.1)
yline(0, '-', 'LineWidth', 1, 'Color', [0.9290 0.6940 0.1250], 'Alpha', 0.3)
plot(data.time(startframe:finishframe), data.max_corr(startframe:finishframe), 'LineWidth', 2);
ax = gca;
ax.XAxis.Limits = [data.time(startframe) data.time(finishframe)];
ax.FontSize = 12;
xtickformat('m:ss')
xsecondarylabel('Visible','off')
[~,~] = title(['Moment' data.moments(moment_idx)], [num2str(data.window) '-second window']);
hold off
saveas(gcf, char(strcat(path, num2str(data.window), 's-win_moment', data.moments(moment_idx), '.tiff')))

results = f;

end