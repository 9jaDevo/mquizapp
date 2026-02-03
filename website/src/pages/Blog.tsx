import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import useSWR from 'swr';
import SEO from '../components/common/SEO';
import BlogCard from '../components/blog/BlogCard';
import BlogSearch from '../components/blog/BlogSearch';
import GlassButton from '../components/common/GlassButton';
import GlassCard from '../components/common/GlassCard';
import { getBlogPosts, getBlogCategories } from '../api/blog';
import type { BlogCategory } from '../api/blog';
import { Loader2 } from 'lucide-react';
import { trackAnalyticsEvent } from '../utils/analytics';

const Blog: React.FC = () => {
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedCategory, setSelectedCategory] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  // Track page view
  useEffect(() => {
    trackAnalyticsEvent('page_view', {
      page_title: 'Blog',
      page_location: window.location.href,
      page_path: '/blog',
    });
  }, []);

  // Fetch blog posts
  const { data: postsData, error: postsError, isLoading: postsLoading } = useSWR(
    ['posts', currentPage, selectedCategory, searchQuery],
    () => getBlogPosts({
      page: currentPage,
      limit: 9,
      category: selectedCategory,
      search: searchQuery,
    })
  );

  // Fetch categories
  const { data: categoriesData } = useSWR('categories', getBlogCategories);

  const posts = postsData?.data.posts || [];
  const pagination = postsData?.data.pagination;
  const categories: BlogCategory[] = categoriesData?.data.categories || [];

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    setCurrentPage(1);
  };

  const handleCategoryFilter = (categorySlug: string) => {
    setSelectedCategory(categorySlug === selectedCategory ? '' : categorySlug);
    setCurrentPage(1);
  };

  // Create schema markup for blog collection
  const blogCollectionSchema = {
    '@context': 'https://schema.org',
    '@type': 'Blog',
    name: 'mQuiz Blog',
    description: 'Learning tips, strategies, and insights for gamified education',
    url: 'https://mquiz.uk/blog',
    image: 'https://mquiz.uk/og-image.jpg',
    mainEntity: {
      '@type': 'BlogPosting',
      headline: 'Latest Articles',
      description: 'Read the latest articles, tips, and insights on gamified learning',
      image: 'https://mquiz.uk/og-image.jpg',
    },
  };

  return (
    <>
      <SEO
        title="mQuiz Blog - Learning Tips, Updates & Insights"
        description="Read the latest articles, tips, and insights on gamified learning, quiz strategies, and educational technology."
        url="https://mquiz.uk/blog"
        type="Blog"
        structuredData={blogCollectionSchema}
      />

      <div className="container-custom section-padding">
        {/* Header */}
        <motion.div
          className="text-center max-w-3xl mx-auto mb-12"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <h1 className="text-4xl md:text-5xl font-heading font-bold mb-6">
            mQuiz <span className="gradient-text">Blog</span>
          </h1>
          <p className="text-lg text-slate-600 dark:text-slate-300">
            Discover tips, strategies, and insights to maximize your learning experience.
          </p>
        </motion.div>

        {/* Search and Filters */}
        <div className="mb-12">
          <div className="max-w-2xl mx-auto mb-8">
            <BlogSearch onSearch={handleSearch} />
          </div>

          {/* Category Filter */}
          {categories.length > 0 && (
            <div className="flex flex-wrap justify-center gap-3">
              <button
                onClick={() => handleCategoryFilter('')}
                className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
                  !selectedCategory
                    ? 'bg-primary text-white'
                    : 'bg-white/10 hover:bg-white/20 dark:bg-slate-800/50'
                }`}
              >
                All
              </button>
              {categories.map((category) => (
                <button
                  key={category.id}
                  onClick={() => handleCategoryFilter(category.slug)}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-all ${
                    selectedCategory === category.slug
                      ? 'bg-primary text-white'
                      : 'bg-white/10 hover:bg-white/20 dark:bg-slate-800/50'
                  }`}
                >
                  {category.name} ({category.post_count})
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Loading State */}
        {postsLoading && (
          <div className="flex justify-center items-center min-h-[400px]">
            <Loader2 className="w-12 h-12 animate-spin text-primary" />
          </div>
        )}

        {/* Error State */}
        {postsError && (
          <GlassCard className="p-8 text-center">
            <p className="text-red-600 dark:text-red-400 mb-4">
              Failed to load blog posts. Please try again later.
            </p>
            <p className="text-sm text-slate-600 dark:text-slate-400">
              Make sure the API backend is running and VITE_API_BASE_URL is configured correctly.
            </p>
          </GlassCard>
        )}

        {/* Blog Posts Grid */}
        {!postsLoading && !postsError && posts.length > 0 && (
          <>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
              {posts.map((post, index) => (
                <BlogCard key={post.id} post={post} index={index} />
              ))}
            </div>

            {/* Pagination */}
            {pagination && pagination.total_pages > 1 && (
              <div className="flex justify-center items-center gap-4">
                <GlassButton
                  onClick={() => setCurrentPage(currentPage - 1)}
                  disabled={!pagination.has_prev}
                  variant="outline"
                >
                  Previous
                </GlassButton>
                <span className="text-slate-600 dark:text-slate-400">
                  Page {pagination.current_page} of {pagination.total_pages}
                </span>
                <GlassButton
                  onClick={() => setCurrentPage(currentPage + 1)}
                  disabled={!pagination.has_next}
                  variant="outline"
                >
                  Next
                </GlassButton>
              </div>
            )}
          </>
        )}

        {/* No Posts Found */}
        {!postsLoading && !postsError && posts.length === 0 && (
          <GlassCard className="p-12 text-center">
            <p className="text-xl text-slate-600 dark:text-slate-400">
              No blog posts found. {searchQuery && 'Try a different search term.'}
            </p>
          </GlassCard>
        )}
      </div>
    </>
  );
};

export default Blog;
