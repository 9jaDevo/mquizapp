<?php

defined('BASEPATH') or exit('No direct script access allowed');

class Migration_Add_seo_analytics extends CI_Migration
{

    public function up()
    {
        // Create SEO Analytics tracking table
        $this->dbforge->add_field(array(
            'id' => array(
                'type' => 'INT',
                'constraint' => 11,
                'unsigned' => TRUE,
                'auto_increment' => TRUE
            ),
            'post_id' => array(
                'type' => 'INT',
                'constraint' => 11,
                'unsigned' => TRUE,
            ),
            'keyword_source' => array(
                'type' => 'ENUM',
                'constraint' => array('editor', 'auto'),
                'default' => 'auto',
            ),
            'keywords_generated' => array(
                'type' => 'VARCHAR',
                'constraint' => 500,
                'null' => TRUE,
            ),
            'keyword_count' => array(
                'type' => 'INT',
                'constraint' => 3,
                'default' => 0,
                'unsigned' => TRUE,
            ),
            'ai_bot_hits' => array(
                'type' => 'INT',
                'constraint' => 11,
                'default' => 0,
                'unsigned' => TRUE,
            ),
            'human_views' => array(
                'type' => 'INT',
                'constraint' => 11,
                'default' => 0,
                'unsigned' => TRUE,
            ),
            'avg_time_on_page' => array(
                'type' => 'INT',
                'constraint' => 11,
                'default' => 0,
                'unsigned' => TRUE,
                'comment' => 'Average time on page in seconds'
            ),
            'last_updated' => array(
                'type' => 'TIMESTAMP',
                'default' => 'CURRENT_TIMESTAMP',
                'on_update' => 'CURRENT_TIMESTAMP'
            ),
        ));

        $this->dbforge->add_key('id', TRUE);
        $this->dbforge->add_key('post_id');
        $this->dbforge->add_key('keyword_source');

        // Add unique key for post_id
        $this->db->query('ALTER TABLE tbl_blog_seo_analytics ADD UNIQUE KEY unique_post_seo (post_id)');

        $this->dbforge->create_table('tbl_blog_seo_analytics', TRUE);

        // Add foreign key constraint
        $this->db->query('ALTER TABLE tbl_blog_seo_analytics ADD CONSTRAINT fk_blog_seo_post FOREIGN KEY (post_id) REFERENCES tbl_blog_posts(id) ON DELETE CASCADE');
    }

    public function down()
    {
        // Drop foreign key first
        $this->db->query('ALTER TABLE tbl_blog_seo_analytics DROP FOREIGN KEY fk_blog_seo_post');

        // Drop table
        $this->dbforge->drop_table('tbl_blog_seo_analytics', TRUE);
    }
}
