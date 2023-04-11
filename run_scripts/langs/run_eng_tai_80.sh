#!/bin/bash

# Exit on error
set -e
set -o pipefail
python_path=python

# Evaluation
eval_use_gpu=1
id=0
. data/convtasnet/utils/parse_options.sh

task=eng_tai_80
mode=sep_clean

folder=data/convtasnet/data/wav8k/$task
train_dir=$folder/tr
valid_dir=$folder/cv
test_dir=$folder/tt


expdir=exp/train_$task
mkdir -p $expdir && echo $expdir/run_uuid.txt
echo "Results from the following experiment will be stored in $expdir"

echo "Stage 1: Training"
mkdir -p logs
CUDA_VISIBLE_DEVICES=$id $python_path data/convtasnet/train.py \
	--conf_dir data/convtasnet/local/adapt_${task}.yml \
	--exp_dir ${expdir}/ | tee logs/train_${task}.log
cp logs/train_${task}.log $expdir/train.log

# Get ready to publish
mkdir -p $expdir/publish_dir
echo "wham/ConvTasNet" > $expdir/publish_dir/recipe_name.txt


echo "Stage 2 : EAT Evaluation"
mkdir -p $expdir/eat
CUDA_VISIBLE_DEVICES=$id $python_path data/convtasnet/eval.py \
	--task $mode \
	--conf_dir data/convtasnet/local/adapt_eat.yml \
	--test_dir data/convtasnet/data/wav8k/eat/tt \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir}/eat | tee logs/eval_${task}.log
cp logs/eval_${task}.log $expdir/eval.log
	
echo "Stage 3 : TAI Evaluation"
mkdir -p $expdir/tai
CUDA_VISIBLE_DEVICES=$id $python_path data/convtasnet/eval.py \
	--task $mode \
	--conf_dir data/convtasnet/local/adapt_tai.yml \
	--test_dir data/convtasnet/data/wav8k/tai/tt \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir}/tai | tee logs/eval_${task}.log
cp logs/eval_${task}.log $expdir/eval.log

echo "Stage 4 : ENG Evaluation"
mkdir -p $expdir/eng
CUDA_VISIBLE_DEVICES=$id $python_path data/convtasnet/eval.py \
	--task $mode \
	--conf_dir data/convtasnet/local/adapt_eng.yml \
	--test_dir data/convtasnet/data/wav8k/eng/tt \
	--use_gpu $eval_use_gpu \
	--exp_dir ${expdir}/eng | tee logs/eval_${task}.log
cp logs/eval_${task}.log $expdir/eval.log