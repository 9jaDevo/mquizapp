import React from 'react';
import { motion } from 'framer-motion';
import { cn } from '../../utils/cn';

interface GlassButtonProps {
  children: React.ReactNode;
  variant?: 'primary' | 'secondary' | 'outline';
  size?: 'sm' | 'md' | 'lg';
  href?: string;
  onClick?: () => void;
  icon?: React.ReactNode;
  className?: string;
  disabled?: boolean;
  type?: 'button' | 'submit' | 'reset';
  fullWidth?: boolean;
}

const GlassButton: React.FC<GlassButtonProps> = ({
  children,
  variant = 'primary',
  size = 'md',
  href,
  onClick,
  icon,
  className,
  disabled = false,
  type = 'button',
  fullWidth = false,
}) => {
  const baseClasses = cn(
    'relative inline-flex items-center justify-center gap-2 rounded-xl font-medium transition-all duration-300',
    'backdrop-blur-md border',
    'disabled:opacity-50 disabled:cursor-not-allowed',
    {
      'w-full': fullWidth,
    },
    {
      'px-4 py-2 text-sm': size === 'sm',
      'px-6 py-3 text-base': size === 'md',
      'px-8 py-4 text-lg': size === 'lg',
    },
    {
      'bg-primary/80 border-primary text-white hover:bg-primary hover:shadow-lg hover:shadow-primary/50':
        variant === 'primary',
      'bg-secondary/80 border-secondary text-white hover:bg-secondary hover:shadow-lg hover:shadow-secondary/50':
        variant === 'secondary',
      'bg-white/10 border-white/20 text-slate-900 dark:text-white hover:bg-white/20 hover:border-white/40':
        variant === 'outline',
    },
    className
  );

  const content = (
    <>
      {icon && <span className="flex-shrink-0">{icon}</span>}
      <span>{children}</span>
    </>
  );

  if (href) {
    return (
      <motion.a
        href={href}
        className={baseClasses}
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.95 }}
        transition={{ duration: 0.2 }}
      >
        <div className="absolute inset-0 rounded-xl bg-gradient-to-r from-transparent via-white/10 to-transparent opacity-0 hover:opacity-100 transition-opacity" />
        <span className="relative z-10 flex items-center gap-2">
          {content}
        </span>
      </motion.a>
    );
  }

  return (
    <motion.button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={baseClasses}
      whileHover={{ scale: disabled ? 1 : 1.05 }}
      whileTap={{ scale: disabled ? 1 : 0.95 }}
      transition={{ duration: 0.2 }}
    >
      <div className="absolute inset-0 rounded-xl bg-gradient-to-r from-transparent via-white/10 to-transparent opacity-0 hover:opacity-100 transition-opacity" />
      <span className="relative z-10 flex items-center gap-2">
        {content}
      </span>
    </motion.button>
  );
};

export default GlassButton;
