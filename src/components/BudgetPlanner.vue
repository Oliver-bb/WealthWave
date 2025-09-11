<template>
  <div class="budget-planner">
    <div class="main-content">
      <div class="container">
        <!-- Top: left form + right chart -->
        <div class="budget-section">
          <!-- Left: Budget form -->
          <div class="form-section">
            <!-- Income -->
            <div class="income-section">
              <div class="section-header">
                <div class="section-icon green"></div>
                <h3>Monthly Income</h3>
              </div>
              <div class="form-group">
                <label>Salary</label>
                <input type="text" v-model="income.salary" placeholder="Enter your monthly salary" />
              </div>
              <div class="form-group">
                <label>Investments</label>
                <input type="text" v-model="income.investments" placeholder="Investment returns" />
              </div>
              <div class="form-group">
                <label>Other Income</label>
                <input type="text" v-model="income.other" placeholder="Freelance, side jobs, etc." />
              </div>
            </div>

            <!-- Expenses -->
            <div class="expenses-section">
              <div class="section-header">
                <div class="section-icon red"></div>
                <h3>Monthly Expenses</h3>
              </div>
              <div class="form-group">
                <label>Housing</label>
                <input type="text" v-model="expenses.housing" placeholder="Rent, mortgage, utilities" />
              </div>
              <div class="form-group">
                <label>Transportation</label>
                <input type="text" v-model="expenses.transportation" placeholder="Car payments, gas, public transport" />
              </div>
              <div class="form-group">
                <label>Food & Dining</label>
                <input type="text" v-model="expenses.food" placeholder="Groceries, restaurants" />
              </div>
              <div class="form-group">
                <label>Entertainment</label>
                <input type="text" v-model="expenses.entertainment" placeholder="Movies, subscriptions, hobbies" />
              </div>
              <div class="form-group">
                <label>Healthcare</label>
                <input type="text" v-model="expenses.healthcare" placeholder="Insurance, medical expenses" />
              </div>
            </div>

            <button class="calculate-btn" @click="calculateBudget">Calculate Budget</button>
          </div>

          <!-- Right: Pie Chart and Alerts -->
          <div class="summary-section">
            <div class="chart-card">
              <div class="chart-header">
                <h3>Expense Distribution</h3>
              </div>
              <div class="chart-section">
                <div ref="chartRef" class="chart-container"></div>
              </div>
              
              <!-- Overspending Alerts inside the same card -->
              <div class="alerts-section-inline">
                <div class="alerts-header-inline">
                  <h3>Overspending Alerts</h3>
                  <p class="muted">Monitor your spending patterns and budget limits</p>
                </div>
                <div class="alerts-grid-inline">
                  <div
                    v-for="item in alertCards"
                    :key="item.key"
                    class="alert-card-inline"
                    :class="statusClass(item)"
                  >
                    <div class="alert-header">
                      <h4>{{ item.name }}</h4>
                      <div class="alert-icon">{{ statusIcon(item) }}</div>
                    </div>

                    <div class="alert-content">
                      <div class="alert-row">
                        <span>Spent</span>
                        <span>${{ formatNumber(item.spent) }}</span>
                      </div>

                      <div class="alert-row editable">
                        <span>Budget</span>
                        <div class="budget-edit">
                          <span class="currency">$</span>
                          <input
                            type="number"
                            class="budget-input"
                            v-model.number="budgets[item.key]"
                            min="0"
                          />
                        </div>
                      </div>

                      <div class="progress-bar">
                        <div
                          class="progress-fill"
                          :class="barClass(item)"
                          :style="{ width: progressWidth(item) }"
                        ></div>
                      </div>
                      <div class="alert-status">
                        {{ percentUsed(item) }}% - {{ statusText(item) }}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed, watch } from "vue";
import * as echarts from "echarts";

export default {
  name: "BudgetPlanner",
  setup() {
    // ===== Left form =====
    const income = ref({ salary: "5800", investments: "0", other: "0" });
    const expenses = ref({
      housing: "1800",
      transportation: "650",
      food: "400",
      entertainment: "200",
      healthcare: "150",
    });

    // 用于“已计算”的快照：仅点击按钮后更新
    const displayedExpenses = ref({ ...expenses.value });

    // ===== Chart update trigger =====
    const shouldUpdate = ref(false);

    // ===== Pie chart =====
    const chartRef = ref(null);
    let chart = null;

    const initChart = () => {
      if (!chartRef.value) return;
      if (!chart) {
        chart = echarts.init(chartRef.value);
        window.addEventListener("resize", () => chart && chart.resize());
      }
      updateChart();
    };

    const updateChart = () => {
      if (!chart) return;
      const data = [
        { value: parseFloat(displayedExpenses.value.housing) || 0,        name: "Housing" },
        { value: parseFloat(displayedExpenses.value.transportation) || 0, name: "Transportation" },
        { value: parseFloat(displayedExpenses.value.food) || 0,           name: "Food & Dining" },
        { value: parseFloat(displayedExpenses.value.entertainment) || 0,  name: "Entertainment" },
        { value: parseFloat(displayedExpenses.value.healthcare) || 0,     name: "Healthcare" },
      ];
      
      // Detect dark mode
      const isDarkMode = document.documentElement.classList.contains('non-home-dark');
      const textColor = isDarkMode ? '#e6eaf2' : '#374151';
      
      chart.setOption({
        tooltip: { 
          trigger: "item", 
          formatter: "{b}<br/>${c} ({d}%)",
          textStyle: { color: textColor }
        },
        legend: { 
          bottom: 8,
          textStyle: { color: textColor }
        },
        series: [{
          name: "Expenses",
          type: "pie",
          radius: ["40%", "70%"],
          center: ["50%", "50%"],
          itemStyle: { borderRadius: 8, borderColor: "#fff", borderWidth: 2 },
          label: { 
            formatter: "{b}\n${c}",
            color: textColor
          },
          data: data.length ? data : [{ value: 1, name: "No Data" }],
        }],
      });
    };

    const calculateBudget = () => { 
      shouldUpdate.value = true;
      // 同步快照：Alerts与图表都在点击后更新
      displayedExpenses.value = { ...expenses.value };
      displayedBudgets.value  = { ...budgets.value };
      if (chart) updateChart(); 
    };

    // ===== Alerts =====
    const categoryMeta = [
      { key: "housing",        name: "Housing" },
      { key: "transportation", name: "Transportation" },
      { key: "food",           name: "Food & Dining" },
      { key: "entertainment",  name: "Entertainment" },
      { key: "healthcare",     name: "Healthcare" },
    ];

    const budgets = ref({
      housing: 2000,
      transportation: 500,
      food: 600,
      entertainment: 300,
      healthcare: 200,
    });

    const displayedBudgets = ref({ ...budgets.value });

    const alertCards = computed(() =>
      categoryMeta.map(m => {
        const spent  = parseFloat(displayedExpenses.value[m.key]) || 0;
        const budget = parseFloat(displayedBudgets.value[m.key]) || 0;
        return { ...m, spent, budget };
      })
    );

    const percentUsed = (item) => {
      const spent = item.spent || 0;
      const budget = item.budget || 0;
      if (budget <= 0) return spent > 0 ? 100 : 0;
      return Math.round((spent / budget) * 100);
    };
    const statusClass   = (item) => percentUsed(item) > 100 ? "exceeded" : (percentUsed(item) >= 90 ? "warning" : "good");
    const barClass      = (item) => statusClass(item);
    const progressWidth = (item) => Math.min(percentUsed(item), 100) + "%";
    const statusText    = (item) => percentUsed(item) > 100 ? "Exceeded" : (percentUsed(item) >= 90 ? "Warning" : "Good");
    const statusIcon    = (item) => percentUsed(item) > 100 ? "🚫" : (percentUsed(item) >= 90 ? "⚠️" : "✅");
    const formatNumber  = (v) => (parseFloat(v) || 0).toLocaleString();

    // ===== Mount & watchers =====
    onMounted(() => {
      initChart();
      calculateBudget();
    });

    // Only update when Calculate Budget is clicked
    // Remove automatic updates on input change

    return {
      income, expenses, calculateBudget,
      chartRef, shouldUpdate,
      budgets, alertCards, percentUsed, statusClass, barClass, progressWidth, statusText, statusIcon, formatNumber,
    };
  },
};
</script>

<style scoped>
.budget-planner { min-height: 100vh; background: #f8fafc; }
.main-content { padding: 40px 0 3rem 0; }
.container { max-width: 1400px; margin: 0 auto; padding: 0 2rem; }

/* top layout: left form + right flashcards */
.budget-section { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; margin-bottom: 32px; }

/* left card */
.form-section { background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,.1); }
.income-section, .expenses-section { margin-bottom: 20px; }

.section-header { display: flex; align-items: center; gap: 8px; margin-bottom: 12px; }
.section-icon { width: 12px; height: 12px; border-radius: 50%; }
.section-icon.green { background: #10B981; }
.section-icon.red { background: #EF4444; }
.section-header h3 { font-size: 1.05rem; font-weight: 700; color: #111827; margin: 0; }

.form-group { margin-bottom: 12px; }
.form-group label { display: block; font-size: .875rem; font-weight: 500; color: #374151; margin-bottom: 6px; }
.form-group input { 
  width: 100%; 
  padding: .72rem; 
  border: 1px solid #d1d5db; 
  border-radius: 8px; 
  background: #fff; 
  font-size: .9rem; 
  box-sizing: border-box;
  max-width: 100%;
}
.form-group input:focus { outline: none; border-color: #4F46E5; box-shadow: 0 0 0 3px rgba(79,70,229,.12); }

.calculate-btn { width: 100%; background: #4F46E5; color: #fff; border: 0; padding: .9rem; border-radius: 10px; font-weight: 700; cursor: pointer; }
.calculate-btn:hover { background: #4338CA; }

/* right chart section */
.summary-section { display: flex; flex-direction: column; }
.chart-card { 
  background: #fff; 
  border-radius: 12px; 
  box-shadow: 0 8px 24px rgba(0,0,0,.06); 
  padding: 16px; 
  display: flex;
  flex-direction: column;
  height: fit-content;
  position: relative;
}
.chart-header { padding: 4px 6px 8px; border-bottom: 1px solid #f1f5f9; margin-bottom: 10px; }
.chart-header h3 { font-size: 0.95rem; font-weight: 700; color: #111827; margin: 0; }

/* inline alerts section - ensure it stays inside the same card */
.alerts-section-inline { 
  margin-top: 16px; 
  padding-top: 16px;
  border-top: 1px solid #f1f5f9;
  position: relative;
  z-index: 1;
}
.alerts-header-inline { margin-bottom: 12px; }
.alerts-header-inline h3 { font-size: 0.9rem; font-weight: 700; color: #111827; margin: 0 0 3px 0; }
.alerts-header-inline .muted { color: #64748b; font-size: .8rem; margin: 0; }

.chart-section { background: #fff; padding: 2px; border-radius: 8px; }
.summary-section .chart-container { height: 340px; min-height: 340px; }

/* Alerts grid - inline version */
.alerts-grid-inline { 
  display: grid; 
  grid-template-columns: repeat(2, minmax(0, 1fr)); 
  gap: 14px; 
  max-height: none;
  overflow: visible;
}
.alert-card-inline { 
  background: #f8fafc; 
  border-radius: 8px; 
  padding: 12px; 
  border-left: 3px solid;
  box-shadow: 0 1px 2px rgba(0,0,0,.04);
  font-size: 0.92rem;
}
.alert-card.warning  { border-left-color: #F59E0B; }
.alert-card.exceeded { border-left-color: #EF4444; }
.alert-card.good     { border-left-color: #10B981; }

.alert-card-inline.warning  { border-left-color: #F59E0B; }
.alert-card-inline.exceeded { border-left-color: #EF4444; }
.alert-card-inline.good     { border-left-color: #10B981; }

.alert-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px; }
.alert-header h4 { font-size: 0.95rem; font-weight: 700; color: #111827; margin: 0; }
.alert-content { display: flex; flex-direction: column; gap: 6px; }
.alert-row { display: flex; justify-content: space-between; font-size: .9rem; color: #64748b; }

.progress-bar { width: 100%; height: 8px; background: #f1f5f9; border-radius: 4px; overflow: hidden; }
.progress-fill { height: 100%; border-radius: 4px; }
.progress-fill.warning  { background: #F59E0B; }
.progress-fill.exceeded { background: #EF4444; }
.progress-fill.good     { background: #10B981; }

.alert-status { font-size: .9rem; font-weight: 700; }
.alert-card.warning  .alert-status { color: #B45309; }     
.alert-card.exceeded .alert-status { color: #B91C1C; }     
.alert-card.good     .alert-status { color: #065F46; }     

/* 强化 inline 版本的状态色 */
.alert-card-inline.warning  .alert-status { color: #B45309; }
.alert-card-inline.exceeded .alert-status { color: #B91C1C; }
.alert-card-inline.good     .alert-status { color: #065F46; }

.alert-row.editable { align-items: center; }
.budget-edit { display: inline-flex; align-items: center; gap: 6px; }
.budget-edit .currency { color: #6b7280; font-size: 0.9rem; }
.budget-input { width: 110px; padding: 6px 10px; border: 1px solid #e5e7eb; border-radius: 8px; font-size: 0.9rem; background: #fff; }
.budget-input:focus { outline: none; border-color: #4F46E5; box-shadow: 0 0 0 3px rgba(79,70,229,.12); }

/* responsive */
@media (max-width: 1200px) {
  .budget-section { grid-template-columns: 1fr; }
  .alerts-grid-inline { grid-template-columns: 1fr; }
}
</style>
