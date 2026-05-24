import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { AnalyticsCharts } from '@/app/(dashboard)/analytics/analytics-charts';
import type { DashboardStats } from '@/types/api';

const defaultStats: DashboardStats = {
  totalUsers: 1000,
  totalQuestions: 500,
  activeLeagues: 3,
  paymentsToday: 25000,
  successfulPaymentsToday: 20000,
  unresolvedFraud: 2,
  dau: 120,
  mau: 800,
};

const defaultProps = {
  stats: defaultStats,
  userGrowth: [],
  revenue: [],
  revenueTotal: 25000,
  completions: [],
  topCategories: [],
  countries: [],
};

describe('AnalyticsCharts', () => {
  it('renders without crashing when stats are null', () => {
    const { container } = render(<AnalyticsCharts {...defaultProps} stats={null} />);
    expect(container.firstChild).toBeInTheDocument();
  });

  it('renders Revenue (30d) KPI card', () => {
    render(<AnalyticsCharts {...defaultProps} />);
    expect(screen.getByText(/revenue \(30d\)/i)).toBeInTheDocument();
  });

  it('renders New Users (30d) KPI card', () => {
    render(<AnalyticsCharts {...defaultProps} />);
    expect(screen.getByText(/new users \(30d\)/i)).toBeInTheDocument();
  });

  it('renders DAU / MAU KPI card', () => {
    render(<AnalyticsCharts {...defaultProps} />);
    expect(screen.getByText(/dau \/ mau/i)).toBeInTheDocument();
  });

  it('renders User Growth chart heading', () => {
    render(<AnalyticsCharts {...defaultProps} />);
    expect(screen.getByText(/user growth/i)).toBeInTheDocument();
  });

  it('renders Revenue chart heading', () => {
    render(<AnalyticsCharts {...defaultProps} />);
    expect(screen.getAllByText(/revenue/i).length).toBeGreaterThan(0);
  });

  it('renders Quiz Completions chart heading', () => {
    render(<AnalyticsCharts {...defaultProps} />);
    expect(screen.getByText(/quiz completions/i)).toBeInTheDocument();
  });

  it('displays the revenueTotal formatted value', () => {
    render(<AnalyticsCharts {...defaultProps} revenueTotal={25000} />);
    // ₦25,000 should appear somewhere in the KPI strip
    expect(screen.getByText(/25,000/)).toBeInTheDocument();
  });

  it('renders with time-series data without crashing', () => {
    const props = {
      ...defaultProps,
      userGrowth: [
        { date: '2026-05-01', count: 10 },
        { date: '2026-05-02', count: 20 },
      ],
      revenue: [
        { date: '2026-05-01', total: 5000, count: 3 },
      ],
      completions: [
        { date: '2026-05-01', count: 15 },
      ],
    };
    const { container } = render(<AnalyticsCharts {...props} />);
    expect(container.firstChild).toBeInTheDocument();
  });
});
