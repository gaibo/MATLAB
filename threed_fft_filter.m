%% Load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);
data_mat3 = permute(data_mat3,[2 1 3]); % To correct the axes (if needed)

%%

% Transform data with FFT
fft_data_mat3 = fftshift(fftn(data_mat3));

% Construct a filter
s_x = 0.25;
s_y = 0.25;
s_z = 0.5;
[x,y,z] = meshgrid(-1:(2/300):1-(2/300),-1:(2/300):1-(2/300),-1:(2/200):1-(2/200));
filter_3d = exp(-((x/s_x).^2 + (y/s_y).^2 + (z/s_z).^2));

% Visualize it
figure(1)
clf
imagesc(filter_3d(:,:,50))

figure(2)
clf
imagesc(squeeze(filter_3d(:,150,:)))

figure(3)
clf
isosurface(filter_3d,0.5)
axis equal

% Apply filter
filtered_fft_data_mat3 = filter_3d .* fft_data_mat3;

% Transform back and just take real part
smoothed_data_mat3 = real(ifftn(ifftshift(filtered_fft_data_mat3)));

% Visualize again
figure(4)
clf
imagesc(smoothed_data_mat3(:,:,50))

figure(5)
clf
imagesc(data_mat3(:,:,50))

figure(6)
clf
imagesc(squeeze(smoothed_data_mat3(:,150,:)));

figure(7)
clf
plot(squeeze(smoothed_data_mat3(150,150,:)))