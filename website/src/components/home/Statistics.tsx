import React from 'react';
import { motion } from 'framer-motion';
import { Users, BookOpen, Trophy, Heart } from 'lucide-react';
import GlassCard from '../common/GlassCard';

const stats = [
  { icon: Users, value: '10,000+', label: 'Active Users' },
  { icon: BookOpen, value: '50,000+', label: 'Lessons Completed' },
  { icon: Trophy, value: '25,000+', label: 'Quiz Battles Played' },
  { icon: Heart, value: '15,000+', label: 'Community Members' },
];

const Statistics: React.FC = () => {
  return (
    <section className="section-padding bg-gradient-to-br from-primary/5 via-secondary/5 to-accent/5">
      <div className="container-custom">
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, index) => {
            const Icon = stat.icon;
            return (
              <motion.div
                key={index}
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1, duration: 0.5 }}
              >
                <GlassCard className="p-8 text-center" blur="lg">
                  <Icon className="w-12 h-12 mx-auto mb-4 text-primary dark:text-accent" />
                  <p className="text-3xl md:text-4xl font-bold gradient-text mb-2">
                    {stat.value}
                  </p>
                  <p className="text-sm text-slate-600 dark:text-slate-400">
                    {stat.label}
                  </p>
                </GlassCard>
              </motion.div>
            );
          })}
        </div>
      </div>
    </section>
  );
};

export default Statistics;
