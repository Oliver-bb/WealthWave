<template>
  <!-- Sticky site header -->
  <header
    ref="el"
    class="header"
    :class="[
      isDark ? 'theme-slate' : 'theme-pearl',
      (currentRoute !== 'home' || scrolled) && 'solid'
    ]"
    :data-ribbon="currentRoute === 'home' ? 'on' : 'off'"
  >
    <div class="container">
      <nav class="navbar">
        <!-- Logo -->
        <div
          class="logo"
          role="link"
          tabindex="0"
          @click="go('home')"
          @keydown.enter.prevent="go('home')"
          @keydown.space.prevent="go('home')"
          style="cursor:pointer"
        >
          <img class="logo-mark" :src="logoSrc" alt="WealthWave Logo" aria-hidden="true">
        </div>

        <!-- Mobile toggle -->
        <button class="menu-toggle" @click="menuOpen = !menuOpen" aria-label="Toggle menu">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
            <path d="M4 7h16M4 12h16M4 17h16" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
          </svg>
        </button>

        <!-- Links -->
        <ul class="nav-links" :class="{ open: menuOpen }">
          <li><a href="#" :class="{ active: currentRoute === 'home' }" @click.prevent="go('home')">Home</a></li>
          <li><a href="#" :class="{active: currentRoute==='tax-learn'}" @click.prevent="go('tax-learn')">Financial Concepts</a></li>
          <li><a href="#" :class="{active: currentRoute==='financial-literacy'}" @click.prevent="go('financial-literacy')">Video Guides</a></li>
          <li><a href="#" :class="{active: currentRoute==='budget-planner'}" @click.prevent="go('budget-planner')">Budget Planner</a></li>
          <li><a href="#" :class="{active: currentRoute==='savings-goal-calculator'}" @click.prevent="go('savings-goal-calculator')">Savings Goals</a></li>
       <!--   <li><a href="#" :class="{active: currentRoute==='cost-estimator'}" @click.prevent="go('cost-estimator')">Study & Living Costs</a></li> -->
          
      <!--    <li><a href="#" :class="{active: currentRoute==='mortgage-calculator'}" @click.prevent="go('mortgage-calculator')">Home & Mortgage Planning</a></li> -->
        </ul>
      </nav>
    </div>
  </header>

  <!-- Spacer: 0 on home, real height elsewhere -->
  <div
    class="header-spacer"
    :style="{ height: (currentRoute === 'home' ? '0px' : headerH + 'px') }"
    aria-hidden="true"
  />
</template>

<script setup>
import { inject, ref, onMounted, onBeforeUnmount, watch, nextTick, computed } from 'vue'

const navigateTo = inject('navigateTo')
const currentRoute = inject('currentRoute')

const menuOpen = ref(false)
const go = (r) => { menuOpen.value = false; navigateTo(r) }

const isDark = ref(window.matchMedia?.('(prefers-color-scheme: dark)').matches ?? false)
let mql, themeHandler

// Computed property to switch between dark/light logos
const logoSrc = computed(() => {
  return isDark.value ? '/logo-dark.png' : '/logo-light.png'
})

// measure header height and publish to :root as --header-height
const el = ref(null)
const headerH = ref(72)

const scrolled = ref(false)
function onScroll() {
  scrolled.value = window.scrollY > 8
}

function publishHeight(h) {
  document.documentElement.style.setProperty('--header-height', `${h}px`)
}

function measure() {
  const h = el.value?.offsetHeight || 72
  headerH.value = h
  publishHeight(h)
}

let ro
function setupResizeObserver() {
  if (window.ResizeObserver && el.value) {
    ro = new ResizeObserver(measure)
    ro.observe(el.value)
  } else {
    window.addEventListener('resize', measure)
  }
}

onMounted(() => {
  // Dark mode listener
  mql = window.matchMedia('(prefers-color-scheme: dark)')
  themeHandler = (e) => { isDark.value = e.matches }
  mql.addEventListener('change', themeHandler)

  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()

  // Initial measure and observers
  nextTick(measure)
  setupResizeObserver()
})

// Re-measure when menu opens/closes (height can change on mobile)
watch(menuOpen, async () => { await nextTick(); measure() })

// Apply dark page backdrop when OS is dark AND we're off home
const DARK_CLASS = 'non-home-dark'
function applyPageTheme() {
  const html = document.documentElement
  const shouldDark = (currentRoute.value !== 'home') && isDark.value
  html.classList.toggle(DARK_CLASS, shouldDark)
}
watch([currentRoute, isDark], applyPageTheme, { immediate: true })

onBeforeUnmount(() => {
  mql?.removeEventListener('change', themeHandler)
  if (ro) ro.disconnect()
  else window.removeEventListener('resize', measure)
  window.removeEventListener('scroll', onScroll)
})
</script>

<!-- Global (unscoped) styles used when .non-home-dark is present -->
<style>
:root {
  --page-bg-dark: #0b1220;
  --page-text-dark: #e6eaf2;
}
.non-home-dark, .non-home-dark body {
  background-color: var(--page-bg-dark);
  color: var(--page-text-dark);
}
.non-home-dark main,
.non-home-dark .container,
.non-home-dark .page-section {
  background: transparent;
}
.non-home-dark .page-header { color: var(--page-text-dark); }

/* Dark mode page header text overrides */
.non-home-dark .ww-header h1,
.non-home-dark .ww-header h2,
.non-home-dark .ww-header h3 {
  color: #e6eaf2 !important;
}
.non-home-dark .ww-header p {
  color: #e6eaf2 !important;  /* Same white color as headings */
}

/* Dark mode - comprehensive card and form styling */
.non-home-dark .form-section,
.non-home-dark .calculator-card,
.non-home-dark .savings-plan,
.non-home-dark .progress-visualization,
.non-home-dark .goal-breakdown,
.non-home-dark .modules-grid > div,
.non-home-dark .module-card,
.non-home-dark .video-card,
.non-home-dark .course-card,
.non-home-dark .left-column > div,
.non-home-dark .right-column > div,
.non-home-dark .calculator-container,
.non-home-dark .breakdown-section,
.non-home-dark .flashcard-container,
.non-home-dark .flashcard,
.non-home-dark .flashcard-wrapper,
.non-home-dark .terms-card,
.non-home-dark .right-column,
.non-home-dark .card-section {
  background: #1f2937 !important;
  color: #e6eaf2 !important;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3) !important;
}

/* Dark mode form inputs */
.non-home-dark input,
.non-home-dark select,
.non-home-dark textarea,
.non-home-dark .form-input,
.non-home-dark .form-select,
.non-home-dark .timeline-input,
.non-home-dark .input-container input,
.non-home-dark .currency-symbol {
  background: #374151 !important;
  color: #e6eaf2 !important;
}

.non-home-dark input::placeholder,
.non-home-dark textarea::placeholder {
  color: #9ca3af !important;
}

/* Universal font consistency across all pages */
* {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif !important;
}

/* Light mode text for specific page components only */
.tax-learn *:not(button):not(.btn),
.budget-planner *:not(button):not(.btn),
.savings-goal-calculator *:not(button):not(.btn),
.financial-literacy *:not(button):not(.btn),
.mortgage-calculator *:not(button):not(.btn),
.cost-estimator *:not(button):not(.btn) {
  color: #000000 !important;
}

/* Universal dark mode text - exclude budget planner and preserve color elements */
.non-home-dark *:not(button):not(.btn):not(.tax-color):not(.category-badge):not(.item-icon):not(.resource-icon):not(.section-icon) {
  color: #e6eaf2 !important;
}

/* Let Budget Planner handle its own styling but preserve alert colors */
.non-home-dark .budget-planner * {
  color: inherit;
}

/* Preserve budget alert status colors in dark mode */
.non-home-dark .alert-card-inline.warning,
.non-home-dark .alert-card.warning {
  border-left-color: #F59E0B !important;
}

.non-home-dark .alert-card-inline.exceeded,
.non-home-dark .alert-card.exceeded {
  border-left-color: #EF4444 !important;
}

.non-home-dark .alert-card-inline.good,
.non-home-dark .alert-card.good {
  border-left-color: #10B981 !important;
}

.non-home-dark .alert-card-inline.warning .alert-status,
.non-home-dark .alert-card.warning .alert-status {
  color: #F59E0B !important;
}

.non-home-dark .alert-card-inline.exceeded .alert-status,
.non-home-dark .alert-card.exceeded .alert-status {
  color: #EF4444 !important;
}

.non-home-dark .alert-card-inline.good .alert-status,
.non-home-dark .alert-card.good .alert-status {
  color: #10B981 !important;
}

.non-home-dark .progress-fill.warning {
  background: #F59E0B !important;
}

.non-home-dark .progress-fill.exceeded {
  background: #EF4444 !important;
}

.non-home-dark .progress-fill.good {
  background: #10B981 !important;
}

/* Fix chart text visibility in dark mode */
.non-home-dark .chart-container text,
.non-home-dark .chart-container .echarts-legend-item,
.non-home-dark .chart-container .echarts-legend-item text,
.non-home-dark .chart-container div[style*="color"],
.non-home-dark svg text,
.non-home-dark canvas + div text {
  fill: #e6eaf2 !important;
  color: #e6eaf2 !important;
}

/* Make sure chart legend is fully visible - more specific targeting */
.non-home-dark .chart-container * {
  color: #e6eaf2 !important;
}

.non-home-dark div[_echarts_instance_] * {
  color: #e6eaf2 !important;
  fill: #e6eaf2 !important;
}

.non-home-dark .chart-container > div * {
  color: #e6eaf2 !important;
  fill: #e6eaf2 !important;
}

/* Preserve color-coded elements in dark mode with proper contrast */
.non-home-dark .tax-color.red,
.non-home-dark .section-icon.red {
  background: #ef4444 !important;
  color: #dc2626 !important;
}

.non-home-dark .category-badge.red,
.non-home-dark .item-icon.red,
.non-home-dark .resource-icon.red {
  background: #ef4444 !important;
  color: white !important;
}

.non-home-dark .tax-color.orange {
  background: #f97316 !important;
  color: #ea580c !important;
}

.non-home-dark .category-badge.orange,
.non-home-dark .item-icon.orange,
.non-home-dark .resource-icon.orange {
  background: #f97316 !important;
  color: white !important;
}

.non-home-dark .tax-color.green,
.non-home-dark .section-icon.green {
  background: #10b981 !important;
  color: #16a34a !important;
}

.non-home-dark .category-badge.green,
.non-home-dark .item-icon.green,
.non-home-dark .resource-icon.green {
  background: #10b981 !important;
  color: white !important;
}

.non-home-dark .tax-color.blue {
  background: #3b82f6 !important;
  color: #2563eb !important;
}

.non-home-dark .category-badge.blue,
.non-home-dark .item-icon.blue,
.non-home-dark .resource-icon.blue {
  background: #3b82f6 !important;
  color: white !important;
}

.non-home-dark .tax-color.purple {
  background: #8b5cf6 !important;
  color: #a855f7 !important;
}

.non-home-dark .category-badge.purple,
.non-home-dark .item-icon.purple,
.non-home-dark .resource-icon.purple {
  background: #8b5cf6 !important;
  color: white !important;
}

/* Slightly dimmed text for paragraphs and descriptions in dark mode only */
.non-home-dark p,
.non-home-dark .description,
.non-home-dark .card-description,
.non-home-dark .module-description,
.non-home-dark small {
  color: #d1d5db !important;
}

/* Dark mode buttons - preserve original backgrounds and styling */
.non-home-dark button {
  background: inherit !important;
  color: white !important;
}

/* Make specific action buttons blue in dark mode with consistent rounded corners */
.non-home-dark .start-learning-btn,
.non-home-dark .calculate-btn,
.non-home-dark button[class*="calculate"],
.non-home-dark button[class*="calc"],
.non-home-dark .btn-calculate,
.non-home-dark .primary-btn,
.non-home-dark .hint-link,
.non-home-dark .arrow-btn,
.non-home-dark button[class*="prev"],
.non-home-dark button[class*="next"],
.non-home-dark button[class*="term"],
.non-home-dark .nav-btn,
.non-home-dark .navigation-btn,
.non-home-dark button[style*="background: #4f46e5"],
.non-home-dark button[style*="background:#4f46e5"] {
  background: #4f46e5 !important;
  color: white !important;
  border-radius: 6px !important;
}

/* Ensure all buttons have consistent rounded corners and padding */
.non-home-dark button {
  border-radius: 6px !important;
  padding: 8px 16px !important;
}

/* Clean, specific dark mode styling */
.non-home-dark .form-section,
.non-home-dark .calculator-card,
.non-home-dark .flashcard,
.non-home-dark .breakdown-section,
.non-home-dark .terms-card {
  background: #1f2937 !important;
  color: #e6eaf2 !important;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.3) !important;
}

/* Form elements */
.non-home-dark input,
.non-home-dark select,
.non-home-dark textarea {
  background: #374151 !important;
  color: #e6eaf2 !important;
  border-color: #4b5563 !important;
}

/* Remove problematic hover effects - let original component styles handle it */
</style>

<style scoped>
/* ===== Header container ===== */
.header {
  position: sticky; top: 0; z-index: 40; width: 100%;
  isolation: isolate;
  background: transparent;
  box-shadow: 0 6px 20px rgba(0,0,0,.04);
}

/* spacer element lives outside the sticky header to push content down */
.header-spacer { width: 100%; }

/* ===== Glass layer (shared) — no color here ===== */
.header.theme-pearl::before,
.header.theme-slate::before {
  content: "";
  position: absolute; inset: 0;
  z-index: -1;
  backdrop-filter: blur(16px) saturate(160%);
  -webkit-backdrop-filter: blur(16px) saturate(160%);
  border-bottom: 1px solid transparent; /* set per theme */
}

/* Light ribbon */
.header.theme-pearl::before {
  background: #ffffff;
  border-bottom-color: rgba(0,0,0,0.06);
}
.header.theme-pearl .logo-text { color: #000000; }              /* dark text in light theme */
.header.theme-pearl .nav-links a { color: #000000; font-weight: 600; }  /* dark black text */
.header.theme-pearl .nav-links a:hover { color: #333333; }  /* slightly lighter on hover */
.header.theme-pearl .nav-links a::after { background: #000000; }

/* Dark ribbon */
.header.theme-slate::before {
  background: #030911;
  border-bottom-color: rgba(255,255,255,0.06);
}
.header.theme-slate .logo-text { color: #E5E7EB; }
.header.theme-slate .nav-links a { color: #e6eaf2; text-shadow: 0 1px 2px rgba(0,0,0, 0.35); }
.header.theme-slate .nav-links a:hover,
.header.theme-slate .nav-links a.active { color: #fff; }
.header.theme-slate .nav-links a::after { background: rgba(255,255,255,0.9); }

/* ===== Layout & sizing ===== */
.navbar {
  height: 137px;  /* reasonable navbar height */
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.logo-mark { 
  width: 130px !important; 
  height: 130px !important; 
  object-fit: contain;
  border-radius: 4px;
}
.logo-text { font-size: 22px !important; line-height: 1; font-weight: 700; letter-spacing: -0.02em; }

/* Desktop links */
.nav-links {
  display: flex;
  align-items: center;
  gap: 20px;
  list-style: none;
  margin: 0;
  padding: 0;
}
.nav-links a {
  position: relative;
  white-space: nowrap;
  padding: 10px 6px 12px;
  text-decoration: none;
  font-weight: 700;
  font-size: 16px;
  transition: color .15s ease;
}
.nav-links a::after {
  content: "";
  position: absolute;
  left: 0; right: 100%; bottom: 4px; height: 2px;
  border-radius: 1px;
  transition: right .22s ease;
}
.nav-links a:hover::after,
.nav-links a.active::after { right: 0; }

/* ===== Responsive nav ===== */
.menu-toggle {
  display: none;
  width: 40px; height: 40px;
  border: 1px solid currentColor; border-radius: 10px;
  background: transparent; color: currentColor; opacity: .85;
}

@media (max-width: 1200px) {
  .menu-toggle { display: inline-flex; align-items: center; justify-content: center; }

  /* Use dynamic header height for the dropdown top edge */
  .nav-links {
    position: fixed; left: 0; right: 0; top: var(--header-height, 72px);
    display: none;
    flex-direction: column; align-items: flex-start;
    gap: 12px; padding: 12px 16px;
    background: rgba(255,255,255,0.95);
    backdrop-filter: blur(12px);
    -webkit-backdrop-filter: blur(12px);
    box-shadow: 0 12px 30px rgba(0,0,0,.14);
    z-index: 50;
  }
  .nav-links.open { display: flex; }

  .header.theme-slate .nav-links {
    background: rgba(3, 9, 17,0.92);
  }
}

/* Wider screens: keep consistent logo and navbar sizes */
@media (min-width: 1200px) {
  .header.theme-pearl .nav-links { background: rgba(255, 255, 255, 0.95); }
}

/* Ribbon visibility: hidden by default, only ON at home */
.header::before {
  opacity: 0;
  border-bottom-color: transparent;
  transition: opacity .18s ease, background-color .18s ease, border-color .18s ease;
}
.header { box-shadow: none; }
.header[data-ribbon="on"]::before { opacity: 1; }
.header[data-ribbon="on"] { box-shadow: 0 6px 20px rgba(0,0,0,.04); }

/* SOLID STATE: background depends on theme (no generic .header.solid::before) */
.header.theme-pearl.solid::before {
  opacity: 1;
  background: #ffffff;
  border-bottom-color: rgba(0,0,0,0.06);
}
.header.theme-slate.solid::before {
  opacity: 1;
  background: #0b1220;
  border-bottom-color: rgba(255,255,255,0.06);
}

/* Optional: subtle shadow when solid */
.header.solid { box-shadow: 0 4px 16px rgba(0,0,0,0.08); }
</style>
