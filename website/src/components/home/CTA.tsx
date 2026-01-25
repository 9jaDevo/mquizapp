import React from 'react';
import { motion } from 'framer-motion';
import { Download, Smartphone } from 'lucide-react';
import GlassButton from '../common/GlassButton';
import appMockup from '../../assets/app-mockup.webp';

const CTA: React.FC = () => {
  return (
    <section className="section-padding">
      <div className="container-custom">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-center">
          {/* Left Side - Phone Mockup */}
          <motion.div
            initial={{ opacity: 0, x: -60 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="flex justify-center lg:justify-start"
          >
            <img
              src={appMockup}
              alt="mQuiz App Interface"
              className="w-full max-w-sm h-auto"
            />
          </motion.div>

          {/* Right Side - Content */}
          <motion.div
            initial={{ opacity: 0, x: 60 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
          >
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
              Ready to Start Your <span className="gradient-text">Learning Journey</span>?
            </h2>
            <p className="text-lg text-slate-600 dark:text-slate-300 mb-8">
              Join thousands of learners who are already transforming their education
              with mQuiz. Download the app now and start earning rewards while you learn!
            </p>

            <div className="flex flex-col sm:flex-row gap-4 mb-12">
              <GlassButton
                variant="primary"
                size="lg"
                icon={<Download className="w-5 h-5" />}
                href="/download"
              >
                Download for Android
              </GlassButton>
              <GlassButton
                variant="secondary"
                size="lg"
                icon={<Smartphone className="w-5 h-5" />}
                href="/download"
              >
                Download for iOS
              </GlassButton>
            </div>

            
          </motion.div>
        </div>
      </div>
    </section>
  );
};

export default CTA;
