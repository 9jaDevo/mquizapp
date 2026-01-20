import React from 'react';
import SEO from '../components/common/SEO';

const Contact: React.FC = () => {
  return (
    <>
      <SEO
        title="Contact mQuiz - Get in Touch"
        description="Have questions? Contact the mQuiz team. We're here to help with any queries about our quiz learning platform."
        url="https://mquiz.uk/contact"
      />
      <div className="container-custom section-padding">
        <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6 gradient-text">
          Contact Us
        </h1>
        <p className="text-lg text-slate-600 dark:text-slate-300">
          Coming soon...
        </p>
      </div>
    </>
  );
};

export default Contact;
