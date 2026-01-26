<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Blog Authors | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Blog Authors</h1>
                    </div>
                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Manage Authors</h4>
                                        <div class="card-header-action">
                                            <button class="btn btn-primary" data-toggle="modal" data-target="#createAuthorModal">
                                                <i class="fas fa-plus"></i> Add Author
                                            </button>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <table aria-describedby="mydesc" class='table-striped' id='author_list'
                                            data-toggle="table" data-url="<?= base_url('blog/get_authors') ?>"
                                            data-click-to-select="true" data-side-pagination="client"
                                            data-pagination="true" data-page-list="[5, 10, 20, 50, 100, All]"
                                            data-search="true" data-show-columns="true"
                                            data-show-refresh="true" data-trim-on-search="false"
                                            data-responsive="true" data-sort-name="id" data-sort-order="desc">
                                            <thead>
                                                <tr>
                                                    <th scope="col" data-field="id" data-sortable="true">ID</th>
                                                    <th scope="col" data-field="avatar">Avatar</th>
                                                    <th scope="col" data-field="name" data-sortable="true">Name</th>
                                                    <th scope="col" data-field="email">Email</th>
                                                    <th scope="col" data-field="status" data-sortable="true">Status</th>
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

                <!-- Create Author Modal -->
                <div class="modal fade" id="createAuthorModal" tabindex="-1" role="dialog">
                    <div class="modal-dialog modal-lg" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Create Author</h5>
                                <button type="button" class="close" data-dismiss="modal">
                                    <span>&times;</span>
                                </button>
                            </div>
                            <form id="createAuthorForm">
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Name <span class="text-danger">*</span></label>
                                                <input type="text" name="name" class="form-control" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Email <span class="text-danger">*</span></label>
                                                <input type="email" name="email" class="form-control" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label>Avatar URL</label>
                                        <input type="url" name="avatar" class="form-control" placeholder="https://example.com/avatar.jpg">
                                    </div>
                                    <div class="form-group">
                                        <label>Bio</label>
                                        <textarea name="bio" class="form-control" rows="3"></textarea>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Twitter</label>
                                                <input type="url" name="twitter" class="form-control" placeholder="https://twitter.com/username">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>LinkedIn</label>
                                                <input type="url" name="linkedin" class="form-control" placeholder="https://linkedin.com/in/username">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>GitHub</label>
                                                <input type="url" name="github" class="form-control" placeholder="https://github.com/username">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Website</label>
                                                <input type="url" name="website" class="form-control" placeholder="https://example.com">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label>Status</label>
                                        <select name="status" class="form-control">
                                            <option value="active">Active</option>
                                            <option value="inactive">Inactive</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                    <button type="submit" class="btn btn-primary">Create Author</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

                <!-- Edit Author Modal -->
                <div class="modal fade" id="editAuthorModal" tabindex="-1" role="dialog">
                    <div class="modal-dialog modal-lg" role="document">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title">Edit Author</h5>
                                <button type="button" class="close" data-dismiss="modal">
                                    <span>&times;</span>
                                </button>
                            </div>
                            <form id="editAuthorForm">
                                <input type="hidden" name="id" id="edit_author_id">
                                <div class="modal-body">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Name <span class="text-danger">*</span></label>
                                                <input type="text" name="name" id="edit_author_name" class="form-control" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Email <span class="text-danger">*</span></label>
                                                <input type="email" name="email" id="edit_author_email" class="form-control" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label>Avatar URL</label>
                                        <input type="url" name="avatar" id="edit_author_avatar" class="form-control">
                                    </div>
                                    <div class="form-group">
                                        <label>Bio</label>
                                        <textarea name="bio" id="edit_author_bio" class="form-control" rows="3"></textarea>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Twitter</label>
                                                <input type="url" name="twitter" id="edit_author_twitter" class="form-control">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>LinkedIn</label>
                                                <input type="url" name="linkedin" id="edit_author_linkedin" class="form-control">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>GitHub</label>
                                                <input type="url" name="github" id="edit_author_github" class="form-control">
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <label>Website</label>
                                                <input type="url" name="website" id="edit_author_website" class="form-control">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label>Status</label>
                                        <select name="status" id="edit_author_status" class="form-control">
                                            <option value="active">Active</option>
                                            <option value="inactive">Inactive</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                    <button type="submit" class="btn btn-primary">Update Author</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

            </div>
            <?php include __DIR__ . '/../footer.php'; ?>
        </div>
    </div>

    <script type="text/javascript">
        $(document).ready(function() {
            // Create author
            $('#createAuthorForm').on('submit', function(e) {
                e.preventDefault();
                $.ajax({
                    url: '<?= base_url("blog/create_author") ?>',
                    type: 'POST',
                    data: $(this).serialize(),
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#createAuthorModal').modal('hide');
                            $('#author_list').bootstrapTable('refresh');
                            iziToast.success({
                                message: result.message,
                                position: 'topRight'
                            });
                            $('#createAuthorForm')[0].reset();
                        } else {
                            iziToast.error({
                                message: result.message,
                                position: 'topRight'
                            });
                        }
                    }
                });
            });

            // Edit author
            $(document).on('click', '.edit-author', function() {
                var id = $(this).data('id');
                $.ajax({
                    url: '<?= base_url("blog/get_author_by_id") ?>',
                    type: 'POST',
                    data: {
                        id: id
                    },
                    success: function(response) {
                        var author = JSON.parse(response);
                        $('#edit_author_id').val(author.id);
                        $('#edit_author_name').val(author.name);
                        $('#edit_author_email').val(author.email);
                        $('#edit_author_avatar').val(author.avatar);
                        $('#edit_author_bio').val(author.bio);
                        $('#edit_author_twitter').val(author.twitter);
                        $('#edit_author_linkedin').val(author.linkedin);
                        $('#edit_author_github').val(author.github);
                        $('#edit_author_website').val(author.website);
                        $('#edit_author_status').val(author.status);
                        $('#editAuthorModal').modal('show');
                    }
                });
            });

            // Update author
            $('#editAuthorForm').on('submit', function(e) {
                e.preventDefault();
                $.ajax({
                    url: '<?= base_url("blog/update_author") ?>',
                    type: 'POST',
                    data: $(this).serialize(),
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#editAuthorModal').modal('hide');
                            $('#author_list').bootstrapTable('refresh');
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

            // Delete author
            $(document).on('click', '.delete-author', function() {
                var id = $(this).data('id');
                if (confirm('Are you sure you want to delete this author?')) {
                    $.ajax({
                        url: '<?= base_url("blog/delete_author") ?>',
                        type: 'POST',
                        data: {
                            id: id
                        },
                        success: function(response) {
                            var result = JSON.parse(response);
                            $('#author_list').bootstrapTable('refresh');
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

</body>

</html>