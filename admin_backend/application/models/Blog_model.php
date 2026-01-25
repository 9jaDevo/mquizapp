<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Blog_model extends CI_Model
{
    public function __construct()
    {
        parent::__construct();
        date_default_timezone_set(get_system_timezone());
    }

    /**
     * Get all blog posts with pagination and filters
     */
    public function get_posts($page = 1, $limit = 10, $category = null, $search = null, $sort = 'created_at', $order = 'DESC')
    {
        $offset = ($page - 1) * $limit;

        $this->db->select('bp.*, bc.id as category_id, bc.name as category_name, bc.slug as category_slug, 
                          ba.id as author_id, ba.name as author_name, ba.avatar as author_avatar, ba.bio as author_bio');
        $this->db->from('tbl_blog_posts bp');
        $this->db->join('tbl_blog_categories bc', 'bp.category_id = bc.id', 'left');
        $this->db->join('tbl_blog_authors ba', 'bp.author_id = ba.id', 'left');
        $this->db->where('bp.status', 'published');

        if (!empty($category)) {
            $this->db->where('bc.slug', $category);
        }

        if (!empty($search)) {
            $this->db->group_start();
            $this->db->like('bp.title', $search);
            $this->db->or_like('bp.excerpt', $search);
            $this->db->or_like('bp.content', $search);
            $this->db->group_end();
        }

        // Get total count before pagination
        $total_query = $this->db->get();
        $total_posts = $total_query->num_rows();

        $this->db->limit($limit, $offset);
        $this->db->order_by("bp.{$sort}", $order);

        $query = $this->db->get();
        $posts = $query->result_array();

        return array(
            'posts' => $posts,
            'total' => $total_posts,
            'page' => $page,
            'limit' => $limit,
            'pages' => ceil($total_posts / $limit)
        );
    }

    /**
     * Get single post by slug
     */
    public function get_post_by_slug($slug)
    {
        $this->db->select('bp.*, bc.id as category_id, bc.name as category_name, bc.slug as category_slug,
                          ba.id as author_id, ba.name as author_name, ba.avatar as author_avatar, ba.bio as author_bio');
        $this->db->from('tbl_blog_posts bp');
        $this->db->join('tbl_blog_categories bc', 'bp.category_id = bc.id', 'left');
        $this->db->join('tbl_blog_authors ba', 'bp.author_id = ba.id', 'left');
        $this->db->where('bp.slug', $slug);
        $this->db->where('bp.status', 'published');

        $query = $this->db->get();
        return $query->row_array();
    }

    /**
     * Get single post by ID
     */
    public function get_post_by_id($id)
    {
        $this->db->select('bp.*, bc.id as category_id, bc.name as category_name, bc.slug as category_slug,
                          ba.id as author_id, ba.name as author_name, ba.avatar as author_avatar, ba.bio as author_bio');
        $this->db->from('tbl_blog_posts bp');
        $this->db->join('tbl_blog_categories bc', 'bp.category_id = bc.id', 'left');
        $this->db->join('tbl_blog_authors ba', 'bp.author_id = ba.id', 'left');
        $this->db->where('bp.id', $id);
        $this->db->where('bp.status', 'published');

        $query = $this->db->get();
        return $query->row_array();
    }

    /**
     * Get featured posts
     */
    public function get_featured_posts($limit = 5)
    {
        $this->db->select('bp.*, bc.id as category_id, bc.name as category_name, bc.slug as category_slug,
                          ba.id as author_id, ba.name as author_name, ba.avatar as author_avatar, ba.bio as author_bio');
        $this->db->from('tbl_blog_posts bp');
        $this->db->join('tbl_blog_categories bc', 'bp.category_id = bc.id', 'left');
        $this->db->join('tbl_blog_authors ba', 'bp.author_id = ba.id', 'left');
        $this->db->where('bp.status', 'published');
        $this->db->where('bp.featured', 1);
        $this->db->limit($limit);
        $this->db->order_by('bp.created_at', 'DESC');

        $query = $this->db->get();
        return $query->result_array();
    }

    /**
     * Get related posts by category
     */
    public function get_related_posts($post_id, $category_id, $limit = 4)
    {
        $this->db->select('bp.*, bc.id as category_id, bc.name as category_name, bc.slug as category_slug,
                          ba.id as author_id, ba.name as author_name, ba.avatar as author_avatar, ba.bio as author_bio');
        $this->db->from('tbl_blog_posts bp');
        $this->db->join('tbl_blog_categories bc', 'bp.category_id = bc.id', 'left');
        $this->db->join('tbl_blog_authors ba', 'bp.author_id = ba.id', 'left');
        $this->db->where('bp.status', 'published');
        $this->db->where('bp.id !=', $post_id);
        $this->db->where('bp.category_id', $category_id);
        $this->db->limit($limit);
        $this->db->order_by('bp.created_at', 'DESC');

        $query = $this->db->get();
        return $query->result_array();
    }

    /**
     * Get all categories
     */
    public function get_categories()
    {
        $this->db->select('bc.*, COUNT(bp.id) as post_count');
        $this->db->from('tbl_blog_categories bc');
        $this->db->join('tbl_blog_posts bp', 'bc.id = bp.category_id AND bp.status = "published"', 'left');
        $this->db->where('bc.status', 'active');
        $this->db->group_by('bc.id');
        $this->db->order_by('bc.name', 'ASC');

        $query = $this->db->get();
        return $query->result_array();
    }

    /**
     * Get tags for a post
     */
    public function get_post_tags($post_id)
    {
        $this->db->select('tag');
        $this->db->from('tbl_blog_post_tags');
        $this->db->where('post_id', $post_id);
        $this->db->order_by('tag', 'ASC');

        $query = $this->db->get();
        $tags = $query->result_array();

        return array_map(function ($tag) {
            return $tag['tag'];
        }, $tags);
    }

    /**
     * Increment post view count
     */
    public function increment_views($post_id)
    {
        $this->db->set('views', 'views+1', FALSE);
        $this->db->where('id', $post_id);
        $this->db->update('tbl_blog_posts');

        return $this->get_post_views($post_id);
    }

    /**
     * Get current view count for post
     */
    public function get_post_views($post_id)
    {
        $query = $this->db->select('views')->from('tbl_blog_posts')->where('id', $post_id)->get();
        if ($query->num_rows() > 0) {
            return $query->row_array()['views'];
        }
        return 0;
    }

    /**
     * Calculate reading time in minutes
     */
    public function calculate_reading_time($content)
    {
        $word_count = str_word_count(strip_tags($content));
        $reading_time = ceil($word_count / 200); // Average reading speed: 200 words per minute
        return max(1, $reading_time);
    }

    /**
     * Format post data for API response
     */
    public function format_post($post)
    {
        if (empty($post)) {
            return null;
        }

        return array(
            'id' => (int) $post['id'],
            'title' => $post['title'],
            'slug' => $post['slug'],
            'excerpt' => $post['excerpt'],
            'content' => $post['content'],
            'featured_image' => $post['featured_image'],
            'author' => array(
                'id' => (int) $post['author_id'],
                'name' => $post['author_name'],
                'avatar' => $post['author_avatar'],
                'bio' => $post['author_bio']
            ),
            'category' => array(
                'id' => (int) $post['category_id'],
                'name' => $post['category_name'],
                'slug' => $post['category_slug']
            ),
            'tags' => $this->get_post_tags($post['id']),
            'reading_time' => $this->calculate_reading_time($post['content']),
            'views' => (int) $post['views'],
            'created_at' => $post['created_at'],
            'updated_at' => $post['updated_at'],
            'meta_title' => $post['meta_title'],
            'meta_description' => $post['meta_description'],
            'meta_keywords' => $post['meta_keywords']
        );
    }

    /**
     * Format category data for API response
     */
    public function format_category($category)
    {
        return array(
            'id' => (int) $category['id'],
            'name' => $category['name'],
            'slug' => $category['slug'],
            'description' => $category['description'],
            'post_count' => (int) $category['post_count']
        );
    }
}
