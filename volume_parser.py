import librosa
import numpy as np
import json

########################
### VOLUME CONVERTER ###
########################

file = "pt1_var1.mp3" # FILE NAME HERE

print("Loading " + file + "...")
y, sr = librosa.load(file, mono=True)
print(f"Loaded! Length: {len(y)} samples, SR: {sr}")

hop_length = int(sr / 60)
print(f"Step: {hop_length} samples (~{1/60:.3f} seconds)")

values = []
for idx, i in enumerate(range(0, len(y), hop_length)):
    frame = y[i:i+hop_length]
    if len(frame) == 0:
        continue
    rms = np.sqrt(np.mean(frame**2))
    values.append(float(rms))

    if idx % 100 == 0:
        print(f"[{idx}] RMS = {rms:.4f}")

print("Total frames:", len(values))

max_val = max(values) if values else 1
values = [round(float(v) / max_val, 4) for v in values]

print(f"Max volume (before normalization): {max_val:.4f}")
print("Examples of normalized values:", values[:10])

with open("volume.json", "w") as f:
    json.dump(values, f)

print("Done! File volume.json converted and saved.")