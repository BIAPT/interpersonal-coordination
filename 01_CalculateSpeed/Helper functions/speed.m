% Paige Whitehead March 26, 2024

function speed = speed(data_x, data_y, speed_length)

% Initialize speed vector
speed = zeros(speed_length,1); 

% Compute speed
for i = 1:speed_length

    speed(i,1) = sqrt((data_x(i+1) - data_x(i))^2 + (data_y(i+1) - data_y(i))^2);

end

end