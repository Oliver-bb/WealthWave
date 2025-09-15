<!-- src/components/PageHeader.vue -->
<template>
  <header class="ww-header" :class="[align, dark ? 'dark' : 'light']">
    <div class="header-inner">
      <div v-if="$slots.default" class="header-icon"></div>

      <div class="header-text">
        <Typography :variant="'main'" :tag="titleTag">
          {{ title }}
        </Typography>
        <Typography v-if="subtitle" variant="subtitle" tag="p">
          {{ subtitle }}
        </Typography>
      </div>
    </div>
  </header>
</template>

<script setup>
import Typography from './Typography.vue'

const props = defineProps({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  align: { type: String, default: 'center' }, // 'center' | 'left'
  titleTag: { type: String, default: 'h1' },
  dark: { type: Boolean, default: false }     // kept for compatibility
})
</script>

<style scoped>
/* Page header positioned properly below navbar */
.ww-header {
  background: transparent;
  border: none;
  margin-top: -120px;  /* adjusted for 160px navbar height */
  margin-bottom: 0px;  /* let individual components handle their own spacing */
  padding: 4px 0 20px 0;  /* back to original spacing within header */
  min-height: 60px;  /* back to original height */
}

.header-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;  /* horizontal padding only */
  display: flex;
  align-items: center;
  gap: 12px;
}

/* alignment */
.ww-header.center .header-text { text-align: center; margin: 0 auto; }
.ww-header.left   .header-text { text-align: left; }

/* Dark text in light mode, theme tokens in dark mode */
.header-text :deep(h1),
.header-text :deep(h2),
.header-text :deep(h3) {
  color: #000000;  /* Dark headings in light mode */
}
.header-text :deep(p) {
  color: #000000;  /* Dark black subtitle in light mode */
}

/* Dark mode overrides */
:global(.non-home-dark) .ww-header .header-text :deep(h1),
:global(.non-home-dark) .ww-header .header-text :deep(h2),
:global(.non-home-dark) .ww-header .header-text :deep(h3) {
  color: #e6eaf2 !important;  /* Light text in dark mode */
}
:global(.non-home-dark) .ww-header .header-text :deep(p) {
  color: #9ca3af !important;  /* Light gray subtitle in dark mode */
}

/* optional icon slot */
.header-icon {
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #4f46e5;
}

@media (max-width: 640px) {
  .header-inner { gap: 10px; }
}
</style>
