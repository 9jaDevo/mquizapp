<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Blog extends CI_Controller
{
    public function __construct()
    {
        parent::__construct();
        if (!$this->session->userdata('isLoggedIn')) {
            redirect('/');
        }
        $this->load->database();
        $this->load->model('Blog_model');
        $this->load->helper('seo_helper');

        date_default_timezone_set(get_system_timezone());

        $this->result = $this->db->where('auth_id', $this->session->userdata('authId'))->get('tbl_authenticate')->row_array();
    }

    // ==================== BLOG POSTS ====================

    public function posts()
    {
        if (!has_permissions('read', 'blog')) {
            redirect('/', 'refresh');
        }

        $this->load->view('header');
        $this->load->view('blog/posts');
        $this->load->view('footer');
    }

    public function get_posts()
    {
        $offset = 0;
        $limit = 10;
        $sort = 'id';
        $order = 'DESC';
        $where = '';

        if ($this->input->post('offset'))
            $offset = $this->input->post('offset');
        if ($this->input->post('limit'))
            $limit = $this->input->post('limit');
        if ($this->input->post('sort'))
            $sort = $this->input->post('sort');
        if ($this->input->post('order'))
            $order = $this->input->post('order');
        if ($this->input->post('search')) {
            $search = $this->input->post('search');
            $where = " AND (p.title LIKE '%" . $search . "%' OR p.slug LIKE '%" . $search . "%' OR a.name LIKE '%" . $search . "%')";
        }
        if ($this->input->post('category')) {
            $category = $this->input->post('category');
            $where .= " AND p.category_id = " . $category;
        }
        if ($this->input->post('status')) {
            $status = $this->input->post('status');
            $where .= " AND p.status = '" . $status . "'";
        }

        $join = "LEFT JOIN tbl_blog_authors a ON a.id = p.author_id 
                 LEFT JOIN tbl_blog_categories c ON c.id = p.category_id";

        $query = $this->db->query("SELECT COUNT(p.id) as total FROM tbl_blog_posts p $join WHERE 1=1 $where");
        $res = $query->result();
        foreach ($res as $row1) {
            $total = $row1->total;
        }

        $query1 = $this->db->query("SELECT p.*, a.name as author_name, c.name as category_name 
                                     FROM tbl_blog_posts p 
                                     $join 
                                     WHERE 1=1 $where 
                                     ORDER BY p.$sort $order 
                                     LIMIT $offset, $limit");
        $res1 = $query1->result();

        $bulkData = array();
        $bulkData['total'] = $total;
        $rows = array();
        $tempRow = array();
        $count = 1;

        foreach ($res1 as $row) {
            $image = (!empty($row->featured_image)) ? '<img src="' . $row->featured_image . '" width="60">' : '-';
            $status_badge = '';
            if ($row->status == 'published') {
                $status_badge = '<span class="badge badge-success">Published</span>';
            } elseif ($row->status == 'draft') {
                $status_badge = '<span class="badge badge-warning">Draft</span>';
            } else {
                $status_badge = '<span class="badge badge-secondary">Archived</span>';
            }

            $featured = $row->featured ? '<span class="badge badge-primary">Featured</span>' : '';

            $operate = '<a class="btn btn-icon btn-sm btn-primary edit-data" data-id="' . $row->id . '" data-toggle="modal" data-target="#editDataModal" title="Edit"><i class="fa fa-edit"></i></a>';
            $operate .= ' <a class="btn btn-icon btn-sm btn-danger delete-data" data-id="' . $row->id . '" title="Delete"><i class="fa fa-trash"></i></a>';
            $operate .= ' <a class="btn btn-icon btn-sm btn-info" href="' . base_url('blog-preview/' . $row->id) . '" target="_blank" title="Preview"><i class="fa fa-eye"></i></a>';

            $tempRow['id'] = $row->id;
            $tempRow['image'] = $image;
            $tempRow['title'] = $row->title;
            $tempRow['slug'] = $row->slug;
            $tempRow['category'] = $row->category_name ?? '-';
            $tempRow['author'] = $row->author_name ?? '-';
            $tempRow['status'] = $status_badge;
            $tempRow['featured'] = $featured;
            $tempRow['views'] = $row->views;
            $tempRow['created_at'] = date('M d, Y', strtotime($row->created_at));
            $tempRow['operate'] = $operate;
            $rows[] = $tempRow;
            $count++;
        }

        $bulkData['rows'] = $rows;
        echo json_encode($bulkData);
    }

    public function create_post()
    {
        if (!has_permissions('create', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $this->form_validation->set_rules('title', 'Title', 'required');
        $this->form_validation->set_rules('content', 'Content', 'required');
        $this->form_validation->set_rules('category_id', 'Category', 'required');
        $this->form_validation->set_rules('author_id', 'Author', 'required');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = validation_errors();
        } else {
            $slug = url_title($this->input->post('title'), 'dash', true);

            // Check if slug exists
            $exists = $this->db->where('slug', $slug)->get('tbl_blog_posts')->num_rows();
            if ($exists > 0) {
                $slug = $slug . '-' . time();
            }

            $data = array(
                'title' => $this->input->post('title'),
                'slug' => $slug,
                'excerpt' => $this->input->post('excerpt'),
                'content' => $this->input->post('content'),
                'featured_image' => $this->input->post('featured_image'),
                'category_id' => $this->input->post('category_id'),
                'author_id' => $this->input->post('author_id'),
                'status' => $this->input->post('status', true) ?? 'draft',
                'featured' => $this->input->post('featured') ?? 0,
                'meta_title' => $this->input->post('meta_title'),
                'meta_description' => $this->input->post('meta_description'),
                'meta_keywords' => $this->input->post('meta_keywords'),
                'publish_date' => date('Y-m-d H:i:s'),
            );

            // Auto-generate keywords if empty
            if (empty($data['meta_keywords'])) {
                $keywords = generate_keywords($data['content'], $data['title']);
                $data['meta_keywords'] = implode(', ', $keywords);
                $keyword_source = 'auto';
            } else {
                $keyword_source = 'editor';
            }

            // Auto-generate meta description if empty
            if (empty($data['meta_description'])) {
                $data['meta_description'] = auto_meta_description($data['content']);
            }

            $this->db->insert('tbl_blog_posts', $data);
            $post_id = $this->db->insert_id();

            // Log SEO activity
            if ($post_id) {
                log_seo_activity($post_id, $keyword_source, $data['meta_keywords']);
            }

            // Handle tags
            if ($this->input->post('tags')) {
                $tags = explode(',', $this->input->post('tags'));
                foreach ($tags as $tag) {
                    $tag = trim($tag);
                    if (!empty($tag)) {
                        $this->db->insert('tbl_blog_post_tags', [
                            'post_id' => $post_id,
                            'tag' => $tag
                        ]);
                    }
                }
            }

            $response['error'] = false;
            $response['message'] = 'Blog post created successfully';
        }
        echo json_encode($response);
    }

    public function update_post()
    {
        if (!has_permissions('update', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $this->form_validation->set_rules('id', 'Post ID', 'required');
        $this->form_validation->set_rules('title', 'Title', 'required');
        $this->form_validation->set_rules('content', 'Content', 'required');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = validation_errors();
        } else {
            $id = $this->input->post('id');
            $data = array(
                'title' => $this->input->post('title'),
                'excerpt' => $this->input->post('excerpt'),
                'content' => $this->input->post('content'),
                'featured_image' => $this->input->post('featured_image'),
                'category_id' => $this->input->post('category_id'),
                'author_id' => $this->input->post('author_id'),
                'status' => $this->input->post('status'),
                'featured' => $this->input->post('featured') ?? 0,
                'meta_title' => $this->input->post('meta_title'),
                'meta_description' => $this->input->post('meta_description'),
                'meta_keywords' => $this->input->post('meta_keywords'),
            );

            // Auto-generate keywords if empty
            if (empty($data['meta_keywords'])) {
                $keywords = generate_keywords($data['content'], $data['title']);
                $data['meta_keywords'] = implode(', ', $keywords);
                $keyword_source = 'auto';
            } else {
                $keyword_source = 'editor';
            }

            $this->db->where('id', $id)->update('tbl_blog_posts', $data);

            // Update SEO activity
            log_seo_activity($id, $keyword_source, $data['meta_keywords']);

            // Update tags
            $this->db->where('post_id', $id)->delete('tbl_blog_post_tags');
            if ($this->input->post('tags')) {
                $tags = explode(',', $this->input->post('tags'));
                foreach ($tags as $tag) {
                    $tag = trim($tag);
                    if (!empty($tag)) {
                        $this->db->insert('tbl_blog_post_tags', [
                            'post_id' => $id,
                            'tag' => $tag
                        ]);
                    }
                }
            }

            $response['error'] = false;
            $response['message'] = 'Blog post updated successfully';
        }
        echo json_encode($response);
    }

    public function delete_post()
    {
        if (!has_permissions('delete', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $id = $this->input->post('id');
        $this->db->where('id', $id)->delete('tbl_blog_posts');
        $this->db->where('post_id', $id)->delete('tbl_blog_post_tags');

        $response['error'] = false;
        $response['message'] = 'Blog post deleted successfully';
        echo json_encode($response);
    }

    // ==================== CATEGORIES ====================

    public function categories()
    {
        if (!has_permissions('read', 'blog')) {
            redirect('/', 'refresh');
        }

        $this->load->view('header');
        $this->load->view('blog/categories');
        $this->load->view('footer');
    }

    public function get_categories()
    {
        $categories = $this->Blog_model->get_categories();
        $data = array();
        foreach ($categories as $category) {
            $operate = '<button class="btn btn-icon btn-sm btn-primary edit-category" data-id="' . $category['id'] . '"><i class="fa fa-edit"></i></button>';
            $operate .= ' <button class="btn btn-icon btn-sm btn-danger delete-category" data-id="' . $category['id'] . '"><i class="fa fa-trash"></i></button>';

            $status = $category['status'] == 'active' ? '<span class="badge badge-success">Active</span>' : '<span class="badge badge-danger">Inactive</span>';

            $data[] = array(
                'id' => $category['id'],
                'name' => $category['name'],
                'slug' => $category['slug'],
                'description' => substr($category['description'] ?? '', 0, 100) . '...',
                'post_count' => $category['post_count'] ?? 0,
                'status' => $status,
                'operate' => $operate
            );
        }
        echo json_encode(['total' => count($data), 'rows' => $data]);
    }

    public function create_category()
    {
        if (!has_permissions('create', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $this->form_validation->set_rules('name', 'Name', 'required');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = validation_errors();
        } else {
            $slug = url_title($this->input->post('name'), 'dash', true);

            $data = array(
                'name' => $this->input->post('name'),
                'slug' => $slug,
                'description' => $this->input->post('description'),
                'status' => $this->input->post('status') ?? 'active'
            );

            $this->db->insert('tbl_blog_categories', $data);
            $response['error'] = false;
            $response['message'] = 'Category created successfully';
        }
        echo json_encode($response);
    }

    public function update_category()
    {
        if (!has_permissions('update', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $id = $this->input->post('id');
        $data = array(
            'name' => $this->input->post('name'),
            'description' => $this->input->post('description'),
            'status' => $this->input->post('status')
        );

        $this->db->where('id', $id)->update('tbl_blog_categories', $data);
        $response['error'] = false;
        $response['message'] = 'Category updated successfully';
        echo json_encode($response);
    }

    public function delete_category()
    {
        if (!has_permissions('delete', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $id = $this->input->post('id');
        $this->db->where('id', $id)->delete('tbl_blog_categories');
        $response['error'] = false;
        $response['message'] = 'Category deleted successfully';
        echo json_encode($response);
    }

    // ==================== AUTHORS ====================

    public function authors()
    {
        if (!has_permissions('read', 'blog')) {
            redirect('/', 'refresh');
        }

        $this->load->view('header');
        $this->load->view('blog/authors');
        $this->load->view('footer');
    }

    public function get_authors()
    {
        $query = $this->db->get('tbl_blog_authors');
        $authors = $query->result_array();

        $data = array();
        foreach ($authors as $author) {
            $operate = '<button class="btn btn-icon btn-sm btn-primary edit-author" data-id="' . $author['id'] . '"><i class="fa fa-edit"></i></button>';
            $operate .= ' <button class="btn btn-icon btn-sm btn-danger delete-author" data-id="' . $author['id'] . '"><i class="fa fa-trash"></i></button>';

            $status = $author['status'] == 'active' ? '<span class="badge badge-success">Active</span>' : '<span class="badge badge-danger">Inactive</span>';
            $avatar = !empty($author['avatar']) ? '<img src="' . $author['avatar'] . '" width="40" class="rounded-circle">' : '-';

            $data[] = array(
                'id' => $author['id'],
                'avatar' => $avatar,
                'name' => $author['name'],
                'email' => $author['email'],
                'status' => $status,
                'created_at' => date('M d, Y', strtotime($author['created_at'])),
                'operate' => $operate
            );
        }
        echo json_encode(['total' => count($data), 'rows' => $data]);
    }

    public function create_author()
    {
        if (!has_permissions('create', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $this->form_validation->set_rules('name', 'Name', 'required');
        $this->form_validation->set_rules('email', 'Email', 'required|valid_email|is_unique[tbl_blog_authors.email]');

        if (!$this->form_validation->run()) {
            $response['error'] = true;
            $response['message'] = validation_errors();
        } else {
            $social_links = array(
                'twitter' => $this->input->post('twitter'),
                'linkedin' => $this->input->post('linkedin'),
                'github' => $this->input->post('github'),
                'website' => $this->input->post('website')
            );

            $data = array(
                'name' => $this->input->post('name'),
                'email' => $this->input->post('email'),
                'avatar' => $this->input->post('avatar'),
                'bio' => $this->input->post('bio'),
                'social_links' => json_encode($social_links),
                'status' => $this->input->post('status') ?? 'active'
            );

            $this->db->insert('tbl_blog_authors', $data);
            $response['error'] = false;
            $response['message'] = 'Author created successfully';
        }
        echo json_encode($response);
    }

    public function update_author()
    {
        if (!has_permissions('update', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $id = $this->input->post('id');
        $social_links = array(
            'twitter' => $this->input->post('twitter'),
            'linkedin' => $this->input->post('linkedin'),
            'github' => $this->input->post('github'),
            'website' => $this->input->post('website')
        );

        $data = array(
            'name' => $this->input->post('name'),
            'email' => $this->input->post('email'),
            'avatar' => $this->input->post('avatar'),
            'bio' => $this->input->post('bio'),
            'social_links' => json_encode($social_links),
            'status' => $this->input->post('status')
        );

        $this->db->where('id', $id)->update('tbl_blog_authors', $data);
        $response['error'] = false;
        $response['message'] = 'Author updated successfully';
        echo json_encode($response);
    }

    public function delete_author()
    {
        if (!has_permissions('delete', 'blog')) {
            $response['error'] = true;
            $response['message'] = 'Permission denied';
            echo json_encode($response);
            return;
        }

        $id = $this->input->post('id');
        $this->db->where('id', $id)->delete('tbl_blog_authors');
        $response['error'] = false;
        $response['message'] = 'Author deleted successfully';
        echo json_encode($response);
    }

    // ==================== SEO ANALYTICS ====================

    public function seo_analytics()
    {
        if (!has_permissions('read', 'blog')) {
            redirect('/', 'refresh');
        }

        $this->load->view('header');
        $this->load->view('blog/seo_analytics');
        $this->load->view('footer');
    }

    public function get_seo_analytics()
    {
        $query = $this->db->query("
            SELECT s.*, p.title, p.slug 
            FROM tbl_blog_seo_analytics s
            LEFT JOIN tbl_blog_posts p ON p.id = s.post_id
            ORDER BY s.id DESC
        ");
        $analytics = $query->result_array();

        $data = array();
        foreach ($analytics as $row) {
            $source_badge = $row['keyword_source'] == 'auto'
                ? '<span class="badge badge-info">Auto-Generated</span>'
                : '<span class="badge badge-success">Editor</span>';

            $data[] = array(
                'id' => $row['id'],
                'post_title' => $row['title'] ?? 'Deleted Post',
                'keyword_source' => $source_badge,
                'keywords' => substr($row['keywords_generated'] ?? '', 0, 100) . '...',
                'keyword_count' => $row['keyword_count'],
                'ai_bot_hits' => $row['ai_bot_hits'],
                'human_views' => $row['human_views'],
                'avg_time' => gmdate('i:s', $row['avg_time_on_page']),
                'last_updated' => date('M d, Y H:i', strtotime($row['last_updated']))
            );
        }
        echo json_encode(['total' => count($data), 'rows' => $data]);
    }

    // ==================== UTILITIES ====================

    public function upload_image()
    {
        if (!empty($_FILES['file']['name'])) {
            $config['upload_path'] = FCPATH . 'upload/blog/';
            $config['allowed_types'] = 'jpg|jpeg|png|gif|webp';
            $config['max_size'] = 5120; // 5MB
            $config['file_name'] = time() . '_' . $_FILES['file']['name'];

            if (!is_dir($config['upload_path'])) {
                mkdir($config['upload_path'], 0777, true);
            }

            $this->load->library('upload', $config);

            if ($this->upload->do_upload('file')) {
                $data = $this->upload->data();
                $response['error'] = false;
                $response['file_path'] = base_url('upload/blog/' . $data['file_name']);
                $response['message'] = 'Image uploaded successfully';
            } else {
                $response['error'] = true;
                $response['message'] = $this->upload->display_errors();
            }
        } else {
            $response['error'] = true;
            $response['message'] = 'No file selected';
        }
        echo json_encode($response);
    }

    public function get_post_by_id()
    {
        $id = $this->input->post('id');
        $post = $this->db->where('id', $id)->get('tbl_blog_posts')->row_array();

        // Get tags
        $tags = $this->db->where('post_id', $id)->get('tbl_blog_post_tags')->result_array();
        $post['tags'] = implode(', ', array_column($tags, 'tag'));

        echo json_encode($post);
    }

    public function get_category_by_id()
    {
        $id = $this->input->post('id');
        $category = $this->db->where('id', $id)->get('tbl_blog_categories')->row_array();
        echo json_encode($category);
    }

    public function get_author_by_id()
    {
        $id = $this->input->post('id');
        $author = $this->db->where('id', $id)->get('tbl_blog_authors')->row_array();
        if ($author && !empty($author['social_links'])) {
            $social = json_decode($author['social_links'], true);
            $author = array_merge($author, $social);
        }
        echo json_encode($author);
    }
}
