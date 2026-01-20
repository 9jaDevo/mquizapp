import React from 'react';
import { Link } from 'react-router-dom';
import { motion } from 'framer-motion';
import { Calendar, Clock, User } from 'lucide-react';
import type { BlogPost } from '../../api/blog';
import GlassCard from '../common/GlassCard';
import { format } from 'date-fns';

interface BlogCardProps {
  post: BlogPost;
  index?: number;
}

const BlogCard: React.FC<BlogCardProps> = ({ post, index = 0 }) => {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.1 }}
    >
      <Link to={`/blog/${post.slug}`}>
        <GlassCard className="overflow-hidden h-full" hover>
          {/* Featured Image */}
          {post.featured_image && (
            <div className="relative h-48 overflow-hidden">
              <img
                src={post.featured_image}
                alt={post.title}
                className="w-full h-full object-cover transition-transform duration-300 hover:scale-110"
              />
              {/* Category Badge */}
              <div className="absolute top-4 left-4">
                <span className="px-3 py-1 rounded-full text-xs font-medium bg-primary text-white">
                  {post.category.name}
                </span>
              </div>
            </div>
          )}

          <div className="p-6">
            {/* Title */}
            <h3 className="text-xl font-heading font-bold text-slate-900 dark:text-white mb-3 line-clamp-2 hover:text-primary transition-colors">
              {post.title}
            </h3>

            {/* Excerpt */}
            <p className="text-slate-600 dark:text-slate-400 mb-4 line-clamp-3">
              {post.excerpt}
            </p>

            {/* Meta Info */}
            <div className="flex flex-wrap items-center gap-4 text-sm text-slate-500 dark:text-slate-400">
              {post.author && (
                <div className="flex items-center gap-2">
                  <User className="w-4 h-4" />
                  <span>{post.author.name}</span>
                </div>
              )}
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4" />
                <span>{format(new Date(post.created_at), 'MMM dd, yyyy')}</span>
              </div>
              {post.reading_time && (
                <div className="flex items-center gap-2">
                  <Clock className="w-4 h-4" />
                  <span>{post.reading_time} min read</span>
                </div>
              )}
            </div>

            {/* Tags */}
            {post.tags && post.tags.length > 0 && (
              <div className="flex flex-wrap gap-2 mt-4">
                {post.tags.slice(0, 3).map((tag, i) => (
                  <span
                    key={i}
                    className="px-2 py-1 text-xs rounded-md bg-primary/10 text-primary dark:bg-primary/20"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            )}
          </div>
        </GlassCard>
      </Link>
    </motion.div>
  );
};

export default BlogCard;
