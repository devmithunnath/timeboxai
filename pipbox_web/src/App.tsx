import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Footer } from './components/Layout';
import Home from './pages/Home';
import Privacy from './pages/Privacy';

function App() {
  return (
    <Router>
      <div style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <main style={{ flex: 1 }}>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/privacy" element={<Privacy />} />
          </Routes>
        </main>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
