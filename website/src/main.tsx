import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { RouterProvider } from 'react-router-dom'
import { HelmetProvider } from 'react-helmet-async'
import { ThemeProvider } from './context/ThemeContext'
import Analytics from './components/common/Analytics'
import { router } from './router'
import './index.css'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <HelmetProvider>
      <ThemeProvider>
        <Analytics 
          gaTrackingId={import.meta.env.VITE_GA_TRACKING_ID}
          botTrackingId={import.meta.env.VITE_GA_BOT_PROPERTY_ID}
          enableBotTracking={import.meta.env.VITE_GA_ENABLE_BOT_TRACKING === 'true'}
          enableCoreWebVitals={import.meta.env.VITE_ANALYTICS_ENABLE_CORE_WEB_VITALS === 'true'}
          debug={import.meta.env.DEV}
        />
        <RouterProvider router={router} />
      </ThemeProvider>
    </HelmetProvider>
  </StrictMode>,
)
