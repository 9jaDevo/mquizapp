import React, { useEffect } from 'react';
import SEO from '../components/common/SEO';
import { CheckCircle } from 'lucide-react';
import { trackAnalyticsEvent } from '../utils/analytics';
import { seoConfig } from '../utils/seoConfig';

const About: React.FC = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
    trackAnalyticsEvent('page_view', {
      page_title: 'About',
      page_location: window.location.href,
      page_path: '/about',
    });
  }, []);
  const features = [
    'Quiz Zone: Challenge yourself with multiple-choice questions across various categories and levels.',
    'Contest Quiz: Compete for prizes and recognition by answering questions in timed contests.',
    'Group Battle: Collaborate and compete with friends in group quizzes to score the highest points.',
    '1 vs 1 Battle: Test your knowledge against others for coins and rewards in one-on-one battles.',
    'Daily Quiz: Stay engaged with daily quizzes and keep your learning momentum.',
    'Fun \'N\' Learn: Quick comprehension tests to enhance your understanding.',
    'Guess Word: Improve your vocabulary with fun and interactive word games.',
    'Audio Quiz: Listen and answer questions based on audio clips.',
    'Math Mania: Hone your math skills with questions on algebra, calculus, and geometry.',
    'True | False: Fast-paced quizzes to quickly test and expand your knowledge.',
    'Exam Quiz: Prepare for exams with timed quizzes using exam keys.',
    'Self-Challenge: Customize quizzes to match your interests and abilities.',
    'Leaderboard: See where you stand globally and challenge others to climb the ranks.',
  ];

  return (
    <>
      <SEO
        title={seoConfig.about.title}
        description={seoConfig.about.description}
        keywords={seoConfig.about.keywords}
        url="https://mquiz.uk/about"
        type={seoConfig.about.type}
      />
      <div className="container-custom section-padding">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6 gradient-text">
            Welcome to mQuiz Learn and Earn!
          </h1>

          <section className="mb-12">
            <p className="text-lg text-slate-700 dark:text-slate-300 mb-6">
              mQuiz is a product of TOG Africa, dedicated to fostering ICT in education and promoting continuous learning among students through technology. Our app is designed to make learning fun, engaging, and rewarding.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-heading font-bold mb-6 gradient-text">Our Mission</h2>
            <p className="text-lg text-slate-700 dark:text-slate-300">
              At mQuiz, we aim to revolutionize students' learning by integrating technology into their educational journey. We encourage students to embrace ICT and use it to enhance their knowledge and skills.
            </p>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-heading font-bold mb-6 gradient-text">What We Offer</h2>
            <p className="text-lg text-slate-700 dark:text-slate-300 mb-6">
              mQuiz offers a variety of interactive quiz formats that cater to different learning preferences and subjects. Whether preparing for exams, improving your math skills, or having fun with vocabulary games, mQuiz provides a platform for continuous learning. Our features include:
            </p>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {features.map((feature, index) => (
                <div key={index} className="flex items-start gap-3">
                  <CheckCircle className="w-5 h-5 text-primary flex-shrink-0 mt-1" />
                  <p className="text-slate-700 dark:text-slate-300">{feature}</p>
                </div>
              ))}
            </div>
          </section>

          <section className="mb-12">
            <h2 className="text-3xl font-heading font-bold mb-6 gradient-text">Why Choose mQuiz?</h2>
            <p className="text-lg text-slate-700 dark:text-slate-300 mb-6">
              mQuiz is not just an app; it's a community of learners passionate about using technology to advance their education. Our app is user-friendly, engaging, and designed to make learning an enjoyable experience. Learning should never stop; with mQuiz, it doesn't have to.
            </p>
            <p className="text-lg text-slate-700 dark:text-slate-300 mb-6">
              Join us in our mission to bring ICT into education and make continuous learning a reality for students everywhere. Download mQuiz Learn and Earn today and start your journey to a brighter, more knowledgeable future!
            </p>
          </section>

          <section className="bg-gradient-to-r from-primary/10 to-secondary/10 rounded-2xl p-8 border border-primary/20">
            <h2 className="text-2xl font-bold mb-4">Get In Touch</h2>
            <p className="text-slate-700 dark:text-slate-300 mb-4">For more information, support, or inquiries, feel free to reach out to us:</p>
            <ul className="space-y-2 text-slate-700 dark:text-slate-300">
              <li><strong>Email:</strong> <a href="mailto:support@mquiz.uk" className="text-primary hover:underline">support@mquiz.uk</a></li>
              <li><strong>Address:</strong> Plot 624, Kingfem Plaza, GA 247, 1096 Ahmadu Bello Way, Abuja 900108, Federal Capital Territory, Nigeria</li>
            </ul>
            <p className="text-slate-700 dark:text-slate-300 mt-4">Thank you for choosing mQuiz Learn and Earn. Let's make learning fun together!</p>
          </section>
        </div>
      </div>
    </>
  );
};

export default About;
