import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Plus, Minus } from 'lucide-react';
import GlassCard from '../common/GlassCard';

interface FAQItem {
  question: string;
  answer: string;
  category?: string;
}

const faqs: FAQItem[] = [
  {
    question: 'What is mQuiz?',
    answer: 'mQuiz is an engaging and interactive quiz app designed to enhance learning and provide exciting rewards. It offers a wide range of quiz categories for users of all ages, combining education with entertainment to make learning fun and rewarding.',
    category: 'General',
  },
  {
    question: 'How can I download the mQuiz app?',
    answer: 'You can download the mQuiz app from the App Store for iOS devices or Google Play for Android devices. Simply search for "mQuiz" in your device\'s app store and start your learning journey today!',
    category: 'Getting Started',
  },
  {
    question: 'How do I earn rewards on mQuiz?',
    answer: 'Earn points by taking quizzes and achieving high scores. Accumulate points through daily quizzes, quiz battles, and challenges to unlock badges and redeem them for real-world rewards. The more you play and learn, the more you earn!',
    category: 'Rewards',
  },
  {
    question: 'Can I earn real money with mQuiz?',
    answer: 'Yes, you can earn real money by participating in quizzes and achieving high scores. Redeem your accumulated points for cash rewards through our reward redemption system.',
    category: 'Rewards',
  },
  {
    question: 'Can I withdraw my earnings to my bank account?',
    answer: 'Yes, you can withdraw your earnings to your local bank account or via PayPal. Simply follow the withdrawal process in the app under the rewards section. Minimum withdrawal thresholds apply.',
    category: 'Payments',
  },
  {
    question: 'Is mQuiz suitable for all ages?',
    answer: 'Yes, mQuiz offers quizzes for kids, teens, and adults. Our diverse quiz categories including science, history, mathematics, geography, and more ensure fun and learning for everyone regardless of age or skill level.',
    category: 'General',
  },
  {
    question: 'Can I join the mQuiz community and interact with other users?',
    answer: 'Absolutely! Join the mQuiz global community to expand your knowledge, challenge friends in quiz battles, participate in community events, and compete on leaderboards. Connect with learners from around the world!',
    category: 'Community',
  },
  {
    question: 'What types of quiz modes are available?',
    answer: 'mQuiz offers 12+ quiz modes including Quiz Zone, Contest Quiz, Group Battle, 1v1 Battle, Daily Quiz, Fun \'N\' Learn, Guess Word, Audio Quiz, Math Mania, True|False, Exam Quiz, and Self-Challenge modes to suit different learning styles.',
    category: 'Features',
  },
];

const FAQ: React.FC = () => {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  const toggleFAQ = (index: number) => {
    setOpenIndex(openIndex === index ? null : index);
  };

  return (
    <section className="section-padding">
      <div className="container-custom">
        <motion.div
          className="text-center max-w-3xl mx-auto mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
            Frequently Asked <span className="gradient-text">Questions</span>
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300">
            Find answers to common questions about mQuiz and how to get started
          </p>
        </motion.div>

        <div className="max-w-4xl mx-auto">
          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.05 }}
                itemScope
                itemType="https://schema.org/Question"
              >
                <GlassCard className="overflow-hidden" blur="md">
                  <button
                    onClick={() => toggleFAQ(index)}
                    className="w-full p-6 text-left flex items-center justify-between gap-4 hover:bg-white/5 transition-colors"
                    aria-expanded={openIndex === index}
                  >
                    <div className="flex-1">
                      <h3
                        className="text-lg font-semibold text-slate-900 dark:text-white"
                        itemProp="name"
                      >
                        {faq.question}
                      </h3>
                    </div>
                    <div className="flex-shrink-0">
                      {openIndex === index ? (
                        <Minus className="w-5 h-5 text-primary" />
                      ) : (
                        <Plus className="w-5 h-5 text-primary" />
                      )}
                    </div>
                  </button>

                  <AnimatePresence>
                    {openIndex === index && (
                      <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.3 }}
                        itemScope
                        itemType="https://schema.org/Answer"
                      >
                        <div className="px-6 pb-6">
                          <p
                            className="text-slate-700 dark:text-slate-300 leading-relaxed"
                            itemProp="text"
                          >
                            {faq.answer}
                          </p>
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </GlassCard>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Still have questions CTA */}
        <motion.div
          className="mt-16 text-center"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
        >
          <GlassCard className="p-8 max-w-2xl mx-auto" blur="lg">
            <h3 className="text-2xl font-heading font-bold mb-4 text-slate-900 dark:text-white">
              Still Have Questions?
            </h3>
            <p className="text-slate-700 dark:text-slate-300 mb-6">
              Can't find the answer you're looking for? Please reach out to our friendly team.
            </p>
            <a
              href="/contact"
              className="inline-flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-primary to-secondary text-white font-semibold rounded-xl hover:shadow-lg transition-all"
            >
              Contact Support
            </a>
          </GlassCard>
        </motion.div>
      </div>
    </section>
  );
};

export default FAQ;
