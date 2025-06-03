# Circular Economy Dynamics Model

**Aggregating Individual Decisions to Represent a Macro Economy**

*Agent-Based Implementation of the 3-Equation New Keynesian Model*

## Overview

The Circular Economy Dynamics Model is a NetLogo-based agent-based simulation that explores how individual economic decisions aggregate to create macroeconomic phenomena. This model implements the foundational 3-Equation New Keynesian Model through bottom-up agent interactions, capturing the complex dynamics between households, firms, and monetary policy within a circular economy framework.

## Background and Motivation

### The Macro-Micro Linkage Problem

Understanding how individual decisions by households and firms aggregate to form macroeconomic outcomes is fundamental to economic analysis. Traditional equation-based models often struggle to capture the heterogeneity and complex interactions that characterize real economies. This model addresses that gap by:

- **Bridging Micro and Macro**: Integrating individual decision-making behaviors into broader economic context
- **Capturing Bottom-up Effects**: How individual actions aggregate to influence the economy
- **Modeling Top-down Effects**: How macroeconomic policies impact individual behavior
- **Policy Analysis**: Evaluating fiscal and monetary policy impacts on key economic indicators

### Why Agent-Based Modeling?

Agent-based modeling offers several advantages over traditional approaches:

1. **Heterogeneity**: Captures diversity in agent characteristics and decision-making processes
2. **Complex Interactions**: Models multifaceted relationships and feedback loops
3. **Emergent Properties**: Reveals phenomena that emerge from agent interactions
4. **Policy Flexibility**: Allows testing of various interventions under different scenarios

## Theoretical Foundation: The 3-Equation Model

The model implements three fundamental macroeconomic relationships:

### 1. IS Curve (Investment-Saving)
- **Relationship**: Output vs. Interest Rate (demand side)
- **Mechanism**: Lower interest rates → higher investment/consumption → increased output
- **Agent Implementation**: Household consumption decisions based on MPC, firm investment based on interest sensitivity

### 2. Phillips Curve
- **Relationship**: Inflation vs. Output Gap (supply side)
- **Mechanism**: Output above potential → upward price pressure → inflation
- **Agent Implementation**: Adaptive inflation expectations, dynamic price adjustments

### 3. Monetary Policy Rule
- **Relationship**: Central bank interest rate responses
- **Mechanism**: Interest rate adjustments to stabilize inflation and output
- **Agent Implementation**: Policy rule balancing inflation and unemployment targets

## Model Architecture

### Agent Types

**Households (100 agents)**
- Make consumption decisions based on Marginal Propensity to Consume (MPC)
- Update inflation expectations adaptively
- Supply labor to firms and receive wages
- Purchase goods and services from firms

**Firms (40 agents)**
- Determine investment levels based on interest sensitivity
- Pay wages to households using investment budgets
- Adjust production and pricing based on demand
- Operate under perfect competition assumptions

### Key Parameters

#### Household Properties
- **MPC (Marginal Propensity to Consume)**: Average with 0.1 standard deviation
- **Inflation-adaptability**: Range [0,1] where 0=grounded expectations, 1=fully adaptive
- **Interest-sensitivity**: How investment responds to interest rate changes

#### Firm Properties
- **Interest-sensitivity**: Investment responsiveness to rate changes (0.1 std dev)
- **Production decisions**: Based on demand and cost factors

#### Monetary Policy
- **Loss-balance**: Weight on inflation vs. unemployment in policy rule (1=balanced)
- **Stabilizing-interest-rate**: Equilibrium rate (0.05 baseline)
- **Inflation-sensitivity**: Responsiveness to output gap (0.35 baseline)

### Agent Rules and Interactions

#### Each Time Step:

**Households:**
1. Calculate consumption based on income and MPC
2. Find random firm and make purchases
3. Update inflation expectations based on adaptability parameter

**Firms:**
1. Determine investment based on current interest rates
2. Find random household and pay wages
3. Adjust production and pricing strategies

**System Updates:**
1. Calculate aggregate consumption and investment
2. Update output, inflation, and unemployment
3. Adjust interest rates via monetary policy rule

## Key Assumptions

The model operates under several simplifying assumptions:

- **Perfect Competition**: Firms price at marginal cost
- **Simplified Decision-Making**: No complex utility optimization or strategic competition
- **MPC Stability**: Marginal propensity to consume not strongly influenced by interest rates
- **Money Neutrality**: Long-run neutrality of monetary policy
- **Rational Expectations Framework**: Agents form expectations systematically
- **Sticky Prices**: Prices don't adjust immediately to equilibrium

## Experimental Design

### Core Experiment: Inflation Adaptability Analysis

**Objective**: Examine how different levels of household inflation-adaptability influence economic response to demand shocks.

**Setup**:
- Test inflation-adaptability levels: [0.0, 0.25, 0.5, 0.75, 1.0]
- Baseline conditions: MPC=0.4, interest-sensitivity=0.6, 40 firms, 100 households
- Stabilization period: 50 ticks
- Demand shock: +1000 exogenous investment units
- Post-shock observation: 50 ticks
- Replication: 5 trials per condition (25 total)

**Variables Measured**:
- Interest rates
- Inflation dynamics
- Output (GDP)
- Unemployment
- Agent-level consumption, investment, income, revenue

## Results and Findings

### Key Experimental Results

#### Inflation-Adaptability = 0.0 (Fully Grounded Expectations)
- **Interest Rate**: Sharp spike at shock introduction, stabilizes at higher level
- **Inflation**: Significant drop followed by oscillations before stabilizing lower
- **Output**: Quick spike returning to baseline with minor oscillations
- **Interpretation**: Grounded expectations require aggressive monetary intervention

#### Inflation-Adaptability = 0.5 (Moderate Adaptation)
- **Interest Rate**: Sharp increase followed by gradual decrease to new equilibrium
- **Inflation**: Initial drop with gradual recovery to near-original levels
- **Output**: Similar spike pattern with smoother stabilization
- **Interpretation**: Moderate adaptability enables more efficient adjustment

#### Inflation-Adaptability = 1.0 (Fully Adaptive Expectations)
- **Interest Rate**: Significant spike with gradual decline to higher equilibrium
- **Inflation**: Sharp drop followed by gradual increase above pre-shock level
- **Output**: Notable fluctuations during adjustment
- **Interpretation**: High adaptability increases responsiveness but adds volatility

### Empirical Validation: COVID-19 Response

The model's predictions align with real-world data from the St. Louis Federal Reserve (May 2020 - May 2024):

- **Federal Funds Rate**: Near-zero through early 2022, gradual increase afterward
- **Inflation (Sticky Price CPI)**: Low through 2021, rising from mid-2021 to early 2023
- **Unemployment**: Steep decline from 2020 peak, steady recovery through 2022

This validation demonstrates the model's accuracy in capturing demand shock responses, particularly the effects of COVID-19 relief acts (CARES Act, American Rescue Plan).

### Emergent Phenomena

The simulation reveals several important emergent behaviors:

1. **Consumption Stability**: Household consumption remains stable despite shocks
2. **Investment Responsiveness**: Firm investment shows immediate spike response
3. **Revenue Volatility**: Firm revenues exhibit pronounced variability during adjustment
4. **Income Persistence**: Household income shows minor fluctuations around stable levels

## Policy Implications

### For Monetary Policy
- **Expectation Management**: Critical importance of inflation expectation anchoring
- **Timing**: Aggressive early intervention may be necessary with grounded expectations
- **Gradualism**: Moderate adaptability allows for smoother policy implementation

### For Fiscal Policy
- **Stimulus Effectiveness**: Targeted investment increases generate significant economic response
- **Timing Sensitivity**: Quick firm adjustment suggests careful stimulus calibration needed
- **Spillover Effects**: Investment shocks create broad economic impacts through circular flow

## Technical Implementation

### Built With
- **NetLogo**: Primary simulation platform
- **BehaviorSpace**: Experimental framework for parameter sweeps
- **FRED Data Integration**: For empirical validation

### Model Files Structure
```
circular-economy-model/
├── model.nlogo              # Main NetLogo model file
├── experiments/              # BehaviorSpace experiment configurations
├── data/                    # Empirical validation datasets
├── analysis/                # Result analysis scripts
└── documentation/           # Additional model documentation
```

### Running the Model

#### Prerequisites
- NetLogo 6.0 or higher
- BehaviorSpace (included with NetLogo)

#### Basic Usage
```bash
# Open NetLogo and load the model file
# Set desired parameters in interface
# Run single simulation or batch experiments via BehaviorSpace
```

#### Parameter Configuration
```netlogo
; Key parameters to adjust:
n-households: 100
n-firms: 40
inflation-adaptability: 0.5    ; Range [0,1]
MPC: 0.4                       ; With 0.1 std deviation
interest-sensitivity: 0.6      ; With 0.1 std deviation
loss-balance: 1.0              ; Policy rule weighting
```

## Future Development

### Planned Enhancements

#### Microeconomic Sophistication
- **Utility Optimization**: Implement household utility maximization
- **Strategic Firm Behavior**: Add game-theoretic competitive dynamics
- **Bounded Rationality**: Incorporate cognitive limitations and heuristics
- **Heterogeneous Expectations**: Diverse expectation formation mechanisms

#### Market Dynamics
- **Price Stickiness**: More realistic price adjustment mechanisms
- **Market Segmentation**: Industry-specific behaviors and interactions
- **Financial Markets**: Banking sector and credit dynamics
- **International Trade**: Open economy extensions

#### Policy Tools
- **Fiscal Policy**: Government spending and taxation mechanisms
- **Regulatory Framework**: Financial and market regulations
- **Supply-Side Policies**: Productivity and structural reforms

### Validation Extensions
- **Cross-Country Validation**: Test against different economic systems
- **Historical Episodes**: Major economic events and policy changes
- **Real-Time Forecasting**: Predictive model testing
- **Sensitivity Analysis**: Robustness testing across parameter spaces

## Contributing

We welcome contributions in several areas:

### Research Contributions
- Empirical validation with new datasets
- Alternative agent behavior specifications
- Policy scenario development
- Cross-model comparisons

### Technical Contributions
- Performance optimization
- Visualization enhancements
- Data integration tools
- Documentation improvements

### Getting Started
1. Fork the repository
2. Create a feature branch
3. Implement changes with appropriate tests
4. Submit pull request with detailed description

## Academic Usage

### Citation
```bibtex
@misc{sterling2024circular,
  title={Aggregating Individual Decisions to Represent a Macro Economy},
  author={Sterling, Ethan},
  year={2024},
  institution={Northwestern University},
  course={COMP SCI 372}
}
```

### Educational Applications
- **Macroeconomics Courses**: Demonstrating micro-macro linkages
- **Policy Analysis**: Testing intervention scenarios
- **Research Methods**: Agent-based modeling techniques
- **Economic Forecasting**: Understanding prediction limitations

## References

- Carlin, W., Soskice, D. (2009). Teaching Intermediate Macroeconomics using the 3-Equation Model. Palgrave Macmillan.
- Federal Reserve Bank of St. Louis. FRED Economic Data. https://fred.stlouisfed.org/
- Wilensky, U. (1999). NetLogo. Northwestern University. http://ccl.northwestern.edu/netlogo/

## License

[MIT License](LICENSE) - Feel free to use for research and educational purposes.

## Contact

**Ethan Sterling**  
Northwestern University  
Computer Science 372  

For questions about the model, collaboration opportunities, or technical support, please open an issue in this repository.

---

*This project demonstrates the power of agent-based modeling in bridging the micro-macro divide in economics, providing insights into complex economic phenomena through individual agent interactions and emergent system behaviors.*
