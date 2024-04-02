% Dannie Fu December 6 2020
% This script computes STE and NSTE values over a sliding window.
%
% Variables computed are 
% STE1 = STE YX
% STE2 = STE XY
% NSTE1 = NSTE YX 
% NSTE2 = NSTE XY
% ---------------------------------------------------------------------------------

function [STE1,NSTE1,STE2,NSTE2]= calculate_STE(X,Y,dim,tau)

    STE = NaN(length(tau),2); 
    NSTE = NaN(length(tau),2);

    delta=f_predictiontime(X,Y,50);

     % Looping through tau
    for L=1:length(tau)
        % Passing in [X Y], returns: [STE_YX STE_XY], [NSTE_YX NSTE_XY]
        [STE(L,1:2), NSTE(L,1:2)] = f_nste([X Y], dim, tau(L), delta);
    end
    
    [mxNSTE, ~]=max(NSTE); %mxNSTE and mxNTau
    [mxSTE, ~]=max(STE); 
   
    % Target to Source Y->X
    STE1 =mxSTE(1);    
    NSTE1 =mxNSTE(1);

    % Source to Target X->Y
    STE2=mxSTE(2);    
    NSTE2=mxNSTE(2);
end
