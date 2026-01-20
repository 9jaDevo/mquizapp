import React from 'react';
import { motion } from 'framer-motion';
import { Download, Smartphone } from 'lucide-react';
import GlassButton from '../common/GlassButton';
import GlassCard from '../common/GlassCard';

const CTA: React.FC = () => {
  return (
    <section className="section-padding">
      <div className="container-custom">
        <GlassCard className="p-12 md:p-16 text-center" blur="xl">
          <div className="max-w-3xl mx-auto">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
            >
              <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
                Ready to Start Your <span className="gradient-text">Learning Journey</span>?
              </h2>
              <p className="text-lg text-slate-600 dark:text-slate-300 mb-8">
                Join thousands of learners who are already transforming their education
                with mQuiz. Download the app now and start earning rewards while you learn!
              </p>

              <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-12">
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

              {/* QR Code Placeholder */}
              <div className="inline-block p-6 bg-white dark:bg-slate-800 rounded-2xl">
                <div className="w-32 h-32 bg-gradient-to-br from-slate-200 to-slate-300 dark:from-slate-700 dark:to-slate-600 rounded-xl flex items-center justify-center">
                  <p className="text-xs text-slate-600 dark:text-slate-400 text-center">
                    QR Code
                    <br />
                    Placeholder
                  </p>
                </div>
                <p className="text-sm text-slate-600 dark:text-slate-400 mt-2">
                  Scan to Download
                </p>
              </div>
            </motion.div>
          </div>
        </GlassCard>
      </div>
    </section>
  );
};

export default CTA;
