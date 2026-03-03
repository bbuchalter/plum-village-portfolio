<?php
/**
 * Title: Course Feature Card
 * Slug: plum-village/course-feature
 * Categories: plum-village
 * Description: A featured course card with image placeholder, title, description, and call-to-action button.
 * Keywords: course, card, feature, learndash
 */
?>

<!-- wp:group {"style":{"spacing":{"padding":{"top":"0","bottom":"0","left":"0","right":"0"}},"border":{"radius":"8px","width":"1px","color":"var:preset|color|light-sage"}},"backgroundColor":"soft-white","layout":{"type":"constrained"}} -->
<div class="wp-block-group has-soft-white-background-color has-background" style="border-color:var(--wp--preset--color--light-sage);border-width:1px;border-radius:8px;padding-top:0;padding-right:0;padding-bottom:0;padding-left:0">
	<!-- wp:image {"sizeSlug":"large","style":{"border":{"radius":{"topLeft":"8px","topRight":"8px","bottomLeft":"0px","bottomRight":"0px"}}}} -->
	<figure class="wp-block-image size-large" style="border-top-left-radius:8px;border-top-right-radius:8px;border-bottom-left-radius:0px;border-bottom-right-radius:0px"><img src="" alt="Course image"/></figure>
	<!-- /wp:image -->

	<!-- wp:group {"style":{"spacing":{"padding":{"top":"var:preset|spacing|30","bottom":"var:preset|spacing|30","left":"var:preset|spacing|30","right":"var:preset|spacing|30"}}},"layout":{"type":"constrained"}} -->
	<div class="wp-block-group" style="padding-top:var(--wp--preset--spacing--30);padding-right:var(--wp--preset--spacing--30);padding-bottom:var(--wp--preset--spacing--30);padding-left:var(--wp--preset--spacing--30)">
		<!-- wp:paragraph {"style":{"typography":{"fontSize":"0.75rem","textTransform":"uppercase","letterSpacing":"0.15em","fontWeight":"600"}},"textColor":"muted-gold"} -->
		<p class="has-muted-gold-color has-text-color" style="font-size:0.75rem;font-weight:600;letter-spacing:0.15em;text-transform:uppercase">Featured Course</p>
		<!-- /wp:paragraph -->

		<!-- wp:heading {"level":3,"textColor":"forest-green","style":{"typography":{"fontSize":"1.35rem"},"spacing":{"margin":{"top":"var:preset|spacing|10","bottom":"var:preset|spacing|10"}}}} -->
		<h3 class="wp-block-heading has-forest-green-color has-text-color" style="font-size:1.35rem;margin-top:var(--wp--preset--spacing--10);margin-bottom:var(--wp--preset--spacing--10)">Foundations of Mindfulness</h3>
		<!-- /wp:heading -->

		<!-- wp:paragraph {"textColor":"dark-text","fontSize":"small","style":{"typography":{"lineHeight":"1.7"}}} -->
		<p class="has-dark-text-color has-text-color has-small-font-size" style="line-height:1.7">Begin your journey with the core practices of sitting meditation, walking meditation, and mindful breathing. This course offers a structured path through the foundational teachings of the Plum Village tradition.</p>
		<!-- /wp:paragraph -->

		<!-- wp:group {"layout":{"type":"flex","justifyContent":"space-between","flexWrap":"wrap","verticalAlignment":"center"}} -->
		<div class="wp-block-group">
			<!-- wp:paragraph {"textColor":"warm-brown","fontSize":"small","style":{"typography":{"fontStyle":"italic"}}} -->
			<p class="has-warm-brown-color has-text-color has-small-font-size" style="font-style:italic">8 lessons &middot; Self-paced</p>
			<!-- /wp:paragraph -->

			<!-- wp:buttons -->
			<div class="wp-block-buttons">
				<!-- wp:button {"backgroundColor":"forest-green","textColor":"cream","style":{"border":{"radius":"4px"},"spacing":{"padding":{"top":"0.6rem","bottom":"0.6rem","left":"1.5rem","right":"1.5rem"}},"typography":{"fontSize":"0.875rem"}}} -->
				<div class="wp-block-button"><a class="wp-block-button__link has-cream-color has-forest-green-background-color has-text-color has-background wp-element-button" href="/courses" style="border-radius:4px;padding-top:0.6rem;padding-right:1.5rem;padding-bottom:0.6rem;padding-left:1.5rem;font-size:0.875rem">Begin Course</a></div>
				<!-- /wp:button -->
			</div>
			<!-- /wp:buttons -->
		</div>
		<!-- /wp:group -->
	</div>
	<!-- /wp:group -->
</div>
<!-- /wp:group -->
