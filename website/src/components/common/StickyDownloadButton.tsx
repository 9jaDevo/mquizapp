import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';
import { Download, Smartphone } from 'lucide-react';

const StickyDownloadButton: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const location = useLocation();
  const isDownloadPage = location.pathname === '/download';

  // Show after user scrolls 120px
  useEffect(() => {
    if (isDownloadPage) return;
    const onScroll = () => setVisible(window.scrollY > 120);
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
    return () => window.removeEventListener('scroll', onScroll);
  }, [isDownloadPage]);

  // Don't show on the download page itself
  if (isDownloadPage) return null;

  return (
    <AnimatePresence>
      {visible && (
        <motion.div
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 100, opacity: 0 }}
          transition={{ type: 'spring', stiffness: 300, damping: 30 }}
          className="fixed bottom-5 left-1/2 -translate-x-1/2 z-50 md:left-auto md:right-6 md:translate-x-0"
        >
          <Link
            to="/download"
            className="
              group flex items-center gap-2.5
              px-5 py-3 rounded-2xl
              bg-gradient-to-r from-blue-600 to-purple-600
              text-white font-semibold text-sm
              shadow-lg shadow-blue-500/40
              hover:shadow-xl hover:shadow-purple-500/40
              hover:scale-105
              transition-all duration-300
              border border-white/20
              backdrop-blur-md
              whitespace-nowrap
            "
            aria-label="Download mQuiz App"
          >
            {/* Mobile icon — shows on all screens */}
            <span className="flex items-center justify-center w-7 h-7 rounded-full bg-white/20 group-hover:bg-white/30 transition-colors duration-200">
              <Smartphone size={15} className="stroke-[2.5]" />
            </span>

            <span className="flex flex-col leading-tight">
              <span className="text-white/75 text-[10px] font-normal uppercase tracking-wider">
                Get the App
              </span>
              <span>Download mQuiz</span>
            </span>

            <Download size={15} className="ml-1 group-hover:translate-y-0.5 transition-transform duration-200 stroke-[2.5]" />

            {/* Subtle animated ping to attract attention */}
            <span className="absolute -top-1 -right-1 flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-purple-400 opacity-75" />
              <span className="relative inline-flex rounded-full h-3 w-3 bg-purple-500" />
            </span>
          </Link>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default StickyDownloadButton;
