% Paige Whitehead March 26, 2024

function result = interpolate(speed)

% Find NaNs
nanx = isnan(speed);
t    = 1:numel(speed); % creates a count vector (1-54000)

% Linear interpolation over NaNs
speed(nanx) = interp1(t(~nanx), speed(~nanx), t(nanx));

result = speed;

end 