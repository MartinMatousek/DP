#!/bin/bash

# Exit on error
set -e
set -o pipefail
storage_dir= 
python_path=python

stage=3 # Controls from which stage to start
tag=""  # Controls the directory name associated to the experiment
id=0

# Data
task=sep_clean  # Specify the task here (sep_clean, sep_noisy, enh_single, enh_both)
sample_rate=8000
mode=adapt80
nondefault_src=  # If you want to train a network with 3 output streams for example.

# Training
batch_size=8
num_workers=8
optimizer=adam
lr=0.001
epochs=200

# Architecture
n_blocks=8
n_repeats=3
mask_nonlinear=relu

# Evaluation
eval_use_gpu=1

. data/convtasnet/utils/parse_options.sh

sr_string=$(($sample_rate/1000))
suffix=wav${sr_string}k/$mode
dumpdir=data/convtasnet/data/$suffix  # directory to put generated json file

train_dir=$dumpdir/tr
valid_dir=$dumpdir/cv
test_dir=$dumpdir/tt

# Generate a random ID for the run if no tag is specified
uuid=$($python_path -c 'import uuid, sys; print(str(uuid.uuid4())[:8])')
if [[ -z ${tag} ]]; then
	tag=${task}_${sr_string}k${mode}_${uuid}
fi
expdir=exp/train_convtasnet_${tag}
mkdir -p $expdir && echo $uuid >> $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"

if [[ $stage -le 3 ]]; then
  echo "Stage 3: Training"
  mkdir -p logs
  CUDA_VISIBLE_DEVICES=$id $python_path data/convtasnet/train_adapt80.py \
		--train_dir $train_dir \
		--valid_dir $valid_dir \
		--task $task \
		--sample_rate $sample_rate \
		--lr $lr \
		--epochs $epochs \
		--batch_size $batch_size \
		--num_workers $num_workers \
		--mask_act $mask_nonlinear \
		--n_blocks $n_blocks \
		--n_repeats $n_repeats \
		--exp_dir ${expdir}/ | tee logs/train_${tag}.log
	cp logs/train_${tag}.log $expdir/train.log

	# Get ready to publish
	mkdir -p $expdir/publish_dir
	echo "wham/ConvTasNet" > $expdir/publish_dir/recipe_name.txt
fi

if [[ $stage -le 4 ]]; then
	echo "Stage 4 : Evaluation"
	CUDA_VISIBLE_DEVICES=$id $python_path data/convtasnet/eval.py \
		--task $task \
		--test_dir $test_dir \
		--use_gpu $eval_use_gpu \
		--exp_dir ${expdir} | tee logs/eval_${tag}.log
	cp logs/eval_${tag}.log $expdir/eval.log
fi
