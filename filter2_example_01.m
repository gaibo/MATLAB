
clear all

%% load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);

%% build filter

N = 21;
s = .5;
[x,y] = meshgrid(-1:2/(N-1):1,-1:2/(N-1):1);
r = sqrt(x.^2 + y.^2);
h = exp(-(r/s).^2);
volume = sum(sum(h));
h = h/volume;

figure(1)
clf
imagesc(h)
axis tight

%% apply filter to one layer

data = data_mat3(:,:,1);

figure(2)
clf
imagesc(data)

filtered_data = filter2(h,data);

figure(3)
clf
imagesc(filtered_data)


