#!/usr/bin/env sh

export X509_USER_PROXY=/afs/cern.ch/user/a/algomez/x509up_u15148

TARBALL="/cvmfs/cms.cern.ch/phys_generator/gridpacks/2017/13TeV/powheg/V2/TT_hvq/TT_hdamp_NNPDF31_NNLO_ljets.tgz" ### ttbar
SAMPLE="ttbar"
TOTALNEVENTS=500000
NJOBS=50


CMSDIR="/afs/cern.ch/work/a/algomez/Generation/CMSSW_9_1_0_pre3/src/"
#WORKINGDIR=${PWD}
WORKINGDIR="/afs/cern.ch/work/a/algomez/Generation/delphes/examples/PythiaSamples/"${SAMPLE}"/"
OUTPUTFile='delphesSample_'${SAMPLE}

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc630
cd ${CMSDIR}
eval `scram runtime -sh`
cd ${WORKINGDIR}

NEVENTS=$((${TOTALNEVENTS}/${NJOBS}))

for (( i = 46; i < ${NJOBS}+46; i++ )); do

  ##### Running gridpacks
  #$CMSDIR/GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh ${TARBALL} ${NEVENTS} ${RANDOM}
  #mv cmsgrid_final.lhe cmsgrid_final_${i}.lhe

  ##### RUnning delphes with Pythia8
  #cd ${CMSDIR}
  #eval `scram runtime -sh`
  #cd ${WORKINGDIR}
  export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled2/
  export LD_LIBRARY_PATH=$PYTHIA8/lib:$LD_LIBRARY_PATH

  cp ${WORKINGDIR}/../configLHE_${SAMPLE}.cmnd ${WORKINGDIR}/configLHE_${i}.cmnd
  sed -i "s/Main:numberOfEvents = 100/Main:numberOfEvents = ${NEVENTS}/" configLHE_${i}.cmnd
  sed -i 's|cmsgrid_final.lhe|'${WORKINGDIR}'\/cmsgrid_final_'${i}'.lhe|' configLHE_${i}.cmnd

  rm ${OUTPUTFile}_${i}.root
  #../../../DelphesPythia8 ../../../cards/CMS_PhaseII/CMS_PhaseII_Substructure_200PU_withHTT.tcl configLHE_${i}.cmnd ${OUTPUTFile}_${i}.root
  ../../../DelphesPythia8 ../../cards/CMS_PhaseII/CMS_PhaseII_Substructure_200PU_withHTT_NoEnergyScale.tcl configLHE_${i}.cmnd ${OUTPUTFile}_${i}.root

done
