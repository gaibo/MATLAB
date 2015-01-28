%% Load data

file_path = 'C:\Users\Gaibo\Desktop\STM data analysis\CITS image data';
file_name = 'NO HEADER I(V) TraceUp Wed Feb 19 13_09_41 2014 [167-1]  STM_Spectroscopy STM.txt';

data = load([file_path '\' file_name]);

[U,S,V] = svd(data,'econ');

recomp_data = U*S/V;

%% Are they the same

if single(sum(recomp_data)) == single(sum(data))
    disp('They are pretty much the same')
else
    disp('NOPE')
end

if single(sum(sum(recomp_data))/sum(sum(data))) == single(1)
    disp('They are pretty much the same')
else
    disp('NOPE')
end

%% Visuals

figure(1)
clf
semilogy(diag(S))

figure(2)
clf
count = 0;
for k1 = 1 : 9
    count = count + 1;
    subplot(3,3,count)
    plot(V(:,k1))
    axis tight
end

U_mat = reshape(U,300,300,200);


figure(3)
clf
count = 0;
for k1 = 1 : 9
    count = count + 1;
    subplot(3,3,count)
    imagesc(U_mat(:,:,k1))
    axis tight
end

num_PC = 10;
data_dn =  U(:,1:num_PC)*S(1:num_PC,1:num_PC)*V(:,1:num_PC)';
data_dn = reshape(data_dn,300,300,200);


figure(6)
clf
imagesc(data_dn(:,:,1))

figure(7)
clf
plot(squeeze(data_dn(150,150,:)))

% figure(4)
% clf
% plot(U(50,:))
% 
% figure(5)
% clf
% plot(U(:,50))