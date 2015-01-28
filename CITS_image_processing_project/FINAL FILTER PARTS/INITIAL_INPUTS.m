%% Initial inputs

% For configuring loaded data
row_dimension = 300;    % Image size
column_dimension = 300; %     || (Probably same as above)
page_dimension = 200;   % Number of evenly spaced voltages applied

% For configuring Voltage range parameters
V_lowerbound = -1.5;
V_upperbound = 1.5;

% For configuring data smoothing
kernel_size = 7;    % size of kernel for 2-D image layer filtering (must be odd)
window_size = 15;   % size of window for 1-D current data filtering (must be odd)