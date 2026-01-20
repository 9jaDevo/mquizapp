import React from 'react';
import { Link } from 'react-router-dom';
import { Facebook, Youtube, Mail, ArrowUp } from 'lucide-react';
import GlassInput from './GlassInput';
import GlassButton from './GlassButton';

const Footer: React.FC = () => {
  const scrollToTop = () => {
    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    window.scrollTo({ 
      top: 0, 
      behavior: prefersReducedMotion ? 'auto' : 'smooth' 
    });
  };

  return (
    <footer className="bg-slate-900 dark:bg-slate-950 text-slate-300">
      <div className="container-custom py-16">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-12">
          {/* Company Info */}
          <div>
            <div className="flex items-center space-x-2 mb-4">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary to-secondary flex items-center justify-center text-white font-bold text-xl">
                m
              </div>
              <span className="text-2xl font-heading font-bold text-white">
                Quiz
              </span>
            </div>
            <p className="text-sm text-slate-400 mb-6">
              Learn, engage, and earn rewards with the ultimate quiz learning platform.
              Challenge yourself and compete with friends.
            </p>
            <div className="flex space-x-4">
              <a
                href="https://facebook.com/mquizonline"
                target="_blank"
                rel="noopener noreferrer"
                className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-colors"
                aria-label="Facebook"
              >
                <Facebook className="w-5 h-5" />
              </a>
              <a
                href="https://youtube.com/@mquizonline"
                target="_blank"
                rel="noopener noreferrer"
                className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-colors"
                aria-label="YouTube"
              >
                <Youtube className="w-5 h-5" />
              </a>
              <a
                href="mailto:contact@mquiz.uk"
                className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-colors"
                aria-label="Email"
              >
                <Mail className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Product Links */}
          <div>
            <h3 className="text-white font-semibold mb-4">Product</h3>
            <ul className="space-y-3">
              <li>
                <Link
                  to="/features"
                  className="text-sm text-slate-400 hover:text-primary transition-colors"
                >
                  Features
                </Link>
              </li>
              <li>
                <Link
                  to="/download"
                  className="text-sm text-slate-400 hover:text-primary transition-colors"
                >
                  Download
                </Link>
              </li>
              <li>
                <Link
                  to="/blog"
                  className="text-sm text-slate-400 hover:text-primary transition-colors"
                >
                  Blog
                </Link>
              </li>
            </ul>
          </div>

          {/* Company Links */}
          <div>
            <h3 className="text-white font-semibold mb-4">Company</h3>
            <ul className="space-y-3">
              <li>
                <Link
                  to="/about"
                  className="text-sm text-slate-400 hover:text-primary transition-colors"
                >
                  About Us
                </Link>
              </li>
              <li>
                <Link
                  to="/contact"
                  className="text-sm text-slate-400 hover:text-primary transition-colors"
                >
                  Contact
                </Link>
              </li>
              <li>
                <Link
                  to="/privacy"
                  className="text-sm text-slate-400 hover:text-primary transition-colors"
                >
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link
                  to="/terms"
                  className="text-sm text-slate-400 hover:text-primary transition-colors"
                >
                  Terms & Conditions
                </Link>
              </li>
            </ul>
          </div>

          {/* Newsletter */}
          <div>
            <h3 className="text-white font-semibold mb-4">Stay Updated</h3>
            <p className="text-sm text-slate-400 mb-4">
              Subscribe to our newsletter for the latest updates and tips.
            </p>
            <form className="space-y-3">
              <GlassInput
                type="email"
                placeholder="Enter your email"
                className="bg-slate-800/50"
              />
              <GlassButton
                type="submit"
                variant="primary"
                size="sm"
                className="w-full"
              >
                Subscribe
              </GlassButton>
            </form>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="pt-8 border-t border-slate-800 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-sm text-slate-400">
            &copy; {new Date().getFullYear()} mQuiz. All rights reserved.
          </p>
          <button
            onClick={scrollToTop}
            className="p-2 rounded-lg bg-white/5 hover:bg-white/10 transition-colors"
            aria-label="Back to top"
          >
            <ArrowUp className="w-5 h-5" />
          </button>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
