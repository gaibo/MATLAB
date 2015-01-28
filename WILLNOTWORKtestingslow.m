file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);

%%

layers = 3;
concatenated_mat3 = zeros((2*layers+1)^2,(2*layers+1)^2,200);
concatenated_mat = zeros((2*layers+1)^2,200);

weight_mat = zeros(1,(2*layers+1)^2);
for layer_counter_2 = 1:layers
    weight_mat(1,(2*layer_counter_2-1)^2:(2*layer_counter_2-1)^2 + 8*layer_counter_2-1) = 1 - ((layer_counter_2)/(layers+1))^2;
end
weight_mat(1,(2*layers+1)^2) = 1;

for x = 1:300
    for y = 1:300
        concatenated_mat_row_counter = 0;
        for layer_counter = 1:layers
            for x_parameter = x-layer_counter
                for y_parameter = y-layer_counter:y+layer_counter-1
                    row_mat = permute(data_mat3(x_parameter,y_parameter,:),[2 3 1]);
                    concatenated_mat_row_counter = concatenated_mat_row_counter + 1;
                    concatenated_mat(concatenated_mat_row_counter,:) = row_mat;
                end
            end
            for y_parameter = y+layer_counter
                for x_parameter = x-layer_counter:x+layer_counter-1
                    row_mat = permute(data_mat3(x_parameter,y_parameter,:),[2 3 1]);
                    concatenated_mat_row_counter = concatenated_mat_row_counter + 1;
                    concatenated_mat(concatenated_mat_row_counter,:) = row_mat;
                end
            end
            for x_parameter = x+layer_counter
                for y_parameter = y-layer_counter+1:y+layer_counter
                    row_mat = permute(data_mat3(x_parameter,y_parameter,:),[2 3 1]);
                    concatenated_mat_row_counter = concatenated_mat_row_counter + 1;
                    concatenated_mat(concatenated_mat_row_counter,:) = row_mat;
                end
            end
            for y_parameter = y-layer_counter
                for x_parameter = x-layer_counter+1:x+layer_counter
                    row_mat = permute(data_mat3(x_parameter,y_parameter,:),[2 3 1]);
                    concatenated_mat_row_counter = concatenated_mat_row_counter + 1;
                    concatenated_mat(concatenated_mat_row_counter,:) = row_mat;
                end
            end
        end
        row_mat = permute(data_mat3(x,y,:),[2 3 1]);
        concatenated_mat_row_counter = concatenated_mat_row_counter + 1;
        concatenated_mat(concatenated_mat_row_counter,:) = row_mat;

        weighted_mean = (weight_mat * concatenated_mat)/sum(weight_mat);
        concatenated_mat3(x,y,:) = weighted_mean;
    end
end

%%

figure('Name','Unfiltered Slow')
clf
plot(permute(data_mat3(150,150,:),[2 3 1]))

figure('Name','Filtered Slow')
clf
plot(permute(concatenated_mat3(150,150,:),[2 3 1]))

figure('Name','Both Together Slow')
clf
hold on
plot(permute(data_mat3(150,150,:),[2 3 1]))
plot(permute(concatenated_mat3(150,150,:),[2 3 1]))
hold off