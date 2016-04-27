clear;
%Pfad des Ordners, in dem die Dicom-Datein liegeb
dcm_path = ('D:\Studium\16SoSe\MedBV\medbv_data\medbv_data\p01\'); 
% Ansammlung Dicom-Dateien
filenames  = dir(fullfile(dcm_path, '*.dcm')); 
% wir brauchen erstmal nur die Namen der Dateien
filenames = {filenames.name}; 
% m = Anzahl aller Dateien
m = numel(filenames);               

for k=1:m 
    d = filenames{k}; 
    f = fullfile(dcm_path , d); 
    dynamische_variable =  regexprep(d(1:14),'-','_');     
    bild.(dynamische_variable)=dicomread( f) ;
    
end 
% Variablen fuer die anisotrope Diffusion
num_iter = 15;
delta_t = 1/7;
kappa = 0.5;
option = 1;

for k=1:m
    d = filenames{k};
    d = regexprep(d,'.dcm','');
    d =regexprep(d,'-','_');  
  % figure,imshow(bild.(d));
    bild_anisodiff = anisodiff2D(bild.(d) ,num_iter,delta_t,kappa,option);
    ui8_bild= uint8(bild_anisodiff);
    figure,imshow(ui8_bild)
  % imshow(fimage)
  % Hough((bild.(d))) 
end
