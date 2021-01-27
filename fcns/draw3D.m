function draw3D(vol, tic_x, tic_y, tic_z, thre, object)
% thre = 0.2;
% width = 0.5;
% tic_x = linspace(-width,width,K);
% tic_y = linspace(-width,width,K);
% tic_z = linspace(0,100e-12*L, L);
% tic_t = linspace(0, 32e-12*size(sig_in,3)/2, size(sig_in,3)/2);
[tic_X, tic_Y] = meshgrid(tic_x, tic_y);
[I,J] = size(tic_X);
tic_X = reshape(tic_X, [I*J 1]);
tic_Y = reshape(tic_Y, [I*J 1]);
[M,dep] = max(vol, [], 1);
M = squeeze(M);
dep = squeeze(dep);
dep = tic_z(dep);
M = reshape(M, [I*J 1]);
dep = reshape(dep, [I*J 1]);
M = M/max(M(:));
h = figure('color', 'black');
colordef black
% scatter3(dep(M > thre),tic_X(M > thre),tic_Y(M > thre), 60, M(M > thre), 'square','filled');

M_thred = M(M > thre);
[~, loc_min] = min(M_thred(:));
[~, loc_max] = max(M_thred(:));
if object == 'mannequin'
    M_thred(loc_max) = 2;
    M_thred(loc_min) = -0.1;
    load('./colormap/mannequin_cmp.mat');
    z_min = 0;
    z_max = 1;
    x_min = -0.425;
    x_max = 0.425;
    y_min = -0.425;
    y_max = 0.425;
elseif object == 'H'
    M_thred(loc_max) = 1.2;
    M_thred(loc_min) = 0;
    load('./colormap/H_cmp.mat');
    z_min = 0.2;
    z_max = 1.2;
    x_min = -0.3;
    x_max = 0.3;
    y_min = -0.3;
    y_max = 0.3;
end
scatter3(dep(M > thre),tic_X(M > thre),tic_Y(M > thre), 60, M_thred, 'square','filled');
axis([z_min z_max x_min x_max y_min y_max])
set(gca,'xtick',[],'xticklabel',[], 'xcolor', 'red')
set(gca,'ytick',[],'zticklabel',[], 'ycolor', 'red')
set(gca,'ztick',[],'zticklabel',[], 'zcolor', 'red')
box on
colormap(mycmp)
