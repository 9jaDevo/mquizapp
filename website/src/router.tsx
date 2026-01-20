import { createBrowserRouter } from 'react-router-dom';
import Layout from './components/common/Layout';
import Home from './pages/Home';
import About from './pages/About';
import Features from './pages/Features';
import Blog from './pages/Blog';
import Contact from './pages/Contact';
import Download from './pages/Download';
import Privacy from './pages/Privacy';
import Terms from './pages/Terms';
import NotFound from './pages/NotFound';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        index: true,
        element: <Home />,
      },
      {
        path: 'about',
        element: <About />,
      },
      {
        path: 'features',
        element: <Features />,
      },
      {
        path: 'blog',
        element: <Blog />,
      },
      {
        path: 'contact',
        element: <Contact />,
      },
      {
        path: 'download',
        element: <Download />,
      },
      {
        path: 'privacy',
        element: <Privacy />,
      },
      {
        path: 'terms',
        element: <Terms />,
      },
      {
        path: '*',
        element: <NotFound />,
      },
    ],
  },
]);
