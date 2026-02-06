<?php
defined('BASEPATH') or exit('No direct script access allowed');

/**
 * Geolocation Library
 * 
 * Handles country detection from IP addresses and continent mapping
 * Uses free IP geolocation APIs with caching for performance
 * 
 * @package    CodeIgniter
 * @category   Libraries
 * @author     Quiz App Team
 * @created    2026-02-06
 */
class Geolocation
{

    protected $CI;
    protected $cache_duration = 86400; // 24 hours in seconds

    public function __construct()
    {
        $this->CI = &get_instance();
        $this->CI->load->database();
    }

    /**
     * Detect country from IP address using free API
     * 
     * @param string $ip_address IP address to lookup
     * @return array|null Returns array with country_code, country_name, continent or null on failure
     */
    public function detectCountryFromIP($ip_address)
    {
        // Skip local/private IPs
        if ($this->isLocalIP($ip_address)) {
            return [
                'country_code' => 'US',
                'country_name' => 'United States',
                'continent' => 'North America'
            ];
        }

        // Check cache first
        $cached = $this->getCachedLocation($ip_address);
        if ($cached !== null) {
            return $cached;
        }

        // Try primary API: ip-api.com (free, no key required, 45 req/min)
        $location = $this->fetchFromIpApi($ip_address);

        // Fallback to secondary API if primary fails
        if ($location === null) {
            $location = $this->fetchFromIpInfo($ip_address);
        }

        // Cache the result
        if ($location !== null) {
            $this->cacheLocation($ip_address, $location);
        }

        return $location;
    }

    /**
     * Get continent name from country code
     * 
     * @param string $country_code ISO 3166-1 alpha-2 country code
     * @return string|null Continent name or null if not found
     */
    public function getContinent($country_code)
    {
        $query = $this->CI->db->select('continent')
            ->from('tbl_country_region_mapping')
            ->where('country_code', $country_code)
            ->get();

        if ($query->num_rows() > 0) {
            return $query->row()->continent;
        }

        return null;
    }

    /**
     * Get full country information from code
     * 
     * @param string $country_code ISO 3166-1 alpha-2 country code
     * @return object|null Country information or null if not found
     */
    public function getCountryInfo($country_code)
    {
        $query = $this->CI->db->select('country_code, country_name, continent, region_code')
            ->from('tbl_country_region_mapping')
            ->where('country_code', $country_code)
            ->get();

        if ($query->num_rows() > 0) {
            return $query->row();
        }

        return null;
    }

    /**
     * Get all countries for a continent
     * 
     * @param string $continent Continent name
     * @return array Array of country objects
     */
    public function getCountriesByContinent($continent)
    {
        $query = $this->CI->db->select('country_code, country_name, continent')
            ->from('tbl_country_region_mapping')
            ->where('continent', $continent)
            ->order_by('country_name', 'ASC')
            ->get();

        return $query->result();
    }

    /**
     * Get all continents
     * 
     * @return array Array of unique continent names
     */
    public function getAllContinents()
    {
        $query = $this->CI->db->select('DISTINCT continent')
            ->from('tbl_country_region_mapping')
            ->where('continent !=', 'Antarctica') // Exclude Antarctica
            ->order_by('continent', 'ASC')
            ->get();

        $continents = [];
        foreach ($query->result() as $row) {
            $continents[] = $row->continent;
        }

        return $continents;
    }

    /**
     * Fetch location from ip-api.com
     * 
     * @param string $ip_address IP address
     * @return array|null Location data or null on failure
     */
    private function fetchFromIpApi($ip_address)
    {
        try {
            $url = "http://ip-api.com/json/{$ip_address}?fields=status,message,countryCode,country,continent,continentCode";
            $response = @file_get_contents($url, false, stream_context_create([
                'http' => [
                    'timeout' => 3,
                    'ignore_errors' => true
                ]
            ]));

            if ($response === false) {
                return null;
            }

            $data = json_decode($response, true);

            if ($data && isset($data['status']) && $data['status'] === 'success') {
                // Map continent code to full name if needed
                $continent = $this->mapContinentName($data['continent']);

                return [
                    'country_code' => strtoupper($data['countryCode']),
                    'country_name' => $data['country'],
                    'continent' => $continent
                ];
            }

            return null;
        } catch (Exception $e) {
            log_message('error', 'Geolocation API error (ip-api): ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Fetch location from ipinfo.io (fallback)
     * 
     * @param string $ip_address IP address
     * @return array|null Location data or null on failure
     */
    private function fetchFromIpInfo($ip_address)
    {
        try {
            $url = "https://ipinfo.io/{$ip_address}/json";
            $response = @file_get_contents($url, false, stream_context_create([
                'http' => [
                    'timeout' => 3,
                    'ignore_errors' => true
                ]
            ]));

            if ($response === false) {
                return null;
            }

            $data = json_decode($response, true);

            if ($data && isset($data['country'])) {
                $country_code = strtoupper($data['country']);

                // Look up continent from our database
                $continent = $this->getContinent($country_code);
                if ($continent === null) {
                    $continent = 'Unknown';
                }

                // Get full country name from database
                $country_info = $this->getCountryInfo($country_code);
                $country_name = $country_info ? $country_info->country_name : $country_code;

                return [
                    'country_code' => $country_code,
                    'country_name' => $country_name,
                    'continent' => $continent
                ];
            }

            return null;
        } catch (Exception $e) {
            log_message('error', 'Geolocation API error (ipinfo): ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Map continent name variations to standard names
     * 
     * @param string $continent Continent name from API
     * @return string Standardized continent name
     */
    private function mapContinentName($continent)
    {
        $mapping = [
            'AF' => 'Africa',
            'AS' => 'Asia',
            'EU' => 'Europe',
            'NA' => 'North America',
            'SA' => 'South America',
            'OC' => 'Oceania',
            'AN' => 'Antarctica',
            'Africa' => 'Africa',
            'Asia' => 'Asia',
            'Europe' => 'Europe',
            'North America' => 'North America',
            'South America' => 'South America',
            'Oceania' => 'Oceania',
            'Antarctica' => 'Antarctica'
        ];

        return isset($mapping[$continent]) ? $mapping[$continent] : $continent;
    }

    /**
     * Check if IP is local/private
     * 
     * @param string $ip_address IP address to check
     * @return bool True if local IP
     */
    private function isLocalIP($ip_address)
    {
        // Check for localhost
        if (in_array($ip_address, ['127.0.0.1', '::1', 'localhost'])) {
            return true;
        }

        // Check for private IP ranges
        if (!filter_var($ip_address, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE)) {
            return true;
        }

        return false;
    }

    /**
     * Get cached location data for IP
     * 
     * @param string $ip_address IP address
     * @return array|null Cached location or null if not cached/expired
     */
    private function getCachedLocation($ip_address)
    {
        $cache_key = 'geo_' . md5($ip_address);

        // Using CodeIgniter's cache driver if available
        if (method_exists($this->CI, 'cache')) {
            $cached = $this->CI->cache->get($cache_key);
            if ($cached !== false) {
                return $cached;
            }
        }

        // Fallback to database cache
        $query = $this->CI->db->select('cache_data')
            ->from('tbl_cache')
            ->where('cache_key', $cache_key)
            ->where('cache_expiry >', time())
            ->get();

        if ($query && $query->num_rows() > 0) {
            return json_decode($query->row()->cache_data, true);
        }

        return null;
    }

    /**
     * Cache location data for IP
     * 
     * @param string $ip_address IP address
     * @param array $location Location data
     */
    private function cacheLocation($ip_address, $location)
    {
        $cache_key = 'geo_' . md5($ip_address);

        // Using CodeIgniter's cache driver if available
        if (method_exists($this->CI, 'cache')) {
            $this->CI->cache->save($cache_key, $location, $this->cache_duration);
            return;
        }

        // Fallback to database cache
        // Create cache table if it doesn't exist
        if (!$this->CI->db->table_exists('tbl_cache')) {
            $this->CI->db->query("
                CREATE TABLE IF NOT EXISTS `tbl_cache` (
                    `id` int NOT NULL AUTO_INCREMENT,
                    `cache_key` varchar(255) NOT NULL,
                    `cache_data` text NOT NULL,
                    `cache_expiry` int NOT NULL,
                    PRIMARY KEY (`id`),
                    UNIQUE KEY `cache_key` (`cache_key`),
                    KEY `cache_expiry` (`cache_expiry`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
            ");
        }

        $data = [
            'cache_key' => $cache_key,
            'cache_data' => json_encode($location),
            'cache_expiry' => time() + $this->cache_duration
        ];

        // Insert or update
        $existing = $this->CI->db->where('cache_key', $cache_key)->get('tbl_cache');
        if ($existing->num_rows() > 0) {
            $this->CI->db->where('cache_key', $cache_key)->update('tbl_cache', $data);
        } else {
            $this->CI->db->insert('tbl_cache', $data);
        }
    }

    /**
     * Get user's IP address from request
     * Handles proxies and load balancers
     * 
     * @return string IP address
     */
    public function getUserIP()
    {
        $ip_keys = [
            'HTTP_CF_CONNECTING_IP',  // CloudFlare
            'HTTP_X_FORWARDED_FOR',    // Proxy
            'HTTP_CLIENT_IP',          // Proxy
            'HTTP_X_REAL_IP',          // Nginx proxy
            'REMOTE_ADDR'              // Direct connection
        ];

        foreach ($ip_keys as $key) {
            if (isset($_SERVER[$key]) && !empty($_SERVER[$key])) {
                $ip = $_SERVER[$key];

                // Handle comma-separated IPs (X-Forwarded-For can have multiple)
                if (strpos($ip, ',') !== false) {
                    $ips = explode(',', $ip);
                    $ip = trim($ips[0]);
                }

                // Validate IP
                if (filter_var($ip, FILTER_VALIDATE_IP)) {
                    return $ip;
                }
            }
        }

        return '0.0.0.0';
    }
}
