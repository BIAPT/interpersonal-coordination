function Integer = F_Symb2Int(E)
% This function transforms intergers into symbols based on their amplitude 

[V I] = sort(E');
I = I';
SZ = size(E);

Integer = zeros(SZ(1), 1);
for i = 1 : SZ(2)
    Integer = Integer + I(:,i)*10^(SZ(2)-i)';
end