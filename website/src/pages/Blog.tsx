import React from 'react';
import SEO from '../components/common/SEO';

const Blog: React.FC = () => {
  return (
    <>
      <SEO
        title="mQuiz Blog - Learning Tips, Updates & Insights"
        description="Read the latest articles, tips, and insights on gamified learning, quiz strategies, and educational technology."
        url="https://mquiz.uk/blog"
      />
      <div className="container-custom section-padding">
        <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6 gradient-text">
          Blog
        </h1>
        <p className="text-lg text-slate-600 dark:text-slate-300">
          Coming soon...
        </p>
      </div>
    </>
  );
};

export default Blog;
