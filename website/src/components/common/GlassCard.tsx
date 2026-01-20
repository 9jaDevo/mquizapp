import React from 'react';
import { motion } from 'framer-motion';
import { cn } from '../../utils/cn';

interface GlassCardProps {
  children: React.ReactNode;
  className?: string;
  blur?: 'sm' | 'md' | 'lg' | 'xl';
  opacity?: number;
  hover?: boolean;
  onClick?: () => void;
  as?: 'div' | 'article' | 'section';
}

const blurClasses = {
  sm: 'backdrop-blur-sm',
  md: 'backdrop-blur-md',
  lg: 'backdrop-blur-lg',
  xl: 'backdrop-blur-xl',
};

const GlassCard: React.FC<GlassCardProps> = ({
  children,
  className,
  blur = 'lg',
  opacity = 0.1,
  hover = true,
  onClick,
  as: Component = 'div',
}) => {
  const MotionComponent = motion[Component as keyof typeof motion] as any;

  return (
    <MotionComponent
      className={cn(
        'relative rounded-2xl border border-white/20 shadow-glass',
        blurClasses[blur],
        hover && 'glass-hover cursor-pointer',
        'dark:border-white/10',
        className
      )}
      style={{
        background: `rgba(255, 255, 255, ${opacity})`,
      }}
      onClick={onClick}
      whileHover={hover ? { y: -4, scale: 1.02 } : undefined}
      transition={{ duration: 0.3, ease: 'easeOut' }}
    >
      <div className="absolute inset-0 rounded-2xl bg-gradient-to-br from-white/10 to-transparent pointer-events-none" />
      <div className="relative z-10">
        {children}
      </div>
    </MotionComponent>
  );
};

export default GlassCard;
