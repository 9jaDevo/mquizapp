/**
 * Schema Generator Utility
 * Industrial-standard schema.org markup generation
 * Supports: NewsArticle, BreadcrumbList, FAQPage, Person
 */

interface Author {
    id: number;
    name: string;
    avatar: string;
    bio: string;
    social_links?: {
        twitter?: string;
        linkedin?: string;
        github?: string;
        website?: string;
        [key: string]: string | undefined;
    };
}

interface Category {
    id: number;
    name: string;
    slug: string;
}

interface BlogPost {
    id: number;
    title: string;
    slug: string;
    excerpt: string;
    content?: string;
    featured_image: string;
    author: Author;
    category: Category;
    created_at: string;
    updated_at: string;
    meta_title?: string;
    meta_description?: string;
    meta_keywords?: string;
    reading_time?: number;
    views: number;
}

interface FAQ {
    question: string;
    answer: string;
}

/**
 * Generate NewsArticle schema.org markup
 * Google standard for article/blog posts
 */
export function generateArticleSchema(
    post: BlogPost,
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any> {
    const authorSchema = generateAuthorSchema(post.author);

    return {
        '@context': 'https://schema.org',
        '@type': 'NewsArticle',
        '@id': `${baseUrl}/blog/${post.slug}#article`,
        headline: post.meta_title || post.title,
        description: post.meta_description || post.excerpt,
        image: {
            '@type': 'ImageObject',
            url: post.featured_image,
            width: 1200,
            height: 630,
        },
        datePublished: post.created_at,
        dateModified: post.updated_at,
        author: {
            '@type': 'Person',
            '@id': `${baseUrl}#/schema/person/${post.author.id}`,
            name: post.author.name,
            image: {
                '@type': 'ImageObject',
                url: post.author.avatar,
            },
            description: post.author.bio,
            // Add social profiles
            sameAs: Object.values(post.author.social_links || {}).filter(
                (link) => link && link.startsWith('http')
            ),
        },
        publisher: {
            '@type': 'Organization',
            '@id': `${baseUrl}#organization`,
            name: 'mQuiz',
            url: baseUrl,
            logo: {
                '@type': 'ImageObject',
                url: `${baseUrl}/logo.png`,
                width: 250,
                height: 60,
            },
        },
        articleSection: post.category.name,
        keywords: post.meta_keywords || '',
        wordCount: calculateWordCount(post.content || ''),
        timeRequired: `PT${post.reading_time || 5}M`,
        mainEntityOfPage: {
            '@type': 'WebPage',
            '@id': `${baseUrl}/blog/${post.slug}`,
        },
    };
}

/**
 * Generate BreadcrumbList schema
 * Helps search engines understand site hierarchy
 */
export function generateBreadcrumbSchema(
    segments: Array<{ name: string; url: string }>,
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any> {
    const itemListElement = segments.map((segment, index) => ({
        '@type': 'ListItem',
        position: index + 1,
        name: segment.name,
        item: segment.url.startsWith('http') ? segment.url : `${baseUrl}${segment.url}`,
    }));

    return {
        '@context': 'https://schema.org',
        '@type': 'BreadcrumbList',
        itemListElement,
    };
}

/**
 * Generate FAQPage schema
 * Used for FAQ sections on pages
 */
export function generateFAQPageSchema(
    faqs: FAQ[],
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any> {
    return {
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        '@id': `${baseUrl}#faqpage`,
        mainEntity: faqs.map((faq) => ({
            '@type': 'Question',
            name: faq.question,
            acceptedAnswer: {
                '@type': 'Answer',
                text: faq.answer,
            },
        })),
    };
}

/**
 * Generate Person schema for author
 * Includes social media profiles
 */
export function generateAuthorSchema(
    author: Author,
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any> {
    const sameAs = Object.values(author.social_links || {}).filter(
        (link) => link && link.startsWith('http')
    );

    return {
        '@context': 'https://schema.org',
        '@type': 'Person',
        '@id': `${baseUrl}#/schema/person/${author.id}`,
        name: author.name,
        image: author.avatar,
        description: author.bio,
        ...(sameAs.length > 0 && { sameAs }),
    };
}

/**
 * Generate Organization schema
 * Home page main entity
 */
export function generateOrganizationSchema(
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any> {
    return {
        '@context': 'https://schema.org',
        '@type': 'Organization',
        '@id': `${baseUrl}#organization`,
        name: 'mQuiz',
        url: baseUrl,
        logo: {
            '@type': 'ImageObject',
            url: `${baseUrl}/logo.png`,
            width: 250,
            height: 60,
        },
        description: 'Interactive quiz learning platform with real rewards',
        sameAs: [
            'https://facebook.com/mquizonline',
            'https://youtube.com/@mquizonline',
            'https://instagram.com/mquiz.uk',
            'https://tiktok.com/@mquiz.uk',
        ],
        contactPoint: {
            '@type': 'ContactPoint',
            contactType: 'Customer Support',
            url: `${baseUrl}/contact`,
        },
    };
}

/**
 * Generate LocalBusiness schema
 * For location-based information
 */
export function generateLocalBusinessSchema(
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any> {
    return {
        '@context': 'https://schema.org',
        '@type': 'LocalBusiness',
        '@id': `${baseUrl}#localbusiness`,
        name: 'mQuiz',
        url: baseUrl,
        logo: `${baseUrl}/logo.png`,
        description: 'Interactive quiz learning platform',
        contactPoint: {
            '@type': 'ContactPoint',
            contactType: 'Customer Service',
            email: 'contact@mquiz.uk',
        },
    };
}

/**
 * Generate WebSite schema with search action
 * Enables sitelinks search box
 */
export function generateWebsiteSchema(
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any> {
    return {
        '@context': 'https://schema.org',
        '@type': 'WebSite',
        '@id': `${baseUrl}#website`,
        url: baseUrl,
        name: 'mQuiz',
        potentialAction: {
            '@type': 'SearchAction',
            target: {
                '@type': 'EntryPoint',
                urlTemplate: `${baseUrl}/blog?search={search_term_string}`,
            },
            'query-input': 'required name=search_term_string',
        },
    };
}

/**
 * Calculate word count from HTML content
 */
function calculateWordCount(content: string): number {
    // Strip HTML tags
    const text = content.replace(/<[^>]*>/g, '');
    // Split by whitespace and count
    return text.trim().split(/\s+/).length;
}

/**
 * Combine multiple schemas into array
 * Useful for pages with multiple entity types
 */
export function combineSchemas(...schemas: Record<string, any>[]): Record<string, any>[] {
    return schemas.filter((schema) => schema && Object.keys(schema).length > 0);
}

/**
 * Validate schema structure
 * Ensures required fields are present
 */
export function validateSchema(schema: Record<string, any>): { valid: boolean; errors: string[] } {
    const errors: string[] = [];

    if (!schema['@context']) {
        errors.push('Missing @context');
    }

    if (!schema['@type']) {
        errors.push('Missing @type');
    }

    // Type-specific validations
    if (schema['@type'] === 'NewsArticle') {
        if (!schema.headline) errors.push('NewsArticle: Missing headline');
        if (!schema.datePublished) errors.push('NewsArticle: Missing datePublished');
        if (!schema.author) errors.push('NewsArticle: Missing author');
    }

    if (schema['@type'] === 'BreadcrumbList') {
        if (!schema.itemListElement || !Array.isArray(schema.itemListElement)) {
            errors.push('BreadcrumbList: Missing or invalid itemListElement');
        }
    }

    return {
        valid: errors.length === 0,
        errors,
    };
}

/**
 * Serialize schema to JSON-LD script tag
 */
export function serializeSchema(schema: Record<string, any>): string {
    return JSON.stringify(schema, null, 2);
}

/**
 * Generate schema for blog listing page
 * Combines WebSite + Organization schemas
 */
export function generateBlogListingSchema(
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any>[] {
    return [generateWebsiteSchema(baseUrl), generateOrganizationSchema(baseUrl)];
}

/**
 * Generate schema for article with all enhancements
 */
export function generateCompleteArticleSchema(
    post: BlogPost,
    breadcrumbs: Array<{ name: string; url: string }> = [],
    baseUrl: string = 'https://mquiz.uk'
): Record<string, any>[] {
    const schemas: Record<string, any>[] = [generateArticleSchema(post, baseUrl)];

    if (breadcrumbs.length > 0) {
        schemas.push(generateBreadcrumbSchema(breadcrumbs, baseUrl));
    }

    return schemas;
}
