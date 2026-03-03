<?php
/**
 * LearnDash Lesson Template Override
 *
 * Renders lesson content with breadcrumbs, progress indicator,
 * mark-complete button, and previous/next navigation. This is a content
 * template — it renders inside the_content(), NOT as a full page template.
 *
 * Available variables (extracted by LearnDash):
 * $course_id, $course, $user_id, $logged_in, $course_status,
 * $has_access, $content, $materials, $post, $topics, $quizzes,
 * $show_content, $lesson_progression_enabled, $previous_lesson_completed,
 * $all_quizzes_completed, $lesson_settings
 *
 * @package PlumVillage
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

$lesson_id     = get_the_ID();
$course_post   = $course_id ? get_post( $course_id ) : null;
$course_steps  = $course_id ? learndash_get_course_steps( $course_id ) : array();
$lesson_index  = array_search( $lesson_id, $course_steps );
$total_lessons = count( $course_steps );
$lesson_number = false !== $lesson_index ? $lesson_index + 1 : 0;

// Previous/next lessons
$prev_lesson_id = ( false !== $lesson_index && $lesson_index > 0 ) ? $course_steps[ $lesson_index - 1 ] : null;
$next_lesson_id = ( false !== $lesson_index && $lesson_index < $total_lessons - 1 ) ? $course_steps[ $lesson_index + 1 ] : null;

// Completion status
$is_complete = false;
if ( $user_id && $course_id ) {
	$is_complete = learndash_is_lesson_complete( $user_id, $lesson_id, $course_id );
}
?>

<div class="<?php echo esc_attr( learndash_the_wrapper_class() ); ?>">

	<?php
	/**
	 * Fires before the lesson content.
	 *
	 * @param int $post_id   Post ID.
	 * @param int $course_id Course ID.
	 * @param int $user_id   User ID.
	 */
	do_action( 'learndash-lesson-before', get_the_ID(), $course_id, $user_id );
	?>

	<!-- Breadcrumb -->
	<nav style="font-size: var(--wp--preset--font-size--small); margin-bottom: var(--wp--preset--spacing--30); color: var(--wp--preset--color--warm-brown);">
		<a href="<?php echo esc_url( home_url( '/' ) ); ?>" style="color: var(--wp--preset--color--warm-brown);">Home</a>
		<span style="margin: 0 0.5rem;">&rsaquo;</span>
		<?php if ( $course_post ) : ?>
			<a href="<?php echo esc_url( get_permalink( $course_id ) ); ?>" style="color: var(--wp--preset--color--warm-brown);">
				<?php echo esc_html( $course_post->post_title ); ?>
			</a>
			<span style="margin: 0 0.5rem;">&rsaquo;</span>
		<?php endif; ?>
		<span style="color: var(--wp--preset--color--dark-text);"><?php the_title(); ?></span>
	</nav>

	<!-- Progress indicator -->
	<?php if ( $lesson_number > 0 ) : ?>
		<p style="font-size: var(--wp--preset--font-size--small); color: var(--wp--preset--color--warm-brown); margin-bottom: var(--wp--preset--spacing--20);">
			Lesson <?php echo esc_html( $lesson_number ); ?> of <?php echo esc_html( $total_lessons ); ?>
			<?php if ( $is_complete ) : ?>
				<span style="color: var(--wp--preset--color--forest-green); font-weight: 600;">&middot; &#10003; Complete</span>
			<?php endif; ?>
		</p>
	<?php endif; ?>

	<?php if ( $show_content ) : ?>

		<!-- Lesson content -->
		<?php if ( ! empty( $content ) ) : ?>
			<div style="line-height: 1.7; margin-bottom: var(--wp--preset--spacing--40);">
				<?php echo $content; // phpcs:ignore WordPress.Security.EscapeOutput.OutputNotEscaped ?>
			</div>
		<?php endif; ?>

		<!-- Mark Complete -->
		<?php if ( $logged_in && $course_id && ! $is_complete ) : ?>
			<div style="text-align: center; margin-bottom: var(--wp--preset--spacing--40);">
				<?php echo learndash_mark_complete( $course_id ); ?>
			</div>
		<?php elseif ( $logged_in && $is_complete ) : ?>
			<div style="text-align: center; margin-bottom: var(--wp--preset--spacing--40);">
				<span style="display: inline-block; padding: 0.75rem 2rem; background: var(--wp--preset--color--light-sage); color: var(--wp--preset--color--forest-green); border-radius: 4px; font-weight: 600;">
					&#10003; Lesson Complete
				</span>
			</div>
		<?php endif; ?>

	<?php endif; ?>

	<!-- Previous/Next Navigation -->
	<nav style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid var(--wp--preset--color--light-sage); padding-top: var(--wp--preset--spacing--30); margin-top: var(--wp--preset--spacing--30); gap: var(--wp--preset--spacing--20);">
		<div style="flex: 1;">
			<?php if ( $prev_lesson_id ) :
				$prev_post = get_post( $prev_lesson_id );
			?>
				<a href="<?php echo esc_url( get_permalink( $prev_lesson_id ) ); ?>" style="color: var(--wp--preset--color--warm-brown); text-decoration: none; font-size: var(--wp--preset--font-size--small);">
					<span style="display: block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 0.25rem;">&larr; Previous</span>
					<span style="font-family: var(--wp--preset--font-family--heading); font-size: var(--wp--preset--font-size--medium);">
						<?php echo esc_html( $prev_post->post_title ); ?>
					</span>
				</a>
			<?php endif; ?>
		</div>

		<div style="flex: 1; text-align: right;">
			<?php if ( $next_lesson_id ) :
				$next_post = get_post( $next_lesson_id );
			?>
				<a href="<?php echo esc_url( get_permalink( $next_lesson_id ) ); ?>" style="color: var(--wp--preset--color--warm-brown); text-decoration: none; font-size: var(--wp--preset--font-size--small);">
					<span style="display: block; font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 0.25rem;">Next &rarr;</span>
					<span style="font-family: var(--wp--preset--font-family--heading); font-size: var(--wp--preset--font-size--medium);">
						<?php echo esc_html( $next_post->post_title ); ?>
					</span>
				</a>
			<?php endif; ?>
		</div>
	</nav>

	<!-- Back to course -->
	<?php if ( $course_post ) : ?>
		<div style="text-align: center; margin-top: var(--wp--preset--spacing--30);">
			<a href="<?php echo esc_url( get_permalink( $course_id ) ); ?>" style="color: var(--wp--preset--color--warm-brown); font-size: var(--wp--preset--font-size--small);">
				&larr; Back to <?php echo esc_html( $course_post->post_title ); ?>
			</a>
		</div>
	<?php endif; ?>

	<?php
	/**
	 * Fires after the lesson content.
	 *
	 * @param int $post_id   Post ID.
	 * @param int $course_id Course ID.
	 * @param int $user_id   User ID.
	 */
	do_action( 'learndash-lesson-after', get_the_ID(), $course_id, $user_id );
	learndash_load_login_modal_html();
	?>

</div>
