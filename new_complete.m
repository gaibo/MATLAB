%% Load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);
data_mat3 = permute(data_mat3,[2 1 3]); % To correct the axes

%% Reduce noise on the data in multiple dimensions

kernel_size = 7;   % size of the convolution kernel (must be odd) ([kernel_size kernel_size kernel_size])
std_dev = 1;  % standard deviation of Gaussian function used to weight
smoothed_data_mat3 = smooth3(data_mat3,'gaussian',kernel_size,std_dev);

% Compare original and smoothed data matrices
row = 150;
column = 150;
page = 50;

% 1 and 2 are original
figure(1)
clf
imagesc(data_mat3(:,:,page))

figure(2)
clf
plot(permute(data_mat3(row,column,:),[3 2 1]))

% 3 and 4 are smoothed
figure(3)
clf
imagesc(smoothed_data_mat3(:,:,page))

figure(4)
clf
plot(permute(smoothed_data_mat3(row,column,:),[3 2 1]))

%% Correct the zero value (I should be zero when V is zero)

% Calculate correction value (c)
I_below = smoothed_data_mat3(:,:,100);
I_above = smoothed_data_mat3(:,:,101);
I_average = (I_above + I_below)/2;  % should ideally be zero, so this value will be subtracted from the data

% Allocate and fill a matrix with corrected images
zero_corrected_smoothed_data_mat3 = zeros(300,300,200);
for page_counter = 1:200
    zero_corrected_smoothed_data_mat3(:,:,page_counter) = smoothed_data_mat3(:,:,page_counter) - I_average;
end

% Image after zero-correction and smoothing
figure(5)
clf
imagesc(zero_corrected_smoothed_data_mat3(:,:,page))

% Plot comparisons of zero-corrected smooth and non-corrected smooth
figure(6)
clf
hold on
plot(permute(smoothed_data_mat3(row,column,:),[3 2 1]))
plot(permute(zero_corrected_smoothed_data_mat3(row,column,:),[3 2 1]))
hold off

%% Calculate the derivative of I with respect to V, then calculate LDOS, which is the derivative divided by I/V

% Add actual scale to the voltage steps
V_range = -1.5:3/199:1.5;

% Approximate differentiation resulting in 300x300x199 matrix
diff_zero_corrected_smoothed_data_mat3 = diff(zero_corrected_smoothed_data_mat3,1,3)/(3/199);   % 3/199 is the voltage step size, here used for differentiation

% Plot the derivative
figure(7)
clf
plot(permute(diff_zero_corrected_smoothed_data_mat3(row,column,:),[3 2 1]))

% The differentiated data is divided by corresponding I/V values to yield
% LDOS.
ldos_left_mat3 = zeros(300,300,199);    % tentatively called "left" since it will use only the first 199 I/V values out of 200
I_over_V_mat3 = zeros(300,300,199);
for row_counter = 1:300
    for column_counter = 1:300
        I_over_V_mat3(row_counter,column_counter,:) = permute(zero_corrected_smoothed_data_mat3(row_counter,column_counter,1:199),[2 3 1])./V_range(1:199);
        ldos_left_mat3(row_counter,column_counter,:) = permute(diff_zero_corrected_smoothed_data_mat3(row_counter,column_counter,:),[2 3 1])./permute(I_over_V_mat3(row_counter,column_counter,:),[2 3 1]);
    end
end

% Plot the I/V
figure(8)
clf
plot(permute(I_over_V_mat3(row,column,:),[3 2 1]))

% Plot the LDOS
figure(9)
clf
plot(permute(ldos_left_mat3(row,column,:),[3 2 1]))