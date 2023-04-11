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

# CLEAN OR NOISY
task=sep_noisy
main_dir=train_eng_eat_50_noisy

#EAT
. utils/parse_options.sh

test_dir=data/wav8k/eat/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$main_dir/eat
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt

echo "Stage 1/3 : EAT Evaluation - $expdir"
CUDA_VISIBLE_DEVICES=$id $python_path eval.py \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--main_dir $main_dir \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log

#TAT
. utils/parse_options.sh

test_dir=data/wav8k/tat/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$main_dir/tat
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt


echo "Stage 2/3 : TAT Evaluation - $expdir"
CUDA_VISIBLE_DEVICES=$id $python_path eval.py \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--main_dir $main_dir \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log

#ENG
. utils/parse_options.sh

test_dir=data/wav8k/min/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$main_dir/eng
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt


echo "Stage 3/3 : ENG Evaluation - $expdir"
CUDA_VISIBLE_DEVICES=$id $python_path eval.py \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--main_dir $main_dir \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log