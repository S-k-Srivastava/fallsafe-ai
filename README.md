# 🛡️ FallSafe AI  
### On-Device Fall Detection with Inertial Sensors & Applied Machine Learning

**FallSafe AI** is an end-to-end, on-device fall detection system built using **mobile inertial sensor data** and **deep learning**, with a strong emphasis on **model evaluation, deployability, and system-level robustness**.

The project covers the full ML lifecycle:  
**dataset → preprocessing → windowing → multi-task training → TFLite deployment → real-time inference**.

---

## 🎯 Problem Statement

Falls are rare, high-impact events that are difficult to detect reliably using noisy mobile sensor data.  
Many ML approaches fail due to poor generalization and high false-positive rates after deployment.

FallSafe AI addresses these challenges through **careful model design, evaluation discipline, and runtime decision logic**, not just raw accuracy optimization.

---

## 📊 Dataset & Source Attribution

The model was trained and evaluated using the **MobiFall Dataset v2.0**, a publicly available benchmark dataset for fall detection research.

- **Dataset:** MobiFall Dataset v2.0  
- **Source:** Kaggle  
- **Link:** https://www.kaggle.com/datasets/kmknation/mobifall-dataset-v20/data  
- **Description:** Smartphone-based inertial sensor recordings of simulated falls and daily activities performed by multiple subjects.
- **Sensors Used:**
  - Accelerometer
  - Gyroscope
  - Orientation (derived via sensor fusion)

This dataset provides diverse motion patterns across subjects and activities, enabling realistic evaluation of fall-detection systems.

---

## 🧠 ML System Overview

### Input Representation
- Sliding window time-series
- Shape:
```

[1, 200, 9]

```
- Channels:
- Accelerometer (x, y, z)
- Gyroscope (x, y, z)
- Orientation (x, y, z) *(optional at runtime)*

---

## 🏗️ Model Architecture

- **Temporal CNN (1D Convolutions + Dilations)**
- **Multi-task learning**:
- **Head 1:** Fall vs ADL (binary classification)
- **Head 2:** Activity / fall cause (13-class classification)

CNNs were selected over RNNs to ensure:
- TensorFlow Lite compatibility
- Low-latency mobile inference
- Stable performance after deployment

---

## 📈 Evaluation Results

Evaluated using **subject-independent splits** to prevent data leakage.

| Metric | Result |
|---|---|
| Fall Recall | **~96%** |
| Overall Accuracy | **~95%** |
| Post-TFLite Accuracy Loss | ~0% |
| Inference Latency | < 20 ms (mobile CPU) |

Accuracy was validated **after TFLite conversion**, not just in Keras.

---

## 🧩 False Positive Control (Runtime Logic)

A fall is confirmed only when:
- Fall probability > **0.8**
- Detected in **≥ 3 consecutive windows**
- Acceleration magnitude > **15 m/s²**
- No fall detected in the last **30 seconds** (cooldown)

This system-level logic significantly reduces false positives from transient motion.

---

## 📱 Deployment

- **Runtime:** TensorFlow Lite
- **Platform:** Flutter (Android)
- **Sensors:** Accelerometer, Gyroscope  
*(Orientation via rotation vector can be added via platform channels)*

All inference runs fully **on-device**, preserving privacy and minimizing latency.

---

## 📓 Training & Reproducibility

The full training pipeline is documented in a public Kaggle notebook:

👉 **https://www.kaggle.com/code/skshackster1/fall-detection-tflite**

The notebook includes:
- Dataset parsing & preprocessing
- Sliding window generation
- Multi-task training
- Evaluation metrics
- TFLite conversion & validation

---

## 🗂️ Activity Classes

```

Falls: BSC, FOL, SDL, STD
ADL:  WAL, JOG, STN, STU, SIT, SCH, CSI, CSO, LYI

```

---

## 🛠️ Tech Stack

- Python, NumPy, scikit-learn
- TensorFlow / Keras
- TensorFlow Lite
- Flutter (Dart)
- Android Sensors API

---

## 🧑‍💻 Author

**Saurav Kumar Srivastava**  
AI / ML Engineer — Applied ML, Mobile Inference, Agentic Systems

---

⭐ This project demonstrates production-oriented ML engineering, from ethical data usage and evaluation rigor to mobile deployment constraints.