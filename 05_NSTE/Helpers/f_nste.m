function [STE, NSTE] = f_nste(data, dim, lag, delta)
% only applied for bivariate data
% (c1,c2): c2 -> c1
% That is, Column to Row

ch=size(data,2); % For 2 signals, ch=2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Part 1. STE of original data %%%%%%%%%%%%%%%%%%

Ddata=delayRecons(data, lag, dim); % embedding 
for c=1:ch
    INT(:,c)=F_Int2Symb(Ddata(:,:,c)); % transform to symbol
end
Int_future=INT(1+delta:end,:);
Int_past=INT(1:end-delta,:);

% P1 = P[X(n+1),X(n),Y(n)]
% P2 = P[X(n),Y(n)]
% P3 = P[X(n+1),X(n),???]
% P4 = P[X(n)]
%[P1, P2, P3, P4] = f_Integer2prob(Integer1, Integer2, Integer3)
% Integer1: Target Future: X(n+1)
% Integer2: Target Present: X(n)
% Integer3: Source Present: Y(n)

% Compute STE_YX and H(X_future | X_past) 
[P1, P2, P3, P4] = f_Integer2prob(Int_future(:,1), Int_past(:,1), Int_past(:,2)); %(XF, XP, YP)
STE(1) = sum( P1 .* (log2( P1.*P4 ) - log2(P2.*P3)) ); % P1 = P(XF,XP,YP) => target is X, source is Y => STE_YX
H(1) = -sum ( P3 .* (log2(P3) - log2(P4)));

% Compute STE_XY and H(Y_future | Y_past) 
[P1, P2, P3, P4] = f_Integer2prob(Int_future(:,2), Int_past(:,2), Int_past(:,1)); %(YF, YP, XP)
STE(2) = sum( P1 .* (log2( P1.*P4 ) - log2(P2.*P3)) ); % P1 = P(YF,YP,YP) => target is Y, source is X => STE_XY
H(2) = -sum ( P3 .* (log2(P3) - log2(P4)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Part 2. STE of shuffled data  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Computing STE_YX and NSTE_YX %%%%%%%%%%%%%%%%%

% first data X = target 
% second data Y = source 

% second data is shuffled because it is source 
data2=data(:,2); 

% num_trials = 20; % Number of trials for getting shuffled value (original)
num_trials = 100; % Number of trials for getting shuffled value 
for i = 1:num_trials
    shuffled_data2 = data2(randperm(length(data2))); % shuffle data 
    
    Ddata=delayRecons([data(:,1) shuffled_data2], lag, dim);
    clear INT;
    for c=1:ch
        INT(:,c)=F_Int2Symb(Ddata(:,:,c));
    end
    Int_future=INT(1+delta:end,:);
    Int_past=INT(1:end-delta,:);

    [P1, P2, P3, P4] = f_Integer2prob(Int_future(:,1), Int_past(:,1), Int_past(:,2));
    STE_shuffled_all(i) = sum( P1 .* (log2( P1.*P4 ) - log2(P2.*P3)) );
end 

STE_shuffled_ave = mean(STE_shuffled_all);

NSTE_numerator(1) = STE(1) - STE_shuffled_ave; %STE(1) is STE_YX

if NSTE_numerator(1) < 0
    NSTE(1) = 0; % set NSTE to 0 if shuffled STE is greater than normal STE 
else
    NSTE(1) = NSTE_numerator(1)/H(1);  
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Part 3. STE of shuffled data  %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%  Computing STE_XY and NSTE_XY %%%%%%%%%%%%%%%%%

% first data X = source 
% second data Y = target 

% first data is shuffled because it is source 
data1=data(:,1); % source data

% num_trials = 20; % Number of trials for getting shuffled value 
num_trials = 100; % Number of trials for getting shuffled value 
for i = 1:num_trials
    shuffled_data1 = data1(randperm(length(data1)));
    
    Ddata=delayRecons([shuffled_data1 data(:,2)], lag, dim);
    clear INT;
    for c=1:ch
        INT(:,c)=F_Int2Symb(Ddata(:,:,c));
    end
    Int_future=INT(1+delta:end,:);
    Int_past=INT(1:end-delta,:);

    [P1, P2, P3, P4] = f_Integer2prob(Int_future(:,2), Int_past(:,2), Int_past(:,1));
    STE_shuffled_all = sum( P1 .* (log2( P1.*P4 ) - log2(P2.*P3)) );
end 

STE_shuffled_ave = mean(STE_shuffled_all);

NSTE_numerator(2) = STE(2) - STE_shuffled_ave;

if NSTE_numerator(2) < 0
    NSTE(2) = 0; % set NSTE to 0 if shuffled STE is greater than normal STE 
else
    NSTE(2) = NSTE_numerator(2)/H(2); % STE(2) is STE_XY => NSTE(2) is NSTE_XY
end 

















