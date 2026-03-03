<?php
/**
 * Plugin Name: Plum Village Blocks
 * Description: Custom Gutenberg blocks for the Plum Village online monastery.
 * Version: 1.0.0
 * Author: Brian Buchalter
 * License: GPL-2.0-or-later
 * Text Domain: plum-village-blocks
 */

if (!defined('ABSPATH')) exit;

function plum_village_blocks_init() {
    register_block_type(__DIR__ . '/build/dharma-talk');
    register_block_type(__DIR__ . '/build/practice-pause');
}
add_action('init', 'plum_village_blocks_init');
