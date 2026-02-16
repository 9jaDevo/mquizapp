/**
 * SEO Configuration
 * Centralized SEO metadata for all pages
 */

export interface PageSEO {
    title: string;
    description: string;
    keywords: string;
    type?: string;
    image?: string;
}

export const seoConfig: Record<string, PageSEO> = {
    home: {
        title: 'mQuiz - Learn, Engage, and Earn Rewards | Quiz Learning App',
        description: 'Join mQuiz, the ultimate quiz app that combines fun learning with real rewards. Challenge yourself, compete with friends, and earn while you learn.',
        keywords: 'quiz app, learning app, earn money, educational games, online quizzes, gamified learning, peer-to-peer quiz battles, earn rewards',
        type: 'website',
        image: 'https://mquiz.uk/og-image.jpg',
    },

    features: {
        title: 'mQuiz Features - Gamified Learning, P2P Battles & Real Rewards',
        description: 'Discover mQuiz features: gamified learning with achievements, P2P quiz battles, real gem rewards, progress tracking, daily quizzes, math challenges, and 12+ quiz modes to master your knowledge.',
        keywords: 'quiz features, gamified learning, P2P quiz battles, earn gems, quiz rewards, leaderboard, 1v1 battles, group quiz, daily quiz, math quiz, audio quiz, true false quiz, exam preparation',
        type: 'website',
    },

    about: {
        title: 'About mQuiz - Our Mission and Story',
        description: 'Learn about mQuiz\'s mission to revolutionize education through gamification and interactive learning. Discover our story and values.',
        keywords: 'about mquiz, TOG Africa, educational technology, ICT in education, gamification, quiz learning platform, Nigeria education',
        type: 'website',
    },

    download: {
        title: 'Download mQuiz App - Available on Android & iOS',
        description: 'Download mQuiz app for free on Google Play Store and App Store. Start learning and earning rewards today!',
        keywords: 'download mquiz, mquiz app, quiz app download, android quiz app, ios quiz app, google play store, app store, free learning app',
        type: 'website',
    },

    competition: {
        title: 'mQuiz Battle for 100K - Competition Details & Prizes',
        description: 'Learn about the mQuiz Battle for 100K contest timeline, entry requirements, prizes, and social ambassador award. Compete on the mQuiz app to win real cash.',
        keywords: 'mquiz competition, quiz contest, battle for 100k, mquiz prizes, leaderboard contest, social ambassador award, skill-based quiz challenge',
        type: 'website',
    },

    contact: {
        title: 'Contact mQuiz - Get in Touch',
        description: 'Have questions? Contact the mQuiz team. We\'re here to help with any queries about our quiz learning platform.',
        keywords: 'contact mquiz, customer support, help, support email, mquiz contact form, get in touch',
        type: 'website',
    },

    blog: {
        title: 'mQuiz Blog - Learning Tips, Updates & Insights',
        description: 'Read the latest articles, tips, and insights on gamified learning, quiz strategies, and educational technology.',
        keywords: 'mquiz blog, learning tips, quiz strategies, education blog, study tips, exam preparation, gamification, educational insights',
        type: 'blog',
    },

    privacy: {
        title: 'Privacy Policy - mQuiz',
        description: 'Read mQuiz\'s privacy policy to understand how we collect, use, and protect your personal information.',
        keywords: 'privacy policy, data protection, user privacy, mquiz privacy, terms of service',
        type: 'website',
    },

    terms: {
        title: 'Terms & Conditions - mQuiz',
        description: 'Read mQuiz\'s terms and conditions to understand the rules and guidelines for using our platform.',
        keywords: 'terms and conditions, user agreement, terms of service, mquiz terms, usage guidelines',
        type: 'website',
    },
};

/**
 * Generate dynamic blog title based on filters
 */
export const generateBlogTitle = (params: {
    category?: string;
    search?: string;
    page?: number;
}): string => {
    const { category, search, page } = params;

    let title = 'mQuiz Blog';

    if (search) {
        title += ` - Search Results for "${search}"`;
    } else if (category) {
        // Capitalize category name
        const categoryName = category
            .split('-')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
        title += ` - ${categoryName} Articles`;
    } else {
        title += ' - Learning Tips, Updates & Insights';
    }

    if (page && page > 1) {
        title += ` - Page ${page}`;
    }

    return title;
};

/**
 * Generate dynamic blog description based on filters
 */
export const generateBlogDescription = (params: {
    category?: string;
    search?: string;
    page?: number;
    totalPosts?: number;
}): string => {
    const { category, search, page, totalPosts } = params;

    if (search) {
        const resultCount = totalPosts ? `${totalPosts} ` : '';
        return `Browse ${resultCount}articles matching "${search}". Find tips, strategies, and insights on quiz learning and education.`;
    }

    if (category) {
        const categoryName = category
            .split('-')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
        return `Explore ${categoryName} articles on mQuiz Blog. Discover expert tips, strategies, and insights to improve your learning experience.`;
    }

    const pageInfo = page && page > 1 ? ` - Page ${page}` : '';
    return `Read the latest articles, tips, and insights on gamified learning, quiz strategies, and educational technology${pageInfo}.`;
};

/**
 * Generate dynamic blog keywords based on filters
 */
export const generateBlogKeywords = (params: {
    category?: string;
    search?: string;
}): string => {
    const { category, search } = params;

    const baseKeywords = 'mquiz blog, learning tips, quiz strategies, education blog, study tips';

    if (search) {
        return `${baseKeywords}, ${search}, search results`;
    }

    if (category) {
        return `${baseKeywords}, ${category}, ${category} articles`;
    }

    return `${baseKeywords}, exam preparation, gamification, educational insights`;
};

/**
 * Get category display name from slug
 */
export const getCategoryDisplayName = (slug: string): string => {
    return slug
        .split('-')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
};
