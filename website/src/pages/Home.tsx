import React, { useEffect } from 'react';
import SEO from '../components/common/SEO';
import { trackAnalyticsEvent } from '../utils/analytics';
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
        title="mQuiz - Learn, Engage, and Earn Rewards | Quiz Learning App"
        description="Join mQuiz, the ultimate quiz app that combines fun learning with real rewards. Challenge yourself, compete with friends, and earn while you learn."
        keywords="quiz app, learning app, earn money, educational games, online quizzes, gamified learning, peer-to-peer quiz battles"
        url="https://mquiz.uk"
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
