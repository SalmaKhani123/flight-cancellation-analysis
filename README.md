# ✈️ U.S. Flight Cancellation Analysis


## 📊 Project Overview

An end-to-end data analytics project analyzing **1.19 million U.S. domestic flights** from January 2019 and January 2020 to identify cancellation patterns and predict flight cancellation risk using machine learning.

## 🎯 Key Insights

| Metric | Value |
|--------|-------|
| Total Flights Analyzed | 1.19M |
| Overall Cancellation Rate | 2.0% |
| Worst Day for Cancellations | Saturday (3.0%) |
| Highest Risk Carrier | MQ - Envoy Air (5.3%) |
| Lowest Risk Carrier | HA - Hawaiian Airlines (0.17%) |

### Key Findings:
- **Saturday flights have 67% higher cancellation risk** compared to Thursday (lowest day)
- **Regional carriers (MQ, EV, OO) have 2-3x higher cancellation rates** than major carriers
- **Hawaiian Airlines (HA) has the lowest cancellation rate** at just 0.17%
- **Geographic hotspots**: Chicago O'Hare and Northeast airports show elevated cancellation risk

---

## 🛠️ Tech Stack

| Tool | Purpose |
|------|---------|
| **Snowflake** | Cloud data warehouse for data storage and SQL transformations |
| **Python** | Machine learning model development (scikit-learn) |
| **Tableau** | Interactive dashboard visualization |
| **Google Colab** | Python development environment |

---

## 📁 Project Structure
```
flight-cancellation-analysis/
├── README.md
├── sql/
│   └── snowflake_queries.sql
├── python/
│   └── flight_cancellation_ml_model.py
├── docs/
│   ├── data_dictionary.md
│   └── tableau_config.md
└── images/
    └── dashboard_preview.png
```

---

## 🗄️ Data Source

**Bureau of Transportation Statistics (BTS)**  
https://www.transtats.bts.gov/

- **Dataset**: On-Time Performance Data
- **Time Period**: January 2019 & January 2020
- **Records**: 1,191,331 individual flights
- **Aggregated Routes**: 480,979 unique route combinations

---

## 🔄 Data Pipeline
```
Raw Data (CSV) → Snowflake (Staging) → SQL Transformations → Aggregated Views → ML Predictions → Tableau Dashboard
```

### Pipeline Steps:
1. **Ingestion**: Load raw CSV files into Snowflake staging tables
2. **Cleaning**: Handle nulls, filter cancelled flights for analysis
3. **Aggregation**: Group by day, carrier, origin, destination
4. **ML Training**: Train Random Forest model on balanced dataset
5. **Prediction**: Apply predictions to all routes
6. **Visualization**: Connect Tableau to Snowflake for dashboarding

---

## 🤖 Machine Learning Model

### Model Details:
- **Algorithm**: Random Forest Classifier
- **Target Variable**: Flight Cancellation (Yes/No)
- **Training Data**: 47,308 flights (balanced 50/50 split)
- **Test Accuracy**: 73%

### Features Used:
| Feature | Description |
|---------|-------------|
| DAY_OF_WEEK | Day of week (1-7) |
| CARRIER | Airline carrier code |
| ORIGIN | Origin airport code |
| DEST | Destination airport code |
| DISTANCE | Flight distance in miles |

### Model Performance:
```
              precision    recall  f1-score   support

Not Cancelled     0.74      0.71      0.73      4735
    Cancelled     0.72      0.75      0.73      4727

     accuracy                         0.73      9462
```

### ⚠️ Important Note on Model Training:
The training data was intentionally balanced (50/50 cancelled vs not cancelled) to ensure the model learns cancellation patterns effectively. In production, the decision threshold would be recalibrated to reflect the true 2% baseline cancellation rate.

---

## 📈 Dashboard Features

### Visualizations:
1. **Geographic Map**: U.S. airports sized by flight volume, colored by cancellation risk
2. **Carrier Analysis**: Horizontal bar chart ranking airlines by cancellation rate
3. **Day of Week Trends**: Bar chart showing cancellation patterns across weekdays
4. **KPI Cards**: Key metrics at a glance (Total Flights, Cancellation Rate, Worst/Best Carriers)

### Interactivity:
- Filter by carrier
- Hover tooltips with detailed metrics
- Color-coded risk indicators

---

## 🚀 How to Reproduce

### Prerequisites:
- Snowflake account (trial available)
- Python 3.8+ with scikit-learn, pandas
- Tableau Desktop or Tableau Public

### Steps:
1. Clone this repository
2. Run SQL scripts in Snowflake to create database and tables
3. Upload CSV data to Snowflake stage
4. Run Python ML script in Google Colab
5. Connect Tableau to Snowflake and build visualizations

---

## 📊 Future Enhancements

- [ ] Add Dashboard 2: ML Predictions vs Actual comparison
- [ ] Incorporate weather data as additional feature
- [ ] Add time-of-day analysis (morning vs evening flights)
- [ ] Deploy ML model as API for real-time predictions
- [ ] Automate data refresh with Snowflake tasks

---

## 👩‍💻 Author

**Salma Khani**  
Business Intelligence & Data Analytics

- 🌐 Portfolio: [salmakhani.com](https://salmakhani.com)
- 💼 LinkedIn: [Connect with me](https://linkedin.com/in/YOUR_LINKEDIN)

---

## 📜 License

This project is for educational and portfolio purposes. Data sourced from publicly available U.S. Bureau of Transportation Statistics.
