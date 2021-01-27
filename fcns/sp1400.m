function ximage = sp1400(data, miniter, maxiter, tautv, width, timeRes, pulseWidth, radius )
bin = size(data,3); 
N = size(data,1);                     % pixel number of x,y
c = 3e8;                  % speed of light

data(data<0) = 0;
grid_z = repmat(linspace(0,size(data,3),size(data,3))', [1 size(data,1) size(data,2)]);
data = permute(data, [3 2 1]);
data = data.*grid_z.^2;
data = permute(data, [2 3 1]);

beamspot = definebeam(N,width,radius);
psf = definePsf(N,width,bin,timeRes,c,beamspot);          % accept signal from point object
[mtx,mtxi] = resamplingOperator(bin);% transform between t^2 domain and t domain
sigmaBin = ceil(pulseWidth*(10^-12)/timeRes/2/sqrt(2*log(2)));
jit = normpdf(-1000:1000, 0, sigmaBin);
jit = reshape(jit, [1 1 2001]);
% load('jit21.mat');
A = @(x) forwardmodel(x,psf,mtxi,jit,N,bin);           % forwardmodel of NLOS imaging
AT = @(x) forwardmodel(x,psf,mtxi,jit,N,bin);  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     signal
signaltype = 'external';
switch signaltype
    case 'truth'
        truth = zeros(N,N,bin);      % groundtruth in squzrez domain
        truth(12:22,12:17,200) = 1;  % 200 = 1.0861m
        truth(12:22,17:22,200) = 1; 
        y = A(truth)*1000;                                
    case 'external'
%         for k = 1:1
%             sig = sig(:,:,1:2:end) + sig(:,:,2:2:end);
%         end
%         load('731data.mat');
%         y = zeros(2*N, 2*N,bin);
%         y(33:96, 33:96,:) = data;
        y = data;
        truth = y;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set regularization parameters and iteration limit:
% tautv = 0;
% miniter = 15; 
% maxiter = 100 ;
tolerance = 1e-8;
stopcriterion = 3;
verbose = 1;        
finit = y;

ximage ...
     = spiral_tap(N,N,bin, y,A,tautv,psf,jit,mtx, miniter, maxiter, ...
     'noisetype','gaussian',...
     'penalty','TV',...
     'AT',AT,...    
     'maxiter',maxiter,...
     'Initialization',finit,...
     'miniter',miniter,...
     'stopcriterion',stopcriterion,...
     'tolerance',tolerance,...
     'monotone',1,...
     'saveobjective',1,...
     'savereconerror',1,...
     'savecputime',1,...
     'savesolutionpath',0,...
     'truth',truth,...
     'verbose',verbose);
end

function beamspot = definebeam(N,width,radius)
[x,y] = meshgrid(1:N,1:N);
R = N*radius/width/4;
beamspot = exp(-((x-N/2-1).^2/R^2+(y-N/2-1).^2/R^2));
mask = beamspot>0.01;
beamspot = beamspot.*mask;
end

function psf = definePsf(N,width,bin,timeRes,c,beamspot)
    linexy = linspace(-2*width,2*width,2*N-1);            % linspace of scan range
    range = (bin*timeRes*c/2)^2;                    % total range of t^2 domain: bin^2*timeRes^2
    gridrange = bin*(timeRes*c/2)^2;                % one grid in t^2 domain: bin*timeRes^2
    [xx,yy,squarez] = meshgrid(linexy,linexy,0:gridrange:range);
    blur = abs((xx).^2+(yy).^2-squarez+0.0000001);
    blur = double(blur == repmat(min(blur,[],3),[ 1 1 bin+1 ]));
    blur = blur(:,:,1:bin);                               % generate light-cone
    psf = zeros(2*N-1,2*N-1,2*bin);                       
    psf(:,: ,bin+1:2*bin) = blur;                          % place it at center
    beam = zeros(N,N,1);
    beam(:,:,1) = beamspot;
    psf = convolution(psf,beam,1);
end


function [mtx,mtxi] = resamplingOperator(bin)
mtx = sparse([],[],[],bin^2,bin,bin^2);
x = 1:bin^2;
mtx(sub2ind(size(mtx),x,ceil(sqrt(x)))) = 1;
mtx  = spdiags(1./sqrt(x)',0,bin^2,bin^2)*mtx;
mtxi = mtx';

K = log(bin)/log(2);
for k = 1:K
    mtx  = 0.5*(mtx(1:2:end,:)  + mtx(2:2:end,:));
    mtxi = 0.5*(mtxi(:,1:2:end) + mtxi(:,2:2:end));
end
end


function Ax = forwardmodel(x,psf,mtxi,jit,N,bin)
    d = convolution(psf,x,2);
    pd = permute(d,[3 2 1]);             % convert signal to t domain
    mpd = reshape(mtxi*pd(:,:),[bin N N]);
    b = permute(mpd,[3 2 1]);
    Ax = convn(b,jit,'same');            % convolution with jitter

end
  
function [ sb ] = convolution( A ,B, type )
    [yb,xb,zb] = size(A);
    [ys,xs,zs] = size(B);
    pada = zeros(yb,xb,zb);
    qq = floor(yb/2)+1-floor(ys/2);
    ww = floor(yb/2)+floor(ys/2)+mod(ys,2);
    ee = floor(xb/2)+1-floor(xs/2);
    rr = floor(xb/2)+floor(xs/2)+mod(xs,2);
    tt = floor(zb/2)+1-floor(zs/2);
    yy = floor(zb/2)+floor(zs/2)+mod(zs,2);
    pada(qq:ww,ee:rr,tt:yy) = B;
    fs = ifftshift(fftn(fftshift(pada)));  
    fb = ifftshift(fftn(fftshift(A)));
    if type == 1
        sb = ifftshift(ifftn(fftshift(fs.*fb))); %结果大小等于big
    else
        sb = ifftshift(ifftn(fftshift(fs.*fb))); 
        sb = sb(qq-1:ww-1,ee-1:rr-1,tt-1:yy-1);  %从结果中取出中间那块，大小等于small
    end

end

