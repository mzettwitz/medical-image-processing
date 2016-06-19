close all;
clear;

% add path to example data
file = mfilename('fullpath');
[pathstr,name,ext] = fileparts(file);
cd(pathstr);
parent = pwd;
addpath(genpath(parent));

patient = 'p03'; %p01,p02,p03
%Pfad des Ordners, in dem die Dicom-Datein liegen
dcm_path = (strcat('../data/',patient)); 
filenames  = dir(fullfile(dcm_path, '*.dcm')); 
% wir brauchen erstmal nur die Namen der Dateien
filenames = {filenames.name}; 
% m = Anzahl aller Dateien
m = numel(filenames);               
%m = 50;

% =================== read ground truth
pat_number = patient(3);
gt_path = strcat('../ground_truth/p', pat_number, '_needle_positions.csv');
gt_data = csvread(gt_path);

for k=1:m 
    d = filenames{k}; 
    f = fullfile(dcm_path, d); 
    dynamische_variable =  regexprep(d(1:14),'-','_');     
    bild.(dynamische_variable)=dicomread( f) ;
    
end 
% Variablen fuer die anisotrope Diffusion
num_iter = 20;
delta_t = 1/50;
kappa = 8;
option = 1;

for k=1:m
    d = filenames{k};
    d = regexprep(d,'.dcm','');
    d = regexprep(d,'-','_');  
    
    img = bild.(d);
    
    % convert into double for window/leveling
    img_d = im2double(img);
    img_adj = imadjust(img_d, [0.49 0.525]); %[0.5045 0.5155]
    
    % anisotropic diffusion filtering
    %img_filt = anisodiff2D(img_adj ,num_iter,delta_t,kappa,option);
    %img_filt = ordfilt2(img_adj,15,ones(5,5));
    
    % morphological closing
    se = strel('rectangle', [2 4]);
    %img_morph = imclose(img_filt, se);
    
    if mod(k,10) == 0
       %imtool(img_d); %find nice threshold for window/level every 10th img
    end
    
    % print to compare
    %figure
    %subplot(2,2,1), imshow(img,[]), title('original')
    %subplot(2,2,2), imshow(img_adj), title('window/level')
    %subplot(2,2,3), imshow(img_filt), title('filtered')
    %subplot(2,2,4), imshow(img_morph), title('morph')
    %if(k <= m && k > 10)
   %    filname = filenames{k-1};
   %    sub_img = subtraction(d,filname,bild);
   %    titel = num2str(d,filname);
   %    figure, imshow (sub_img,[]), title (titel);
   % end
   
  % ground truth plot
   x = [gt_data(k,1) gt_data(k,3)];
   y = [gt_data(k,2) gt_data(k,4)];
   figure, imshow(im2int16(img_adj),[]), title('window/level'), hold on
   plot(x, y, 'Color', 'r','LineWidth',2)
   hold off
   
   % hough transformation
   Hough(im2int16(img_adj)); 
end