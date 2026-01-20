import apiClient from './client';

export interface BlogPost {
  id: number;
  title: string;
  slug: string;
  excerpt: string;
  content?: string;
  featured_image: string;
  author: {
    id: number;
    name: string;
    avatar: string;
    bio: string;
  };
  category: {
    id: number;
    name: string;
    slug: string;
  };
  tags: string[];
  reading_time?: number;
  views: number;
  created_at: string;
  updated_at: string;
  meta_title?: string;
  meta_description?: string;
  meta_keywords?: string;
}

export interface BlogCategory {
  id: number;
  name: string;
  slug: string;
  description: string;
  post_count: number;
}

export interface PaginationInfo {
  current_page: number;
  total_pages: number;
  total_posts: number;
  per_page: number;
  has_next: boolean;
  has_prev: boolean;
}

export interface BlogPostsParams {
  page?: number;
  limit?: number;
  category?: string;
  search?: string;
  sort?: string;
  order?: 'ASC' | 'DESC';
}

export interface BlogPostsResponse {
  success: boolean;
  data: {
    posts: BlogPost[];
    pagination: PaginationInfo;
  };
}

export interface BlogPostResponse {
  success: boolean;
  data: {
    post: BlogPost;
  };
}

export interface BlogCategoriesResponse {
  success: boolean;
  data: {
    categories: BlogCategory[];
  };
}

// Get all blog posts with pagination and filters
export const getBlogPosts = async (params: BlogPostsParams = {}): Promise<BlogPostsResponse> => {
  const response = await apiClient.get<BlogPostsResponse>('/api/blog/posts', { params });
  return response.data;
};

// Get single blog post by slug
export const getBlogPost = async (slug: string): Promise<BlogPostResponse> => {
  const response = await apiClient.get<BlogPostResponse>(`/api/blog/post/${slug}`);
  return response.data;
};

// Get all blog categories
export const getBlogCategories = async (): Promise<BlogCategoriesResponse> => {
  const response = await apiClient.get<BlogCategoriesResponse>('/api/blog/categories');
  return response.data;
};

// Get featured posts
export const getFeaturedPosts = async (limit = 5): Promise<BlogPostsResponse> => {
  const response = await apiClient.get<BlogPostsResponse>('/api/blog/featured', {
    params: { limit },
  });
  return response.data;
};

// Get related posts
export const getRelatedPosts = async (id: number, limit = 4): Promise<BlogPostsResponse> => {
  const response = await apiClient.get<BlogPostsResponse>(`/api/blog/related/${id}`, {
    params: { limit },
  });
  return response.data;
};

// Increment post view count
export const incrementPostViews = async (id: number): Promise<{ success: boolean; data: { views: number } }> => {
  const response = await apiClient.post(`/api/blog/post/${id}/view`);
  return response.data;
};
