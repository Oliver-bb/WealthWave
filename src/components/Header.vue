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
          <li><a href="#" :class="{active: currentRoute==='budget-planner'}" @click.prevent="go('budget-planner')">Budget Planner</a></li>
          <li><a href="#" :class="{active: currentRoute==='savings-goal-calculator'}" @click.prevent="go('savings-goal-calculator')">Savings Goals</a></li>
          <li><a href="#" :class="{active: currentRoute==='mortgage-calculator'}" @click.prevent="go('mortgage-calculator')">Mortgage Calculator</a></li>
          <li><a href="#" :class="{active: currentRoute==='financial-literacy'}" @click.prevent="go('financial-literacy')">Video Guides</a></li>
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
.non-home-dark main {
  background-color: var(--page-bg-dark);
  min-height: calc(100vh - var(--header-height, 137px));
}

/* Override page component backgrounds in dark mode */
.non-home-dark .financial-literacy,
.non-home-dark .budget-planner,
.non-home-dark .savings-goal-calculator,
.non-home-dark .tax-learn,
.non-home-dark .mortgage-calculator,
.non-home-dark .cost-estimator {
  background: var(--page-bg-dark) !important;
  margin-bottom: 0 !important;
}

/* Ensure page components fill the main container properly */
.non-home-dark .financial-literacy,
.non-home-dark .budget-planner,
.non-home-dark .savings-goal-calculator,
.non-home-dark .tax-learn,
.non-home-dark .mortgage-calculator,
.non-home-dark .cost-estimator {
  min-height: 100%;
}
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



/* Slightly dimmed text for paragraphs and descriptions in dark mode only */
.non-home-dark p,
.non-home-dark .description,
.non-home-dark .card-description,
.non-home-dark .module-description,
.non-home-dark small {
  color: #d1d5db !important;
}

/* Dark mode buttons - preserve original backgrounds and styling */
.non-home-dark button:not(.menu-toggle):not(.start-learning-btn):not(.calculate-btn):not(.primary-btn):not(.hint-link):not(.arrow-btn) {
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
  border-radius: 10px !important;
  padding: .9rem !important;
  font-weight: 700 !important;
  border: 0 !important;
}

/* Ensure all buttons have consistent rounded corners and padding */
.non-home-dark button {
  border-radius: 6px !important;
  padding: 8px 16px !important;
}

/* Specific override for arrow buttons to maintain their compact size */
.non-home-dark .arrow-btn {
  background: #4f46e5 !important;
  color: white !important;
  border-radius: 4px !important;
  width: 32px !important;
  height: 32px !important;
  padding: 0 !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
}

/* Ensure all white background elements become dark */
.non-home-dark [style*="background: white"],
.non-home-dark [style*="background:#fff"],
.non-home-dark [style*="background: #fff"],
.non-home-dark [style*="background-color: white"],
.non-home-dark [style*="background-color: #fff"] {
  background: #1f2937 !important;
  color: #e6eaf2 !important;
}

/* Dark text only for content & page header, not the site header */
.non-home-dark :where(main, .ww-header) *:not(button):not(.btn) {
  color: #e6eaf2 !important;
}

/* Ensure the content canvas itself is dark */
.non-home-dark :where(main, .ww-header) {
  background: var(--page-bg-dark) !important;  /* #0b1220 */
}

/* Inherit backgrounds inside content/page header only (not the site header) */
.non-home-dark :where(main, .ww-header),
.non-home-dark :where(main, .ww-header) * {
  background-color: inherit !important;
}

/* Borders for content/page header only */
.non-home-dark :where(main, .ww-header) * {
  border-color: #374151 !important;
}


.non-home-dark .form-section,
.non-home-dark .calculator-card,
.non-home-dark .flashcard,
.non-home-dark .card,
.non-home-dark .breakdown-section,
.non-home-dark div[class*="card"],
.non-home-dark div[class*="breakdown"],
.non-home-dark div[class*="result"] {
  background: #1f2937 !important;
  color: #e6eaf2 !important;
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
  height: 137px;  /* increased navbar height to cover logo */
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
  width: 48px !important; 
  height: 48px !important;
  min-width: 48px;
  min-height: 48px;
  border: 1px solid currentColor; 
  border-radius: 8px;
  background: transparent; 
  color: currentColor; 
  opacity: .85;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.menu-toggle:hover {
  opacity: 1;
  background: rgba(0,0,0,0.05);
}

.menu-toggle:active {
  transform: scale(0.95);
  background: rgba(0,0,0,0.1);
}

.header.theme-slate .menu-toggle {
  width: 48px !important; 
  height: 48px !important;
  min-width: 48px;
  min-height: 48px;
  border: 1px solid currentColor; 
  border-radius: 8px;
  background: transparent; 
  color: currentColor; 
  opacity: .85;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.header.theme-slate .menu-toggle:hover {
  opacity: 1;
  background: rgba(255,255,255,0.1);
}

.header.theme-slate .menu-toggle:active {
  transform: scale(0.95);
  background: rgba(255,255,255,0.15);
}

@media (max-width: 1200px) {
  .menu-toggle { display: inline-flex; align-items: center; justify-content: center; }

  /* Use dynamic header height for the dropdown top edge */
  .nav-links {
    position: fixed; left: 0; right: 0; top: var(--header-height, 72px);
    display: none;
    flex-direction: column; align-items: flex-start;
    gap: 12px; padding: 20px 16px;
    background: rgba(255,255,255,0.98);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    box-shadow: 0 8px 32px rgba(0,0,0,.15);
    border-bottom: 1px solid rgba(0,0,0,0.1);
    z-index: 100;
    max-height: calc(100vh - var(--header-height, 72px));
    overflow-y: auto;
  }
  .nav-links.open { display: flex; }

  .header.theme-slate .nav-links {
    background: rgba(3, 9, 17,0.98);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    box-shadow: 0 8px 32px rgba(0,0,0,.3);
    border-bottom: 1px solid rgba(255,255,255,0.1);
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

@media (max-width: 1200px) {
  .header .nav-links {
    background: rgba(255,255,255,0.98) !important;
    border-bottom: 1px solid rgba(0,0,0,0.1) !important;
  }
  .header.theme-slate .nav-links {
    background: rgba(3,9,17,0.98) !important;
    border-bottom: 1px solid rgba(255,255,255,0.1) !important;
  }
}

/* === Lock hamburger size across themes/routes on mobile widths === */
@media (max-width: 1200px) {
  .header .menu-toggle {
    --menu-size: 48px;
    --icon-size: 24px;

    width: var(--menu-size) !important;
    height: var(--menu-size) !important;
    min-width: var(--menu-size);
    min-height: var(--menu-size);
    padding: 0 !important;          /* neutralize any global button padding */
    box-sizing: border-box;          /* padding/border won't change size */
    display: inline-flex;
    align-items: center;
    justify-content: center;
    line-height: 0;
  }
  .header .menu-toggle svg {
    width: var(--icon-size);
    height: var(--icon-size);
    flex: none;
  }
}

</style>
