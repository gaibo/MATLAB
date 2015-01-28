% For configuring data smoothing
std_dev = 0.5;  % value proportional to standard deviation for Gaussian filter
window_size = 15;   % size of window for 1-D current data filtering (must be odd)

row_counter = 150;
column_counter = 150;

x = -1:2/(window_size-1):1;
h_perpendicular = exp(-(x/std_dev).^2);
area = sum(h_perpendicular);
h_perpendicular = h_perpendicular/area;

smoothed = smooth(data_mat3(row_counter,column_counter,:),window_size);

filtfilted = filtfilt(h_perpendicular,1,data_mat3(row_counter,column_counter,:));

figure(9001)
clf
hold on
plot(smoothed,'Color','r','LineStyle','--')
plot(filtfilted,'Color','g')
hold off