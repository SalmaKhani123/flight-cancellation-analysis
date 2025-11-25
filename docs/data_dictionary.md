# Data Dictionary

## Raw Flight Data (flights_raw)

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| DAY_OF_MONTH | INT | Day of the month (1-31) |
| DAY_OF_WEEK | INT | Day of week (1=Monday, 7=Sunday) |
| OP_UNIQUE_CARRIER | VARCHAR | Unique carrier code |
| OP_CARRIER | VARCHAR | Operating carrier code |
| OP_CARRIER_FL_NUM | VARCHAR | Flight number |
| TAIL_NUM | VARCHAR | Aircraft tail number |
| OP_CARRIER_CODE | VARCHAR | Carrier code |
| ORIGIN_AIRPORT_ID | INT | Origin airport ID |
| ORIGIN_AIRPORT_SEQ_ID | INT | Origin airport sequence ID |
| ORIGIN | VARCHAR | Origin airport code (e.g., "ATL", "ORD") |
| DEST_AIRPORT_ID | INT | Destination airport ID |
| DEST_AIRPORT_SEQ_ID | INT | Destination airport sequence ID |
| DEST | VARCHAR | Destination airport code |
| DEP_TIME | VARCHAR | Actual departure time |
| DEP_DELAY | FLOAT | Departure delay in minutes (negative = early) |
| DEP_TIME_BLK | VARCHAR | Departure time block |
| ARR_TIME | VARCHAR | Actual arrival time |
| ARR_DELAY | FLOAT | Arrival delay in minutes (negative = early) |
| CANCELLED | INT | Cancellation flag (0=No, 1=Yes) |
| DIVERTED | INT | Diversion flag (0=No, 1=Yes) |
| DISTANCE | INT | Flight distance in miles |

---

## Aggregated View (FLIGHTS_CLEAN)

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| DAY_OF_WEEK | INT | Day of week (1-7) |
| CARRIER_CODE | VARCHAR | Airline carrier code |
| ORIGIN | VARCHAR | Origin airport code |
| DEST | VARCHAR | Destination airport code |
| AVG_DEP_DELAY | FLOAT | Average departure delay for this route |
| AVG_ARR_DELAY | FLOAT | Average arrival delay for this route |
| FLIGHT_COUNT | INT | Total number of flights on this route |
| DELAYED_FLIGHTS | INT | Number of delayed flights |
| CANCELLED_FLIGHTS | INT | Number of cancelled flights |
| DIVERTED_FLIGHTS | INT | Number of diverted flights |
| AVG_DISTANCE | FLOAT | Average flight distance |
| ON_TIME_PCT | FLOAT | Percentage of on-time flights |

---

## ML Training Data (flights_ml_data)

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| DAY_OF_WEEK | INT | Day of week (1-7) |
| CARRIER | VARCHAR | Airline carrier code |
| ORIGIN | VARCHAR | Origin airport code |
| DEST | VARCHAR | Destination airport code |
| DISTANCE | INT | Flight distance in miles |
| IS_CANCELLED | INT | Target variable (0=Not Cancelled, 1=Cancelled) |

---

## Predictions Table (flights_with_predictions)

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| DAY_OF_WEEK | INT | Day of week (1-7) |
| CARRIER | VARCHAR | Airline carrier code |
| ORIGIN | VARCHAR | Origin airport code |
| DEST | VARCHAR | Destination airport code |
| DISTANCE | FLOAT | Average flight distance |
| FLIGHT_COUNT | INT | Total flights on this route |
| CANCELLED_FLIGHTS | INT | Actual cancelled flights |
| AVG_DEP_DELAY | FLOAT | Average departure delay |
| AVG_ARR_DELAY | FLOAT | Average arrival delay |
| ON_TIME_PCT | FLOAT | On-time percentage |
| CARRIER_ENCODED | INT | Encoded carrier value |
| ORIGIN_ENCODED | INT | Encoded origin value |
| DEST_ENCODED | INT | Encoded destination value |
| CANCELLATION_PREDICTION | INT | ML prediction (0=No, 1=Yes) |
| CANCELLATION_PROBABILITY | FLOAT | ML probability score (0-1) |

---

## Carrier Code Reference

| Code | Airline Name |
|------|--------------|
| AA | American Airlines |
| AS | Alaska Airlines |
| B6 | JetBlue Airways |
| DL | Delta Air Lines |
| EV | ExpressJet Airlines |
| F9 | Frontier Airlines |
| G4 | Allegiant Air |
| HA | Hawaiian Airlines |
| MQ | Envoy Air (American Eagle) |
| NK | Spirit Airlines |
| OH | PSA Airlines |
| OO | SkyWest Airlines |
| UA | United Airlines |
| WN | Southwest Airlines |
| YV | Mesa Airlines |
| YX | Republic Airways |
| 9E | Endeavor Air |

---

## Day of Week Reference

| Value | Day |
|-------|-----|
| 1 | Monday |
| 2 | Tuesday |
| 3 | Wednesday |
| 4 | Thursday |
| 5 | Friday |
| 6 | Saturday |
| 7 | Sunday |
