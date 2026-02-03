import React, { useEffect } from 'react';
import SEO from '../components/common/SEO';
import { trackAnalyticsEvent } from '../utils/analytics';
import { seoConfig } from '../utils/seoConfig';
import Hero from '../components/home/Hero';
import Features from '../components/home/Features';
import Statistics from '../components/home/Statistics';
import HowItWorks from '../components/home/HowItWorks';
import Testimonials from '../components/home/Testimonials';
import FAQ from '../components/home/FAQ';
import CTA from '../components/home/CTA';

const Home: React.FC = () => {
  useEffect(() => {
    trackAnalyticsEvent('page_view', {
      page_title: 'Home',
      page_location: window.location.href,
      page_path: '/',
    });
  }, []);

  const structuredData = {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    name: 'mQuiz',
    url: 'https://mquiz.uk',
    logo: 'https://mquiz.uk/logo.png',
    description: 'Interactive quiz learning platform with real rewards',
    sameAs: [
      'https://facebook.com/mquizonline',
      'https://youtube.com/@mquizonline',
    ],
  };

  return (
    <>
      <SEO
        title={seoConfig.home.title}
        description={seoConfig.home.description}
        keywords={seoConfig.home.keywords}
        url="https://mquiz.uk"
        type={seoConfig.home.type}
        image={seoConfig.home.image}
        structuredData={structuredData}
      />
      <Hero />
      <Features />
      <Statistics />
      <HowItWorks />
      <Testimonials />
      <FAQ />
      {/* <AppShowcase /> */}
      <CTA />
    </>
  );
};

export default Home;
