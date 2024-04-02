function Symbol = F_Int2Symb(E)

[sorted,idx] = sort(E');
idx = idx'; 
SZ = size(E);

Symbol = zeros(SZ(1), 1);
ranks = repelem(1:SZ(2),SZ(1),1);

for i = 1:SZ(1) % Loop through rows 
    idx_row = idx(i,:);
    ranks(i,idx_row) = ranks(i,:);
    
    % Using polyval to convert the array of ranks into a single value 
    % E.g. For dim=3, polyval(r,10) computes r1*10^2 + r2*10 + r3
    Symbol(i) = polyval(ranks(i,:), 10);
end 
