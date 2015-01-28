% For configuring the convolution kernel for filtering
% Sizes of the convolution kernel must be odd ([kernel_surface_size kernel_surface_size kernel_height_size])
kernel_surface_size = 7;
kernel_height_size = 15;
std_dev = 0.5;  % standard deviation of Gaussian function used to weight

% Constructing a convolution kernel
[x,y,z] = meshgrid(-1:2/(kernel_surface_size-1):1,-1:2/(kernel_surface_size-1):1,-1:2/(kernel_height_size-1):1);
r_mat3 = sqrt(x.^2 + y.^2 + z.^2);
h_mat3 = exp(-(r_mat3/std_dev).^2);
normalizer = sum(sum(sum(h_mat3)));
h_mat3 = h_mat3/normalizer;

% Filtering data
smoothed_data_mat3 = imfilter(data_mat3,h_mat3);