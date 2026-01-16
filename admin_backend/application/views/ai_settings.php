<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title><?= lang('ai_settings'); ?> | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

    <?php base_url() . include 'include.php'; ?>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <!-- Main Content -->
            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1><?= lang('ai_settings'); ?></h1>
                    </div>
                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body">
                                        <form method="post" class="needs-validation" novalidate="">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-4 col-lg-4 col-sm-12 col-12">
                                                    <label class="control-label"><?= lang('ai_provider'); ?></label><br>
                                                    <select name="ai_provider" id="ai_provider" class="form-control" required>
                                                        <option value=""><?= lang('select_provider'); ?></option>
                                                        <option value="gemini" <?= (($ai_provider['message'] ?? '') == 'gemini') ? 'selected' : '' ?>><?= lang('gemini') ?></option>
                                                        <option value="openai" <?= (($ai_provider['message'] ?? '') == 'openai') ? 'selected' : '' ?>><?= lang('openai') ?></option>
                                                    </select>
                                                </div>
                                                <div class="form-group col-md-4 col-lg-4 col-sm-12 col-12 geminiData">
                                                    <label class="control-label"><?= lang('ai_model'); ?></label><br>
                                                    <input type="text" name="gemini_model" id="gemini_model" class="form-control" value="<?= $gemini_model['message'] ?? '' ?>">
                                                </div>
                                                <div class="form-group col-md-4 col-lg-4 col-sm-12 col-12 geminiData">
                                                    <label class="control-label"><?= lang('ai_api_key'); ?></label><br>
                                                    <div class="input-group">
                                                        <input type="password" id="gemini_api_key" name="gemini_api_key" class="form-control" value="<?= $gemini_api_key['message'] ?? '' ?>">
                                                        <div class="input-group-prepend">
                                                            <div class="input-group-text">
                                                                <i class="fa fa-eye-slash" id="btnGeminiIcon"></i>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="form-group col-md-4 col-lg-4 col-sm-12 col-12 openaiData">
                                                    <label class="control-label"><?= lang('ai_model'); ?></label><br>
                                                    <input type="text" name="openai_model" id="openai_model" class="form-control" value="<?= $openai_model['message'] ?? '' ?>">
                                                </div>
                                                <div class="form-group col-md-4 col-lg-4 col-sm-12 col-12 openaiData">
                                                    <label class="control-label"><?= lang('ai_api_key'); ?></label><br>
                                                    <div class="input-group">
                                                        <input type="password" id="openai_api_key" name="openai_api_key" class="form-control" value="<?= $openai_api_key['message'] ?? '' ?>">
                                                        <div class="input-group-prepend">
                                                            <div class="input-group-text">
                                                                <i class="fa fa-eye-slash" id="btnOpenaiIcon"></i>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="form-group col-sm-12">
                                                    <input type="submit" name="btnadd" value="<?= lang('submit'); ?>" class="<?= BUTTON_CLASS ?>" />
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        </div>
    </div>
    <?php base_url() . include 'footer.php'; ?>

    <script>
        ai_provider = $('#ai_provider').val();
        providerData(ai_provider);

        function providerData(ai_provider) {
            if (ai_provider == 'gemini') {
                $('.geminiData').show();
                $('#gemini_model').attr('required', true);
                $('#gemini_api_key').attr('required', true);
                $('.openaiData').hide();
                $('#openai_model').removeAttr('required');
                $('#openai_api_key').removeAttr('required');
            } else if (ai_provider == 'openai') {
                $('.openaiData').show();
                $('#openai_model').attr('required', true);
                $('#openai_api_key').attr('required', true);
                $('.geminiData').hide();
                $('#gemini_model').removeAttr('required');
                $('#gemini_api_key').removeAttr('required');
            }
        }
        $('#ai_provider').on('change', function() {
            ai_provider = $('#ai_provider').val();
            providerData(ai_provider);
        });

        function toggleApiKeyVisibility(buttonSelector, inputSelector) {
            $(buttonSelector).click(function() {
                var input = $(inputSelector);
                var isPassword = input.attr("type") === "password";

                input.attr("type", isPassword ? "text" : "password");
                $(this).attr("class", isPassword ? "fa fa-eye" : "fa fa-eye-slash");
            });
        }

        toggleApiKeyVisibility("#btnOpenaiIcon", "#openai_api_key")
        toggleApiKeyVisibility("#btnGeminiIcon", "#gemini_api_key")
    </script>
</body>

</html>