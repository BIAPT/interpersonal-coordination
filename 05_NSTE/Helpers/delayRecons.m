function y=delayRecons(data, v, m)
% This function splits the data up based on the specified embedding dimension and
% lag. 
%
% Input Params:
%       data: should be 2-d matrix, where each row is a data point and each
%             column is a signal e.g. 10x2 matrix
%       v:  lag - the time delay 
%       m:  embedding dimension (the number of ranks that will be
%           used when symbolizing the data) e.g. m = 3 means three data
%           points will be ranked from 1 to 3 based on their amplitude. 
%       output: is 3-d matrix
%
% Example: If v = 1, m = 2
% 
% Input =  
%   [ 1     2
%     4     5
%     6     1
%     9    10 ]
%
% Output: 
% val(:,:,1) =
%     1     4
%     4     6
%     6     9

% val(:,:,2) =
%     2     5
%     5     1
%     1    10


MaxEpoch=length(data);
ch=size(data,2);

y=zeros(MaxEpoch-v*(m-1),m,ch);
for c=1:ch
    for j=1:m
        y(:, j, c)=data(1+(j-1)*v:end-(m-j)*v, c);
    end
end

