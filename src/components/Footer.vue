<template>
  <footer class="footer" role="contentinfo">
  <div class="footer-content">
    <!-- Left: logo + copy (logo on the left, text nudged left) -->
    <div class="brand-block">
      <img :src="logoSrc" alt="WealthWave" class="footer-logo" @click="goHome" />
      <div class="brand-copy">
        <h4 class="brand-title">WealthWave</h4>
        <p class="brand-blurb">
          WealthWave is a simple, practical platform designed to help you take control of your money.
          From learning financial concepts to setting savings goals, planning budgets, and understanding tax,
          our tools make financial literacy easy, trackable, and doable for everyone.
        </p>
      </div>
    </div>

    <!-- Right: explore list -->
    <nav class="footer-links" aria-label="Explore">
      
      <ul class="links-list">
  <li><a href="#home" @click.prevent="go('home')">Home</a></li>
  <li><a href="#tax-learn" @click.prevent="go('tax-learn')">Financial Concepts</a></li>
  <li><a href="#budget-planner" @click.prevent="go('budget-planner')">Budget Planner</a></li>
  <li><a href="#savings-goal-calculator" @click.prevent="go('savings-goal-calculator')">Savings Goals</a></li>
  <li><a href="#mortgage-calculator" @click.prevent="go('mortgage-calculator')">Mortgage Calculator</a></li>
  <li><a href="#financial-literacy" @click.prevent="go('financial-literacy')">Video Guides</a></li>
</ul>

    </nav>
  </div>
</footer>
</template>


<script setup>
import { inject, ref, computed, onMounted, onBeforeUnmount } from 'vue'

const navigateTo = inject('navigateTo')
const goHome = () => navigateTo('home')
const go = (r) => navigateTo(r)

// Theme detection for logo switching
const isDark = ref(window.matchMedia?.('(prefers-color-scheme: dark)').matches ?? false)

// Computed property to switch between dark/light logos
const logoSrc = computed(() => {
  return isDark.value ? '/logo-dark.png' : '/logo-light.png'
})

// Listen for theme changes
let mql, themeHandler
onMounted(() => {
  if (window.matchMedia) {
    mql = window.matchMedia('(prefers-color-scheme: dark)')
    themeHandler = (e) => { isDark.value = e.matches }
    mql.addListener?.(themeHandler)
    mql.addEventListener?.('change', themeHandler)
  }
})

onBeforeUnmount(() => {
  if (mql && themeHandler) {
    mql.removeListener?.(themeHandler)
    mql.removeEventListener?.('change', themeHandler)
  }
})
</script>

<style scoped>
.footer {
  position: relative;
  margin-top: auto;
  padding: 20px 0;
  background: transparent;
}
.footer::before{
  content:""; position:absolute; inset:0; z-index:-1;
  background:#0f172a;           /* dark strip like your site */
  border-top:1px solid rgba(255,255,255,.12);
}

/* 2 columns, aligned like the reference */
.footer-content{
  max-width:1200px; margin:0 auto; padding:0 12px;
  display:grid; grid-template-columns: minmax(0,1.6fr) minmax(0,1fr);
  gap:48px; align-items:start;
}

/* Left column: logo + text */
.brand-block{
  display:grid; grid-template-columns: 72px 1fr; gap:60px; align-items:start;
}
.footer-logo{ width:130px; height:130px; object-fit:contain; cursor:pointer; }
.brand-title{ margin:0 0 8px; font-weight:800; text-transform: none; font-size:18px; letter-spacing:.2px; color:#e5e7eb;  }
.brand-blurb{
  margin:0; max-width:560px; font-size:14px; line-height:1.65;
  color:#9ca3af; text-align:justify; text-justify:inter-word; hyphens:auto; -webkit-hyphens:auto;
}

/* Right column: vertical nav */
.footer-links{ background:transparent !important; }  /* avoid any global card bg */
.links-title{ margin:0 0 12px; font-weight:700; font-size:14px; color:#e5e7eb;  letter-spacing:.3px; }
.links-list{ list-style:none; margin:0; padding:0; display:grid; gap:10px; }
.links-list a{ color:#e5e7eb; text-decoration:none; font-weight:600; }
.links-list a:hover{ color:#c7d2fe; }


/* Nudge footer logo a bit left on larger screens */
@media (min-width: 900px) {
  .footer-logo {
    transform: translateX(-50px);  /* adjust -6/-8/-12px to taste */
  }
}


/* Mobile stacking */
@media (max-width: 900px){
  .footer-content{ grid-template-columns:1fr; gap:28px; }
  .brand-block{ grid-template-columns:64px 1fr; }
  .brand-blurb{ text-align:left; max-width:none; }
}

/* Light theme (if user forces light) */
@media (prefers-color-scheme: light){
  .footer::before{ background:#f8fafc; border-top:1px solid #e5e7eb; }
  .brand-title{ color:#111827; }
  .brand-blurb{ color:#6b7280; }
  .links-title, .links-list a{ color:#374151; }
  .links-list a:hover{ color:var(--primary-color); }
}

</style>
