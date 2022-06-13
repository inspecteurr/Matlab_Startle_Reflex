function tracer_graphes_protocole_bruit ()


%////////////////////////////////FICHIER/////////////////////////////////////%
%Demande du fichier par l'opérateur
[fich,rep] = uigetfile({'*.mat';'*.tdms'});

%Conversion en .mat si le fichier est en .tdms
if strcmp(fich(end-3:end),'tdms')
    [ConvertedData,ConvertVer,ChanNames]=convertTDMS(1,[rep,fich]);
else
    load([rep,fich])
end
%////////////////////////////////////////////////////////////////////////////%


%//////////////CARACTERISTIQUES COMMUNES A TOUT LES PROGRAMMES///////////////%
%Recherche des valeurs de fréquence d'échantillonnage
F_ech = 1/ConvertedData.Data.MeasuredData(3).Property(3).Value;
%Rcherche du nombre d'échantillons de chaque mesures
N_sample = length(ConvertedData.Data.MeasuredData(3).Data);
%Conversion pour avoir une échellede temps
temps = linspace(0,N_sample/F_ech,N_sample);
%////////////////////////////////////////////////////////////////////////////%



%///////////////VARIABLE POUR CONNAITRE SI IL Y A REBOUCLAGE/////////////////%
%recherche de la première phrase de mesure 
recherche_valeur_texte = ConvertedData.Data.MeasuredData(3).Name;
%Recherche du mot 'Signal' dans cette phrase
n2 = strfind(recherche_valeur_texte,'Signal');
%Recherche du mot qui suit le mot 'Signal'
text_analyse_rebouclage = recherche_valeur_texte(n2+7:n2+11);
%////////////////////////////////////////////////////////////////////////////%



%//////////////////////CREATION DES TABLEAUX/////////////////////////////////%
%Création des tableaux en fonction du rebouclage ou pas 
if strcmp(text_analyse_rebouclage,'ampli')
    %Taille des tableaux en sautant une ligne sur deux
    taille_tableaux = length(ConvertedData.Data.MeasuredData)/2-1;
    %Création du tableau comprenant les valeurs du rebouclage 
    data_rebouclage = zeros(N_sample,taille_tableaux);
else
    %Taille des tableaux en enlevant les 2 premières lignes
    taille_tableaux = length(ConvertedData.Data.MeasuredData)-2;
end

%Création du tableau comprenant les les données du capteur
data = zeros(N_sample,taille_tableaux);
%Création du tableau de valeur des amplitudes de bruit envoyé (grâce au titre des colonnes)
val_stim_Volt = zeros(1,taille_tableaux);
%Création du tableau de valeur des fréquences (grâce au titre des colonnes)
val_stim_Hertz = zeros(1,taille_tableaux);
%Création du tableau de valeur des fréquences (grâce aux donées)
frequence = zeros(1,taille_tableaux);
%////////////////////////////////////////////////////////////////////////////%



%////////////PRISE VALEURS CAPTEUR SELON L'AMPLITUDE/////////////////////////%
if strcmp(text_analyse_rebouclage,'ampli')
    %Prise de ces valeurs si il y a un rebouclage
    disp('il y a un signal ampli')
    k=4;
    j=1;
    %Le while permet de sauter les données envoyées à l'ampli
    while k<=length(ConvertedData.Data.MeasuredData)
        %Prise du texte
        recherche_valeur_texte = ConvertedData.Data.MeasuredData(k).Name;
        %Recherche de la valeur en Volt
        n2 = strfind(recherche_valeur_texte,' V ');
        text_analyse = recherche_valeur_texte(n2-5:n2);
        %Changement de la virgule en point 
        text_analyse(text_analyse==',')='.';
        val_stim_Volt(j)= str2double(text_analyse);
        %Prise des valeurs capteurs
        data(:,j) = (ConvertedData.Data.MeasuredData(k).Data(1:N_sample));
        k = k+2;
        j = j+1;
    end
%Prise de ces valeurs si le signal ampli n'est pas enregistré 
else
    for j = 3:length(ConvertedData.Data.MeasuredData);
        %Prise du texte
        recherche_valeur_texte = ConvertedData.Data.MeasuredData(j).Name;
        %Recherche de la valeur en Volt
        n2 = strfind(recherche_valeur_texte,' V ');
        text_analyse = recherche_valeur_texte(n2-5:n2);
        %Changement de la virgule en point 
        text_analyse(text_analyse==',')='.';
        val_stim_Volt(j-2)= str2double(text_analyse);
        %Prise des valeurs capteurs
        data(:,j-2) = (ConvertedData.Data.MeasuredData(j).Data(1:N_sample));
    end
end
%////////////////////////////////////////////////////////////////////////////%



%////////////PRISE VALEURS FREQUENCE SI SON PREPARATOIRE/////////////////////%
if recherche_valeur_texte(end-17)=='z'
    k=3;
    j=1;
    if strcmp(text_analyse_rebouclage,'ampli')
        while k<length(ConvertedData.Data.MeasuredData)
            %Prise du texte
            recherche_valeur_texte = ConvertedData.Data.MeasuredData(k).Name;
            %Reherche de la valeur en Volt
            n2 = strfind(recherche_valeur_texte,' V ');
            %Recherche de la valeur en Hertz
            n3 = strfind(recherche_valeur_texte,' H');
            %Prise de l'information entre les deux 
            text_analyse = recherche_valeur_texte(n2+3:n3-1);
            %Changement de la virgule en point 
            text_analyse(text_analyse==',')='.';
            val_stim_Hertz(j)= str2double(text_analyse);
            
            %Indentation des variables 
            k = k+2;
            j = j+1;
        end
    else
        for j = 3:length(ConvertedData.Data.MeasuredData);
            %Prise du texte
            recherche_valeur_texte = ConvertedData.Data.MeasuredData(j).Name;
            %Reherche de la valeur en Volt
            n2 = strfind(recherche_valeur_texte,' V ');
            %Recherche de la valeur en Hertz
            n3 = strfind(recherche_valeur_texte,' H');
            %Prise de l'information entre les deux 
            text_analyse = recherche_valeur_texte(n2+3:n3-1);
            %Changement de la virgule en point 
            text_analyse(text_analyse==',')='.';
            val_stim_Hertz(j-2)= str2double(text_analyse);
        end  
    end
end
%////////////////////////////////////////////////////////////////////////////%



%///////////////CALCUL A PARTIR DES DONNEES DU REBOUCLAGE////////////////////%

%Prise des données du rebouclage si ces données existent
if strcmp(text_analyse_rebouclage,'ampli')
   k=3;
   j=1;
   
   %Création du tableau comprenant l'amplitude du son mesurée grâce aux données
   amplitude_son = zeros(1,taille_tableaux);

   while k<length(ConvertedData.Data.MeasuredData)
        %Prise des données 
        data_rebouclage(:,j) = (ConvertedData.Data.MeasuredData(k).Data(1:N_sample));
        %Si un son préparatoir est enregistré :
        if recherche_valeur_texte(end-17)=='z'
            %Intervale des entiers les plus proches des valeurs entourant le son (0.5s)
            index_ = floor(0.1*F_ech):floor(0.6*F_ech);
            %Calcul de la fréquence envoyée la moins élevée
            f_min = min (val_stim_Hertz);
            %Création du tableau comprenant les données du periodogramme
            if (f_min<3500)
                % nombre de point du periodogramme
                N_FFT = 2048;
                %Décimation afin d'être plus précis par la suite (car 80kHz c'est trop)
                data_analyse = decimate(data_rebouclage(index_,j),10);
                % on divise la fréquence d'éhantillonnage par le même ratio
                 F_ech_FFT = F_ech/10;
            else
                % nombre de point du periodogramme, plus de points
                N_FFT = 2048*2;
                F_ech_FFT = F_ech;
                %
                data_analyse = data_rebouclage(index_,j);
            end
            %Création du tableau comprenant les données du periodogramme
            periodogramme = zeros(N_FFT+1,taille_tableaux);
            %Calcul de l'amplitude du son grâce au rebouclage
            amplitude_son(j) = (max(data_analyse) - min(data_analyse))/2;
            %amplitude_son(j) = std(data_analyse)
            %Calcul de l'écart entre l'amplitude envoyée et l'amplitude demandée
            ecart_amp = amplitude_son(j) - val_stim_Volt(j);
            %Calcul du pourcentage de différence 
            pourcentage_ecart_amp = ecart_amp/val_stim_Volt(j);
            %Message d'erreur si l'amplitude demandée est trop éloignée de l'amplitude envoyée (0.1%)
            if (pourcentage_ecart_amp > 0.001)
                warndlg (['L''amplitude n°', num2str(j),'est trop faible : ', num2str(ecart_freq),'Hz'], 'Problème d''amplitude')
            else if (pourcentage_ecart_amp > 0.001)
                warndlg ('L''amplitude n°' + j + 'est trop élevée : ' + ecart_freq + 'Hz', 'Problème d''amplitude')
                end
            end
            
            
            %Création du périodogramme avec F_ech divisée par 10 à cause de la décimation
            [periodogramme(:,j),Freq] = periodogram(data_analyse,hamming(length(data_analyse)),N_FFT*2,F_ech_FFT);
            %Mesure du maximum du périodogramme
            [FFT_max,N] = max(periodogramme(:,j));
            %Prise de l'abscice qui correspond à la fréquence du signal
            frequence(j) = Freq(N);
            %Calcul de l'écart entre la fréquence envoyée et la fréquence demandée
            ecart_freq = frequence(j)-val_stim_Hertz(j);
            %Calcul du pourcentage de différence 
            pourcentage_ecart_freq = ecart_freq/val_stim_Hertz(j);
            %Message d'erreur si la fréquence demandée est trop éloignée de la fréquence envoyée (0.1%)
            if (pourcentage_ecart_freq > 0.001)
                warndlg (['La fréquence n°', num2str(j),'est trop faible : ', num2str(ecart_freq),'Hz'], 'Problème de fréquence')
            else if (pourcentage_ecart_freq > 0.001)
                warndlg ('La fréquence n°' + j + 'est trop élevée : ' + ecart_freq + 'Hz', 'Problème de fréquence')
                end
            end
        end
        %Indentation des variables 
        k = k+2;
        j = j+1;
    end
end
%////////////////////////////////////////////////////////////////////////////%


%///////////////CALCUL DE L'AMPLITUDE MAX DU CAPTEUR/////////////////////////%
if recherche_valeur_texte(end-17)=='z'
%Calcul si il y a un son préparatoire (la mesure dure 4s dans ce cas)
    amplitude_max = std(data(round(1.7*F_ech):round(2.7*F_ech),:));
else
%Calcul si il n'y a pas de son préparatoire
    amplitude_max = std(data(round(0.1*F_ech):round(1.1*F_ech),:));
end
%////////////////////////////////////////////////////////////////////////////%



%//////////////////CALCUL DE LA DROITE DE REGRESSION/////////////////////////%
if strcmp(text_analyse_rebouclage,'ampli')
    [b,~,~,~,stats] = regress(amplitude_max',[val_stim_Volt',ones(taille_tableaux,1)]);
else
    [b,~,~,~,stats] = regress(amplitude_max',[val_stim_Volt',ones(taille_tableaux,1)]);
end
%////////////////////////////////////////////////////////////////////////////%



%//////////////////////////////AFFICHAGE/////////////////////////////////////%
%Création d'une figure pour affichage 
fig = figure ('name', 'graphs du fichier','DefaultAxesFontSize',14);
%Changementde la position de l'annotation en fonction du nombre de graph
if strcmp(text_analyse_rebouclage,'ampli')
    placement = [0.65 0.8 0.2 0.03];
else
    placement =[0.42 0.85 0.2 0.03];
end
%Création des annotation pour montrer le r² et le p et l'équation de la droite de régression
annotation('textbox',placement,'String',['e = ',num2str(b(1),'%1.3f'),'x +',num2str(b(2),'%1.3f'), ...
    ' / (r²=',num2str(stats(1),'%1.2f'), ') / ', ...
    '(p=',num2str(stats(3),'%1.4f'),')'],'FontSize', 14);



%Affichage des données capteur
if strcmp(text_analyse_rebouclage,'ampli')
    subplot(2,2,1)
else
    subplot(1,3,1)
end
plot(temps,data)
grid on
grid minor 
box off
title ('Réponse capteur en fonction du temps')
xlabel('Temps (s)')
ylabel('Tension du cateur (V)')

%Affichage des données amplitudes 
if strcmp(text_analyse_rebouclage,'ampli')
    subplot(2,2,2)
else
    subplot(1,3,2)
end
plot(val_stim_Volt,amplitude_max,'+')
hold on
%Création de la droite de régression 
line([0 val_stim_Volt],[0 val_stim_Volt]*b(1)+b(2),'linewidth',2,'color','r')
grid on 
grid minor 
box off 
title (sprintf('Amplitude de réponse en fonction\n de la valeur envoyée à l''ampli'))
%Récupération des données de la figure en cour
h_f = gcf;
%Abaissement de la figure en cours 
h_f.Children(1).Position = h_f.Children(1).Position + [0 -0.01 0 0];
xlabel('Amplitude envoyée (V)')
ylabel('Tension du capteur (V)')

%Affichage des données en boîtes 
if strcmp(text_analyse_rebouclage,'ampli')
    subplot(2,2,4)
else
    subplot(1,3,3)
end
boxplot(amplitude_max,val_stim_Volt)
grid on 
grid minor 
box off 
%Abaissement de la figure en cour
h_f.Children(1).Position = h_f.Children(1).Position + [0 -0.05 0 0];
%Agrandissement de la figure en cour 
h_f.Children(1).OuterPosition = h_f.Children(1).OuterPosition + [0 0.01 0 0];
title (sprintf('Amplitude de réponse en fonction\n de la valeur envoyée à l''ampli'))
%Hausse du titre de la figure en cours 
h_f.Children(1).Title.Position = h_f.Children(1).Title.Position + [0 0.000008 0];
xlabel('Amplitude envoyée (V)')
ylabel('Tension du capteur (V)')

%Affichage du rebouclage 
if strcmp(text_analyse_rebouclage,'ampli')
    subplot(2,2,3)
    plot(temps,data_rebouclage)
    grid on 
    grid minor 
    box off 
    title ('Signal envoyé')
    xlabel('Temps (s)')
    ylabel('Tension envoyée (V)')
end
%////////////////////////////////////////////////////////////////////////////%
