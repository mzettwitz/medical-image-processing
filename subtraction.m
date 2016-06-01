function [ sub_filt ] = subtraction( d,filename)
%SUBTRACTION Summary of this function goes here
%   Detailed explanation goes here


d_pre = regexprep(filename,'.dcm','');
         d_pre = regexprep(d_pre,'-','_');
         d =regexprep(d,'.dcm','');
         subtract = d - d_pre;
         subtract = im2double(subtract);
         sub_img = ordfilt2(subtract,15,ones(5,5));
         
          sub_filt = im2int16(sub_img);
%         
       %  figure
       %  imtool(sub_filt)
         
%         %if(subtract - )
end

