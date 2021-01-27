clear;clc;
num = 2;
addpath('./fcns');
switch (num)
    case 1
        dataset = load('./data/H.mat');
        depth_min = 0.75;
        depth_max = 0.82;
        threshold = 0.35;
        load('H_cmp.mat');
        object = 'H';
    case 2
        dataset = load('./data/mannequin.mat');
        depth_min = 0.6;
        depth_max = 1;
        threshold = 0.08;
        load('mannequin_cmp.mat')
        object = 'mannequin';
end     

% numbers of iteration
miniter = 1;
maxiter = 300;

% parameters to controll TV normalization
tautv = 1e6;

% parameters from dataset
width = dataset.width;
data = dataset.sig_in;
timeRes = dataset.timeRes;
pulsewidth = dataset.pulsewidth;
radius = dataset.radius;



ximage = sp1400( data, miniter, maxiter, tautv, width, timeRes, pulsewidth, radius );

c = 3e8;
tic_x = linspace(-width, width, size(data, 1));
tic_y = linspace(-width, width, size(data, 2));
tic_z = linspace(0, timeRes*(size(data, 3) - 1)*c/2, size(data, 3));
ximage(tic_z < depth_min | tic_z > depth_max, :, :) = 0;
draw3D(ximage, tic_x, tic_y, tic_z, threshold, object);
