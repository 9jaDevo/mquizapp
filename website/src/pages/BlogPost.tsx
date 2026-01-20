import React, { useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import useSWR from 'swr';
import { Calendar, Clock, User, ArrowLeft, Loader2 } from 'lucide-react';
import SEO from '../components/common/SEO';
import GlassCard from '../components/common/GlassCard';
import GlassButton from '../components/common/GlassButton';
import { getBlogPost, getRelatedPosts, incrementPostViews } from '../api/blog';
import { format } from 'date-fns';

const BlogPost: React.FC = () => {
  const { slug } = useParams<{ slug: string }>();

  // Fetch blog post
  const { data: postData, error: postError, isLoading: postLoading } = useSWR(
    slug ? `post-${slug}` : null,
    () => slug ? getBlogPost(slug) : null
  );

  const post = postData?.data.post;

  // Fetch related posts
  const { data: relatedData } = useSWR(
    post ? `related-${post.id}` : null,
    () => post ? getRelatedPosts(post.id, 3) : null
  );

  const relatedPosts = relatedData?.data.posts || [];

  // Increment view count
  useEffect(() => {
    if (post) {
      incrementPostViews(post.id).catch(console.error);
    }
  }, [post]);

  if (postLoading) {
    return (
      <div className="container-custom section-padding">
        <div className="flex justify-center items-center min-h-[400px]">
          <Loader2 className="w-12 h-12 animate-spin text-primary" />
        </div>
      </div>
    );
  }

  if (postError || !post) {
    return (
      <div className="container-custom section-padding">
        <GlassCard className="p-12 text-center">
          <h1 className="text-3xl font-bold mb-4">Post Not Found</h1>
          <p className="text-slate-600 dark:text-slate-400 mb-6">
            The blog post you're looking for doesn't exist or has been removed.
          </p>
          <GlassButton variant="primary" href="/blog">
            Back to Blog
          </GlassButton>
        </GlassCard>
      </div>
    );
  }

  return (
    <>
      <SEO
        title={post.meta_title || post.title}
        description={post.meta_description || post.excerpt}
        keywords={post.meta_keywords}
        url={`https://mquiz.uk/blog/${post.slug}`}
        type="article"
        image={post.featured_image}
        publishedTime={post.created_at}
        modifiedTime={post.updated_at}
      />

      <div className="container-custom section-padding">
        {/* Back Button */}
        <Link
          to="/blog"
          className="inline-flex items-center gap-2 text-primary hover:text-primary-dark mb-8 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
          <span>Back to Blog</span>
        </Link>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
          {/* Main Content */}
          <div className="lg:col-span-2">
            <motion.article
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
            >
              <GlassCard className="overflow-hidden">
                {/* Featured Image */}
                {post.featured_image && (
                  <img
                    src={post.featured_image}
                    alt={post.title}
                    className="w-full h-96 object-cover"
                  />
                )}

                <div className="p-8 md:p-12">
                  {/* Category */}
                  <Link
                    to={`/blog?category=${post.category.slug}`}
                    className="inline-block px-3 py-1 rounded-full text-sm font-medium bg-primary text-white mb-4"
                  >
                    {post.category.name}
                  </Link>

                  {/* Title */}
                  <h1 className="text-3xl md:text-4xl lg:text-5xl font-heading font-bold mb-6 text-slate-900 dark:text-white">
                    {post.title}
                  </h1>

                  {/* Meta Info */}
                  <div className="flex flex-wrap items-center gap-6 mb-8 pb-8 border-b border-slate-200 dark:border-slate-700">
                    {post.author && (
                      <div className="flex items-center gap-3">
                        <img
                          src={post.author.avatar}
                          alt={post.author.name}
                          className="w-12 h-12 rounded-full"
                        />
                        <div>
                          <div className="flex items-center gap-2">
                            <User className="w-4 h-4" />
                            <span className="font-medium">{post.author.name}</span>
                          </div>
                        </div>
                      </div>
                    )}
                    <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400">
                      <Calendar className="w-4 h-4" />
                      <span>{format(new Date(post.created_at), 'MMMM dd, yyyy')}</span>
                    </div>
                    {post.reading_time && (
                      <div className="flex items-center gap-2 text-slate-600 dark:text-slate-400">
                        <Clock className="w-4 h-4" />
                        <span>{post.reading_time} min read</span>
                      </div>
                    )}
                  </div>

                  {/* Content */}
                  <div
                    className="prose prose-lg dark:prose-invert max-w-none prose-headings:font-heading prose-a:text-primary prose-img:rounded-xl"
                    dangerouslySetInnerHTML={{ __html: post.content || '' }}
                  />

                  {/* Tags */}
                  {post.tags && post.tags.length > 0 && (
                    <div className="mt-12 pt-8 border-t border-slate-200 dark:border-slate-700">
                      <h3 className="text-lg font-semibold mb-4">Tags</h3>
                      <div className="flex flex-wrap gap-2">
                        {post.tags.map((tag, i) => (
                          <span
                            key={i}
                            className="px-3 py-1 rounded-full text-sm bg-primary/10 text-primary dark:bg-primary/20"
                          >
                            #{tag}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* Author Bio */}
                  {post.author && post.author.bio && (
                    <div className="mt-12 pt-8 border-t border-slate-200 dark:border-slate-700">
                      <div className="flex items-start gap-4">
                        <img
                          src={post.author.avatar}
                          alt={post.author.name}
                          className="w-16 h-16 rounded-full"
                        />
                        <div>
                          <h3 className="text-lg font-semibold mb-2">About {post.author.name}</h3>
                          <p className="text-slate-600 dark:text-slate-400">{post.author.bio}</p>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              </GlassCard>
            </motion.article>
          </div>

          {/* Sidebar */}
          <div className="lg:col-span-1">
            <div className="sticky top-24 space-y-8">
              {/* Related Posts */}
              {relatedPosts.length > 0 && (
                <GlassCard className="p-6">
                  <h3 className="text-xl font-heading font-bold mb-4">Related Posts</h3>
                  <div className="space-y-4">
                    {relatedPosts.map((relatedPost) => (
                      <Link
                        key={relatedPost.id}
                        to={`/blog/${relatedPost.slug}`}
                        className="block group"
                      >
                        <div className="flex gap-3">
                          {relatedPost.featured_image && (
                            <img
                              src={relatedPost.featured_image}
                              alt={relatedPost.title}
                              className="w-20 h-20 object-cover rounded-lg flex-shrink-0"
                            />
                          )}
                          <div>
                            <h4 className="font-semibold text-sm line-clamp-2 group-hover:text-primary transition-colors">
                              {relatedPost.title}
                            </h4>
                            <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">
                              {format(new Date(relatedPost.created_at), 'MMM dd, yyyy')}
                            </p>
                          </div>
                        </div>
                      </Link>
                    ))}
                  </div>
                </GlassCard>
              )}
            </div>
          </div>
        </div>
      </div>
    </>
  );
};

export default BlogPost;
