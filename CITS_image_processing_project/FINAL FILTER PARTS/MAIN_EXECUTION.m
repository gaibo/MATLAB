%% Reduce noise on the data in multiple dimensions

% 2-D filter image layers with a constructed parabolic filter
[x,y] = meshgrid(-(kernel_size-1)/2:(kernel_size-1)/2,-(kernel_size-1)/2:(kernel_size-1)/2);
r = sqrt(x.^2 + y.^2);
h_surface = 1 - (r/((kernel_size*sqrt(2))/2)).^2;
volume = sum(sum(h_surface));
h_surface = h_surface/volume;

layerfiltered_data_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for page_counter = 1:page_dimension
    layerfiltered_data_mat3(:,:,page_counter) = filter2(h_surface,data_mat3(:,:,page_counter));
end

% 1-D filter lists of current values with constructed parabolic filter
r = -(window_size-1)/2:(window_size-1)/2;
h_perpendicular = 1 - (r/((window_size+1)/2)).^2;
area = sum(h_perpendicular);
h_perpendicular = h_perpendicular/area;

% Correct for 1-D filter delay
afterbuffer_size = (window_size-1)/2;
afterbuffered_layerfiltered_data_mat3 = cat(3,layerfiltered_data_mat3,layerfiltered_data_mat3(:,:,end:-1:end-afterbuffer_size+1));

afterbuffered_smoothed_data_mat3 = filter(h_perpendicular,1,afterbuffered_layerfiltered_data_mat3,[],3);
smoothed_data_mat3 = afterbuffered_smoothed_data_mat3(:,:,afterbuffer_size+1:end);

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

% Add actual scale to the voltage steps and produce 3-D matrix of it for
% later I/V calculation
V_step = (V_upperbound - V_lowerbound)/(page_dimension - 1);
V_range = V_lowerbound:V_step:V_upperbound; % separates the voltage range into evenly valued steps based on input
V_range_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for row_counter = 1:row_dimension
    for column_counter = 1:column_dimension
        V_range_mat3(row_counter,column_counter,:) = V_range;
    end
end

% Average two approximate differentiations to obtain better overall
% approximate differentiation, keeping in mind resulting matrix will miss
% one page on either side
diff_left_mat3 = diff(zero_corrected_smoothed_data_mat3(:,:,1:end-1),1,3)/V_step;
diff_right_mat3 = diff(zero_corrected_smoothed_data_mat3(:,:,2:end),1,3)/V_step;
diff_zero_corrected_smoothed_data_mat3 = (diff_left_mat3 + diff_right_mat3)/2;

% Add two pages for good measure, so the full range can still be plotted,
% although end points will not really be meaningful
diff_begin = diff(zero_corrected_smoothed_data_mat3(:,:,1:2),1,3)/V_step;
diff_end = diff(zero_corrected_smoothed_data_mat3(:,:,end-1:end),1,3)/V_step;
diff_zero_corrected_smoothed_data_mat3 = cat(3,diff_begin,diff_zero_corrected_smoothed_data_mat3,diff_end);

% Calculate I/V for each point
I_over_V_mat3 = zero_corrected_smoothed_data_mat3(:,:,:)./V_range_mat3(:,:,:);

% Divide differentiated data by corresponding I/V values to yield LDOS
ldos_mat3 = diff_zero_corrected_smoothed_data_mat3./I_over_V_mat3;