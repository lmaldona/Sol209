
*Renueve la memoria y declare el directorio
clear all

*Directorio donde se trabaja (solo valido si tiene Mac y acceso al Dropbox
*de LM...)
cd ~/Dropbox/Stata /*declara directorio*/
pwd /*Permite ver el directorio actual*/
dir /*Informacion en el directorio*/

* Simulacion 2: 10000 repeticiones
* ------------------------------------------
clear
set obs 2000 /*Defina una poblacion con 2000 observaciones*/

*Generacion de x
gen id=_n

gen x=0
replace x=1 if id<1001

*Media y desviacion estandar en la poblacion
sum x

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
           x |      2000          .5     .500125          0          1

*Programa para extraer muestra con n=200
program clase12, rclass //rclass define objeto
	version 12 //Version de Stata
	preserve //No modificar dato originales
	sample 200, count //muestreo sin reemplazo
	summarize x
	return scalar mean = r(mean) //Usa la media
	restore //Volver a base original de 2000
end //

set seed 1235
simulate mean=r(mean), reps(10000) nodots: clase12 x	

*Distribucion de probabilidad
histogram mean, frequency normal discrete


*Media y desviacion estandar de la distribucion muestral
dis .500125/sqrt(200) //Ver formulas en slide 19 de clase 12
.03536418


sum mean

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
        mean |     10000      .50074    .0336368        .37        .62



* Intervalo de confianza a traves de simulacion, 95%: .435 - .565 
* ---------------------------------------------------------------
egen zb=std(mean)
centile zb, centile(2.5 97.5)
                                                   
    Variable |     Obs  Percentile      Centile        
-------------+---------------------------------------
          zb |   10000        2.5     -1.954406       
             |               97.5      1.910407        

tab zb

gen zb2=zb
replace zb2=0 if zb<=1.910407 & zb>=-1.954406 //0 es intervalo

centile mean , centile(2.5 97.5)

                                                     
    Variable |     Obs  Percentile      Centile       
-------------+-----------------------------------------
        mean |   10000        2.5          .435            
             |               97.5          .565        


gen mean2=mean
replace mean2=.5 if mean>=.435 & mean<=.565 //.5 es intervalo

tab mean2

      mean2 |      Freq.     Percent        Cum.
------------+-----------------------------------
        .37 |          1        0.01        0.01
       .375 |          1        0.01        0.02
       .385 |          2        0.02        0.04
       .395 |          2        0.02        0.06
         .4 |          7        0.07        0.13
       .405 |         11        0.11        0.24
        .41 |         17        0.17        0.41
       .415 |         14        0.14        0.55
        .42 |         28        0.28        0.83
       .425 |         50        0.50        1.33
        .43 |         71        0.71        2.04
         .5 |      9,565       95.65       97.69
        .57 |         64        0.64       98.33
       .575 |         53        0.53       98.86
        .58 |         28        0.28       99.14
       .585 |         22        0.22       99.36
        .59 |         20        0.20       99.56
       .595 |         17        0.17       99.73
         .6 |         14        0.14       99.87
       .605 |          4        0.04       99.91
        .61 |          3        0.03       99.94
       .615 |          3        0.03       99.97
        .62 |          3        0.03      100.00
------------+-----------------------------------
      Total |     10,000      100.00



*Grafico 1
kdensity zb, title (Variable estandarizada) ///
xline(-1.95) ///
xline(1.91) ///
xlabel(-1.95 "-1.95" 0 "mean" 1.91 "1.91", grid gmin gmax)

*Grafico 2
kdensity mean, title (Variable no estandarizada) ///
xline(.44) ///
xline(.57) ///
xlabel(.44 ".44" .5 "mean=.5" .57 ".57", grid gmin gmax)

* Intervalo de confianza a traves de procedemiento anal’tico 
* ----------------------------------------------------------
*Tomamos solo una muestra de 200 casos

clear
set obs 2000 /*Defina una poblacion con 2000 observaciones*/

*Generacion de x
gen id=_n

gen x=0
replace x=1 if id<1001

*Media y desviacion estandar en la poblacion
sum x

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
           x |      2000          .5     .500125          0          1

*Tomamos la muestra aleatoria simple de la poblacio—n de 200 casos
set seed 1222
sample 200, count

*Media y desviacion estandar en la muestra
sum x

    Variable |       Obs        Mean    Std. Dev.       Min        Max
-------------+--------------------------------------------------------
           x |       200        .535    .5000251          0          1

*Aplicamos formula de intervalo de confianza (slide 19)
dis .535 + 1.96*(.500125/sqrt(200))
.60431379 

dis .535 - 1.96*(.500125/sqrt(200)) 
.46568621

*Comparemos con regresion
reg x

------------------------------------------------------------------------------
           x |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
       _cons |       .535   .0353571    15.13   0.000     .4652773    .6047227
------------------------------------------------------------------------------
