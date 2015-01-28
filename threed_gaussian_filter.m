%% Load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);
data_mat3 = permute(data_mat3,[2 1 3]); % To correct the axes

%% Using imfilter (Probably Should Not Work)

std_dev = 0.5;
[x,y,z] = meshgrid(-1:2/6:1,-1:2/6:1,-1:2/14:1);
r = sqrt(x.^2 + y.^2 + z.^2);
h_3d = exp(-(r/std_dev).^2);
volume_4d = sum(sum(sum(h_3d)));
h_3d = h_3d/volume_4d;

filtered_data_mat3 = imfilter(data_mat3,h_3d);

figure(1)
clf
imagesc(h_3d(:,:,10))

figure(2)
clf
plot(permute(h_3d(4,4,:),[2 3 1]))

figure(3)
clf
imagesc(filtered_data_mat3(:,:,50))

figure(4)
clf
plot(permute(filtered_data_mat3(150,150,:),[2 3 1]))

%% Using Separate Surface and Perpendicular Filters

% 2-D filtering images with filter2
std_dev = 0.5;
[x,y] = meshgrid(-1:2/6:1,-1:2/6:1);
r = sqrt(x.^2 + y.^2);
h_surface = exp(-(r/std_dev).^2);
volume = sum(sum(h_surface));
h_surface = h_surface/volume;

filtered_data_mat3 = zeros(300,300,200);
for page_counter = 1:200
    filtered_data_mat3(:,:,page_counter) = filter2(h_surface,data_mat3(:,:,page_counter));
end

% 1-D filtering lists of current values with filter (order of the two 
% techniques doesn't actually matter)
std_dev = 0.5;
x = -1:2/14:1;
h_perpendicular = exp(-(x/std_dev).^2);
area = sum(h_perpendicular);
h_perpendicular = h_perpendicular/area;

doublefiltered_data_mat3 = zeros(300,300,200);
for row_counter = 1:300
    for column_counter = 1:300
        doublefiltered_data_mat3(row_counter,column_counter,:) = filtfilt(h_perpendicular,1,filtered_data_mat3(row_counter,column_counter,:));
    end
end

figure(5)
clf
imagesc(h_surface)

figure(6)
clf
plot(h_perpendicular)

figure(7)
clf
imagesc(filtered_data_mat3(:,:,50))

figure(8)
clf
imagesc(doublefiltered_data_mat3(:,:,50))

figure(9)
clf
hold on
plot(permute(doublefiltered_data_mat3(150,150,:),[2 3 1]))
plot(permute(data_mat3(150,150,:),[2 3 1]))
hold off

figure(10)
clf
hold on
plot(permute(filtered_data_mat3(150,150,:),[2 3 1]))
plot(permute(data_mat3(150,150,:),[2 3 1]))
hold off