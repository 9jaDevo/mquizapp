import React, { useState, useRef } from 'react';
import { detectBot } from '../../utils/botDetection';

interface SmartImageProps {
  src: string;
  alt: string;
  className?: string;
  priority?: boolean; // Force eager loading
  onLoad?: () => void;
  srcSet?: string;
  sizes?: string;
}

/**
 * SmartImage Component
 * Adaptive image loading based on bot detection
 * 
 * - Bots: eager loading with sync decoding for immediate indexing
 * - Humans: lazy loading with async decoding for better performance
 */
const SmartImage: React.FC<SmartImageProps> = ({
  src,
  alt,
  className = '',
  priority = false,
  onLoad,
  srcSet,
  sizes,
}) => {
  const [isLoaded, setIsLoaded] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  const botDetection = detectBot();
  const isBot = botDetection.isBot || priority;

  // Determine loading strategy
  const loading = isBot ? 'eager' : 'lazy';
  const decoding = isBot ? 'sync' : 'async';

  // Handle image load event
  const handleLoad = () => {
    setIsLoaded(true);
    if (onLoad) {
      onLoad();
    }

    // Log image visibility for analytics (humans only)
    if (!isBot && imgRef.current) {
      const observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              // Image is visible - could track engagement
              (window as any).__IMAGE_VISIBLE__ = true;
            }
          });
        },
        { threshold: 0.25 }
      );

      observer.observe(imgRef.current);
    }
  };

  return (
    <img
      ref={imgRef}
      src={src}
      alt={alt}
      className={className}
      loading={loading as 'lazy' | 'eager'}
      decoding={decoding as 'sync' | 'async'}
      onLoad={handleLoad}
      srcSet={srcSet}
      sizes={sizes}
      // Add data attributes for testing and debugging
      data-bot={isBot ? 'true' : 'false'}
      data-loaded={isLoaded ? 'true' : 'false'}
    />
  );
};

export default SmartImage;
