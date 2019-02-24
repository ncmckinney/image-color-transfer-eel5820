clc
close all
clear all

%load input image
sourceImg   = double(imread('test_yoshi.jpg'));
% sourceImg   = double(imread('kitchen.jpg'));      %%uncomment to use
% sourceImg   = double(imread('green_summer.jpg'));
sourceImgR  = double(sourceImg(:,:,1));
sourceImgG  = double(sourceImg(:,:,2));
sourceImgB  = double(sourceImg(:,:,3));

sourceImgR  = sourceImgR(:);
sourceImgG  = sourceImgG(:);
sourceImgB  = sourceImgB(:);

%load target image
targetImg   = double(imread('lena_color_512.tif'));
% targetImg   = double(imread('tub.jpg'));      %%uncomment to use
% targetImg   = double(imread('autumn_1.jpeg'));
targetImgR  = double(targetImg(:,:,1));
targetImgG  = double(targetImg(:,:,2));
targetImgB  = double(targetImg(:,:,3));

targetImgR  = targetImgR(:);
targetImgG  = targetImgG(:);
targetImgB  = targetImgB(:);

%mean of RGB pixel values
meanSourceImgR = mean(sourceImgR);
meanSourceImgG = mean(sourceImgG);
meanSourceImgB = mean(sourceImgB);

meanTargetImgR = -(mean(targetImgR));
meanTargetImgG = -(mean(targetImgG));
meanTargetImgB = -(mean(targetImgB));

%covariance of RGB pixel values
covSourceImg = cov([sourceImgR sourceImgB sourceImgG]);
covTargetImg = cov([targetImgR targetImgB targetImgG]);
         
%single value decomposition of RBG
[sourceU, sourceS, sourceV] = svd(covSourceImg);
[targetU, targetS, targetV] = svd(covTargetImg);

%rotation matrix
x = [0;...
     0;...
     0;...
     1];
rotSource = sourceU;
rotTarget = inv(targetU);

rotSource = [rotSource; 0 0 0];
rotTarget = [rotTarget; 0 0 0];

rotSource = [rotSource x];
rotTarget = [rotTarget x];

%translation matrix
tranSource = eye(4) + [0    0   0   meanSourceImgR;...
                       0    0   0   meanSourceImgG;...
                       0    0   0   meanSourceImgB;...
                       0    0   0   0];
 
tranTarget = eye(4) + [0    0   0   meanTargetImgR;...
                       0    0   0   meanTargetImgG;...
                       0    0   0   meanTargetImgB;...
                       0    0   0   0];

%scaling matrix
sourceEigenValR = sqrt(sourceS(1));
sourceEigenValG = sqrt(sourceS(5));
sourceEigenValB = sqrt(sourceS(9));

targetEigenValR = 1/(sqrt(targetS(1)));
targetEigenValG = 1/(sqrt(targetS(5)));
targetEigenValB = 1/(sqrt(targetS(9)));

scaleSource = eye(4) .* [sourceEigenValR    0               0   0;...
                         0                  sourceEigenValG 0   0;...
                         0                  0               sourceEigenValB   0;...
                         0                  0               0   1];
                     
scaleTarget = eye(4) .* [targetEigenValR    0               0   0;...
                         0                  targetEigenValG 0   0;...
                         0                  0               targetEigenValB   0;...
                         0                  0               0   1];
%image transform
iTarget = [targetImgR, targetImgG, targetImgB];
iTarget = iTarget.';

iTarget = [iTarget;ones(1,size(iTarget,2))];

iResult = tranSource * rotSource * scaleSource * scaleTarget * rotTarget * tranTarget * iTarget;
iResult = iResult.';

rMin = min(iResult(:));
rMax = max(iResult(:));

[n, m] = size(iResult);

for i = 1:n
    for j = 1:m
        iResult(i,j) = round((2^8 - 1)*((iResult(i,j) - rMin)/(rMax - rMin)));
    end
end

iResult = iResult.';

iResult = iResult(1:3,:);

resultImage = reshape(iResult',size(targetImg));

figure; 
subplot(1,3,1); imshow(uint8(sourceImg)); title('Source Image'); axis off
subplot(1,3,2); imshow(uint8(targetImg)); title('Target Image'); axis off
subplot(1,3,3); imshow(uint8(resultImage)); title('Result After Color Transfer'); axis off
