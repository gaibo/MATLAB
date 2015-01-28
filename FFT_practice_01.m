
%% 1D

IO_rate = 1E6; %[samples/sec]
N = 16;
num_samples = 2^N;
time_max = num_samples/IO_rate;
time_vec = 0 : time_max/num_samples : time_max-time_max/num_samples;
w = 50E3; %frequency [Hz]
signal = sin(2*pi*w*time_vec)+sin(2*pi*3.5*w*time_vec)+rand(size(time_vec))-.5;

figure(1)
clf
plot(time_vec,signal,'.-')

F_signal = fftshift(fft(signal));

w_vec = -IO_rate/2 : IO_rate/num_samples : IO_rate/2 - IO_rate/num_samples;

figure(2)
clf
plot(w_vec,abs(F_signal))
axis tight


%% 2D

[x,y] = meshgrid(0:1/255:1,0:1/255:1);
z = sin(2*pi*3*x) + sin(2*pi*10*y);
z = z +5*(rand(size(z))-.5);

figure(3)
clf
imagesc(z)

F_z = fftshift(fft2(z));

figure(4)
clf
imagesc(abs(F_z))

s = .25;
[F_x,F_y] = meshgrid(-1 : 2/256 : 1 - 2/256,-1 : 2/256 : 1 - 2/256);
F_r = sqrt(F_x.^2 + F_y.^2);
filter = exp(-(F_r/s).^2);

figure(5)
clf
imagesc(filter)

filtered_F_z = filter.*F_z;


figure(6)
clf
imagesc(abs(filtered_F_z))


filtered_z = ifft2(ifftshift(filtered_F_z));

figure(7)
clf
imagesc(filtered_z)


%% 3D

clear all
[x,y,z] = meshgrid(1:300,1:300,1:200);

F_x = fftn(x);