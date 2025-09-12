
<template>
  <section class="mortgage-calculator">
    <div class="main-content">
      <!-- Left Side - Form -->
      <div class="calculator-card">
        <h2 class="form-title">Enter Loan Details</h2>
        
        <div class="form-field">
          <label class="field-label">Loan Amount ($)</label>
          <input 
            v-model="loanAmount" 
            type="number" 
            class="form-input" 
            placeholder="Enter loan amount (e.g., 500000)"
            min="10000"
            max="5000000"
            step="1000"
            @blur="validateLoanAmount"
          />
        </div>

        <div class="form-row">
          <div class="form-field">
            <label class="field-label">Annual Interest Rate (%)</label>
            <input 
              v-model="interestRate" 
              type="number" 
              class="form-input" 
              placeholder="e.g., 3.75"
              min="0.1"
              max="15"
              step="0.01"
              @blur="validateInterestRate"
            />
          </div>
          
          <div class="form-field">
            <label class="field-label">Loan Term (Years)</label>
            <input 
              v-model="loanTerm" 
              type="number" 
              class="form-input" 
              placeholder="e.g., 30"
              min="5"
              max="40"
              step="1"
              @blur="validateLoanTerm"
            />
          </div>
        </div>

        <button 
          class="calculate-button" 
          @click="calculatePayment"
          style="background: #4F46E5 !important; background-color: #4F46E5 !important; color: white !important; border: none !important;"
        >
          Calculate
        </button>
      </div>

      <!-- Right Side - Results Preview -->
      <div class="results-card">
        <h2 class="form-title">Mortgage Summary</h2>
        
        <div class="results-container">
          <div class="result-item">
            <span class="result-label">Monthly Payment</span>
            <span class="result-value">${{ monthlyPayment ? formatNumber(monthlyPayment) : '0' }}</span>
          </div>
          
          <div class="result-item">
            <span class="result-label">Total Payment</span>
            <span class="result-value">${{ totalPayment ? formatNumber(totalPayment) : '0' }}</span>
          </div>
          
          <div class="result-item">
            <span class="result-label">Total Interest</span>
            <span class="result-value">${{ totalInterest ? formatNumber(totalInterest) : '0' }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Result Modal -->
    <div v-if="showModal" class="modal-overlay" @click="closeModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3 class="modal-title">Calculation Results</h3>
          <button class="close-button" @click="closeModal">×</button>
        </div>
        <div class="modal-body">
          <div class="result-item">
            <span class="result-label">Monthly Payment:</span>
            <span class="result-value">${{ formatNumber(monthlyPayment) }}</span>
          </div>
          <div class="result-item">
            <span class="result-label">Total Payment:</span>
            <span class="result-value">${{ formatNumber(totalPayment) }}</span>
          </div>
          <div class="result-item">
            <span class="result-label">Total Interest:</span>
            <span class="result-value">${{ formatNumber(totalInterest) }}</span>
          </div>
        </div>
        <div class="modal-footer">
          <button class="modal-button" @click="closeModal">OK</button>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'MortgageCalculator',
  data() {
    return {
      loanAmount: '',
      interestRate: '',
      loanTerm: '',
      monthlyPayment: null,
      totalPayment: null,
      totalInterest: null,
      showModal: false
    }
  },
  methods: {
    validateLoanAmount() {
      const amount = parseFloat(this.loanAmount)
      if (amount < 10000 || amount > 5000000) {
        alert('Loan amount must be between $10,000 and $5,000,000')
      }
    },
    
    validateInterestRate() {
      const rate = parseFloat(this.interestRate)
      if (rate < 0.1 || rate > 15) {
        alert('Interest rate must be between 0.1% and 15%')
      }
    },
    
    validateLoanTerm() {
      const term = parseFloat(this.loanTerm)
      if (term < 5 || term > 40) {
        alert('Loan term must be between 5 and 40 years')
      }
    },

    calculatePayment() {
      const principal = parseFloat(this.loanAmount)
      const rate = parseFloat(this.interestRate) / 100 / 12
      const payments = parseFloat(this.loanTerm) * 12
      
      if (!principal || principal < 10000 || principal > 5000000) {
        alert('Please enter a valid loan amount between $10,000 and $5,000,000')
        return
      }
      if (!this.interestRate || parseFloat(this.interestRate) < 0.1 || parseFloat(this.interestRate) > 15) {
        alert('Please enter a valid interest rate between 0.1% and 15%')
        return
      }
      if (!this.loanTerm || parseFloat(this.loanTerm) < 5 || parseFloat(this.loanTerm) > 40) {
        alert('Please enter a valid loan term between 5 and 40 years')
        return
      }
      
      if (principal && rate && payments) {
        const monthlyPayment = principal * (rate * Math.pow(1 + rate, payments)) / (Math.pow(1 + rate, payments) - 1)
        this.monthlyPayment = monthlyPayment.toFixed(2)
        this.totalPayment = (monthlyPayment * payments).toFixed(2)
        this.totalInterest = (this.totalPayment - principal).toFixed(2)
        // No modal - just show results in the right panel
      }
    },
    closeModal() {
      this.showModal = false
    },
    formatNumber(value) {
      if (!value) return '0'
      return parseFloat(value).toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
    }
  }
}
</script>

<style scoped>
.mortgage-calculator {
  background-color: #f8fafc;
  min-height: auto;
  display: flex;
  flex-direction: column;
  padding: 20px 0;
}

.main-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 24px;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 40px;
}

.calculator-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  height: 340px;
  display: flex;
  flex-direction: column;
}

.results-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  padding: 32px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  height: 340px;
  display: flex;
  flex-direction: column;
}

.form-title {
  font-size: 24px;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 32px 0;
}

.form-field {
  margin-bottom: 24px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 24px;
}

.field-label {
  display: block;
  font-size: 16px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
}

.input-container {
  position: relative;
  display: flex;
  align-items: center;
}

.form-input {
  width: 100%;
  height: 48px;
  padding: 0 16px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 16px;
  color: #1f2937;
  background: white;
  outline: none;
  transition: border-color 0.2s, box-shadow 0.2s;
  box-sizing: border-box;
}

.form-input::placeholder {
  color: #9ca3af;
}

/* Dark mode placeholder visibility */
@media (prefers-color-scheme: dark) {
  .form-input::placeholder {
    color: #9CA3AF !important;
    opacity: 1;
  }
}

.form-input:focus {
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
}

.input-prefix {
  position: absolute;
  left: 16px;
  color: #1f2937;
  font-size: 16px;
  font-weight: 600;
  pointer-events: none;
}

.input-suffix {
  position: absolute;
  right: 12px;
  color: #6b7280;
  font-size: 16px;
  pointer-events: none;
}

.input-container .input-prefix + .form-input {
  padding-left: 40px;
}

.input-container .form-input:has(+ .input-suffix) {
  padding-right: 50px;
}

/* Force button styling with maximum specificity */
.mortgage-calculator .calculator-card .calculate-button,
.calculate-button {
  width: 100% !important;
  height: 48px !important;
  background: #4F46E5 !important;
  background-color: #4F46E5 !important;
  color: #fff !important;
  border: 0 !important;
  border: none !important;
  padding: 0.9rem !important;
  border-radius: 8px !important;
  font-weight: 700 !important;
  font-size: 16px !important;
  cursor: pointer !important;
  transition: background-color 0.2s !important;
  margin-top: 16px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
}

.mortgage-calculator .calculator-card .calculate-button:hover,
.calculate-button:hover {
  background: #4338CA !important;
  background-color: #4338CA !important;
}

.mortgage-calculator .calculator-card .calculate-button:active,
.calculate-button:active {
  background: #3730a3 !important;
  background-color: #3730a3 !important;
}

/* Dark mode override */
@media (prefers-color-scheme: dark) {
  .mortgage-calculator .calculator-card .calculate-button,
  .calculate-button {
    background: #4F46E5 !important;
    background-color: #4F46E5 !important;
    color: #fff !important;
  }
  
  .mortgage-calculator .calculator-card .calculate-button:hover,
  .calculate-button:hover {
    background: #4338CA !important;
    background-color: #4338CA !important;
  }
}

.page-footer {
  background: #374151;
  margin-top: auto;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px 24px;
  text-align: center;
  color: #9ca3af;
  font-size: 14px;
}

/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow: hidden;
}

.modal-header {
  padding: 24px 24px 0 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.modal-title {
  font-size: 20px;
  font-weight: 600;
  color: #111827;
  margin: 0;
}

.close-button {
  background: none;
  border: none;
  font-size: 24px;
  color: #6b7280;
  cursor: pointer;
  padding: 4px;
  line-height: 1;
  transition: color 0.2s;
}

.close-button:hover {
  color: #374151;
}

.modal-body {
  padding: 24px;
}

.result-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 0;
  border-bottom: 1px solid #f3f4f6;
}

.result-item:last-child {
  border-bottom: none;
}

.result-label {
  font-size: 16px;
  color: #374151;
  font-weight: 500;
}

.result-value {
  font-size: 18px;
  font-weight: 600;
  color: #059669;
}

.modal-footer {
  padding: 0 24px 24px 24px;
}

.modal-button {
  width: 100%;
  height: 44px;
  background: #4f46e5;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s;
}

.modal-button:hover {
  background: #4338ca;
}

/* Results Container - Fixed Layout */
.results-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
  flex: 1;
}

.result-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 0;
  border-bottom: 1px solid #f3f4f6;
}

.result-item:last-child {
  border-bottom: none;
}

.result-label {
  font-size: 16px;
  color: #6b7280;
  font-weight: 500;
}

.result-value {
  font-size: 24px;
  font-weight: 700;
  color: #059669;
}

/* Responsive */
@media (max-width: 768px) {
  .main-content {
    grid-template-columns: 1fr;
    gap: 24px;
  }
}
</style>