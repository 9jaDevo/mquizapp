<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Monthly Engagement Leaderboard | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

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
                        <h1>Monthly Engagement Leaderboard <small>View month-wise user engagement rankings</small></h1>
                    </div>
                    <div class="section-body">
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="form-group col-md-2 col-sm-6 col-xs-12">
                                                <label class="control-label" for="scope">Scope</label>
                                                <select name="scope" id="scope" class="form-control">
                                                    <option value="world">World</option>
                                                    <option value="country">Country</option>
                                                    <option value="region">Region</option>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-2 col-sm-6 col-xs-12" id="country_div" style="display:none;">
                                                <label class="control-label" for="country_code">Country</label>
                                                <select name="country_code" id="country_code" class="form-control">
                                                    <option value="">Select Country</option>
                                                    <?php
                                                    $countries = $this->db->select('DISTINCT country_code, country_name', FALSE)
                                                        ->from('tbl_country_region_mapping')
                                                        ->order_by('country_name', 'ASC')
                                                        ->get()->result();
                                                    foreach ($countries as $country) {
                                                        echo "<option value='{$country->country_code}'>{$country->country_name}</option>";
                                                    }
                                                    ?>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-2 col-sm-6 col-xs-12" id="region_div" style="display:none;">
                                                <label class="control-label" for="region">Region</label>
                                                <select name="region" id="region" class="form-control">
                                                    <option value="">Select Region</option>
                                                    <?php
                                                    $regions = $this->db->select('DISTINCT continent', FALSE)
                                                        ->from('tbl_country_region_mapping')
                                                        ->where('continent IS NOT NULL')
                                                        ->order_by('continent', 'ASC')
                                                        ->get()->result();
                                                    foreach ($regions as $reg) {
                                                        echo "<option value='{$reg->continent}'>{$reg->continent}</option>";
                                                    }
                                                    ?>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-2 col-sm-6 col-xs-12">
                                                <?php
                                                $yearArray = range(2024, date('Y'));
                                                ?>
                                                <label class="control-label" for="year">Year</label>
                                                <select name="year" id="year" class="form-control">
                                                    <?php foreach ($yearArray as $year) { ?>
                                                        <option value="<?= $year; ?>"><?= $year; ?></option>
                                                    <?php } ?>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-2 col-sm-6 col-xs-12">
                                                <?php
                                                $monthArray = array(
                                                    "1" => "January",
                                                    "2" => "February",
                                                    "3" => "March",
                                                    "4" => "April",
                                                    "5" => "May",
                                                    "6" => "June",
                                                    "7" => "July",
                                                    "8" => "August",
                                                    "9" => "September",
                                                    "10" => "October",
                                                    "11" => "November",
                                                    "12" => "December"
                                                );
                                                ?>
                                                <label class="control-label" for="month">Month</label>
                                                <select name="month" id="month" class="form-control">
                                                    <?php foreach ($monthArray as $key => $month) { ?>
                                                        <option value="<?= $key; ?>"><?= $month; ?></option>
                                                    <?php } ?>
                                                </select>
                                            </div>
                                            <div class="form-group col-md-2 col-sm-6 col-xs-12">
                                                <label class="col-xs-12">Filter</label>
                                                <button type="button" class="<?= BUTTON_CLASS ?> form-control" id="filter_btn">Apply</button>
                                            </div>
                                        </div>
                                        <table aria-describedby="mydesc" class='table-striped' id='engagement_monthly_table'
                                            data-toggle="table"
                                            data-url="<?= base_url() . 'Table/engagement_monthly' ?>"
                                            data-click-to-select="true"
                                            data-side-pagination="server"
                                            data-pagination="true"
                                            data-page-list="[5, 10, 20, 50, 100, 200, All]"
                                            data-search="true"
                                            data-toolbar="#toolbar"
                                            data-show-columns="true"
                                            data-show-refresh="true"
                                            data-trim-on-search="false"
                                            data-mobile-responsive="true"
                                            data-sort-name="user_rank"
                                            data-sort-order="asc"
                                            data-pagination-successively-size="3"
                                            data-maintain-selected="true"
                                            data-show-export="true"
                                            data-export-types='["csv","excel","pdf"]'
                                            data-export-options='{ "fileName": "monthly-engagement-<?= date('d-m-y') ?>" }'
                                            data-query-params="queryParams">
                                            <thead>
                                                <tr>
                                                    <th scope="col" data-field="user_rank" data-sortable="true" data-align="center">Rank</th>
                                                    <th scope="col" data-field="user_id" data-sortable="true" data-visible="false">User ID</th>
                                                    <th scope="col" data-field="name" data-sortable="true">Name</th>
                                                    <th scope="col" data-field="email" data-sortable="true">Email</th>
                                                    <th scope="col" data-field="country_name" data-sortable="true">Country</th>
                                                    <th scope="col" data-field="continent" data-sortable="true">Continent</th>
                                                    <th scope="col" data-field="formatted_time" data-sortable="false">Total Time</th>
                                                    <th scope="col" data-field="total_minutes" data-sortable="true" data-visible="false">Minutes</th>
                                                    <th scope="col" data-field="last_updated" data-sortable="true">Last Updated</th>
                                                </tr>
                                            </thead>
                                        </table>
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
        $(document).ready(function() {
            var today = new Date();
            document.getElementById("year").value = today.getFullYear();
            document.getElementById("month").value = (today.getMonth() + 1);

            $('#engagement_monthly_table').bootstrapTable('refresh');
            $('#engagement_monthly_table').show();

            // Scope change handler
            $('#scope').on('change', function() {
                var scope = $(this).val();
                if (scope == 'country') {
                    $('#country_div').show();
                    $('#region_div').hide();
                } else if (scope == 'region') {
                    $('#region_div').show();
                    $('#country_div').hide();
                } else {
                    $('#country_div').hide();
                    $('#region_div').hide();
                }
            });
        });
    </script>

    <script type="text/javascript">
        window.actionEvents = {};
    </script>

    <script type="text/javascript">
        function queryParams(p) {
            return {
                "scope": $('#scope').val(),
                "country_code": $('#country_code').val(),
                "region": $('#region').val(),
                "year": $('#year').val(),
                "month": $('#month').val(),
                sort: p.sort,
                order: p.order,
                offset: p.offset,
                limit: p.limit,
                search: p.search
            };
        }

        $('#filter_btn').on('click', function() {
            $('#engagement_monthly_table').bootstrapTable('refresh');
            $('#engagement_monthly_table').show();
        });
    </script>

</body>

</html>