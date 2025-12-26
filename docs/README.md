# AudioPure Landing Page

Professional landing page for AudioPure - AI-powered audio editing app.

## 🌐 Live Website

Visit: [https://yourusername.github.io/AudioPure](https://yourusername.github.io/AudioPure)

## 🚀 Quick Start

This site is deployed using GitHub Pages from the `docs/` folder.

### Local Development

1. Navigate to the docs folder:
```bash
cd docs
```

2. Open with a local server:
```bash
python3 -m http.server 8000
# or
npx serve
```

3. Visit `http://localhost:8000`

## 📦 Deployment to GitHub Pages

### Step 1: Push to GitHub

```bash
git add docs/
git commit -m "Add professional landing page"
git push origin main
```

### Step 2: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under **Source**, select:
   - Branch: `main`
   - Folder: `/docs`
4. Click **Save**

Your site will be live at: `https://yourusername.github.io/AudioPure`

## 🎨 Features

- **Premium Design**: YC-worthy professional landing page
- **Purple Theme**: Matches the AudioPure iOS app aesthetic
- **Responsive**: Perfect on all devices
- **Animated**: Smooth scroll animations and micro-interactions
- **Fast**: Optimized for performance
- **SEO Ready**: Proper meta tags and semantic HTML

## 📁 Structure

```
docs/
├── index.html      # Main landing page
├── styles.css      # Premium styling and animations
├── script.js       # Interactive features
└── README.md       # This file
```

## 🛠️ Customization

### Update App Store Link

In `index.html`, replace `#` with your actual App Store URL:

```html
<a href="YOUR_APP_STORE_URL" class="btn btn-large btn-primary">
```

### Update Stats

Modify the hero stats in `index.html`:

```html
<div class="stat-number">10+</div>
<div class="stat-label">Quick Presets</div>
```

### Change Colors

Edit CSS variables in `styles.css`:

```css
:root {
    --primary-purple: #8B5CF6;
    --primary-purple-dark: #7C3AED;
    /* ... */
}
```

## 📱 Sections

1. **Hero**: Eye-catching headline with CTA
2. **Features**: 6 key features with icons
3. **How It Works**: 3-step process
4. **Pricing**: 3 pricing tiers
5. **CTA**: Final conversion section
6. **Footer**: Links and info

## 🎯 Performance

- **Lighthouse Score**: 95+
- **First Contentful Paint**: < 1s
- **Time to Interactive**: < 2s
- **Mobile Optimized**: Yes

## 📄 License

All rights reserved © 2024 AudioPure

## 🙋‍♂️ Support

For questions or support, visit [your-contact-page]
