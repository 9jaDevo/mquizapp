<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no">

    <title>Blog Posts | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

    <?php base_url() . include '../include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include '../header.php'; ?>

            <section class="section">
                <div class="section-header">
                    <h1>Blog Posts</h1>
                </div>
                <div class="section-body">
                    <div class="row">
                        <div class="col-12">
                            <div class="card">
                                <div class="card-header">
                                    <h4>Manage Blog Posts</h4>
                                    <div class="card-header-action">
                                        <button class="btn btn-primary" data-toggle="modal" data-target="#createPostModal">
                                            <i class="fas fa-plus"></i> Create New Post
                                        </button>
                                    </div>
                                </div>
                                <div class="card-body">
                                    <div class="row mb-3">
                                        <div class="col-md-3">
                                            <select id="filter_category" class="form-control">
                                                <option value="">All Categories</option>
                                                <?php
                                                $categories = $this->db->get('tbl_blog_categories')->result_array();
                                                foreach ($categories as $cat) {
                                                    echo '<option value="' . $cat['id'] . '">' . $cat['name'] . '</option>';
                                                }
                                                ?>
                                            </select>
                                        </div>
                                        <div class="col-md-3">
                                            <select id="filter_status" class="form-control">
                                                <option value="">All Status</option>
                                                <option value="published">Published</option>
                                                <option value="draft">Draft</option>
                                                <option value="archived">Archived</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div id="toolbar">
                                        <button class="btn btn-danger btn-sm" id="delete_multiple_posts" disabled>
                                            <i class="fa fa-trash"></i> Delete Selected
                                        </button>
                                    </div>
                                    <table aria-describedby="mydesc" class='table-striped' id='post_list'
                                        data-toggle="table" data-url="<?= base_url('blog/get_posts') ?>"
                                        data-click-to-select="true" data-side-pagination="server"
                                        data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200, All]"
                                        data-search="true" data-toolbar="#toolbar"
                                        data-show-columns="true" data-show-refresh="true"
                                        data-trim-on-search="false" data-responsive="true"
                                        data-sort-name="id" data-sort-order="desc"
                                        data-pagination-successively-size="3" data-query-params="queryParams">
                                        <thead>
                                            <tr>
                                                <th scope="col" data-field="state" data-checkbox="true"></th>
                                                <th scope="col" data-field="id" data-sortable="true">ID</th>
                                                <th scope="col" data-field="image">Image</th>
                                                <th scope="col" data-field="title" data-sortable="true">Title</th>
                                                <th scope="col" data-field="slug">Slug</th>
                                                <th scope="col" data-field="category" data-sortable="true">Category</th>
                                                <th scope="col" data-field="author">Author</th>
                                                <th scope="col" data-field="status" data-sortable="true">Status</th>
                                                <th scope="col" data-field="featured">Featured</th>
                                                <th scope="col" data-field="views" data-sortable="true">Views</th>
                                                <th scope="col" data-field="created_at" data-sortable="true">Created</th>
                                                <th scope="col" data-field="operate">Actions</th>
                                            </tr>
                                        </thead>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Create Post Modal -->
            <div class="modal fade" id="createPostModal" tabindex="-1" role="dialog">
                <div class="modal-dialog modal-xl" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Create New Post</h5>
                            <button type="button" class="close" data-dismiss="modal">
                                <span>&times;</span>
                            </button>
                        </div>
                        <form id="createPostForm" method="post" enctype="multipart/form-data">
                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <label>Title <span class="text-danger">*</span></label>
                                            <input type="text" name="title" class="form-control" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Excerpt</label>
                                            <textarea name="excerpt" class="form-control" rows="2"></textarea>
                                        </div>
                                        <div class="form-group">
                                            <label>Content <span class="text-danger">*</span></label>
                                            <textarea name="content" id="create_content" class="form-control" rows="15"></textarea>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Category <span class="text-danger">*</span></label>
                                            <select name="category_id" class="form-control" required>
                                                <option value="">Select Category</option>
                                                <?php foreach ($categories as $cat): ?>
                                                    <option value="<?= $cat['id'] ?>"><?= $cat['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Author <span class="text-danger">*</span></label>
                                            <select name="author_id" class="form-control" required>
                                                <option value="">Select Author</option>
                                                <?php
                                                $authors = $this->db->get('tbl_blog_authors')->result_array();
                                                foreach ($authors as $author):
                                                ?>
                                                    <option value="<?= $author['id'] ?>"><?= $author['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Status</label>
                                            <select name="status" class="form-control">
                                                <option value="draft">Draft</option>
                                                <option value="published">Published</option>
                                                <option value="archived">Archived</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <div class="custom-control custom-checkbox">
                                                <input type="checkbox" class="custom-control-input" id="create_featured" name="featured" value="1">
                                                <label class="custom-control-label" for="create_featured">Featured Post</label>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label>Featured Image</label>
                                            <input type="file" class="form-control" id="create_featured_image" accept="image/*">
                                            <input type="hidden" name="featured_image" id="create_featured_image_url">
                                            <div id="create_image_preview" class="mt-2"></div>
                                        </div>
                                        <div class="form-group">
                                            <label>Tags (comma separated)</label>
                                            <input type="text" name="tags" class="form-control" placeholder="technology, web, tutorial">
                                        </div>
                                        <h6 class="mt-4">SEO Settings</h6>
                                        <hr>
                                        <div class="form-group">
                                            <label>Meta Title</label>
                                            <input type="text" name="meta_title" class="form-control">
                                            <small class="text-muted">Leave empty to use post title</small>
                                        </div>
                                        <div class="form-group">
                                            <label>Meta Description</label>
                                            <textarea name="meta_description" class="form-control" rows="2"></textarea>
                                            <small class="text-muted">Auto-generated if empty</small>
                                        </div>
                                        <div class="form-group">
                                            <label>Meta Keywords</label>
                                            <input type="text" name="meta_keywords" class="form-control">
                                            <small class="text-muted">Auto-generated if empty</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                <button type="submit" class="btn btn-primary">Create Post</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Edit Post Modal -->
            <div class="modal fade" id="editDataModal" tabindex="-1" role="dialog">
                <div class="modal-dialog modal-xl" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title">Edit Post</h5>
                            <button type="button" class="close" data-dismiss="modal">
                                <span>&times;</span>
                            </button>
                        </div>
                        <form id="editPostForm" method="post">
                            <input type="hidden" name="id" id="edit_id">
                            <div class="modal-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="form-group">
                                            <label>Title <span class="text-danger">*</span></label>
                                            <input type="text" name="title" id="edit_title" class="form-control" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Excerpt</label>
                                            <textarea name="excerpt" id="edit_excerpt" class="form-control" rows="2"></textarea>
                                        </div>
                                        <div class="form-group">
                                            <label>Content <span class="text-danger">*</span></label>
                                            <textarea name="content" id="edit_content" class="form-control" rows="15"></textarea>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <label>Category <span class="text-danger">*</span></label>
                                            <select name="category_id" id="edit_category_id" class="form-control" required>
                                                <?php foreach ($categories as $cat): ?>
                                                    <option value="<?= $cat['id'] ?>"><?= $cat['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Author <span class="text-danger">*</span></label>
                                            <select name="author_id" id="edit_author_id" class="form-control" required>
                                                <?php foreach ($authors as $author): ?>
                                                    <option value="<?= $author['id'] ?>"><?= $author['name'] ?></option>
                                                <?php endforeach; ?>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Status</label>
                                            <select name="status" id="edit_status" class="form-control">
                                                <option value="draft">Draft</option>
                                                <option value="published">Published</option>
                                                <option value="archived">Archived</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <div class="custom-control custom-checkbox">
                                                <input type="checkbox" class="custom-control-input" id="edit_featured" name="featured" value="1">
                                                <label class="custom-control-label" for="edit_featured">Featured Post</label>
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label>Featured Image</label>
                                            <input type="file" class="form-control" id="edit_featured_image" accept="image/*">
                                            <input type="hidden" name="featured_image" id="edit_featured_image_url">
                                            <div id="edit_image_preview" class="mt-2"></div>
                                        </div>
                                        <div class="form-group">
                                            <label>Tags</label>
                                            <input type="text" name="tags" id="edit_tags" class="form-control">
                                        </div>
                                        <h6 class="mt-4">SEO Settings</h6>
                                        <hr>
                                        <div class="form-group">
                                            <label>Meta Title</label>
                                            <input type="text" name="meta_title" id="edit_meta_title" class="form-control">
                                        </div>
                                        <div class="form-group">
                                            <label>Meta Description</label>
                                            <textarea name="meta_description" id="edit_meta_description" class="form-control" rows="2"></textarea>
                                        </div>
                                        <div class="form-group">
                                            <label>Meta Keywords</label>
                                            <input type="text" name="meta_keywords" id="edit_meta_keywords" class="form-control">
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                <button type="submit" class="btn btn-primary">Update Post</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <script src="//cdn.ckeditor.com/4.16.2/full/ckeditor.js"></script>
            <script type="text/javascript">
                function queryParams(p) {
                    return {
                        limit: p.limit,
                        sort: p.sort,
                        order: p.order,
                        offset: p.offset,
                        search: p.search,
                        category: $('#filter_category').val(),
                        status: $('#filter_status').val()
                    };
                }

                $(document).ready(function() {
                    if (typeof CKEDITOR !== 'undefined') {
                        CKEDITOR.replace('create_content', {
                            height: 400,
                            toolbar: 'Full'
                        });
                        CKEDITOR.replace('edit_content', {
                            height: 400,
                            toolbar: 'Full'
                        });
                    }

                    $('#filter_category, #filter_status').on('change', function() {
                        $('#post_list').bootstrapTable('refresh');
                    });

                    $('#create_featured_image').on('change', function() {
                        var formData = new FormData();
                        formData.append('file', this.files[0]);
                        $.ajax({
                            url: '<?= base_url("blog/upload_image") ?>',
                            type: 'POST',
                            data: formData,
                            processData: false,
                            contentType: false,
                            success: function(response) {
                                var result = JSON.parse(response);
                                if (!result.error) {
                                    $('#create_featured_image_url').val(result.file_path);
                                    $('#create_image_preview').html('<img src="' + result.file_path + '" class="img-thumbnail" width="200">');
                                } else {
                                    alert(result.message);
                                }
                            }
                        });
                    });

                    $('#edit_featured_image').on('change', function() {
                        var formData = new FormData();
                        formData.append('file', this.files[0]);
                        $.ajax({
                            url: '<?= base_url("blog/upload_image") ?>',
                            type: 'POST',
                            data: formData,
                            processData: false,
                            contentType: false,
                            success: function(response) {
                                var result = JSON.parse(response);
                                if (!result.error) {
                                    $('#edit_featured_image_url').val(result.file_path);
                                    $('#edit_image_preview').html('<img src="' + result.file_path + '" class="img-thumbnail" width="200">');
                                } else {
                                    alert(result.message);
                                }
                            }
                        });
                    });

                    $('#createPostForm').on('submit', function(e) {
                        e.preventDefault();
                        if (typeof CKEDITOR !== 'undefined') {
                            for (var instance in CKEDITOR.instances) {
                                CKEDITOR.instances[instance].updateElement();
                            }
                        }
                        $.ajax({
                            url: '<?= base_url("blog/create_post") ?>',
                            type: 'POST',
                            data: $(this).serialize(),
                            success: function(response) {
                                var result = JSON.parse(response);
                                if (!result.error) {
                                    $('#createPostModal').modal('hide');
                                    $('#post_list').bootstrapTable('refresh');
                                    iziToast.success({
                                        message: result.message,
                                        position: 'topRight'
                                    });
                                    $('#createPostForm')[0].reset();
                                    $('#create_image_preview').html('');
                                    if (typeof CKEDITOR !== 'undefined') {
                                        CKEDITOR.instances.create_content.setData('');
                                    }
                                } else {
                                    iziToast.error({
                                        message: result.message,
                                        position: 'topRight'
                                    });
                                }
                            }
                        });
                    });

                    $(document).on('click', '.edit-data', function() {
                        var id = $(this).data('id');
                        $.ajax({
                            url: '<?= base_url("blog/get_post_by_id") ?>',
                            type: 'POST',
                            data: {
                                id: id
                            },
                            success: function(response) {
                                var post = JSON.parse(response);
                                $('#edit_id').val(post.id);
                                $('#edit_title').val(post.title);
                                $('#edit_excerpt').val(post.excerpt);
                                $('#edit_category_id').val(post.category_id);
                                $('#edit_author_id').val(post.author_id);
                                $('#edit_status').val(post.status);
                                $('#edit_featured').prop('checked', post.featured == 1);
                                $('#edit_tags').val(post.tags);
                                $('#edit_meta_title').val(post.meta_title);
                                $('#edit_meta_description').val(post.meta_description);
                                $('#edit_meta_keywords').val(post.meta_keywords);
                                $('#edit_featured_image_url').val(post.featured_image);
                                if (post.featured_image) {
                                    $('#edit_image_preview').html('<img src="' + post.featured_image + '" class="img-thumbnail" width="200">');
                                }
                                if (typeof CKEDITOR !== 'undefined') {
                                    CKEDITOR.instances.edit_content.setData(post.content);
                                } else {
                                    $('#edit_content').val(post.content);
                                }
                            }
                        });
                    });

                    $('#editPostForm').on('submit', function(e) {
                        e.preventDefault();
                        if (typeof CKEDITOR !== 'undefined') {
                            for (var instance in CKEDITOR.instances) {
                                CKEDITOR.instances[instance].updateElement();
                            }
                        }
                        $.ajax({
                            url: '<?= base_url("blog/update_post") ?>',
                            type: 'POST',
                            data: $(this).serialize(),
                            success: function(response) {
                                var result = JSON.parse(response);
                                if (!result.error) {
                                    $('#editDataModal').modal('hide');
                                    $('#post_list').bootstrapTable('refresh');
                                    iziToast.success({
                                        message: result.message,
                                        position: 'topRight'
                                    });
                                } else {
                                    iziToast.error({
                                        message: result.message,
                                        position: 'topRight'
                                    });
                                }
                            }
                        });
                    });

                    $(document).on('click', '.delete-data', function() {
                        var id = $(this).data('id');
                        if (confirm('Are you sure you want to delete this post?')) {
                            $.ajax({
                                url: '<?= base_url("blog/delete_post") ?>',
                                type: 'POST',
                                data: {
                                    id: id
                                },
                                success: function(response) {
                                    var result = JSON.parse(response);
                                    $('#post_list').bootstrapTable('refresh');
                                    iziToast.success({
                                        message: result.message,
                                        position: 'topRight'
                                    });
                                }
                            });
                        }
                    });
                });
            </script>
            <table aria-describedby="mydesc" class='table-striped' id='post_list'
                data-toggle="table" data-url="<?= base_url('blog/get_posts') ?>"
                data-click-to-select="true" data-side-pagination="server"
                data-pagination="true" data-page-list="[5, 10, 20, 50, 100, 200, All]"
                data-search="true" data-toolbar="#toolbar"
                data-show-columns="true" data-show-refresh="true"
                data-trim-on-search="false" data-responsive="true"
                data-sort-name="id" data-sort-order="desc"
                data-pagination-successively-size="3" data-query-params="queryParams">
                <thead>
                    <tr>
                        <th scope="col" data-field="state" data-checkbox="true"></th>
                        <th scope="col" data-field="id" data-sortable="true">ID</th>
                        <th scope="col" data-field="image">Image</th>
                        <th scope="col" data-field="title" data-sortable="true">Title</th>
                        <th scope="col" data-field="slug">Slug</th>
                        <th scope="col" data-field="category" data-sortable="true">Category</th>
                        <th scope="col" data-field="author">Author</th>
                        <th scope="col" data-field="status" data-sortable="true">Status</th>
                        <th scope="col" data-field="featured">Featured</th>
                        <th scope="col" data-field="views" data-sortable="true">Views</th>
                        <th scope="col" data-field="created_at" data-sortable="true">Created</th>
                        <th scope="col" data-field="operate">Actions</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>
    </div>
    </div>
    </div>
    </section>

    <!-- Create Post Modal -->
    <div class="modal fade" id="createPostModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-xl" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Create New Post</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="createPostForm" method="post" enctype="multipart/form-data">
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="form-group">
                                    <label>Title <span class="text-danger">*</span></label>
                                    <input type="text" name="title" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label>Excerpt</label>
                                    <textarea name="excerpt" class="form-control" rows="2"></textarea>
                                </div>
                                <div class="form-group">
                                    <label>Content <span class="text-danger">*</span></label>
                                    <textarea name="content" id="create_content" class="form-control" rows="15"></textarea>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Category <span class="text-danger">*</span></label>
                                    <select name="category_id" class="form-control" required>
                                        <option value="">Select Category</option>
                                        <?php foreach ($categories as $cat): ?>
                                            <option value="<?= $cat['id'] ?>"><?= $cat['name'] ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Author <span class="text-danger">*</span></label>
                                    <select name="author_id" class="form-control" required>
                                        <option value="">Select Author</option>
                                        <?php
                                        $authors = $this->db->get('tbl_blog_authors')->result_array();
                                        foreach ($authors as $author):
                                        ?>
                                            <option value="<?= $author['id'] ?>"><?= $author['name'] ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Status</label>
                                    <select name="status" class="form-control">
                                        <option value="draft">Draft</option>
                                        <option value="published">Published</option>
                                        <option value="archived">Archived</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="create_featured" name="featured" value="1">
                                        <label class="custom-control-label" for="create_featured">Featured Post</label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Featured Image</label>
                                    <input type="file" class="form-control" id="create_featured_image" accept="image/*">
                                    <input type="hidden" name="featured_image" id="create_featured_image_url">
                                    <div id="create_image_preview" class="mt-2"></div>
                                </div>
                                <div class="form-group">
                                    <label>Tags (comma separated)</label>
                                    <input type="text" name="tags" class="form-control" placeholder="technology, web, tutorial">
                                </div>

                                <!-- SEO Fields -->
                                <h6 class="mt-4">SEO Settings</h6>
                                <hr>
                                <div class="form-group">
                                    <label>Meta Title</label>
                                    <input type="text" name="meta_title" class="form-control">
                                    <small class="text-muted">Leave empty to use post title</small>
                                </div>
                                <div class="form-group">
                                    <label>Meta Description</label>
                                    <textarea name="meta_description" class="form-control" rows="2"></textarea>
                                    <small class="text-muted">Auto-generated if empty</small>
                                </div>
                                <div class="form-group">
                                    <label>Meta Keywords</label>
                                    <input type="text" name="meta_keywords" class="form-control">
                                    <small class="text-muted">Auto-generated if empty</small>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Create Post</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Post Modal -->
    <div class="modal fade" id="editDataModal" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-xl" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Post</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="editPostForm" method="post">
                    <input type="hidden" name="id" id="edit_id">
                    <div class="modal-body">
                        <div class="row">
                            <div class="col-md-8">
                                <div class="form-group">
                                    <label>Title <span class="text-danger">*</span></label>
                                    <input type="text" name="title" id="edit_title" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label>Excerpt</label>
                                    <textarea name="excerpt" id="edit_excerpt" class="form-control" rows="2"></textarea>
                                </div>
                                <div class="form-group">
                                    <label>Content <span class="text-danger">*</span></label>
                                    <textarea name="content" id="edit_content" class="form-control" rows="15"></textarea>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <label>Category <span class="text-danger">*</span></label>
                                    <select name="category_id" id="edit_category_id" class="form-control" required>
                                        <?php foreach ($categories as $cat): ?>
                                            <option value="<?= $cat['id'] ?>"><?= $cat['name'] ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Author <span class="text-danger">*</span></label>
                                    <select name="author_id" id="edit_author_id" class="form-control" required>
                                        <?php foreach ($authors as $author): ?>
                                            <option value="<?= $author['id'] ?>"><?= $author['name'] ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label>Status</label>
                                    <select name="status" id="edit_status" class="form-control">
                                        <option value="draft">Draft</option>
                                        <option value="published">Published</option>
                                        <option value="archived">Archived</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <div class="custom-control custom-checkbox">
                                        <input type="checkbox" class="custom-control-input" id="edit_featured" name="featured" value="1">
                                        <label class="custom-control-label" for="edit_featured">Featured Post</label>
                                    </div>
                                </div>
                                <div class="form-group">
                                    <label>Featured Image</label>
                                    <input type="file" class="form-control" id="edit_featured_image" accept="image/*">
                                    <input type="hidden" name="featured_image" id="edit_featured_image_url">
                                    <div id="edit_image_preview" class="mt-2"></div>
                                </div>
                                <div class="form-group">
                                    <label>Tags</label>
                                    <input type="text" name="tags" id="edit_tags" class="form-control">
                                </div>

                                <h6 class="mt-4">SEO Settings</h6>
                                <hr>
                                <div class="form-group">
                                    <label>Meta Title</label>
                                    <input type="text" name="meta_title" id="edit_meta_title" class="form-control">
                                </div>
                                <div class="form-group">
                                    <label>Meta Description</label>
                                    <textarea name="meta_description" id="edit_meta_description" class="form-control" rows="2"></textarea>
                                </div>
                                <div class="form-group">
                                    <label>Meta Keywords</label>
                                    <input type="text" name="meta_keywords" id="edit_meta_keywords" class="form-control">
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Update Post</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function queryParams(p) {
            return {
                limit: p.limit,
                sort: p.sort,
                order: p.order,
                offset: p.offset,
                search: p.search,
                category: $('#filter_category').val(),
                status: $('#filter_status').val()
            };
        }

        $(document).ready(function() {
            // Initialize CKEditor for content
            if (typeof CKEDITOR !== 'undefined') {
                CKEDITOR.replace('create_content', {
                    height: 400,
                    toolbar: 'Full'
                });
                CKEDITOR.replace('edit_content', {
                    height: 400,
                    toolbar: 'Full'
                });
            }

            // Filter change
            $('#filter_category, #filter_status').on('change', function() {
                $('#post_list').bootstrapTable('refresh');
            });

            // Image upload for create
            $('#create_featured_image').on('change', function() {
                var formData = new FormData();
                formData.append('file', this.files[0]);

                $.ajax({
                    url: '<?= base_url("blog/upload_image") ?>',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#create_featured_image_url').val(result.file_path);
                            $('#create_image_preview').html('<img src="' + result.file_path + '" class="img-thumbnail" width="200">');
                        } else {
                            alert(result.message);
                        }
                    }
                });
            });

            // Image upload for edit
            $('#edit_featured_image').on('change', function() {
                var formData = new FormData();
                formData.append('file', this.files[0]);

                $.ajax({
                    url: '<?= base_url("blog/upload_image") ?>',
                    type: 'POST',
                    data: formData,
                    processData: false,
                    contentType: false,
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#edit_featured_image_url').val(result.file_path);
                            $('#edit_image_preview').html('<img src="' + result.file_path + '" class="img-thumbnail" width="200">');
                        } else {
                            alert(result.message);
                        }
                    }
                });
            });

            // Create post
            $('#createPostForm').on('submit', function(e) {
                e.preventDefault();

                // Update CKEditor content
                if (typeof CKEDITOR !== 'undefined') {
                    for (var instance in CKEDITOR.instances) {
                        CKEDITOR.instances[instance].updateElement();
                    }
                }

                $.ajax({
                    url: '<?= base_url("blog/create_post") ?>',
                    type: 'POST',
                    data: $(this).serialize(),
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#createPostModal').modal('hide');
                            $('#post_list').bootstrapTable('refresh');
                            iziToast.success({
                                message: result.message,
                                position: 'topRight'
                            });
                            $('#createPostForm')[0].reset();
                            $('#create_image_preview').html('');
                            if (typeof CKEDITOR !== 'undefined') {
                                CKEDITOR.instances.create_content.setData('');
                            }
                        } else {
                            iziToast.error({
                                message: result.message,
                                position: 'topRight'
                            });
                        }
                    }
                });
            });

            // Load post data for editing
            $(document).on('click', '.edit-data', function() {
                var id = $(this).data('id');
                $.ajax({
                    url: '<?= base_url("blog/get_post_by_id") ?>',
                    type: 'POST',
                    data: {
                        id: id
                    },
                    success: function(response) {
                        var post = JSON.parse(response);
                        $('#edit_id').val(post.id);
                        $('#edit_title').val(post.title);
                        $('#edit_excerpt').val(post.excerpt);
                        $('#edit_category_id').val(post.category_id);
                        $('#edit_author_id').val(post.author_id);
                        $('#edit_status').val(post.status);
                        $('#edit_featured').prop('checked', post.featured == 1);
                        $('#edit_tags').val(post.tags);
                        $('#edit_meta_title').val(post.meta_title);
                        $('#edit_meta_description').val(post.meta_description);
                        $('#edit_meta_keywords').val(post.meta_keywords);
                        $('#edit_featured_image_url').val(post.featured_image);

                        if (post.featured_image) {
                            $('#edit_image_preview').html('<img src="' + post.featured_image + '" class="img-thumbnail" width="200">');
                        }

                        if (typeof CKEDITOR !== 'undefined') {
                            CKEDITOR.instances.edit_content.setData(post.content);
                        } else {
                            $('#edit_content').val(post.content);
                        }
                    }
                });
            });

            // Update post
            $('#editPostForm').on('submit', function(e) {
                e.preventDefault();

                if (typeof CKEDITOR !== 'undefined') {
                    for (var instance in CKEDITOR.instances) {
                        CKEDITOR.instances[instance].updateElement();
                    }
                }

                $.ajax({
                    url: '<?= base_url("blog/update_post") ?>',
                    type: 'POST',
                    data: $(this).serialize(),
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#editDataModal').modal('hide');
                            $('#post_list').bootstrapTable('refresh');
                            iziToast.success({
                                message: result.message,
                                position: 'topRight'
                            });
                        } else {
                            iziToast.error({
                                message: result.message,
                                position: 'topRight'
                            });
                        }
                    }
                });
            });

            // Delete post
            $(document).on('click', '.delete-data', function() {
                var id = $(this).data('id');
                if (confirm('Are you sure you want to delete this post?')) {
                    $.ajax({
                        url: '<?= base_url("blog/delete_post") ?>',
                        type: 'POST',
                        data: {
                            id: id
                        },
                        success: function(response) {
                            var result = JSON.parse(response);
                            $('#post_list').bootstrapTable('refresh');
                            iziToast.success({
                                message: result.message,
                                position: 'topRight'
                            });
                        }
                    });
                }
            });
        });
    </script>

    <?php base_url() . include '../footer.php'; ?>
</body>

</html>