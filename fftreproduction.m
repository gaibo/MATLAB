%% Load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);
data_mat3 = permute(data_mat3,[2 1 3]); % To correct the axes

%% 1-Dimensional

% Create a realistic convoluted signal and show it
IO_rate = 500;
N = 10;
num_samples = 2^N;  % number of samples for FFT has to be 2^N
total_time = num_samples/IO_rate;
time_vec = 0 : total_time/num_samples : total_time - total_time/num_samples;    % this way an evenly spaced timing table with correct number of values is created
freq = 5000;

signal = sin(2*pi*freq*time_vec) + sin(2*pi*freq*5234*time_vec) + rand(size(time_vec)) - 0.43234;   % convoluted but patterned signal is created. 2*pi*freq makes period 1/freq.

figure(1)
clf
plot(time_vec,signal,'.-')
axis tight

% Process with fft and show it
fft_signal = fftshift(fft(signal));
freq_vec = -IO_rate/2 : IO_rate/num_samples : IO_rate/2 - IO_rate/num_samples;

figure(2)
clf
plot(freq_vec,abs(fft_signal))
axis tight

%% 2-Dimensional

% Create a convoluted image and show it
[x,y] = meshgrid(0:1/255:1,0:1/255:1);  % 256 is 2^8
z = sin(2*pi*3.5*x) + sin(2*pi*4324*y) - 5*rand(size(x)) + 0.59231;

figure(3)
clf
imagesc(z)

% Do fft to it and show it
fft_z = fftshift(fft2(z));

figure(4)
clf
imagesc(abs(fft_z))

% Create a filter to clean up fft_z processed signal and show it
s = .25;
[F_x,F_y] = meshgrid(-1 : 2/256 : 1 - 2/256,-1 : 2/256 : 1 - 2/256);
r = sqrt(F_x.^2 + F_y.^2);
filter_2d = exp(-(r/s).^2);

figure(5)
clf
imagesc(filter_2d)

% Filter the fft image and show it
filtered_fft_z = filter_2d.*fft_z;

figure(6)
clf
imagesc(abs(filtered_fft_z))

% Shift fft back to original domain and show the cleaned up signal
filtered_z = ifft2(ifftshift(filtered_fft_z));

figure(7)
clf
imagesc(filtered_z)

%% 3-Dimensional

% Specify a page (image layer) for visualization
page = 1;

% Perform fft on CITS data and show one transformed image
fft_data_mat3 = fftshift(fftn(data_mat3));

figure(8)
clf
imagesc(abs(fft_data_mat3(:,:,page)))

% Create 3-D filter for data and show one layer of it
sx = .25;
sy = .25;
sz = .25;
[x,y,z] = meshgrid(-1 : 2/300 : 1-2/300,-1 : 2/300 : 1-2/300,-1 : 2/200 : 1-2/200);
r = sqrt(x.^2 + y.^2 + z.^2);
filter_3d = exp(-((x/sx).^2 + (y/sy).^2 + (z/sz).^2));

figure(9)
clf
imagesc(filter_3d(:,:,page))

figure(10)
clf
imagesc(squeeze(filter_3d(:,150,:)))

figure(20)
clf
isosurface(filter_3d,.5)
axis equal

% Filter the transformed CITS data matrix
filtered_fft_data_mat3 = filter_3d.*fft_data_mat3;

% Transform matrix back to original domain and compare an image
filtered_data_mat3 = real(ifftn(ifftshift(filtered_fft_data_mat3)));

figure(11)
clf
imagesc(filtered_data_mat3(:,:,page))

figure(12)
clf
imagesc(data_mat3(:,:,page))

figure(13)
clf
plot(squeeze(filtered_data_mat3(150,150,:)))