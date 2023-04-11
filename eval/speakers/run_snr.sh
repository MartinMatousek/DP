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

#NOISE clean
. utils/parse_options.sh

dumpdir=data/wav8k/noise_test

test_dir=data/wav8k/noise_test/tt

folder=snr_noisy100

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

#S1 clean
. utils/parse_options.sh

dumpdir=data/wav8k/s1_test

test_dir=data/wav8k/s1_test/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$folder/s1_clean
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"


echo "Stage 1/2 : S1 clean Evaluation"
CUDA_VISIBLE_DEVICES=$id $python_path eval_snr.py \
	--speakers 1 \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log

#S2 clean
# . utils/parse_options.sh

# dumpdir=data/wav8k/s2_test

# test_dir=data/wav8k/s2_test/tt

# uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

# expdir=exp/$folder/s2_clean
# mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
# echo "Results from the following experiment will be stored in $expdir"


# echo "Stage 2/4 : S2 clean"
# CUDA_VISIBLE_DEVICES=$id $python_path eval_snr.py \
	# --task $task \
	# --test_dir $test_dir \
	# --use_gpu $eval_use_gpu \
	# --exp_dir ${expdir} | tee logs/eval_${tag}.log
# cp logs/eval_${tag}.log $expdir/eval.log


#NOISY part
task=sep_noisy

#S1 noisy
. utils/parse_options.sh

dumpdir=data/wav8k/s1_test

test_dir=data/wav8k/s1_test/tt

uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

expdir=exp/$folder/s1_noisy
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"


echo "Stage 2/2 : S1 noisy Evaluation"
CUDA_VISIBLE_DEVICES=$id $python_path eval_snr.py \
	--speakers 1 \
	--task $task \
	--test_dir $test_dir \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir} | tee logs/eval_${tag}.log
cp logs/eval_${tag}.log $expdir/eval.log

#S2 noisy
# . utils/parse_options.sh

# dumpdir=data/wav8k/s2_test

# test_dir=data/wav8k/s2_test/tt

# uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')

# expdir=exp/$folder/s2_noisy
# mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
# echo "Results from the following experiment will be stored in $expdir"


# echo "Stage 4/4 : S2 noisy Evaluation"
# CUDA_VISIBLE_DEVICES=$id $python_path eval_snr.py \
	# --task $task \
	# --test_dir $test_dir \
	# --use_gpu $eval_use_gpu \
	# --exp_dir ${expdir} | tee logs/eval_${tag}.log
# cp logs/eval_${tag}.log $expdir/eval.log
