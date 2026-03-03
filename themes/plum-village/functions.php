<?php
/**
 * Plum Village Theme Functions
 *
 * @package PlumVillage
 * @since 1.0.0
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * Enqueue Google Fonts.
 */
function plum_village_enqueue_fonts() {
	$fonts_url = 'https://fonts.googleapis.com/css2?' . implode( '&', array(
		'family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700',
		'family=Source+Sans+3:wght@400;600',
		'display=swap',
	) );

	wp_enqueue_style(
		'plum-village-google-fonts',
		$fonts_url,
		array(),
		null
	);
}
add_action( 'wp_enqueue_scripts', 'plum_village_enqueue_fonts' );
add_action( 'enqueue_block_editor_assets', 'plum_village_enqueue_fonts' );

/**
 * Theme setup.
 */
function plum_village_setup() {
	add_theme_support( 'wp-block-styles' );
	add_theme_support( 'learndash' );
	add_theme_support( 'buddypress' );
}
add_action( 'after_setup_theme', 'plum_village_setup' );

/**
 * Register block pattern category.
 */
function plum_village_register_pattern_category() {
	register_block_pattern_category(
		'plum-village',
		array(
			'label' => __( 'Plum Village', 'plum-village' ),
		)
	);
}
add_action( 'init', 'plum_village_register_pattern_category' );
