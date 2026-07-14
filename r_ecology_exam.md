> #### Giulia Condorelli
>> ##### matricola n. 1185693

# Analisi dell’Impatto dei Pascoli sulla Vegetazione del Campo Imperatore (2015-2025) 🐄

---

# 📌 Introduzione

Il progetto **LIFE PRATERIE** (LIFE11/NAT/IT/234) propone la conservazione a lungo termine delle **praterie e dei pascoli** nel territorio del **Parco Nazionale del Gran Sasso e Monti della Laga**, con particolare attenzione all’equilibrio tra **attività produttive** (come il pascolo estensivo) e **tutela ambientale**.

Campo Imperatore rappresenta una delle aree più sensibili, interessata da:

- pascolo non regolamentato   
- sovraccarico da parte del bestiame in specifiche zone  
- ridotta disponibilità di infrastrutture (es. abbeveratoi)  
- impatto crescente del turismo su strada e escursionistico.


  ![mappa Campo Imperatore2](https://github.com/user-attachments/assets/439212a0-01d1-4bfc-87bc-55b12383ea80)

---

# 🛰️ Obiettivo del Progetto in R

L’obiettivo dell’elaborazione telerilevata in R è **monitorare i cambiamenti nella vegetazione** dal **2015 al 2025**, utilizzando immagini **Sentinel-2** e calcolando due **indici spettrali**:

- **DVI** (Difference Vegetation Index)  
- **NDVI** (Normalized Difference Vegetation Index)
---

# 🧪 Data gathering e Metodologia

## Raccolta delle immagini
Le immagini sono state scaricate attraverso il sito web di [Google Earth Engine](https://earthengine.google.com/), scegliendo l'area descritta precedentemente.

> [!NOTE]
>
> Il codice completo in JavaScript utilizzato per ottenere le immagini si trova nel file Code.js

## Impostazione della working directory
````md
setwd("C://Users/giuli/OneDrive/telexam/")
````

## Caricamento pacchetti
````md
library(terra)  
library(imageRy)  
library(viridis)
library(ggridges)
library(ggplot2)  
library(patchwork)  
````
## Importazione raster Sentinel-2
````md
campoimp15 <- rast("CampoImp2015.tif")  
campoimp25 <- rast("CampoImp2025.tif")
 ````

> [!NOTE]
>
> I raster campoimp15 e campoimp25 corrispondo al periodo che va da luglio a settembre rispettivamente dell'anno 2015 e 2025.  

## Visualizzazione con colori reali (RGB)
 ````md
# Creazione di un pannello multiframe dove poter affiancare le due immagini  
im.multiframe(1,2)    # Funzione che fa parte del pacchetto imageRy
# Utilizzo della funzione plotRGB() proveniente dal pacchetto imageRy  
plotRGB(campoimp15, r = 1, g = 2, b = 3, stretch = "lin", main = "Campo Imperatore, 2015")   
plotRGB(campoimp25, r = 1, g = 2, b = 3, stretch = "lin", main = "Campo Imperatore, 2025")   
 ````
<p align="center">
<img width="514" height="513" alt="CampoImpRGB" src="https://github.com/user-attachments/assets/cbe066b7-c7c1-4ef6-828a-cdf96856a449" />
  
 ````md    
# Visualizzazione separata delle quattro bande (RGB e NIR) per entrambe le immagini    
im.multiframe(2,2)  
# Bande plottate separatamente, per evitare sovrapposizioni  
plot(campoimp15[[1]], main = "B4 - Red", col = magma(100))  
plot(campoimp15[[2]], main = "B3 - Green", col = magma(100))  
plot(campoimp15[[3]], main = "B2 - Blue", col = magma(100))  
plot(campoimp15[[4]], main = "B8 - NIR", col = magma(100))  
   ````
  <p align="center">
  <img width="514" height="513" alt="campoimp15magma" src="https://github.com/user-attachments/assets/f3080c82-749d-4f18-8821-931651f79404" /> 
    
````md
# Stesso procedimento per l'immagine di quest'anno  
im.multiframe(2,2)  
plot(campoimp25[[1]], main = "B4 - Red", col = magma(100))  
plot(campoimp25[[2]], main = "B3 - Green", col = magma(100))  
plot(campoimp25[[3]], main = "B2 - Blue", col = magma(100))  
plot(campoimp25[[4]], main = "B8 - NIR", col = magma(100))
  ````
  <p align="center">
<img width="514" height="513" alt="campoimp25magma" src="https://github.com/user-attachments/assets/96172aae-8da7-450f-af57-9a1c477f4efe" />  
    
> **Commento**
>  
> Le immagini con il NIR (Near-InfraRed) sono molto importanti perchè sono quelle che permettono di osservare lo stato di salute della vegetazione. 
> Una minor riflessione del NIR indica una vegetazione sottoposta a stress. 

Sostituendo il NIR al posto della banda del blu, si evidenziano le zone di vegetazione (blu) e tutto ciò che non è vegetazione (giallo).

 ````md
 im.multiframe(1,2)  
plotRGB(campoimp15, r = 1, g = 2, b = 4, stretch="lin", main = "Campo Imperatore, 2015")   
plotRGB(campoimp25, r = 1, g = 2, b = 4, stretch="lin", main = "Campo Imperatore, 2025")  
 ````
<p align="center">
<img width="514" height="513" alt="campoimpblu2015_2025" src="https://github.com/user-attachments/assets/b3928881-e598-4a8a-89b9-25fb57933724" />  
  
> **Commento**  
>  
> L'immagine mostra chiaramente una diminuzione della vegetazione nella zona d'interesse.

# 🌿 Analisi DVI

Il DVI (Difference Vegetation Index) è uno dei più semplici indici spettrali utilizzati per valutare la presenza e la vitalità della vegetazione.   
Si calcola sottraendo la riflettanza nel rosso (Red) da quella nel vicino infrarosso (NIR):   
$` DVI = NIR - Red `$   
Le piante sane riflettono molto nel NIR e poco nel rosso, quindi valori alti di DVI indicano vegetazione vigorosa.   
È un indice non normalizzato, ma fornisce indicazioni dirette sulla biomassa verde e può essere utile per analisi   comparative quando le condizioni di acquisizione sono simili.

 ````md
# Per semplificare si userà la funzione im.dvi(), che è una funzione del pacchetto imageRy    
dvi_2015 <- im.dvi(campoimp15, 4, 1)   
dvi_2025 <- im.dvi(campoimp25, 4, 1)  
 
# Visualizzazione della DVI
im.multiframe(1, 2)
plot(dvi_2015, col = viridis(100), main = "DVI 2015")
plot(dvi_2025, col = viridis(100), main = "DVI 2025")

 ````
<p align="center">
<img width="614" height="613" alt="DVI2015_2025" src="https://github.com/user-attachments/assets/f8e24d15-e7a2-434f-a2a2-ac8c669b494c" />

````md
# Calcolo e visualizzazione differenza DVI   
dvi_diff <- dvi_2025 - dvi_2015   
im.multiframe(1, 1)  
plot(dvi_diff, col = magma(100), main = "Differenza DVI (2025 - 2015)")   
 ````
<p align="center">
  <img width="614" height="613" alt="DIFFDVI2025_2015" src="https://github.com/user-attachments/assets/b86a6460-617a-47cd-a5ad-e1872f19c5ad" />
  
> **Commento**
>  
> Nell'immagine si vede come i colori facciano principalmente riferimento a valori negativi, il che indica una diminuzione dei valori di DVI e quindi una perdita di copertura vegetale.
  
# 🌿 Analisi NDVI (Normalized Difference Vegetation Index)
Il NDVI è uno degli indici di vegetazione più diffusi in telerilevamento grazie alla sua capacità di normalizzare le differenze tra immagini acquisite in tempi o condizioni diverse.
Si calcola come:
NDVI = (NIR − Red) / (NIR + Red)  

I valori ottenuti variano tra -1 e +1: valori vicini a +1 indicano vegetazione densa e sana, mentre valori prossimi a 0 o negativi indicano suolo nudo, rocce o acqua.
L'NDVI è particolarmente utile per monitorare variazioni nella copertura vegetale nel tempo e valutare stress idrici, cambiamenti climatici o impatti antropici, come nel caso di pascoli intensivi.

$` NDVI = \frac{(NIR - Red)}{(NIR + Red)} `$  

 ````md
# Per semplificare si userà la funzione im.ndvi(), che è una funzione del pacchetto imageRy   
ndvi_2015 <- im.ndvi(campoimp15, 4, 1)    
ndvi_2025 <- im.ndvi(campoimp25, 4, 1)
# Creazione di un pannello multiframe isualizzazione NDVI
im.multiframe(1, 2)
plot(ndvi_2015, col = viridis(100), main = "NDVI 2015")
plot(ndvi_2025, col = viridis(100), main = "NDVI 2025")
````
<p align="center">
<img width="614" height="613" alt="NDVI2015_2025" src="https://github.com/user-attachments/assets/203cdfd5-1b97-42b5-82c4-cda827e9c5c8" />

## Ridgeline plot
>[!TIP]
> Il ridgeplot consente di confrontare visivamente la distribuzione dell’indice NDVI tra il 2015 e il 2025, evidenziando eventuali variazioni nella densità e nello stato della vegetazione nel tempo.
````md
# Per cominciare si crea un vettore per visualizzare le due immagini contemporaneamente
campoimp_ridg=c(ndvi_2015, ndvi_2025)  
names(campoimp_ridg) =c("NDVI 2015", "NDVI 2025") # Per assegnare i nomi alle due immagini del vettore
# Applicazione della funzione im.ridgeline del pacchetto imageRy
im.ridgeline(campoimp_ridg, scale=2, palette="viridis")
````
<p align="center">
<img width="414" height="413" alt="graficoim ridgeline" src="https://github.com/user-attachments/assets/1bf4b47a-4f2c-4921-8aa5-4de4636e1289" />

> **Commento**
> 
> Si nota come la curva relativa al 2025 sia più spostata verso sinistra e più stretta rispetto alla curva del 2015 e ciò potrebbe significare che ci siano più aree con vegetazione in sofferenza (valori NDVI più bassi) e con una copertura piuttosto omogenea (tutto degradato o tutto pascolo). 


## Classificazione per classi di vegetazione
 ````md
# Scelta del range di valori adatto alla classificazione   
# Si fa riferimento agli istogrammi della distribuzione  dell'NDVI:
hist(ndvi_2015, main = "NDVI 2015", col = "darkgreen")   
hist(ndvi_2025, main = "NDVI 2025", col = "darkblue")
 ```` 
<details>
<summary>Istogrammi (cliccare qui)</summary>  
  
<p align="center">
<img width="414" height="413" alt="histNDVI2015" src="https://github.com/user-attachments/assets/59237733-25df-479f-8fef-9cd9e7085358" />

<img width="414" height="413" alt="histNDVI2025" src="https://github.com/user-attachments/assets/b2ed5967-d200-4416-b284-787dcb8b4d5f" />
</p>

</details>



 ````md
class_matrix <- matrix(c(-Inf, 0.2, 1, 
                         0.2, 0.4, 2, 
                         0.4, Inf, 3), 
                       ncol = 3, byrow = TRUE)
class_matrix
     [,1] [,2] [,3]
[1,] -Inf  0.2    1       # Se NDVI < 0.2 allora si associa una classe di tipo 1 (Suolo nudo)
[2,]  0.2  0.4    2       # Se 0.2 ≤ NDVI < 0.4 allora si associa una classe di tipo 2 (Vegetazione media)
[3,]  0.4  Inf    3       # Se NDVI ≥ 0.4 allora si associa una classe di tipo 3 (Vegetazione sana)  

ndvi_2015_cl <- classify(ndvi_2015, class_matrix)  
ndvi_2025_cl <- classify(ndvi_2025, class_matrix)  
# Verifica visuale   
im.multiframe(1, 2   
plot(ndvi_2015_cl, col = c("orange", "yellow", "darkgreen"), main = "NDVI class. 2015")  
plot(ndvi_2025_cl, col = c("orange", "yellow", "darkgreen"), main = "NDVI class. 2025")  
 ````
<p align="center">
<img width="614" height="613" alt="class3NDVI2015_2025" src="https://github.com/user-attachments/assets/f284cddf-1be0-49ec-8502-727bd0e5912c" />

>**Commento**
>
> Sono visivamente evidenti i cambiamenti nella vegetazione. C'è stata una quasi completa sostituzione di tutta quella vegetazione considerata sana. Nell'immagine rappresentante il 2025 domina una vegetazione media, ovvero una vegetazione sottoposta a stress o rada.
  
## Calcolo percentuali
 ````md
# Frequenze
freq_2015 <- freq(ndvi_2015_cl)
freq_2025 <- freq(ndvi_2025_cl)
# Percentuali
perc_2015 <- freq_2015$count * 100 / ncell(ndvi_2015_cl)
perc_2025 <- freq_2025$count * 100 / ncell(ndvi_2025_cl)
# Tabella
tab <- data.frame(
  classi = c("Suolo nudo", "Vegetazione media", "Vegetazione sana"),
  a2015 = round(perc_2015, 2),
  a2025 = round(perc_2025, 2)
)
print(tab)
           classi a2015 a2025  
1        Suolo nudo  0.17  9.05  
2 Vegetazione media 16.42 90.01    
3  Vegetazione sana 83.41  0.94
   ````

Si riportano i risultati in una tabella:

| classi | a2015 | a2025 |
|--- |--- |--- |
|   1: Suolo nudo |  0.17%  |  9.05%  |
|   2: Vegetazione media |16.42% |90.01% |
|   3: Vegetazione sana |83.41% |0.94% |

## Visualizzazione
 ````md
p1 <- ggplot(tab, aes(x = classi, y = a2015, fill = classi)) +    
  geom_bar(stat = "identity") +
  scale_fill_viridis_d() +
  ylim(0, 100) +
  labs(title = "Classi NDVI 2015", y = "%", x = NULL) +
  theme_minimal()

p2 <- ggplot(tab, aes(x = classi, y = a2025, fill = classi)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d() +
  ylim(0, 100) +
  labs(title = "Classi NDVI 2025", y = "%", x = NULL) +
  theme_minimal()

p1 + p2      # Grazie al pacchetto patchwork si possono unire i grafici in questo modo
 ````

>[!IMPORTANT]
> - ggplot(tab, aes(...)): inizializza il grafico dal data.frame tab.  
> - geom_bar(): crea le barre del grafico.  
> - scale_fill_viridis_d(): applica una palette a contrasto visivo compatibile con persone affette da daltonismo.  
> - ylim(): impone che l'asse delle y vada da 0 a 100 (percentuali).  
> - labs(): modifica titoli e etichette degli assi.  
> - theme_minimal(): applica un tema minimale per rendere il grafico più pulito e leggibile.  

<p align="center">
  <img width="1192" height="613" alt="ggplotNDVI" src="https://github.com/user-attachments/assets/f014621c-8322-4fda-8517-b948bbdb2b19" />

---

## 📉 Analisi multitemporale
L'analisi multitemporale ha permesso di confrontare i dati telerilevati del 2015 e del 2025, focalizzandosi in particolare sulla banda del NIR e sull'indice NDVI, al fine di evidenziare variazioni significative nello stato della vegetazione nell’arco del decennio.
````md
nir_diff <- campoimp25[[4]] - campoimp15[[4]]
ndvi_diff <- ndvi_2025 - ndvi_2015  
im.multiframe(1, 2)
plot(nir_diff, col = viridis(100), main = "NIR (2025 - 2015)")
plot(ndvi_diff, col = viridis(100), main = "NDVI (2025 - 2015)")
````
<p align="center">
<img width="599" height="613" alt="NIR_NDVIdiff" src="https://github.com/user-attachments/assets/6f9ff787-7b4d-4341-89e3-5734136d1b88" />

> **Commento**
>
> Le mappe di differenza NIR e NDVI tra il 2015 e il 2025 mostrano una chiara riduzione della riflettanza nel vicino infrarosso e dei valori di NDVI in diverse aree di Campo Imperatore, suggerendo un peggioramento della salute vegetazionale, verosimilmente legato a fattori di pressione ambientale come il pascolo incontrollato e i cambiamenti climatici.

## 📌 Commenti e Conclusioni

Dai risultati ottenuti emerge una chiara contrazione della vegetazione sana: la copertura verde intensa (NDVI elevato / DVI alto) nel 2015 era molto più estesa, mentre nel 2025 appare fortemente ridotta. Parallelamente, si osserva un incremento delle aree con vegetazione moderata o degradata, e persino suolo nudo. Questi risultati suggeriscono una perdita di vigore vegetativo, probabilmente dovuta a pressione antropica (sovrappascolo, flusso turistico) e stress ambientale, come siccità o uso non sostenibile del territorio.
### Obiettivo progetto LIFE11/NAT/IT/234 – PRATERIE
Alla luce delle analisi effettuate, risulta evidente come sia fondamentale intervenire sulla gestione del pascolo e delle infrastrutture turistiche. Solo attraverso strategie condivise con gli attori locali sarà possibile contribuire attivamente alla conservazione degli habitat montani, valorizzandoli come patrimonio collettivo da tutelare oggi e trasmettere integro alle generazioni future.

## 🎯 Il contributo del telerilevamento

L’uso del telerilevamento ha permesso un’analisi spaziale e temporale oggettiva, evidenziando come l’attività antropica (pascolo e turismo) impatti sulla biodiversità e sulla qualità degli habitat.

## 📎 Link utili

LIFE11/NAT/IT/234 – PRATERIE: [Sito ufficiale del progetto](http://www.lifepraterie.it/pagina.php?id=11)

Documentazione Sentinel-2 ESA - [Google Earth Engine](https://earthengine.google.com/)





