% Source code: Dannie Fu June 29 2020
% Modified: Paige Whitehead March 26, 2024

% This script computes the observed NSTE and the shuffled NSTE.

% Need to specify:
%   LOAD_DIR, OUT_DIR
%   moments  - all moments within the sessions
%   "NSTE Input params" section

% Note: Time shift test is not implemented. Only permutation test is
% implemented
% ------------------------

clear;

% NOTE: path strings should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\04_Classification\';
OUT_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\05_NSTE\';

moments = [split(cellstr(sprintf('%d ',1:27)),' '); split(cellstr(sprintf('%d ',29:37)),' ')]; % each moment is a row

% Permutation test iterations
% num_iter = 100;

% NSTE input parameters
fs = 60;            % Sampling frequency
win_size_sec = 2;   % Window size in seconds 
win_step_sec = 0.5; % Window step size in seconds. For nonoverlapping window, set win_size_sec = win_size_sec
dim = 3;            % Embedding dimension
tau = 6:3:15;       % STE lag

% Loop through moments
for i=1:size(moments,1)
    
   
    disp(strcat('Moment: ', moments(i,1)));

    % Load Data 
    load([LOAD_DIR 'classified_data.mat']);

    % Find session number
    for r=1:length(data)
        if find(strcmp(data(r).moments, moments(i,1)))
        NSTE(i).session = data(r).session;
        session_idx = str2double(NSTE(i).session) - 2;
        end
    end

    % Set moment index
    for x = 1:length(data(session_idx).moments)
        moment_idx = find(strcmp(data(session_idx).moments, moments(i,1)));
    end

    % Find start and end points
    startcell = str2double(split(data(session_idx).start(moment_idx), ':'));
    startframe = (startcell(1)*fs + startcell(2))*fs;

    finishcell = str2double(split(data(session_idx).finish(moment_idx), ':'));
    finishframe = (finishcell(1)*fs + finishcell(2))*fs;
    
    SAVE_NAME = 'NSTE'; 

    % Make sure signals start and end at same time
    signal_A = [data(session_idx).frames(startframe:finishframe), data(session_idx).speedA(startframe:finishframe)];
    signal_B = [data(session_idx).frames(startframe:finishframe), data(session_idx).speedB(startframe:finishframe)];

    % Get start time 
    start_time = max(signal_A(1,1),signal_B(1,1));
    [~, idx_start_1] = min(abs(signal_A(:,1)-start_time)); 
    [~, idx_start_2] = min(abs(signal_B(:,1)-start_time)); 

    % If signal starts with NaN, find next non Nan as start time 
    if(isnan(signal_A(idx_start_1,2)))
        idx_start_1 = find(~isnan(signal_A(:,2)), 1);
        start_time = signal_A(idx_start_1,1);

        [~, idx_start_2] = min(abs(signal_B(:,1)-start_time)); 

    elseif(isnan(signal_B(idx_start_2,2)))
        idx_start_2 = find(~isnan(signal_B(:,2)), 1);
        start_time = signal_B(idx_start_2,1);

        [~, idx_start_1] = min(abs(signal_A(:,1)-start_time)); 
    end 

    % Get end time 
    end_time = min(signal_A(end,1), signal_B(end,1));
    [~, idx_end_1] = min(abs(signal_A(:,1)-end_time)); 
    [~, idx_end_2] = min(abs(signal_B(:,1)-end_time)); 
    
    % Trim data to start and end idxs 
    signal_A = signal_A(idx_start_1:idx_end_1,:);
    signal_B = signal_B(idx_start_2:idx_end_2,:);
    
    % Since signal_A or signal_B might be longer by 1 or 2 samples (milliseconds), take
    % the length of the shorter one 
    signal_length = min(length(signal_A), length(signal_B));
    signal_A = signal_A(1:signal_length,:);
    signal_B = signal_B(1:signal_length,:);

    a = signal_A(:,2); 
    b = signal_B(:,2); 
    
    win_size = win_size_sec*fs; % Window size in samples 
    win_step = win_step_sec*fs;  % Step size in samples 
    win_overlap = win_size - win_step;  % Overlap size in samples 

    % Split up signals into windows. Columns of A, B are the segmented data
    A_wins = buffer(a,win_size,win_overlap,'nodelay');
    B_wins = buffer(b,win_size,win_overlap,'nodelay');
    
    %% Compute observed NSTE

    % Pre-allocate 
    total_win = size(A_wins,2)-1;  % Don't include the last window because it contains 0s 
    NSTE(i).STE_BA = NaN(total_win,1);
    NSTE(i).NSTE_BA = NaN(total_win,1);
    NSTE(i).STE_AB = NaN(total_win,1);
    NSTE(i).NSTE_AB = NaN(total_win,1);

    for m=1:total_win-1
        [NSTE(i).STE_BA(m),NSTE(i).NSTE_BA(m),NSTE(i).STE_AB(m),NSTE(i).NSTE_AB(m)] = calculate_STE(A_wins(:,m),B_wins(:,m),dim,tau);
    end

    % Time
    time = data(session_idx).time(startframe:finishframe-win_size).';
    time_idx = 1:fs/2:length(time);
    NSTE(i).nste_time = time(time_idx); % 1 sample per 0.5 second
    
    save([OUT_DIR SAVE_NAME '.mat'], 'NSTE');
     

%     %% Compute shuffled NSTE
%     
%     % Pre-allocate 
%     STE_BA_shuffle = NaN(total_win,num_iter);
%     NSTE_BA_shuffle = NaN(total_win,num_iter);
%     STE_AB_shuffle = NaN(total_win,num_iter);
%     NSTE_AB_shuffle = NaN(total_win,num_iter);
%     
%     for k=1:num_iter
%         
%         disp(['Iteration ',num2str(k)]);
%         
%         % Get random window from second subject
%         B_rand_wins = getRandWindows(b, size(A_wins));
%         
%         % Compute NSTE between signal 1 and random signal 2 windows
%         for m=1:total_win-1
%             [STE_BA_shuffle(m,k),NSTE_BA_shuffle(m,k),STE_AB_shuffle(m,k),NSTE_AB_shuffle(m,k)]= calculate_STE(A_wins(:,m),B_rand_wins(:,m),dim,tau);
%         end
%         
%     end
%         
%     % Sort shuffled concordance in ascending order for each iteration 
%     NSTE_BA_shuffle_sorted = sort(NSTE_BA_shuffle,1);
%     NSTE_AB_shuffle_sorted = sort(NSTE_AB_shuffle,1);
%     
%     % Pre-allocate size
%     pval_AB = NaN(size(NSTE_BA_shuffle_sorted,2));
%     pval_BA = NaN(size(NSTE_BA_shuffle_sorted,2));
% 
%     for j = 1:size(NSTE_BA_shuffle_sorted,2)
% 
%         % From histogram of shuffled NSTE, compute the p-value as the fraction of the distribution that
%         % is more extreme than the observed ssi value.
%         % we use absolute value so that both positive and negative correlations
%         % count as "extreme". If pval is smaller than the critical value (0.05),
%         % then the two are significantly different 
%         pval_AB(j) = (sum(abs(NSTE_AB_shuffle_sorted(:,j)) > abs(NSTE_AB(j,2))))/ (size(NSTE_AB_shuffle_sorted,1));
%         pval_BA(j) = (sum(abs(NSTE_BA_shuffle_sorted(:,j)) > abs(NSTE_BA(j,2))))/ (size(NSTE_BA_shuffle_sorted,1));
%     end 
% 
%     save(strcat(OUT_DIR,SAVE_NAME,'.mat'),"NSTE_BA", "NSTE_AB","STE_BA", "STE_AB","nste_time", ...
%         "NSTE_BA_shuffle", "NSTE_AB_shuffle", "pval_AB", "pval_BA");
%     
%     clear STE_BA STE_AB NSTE_BA NSTE_AB STE_BA_shuffle NSTE_BA_shuffle STE_AB_shuffle NSTE_AB_shuffle pval_AB pval_BA;          
    
end 

