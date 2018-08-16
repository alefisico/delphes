# Run delphes in lxplus with CMSSW enviroment

_Disclaimer:_ This recipe works for a specific process in CMSSW. Use it with caution.

This instructions are based on [this recipe](https://twiki.cern.ch/twiki/bin/viewauth/CMS/DelphesUPG). This version of delphes contains a version of the fastjet package including the [HEPToptagger](http://www.thphys.uni-heidelberg.de/~plehn/index.php?show=heptoptagger&visible=tools)

## Instructions to compile Delphes

1. Log in to lxplus.cern.ch
1. Go to your working directory, create a new folder, go there
1. Set CMS enviroment:
```bash
cmsrel CMSSW_9_1_0_pre3
cd CMSSW_9_1_0_pre3/src/
cmsenv
cd ../../
```
1. Clone this version of delphes, which includes the HTT and some files to run some jobs:
```bash
git clone https://github.com/alefisico/delphes.git
cd delphes
git checkout tags/v01
make -j 4
```
1. Include Pythia8 libraries:
```
export PYTHIA8=/cvmfs/cms.cern.ch/slc6_amd64_gcc530/external/pythia8/223-mlhled2/
export LD_LIBRARY_PATH=$PYTHIA8/lib:$LD_LIBRARY_PATH
```
1. Compile again:
```
make -j 4 HAS_PYTHIA8=true DelphesPythia8  
```
1. Run a test job:
```
./DelphesPythia8 cards/CMS_PhaseII/CMS_PhaseII_200PU_v03.tcl examples/Pythia8/configLHE.cmnd delphes_lhe.root
```

## Run ttbar or ttH(bb) jobs

1. Update the delphes repo. Inside the `delphes/` directory:
```
git checkout myV0
```
1. Go to `cd examples/PythiaSamples/`
1. There you have two files: configLHE_*.cmnd and run_jobs_*.sh. The configLHE_* files contain already the information that you need for each process. Do not change those files
1. Set your proxy:
```
voms-proxy-init -voms cms
```
1. Copy the name of your proxy file.

### Send several jobs in parallel

1. Open `run_severaljobs_ttHbb.sh`.
1. Modify the first part of the script with your variables. Each parameter is described in the script. _Do not forget to change the proxy name_
1. Once your parameters are there. just run:
```
source run_severaljobs_ttHbb.sh
```


### Send a bunch of jobs one after another (stupid way)
1. To send jobs to the batch system, you need the run_jobs_*.sh files. There you can change the `TOTALNEVENTS` and the `NJOBS` variable. The current setup runs 50 jobs with 10k events each. Finaly remove the number 46 from [line24](https://github.com/alefisico/delphes/blob/myV0/examples/PythiaSamples/run_jobs_ttbar.sh#L24).
1. Create a `ttbar` and `ttHbb` folders
1. Send your jobs to the batch system:
```
bsub -q 1nw run_jobs_ttbar.sh  #### To submit the jobs
### To check status:  bjobs
### To kill jobs: bkill -r NUMBEROFJOB
```
