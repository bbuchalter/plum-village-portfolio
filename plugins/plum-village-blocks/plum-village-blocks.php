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
    register_block_type(__DIR__ . '/build/course-grid', array(
        'render_callback' => 'plum_village_render_course_grid',
    ));
}
add_action('init', 'plum_village_blocks_init');

/**
 * Server-side render callback for the Course Grid block.
 *
 * Queries LearnDash courses and returns an HTML grid of course cards.
 * Used by ServerSideRender in the editor and for frontend output.
 */
function plum_village_render_course_grid( $attributes ) {
    $columns          = isset( $attributes['columns'] ) ? absint( $attributes['columns'] ) : 3;
    $count            = isset( $attributes['count'] ) ? absint( $attributes['count'] ) : 3;
    $show_excerpt     = isset( $attributes['showExcerpt'] ) ? (bool) $attributes['showExcerpt'] : true;
    $show_lesson_count = isset( $attributes['showLessonCount'] ) ? (bool) $attributes['showLessonCount'] : true;

    $courses = get_posts( array(
        'post_type'      => 'sfwd-courses',
        'posts_per_page' => $count,
        'post_status'    => 'publish',
        'orderby'        => 'date',
        'order'          => 'DESC',
    ) );

    if ( empty( $courses ) ) {
        return '<div class="wp-block-plum-village-course-grid"><p class="wp-block-plum-village-course-grid__empty">No courses available yet.</p></div>';
    }

    $html = sprintf(
        '<div class="wp-block-plum-village-course-grid" data-columns="%d"><div class="wp-block-plum-village-course-grid__grid">',
        $columns
    );

    foreach ( $courses as $course ) {
        $course_id = $course->ID;
        $permalink = get_permalink( $course_id );
        $title     = esc_html( $course->post_title );

        // Thumbnail
        if ( has_post_thumbnail( $course_id ) ) {
            $image = get_the_post_thumbnail( $course_id, 'medium_large', array(
                'class' => 'wp-block-plum-village-course-grid__card-image',
            ) );
            $thumbnail = sprintf( '<a href="%s">%s</a>', esc_url( $permalink ), $image );
        } else {
            $thumbnail = sprintf(
                '<a href="%s" class="wp-block-plum-village-course-grid__card-placeholder">&#128218;</a>',
                esc_url( $permalink )
            );
        }

        // Meta line
        $meta = '';
        if ( $show_lesson_count && function_exists( 'learndash_get_course_steps' ) ) {
            $steps = learndash_get_course_steps( $course_id );
            $lesson_count = count( $steps );
            $meta = sprintf(
                '<p class="wp-block-plum-village-course-grid__card-meta">%s &middot; Open access</p>',
                sprintf( _n( '%d lesson', '%d lessons', $lesson_count, 'plum-village-blocks' ), $lesson_count )
            );
        }

        // Excerpt
        $excerpt = '';
        if ( $show_excerpt ) {
            $text = $course->post_excerpt ?: wp_trim_words( wp_strip_all_tags( $course->post_content ), 20 );
            if ( $text ) {
                $excerpt = sprintf(
                    '<p class="wp-block-plum-village-course-grid__card-excerpt">%s</p>',
                    esc_html( $text )
                );
            }
        }

        $html .= sprintf(
            '<article class="wp-block-plum-village-course-grid__card">
                %s
                <div class="wp-block-plum-village-course-grid__card-body">
                    <h3 class="wp-block-plum-village-course-grid__card-title"><a href="%s">%s</a></h3>
                    %s
                    %s
                    <a href="%s" class="wp-block-plum-village-course-grid__card-link">View Course &rarr;</a>
                </div>
            </article>',
            $thumbnail,
            esc_url( $permalink ),
            $title,
            $meta,
            $excerpt,
            esc_url( $permalink )
        );
    }

    $html .= '</div></div>';

    return $html;
}
