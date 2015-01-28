%% Using Separate Surface and Perpendicular Filters

% 2-D filtering image layers with a constructed filter
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

% 1-D filtering lists of current values with smooth function (adjacent-averaging)
doublefiltered_data_mat3 = zeros(300,300,200);
for row_counter = 1:300
    for column_counter = 1:300
        doublefiltered_data_mat3(row_counter,column_counter,:) = smooth(filtered_data_mat3(row_counter,column_counter,:),15);
    end
end

figure(5)
clf
imagesc(h_surface)

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