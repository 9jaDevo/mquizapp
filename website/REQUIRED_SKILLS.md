# mQuiz Website - Required Skills & Technologies

## 🎯 Core Competencies Required

### 1. Frontend Development
- **React 18+** - Functional components, hooks, context, performance optimization
- **TypeScript** - Type safety, interfaces, generics, utility types
- **Vite** - Build tool configuration, dev server optimization

### 2. Styling & Design
- **Tailwind CSS 4.0** - Utility-first CSS, custom configurations, responsive design
- **CSS3** - Backdrop filters, gradients, shadows, transforms, animations
- **Glassmorphism** - Frosted glass effects, blur, transparency, layering
- **Responsive Design** - Mobile-first approach, breakpoints, fluid layouts

### 3. Animation
- **Framer Motion** - Complex animations, variants, gestures, scroll-triggered effects
- **CSS Animations** - Keyframes, transitions, transforms
- **3D Effects** - Perspective, rotation, depth

### 4. Routing
- **React Router v6** - BrowserRouter, nested routes, dynamic routes, navigation

### 5. SEO Expertise
- **Meta Tags** - Title, description, keywords optimization
- **Open Graph** - Social media previews
- **Structured Data** - JSON-LD, schema.org markup
- **Sitemap Generation** - XML sitemap creation
- **Performance** - Core Web Vitals, Lighthouse optimization

### 6. Content Management
- **MDX** - Markdown + React components for blog
- **Frontmatter** - Metadata parsing
- **Syntax Highlighting** - Code block styling
- **Content Organization** - File-based CMS approach

### 7. Form Handling
- **React Hook Form** - Form state management
- **Zod** - Schema validation
- **Email Integration** - EmailJS or similar service

### 8. State Management
- **React Context** - Global state (theme, user preferences)
- **Local Storage** - Persistence
- **Custom Hooks** - Reusable logic

### 9. Performance Optimization
- **Code Splitting** - React.lazy, dynamic imports
- **Image Optimization** - WebP, lazy loading, responsive images
- **Bundle Optimization** - Tree shaking, minification
- **Caching Strategies** - Service workers, CDN

### 10. Accessibility
- **WCAG 2.1 AA** - Semantic HTML, ARIA labels, keyboard navigation
- **Screen Reader Support** - Proper markup and descriptions

## 🛠️ Technical Stack

```json
{
  "framework": "React 18.3+",
  "language": "TypeScript 5+",
  "buildTool": "Vite 5+",
  "styling": "Tailwind CSS 4.0",
  "animation": "Framer Motion 11+",
  "routing": "React Router 6+",
  "forms": "React Hook Form + Zod",
  "seo": "React Helmet Async",
  "blog": "MDX + Remark/Rehype",
  "icons": "Lucide React",
  "deployment": "Vercel/Netlify"
}
```

## 📚 Knowledge Areas

### Design Patterns
- Component composition
- Render props
- Higher-order components
- Custom hooks
- Context providers
- Compound components

### Best Practices
- DRY (Don't Repeat Yourself)
- SOLID principles
- Clean code
- Performance optimization
- SEO best practices
- Accessibility standards

### Web Standards
- HTML5 semantic elements
- CSS Grid & Flexbox
- ES6+ JavaScript features
- Web APIs (Intersection Observer, etc.)
- Progressive Web Apps (PWA)

## 🎨 Design Skills

### UI/UX Principles
- Visual hierarchy
- White space usage
- Color theory
- Typography
- Consistency
- User flow

### Modern Design Trends
- Glassmorphism
- Neomorphism (optional)
- Gradient overlays
- Micro-interactions
- Smooth animations
- Dark mode design

## 🚀 Development Workflow

### Version Control
- Git basics
- Commit conventions
- Branch management

### Testing
- Component testing (optional but recommended)
- E2E testing basics
- Browser testing

### Debugging
- Browser DevTools
- React DevTools
- Performance profiling
- Network analysis

### Deployment
- Vercel/Netlify deployment
- Environment variables
- Custom domain setup
- SSL/HTTPS configuration

## 📊 SEO & Marketing Skills

### On-Page SEO
- Keyword research
- Meta tag optimization
- Heading hierarchy
- Internal linking
- Image optimization
- URL structure

### Technical SEO
- Sitemap creation
- Robots.txt
- Structured data
- Canonical URLs
- Mobile optimization
- Page speed

### Analytics
- Google Analytics 4 setup
- Event tracking
- Goal configuration
- Performance monitoring

## 🔧 Tools & Libraries

### Development Tools
- VS Code (or similar IDE)
- Git
- npm/yarn
- Browser DevTools

### Key Libraries
```
react, react-dom
react-router-dom
tailwindcss
framer-motion
react-helmet-async
react-hook-form
zod
lucide-react
@mdx-js/rollup
gray-matter
reading-time
remark-gfm
rehype-highlight
date-fns
emailjs-com
```

### Deployment Platforms
- Vercel (recommended)
- Netlify
- GitHub Pages (with workarounds)

## 🎯 Specific Implementation Skills

### Glassmorphism Implementation
```css
/* Must know how to implement */
backdrop-filter: blur(20px);
background: rgba(255, 255, 255, 0.1);
border: 1px solid rgba(255, 255, 255, 0.2);
box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
```

### Framer Motion Animations
```typescript
// Must understand variants, transitions, gestures
<motion.div
  initial={{ opacity: 0, y: 60 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.6 }}
  whileHover={{ scale: 1.05 }}
/>
```

### SEO Implementation
```typescript
// Must implement proper meta tags
<Helmet>
  <title>Page Title - mQuiz</title>
  <meta name="description" content="..." />
  <meta property="og:title" content="..." />
  <script type="application/ld+json">
    {JSON.stringify(structuredData)}
  </script>
</Helmet>
```

### MDX Blog Setup
```typescript
// Must configure MDX with plugins
import { MDXProvider } from '@mdx-js/react';
import remarkGfm from 'remark-gfm';
import rehypeHighlight from 'rehype-highlight';
```

### Responsive Design
```typescript
// Must implement mobile-first responsive design
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4">
  {/* Cards */}
</div>
```

## 📖 Learning Resources

### Documentation
- React: https://react.dev
- TypeScript: https://www.typescriptlang.org
- Tailwind CSS: https://tailwindcss.com
- Framer Motion: https://www.framer.com/motion
- React Router: https://reactrouter.com

### SEO Resources
- Google Search Central: https://developers.google.com/search
- Schema.org: https://schema.org
- Web.dev: https://web.dev

### Design Inspiration
- Dribbble: https://dribbble.com
- Awwwards: https://awwwards.com
- CSS Design Awards: https://cssdesignawards.com

## ✅ Skill Checklist

Before starting, ensure proficiency in:
- [ ] React functional components and hooks
- [ ] TypeScript basics and type safety
- [ ] Tailwind CSS utility classes
- [ ] CSS backdrop-filter and glassmorphism
- [ ] Framer Motion animation basics
- [ ] React Router navigation
- [ ] Responsive design principles
- [ ] SEO meta tags and structured data
- [ ] MDX and markdown
- [ ] Form handling and validation
- [ ] Git version control
- [ ] Vercel/Netlify deployment

## 🎓 Recommended Expertise Level

**Minimum:** Intermediate to Advanced
**Ideal:** Advanced with production experience

### Beginner-Friendly Aspects
- Basic component structure
- Tailwind utility classes
- Simple animations

### Advanced Requirements
- Complex Framer Motion animations
- SEO structured data implementation
- MDX configuration
- Performance optimization
- Accessibility compliance

## 🚀 Success Criteria

The coding agent should be able to:
1. Set up a modern React + TypeScript + Vite project
2. Configure Tailwind with custom utilities
3. Create reusable glassmorphic components
4. Implement smooth animations with Framer Motion
5. Build SEO-optimized pages with proper meta tags
6. Set up MDX-based blog with syntax highlighting
7. Ensure mobile responsiveness across all pages
8. Implement dark mode with theme switching
9. Create accessible UI components
10. Deploy to Vercel with optimal configuration

---

**Note:** This is a complex project requiring strong frontend development skills, particularly in React, TypeScript, modern CSS, animation, and SEO. The coding agent should have experience building production-ready web applications with similar requirements.
