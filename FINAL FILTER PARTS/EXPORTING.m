%% Exporting data

dlmwrite('STEP 1 original.txt',permute(data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 2 3d-smoothed.txt',permute(smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 3 zero-corrected 3d-smoothed.txt',permute(zero_corrected_smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 4 differentiated zero-corrected 3d-smoothed.txt',permute(diff_zero_corrected_smoothed_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 5 I over V.txt',permute(I_over_V_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('STEP 6 LDOS.txt',permute(ldos_mat3(row,column,:),[2 3 1]),'delimiter','\t')
dlmwrite('SUPPLEMENT layerfiltered data.txt',permute(layerfiltered_data_mat3(row,column,:),[2 3 1]),'delimiter','\t')