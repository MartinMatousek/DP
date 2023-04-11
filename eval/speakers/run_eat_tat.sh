!/bin/bash

set -e
set -o pipefail

storage_dir=

python_path=C:/Users/mmatousek/anaconda3/python.exe

stage=4
id=0
tag=""

sample_rate=8000

# Evaluation
eval_use_gpu=1

#CLEAN part
task=sep_clean
folder=clean

#TAT clean
. utils/parse_options.sh

dumpdir=data/wav8k/tat

test_dir=data/wav8k/tat/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$folder/tat
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"


echo "Stage 1/4 : TAT clean Evaluation"
CUDA_VISIBLE_DEVICES=$id $python_path eval_eat_tat_clean.py \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log

#EAT clean
. utils/parse_options.sh

dumpdir=data/wav8k/eat

test_dir=data/wav8k/eat/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$folder/eat
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"


echo "Stage 2/4 : EAT clean Evaluation"
CUDA_VISIBLE_DEVICES=$id $python_path eval_eat_tat_clean.py \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log


#NOISY part
task=sep_noisy
folder=noisy

#TAT noisy
. utils/parse_options.sh

dumpdir=data/wav8k/tat

test_dir=data/wav8k/tat/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$folder/tat
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"


echo "Stage 3/4 : TAT noisy Evaluation"
CUDA_VISIBLE_DEVICES=$id $python_path eval_eat_tat_noisy.py \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log

#EAT noisy
. utils/parse_options.sh

dumpdir=data/wav8k/eat

test_dir=data/wav8k/eat/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$folder/eat
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"


echo "Stage 4/4 : EAT noisy Evaluation"
CUDA_VISIBLE_DEVICES=$id $python_path eval_eat_tat_noisy.py \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log