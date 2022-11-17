%% Importation de la vidéo
video = VideoReader("vid.mp4");
%implay("vid.mp4")

%% points 
image = read(video,1);
figure,imshow(image)
I = CouleursIndexees(image);
figure,imshow(I)
D = DetecteurDeHarris(sigma1,sigma2,sigma3,lambda,I);
figure,imshow(D)

%% Initialisation des variables initiales 
nbFrames = video.NumFrames;
nbCoins = 10;
lambda = 0.05;
sigma1 = 2;
sigma2 = 3;
sigma3 = 5;

%Détection manuelle des nb coins de la feuille (nb points initiaux)
imag = read(video,1);   %--> Image en "vraies couleurs"
%figure , image(imag)
%les coordonnées des nb coins de la feuille mis dans une matrice 
coinsImag1 = [684 412;1340 237 ;1431 583;629 767; 729 524; 921 475; 882 596; 1152 451;989 436;1009 489];   

% initialisation de la matrice des position x des nb coins coins de la feuille pour chaque frame
XcoinsFeuille = zeros(nbFrames,nbCoins);
% initialisation de la matrice des position y des nb coins coins de la feuille pour chaque frame
YcoinsFeuille = zeros(nbFrames,nbCoins);

%Ajout de la position initiale des nb coins  
XcoinsFeuille(1,:)= coinsImag1(:,1);
YcoinsFeuille(1,:)=coinsImag1(:,2);

%On considère que la position des coins ne change pas de la frame 1 à la
%frame 2 
coinsImag2 = coinsImag1;
%Ajout de la position initiale des 4 coins  
XcoinsFeuille(2,:)= coinsImag1(:,1);
YcoinsFeuille(2,:)=coinsImag1(:,2);



%% Détection des coins sur chaque frame de la vidéo 

for i=1:nbFrames-2
    %Lecture de la frame
    I = read(video,i+2);

    %Passage en couleurs indexées 
    Image = CouleursIndexees(I);

    %Calcul du détecteur de Harris 
    D = DetecteurDeHarris(sigma1,sigma2,sigma3,lambda,Image);
    
    Coins1(:,1) = XcoinsFeuille(i,:);
    Coins1(:,2) = YcoinsFeuille(i,:);
    Coins2(:,1) = XcoinsFeuille(i+1,:);
    Coins2(:,2) = YcoinsFeuille(i+1,:);

    %Détection des coins de l'image
    Max = MaximaHarris(D,Coins1,Coins2);

    %Positions X et Y des coins sauvegardées dans les matrices XcoinsFeuille et YcoinsFeuille
    XcoinsFeuille(i+2,:) = Max(:,1);
    YcoinsFeuille(i+2,:) = Max(:,2);

end



%% Save de la matrice des coins de chaque image 

save("matriceCoinsX.mat","XcoinsFeuille")
save("matriceCoinsY.mat","YcoinsFeuille")

%pour importer la matrice 
% --> XcoinsFeuille = load('matriceCoinsX.mat') 
% --> YcoinsFeuille = load('matriceCoinsY.mat')



%% Création de la vidéo de vérification de la détection des coins 

videoCoins = VideoWriter('vidéoCoins','MPEG-4');
open(videoCoins)

position = zeros(nbCoins,2);

for i=1:nbFrames
    image = read(video,i);
    I = ColorerCoins(position,XcoinsFeuille,YcoinsFeuille,image,i);
    writeVideo(videoCoins,I)
end
close(videoCoins)

%% Lancement de la videoCoins

implay('vidéoCoins.mp4')


%% Création de la vidéo avec l'image incrustée 

imageDeRemplacement = imread("imageDeRemplacement.jpg");

newVideo = VideoWriter('newVideo','MPEG-4');
newVideo.FrameRate = 25;
open(newVideo)
for i=1:nbFrames 
    XcoinsFeuilleT = XcoinsFeuille(i,:).';
    YcoinsFeuilleT = YcoinsFeuille(i,:).';
    frame = read(video, i);
    nouvelleImage = RemplacerPapierParImage(frame,imageDeRemplacement,XcoinsFeuilleT,YcoinsFeuilleT);
    writeVideo(newVideo,nouvelleImage)
end
close(newVideo)

%%
implay('newVideo.mp4')

