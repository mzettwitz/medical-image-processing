function [index, maxGradient] = maxGrad(x,y, I)
%DISCGRAD 
%   Find the maximum gradient on a line segment
%   The algorithms uses the forward/backward/central gradient approximation

%INPUT  Matrix as set of points on a line
%OUTPUT position (index) and maximum gradient

maxGradient = 0;
index = 1;
grad = 0;

for i = 1 : size(x)
   pre = i-1;
   suc = i+1;
   
   v = I(x(i),y(i));
   
   % forward
   if(pre == 0)
       vSuc = I(x(suc),y(suc));
       grad = abs(vSuc - v);
   end
   
   % center
   if(pre ~= 0 & suc ~= size(x)+1)
       vSuc = I(x(suc),y(suc));
       vPre = I(x(pre),y(pre));
       grad = abs((vSuc - vPre)/2);
   end;
   
   % backward
   if(suc == size(x)+1)
       vPre = I(x(pre),y(pre));
       grad = abs(v - vPre); 
   end
   
   % update max;
   if(grad > maxGradient)
      maxGradient = grad;
      index = i;
   end
   
end

end

