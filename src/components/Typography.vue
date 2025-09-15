<template>
  <component :is="tag" :class="classes">
    <slot />
  </component>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  variant: {
    type: String,
    default: 'subtitle' // 'main' | 'subtitle'
  },
  tag: {
    type: String,
    default: 'p' // h1 for main, p for subtitle (as you use)
  }
})

const classes = computed(() => (props.variant === 'main' ? 'main-title' : 'subtitle'))
</script>

<style scoped>
.main-title {
  font-size: 1.5rem;      /* ~24px - increased for better visibility */
  font-weight: 700;
  color: var(--text-primary);      /* THEME TOKEN */
  line-height: 1.2;      /* tighter line height */
  margin-bottom: 0.1rem;  /* very minimal margin */
  text-align: inherit;             /* inherit alignment from parent (center/left) */
}

.subtitle {
  font-size: 1.1rem;      /* ~18px - increased for better visibility */
  color: #333333;         /* Dark gray for better readability in light mode */
  line-height: 1.4;      /* tighter line height */
  font-weight: 400;
  margin-top: 0.05rem;    /* ultra minimal margin */
  margin-bottom: 0.1rem;  /* ultra minimal margin */
  text-align: inherit;             /* inherit alignment from parent */
}

/* Dark mode override */
:global(.non-home-dark) .subtitle {
  color: var(--text-secondary);    /* Use theme token in dark mode */
}
</style>
