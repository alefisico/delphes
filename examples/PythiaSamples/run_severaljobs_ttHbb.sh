#!/usr/bin/env sh

##### Parameters to modify
SAMPLE="ttHbb"            #### can be or ttHbb or ttbar
TOTALNEVENTS=500000       #### total number of events
NJOBS=50                  #### number of jobs submitted in parallel
FIRSTJOB=100              #### this is just a label, your jobs will be named ttbar_FIRSTJOB
CMSDIR="/afs/cern.ch/work/a/algomez/Generation/CMSSW_9_1_0_pre3/src/"  #### change with your CMSSW release directory
WORKINGDIR="/afs/cern.ch/work/a/algomez/Generation/delphes/examples/PythiaSamples/"${SAMPLE}"/" #### change with your Delphes directory
USERPROXY=${HOME}/x509up_u15148   #### change with your proxy name 


#### script
if [ ! -d ${WORKINGDIR} ]; then
  echo "Creating working directory"
  mkdir ${WORKINGDIR}
fi
OUTPUTFile='delphesSample_'${SAMPLE}
if [[ ${SAMPLE} = "ttHbb" ]]; then
    TARBALL="/cvmfs/cms.cern.ch/phys_generator/gridpacks/2017/13TeV/powheg/V2/ttH_inclusive_hdamp_NNPDF31_13TeV_M125/v1/ttH_inclusive_hdamp_NNPDF31_13TeV_M125.tgz"
else
    TARBALL="/cvmfs/cms.cern.ch/phys_generator/gridpacks/2017/13TeV/powheg/V2/TT_hvq/TT_hdamp_NNPDF31_NNLO_ljets.tgz"
fi
NEVENTS=$((${TOTALNEVENTS}/${NJOBS}))
for (( i = ${FIRSTJOB}; i < ${NJOBS}+${FIRSTJOB}; i++ )); do

  echo "Creating job "${i}
  ##### Creating folders
  NEWDIR=${WORKINGDIR}/${SAMPLE}_${i}
  if [ -d ${NEWDIR} ]; then
    rm -r ${NEWDIR}
  fi
  mkdir -p ${NEWDIR}
  cd ${NEWDIR}

  FILETOSUBMIT="run_job_${SAMPLE}_${i}.sh"
  ##### Creating file to submit jobs
  echo """#!/usr/bin/env sh
export X509_USER_PROXY=${USERPROXY}

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc630
cd ${CMSDIR}
eval \`scram runtime -sh\`
cd ${NEWDIR}

##### Running gridpacks
$CMSDIR/GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh ${TARBALL} ${NEVENTS} ${RANDOM} 10
mv cmsgrid_final.lhe cmsgrid_final_${i}.lhe

##### RUnning delphes with Pythia8
cd ${CMSDIR}
eval \`scram runtime -sh\`
cd ${NEWDIR}
export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled2/
export LD_LIBRARY_PATH=\$PYTHIA8/lib:\$LD_LIBRARY_PATH

cp ${WORKINGDIR}/../configLHE_${SAMPLE}.cmnd ${NEWDIR}/configLHE_${i}.cmnd
sed -i 's/Main:numberOfEvents = 100/Main:numberOfEvents = ${NEVENTS}/' configLHE_${i}.cmnd
sed -i 's|cmsgrid_final.lhe|'${NEWDIR}'\/cmsgrid_final_'${i}'.lhe|' configLHE_${i}.cmnd

rm ${OUTPUTFile}_${i}.root
${WORKINGDIR}../DelphesPythia8 ${WORKINGDIR}../cards/CMS_PhaseII/CMS_PhaseII_Substructure_200PU_withHTT.tcl configLHE_${i}.cmnd ${OUTPUTFile}_${i}.root

""" >> ${FILETOSUBMIT}
  chmod +x ${FILETOSUBMIT}

  echo "submitting job"
  bsub -q 2nd ${FILETOSUBMIT}

done

cd ${WORKINGDIR}../
echo "Have a nice day :)"
