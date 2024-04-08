% Paige Whitehead March 26, 2024

% This script: 
% (1) computes rolling-window Spearman correlations between two time series, and
% (2) computes a maximum correlation vector from the resulting correlation vectors.

% It uses the function compute_corr (ensure this function is in your path).
% The function has 3 input arguments: 
% (1) speed data from one source, 
% (2) speed data from a second source, and 
% (3) a sliding window size in frames 

%% SETUP 

clear; 

% Set session number variable
session = '03';

% Set paths
% NOTE: path strings should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\02_Preprocess\';
OUT_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\03_SpeedCorrelations\';

% Import speed data
speed_data = table2array(readtable([LOAD_DIR 'session' session '_data_preprocessed.csv']));

% Session index (automatically set based on session number)
session_idx = str2double(session) - 2; % Subtract 2 because we are not analyzing data from sessions 1 or 2 (did not collect subjective reports)

% Load master data struct (stores data from all sessions)
load([OUT_DIR 'data.mat']);

% Set window size 
fs           = 60;
win_size_sec = 5; % window size in seconds
window       = fs*win_size_sec;


%% FORMAT DATA

% Create time vector
t1       = datetime(2013,11,1,0,0,0,0);
t2       = datetime(2013,11,1,0,15,0,0);
t        = t1:seconds(1/60):t2;
t.Format = 'mm:ss.SSS';
t        = t(2:end); % remove first value (t = 0)

% Create main data struct
data(session_idx).frames  = (1:length(speed_data)).';
data(session_idx).time    = t;
data(session_idx).session = session;
data(session_idx).window  = win_size_sec;
data(session_idx).ALH     = speed_data(:,1);
data(session_idx).ARH     = speed_data(:,2);
data(session_idx).BLH     = speed_data(:,3);
data(session_idx).BRH     = speed_data(:,4);


%% COMPUTE CORRELATIONS

data(session_idx).ALH_BLH = compute_corr(data(session_idx).ALH, data(session_idx).BLH, window);
data(session_idx).ALH_BRH = compute_corr(data(session_idx).ALH, data(session_idx).BRH, window);
data(session_idx).ARH_BLH = compute_corr(data(session_idx).ARH, data(session_idx).BLH, window);
data(session_idx).ARH_BRH = compute_corr(data(session_idx).ARH, data(session_idx).BRH, window);


%% MAXIMUM CORRELATION ALGORITHM

% Combine correlation column vectors into matrix 
corr_data = [data(session_idx).ALH_BLH, data(session_idx).ALH_BRH, data(session_idx).ARH_BLH, data(session_idx).ARH_BRH];

% Initialize new fields in main data struct
data(session_idx).max_corr     = NaN(length(corr_data),1);
data(session_idx).speedA       = NaN(length(corr_data),1);
data(session_idx).speedB       = NaN(length(corr_data),1);
data(session_idx).speed_source = strings(length(corr_data),1);

% Compute maximum correlation and save data to fields max_corr, speedA, speedB, and speed_source
for i = 1:length(corr_data)
    [data(session_idx).max_corr(i), maxLoc] = max(corr_data(i,:), [], 2);
    if maxLoc == 1 
        data(session_idx).speedA(i) = data(session_idx).ALH(i);
        data(session_idx).speedB(i) = data(session_idx).BLH(i);
        data(session_idx).speed_source(i) = 'ALH_BLH';
    elseif maxLoc == 2
        data(session_idx).speedA(i) = data(session_idx).ALH(i);
        data(session_idx).speedB(i) = data(session_idx).BRH(i);
        data(session_idx).speed_source(i) = 'ALH_BRH';
    elseif maxLoc == 3
        data(session_idx).speedA(i) = data(session_idx).ARH(i);
        data(session_idx).speedB(i) = data(session_idx).BLH(i);
        data(session_idx).speed_source(i) = 'ARH_BLH';
    elseif maxLoc == 4
        data(session_idx).speedA(i) = data(session_idx).ARH(i);
        data(session_idx).speedB(i) = data(session_idx).BRH(i);
        data(session_idx).speed_source(i) = 'ARH_BRH';
    end
end

% Save data struct as Matlab variable
save([OUT_DIR 'data.mat'], 'data');

