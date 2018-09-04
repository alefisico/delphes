#!/usr/bin/env sh

##### Parameters to modify
ttbarDecay="hadronic"            #### can be semileptonic or dileptonic or hadronic
NJOBS=30                   #### number of jobs submitted in parallel
FIRSTJOB=1656              #### this is just a label, your jobs will be named ttbar_FIRSTJOB
CMSDIR="/afs/cern.ch/work/a/algomez/Generation/CMSSW_9_1_0_pre3/src/"  #### change with your CMSSW release directory
INITIALDIR="/afs/cern.ch/work/a/algomez/Generation/delphes/examples/PythiaSamples/" #### change with your Delphes directory
USERPROXY=${HOME}/x509up_u15148   #### change with your proxy name

if [[ ${ttbarDecay} = "dileptonic" ]]; then
  WORKINGDIR=${INITIALDIR}"ttbb/sample0007_"${ttbarDecay}"/"
elif [[ ${ttbarDecay} = "semileptonic" ]]; then
  WORKINGDIR=${INITIALDIR}"ttbb/sample0009_"${ttbarDecay}"/"
else
  WORKINGDIR=${INITIALDIR}"ttbb/sample0008_"${ttbarDecay}"/"
fi

SAMPLE="ttbb_"${ttbarDecay}
OUTPUTFile='delphesSample_'${SAMPLE}

cd ${WORKINGDIR}
for (( i = ${FIRSTJOB}; i < ${NJOBS}+${FIRSTJOB}; i++ )); do

  echo "Creating job "${i}
  lheFile="pwgevents-"${i}".lhe"

  FILETOSUBMIT="run_job_${SAMPLE}_${i}.sh"
  ##### Creating file to submit jobs
  echo """#!/usr/bin/env sh
export X509_USER_PROXY=${USERPROXY}

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc630
cd ${CMSDIR}
eval \`scram runtime -sh\`
cd ${WORKINGDIR}

##### Untar lhe file
gunzip ${lheFile}.gz

##### Running delphes with Pythia8
cd ${CMSDIR}
eval \`scram runtime -sh\`
cd ${WORKINGDIR}
export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled2/
export LD_LIBRARY_PATH=\$PYTHIA8/lib:\$LD_LIBRARY_PATH

cp ${INITIALDIR}/configLHE_ttbb.cmnd configLHE_${i}.cmnd
sed -i 's|LHEFILE|'${WORKINGDIR}${lheFile}'|' configLHE_${i}.cmnd

rm ${OUTPUTFile}_${i}.root
${INITIALDIR}../../DelphesPythia8 ${INITIALDIR}../../cards/CMS_PhaseII/CMS_PhaseII_Substructure_200PU_withHTT_NoEnergyScale.tcl configLHE_${i}.cmnd ${OUTPUTFile}_${i}.root

""" >> ${FILETOSUBMIT}
  chmod +x ${FILETOSUBMIT}

  echo "submitting job"
  bsub -q 2nd ${FILETOSUBMIT}

done

cd ${INITIALDIR}
echo "Have a nice day :)"
