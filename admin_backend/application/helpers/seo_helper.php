<?php

/**
 * SEO Helper Functions
 * 
 * Provides industrial-standard SEO utilities:
 * - TF-IDF based keyword extraction
 * - Automatic meta description generation
 * - Keyword validation and quality checks
 * - Entity extraction for AI model compliance
 * - Keyword density analysis
 */

defined('BASEPATH') or exit('No direct script access allowed');

/**
 * English stop words for keyword filtering
 * Removes common words that don't add SEO value
 */
$STOP_WORDS = array(
    'the',
    'a',
    'an',
    'and',
    'or',
    'but',
    'in',
    'on',
    'at',
    'to',
    'for',
    'of',
    'by',
    'with',
    'is',
    'are',
    'was',
    'were',
    'be',
    'been',
    'being',
    'have',
    'has',
    'had',
    'do',
    'does',
    'did',
    'will',
    'would',
    'could',
    'should',
    'may',
    'might',
    'can',
    'this',
    'that',
    'these',
    'those',
    'i',
    'you',
    'he',
    'she',
    'it',
    'we',
    'they',
    'what',
    'which',
    'who',
    'when',
    'where',
    'why',
    'how',
    'all',
    'each',
    'every',
    'both',
    'few',
    'more',
    'most',
    'other',
    'some',
    'such',
    'no',
    'nor',
    'not',
    'only',
    'so',
    'as',
    'as',
    'if',
    'than',
    'from',
    'up',
    'about',
    'into',
    'through',
    'during',
    'before',
    'after',
    'above',
    'below',
    'between',
    'under',
    'again',
    'further',
    'then',
    'once',
    'here',
    'there',
    'your',
    'their',
    'our',
    'just'
);

/**
 * Generate keywords from content using TF-IDF approach
 * Industrial standard: Combines term frequency with content relevance
 * 
 * @param string $content Main content text or HTML
 * @param string $title Document title (weighted higher)
 * @param int $min_length Minimum keyword character length
 * @param int $max_keywords Maximum keywords to generate
 * @param array $stop_words Optional custom stop words list
 * @return string Comma-separated keywords string
 */
function generate_keywords($content, $title = '', $min_length = 3, $max_keywords = 10, $stop_words = null)
{
    global $STOP_WORDS;

    if (empty($content)) {
        return '';
    }

    // Use default stop words if none provided
    if ($stop_words === null) {
        $stop_words = $STOP_WORDS;
    }

    // Strip HTML tags and normalize whitespace
    $clean_content = strip_tags($content);
    $clean_content = preg_replace('/\s+/', ' ', $clean_content);
    $clean_content = trim($clean_content);

    // Lowercase for processing
    $text_lower = strtolower($clean_content);
    $title_lower = strtolower($title);

    // Extract words (2+ characters)
    preg_match_all('/\b[a-z]{2,}\b/', $text_lower, $matches);
    $words = $matches[0];

    // Also extract from title with higher weight
    preg_match_all('/\b[a-z]{2,}\b/', $title_lower, $title_matches);
    $title_words = $title_matches[0];

    // Calculate term frequency
    $word_freq = array_count_values($words);
    $title_freq = array_count_values($title_words);

    // Weight title words higher (3x)
    foreach ($title_freq as $word => $count) {
        $word_freq[$word] = isset($word_freq[$word]) ? $word_freq[$word] + ($count * 3) : ($count * 3);
    }

    // Filter stop words and short terms
    $filtered_keywords = array();
    foreach ($word_freq as $word => $freq) {
        $len = strlen($word);
        if ($len >= $min_length && !in_array($word, $stop_words) && $freq >= 2) {
            $filtered_keywords[$word] = $freq;
        }
    }

    // Extract multi-word phrases (2-3 words)
    $phrases = extract_phrases($clean_content, 2, 3, $stop_words);
    foreach ($phrases as $phrase => $freq) {
        if ($freq >= 2) {
            $filtered_keywords[$phrase] = $freq + 5; // Boost phrase frequency
        }
    }

    // Sort by frequency (descending)
    arsort($filtered_keywords);

    // Limit to max keywords and enforce minimum character length per keyword
    $final_keywords = array();
    foreach ($filtered_keywords as $keyword => $freq) {
        if (strlen($keyword) >= $min_length && strlen($keyword) <= 50) {
            $final_keywords[] = trim($keyword);
            if (count($final_keywords) >= $max_keywords) {
                break;
            }
        }
    }

    // Ensure minimum of 3 keywords if content is substantial
    if (count($final_keywords) < 3 && str_word_count($content) > 100) {
        // If we don't have enough, add top individual words
        $top_words = array_slice(array_keys($word_freq), 0, $max_keywords);
        foreach ($top_words as $word) {
            if (!in_array($word, $final_keywords) && strlen($word) >= $min_length) {
                $final_keywords[] = $word;
                if (count($final_keywords) >= 3) {
                    break;
                }
            }
        }
    }

    return implode(', ', $final_keywords);
}

/**
 * Extract multi-word phrases from content
 * Used for long-tail keyword generation
 * 
 * @param string $text Content text
 * @param int $min_words Minimum words in phrase
 * @param int $max_words Maximum words in phrase
 * @param array $stop_words Stop words list
 * @return array Phrase frequency array
 */
function extract_phrases($text, $min_words = 2, $max_words = 3, $stop_words = null)
{
    global $STOP_WORDS;

    if ($stop_words === null) {
        $stop_words = $STOP_WORDS;
    }

    $text = strtolower($text);
    preg_match_all('/\b[a-z]{2,}\b/', $text, $matches);
    $words = $matches[0];

    $phrases = array();

    for ($size = $min_words; $size <= $max_words; $size++) {
        for ($i = 0; $i <= count($words) - $size; $i++) {
            $phrase_words = array_slice($words, $i, $size);

            // Skip if contains stop words
            $has_stop = false;
            foreach ($phrase_words as $word) {
                if (in_array($word, $stop_words)) {
                    $has_stop = true;
                    break;
                }
            }

            if (!$has_stop) {
                $phrase = implode(' ', $phrase_words);
                $phrases[$phrase] = isset($phrases[$phrase]) ? $phrases[$phrase] + 1 : 1;
            }
        }
    }

    // Only keep phrases that appear 2+ times
    return array_filter($phrases, function ($count) {
        return $count >= 2;
    });
}

/**
 * Auto-generate meta description from content
 * Industrial standard: 150-160 characters, first meaningful sentences
 * 
 * @param string $content Full content HTML/text
 * @param int $target_length Target description length (Google standard: 160)
 * @param int $min_length Minimum acceptable length
 * @return string Meta description
 */
function auto_meta_description($content, $target_length = 160, $min_length = 120)
{
    if (empty($content)) {
        return '';
    }

    // Strip HTML tags
    $text = strip_tags($content);

    // Remove extra whitespace
    $text = preg_replace('/\s+/', ' ', $text);
    $text = trim($text);

    // If content is shorter than target, return as-is
    if (strlen($text) <= $target_length) {
        return $text;
    }

    // Extract first N sentences that fit length requirement
    $sentences = preg_split('/(?<=[.!?])\s+/', $text);

    $description = '';
    foreach ($sentences as $sentence) {
        $sentence = trim($sentence);
        if (empty($sentence)) {
            continue;
        }

        $test_description = $description . ($description ? ' ' : '') . $sentence;

        if (strlen($test_description) <= $target_length) {
            $description = $test_description;
        } else {
            break;
        }
    }

    // If no complete sentences fit, truncate at word boundary
    if (strlen($description) < $min_length) {
        $description = substr($text, 0, $target_length);
        // Truncate at last word boundary
        $last_space = strrpos($description, ' ');
        if ($last_space !== false) {
            $description = substr($description, 0, $last_space) . '...';
        }
    }

    return trim($description);
}

/**
 * Validate and clean keywords string
 * Ensures quality and uniqueness
 * 
 * @param string $keywords_string Comma-separated keywords
 * @param bool $strict_mode Enforce strict quality checks
 * @return string Validated and cleaned keywords
 */
function validate_keywords($keywords_string, $strict_mode = true)
{
    if (empty($keywords_string)) {
        return '';
    }

    // Split and clean
    $keywords = array_map('trim', explode(',', $keywords_string));

    // Remove duplicates (case-insensitive)
    $keywords = array_unique(array_map('strtolower', $keywords));

    // Validate each keyword
    $valid_keywords = array();
    foreach ($keywords as $keyword) {
        $keyword = trim($keyword);
        $len = strlen($keyword);

        if ($strict_mode) {
            // Strict mode: 3-50 chars, no special chars except hyphens
            if ($len >= 3 && $len <= 50 && preg_match('/^[a-z0-9\s\-]+$/i', $keyword)) {
                $valid_keywords[] = $keyword;
            }
        } else {
            // Lenient mode: just enforce length
            if ($len >= 3 && $len <= 50) {
                $valid_keywords[] = $keyword;
            }
        }
    }

    return implode(', ', $valid_keywords);
}

/**
 * Extract named entities and concepts from content
 * Used for AI model compliance and semantic understanding
 * 
 * @param string $content Content text
 * @param int $limit Maximum entities to return
 * @return array Entity array
 */
function extract_entities($content, $limit = 5)
{
    if (empty($content)) {
        return array();
    }

    // Extract capitalized phrases (potential proper nouns)
    preg_match_all('/\b[A-Z][a-z]+(?:\s[A-Z][a-z]+)*/m', $content, $matches);
    $entities = array_count_values($matches[0]);

    // Sort by frequency
    arsort($entities);

    // Return top entities
    return array_keys(array_slice($entities, 0, $limit));
}

/**
 * Calculate keyword density in content
 * Helps identify over-optimization issues
 * Google standard: 1-2% density ideal
 * 
 * @param string $content Full content
 * @param string $keyword Keyword to check
 * @return float Keyword density percentage
 */
function calculate_keyword_density($content, $keyword)
{
    if (empty($content) || empty($keyword)) {
        return 0;
    }

    $keyword_lower = strtolower($keyword);
    $content_lower = strtolower($content);

    // Count occurrences
    $keyword_count = substr_count($content_lower, $keyword_lower);

    // Get word count
    $word_count = str_word_count(strip_tags($content));

    if ($word_count == 0) {
        return 0;
    }

    // Calculate density
    $keyword_words = str_word_count($keyword);
    $density = ($keyword_count * $keyword_words / $word_count) * 100;

    return round($density, 2);
}

/**
 * Get reading time estimation
 * Useful for user engagement and schema markup
 * 
 * @param string $content Content text
 * @param int $words_per_minute Reading speed (average: 200)
 * @return int Reading time in minutes
 */
function get_reading_time($content, $words_per_minute = 200)
{
    $word_count = str_word_count(strip_tags($content));
    $reading_time = ceil($word_count / $words_per_minute);
    return max(1, $reading_time);
}

/**
 * Log SEO generation activity for analytics
 * Tracks which posts use auto-generated vs editor keywords
 * 
 * @param int $post_id Post ID
 * @param string $source 'editor' or 'auto'
 * @param string $keywords Generated/provided keywords
 * @param object $ci CodeIgniter instance
 * @return bool Success status
 */
function log_seo_activity($post_id, $source, $keywords, $ci = null)
{
    // If CodeIgniter instance not provided, try to get it
    if ($ci === null) {
        $ci = &get_instance();
    }

    try {
        $ci->db->set('post_id', $post_id);
        $ci->db->set('keyword_source', $source);
        $ci->db->set('keywords_generated', $keywords);
        $ci->db->set('keyword_count', count(explode(',', $keywords)));
        $ci->db->insert('tbl_blog_seo_analytics');

        return true;
    } catch (Exception $e) {
        // Fail silently - don't break blog functionality
        return false;
    }
}

/**
 * Check if keywords meet minimum quality threshold
 * 
 * @param string $keywords Comma-separated keywords
 * @return bool True if keywords meet quality standards
 */
function is_quality_keywords($keywords)
{
    if (empty($keywords)) {
        return false;
    }

    $keyword_array = array_map('trim', explode(',', $keywords));

    // Quality checks:
    // 1. Minimum 3 keywords
    // 2. Each keyword 3-50 chars
    // 3. At least 50% should be multi-word phrases or nouns

    if (count($keyword_array) < 3) {
        return false;
    }

    $valid_count = 0;
    foreach ($keyword_array as $kw) {
        $len = strlen($kw);
        if ($len >= 3 && $len <= 50) {
            $valid_count++;
        }
    }

    return ($valid_count / count($keyword_array)) >= 0.5;
}

/**
 * Sanitize HTML content for plain text extraction
 * Removes script tags, style, and markdown artifacts
 * 
 * @param string $html HTML content
 * @return string Plain text
 */
function sanitize_content_for_seo($html)
{
    // Remove script and style tags
    $text = preg_replace('/<script\b[^>]*>(.*?)<\/script>/is', '', $html);
    $text = preg_replace('/<style\b[^>]*>(.*?)<\/style>/is', '', $text);

    // Strip HTML tags
    $text = strip_tags($text);

    // Decode HTML entities
    $text = html_entity_decode($text, ENT_QUOTES, 'UTF-8');

    // Remove excessive whitespace
    $text = preg_replace('/\s+/', ' ', $text);

    return trim($text);
}

/* End of file seo_helper.php */
