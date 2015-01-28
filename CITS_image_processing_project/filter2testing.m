file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);
data_mat3 = reshape(data,[300 300 200]);
data_mat3_correctimage = permute(data_mat3,[2 1 3]);

%%

layers = 3;

%{
[x_parabolic,y_parabolic] = meshgrid(-1:(1/layers):1,-1:(1/layers):1);
radius = sqrt(x_parabolic.^2 + y_parabolic.^2);
h = 1 - (radius./1.5).^2;
volume = sum(sum(h));
h_normalized = h/volume;
%}
std_dev = 0.5;
[x_gaussian,y_gaussian] = meshgrid(-1:(1/layers):1,-1:(1/layers):1);
radius = sqrt(x_gaussian.^2 + y_gaussian.^2);
h = exp(-(radius/std_dev).^2);
volume = sum(sum(h));
h_normalized = h/volume;


concatenated_mat3 = zeros(300,300,200);

for page = 1:200
    data = data_mat3_correctimage(:,:,page);
    concatenated_mat3(:,:,page) = filter2(h_normalized,data);
end

%{
x = 150;
y = 150;

mean_mat = zeros((2*layers+1)^2,200);
figure('Name','Unfiltered, Unweighted Mean','NumberTitle','off')
clf
mean_counter = 0;
for mean_x = x-layers:x+layers
    for mean_y = y-layers:x+layers
        mean_counter = mean_counter + 1;
        mean_mat(mean_counter,:) = permute(data_mat3_correctimage(mean_x,mean_y,:),[2 3 1]);
    end
end
plot(mean(mean_mat))
%}

%{
figure('Name','Gaussian Filtered','NumberTitle','off')
clf
plot(permute(concatenated_mat3(x,y,:),[2 3 1]))

figure('Name','Both Together','NumberTitle','off')
clf
hold on
plot(mean(mean_mat),'b')
plot(permute(concatenated_mat3(150,150,:),[2 3 1]),'r')
plot(permute(data_mat3_correctimage(150,150,:),[2 3 1]),'k')
hold off
%}

%{
figure('Name','Unprocessed CITS Image at 50th Voltage Step','NumberTitle','off')
clf
imagesc(data_mat3_correctimage(:,:,50))
%}

figure('Name','Filtered CITS Image at 50th Voltage Step','NumberTitle','off')
clf
imagesc(concatenated_mat3(:,:,50))