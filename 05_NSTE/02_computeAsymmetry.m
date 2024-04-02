% Source code: Dannie Fu March 12 2021
% Modified: Paige Whitehead March 26, 2024

% This script computes asymmetry from NSTE AB and NSTE BA

% ------------------------

clear;

% NOTE: path string should end with '\'
LOAD_DIR = 'C:\Users\Paige\Documents\Research\PSM\Data Analysis\Movement Analysis\Scripts\05_NSTE\';                               
LOAD_NAME = 'NSTE';  
SAVE_DIR = LOAD_DIR;
SAVE_NAME = [LOAD_NAME '_asym.mat'];

asym_win_size = 1;

load([LOAD_DIR LOAD_NAME]);

for i=1:length(NSTE)
    asym(i).asym_win_size = asym_win_size;
   
    asym(i).asym_AB = (NSTE(i).NSTE_AB - NSTE(i).NSTE_BA)./(NSTE(i).NSTE_AB + NSTE(i).NSTE_BA);
    asym(i).asym_AB(isnan(asym(i).asym_AB)) = 0;

    % try taking average asymmetry across sliding windows of 3 seconds no
    % overlap
    asym_wins = buffer(asym(i).asym_AB,asym_win_size, 0, 'nodelay');

    asym(i).asym_ave = mean(asym_wins, 1, 'omitnan');
end

save([SAVE_DIR SAVE_NAME], 'asym');

