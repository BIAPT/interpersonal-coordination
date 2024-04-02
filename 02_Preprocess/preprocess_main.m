% Paige Whitehead March 26, 2024

% This script preprocesses raw speed vectors in three steps: 
% (1) it removes outliers over a 1-sec window (any value >3 local SDs away from the local mean), 
% (2) it linearly interpolates missing values, and 
% (3) it smoothes the resulting speed vectors with a 0.5-sec window moving average filter.

%% SETUP

clear; 

% Set session number variable
session = '07';

% Set paths
% NOTE: path strings should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\01_CalculateSpeed\';
OUT_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\02_Preprocess\';

% Import data
data = table2array(readtable([LOAD_DIR 'session' session '_data.csv']));

% Add extra row
data = [data; data(length(data),:)]; % computing speed leads to n-1 values (ie. 53999), so duplicate last row to get an even number (ie. 54000)


%% 1. REMOVE OUTLIERS

% Visually inspect for outliers
plot(data)

% Select each speed vector (specify column # that matches commented description) 
ALH = data(:,1); % participant "A", left hand
ARH = data(:,2); % participant "A", right hand
BLH = data(:,3); % participant "B", left hand
BRH = data(:,4); % participant "B", right hand

% Set outlier detection window size
window = 60; % 60 frames = 1 second

NaN_before = sum(isnan([ALH;ARH;BLH;BRH])); % # of NaNs (across all vectors) before

% Replace outliers with NaNs
ALH(isoutlier(ALH, 'movmean', window)) = NaN; 
ARH(isoutlier(ARH, 'movmean', window)) = NaN;
BLH(isoutlier(BLH, 'movmean', window)) = NaN;
BRH(isoutlier(BRH, 'movmean', window)) = NaN;

NaN_after = sum(isnan([ALH;ARH;BLH;BRH])); % # of NaNs (across all vectors) after

prop_NaN = (NaN_after-NaN_before)/length([ALH;ARH;BLH;BRH]); % proportion of NaNs in data

% Check outlier removal
plot(ALH)
hold on
plot(ARH)
plot(BLH)
plot(BRH)
hold off


%% 2. INTERPOLATE DATA

ALH_interpolated = interpolate(ALH);
ARH_interpolated = interpolate(ARH);
BLH_interpolated = interpolate(BLH);
BRH_interpolated = interpolate(BRH);


%% 3. SMOOTH DATA

% Set smoothing window size
span = 30; % 30 frames = 0.5 seconds

% Smooth interpolated speed vectors
ALH_smoothed = smooth(ALH_interpolated, span);
ARH_smoothed = smooth(ARH_interpolated, span);
BLH_smoothed = smooth(BLH_interpolated, span);
BRH_smoothed = smooth(BRH_interpolated, span);

% Combine smoothed speed vectors
smoothed_matrix = [ALH_smoothed, ARH_smoothed, BLH_smoothed, BRH_smoothed];

% Save smoothed speed vector matrix as csv
writematrix(smoothed_matrix, [OUT_DIR 'session' session '_data_preprocessed.csv']);


% % Check smoothing
% for blocki = 1:5 % Plot smoothed data against input data per block
% 
%     blocklength = 10800;
%     time = linspace(0, 900, length(ALH)); % to be used for x-axis (time)
% 
%     start = ((blocki-1)*blocklength)+1;
%     stop  = blocki*blocklength;
% 
%     f = figure;
%     plot(time(start:stop), ALH(start:stop));
%     hold on
%     plot(time(start:stop), ALH_smoothed(start:stop))
%     xlabel('Time (seconds)')
%     legend('Input data', 'Smoothed')
%     f.Position = [100 100 2000 500];
%     hold off
% 
% end

