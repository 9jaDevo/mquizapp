import React from 'react';
import SEO from '../components/common/SEO';

const Features: React.FC = () => {
  return (
    <>
      <SEO
        title="mQuiz Features - Discover What Makes Us Special"
        description="Explore mQuiz's powerful features including gamified learning, quiz battles, progress tracking, and real rewards."
        url="https://mquiz.uk/features"
      />
      <div className="container-custom section-padding">
        <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6 gradient-text">
          Features
        </h1>
        <p className="text-lg text-slate-600 dark:text-slate-300">
          Coming soon...
        </p>
      </div>
    </>
  );
};

export default Features;
