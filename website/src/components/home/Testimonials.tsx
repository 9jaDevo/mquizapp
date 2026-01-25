import React from 'react';
import { motion } from 'framer-motion';
import { Star, Quote } from 'lucide-react';
import GlassCard from '../common/GlassCard';

const testimonials = [
  {
    name: 'Ogundele Omolola',
    platform: 'Google Play Store',
    date: '18 Jun',
    rating: 5,
    text: 'I so much love the App. Very easy to install and also to register. I didn\'t regret downloading this app. I will continue to recommend it to family and friends. The App is top notch. And the quiz is amazing. Keep up the good work!',
    avatar: 'https://mquiz.uk/wp-content/uploads/2024/06/u1.png',
  },
  {
    name: 'Fasemi Oluwaseyi',
    platform: 'App Store',
    date: '5 Jun',
    rating: 5,
    text: 'I especially enjoyed how user friendly this app is. Playing the game is fun, especially the fact that one can play with his or her friends simultaneously. Also ads are so minimal.',
    avatar: 'https://mquiz.uk/wp-content/uploads/2024/06/u4.jpg',
  },
  {
    name: 'Kay H',
    platform: 'App Store',
    date: 'Recent',
    rating: 5,
    text: 'Wow! So such a quiz app exists, such that it has a section for Islamic quiz! I even played a quickie and got a 10/10. I loved it and enjoyed my time, as it evoked my memory. I honestly recommend!',
    avatar: 'https://mquiz.uk/wp-content/uploads/2024/06/u3.png',
  },
  {
    name: 'Esther Adejayan',
    platform: 'Google Play Store',
    date: 'Recent',
    rating: 5,
    text: 'Wow! This app is great, not only do you get to have fun playing the games but you also acquire more knowledge as the quizzes cut across different areas.',
    avatar: 'https://mquiz.uk/wp-content/uploads/2024/06/u2.jpg',
  },
  {
    name: 'Abolaji Olumide',
    platform: 'Google Play Store',
    date: '26 Jun',
    rating: 5,
    text: 'MQUIZ is a very good app, it helps to think faster and smarter. I don\'t regret downloading this application. It also helped me remember some things my teacher taught me in my secondary school life.',
    avatar: 'https://mquiz.uk/wp-content/uploads/2024/06/u6.png',
  },
  {
    name: 'Victoria Udo',
    platform: 'App Store',
    date: '10 Jan',
    rating: 5,
    text: 'mQuiz is a nice app that allows users to participate in quiz thereby testing their knowledge. This is a very nice app with fast and reliable features. I give it a five star.',
    avatar: 'https://mquiz.uk/wp-content/uploads/2024/06/u5.png',
  },
];

const Testimonials: React.FC = () => {
  return (
    <section className="section-padding bg-slate-50/50 dark:bg-slate-900/50">
      <div className="container-custom">
        <motion.div
          className="text-center max-w-3xl mx-auto mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
        >
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6">
            What Our <span className="gradient-text">Users Are Saying</span>
          </h2>
          <p className="text-lg text-slate-600 dark:text-slate-300">
            Join thousands of satisfied learners who have transformed their education with mQuiz
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
            >
              <GlassCard className="p-6 h-full flex flex-col" blur="md" hover>
                <div className="flex items-start gap-4 mb-4">
                  <img
                    src={testimonial.avatar}
                    alt={testimonial.name}
                    className="w-12 h-12 rounded-full object-cover"
                    loading="lazy"
                  />
                  <div className="flex-1">
                    <h3 className="font-semibold text-slate-900 dark:text-white">
                      {testimonial.name}
                    </h3>
                    <p className="text-sm text-slate-600 dark:text-slate-400">
                      {testimonial.platform} · {testimonial.date}
                    </p>
                  </div>
                  <Quote className="w-8 h-8 text-primary/20" />
                </div>

                <div className="flex gap-1 mb-4">
                  {[...Array(testimonial.rating)].map((_, i) => (
                    <Star
                      key={i}
                      className="w-4 h-4 fill-yellow-400 text-yellow-400"
                    />
                  ))}
                </div>

                <p className="text-slate-700 dark:text-slate-300 leading-relaxed flex-1">
                  {testimonial.text}
                </p>
              </GlassCard>
            </motion.div>
          ))}
        </div>

        {/* Trust Indicators */}
        <motion.div
          className="mt-16 text-center"
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
        >
          <div className="flex flex-wrap justify-center items-center gap-8">
            <div className="flex items-center gap-2">
              <Star className="w-6 h-6 fill-yellow-400 text-yellow-400" />
              <span className="text-2xl font-bold gradient-text">4.8/5</span>
              <span className="text-slate-600 dark:text-slate-400">Average Rating</span>
            </div>
            <div className="w-px h-8 bg-slate-300 dark:bg-slate-700 hidden md:block" />
            <div>
              <span className="text-2xl font-bold gradient-text">10K+</span>
              <span className="text-slate-600 dark:text-slate-400 ml-2">Happy Users</span>
            </div>
            <div className="w-px h-8 bg-slate-300 dark:bg-slate-700 hidden md:block" />
            <div>
              <span className="text-2xl font-bold gradient-text">25K+</span>
              <span className="text-slate-600 dark:text-slate-400 ml-2">Quiz Battles</span>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
};

export default Testimonials;
