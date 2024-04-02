% Paige Whitehead March 26, 2024

% This script:
% (1) classifies each session's moments as either high or low coordination, and 
% (2) produces a confusion matrix to assess the performance of the classification algorithm

%% SETUP

clear;

% Set paths
% NOTE: path strings should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\03_SpeedCorrelations\';
OUT_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\04_Classification\';

% Load master data struct
load([LOAD_DIR 'data.mat']);

% Specify how each moment was coded
data(1).code    = {'low' 'high' 'high' 'high' 'low' 'high' 'low' 'low' 'high'};
data(2).code    = {'high' 'high' 'high' 'low' 'high' 'low' 'low' 'high' 'high' 'low' 'low' 'high' 'low' 'high' 'high' 'high' 'high' 'high'};
data(3).code    = {'high'};
data(4).code    = {'high' 'high' 'high'};
data(5).code    = {'high' 'high' 'low' 'high' 'low'};


%% CLASSIFICATION

for session_idx = 1:length(data)

    for moment_idx = 1:length(data(session_idx).moments)

        % Fixed variables
        srate = 60;

        % Convert timestamps to frames
        startcell   = str2double(strsplit(char(data(session_idx).start(moment_idx)), ':'));
        startframe  = (startcell(1)*srate + startcell(2))*srate;

        finishcell  = str2double(strsplit(char(data(session_idx).finish(moment_idx)), ':'));
        finishframe = (finishcell(1)*srate + finishcell(2))*srate;

        % Initialize high and low bins
        high = zeros(length(startframe:finishframe),1);
        low  = zeros(length(startframe:finishframe),1);

        % Bin data
        for frame_idx = startframe:finishframe

            if data(session_idx).max_corr(frame_idx) > 0.5
                high(frame_idx-(startframe-1)) = data(session_idx).max_corr(frame_idx) - 0.5;
            else
                low(frame_idx-(startframe-1)) = 0.5 - data(session_idx).max_corr(frame_idx);
            end

        end
        
        % Sum data in each bin
        highsum = sum(high);
        lowsum  = sum(low);
        
        % Classify moment
        if highsum > lowsum
            data(session_idx).classification(moment_idx) = 1;
            data(session_idx).label(moment_idx)          = {'high'};
        else
            data(session_idx).classification(moment_idx) = 0;
            data(session_idx).label(moment_idx)          = {'low'};
        end

    end

end


save([OUT_DIR 'classified_data.mat'], 'data');


%% COMPUTE CONFUSION MATRIX AND PRODUCE CHART

% Combine predicted labels
predicted    = [data(1).label...  
                data(2).label...
                data(3).label...
                data(4).label...
                data(5).label];

% Combine ground truth labels (ie human-coded labels)
ground_truth = [data(1).code...
                data(2).code...
                data(3).code...
                data(4).code...
                data(5).code];

C = confusionmat(ground_truth, predicted);
cm = confusionchart(C, {'Low', 'High'});
cm.Title = 'Moment Classification Confusion Matrix';
cm.YLabel = 'Ground Truth Class';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

saveas(gcf, [OUT_DIR 'confusion_matrix_w_summaries.tiff'])

