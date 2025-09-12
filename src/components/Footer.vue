<template>
  <footer class="footer" role="contentinfo">
    <div class="footer-content">
      <div class="footer-large-logo" @click="goHome" style="cursor:pointer">
        <img :src="logoSrc" alt="WealthWave" class="footer-logo-image">
      </div>
      
      <nav class="footer-links" aria-label="Footer">
        <!-- All links route to home -->
        <a href="#" @click.prevent="goHome">About</a>
        <a href="#" @click.prevent="goHome">Contact</a>
        <a href="#" @click.prevent="goHome">Privacy</a>
      </nav>
    </div>
  </footer>
</template>

<script setup>
import { inject, ref, computed, onMounted, onBeforeUnmount } from 'vue'

const navigateTo = inject('navigateTo')
const goHome = () => navigateTo('home')

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
  z-index: 0;
  margin-top: auto;
  padding: 16px 0;
  height: 120px;
  display: flex;
  align-items: center;
  background: transparent;          /* glass is drawn by ::before */
  flex-shrink: 0;
}

.footer-large-logo {
  display: flex;
  justify-content: center;
  align-items: center;
}

.footer-logo-image {
  max-width: 120px;
  max-height: 80px;
  width: clamp(80px, 12vw, 120px);
  height: auto;
  object-fit: contain;
  transition: transform 0.2s ease;
}

.footer-logo-image:hover {
  transform: scale(1.05);
}

/* Simple background layer - consistent across all pages */
.footer::before {
  content: "";
  position: absolute; inset: 0;
  z-index: -1;
  background: #ffffff !important;                       /* solid white background for complete consistency */
  border-top: 1px solid #E5E7EB !important;
  box-shadow: 0 -1px 3px rgba(0,0,0,0.1) !important;
}

/* Center everything */
.footer-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
}

/* Brand */
.footer-brand {
  display: flex;
  align-items: center;
  gap: 8px;
}
.logo-mark { width: 24px; height: 24px; }
.logo-text { font-weight: 700; font-size: 18px; color: #111827; }   /* stronger contrast */

/* Links */
.footer-links {
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
  justify-content: center;
  padding-bottom: 20px;
}
.footer-links a {
  color: #374151;                     /* darker than muted for legibility */
  text-decoration: none;
  font-size: 14px;
  font-weight: 500;
  transition: color .2s ease;
}
.footer-links a:hover { color: var(--primary-color); }
.footer-links a:focus-visible {
  outline: none;
  box-shadow: 0 0 0 2px var(--primary-color);
  border-radius: 6px;
  padding: 2px 4px;
}

/* Small screens */
@media (max-width: 480px) {
  .footer-links { gap: 16px; }
}

/* Dark mode for all pages - consistent across home and other pages */
@media (prefers-color-scheme: dark) {
  .footer::before {
    background: #111827 !important;                      /* solid dark background for complete consistency */
    border-top: 1px solid rgba(255,255,255,.15) !important;
    box-shadow: 0 -1px 3px rgba(0,0,0,0.2) !important;
  }
  .logo-text { color: #e5e7eb; }
  .footer-links a { color: #e5e7eb; }
  .footer-links a:hover { color: #c7d2fe; }
}
</style>
