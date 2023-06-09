import numpy as np
import soundfile as sf
from scipy.signal import resample_poly
import os
import json


def read_scaled_wav(path, scaling_factor, downsample_8K=False):
    samples, sr_orig = sf.read(path)

    if len(samples.shape) > 1:
        samples = samples[:, 0]

    if downsample_8K:
        samples = resample_poly(samples, 8000, sr_orig)
    samples *= scaling_factor
    return samples


def wavwrite_quantize(samples):
    return np.int16(np.round((2 ** 15) * samples))


def quantize(samples):
    int_samples = wavwrite_quantize(samples)
    return np.float64(int_samples) / (2 ** 15)


def wavwrite(file, samples, sr):
    """This is how the old Matlab function wavwrite() quantized to 16 bit.
    We match it here to maintain parity with the original dataset"""
    int_samples = wavwrite_quantize(samples)
    sf.write(file, int_samples, sr, subtype='PCM_16')


def append_or_truncate(s1_samples, s2_samples, noise_samples, min_or_max='max', start_samp_16k=0, downsample=False):
    if downsample:
        speech_start_sample = start_samp_16k // 2
    else:
        speech_start_sample = start_samp_16k

    speech_end_sample = speech_start_sample + len(s1_samples)

    if min_or_max == 'min':
        noise_samples = noise_samples[speech_start_sample:speech_end_sample]
    else:
        s1_append = np.zeros_like(noise_samples)
        s2_append = np.zeros_like(noise_samples)
        s1_append[speech_start_sample:speech_end_sample] = s1_samples
        s2_append[speech_start_sample:speech_end_sample] = s2_samples
        s1_samples = s1_append
        s2_samples = s2_append

    return s1_samples, s2_samples, noise_samples


def fix_length(s1, s2, min_or_max='max'):
    # Fix length
    if min_or_max == 'min':
        utt_len = np.minimum(len(s1), len(s2))
        s1 = s1[:utt_len]
        s2 = s2[:utt_len]
    elif min_or_max == 'max':  # max
        utt_len = np.maximum(len(s1), len(s2))
        s1 = np.append(s1, np.zeros(utt_len - len(s1)))
        s2 = np.append(s2, np.zeros(utt_len - len(s2)))
    elif min_or_max == 'tat':
        utt_len = np.minimum(len(s1), len(s2))
        s1 = s1[-utt_len:]
        s2 = s2[-utt_len:]
    return s1, s2


def create_wham_mixes(s1_samples, s2_samples, noise_samples):
    mix_clean = s1_samples + s2_samples
    mix_single = noise_samples + s1_samples
    mix_both = noise_samples + s1_samples + s2_samples
    return mix_clean, mix_single, mix_both

def preprocess_one_dir(in_dir, out_dir, out_filename):
    """Create .json file for one condition."""
    file_infos = []
    in_dir = os.path.abspath(in_dir)
    wav_list = os.listdir(in_dir)
    wav_list.sort()
    for wav_file in wav_list:
        if not wav_file.endswith(".wav"):
            continue
        wav_path = os.path.join(in_dir, wav_file)
        samples = sf.SoundFile(wav_path)
        file_infos.append((wav_path, len(samples)))
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)
    with open(os.path.join(out_dir, out_filename + ".json"), "w") as f:
        json.dump(file_infos, f, indent=4)

def preprocess(in_dir, out_dir):
    speaker_list = ["mix_both", "mix_clean", "s1", "s2"]
    for data_type in ["tr", "cv", "tt"]:
        for spk in speaker_list:
            preprocess_one_dir(
                os.path.join(in_dir, data_type, spk),
                os.path.join(out_dir, data_type),
                spk,)