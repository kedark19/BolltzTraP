#!/usr/local/bin/gnuplot --persist
###########################################################################################################################
###########################################################################################################################
####                                                                                                                   ####
####   Gnuplot Script To plot TRACE Output File From BoltzTrap Code at different Temperatures as a function of Eenrgy  ####
####                                                                                                                   ####
####   Ref.  : Hilal Balout, mail: hilal_balout@hotmail.com                                                            ####
####                                                                                                                   ####
####   Usage: gnuplot -c pTRACE_E_multT.gp  File Efermi dE  T_min T_max dT                                             ####
####                               \          \     \    \    \      \   \___Temperature step                          ####
####                                \          \     \    \    \      \______Maximum of Temperature                    ####
####                                 \          \     \    \    \____________Minimum of Temperature                    ####
####                                  \          \     \    \________________plot interva (with Ef set to 0)           ####
####                                   \          \     \____________________Fermi Energy (in Ry)                      ####
####                                    \          \_________________________BoltzTraP TRACE File name {.trace}        ####
####                                     \___________________________________Script Name                               ####
####                                                                                                                   ####
####   Exemple: gnuplot -c pTrace_E.gp file.trace 0.4 0.1 300 800 100                                                  ####
####   Output : PDF File --->  Trace_300K-800K.pdf                                                                     ####
####                                                                                                                   ####
###########################################################################################################################
if  (ARGC != 6){print "\n       Arguments Error... ";
print "======================================================================="
print "  Usage: gnuplot -c pTRACE_E_multT.gp File Efermi dE  T_min T_max dT" 
print "=======================================================================\n"
exit
}


#VariableVariableVariableVariableVariableVariableVariableVariableVariableVariableVariableVariableVariable
#Scaling Variables

Echel_Sebk=1e6
Echel_Sigma=1e20
Echel_PF=1e12

#VariableVariableVariableVariableVariableVariableVariableVariableVariableVariableVariableVariableVariable

############################################################################################################
############################################################################################################
file2plot=ARG1
print "File name            : ", file2plot
print "Temperature Interval : [",ARG4," - ",ARG5,"]"
print "Fermi Energy         : ", ARG2
print "Plot Interval        : [", -ARG3," - ",ARG3,"]"
############################################################################################################


set term pdf enhanced color font "Times,8" size 3.6,5.4
set output sprintf("Trace_%sK-%sK.pdf",ARG4,ARG5)

set xrang [-ARG3:ARG3]
set mxtics 5
set xtics scale 1.5 
set tics out nomirror 
set border 3 lw 0.5

set style line 1 lt 1 lw 2 pt 7 ps 0.75 lc rgb "red"
set label sprintf("Transport Properties at  %sK < T < %sK ",ARG4,ARG5) at screen 0.5,0.975 center font ",10 bold" textcolor rgb "black"
set tmargin 1 
set bmargin 3 
set lmargin 15 
set rmargin 0
set key
dyy=0.025
set multiplot

set size 0.95,0.27
#set key l t  maxrows 3
set key maxrows 3
set origin 0.,dyy
set xlabel "{/Symbol e - e}_{Fermi} ( Ry )" 
set ylabel "Seebeck  ( {/Symbol m}V . K^{-1} ) " 
print "Seebeck plot ..."
plot for [i=ARG4:ARG5:ARG6] sprintf("<awk '$2==%d' %s",int(i),file2plot) u ($1-ARG2):($5*Echel_Sebk) w lp  lw 0.8 pt 7 ps 0.1 title sprintf("%d K",i) 
print "          ...Done\n"

set origin 0,0.23+dyy
unset xlabel
unset key
unset label
set xtics offset 0,0.5 font ",4" textcolor rgb "grey"
set ylabel sprintf("{/Symbol s/t } ({/Symbol W} .m.s)^-1")  #( 10^{%.0f}  {/Symbol W} .m.s )",log10(Echel_Sigma)) 
print "Electrical Conductivity plot ..."
plot  for [i=ARG4:ARG5:ARG6] sprintf("<awk '$2==%d'  %s",int(i),file2plot) u ($1-ARG2):($6) w lp  lw 0.4 pt 7 ps 0.1
print "          ...Done\n"


set origin 0,0.46+dyy
unset xlabel
unset key
unset label
set xtics offset 0,0.5 font ",4" textcolor rgb "grey"
set ylabel sprintf("{/Symbol k/t } ( W/mKs)")              #( 10^{%.0f}  {/Symbol W} .m.s )",log10(Echel_Sigma)) 
print "Thermal Conductivity plot ..."
plot  for [i=ARG4:ARG5:ARG6] sprintf("<awk '$2==%d'  %s",int(i),file2plot) u ($1-ARG2):($8) w lp  lw 0.4 pt 7 ps 0.1
print "          ...Done\n"

set origin 0,0.69+dyy
unset xlabel
unset key
unset label
set xtics offset 0,0.5 font ",4" textcolor rgb "grey"
set ylabel sprintf ("PF/{/Symbol t} (W/m.K^{2}.s )" )
print "Power Factor plot ..."
plot  for [i=ARG4:ARG5:ARG6] sprintf("<awk '$2==%d' %s",int(i),file2plot) u ($1-ARG2):($5*$5*$6) w lp  lw 0.8 pt 7 ps 0.1 title sprintf("%d K",i)
print "          ...Done\n"





