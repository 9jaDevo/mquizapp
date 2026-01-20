import React from 'react';
import { motion } from 'framer-motion';
import { Star, Quote } from 'lucide-react';
import GlassCard from '../common/GlassCard';

const testimonials = [
  {
    name: 'Sarah Johnson',
    role: 'Student',
    image: '/placeholder-user-1.jpg', // TODO: Replace with actual user photo
    rating: 5,
    text: 'mQuiz has completely transformed my learning experience. The gamification makes studying fun, and I love earning rewards while learning!',
  },
  {
    name: 'Michael Chen',
    role: 'Teacher',
    image: '/placeholder-user-2.jpg', // TODO: Replace with actual user photo
    rating: 5,
    text: 'As an educator, I recommend mQuiz to all my students. The quiz battles feature creates healthy competition and improves engagement.',
  },
  {
    name: 'Emily Davis',
    role: 'Professional',
    image: '/placeholder-user-3.jpg', // TODO: Replace with actual user photo
    rating: 5,
    text: 'I use mQuiz to keep my knowledge fresh. The variety of categories and the ability to earn real rewards is simply amazing!',
  },
];

const Testimonials: React.FC = () => {
  return (
    <section className="section-padding bg-gradient-to-br from-secondary/5 via-primary/5 to-accent/5">
      <div className="container-custom">
        <motion.div
          className="text-center max-w-3xl mx-auto mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
            What Our <span className="gradient-text">Users Say</span>
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300">
            Join thousands of satisfied learners who have transformed their education with mQuiz.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
            >
              <GlassCard className="p-8 h-full" blur="md" hover>
                <Quote className="w-10 h-10 text-primary/30 mb-4" />
                <p className="text-slate-700 dark:text-slate-300 mb-6">
                  "{testimonial.text}"
                </p>
                <div className="flex items-center gap-4">
                  <img
                    src={testimonial.image}
                    alt={testimonial.name}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                  <div>
                    <h4 className="font-semibold text-slate-900 dark:text-white">
                      {testimonial.name}
                    </h4>
                    <p className="text-sm text-slate-600 dark:text-slate-400">
                      {testimonial.role}
                    </p>
                  </div>
                </div>
                <div className="flex gap-1 mt-4">
                  {Array.from({ length: testimonial.rating }).map((_, i) => (
                    <Star
                      key={i}
                      className="w-5 h-5 fill-yellow-400 text-yellow-400"
                    />
                  ))}
                </div>
              </GlassCard>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
