# 🛡️ FallSafe AI  
### Real-Time On-Device Fall Detection with Mobile Sensors & ML

**FallSafe AI** is a mobile application that detects human falls in real time using **on-device machine learning** and inertial sensor data (accelerometer, gyroscope, optional orientation).  
All inference runs locally using **TensorFlow Lite**, ensuring **low latency, privacy, and reliability**.

---

## 🚀 Key Features

- ✅ Real-time fall detection (**~96% recall**)
- ✅ Fall cause & activity classification (13 classes)
- ✅ On-device inference (no cloud dependency)
- ✅ False-positive reduction via temporal confirmation
- ✅ Battery-efficient, mobile-safe CNN model
- 📓 **Full training notebook available**

---

## 🧠 ML Overview

- **Model:** Temporal CNN (multi-task)
- **Inputs:** `[1, 200, 9]` sensor window  
  - Accel (x,y,z), Gyro (x,y,z), Orientation (optional)
- **Outputs:**
  - Fall probability (sigmoid)
  - Activity / fall cause (13-class softmax)

CNNs were chosen over RNNs for **TFLite compatibility and mobile performance**.

---

## 📊 Performance (MobiFall v2.0)

| Metric | Result |
|---|---|
| Fall Recall | **96%** |
| Accuracy | **95%** |
| TFLite Accuracy Loss | ~0% |
| Inference Latency | <20 ms |

---

## 📓 Training Notebook

A complete Kaggle notebook showing the entire training pipeline — from data loading, windowing, model training, and evaluation — is available here:

👉 **https://www.kaggle.com/code/skshackster1/fall-detection-tflite**

This notebook demonstrates:
- Parsing the MobiFall dataset  
- Multi-task model training  
- Evaluation metrics  
- TFLite conversion  
- Sanity-check inference in Python

---

## 🧩 False-Positive Prevention

A fall is confirmed only if:
- Fall probability > **0.8**
- Detected in **3 consecutive windows**
- Acceleration magnitude > **15 m/s²**
- No fall in last **30 seconds** (cooldown)

This avoids false alarms from brief, non-fall movements.

---

## 📱 Mobile Stack

- **Flutter**
- **TensorFlow Lite**
- **sensors_plus**
- Android accelerometer & gyroscope  
*(Orientation via rotation vector is optional)*

---

## 🗂️ Activity Classes

```

Falls: BSC, FOL, SDL, STD
ADL:  WAL, JOG, STN, STU, SIT, SCH, CSI, CSO, LYI

```

---

## 🧑‍💻 Author

**Saurav Kumar Srivastava**  
AI Engineer | Mobile ML | Agentic Systems

---

⭐ Designed as an end-to-end, deployable mobile ML system.  