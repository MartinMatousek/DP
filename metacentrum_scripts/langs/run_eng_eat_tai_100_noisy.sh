#!/bin/bash
#PBS -N eng_eat_tai_100_noisy
#PBS -l select=1:ncpus=1:mem=128gb:scratch_ssd=128gb:ngpus=1:gpu_cap=cuda80 -q gpu_long
#PBS -l walltime=120:00:00 
#PBS -m ae

TIME=$( date '+%F_%H:%M:%S' )
echo "SCRIPT STARTED:   $TIME"

# define a DATADIR variable: directory where the input files are taken from and where output will be copied to
DATADIR=/storage/plzen1/home/martin_matousek 

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of node it is run on and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt
arrIN=(${PBS_JOBID//./ })
JOID=${arrIN[0]}   

# test if scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

TIME=$( date '+%F_%H:%M:%S' )
echo "COPYING AND UNTARING STARTED:   $TIME"

chmod 700 $SCRATCHDIR

mkdir $SCRATCHDIR/data

cp $DATADIR/data/convtasnet.tar $SCRATCHDIR/data/

tar -zxvf $SCRATCHDIR/data/convtasnet.tar -C $SCRATCHDIR/data/

mkdir $SCRATCHDIR/data/wav8k

cp $DATADIR/data/min.tar $SCRATCHDIR/data/wav8k/
tar -zxvf $SCRATCHDIR/data/wav8k/min.tar -C $SCRATCHDIR/data/wav8k/

cd $SCRATCHDIR

TIME=$( date '+%F_%H:%M:%S' )
echo "INSTALLATION STARTED:   $TIME"

module load conda-modules
module load gcc-8.3.0
module add conda-modules-py37
# conda create --prefix=/storage/plzen1/home/martin_matousek/conda/dp_plzen python=3.8
conda activate /storage/plzen1/home/martin_matousek/conda/dp_plzen
export PATH=/storage/plzen1/home/martin_matousek/conda/dp_plzen/bin:$PATH
# conda install pytorch=1.10.0 torchvision torchaudio=0.10.0 cudatoolkit=11.1 -c pytorch -c conda-forge -y
# pip install asteroid
# pip install setuptools==59.5.0
# pip install librosa

TIME=$( date '+%F_%H:%M:%S' )
echo "STARTED:   $TIME"

bash data/convtasnet/run_eng_eat_tai_100_noisy.sh

TIME=$( date '+%F_%H:%M:%S' )
echo "FINISHED:   $TIME"

# move the output to user's DATADIR or exit in case of failure
mkdir $DATADIR/exp
mkdir $DATADIR/logs
mkdir $DATADIR/convtasnet/data
cp -R exp $DATADIR/exp/$JOID || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }
cp -R logs $DATADIR/logs/$JOID || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }
cp -R data/convtasnet/data/local $DATADIR/info || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }
cp -R data/convtasnet/data/wav8k $DATADIR/info || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }

TIME=$( date '+%F_%H:%M:%S' )
echo "SCRIPT FINISHED: $TIME"

# clean the SCRATCH directory
clean_scratch