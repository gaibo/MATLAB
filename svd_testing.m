%% Load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);

[U,S,V] = svd(data,'econ');

%% Check some visuals

figure(1)
clf
semilogy(diag(S))

U_mat3 = reshape(U,300,300,200);
figure(2)
clf
for counter = 1:9
    subplot(3,3,counter)
    imagesc(U_mat3(:,:,counter+5))
    axis tight
end

figure(3)
clf
for counter = 1:9
    subplot(3,3,counter)
    plot(V(:,counter+5))
    axis tight
end

%% Process it

PC_cutoff = 11;
denoised_data = U(:,1:PC_cutoff) * S(1:PC_cutoff,1:PC_cutoff) * V(:,1:PC_cutoff)';
denoised_data_mat3 = reshape(denoised_data,300,300,200);

figure(4)
clf
imagesc(denoised_data_mat3(:,:,50))

figure(5)
clf
plot(squeeze(denoised_data_mat3(150,150,:)))