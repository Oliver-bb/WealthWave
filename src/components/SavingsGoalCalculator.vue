<template>
  <div class="savings-goal-calculator">
    <!-- Main Content -->
    <div class="main-content">
      <!-- Left Side - Form -->
      <div class="form-section">
        <div class="form-group">
          <label>Savings Goal</label>
          <input
            type="text"
            v-model="savingsGoal"
            placeholder="Enter your target amount"
            class="form-input"
          />
        </div>

        <div class="form-row">
          <div class="form-group timeline-group">
            <label>Timeline</label>
            <input
              type="text"
              v-model="timeline"
              placeholder="Duration"
              class="form-input timeline-input"
            />
          </div>
          <div class="form-group unit-group">
            <select v-model="timeUnit" class="form-select">
              <option value="weeks">Weeks</option>
              <option value="months">Months</option>
              <option value="years">Years</option>
            </select>
          </div>
        </div>

        <div class="form-group">
          <label>Initial Deposit (Optional)</label>
          <input
            type="text"
            v-model="initialDeposit"
            placeholder="Amount you already have saved"
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label>Interest Rate (Annual %)</label>
          <input
            type="text"
            v-model="interestRate"
            placeholder="Expected annual interest rate"
            class="form-input"
          />
        </div>

        <button
          type="button"
          class="calculate-btn"
          @click="calculateSavings"
        >
          Calculate Savings Plan
        </button>
        <!-- Status messages (sits under the button) -->
<div class="status-wrap" aria-live="polite">
  <p v-if="statusMessage" class="status-msg" :class="statusClass">
    {{ statusMessage }}
  </p>
</div>

      </div>

      <!-- Right Side - Results -->
      <div class="results-section">
        <!-- Compact Savings Plan -->
        <div class="savings-plan">
          <h3>Your Savings Plan</h3>
          <div class="plan-grid">
            <div class="plan-item main">
              <span class="amount">${{ currentDisplayAmount }}</span>
              <span class="label">{{ currentDisplayLabel }}</span>
            </div>
            <div class="plan-item secondary">
              <span class="value">${{ secondaryDisplayAmount }}</span>
              <span class="label">{{ secondaryDisplayLabel }}</span>
            </div>
          </div>
        </div>

        <!-- Split Progress Visualization -->
        <div class="progress-visualization">
          <!-- Principal vs Interest Chart -->
          <div class="chart-section">
            <h4>Principal vs Interest</h4>
            <div class="chart-container">
              <div ref="chartCanvas" class="echart"></div>
            </div>
          </div>
          
          <!-- Goal Progress Circle -->
          <div class="progress-section">
            <h4>Goal Progress</h4>
            <div class="progress-circle-container">
              <div class="progress-circle">
                <svg viewBox="0 0 100 100" class="circular-chart">
                  <path class="circle-bg" d="M 50,50 m 0,-40 a 40,40 0 1 1 0,80 a 40,40 0 1 1 0,-80"></path>
                  <path class="circle" :stroke-dasharray="progressDashArray" d="M 50,50 m 0,-40 a 40,40 0 1 1 0,80 a 40,40 0 1 1 0,-80"></path>
                </svg>
                <div class="percentage">{{ progressPercentage }}%</div>
                <div class="progress-label">Progress</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import * as echarts from 'echarts'

export default {
  name: 'SavingsGoalCalculator',
  data() {
    return {
      savingsGoal: '10,000',
      timeline: '12',
      timeUnit: 'months',
      initialDeposit: '1,000',
      interestRate: '3.5',
      // keep numeric
      monthlyAmount: 0,
      weeklyAmount: 0,
      chart: null,

      // NEW: status UI
      statusMessage: '',
      statusType: '' // '', 'info', 'success', 'warn', 'error'
    }
  },
  computed: {
    savingsGoalNum() {
      return parseFloat(this.savingsGoal.replace(/,/g, '')) || 0
    },
    initialDepositNum() {
      return parseFloat(this.initialDeposit.replace(/,/g, '')) || 0
    },
    timelineNum() {
      return parseFloat(this.timeline) || 0
    },
    amountToSave() {
      return Math.max(0, this.savingsGoalNum - this.initialDepositNum)
    },
    // NEW: class for message badge
    statusClass() {
      return this.statusType ? `is-${this.statusType}` : ''
    },
    
    // Timeline 互动显示
    currentDisplayAmount() {
      if (this.timeUnit === 'weeks') return this.weeklyAmount
      if (this.timeUnit === 'years') return this.monthlyAmount * 12
      return this.monthlyAmount
    },
    
    currentDisplayLabel() {
      if (this.timeUnit === 'weeks') return `Required savings per week`
      if (this.timeUnit === 'years') return `Required savings per year`
      return `Required savings per month`
    },
    
    secondaryDisplayAmount() {
      if (this.timeUnit === 'weeks') return this.monthlyAmount
      if (this.timeUnit === 'years') return this.monthlyAmount
      return this.weeklyAmount
    },
    
    secondaryDisplayLabel() {
      if (this.timeUnit === 'weeks') return `Per Month`
      if (this.timeUnit === 'years') return `Per Month`
      return `Per Week`
    },
    
    // Goal Progress 计算
    progressPercentage() {
      if (this.savingsGoalNum === 0) return 0
      const progress = (this.initialDepositNum / this.savingsGoalNum) * 100
      return Math.min(Math.round(progress), 100)
    },
    
    progressDashArray() {
      const circumference = 2 * Math.PI * 40; // radius = 40
      const progress = this.progressPercentage / 100;
      const strokeDash = circumference * progress;
      return `${strokeDash} ${circumference}`;
    },
    
    progressDescription() {
      const initial = this.initialDepositNum.toLocaleString()
      const goal = this.savingsGoalNum.toLocaleString()
      const remaining = (this.savingsGoalNum - this.initialDepositNum).toLocaleString()
      
      if (this.initialDepositNum >= this.savingsGoalNum) {
        return `🎉 Goal achieved! You have $${initial} of your $${goal} target.`
      }
      
      return `You have $${initial} saved. Need $${remaining} more to reach your $${goal} goal.`
    }
  },
  watch: {
    timeUnit(newUnit, oldUnit) {
      // 当时间单位改变时，自动转换数值
      const currentValue = parseFloat(this.timeline) || 0;
      if (currentValue === 0) return;
      
      let newValue = currentValue;
      
      // 从旧单位转换到月
      let months = currentValue;
      if (oldUnit === 'weeks') {
        months = currentValue / 4.333;
      } else if (oldUnit === 'years') {
        months = currentValue * 12;
      }
      
      // 从月转换到新单位
      if (newUnit === 'weeks') {
        newValue = Math.round(months * 4.333);
      } else if (newUnit === 'years') {
        newValue = Math.round(months / 12 * 10) / 10; // 保留一位小数
      } else {
        newValue = Math.round(months);
      }
      
      this.timeline = newValue.toString();
    }
  },
  methods: {
    // NEW: helper to set/clear status
    setStatus(type = '', msg = '') {
      this.statusType = type
      this.statusMessage = msg
    },

    // stability patch (guards, clamping, weeks handling, ceil) + messages
    calculateSavings() {
      // clear any previous message
      this.setStatus('', '')

      const goal = Math.max(0, this.savingsGoalNum)
      const initial = Math.max(0, this.initialDepositNum)
      const ratePct = Math.max(0, parseFloat(this.interestRate) || 0)
      const duration = Math.max(0, this.timelineNum)

      // normalise periods
      let months
      let weeks
      if (this.timeUnit === 'weeks') {
        weeks = duration
        months = duration / 4.333 // months only for interest math
      } else if (this.timeUnit === 'years') {
        months = duration * 12
        weeks = months * 4.333
      } else {
        months = duration // months
        weeks = months * 4.333
      }

      // invalid / zero-duration -> fail safe
      if (!isFinite(months) || months <= 0) {
        this.monthlyAmount = 0
        this.weeklyAmount = 0
        this.setStatus('error', 'Please enter a timeline greater than 0.')
        return
      }

      const mRate = (ratePct / 100) / 12

      // growth of initial alone
      const fvInitial = mRate > 0 ? initial * Math.pow(1 + mRate, months) : initial
      if (fvInitial >= goal) {
        this.monthlyAmount = 0
        this.weeklyAmount = 0
        this.setStatus('success', 'Great news — your current savings already meet this goal. No monthly contributions needed.')
        return
      }

      // required payments
      const remaining = Math.max(0, goal - fvInitial)
      let monthly

      if (mRate > 0) {
        // ordinary annuity (end of month)
        const factor = (Math.pow(1 + mRate, months) - 1) / mRate
        monthly = Math.ceil(remaining / factor)
      } else {
        monthly = Math.ceil((goal - initial) / months)
      }

      // weekly: compute directly if user selected weeks; else derive from monthly
      const weekly =
        this.timeUnit === 'weeks'
          ? Math.ceil((goal - initial) / Math.max(1, weeks))
          : Math.ceil(monthly / 4.333)

      this.monthlyAmount = monthly
      this.weeklyAmount = weekly

      // context notes
      const notes = []
      if (this.timeUnit === 'weeks') notes.push('Using weeks; weekly amount is computed directly.')
      if (mRate === 0) notes.push('Interest rate is 0%, plan assumes no growth.')
      if (months < 2) notes.push('Very short timeline — monthly amount may be high.')

      if (notes.length) {
        const hasWarn = months < 2
        this.setStatus(hasWarn ? 'warn' : 'info', notes.join(' '))
      }

      this.$nextTick(() => {
        this.initChart(months, monthly, initial, mRate, goal)
      })
    },

    // Principal vs Interest 面积图
    initChart(months, monthly, initial, mRate, goal) {
      if (this.chart) {
        this.chart.dispose()
        this.chart = null
      }

      const el = this.$refs.chartCanvas
      if (!el) return

      const steps = Math.min(Math.max(Math.round(months), 1), 60)
      const categories = Array.from({ length: steps + 1 }, (_, i) => {
        if (this.timeUnit === 'weeks') return i + ' weeks'
        if (this.timeUnit === 'years') return (i / 12).toFixed(1) + ' years'
        return i + ' months'
      })
      
      const principalData = []
      const interestData = []

      let totalPrincipal = initial
      let totalInterest = 0
      
      principalData.push(initial)
      interestData.push(0)
      
      for (let i = 0; i < steps; i++) {
        totalPrincipal += monthly
        const interestEarned = (totalPrincipal + totalInterest) * mRate
        totalInterest += interestEarned
        
        principalData.push(totalPrincipal)
        interestData.push(totalInterest)
      }

      const maxValue = Math.max(goal, totalPrincipal + totalInterest)
      const yMax = Math.ceil((maxValue * 1.1) / 1000) * 1000

      const chart = echarts.init(el)
      chart.setOption({
        grid: { left: '10%', right: '10%', bottom: '15%', top: '15%' },
        tooltip: {
          trigger: 'axis',
          axisPointer: { type: 'cross' },
          formatter: function(params) {
            const period = params[0].axisValue
            let html = `<strong>${period}</strong><br/>`
            params.forEach(param => {
              html += `${param.marker} ${param.seriesName}: $${param.value.toLocaleString()}<br/>`
            })
            const total = params.reduce((sum, param) => sum + param.value, 0)
            html += `<strong>Total: $${total.toLocaleString()}</strong>`
            return html
          }
        },
        legend: {
          data: ['Principal', 'Interest'],
          top: '5%',
          textStyle: { color: '#666' }
        },
        xAxis: {
          type: 'category',
          data: categories,
          name: this.timeUnit.charAt(0).toUpperCase() + this.timeUnit.slice(1),
          nameLocation: 'middle',
          nameGap: 25,
          nameTextStyle: { color: '#666', fontSize: 12 },
          axisLine: { show: true, lineStyle: { color: '#ddd' } },
          axisTick: { show: true, lineStyle: { color: '#ddd' } },
          axisLabel: { color: '#666', fontSize: 10, rotate: 45 }
        },
        yAxis: {
          type: 'value',
          name: 'Amount ($)',
          nameLocation: 'middle',
          nameGap: 40,
          min: 0,
          max: yMax,
          axisLine: { show: true, lineStyle: { color: '#ddd' } },
          axisTick: { show: true, lineStyle: { color: '#ddd' } },
          axisLabel: { 
            color: '#666', 
            fontSize: 10, 
            formatter: (value) => '$' + (value / 1000).toFixed(0) + 'K'
          },
          splitLine: { show: true, lineStyle: { color: '#f0f0f0' } }
        },
        series: [
          {
            name: 'Principal',
            type: 'line',
            stack: 'total',
            data: principalData,
            smooth: true,
            lineStyle: { width: 0 },
            showSymbol: false,
            areaStyle: {
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [
                  { offset: 0, color: 'rgba(76, 175, 80, 0.8)' },
                  { offset: 1, color: 'rgba(76, 175, 80, 0.3)' }
                ]
              }
            }
          },
          {
            name: 'Interest',
            type: 'line',
            stack: 'total',
            data: interestData,
            smooth: true,
            lineStyle: { width: 0 },
            showSymbol: false,
            areaStyle: {
              color: {
                type: 'linear', x: 0, y: 0, x2: 0, y2: 1,
                colorStops: [
                  { offset: 0, color: 'rgba(33, 150, 243, 0.8)' },
                  { offset: 1, color: 'rgba(33, 150, 243, 0.3)' }
                ]
              }
            }
          }
        ]
      })

      this.chart = chart
    },

    formatNumber(num) {
      return new Intl.NumberFormat().format(num || 0)
    }
  },

  beforeUnmount() {
    if (this.chart) {
      this.chart.dispose()
    }
  }
}
</script>


<style scoped>
  .savings-goal-calculator {
    min-height: 100vh;
    background: #f8f9fa;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    padding: 40px 20px;
  }

  .header {
    text-align: center;
    margin-bottom: 40px;
  }

  .header h1 {
    font-size: 32px;
    font-weight: 600;
    color: #333;
    margin: 0 0 8px 0;
  }

  .header p {
    font-size: 16px;
    color: #666;
    margin: 0;
  }

  .main-content {
    max-width: 1200px;
    margin: 0 auto;
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 40px;
    align-items: stretch; /* CHANGED: equal height columns */
  }

  .form-section {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }

  .form-group {
    margin-bottom: 20px;
  }

  .form-group label {
    display: block;
    font-size: 14px;
    font-weight: 500;
    color: #333;
    margin-bottom: 6px;
  }

  .form-input {
    width: 100%;
    padding: 12px 16px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
    background: white;
    box-sizing: border-box;
  }

  .form-input:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
  }

  .form-row {
    display: grid;
    grid-template-columns: 1fr 120px;
    gap: 12px;
    align-items: end;
  }

  .timeline-group {
    margin-bottom: 0;
  }

  .unit-group {
    margin-bottom: 0;
  }

  .unit-group label {
    visibility: hidden;
    height: 20px;
    margin-bottom: 6px;
  }

  .timeline-input {
    width: 100%;
  }

  .form-select {
    padding: 12px 16px;
    border: 1px solid #ddd;
    border-radius: 6px;
    font-size: 14px;
    background: white;
    cursor: pointer;
    box-sizing: border-box;
  }

  .form-select:focus {
    outline: none;
    border-color: #007bff;
    box-shadow: 0 0 0 2px rgba(0,123,255,0.25);
  }

  .calculate-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 48px;
    padding: 0 16px;
    border-radius: 8px;
    line-height: 1;
    background: #4F46E5;
    border: 1px solid #4F46E5;
    color: #fff;
    cursor: pointer;
    font-size: 16px;
    font-weight: 600;
    letter-spacing: .2px;
    transition: background-color .2s, box-shadow .2s;
  }

  .calculate-btn:hover {
    background: #4338CA;
    color: #fff;
  }

  .calculate-btn:focus-visible {
    outline: 3px solid rgba(79, 70, 229, .35);
    outline-offset: 2px;
  }

  .results-section {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .savings-plan {
    background: #fff;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    margin-bottom: 20px;
  }

  .savings-plan h3 {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin: 0 0 16px 0;
  }

  .monthly-amount {
    text-align: center;
    margin-bottom: 20px;
  }

  .monthly-amount .amount {
    display: block;
    font-size: 36px;
    font-weight: 700;
    color: #28a745;
    margin-bottom: 4px;
  }

  .monthly-amount .label {
    font-size: 14px;
    color: #666;
  }

  .breakdown {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  .breakdown-item {
    text-align: center;
    padding: 16px;
    border-radius: 8px;
  }

  .breakdown-item.blue {
    background: rgba(0, 123, 255, 0.1);
  }

  .breakdown-item.purple {
    background: rgba(108, 117, 125, 0.1);
  }

  .breakdown-item .value {
    display: block;
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 4px;
  }

  .breakdown-item.blue .value {
    color: #007bff;
  }

  .breakdown-item.purple .value {
    color: #6c757d;
  }

  .breakdown-item .label {
    font-size: 12px;
    color: #666;
  }

  .progress-visualization {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 200px;
    align-items: start;
    gap: 16px;
    background: white;
    padding: 16px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }

  .chart-section h4 {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin: 0 0 12px 0;
  }
  
  .progress-section h4 {
    font-size: 14px;
    font-weight: 600;
    color: #333;
    margin: 0 0 8px 0;
  }

  .chart-container {
    width: 100%;
    height: 250px;
    overflow: hidden;
  }

  .echart {
    width: 100%;
    height: 100%;
  }

  .goal-breakdown {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }

  .goal-breakdown h4 {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin: 0 0 16px 0;
  }

  .breakdown-table {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .breakdown-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 0;
  }

  .breakdown-row .label {
    font-size: 14px;
    color: #666;
  }

  .breakdown-row .value {
    font-size: 14px;
    font-weight: 600;
    color: #333;
  }

  @media (max-width: 768px) {
    .main-content {
      grid-template-columns: 1fr;
      gap: 24px;
    }

    .form-row {
      grid-template-columns: 1fr;
      gap: 12px;
    }

    .breakdown {
      grid-template-columns: 1fr;
    }
  }

  .status-wrap {
  min-height: 18px;          /* keeps space even when empty */
  margin-top: 10px;
}

.status-msg {
  margin: 0;
  padding: 10px 12px;
  border-radius: 8px;
  font-size: 14px;
  line-height: 1.3;
  border: 1px solid transparent;
}

/* Variants */
.is-info {
  background: #eef2ff;
  border-color: #c7d2fe;
  color: #3730a3;
}
.is-success {
  background: #ecfdf5;
  border-color: #a7f3d0;
  color: #065f46;
}
.is-warn {
  background: #fffbeb;
  border-color: #fde68a;
  color: #92400e;
}
.is-error {
  background: #fef2f2;
  border-color: #fecaca;
  color: #991b1b;
}

.progress-section {
  width: 200px;
  max-width: 200px;
  overflow: hidden;
  padding: 0;
}

.progress-circle-container {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  text-align: center;
  padding-left: 10px;
}

.progress-circle {
  position: relative;
  width: 140px;
  height: 140px;
  margin-top: 30px;
  margin-bottom: 20px;
}

.circular-chart {
  width: 100%;
  height: 100%;
  transform: rotate(-90deg);
}

.circle-bg {
  fill: none;
  stroke: #e5e7eb;
  stroke-width: 8;
}

.circle {
  fill: none;
  stroke: #10b981;
  stroke-width: 8;
  stroke-linecap: round;
  transition: stroke-dasharray 0.6s ease-in-out;
}

.percentage {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 26px;
  font-weight: 700;
  color: #10b981;
}

.progress-label {
  position: absolute;
  top: 65%;
  left: 50%;
  transform: translateX(-50%);
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
}

.progress-details {
  width: 100%;
  max-width: 180px;
  line-height: 1.3;
  padding: 0 8px;
  box-sizing: border-box;
}

.progress-details p {
  margin: 0;
  font-size: 11px;
  color: #6b7280;
  word-wrap: break-word;
}

.plan-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}

.plan-item {
  text-align: center;
  padding: 12px;
  border-radius: 8px;
}

.plan-item.main {
  background: linear-gradient(135deg, #ecfdf5 0%, #d1fae5 100%);
  border: 2px solid #059669;
}

.plan-item.secondary {
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  border: 2px solid #3b82f6;
}

.plan-item .amount {
  display: block;
  font-size: 20px;
  font-weight: 700;
  color: #059669;
  margin-bottom: 4px;
}

.plan-item .value {
  display: block;
  font-size: 16px;
  font-weight: 600;
  color: #3b82f6;
  margin-bottom: 4px;
}

.plan-item .label {
  font-size: 11px;
  color: #6b7280;
  font-weight: 500;
  line-height: 1.2;
}

@media (max-width: 1024px) {
  .progress-visualization {
    grid-template-columns: 1fr;
    gap: 24px;
  }
  
  .progress-section {
    width: 100%;
    max-width: 100%;
    overflow: visible;
  }
  
  .chart-container {
    height: 200px;
  }
  
  .progress-details {
    max-width: 100%;
    padding: 0 20px;
  }
}

</style>
