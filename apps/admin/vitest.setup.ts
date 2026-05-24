import '@testing-library/jest-dom';

// Recharts (and many browser APIs) require ResizeObserver — provide a no-op in jsdom
global.ResizeObserver = class ResizeObserver {
  observe() {}
  unobserve() {}
  disconnect() {}
};
