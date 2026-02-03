import React, { useState, useEffect } from 'react';
import SEO from '../components/common/SEO';
import { trackAnalyticsEvent } from '../utils/analytics';
import { sendContactEmail, validateContactForm, type ContactFormData } from '../utils/emailService';
import { Mail, Phone, MapPin, Send, AlertCircle, CheckCircle } from 'lucide-react';
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

  const [formData, setFormData] = useState<ContactFormData>({
    name: '',
    email: '',
    subject: '',
    message: '',
    phone: '',
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<{
    type: 'success' | 'error' | null;
    message: string;
  }>({
    type: null,
    message: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
    // Clear status when user starts typing again
    if (submitStatus.type) {
      setSubmitStatus({ type: null, message: '' });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSubmitStatus({ type: null, message: '' });

    try {
      // Validate form
      const validation = validateContactForm(formData);
      if (!validation.valid) {
        setSubmitStatus({
          type: 'error',
          message: validation.errors[0],
        });
        setIsSubmitting(false);
        return;
      }

      // Send email
      await sendContactEmail(formData);

      // Track successful submission
      trackAnalyticsEvent('contact_form_submitted', {
        form_type: 'contact',
        subject: formData.subject,
      });

      // Success message
      setSubmitStatus({
        type: 'success',
        message: 'Thank you for your message! We\'ll get back to you as soon as possible.',
      });

      // Reset form
      setFormData({
        name: '',
        email: '',
        subject: '',
        message: '',
        phone: '',
      });
    } catch (error) {
      console.error('Form submission error:', error);
      
      // Track failed submission
      trackAnalyticsEvent('contact_form_error', {
        form_type: 'contact',
        error_message: error instanceof Error ? error.message : 'Unknown error',
      });

      setSubmitStatus({
        type: 'error',
        message: 'Failed to send message. Please try again or contact us directly at support@mquiz.uk',
      });
    } finally {
      setIsSubmitting(false);
    }
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

            {/* Status Message */}
            {submitStatus.type && (
              <div className={`mb-6 p-4 rounded-lg flex items-start gap-3 ${
                submitStatus.type === 'success'
                  ? 'bg-green-50 dark:bg-green-500/10 border border-green-200 dark:border-green-500/20'
                  : 'bg-red-50 dark:bg-red-500/10 border border-red-200 dark:border-red-500/20'
              }`}>
                {submitStatus.type === 'success' ? (
                  <CheckCircle className="w-5 h-5 text-green-600 dark:text-green-400 flex-shrink-0 mt-0.5" />
                ) : (
                  <AlertCircle className="w-5 h-5 text-red-600 dark:text-red-400 flex-shrink-0 mt-0.5" />
                )}
                <p className={`text-sm ${
                  submitStatus.type === 'success'
                    ? 'text-green-700 dark:text-green-300'
                    : 'text-red-700 dark:text-red-300'
                }`}>
                  {submitStatus.message}
                </p>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                    Name <span className="text-red-500">*</span>
                  </label>
                  <GlassInput
                    type="text"
                    name="name"
                    value={formData.name}
                    onChange={handleChange}
                    placeholder="Your name"
                    required
                    disabled={isSubmitting}
                    className="bg-white dark:bg-slate-800/50"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                    Email <span className="text-red-500">*</span>
                  </label>
                  <GlassInput
                    type="email"
                    name="email"
                    value={formData.email}
                    onChange={handleChange}
                    placeholder="your@email.com"
                    required
                    disabled={isSubmitting}
                    className="bg-white dark:bg-slate-800/50"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                    Subject <span className="text-red-500">*</span>
                  </label>
                  <GlassInput
                    type="text"
                    name="subject"
                    value={formData.subject}
                    onChange={handleChange}
                    placeholder="How can we help?"
                    required
                    disabled={isSubmitting}
                    className="bg-white dark:bg-slate-800/50"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                    Phone <span className="text-slate-500">(Optional)</span>
                  </label>
                  <GlassInput
                    type="tel"
                    name="phone"
                    value={formData.phone}
                    onChange={handleChange}
                    placeholder="+234 (0) 123 456 7890"
                    disabled={isSubmitting}
                    className="bg-white dark:bg-slate-800/50"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-700 dark:text-slate-300 mb-2">
                  Message <span className="text-red-500">*</span>
                </label>
                <textarea
                  name="message"
                  value={formData.message}
                  onChange={handleChange}
                  placeholder="Your message..."
                  rows={6}
                  required
                  disabled={isSubmitting}
                  className="w-full px-4 py-3 rounded-lg bg-white dark:bg-slate-800/50 border border-slate-300 dark:border-slate-600 text-slate-900 dark:text-white placeholder-slate-400 dark:placeholder-slate-400 focus:outline-none focus:border-primary transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                />
              </div>

              <GlassButton
                type="submit"
                variant="primary"
                size="lg"
                icon={<Send className="w-5 h-5" />}
                className="w-full"
                disabled={isSubmitting}
              >
                {isSubmitting ? 'Sending...' : 'Send Message'}
              </GlassButton>
            </form>
          </div>
        </div>
      </div>
    </>
  );
};

export default Contact;
