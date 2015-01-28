%% All Inputs Go In Here

% For configuring loaded data
row_dimension = 300;    % Image size
column_dimension = 300; %     || (Probably same as above)
page_dimension = 200;   % Number of evenly spaced voltages applied

% For configuring Voltage range parameters
V_lowerbound = -1.5;
V_upperbound = 1.5;

% For configuring data smoothing
std_dev = 0.5;  % value proportional to standard deviation for Gaussian filter
kernel_size = 7;    % size of kernel for 2-D image layer filtering (must be odd)
window_size = 15;   % size of window for 1-D current data filtering (must be odd)

% For visualizing data (so each image or plot can be compared to previous)
row = 150;
column = 150;
page = 50;

%% Load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[row_dimension column_dimension page_dimension]);
data_mat3 = permute(data_mat3,[2 1 3]); % To correct the axes (if needed)

%% Reduce noise on the data in multiple dimensions

% 2-D filtering image layers with a constructed Gaussian filter
[x,y] = meshgrid(-1:2/(kernel_size-1):1,-1:2/(kernel_size-1):1);
r = sqrt(x.^2 + y.^2);
h_surface = exp(-(r/std_dev).^2);
volume = sum(sum(h_surface));
h_surface = h_surface/volume;

layerfiltered_data_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for page_counter = 1:page_dimension
    layerfiltered_data_mat3(:,:,page_counter) = filter2(h_surface,data_mat3(:,:,page_counter));
end

% 1-D filtering lists of current values with constructed parabolic filter
w = -(window_size-1)/2:(window_size-1)/2;
h_perpendicular = 1 - (w/((window_size+1)/2)).^2;
area = sum(h_perpendicular);
h_perpendicular = h_perpendicular/area;

smoothed_data_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for row_counter = 1:row_dimension
    for column_counter = 1:column_dimension
        smoothed_data_mat3(row_counter,column_counter,:) = filter(h_perpendicular,1,layerfiltered_data_mat3(row_counter,column_counter,:));
    end
end

%% Correct the zero value (I should be zero when V is zero)

% Calculate correction value (I_error_average)
if bitget(page_dimension,1)
    I_error_average = smoothed_data_mat3(:,:,(page_dimension+1)/2);
else
    I_error_below = smoothed_data_mat3(:,:,page_dimension/2);
    I_error_above = smoothed_data_mat3(:,:,page_dimension/2+1);
    I_error_average = (I_error_above + I_error_below)/2;  % should ideally be zero; this value will be subtracted from the data
end

% Allocate and fill a matrix with corrected images
zero_corrected_smoothed_data_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for page_counter = 1:page_dimension
    zero_corrected_smoothed_data_mat3(:,:,page_counter) = smoothed_data_mat3(:,:,page_counter) - I_error_average;
end

%% Calculate the derivative of I with respect to V, then calculate LDOS, which is the derivative divided by I/V

% Add actual scale to the voltage steps and produce 3-D matrix of it
V_step = (V_upperbound - V_lowerbound)/(page_dimension - 1);
V_range = V_lowerbound:V_step:V_upperbound; % separates the voltage range into evenly valued steps based on input
V_range_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for row_counter = 1:row_dimension
    for column_counter = 1:column_dimension
        V_range_mat3(row_counter,column_counter,:) = V_range;
    end
end

% Averaging two approximate differentiations to obtain matrix with two less pages
diff_left_mat3 = diff(zero_corrected_smoothed_data_mat3(:,:,1:(page_dimension-1)),1,3)/V_step;
diff_right_mat3 = diff(zero_corrected_smoothed_data_mat3(:,:,2:page_dimension),1,3)/V_step;
diff_zero_corrected_smoothed_data_mat3 = (diff_left_mat3 + diff_right_mat3)/2;

% I/V is calculated for each usable point (only page_dimension-2 layers are
% usable now due to approximate differentiation)
I_over_V_mat3 = zero_corrected_smoothed_data_mat3(:,:,2:(page_dimension-1))./V_range_mat3(:,:,2:(page_dimension-1));

% The differentiated data is divided by corresponding I/V values to yield LDOS
ldos_mat3 = diff_zero_corrected_smoothed_data_mat3./I_over_V_mat3;

%% Visualization - Figures

% 1 and 2 are original data
figure(1)
clf
imagesc(data_mat3(:,:,page))

figure(2)
clf
plot(permute(data_mat3(row,column,:),[3 2 1]))

% 3 and 4 are smoothed (4 (green dotted) has comparison with 2 (red dashed))
figure(3)
clf
imagesc(smoothed_data_mat3(:,:,page))

figure(4)
clf
hold on
plot(permute(data_mat3(row,column,:),[3 2 1]),'Color','r','LineStyle','--')
plot(permute(smoothed_data_mat3(row,column,:),[3 2 1]),'Color','g','LineStyle',':')
hold off

% 5 and 6 are zero-corrected and smoothed (6 has comparison to 4 (green 
% dotted) and 2 (red dashed))
figure(5)
clf
imagesc(zero_corrected_smoothed_data_mat3(:,:,page))

figure(6)
clf
hold on
plot(permute(data_mat3(row,column,:),[3 2 1]),'Color','r','LineStyle','--')
plot(permute(smoothed_data_mat3(row,column,:),[3 2 1]),'Color','g','LineStyle',':')
plot(permute(zero_corrected_smoothed_data_mat3(row,column,:),[3 2 1]))
hold off

% 7 is plot showing result of differentiation
figure(7)
clf
plot(permute(diff_zero_corrected_smoothed_data_mat3(row,column,:),[3 2 1]))

% 8 is plot showing I/V, which will be used in 9 (LDOS)
figure(8)
clf
plot(permute(I_over_V_mat3(row,column,:),[3 2 1]))

% Plot of the final LDOS
figure(9)
clf
plot(permute(ldos_mat3(row,column,:),[3 2 1]))

%% Exporting data

dlmwrite('STEP 1 original.txt',permute(data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 2 3d-smoothed.txt',permute(smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 3 zero-corrected 3d-smoothed.txt',permute(zero_corrected_smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 4 differentiated zero-corrected 3d-smoothed.txt',permute(diff_zero_corrected_smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 5 I over V.txt',permute(I_over_V_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 6 LDOS.txt',permute(ldos_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('SUPPLEMENT layerfiltered data.txt',permute(layerfiltered_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')