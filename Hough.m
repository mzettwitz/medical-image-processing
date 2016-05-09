function y = Hough(bild)


%gesch?tzter Grauwert der Nadel
%p01: 950+-400
%p02:-200+-700
nadel= 950;
v = 400;

M = bild;

for i=1:numel(M)
    if (M(i)<(nadel-v))||(M(i)>(nadel+v))
        M(i) = -2048;
    end
end

%Verbesserungsm?glichkeiten:

img = bild;
    
    % convert into double for window/leveling
    img_d = im2double(img);
    img_adj = imadjust(img_d,[0.5195 0.53],[]); %[0.5045 0.5155]
    
    % morphological opening
    se = strel('rectangle', [2 4]);
    img_morph = imclose(img_adj, se);
    img_filt = ordfilt2(img_morph,15,ones(5,5));
    
    J = img_filt;
%figure, imshow(J);

%K = histeq(bild);
%figure, imshow(K);

%L = imboxfilt(bild,11);

%verwendetes Bild:
rotI=J;

%m?gliche Methoden: Canny,log,zerocross

BW = edge(rotI,'canny');

[H,theta,rho] = hough(BW);
P = houghpeaks(H,1,'threshold',ceil(0.85*max(H(:))));

%MinLength erh?hen reduziert Anzahl falscher Kanten
lines = houghlines(BW,theta,rho,P,'FillGap',3,'MinLength',3);

x=[];
y=[];
max_y = 0;
max_x = 0;

%angezeigt wird das optisch bessere Bild, nicht das f?r die
%Hough-Transformation genutzte
figure, imshow(img,[]), hold on

for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
   %Vektor mit den x bzw. y Koordinaten der Punkte
    x = [x lines(k).point1(1) lines(k).point2(1)];
    y = [y lines(k).point1(2) lines(k).point2(2)];

    % y-Koordinaten der beiden gerade betrachteten Punkte
    y1 =  lines(k).point1(2);
    y2 =  lines(k).point2(2);
    
    %Suchen des tiefsten Punktes (Nadelspitze)
    if ( y1 > max_y)
       max_y = y1;
       max_x = lines(k).point1(1);
    end

    if ( y2 > max_y)
       max_y = y1;
       max_x = lines(k).point2(1);
    end
end
    
    %Berechnung der Ausgleichsgerade bis zur Nadelspitze
    p = polyfit(x,y,1);
    t2 = 0:0.1:max_x;
    y2 = polyval(p,t2);
    % Anzeigen von Gerade und Nadelspitze
    plot(max_x,polyval(p,max_x),'o',t2,y2, 'LineWidth', 2.5)
     
end
