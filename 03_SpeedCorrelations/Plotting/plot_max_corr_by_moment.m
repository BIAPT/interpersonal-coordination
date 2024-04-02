% Paige Whitehead March 26, 2024

% This  script:
% (1) plots the maximum correlation vector for each moment

% It uses the function plot_moment (ensure this function is in your path). 
% The function has 3 input arguments: 
% (1) a particular row from the master data struct (ie. a particular session's data), 
% (2) an index for the current moment, and 
% (3) the directory path to which plots will be saved

%% SETUP

clear;

% Set paths
% NOTE: path string should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\03_SpeedCorrelations\';
OUT_DIR = LOAD_DIR;

% Load master data struct
load([LOAD_DIR 'data.mat']);

% Compile list of moments for looping
moments = [data(1).moments, data(2).moments, data(3).moments, data(4).moments, data(5).moments]; % each moment is a cell in a row

% Loop through moments
for moment_i=1:length(moments)
    %% PLOT MOMENTS

    disp(strcat('Moment: ', moments(moment_i)));

    % Find session number
    for r=1:length(data)
        if find(strcmp(data(r).moments, moments(moment_i)))
            % Set session index
            session_idx = str2double(data(r).session) - 2;
        end
    end

    % Set moment index
    moment_idx = find(strcmp(data(session_idx).moments, moments(moment_i)));

    % Plot
    plot_moment(data(session_idx), moment_idx, OUT_DIR);

end

