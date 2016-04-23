function y = Hough(bild)

%bild =dicomread('IMG-0015-00001.dcm');
%figure,imshow(bild);
%Übersicht Metadaten
%dicomdisp('IMG-0013-00001.dcm');

%geschätzter Grauwert der Nadel
nadel= 950;
v = 400;

M = bild;

for i=1:numel(M)
    if (M(i)<(nadel-v))||(M(i)>(nadel+v))
        M(i) = -2048;
    end
end

%figure,imshow(M);

%Verbesserungsmöglichkeiten:
J = imboxfilt(imadjust(bild));
%figure, imshow(J);

K = histeq(bild);
%figure, imshow(K);

L = imboxfilt(bild,11);

%verwendetes Bild für Transformation:
rotI=M;

%mögliche Methoden: Canny,log,zerocross

BW = edge(rotI,'canny');

[H,theta,rho] = hough(BW);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

%MinLength erhöhen reduziert Anzahl falscher Kanten
lines = houghlines(BW,theta,rho,P,'FillGap',15,'MinLength',15);

%angezeigt wird das optisch bessere Bild, nicht das für die
%Hough-Transformation genutzte
figure, imshow(J), hold on
max_len = 0;
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

   % Determine the endpoints of the longest line segment
   len = norm(lines(k).point1 - lines(k).point2);
   if ( len > max_len)
      max_len = len;
      xy_long = xy;
   end
end
%highlight the longest line segment
plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
      
end