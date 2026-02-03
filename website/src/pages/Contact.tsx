import React, { useState, useEffect } from 'react';
import SEO from '../components/common/SEO';
import { trackAnalyticsEvent } from '../utils/analytics';
import { Mail, Phone, MapPin, Send } from 'lucide-react';
import GlassButton from '../components/common/GlassButton';
import GlassInput from '../components/common/GlassInput';

const Contact: React.FC = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
    trackAnalyticsEvent('page_view', {
      page_title: 'Contact',
      page_location: window.location.href,
      page_path: '/contact',
    });
  }, []);

  const [formData, setFormData] = useState({
    name: '',
    email: '',
    subject: '',
    message: '',
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission
    console.log('Form submitted:', formData);
    setFormData({ name: '', email: '', subject: '', message: '' });
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  return (
    <>
      <SEO
        title="Contact mQuiz - Get in Touch"
        description="Have questions? Contact the mQuiz team. We're here to help with any queries about our quiz learning platform."
        url="https://mquiz.uk/contact"
      />
      <div className="container-custom section-padding">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6 gradient-text">
            Contact Us
          </h1>
          <p className="text-lg text-slate-700 dark:text-slate-300 mb-12">
            Have questions or need assistance? We'd love to hear from you. Get in touch with our team and we'll respond as soon as possible.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-12">
            {/* Email */}
            <div className="bg-slate-100 dark:bg-slate-800/50 rounded-2xl p-6 border border-slate-200 dark:border-slate-700 hover:border-primary/50 transition-colors">
              <div className="flex items-center mb-4">
                <Mail className="w-8 h-8 text-primary mr-3" />
                <h3 className="text-xl font-bold text-slate-900 dark:text-white">Email</h3>
              </div>
              <p className="text-slate-700 dark:text-slate-300">
                <a href="mailto:support@mquiz.uk" className="text-primary hover:underline">
                  support@mquiz.uk
                </a>
              </p>
              <p className="text-sm text-slate-600 dark:text-slate-400 mt-2">We typically respond within 24 hours</p>
            </div>

            {/* Address */}
            <div className="bg-slate-100 dark:bg-slate-800/50 rounded-2xl p-6 border border-slate-200 dark:border-slate-700 hover:border-primary/50 transition-colors">
              <div className="flex items-center mb-4">
                <MapPin className="w-8 h-8 text-primary mr-3" />
                <h3 className="text-xl font-bold text-slate-900 dark:text-white">Address</h3>
              </div>
              <p className="text-slate-700 dark:text-slate-300 text-sm">
                Plot 624, Kingfem Plaza<br />
                GA 247, 1096 Ahmadu Bello Way<br />
                Abuja 900108, FCT, Nigeria
              </p>
            </div>

            {/* Follow Us */}
            <div className="bg-slate-100 dark:bg-slate-800/50 rounded-2xl p-6 border border-slate-200 dark:border-slate-700 hover:border-primary/50 transition-colors">
              <div className="flex items-center mb-4">
                <Phone className="w-8 h-8 text-primary mr-3" />
                <h3 className="text-xl font-bold text-slate-900 dark:text-white">Follow Us</h3>
              </div>
              <div className="space-y-2 text-sm">
                <p><a href="https://facebook.com/mquizonline" target="_blank" rel="noopener noreferrer" className="text-slate-700 dark:text-primary hover:underline">Facebook</a></p>
                <p><a href="https://youtube.com/@mquizonline" target="_blank" rel="noopener noreferrer" className="text-slate-700 dark:text-primary hover:underline">YouTube</a></p>
                <p><a href="https://instagram.com/mquiz.uk" target="_blank" rel="noopener noreferrer" className="text-slate-700 dark:text-primary hover:underline">Instagram</a></p>
                <p><a href="https://tiktok.com/@mquiz.uk" target="_blank" rel="noopener noreferrer" className="text-slate-700 dark:text-primary hover:underline">TikTok</a></p>
              </div>
            </div>
          </div>

          {/* Contact Form */}
          <div className="bg-slate-100 dark:bg-gradient-to-br dark:from-slate-800/50 dark:to-slate-900/50 rounded-2xl p-8 border border-slate-200 dark:border-slate-700">
            <h2 className="text-2xl font-bold mb-6 text-slate-900 dark:text-white">Send us a Message</h2>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                    Name
                  </label>
                  <GlassInput
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    placeholder="Your name"
                    required
                    className="bg-white dark:bg-slate-800/50"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                    Email
                  </label>
                  <GlassInput
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    placeholder="your@email.com"
                    required
                    className="bg-white dark:bg-slate-800/50"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                  Subject
                </label>
                <GlassInput
                  type="text"
                  name="subject"
                  value={formData.subject}
                  onChange={handleChange}
                  placeholder="How can we help?"
                  required
                  className="bg-white dark:bg-slate-800/50"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                  Message
                </label>
                <textarea
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  placeholder="Your message..."
                  rows={6}
                  required
                  className="w-full px-4 py-3 rounded-lg bg-white dark:bg-slate-800/50 border border-slate-300 dark:border-slate-600 text-slate-900 dark:text-white placeholder-slate-400 dark:placeholder-slate-400 focus:outline-none focus:border-primary transition-colors"
                />
              </div>

              <GlassButton
                type="submit"
                variant="primary"
                size="lg"
                icon={<Send className="w-5 h-5" />}
                className="w-full"
              >
                Send Message
              </GlassButton>
            </form>
          </div>
        </div>
      </div>
    </>
  );
};

export default Contact;
