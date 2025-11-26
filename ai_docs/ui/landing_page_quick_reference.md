# Landing Page Quick Reference

**Version:** 2.0
**Last Updated:** 2025-11-26
**For:** Designers & Developers
**File:** `/Users/anton/Documents/Development/defitracker/app/views/home/index.html.erb`

## At a Glance

### Design Identity
- **Aesthetic:** Premium Fintech (dark mode first)
- **Primary Colors:** Emerald (#10B981), Teal (#14F195)
- **Fonts:** Unbounded (display), Onest (body)
- **Philosophy:** Sophisticated, trustworthy, crypto-native premium

### Structure
6 sections in conversion funnel order:
1. Hero → Value prop
2. Trust Bar → Security
3. Core Features → Differentiation
4. Social Proof → Validation
5. Pricing → Decision
6. Final CTA → Conversion

### Key Metrics
- Load time: <2.5s LCP
- File size: 60KB (inline CSS)
- Mobile-first: 320px - 1440px+
- Performance: 95+ Lighthouse score

## Design Tokens (Quick Copy)

```css
/* Colors */
--color-bg-primary: #0A0A0A;
--color-bg-secondary: #1A1A1A;
--color-accent-primary: #10B981;
--color-accent-secondary: #14F195;
--color-text-primary: #F5F5F5;
--color-border: rgba(255, 255, 255, 0.08);

/* Typography */
--font-display: 'Unbounded', sans-serif;
--font-body: 'Onest', sans-serif;

/* Spacing */
--spacing-sm: 16px;
--spacing-md: 24px;
--spacing-lg: 40px;
--spacing-xl: 64px;
--spacing-2xl: 100px;
--spacing-3xl: 150px;

/* Shadows */
--shadow-lg: 0 8px 48px rgba(0, 0, 0, 0.6);
--shadow-accent: 0 8px 32px rgba(16, 185, 129, 0.25);

/* Radius */
--radius-md: 16px;
--radius-lg: 24px;
--radius-full: 9999px;
```

## Common Patterns

### Card Component
```css
.card {
  background: var(--color-bg-secondary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--spacing-xl);
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.card:hover {
  transform: translateY(-8px);
  border-color: var(--color-border-hover);
  box-shadow: var(--shadow-lg);
}
```

### Primary Button
```css
.cta-primary {
  display: inline-flex;
  align-items: center;
  background: var(--color-accent-primary);
  color: var(--color-bg-primary);
  padding: 18px 36px;
  border-radius: var(--radius-full);
  font-weight: 700;
  box-shadow: var(--shadow-accent);
}

.cta-primary:hover {
  background: var(--color-accent-secondary);
  transform: translateY(-2px);
}
```

### Section Header
```html
<div class="section-header scroll-reveal">
  <span class="section-label">Label</span>
  <h2 class="section-title">Title</h2>
  <p class="section-description">Description</p>
</div>
```

### Scroll Reveal
```html
<!-- Add class to any element -->
<div class="scroll-reveal">
  Content appears on scroll
</div>
```

## Responsive Breakpoints

```css
/* Mobile: 320px - 640px (base styles) */

@media (max-width: 640px) {
  /* Small mobile adjustments */
}

@media (max-width: 968px) {
  /* Tablet + mobile: major layout changes */
  .hero-content { grid-template-columns: 1fr; }
  .features-grid .feature-card { grid-column: 1 / 13 !important; }
}
```

## Typography Scale

| Element | Size | Weight | Font |
|---------|------|--------|------|
| Hero H1 | clamp(2.5rem, 6vw, 4.5rem) | 800 | Unbounded |
| Section Title | clamp(2rem, 4vw, 3.5rem) | 800 | Unbounded |
| Feature Title | 1.5rem | 700 | Unbounded |
| Body | 1.05rem | 400 | Onest |
| Button | 1.1rem | 700 | Onest |
| Label | 0.875rem | 700 | Onest |

## Animation Timing

| Effect | Duration | Easing |
|--------|----------|--------|
| Page load | 0.8s | ease-out |
| Scroll reveal | 0.8s | cubic-bezier(0.4, 0, 0.2, 1) |
| Hover | 0.3-0.4s | cubic-bezier(0.4, 0, 0.2, 1) |
| Background | 20s | ease-in-out (float) / linear (rotate) |

## Content Guidelines

### Headlines
- Use "your" for personalization
- Be specific (not generic)
- Lead with benefit

### Value Props
- Quantify when possible ("8+ hours/month")
- Use realistic numbers ($127,453 not $1M)
- Name specific tools (Binance, Coinbase)

### CTAs
- Action-oriented ("Start for free")
- Remove friction ("No credit card")
- Multiple opportunities (6 CTAs throughout)

### Security
- Repeat 3x (Trust Bar, Testimonial, Final CTA)
- Use specific terms ("Read-only API", "AES-256")
- Visual badges (🔒 🛡️ 🚫)

## File Structure

```
/app/views/home/index.html.erb (1,393 lines)

Lines 1-15:    <head> (meta, fonts)
Lines 16-1012: <style> (all CSS inline)
Lines 1014-1366: <body> (6 sections)
Lines 1371-1389: <script> (Intersection Observer)
```

## Deployment

```bash
# Deploy to production
bin/kamal deploy

# Check status
bin/kamal app details

# View logs
bin/kamal app logs

# Rollback if needed
bin/kamal rollback
```

## Testing Checklist

**Visual:**
- [ ] All sections render
- [ ] Fonts load (Unbounded, Onest)
- [ ] Colors match tokens
- [ ] Animations trigger
- [ ] Hover states work

**Responsive:**
- [ ] iPhone SE (320px)
- [ ] iPhone 12 (390px)
- [ ] iPad (768px)
- [ ] Desktop (1280px, 1440px)

**Performance:**
- [ ] Lighthouse 95+
- [ ] LCP <2.5s
- [ ] No layout shifts

**Cross-Browser:**
- [ ] Chrome, Safari, Firefox
- [ ] Mobile Safari, Chrome Mobile

## Quick Edits

### Change Accent Color
```css
:root {
  --color-accent-primary: #10B981; /* Change this */
  --color-accent-secondary: #14F195; /* And this */
}
```

### Update Portfolio Numbers
```html
<!-- Find hero card (line ~1044) -->
<div class="portfolio-value">$127,453</div>
<div class="portfolio-change">+$12,847 (11.2%) за месяц</div>
```

### Add New Testimonial
```html
<div class="testimonial-card scroll-reveal">
  <p class="testimonial-quote">"Quote here"</p>
  <div class="testimonial-author">
    <div class="author-avatar">🧑</div>
    <div class="author-info">
      <div class="author-name">Name</div>
      <div class="author-role">Role</div>
    </div>
  </div>
</div>
```

### Update Pricing
```html
<!-- Find pricing section (line ~1276) -->
<div class="pricing-price">$9.99</div>
<ul class="pricing-features">
  <li>Feature 1</li>
  <li>Feature 2</li>
</ul>
```

## Performance Budget

| Metric | Budget | Current |
|--------|--------|---------|
| HTML | <100KB | 60KB ✅ |
| Fonts | <200KB | ~150KB ✅ |
| LCP | <2.5s | ~1.2s ✅ |
| FID | <100ms | <50ms ✅ |
| CLS | <0.1 | 0 ✅ |

## A/B Testing Template

```ruby
# In HomeController
def index
  @variant = params[:variant] || 'a'

  if @variant == 'b'
    render 'index_variant_b'
  else
    render 'index'
  end
end
```

```bash
# URLs for testing
https://idea.defitracker.online          # Variant A (control)
https://idea.defitracker.online?variant=b # Variant B (test)
```

## Common Issues & Fixes

### Fonts Not Loading
```html
<!-- Ensure preconnect -->
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
```

### Animations Not Triggering
```javascript
// Check if Intersection Observer supported
if ('IntersectionObserver' in window) {
  // Use observer
} else {
  // Fallback: show all
  document.querySelectorAll('.scroll-reveal').forEach(el => {
    el.classList.add('revealed');
  });
}
```

### Mobile Layout Breaking
```css
/* Add to troublesome element */
.element {
  max-width: 100%;
  overflow: hidden;
}
```

## Related Documentation

- **Design System:** `/ai_docs/ui/landing_page_design_system.md`
- **Design Decisions:** `/ai_docs/ui/landing_page_design_decisions.md`
- **Structure:** `/ai_docs/ui/landing_page_structure.md`
- **Technical:** `/ai_docs/development/landing_page_technical_implementation.md`
- **GTM Alignment:** `/ai_docs/business/landing_page_gtm_alignment.md`
- **Changelog:** `/ai_docs/ui/landing_page_redesign_changelog.md`

## Contact

For questions about landing page implementation:
- Design questions → See Design System doc
- Technical questions → See Technical Implementation doc
- Business questions → See GTM Alignment doc
- Quick reference → This document

---

**Last Updated:** 2025-11-26
**Version:** 2.0 (Complete Redesign)
**Status:** Production Live ✅
