
#!/bin/bash

PACKAGE=package.tar.gz

# Echo exact command
echo "$(basename $0) $*"


###################################################################################################
# ProjectMetis/CondorTask specific (Setting up some common environment)
###################################################################################################
#echo "To check whether it's on condor universe Vanilla or Local. The following variables are used."
#echo "If _CONDOR_SLOT is set, it's on Vanilla"
#echo "If X509_USER_PROXY is set, it's either on Vanilla or Local."
# if 
if [ "x${_CONDOR_JOB_AD}" == "x" ]; then
    :
    INPUTFILENAMES=$1
    shift;
else
    hostname
    uname -a
    date
    whoami
    pwd
    echo "ls'ing hadoop"
    ls -lh /hadoop/cms/store/user/phchang/
    echo "_CONDOR_SLOT" ${_CONDOR_SLOT}
    echo "X509_USER_PROXY" ${X509_USER_PROXY}
    echo "_CONDOR_SCRATCH_DIR"             ${_CONDOR_SCRATCH_DIR}
    echo "_CONDOR_SLOT"                    ${_CONDOR_SLOT}
    echo "CONDOR_VM"                       ${CONDOR_VM}
    echo "X509_USER_PROXY"                 ${X509_USER_PROXY}
    echo "_CONDOR_JOB_AD"                  ${_CONDOR_JOB_AD}
    echo "_CONDOR_MACHINE_AD"              ${_CONDOR_MACHINE_AD}
    echo "_CONDOR_JOB_IWD"                 ${_CONDOR_JOB_IWD}
    echo "_CONDOR_WRAPPER_ERROR_FILE"      ${_CONDOR_WRAPPER_ERROR_FILE}
    echo "CONDOR_IDS"                      ${CONDOR_IDS}
    echo "CONDOR_ID"                       ${CONDOR_ID}
    OUTPUTDIR=$1
    OUTPUTNAME=$2
    INPUTFILENAMES=$3
    IFILE=$4
    CMSSWVERSION=$5
    SCRAMARCH=$6
    if [ "x${_CONDOR_SLOT}" == "x" ]; then
        WORKDIR=/tmp/phchang_condor_local_${OUTPUTDIR//\//_}_${OUTPUTNAME}_${IFILE}
        mkdir -p ${WORKDIR}
        ls
        cp package.tar.gz ${WORKDIR}
        cd ${WORKDIR}
        ls
        echo "This is in Condor session with Universe=Local."
        echo "WORKDIR=${WORKDIR}"
        echo "pwd"
        pwd
    fi
    echo "OUTPUTDIR     : $1"
    echo "OUTPUTNAME    : $2"
    echo "INPUTFILENAMES: $3"
    echo "IFILE         : $4"
    echo "CMSSWVERSION  : $5"
    echo "SCRAMARCH     : $6"
    shift 6
    #tar xvzf package.tar.gz
    #if [ $? -eq 0 ]; then
    #    echo "Successfully untarred package."
    #    :
    #else
    #    echo "Failed to untar package."
    #    exit
    #fi
fi
###################################################################################################

#OUTPUTDIR=$1
#OUTPUTNAME=$2
#INPUTFILENAMES=$3
#IFILE=$4
#CMSSWVERSION=$5
#SCRAMARCH=$6

OUTDIR=${OUTPUTDIR}
OUTPUT=${OUTPUTNAME}
JOBNUM=${IFILE}
RANDOMSEED=123${IFILE}
TAG=""

if [ -z ${OUTDIR} ]; then usage; fi
if [ -z ${OUTPUT} ]; then usage; fi
if [ -z ${JOBNUM} ]; then usage; fi
if [ -z ${RANDOMSEED} ]; then usage; fi

# Verbose
date
echo "================================================"
echo "$(basename $0) $*"
echo "$(basename $0) $*" >> $DIR/.$(basename $0).history
echo "------------------------------------------------"
echo "FRAGMENT          : ${FRAGMENT}"
echo "OUTDIR            : ${OUTDIR}"
echo "OUTPUT            : ${OUTPUT}"
echo "JOBNUM            : ${JOBNUM}"
echo "RANDOMSEED        : ${RANDOMSEED}"
echo "CMSSWVERSION      : ${CMSSWVERSION}"
echo "TAG               : ${TAG}"
echo "================================================"



#!/bin/bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc630
if [ -r CMSSW_9_3_4/src ] ; then 
 echo release CMSSW_9_3_4 already exists
else
scram p CMSSW CMSSW_9_3_4
fi
cd CMSSW_9_3_4/src
eval `scram runtime -sh`

curl -s --insecure https://cms-pdmv.cern.ch/mcm/public/restapi/requests/get_fragment/SMP-RunIIFall17wmLHEGS-00059 --retry 2 --create-dirs -o Configuration/GenProduction/python/SMP-RunIIFall17wmLHEGS-00059-fragment.py 
[ -s Configuration/GenProduction/python/SMP-RunIIFall17wmLHEGS-00059-fragment.py ] || exit $?;

#cat << EOF > www_2l_fragment.py
#import FWCore.ParameterSet.Config as cms
#
#externalLHEProducer = cms.EDProducer("ExternalLHEProducer",
#    args = cms.vstring('/cvmfs/cms.cern.ch/phys_generator/gridpacks/2017/13TeV/madgraph/V5_2.4.2/VVV/WWWJets_4f_NLO_slc6_amd64_gcc481_CMSSW_7_1_30_tarball.tar.xz'),
#    nEvents = cms.untracked.uint32(5000),
#    numberOfParameters = cms.uint32(1),
#    outputFile = cms.string('cmsgrid_final.lhe'),
#    scriptName = cms.FileInPath('GeneratorInterface/LHEInterface/data/run_generic_tarball_cvmfs.sh')
#)
#from Configuration.Generator.Pythia8CommonSettings_cfi import *
#from Configuration.Generator.MCTunes2017.PythiaCP5Settings_cfi import *
#from Configuration.Generator.Pythia8aMCatNLOSettings_cfi import *
#
#generator = cms.EDFilter("Pythia8HadronizerFilter",
#                         maxEventsToPrint = cms.untracked.int32(1),
#                         pythiaPylistVerbosity = cms.untracked.int32(1),
#                         filterEfficiency = cms.untracked.double(1.0),
#                         pythiaHepMCVerbosity = cms.untracked.bool(False),
#                         comEnergy = cms.double(13000.),
#                         PythiaParameters = cms.PSet(
#                            pythia8CommonSettingsBlock,
#                            pythia8CP5SettingsBlock,
#                            pythia8aMCatNLOSettingsBlock,
#                            processParameters = cms.vstring(
#                                '23:mMin = 0.05',      
#                                '24:mMin = 0.05',      
#                                'TimeShower:nPartonsInBorn = 0', #number of coloured particles (before resonance decays) in born matrix element
#                                'ResonanceDecayFilter:filter = on', 
#                                'ResonanceDecayFilter:exclusive = off', #off: require at least the specified number of daughters, on: require exactly the specified number of daughters
#                                'ResonanceDecayFilter:eMuAsEquivalent = off', #on: treat electrons and muons as equivalent
#                                'ResonanceDecayFilter:eMuTauAsEquivalent = on', #on: treat electrons, muons , and taus as equivalent
#                                'ResonanceDecayFilter:allNuAsEquivalent = on', #on: treat all three neutrino flavours as equivalent
#            #'ResonanceDecayFilter:mothers =', #list of mothers not specified -> count all particles in hard process+resonance decays (better to avoid specifying mothers when including leptons from the lhe in counting, since intermediate resonances are not gauranteed to appear in general
#                                'ResonanceDecayFilter:daughters = 11,11'
#                                ),
#                            parameterSets = cms.vstring('pythia8CommonSettings',
#                                    'pythia8CP5Settings',
#                                    'pythia8aMCatNLOSettings',
#                                    'processParameters',
#                                    )
#                            )
#                         )
#ProductionFilterSequence = cms.Sequence(generator)
#
#EOF
#
#mkdir -p Configuration/GenProduction/python/
#cp www_2l_fragment.py Configuration/GenProduction/python/

scram b
cd ../../
#cmsDriver.py Configuration/GenProduction/python/www_2l_fragment.py \
cmsDriver.py Configuration/GenProduction/python/SMP-RunIIFall17wmLHEGS-00059-fragment.py \
    --fileout file:file_GEN-SIM__LHE.root \
    --mc \
    --eventcontent RAWSIM,LHE \
    --customise_commands "process.source.numberEventsInLuminosityBlock = cms.untracked.uint32(50) \n process.source.firstRun = cms.untracked.uint32(${JOBNUM}) \n process.RandomNumberGeneratorService.externalLHEProducer.initialSeed = ${RANDOMSEED}" \
    --datatier GEN-SIM,LHE \
    --conditions 93X_mc2017_realistic_v3 \
    --beamspot Realistic25ns13TeVEarly2017Collision \
    --step LHE,GEN,SIM \
    --geometry DB:Extended \
    --era Run2_2017 \
    --python_filename SMP-RunIIFall17wmLHEGS-00059_1_cfg.py \
    --no_exec \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    -n 500 || exit $? ;
cmsRun -e -j GEN-SIM,LHE.xml SMP-RunIIFall17wmLHEGS-00059_1_cfg.py

#!/bin/bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc630
if [ -r CMSSW_9_4_0_patch1/src ] ; then
 echo release CMSSW_9_4_0_patch1 already exists
else
scram p CMSSW CMSSW_9_4_0_patch1
fi
cd CMSSW_9_4_0_patch1/src
eval `scram runtime -sh`


scram b
cd ../../
cmsDriver.py step1 \
    --filein file:file_GEN-SIM__LHE.root \
    --fileout file:file_GEN-SIM-RAW.root \
    --pileup_input "file:/hadoop/cms/store/user/phchang/pileupfiles/F4CEFFB5-FC0E-E811-A015-0025905B857E.root" \
    --mc \
    --eventcontent PREMIXRAW \
    --datatier GEN-SIM-RAW \
    --conditions 94X_mc2017_realistic_v11 \
    --step DIGIPREMIX_S2,DATAMIX,L1,DIGI2RAW,HLT:2e34v40 \
    --datamix PreMix \
    --era Run2_2017 \
    --python_filename SMP-RunIIFall17DRPremix-00015_1_cfg.py \
    --no_exec \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    -n 500 || exit $? ;
cmsRun -e -j GEN-SIM-RAW.xml SMP-RunIIFall17DRPremix-00015_1_cfg.py

cmsDriver.py step2 \
    --filein file:file_GEN-SIM-RAW.root \
    --fileout file:file_AODSIM.root \
    --mc \
    --eventcontent AODSIM \
    --runUnscheduled \
    --datatier AODSIM \
    --conditions 94X_mc2017_realistic_v11 \
    --step RAW2DIGI,RECO,RECOSIM,EI \
    --era Run2_2017 \
    --python_filename SMP-RunIIFall17DRPremix-00015_2_cfg.py \
    --no_exec \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    -n 500 || exit $? ;
cmsRun -e -j AODSIM.xml SMP-RunIIFall17DRPremix-00015_2_cfg.py

#!/bin/bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc6_amd64_gcc630
if [ -r CMSSW_9_4_6_patch1/src ] ; then
 echo release CMSSW_9_4_6_patch1 already exists
else
scram p CMSSW CMSSW_9_4_6_patch1
fi
cd CMSSW_9_4_6_patch1/src
eval `scram runtime -sh`


scram b
cd ../../
cmsDriver.py step1 \
    --filein file:file_AODSIM.root \
    --fileout file:file_MINIAODSIM.root \
    --mc \
    --eventcontent MINIAODSIM \
    --runUnscheduled \
    --datatier MINIAODSIM \
    --conditions 94X_mc2017_realistic_v14 \
    --step PAT \
    --scenario pp \
    --era Run2_2017,run2_miniAOD_94XFall17 \
    --python_filename SMP-RunIIFall17MiniAODv2-00024_1_cfg.py \
    --no_exec \
    --customise Configuration/DataProcessing/Utils.addMonitoring \
    -n 500 || exit $? ;
cmsRun -e -j MINIAODSIM.xml SMP-RunIIFall17MiniAODv2-00024_1_cfg.py

FINALOUTPUT=file_MINIAODSIM.root 


# Printing out some information about the result of each step
XML=GEN-SIM,LHE.xml
echo "getting stats from "${XML}
grep "TotalEvents" ${XML}
grep "Timing-tstoragefile-write-totalMegabytes"  ${XML}
grep "PeakValueRss" ${XML}
grep "AvgEventTime" ${XML}
grep "AvgEventCPU"  ${XML}
grep "TotalJobCPU"  ${XML}
grep "EventThroughput" ${XML}


# Printing out some information about the result of each step
XML=GEN-SIM-RAW.xml
echo "getting stats from "${XML}
grep "TotalEvents" ${XML}
grep "Timing-tstoragefile-write-totalMegabytes"  ${XML}
grep "PeakValueRss" ${XML}
grep "AvgEventTime" ${XML}
grep "AvgEventCPU"  ${XML}
grep "TotalJobCPU"  ${XML}
grep "EventThroughput" ${XML}


# Printing out some information about the result of each step
XML=AODSIM.xml
echo "getting stats from "${XML}
grep "TotalEvents" ${XML}
grep "Timing-tstoragefile-write-totalMegabytes"  ${XML}
grep "PeakValueRss" ${XML}
grep "AvgEventTime" ${XML}
grep "AvgEventCPU"  ${XML}
grep "TotalJobCPU"  ${XML}
grep "EventThroughput" ${XML}


# Printing out some information about the result of each step
XML=MINIAODSIM.xml
echo "getting stats from "${XML}
grep "TotalEvents" ${XML}
grep "Timing-tstoragefile-write-totalMegabytes"  ${XML}
grep "PeakValueRss" ${XML}
grep "AvgEventTime" ${XML}
grep "AvgEventCPU"  ${XML}
grep "TotalJobCPU"  ${XML}
grep "EventThroughput" ${XML}


# For copying outputs when using some older CMSSW this stupid thing needs to be loaded
export LD_PRELOAD=/usr/lib64/gfal2-plugins//libgfal_plugin_xrootd.so 

gfal-copy -p -f -t 4200 --verbose file://`pwd`/${FINALOUTPUT} gsiftp://gftp.t2.ucsd.edu/${OUTPUTDIR}/${OUTPUTNAME}_${IFILE}.root --checksum ADLER32
echo "Bye."

date

