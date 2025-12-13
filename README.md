# 🦢⬛ Black Swan Credit Detector
"It does not matter how frequently something succeeds if failure is too costly to bear." — By Nassim Nicholas Taleb. 
A scalable credit risk engine designed to detect financial fragility and 'Black Swan' events. Inspired by Nassim Taleb's concept of asymmetric risk.

![Status](https://img.shields.io/badge/Status-Phase%201%3A%20Data%20Engineering-blue) ![Stack](https://img.shields.io/badge/Tech-Polars%20%7C%20SQL%20%7C%20Parquet-green)

## 🎯 The Philosophy: Why "Black Swan"?
Traditional Credit Scoring systems often rely on **averages** (e.g., average monthly balance). However, in credit risk, the payoff is **asymmetric**:
* **Upside:** Limited (Interest payments).
* **Downside:** Unlimited relative to profit (Default/Total Loss).

This project is built on the premise that **averages hide risks**. To protect the downside, we must hunt for **Outliers** and **Fragility Signals** (Taleb's "Black Swans").

Instead of asking *"How does this client behave on average?"*, this engine asks: *"How did this client behave on their worst day?"*

## 🏗 Technical Architecture (Current State)
This repository currently hosts the **Data Engineering foundation** (Phase 1).
It implements a scalable "Big Data" pipeline capable of processing datasets larger than local RAM, avoiding typical Pandas memory errors.

### 1. Feature Engineering (SQL)
The SQL logic (`feature_engineering.sql`) aggregates raw data from multiple sources to create a comprehensive view of the client's financial health.

Instead of simple averages, the focus is on extracting **behavioral patterns**:
* **Delinquency History:** Identifying past payment failures and historical delays.
* **Financial Stability:** Tracking volatility in payment amounts and contract changes.
* **Credit Exposure:** Aggregating total debt loads from external bureaus to understand the client's overall burden.


## 📂 Project Structure

```text
/black-swan-credit-detector
│
├── /data_pipeline            # ✅ COMPLETED (Phase 1)
│   ├── feature_engineering.sql  # SQL Logic: Creating the Risk Data Marts
│   └── etl_script.py            # TO DO
│
├── /training                 # 🚧 PLANNED (Phase 2)
│   └── (To be added: XGBoost training with custom asymmetric loss)
│
└── /serving                  # 🔮 PLANNED (Phase 3)
    └── (To be added: FastAPI & Docker containerization)
