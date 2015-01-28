%% Visualization - Figures

% 1 and 2 are original data
figure(1)
clf
imagesc(data_mat3(:,:,page))

figure(2)
clf
plot(permute(data_mat3(row,column,:),[3 2 1]))

% 3 and 4 are smoothed (4 (green dotted) has comparison with 2 (red dashed))
figure(3)
clf
imagesc(smoothed_data_mat3(:,:,page))

figure(4)
clf
hold on
plot(permute(data_mat3(row,column,:),[3 2 1]),'Color','r','LineStyle','--')
plot(permute(smoothed_data_mat3(row,column,:),[3 2 1]),'Color','g','LineStyle',':')
hold off

% 5 and 6 are zero-corrected and smoothed (6 has comparison to 4 (green 
% dotted) and 2 (red dashed))
figure(5)
clf
imagesc(zero_corrected_smoothed_data_mat3(:,:,page))

figure(6)
clf
hold on
plot(permute(data_mat3(row,column,:),[3 2 1]),'Color','r','LineStyle','--')
plot(permute(smoothed_data_mat3(row,column,:),[3 2 1]),'Color','g','LineStyle',':')
plot(permute(zero_corrected_smoothed_data_mat3(row,column,:),[3 2 1]))
hold off

% 7 is plot showing result of differentiation
figure(7)
clf
plot(permute(diff_zero_corrected_smoothed_data_mat3(row,column,:),[3 2 1]))

% 8 is plot showing I/V, which will be used in 9 (LDOS)
figure(8)
clf
plot(permute(I_over_V_mat3(row,column,:),[3 2 1]))

% Plot of the final LDOS
figure(9)
clf
plot(permute(ldos_mat3(row,column,:),[3 2 1]))

% Image of the final LDOS
figure(10)
clf
imagesc(ldos_mat3(:,:,page))

% Surf of the final LDOS
figure(11)
clf
surf(ldos_mat3(:,:,page))