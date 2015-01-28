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
diff_left_mat3 = diff(zero_corrected_smoothed_data_mat3(:,:,1:199),1,3)/V_step;
diff_right_mat3 = diff(zero_corrected_smoothed_data_mat3(:,:,2:200),1,3)/V_step;
diff_zero_corrected_smoothed_data_mat3 = (diff_left_mat3 + diff_right_mat3)/2;

% I/V is calculated for each usable point (only page_dimension-2 layers are
% usable now due to approximate differentiation)
I_over_V = zero_corrected_smoothed_data_mat3(:,:,2:199)./V_range_mat3(:,:,2:199);

% The differentiated data is divided by corresponding I/V values to yield LDOS
ldos_mat3 = diff_zero_corrected_smoothed_data_mat3./I_over_V;