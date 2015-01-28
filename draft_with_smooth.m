%% All Inputs Go In Here

% For configuring loaded data
row_dimension = 300;    % Image size
column_dimension = 300; %     ||
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

%% [WIP] Reduce noise on the data in multiple dimensions

% 2-D filtering image layers with a constructed filter
[x,y] = meshgrid(-1:2/(kernel_size-1):1,-1:2/(kernel_size-1):1);
r = sqrt(x.^2 + y.^2);
h_surface = exp(-(r/std_dev).^2);
volume = sum(sum(h_surface));
h_surface = h_surface/volume;

layerfiltered_data_mat3 = zeros(300,300,200);
for page_counter = 1:200
    layerfiltered_data_mat3(:,:,page_counter) = filter2(h_surface,data_mat3(:,:,page_counter));
end

% 1-D filtering lists of current values with smooth function (adjacent-averaging)
smoothed_data_mat3 = zeros(300,300,200);
for row_counter = 1:300
    for column_counter = 1:300
        smoothed_data_mat3(row_counter,column_counter,:) = smooth(layerfiltered_data_mat3(row_counter,column_counter,:),window_size);
    end
end

%% Correct the zero value (I should be zero when V is zero)

% Calculate correction value (I_average)
I_below = smoothed_data_mat3(:,:,page_dimension/2);
I_above = smoothed_data_mat3(:,:,page_dimension/2+1);
I_average = (I_above + I_below)/2;  % should ideally be zero, so this value will be subtracted from the data

% Allocate and fill a matrix with corrected images
zero_corrected_smoothed_data_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for page_counter = 1:page_dimension
    zero_corrected_smoothed_data_mat3(:,:,page_counter) = smoothed_data_mat3(:,:,page_counter) - I_average;
end

%% Calculate the derivative of I with respect to V, then calculate LDOS, which is the derivative divided by I/V

% Add actual scale to the voltage steps
V_step = (V_upperbound - V_lowerbound)/(page_dimension - 1);
V_range = V_lowerbound:V_step:V_upperbound; % separates the voltage range into evenly valued steps based on input

% Approximate differentiation resulting in a matrix with one less page
diff_zero_corrected_smoothed_data_mat3 = diff(zero_corrected_smoothed_data_mat3,1,3)/V_step;

% The differentiated data is divided by corresponding I/V values to yield
% LDOS.
ldos_left_mat3 = zeros(row_dimension,column_dimension,page_dimension-1);    % tentatively called "left" since it will use only the first (page_dimension - 1) I/V values
I_over_V_mat3 = zeros(row_dimension,column_dimension,page_dimension-1);
for row_counter = 1:row_dimension
    for column_counter = 1:column_dimension
        I_over_V_mat3(row_counter,column_counter,:) = permute(zero_corrected_smoothed_data_mat3(row_counter,column_counter,1:(page_dimension-1)),[2 3 1])./V_range(1:(page_dimension-1));
        ldos_left_mat3(row_counter,column_counter,:) = permute(diff_zero_corrected_smoothed_data_mat3(row_counter,column_counter,:),[2 3 1])./permute(I_over_V_mat3(row_counter,column_counter,:),[2 3 1]);
    end
end

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
plot(permute(ldos_left_mat3(row,column,:),[3 2 1]))

%% Exporting data
%{
dlmwrite('STEP 1 original.txt',permute(data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 2 3d-smoothed.txt',permute(smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 3 zero-corrected 3d-smoothed.txt',permute(zero_corrected_smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 4 differentiated zero-corrected 3d-smoothed.txt',permute(diff_zero_corrected_smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 5 I over V.txt',permute(I_over_V_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 6 LDOS.txt',permute(ldos_left_mat3(row,column,:),[2 3 1]),'delimiter','\t')
%}