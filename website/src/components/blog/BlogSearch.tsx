import React, { useState } from 'react';
import { Search } from 'lucide-react';
import GlassInput from '../common/GlassInput';

interface BlogSearchProps {
  onSearch: (query: string) => void;
  placeholder?: string;
}

const BlogSearch: React.FC<BlogSearchProps> = ({ 
  onSearch, 
  placeholder = 'Search articles...' 
}) => {
  const [query, setQuery] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSearch(query);
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setQuery(e.target.value);
    // Debounce search
    const timer = setTimeout(() => {
      onSearch(e.target.value);
    }, 500);
    return () => clearTimeout(timer);
  };

  return (
    <form onSubmit={handleSubmit} className="w-full">
      <GlassInput
        type="text"
        placeholder={placeholder}
        value={query}
        onChange={handleChange}
        icon={<Search className="w-5 h-5" />}
        iconPosition="left"
      />
    </form>
  );
};

export default BlogSearch;
