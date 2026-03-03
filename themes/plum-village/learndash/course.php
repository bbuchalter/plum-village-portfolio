<?php
/**
 * LearnDash Course Template Override
 *
 * Renders the course content area: description, lesson list with progress
 * indicators, and CTA button. This is a content template — it renders inside
 * the_content(), NOT as a full page template.
 *
 * Available variables (extracted by LearnDash):
 * $course_id, $course, $user_id, $logged_in, $course_status,
 * $has_access, $lessons, $quizzes, $content, $materials,
 * $lesson_progression_enabled, $has_course_content, $lesson_topics
 *
 * @package PlumVillage
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

$course_steps  = learndash_get_course_steps( $course_id );
$lesson_count  = count( $course_steps );
?>

<div class="<?php echo esc_attr( learndash_the_wrapper_class() ); ?>">

	<?php
	/**
	 * Fires before the course content.
	 *
	 * @param int $post_id   Post ID.
	 * @param int $course_id Course ID.
	 * @param int $user_id   User ID.
	 */
	do_action( 'learndash-course-before', get_the_ID(), $course_id, $user_id );
	?>

	<p style="font-size: var(--wp--preset--font-size--small); color: var(--wp--preset--color--warm-brown); margin-bottom: var(--wp--preset--spacing--30);">
		<?php
		printf(
			_n( '%d lesson', '%d lessons', $lesson_count, 'plum-village' ),
			$lesson_count
		);
		?>
		&middot; Open access &middot; Self-paced
	</p>

	<?php if ( ! empty( $content ) ) : ?>
		<div class="learndash-course-single__content" style="margin-bottom: var(--wp--preset--spacing--40); line-height: 1.7;">
			<?php echo $content; // phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped ?>
		</div>
	<?php endif; ?>

	<?php if ( $logged_in && $course_status ) : ?>
		<div style="background: var(--wp--preset--color--light-sage); padding: var(--wp--preset--spacing--20); border-radius: 6px; margin-bottom: var(--wp--preset--spacing--30); font-size: var(--wp--preset--font-size--small);">
			<strong>Your status:</strong> <?php echo esc_html( $course_status ); ?>
		</div>
	<?php endif; ?>

	<?php if ( ! empty( $course_steps ) ) : ?>
		<h2 style="font-family: var(--wp--preset--font-family--heading); color: var(--wp--preset--color--forest-green); font-size: var(--wp--preset--font-size--x-large); margin-bottom: var(--wp--preset--spacing--20);">
			Lessons
		</h2>

		<ol style="list-style: none; padding: 0; margin: 0 0 var(--wp--preset--spacing--40);">
			<?php
			$lesson_num = 0;
			foreach ( $course_steps as $step_id ) :
				$step_post = get_post( $step_id );
				if ( ! $step_post || 'sfwd-lessons' !== $step_post->post_type ) {
					continue;
				}
				$lesson_num++;

				$is_complete = false;
				if ( $user_id ) {
					$is_complete = learndash_is_lesson_complete( $user_id, $step_id, $course_id );
				}

				$status_icon  = $is_complete ? '&#10003;' : $lesson_num;
				$status_color = $is_complete ? 'var(--wp--preset--color--forest-green)' : 'var(--wp--preset--color--warm-brown)';
				$status_bg    = $is_complete ? 'var(--wp--preset--color--light-sage)' : 'transparent';
			?>
				<li style="border-bottom: 1px solid var(--wp--preset--color--light-sage); padding: var(--wp--preset--spacing--20) 0;">
					<a href="<?php echo esc_url( get_permalink( $step_id ) ); ?>" style="display: flex; align-items: center; gap: var(--wp--preset--spacing--20); text-decoration: none; color: inherit;">
						<span style="display: flex; align-items: center; justify-content: center; width: 2rem; height: 2rem; border-radius: 50%; border: 2px solid <?php echo $status_color; ?>; background: <?php echo $status_bg; ?>; color: <?php echo $status_color; ?>; font-size: var(--wp--preset--font-size--small); font-weight: 600; flex-shrink: 0;">
							<?php echo $status_icon; ?>
						</span>
						<span style="font-family: var(--wp--preset--font-family--heading); font-size: var(--wp--preset--font-size--large); color: var(--wp--preset--color--dark-text);">
							<?php echo esc_html( $step_post->post_title ); ?>
						</span>
					</a>
				</li>
			<?php endforeach; ?>
		</ol>
	<?php endif; ?>

	<div style="text-align: center; margin-bottom: var(--wp--preset--spacing--40);">
		<?php if ( $logged_in && 'Completed' === $course_status ) : ?>
			<span style="display: inline-block; padding: 0.75rem 2rem; background: var(--wp--preset--color--light-sage); color: var(--wp--preset--color--forest-green); border-radius: 4px; font-weight: 600;">
				&#10003; Course Complete
			</span>
		<?php elseif ( ! empty( $course_steps ) ) : ?>
			<a href="<?php echo esc_url( get_permalink( $course_steps[0] ) ); ?>" style="display: inline-block; padding: 0.75rem 2rem; background: var(--wp--preset--color--forest-green); color: var(--wp--preset--color--cream); border-radius: 4px; text-decoration: none; font-weight: 600;">
				<?php echo $logged_in && 'In Progress' === $course_status ? 'Continue Course' : 'Begin Course'; ?> &rarr;
			</a>
		<?php endif; ?>
	</div>

	<?php
	/**
	 * Fires after the course content.
	 *
	 * @param int $post_id   Post ID.
	 * @param int $course_id Course ID.
	 * @param int $user_id   User ID.
	 */
	do_action( 'learndash-course-after', get_the_ID(), $course_id, $user_id );
	learndash_load_login_modal_html();
	?>

</div>
