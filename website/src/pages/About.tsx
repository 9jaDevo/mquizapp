import React from 'react';
import SEO from '../components/common/SEO';

const About: React.FC = () => {
  return (
    <>
      <SEO
        title="About mQuiz - Our Mission and Story"
        description="Learn about mQuiz's mission to revolutionize education through gamification and interactive learning. Discover our story and values."
        url="https://mquiz.uk/about"
      />
      <div className="container-custom section-padding">
        <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6 gradient-text">
          About mQuiz
        </h1>
        <p className="text-lg text-slate-600 dark:text-slate-300">
          Coming soon...
        </p>
      </div>
    </>
  );
};

export default About;
