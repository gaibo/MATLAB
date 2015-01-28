%% [EDITABLE] USER CONFIGURATIONS ARE HERE

% Configure data loading
file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';
row_dimension = 300;    % image size
column_dimension = 300; %     || (probably same as above)
page_dimension = 200;   % number of evenly spaced voltages applied
invert_axes_onoff = 0;  % usually needed to correctly display images (0 to disable, 1 to enable) [DEFAULT 1]

% Configure Principal Components Analysis (Singular Value Decomposition)
pca_denoising_onoff = 1;    % choose whether to use PCA (0 to disable, 1 to enable) [DEFAULT 0]
% If turned on, run this section and the "Load data and shape" section,
% then proceed to edit further configurations before re-running everything

% Configure Fast Fourier Transform filtering
s = 0.3;    % s is proportional to standard deviation (smaller value = stronger filtering) [DEFAULT 0.3]

% Configure Moving Average filtering
window_size = 15;   % moving window size (must be odd) (bigger value = more smoothing) [DEFAULT 15]

% Configure voltage range
V_lowerbound = -1.5;
V_upperbound = 1.5;

% Configure visualization
diagnostic_mode_onoff = 1;  % choose whether to output a figure for every step, useful for checking steps (0 to disable, 1 to enable) [DEFAULT 0]

survey_mode_onoff = 1;  % choose whether to output a range of LDOS images, useful in finding good contrast (0 to disable, 1 to enable) [DEFAULT 0]
ldos_image_lowerbound = 45; % if turned on, the specified image and the next 35 images will be placed onto subplots

row = 150;  % row and column are for plots
column = 150;
page = 50;  % page is for images

% Configure data export
data_export_onoff = 1;  % create a series of files in the MATLAB Current Folder (0 to disable, 1 to enable) [DEFAULT 0]

%% Load data and shape

data = load([file_path '\' file_name]);

% Shape data into stack of images
data_mat3 = reshape(data,row_dimension,column_dimension,page_dimension);

% Correct the axes if necessary
if invert_axes_onoff == 1
    data_mat3 = permute(data_mat3,[2 1 3]);
    data = reshape(data_mat3,row_dimension*column_dimension,page_dimension);    % useful for PCA
else
end

%% [EDITABLE] [ONLY USED IF TURNED ON IN FIRST SECTION] Further configurations for PCA (SVD)

% Run this block of code to create figures and determine the number of
% principal components you want to keep
if pca_denoising_onoff == 1
    [U,S,V] = svd(data,'econ');
    
    figure('Name','PCA Configuration Reference 1','NumberTitle','off')
    clf
    semilogy(diag(S))
    
    U_mat3 = reshape(U,row_dimension,column_dimension,page_dimension);
    figure('Name','PCA Configuration Reference 2','NumberTitle','off')
    clf
    for counter = 1:36
        subplot(6,6,counter)
        imagesc(U_mat3(:,:,counter+0))  % modify the "+0" to see different groups of data
        axis tight
    end
    
    figure('Name','PCA Configuration Reference 3','NumberTitle','off')
    clf
    for counter = 1:36
        subplot(6,6,counter)
        plot(V(:,counter+0))    % modify the "+0" to see different groups of data
        axis tight
    end
    
    PC_cutoff = 11;    % enter chosen last point to keep (cutoff) here [DEFAULT 10]
else
end

%% [ONLY USED IF TURNED ON] Denoise with PCA (SVD)

if pca_denoising_onoff == 1
    denoised_data = U(:,1:PC_cutoff) * S(1:PC_cutoff,1:PC_cutoff) * V(:,1:PC_cutoff)';
    
    % Reshape
    data_mat3 = reshape(denoised_data,row_dimension,column_dimension,page_dimension);
else
end

%% Filter the image layers with FFT

% Transform data with FFT
fft_data_mat3 = fftshift(fftn(data_mat3));

% Construct a filter (a 3-D filter but only affects individual layers)
[x,y,z] = meshgrid(-1:(2/row_dimension):1-(2/row_dimension),-1:(2/column_dimension):1-(2/column_dimension),-1:(2/page_dimension):1-(2/page_dimension));
r_1 = sqrt(x.^2 + y.^2);  % r_1 a matrix of radii
fft_filter = exp(-(r_1/s).^2);

% Apply filter
filtered_fft_data_mat3 = fft_filter .* fft_data_mat3;

% Transform back and just take real part
layerfiltered_data_mat3 = real(ifftn(ifftshift(filtered_fft_data_mat3)));

%% Filter the perpendicular lists with a moving average

% Construct a parabolic filter
r_2 = -(window_size-1)/2:(window_size-1)/2;   % r_2 is essentially a range of radii again
h_perpendicular = 1 - (r_2/((window_size+1)/2)).^2;
area = sum(h_perpendicular);
h_perpendicular = h_perpendicular/area; % normalize

% Prepare to correct for 1-D filter delay by extending end
afterbuffer_size = (window_size-1)/2;
afterbuffered_layerfiltered_data_mat3 = cat(3,layerfiltered_data_mat3,layerfiltered_data_mat3(:,:,end:-1:end-afterbuffer_size+1));

% Apply filter function with constructed filter and crop to finish correction
afterbuffered_fullyfiltered_data_mat3 = filter(h_perpendicular,1,afterbuffered_layerfiltered_data_mat3,[],3);   % process
fullyfiltered_data_mat3 = afterbuffered_fullyfiltered_data_mat3(:,:,afterbuffer_size+1:end);    % take off buffer

%% Correct the zero value (I should be zero when V is zero)

% Calculate correction value (I_error_average)
if bitget(page_dimension,1) % if odd
    I_error_average = fullyfiltered_data_mat3(:,:,(page_dimension+1)/2);
else   % if even
    I_error_below = fullyfiltered_data_mat3(:,:,page_dimension/2);
    I_error_above = fullyfiltered_data_mat3(:,:,page_dimension/2 + 1);
    I_error_average = (I_error_above + I_error_below)/2;  % should ideally be zero; this value will be subtracted from the data
end

% Allocate and fill a matrix with corrected images
zero_corrected_fullyfiltered_data_mat3 = zeros(row_dimension,column_dimension,page_dimension);
for page_counter = 1:page_dimension
    zero_corrected_fullyfiltered_data_mat3(:,:,page_counter) = fullyfiltered_data_mat3(:,:,page_counter) - I_error_average;
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
diff_left_mat3 = diff(zero_corrected_fullyfiltered_data_mat3(:,:,1:end-1),1,3)/V_step;
diff_right_mat3 = diff(zero_corrected_fullyfiltered_data_mat3(:,:,2:end),1,3)/V_step;
diff_zero_corrected_fullyfiltered_data_mat3 = (diff_left_mat3 + diff_right_mat3)/2;

% Add two pages for good measure, so the full range can still be plotted,
% although end points will not really be meaningful anyways
diff_begin = diff(zero_corrected_fullyfiltered_data_mat3(:,:,1:2),1,3)/V_step;
diff_end = diff(zero_corrected_fullyfiltered_data_mat3(:,:,end-1:end),1,3)/V_step;
diff_zero_corrected_fullyfiltered_data_mat3 = cat(3,diff_begin,diff_zero_corrected_fullyfiltered_data_mat3,diff_end);

% Calculate I/V for each point
I_over_V_mat3 = zero_corrected_fullyfiltered_data_mat3./V_range_mat3;

% Divide differentiated data by corresponding I/V values to yield LDOS
ldos_mat3 = diff_zero_corrected_fullyfiltered_data_mat3./I_over_V_mat3;

%% Visualize

% All images are based on page, all plots are based on row and column

% Set up diagnostic mode outputs
if diagnostic_mode_onoff == 1
    % Starting data (if pca is on they will already be somewhat denoised)
    figure('Name','Starting Image (May be Denoised)','NumberTitle','off')
    clf
    imagesc(data_mat3(:,:,page))
    
    figure('Name','Starting Plot (May be Denoised)','NumberTitle','off')
    clf
    plot(squeeze(data_mat3(row,column,:)))
    
    % After layer filtering
    figure('Name','Layer Filtered Image','NumberTitle','off')
    clf
    imagesc(layerfiltered_data_mat3(:,:,page))
    
    figure('Name','Layer Filtered Plot with Comparison','NumberTitle','off')
    clf
    hold on
    plot(squeeze(data_mat3(row,column,:)),'Color','r','LineStyle','--')
    plot(squeeze(layerfiltered_data_mat3(row,column,:)))
    hold off
    
    % After perpendicular list filtering
    figure('Name','Fully Filtered Image','NumberTitle','off')
    clf
    imagesc(fullyfiltered_data_mat3(:,:,page))
    
    figure('Name','Fully Filtered Plot with Comparison','NumberTitle','off')
    clf
    hold on
    plot(squeeze(data_mat3(row,column,:)),'Color','r','LineStyle','--')
    plot(squeeze(layerfiltered_data_mat3(row,column,:)),'Color','g','LineStyle',':')
    plot(squeeze(fullyfiltered_data_mat3(row,column,:)))
    hold off
    
    % After zero-correction
    figure('Name','Zero-Corrected Fully Filtered Image','NumberTitle','off')
    clf
    imagesc(zero_corrected_fullyfiltered_data_mat3(:,:,page))
    
    figure('Name','Zero-Corrected Fully Filtered Plot with Comparison','NumberTitle','off')
    clf
    hold on
    plot(squeeze(data_mat3(row,column,:)),'Color','r','LineStyle','--')
    plot(squeeze(layerfiltered_data_mat3(row,column,:)),'Color','g','LineStyle',':')
    plot(squeeze(fullyfiltered_data_mat3(row,column,:)),'Color','k')
    plot(squeeze(zero_corrected_fullyfiltered_data_mat3(row,column,:)))
    hold off
    
    % After differentiation
    figure('Name','Differentiated Zero-Corrected Fully Filtered Plot','NumberTitle','off')
    clf
    plot(squeeze(diff_zero_corrected_fullyfiltered_data_mat3(row,column,:)))
    
    % I/V made from the zero-corrected fullyfiltered data, which will be used to make 11 (LDOS)
    figure('Name','I/V Zero-Corrected Fully Filtered Plot','NumberTitle','off')
    clf
    plot(squeeze(I_over_V_mat3(row,column,:)))
else
end

% Set up survey mode outputs
if survey_mode_onoff == 1
    % survey of 36 subplots of LDOS images
    figure('Name',['LDOS Images Starting with Page = ',num2str(ldos_image_lowerbound)],'NumberTitle','off')
    clf
    for counter = 1:36
        subplot(6,6,counter)
        imagesc(ldos_mat3(:,:,ldos_image_lowerbound-1 + counter))
    end
else
end

% The following will be outputs regardless of initial selections

% Plot of the final LDOS
figure('Name','LDOS Plot','NumberTitle','off')
clf
plot(squeeze(ldos_mat3(row,column,:)))

% Image of the final LDOS
figure('Name','LDOS Image','NumberTitle','off')
clf
m = ldos_mat3(:,:,page);
m_mean = mean(mean(m));
m_std = std( reshape(m,1,numel(m)));
imagesc(m)
caxis([ m_mean-1*m_std m_mean+1*m_std ])
%caxis([ -100 100 ])

% Surf of the final LDOS
figure('Name','LDOS Surf','NumberTitle','off')
clf
surf(ldos_mat3(:,:,page))

%% Exporting visualized data (only exports specified arrays for testing)

if data_export_onoff == 1
    dlmwrite('STEP 1 original or pca denoised.txt',permute(data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
    dlmwrite('STEP 2 layerfiltered data.txt',permute(layerfiltered_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
    dlmwrite('STEP 3 fullyfiltered.txt',permute(fullyfiltered_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
    dlmwrite('STEP 4 zero-corrected fullyfiltered.txt',permute(zero_corrected_fullyfiltered_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
    dlmwrite('STEP 5 differentiated zero-corrected fullyfiltered.txt',permute(diff_zero_corrected_fullyfiltered_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
    dlmwrite('STEP 6 I over V.txt',permute(I_over_V_mat3(row,column,:),[2 3 1]),'delimiter','\t')
    dlmwrite('STEP 7 LDOS.txt',permute(ldos_mat3(row,column,:),[2 3 1]),'delimiter','\t')
else
end