% Paige Whitehead March 26, 2024

% This script converts x and y bodypart coordinates outputted by DeepLabCut
% into speed time series (unit: pixels/frame). 

%% SETUP

clear; 

% Set paths
% NOTE: path strings should end with '\'
LOAD_DIR = 'E:\PSM_Data\Data\session07_11-26-2022\Extracted data\';
OUT_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\01_CalculateSpeed\';

% Set session number variable
session = '07';

% Import raw coordinate data
data = table2array(readtable([LOAD_DIR  'session' session '_improvisationDLC_resnet101_model_v2Feb9shuffle1_100000_el_filtered']));

% Select A's left hand coordinate data
ALH_x = data(:,2);
ALH_y = data(:,3);

% Select A's right hand coordinate data
ARH_x = data(:,20);
ARH_y = data(:,21);

% Select B's left hand coordinate data
BLH_x = data(:,23);
BLH_y = data(:,24);

% Select B's right hand coordinate data
BRH_x = data(:,41);
BRH_y = data(:,42);

% Set length of speed vector to be computed
speed_length = 53999; % 53999 because some videos are exactly 54000 frames and speed can be max n-1 frames


%% COMPUTE SPEED

% Compute speed vector for each hand (unit: pixels/frame)
ALH = speed(ALH_x, ALH_y, speed_length);
ARH = speed(ARH_x, ARH_y, speed_length);
BLH = speed(BLH_x, BLH_y, speed_length);
BRH = speed(BRH_x, BRH_y, speed_length);

% Combine speed vectors
speed_matrix = [ALH, ARH, BLH, BRH];

% Save speed vector matrix as csv
writematrix(speed_matrix, [OUT_DIR 'session' session '_data.csv']);

