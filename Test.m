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

for k=1:m 
    d = filenames{k};
    d = regexprep(d,'.dcm','');
    d =regexprep(d,'-','_');
    figure; %TODO: wie gibt man den nochmal namen? werden ganz schön viele fenster :D
    imshow(bild.(d))
end
