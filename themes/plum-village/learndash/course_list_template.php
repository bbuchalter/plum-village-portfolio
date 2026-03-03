<?php
/**
 * LearnDash Course List Template Override
 *
 * Renders a grid of course cards for the course archive page.
 * Overrides LearnDash's default course list output.
 *
 * @package PlumVillage
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

$courses = get_posts( array(
	'post_type'      => 'sfwd-courses',
	'posts_per_page' => 12,
	'post_status'    => 'publish',
	'orderby'        => 'date',
	'order'          => 'DESC',
) );

get_header();
?>

<div class="learndash-course-archive" style="max-width: 1100px; margin: 0 auto; padding: var(--wp--preset--spacing--40) var(--wp--preset--spacing--30);">

	<h1 style="font-family: var(--wp--preset--font-family--heading); color: var(--wp--preset--color--forest-green); font-size: var(--wp--preset--font-size--xx-large); text-align: center; margin-bottom: var(--wp--preset--spacing--10);">
		Courses
	</h1>

	<p style="text-align: center; color: var(--wp--preset--color--warm-brown); font-size: var(--wp--preset--font-size--large); font-family: var(--wp--preset--font-family--heading); font-style: italic; margin-bottom: var(--wp--preset--spacing--40);">
		Explore the practices of the Plum Village tradition
	</p>

	<?php if ( ! empty( $courses ) ) : ?>
		<div class="learndash-course-archive__grid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: var(--wp--preset--spacing--30);">
			<?php foreach ( $courses as $course ) :
				$course_id   = $course->ID;
				$steps       = learndash_get_course_steps( $course_id );
				$lesson_count = count( $steps );
				$excerpt     = $course->post_excerpt ?: wp_trim_words( $course->post_content, 20 );
			?>
				<article class="learndash-course-card" style="background: var(--wp--preset--color--soft-white); border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.08); transition: box-shadow 0.2s ease;">
					<?php if ( has_post_thumbnail( $course_id ) ) : ?>
						<a href="<?php echo esc_url( get_permalink( $course_id ) ); ?>">
							<?php echo get_the_post_thumbnail( $course_id, 'medium_large', array( 'style' => 'width: 100%; height: 200px; object-fit: cover; display: block;' ) ); ?>
						</a>
					<?php else : ?>
						<a href="<?php echo esc_url( get_permalink( $course_id ) ); ?>" style="display: block; height: 200px; background: linear-gradient(135deg, var(--wp--preset--color--cream) 0%, var(--wp--preset--color--light-sage) 100%); display: flex; align-items: center; justify-content: center;">
							<span style="font-size: 3rem; opacity: 0.3;">&#128218;</span>
						</a>
					<?php endif; ?>

					<div style="padding: var(--wp--preset--spacing--20) var(--wp--preset--spacing--20) var(--wp--preset--spacing--30);">
						<h3 style="font-family: var(--wp--preset--font-family--heading); color: var(--wp--preset--color--forest-green); font-size: var(--wp--preset--font-size--large); margin: 0 0 var(--wp--preset--spacing--10);">
							<a href="<?php echo esc_url( get_permalink( $course_id ) ); ?>" style="color: inherit; text-decoration: none;">
								<?php echo esc_html( $course->post_title ); ?>
							</a>
						</h3>

						<p style="font-size: var(--wp--preset--font-size--small); color: var(--wp--preset--color--warm-brown); margin: 0 0 var(--wp--preset--spacing--10);">
							<?php
							printf(
								_n( '%d lesson', '%d lessons', $lesson_count, 'plum-village' ),
								$lesson_count
							);
							?>
							&middot; Open access
						</p>

						<?php if ( $excerpt ) : ?>
							<p style="font-size: var(--wp--preset--font-size--small); color: var(--wp--preset--color--dark-text); line-height: 1.6; margin: 0 0 var(--wp--preset--spacing--20);">
								<?php echo esc_html( wp_strip_all_tags( $excerpt ) ); ?>
							</p>
						<?php endif; ?>

						<a href="<?php echo esc_url( get_permalink( $course_id ) ); ?>" style="display: inline-block; color: var(--wp--preset--color--forest-green); font-weight: 600; font-size: var(--wp--preset--font-size--small); text-decoration: none;">
							View Course &rarr;
						</a>
					</div>
				</article>
			<?php endforeach; ?>
		</div>
	<?php else : ?>
		<p style="text-align: center; color: var(--wp--preset--color--warm-brown); font-style: italic;">
			No courses available yet. Check back soon.
		</p>
	<?php endif; ?>

</div>

<?php
get_footer();
