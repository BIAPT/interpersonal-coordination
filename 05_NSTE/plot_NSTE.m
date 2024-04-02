% Source code: Dannie Fu January 27 2020
% Modified: Paige Whitehead March 26, 2024

% This script generates figures for NSTE and STE BA and AB
% The variables must be loaded into the workspace before running.

% ------------------------

clear;

% NOTE: path strings should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\05_NSTE\';
OUT_DIR = LOAD_DIR;

load([LOAD_DIR 'NSTE']);
load([LOAD_DIR 'NSTE_asym']);

% Select moment
moment = 33;
if moment > 28
    row = moment-1;
else
    row = moment;
end

% Plot NSTE A-B and B-A
f = figure; 
plot(NSTE(row).nste_time, NSTE(row).NSTE_BA, LineWidth = 1.5);
hold on
plot(NSTE(row).nste_time, NSTE(row).NSTE_AB, LineWidth = 1.5);
title(['Moment ' num2str(moment)], 'NSTE');                              
ylabel('NSTE');
xlabel('Time (minutes)');
xtickformat('m:ss')
xsecondarylabel('Visible','off')
ax = gca;
ax.FontSize = 14;
legend('NSTE B->A','NSTE A->B');
f.Position = [100 100 1000 700];
saveas(gcf, [OUT_DIR 'NSTE_moment' num2str(moment) '.tiff']) 

% Plot asymmetry
f = figure; 
plot(linspace(NSTE(row).nste_time(1), NSTE(row).nste_time(end), length(asym(row).asym_ave)), asym(row).asym_ave, LineWidth = 1.5);
title(['Moment ' num2str(moment)], ['Average Asymmetry A-B (' num2str(asym(row).asym_win_size) '-second window)']);
ylabel('STE');
xlabel('Time (minutes)');
xtickformat('m:ss')
xsecondarylabel('Visible','off')
ax = gca;
ax.FontSize = 14;
yline(0, '-', 'LineWidth', 1, 'Color', [0.9290 0.6940 0.1250], 'Alpha', 0.3)
f.Position = [100 100 1000 700];
saveas(gcf, [OUT_DIR 'asymmetry_moment' num2str(moment) '.tiff'])   
