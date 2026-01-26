<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Create Blog Post | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

    <?php include __DIR__ . '/../include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php include __DIR__ . '/../header.php'; ?>

            <!-- Main Content -->
            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>Create New Blog Post</h1>
                        <div class="section-header-breadcrumb">
                            <div class="breadcrumb-item"><a href="<?= base_url('blog-posts') ?>">Blog Posts</a></div>
                            <div class="breadcrumb-item active">Create Post</div>
                        </div>
                    </div>
                    <div class="section-body">
                        <form id="createPostForm" method="post" action="<?= base_url('blog/create_post') ?>">
                            <div class="row">
                                <div class="col-md-8">
                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Post Content</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="form-group">
                                                <label>Title <span class="text-danger">*</span></label>
                                                <input type="text" name="title" class="form-control" required>
                                            </div>
                                            <div class="form-group">
                                                <label>Excerpt</label>
                                                <textarea name="excerpt" class="form-control" rows="2" placeholder="Brief summary of the post (optional)"></textarea>
                                            </div>
                                            <div class="form-group">
                                                <label>Content <span class="text-danger">*</span></label>
                                                <textarea name="content" id="create_content" class="form-control" rows="20"></textarea>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="card">
                                        <div class="card-header">
                                            <h4>SEO Settings</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="form-group">
                                                <label>Meta Title</label>
                                                <input type="text" name="meta_title" class="form-control">
                                                <small class="text-muted">Leave empty to use post title</small>
                                            </div>
                                            <div class="form-group">
                                                <label>Meta Description</label>
                                                <textarea name="meta_description" class="form-control" rows="2"></textarea>
                                                <small class="text-muted">Auto-generated from content if empty</small>
                                            </div>
                                            <div class="form-group">
                                                <label>Meta Keywords</label>
                                                <input type="text" name="meta_keywords" class="form-control" placeholder="keyword1, keyword2, keyword3">
                                                <small class="text-muted">Auto-generated from content if empty</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-md-4">
                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Publish</h4>
                                        </div>
                                        <div class="card-body">
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
                                                    <input type="checkbox" class="custom-control-input" id="featured" name="featured" value="1">
                                                    <label class="custom-control-label" for="featured">Featured Post</label>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <button type="submit" class="btn btn-primary btn-block">
                                                    <i class="fa fa-save"></i> Create Post
                                                </button>
                                                <a href="<?= base_url('blog-posts') ?>" class="btn btn-secondary btn-block">
                                                    <i class="fa fa-times"></i> Cancel
                                                </a>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Organization</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="form-group">
                                                <label>Category <span class="text-danger">*</span></label>
                                                <select name="category_id" class="form-control" required>
                                                    <option value="">Select Category</option>
                                                    <?php
                                                    $categories = $this->db->get('tbl_blog_categories')->result_array();
                                                    foreach ($categories as $cat):
                                                    ?>
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
                                                <label>Tags</label>
                                                <input type="text" name="tags" class="form-control" placeholder="tech, tutorial, news">
                                                <small class="text-muted">Comma separated</small>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="card">
                                        <div class="card-header">
                                            <h4>Featured Image</h4>
                                        </div>
                                        <div class="card-body">
                                            <div class="form-group">
                                                <input type="file" class="form-control" id="featured_image" accept="image/*">
                                                <input type="hidden" name="featured_image" id="featured_image_url">
                                                <div id="image_preview" class="mt-2"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </section>
            </div>
            <?php include __DIR__ . '/../footer.php'; ?>
        </div>
    </div>

    <script src="//cdn.ckeditor.com/4.16.2/full/ckeditor.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            // Initialize CKEditor
            if (typeof CKEDITOR !== 'undefined') {
                CKEDITOR.replace('create_content', {
                    height: 400,
                    toolbar: 'Full'
                });
            }

            // Handle image upload
            $('#featured_image').on('change', function() {
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
                            $('#featured_image_url').val(result.file_path);
                            $('#image_preview').html('<img src="' + result.file_path + '" class="img-thumbnail" width="100%">');
                        } else {
                            iziToast.error({
                                message: result.message,
                                position: 'topRight'
                            });
                        }
                    },
                    error: function() {
                        iziToast.error({
                            message: 'Failed to upload image',
                            position: 'topRight'
                        });
                    }
                });
            });

            // Handle form submission
            $('#createPostForm').on('submit', function(e) {
                e.preventDefault();

                // Update CKEditor content
                if (typeof CKEDITOR !== 'undefined') {
                    for (var instance in CKEDITOR.instances) {
                        CKEDITOR.instances[instance].updateElement();
                    }
                }

                var formData = $(this).serialize();

                $.ajax({
                    url: '<?= base_url("blog/create_post") ?>',
                    type: 'POST',
                    data: formData,
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            iziToast.success({
                                message: result.message,
                                position: 'topRight'
                            });
                            setTimeout(function() {
                                window.location.href = '<?= base_url("blog-posts") ?>';
                            }, 1500);
                        } else {
                            iziToast.error({
                                message: result.message,
                                position: 'topRight'
                            });
                        }
                    },
                    error: function() {
                        iziToast.error({
                            message: 'An error occurred',
                            position: 'topRight'
                        });
                    }
                });
            });
        });
    </script>

</body>

</html>