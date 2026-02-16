import React, { useEffect } from 'react';
import { motion } from 'framer-motion';
import {
  Award,
  BadgeCheck,
  CalendarDays,
  Crown,
  Share2,
  Sparkles,
  Target,
  Timer,
  Trophy,
  Users,
} from 'lucide-react';
import SEO from '../components/common/SEO';
import GlassCard from '../components/common/GlassCard';
import GlassButton from '../components/common/GlassButton';
import { trackAnalyticsEvent } from '../utils/analytics';
import { seoConfig } from '../utils/seoConfig';

const timeline = [
  { label: 'Registration Opens', value: '16th February 2026' },
  { label: 'Contest Period', value: 'Inside the mQuiz App' },
  { label: 'Winners Announced', value: '28th March 2026' },
];

const prizeTiers = [
  { place: '1st Place', amount: '₦35,000' },
  { place: '2nd Place', amount: '₦20,000' },
  { place: '3rd Place', amount: '₦15,000' },
];

const entrySteps = [
  'Daily check-ins',
  'Playing quiz rounds',
  'Climbing the leaderboard',
];

const consistencyAwards = [
  {
    title: 'Monthly Leaderboard Champion',
    prize: '₦10,000',
    description: 'Highest total leaderboard points for the month. This rewards long-term consistency.',
  },
  {
    title: 'Most App Engagement',
    prize: '₦10,000',
    description: 'Measured by active days and completed quiz sessions. The more you play, the higher your chances.',
  },
];

const howItWorks = [
  'Use your Instagram handle as your team keyword.',
  'Tell friends to follow our official Instagram page.',
  'Ask them to comment your team keyword on the giveaway post.',
  'Each valid comment counts as 1 referral point.',
];

const socialRules = [
  'You must be registered and active in the mQuiz app.',
  'You must meet the 500-point requirement.',
  'The person commenting must follow our page.',
  'Each account can comment only one team name.',
  'Duplicate comments do not count.',
  'Fake or suspicious accounts will be disqualified.',
];

const Competition: React.FC = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
    trackAnalyticsEvent('page_view', {
      page_title: 'Competition',
      page_location: window.location.href,
      page_path: '/competition',
    });
  }, []);

  return (
    <>
      <SEO
        title={seoConfig.competition.title}
        description={seoConfig.competition.description}
        keywords={seoConfig.competition.keywords}
        url="https://mquiz.uk/competition"
        type={seoConfig.competition.type}
      />
      <div className="container-custom section-padding">
        <motion.div
          className="max-w-4xl mx-auto text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 text-primary font-semibold text-sm mb-6">
            <Sparkles className="w-4 h-4" />
            🔥 mQuiz Battle for 100K
          </div>
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-heading font-bold mb-6">
            Knowledge. Speed. Consistency. Influence.
          </h1>
          <p className="text-lg md:text-xl text-slate-700 dark:text-slate-300">
            The mQuiz Battle for 100K is a competitive knowledge challenge where only the smartest and most consistent players win real cash. All contest activities happen inside the mQuiz Mobile App.
          </p>
        </motion.div>

        <section className="mb-16">
          <motion.h2
            className="text-3xl md:text-4xl font-heading font-bold text-center mb-10"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            Competition <span className="gradient-text">Timeline</span>
          </motion.h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {timeline.map((item) => (
              <GlassCard key={item.label} className="p-6" hover={false}>
                <div className="flex items-center gap-3 mb-4">
                  <CalendarDays className="w-5 h-5 text-primary" />
                  <h3 className="font-semibold text-lg">{item.label}</h3>
                </div>
                <p className="text-slate-700 dark:text-slate-300 text-base">
                  {item.value}
                </p>
              </GlassCard>
            ))}
          </div>
        </section>

        <section className="mb-16">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-start">
            <GlassCard className="p-8" hover={false}>
              <div className="flex items-center gap-3 mb-4">
                <BadgeCheck className="w-6 h-6 text-primary" />
                <h2 className="text-2xl font-heading font-bold">Important Entry Requirement</h2>
              </div>
              <p className="text-slate-700 dark:text-slate-300 mb-6">
                To qualify for the main contest, you must have at least 500 points in the mQuiz app before you can participate. This ensures only active and serious players enter the competition.
              </p>
              <div className="bg-primary/10 border border-primary/20 rounded-2xl p-5">
                <p className="font-semibold text-slate-900 dark:text-white">No shortcuts. No free rides.</p>
              </div>
            </GlassCard>

            <GlassCard className="p-8" hover={false}>
              <div className="flex items-center gap-3 mb-4">
                <Target className="w-6 h-6 text-primary" />
                <h2 className="text-2xl font-heading font-bold">How to Earn 500 Points</h2>
              </div>
              <ul className="space-y-3 text-slate-700 dark:text-slate-300">
                {entrySteps.map((step) => (
                  <li key={step} className="flex items-start gap-3">
                    <Award className="w-5 h-5 text-primary mt-1" />
                    <span>{step}</span>
                  </li>
                ))}
              </ul>
            </GlassCard>
          </div>
        </section>

        <section className="mb-16">
          <motion.h2
            className="text-3xl md:text-4xl font-heading font-bold text-center mb-10"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            Main Contest <span className="gradient-text">Prizes</span>
          </motion.h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {prizeTiers.map((tier) => (
              <GlassCard key={tier.place} className="p-6 text-center" hover={false}>
                <Trophy className="w-10 h-10 text-primary mx-auto mb-4" />
                <h3 className="text-xl font-heading font-bold mb-2">{tier.place}</h3>
                <p className="text-2xl font-semibold text-primary">{tier.amount}</p>
              </GlassCard>
            ))}
          </div>
          <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-6">
            <GlassCard className="p-6" hover={false}>
              <h3 className="font-semibold text-lg mb-3">Winners are determined by</h3>
              <ul className="space-y-2 text-slate-700 dark:text-slate-300">
                <li className="flex items-start gap-3">
                  <Timer className="w-5 h-5 text-primary mt-1" />
                  <span>Highest number of correct answers</span>
                </li>
                <li className="flex items-start gap-3">
                  <Timer className="w-5 h-5 text-primary mt-1" />
                  <span>Fastest completion time</span>
                </li>
              </ul>
            </GlassCard>
            <GlassCard className="p-6" hover={false}>
              <h3 className="font-semibold text-lg mb-3">Accuracy + Speed = Victory</h3>
              <p className="text-slate-700 dark:text-slate-300">
                The app already tracks this automatically, so focus on getting every answer right and finishing quickly.
              </p>
            </GlassCard>
          </div>
        </section>

        <section className="mb-16">
          <motion.h2
            className="text-3xl md:text-4xl font-heading font-bold text-center mb-10"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            Consistency <span className="gradient-text">Rewards</span>
          </motion.h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {consistencyAwards.map((awardItem) => (
              <GlassCard key={awardItem.title} className="p-6" hover={false}>
                <div className="flex items-center gap-3 mb-3">
                  <Crown className="w-6 h-6 text-primary" />
                  <h3 className="text-xl font-heading font-bold">{awardItem.title}</h3>
                </div>
                <p className="text-2xl font-semibold text-primary mb-3">{awardItem.prize}</p>
                <p className="text-slate-700 dark:text-slate-300">{awardItem.description}</p>
              </GlassCard>
            ))}
          </div>
        </section>

        <section className="mb-16">
          <motion.h2
            className="text-3xl md:text-4xl font-heading font-bold text-center mb-10"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            Social Ambassador <span className="gradient-text">Award</span>
          </motion.h2>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
            <GlassCard className="p-8" hover={false}>
              <div className="flex items-center gap-3 mb-4">
                <Share2 className="w-6 h-6 text-primary" />
                <h3 className="text-2xl font-heading font-bold">How It Works</h3>
              </div>
              <p className="text-slate-700 dark:text-slate-300 mb-4">
                Want to win by growing the mQuiz community? Earn the Social Ambassador Award through referrals on Instagram.
              </p>
              <div className="bg-slate-900/5 dark:bg-white/5 rounded-2xl p-4 mb-4">
                <p className="font-semibold">Example</p>
                <p className="text-slate-700 dark:text-slate-300">
                  If your handle is @alexfit, your keyword becomes: <span className="font-semibold">TEAM ALEXFIT</span>
                </p>
              </div>
              <ul className="space-y-3 text-slate-700 dark:text-slate-300">
                {howItWorks.map((item) => (
                  <li key={item} className="flex items-start gap-3">
                    <Users className="w-5 h-5 text-primary mt-1" />
                    <span>{item}</span>
                  </li>
                ))}
              </ul>
            </GlassCard>

            <GlassCard className="p-8" hover={false}>
              <div className="flex items-center gap-3 mb-4">
                <BadgeCheck className="w-6 h-6 text-primary" />
                <h3 className="text-2xl font-heading font-bold">Social Category Rules</h3>
              </div>
              <ul className="space-y-3 text-slate-700 dark:text-slate-300">
                {socialRules.map((rule) => (
                  <li key={rule} className="flex items-start gap-3">
                    <Target className="w-5 h-5 text-primary mt-1" />
                    <span>{rule}</span>
                  </li>
                ))}
              </ul>
              <div className="mt-6 bg-primary/10 border border-primary/20 rounded-2xl p-4">
                <p className="font-semibold text-slate-900 dark:text-white">
                  The participant with the highest number of verified referrals wins.
                </p>
              </div>
            </GlassCard>
          </div>

          <GlassCard className="p-8 mt-8" hover={false}>
            <div className="flex items-center gap-3 mb-4">
              <Sparkles className="w-6 h-6 text-primary" />
              <h3 className="text-2xl font-heading font-bold">Bonus Advantage</h3>
            </div>
            <p className="text-slate-700 dark:text-slate-300">
              If someone comments your team keyword and downloads and registers on mQuiz, you earn bonus referral credit because real growth matters.
            </p>
          </GlassCard>
        </section>

        <section className="mb-16">
          <motion.h2
            className="text-3xl md:text-4xl font-heading font-bold text-center mb-10"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            Why This Competition <span className="gradient-text">Is Different</span>
          </motion.h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {[
              'Skill-based',
              'Performance-based',
              'Engagement-driven',
              'Community-powered',
              'Your knowledge earns you points.',
              'Your speed earns you rank.',
              'Your consistency earns you advantage.',
              'Your influence earns you bonus power.',
            ].map((item) => (
              <GlassCard key={item} className="p-6" hover={false}>
                <div className="flex items-center gap-3">
                  <BadgeCheck className="w-5 h-5 text-primary" />
                  <span className="text-slate-700 dark:text-slate-300 font-medium">{item}</span>
                </div>
              </GlassCard>
            ))}
          </div>
        </section>

        <section className="mb-16">
          <motion.h2
            className="text-3xl md:text-4xl font-heading font-bold text-center mb-10"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
          >
            How to <span className="gradient-text">Get Started</span>
          </motion.h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              'Download the mQuiz App',
              'Register',
              'Start earning points',
              'Reach 500 points',
              'Join the official contest',
              'Compete. Win. Get Paid.',
            ].map((step, index) => (
              <GlassCard key={step} className="p-6" hover={false}>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-primary/10 text-primary font-semibold flex items-center justify-center">
                    {index + 1}
                  </div>
                  <p className="font-medium text-slate-700 dark:text-slate-300">{step}</p>
                </div>
              </GlassCard>
            ))}
          </div>
        </section>

        <section className="mb-8">
          <GlassCard className="p-10 text-center" hover={false}>
            <h2 className="text-3xl md:text-4xl font-heading font-bold mb-4">
              The Countdown Has Begun
            </h2>
            <p className="text-slate-700 dark:text-slate-300 mb-6">
              Thousands will play. Only a few will dominate. Will your name be on the leaderboard?
            </p>
            <div className="flex flex-col md:flex-row items-center justify-center gap-4">
              <GlassButton href="/download" variant="primary" size="lg">
                Download mQuiz Now
              </GlassButton>
              <div className="text-sm text-slate-600 dark:text-slate-400">
                Scan the QR code or download from the App Store / Play Store.
              </div>
            </div>
            <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4 text-sm text-slate-600 dark:text-slate-400">
              <div className="flex items-center justify-center gap-2">
                <Target className="w-4 h-4 text-primary" />
                Earn 500 points
              </div>
              <div className="flex items-center justify-center gap-2">
                <Trophy className="w-4 h-4 text-primary" />
                Enter the contest
              </div>
              <div className="flex items-center justify-center gap-2">
                <Crown className="w-4 h-4 text-primary" />
                Win real cash
              </div>
            </div>
          </GlassCard>
        </section>
      </div>
    </>
  );
};

export default Competition;
