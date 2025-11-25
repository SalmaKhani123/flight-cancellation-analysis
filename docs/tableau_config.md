# Tableau Configuration Guide

## Dashboard Overview
This configuration reflects Dashboard 1: Historical Cancellation Analysis (actual data, not ML predictions).

---

## Calculated Fields

### 1. Cancellation Rate by Group
**Purpose**: Calculate cancellation rate for carriers, days, airports
```
SUM([Cancelled Flights]) / SUM([Flight Count])
```
**Format**: Percentage, 1 decimal place  
**Used in**: Map colors, carrier bars, day of week bars

---

### 2. Day Name
**Purpose**: Convert DAY_OF_WEEK number to readable day name
```
CASE [Day Of Week]
    WHEN 1 THEN 'Monday'
    WHEN 2 THEN 'Tuesday'
    WHEN 3 THEN 'Wednesday'
    WHEN 4 THEN 'Thursday'
    WHEN 5 THEN 'Friday'
    WHEN 6 THEN 'Saturday'
    WHEN 7 THEN 'Sunday'
END
```
**Used in**: Day of week chart X-axis labels

---

## Geographic Configuration

### Setting Up Airport Locations

1. **Right-click on ORIGIN** → Geographic Role → **Airport**
2. **Right-click on DEST** → Geographic Role → **Airport**

Tableau automatically assigns latitude/longitude based on airport codes.

---

## Color Configuration

### Map Colors (Cancellation Rate by Airport)
**Data Source**: FLIGHTS_CLEAN aggregated by ORIGIN  
**Color Field**: Cancellation Rate (calculated field)

**Palette**: Red-Green-Gold Diverging
- **Reversed**: ✓ (red = high cancellation rate)
- **Stepped Color**: 5 steps
- **Range**: 0% to 4% (reflects actual data distribution)
- **Colors**: 
  - 0-0.8%: Dark Green (low risk)
  - 0.8-1.6%: Light Green
  - 1.6-2.4%: Yellow/Gold (medium risk)
  - 2.4-3.2%: Orange
  - 3.2-4.0%: Red (high risk)

**Size**: SUM(Flight Count) - larger circles = more flights

---

### Bar Chart Colors (Carrier Rankings)
**Palette**: Red-Green-Gold Diverging
- **Reversed**: ✓
- **Continuous color** based on Cancellation Rate
- **Range**: 0% to 6% (MQ at 5.3% is max)

---

### Day of Week Chart Colors
**Palette**: Green-Gold diverging
- **Saturday (3.0%)**: Gold/Yellow - stands out as highest
- **Other days**: Green gradient
- **Thursday (1.6%)**: Darkest green - lowest rate

---

## KPI Cards Configuration

### Card 1: Total Flights
- **Calculation**: `SUM([Flight Count])`
- **Format**: Number, Custom: `0.00,,"M"`
- **Result**: 1.19M
- **Label**: "Total Flights"

### Card 2: Overall Cancellation Rate
- **Calculation**: `SUM([Cancelled Flights]) / SUM([Flight Count])`
- **Format**: Percentage, 1 decimal
- **Result**: 2.0%
- **Label**: "Cancellation Rate"

### Card 3: Worst Day - Saturday
- **Calculation**: `MAX(Cancellation Rate)` filtered by Day of Week
- **Result**: 3.0%
- **Label**: "Worst Day - Saturday"

### Card 4: Worst Carrier
- **Calculation**: `MAX(Cancellation Rate)` filtered by Carrier = "MQ"
- **Result**: 5.3%
- **Label**: "Worst Carrier - MQ"

### Card 5: Best Carrier
- **Calculation**: `MIN(Cancellation Rate)` filtered by Carrier = "HA"
- **Result**: 0.17%
- **Label**: "Best Carrier - HA"

**KPI Formatting**:
- Font Size: 48pt (large number)
- Label Font: 12pt
- Alignment: Center

---

## Chart Configurations

### Map Visualization
- **Type**: Symbol Map
- **Marks**: Circle
- **Latitude/Longitude**: Auto-generated from ORIGIN airport codes
- **Color**: Cancellation Rate (0-4% scale)
- **Size**: Flight Count
- **Opacity**: 80%
- **Border**: Dark gray, thin

**Tooltip**:
```
Airport: <ORIGIN>
Total Flights: <SUM(Flight Count)>
Cancellation Rate: <Cancellation Rate>
```

---

### Day of Week Bar Chart
- **Type**: Vertical Bar Chart
- **X-axis**: Day Name (calculated field)
- **Y-axis**: Cancellation Rate
- **Color**: Green-Gold gradient by value
- **Labels**: Show percentage on top of bars
- **Sorted**: Monday to Sunday (natural order)

**Tooltip**:
```
Day: <Day Name>
Cancellation Rate: <Cancellation Rate>
Total Cancellations: <SUM(Cancelled Flights)>
```

---

### Carrier Bar Chart (Top 14)
- **Type**: Horizontal Bar Chart
- **Rows**: Carrier (filtered to top 14 by flight volume)
- **Columns**: Cancellation Rate
- **Color**: Red-Green gradient by rate
- **Sorted**: Descending (worst at top)
- **Labels**: Show percentage at end of bars

**Filter**: Top 14 carriers by SUM(Flight Count)

**Tooltip**:
```
Carrier: <CARRIER>
Cancellation Rate: <Cancellation Rate>
Total Flights: <SUM(Flight Count)>
```

---

## Dashboard Layout Structure
```
+--------------------------------------------------+
|  U.S. Flight Cancellation Analysis               |
|  Data: January 2019 & January 2020               |
+--------------------------------------------------+
| Total    | Cancel  | Worst Day | Worst  | Best   |
| Flights  | Rate    | Saturday  | MQ     | HA     |
| 1.19M    | 2.0%    | 3.0%      | 5.3%   | 0.17%  |
+--------------------------------------------------+
|                                                  |
|        U.S. Flight Cancellations by Airport      |
|              (Geographic Map)                    |
|                                                  |
+--------------------------------------------------+
| Cancellations by   | Cancellation Rate by        |
| Day of Week        | Carrier (Top 14)            |
| (Vertical bars)    | (Horizontal bars)           |
+--------------------------------------------------+
```

**Size**: Automatic (responsive)  
**Background**: White  
**Spacing**: 10px padding between sections

---

## Connection to Snowflake

### Data Source Configuration
1. **Connector**: Snowflake
2. **Server**: `your-account.snowflakecomputing.com`
3. **Warehouse**: COMPUTE_WH
4. **Database**: FLIGHT_DELAY_DB
5. **Schema**: RAW_DATA
6. **Table/View**: FLIGHTS_CLEAN

### Live vs Extract
- **Dashboard 1**: Can use Extract (data is static Jan 2019/2020)
- **Refresh**: Not needed unless data changes

---

## Interactivity (Optional Enhancements)

### Suggested Filters
1. **Carrier Filter**: Multi-select dropdown
2. **Day of Week Filter**: Checkbox list
3. **Date Range**: If expanding beyond Jan 2019/2020

**Note**: Current dashboard has no filters for simplicity and clarity.

---

## Publishing

### Tableau Public
1. File → Save to Tableau Public As...
2. Name: "US Flight Cancellation Analysis"
3. Privacy: Public
4. Tags: aviation, data-analytics, machine-learning, snowflake

### Tableau Online
1. Server → Publish Workbook
2. Project: Personal Space
3. Sheets: Select Dashboard 1

---

## Performance Optimization

- **Aggregated data**: Using FLIGHTS_CLEAN (480K routes) instead of flights_raw (1.19M flights)
- **Extract recommended**: For faster load times
- **Filters**: Minimal to reduce query complexity
