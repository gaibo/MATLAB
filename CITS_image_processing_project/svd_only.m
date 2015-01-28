%% Load data and shape

% For configuring loaded data
row_dimension = 300;    % Image size
column_dimension = 300; %     || (Probably same as above)
page_dimension = 200;   % Number of evenly spaced voltages applied
file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);

% Shape data into stack of images for later use
data_mat3 = reshape(data,row_dimension,column_dimension,page_dimension);

% [OPTIONAL STEP] Correct the axes if necessary
data_mat3 = permute(data_mat3,[2 1 3]);

%% [OPTIONAL STEP] Denoise with Principal Components Analysis 

% Unshape the data_mat3
reunshaped_data = reshape(data_mat3,90000,200);

[U,S,V] = svd(reunshaped_data,'econ');

PC_cutoff = 200;
denoised_data = U(:,1:PC_cutoff) * S(1:PC_cutoff,1:PC_cutoff) * V(:,1:PC_cutoff)';

% Reshape
fullyfiltered_data_mat3 = reshape(denoised_data,row_dimension,column_dimension,page_dimension);

%% Correct the zero value (I should be zero when V is zero)

% Calculate correction value (I_error_average)
if bitget(page_dimension,1)
    I_error_average = fullyfiltered_data_mat3(:,:,(page_dimension+1)/2);
else
    I_error_below = fullyfiltered_data_mat3(:,:,page_dimension/2);
    I_error_above = fullyfiltered_data_mat3(:,:,page_dimension/2+1);
    I_error_average = (I_error_above + I_error_below)/2;  % should ideally be zero; this value will be subtracted from the data
end

% Allocate and fill a matrix with corrected images
zero_corrected_fullyfiltered_data_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for page_counter = 1:page_dimension
    zero_corrected_fullyfiltered_data_mat3(:,:,page_counter) = fullyfiltered_data_mat3(:,:,page_counter) - I_error_average;
end

%% Calculate the derivative of I with respect to V, then calculate LDOS, which is the derivative divided by I/V

% For configuring Voltage range parameters
V_lowerbound = -1.5;
V_upperbound = 1.5;

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
diff_left_mat3 = diff(zero_corrected_fullyfiltered_data_mat3(:,:,1:end-1),1,3)/V_step;
diff_right_mat3 = diff(zero_corrected_fullyfiltered_data_mat3(:,:,2:end),1,3)/V_step;
diff_zero_corrected_fullyfiltered_data_mat3 = (diff_left_mat3 + diff_right_mat3)/2;

% Add two pages for good measure, so the full range can still be plotted,
% although end points will not really be meaningful
diff_begin = diff(zero_corrected_fullyfiltered_data_mat3(:,:,1:2),1,3)/V_step;
diff_end = diff(zero_corrected_fullyfiltered_data_mat3(:,:,end-1:end),1,3)/V_step;
diff_zero_corrected_fullyfiltered_data_mat3 = cat(3,diff_begin,diff_zero_corrected_fullyfiltered_data_mat3,diff_end);

% Calculate I/V for each point
I_over_V_mat3 = zero_corrected_fullyfiltered_data_mat3(:,:,:)./V_range_mat3(:,:,:);

% Divide differentiated data by corresponding I/V values to yield LDOS
ldos_mat3 = diff_zero_corrected_fullyfiltered_data_mat3./I_over_V_mat3;

%% Visualization - Figures

% For visualizing data (so each image or plot can be compared to previous)
row = 150;
column = 150;
page = 50;

% 1 and 2 are starting data (could be already de-noised)
figure(1)
clf
imagesc(data_mat3(:,:,page))

figure(2)
clf
plot(squeeze(data_mat3(row,column,:)))
% 
% % 3 and 4 are after layer filtering
% figure(3)
% clf
% imagesc(layerfiltered_data_mat3(:,:,page))
% 
% figure(4)
% clf
% hold on
% plot(squeeze(data_mat3(row,column,:)),'Color','r','LineStyle','--')
% plot(squeeze(layerfiltered_data_mat3(row,column,:)))
% hold off

% 5 and 6 are after perpendicular list filtering
figure(5)
clf
imagesc(fullyfiltered_data_mat3(:,:,page))

figure(6)
clf
hold on
plot(squeeze(data_mat3(row,column,:)),'Color','r','LineStyle','--')
% plot(squeeze(layerfiltered_data_mat3(row,column,:)),'Color','g','LineStyle',':')
plot(squeeze(fullyfiltered_data_mat3(row,column,:)))
hold off

% 7 and 8 are after zero-correction
figure(7)
clf
imagesc(zero_corrected_fullyfiltered_data_mat3(:,:,page))

figure(8)
clf
hold on
plot(squeeze(data_mat3(row,column,:)),'Color','r','LineStyle','--')
% plot(squeeze(layerfiltered_data_mat3(row,column,:)),'Color','g','LineStyle',':')
plot(squeeze(fullyfiltered_data_mat3(row,column,:)),'Color','b','LineStyle','-.')
plot(squeeze(zero_corrected_fullyfiltered_data_mat3(row,column,:)))
hold off

% 9 is result of differentiation
figure(9)
clf
plot(squeeze(diff_zero_corrected_fullyfiltered_data_mat3(row,column,:)))

% 10 is I/V, which will be used to make 11 (LDOS)
figure(10)
clf
plot(squeeze(I_over_V_mat3(row,column,:)))

% 11 is plot of the final LDOS
figure(11)
clf
plot(squeeze(ldos_mat3(row,column,:)))
axis tight

% 12 is image of the final LDOS
figure(12)
clf
imagesc(ldos_mat3(:,:,page))

% 13 is surf of the final LDOS
figure(13)
clf
surf(ldos_mat3(:,:,page))