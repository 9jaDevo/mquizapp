<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title><?= lang('ads_settings'); ?> | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1><?= lang('ads_settings_for_app'); ?> <small class="text-small"><?= lang('note_that_this_will_directly_reflect_the_changes_in_app'); ?></small></h1>
                        <div class="section-header-button ml-auto">
                            <a href="<?= base_url(); ?>ad-compliance-reports" class="btn btn-primary btn-sm">View Compliance Reports</a>
                        </div>
                    </div>
                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body">

                                        <form method="post" class="needs-validation" novalidate="">
                                            <input type="hidden" name="<?= $this->security->get_csrf_token_name(); ?>" value="<?= $this->security->get_csrf_hash(); ?>">

                                            <div class="row">
                                                <div class="form-group col-md-2 col-sm-6">
                                                    <label class="control-label"><?= lang('in_app_ads'); ?></label><br>
                                                    <input type="checkbox" id="in_app_ads_mode_btn" data-plugin="switchery" <?php
                                                                                                                            if (!empty($in_app_ads_mode) && $in_app_ads_mode['message'] == '1') {
                                                                                                                                echo 'checked';
                                                                                                                            }
                                                                                                                            ?>>

                                                    <input type="hidden" id="in_app_ads_mode" name="in_app_ads_mode" value="<?= ($in_app_ads_mode) ? $in_app_ads_mode['message'] : 0; ?>">
                                                </div>
                                                <div class="form-group col-sm-12 adsHide">
                                                    <span class="bg-light p-2">
                                                        <div class="form-check form-check-inline mr-0">
                                                            <input type="radio" class="form-check-input" id="google_admob" name="ads_type" value="1" required <?php
                                                                                                                                                                if (!empty($ads_type) && $ads_type['message'] == '1') {
                                                                                                                                                                    echo 'checked';
                                                                                                                                                                } ?>>
                                                            <label class="form-check-label" for="google_admob"><?= lang('google_admob'); ?></label>
                                                        </div>
                                                        <div class="form-check form-check-inline">
                                                            <input type="radio" class="form-check-input" id="iron_source" name="ads_type" value="2" required <?php
                                                                                                                                                                if (!empty($ads_type) && $ads_type['message'] == '2') {
                                                                                                                                                                    echo 'checked';
                                                                                                                                                                } ?>>
                                                            <label class="form-check-label" for="iron_source"><?= lang('iron_source'); ?></label>
                                                        </div>
                                                        <div class="form-check form-check-inline">
                                                            <input type="radio" class="form-check-input" id="unity_ads" name="ads_type" value="3" required <?php
                                                                                                                                                            if (!empty($ads_type) && $ads_type['message'] == '3') {
                                                                                                                                                                echo 'checked';
                                                                                                                                                            } ?>>
                                                            <label class="form-check-label" for="unity_ads"><?= lang('unity_ads'); ?></label>
                                                        </div>
                                                    </span>
                                                </div>
                                            </div>

                                            <div class="adsgoogle">
                                                <div class="row">
                                                    <div class="form-group col-md-4 col-sm-12">
                                                        <label class="control-label"><?= lang('android_banner_id'); ?></label>
                                                        <input type="text" id="android_banner_id" name="android_banner_id" class="form-control googleAtt" value="<?= (!empty($android_banner_id['message'])) ? $android_banner_id['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-4 col-sm-12">
                                                        <label class="control-label"><?= lang('android_interstitial_id'); ?></label>
                                                        <input type="text" id="android_interstitial_id" name="android_interstitial_id" class="form-control googleAtt" value="<?= (!empty($android_interstitial_id['message'])) ? $android_interstitial_id['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-4 col-sm-12">
                                                        <label class="control-label"><?= lang('android_reward_id'); ?></label>
                                                        <input type="text" id="android_rewarded_id" name="android_rewarded_id" class="form-control googleAtt" value="<?= (!empty($android_rewarded_id['message'])) ? $android_rewarded_id['message'] : "" ?>">
                                                    </div>
                                                </div>
                                                <div class="row">
                                                    <div class="form-group col-md-4 col-sm-12">
                                                        <label class="control-label"><?= lang('ios_banner_id'); ?></label>
                                                        <input type="text" id="ios_banner_id" name="ios_banner_id" class="form-control googleAtt" value="<?= (!empty($ios_banner_id['message'])) ? $ios_banner_id['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-4 col-sm-12">
                                                        <label class="control-label"><?= lang('ios_interstitial_id'); ?></label>
                                                        <input type="text" id="ios_interstitial_id" name="ios_interstitial_id" class="form-control googleAtt" value="<?= (!empty($ios_interstitial_id['message'])) ? $ios_interstitial_id['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-4 col-sm-12">
                                                        <label class="control-label"><?= lang('ios_reward_id'); ?></label>
                                                        <input type="text" id="ios_rewarded_id" name="ios_rewarded_id" class="form-control googleAtt" value="<?= (!empty($ios_rewarded_id['message'])) ? $ios_rewarded_id['message'] : "" ?>">
                                                    </div>
                                                </div>

                                                <hr class="col-12">
                                                <div class="row">
                                                    <div class="form-group col-md-12 col-sm-12 mb-2">
                                                        <h6 class="font-weight-bold"><?= lang('premium_ad_formats'); ?> <small class="text-muted">(AdMob Only)</small></h6>
                                                    </div>
                                                </div>

                                                <div class="row">
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label">App Open Ad ID - Android</label>
                                                        <input type="text" id="app_open_id_android" name="app_open_id_android" class="form-control googleAtt" value="<?= (!empty($app_open_id_android['message'])) ? $app_open_id_android['message'] : "" ?>" placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
                                                        <small class="form-text text-muted">Shown when app is launched or resumed from background</small>
                                                    </div>
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label">App Open Ad ID - iOS</label>
                                                        <input type="text" id="app_open_id_ios" name="app_open_id_ios" class="form-control googleAtt" value="<?= (!empty($app_open_id_ios['message'])) ? $app_open_id_ios['message'] : "" ?>" placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
                                                        <small class="form-text text-muted">Shown when app is launched or resumed from background</small>
                                                    </div>
                                                </div>

                                                <div class="row">
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label">Rewarded Interstitial Ad ID - Android</label>
                                                        <input type="text" id="rewarded_interstitial_id_android" name="rewarded_interstitial_id_android" class="form-control googleAtt" value="<?= (!empty($rewarded_interstitial_id_android['message'])) ? $rewarded_interstitial_id_android['message'] : "" ?>" placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
                                                        <small class="form-text text-muted">Full-page rewarded ad with higher reward (15 coins vs 10)</small>
                                                    </div>
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label">Rewarded Interstitial Ad ID - iOS</label>
                                                        <input type="text" id="rewarded_interstitial_id_ios" name="rewarded_interstitial_id_ios" class="form-control googleAtt" value="<?= (!empty($rewarded_interstitial_id_ios['message'])) ? $rewarded_interstitial_id_ios['message'] : "" ?>" placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
                                                        <small class="form-text text-muted">Full-page rewarded ad with higher reward (15 coins vs 10)</small>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="adsunity">
                                                <div class="row">
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('android_game_id'); ?></label>
                                                        <input type="text" id="android_game_id" name="android_game_id" class="form-control unityAtt" value="<?= (!empty($android_game_id['message'])) ? $android_game_id['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('ios_game_id'); ?></label>
                                                        <input type="text" id="ios_game_id" name="ios_game_id" class="form-control unityAtt" value="<?= (!empty($ios_game_id['message'])) ? $ios_game_id['message'] : "" ?>">
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="ironSource">
                                                <div class="row">
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('app_key_android_iron_source'); ?></label>
                                                        <input type="text" id="app_key_android_iron_source" name="app_key_android_iron_source" class="form-control ironAtt" value="<?= (!empty($app_key_android_iron_source['message'])) ? $app_key_android_iron_source['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('app_key_ios_iron_source'); ?></label>
                                                        <input type="text" id="app_key_ios_iron_source" name="app_key_ios_iron_source" class="form-control ironAtt" value="<?= (!empty($app_key_ios_iron_source['message'])) ? $app_key_ios_iron_source['message'] : "" ?>">
                                                    </div>
                                                </div>

                                                <div class="row">
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('rewarded_id_android_iron_source'); ?></label>
                                                        <input type="text" id="rewarded_id_android_iron_source" name="rewarded_id_android_iron_source" class="form-control ironAtt" value="<?= (!empty($rewarded_id_android_iron_source['message'])) ? $rewarded_id_android_iron_source['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('rewarded_id_ios_iron_source'); ?></label>
                                                        <input type="text" id="rewarded_id_ios_iron_source" name="rewarded_id_ios_iron_source" class="form-control ironAtt" value="<?= (!empty($rewarded_id_ios_iron_source['message'])) ? $rewarded_id_ios_iron_source['message'] : "" ?>">
                                                    </div>
                                                </div>


                                                <div class="row">
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('interstitial_id_android_iron_source'); ?></label>
                                                        <input type="text" id="interstitial_id_android_iron_source" name="interstitial_id_android_iron_source" class="form-control ironAtt" value="<?= (!empty($interstitial_id_android_iron_source['message'])) ? $interstitial_id_android_iron_source['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('interstitial_id_ios_iron_source'); ?></label>
                                                        <input type="text" id="interstitial_id_ios_iron_source" name="interstitial_id_ios_iron_source" class="form-control ironAtt" value="<?= (!empty($interstitial_id_ios_iron_source['message'])) ? $interstitial_id_ios_iron_source['message'] : "" ?>">
                                                    </div>
                                                </div>

                                                <div class="row">
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('banner_id_android_iron_source'); ?></label>
                                                        <input type="text" id="banner_id_android_iron_source" name="banner_id_android_iron_source" class="form-control ironAtt" value="<?= (!empty($banner_id_android_iron_source['message'])) ? $banner_id_android_iron_source['message'] : "" ?>">
                                                    </div>
                                                    <div class="form-group col-md-6 col-sm-12">
                                                        <label class="control-label"><?= lang('banner_id_ios_iron_source'); ?></label>
                                                        <input type="text" id="banner_id_ios_iron_source" name="banner_id_ios_iron_source" class="form-control ironAtt" value="<?= (!empty($banner_id_ios_iron_source['message'])) ? $banner_id_ios_iron_source['message'] : "" ?>">
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-sm-12 col-md-4">
                                                    <label class="control-label"><?= lang('reward_ads_coin'); ?> <small class="text-danger">*</small></label>
                                                    <input type="number" id="reward_coin" min="0" name="reward_coin" required class="form-control" value="<?php echo ($reward_coin) ? $reward_coin['message'] : ""; ?>">
                                                </div>
                                            </div>

                                            <div class="row daily-ads-div">
                                                <hr class="col-12">
                                                <div class="form-group col-md-12 col-sm-12 mb-4">
                                                    <h5 class="font-weight-bold"><?= lang('daily_watch_ads_settings'); ?></h6>
                                                </div>
                                                <div class="form-group col-md-2 col-sm-12">
                                                    <label class="control-label"><?= lang('visibility'); ?></label><br>
                                                    <input type="checkbox" id="daily-ads-visibility-btn" data-plugin="switchery" <?php
                                                                                                                                    if (isset($daily_ads_visibility) && $daily_ads_visibility['message'] == '1') {
                                                                                                                                        echo 'checked';
                                                                                                                                    }
                                                                                                                                    ?>>

                                                    <input type="hidden" id="daily-ads-visibility-mode" name="daily_ads_visibility" value="<?= (isset($daily_ads_visibility)) ? $daily_ads_visibility['message'] : 0; ?>">
                                                </div>
                                                <div class="form-group col-sm-12 col-md-2">
                                                    <label class="control-label"><?= lang('coins'); ?></label>
                                                    <input type="number" name="daily_ads_coins" class="form-control" min="0" id="daily-ads-coins" placeholder="Enter Coins" value="<?= (isset($daily_ads_coins)) ? $daily_ads_coins['message'] : 5; ?>">
                                                </div>
                                                <div class="form-group col-sm-12 col-md-2">
                                                    <label class="control-label"><?= lang('total_counter'); ?><small class="text-danger"> <?= lang('in_24_hours'); ?></small></label>
                                                    <input type="number" placeholder="Enter number of hours" min="0" name="daily_ads_counter" class="form-control" id="daily-cool-off-time" value="<?= (isset($daily_ads_counter)) ? $daily_ads_counter['message'] : 24; ?>">
                                                </div>
                                                <hr class="col-12">
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-12 col-sm-12 mb-2">
                                                    <h6 class="font-weight-bold">Ad Rollout Controls <small class="text-muted">(safe staged release)</small></h6>
                                                </div>

                                                <div class="form-group col-md-3 col-sm-6">
                                                    <label class="control-label">Utility Interstitials</label><br>
                                                    <input type="checkbox" id="ad-rollout-utility-interstitials-btn" data-plugin="switchery" <?php
                                                                                                                                                if (!empty($ad_rollout_utility_interstitials) && $ad_rollout_utility_interstitials['message'] == '1') {
                                                                                                                                                    echo 'checked';
                                                                                                                                                }
                                                                                                                                                ?>>
                                                    <input type="hidden" id="ad-rollout-utility-interstitials" name="ad_rollout_utility_interstitials" value="<?= (isset($ad_rollout_utility_interstitials)) ? $ad_rollout_utility_interstitials['message'] : 1; ?>">
                                                </div>

                                                <div class="form-group col-md-3 col-sm-6">
                                                    <label class="control-label">Wallet Banner Placement</label><br>
                                                    <input type="checkbox" id="ad-rollout-wallet-banner-btn" data-plugin="switchery" <?php
                                                                                                                                        if (!empty($ad_rollout_wallet_banner_placement) && $ad_rollout_wallet_banner_placement['message'] == '1') {
                                                                                                                                            echo 'checked';
                                                                                                                                        }
                                                                                                                                        ?>>
                                                    <input type="hidden" id="ad-rollout-wallet-banner" name="ad_rollout_wallet_banner_placement" value="<?= (isset($ad_rollout_wallet_banner_placement)) ? $ad_rollout_wallet_banner_placement['message'] : 1; ?>">
                                                </div>

                                                <div class="form-group col-md-3 col-sm-6">
                                                    <label class="control-label">Coin Store Banner Placement</label><br>
                                                    <input type="checkbox" id="ad-rollout-coinstore-banner-btn" data-plugin="switchery" <?php
                                                                                                                                        if (!empty($ad_rollout_coin_store_banner_placement) && $ad_rollout_coin_store_banner_placement['message'] == '1') {
                                                                                                                                            echo 'checked';
                                                                                                                                        }
                                                                                                                                        ?>>
                                                    <input type="hidden" id="ad-rollout-coinstore-banner" name="ad_rollout_coin_store_banner_placement" value="<?= (isset($ad_rollout_coin_store_banner_placement)) ? $ad_rollout_coin_store_banner_placement['message'] : 1; ?>">
                                                </div>

                                                <div class="form-group col-md-3 col-sm-6">
                                                    <label class="control-label">Rewarded Fallback Ladder</label><br>
                                                    <input type="checkbox" id="ad-rollout-rewarded-fallback-btn" data-plugin="switchery" <?php
                                                                                                                                            if (!empty($ad_rollout_rewarded_fallback) && $ad_rollout_rewarded_fallback['message'] == '1') {
                                                                                                                                                echo 'checked';
                                                                                                                                            }
                                                                                                                                            ?>>
                                                    <input type="hidden" id="ad-rollout-rewarded-fallback" name="ad_rollout_rewarded_fallback" value="<?= (isset($ad_rollout_rewarded_fallback)) ? $ad_rollout_rewarded_fallback['message'] : 1; ?>">
                                                </div>
                                            </div>

                                            <div class="row">
                                                <div class="form-group col-md-3 col-sm-6">
                                                    <label class="control-label">Compliance Upload</label><br>
                                                    <input type="checkbox" id="ad-compliance-upload-enabled-btn" data-plugin="switchery" <?php
                                                                                                                                            if (!empty($ad_compliance_upload_enabled) && $ad_compliance_upload_enabled['message'] == '1') {
                                                                                                                                                echo 'checked';
                                                                                                                                            }
                                                                                                                                            ?>>
                                                    <input type="hidden" id="ad-compliance-upload-enabled" name="ad_compliance_upload_enabled" value="<?= (isset($ad_compliance_upload_enabled)) ? $ad_compliance_upload_enabled['message'] : 1; ?>">
                                                </div>
                                                <div class="form-group col-md-3 col-sm-6">
                                                    <label class="control-label">Compliance Batch Size</label>
                                                    <input type="number" min="1" max="100" name="ad_compliance_upload_batch_size" class="form-control" value="<?= (isset($ad_compliance_upload_batch_size) && !empty($ad_compliance_upload_batch_size['message'])) ? $ad_compliance_upload_batch_size['message'] : 25; ?>">
                                                    <small class="form-text text-muted">Number of events per upload request.</small>
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

    <script type="text/javascript">
        $(document).ready(function() {

            $('.adsHide').hide(100);
            $('.adsgoogle').hide(100);
            $('.adsunity').hide(100);
            $('.ironSource').hide(100);

            var ads = $('#in_app_ads_mode').val();
            if (ads === '1' || ads === 1) {
                $('.adsHide').show(200);
                var ads_type = $("input:radio[name=ads_type]:checked").val();
                if (ads_type == undefined) {
                    $("input[name=ads_type][value=1]").prop('checked', true);
                }
            } else if (ads === '2' || ads === 2) {
                $('.adsHide').show(200);
                var ads_type = $("input:radio[name=ads_type]:checked").val();
                if (ads_type == undefined) {
                    $("input[name=ads_type][value=2]").prop('checked', true);
                }
            } else if (ads === '3' || ads === 3) {
                $('.adsHide').show(200);
                var ads_type = $("input:radio[name=ads_type]:checked").val();
                if (ads_type == undefined) {
                    $("input[name=ads_type][value=3]").prop('checked', true);
                }
            } else {
                $('.adsHide').hide(100);
                $('.adsgoogle').hide(100);
                $('.adsunity').hide(100);
                $('.ironSource').hide(100);
                $('.googleAtt').removeAttr('required');
                $('.unityAtt').removeAttr('required');
                $('.ironAtt').removeAttr('required');

            }
            var ads_type = $("input:radio[name=ads_type]:checked").val();
            ads_type_manage(ads_type);
        });

        function ads_type_manage(ads_type) {

            var ads = $('#in_app_ads_mode').val();

            if (ads == "0" || ads == 0) {
                $('.adsHide').hide(100);
                $('.adsgoogle').hide(100);
                $('.adsunity').hide(100);
                $('.ironSource').hide(100);
                $('.googleAtt').removeAttr('required');
                $('.unityAtt').removeAttr('required');
                $('.ironAtt').removeAttr('required');
            } else {
                if (ads_type === '1' || ads_type === 1) {
                    $('.adsgoogle').show(200);
                    $('.googleAtt').attr('required', 'required');
                    $('.adsunity').hide(200);
                    $('.unityAtt').removeAttr('required');
                    $('.ironSource').hide(200);
                    $('.ironAtt').removeAttr('required');
                } else if (ads_type === '2' || ads_type === 2) {
                    $('.ironSource').show(200);
                    $('.ironAtt').attr('required', 'required');
                    $('.adsunity').hide(100);
                    $('.unityAtt').removeAttr('required');
                    $('.adsgoogle').hide(100);
                    $('.googleAtt').removeAttr('required');
                } else if (ads_type === '3' || ads_type === 3) {
                    $('.adsgoogle').hide(100);
                    $('.googleAtt').removeAttr('required');
                    $('.adsunity').show(200);
                    $('.unityAtt').attr('required', 'required');
                    $('.ironSource').hide(200);
                    $('.ironAtt').removeAttr('required');
                } else {
                    $('.adsHide').hide(100);
                    $('.adsgoogle').hide(100);
                    $('.googleAtt').removeAttr('required');
                    $('.adsunity').hide(100);
                    $('.unityAtt').removeAttr('required');
                    $('.ironSource').hide(200);
                    $('.ironAtt').removeAttr('required');
                }
            }


        }

        $(document).on('click', 'input[name="ads_type"]', function() {
            var ads_type = $(this).val();
            ads_type_manage(ads_type);
        });
    </script>

    <script type="text/javascript">
        $('[data-plugin="switchery"]').each(function(index, element) {
            var init = new Switchery(element, {
                size: 'small',
                color: '#1abc9c',
                secondaryColor: '#f1556c'
            });
        });
    </script>

    <script type="text/javascript">
        /* on change of Ads mode btn - switchery js */
        var changeCheckbox = document.querySelector('#in_app_ads_mode_btn');
        changeCheckbox.onchange = function() {
            if (changeCheckbox.checked) {
                $('#in_app_ads_mode').val(1);
                $('.adsHide').show(200);
                $("input[name=ads_type][value=1]").prop('checked', true);
                var ads_type = $("input:radio[name=ads_type]:checked").val();
                ads_type_manage(ads_type);
                $('#daily-ads-visibility-mode').val(<?= (isset($daily_ads_visibility)) ? $daily_ads_visibility['message'] : 0 ?>);
            } else {
                $('#in_app_ads_mode').val(0);
                $('.adsHide').hide(100);
                ads_type_manage(0);
                $('#daily-ads-visibility-mode').val(0);
            }
        };
        var visibilityBtn = document.querySelector('#daily-ads-visibility-btn');
        visibilityBtn.onchange = function() {
            if (visibilityBtn.checked) {
                $('#daily-ads-visibility-mode').val(1);
            } else {
                $('#daily-ads-visibility-mode').val(0);
            }
        };

        var utilityInterstitialsBtn = document.querySelector('#ad-rollout-utility-interstitials-btn');
        utilityInterstitialsBtn.onchange = function() {
            $('#ad-rollout-utility-interstitials').val(utilityInterstitialsBtn.checked ? 1 : 0);
        };

        var walletBannerBtn = document.querySelector('#ad-rollout-wallet-banner-btn');
        walletBannerBtn.onchange = function() {
            $('#ad-rollout-wallet-banner').val(walletBannerBtn.checked ? 1 : 0);
        };

        var coinStoreBannerBtn = document.querySelector('#ad-rollout-coinstore-banner-btn');
        coinStoreBannerBtn.onchange = function() {
            $('#ad-rollout-coinstore-banner').val(coinStoreBannerBtn.checked ? 1 : 0);
        };

        var rewardedFallbackBtn = document.querySelector('#ad-rollout-rewarded-fallback-btn');
        rewardedFallbackBtn.onchange = function() {
            $('#ad-rollout-rewarded-fallback').val(rewardedFallbackBtn.checked ? 1 : 0);
        };

        var complianceUploadBtn = document.querySelector('#ad-compliance-upload-enabled-btn');
        complianceUploadBtn.onchange = function() {
            $('#ad-compliance-upload-enabled').val(complianceUploadBtn.checked ? 1 : 0);
        };
    </script>

</body>

</html>