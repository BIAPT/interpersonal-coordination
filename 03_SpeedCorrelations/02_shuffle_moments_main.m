% Paige Whitehead March 26, 2024

% This script:
% (1) shuffles the data within each moment by slicing the data at a random 
% breakpoint and flipping the data about that breakpoint, and 
% (2) computes a correlation significance threshold for each moment based 
% on 1000 iterations of slicing 

%% SET PROPERTIES FOR SOCKEYE (UBC SUPERCOMPUTER)

c = parcluster;
c.AdditionalProperties.AllocationCode = 'st-toddrebe-1';
c.AdditionalProperties.EmailAddress = 'ppaigew@student.ubc.ca';
c.AdditionalProperties.JobPlacement = 'free';
c.AdditionalProperties.RequireExclusiveNode = false;
c.AdditionalProperties.MemPerCPU = '4000mb';
c.AdditionalProperties.NumNodes = '4';
c.AdditionalProperties.WallTime = '05:00:00';


%% SETUP

clear; 

% Set paths
% NOTE: path strings should end with '\'
LOAD_DIR = 'ppaigew@sockeye.arc.ubc.ca:/scratch/st-toddrebe-1/ppaigew/';
OUT_DIR  = LOAD_DIR';

% Load master data struct
load([LOAD_DIR 'data.mat']);

% Specify each moment's timestamps
data(1).moments = split(cellstr(sprintf('%d ', 1:9)), ' ').';
data(1).start   = {'2:20', '3:06', '3:31', '4:17', '4:35', '5:42', '6:14', '7:31', '13:33'};
data(1).finish  = {'3:05', '3:24', '4:05', '4:33', '5:02', '5:56', '6:44', '8:30', '13:56'};

data(2).moments = split(cellstr(sprintf('%d ', 10:27)), ' ').';
data(2).start   = {'1:32', '2:53', '3:54', '5:41', '6:14', '8:20', '9:14', '9:46', '10:09', '10:18', '10:36', '11:02', '11:20', '12:06', '12:32', '13:27', '13:58', '14:33'};
data(2).finish  = {'2:11', '3:50', '5:40', '6:00', '6:27', '8:59', '9:33', '10:06', '10:18', '10:30', '10:54', '11:20', '11:34', '12:22', '13:05', '13:50', '14:26', '15:00'};

data(3).moments = {'29'};
data(3).start   = {'5:27'};
data(3).finish  = {'6:00'};

data(4).moments = split(cellstr(sprintf('%d ', 30:32)), ' ').';
data(4).start   = {'3:06', '8:47', '12:15'};
data(4).finish  = {'3:40', '9:25', '12:47'};

data(5).moments = split(cellstr(sprintf('%d ', 33:37)), ' ').';
data(5).start   = {'4:18', '4:36', '5:50', '9:55', '10:50'};
data(5).finish  = {'4:29', '5:13', '6:27', '10:25', '11:35'};

% Compile list of moments for looping
moments = [data(1).moments, data(2).moments, data(3).moments, data(4).moments, data(5).moments];

% Set sampling frequency
fs = 60;

% Loop through moments
for moment_i=1:length(moments)
    %% SHUFFLE SPEED

    disp(strcat('Moment: ', moments(moment_i)));

    % Find session number
    for r=1:length(data)
        if find(strcmp(data(r).moments, moments(moment_i)))
            session_idx = str2double(data(r).session) - 2;
        end
    end

    moment_idx = find(strcmp(data(session_idx).moments, moments(moment_i)));

    % Find start and end points
    startcell = str2double(split(data(session_idx).start(moment_idx), ':'));
    startframe = (startcell(1)*60 + startcell(2))*fs;

    finishcell = str2double(split(data(session_idx).finish(moment_idx), ':'));
    finishframe = (finishcell(1)*60 + finishcell(2))*fs;

    num_iter = 1000;                           % # layers (depth) 
    num_rows = length(startframe:finishframe); % datalength
    num_cols = 4;                              % hand pairs

    % Pre-allocate 3-D array
    corr_shuffle = zeros(num_iter, num_rows, num_cols);

    parfor hand_pair = 1:num_cols

        for iter_i = 1:num_iter
            disp(['Iteration ', num2str(iter_i)]);

            ALH_data = data(session_idx).ALH(startframe:finishframe);
            ALH_breakpoint = randsample(1:numel(ALH_data), 1);
            ALH1 = ALH_data(1:ALH_breakpoint);
            ALH2 = ALH_data(ALH_breakpoint+1:end);
            ALH_shuffle = [ALH2; ALH1];

            ARH_data = data(session_idx).ARH(startframe:finishframe);
            ARH_breakpoint = randsample(1:numel(ARH_data), 1);
            ARH1 = ARH_data(1:ARH_breakpoint);
            ARH2 = ARH_data(ARH_breakpoint+1:end);
            ARH_shuffle = [ARH2; ARH1];

            if hand_pair == 1
                corr_shuffle(iter_i,:, hand_pair) = compute_corr(ALH_shuffle, data(session_idx).BLH(startframe:finishframe), data(session_idx).window*fs)';
            elseif hand_pair == 2
                corr_shuffle(iter_i,:, hand_pair) = compute_corr(ALH_shuffle, data(session_idx).BRH(startframe:finishframe), data(session_idx).window*fs)';
            elseif hand_pair == 3
                corr_shuffle(iter_i,:, hand_pair) = compute_corr(ARH_shuffle, data(session_idx).BLH(startframe:finishframe), data(session_idx).window*fs)';
            elseif hand_pair == 4
                corr_shuffle(iter_i,:, hand_pair) = compute_corr(ARH_shuffle, data(session_idx).BRH(startframe:finishframe), data(session_idx).window*fs)';

            end
        end
    end

    save(strcat(OUT_DIR, "session", data(session_idx).session, "_moment", data(session_idx).moments(moment_idx), "_shuffled_corrs.mat"), "corr_shuffle");


    %% COMPUTE 95TH PERCENTILE

    corr_dist = zeros(size(corr_shuffle, 1), size(corr_shuffle, 2));

    for frame_i = 1:size(corr_shuffle, 2)
        moment_source = data(session_idx).speed_source(startframe:finishframe);
        source_i = moment_source(frame_i,1);
        if strcmp(source_i, 'ALH_BLH')
            corr_dist(:, frame_i) = corr_shuffle(:, frame_i, 1);
        elseif strcmp(source_i, 'ALH_BRH')
            corr_dist(:, frame_i) = corr_shuffle(:, frame_i, 2);
        elseif strcmp(source_i, 'ARH_BLH')
            corr_dist(:, frame_i) = corr_shuffle(:, frame_i, 3);
        elseif strcmp(source_i, 'ARH_BRH')
            corr_dist(:, frame_i) = corr_shuffle(:, frame_i, 4);
        end
    end

    data(session_idx).significance_threshold(moment_idx) = prctile(corr_dist, 95, "all");

end
 
