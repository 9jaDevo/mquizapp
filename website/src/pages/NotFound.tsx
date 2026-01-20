import React from 'react';
import SEO from '../components/common/SEO';
import GlassButton from '../components/common/GlassButton';
import GlassCard from '../components/common/GlassCard';

const NotFound: React.FC = () => {
  return (
    <>
      <SEO
        title="Page Not Found - mQuiz"
        description="The page you're looking for doesn't exist."
      />
      <div className="container-custom section-padding min-h-[60vh] flex items-center justify-center">
        <GlassCard className="p-12 text-center max-w-2xl" blur="xl">
          <h1 className="text-9xl font-bold gradient-text mb-4">404</h1>
          <h2 className="text-3xl font-heading font-bold mb-4 text-slate-900 dark:text-white">
            Page Not Found
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300 mb-8">
            Oops! The page you're looking for doesn't exist. Let's get you back on track.
          </p>
          <GlassButton variant="primary" size="lg" href="/">
            Go Back Home
          </GlassButton>
        </GlassCard>
      </div>
    </>
  );
};

export default NotFound;
