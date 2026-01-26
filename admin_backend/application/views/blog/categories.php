<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>Blog Categories | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>
    <?php base_url() . include '../include.php'; ?>
</head>

<body>
    <?php base_url() . include '../header.php'; ?>

    <section class="section">
        <div class="section-header">
            <h1>Blog Categories</h1>
        </div>
        <div class="section-body">
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h4>Manage Categories</h4>
                            <div class="card-header-action">
                                <button class="btn btn-primary" data-toggle="modal" data-target="#createCategoryModal">
                                    <i class="fas fa-plus"></i> Add Category
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <table aria-describedby="mydesc" class='table-striped' id='category_list'
                                data-toggle="table" data-url="<?= base_url('blog/get_categories') ?>"
                                data-click-to-select="true" data-side-pagination="client"
                                data-pagination="true" data-page-list="[5, 10, 20, 50, 100, All]"
                                data-search="true" data-show-columns="true"
                                data-show-refresh="true" data-trim-on-search="false"
                                data-responsive="true" data-sort-name="id" data-sort-order="desc">
                                <thead>
                                    <tr>
                                        <th scope="col" data-field="id" data-sortable="true">ID</th>
                                        <th scope="col" data-field="name" data-sortable="true">Name</th>
                                        <th scope="col" data-field="slug">Slug</th>
                                        <th scope="col" data-field="description">Description</th>
                                        <th scope="col" data-field="post_count" data-sortable="true">Posts</th>
                                        <th scope="col" data-field="status" data-sortable="true">Status</th>
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

    <!-- Create Category Modal -->
    <div class="modal fade" id="createCategoryModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Create Category</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="createCategoryForm">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Category Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" required>
                            <small class="text-muted">Slug will be auto-generated</small>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <textarea name="description" class="form-control" rows="3"></textarea>
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
                        <button type="submit" class="btn btn-primary">Create Category</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Edit Category Modal -->
    <div class="modal fade" id="editCategoryModal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Category</h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <form id="editCategoryForm">
                    <input type="hidden" name="id" id="edit_category_id">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>Category Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" id="edit_category_name" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <textarea name="description" id="edit_category_description" class="form-control" rows="3"></textarea>
                        </div>
                        <div class="form-group">
                            <label>Status</label>
                            <select name="status" id="edit_category_status" class="form-control">
                                <option value="active">Active</option>
                                <option value="inactive">Inactive</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-primary">Update Category</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <?php $this->load->view('footer'); ?>
    </div>
    </div>

    <script type="text/javascript">
        $(document).ready(function() {
            // Create category
            $('#createCategoryForm').on('submit', function(e) {
                e.preventDefault();
                $.ajax({
                    url: '<?= base_url("blog/create_category") ?>',
                    type: 'POST',
                    data: $(this).serialize(),
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#createCategoryModal').modal('hide');
                            $('#category_list').bootstrapTable('refresh');
                            iziToast.success({
                                message: result.message,
                                position: 'topRight'
                            });
                            $('#createCategoryForm')[0].reset();
                        } else {
                            iziToast.error({
                                message: result.message,
                                position: 'topRight'
                            });
                        }
                    }
                });
            });

            // Edit category
            $(document).on('click', '.edit-category', function() {
                var id = $(this).data('id');
                $.ajax({
                    url: '<?= base_url("blog/get_category_by_id") ?>',
                    type: 'POST',
                    data: {
                        id: id
                    },
                    success: function(response) {
                        var category = JSON.parse(response);
                        $('#edit_category_id').val(category.id);
                        $('#edit_category_name').val(category.name);
                        $('#edit_category_description').val(category.description);
                        $('#edit_category_status').val(category.status);
                        $('#editCategoryModal').modal('show');
                    }
                });
            });

            // Update category
            $('#editCategoryForm').on('submit', function(e) {
                e.preventDefault();
                $.ajax({
                    url: '<?= base_url("blog/update_category") ?>',
                    type: 'POST',
                    data: $(this).serialize(),
                    success: function(response) {
                        var result = JSON.parse(response);
                        if (!result.error) {
                            $('#editCategoryModal').modal('hide');
                            $('#category_list').bootstrapTable('refresh');
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

            // Delete category
            $(document).on('click', '.delete-category', function() {
                var id = $(this).data('id');
                if (confirm('Are you sure you want to delete this category?')) {
                    $.ajax({
                        url: '<?= base_url("blog/delete_category") ?>',
                        type: 'POST',
                        data: {
                            id: id
                        },
                        success: function(response) {
                            var result = JSON.parse(response);
                            $('#category_list').bootstrapTable('refresh');
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