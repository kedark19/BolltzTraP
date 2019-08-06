#!/bin/sh
####################################################################
####################################################################
####################################################################
# define some QE variables (do not change)
# Path of your pseudopotential file 
PSEUDO_DIR=export PSEUDO_DIR=~/kedar/softwares/SSSP_precision_pseudos/
# Path of your Quantum espresso executables
PW_ROOT=export PW_ROOT=~/softwares/qe/qe-6.3/bin/
# Path of BoltzTraP executable
Boltz_path=export Boltz_path=~/kedar/softwares/boltztrap-1.2.5/src/
name=Si
nK=8
dnk=12
degauss=0.005

rm -rf boltz
mkdir boltz
cd boltz

# scf calculation
echo "SCF......."

cat >  $name.relax.in << EOF
&control
 calculation='relax' 
 restart_mode='from_scratch'
 prefix='Boltz'
 pseudo_dir = '$PSEUDO_DIR/'
!verbosity =high
/
&system
 ibrav= 2
 celldm(1) =10.187
 nat= 2
 ntyp= 1
    ecutwfc = 50,
    occupations='smearing',
    degauss=0.005
    input_dft='pbe'
    london=.true.
 /
 &electrons
    conv_thr = 1.0e-9
    electron_maxstep = 150,
    mixing_beta=0.3
    diagonalization='cg'
 /
 &ions
    ion_dynamics = 'bfgs'
 /
 &cell
    cell_factor = 10
    cell_dynamics='damp-w'
    cell_dofree='z'
/
ATOMIC_SPECIES
Si 28.085 Si.pbe-n-rrkjus_psl.1.0.0.UPF
ATOMIC_POSITIONS {crystal}
Si 0.00 0.00 0.00
Si 0.25 0.25 0.25
K_POINTS AUTOMATIC
10 10 10 1 1 1
EOF
mpirun -np 4 $PW_ROOT/pw.x <$name.relax.in> $name.relax.out

######################################################################
# nscf calculation
echo "NSCF........"
cat >  $name.nscf.in << EOF
&control
 calculation='nscf' 
 restart_mode='from_scratch'
 prefix='Boltz'
 pseudo_dir = '$PSEUDO_DIR/'
 verbosity ='high'
/
&system
 ibrav= 2
 celldm(1) =10.187
 nat= 2
 ntyp= 1
    ecutwfc = 50,
    occupations='smearing',
    degauss=0.005
    input_dft='pbe'
    london=.true.
 /
 &electrons
    conv_thr = 1.0e-9
    electron_maxstep = 150,
    mixing_beta=0.3
    diagonalization='cg'
 /
 &ions
    ion_dynamics = 'bfgs'
 /
 &cell
    cell_factor = 10
    cell_dynamics='damp-w'
    cell_dofree='z'
/
ATOMIC_SPECIES
Si 28.085 Si.pbe-n-rrkjus_psl.1.0.0.UPF
ATOMIC_POSITIONS {crystal}
Si 0.00 0.00 0.00
Si 0.25 0.25 0.25
K_POINTS AUTOMATIC
20 20 20 1 1 1
EOF
mpirun -np 4 $PW_ROOT/pw.x <$name.nscf.in> $name.nscf.out

#####################################################################################      

echo "BoltzTraP Calculation......"
#######################################################################################
# BoltzTraP 
cp ../qe2boltz.py .
cp $name.nscf.out Boltz.nscf.out
E_fermi=`grep 'Fermi energy' Si.nscf.out | awk '{print $5}'`
python2.7 qe2boltz.py Boltz pw  $E_fermi 0 

# Path of BoltzTraP
$Boltz_path/BoltzTraP BoltzTraP.def



################################################################################

