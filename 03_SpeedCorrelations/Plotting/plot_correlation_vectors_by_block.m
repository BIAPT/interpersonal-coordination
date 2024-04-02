% Paige Whitehead March 26, 2024

% This script:
% (1) plots correlation vectors by block

% It uses the function plot_corr_blockwise (ensure this function is in your path).
% The function has 3 input arguments: 
% (1) a particular row from the master data struct (ie. a particular session's data), 
% (2) the name of the hand pair to be plotted, and 
% (3) the directory path to which plots will be saved

%% SETUP

clear; 

% Set session number variable
session = '07';

% Set paths
% NOTE: path string should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\03_SpeedCorrelations\';
OUT_DIR = LOAD_DIR;

% Session index
session_idx = str2double(session) - 2; % Subtract 2 because we are not analyzing data from sessions 1 or 2 (did not collect subjective reports)

% Load master data struct
load([LOAD_DIR 'data.mat']);


%% PLOT CORRELATIONS

plot_corr_blockwise(data(session_idx), 'ALH_BLH', OUT_DIR)
plot_corr_blockwise(data(session_idx), 'ALH_BRH', OUT_DIR)
plot_corr_blockwise(data(session_idx), 'ARH_BLH', OUT_DIR)
plot_corr_blockwise(data(session_idx), 'ARH_BRH', OUT_DIR)

