import React, { useEffect } from 'react';
import SEO from '../components/common/SEO';
import { trackAnalyticsEvent } from '../utils/analytics';

const Privacy: React.FC = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
    trackAnalyticsEvent('page_view', {
      page_title: 'Privacy Policy',
      page_location: window.location.href,
      page_path: '/privacy',
    });
  }, []);

  return (
    <>
      <SEO
        title="Privacy Policy - mQuiz"
        description="Read mQuiz's privacy policy to understand how we collect, use, and protect your personal information."
        url="https://mquiz.uk/privacy"
      />
      <div className="container-custom section-padding">
        <div className="max-w-4xl mx-auto prose prose-invert">
          <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6">
            Privacy Policy
          </h1>
          <p className="text-sm text-slate-500 dark:text-slate-400 mb-8">Effective Date: 01 June 2024</p>
          <p className="text-slate-700 dark:text-slate-300 mb-8">
            mQuiz ("we", "our", or "us") respects your privacy and is committed to protecting it. This Privacy Policy explains how we collect, use, and share information when you use our mobile application and related services (the "Service").
          </p>
          <p className="text-slate-700 dark:text-slate-300 mb-8">
            By accessing or using the Service, you agree to the practices described in this Privacy Policy.
          </p>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">1. Information We Collect</h2>
            
            <h3 className="text-xl font-semibold mb-3">A. Information You Provide</h3>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li><strong>Account Information:</strong> When you create an account, we may collect information such as your name, email address, phone number, and login credentials.</li>
              <li><strong>Profile Information:</strong> You may choose to provide additional details such as a profile photo or preferences.</li>
            </ul>

            <h3 className="text-xl font-semibold mb-3">B. Automatically Collected Information</h3>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li><strong>Usage Data:</strong> Information about how you interact with the app, including features used, screens viewed, and session duration.</li>
              <li><strong>Device Information:</strong> Information such as device model, operating system version, app version, and diagnostic data.</li>
            </ul>
            <p className="text-slate-700 dark:text-slate-300 mb-4">
              This information is collected using in-app technologies and third-party SDKs such as Google Firebase and Google AdMob. The app does not use traditional web browser cookies.
            </p>

            <h3 className="text-xl font-semibold mb-3">C. Advertising Information</h3>
            <p className="text-slate-700 dark:text-slate-300">
              We use Google AdMob to display advertisements. AdMob may collect device identifiers, ad interaction data, and approximate location information to deliver ads and measure their performance.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">2. How We Use Your Information</h2>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300">
              <li>To provide, operate, and maintain the Service.</li>
              <li>To improve app functionality, performance, and user experience.</li>
              <li>To understand usage trends and analyze app performance.</li>
              <li>To communicate important updates, notifications, or service-related messages.</li>
              <li>To display advertisements, which may be personalized or non-personalized depending on your consent choices.</li>
              <li>To comply with legal obligations and protect our rights.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">3. App Tracking Transparency (ATT)</h2>
            <p className="text-slate-700 dark:text-slate-300 mb-4">
              In accordance with Apple's App Tracking Transparency framework, we may request your permission to track your activity across apps and websites owned by other companies for advertising and measurement purposes.
            </p>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300">
              <li>You can choose to allow or deny tracking permission. If permission is denied, ads may still be displayed, but they may be less relevant.</li>
              <li>You can manage your tracking preferences at any time through your device settings.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">4. Sharing of Information</h2>
            <p className="text-slate-700 dark:text-slate-300 mb-4">We may share information in the following situations:</p>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li><strong>With Service Providers:</strong> Third-party providers that help us operate, analyze, and improve the Service (such as analytics and crash reporting).</li>
              <li><strong>With Advertising Partners:</strong> Third-party advertising partners such as Google AdMob to display ads and measure ad performance.</li>
              <li><strong>For Legal Reasons:</strong> When required by law or to protect the rights, safety, and security of our users and the Service.</li>
            </ul>
            <p className="text-slate-700 dark:text-slate-300">We do not sell your personal information.</p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">5. Your Choices and Controls</h2>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300">
              <li><strong>Account Management:</strong> You may access and update your account information within the app.</li>
              <li><strong>Ad Preferences:</strong> You can control ad personalization through your device settings or your Google account settings.</li>
              <li><strong>Account Deletion:</strong> You may request deletion of your account and associated data by contacting us at the email address below.</li>
            </ul>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">6. Data Security</h2>
            <p className="text-slate-700 dark:text-slate-300">
              We implement reasonable administrative, technical, and organizational safeguards to protect your information against unauthorized access, loss, misuse, or disclosure.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">7. Children's Privacy</h2>
            <p className="text-slate-700 dark:text-slate-300">
              Our Service is intended for a general audience and is not directed toward children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that such information has been collected, we will delete it promptly.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">8. Changes to This Privacy Policy</h2>
            <p className="text-slate-700 dark:text-slate-300">
              We may update this Privacy Policy from time to time. Any changes will be posted on this page and the effective date will be updated accordingly.
            </p>
          </section>

          <section className="mb-8">
            <h2 className="text-2xl font-bold mb-4">9. Contact Us</h2>
            <p className="text-slate-700 dark:text-slate-300 mb-4">If you have any questions or concerns about this Privacy Policy, please contact us:</p>
            <ul className="list-disc pl-6 text-slate-700 dark:text-slate-300 mb-4">
              <li>Email: <a href="mailto:support@mquiz.uk" className="text-primary hover:underline">support@mquiz.uk</a></li>
              <li>Address: Plot 624, Kingfem Plaza, GA 247, 1096 Ahmadu Bello Way, Abuja 900108, Federal Capital Territory, Nigeria</li>
            </ul>
            <p className="text-slate-700 dark:text-slate-300">
              By using the Service, you acknowledge that you have read and understood this Privacy Policy.
            </p>
          </section>
        </div>
      </div>
    </>
  );
};

export default Privacy;
