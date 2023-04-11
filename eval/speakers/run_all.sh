#!/bin/bash
echo RUN 1/9 - NOISY orig
bash run_noisy.sh
echo RUN 2/9 - NOISY 100
bash run_100_noisy.sh
echo RUN 3/9 - NOISY 80
bash run_80_noisy.sh
echo RUN 4/9 - NOISY 50
bash run_50_noisy.sh
echo RUN 5/9 - CLEAN orig
bash run_clean.sh
echo RUN 6/9 - CLEAN 100
bash run_100_clean.sh
echo RUN 7/9 - CLEAN 80
bash run_80_clean.sh
echo RUN 8/9 - CLEAN 50
bash run_50_clean.sh
echo RUN 9/9 - CLEAN 33
bash run_33_clean.sh
