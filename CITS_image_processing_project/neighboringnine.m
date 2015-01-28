file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);    % Assumes 300x300 imaging with 200 data measurements at each point

%% Plots nine neighboring sets of I-V data from the data matrix onto the same axes

% x and y are row and column locations respectively of the chosen point (represent physical locations for I-V
% measurements)
x = 150;
y = 150;

figure('Name','Neighboring Nine','NumberTitle','off')
clf
hold on
% The 3rd dimension containing I-V data for the specific point is selected
% and plotted. Permute function serves only to make data plottable.
plot(permute(data_mat3(x-1,y-1,:),[2 3 1]),'Marker','d','Color','y')
plot(permute(data_mat3(x-1,y,:),[2 3 1]),'Marker','d','Color','m')
plot(permute(data_mat3(x-1,y+1,:),[2 3 1]),'Marker','d','Color','c')
plot(permute(data_mat3(x,y-1,:),[2 3 1]),'Marker','d','Color','r')
plot(permute(data_mat3(x,y,:),[2 3 1]),'Marker','d','Color','g')
plot(permute(data_mat3(x,y+1,:),[2 3 1]),'Marker','d','Color','b')
plot(permute(data_mat3(x+1,y-1,:),[2 3 1]),'Marker','d','Color','k')
plot(permute(data_mat3(x+1,y,:),[2 3 1]),'Marker','d','Color',[0.5 0.5 0.5])
plot(permute(data_mat3(x+1,y+1,:),[2 3 1]),'Marker','d','Color',[0.25 0.5 0.75])
hold off

%% Mean of the nine sets is found and plotted

% A 2-dimensional matrix consisting of the nine sets of I-V data is created
concatenation_mat = [permute(data_mat3(x-1,y-1,:),[2 3 1]);
                     permute(data_mat3(x-1,y,:),[2 3 1]);
                     permute(data_mat3(x-1,y+1,:),[2 3 1]);
                     permute(data_mat3(x,y-1,:),[2 3 1]);
                     permute(data_mat3(x,y,:),[2 3 1]);
                     permute(data_mat3(x,y+1,:),[2 3 1]);
                     permute(data_mat3(x+1,y-1,:),[2 3 1]);
                     permute(data_mat3(x+1,y,:),[2 3 1]);
                     permute(data_mat3(x+1,y+1,:),[2 3 1])];

figure('Name','Mean of Neighboring Nine','NumberTitle','off')
clf
plot(mean(concatenation_mat),'Marker','d','Color',[0.13123 0.678738 0.843215],'MarkerFaceColor','k','LineStyle',':')

%% Plots the nine I-V sets together with the mean I-V

figure('Name','Neighboring Nine with Mean','NumberTitle','off')
clf
hold on
plot(permute(data_mat3(x-1,y-1,:),[2 3 1]),'Marker','d','Color','y')
plot(permute(data_mat3(x-1,y,:),[2 3 1]),'Marker','d','Color','m')
plot(permute(data_mat3(x-1,y+1,:),[2 3 1]),'Marker','d','Color','c')
plot(permute(data_mat3(x,y-1,:),[2 3 1]),'Marker','d','Color','r')
plot(permute(data_mat3(x,y,:),[2 3 1]),'Marker','d','Color','g')
plot(permute(data_mat3(x,y+1,:),[2 3 1]),'Marker','d','Color','b')
plot(permute(data_mat3(x+1,y-1,:),[2 3 1]),'Marker','d','Color','k')
plot(permute(data_mat3(x+1,y,:),[2 3 1]),'Marker','d','Color',[0.5 0.5 0.5])
plot(permute(data_mat3(x+1,y+1,:),[2 3 1]),'Marker','d','Color',[0.25 0.5 0.75])
plot(mean(concatenation_mat),'Marker','d','Color',[0.13123 0.678738 0.843215],'MarkerFaceColor','k','LineStyle',':')
hold off