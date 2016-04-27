function y = Hough(bild)


%geschätzter Grauwert der Nadel
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

%Verbesserungsmöglichkeiten:
J = imboxfilt(imadjust(bild));
%figure, imshow(J);

K = histeq(bild);
%figure, imshow(K);

L = imboxfilt(bild,11);

%verwendetes Bild:
rotI=M;

%mögliche Methoden: Canny,log,zerocross

BW = edge(rotI,'canny');

[H,theta,rho] = hough(BW);
P = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));

%MinLength erhöhen reduziert Anzahl falscher Kanten
lines = houghlines(BW,theta,rho,P,'FillGap',15,'MinLength',15);

x=[];
y=[];
max_y = 0;
max_x=0;

%angezeigt wird das optisch bessere Bild, nicht das für die
%Hough-Transformation genutzte
figure, imshow(J), hold on

for k = 1:length(lines)
    
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
    plot(max_x,polyval(p,max_x),'o',t2,y2)
     
end
