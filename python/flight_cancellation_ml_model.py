"""
Flight Cancellation Prediction Model
=====================================
Author: Salma Khani
Purpose: Train a Random Forest model to predict flight cancellations
Data Source: Bureau of Transportation Statistics (Jan 2019 & Jan 2020)
"""

# ============================================
# STEP 1: IMPORT LIBRARIES
# ============================================
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report

print("Libraries imported successfully!")


# ============================================
# STEP 2: LOAD DATA
# ============================================
# Load the balanced cancellation dataset exported from Snowflake
df = pd.read_csv('flights_cancellation_ml.csv')

print(f"Total rows: {len(df)}")
print("\nCancellation breakdown:")
print(df['IS_CANCELLED'].value_counts())
print(f"\nColumns: {df.columns.tolist()}")


# ============================================
# STEP 3: EXPLORE DATA
# ============================================
print("="*50)
print("DATA EXPLORATION")
print("="*50)

# Check data types
print("\nData Types:")
print(df.dtypes)

# Check for missing values
print("\nMissing Values:")
print(df.isnull().sum())

# Basic statistics
print("\nBasic Statistics:")
print(df.describe())


# ============================================
# STEP 4: FEATURE ENCODING
# ============================================
print("\n" + "="*50)
print("FEATURE ENCODING")
print("="*50)

# Initialize label encoders for categorical variables
le_carrier = LabelEncoder()
le_origin = LabelEncoder()
le_dest = LabelEncoder()

# Encode categorical columns to numeric values
df['CARRIER_ENCODED'] = le_carrier.fit_transform(df['CARRIER'])
df['ORIGIN_ENCODED'] = le_origin.fit_transform(df['ORIGIN'])
df['DEST_ENCODED'] = le_dest.fit_transform(df['DEST'])

print("Text columns converted to numbers:")
print(df[['CARRIER', 'CARRIER_ENCODED', 'ORIGIN', 'ORIGIN_ENCODED']].head())

# Save encoders for later use
print(f"\nUnique carriers: {len(le_carrier.classes_)}")
print(f"Unique origins: {len(le_origin.classes_)}")
print(f"Unique destinations: {len(le_dest.classes_)}")


# ============================================
# STEP 5: PREPARE FEATURES AND TARGET
# ============================================
print("\n" + "="*50)
print("PREPARING FEATURES")
print("="*50)

# Define features (X) - what the model learns from
features = ['DAY_OF_WEEK', 'CARRIER_ENCODED', 'ORIGIN_ENCODED', 'DEST_ENCODED', 'DISTANCE']
X = df[features]

# Define target (y) - what we're predicting
y = df['IS_CANCELLED']

print(f"Features: {features}")
print(f"Target: IS_CANCELLED (0 = Not Cancelled, 1 = Cancelled)")


# ============================================
# STEP 6: SPLIT DATA (TRAIN/TEST)
# ============================================
print("\n" + "="*50)
print("TRAIN/TEST SPLIT")
print("="*50)

# Split: 80% training, 20% testing
X_train, X_test, y_train, y_test = train_test_split(
    X, y, 
    test_size=0.2, 
    random_state=42
)

print(f"Training set: {len(X_train)} flights")
print(f"Testing set: {len(X_test)} flights")


# ============================================
# STEP 7: TRAIN THE MODEL
# ============================================
print("\n" + "="*50)
print("TRAINING MODEL")
print("="*50)

print("Training Random Forest Classifier...")
print("This may take 30-60 seconds...")

# Create and train the model
model = RandomForestClassifier(
    n_estimators=100,
    random_state=42
)

model.fit(X_train, y_train)

print("✓ Model trained successfully!")


# ============================================
# STEP 8: EVALUATE MODEL
# ============================================
print("\n" + "="*50)
print("MODEL EVALUATION")
print("="*50)

# Make predictions on test data
y_pred = model.predict(X_test)

# Calculate accuracy
accuracy = accuracy_score(y_test, y_pred)

print(f" Model Accuracy: {accuracy * 100:.2f}%")
print("\nDetailed Performance Report:")
print(classification_report(y_test, y_pred, target_names=['Not Cancelled', 'Cancelled']))


# ============================================
# STEP 9: FEATURE IMPORTANCE
# ============================================
print("\n" + "="*50)
print("FEATURE IMPORTANCE")
print("="*50)

# Get feature importance scores
importance = pd.DataFrame({
    'Feature': features,
    'Importance': model.feature_importances_
}).sort_values('Importance', ascending=False)

print("\nWhich features matter most for predicting cancellations:")
print(importance.to_string(index=False))


# ============================================
# STEP 10: APPLY PREDICTIONS TO FULL DATASET
# ============================================
print("\n" + "="*50)
print("APPLYING PREDICTIONS TO FULL DATASET")
print("="*50)

# Load the full aggregated dataset from Snowflake
df_full = pd.read_csv('flights_full_for_predictions.csv')
print(f"Full dataset size: {len(df_full)} routes")

# Function to safely encode values (handle unknowns)
def safe_encode(encoder, column, default_value=-1):
    """Encode values, use default for unknowns not seen in training"""
    encoded = []
    for val in column:
        try:
            encoded.append(encoder.transform([val])[0])
        except ValueError:
            encoded.append(default_value)
    return encoded

# Encode categorical variables
print("Encoding categorical variables...")
df_full['CARRIER_ENCODED'] = safe_encode(le_carrier, df_full['CARRIER'])
df_full['ORIGIN_ENCODED'] = safe_encode(le_origin, df_full['ORIGIN'])
df_full['DEST_ENCODED'] = safe_encode(le_dest, df_full['DEST'])

# Prepare features for prediction
X_full = df_full[['DAY_OF_WEEK', 'CARRIER_ENCODED', 'ORIGIN_ENCODED', 'DEST_ENCODED', 'DISTANCE']]

# Generate predictions
print("Generating predictions...")
df_full['CANCELLATION_PREDICTION'] = model.predict(X_full)
df_full['CANCELLATION_PROBABILITY'] = model.predict_proba(X_full)[:, 1]

print("✓ Predictions complete!")
print(f"\nPredicted high-risk routes: {df_full['CANCELLATION_PREDICTION'].sum()}")
print(f"Average cancellation probability: {df_full['CANCELLATION_PROBABILITY'].mean()*100:.1f}%")


# ============================================
# STEP 11: SAVE RESULTS
# ============================================
print("\n" + "="*50)
print("SAVING RESULTS")
print("="*50)

# Save predictions to CSV
output_file = 'flights_with_ml_predictions.csv'
df_full.to_csv(output_file, index=False)

print(f"✓ Saved {len(df_full)} routes with predictions to: {output_file}")


# ============================================
# SUMMARY
# ============================================
print("\n" + "="*50)
print(" PROJECT SUMMARY")
print("="*50)
print(f"""
Data:
  - Training samples: {len(X_train)}
  - Testing samples: {len(X_test)}
  - Full dataset predictions: {len(df_full)}

Model Performance:
  - Algorithm: Random Forest Classifier
  - Accuracy: {accuracy * 100:.2f}%
  - Trees: 100

Output:
  - File: {output_file}
  - Ready for Tableau visualization!

⚠️ Note: Training data was balanced (50/50) to learn cancellation patterns.
   In production, recalibrate threshold for true 2% baseline rate.
""")

print("🎉 ML Pipeline Complete!")
