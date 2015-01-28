file_path_1 = 'C:\Users\Gaibo\Desktop\STM data analysis\STM image data';
file_path_2 = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name_1 = 'default_2014Jan30-142527_STM-STM_Spectroscopy--12_9.txt';
file_name_2 = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([ file_path_2 '\' file_name_2 ]);

%%

data_mat3 = reshape(data,[ 300 300 200 ]);

%%

figure(1)
clf
imagesc((data_mat3(:,:,1)))

%%

a = 150;
b = 150;
permuted_mat3 = permute(data_mat3(a-1:a+1,b-1:b+1,:),[2 3 1]);
plot(permuted_mat3(1,1,1))

%%

figure(2)
clf
%plot(squeeze(data_mat3(150,150,:)))
plot(permute(data_mat3(150,150,:),[3 2 1]),'Marker','d','Color','k')

%%

n = 150;
m = 150;

figure('Name','Neighboring Nine','NumberTitle','off')
clf
hold on
plot(permute(data_mat3(n-1,m-1,:),[2 3 1]))
plot(permute(data_mat3(n-1,m,:),[2 3 1]))
plot(permute(data_mat3(n-1,m+1,:),[2 3 1]))
plot(permute(data_mat3(n,m-1,:),[2 3 1]))
plot(permute(data_mat3(n,m,:),[2 3 1]))
plot(permute(data_mat3(n,m+1,:),[2 3 1]))
plot(permute(data_mat3(n+1,m-1,:),[2 3 1]))
plot(permute(data_mat3(n+1,m,:),[2 3 1]))
plot(permute(data_mat3(n+1,m+1,:),[2 3 1]))
hold off

%%

concatenation_mat = [permute(data_mat3(n-1,m-1,:),[2 3 1]);
                     permute(data_mat3(n-1,m,:),[2 3 1]);
                     permute(data_mat3(n-1,m+1,:),[2 3 1]);
                     permute(data_mat3(n,m-1,:),[2 3 1]);
                     permute(data_mat3(n,m,:),[2 3 1]);
                     permute(data_mat3(n,m+1,:),[2 3 1]);
                     permute(data_mat3(n+1,m-1,:),[2 3 1]);
                     permute(data_mat3(n+1,m,:),[2 3 1]);
                     permute(data_mat3(n+1,m+1,:),[2 3 1])];

figure('Name','Mean of Neighboring Nine','NumberTitle','off')
clf
plot(mean(concatenation_mat))

%%

figure('Name','Neighboring Nine with Mean','NumberTitle','off')
clf
hold on
plot(permute(data_mat3(n-1,m-1,:),[2 3 1]))
plot(permute(data_mat3(n-1,m,:),[2 3 1]))
plot(permute(data_mat3(n-1,m+1,:),[2 3 1]))
plot(permute(data_mat3(n,m-1,:),[2 3 1]))
plot(permute(data_mat3(n,m,:),[2 3 1]))
plot(permute(data_mat3(n,m+1,:),[2 3 1]))
plot(permute(data_mat3(n+1,m-1,:),[2 3 1]))
plot(permute(data_mat3(n+1,m,:),[2 3 1]))
plot(permute(data_mat3(n+1,m+1,:),[2 3 1]))
plot(mean(concatenation_mat))
hold off

%%

figure(3)
clf
imagesc(mean(data_mat3,3))
plot(squeeze(data_mat3(150,150,:)))

%%

figure(4)
clf
surf((data_mat3(:,:,1)))
shading flat