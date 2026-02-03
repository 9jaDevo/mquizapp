import React, { useEffect } from 'react';
import SEO from '../components/common/SEO';
import { trackAnalyticsEvent } from '../utils/analytics';

const Terms: React.FC = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
    trackAnalyticsEvent('page_view', {
      page_title: 'Terms & Conditions',
      page_location: window.location.href,
      page_path: '/terms',
    });
  }, []);

  return (
    <>
      <SEO
        title="Terms & Conditions - mQuiz"
        description="Read mQuiz's terms and conditions to understand the rules and guidelines for using our platform."
        url="https://mquiz.uk/terms"
      />
      <div className="container-custom section-padding">
        <div className="max-w-4xl mx-auto prose prose-invert">
          <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6">
            Terms & Conditions
          </h1>
          <p className="text-sm text-slate-500 dark:text-slate-400 mb-8">Effective Date: 01-June-2024</p>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">1. Introduction</h2>
            <p className="text-slate-700 dark:text-slate-300 mb-4">
              Welcome to mQuiz Learn and Earn ("we", "our", "us"). These Terms and Conditions ("Terms") govern your use of our mobile application and web version (collectively, the "Service"). By accessing or using the Service, you agree to comply with and be bound by these Terms.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">2. Use of the Service</h2>
            
            <h3 className="text-xl font-semibold mb-3">A. Eligibility</h3>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li>You must be at least 13 years old to use the Service. Using the Service, you represent and warrant meeting this age requirement.</li>
            </ul>

            <h3 className="text-xl font-semibold mb-3">B. Account Registration</h3>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li>You may need to register for an account to access certain Service features. You agree to provide accurate and complete information during the registration process and to keep your account information up-to-date.</li>
            </ul>

            <h3 className="text-xl font-semibold mb-3">C. Account Security</h3>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300">
              <li>You are responsible for maintaining the confidentiality of your account credentials and all activities under your account. You agree to notify us immediately of any unauthorized use of your account.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">3. User Conduct</h2>
            <p className="text-slate-700 dark:text-slate-300 mb-4">
              You agree not to use the Service for any unlawful or prohibited purpose, including but not limited to:
            </p>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li>Engaging in any activity that violates any applicable law or regulation.</li>
              <li>Infringing upon or violating our intellectual property rights or the intellectual property rights of others.</li>
              <li>Posting or transmitting any defamatory, obscene, indecent, or objectionable content.</li>
              <li>Attempting to interfere with the proper functioning of the Service, including by hacking, phishing, or other means.</li>
              <li>Using any automated means, including robots, spiders, or scrapers, to access the Service.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">4. Content</h2>
            
            <h3 className="text-xl font-semibold mb-3">A. User-Generated Content</h3>
            <p className="text-slate-700 dark:text-slate-300 mb-4">
              You may have the opportunity to post or submit content through the Service. You retain ownership of any content you post or submit. Still, you grant us a non-exclusive, royalty-free, worldwide license to use, reproduce, modify, and distribute such content to operate and improve the Service.
            </p>

            <h3 className="text-xl font-semibold mb-3">B. Prohibited Content</h3>
            <p className="text-slate-700 dark:text-slate-300 mb-3">You agree not to post or submit any content that:</p>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li>Is false, misleading, or deceptive.</li>
              <li>Promotes illegal activities or conduct.</li>
              <li>Contains viruses, malware, or other harmful software.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">5. Intellectual Property</h2>
            <p className="text-slate-700 dark:text-slate-300">
              The Service and its entire contents, features, and functionality (including but not limited to all information, software, text, displays, images, video, and audio) are owned by us or our licensors. They are protected by copyright, trademark, patent, trade secret, and other intellectual property laws. You may not use, copy, modify, or distribute any part of the Service without our written consent.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">6. Advertisements</h2>
            <p className="text-slate-700 dark:text-slate-300">
              We use Google AdMob to serve ads on our Service. By using the Service, you agree to display advertisements and AdMob's collection and use of data as described in our Privacy Policy.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">7. Termination</h2>
            <p className="text-slate-700 dark:text-slate-300">
              We reserve the right to terminate or suspend your account and access to the Service, without prior notice or liability, for any reason, including but not limited to your violation of these Terms.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">8. Disclaimer of Warranties</h2>
            <p className="text-slate-700 dark:text-slate-300">
              The Service is provided "as is" and "as available" without warranties of any kind, express or implied, including but not limited to implied warranties of merchantability, fitness for a particular purpose, and non-infringement. We do not warrant the Service being uninterrupted, error-free, or secure.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">9. Limitation of Liability</h2>
            <p className="text-slate-700 dark:text-slate-300">
              To the fullest extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, use, or other intangible losses resulting from your use of or inability to use the Service.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">10. Indemnification</h2>
            <p className="text-slate-700 dark:text-slate-300">
              You agree to indemnify and hold us harmless from and against any claims, liabilities, damages, losses, and expenses, including reasonable attorneys' fees, arising out of or in any way connected with your use of the Service or your violation of these Terms.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">11. Governing Law</h2>
            <p className="text-slate-700 dark:text-slate-300">
              These Terms and your use of the Service are governed by and construed under the laws of Nigeria. Any disputes arising from or relating to these Terms or the Service shall be resolved in the courts in FCT, Abuja.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">12. Changes to These Terms</h2>
            <p className="text-slate-700 dark:text-slate-300">
              We may update these Terms from time to time. We will notify you of any changes by posting the new Terms on this page and updating the effective date. Your continued use of the Service after such changes constitutes your acceptance of the new Terms.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">13. Contact Us</h2>
            <p className="text-slate-700 dark:text-slate-300 mb-4">If you have any questions or concerns about these Terms, don't hesitate to get in touch with us at:</p>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li>Email: <a href="mailto:support@mquiz.uk" className="text-primary hover:underline">support@mquiz.uk</a></li>
              <li>Address: Plot 624, Kingfem Plaza, GA 247, 1096 Ahmadu Bello Way, Abuja 900108, Federal Capital Territory, Nigeria</li>
            </ul>
            <p className="text-slate-700 dark:text-slate-300">
              By using our Service, you acknowledge that you have read and understood these Terms and agree to be bound by them.
            </p>
          </section>
        </div>
      </div>
    </>
  );
};

export default Terms;
