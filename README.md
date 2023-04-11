<b>ÚVOD</b> - https://wiki.metacentrum.cz/wiki/Pruvodce_pro_zacatecniky

<b>PŘIHLÁŠENÍ PŘES PUTTY</b> - https://wiki.metacentrum.cz/wiki/Usage_of_PuTTY
martin_matousek@alfrid.metacentrum.cz

<b>NASTAVENÍ WinSCP</b> - https://wiki.metacentrum.cz/wiki/Usage_of_WinSCP
přenos dat do/z úložiště

<b>INTERAKTIVNÍ ÚLOHA</b> - instalace requirements do condy, nastavení, testování skriptů, ...
qsub -I -l select=1:ncpus=1:mem=128gb:scratch_ssd=128gb:ngpus=1:gpu_cap=cuda80 -q gpu -l walltime=1:00:00

# CONDA nastavení
### potřebné moduly
module load conda-modules
module load gcc-8.3.0
module add conda-modules-py37

### vytvoření enviromentu (povedlo se mi pouze s prefixem)
cd $SCRATCHDIR
conda create --prefix=/storage/plzen1/home/martin_matousek/conda/dp_plzen python=3.8
conda activate /storage/plzen1/home/martin_matousek/conda/dp_plzen

##### přidání enviromentu do PATH
export PATH=/storage/plzen1/home/martin_matousek/conda/dp_plzen/bin:$PATH

##### tohle pomohlo na ukládání pkgs, envs - ukládání na volných kvótách
conda config --prepend pkgs_dirs /storage/plzen1/home/martin_matousek/.conda/pkgs
conda config --prepend envs_dirs /storage/plzen1/home/martin_matousek/.conda/envs


## instalace potřebných závislostí pro trénování
##### jsou potřeba specifické verze, v jiných to vždy na něčem padá
conda install pytorch=1.10.0 torchvision torchaudio=0.10.0 cudatoolkit=11.1 -c pytorch -c conda-forge -y

conda install pytorch-lightning -c conda-forge

TMPDIR=/storage/plzen1/home/martin_matousek/cache_dir/ pip install asteroid --cache-dir=/storage/plzen1/home/martin_matousek/cache_dir/

TMPDIR=/storage/plzen1/home/martin_matousek/cache_dir/ pip install setuptools==59.5.0 --cache-dir=/storage/plzen1/home/martin_matousek/cache_dir/

TMPDIR=/storage/plzen1/home/martin_matousek/cache_dir/ pip install librosa --cache-dir=/storage/plzen1/home/martin_matousek/cache_dir/

##### kontrola CUDA
python -c 'import torch; print(torch.cuda.is_available())'

v python3.8/site-packages/pytorch-lightning/loops/training_epoch_loop.py:350
jsem přidal metric=0, protože to nějak v té verzi PL zlobilo

`call._call_lightning_module_hook(
                    trainer,
                    "lr_scheduler_step",
                    config.scheduler,
                    monitor_val,
					metric=0,
                )`

## MISC
Přepínat všechny skripty na Unixové LF konce řádků jinak s tím neumí pracovat (python soubory netřeba)

#### tar files
V GIT BASH
tar -cvzf convtasnet.tar "convtasnet"

## SPUŠTĚNÍ ÚLOHY
nastavení možností stroje přímo v scriptu - https://wiki.metacentrum.cz/wiki/About_scheduling_system#qsub_options
qsub data/run_conv.sh
qsub data/run_conv_long.sh
...

<b>TROUBLESHOOTING</b> https://wiki.metacentrum.cz/wiki/FAQ/Grid_computing

<b>prodloužení úlohy</b>
qextend 14518449.meta-pbs.metacentrum.cz 24:00:00
