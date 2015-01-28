file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);    % Assumes 300x300 imaging with 200 data measurements at each point

%%

% x and y are row and column locations respectively of the chosen point (represent physical locations for I-V
% measurements) (not in Cartesian coordinates)
x = 150;
y = 150;

% layers is the number of layers of neighbors to the point wanted (for the first layer, there
% are 8 neighbors, for second layer, there are 24, etc.)
layers = 10;

concatenated_mat = zeros((2*layers+1)^2,200);    % Allocating a matrix of sufficient size to collect all the neighboring I-V data
counter = 0;    % Setting a counter

% Loops for collecting and plotting a series of data
figure('Name',['Neighboring ',num2str(layers),' Layer(s)'],'NumberTitle','off')
clf
hold on
for x_parameter = x-layers:x+layers
    for y_parameter = y-layers:y+layers
        counter = counter + 1;
        row_mat = permute(data_mat3(x_parameter,y_parameter,:),[2 3 1]);    %Permute function used to make 3rd dimension into a plottable and accessible row matrix
        concatenated_mat(counter,:) = row_mat;  % Concatenated matrix composed of neighboring I-V sets
        plot(row_mat)
    end
end
hold off

%%

% Plotting the mean I-V
figure('Name',['Mean of Neighboring ',num2str(layers),' Layer(s)'],'NumberTitle','off')
clf
plot(mean(concatenated_mat))

%% To better reduce noise in adjacent-averaging, neighbors are weighted according to layer location
%{
weight = zeros(1,layers);   % Allocation in preparation for a standard row of weights
for location = 1:layers
    weight(1,location) = 1 - ((location)/(layers+1))^2;   % Simple parabolic weighting
end
weight_mat = [fliplr(weight),1,weight]; % A row matrix is put together for easy multiplication later

% Plotting the weighted mean I-V
figure('Name',['Weighted Mean of Neighboring ',num2str(layers),' Layer(s)'],'NumberTitle','off')
clf
weighted_mean = (weight_mat*concatenated_mat)/sum(weight_mat);
plot(weighted_mean)
%}