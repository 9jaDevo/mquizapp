<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no" name="viewport">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Engagement Analytics | <?php echo (is_settings('app_name')) ? is_settings('app_name') : "" ?></title>

    <?php base_url() . include 'include.php'; ?>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<body>
    <div id="app">
        <div class="main-wrapper">
            <?php base_url() . include 'header.php'; ?>

            <!-- Main Content -->
            <div class="main-content">
                <section class="section">
                    <div class="section-header">
                        <h1>Engagement Analytics <small>Detailed engagement trends and insights</small></h1>
                    </div>
                    <div class="section-body">

                        <!-- Date Range Filter -->
                        <div class="row">
                            <div class="col-12">
                                <div class="card">
                                    <div class="card-body">
                                        <div class="row">
                                            <div class="form-group col-md-3">
                                                <label for="start_date">Start Date</label>
                                                <input type="date" class="form-control" id="start_date" value="<?= date('Y-m-d', strtotime('-30 days')) ?>">
                                            </div>
                                            <div class="form-group col-md-3">
                                                <label for="end_date">End Date</label>
                                                <input type="date" class="form-control" id="end_date" value="<?= date('Y-m-d') ?>">
                                            </div>
                                            <div class="form-group col-md-3">
                                                <label>&nbsp;</label>
                                                <button type="button" class="btn btn-primary form-control" onclick="refreshCharts()">
                                                    <i class="fas fa-sync"></i> Update Charts
                                                </button>
                                            </div>
                                            <div class="form-group col-md-3">
                                                <label>&nbsp;</label>
                                                <button type="button" class="btn btn-success form-control" onclick="exportReport()">
                                                    <i class="fas fa-file-pdf"></i> Download Report
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Summary Statistics -->
                        <div class="row">
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-primary">
                                        <i class="fas fa-calendar-day"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Sessions (Period)</h4>
                                        </div>
                                        <div class="card-body" id="total_sessions_period">
                                            <?php
                                            $period_sessions = $this->db->where('DATE(session_start) >=', date('Y-m-d', strtotime('-30 days')))
                                                ->count_all_results('tbl_user_engagement');
                                            echo number_format($period_sessions);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-success">
                                        <i class="fas fa-users"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Active Users</h4>
                                        </div>
                                        <div class="card-body" id="active_users_period">
                                            <?php
                                            $active = $this->db->select('COUNT(DISTINCT user_id) as count', FALSE)
                                                ->where('DATE(session_start) >=', date('Y-m-d', strtotime('-30 days')))
                                                ->get('tbl_user_engagement')->row()->count;
                                            echo number_format($active);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-warning">
                                        <i class="fas fa-clock"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Avg Daily Hours</h4>
                                        </div>
                                        <div class="card-body" id="avg_daily_hours">
                                            <?php
                                            $total_sec = $this->db->select('SUM(duration_seconds) as total')
                                                ->where('DATE(session_start) >=', date('Y-m-d', strtotime('-30 days')))
                                                ->get('tbl_user_engagement')->row()->total ?? 0;
                                            $avg_hours = round($total_sec / 3600 / 30, 1);
                                            echo $avg_hours;
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-3 col-md-6">
                                <div class="card card-statistic-1">
                                    <div class="card-icon bg-danger">
                                        <i class="fas fa-exclamation-triangle"></i>
                                    </div>
                                    <div class="card-wrap">
                                        <div class="card-header">
                                            <h4>Suspicious Sessions</h4>
                                        </div>
                                        <div class="card-body" id="suspicious_sessions">
                                            <?php
                                            $suspicious = $this->db->where('duration_seconds >', 43200)
                                                ->where('DATE(session_start) >=', date('Y-m-d', strtotime('-30 days')))
                                                ->count_all_results('tbl_user_engagement');
                                            echo number_format($suspicious);
                                            ?>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Row 1 -->
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Daily Engagement Trend (Last 30 Days)</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="dailyTrendChart" height="150"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Engagement by Continent</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="continentChart" height="150"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Row 2 -->
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Top 15 Countries by Engagement</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="countriesChart" height="150"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Hourly Activity Heatmap</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="hourlyChart" height="150"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Charts Row 3 -->
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Engagement vs Score Correlation</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="correlationChart" height="150"></canvas>
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="card">
                                    <div class="card-header">
                                        <h4>Weekly Active Users (Last 12 Weeks)</h4>
                                    </div>
                                    <div class="card-body">
                                        <canvas id="retentionChart" height="150"></canvas>
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
        let charts = {
            daily: null,
            continent: null,
            countries: null,
            hourly: null,
            correlation: null,
            retention: null
        };

        $(document).ready(function() {
            loadAllCharts();
        });

        function loadAllCharts() {
            loadDailyTrendChart();
            loadContinentChart();
            loadCountriesChart();
            loadHourlyChart();
            loadCorrelationChart();
            loadRetentionChart();
        }

        function refreshCharts() {
            // Destroy existing charts
            Object.keys(charts).forEach(key => {
                if (charts[key]) {
                    charts[key].destroy();
                }
            });

            loadAllCharts();

            iziToast.success({
                title: 'Success',
                message: 'Charts updated successfully',
                position: 'topRight'
            });
        }

        function loadDailyTrendChart() {
            // PHP inline data for last 30 days
            <?php
            $daily_data = $this->db->query("
                SELECT DATE(session_start) as date, COUNT(*) as sessions, SUM(duration_seconds)/3600 as hours
                FROM tbl_user_engagement
                WHERE session_start >= DATE_SUB(NOW(), INTERVAL 30 DAY)
                GROUP BY DATE(session_start)
                ORDER BY date ASC
            ")->result();

            $dates = [];
            $sessions = [];
            $hours = [];
            foreach ($daily_data as $row) {
                $dates[] = date('M d', strtotime($row->date));
                $sessions[] = $row->sessions;
                $hours[] = round($row->hours, 1);
            }
            ?>

            const ctx1 = document.getElementById('dailyTrendChart').getContext('2d');
            charts.daily = new Chart(ctx1, {
                type: 'line',
                data: {
                    labels: <?= json_encode($dates) ?>,
                    datasets: [{
                        label: 'Sessions',
                        data: <?= json_encode($sessions) ?>,
                        borderColor: 'rgb(54, 162, 235)',
                        backgroundColor: 'rgba(54, 162, 235, 0.1)',
                        yAxisID: 'y',
                    }, {
                        label: 'Hours',
                        data: <?= json_encode($hours) ?>,
                        borderColor: 'rgb(255, 99, 132)',
                        backgroundColor: 'rgba(255, 99, 132, 0.1)',
                        yAxisID: 'y1',
                    }]
                },
                options: {
                    responsive: true,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    scales: {
                        y: {
                            type: 'linear',
                            display: true,
                            position: 'left',
                            title: {
                                display: true,
                                text: 'Sessions'
                            }
                        },
                        y1: {
                            type: 'linear',
                            display: true,
                            position: 'right',
                            title: {
                                display: true,
                                text: 'Hours'
                            },
                            grid: {
                                drawOnChartArea: false,
                            },
                        },
                    }
                }
            });
        }

        function loadContinentChart() {
            <?php
            $continent_data = $this->db->query("
                SELECT u.continent, SUM(e.duration_seconds)/60 as minutes
                FROM tbl_user_engagement e
                JOIN tbl_users u ON e.user_id = u.id
                WHERE u.continent IS NOT NULL
                GROUP BY u.continent
                ORDER BY minutes DESC
            ")->result();

            $continents = [];
            $minutes = [];
            $colors = ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40'];
            foreach ($continent_data as $row) {
                $continents[] = $row->continent;
                $minutes[] = round($row->minutes, 0);
            }
            ?>

            const ctx2 = document.getElementById('continentChart').getContext('2d');
            charts.continent = new Chart(ctx2, {
                type: 'doughnut',
                data: {
                    labels: <?= json_encode($continents) ?>,
                    datasets: [{
                        data: <?= json_encode($minutes) ?>,
                        backgroundColor: <?= json_encode(array_slice($colors, 0, count($continents))) ?>,
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'right',
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    return context.label + ': ' + Math.round(context.parsed) + ' mins';
                                }
                            }
                        }
                    }
                }
            });
        }

        function loadCountriesChart() {
            <?php
            $country_data = $this->db->query("
                SELECT u.country_name, SUM(e.duration_seconds)/60 as minutes
                FROM tbl_user_engagement e
                JOIN tbl_users u ON e.user_id = u.id
                WHERE u.country_name IS NOT NULL
                GROUP BY u.country_name
                ORDER BY minutes DESC
                LIMIT 15
            ")->result();

            $countries = [];
            $c_minutes = [];
            foreach ($country_data as $row) {
                $countries[] = $row->country_name;
                $c_minutes[] = round($row->minutes, 0);
            }
            ?>

            const ctx3 = document.getElementById('countriesChart').getContext('2d');
            charts.countries = new Chart(ctx3, {
                type: 'bar',
                data: {
                    labels: <?= json_encode($countries) ?>,
                    datasets: [{
                        label: 'Minutes',
                        data: <?= json_encode($c_minutes) ?>,
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgb(54, 162, 235)',
                        borderWidth: 1
                    }]
                },
                options: {
                    indexAxis: 'y',
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        }
                    }
                }
            });
        }

        function loadHourlyChart() {
            <?php
            $hourly_data = $this->db->query("
                SELECT HOUR(session_start) as hour, COUNT(*) as sessions
                FROM tbl_user_engagement
                GROUP BY HOUR(session_start)
                ORDER BY hour ASC
            ")->result();

            $hours_arr = array_fill(0, 24, 0);
            foreach ($hourly_data as $row) {
                $hours_arr[$row->hour] = $row->sessions;
            }
            $hour_labels = [];
            for ($i = 0; $i < 24; $i++) {
                $hour_labels[] = $i . ':00';
            }
            ?>

            const ctx4 = document.getElementById('hourlyChart').getContext('2d');
            charts.hourly = new Chart(ctx4, {
                type: 'bar',
                data: {
                    labels: <?= json_encode($hour_labels) ?>,
                    datasets: [{
                        label: 'Sessions',
                        data: <?= json_encode($hours_arr) ?>,
                        backgroundColor: 'rgba(255, 206, 86, 0.5)',
                        borderColor: 'rgb(255, 206, 86)',
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }

        function loadCorrelationChart() {
            <?php
            $correlation_data = $this->db->query("
                SELECT e.user_id, e.total_minutes, u.coins
                FROM tbl_leaderboard_engagement_alltime e
                JOIN tbl_users u ON e.user_id = u.id
                WHERE u.coins IS NOT NULL
                ORDER BY e.total_minutes DESC
                LIMIT 100
            ")->result();

            $scatter_data = [];
            foreach ($correlation_data as $row) {
                $scatter_data[] = ['x' => $row->total_minutes, 'y' => $row->coins];
            }
            ?>

            const ctx5 = document.getElementById('correlationChart').getContext('2d');
            charts.correlation = new Chart(ctx5, {
                type: 'scatter',
                data: {
                    datasets: [{
                        label: 'Users',
                        data: <?= json_encode($scatter_data) ?>,
                        backgroundColor: 'rgba(153, 102, 255, 0.5)',
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        x: {
                            title: {
                                display: true,
                                text: 'Engagement Minutes'
                            }
                        },
                        y: {
                            title: {
                                display: true,
                                text: 'Coins'
                            }
                        }
                    }
                }
            });
        }

        function loadRetentionChart() {
            <?php
            $retention_data = $this->db->query("
                SELECT YEARWEEK(session_start) as week, COUNT(DISTINCT user_id) as users
                FROM tbl_user_engagement
                WHERE session_start >= DATE_SUB(NOW(), INTERVAL 12 WEEK)
                GROUP BY YEARWEEK(session_start)
                ORDER BY week ASC
            ")->result();

            $weeks = [];
            $users_per_week = [];
            foreach ($retention_data as $row) {
                $year = substr($row->week, 0, 4);
                $week = substr($row->week, 4, 2);
                $weeks[] = 'W' . $week . ' ' . $year;
                $users_per_week[] = $row->users;
            }
            ?>

            const ctx6 = document.getElementById('retentionChart').getContext('2d');
            charts.retention = new Chart(ctx6, {
                type: 'line',
                data: {
                    labels: <?= json_encode($weeks) ?>,
                    datasets: [{
                        label: 'Active Users',
                        data: <?= json_encode($users_per_week) ?>,
                        borderColor: 'rgb(75, 192, 192)',
                        backgroundColor: 'rgba(75, 192, 192, 0.2)',
                        tension: 0.1
                    }]
                },
                options: {
                    responsive: true,
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
        }

        function exportReport() {
            iziToast.info({
                title: 'Info',
                message: 'PDF export will be implemented in export functionality step',
                position: 'topRight'
            });
        }
    </script>

</body>

</html>