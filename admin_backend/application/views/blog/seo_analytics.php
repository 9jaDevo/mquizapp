<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <title>SEO Analytics | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>
    <?php base_url() . include '../include.php'; ?>
</head>

<body>
    <?php base_url() . include '../header.php'; ?>

    <section class="section">
        <div class="section-header">
            <h1>SEO Analytics Dashboard</h1>
        </div>
        <div class="section-body">
            <!-- Summary Cards -->
            <div class="row">
                <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                    <div class="card card-statistic-1">
                        <div class="card-icon bg-primary">
                            <i class="fas fa-robot"></i>
                        </div>
                        <div class="card-wrap">
                            <div class="card-header">
                                <h4>Total AI Bot Hits</h4>
                            </div>
                            <div class="card-body" id="total_bot_hits">
                                0
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                    <div class="card card-statistic-1">
                        <div class="card-icon bg-success">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="card-wrap">
                            <div class="card-header">
                                <h4>Total Human Views</h4>
                            </div>
                            <div class="card-body" id="total_human_views">
                                0
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                    <div class="card card-statistic-1">
                        <div class="card-icon bg-warning">
                            <i class="fas fa-key"></i>
                        </div>
                        <div class="card-wrap">
                            <div class="card-header">
                                <h4>Auto-Generated Keywords</h4>
                            </div>
                            <div class="card-body" id="auto_keywords">
                                0
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-6 col-12">
                    <div class="card card-statistic-1">
                        <div class="card-icon bg-info">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="card-wrap">
                            <div class="card-header">
                                <h4>Avg. Time on Page</h4>
                            </div>
                            <div class="card-body" id="avg_time">
                                0s
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="row">
                <div class="col-lg-6 col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h4>Bot vs Human Traffic</h4>
                        </div>
                        <div class="card-body">
                            <canvas id="botVsHumanChart" height="200"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6 col-md-12">
                    <div class="card">
                        <div class="card-header">
                            <h4>Keyword Generation Sources</h4>
                        </div>
                        <div class="card-body">
                            <canvas id="keywordSourceChart" height="200"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Detailed Analytics Table -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h4>Post-Level SEO Analytics</h4>
                        </div>
                        <div class="card-body">
                            <table aria-describedby="mydesc" class='table-striped' id='seo_analytics_list'
                                data-toggle="table" data-url="<?= base_url('blog/get_seo_analytics') ?>"
                                data-click-to-select="false" data-side-pagination="client"
                                data-pagination="true" data-page-list="[10, 20, 50, 100, All]"
                                data-search="true" data-show-columns="true"
                                data-show-refresh="true" data-trim-on-search="false"
                                data-responsive="true" data-sort-name="id" data-sort-order="desc">
                                <thead>
                                    <tr>
                                        <th scope="col" data-field="id" data-sortable="true">ID</th>
                                        <th scope="col" data-field="post_title" data-sortable="true">Post Title</th>
                                        <th scope="col" data-field="keyword_source">Keyword Source</th>
                                        <th scope="col" data-field="keywords">Keywords</th>
                                        <th scope="col" data-field="keyword_count" data-sortable="true">Keyword Count</th>
                                        <th scope="col" data-field="ai_bot_hits" data-sortable="true">Bot Hits</th>
                                        <th scope="col" data-field="human_views" data-sortable="true">Human Views</th>
                                        <th scope="col" data-field="avg_time" data-sortable="true">Avg. Time</th>
                                        <th scope="col" data-field="last_updated" data-sortable="true">Last Updated</th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Top Performing Posts -->
            <div class="row">
                <div class="col-lg-6">
                    <div class="card">
                        <div class="card-header">
                            <h4>Top Posts by Bot Hits</h4>
                        </div>
                        <div class="card-body">
                            <ul class="list-unstyled list-unstyled-border" id="top_bot_posts">
                                <li class="media">
                                    <div class="media-body">
                                        <div class="text-muted text-small">Loading...</div>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="card">
                        <div class="card-header">
                            <h4>Top Posts by Human Views</h4>
                        </div>
                        <div class="card-body">
                            <ul class="list-unstyled list-unstyled-border" id="top_human_posts">
                                <li class="media">
                                    <div class="media-body">
                                        <div class="text-muted text-small">Loading...</div>
                                    </div>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            let botVsHumanChart, keywordSourceChart;

            // Load analytics data
            function loadAnalytics() {
                $.ajax({
                    url: '<?= base_url("blog/get_seo_analytics") ?>',
                    type: 'GET',
                    success: function(response) {
                        var data = JSON.parse(response);
                        var analytics = data.rows;

                        if (analytics.length === 0) {
                            return;
                        }

                        // Calculate totals
                        let totalBotHits = 0;
                        let totalHumanViews = 0;
                        let autoKeywords = 0;
                        let editorKeywords = 0;
                        let totalTime = 0;

                        analytics.forEach(function(row) {
                            totalBotHits += parseInt(row.ai_bot_hits);
                            totalHumanViews += parseInt(row.human_views);
                            if (row.keyword_source.includes('Auto')) {
                                autoKeywords++;
                            } else {
                                editorKeywords++;
                            }
                        });

                        // Update summary cards
                        $('#total_bot_hits').text(totalBotHits.toLocaleString());
                        $('#total_human_views').text(totalHumanViews.toLocaleString());
                        $('#auto_keywords').text(autoKeywords);

                        // Calculate average time
                        let avgTime = 0;
                        analytics.forEach(function(row) {
                            let timeParts = row.avg_time.split(':');
                            avgTime += parseInt(timeParts[0]) * 60 + parseInt(timeParts[1]);
                        });
                        avgTime = Math.round(avgTime / analytics.length);
                        $('#avg_time').text(Math.floor(avgTime / 60) + 'm ' + (avgTime % 60) + 's');

                        // Bot vs Human Chart
                        const botVsHumanCtx = document.getElementById('botVsHumanChart').getContext('2d');
                        if (botVsHumanChart) {
                            botVsHumanChart.destroy();
                        }
                        botVsHumanChart = new Chart(botVsHumanCtx, {
                            type: 'doughnut',
                            data: {
                                labels: ['AI Bot Hits', 'Human Views'],
                                datasets: [{
                                    data: [totalBotHits, totalHumanViews],
                                    backgroundColor: ['#6777ef', '#66bb6a'],
                                    borderWidth: 0
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: 'bottom'
                                    }
                                }
                            }
                        });

                        // Keyword Source Chart
                        const keywordSourceCtx = document.getElementById('keywordSourceChart').getContext('2d');
                        if (keywordSourceChart) {
                            keywordSourceChart.destroy();
                        }
                        keywordSourceChart = new Chart(keywordSourceCtx, {
                            type: 'pie',
                            data: {
                                labels: ['Auto-Generated', 'Editor'],
                                datasets: [{
                                    data: [autoKeywords, editorKeywords],
                                    backgroundColor: ['#ffa426', '#28a745'],
                                    borderWidth: 0
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: 'bottom'
                                    }
                                }
                            }
                        });

                        // Top posts by bot hits
                        let topBotPosts = [...analytics].sort((a, b) => b.ai_bot_hits - a.ai_bot_hits).slice(0, 5);
                        let botPostsHtml = '';
                        topBotPosts.forEach(function(post, index) {
                            botPostsHtml += `
                            <li class="media">
                                <div class="media-title font-weight-bold">${index + 1}. ${post.post_title}</div>
                                <div class="media-body">
                                    <div class="badge badge-primary">${post.ai_bot_hits} Bot Hits</div>
                                </div>
                            </li>
                        `;
                        });
                        $('#top_bot_posts').html(botPostsHtml);

                        // Top posts by human views
                        let topHumanPosts = [...analytics].sort((a, b) => b.human_views - a.human_views).slice(0, 5);
                        let humanPostsHtml = '';
                        topHumanPosts.forEach(function(post, index) {
                            humanPostsHtml += `
                            <li class="media">
                                <div class="media-title font-weight-bold">${index + 1}. ${post.post_title}</div>
                                <div class="media-body">
                                    <div class="badge badge-success">${post.human_views} Human Views</div>
                                </div>
                            </li>
                        `;
                        });
                        $('#top_human_posts').html(humanPostsHtml);
                    }
                });
            }

            // Load on page ready
            loadAnalytics();

            // Refresh on table refresh
            $('#seo_analytics_list').on('refresh.bs.table', function() {
                loadAnalytics();
            });

            // Auto-refresh every 30 seconds
            setInterval(function() {
                loadAnalytics();
                $('#seo_analytics_list').bootstrapTable('refresh', {
                    silent: true
                });
            }, 30000);
        });
    </script>

    <?php base_url() . include '../footer.php'; ?>
</body>

</html>