# Bitcoin DCA Analysis Terminal

🚀 **Advanced Bitcoin DCA Analysis and Price Prediction Tool**

A comprehensive terminal application for Bitcoin analysis featuring:
- 🔮 Advanced price prediction using deep learning and Bitcoin-specific patterns
- 📈 DCA optimization based on historical performance analysis
- 🧪 Comprehensive backtesting of DCA strategies
- 📊 Beautiful terminal interface with Rich library

## Features

### 🔮 Price Prediction
- **Deep Learning Models**: LSTM and Random Forest ensemble predictions
- **Bitcoin-Specific Features**: Halving cycles, market maturity, supply analysis
- **Technical Analysis**: 20+ technical indicators (RSI, MACD, Bollinger Bands, etc.)
- **Pattern Recognition**: Time-based patterns and market cycle analysis

### 📈 DCA Recommendations
- **Optimal Day Analysis**: Find the best day of month for DCA investments
- **Weekly Patterns**: Analyze day-of-week performance  
- **Combined Strategies**: Optimal combinations of timing factors
- **Success Rate Analysis**: Historical win rates for different strategies
- **📅 Custom Date Ranges**: Analyze specific time periods (bull/bear markets, recent years)
- **⚠️ Data Validation**: Ensures sufficient data for reliable analysis (minimum 90 days)

### 🧪 DCA Backtesting
- **Monthly DCA Strategies**: Fixed day of month or optimal weekday combinations
- **Performance Metrics**: Returns, Sharpe ratio, volatility, max drawdown
- **Transaction Analysis**: Detailed trade-by-trade breakdown
- **📅 Custom Date Ranges**: Backtest specific time periods
- **🎯 Strategy Options**: 
  - **day_of_month**: Invest on specific day each month (e.g., 15th)
  - **optimal**: Invest on chosen weekday closest to chosen day of month

### 📊 Market Overview
- **Real-time Metrics**: Current price, trends, volatility
- **Historical Context**: All-time highs/lows, long-term performance
- **Market Cycles**: Halving cycle analysis and positioning

## Installation

1. **Clone or download the project files**
2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

## Testing

Run the comprehensive test suite to ensure everything works correctly:

```bash
python tests/test_btc_analyzer.py
```

The test suite includes:
- ✅ **Valid data processing** - Normal Bitcoin price data handling
- ❌ **Invalid data handling** - Corrupted files, missing columns, negative prices
- 🧪 **Edge cases** - Empty datasets, extreme values, wrong data types  
- 🔄 **Error recovery** - Fallback mechanisms and graceful degradation
- 📊 **All components** - Data loading, prediction, DCA analysis, backtesting

**Test Results:** 30 tests covering all major functionality, new UI features, and error conditions.

## Usage

### Installation
```bash
# Install as a package
pip install -e .
```

### Quick Start
```bash
# Run from anywhere after installation
btc-dca

# Or run as module
python -m bitcoin_dca.main
```
**Startup time: ~1-2 seconds** with optimized on-demand feature loading

**Note**: On first run, if no Bitcoin data file is found, the application will automatically download the latest data from [stooq.com](https://stooq.com/q/d/l/?s=btcusd&i=d).

### ⚡ **Performance Features**

The application is optimized for fast startup and efficient resource usage:

**Key optimizations:**
- 🚀 **Lazy loading** - Heavy libraries load only when needed
- 💾 **Smart caching** - Features cached to disk for instant reuse  
- 🎯 **On-demand computation** - Only compute features for selected analysis
- ⚡ **Minimal startup** - Load basic data first, enhance progressively
- 📉 **Memory efficient** - Optimized memory usage (15-25 MB at startup)

**Performance analysis tools:**
```bash
python scripts/startup_info.py           # View detailed startup analysis
```

### With Custom Data File
```bash
btc-dca --csv your_bitcoin_data.csv
```

### Automatic Data Download
- 🌐 **Auto-download**: Downloads latest Bitcoin price data if CSV doesn't exist
- 📊 **Data validation**: Verifies downloaded data integrity
- 🔄 **Retry mechanism**: Re-downloads if data loading fails
- 💾 **Local caching**: Saves data locally for future use

## Data Format

The application expects a CSV file with the following structure:
```csv
Date,Open,High,Low,Close
2010-07-19,0.08584,0.09307,0.07723,0.0808
2010-07-20,0.0808,0.08181,0.07426,0.07474
...
```

## Application Flow

### Main Menu Options

1. **🔮 Price Prediction**
   - Enter target date (YYYY-MM-DD)
   - Get AI-powered price prediction with confidence score
   - Includes market analysis and technical context

2. **📈 DCA Recommendations**
   - Analyze optimal investment timing
   - View best days of month and week
   - Get personalized strategy recommendations

3. **🧪 DCA Backtesting**
   - Test different DCA strategies
   - Choose from predefined or custom strategies
   - Get detailed performance analysis

4. **📊 Market Overview**
   - Current market snapshot
   - Historical performance metrics
   - Volatility and trend analysis

5. **📥 Update Dataset**
   - Download fresh Bitcoin price data from stooq.com
   - Automatically clears cache and reloads data
   - Shows before/after data range comparison
   - Keep analysis current with latest market movements

6. **🧹 Clear Cache**
   - Remove all cached features and computed data
   - Free up disk space (.cache directory)
   - Force recomputation of all features
   - Useful after manual data updates or troubleshooting

## Advanced Features

### Prediction Models
- **Ensemble Approach**: Combines LSTM and Random Forest predictions
- **Feature Engineering**: 40+ engineered features including:
  - Technical indicators (SMA, EMA, RSI, MACD, Bollinger Bands)
  - Bitcoin halving cycle analysis
  - Market maturity metrics
  - Seasonal and cyclical patterns

### DCA Analysis
- **Historical Optimization**: Analyzes 10+ years of data
- **Multiple Time Frames**: 30, 90, 180, and 365-day return analysis
- **Statistical Significance**: Success rates and confidence intervals

### Backtesting Engine
- **Realistic Simulation**: Includes transaction fees and market gaps
- **Comprehensive Metrics**: 
  - Total and annualized returns
  - Sharpe ratio and volatility
  - Maximum drawdown
  - Win rate analysis

## Technical Implementation

### Architecture
```
bitcoin_dca/
├── main.py          # Main application and UI
├── data_loader.py   # Data preprocessing and feature engineering
├── predictor.py     # ML models for price prediction
├── dca_analyzer.py  # DCA optimization algorithms
└── backtester.py    # Strategy backtesting engine
```

### Key Technologies
- **pandas/numpy**: Data manipulation and analysis
- **scikit-learn**: Machine learning algorithms
- **TensorFlow**: Deep learning (LSTM) models
- **Rich**: Beautiful terminal interface
- **TA-Lib**: Technical analysis indicators

### Data Processing Pipeline
1. **Raw Data Loading**: CSV parsing and validation
2. **Feature Engineering**: Technical indicators and Bitcoin-specific features
3. **Model Training**: Real-time model training on historical data
4. **Analysis Execution**: Strategy analysis and backtesting
5. **Results Visualization**: Rich terminal output with charts and tables

## Performance Considerations

- **Efficient Processing**: Vectorized operations for large datasets
- **Memory Management**: Optimized for datasets with 10+ years of daily data
- **Model Caching**: Smart caching to avoid retraining
- **Parallel Processing**: Multi-threaded backtesting for strategy comparison

## Example Output

### Price Prediction
```
🔮 Price Prediction for 2025-01-15
┌─────────────────┬──────────────┐
│ Predicted Price │ $67,234.50   │
│ Confidence      │ 78.5%        │
│ Model           │ Ensemble     │
│ Features Used   │ 42           │
└─────────────────┴──────────────┘
```

### DCA Recommendations
```
📅 Best Days of Month for DCA
┌──────┬─────┬────────────┬─────────────┐
│ Rank │ Day │ Avg Return │ Success Rate│
├──────┼─────┼────────────┼─────────────┤
│ 1    │ 21  │ 8.24%      │ 73.2%       │
│ 2    │ 15  │ 7.89%      │ 71.8%       │
│ 3    │ 28  │ 7.45%      │ 69.4%       │
└──────┴─────┴────────────┴─────────────┘
```

## Disclaimer

This tool is for educational and research purposes only. Cryptocurrency investments are highly volatile and risky. Past performance does not guarantee future results. Always do your own research and consider consulting with financial advisors before making investment decisions.

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve the application.

## License

This project is open source and available under the [MIT License](LICENSE).