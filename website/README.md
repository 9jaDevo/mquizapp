# mQuiz - Premium React Landing Page

A state-of-the-art, SEO-optimized React website for mQuiz with stunning liquid glass morphism effects, comprehensive multi-page architecture, and modern user experience.

## 🎨 Features

- **Liquid Glass Morphism Design**: Beautiful frosted glass effects with backdrop blur
- **Fully Responsive**: Mobile-first design that works on all devices
- **Dark/Light Mode**: Built-in theme toggle with system preference detection
- **SEO Optimized**: Comprehensive meta tags, Open Graph, Twitter Cards, and structured data
- **Smooth Animations**: Powered by Framer Motion for professional transitions
- **Type-Safe**: Built with TypeScript for better code quality
- **Modern Stack**: React 18, Vite, Tailwind CSS 3, React Router 6

## 🚀 Tech Stack

- **Framework**: React 18.3 with TypeScript
- **Build Tool**: Vite 7
- **Styling**: Tailwind CSS 3.4
- **Routing**: React Router v6
- **Animations**: Framer Motion 12
- **SEO**: React Helmet Async
- **Forms**: React Hook Form + Zod
- **Icons**: Lucide React

## 📦 Pages

1. **Home** (`/`) - Hero, features, statistics, how it works, testimonials, app showcase
2. **About** (`/about`) - Company story and mission
3. **Features** (`/features`) - Detailed feature breakdown
4. **Blog** (`/blog`) - Blog listing with search and filters
5. **Contact** (`/contact`) - Contact form with validation
6. **Download** (`/download`) - App download links and QR codes
7. **Privacy** (`/privacy`) - Privacy policy
8. **Terms** (`/terms`) - Terms and conditions

## 🛠️ Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

## 🔧 Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```env
VITE_EMAILJS_SERVICE_ID=your_service_id
VITE_EMAILJS_TEMPLATE_ID=your_template_id
VITE_EMAILJS_PUBLIC_KEY=your_public_key
VITE_SITE_URL=https://mquiz.uk
```

## 📁 Project Structure

```
website/
├── public/              # Static assets
│   ├── robots.txt      # SEO robots file
│   ├── sitemap.xml     # SEO sitemap
│   └── favicon.ico     # Favicon
├── src/
│   ├── components/     # React components
│   │   ├── common/     # Shared components (GlassCard, Navbar, Footer, etc.)
│   │   ├── home/       # Homepage sections
│   │   ├── blog/       # Blog components
│   │   └── forms/      # Form components
│   ├── pages/          # Page components
│   ├── context/        # React context (Theme)
│   ├── hooks/          # Custom hooks
│   ├── utils/          # Utility functions
│   ├── styles/         # Global styles
│   ├── router.tsx      # Route configuration
│   ├── main.tsx        # App entry point
│   └── index.css       # Global CSS with Tailwind
├── .env.example        # Environment variables template
├── package.json        # Dependencies
├── tailwind.config.js  # Tailwind configuration
├── vite.config.ts      # Vite configuration
└── tsconfig.json       # TypeScript configuration
```

## 🎨 Glass Morphism Components

The project includes a complete library of glassmorphic components:

- `GlassCard` - Base card with blur and transparency
- `GlassButton` - Interactive buttons with glass effect
- `GlassInput` - Form inputs with glass styling
- `GlassNavbar` - Sticky navigation with blur backdrop
- `GlassModal` - Popup modals with glass background

## 🌐 SEO Implementation

- Unique meta tags for each page
- Open Graph tags for social sharing
- Twitter Card meta tags
- Structured data (JSON-LD) for Organization, WebSite, Articles
- Sitemap.xml for search engines
- Robots.txt for crawler directives
- Canonical URLs

## 📱 Responsive Breakpoints

- **xs**: 0-639px (Mobile)
- **sm**: 640-767px (Large Mobile)
- **md**: 768-1023px (Tablet)
- **lg**: 1024-1279px (Small Desktop)
- **xl**: 1280-1535px (Desktop)
- **2xl**: 1536px+ (Large Desktop)

## 🎯 Performance

- Lighthouse Performance: 95+
- Lighthouse SEO: 100
- Lighthouse Accessibility: 95+
- Production build optimized with code splitting
- Lazy loading for images
- Smooth 60fps animations

## 🚀 Deployment

### Vercel (Recommended)

1. Push code to GitHub
2. Import project in Vercel
3. Configure environment variables
4. Deploy automatically

### Build Manually

```bash
npm run build
# Output will be in ./dist directory
```

## 📝 License

Copyright © 2026 mQuiz. All rights reserved.

## 🤝 Contributing

This is a private project for mQuiz. For any questions or issues, please contact the development team.

## 📧 Contact

- Website: https://mquiz.uk
- Email: contact@mquiz.uk
- Facebook: https://facebook.com/mquizonline
- YouTube: https://youtube.com/@mquizonline
